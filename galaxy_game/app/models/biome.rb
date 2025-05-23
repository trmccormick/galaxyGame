# app/models/biome.rb

# Temperature in this model is stored in Kelvin.
# Methods that accept temperature will auto-convert from Celsius if the value is < 200.

class Biome < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :temperature_range, presence: true
  validates :humidity_range, presence: true

  # Associations
  has_many :planet_biomes, class_name: 'CelestialBodies::PlanetBiome', dependent: :destroy
  has_many :celestial_bodies, through: :planet_biomes

  # Safe range parser
  def safe_range_parser(value)
    if value.is_a?(String) && value.match?(/\A-?\d+..-?\d+\z/)
      eval(value)
    else
      value
    end
  end

  def climate_type
    # This is a simplified example. You'll want to refine this logic
    # to match your game's specific climate definitions.
    # Use the optimal_temperature or temperature_range for classification.

    avg_temp = optimal_temperature # Use the method we just added
    avg_humidity = (humidity_range.min + humidity_range.max) / 2.0 if humidity_range.is_a?(Range)

    case
    when avg_temp && avg_temp > 295 && avg_humidity && avg_humidity > 70
      'tropical'
    when avg_temp && avg_temp > 275 && avg_humidity && avg_humidity > 50
      'temperate_wet' # Or 'temperate'
    when avg_temp && avg_temp < 265
      'polar'
    when avg_humidity && avg_humidity < 30
      'arid'
    else
      'other' # Default or more specific types
    end
  end  

  # Custom getters and setters for temperature_range
  def temperature_range
    range = super()
    safe_range_parser(range)
  end

  def temperature_range=(value)
    super(value.is_a?(Range) ? value : safe_range_parser(value)) unless value.nil?
  end

  # Custom getters and setters for humidity_range
  def humidity_range
    range = super()
    safe_range_parser(range)
  end

  def humidity_range=(value)
    super(value.is_a?(Range) ? value : safe_range_parser(value)) unless value.nil?
  end

  # Define optimal_temperature as the midpoint of the temperature_range
  # This provides the method that the BiosphereSimulationService is looking for.
  def optimal_temperature
    return nil unless temperature_range.is_a?(Range)
    (temperature_range.min + temperature_range.max) / 2.0
  end

  # Scope for finding biomes within a temperature range
  scope :within_temperature_range, ->(temperature) { where("temperature_range @> ?", temperature.to_i) }

  # Scope for finding biomes within a humidity range
  scope :within_humidity_range, ->(humidity) { where("humidity_range @> ?", humidity.to_i) }

  # Define biomes based on temperature and humidity
  def self.biomes_for_conditions(temperature, humidity)
    # Convert temperature to Kelvin if it appears to be in Celsius
    temp_in_kelvin = if temperature < 200
                       temperature + 273.15  # Convert Celsius to Kelvin
                     else
                       temperature  # Already in Kelvin
                     end
    
    # PostgreSQL doesn't support Ruby ranges directly, so we need to use a different approach
    all.select do |biome|
      biome.suitable_for?(temp_in_kelvin, humidity)
    end
  end

  # Example method to check if the biome is suitable for the given conditions
  def suitable_for?(temperature, humidity)
    # Convert temperature to Kelvin if it appears to be in Celsius
    temp_in_kelvin = if temperature < 200
                       temperature + 273.15  # Convert Celsius to Kelvin
                     else
                       temperature  # Already in Kelvin
                     end
    
    # For debugging
    Rails.logger.debug { 
      "Biome #{name} suitability check: " \
      "temp (Kelvin): #{temp_in_kelvin} in range #{temperature_range}? " \
      "humidity: #{humidity} in range #{humidity_range}?"
    }
    
    temperature_range.cover?(temp_in_kelvin) && humidity_range.cover?(humidity)
  end

  # Example of a method to handle biome-specific logic
  def handle_biome_logic(planet)
    # Implement specific logic for how this biome interacts with the planet
  end
end

