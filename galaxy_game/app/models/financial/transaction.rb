module Financial
  class Transaction < ApplicationRecord
    # --- Structural Fix ---
    self.table_name = 'transactions' # <--- ADDED LINE

    belongs_to :account
    belongs_to :recipient, polymorphic: true

    # A transaction must now belong to a specific Currency object
    belongs_to :currency

    # Define transaction types as an enum for better maintainability and data integrity
    enum transaction_type: { 
      deposit: 'deposit', 
      withdraw: 'withdraw', 
      transfer: 'transfer', 
      tax_collection: 'tax_collection' 
    }

    # Validations
    validates :amount, presence: true, numericality: { other_than: 0 }
    validates :transaction_type, presence: true
    validates :currency, presence: true
    validates :account, presence: true
  end
end