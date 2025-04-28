class CreateMaterialPiles < ActiveRecord::Migration[7.0]
  def change
    create_table :material_piles do |t|
      t.references :surface_storage, null: false, foreign_key: true
      t.string :material_type, null: false
      t.decimal :amount, precision: 20, scale: 2, null: false, default: 0
      t.decimal :quality_factor, precision: 4, scale: 3, null: false, default: 1.0
      t.json :coordinates
      t.decimal :height
      t.decimal :spread_radius

      t.timestamps
    end

    add_index :material_piles, [:surface_storage_id, :material_type]
  end
end
