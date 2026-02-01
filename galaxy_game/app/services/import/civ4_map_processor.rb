# app/services/import/civ4_map_processor.rb
module Import
  class Civ4MapProcessor
    def process(civ4_file_path, mode: :terrain)
      Rails.logger.info "[Civ4MapProcessor] Processing Civ4 map: #{civ4_file_path} in #{mode} mode"

      # Step 1: Import raw Civ4 data
      if mode == :mars_blueprint
        @raw_data = Import::Civ4WbsImportService.new(civ4_file_path).send(:parse_wbs_file)
      else
        @raw_data = Import::Civ4WbsImportService.new(civ4_file_path).import
      end

      if mode == :mars_blueprint
        # Extract terraforming blueprint data instead of terrain
        return extract_mars_blueprints(@raw_data, civ4_file_path)
      end

      # Original terrain generation flow
      # Step 2: Extract elevation from PlotType data (70-80% accurate)
      elevation = extract_elevation_from_plottype(@raw_data)

      # Step 3: Extract biomes from TerrainType data (exact)
      biomes = extract_biomes_from_terrain(@raw_data)

      # Step 4: Extract features and improvements
      features = extract_features(@raw_data)

      # Step 5: Add realistic variation and smoothing
      elevation = add_realistic_variation(elevation, amount: 0.05)
      elevation = smooth_elevation(elevation, passes: 2)

      # Step 6: Extract strategic markers for AI learning
      strategic_markers = extract_strategic_markers(@raw_data)

      # Step 7: Return comprehensive data structure
      {
        lithosphere: {
          elevation: elevation,
          method: 'civ4_plottype_extraction',
          quality: 'high_70_80_percent',
          width: @raw_data[:width],
          height: @raw_data[:height]
        },
        biomes: biomes,
        features: features,
        strategic_markers: strategic_markers,
        source_file: civ4_file_path,
        metadata: {
          format: 'civ4_worldbuilder_save',
          extraction_quality: 'high',
          ai_learning_potential: 'excellent'
        }
      }
    end

    private

    def extract_elevation_from_plottype(raw_data)
      elevation_map = Array.new(raw_data[:height]) do |y|
        Array.new(raw_data[:width]) do |x|
          plot = find_plot_at(raw_data[:plots], x, y)
          estimate_elevation_from_plot(plot) if plot
        end
      end

      elevation_map
    end

    def extract_biomes_from_terrain(raw_data)
      biome_map = Array.new(raw_data[:height]) do |y|
        Array.new(raw_data[:width]) do |x|
          plot = find_plot_at(raw_data[:plots], x, y)
          map_civ4_to_galaxy_biome(plot) if plot
        end
      end

      biome_map
    end

    def find_plot_at(plots, x, y)
      plots.find { |plot| plot[:x] == x && plot[:y] == y }
    end

    def estimate_elevation_from_plot(plot)
      plot_type = plot[:plot_type]
      terrain_type = plot[:terrain_type]
      feature_type = plot[:feature_type]

      # Base elevation from PlotType (4-level system)
      base_elevation = case plot_type
      when 0 then 0.45  # Flat land
      when 1 then 0.35  # Coastal
      when 2 then 0.70  # Hills
      when 3 then 0.15  # Water/ambiguous (refine below)
      else 0.50         # Unknown
      end

      # Refine PlotType=3 (water/peaks ambiguous)
      if plot_type == 3
        base_elevation = case terrain_type
        when /OCEAN/ then 0.10
        when /COAST/ then 0.25
        when /SNOW/ then 0.95   # Snow-capped peaks
        when /GRASS/, /PLAINS/ then 0.90  # High altitude grasslands
        when /DESERT/ then 0.85  # High desert
        else 0.15  # Default to water
        end
      end

      # Terrain type adjustments for land plots
      if plot_type != 3 && terrain_type
        base_elevation += 0.30 if terrain_type.include?('SNOW')
        base_elevation += 0.10 if terrain_type.include?('TUNDRA')
        base_elevation += 0.05 if terrain_type.include?('DESERT')
        base_elevation -= 0.05 if terrain_type.include?('GRASS') && plot_type == 0  # Lowland grass
      end

      # Feature adjustments
      if feature_type
        base_elevation += 0.05 if feature_type.include?('FOREST')
        base_elevation -= 0.10 if feature_type.include?('FLOOD')
        base_elevation += 0.15 if feature_type.include?('MOUNTAIN')  # Additional mountain boost
      end

      # Clamp to valid range
      [[base_elevation, 0.0].max, 1.0].min
    end

    def extract_biomes_from_terrain(raw_data)
      biome_map = Array.new(raw_data[:height]) do |y|
        Array.new(raw_data[:width]) do |x|
          plot = find_plot_at(raw_data[:plots], x, y)
          map_civ4_to_galaxy_biome(plot) if plot
        end
      end

      biome_map
    end

    def map_civ4_to_galaxy_biome(plot)
      terrain_type = plot[:terrain_type]
      feature_type = plot[:feature_type]

      # Base biome from terrain
      base_biome = case terrain_type
      when /GRASS/ then :grasslands
      when /PLAINS/ then :plains
      when /DESERT/ then :desert
      when /TUNDRA/ then :tundra
      when /SNOW/ then :arctic
      when /OCEAN/ then :ocean
      when /COAST/ then :coast
      else :plains  # Default
      end

      # Feature modifications
      if feature_type
        case feature_type
        when /FOREST/ then base_biome = :forest
        when /JUNGLE/ then base_biome = :jungle
        when /MARSH/ then base_biome = :swamp
        when /FLOOD/ then base_biome = :wetlands
        end
      end

      base_biome
    end

    def extract_features(raw_data)
      feature_map = Array.new(raw_data[:height]) do |y|
        Array.new(raw_data[:width]) do |x|
          plot = find_plot_at(raw_data[:plots], x, y)
          extract_plot_features(plot) if plot
        end
      end

      feature_map
    end

    def extract_plot_features(plot)
      features = []

      if plot[:feature_type]
        case plot[:feature_type]
        when /FOREST/ then features << :forest
        when /JUNGLE/ then features << :jungle
        when /MARSH/ then features << :wetlands
        when /FLOOD/ then features << :flood_plains
        when /MOUNTAIN/ then features << :mountains
        when /HILL/ then features << :hills
        end
      end

      features
    end

    def extract_strategic_markers(raw_data)
      markers = {
        resource_deposits: [],
        settlement_sites: [],
        strategic_locations: []
      }

      raw_data[:plots].each do |plot|
        # Extract resource deposits
        if plot[:bonus_type]
          resource_marker = map_civ4_resource_to_galaxy(plot)
          markers[:resource_deposits] << resource_marker if resource_marker
        end

        # Identify potential settlement sites
        if is_good_settlement_location?(plot)
          settlement_marker = {
            location: [plot[:x], plot[:y]],
            advantages: analyze_settlement_advantages(plot),
            priority: calculate_settlement_priority(plot)
          }
          markers[:settlement_sites] << settlement_marker
        end

        # Mark strategic locations
        if is_strategic_location?(plot)
          strategic_marker = {
            location: [plot[:x], plot[:y]],
            type: identify_strategic_type(plot),
            value: assess_strategic_value(plot)
          }
          markers[:strategic_locations] << strategic_marker
        end
      end

      markers
    end

    def map_civ4_resource_to_galaxy(plot)
      bonus_type = plot[:bonus_type]

      resource_mapping = {
        'BONUS_IRON' => { type: 'iron_ore', quality: 'high', size: 'large' },
        'BONUS_COPPER' => { type: 'copper_ore', quality: 'medium', size: 'medium' },
        'BONUS_GOLD' => { type: 'precious_metals', quality: 'high', size: 'small' },
        'BONUS_SILVER' => { type: 'precious_metals', quality: 'medium', size: 'small' },
        'BONUS_GEMS' => { type: 'rare_earth_elements', quality: 'exotic', size: 'small' },
        'BONUS_OIL' => { type: 'hydrocarbons', quality: 'high', size: 'large' },
        'BONUS_COAL' => { type: 'carbon_deposits', quality: 'medium', size: 'large' },
        'BONUS_URANIUM' => { type: 'radioactive_materials', quality: 'weapons_grade', size: 'medium' },
        'BONUS_ALUMINUM' => { type: 'lightweight_metals', quality: 'aerospace', size: 'medium' }
      }

      if resource_mapping[bonus_type]
        {
          location: [plot[:x], plot[:y]],
          resource: resource_mapping[bonus_type][:type],
          quality: resource_mapping[bonus_type][:quality],
          size: resource_mapping[bonus_type][:size],
          terrain: plot[:terrain_type],
          elevation: estimate_elevation_from_plot(plot)
        }
      end
    end

    def is_good_settlement_location?(plot)
      # Check for coastal access, resources, defensible terrain
      has_water_access = plot[:plot_type] == 1 || adjacent_to_water?(plot)
      has_resources = plot[:bonus_type].present?
      good_terrain = !plot[:terrain_type]&.include?('DESERT') && !plot[:terrain_type]&.include?('SNOW')
      not_too_elevated = plot[:plot_type] != 2  # Not hills

      has_water_access && (has_resources || good_terrain) && not_too_elevated
    end

    def is_strategic_location?(plot)
      # Mountain passes, river crossings, natural harbors
      is_mountain_pass = plot[:plot_type] == 2 && has_adjacent_lowlands?(plot)
      is_river_crossing = plot[:river_ns] || plot[:river_we]
      is_coastal = plot[:plot_type] == 1

      is_mountain_pass || is_river_crossing || is_coastal
    end

    def add_realistic_variation(elevation_map, amount: 0.05)
      elevation_map.map do |row|
        row.map do |elevation|
          next elevation unless elevation

          # Add random variation
          variation = (rand - 0.5) * amount * 2
          [[elevation + variation, 0.0].max, 1.0].min
        end
      end
    end

    def smooth_elevation(elevation_map, passes: 1)
      passes.times do
        elevation_map = apply_smoothing_pass(elevation_map)
      end
      elevation_map
    end

    def apply_smoothing_pass(elevation_map)
      height = elevation_map.size
      width = elevation_map.first.size

      smoothed = Array.new(height) { Array.new(width) }

      height.times do |y|
        width.times do |x|
          neighbors = get_neighbor_values(elevation_map, x, y)
          smoothed[y][x] = (elevation_map[y][x] + neighbors.sum.to_f / neighbors.size) / 2.0
        end
      end

      smoothed
    end

    def get_neighbor_values(grid, x, y)
      neighbors = []
      [-1, 0, 1].each do |dy|
        [-1, 0, 1].each do |dx|
          next if dx == 0 && dy == 0
          nx, ny = x + dx, y + dy
          if nx >= 0 && nx < grid.first.size && ny >= 0 && ny < grid.size
            neighbors << grid[ny][nx] if grid[ny][nx]
          end
        end
      end
      neighbors
    end

    def add_realistic_variation(elevation_map, amount: 0.05)
      height = elevation_map.size
      width = elevation_map.first.size

      # First pass: Add biome-aware variation (Phase 1 Quick Fix)
      # This addresses the Sahara problem and other flat desert regions
      enhanced_elevation = Array.new(height) do |y|
        Array.new(width) do |x|
          base_elev = elevation_map[y][x]

          # Find the corresponding plot to get biome information
          plot = find_plot_at(@raw_data[:plots], x, y) if @raw_data
          biome = extract_biome_from_plot(plot) if plot

          # CRITICAL: Never push land areas below sea level
          is_land = base_elev > 0.50 || (biome && biome != :ocean && biome != :coast)
          min_elevation = is_land ? 0.55 : 0.05  # Higher land minimum vs water minimum

          # Apply desert elevation enhancement (Quick Fix for Grok)
          if biome == :desert && base_elev < 0.5
            # Boost desert elevation + add variation for realistic plateaus/dunes
            variation = (rand * 0.3) - 0.15  # -0.15 to +0.15 random variation
            enhanced_elev = base_elev + 0.15 + variation
            enhanced_elev = [enhanced_elev, 0.80].min  # Cap at 0.80 to avoid mountain levels
            enhanced_elev = [enhanced_elev, min_elevation].max  # Respect land/water minimum
          else
            # Standard variation for other biomes
            variation = (rand - 0.5) * amount * 2
            enhanced_elev = base_elev + variation
            enhanced_elev = [enhanced_elev, min_elevation].max  # Never below minimum
          end

          # Clamp to valid range
          [0.0, [enhanced_elev, 1.0].min].max
        end
      end

      enhanced_elevation
    end

    def smooth_elevation(elevation_map, passes: 1)
      smoothed = elevation_map

      passes.times do
        smoothed = apply_smoothing_pass(smoothed)
      end

      smoothed
    end

    # Placeholder methods (to be implemented)
    def analyze_settlement_advantages(plot); {}; end
    def calculate_settlement_priority(plot); 1; end
    def identify_strategic_type(plot); :unknown; end
    def assess_strategic_value(plot); 1; end
    def adjacent_to_water?(plot); false; end
    def has_adjacent_lowlands?(plot); false; end

    def extract_biome_from_plot(plot)
      return :unknown unless plot

      terrain_type = plot[:terrain_type]

      case terrain_type
      when /DESERT/ then :desert
      when /GRASS/ then :grasslands
      when /PLAINS/ then :plains
      when /TUNDRA/ then :tundra
      when /SNOW/ then :arctic
      when /OCEAN/ then :ocean
      when /COAST/ then :coast
      when /FOREST/ then :forest
      when /JUNGLE/ then :jungle
      when /MARSH/ then :wetlands
      else :unknown
      end
    end

    # Mars Blueprint Extraction Methods
    def extract_mars_blueprints(raw_data, source_file)
      Rails.logger.info "[Civ4MapProcessor] Extracting Mars terraforming blueprints from #{source_file}"

      {
        settlement_sites: extract_settlement_sites(raw_data),
        terraforming_targets: extract_terraforming_targets(raw_data),
        geological_features: extract_geological_features(raw_data),
        historical_water_levels: estimate_historical_water_levels(raw_data),
        source_file: source_file,
        extraction_metadata: {
          format: 'civ4_worldbuilder_save',
          planet_type: 'mars',
          extraction_mode: 'blueprint',
          extracted_at: Time.current.iso8601
        }
      }
    end

    def extract_settlement_sites(raw_data)
      settlement_sites = []

      raw_data[:plots].each do |plot|
        x, y = plot[:x], plot[:y]

        # Extract from cities
        if plot[:city_name]
          settlement_sites << {
            x: x,
            y: y,
            type: :city_site,
            name: plot[:city_name],
            suitability: assess_city_suitability(plot),
            features: extract_city_features(plot)
          }
        end

        # Extract from starting positions
        if plot[:starting_position]
          settlement_sites << {
            x: x,
            y: y,
            type: :starting_position,
            suitability: :high,
            features: [:strategic_location]
          }
        end

        # Extract from goody huts (potential settlement sites)
        if plot[:improvement_type]&.include?('GOODY_HUT')
          settlement_sites << {
            x: x,
            y: y,
            type: :goody_hut,
            suitability: :medium,
            features: [:resource_rich, :exploration_site]
          }
        end
      end

      settlement_sites
    end

    def extract_terraforming_targets(raw_data)
      targets = []

      raw_data[:plots].each do |plot|
        x, y = plot[:x], plot[:y]
        terrain_type = plot[:terrain_type]
        plot_type = plot[:plot_type]

        # Use reverse mapping from TerrainTerraformingService
        target_biome = map_terrain_to_terraforming_target(terrain_type, plot_type)

        if target_biome
          targets << {
            x: x,
            y: y,
            target_biome: target_biome,
            current_terrain: terrain_type,
            priority: calculate_terraforming_priority(plot),
            constraints: extract_terraforming_constraints(plot)
          }
        end
      end

      targets
    end

    def extract_geological_features(raw_data)
      features = []

      raw_data[:plots].each do |plot|
        x, y = plot[:x], plot[:y]

        # Extract from bonus types (resources)
        if plot[:bonus_type]
          features << {
            x: x,
            y: y,
            type: :resource_deposit,
            resource: plot[:bonus_type],
            geological_context: infer_geological_context(plot)
          }
        end

        # Extract from features (rivers, mountains, etc.)
        if plot[:feature_type]
          features << {
            x: x,
            y: y,
            type: :terrain_feature,
            feature: plot[:feature_type],
            geological_significance: assess_geological_significance(plot)
          }
        end
      end

      features
    end

    def estimate_historical_water_levels(raw_data)
      water_features = []

      raw_data[:plots].each do |plot|
        x, y = plot[:x], plot[:y]
        terrain_type = plot[:terrain_type]
        plot_type = plot[:plot_type]

        # Identify ancient water features
        if plot_type == 3 && (terrain_type&.include?('OCEAN') || terrain_type&.include?('COAST'))
          water_features << {
            x: x,
            y: y,
            type: :ancient_shoreline,
            water_type: terrain_type&.include?('OCEAN') ? :ocean : :coast,
            elevation_adjustment: calculate_water_level_adjustment(plot)
          }
        end
      end

      {
        features: water_features,
        estimated_ocean_coverage: calculate_ocean_coverage(water_features, raw_data),
        shoreline_migration_notes: "Current terrain represents post-atmospheric-loss state. Ancient shorelines indicate viable terraforming basins."
      }
    end

    private

    # Helper methods for blueprint extraction
    def assess_city_suitability(plot)
      score = 0
      score += 2 if plot[:terrain_type]&.include?('PLAINS')  # Good for agriculture
      score += 1 if plot[:terrain_type]&.include?('GRASS')   # Moderate agriculture
      score += 1 if plot[:bonus_type]                        # Resources nearby
      score += 1 if plot[:feature_type]&.include?('RIVER')  # Water access
      score -= 1 if plot[:terrain_type]&.include?('DESERT') # Harsh conditions
      score -= 1 if plot[:terrain_type]&.include?('SNOW')   # Cold

      case score
      when 3.. then :excellent
      when 1..2 then :good
      when 0 then :moderate
      else :poor
      end
    end

    def extract_city_features(plot)
      features = []
      features << :river_access if plot[:river_directions]&.any?
      features << :resource_rich if plot[:bonus_type]
      features << :defensible if plot[:terrain_type]&.include?('HILL')
      features << :coastal if plot[:terrain_type]&.include?('COAST')
      features
    end

    def map_terrain_to_terraforming_target(terrain_type, plot_type)
      # Use reverse mapping logic from TerrainTerraformingService
      case terrain_type
      when /GRASS/ then :desert  # Grasslands become regolith desert
      when /PLAINS/ then :desert # Plains become barren plains
      when /DESERT/ then :desert # Deserts remain barren
      when /TUNDRA/ then :tundra # Tundra remains cold
      when /SNOW/ then :arctic   # Arctic remains as polar cap
      when /OCEAN/ then :deep_sea if plot_type == 3 # Ocean becomes deep sea basin
      when /COAST/ then :swamp if plot_type == 3   # Coast becomes swampy lowland
      else :rocky  # Default to rocky
      end
    end

    def calculate_terraforming_priority(plot)
      priority = 1
      priority += 2 if plot[:bonus_type]  # Resources increase priority
      priority += 1 if plot[:terrain_type]&.include?('PLAINS')  # Easier to terraform
      priority += 1 if plot[:river_directions]&.any?  # Water access
      priority
    end

    def extract_terraforming_constraints(plot)
      constraints = {}
      constraints[:water_required] = true if plot[:terrain_type]&.include?('DESERT')
      constraints[:atmosphere_required] = true if plot[:terrain_type]&.include?('SNOW')
      constraints[:soil_amendment] = true if plot[:terrain_type]&.include?('PLAINS')
      constraints
    end

    def infer_geological_context(plot)
      context = []
      context << :volcanic if plot[:terrain_type]&.include?('HILL') && plot[:bonus_type]&.include?('IRON')
      context << :sedimentary if plot[:terrain_type]&.include?('PLAINS') && plot[:bonus_type]&.include?('OIL')
      context << :igneous if plot[:terrain_type]&.include?('MOUNTAIN')
      context << :aqueous if plot[:river_directions]&.any?
      context
    end

    def assess_geological_significance(plot)
      significance = :minor
      significance = :major if plot[:feature_type]&.include?('MOUNTAIN')
      significance = :major if plot[:bonus_type]&.include?('URANIUM')
      significance = :moderate if plot[:river_directions]&.any?
      significance
    end

    def calculate_water_level_adjustment(plot)
      # Ancient shorelines should be at lower elevations than current terrain
      base_adjustment = -0.2  # Lower elevation for ancient water
      base_adjustment -= 0.1 if plot[:terrain_type]&.include?('OCEAN')  # Deeper for oceans
      base_adjustment
    end

    def calculate_ocean_coverage(water_features, raw_data)
      total_plots = raw_data[:width] * raw_data[:height]
      water_plots = water_features.size
      (water_plots.to_f / total_plots * 100).round(2)
    end
  end
end