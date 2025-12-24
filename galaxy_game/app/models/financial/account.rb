# app/models/financial/account.rb
module Financial
  class Account < ApplicationRecord
    # Validations: Changed to allow negative balances for the Ledger logic
    validates :balance, numericality: true
    validates :lock_version, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    belongs_to :accountable, polymorphic: true
    belongs_to :colony, optional: true
    belongs_to :currency, required: true
    has_many :transactions, dependent: :destroy

    def self.find_or_create_for_entity_and_currency(accountable_entity:, currency:)
      Account.find_or_create_by!(accountable: accountable_entity, currency: currency) do |account|
        account.balance = 0.0
        account.lock_version = 0
      end
    end

    def can_overdraft?
      # Logic for "Exodus: The Gateway Oligopoly"
      accountable_type == 'Colony' || (accountable.respond_to?(:is_npc?) && accountable.is_npc?)
    end

    def transfer_funds(amount, recipient_account, description = nil)
      raise ArgumentError, "Amount must be positive" if amount.nil? || amount <= 0
      raise "Cannot transfer between accounts of different currencies" if self.currency != recipient_account.currency

      # Check overdraft permission
      unless can_overdraft?
        raise "Insufficient funds" if amount > balance
      end

      Account.transaction do
        self.with_lock do
          recipient_account.with_lock do
            self.balance -= amount
            recipient_account.balance += amount

            transactions.create!(amount: -amount, description: description, transaction_type: :transfer, recipient: recipient_account.accountable, currency: self.currency)
            recipient_account.transactions.create!(amount: amount, description: description, transaction_type: :transfer, recipient: self.accountable, currency: recipient_account.currency)

            save!
            recipient_account.save!
          end
        end
      end
    rescue ActiveRecord::StaleObjectError
      raise "Concurrent modification detected. Please try again."
    end

    def deposit(amount, description = nil)
      raise ArgumentError, "Amount must be positive" if amount.nil? || amount <= 0

      Account.transaction do
        self.with_lock do
          self.balance += amount
          transactions.create!(amount: amount, description: description, transaction_type: :deposit, recipient: self.accountable, currency: self.currency)
          save!
        end
      end
    end

    def withdraw(amount, description = nil)
      raise ArgumentError, "Amount must be positive" if amount.nil? || amount <= 0
      
      # FIXED: Added the overdraft check here to match transfer_funds
      unless can_overdraft?
        raise "Insufficient funds" if amount > balance
      end

      Account.transaction do
        self.with_lock do
          self.balance -= amount
          transactions.create!(amount: -amount, description: description, transaction_type: :withdraw, recipient: self.accountable, currency: self.currency)
          save!
        end
      end
    end
  end
end