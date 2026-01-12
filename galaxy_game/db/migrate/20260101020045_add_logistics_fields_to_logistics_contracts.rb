class AddLogisticsFieldsToLogisticsContracts < ActiveRecord::Migration[7.0]
  def change
    add_column :logistics_contracts, :provider_name, :string unless column_exists?(:logistics_contracts, :provider_name)
    add_column :logistics_contracts, :shipping_cost, :decimal, precision: 10, scale: 2 unless column_exists?(:logistics_contracts, :shipping_cost)
    add_column :logistics_contracts, :started_at, :datetime unless column_exists?(:logistics_contracts, :started_at)
    # completed_at already exists from the original migration
  end
end
