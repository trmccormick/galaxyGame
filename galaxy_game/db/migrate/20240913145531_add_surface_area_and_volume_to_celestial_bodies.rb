class AddSurfaceAreaAndVolumeToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :surface_area, :float
    add_column :celestial_bodies, :volume, :float
  end
end
