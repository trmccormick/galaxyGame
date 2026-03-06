class Settlement < ApplicationRecord
  has_many :transactions
  validates :name, presence: true
  validates :amount, numericality: { greater_than: 0 }

  def total_transactions
    transactions.sum(:amount)
  end
end