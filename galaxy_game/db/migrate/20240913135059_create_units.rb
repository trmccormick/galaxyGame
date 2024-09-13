class CreateUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :units do |t|
      t.string :name
      t.string :unit_type
      t.integer :capacity
      t.integer :energy_cost
      t.integer :production_rate
      t.string :gas_type
      t.json :resource_requirements

      t.timestamps
    end
  end
end
