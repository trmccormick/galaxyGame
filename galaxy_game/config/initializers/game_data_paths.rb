# config/initializers/game_data_paths.rb
module GalaxyGame
  module Paths
    # Ensure JSON_DATA is an absolute path from Rails.root for clarity and consistency
    # Added .freeze for constants
    JSON_DATA = Rails.root.join('app', 'data').freeze 

    # === Celestial Bodies and Star Systems ===

    # Helper for dynamically constructing celestial body folder path
    # e.g., star_systems/sol/celestial_bodies/earth/luna
    def self.celestial_body_data_path(celestial_body)
      system_name = celestial_body.star_system&.name || 'sol'
      # Use Pathname#join for better path handling with Pathname objects
      # This builds the path parts relative to JSON_DATA
      path_parts = [
        'star_systems',
        system_name.downcase,
        'celestial_bodies'
      ]

      if celestial_body.parent_body.present?
        path_parts << celestial_body.parent_body.name.downcase
      end

      path_parts << celestial_body.name.downcase
      
      JSON_DATA.join(*path_parts).to_s # Join relative parts with JSON_DATA
    end

    # === Units paths ===
    # FIX: Use Pathname#join to ensure UNITS_PATH is a Pathname object
    UNITS_PATH = JSON_DATA.join('operational_data', 'units').freeze 
    
    # Also update these to use Pathname#join for consistency
    COMPUTER_UNITS_PATH = UNITS_PATH.join('computer').freeze
    DROID_UNITS_PATH = UNITS_PATH.join('droid').freeze
    ENERGY_UNITS_PATH = UNITS_PATH.join('energy').freeze
    HOUSING_UNITS_PATH = UNITS_PATH.join('housing').freeze # Assuming you have a 'housing' category for units
    LIFE_SUPPORT_UNITS_PATH = UNITS_PATH.join('life_support').freeze
    PRODUCTION_UNITS_PATH = UNITS_PATH.join('production').freeze
    PROPULSION_UNITS_PATH = UNITS_PATH.join('propulsion').freeze
    STORAGE_UNITS_PATH = UNITS_PATH.join('storage').freeze
    STRUCTURE_UNITS_PATH = UNITS_PATH.join('structure').freeze
    VARIOUS_UNITS_PATH = UNITS_PATH.join('various').freeze

    # === Resources paths ===
    RESOURCES_PATH = File.join(JSON_DATA, 'resources').freeze
    MATERIALS_PATH = File.join(RESOURCES_PATH, 'materials').freeze

    # === Structures paths ===
    # This path already correctly includes 'operational_data'
    STRUCTURES_PATH = File.join(JSON_DATA, 'operational_data', 'structures').freeze
    HABITATION_STRUCTURES_PATH = File.join(STRUCTURES_PATH, 'habitation').freeze

    # === Craft paths ===
    CRAFTS_PATH = File.join(JSON_DATA, 'crafts').freeze
    TRANSPORT_CRAFTS_PATH = File.join(CRAFTS_PATH, 'transport').freeze

    # === Materials by category ===
    RAW_MATERIALS_PATH = File.join(MATERIALS_PATH, 'raw').freeze
    PROCESSED_MATERIALS_PATH = File.join(MATERIALS_PATH, 'processed').freeze
    BUILDING_MATERIALS_PATH = File.join(MATERIALS_PATH, 'building').freeze
    CHEMICALS_PATH = File.join(MATERIALS_PATH, 'chemicals').freeze
    GASES_PATH = File.join(MATERIALS_PATH, 'gases').freeze
    LIQUIDS_PATH = File.join(MATERIALS_PATH, 'liquids').freeze
    BYPRODUCTS_PATH = File.join(MATERIALS_PATH, 'byproducts').freeze

    # === Building materials subcategories ===
    STRUCTURAL_MATERIALS_PATH = File.join(BUILDING_MATERIALS_PATH, 'structural').freeze
    FUNCTIONAL_MATERIALS_PATH = File.join(BUILDING_MATERIALS_PATH, 'functional').freeze

    # === Blueprint paths ===
    BLUEPRINTS_PATH = File.join(JSON_DATA, 'blueprints').freeze
    CRAFT_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'craft').freeze
    STRUCTURE_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'structures').freeze
    UNIT_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'units').freeze
    MODULE_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'modules').freeze
    COMPONENT_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'components').freeze

    # === Helper methods for path generation ===
    def self.material_path(category, subcategory, material_id)
      File.join(MATERIALS_PATH, category, subcategory, "#{material_id}.json").freeze
    end

    def self.building_material_path(subcategory, material_id)
      File.join(BUILDING_MATERIALS_PATH, subcategory, "#{material_id}.json").freeze
    end

    def self.blueprint_path(category, subcategory, blueprint_id)
      subcategory_path = subcategory ? File.join(category, subcategory) : category
      File.join(BLUEPRINTS_PATH, subcategory_path, "#{blueprint_id}.json").freeze
    end

    # === Validation methods ===
    def self.valid_material_path?(path)
      path.start_with?(MATERIALS_PATH) && File.exist?(path)
    end

    def self.valid_blueprint_path?(path)
      path.start_with?(BLUEPRINTS_PATH) && File.exist?(path)
    end
  end
end