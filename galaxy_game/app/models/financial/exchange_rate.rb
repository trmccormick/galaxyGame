# app/models/financial/exchange_rate.rb
module Financial
  class ExchangeRate < ApplicationRecord
    belongs_to :from_currency, class_name: 'Financial::Currency'
    belongs_to :to_currency, class_name: 'Financial::Currency'

    validates :from_currency, presence: true
    validates :to_currency, presence: true
    validates :rate, presence: true, numericality: { greater_than: 0 }

    # Ensure we don't have duplicate rates (same from/to pair)
    validates :from_currency_id, uniqueness: { scope: :to_currency_id }

    # Scope for finding rates
    scope :between, ->(from_symbol, to_symbol) {
      joins(:from_currency, :to_currency)
      .where(from_currency: { symbol: from_symbol })
      .where(to_currency: { symbol: to_symbol })
    }

    def self.get_rate(from_symbol, to_symbol)
      rate_record = between(from_symbol, to_symbol).first
      rate_record&.rate || 1.0
    end

    def self.set_rate(from_symbol, to_symbol, rate)
      from_currency = Financial::Currency.find_by(symbol: from_symbol)
      to_currency = Financial::Currency.find_by(symbol: to_symbol)

      return false unless from_currency && to_currency

      rate_record = between(from_symbol, to_symbol).first_or_initialize
      rate_record.rate = rate
      rate_record.save
    end
  end
end