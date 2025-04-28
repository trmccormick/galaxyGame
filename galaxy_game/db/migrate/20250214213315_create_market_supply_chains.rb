class CreateMarketSupplyChains < ActiveRecord::Migration[7.0]
  def change
    create_table :market_supply_chains do |t|

      t.timestamps
    end
  end
end
