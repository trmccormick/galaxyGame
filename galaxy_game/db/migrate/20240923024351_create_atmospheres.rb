class CreateAtmospheres < ActiveRecord::Migration[7.0]
  def change
    create_table :atmospheres do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.float :temperature, default: 0
      t.float :pressure, default: 0
      t.json :composition, default: {}
      t.float :total_atmospheric_mass, default: 0
      t.json :dust, default: {}
      t.integer :pollution, default: 0

      # New fields for flexibility in handling lava tubes, crater domes, etc.
      t.string :environment_type, default: 'planetary' # Default to a planetary atmosphere
      t.boolean :sealing_status, default: false # Track if the environment is sealed (e.g., lava tube)
      t.json :gas_changes, default: {} # Track dynamic changes in composition (terraformed gases, etc.)
      t.float :dynamic_pressure, default: nil # Temporary adjustment for enclosed environments
      t.jsonb :base_values, default: {}, null: false  # Initial/reference values      

      t.timestamps
    end
  end
end