# app/models/financial/bond.rb
module Financial
  class Bond < ApplicationRecord
    belongs_to :issuer, polymorphic: true
    belongs_to :holder, polymorphic: true
    belongs_to :currency

    enum status: { issued: "issued", paid: "paid", defaulted: "defaulted" }

    has_many :repayments, class_name: "Financial::BondRepayment", dependent: :destroy

    validates :amount, numericality: { greater_than: 0 }
    validates :issued_at, presence: true
    validates :status, presence: true

    # Returns the total repaid (in face currency, using exchange rates if needed)
    def total_repaid(exchange_rate_service = nil)
      repayments.sum do |repayment|
        if repayment.currency_id == currency_id
          repayment.amount
        else
          # Use exchange rate service to convert to bond currency
          exchange_rate_service.convert(repayment.amount, repayment.currency_id, currency_id)
        end
      end
    end

    def paid_off?(exchange_rate_service = nil)
      total_repaid(exchange_rate_service) >= amount
    end
  end
end