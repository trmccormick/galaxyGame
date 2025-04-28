class CreateBaseModules < ActiveRecord::Migration[7.0]
  def change
    create_table :base_modules do |t|
      t.string :identifier, null: false, index: { unique: true }       
      t.string :name, null: false
      t.string :description
      t.string :module_type, null: false
      t.integer :energy_cost
      t.json :maintenance_materials 
      t.string :module_class
      t.jsonb :operational_data, default: {}
      t.references :attachable, polymorphic: true, null: true  # Polymorphic association for unit or craft

      t.timestamps
    end

    add_index :base_modules, :operational_data, using: :gin
  end
end