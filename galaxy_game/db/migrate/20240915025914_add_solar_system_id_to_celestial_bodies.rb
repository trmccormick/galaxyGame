class AddSolarSystemIdToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :solar_system_id, :integer
  end
end
