class AddPropertiesToPlanetBiomes < ActiveRecord::Migration[7.0]
  def change
    add_column :planet_biomes, :properties, :jsonb
  end
end
