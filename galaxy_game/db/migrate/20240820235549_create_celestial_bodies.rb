class CreateCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    create_table :celestial_bodies do |t|
      t.string :identifier, null: false, index: { unique: true }
      t.string :name
      t.string :type
      t.decimal :size
      t.decimal :gravity, precision: 10, scale: 2
      t.decimal :density, precision: 10, scale: 2
      t.decimal :orbital_period, precision: 10, scale: 2
      t.float :total_pressure
      t.jsonb :gas_quantities, default: {}
      t.jsonb :materials, default: {}
      t.decimal :mass, precision: 38, scale: 10
      t.float :radius   
      t.float :axial_tilt
      t.float :escape_velocity   

      # for moons
      t.string :parent_body

      t.timestamps
    end
  end
end
