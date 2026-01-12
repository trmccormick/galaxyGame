class AddColumnsToMarketSupplyChains < ActiveRecord::Migration[7.0]
  def change
    add_column :market_supply_chains, :market_order_id, :bigint
    add_reference :market_supply_chains, :sourceable, polymorphic: true, null: false
    add_reference :market_supply_chains, :destinationable, polymorphic: true, null: false
    add_column :market_supply_chains, :resource_name, :string
    add_column :market_supply_chains, :volume, :decimal
    add_column :market_supply_chains, :status, :string
  end
end
