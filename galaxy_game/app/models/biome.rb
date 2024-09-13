# app/models/biome.rb

class Biome < ApplicationRecord
    # Validations
    validates :name, presence: true, uniqueness: true
    validates :temperature_range, presence: true
    validates :humidity_range, presence: true
  
    # Associations
    has_many :planet_biomes
    has_many :planets, through: :planet_biomes
  
    # Define biomes based on temperature and humidity
    def self.biomes_for_conditions(temperature, humidity)
      where('temperature_range @> ? AND humidity_range @> ?', temperature, humidity)
    end
  
    # Example method to get biome suitability
    def suitable_for?(temperature, humidity)
      temperature_range.cover?(temperature) && humidity_range.cover?(humidity)
    end
  
    # Example of a method to handle biome-specific logic
    def handle_biome_logic(planet)
      # Implement specific logic for how this biome interacts with the planet
    end
end