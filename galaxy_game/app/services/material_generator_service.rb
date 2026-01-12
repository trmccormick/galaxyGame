# app/services/material_generator_service.rb
# This service acts as the wrapper for accessing Material data. 
# It will delegate to the GameDataGenerator, or use local stubs for testing.

# NOTE: We require the GameDataGenerator and the lookup services
# to allow the class to initialize in the production environment.
require 'json'
require_relative 'lookup/material_lookup_service'

class MaterialGeneratorService
  TEMPLATE_PATH = GalaxyGame::Paths::TEMPLATE_PATH.join('material_v1.4.json') unless const_defined?(:TEMPLATE_PATH)

  class << self
    # Public method required by NpcPriceCalculator
    def generate_material(material_id)
      material_lookup = Lookup::MaterialLookupService.new
      material_data = material_lookup.find_material(material_id)
      return nil unless material_data

      template = load_template
      deep_merge(template, material_data)
    end

    private

    def load_template
      JSON.parse(File.read(TEMPLATE_PATH))
    end

    # Deep merge two hashes, preferring values from the second
    def deep_merge(hash1, hash2)
      hash1.merge(hash2) do |key, oldval, newval|
        if oldval.is_a?(Hash) && newval.is_a?(Hash)
          deep_merge(oldval, newval)
        else
          newval
        end
      end
    end
  end
end