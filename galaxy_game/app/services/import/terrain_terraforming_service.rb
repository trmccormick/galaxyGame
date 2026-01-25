# app/services/import/terrain_terraforming_service.rb
require_relative '../terrain_analysis/hydrosphere_analyzer'

module Import
  class TerrainTerraformingService
    # Transformation rules: terraformed terrain -> barren terrain
    # Different mappings for different planet types
    TERRAFORMING_REVERSE_MAPS = {
      # Oceanic planets (Earth-like with abundant water)
      oceanic: {
        # Water features -> basins/deposits
        ocean: :deep_sea,           # Ocean becomes deep sea basin
        deep_sea: :rocky,           # Deep sea becomes rocky basin

        # Vegetated land -> desert/regolith
        grasslands: :desert,        # Grasslands become regolith desert
        plains: :desert,           # Plains become barren plains
        forest: :rocky,            # Forests become rocky outcrops
        jungle: :swamp,            # Jungles become swampy lowlands
        swamp: :swamp,             # Swamps remain as water collection areas
        boreal_forest: :tundra,    # Boreal forests become tundra

        # Cold regions -> polar deposits
        arctic: :arctic,           # Arctic remains as polar cap
        tundra: :tundra,           # Tundra remains cold

        # Arid regions -> extreme desert
        desert: :desert,           # Deserts remain barren
        rocky: :rocky              # Rocky areas remain rocky
      },

      # Temperate planets (moderate water, Earth-like but drier)
      temperate: {
        # Water features -> basins/deposits
        ocean: :deep_sea,           # Ocean becomes deep sea basin
        deep_sea: :rocky,           # Deep sea becomes rocky basin

        # Vegetated land -> desert/regolith
        grasslands: :desert,        # Grasslands become regolith desert
        plains: :desert,           # Plains become barren plains
        forest: :rocky,            # Forests become rocky outcrops
        jungle: :swamp,            # Jungles become swampy lowlands
        swamp: :swamp,             # Swamps remain as water collection areas
        boreal_forest: :tundra,    # Boreal forests become tundra

        # Cold regions -> polar deposits
        arctic: :arctic,           # Arctic remains as polar cap
        tundra: :tundra,           # Tundra remains cold

        # Arid regions -> extreme desert
        desert: :desert,           # Deserts remain barren
        rocky: :rocky              # Rocky areas remain rocky
      },

      # Arid planets (Mars-like: no water vapor, no surface water)
      arid: {
        # All water features -> dry basins or polar deposits
        ocean: :arctic,            # Ocean becomes polar ice deposits
        deep_sea: :arctic,         # Deep sea becomes polar deposits

        # All vegetation -> extreme desert
        grasslands: :desert,       # Grasslands become regolith desert
        plains: :desert,          # Plains become barren desert
        forest: :rocky,           # Forests become rocky outcrops
        jungle: :rocky,           # Jungles become rocky terrain
        swamp: :desert,           # Swamps become dry lake beds
        boreal_forest: :rocky,    # Boreal forests become rocky highlands

        # Cold regions -> polar deposits (resource rich)
        arctic: :arctic,          # Arctic remains as polar cap
        tundra: :arctic,          # Tundra becomes polar deposits

        # Arid regions -> extreme desert
        desert: :desert,          # Deserts remain barren
        rocky: :rocky             # Rocky areas remain rocky
      },

      # Ice worlds (very cold, ice-covered)
      ice_world: {
        # Water features -> frozen
        ocean: :arctic,            # Ocean becomes frozen sea
        deep_sea: :arctic,         # Deep sea becomes ice-covered

        # Vegetation -> frozen tundra
        grasslands: :tundra,       # Grasslands become frozen plains
        plains: :tundra,          # Plains become frozen
        forest: :arctic,          # Forests become ice-locked
        jungle: :arctic,          # Jungles become frozen
        swamp: :arctic,           # Swamps become frozen wetlands
        boreal_forest: :arctic,   # Boreal forests become polar

        # Cold regions -> extreme ice
        arctic: :arctic,          # Arctic remains as polar cap
        tundra: :arctic,          # Tundra becomes polar ice

        # Arid regions -> frozen desert
        desert: :tundra,          # Deserts become cold deserts
        rocky: :rocky             # Rocky areas remain rocky
      },

      # Default fallback (similar to temperate)
      default: {
        # Water features -> basins/deposits
        ocean: :deep_sea,           # Ocean becomes deep sea basin
        deep_sea: :rocky,           # Deep sea becomes rocky basin

        # Vegetated land -> desert/regolith
        grasslands: :desert,        # Grasslands become regolith desert
        plains: :desert,           # Plains become barren plains
        forest: :rocky,            # Forests become rocky outcrops
        jungle: :swamp,            # Jungles become swampy lowlands
        swamp: :swamp,             # Swamps remain as water collection areas
        boreal_forest: :tundra,    # Boreal forests become tundra

        # Cold regions -> polar deposits
        arctic: :arctic,           # Arctic remains as polar cap
        tundra: :tundra,           # Tundra remains cold

        # Arid regions -> extreme desert
        desert: :desert,           # Deserts remain barren
        rocky: :rocky              # Rocky areas remain rocky
      }
    }.freeze

    # Terrain types that should remain permanent landmasses (peaks/hills)
    PERMANENT_LANDMASSES = [:boreal_forest, :rocky].freeze

    # Terrain types that become resource nodes in barren state
    RESOURCE_NODE_SOURCES = {
      default: [:arctic, :tundra, :deep_sea],
      ice_world: [:arctic, :tundra],  # Ice worlds have polar ice deposits and frozen tundra resources
      arid: [:arctic, :rocky],  # Arid planets like Mars have polar deposits and rocky highlands
      oceanic: [:rocky],  # Oceanic worlds have rocky outcrops and deep sea resources
      temperate: [:tundra, :rocky]  # Temperate worlds have tundra deposits and rocky outcrops
    }.freeze

    attr_reader :terraformed_data, :planet_characteristics, :errors

    def initialize(terraformed_data, planet_characteristics = {})
      @terraformed_data = terraformed_data
      @planet_characteristics = planet_characteristics || {}
      @errors = []
    end

    # Determine planet type based on characteristics
    def determine_planet_type
      # Data-driven planet classification based on properties, not names

      # Check for explicit planet type override
      return @planet_characteristics[:type].to_sym if @planet_characteristics[:type] && @planet_characteristics[:type] != 'terrestrial_planet'

      # Analyze planet properties to determine hydrosphere characteristics
      planet_props = @planet_characteristics[:properties] || {}

      # Check atmosphere for water indicators
      atmosphere = @planet_characteristics[:atmosphere]
      has_water_vapor = atmosphere&.dig(:composition)&.key?(:water_vapor)

      # Check hydrosphere data
      hydrosphere = @planet_characteristics[:hydrosphere]
      has_surface_water = hydrosphere&.dig(:water_bodies)&.any?

      # Check surface temperature (very cold planets might have ice but no liquid water)
      surface_temp = @planet_characteristics[:surface_temperature]
      is_very_cold = surface_temp && surface_temp < 273  # Below freezing

      # Check body category/type
      body_category = @planet_characteristics[:body_category] || @planet_characteristics[:type]

      # Classification logic
      if body_category == 'ice_world' || (is_very_cold && !has_surface_water)
        :ice_world
      elsif !has_water_vapor && !has_surface_water
        :arid  # Mars-like: no water vapor, no surface water
      elsif has_surface_water && has_water_vapor
        :oceanic  # Earth-like: abundant water
      else
        :temperate  # Default terrestrial
      end
    end

    # Generate barren terrain from terraformed blueprint
    def generate_barren_terrain
      return nil unless valid_data?

      barren_grid = []
      strategic_markers = {
        permanent_landmasses: [],
        resource_nodes: [],
        water_collection_zones: []
      }

      planet_type = determine_planet_type
      reverse_map = TERRAFORMING_REVERSE_MAPS[planet_type] || TERRAFORMING_REVERSE_MAPS[:default]
      resource_sources = RESOURCE_NODE_SOURCES[planet_type] || RESOURCE_NODE_SOURCES[:default]

      @terraformed_data[:grid].each_with_index do |row, y|
        barren_row = []
        row.each_with_index do |terraformed_terrain, x|
          barren_terrain = reverse_terraform(terraformed_terrain, reverse_map)

          # Track strategic locations
          if PERMANENT_LANDMASSES.include?(terraformed_terrain)
            strategic_markers[:permanent_landmasses] << [x, y]
          end

          if resource_sources.include?(barren_terrain)  # Check barren terrain for resource nodes
            strategic_markers[:resource_nodes] << [x, y]
          end

          # Track water collection zones for planets that can have surface water
          if [:default, :oceanic, :temperate].include?(planet_type) && (terraformed_terrain == :ocean || terraformed_terrain == :deep_sea)
            strategic_markers[:water_collection_zones] << [x, y]
          end

          barren_row << barren_terrain
        end
        barren_grid << barren_row
      end

      # Analyze hydrosphere for water distribution and collection sites
      hydrosphere_analysis = analyze_hydrosphere(barren_grid)

      # Recalculate biome counts for barren terrain
      barren_biome_counts = calculate_biome_counts(barren_grid)

      {
        grid: barren_grid,
        width: @terraformed_data[:width],
        height: @terraformed_data[:height],
        biome_counts: barren_biome_counts,
        strategic_markers: strategic_markers,
        hydrosphere_analysis: hydrosphere_analysis,
        terraforming_target: {
          file_path: @terraformed_data[:source_file],
          original_biome_counts: @terraformed_data[:biome_counts],
          strategic_markers: strategic_markers
        }
      }
    end

    private

    def valid_data?
      unless @terraformed_data.is_a?(Hash) && @terraformed_data[:grid]
        @errors << "Invalid terraformed terrain data structure"
        return false
      end

      unless @terraformed_data[:grid].is_a?(Array) && @terraformed_data[:grid].any?
        @errors << "No terrain grid data found"
        return false
      end

      true
    end

    # Reverse terraform: convert lush terrain back to barren state
    def analyze_hydrosphere(barren_grid)
      analyzer = TerrainAnalysis::HydrosphereAnalyzer.new(barren_grid, @planet_characteristics)
      analyzer.analyze
    end

    # Calculate biome counts for the barren terrain
    def calculate_biome_counts(grid)
      counts = Hash.new(0)
      grid.flatten.each do |terrain_type|
        counts[terrain_type] += 1
      end
      counts
    end

    # Reverse terraform: convert terraformed terrain to barren state
    def reverse_terraform(terraformed_terrain, reverse_map)
      reverse_map[terraformed_terrain] || terraformed_terrain
    end
  end
end