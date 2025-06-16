# config/initializers/game_data_paths.rb
module GalaxyGame
  module Paths
    # Base paths
    if Rails.env.development? || Rails.env.production?
      # ✅ Convert to Pathname so .join() works
      JSON_DATA = Pathname.new(File.join('app', 'data'))
    elsif Rails.env.test?
      # ✅ Convert to Pathname so .join() works  
      JSON_DATA = Pathname.new(File.join('spec', 'fixtures', 'data'))
    end

    # === Celestial Bodies and Star Systems ===

    # Helper for dynamically constructing celestial body folder path
    # e.g., star_systems/sol/celestial_bodies/earth/luna
    def self.celestial_body_data_path(celestial_body)
      system_name = celestial_body.star_system&.name || 'sol'
      path_parts = [
        JSON_DATA,
        'star_systems',
        system_name.downcase,
        'celestial_bodies'
      ]

      if celestial_body.parent_body.present?
        path_parts << celestial_body.parent_body.name.downcase
      end

      path_parts << celestial_body.name.downcase
      File.join(*path_parts)
    end

    # === Units paths ===
    UNITS_PATH = File.join(JSON_DATA, 'units')
    COMPUTER_UNITS_PATH = File.join(UNITS_PATH, 'computer')
    DROID_UNITS_PATH = File.join(UNITS_PATH, 'droid')
    ENERGY_UNITS_PATH = File.join(UNITS_PATH, 'energy')
    HOUSING_UNITS_PATH = File.join(UNITS_PATH, 'housing')
    LIFE_SUPPORT_UNITS_PATH = File.join(UNITS_PATH, 'life_support')
    PRODUCTION_UNITS_PATH = File.join(UNITS_PATH, 'production')
    PROPULSION_UNITS_PATH = File.join(UNITS_PATH, 'propulsion')
    STORAGE_UNITS_PATH = File.join(UNITS_PATH, 'storage')
    STRUCTURE_UNITS_PATH = File.join(UNITS_PATH, 'structure')
    VARIOUS_UNITS_PATH = File.join(UNITS_PATH, 'various')

    # === Resources paths ===
    RESOURCES_PATH = File.join(JSON_DATA, 'resources')
    MATERIALS_PATH = File.join(RESOURCES_PATH, 'materials')

    # === Structures paths ===
    STRUCTURES_PATH = File.join(JSON_DATA, 'operational_data', 'structures')
    HABITATION_STRUCTURES_PATH = File.join(STRUCTURES_PATH, 'habitation')
    # Add all other structure types...

    # === Craft paths ===
    CRAFTS_PATH = File.join(JSON_DATA, 'crafts')
    TRANSPORT_CRAFTS_PATH = File.join(CRAFTS_PATH, 'transport')
    # Add all other craft types...

    # === Materials by category ===
    RAW_MATERIALS_PATH = File.join(MATERIALS_PATH, 'raw')
    PROCESSED_MATERIALS_PATH = File.join(MATERIALS_PATH, 'processed')
    BUILDING_MATERIALS_PATH = File.join(MATERIALS_PATH, 'building')
    CHEMICALS_PATH = File.join(MATERIALS_PATH, 'chemicals')
    GASES_PATH = File.join(MATERIALS_PATH, 'gases')
    LIQUIDS_PATH = File.join(MATERIALS_PATH, 'liquids')
    BYPRODUCTS_PATH = File.join(MATERIALS_PATH, 'byproducts')

    # === Building materials subcategories ===
    STRUCTURAL_MATERIALS_PATH = File.join(BUILDING_MATERIALS_PATH, 'structural')
    FUNCTIONAL_MATERIALS_PATH = File.join(BUILDING_MATERIALS_PATH, 'functional')

    # === Blueprint paths ===
    BLUEPRINTS_PATH = File.join(JSON_DATA, 'blueprints')
    CRAFT_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'craft')
    STRUCTURE_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'structures')
    UNIT_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'units')
    MODULE_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'modules')
    COMPONENT_BLUEPRINTS_PATH = File.join(BLUEPRINTS_PATH, 'components')

    # === Helper methods for path generation ===
    def self.material_path(category, subcategory, material_id)
      File.join(MATERIALS_PATH, category, subcategory, "#{material_id}.json")
    end

    def self.building_material_path(subcategory, material_id)
      File.join(BUILDING_MATERIALS_PATH, subcategory, "#{material_id}.json")
    end

    def self.blueprint_path(category, subcategory, blueprint_id)
      subcategory_path = subcategory ? File.join(category, subcategory) : category
      File.join(BLUEPRINTS_PATH, subcategory_path, "#{blueprint_id}.json")
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
