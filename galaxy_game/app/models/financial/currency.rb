# app/models/financial/currency.rb
module Financial
  class Currency < ApplicationRecord
    # A currency can optionally be issued by a polymorphic entity (e.g., a specific Colony, or the game system itself)
    belongs_to :issuer, polymorphic: true, optional: true

    # A currency can have many accounts and transactions associated with it
    has_many :accounts
    has_many :transactions

    # Validations for currency properties
    validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 } # e.g., "Martian Global Coin", "Galactic Crypto Coin"
    validates :symbol, presence: true, uniqueness: true, format: { with: /\A[A-Z0-9]{2,5}\z/, message: "must be 2-5 uppercase letters or numbers" } # e.g., "MGC", "GCC", "USD"
    validates :is_system_currency, inclusion: { in: [true, false] } # Is this a pre-defined system currency (like USD, GCC)?
    validates :precision, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 8 }, allow_nil: true # How many decimal places for this currency? (e.g., 2 for USD, 8 for some crypto)

    # Scope for easily finding system currencies
    scope :system_currencies, -> { where(is_system_currency: true) }
  end
end