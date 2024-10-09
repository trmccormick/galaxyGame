class PlanetBiome < ApplicationRecord
    belongs_to :biome
    belongs_to :celestial_body
end
  