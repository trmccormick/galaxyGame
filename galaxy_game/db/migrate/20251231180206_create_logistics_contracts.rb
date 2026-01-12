class CreateLogisticsContracts < ActiveRecord::Migration[7.0]
  def change
    create_table :logistics_contracts do |t|
      t.references :from_settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.references :to_settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.string :material
      t.decimal :quantity
      t.string :transport_method
      t.integer :status
      t.datetime :scheduled_at
      t.datetime :completed_at
      t.json :operational_data

      t.timestamps
    end
  end
end
