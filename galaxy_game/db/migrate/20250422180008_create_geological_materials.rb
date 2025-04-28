class CreateGeologicalMaterials < ActiveRecord::Migration[7.0]
  def change
    create_table :geological_materials do |t|
      t.references :geosphere, null: false, foreign_key: true
      t.string :name, null: false
      t.string :layer, null: false, default: 'crust'
      t.decimal :percentage, precision: 10, scale: 6, default: 0
      t.decimal :mass, precision: 38, scale: 6, default: 0
      t.string :state, default: 'solid'
      t.decimal :melting_point
      t.decimal :boiling_point
      t.boolean :is_volatile, default: false
      t.string :category
      
      t.timestamps
    end
    
    add_index :geological_materials, [:geosphere_id, :name, :layer], unique: true
  end
end
