class AddOrbitalDistanceKmToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :orbital_distance_km, :decimal, precision: 15, scale: 2, default: 0.0
  end
end
