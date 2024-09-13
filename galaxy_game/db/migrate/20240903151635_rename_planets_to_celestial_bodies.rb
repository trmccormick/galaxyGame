class RenamePlanetsToCelestialBodies < ActiveRecord::Migration[6.1]
  def change
    rename_table :planets, :celestial_bodies
  end
end
