class AddTerrestrialPlanetAttributesToCelestialBodies < ActiveRecord::Migration[6.1]
  def change
    add_column :celestial_bodies, :surface_temperature, :float
    add_column :celestial_bodies, :atmosphere_composition, :text
    add_column :celestial_bodies, :geological_activity, :boolean, default: false
  end
end
