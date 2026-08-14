class AllowNullFromSettlementForLogisticsContracts < ActiveRecord::Migration[7.0]
  def change
    change_column_null :logistics_contracts, :from_settlement_id, true
  end
end
