class CreateStructures < ActiveRecord::Migration[7.0]
  def change
    create_table :structures do |t|
      t.string :name, null: false
      t.string :structure_name, null: false
      t.string :structure_type, null: false
      t.references :settlement, foreign_key: { to_table: :base_settlements }
      t.references :owner, polymorphic: true, null: false
      t.references :container_structure, foreign_key: { to_table: :structures }, null: true
      t.references :location, polymorphic: true, null: true
      t.integer :current_population, default: 0
      t.jsonb :operational_data, default: {}
      
      t.timestamps
    end
    
    add_index :structures, :name, unique: true
    add_index :structures, [:structure_name, :structure_type]
    add_index :structures, :operational_data, using: :gin
  end
end