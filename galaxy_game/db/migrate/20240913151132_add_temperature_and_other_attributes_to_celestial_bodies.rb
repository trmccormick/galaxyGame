class AddTemperatureAndOtherAttributesToCelestialBodies < ActiveRecord::Migration[6.1]
  def change
    add_column :celestial_bodies, :greenhouse_temp, :string
    add_column :celestial_bodies, :polar_temp, :string
    add_column :celestial_bodies, :tropic_temp, :string
    add_column :celestial_bodies, :delta_t, :string
    add_column :celestial_bodies, :ice_latitude, :string
    add_column :celestial_bodies, :habitability_ratio, :string
  end
end
