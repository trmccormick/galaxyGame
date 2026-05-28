# app/models/market/market_order.rb (Renamed to Order)
module Market
    class Order < ApplicationRecord
      self.table_name = 'market_orders'

      belongs_to :market_condition,
                 class_name: 'Market::Condition',
                 foreign_key: 'market_condition_id'

      belongs_to :orderable, polymorphic: true
      belongs_to :base_settlement,
                 class_name: 'Settlement::BaseSettlement',
                 foreign_key: 'base_settlement_id'

      # Order types enum (assuming 0 = buy, 1 = sell based on common patterns)
      enum order_type: { buy: 0, sell: 1 }

      validates :quantity, presence: true
      validates :order_type, presence: true
      validates :resource, presence: true

      before_validation :set_resource_from_market_condition

      # Virtual attributes for price calculation
      def price_per_unit
        # Calculate price using NPC calculator
        if buy?
          Market::NpcPriceCalculator.calculate_bid(base_settlement, resource)
        else
          Market::NpcPriceCalculator.calculate_ask(base_settlement, resource)
        end
      end

      def total_cost
        price_per_unit * quantity
      end

      # Virtual attributes for expiration (24 hours from creation)
      def expires_at
        created_at + 24.hours
      end

      def expired?
        Time.current > expires_at
      end

      # Status based on expiration and fulfillment
      def status
        if expired?
          'expired'
        else
          'pending'
        end
      end

      # Mark as fulfilled
      def fulfill!
        unless update(fulfilled_at: Time.current)
          Rails.logger.error("Order##{id} failed to update fulfilled_at: #{errors.full_messages.join(', ')}")
        end
        fulfilled_at
      end

      private

      def set_resource_from_market_condition
        self.resource ||= market_condition&.resource
      end
    end
end