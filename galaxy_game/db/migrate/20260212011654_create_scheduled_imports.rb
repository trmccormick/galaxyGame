class CreateScheduledImports < ActiveRecord::Migration[7.0]
  def change
    create_table :scheduled_imports do |t|
      t.string :material
      t.decimal :quantity
      t.string :source
      t.integer :destination_id, null: false
      t.decimal :transport_cost
      t.datetime :delivery_eta
      t.integer :status

      t.timestamps
    end
    add_foreign_key :scheduled_imports, :base_settlements, column: :destination_id
  end
end
