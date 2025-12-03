class CreateBiologyLifeForms < ActiveRecord::Migration[7.0]
  def change
    create_table :biology_life_forms do |t|
      # Reference to biosphere
      t.references :biosphere, null: false, foreign_key: { to_table: :biospheres }
      
      # Add type column for STI
      t.string :type
      
      # Basic attributes
      t.string :name, null: false
      t.integer :complexity, default: 0
      t.integer :domain, default: 0
      t.bigint :population, default: 1000
      t.jsonb :properties, default: {}
      t.string :preferred_biome
      
      # Physical properties
      t.decimal :mass, precision: 10, scale: 6, default: 0.1
      t.decimal :size_modifier, precision: 5, scale: 3, default: 1.0
      
      # Biological properties
      t.decimal :metabolism_rate, precision: 5, scale: 3, default: 0.1
      t.decimal :health_modifier, precision: 5, scale: 3, default: 1.0
      t.decimal :consumption_rate, precision: 5, scale: 3, default: 0.1
      t.decimal :foraging_efficiency, precision: 5, scale: 3, default: 0.5
      t.decimal :hunting_efficiency, precision: 5, scale: 3, default: 0.5
      
      # Population dynamics
      t.decimal :reproduction_rate, precision: 5, scale: 3, default: 0.05
      t.decimal :mortality_rate, precision: 5, scale: 3, default: 0.03
      
      # Atmosphere interaction
      t.decimal :o2_production_rate, precision: 8, scale: 6, default: 0.0
      t.decimal :co2_production_rate, precision: 8, scale: 6, default: 0.01
      t.decimal :methane_production_rate, precision: 8, scale: 6, default: 0.0

      t.timestamps
    end
    
    # Add index on type for better performance with STI
    add_index :biology_life_forms, :type
  end
end
