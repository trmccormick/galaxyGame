# app/models/transaction.rb
class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :recipient, polymorphic: true
  
  validates :amount, presence: true
  validates :transaction_type, inclusion: { in: %w[deposit withdraw transfer] }
  
  # Transactions can be positive (deposits) or negative (withdrawals)
  validates :amount, numericality: true
end
