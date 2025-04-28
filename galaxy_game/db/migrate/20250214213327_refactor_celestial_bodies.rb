class RefactorCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    change_table :celestial_bodies do |t|
      # Keep core identifying fields
      t.remove :greenhouse_temp, :polar_temp, :tropic_temp, :delta_t,
               :ice_latitude, :habitability_ratio, :methane_concentration,
               :ammonia_concentration, :hydrogen_concentration, 
               :helium_concentration, :atmosphere_composition,
               :gases, :pressure, :temperature

      # Add consolidated JSONB fields
      t.jsonb :base_values, default: {}, null: false  # Initial/reference values
      t.jsonb :current_values, default: {}, null: false  # Current state
    end
  end
end