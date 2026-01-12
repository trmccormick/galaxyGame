# --- app/models/market/price_history.rb (The required fix) ---
module Market
    class PriceHistory < ApplicationRecord
      # FIX: Explicitly set the table name to match the schema
      self.table_name = 'market_price_histories' 
      
      # 🟢 CRITICAL FIX: Add class_name: 'Market::Condition'
      belongs_to :market_condition, 
                class_name: 'Market::Condition', 
                foreign_key: 'market_condition_id'
      
      validates :price, presence: true
    end
end