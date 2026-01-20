# app/models/transaction.rb
class Transaction < ApplicationRecord
  belongs_to :account, class_name: 'Financial::Account'
  belongs_to :recipient, polymorphic: true
  belongs_to :currency, class_name: 'Financial::Currency', required: true
  
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true, inclusion: { in: %w[deposit withdraw transfer] }
end
