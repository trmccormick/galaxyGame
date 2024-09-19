# app/models/biome.rb

class Biome < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :temperature_range, presence: true
  validates :humidity_range, presence: true

  # Associations
  has_many :planet_biomes
  has_many :celestial_bodies, through: :planet_biomes

  # Safe range parser
  def safe_range_parser(value)
    if value.is_a?(String) && value.match?(/\A-?\d+..-?\d+\z/)
      eval(value)
    else
      value
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

  # Scope for finding biomes within a temperature range
  scope :within_temperature_range, ->(temperature) { where("temperature_range @> ?", temperature.to_i) }

  # Scope for finding biomes within a humidity range
  scope :within_humidity_range, ->(humidity) { where("humidity_range @> ?", humidity.to_i) }

  # Define biomes based on temperature and humidity
  def self.biomes_for_conditions(temperature, humidity)
    within_temperature_range(temperature).within_humidity_range(humidity)
  end

  # Example method to check if the biome is suitable for the given conditions
  def suitable_for?(temperature, humidity)
    temperature_range.cover?(temperature.to_i) && humidity_range.cover?(humidity.to_i)
  end

  # Example of a method to handle biome-specific logic
  def handle_biome_logic(planet)
    # Implement specific logic for how this biome interacts with the planet
  end
end
