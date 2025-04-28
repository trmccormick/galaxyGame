class CreateGeospheres < ActiveRecord::Migration[7.0]
  def change
    create_table :geospheres do |t|
      t.references :celestial_body, null: false, foreign_key: true

      # Storing compositions as JSON objects - keeping for compatibility
      t.json :crust_composition, default: {}    # Composition of the crust as a JSON object
      t.json :mantle_composition, default: {}   # Composition of the mantle as a JSON object
      t.json :core_composition, default: {}     # Composition of the core as a JSON object

      # Total mass for each layer
      t.float :total_crust_mass, default: 0.0   # Total mass of the crust
      t.float :total_mantle_mass, default: 0.0  # Total mass of the mantle
      t.float :total_core_mass, default: 0.0    # Total mass of the core

      t.float :temperature, default: 0.0        # Temperature of the geosphere
      t.float :pressure, default: 0.0           # Pressure of the geosphere
      t.float :geological_activity, default: 0.0 # Geological activity intensity (numeric scale)
      t.boolean :tectonic_activity, default: false # Tectonic activity flag

      t.jsonb :base_values, default: {}, null: false  # Initial/reference values

      t.timestamps
    end
  end
end

