class PlanetBiome < ApplicationRecord
    belongs_to :biome
    belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'

    # Phase 4 - TerraSim: Correct architecture is:
    # belongs_to :biosphere, class_name: 'CelestialBodies::Spheres::Biosphere'
    # NOT :celestial_body (legacy, to be removed in Phase 4)
    # See docs/architecture/biology/biome_model.md
end
  