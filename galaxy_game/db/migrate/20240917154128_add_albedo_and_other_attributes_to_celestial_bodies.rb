class AddAlbedoAndOtherAttributesToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :albedo, :float
    add_column :celestial_bodies, :insolation, :float
  end
end
