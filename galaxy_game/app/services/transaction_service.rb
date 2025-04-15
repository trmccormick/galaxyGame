class TransactionService
  def self.process_transaction(buyer:, seller:, amount:)
    ActiveRecord::Base.transaction do
      # Check for sufficient funds
      if buyer.account.balance < amount
        Rails.logger.error("Transaction failed: Buyer #{buyer.name} has insufficient funds.")
        raise StandardError, "Insufficient funds"
      end

      # Update buyer's account
      buyer.account.update!(balance: buyer.account.balance - amount)
      Rails.logger.info("Buyer #{buyer.name}'s account debited by #{amount}.")

      # Update seller's account
      seller.account.update!(balance: seller.account.balance + amount)
      Rails.logger.info("Seller #{seller.name}'s account credited by #{amount}.")

      # Create transaction record - use your existing schema
      Transaction.create!(
        account: buyer.account,
        recipient: seller,
        amount: -amount,  # Negative because money is leaving the account
        transaction_type: 'transfer',
        description: "Payment from #{buyer.name} to #{seller.name}"
      )
      
      # Also create a corresponding record for the seller's account
      Transaction.create!(
        account: seller.account,
        recipient: buyer,
        amount: amount,  # Positive because money is entering the account
        transaction_type: 'transfer',
        description: "Payment from #{buyer.name} to #{seller.name}"
      )
      
      Rails.logger.info("Transaction recorded: Buyer #{buyer.name} paid Seller #{seller.name} #{amount}.")
      
      true
    end
  rescue StandardError => e
    # Handle exceptions
    Rails.logger.error("Transaction failed: #{e.message}")
    raise
  end
end
