# --- app/models/market/trade.rb (Fixed with volume alias) ---
module Market
  class Trade < ApplicationRecord
    self.table_name = 'market_trades' 
    
    belongs_to :buyer, polymorphic: true
    belongs_to :seller, polymorphic: true
    belongs_to :buyer_settlement, class_name: 'Settlement::BaseSettlement'
    belongs_to :seller_settlement, class_name: 'Settlement::BaseSettlement'
    
    # FIX: Add an alias so tests expecting 'volume' will work
    alias_attribute :volume, :quantity
  end
end