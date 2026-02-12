class CreateScheduledImports < ActiveRecord::Migration[7.0]
  def change
    create_table :scheduled_imports do |t|
      t.string :material, null: false
      t.decimal :quantity, precision: 15, scale: 2, null: false
      t.string :source, null: false
      t.references :destination_settlement, null: false, foreign_key: { to_table: :settlements }
      t.decimal :transport_cost, precision: 15, scale: 2, null: false
      t.datetime :delivery_eta, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :scheduled_imports, [:status, :delivery_eta]
    add_index :scheduled_imports, :material
  end
end</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/galaxy_game/db/migrate/20240211000000_create_scheduled_imports.rb