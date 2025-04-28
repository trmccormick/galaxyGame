class CreateSurfaceStorages < ActiveRecord::Migration[7.0]
  def change
    create_table :surface_storages do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :celestial_body, null: false, foreign_key: true
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.string :name
      t.jsonb :properties, default: {}
      t.timestamps
    end

    # Add indexes for performance
    add_index :surface_storages, [:inventory_id, :celestial_body_id], unique: true
  end
end
