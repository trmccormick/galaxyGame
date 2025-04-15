# app/models/transaction.rb
class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :recipient, polymorphic: true
  
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true, inclusion: { in: %w[deposit withdraw transfer] }
end
