# app/models/account.rb
class Account < ApplicationRecord
  belongs_to :accountable, polymorphic: true
  belongs_to :colony, optional: true # Based on your schema
  belongs_to :currency, class_name: 'Financial::Currency', required: true
  has_many :transactions, dependent: :destroy

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def transfer_funds(amount, recipient_account, description = nil)
    raise "Insufficient funds" if amount > balance

    ActiveRecord::Base.transaction do
      begin
        # Deduct from sender account
        self.balance -= amount

        # Add to recipient account
        recipient_account.balance += amount

        # Save both accounts first
        save!
        recipient_account.save!

        # Create transaction records after accounts are saved
        transactions.create!(
          amount: -amount,
          description: description,
          transaction_type: 'transfer',
          recipient: recipient_account.accountable, # The recipient entity
          currency: self.currency
        )

        recipient_account.transactions.create!(
          amount: amount,
          description: description,
          transaction_type: 'transfer',
          recipient: self.accountable, # The sender entity
          currency: self.currency
        )
      rescue ActiveRecord::RecordInvalid => e
        raise ActiveRecord::Rollback, e.message
      end
    end
  end

  def deposit(amount, description = nil)
    raise ArgumentError, "Amount must be positive" if amount <= 0

    ActiveRecord::Base.transaction do
      begin
        # Add to balance
        self.balance += amount

        # Save account first
        save!

        # Create transaction record after account is saved
        transactions.create!(
          amount: amount,
          description: description,
          transaction_type: 'deposit',
          recipient: self.accountable, # Deposit to self
          currency: self.currency
        )
      rescue ActiveRecord::RecordInvalid => e
        raise ActiveRecord::Rollback, e.message
      end
    end
  end

  def withdraw(amount, description = nil)
    raise "Insufficient funds" if amount > balance

    ActiveRecord::Base.transaction do
      begin
        # Subtract from balance
        self.balance -= amount

        # Save account first
        save!

        # Create transaction record after account is saved
        transactions.create!(
          amount: -amount,  # Negative amount for withdrawals
          description: description,
          transaction_type: 'withdraw',
          recipient: self.accountable, # Withdraw from self
          currency: self.currency
        )
      rescue ActiveRecord::RecordInvalid => e
        raise ActiveRecord::Rollback, e.message
      end
    end
  end
end

