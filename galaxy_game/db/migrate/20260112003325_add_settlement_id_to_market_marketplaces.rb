class AddSettlementIdToMarketMarketplaces < ActiveRecord::Migration[7.0]
  def change
    add_reference :market_marketplaces, :settlement, foreign_key: { to_table: :base_settlements }, index: true
  end
end
