# app/services/financial/transaction_manager.rb (Updated signature)
module Financial
  class TransactionManager
    # Note: Using description: nil instead of memo: nil
    def self.create_transfer(from: nil, to: nil, amount: nil, currency: nil, description: nil)
      Financial::Transaction.create!(
        account: from, 
        recipient: to, 
        amount: amount,
        currency: currency,
        transaction_type: 'tax_collection',
        description: description # <--- CHANGED FROM :memo TO :description
      )
    end
  end
end