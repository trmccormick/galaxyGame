class CreateScheduledImports < ActiveRecord::Migration[7.0]
  def change
    create_table :scheduled_imports do |t|
      t.string :material
      t.decimal :quantity
      t.string :source
      t.references :source_settlement, foreign_key: { to_table: :base_settlements }, optional: true
      t.references :destination_settlement, foreign_key: { to_table: :base_settlements }, null: false
      t.decimal :transport_cost
      t.datetime :delivery_eta
      t.integer :status

      t.timestamps
    end
  end
end
