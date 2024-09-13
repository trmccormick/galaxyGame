class AddKnownPressureToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :known_pressure, :float
  end
end
