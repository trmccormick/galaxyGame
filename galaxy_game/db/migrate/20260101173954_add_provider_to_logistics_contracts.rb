class AddProviderToLogisticsContracts < ActiveRecord::Migration[7.0]
  def change
    add_reference :logistics_contracts, :provider, null: true, foreign_key: { to_table: :logistics_providers }
  end
end
