class AddLogisticsContractFields < ActiveRecord::Migration[6.1]
  def change
    add_column :logistics_contracts, :arrives_at, :datetime
    add_column :logistics_contracts, :eap_at_order_time, :decimal, precision: 12, scale: 2
    add_column :logistics_contracts, :emergency, :boolean, default: false, null: false
    add_column :logistics_contracts, :initiated_by_type, :string
    add_column :logistics_contracts, :initiated_by_id, :bigint
    add_column :logistics_contracts, :failure_reason, :string

    add_index :logistics_contracts, [:initiated_by_type, :initiated_by_id], name: 'idx_log_contracts_on_initiator_type_and_id'
    add_index :logistics_contracts, :arrives_at
    add_index :logistics_contracts, :emergency
  end
end
