module Financial
  class Account < ApplicationRecord
    validates :balance, numericality: { greater_than_or_equal_to: 0 }
    belongs_to :accountable, polymorphic: true
    belongs_to :colony, optional: true
    belongs_to :currency, required: true

    has_many :transactions, dependent: :destroy

    # PATCH: Allow negative balances during development
    # validates :balance, numericality: { greater_than_or_equal_to: 0 }
    validates :balance, numericality: true
    validates :lock_version, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    # --- NEW CLASS METHOD ---
    # Finds an existing account for a given entity and currency, or creates a new one.
    # Useful for automatically provisioning accounts when funds are to be deposited or received.
    #
    # @param accountable_entity [Object] The entity (Player, Organization, Colony, etc.) that owns the account.
    # @param currency [Currency] The Currency object for this account.
    # @return [Account] The found or newly created Account object.
    def self.find_or_create_for_entity_and_currency(accountable_entity:, currency:)
      # find_or_create_by! will find the record if it exists, or create it if not.
      # The block is executed only if a new record is being created.
      Account.find_or_create_by!(accountable: accountable_entity, currency: currency) do |account|
        account.balance = 0.0 # New accounts typically start with a zero balance
        account.lock_version = 0 # Ensure default lock_version is set
        # Any other default attributes for a new account could go here
      end
    end
    # --- END NEW CLASS METHOD ---

    def can_overdraft?
      # This is where the "Oligopoly" logic lives. 
      # If the owner is a Colony or a specific NPC Organization, they can go negative.
      accountable_type == 'Colony' || (accountable.respond_to?(:is_npc?) && accountable.is_npc?)
    end

    # Public method for transferring funds between accounts
    # This method requires both accounts to have the same Currency object.
    def transfer_funds(amount, recipient_account, description = nil)
      raise ArgumentError, "Amount must be positive" if amount.nil? || amount <= 0
      raise "Cannot transfer between accounts of different currencies (#{self.currency.symbol} to #{recipient_account.currency.symbol})" if self.currency != recipient_account.currency

      # Logic adjustment: Only check for insufficient funds if they CANNOT overdraft
      unless can_overdraft?
        raise "Insufficient funds" if amount > balance
      end

      Account.transaction do
        self.with_lock do
          recipient_account.with_lock do
            self.balance -= amount
            recipient_account.balance += amount

            transactions.create!(
              amount: -amount,
              description: description,
              transaction_type: :transfer,
              recipient: recipient_account.accountable,
              currency: self.currency
            )

            recipient_account.transactions.create!(
              amount: amount,
              description: description,
              transaction_type: :transfer,
              recipient: self.accountable,
              currency: recipient_account.currency
            )

            save!
            recipient_account.save!
          end
        end
      end
    rescue ArgumentError => e
      raise e  # Re-raise ArgumentError as-is
    rescue ActiveRecord::RecordInvalid => e
      raise "Transaction failed due to validation error: #{e.message}"
    rescue ActiveRecord::StaleObjectError
      raise "Concurrent modification detected. Please try again."
    end

    # Public method for depositing funds into this account
    def deposit(amount, description = nil)
      raise ArgumentError, "Amount must be positive" if amount.nil? || amount <= 0

      Account.transaction do
        self.with_lock do
          self.balance += amount

          transactions.create!(
            amount: amount,
            description: description,
            transaction_type: :deposit,
            recipient: self.accountable,
            currency: self.currency
          )

          save!
        end
      end
    rescue ArgumentError => e
      raise e  # Re-raise ArgumentError as-is
    rescue ActiveRecord::RecordInvalid => e
      raise "Deposit failed due to validation error: #{e.message}"
    rescue ActiveRecord::StaleObjectError
      raise "Concurrent modification detected during deposit. Please try again."
    end

    # Public method for withdrawing funds from this account
    def withdraw(amount, description = nil)
      raise ArgumentError, "Amount must be positive" if amount.nil? || amount <= 0
      raise "Insufficient funds" if amount > balance

      Account.transaction do
        self.with_lock do
          self.balance -= amount

          transactions.create!(
            amount: -amount,
            description: description,
            transaction_type: :withdraw,
            recipient: self.accountable,
            currency: self.currency
          )

          save!
        end
      end
    rescue ArgumentError => e
      raise e  # Re-raise ArgumentError as-is
    rescue ActiveRecord::RecordInvalid => e
      raise "Withdrawal failed due to validation error: #{e.message}"
    rescue ActiveRecord::StaleObjectError
      raise "Concurrent modification detected during withdrawal. Please try again."
    end
  end
end