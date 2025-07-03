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
      path_parts = [
        'star_systems',
        system_name.downcase,
        'celestial_bodies'
      ]

      if celestial_body.parent_body.present?
        path_parts << celestial_body.parent_body.name.downcase
      end

      path_parts << celestial_body.name.downcase
      
      JSON_DATA.join(*path_parts).to_s 
    end

    # === Operational Data Paths (Units, Structures, Crafts, Modules, Rigs) ===
    # These paths are for the actual game data (operational parameters, etc.)

    # Units Operational Data Paths
    UNITS_PATH = JSON_DATA.join('operational_data', 'units').freeze 
    COMPUTER_UNITS_PATH = UNITS_PATH.join('computers').freeze # Matches script's 'computers' (plural)
    DROID_UNITS_PATH = UNITS_PATH.join('droid').freeze
    ENERGY_UNITS_PATH = UNITS_PATH.join('energy').freeze
    HABITATS_UNITS_PATH = UNITS_PATH.join('habitats').freeze # Matches script's 'habitats' (plural)
    LIFE_SUPPORT_UNITS_PATH = UNITS_PATH.join('life_support').freeze
    PROCESSING_UNITS_PATH = UNITS_PATH.join('processing').freeze # Added for consistency if it exists
    PRODUCTION_UNITS_PATH = UNITS_PATH.join('production').freeze
    PROPULSION_UNITS_PATH = UNITS_PATH.join('propulsion').freeze
    STORAGE_UNITS_PATH = UNITS_PATH.join('storage').freeze
    STRUCTURE_UNITS_PATH = UNITS_PATH.join('structure').freeze # Matches script's 'structure' (singular)
    SPECIALIZED_UNITS_PATH = UNITS_PATH.join('specialized').freeze

    # Robot Units Operational Data Paths (subcategories under units/robots)
    ROBOTS_UNITS_PATH = UNITS_PATH.join('robots').freeze
    ROBOTS_DEPLOYMENT_UNITS_PATH = ROBOTS_UNITS_PATH.join('deployment').freeze
    ROBOTS_CONSTRUCTION_UNITS_PATH = ROBOTS_UNITS_PATH.join('construction').freeze
    ROBOTS_MAINTENANCE_UNITS_PATH = ROBOTS_UNITS_PATH.join('maintenance').freeze
    ROBOTS_EXPLORATION_UNITS_PATH = ROBOTS_UNITS_PATH.join('exploration').freeze
    ROBOTS_LIFE_SUPPORT_UNITS_PATH = ROBOTS_UNITS_PATH.join('life_support').freeze
    ROBOTS_LOGISTICS_UNITS_PATH = ROBOTS_UNITS_PATH.join('logistics').freeze
    ROBOTS_RESOURCE_UNITS_PATH = ROBOTS_UNITS_PATH.join('resource').freeze

    # Modules Operational Data Paths
    MODULES_PATH = JSON_DATA.join('operational_data', 'modules').freeze # Base for operational modules
    COMPUTER_MODULES_PATH = MODULES_PATH.join('computer').freeze
    DEFENSE_MODULES_PATH = MODULES_PATH.join('defense').freeze
    ENERGY_MODULES_PATH = MODULES_PATH.join('energy').freeze
    INFRASTRUCTURE_MODULES_PATH = MODULES_PATH.join('infrastructure').freeze
    LIFE_SUPPORT_MODULES_PATH = MODULES_PATH.join('life_support').freeze
    POWER_MODULES_PATH = MODULES_PATH.join('power').freeze
    PRODUCTION_MODULES_PATH = MODULES_PATH.join('production').freeze
    PROPULSION_MODULES_PATH = MODULES_PATH.join('propulsion').freeze
    SCIENCE_MODULES_PATH = MODULES_PATH.join('science').freeze
    SENSORS_MODULES_PATH = MODULES_PATH.join('sensors').freeze
    STORAGE_MODULES_PATH = MODULES_PATH.join('storage').freeze
    UTILITY_MODULES_PATH = MODULES_PATH.join('utility').freeze

    # Rigs Operational Data Paths
    RIGS_PATH = JSON_DATA.join('operational_data', 'rigs').freeze # Base for operational rigs
    COMPUTER_RIGS_PATH = RIGS_PATH.join('computer').freeze
    DEFENSE_RIGS_PATH = RIGS_PATH.join('defense').freeze
    ENERGY_RIGS_PATH = RIGS_PATH.join('energy').freeze
    INFRASTRUCTURE_RIGS_PATH = RIGS_PATH.join('infrastructure').freeze
    LIFE_SUPPORT_RIGS_PATH = RIGS_PATH.join('life_support').freeze
    POWER_RIGS_PATH = RIGS_PATH.join('power').freeze
    PRODUCTION_RIGS_PATH = RIGS_PATH.join('production').freeze
    PROPULSION_RIGS_PATH = RIGS_PATH.join('propulsion').freeze
    SCIENCE_RIGS_PATH = RIGS_PATH.join('science').freeze
    STORAGE_RIGS_PATH = RIGS_PATH.join('storage').freeze
    UTILITY_RIGS_PATH = RIGS_PATH.join('utility').freeze

    # Structures Operational Data Paths
    STRUCTURES_PATH = JSON_DATA.join('operational_data', 'structures').freeze
    HABITATION_STRUCTURES_PATH = STRUCTURES_PATH.join('habitation').freeze
    LANDING_INFRASTRUCTURE_STRUCTURES_PATH = STRUCTURES_PATH.join('landing_infrastructure').freeze
    LIFE_SUPPORT_STRUCTURES_PATH = STRUCTURES_PATH.join('life_support').freeze
    MANUFACTURING_STRUCTURES_PATH = STRUCTURES_PATH.join('manufacturing').freeze
    POWER_GENERATION_STRUCTURES_PATH = STRUCTURES_PATH.join('power_generation').freeze
    RESOURCE_EXTRACTION_STRUCTURES_PATH = STRUCTURES_PATH.join('resource_extraction').freeze
    RESOURCE_PROCESSING_STRUCTURES_PATH = STRUCTURES_PATH.join('resource_processing').freeze
    SCIENCE_RESEARCH_STRUCTURES_PATH = STRUCTURES_PATH.join('science_research').freeze
    STORAGE_STRUCTURES_PATH = STRUCTURES_PATH.join('storage').freeze
    TRANSPORTATION_STRUCTURES_PATH = STRUCTURES_PATH.join('transportation').freeze
    SPACE_STATIONS_STRUCTURES_PATH = STRUCTURES_PATH.join('space_stations').freeze

    # Craft Operational Data Paths
    CRAFTS_PATH = JSON_DATA.join('operational_data', 'crafts').freeze
    SPACE_CRAFTS_PATH = CRAFTS_PATH.join('space').freeze
    SPACE_SATELLITES_CRAFTS_PATH = SPACE_CRAFTS_PATH.join('satellites').freeze
    SPACE_SPACECRAFT_CRAFTS_PATH = SPACE_CRAFTS_PATH.join('spacecraft').freeze
    SPACE_LANDERS_CRAFTS_PATH = SPACE_CRAFTS_PATH.join('landers').freeze
    SPACE_PROBES_CRAFTS_PATH = SPACE_CRAFTS_PATH.join('probes').freeze
    ATMOSPHERIC_CRAFTS_PATH = CRAFTS_PATH.join('atmospheric').freeze
    GROUND_CRAFTS_PATH = CRAFTS_PATH.join('ground').freeze

    # === Resources Paths ===
    RESOURCES_PATH = JSON_DATA.join('resources').freeze
    MATERIALS_PATH = RESOURCES_PATH.join('materials').freeze
    FUELS_PATH = RESOURCES_PATH.join('fuels').freeze # Added to match script
    CHEMICALS_RESOURCES_PATH = RESOURCES_PATH.join('chemicals').freeze # Added to match script (distinct from materials/chemicals)

    # Materials by category
    RAW_MATERIALS_PATH = MATERIALS_PATH.join('raw').freeze
    RAW_GEOLOGICAL_MATERIALS_PATH = RAW_MATERIALS_PATH.join('geological').freeze
    RAW_BIOLOGICAL_MATERIALS_PATH = RAW_MATERIALS_PATH.join('biological').freeze
    RAW_ATMOSPHERIC_MATERIALS_PATH = RAW_MATERIALS_PATH.join('atmospheric').freeze

    PROCESSED_MATERIALS_PATH = MATERIALS_PATH.join('processed').freeze
    PROCESSED_METALS_MATERIALS_PATH = PROCESSED_MATERIALS_PATH.join('metals').freeze
    PROCESSED_ALLOYS_MATERIALS_PATH = PROCESSED_MATERIALS_PATH.join('alloys').freeze
    PROCESSED_POLYMERS_MATERIALS_PATH = PROCESSED_MATERIALS_PATH.join('polymers').freeze
    PROCESSED_CERAMICS_MATERIALS_PATH = PROCESSED_MATERIALS_PATH.join('ceramics').freeze
    PROCESSED_COMPOSITES_MATERIALS_PATH = PROCESSED_MATERIALS_PATH.join('composites').freeze

    CHEMICALS_MATERIALS_PATH = MATERIALS_PATH.join('chemicals').freeze # This is for materials/chemicals
    CHEMICALS_INDUSTRIAL_MATERIALS_PATH = CHEMICALS_MATERIALS_PATH.join('industrial').freeze
    CHEMICALS_BIOCHEMICAL_MATERIALS_PATH = CHEMICALS_MATERIALS_PATH.join('biochemical').freeze
    CHEMICALS_EXOTIC_MATERIALS_PATH = CHEMICALS_MATERIALS_PATH.join('exotic').freeze

    BUILDING_MATERIALS_PATH = MATERIALS_PATH.join('building').freeze
    STRUCTURAL_MATERIALS_PATH = BUILDING_MATERIALS_PATH.join('structural').freeze
    FUNCTIONAL_MATERIALS_PATH = BUILDING_MATERIALS_PATH.join('functional').freeze

    GASES_MATERIALS_PATH = MATERIALS_PATH.join('gases').freeze
    GASES_INERT_MATERIALS_PATH = GASES_MATERIALS_PATH.join('inert').freeze
    GASES_REACTIVE_MATERIALS_PATH = GASES_MATERIALS_PATH.join('reactive').freeze
    GASES_COMPOUND_MATERIALS_PATH = GASES_MATERIALS_PATH.join('compound').freeze

    LIQUIDS_MATERIALS_PATH = MATERIALS_PATH.join('liquids').freeze
    LIQUIDS_COOLANTS_MATERIALS_PATH = LIQUIDS_MATERIALS_PATH.join('coolants').freeze
    LIQUIDS_SOLVENTS_MATERIALS_PATH = LIQUIDS_MATERIALS_PATH.join('solvents').freeze
    LIQUIDS_REAGENTS_MATERIALS_PATH = LIQUIDS_MATERIALS_PATH.join('reagents').freeze

    BYPRODUCTS_MATERIALS_PATH = MATERIALS_PATH.join('byproducts').freeze
    BYPRODUCTS_WASTE_MATERIALS_PATH = BYPRODUCTS_MATERIALS_PATH.join('waste').freeze
    BYPRODUCTS_RECYCLABLE_MATERIALS_PATH = BYPRODUCTS_MATERIALS_PATH.join('recyclable').freeze

    # Fuels subcategories
    FUELS_SOLID_PATH = FUELS_PATH.join('solid').freeze
    FUELS_LIQUID_PATH = FUELS_PATH.join('liquid').freeze # This is 'liquid' in script, not 'liquid/chemical'
    FUELS_LIQUID_CHEMICAL_PATH = FUELS_LIQUID_PATH.join('chemical').freeze
    FUELS_LIQUID_NUCLEAR_PATH = FUELS_LIQUID_PATH.join('nuclear').freeze
    FUELS_GAS_PATH = FUELS_PATH.join('gas').freeze
    FUELS_PLASMA_PATH = FUELS_PATH.join('plasma').freeze
    FUELS_EXOTIC_PATH = FUELS_PATH.join('exotic').freeze
    
    # Chemicals (top-level under resources) subcategories
    CHEMICALS_SOLVENTS_PATH = CHEMICALS_RESOURCES_PATH.join('solvents').freeze
    CHEMICALS_CATALYSTS_PATH = CHEMICALS_RESOURCES_PATH.join('catalysts').freeze
    CHEMICALS_REAGENTS_PATH = CHEMICALS_RESOURCES_PATH.join('reagents').freeze
    CHEMICALS_COMPOUNDS_PATH = CHEMICALS_RESOURCES_PATH.join('compounds').freeze
    CHEMICALS_SOLUTIONS_PATH = CHEMICALS_RESOURCES_PATH.join('solutions').freeze

    # === Blueprint Paths ===
    BLUEPRINTS_PATH = JSON_DATA.join('blueprints').freeze
    CRAFT_BLUEPRINTS_PATH = BLUEPRINTS_PATH.join('crafts').freeze # Matches script's 'crafts' (plural)
    STRUCTURE_BLUEPRINTS_PATH = BLUEPRINTS_PATH.join('structures').freeze
    UNIT_BLUEPRINTS_PATH = BLUEPRINTS_PATH.join('units').freeze
    MODULE_BLUEPRINTS_PATH = BLUEPRINTS_PATH.join('modules').freeze
    COMPONENT_BLUEPRINTS_PATH = BLUEPRINTS_PATH.join('components').freeze
    RIG_BLUEPRINTS_PATH = BLUEPRINTS_PATH.join('rigs').freeze # Matches script's 'rigs' (plural)

    # === Items Paths ===
    ITEMS_PATH = JSON_DATA.join('items').freeze # Added to match script
    COMPONENTS_ITEMS_PATH = ITEMS_PATH.join('components').freeze
    CONSUMABLE_ITEMS_PATH = ITEMS_PATH.join('consumable').freeze
    CONTAINER_ITEMS_PATH = ITEMS_PATH.join('container').freeze
    EQUIPMENT_ITEMS_PATH = ITEMS_PATH.join('equipment').freeze
    TOOL_ITEMS_PATH = ITEMS_PATH.join('tool').freeze
    FURNITURE_ITEMS_PATH = ITEMS_PATH.join('furniture').freeze
    CRAFTED_PARTS_ITEMS_PATH = ITEMS_PATH.join('crafted_parts').freeze

    # === Helper methods for path generation ===
    def self.material_path(category, subcategory, material_id)
      # This helper needs to be smarter if category/subcategory don't map directly to top-level constants
      # For now, it assumes category is a direct sub-folder of MATERIALS_PATH
      MATERIALS_PATH.join(category, subcategory, "#{material_id}.json").freeze
    end

    def self.building_material_path(subcategory, material_id)
      BUILDING_MATERIALS_PATH.join(subcategory, "#{material_id}.json").freeze
    end

    def self.blueprint_path(category, subcategory, blueprint_id)
      base_path = BLUEPRINTS_PATH.join(category)
      subcategory_path = subcategory ? base_path.join(subcategory) : base_path
      subcategory_path.join("#{blueprint_id}.json").freeze
    end

    # === Validation methods ===
    def self.valid_material_path?(path)
      path.start_with?(MATERIALS_PATH.to_s) && File.exist?(path)
    end

    def self.valid_blueprint_path?(path)
      path.start_with?(BLUEPRINTS_PATH.to_s) && File.exist?(path)
    end
  end
end