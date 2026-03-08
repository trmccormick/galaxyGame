class AddCelestialBodyToPlanetBiomes < ActiveRecord::Migration[7.0]
  def change
    add_reference :planet_biomes, :celestial_body, 
                  null: false, 
                  foreign_key: { to_table: 'celestial_bodies' },
                  index: true
    # Backfill existing records if needed
    PlanetBiome.update_all(celestial_body_id: CelestialBodies::CelestialBody.first.id) rescue nil
  end
end
