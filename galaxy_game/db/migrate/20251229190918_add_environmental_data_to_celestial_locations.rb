class AddEnvironmentalDataToCelestialLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_locations, :environmental_data, :jsonb
  end
end
