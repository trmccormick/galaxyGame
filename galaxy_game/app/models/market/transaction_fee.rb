# app/models/market/transaction_fee.rb (If you want a separate model)
module Market
    class TransactionFee < ApplicationRecord
      self.table_name = 'market_transaction_fees'
      validates :fee_type, presence: true, inclusion: { in: %w[percentage fixed] }
      validates :percentage, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :fixed_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

      def calculate(amount)
        case fee_type
        when 'percentage'
          (amount * (percentage || 0) / 100.0).round(2)
        when 'fixed'
          fixed_amount || 0
        else
          0
        end
      end
    end
end