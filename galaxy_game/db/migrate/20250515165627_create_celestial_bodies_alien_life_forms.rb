class CreateCelestialBodiesAlienLifeForms < ActiveRecord::Migration[7.0]
  def change
    create_table :celestial_bodies_alien_life_forms do |t|
      # Here's the fix - point to the actual table name
      t.references :biosphere, null: false, foreign_key: { to_table: :biospheres }
      
      t.string :name, null: false
      t.integer :complexity, default: 0
      t.integer :domain, default: 0
      t.integer :population, default: 1000
      t.jsonb :properties, default: {}
      t.string :preferred_biome
      t.decimal :mass, precision: 10, scale: 6, default: 0.1
      t.decimal :metabolism_rate, precision: 5, scale: 3, default: 0.1
      t.decimal :health_modifier, precision: 5, scale: 3, default: 1.0
      t.decimal :size_modifier, precision: 5, scale: 3, default: 1.0
      t.decimal :consumption_rate, precision: 5, scale: 3, default: 0.1
      t.decimal :foraging_efficiency, precision: 5, scale: 3, default: 0.5
      t.decimal :hunting_efficiency, precision: 5, scale: 3, default: 0.5
      t.decimal :reproduction_rate, precision: 5, scale: 3, default: 0.05
      t.decimal :mortality_rate, precision: 5, scale: 3, default: 0.03
      t.decimal :o2_production_rate, precision: 8, scale: 6, default: 0.0
      t.decimal :co2_production_rate, precision: 8, scale: 6, default: 0.01
      t.decimal :methane_production_rate, precision: 8, scale: 6, default: 0.0

      t.timestamps
    end
  end
end
