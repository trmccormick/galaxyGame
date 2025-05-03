class CreateExoticMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :exotic_materials do |t|
      t.string :name, null: false
      t.string :state, default: 'solid'
      t.decimal :mass, precision: 20, scale: 4, default: 0
      t.decimal :percentage, precision: 8, scale: 4
      t.integer :rarity, default: 50
      t.integer :stability, default: 50
      t.references :geosphere, null: false, foreign_key: true
      t.jsonb :properties, default: {}

      t.timestamps
    end

    add_index :exotic_materials, :name
    add_index :exotic_materials, :state
  end
end
