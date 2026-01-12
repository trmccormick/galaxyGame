# app/models/market/condition.rb
module Market
    class Condition < ApplicationRecord
      self.table_name = 'market_conditions'

      # TODO: Integrate with AIManager for automated buy/sell order listing and placement
      # TODO: Expand tests for edge cases, order matching, and supply chain creation
      # 🟢 CRITICAL FIX 1: Rename the association to market_orders
      has_many :market_orders, 
             class_name: 'Market::Order',
             foreign_key: 'market_condition_id', # This must be correct
             dependent: :destroy

      has_many :orders, class_name: 'Market::Order', foreign_key: 'market_condition_id', dependent: :destroy
      has_many :price_histories, class_name: 'Market::PriceHistory', foreign_key: 'market_condition_id', dependent: :destroy
      belongs_to :marketplace, class_name: 'Market::Marketplace', foreign_key: 'market_marketplace_id'
  
      # ... other attributes (resource, price, supply, demand, etc.)
  
      def current_price
          price_histories.order(created_at: :desc).first&.price || 10 # Default
      end
    end
end
