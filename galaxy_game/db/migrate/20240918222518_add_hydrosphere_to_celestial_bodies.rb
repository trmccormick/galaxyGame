class AddHydrosphereToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :oceans, :float, default: 0
    add_column :celestial_bodies, :lakes, :float, default: 0
    add_column :celestial_bodies, :rivers, :float, default: 0
    add_column :celestial_bodies, :ice, :float, default: 0
  end
end
