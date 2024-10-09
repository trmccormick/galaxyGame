class CreateBaseUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :base_units do |t|
      t.string :name
      t.string :unit_type
      t.integer :capacity
      t.integer :energy_cost
      t.integer :production_rate
      t.string :gas_type
      t.json :resource_requirements
      t.json :material_list
      t.string :location_type
      t.integer :location_id 
      t.references :owner, polymorphic: true, null: false  

      t.timestamps
    end
  end
end
