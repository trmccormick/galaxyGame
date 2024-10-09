module CelestialBodies
  class Biosphere < ApplicationRecord
    belongs_to :celestial_body
    has_many :planet_biomes
    has_many :biomes, through: :planet_biomes

    attribute :temperature_tropical, :float, default: 300.0
    attribute :temperature_polar, :float, default: 250.0
    attribute :biodiversity_index, :float, default: 0.0
    attribute :habitable_area, :float, default: 0.0
    attribute :biome_distribution, :json, default: {}

    def simulate_biome_management
      BiosphereSimulationService.new(self.celestial_body).balance_biomes
    end

    def introduce_biome(biome)
      planet_biomes.create(biome: biome)
      simulate_biome_management
    end

    def remove_biome(biome)
      planet_biomes.find_by(biome: biome)&.destroy
      simulate_biome_management
    end
  end
end
