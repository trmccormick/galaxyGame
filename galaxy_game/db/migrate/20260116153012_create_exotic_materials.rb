class CreateExoticMaterials < ActiveRecord::Migration[7.0]
  def change
    create_table :exotic_materials do |t|
      t.string :name, null: false
      t.string :state
      t.references :geosphere, null: false, foreign_key: { to_table: :geospheres }
      t.integer :rarity, default: 0
      t.integer :stability, default: 0
      t.decimal :percentage, precision: 10, scale: 4
      t.decimal :mass, precision: 20, scale: 4

      t.timestamps
    end

    add_index :exotic_materials, [:geosphere_id, :name], unique: true
  end
end