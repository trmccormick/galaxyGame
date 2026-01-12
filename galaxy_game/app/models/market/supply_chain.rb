# --- app/models/market/supply_chain.rb (Minimal Definition) ---
module Market
  class SupplyChain < ApplicationRecord
    self.table_name = 'market_supply_chains'

    # Associations (Essential for linking to the trade)
    # The market order (or trade) that generated this supply chain
    # Assuming your trade/order model is named Market::Order
    belongs_to :market_order, class_name: 'Market::Order', foreign_key: 'market_order_id' 

    # Attributes (Assuming the table has these foreign keys/columns)
    # t.bigint :market_order_id
    # t.string :resource_name
    # t.decimal :volume
    # t.string :status, default: 'pending' 

    # Example: A status scope
    scope :active, -> { where.not(status: ['delivered', 'cancelled']) }
  end
end