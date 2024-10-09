class Transaction < ApplicationRecord
    belongs_to :buyer, class_name: 'Colony'
    belongs_to :seller, class_name: 'Colony'
  
    validates :amount, numericality: { greater_than: 0 }
  
    after_create :finalize_transaction
  
    # Adjust accounts after a transaction
    def finalize_transaction
      buyer.account.update(balance: buyer.account.balance - amount)
      seller.account.update(balance: seller.account.balance + amount)
    end
end