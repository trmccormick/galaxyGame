class UpdateScheduledImportsTable < ActiveRecord::Migration[7.0]
  def change
    rename_column :scheduled_imports, :destination_id, :destination_settlement_id
    add_reference :scheduled_imports, :source_settlement, foreign_key: { to_table: :base_settlements }, optional: true
  end
end
