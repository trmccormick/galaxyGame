class CreateHydrospheres < ActiveRecord::Migration[7.0]
  def change
    create_table :hydrospheres do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.float :temperature, default: 0.0
      t.float :pressure, default: 0.0
      t.json :water_bodies, default: {}  # Stores information about oceans, rivers, lakes, etc.
      t.json :composition, default: {}   # Composition of the hydrosphere (H2O, salts, etc.)
      t.json :state_distribution, default: { liquid: 0.0, solid: 0.0, vapor: 0.0 }  # Distribution of states

      t.float :total_water_mass, default: 0.0  # Total mass of water in the hydrosphere
      t.integer :pollution, default: 0  # Pollution level, if applicable

      # New fields for flexibility in handling different states and water bodies
      t.string :environment_type, default: 'planetary'  # Default to planetary hydrosphere
      t.boolean :sealed_status, default: false  # Track if the environment is sealed (e.g., underground lake)
      t.json :water_changes, default: {}  # Track dynamic changes in water bodies (e.g., seasonal changes)

      t.float :dynamic_pressure, default: nil  # Temporary adjustment for sealed or confined water bodies
      t.jsonb :base_values, default: {}, null: false  # Initial/reference values

      t.timestamps
    end
  end
end