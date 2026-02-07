# app/services/import/civ4_wbs_import_service.rb
# app/services/import/civ4_wbs_import_service.rb
module Import
  class Civ4WbsImportService
    # Civ4 TerrainType mappings to Galaxy Game terrain types
    TERRAIN_TYPE_MAPPING = {
      'TERRAIN_GRASS' => :grasslands,
      'TERRAIN_PLAINS' => :plains,
      'TERRAIN_DESERT' => :desert,
      'TERRAIN_TUNDRA' => :tundra,
      'TERRAIN_SNOW' => :arctic,
      'TERRAIN_COAST' => :ocean,      # Shallow coastal water
      'TERRAIN_OCEAN' => :deep_sea    # Deep ocean
    }.freeze

    # Civ4 FeatureType mappings (overlays on terrain)
    FEATURE_TYPE_MAPPING = {
      'FEATURE_FOREST' => :forest,
      'FEATURE_JUNGLE' => :jungle,
      'FEATURE_ICE' => :arctic,        # Ice overlay
      'FEATURE_FALLOUT' => :rocky,     # Radioactive fallout → rocky
      'FEATURE_OASIS' => :swamp        # Oasis → water collection
    }.freeze

    # Civ4 BonusType mappings to Galaxy Game resource categories
    BONUS_TYPE_MAPPING = {
      'BONUS_IRON' => :metal_ore,
      'BONUS_COAL' => :carbon,
      'BONUS_OIL' => :hydrocarbons,
      'BONUS_ALUMINUM' => :metal_ore,
      'BONUS_SILVER' => :precious_metal,
      'BONUS_GOLD' => :precious_metal,
      'BONUS_URANIUM' => :radioactive,
      'BONUS_COPPER' => :metal_ore,
      'BONUS_HORSE' => :organic,
      'BONUS_COW' => :organic,
      'BONUS_CORN' => :organic,
      'BONUS_WHALE' => :organic,
      'BONUS_PIG' => :organic,
      'BONUS_FISH' => :organic,
      'BONUS_CLAM' => :organic,
      'BONUS_CRAB' => :organic,
      'BONUS_RICE' => :organic,
      'BONUS_WHEAT' => :organic,
      'BONUS_DYE' => :organic,
      'BONUS_FUR' => :organic,
      'BONUS_IVORY' => :organic,
      'BONUS_SILK' => :organic,
      'BONUS_SPICE' => :organic,
      'BONUS_SUGAR' => :organic,
      'BONUS_TEA' => :organic,
      'BONUS_TOBACCO' => :organic,
      'BONUS_WINE' => :organic,
      'BONUS_INCENSE' => :organic,
      'BONUS_MARBLE' => :construction,
      'BONUS_STONE' => :construction,
      'BONUS_SALT' => :chemical
    }.freeze

    # Default terrain type for unrecognized combinations
    DEFAULT_TERRAIN = :rocky

    attr_reader :file_path, :errors

    def initialize(file_path)
      @file_path = file_path
      @errors = []
    end

    # Main import method - parses WBS file and returns terrain grid
    def import
      return false unless validate_file

      terrain_grid = []
      biome_counts = Hash.new(0)
      resource_counts = Hash.new(0)
      map_data = parse_wbs_file

      return false unless map_data

      # Extract grid dimensions
      width = map_data[:width]
      height = map_data[:height]

      # Initialize empty grids
      terrain_grid = Array.new(height) { Array.new(width) }
      resource_grid = Array.new(height) { Array.new(width) }

      # Process each plot
      map_data[:plots].each do |plot|
        x, y = plot[:x], plot[:y]

        # Skip if coordinates are out of bounds
        next if x >= width || y >= height || x < 0 || y < 0

        # Determine terrain type using the CORRECTED logic
        terrain_type = determine_terrain_type(plot)
        biome_counts[terrain_type] += 1

        # Determine resource type if present
        resource_type = determine_resource_type(plot)
        resource_counts[resource_type] += 1 if resource_type

        # Store in grids (note: Civ4 uses x,y but we want row,column)
        terrain_grid[y][x] = terrain_type
        resource_grid[y][x] = resource_type
      end

      # Validate we got some data
      if terrain_grid.flatten.compact.empty?
        @errors << "No terrain data found in WBS file"
        return false
      end

      # Fill any missing spots with default terrain
      terrain_grid.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          if cell.nil?
            terrain_grid[y][x] = DEFAULT_TERRAIN
            biome_counts[DEFAULT_TERRAIN] += 1
          end
        end
      end

      {
        grid: terrain_grid,
        width: width,
        height: height,
        biome_counts: biome_counts,
        resource_grid: resource_grid,
        resource_counts: resource_counts,
        source_file: @file_path
      }

    rescue => e
      @errors << "Error parsing WBS file: #{e.message}"
      false
    end

    private

    # Validate the file exists and is readable
    def validate_file
      unless File.exist?(@file_path)
        @errors << "WBS file not found: #{@file_path}"
        return false
      end

      unless File.readable?(@file_path)
        @errors << "WBS file not readable: #{@file_path}"
        return false
      end

      true
    end

    # Parse the Civ4 World Builder Save file
    def parse_wbs_file
      plots = []
      width = nil
      height = nil
      in_map_section = false
      in_plot_section = false
      current_plot = nil

      File.open(@file_path, 'r') do |file|
        file.each_line do |line|
          line.strip!

          case line
          when /^BeginMap$/
            in_map_section = true
          when /^EndMap$/
            in_map_section = false
          when /^BeginPlot$/
            # Close previous plot if any
            if current_plot
              plots << current_plot
              current_plot = nil
            end
            in_plot_section = true
            current_plot = {}
          else
            if in_map_section && line.include?('grid width=')
              width = line.match(/grid width=(\d+)/)&.[](1)&.to_i
            elsif in_map_section && line.include?('grid height=')
              height = line.match(/grid height=(\d+)/)&.[](1)&.to_i
            elsif in_plot_section && current_plot
              parse_plot_line(line, current_plot)
            end
          end
        end
      end

      # Close last plot if any
      plots << current_plot if current_plot

      unless width && height
        @errors << "Could not determine map dimensions from WBS file"
        return nil
      end

      { width: width, height: height, plots: plots }
    end

    # Parse a line within a plot section
    def parse_plot_line(line, plot)
      if line.start_with?('x=')
        # x=0,y=0
        coords = line.match(/x=(\d+),y=(\d+)/)
        if coords
          plot[:x] = coords[1].to_i
          plot[:y] = coords[2].to_i
        end
      elsif line.start_with?('PlotType=')
        plot[:plot_type] = line.match(/PlotType=(\d+)/)&.[](1)&.to_i
      elsif line.start_with?('TerrainType=')
        terrain_match = line.match(/TerrainType=([^,]+)/)
        plot[:terrain_type] = terrain_match[1].strip if terrain_match
      elsif line.start_with?('FeatureType=')
        # Extract feature type (may have variety like "FEATURE_FOREST, FeatureVariety=1")
        feature_match = line.match(/FeatureType=([^,]+)/)
        plot[:feature_type] = feature_match[1].strip if feature_match
      elsif line.start_with?('BonusType=')
        # Resource/bonus (for future use)
        bonus_match = line.match(/BonusType=([^,]+)/)
        plot[:bonus_type] = bonus_match[1].strip if bonus_match
      elsif line.include?('River')
        # River data (for future use)
        plot[:has_river] = true
      end
    end

    # Determine Galaxy Game terrain type from Civ4 plot data
    # This is the CORRECTED logic based on actual Civ4 data structure
    def determine_terrain_type(plot)
      plot_type = plot[:plot_type]
      terrain_type = plot[:terrain_type]
      feature_type = plot[:feature_type]

      # STEP 1: Handle water tiles (PlotType=3 is WATER, not mountains!)
      if plot_type == 3
        # This is water - check if it's ocean or coast
        case terrain_type
        when 'TERRAIN_OCEAN'
          # Check for ice feature
          return :arctic if feature_type&.include?('ICE')
          return :deep_sea
        when 'TERRAIN_COAST'
          # Check for ice feature
          return :arctic if feature_type&.include?('ICE')
          return :ocean
        else
          # Unknown water type, default to ocean
          return :ocean
        end
      end

      # STEP 2: Handle feature overlays (forests, jungles have priority over base terrain)
      if feature_type && FEATURE_TYPE_MAPPING.key?(feature_type)
        # Feature determines the terrain type
        feature_terrain = FEATURE_TYPE_MAPPING[feature_type]
        
        # Special case: forest on tundra should be boreal
        if feature_terrain == :forest && terrain_type == 'TERRAIN_TUNDRA'
          return :boreal
        end
        
        # Special case: forest on hills should be boreal
        if feature_terrain == :forest && plot_type == 2
          return :boreal
        end
        
        return feature_terrain
      end

      # STEP 3: Handle base terrain types for land
      base_terrain = TERRAIN_TYPE_MAPPING[terrain_type]
      
      if base_terrain
        # Special handling for hills (PlotType=2)
        if plot_type == 2
          # Hills are elevated terrain
          case base_terrain
          when :grasslands, :plains
            return :boreal  # Forested hills
          when :desert
            return :rocky   # Desert hills are rocky
          when :tundra
            return :boreal  # Tundra hills are forested
          when :arctic
            return :rocky   # Arctic hills are rocky peaks
          else
            return base_terrain
          end
        else
          # Flat land (PlotType=0 or 1)
          return base_terrain
        end
      end

      # STEP 4: Fallback to default
      DEFAULT_TERRAIN
    end

    # Determine Galaxy Game resource type from Civ4 bonus type
    def determine_resource_type(plot)
      bonus_type = plot[:bonus_type]
      return nil unless bonus_type

      BONUS_TYPE_MAPPING[bonus_type] || :unknown
    end
  end
end