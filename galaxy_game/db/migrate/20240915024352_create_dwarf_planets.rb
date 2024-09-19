class CreateDwarfPlanets < ActiveRecord::Migration[7.0]
  def change
    create_table :dwarf_planets do |t|
      t.string :name
      t.float :mass
      t.float :surface_temperature
      t.text :atmosphere_composition
      t.float :atmospheric_pressure
      t.references :solar_system, null: false, foreign_key: true

      t.timestamps
    end
  end
end
