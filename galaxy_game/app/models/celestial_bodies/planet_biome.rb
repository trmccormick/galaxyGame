# app/models/celestial_bodies/planet_biome.rb
module CelestialBodies
  class PlanetBiome < ApplicationRecord
    # Associations
    # Biome is a top-level model, no class_name needed
    belongs_to :biome
    # Biosphere is namespaced, so class_name is required
    belongs_to :biosphere, class_name: 'CelestialBodies::Spheres::Biosphere'

    # Use store_accessor for flexible properties stored in the 'properties' JSONB column
    store_accessor :properties, :area_percentage, :vegetation_cover, :moisture_level, :latitude, :optimal_temperature, :biodiversity

    # Validations
    validates :biome_id, uniqueness: { scope: :biosphere_id }
    validates :area_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
    validates :vegetation_cover, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
    validates :moisture_level, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
    validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
    validates :biodiversity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    # Callbacks
    after_create :update_biosphere_biodiversity
    after_destroy :update_biosphere_biodiversity

    # Initialize default values for JSONB properties if they are not set
    after_initialize :set_default_properties, if: :new_record?

    # Backward compatibility methods - MOVED FROM PRIVATE TO PUBLIC
    # Remove after all references are updated
    def water_level
      ActiveSupport::Deprecation.warn("water_level is deprecated, use moisture_level instead")
      moisture_level
    end

    def water_level=(value)
      ActiveSupport::Deprecation.warn("water_level= is deprecated, use moisture_level= instead")
      self.moisture_level = value
    end

    private

    def set_default_properties
      # Only set if nil, allowing explicit setting to 0 or other values
      self.area_percentage = 0.0 if area_percentage.nil?
      self.vegetation_cover = 0.0 if vegetation_cover.nil?
      self.moisture_level = 0.0 if moisture_level.nil?
      self.latitude = 0.0 if latitude.nil?
      self.biodiversity = 0.0 if biodiversity.nil?
      # Add other properties and their defaults as needed
    end

    def update_biosphere_biodiversity
      # This method assumes biosphere.calculate_biodiversity_index exists
      # and updates the biosphere's biodiversity_index attribute.
      biosphere.calculate_biodiversity_index
      biosphere.save
    end
  end
end