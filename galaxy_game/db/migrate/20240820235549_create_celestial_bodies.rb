# db/migrate/20240820235549_create_celestial_bodies.rb
class CreateCelestialBodies < ActiveRecord::Migration[7.0] # Ensure this matches your Rails version
  def change
    create_table :celestial_bodies do |t|
      t.string :identifier, null: false, index: { unique: true }
      t.string :name
      t.string :type # For Single Table Inheritance (STI)
      t.decimal :size # Consider precision/scale if this is a ratio
      t.decimal :gravity, precision: 10, scale: 2
      t.decimal :density, precision: 10, scale: 2
      t.decimal :orbital_period, precision: 10, scale: 2
      # t.jsonb :gas_quantities, default: {} # Review if this is still needed with Atmosphere model
      # t.jsonb :materials, default: {} # REMOVED: Assumed to be a `has_many :materials` association to a separate table/model

      t.decimal :mass, precision: 38, scale: 10 # High precision for astronomical masses
      t.decimal :radius, precision: 15, scale: 5 # Changed from float to decimal for better precision
      t.decimal :axial_tilt, precision: 5, scale: 2 # Changed from float to decimal
      t.decimal :escape_velocity, precision: 10, scale: 5 # Changed from float to decimal
      
      # INCREASED PRECISION for surface_area and volume to handle large astronomical values
      t.decimal :surface_area, precision: 22, scale: 5 # Increased from 20 to 22 (allows up to 10^17 - 1)
      t.decimal :volume, precision: 30, scale: 5 # Increased from 25 to 30 (allows up to 10^25 - 1)

      t.integer :status, default: 0, null: false
      t.decimal :known_pressure, precision: 10, scale: 5, default: 0.0, null: false # Changed from float to decimal

      # CRITICAL FIX: Foreign key for parent-child relationship (for moons/satellites)
      # This column stores the ID of the parent CelestialBody
      t.references :parent_celestial_body, foreign_key: { to_table: :celestial_bodies }, index: true, null: true

      t.jsonb :properties, default: {}, null: false # For miscellaneous dynamic properties

      # t.string :parent_body # REMOVED: This string field is no longer needed.
                             # The builder resolves the string identifier to an ID.

      t.timestamps
    end
  end
end