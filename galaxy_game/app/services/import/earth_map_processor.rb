# app/services/import/earth_map_processor.rb
module Import
  class EarthMapProcessor
    # Special processor for Earth - combines FreeCiv and Civ4 data for full habitable rendering

    def self.find_earth_freeciv_map
      # Look for Earth FreeCiv maps in various locations
      # Check in earth subfolder (primary location)
      Dir.glob(File.join(GalaxyGame::Paths::FREECIV_MAPS_PATH, 'earth', 'earth*.sav')).first ||
      Dir.glob(File.join(GalaxyGame::Paths::FREECIV_MAPS_PATH, 'earth*.sav')).first ||
      Dir.glob(File.join(GalaxyGame::Paths::FREECIV_MAPS_PATH, '**', 'earth*.sav')).first ||
      Dir.glob(File.join(GalaxyGame::Paths::PARTIAL_PLANETARY_MAPS_PATH, 'earth*.sav')).first ||
      Dir.glob(File.join(Rails.root, 'data', 'maps', 'freeciv', 'earth', 'earth*.sav')).first ||
      Dir.glob(File.join(Rails.root, 'data', 'maps', 'freeciv', 'earth*.sav')).first
    end

    def self.find_earth_civ4_map
      # Look for Earth Civ4 maps (prefer larger/detailed ones)
      # Check in earth subfolder first, then other locations
      candidates = Dir.glob(File.join(GalaxyGame::Paths::CIV4_MAPS_PATH, 'earth', '*.Civ4WorldBuilderSave')) +
                   Dir.glob(File.join(GalaxyGame::Paths::CIV4_MAPS_PATH, '*earth*.Civ4WorldBuilderSave')) +
                   Dir.glob(File.join(GalaxyGame::Paths::CIV4_MAPS_PATH, '**', '*[Ee]arth*.Civ4WorldBuilderSave')) +
                   Dir.glob('data/Civ4_Maps/*earth*.Civ4WorldBuilderSave')

      # Prefer larger maps
      candidates.max_by { |path| File.basename(path).match(/(\d+)x(\d+)/)&.captures&.map(&:to_i)&.inject(:*) || 0 }
    end

    def initialize(freeciv_path: nil, civ4_path: nil)
      @freeciv_path = freeciv_path || self.class.find_earth_freeciv_map
      @civ4_path = civ4_path || self.class.find_earth_civ4_map
      @errors = []
    end

    # Process Earth data from available sources
    def process
      earth_data = {
        lithosphere: { elevation: nil, structure: nil },
        hydrosphere: { water_mask: nil, current_coverage: 0.71 }, # Earth's actual water coverage
        biosphere: { potential: nil, current_density: 1.0 }, # Earth is fully habitable
        metadata: {
          planet_type: 'earth',
          rendering_mode: 'full_habitable', # Not bare terrain
          sources_used: []
        }
      }

      # Try to load FreeCiv data (primary source for terrain/water)
      if @freeciv_path && File.exist?(@freeciv_path)
        freeciv_data = FreecivSavImportService.new(@freeciv_path).import
        if freeciv_data
          earth_data[:lithosphere][:structure] = extract_terrain_from_freeciv(freeciv_data)
          earth_data[:hydrosphere][:water_mask] = extract_water_from_freeciv(freeciv_data)
          earth_data[:metadata][:sources_used] << 'freeciv'
        end
      end

      # Try to load Civ4 data (secondary source for biomes/elevation hints)
      if @civ4_path && File.exist?(@civ4_path)
        civ4_data = Civ4WbsImportService.new(@civ4_path).import
        if civ4_data
          # Use Civ4 for elevation generation and biome refinement
          earth_data[:lithosphere][:elevation] = generate_elevation_from_civ4(civ4_data)
          earth_data[:biosphere][:potential] = extract_biomes_from_civ4(civ4_data)
          earth_data[:metadata][:sources_used] << 'civ4'
        end
      end

      # Generate fallback elevation if no Civ4 data
      if earth_data[:lithosphere][:elevation].nil?
        earth_data[:lithosphere][:elevation] = generate_fallback_elevation(
          earth_data[:lithosphere][:structure]
        )
      end

      # Apply Earth's full habitability
      earth_data[:biosphere][:current_density] = 1.0

      earth_data
    end

    private

    # Extract terrain structure from FreeCiv (more detailed continents)
    def extract_terrain_from_freeciv(freeciv_data)
      grid = freeciv_data[:grid]
      width = freeciv_data[:width]
      height = freeciv_data[:height]

      # Convert FreeCiv terrain codes to Galaxy Game terrain types
      terrain_grid = Array.new(height) do |y|
        Array.new(width) do |x|
          freeciv_code = grid[y][x]
          freeciv_to_galaxy_terrain(freeciv_code)
        end
      end

      terrain_grid
    end

    # Extract water bodies from FreeCiv
    def extract_water_from_freeciv(freeciv_data)
      grid = freeciv_data[:grid]
      width = freeciv_data[:width]
      height = freeciv_data[:height]

      water_mask = Array.new(height) do |y|
        Array.new(width) do |x|
          freeciv_code = grid[y][x]
          # FreeCiv: ' ' = ocean, ':' = deep ocean, '+' = lake
          [' ', ':', '+'].include?(freeciv_code) ? 1.0 : 0.0
        end
      end

      water_mask
    end

    # Generate elevation from Civ4 data (either plots or grid format)
    def generate_elevation_from_civ4(civ4_data)
      width = civ4_data[:width]
      height = civ4_data[:height]

      elevation_map = Array.new(height) { Array.new(width, 0.5) }

      # Handle grid-based format (from Civ4WbsImportService)
      if civ4_data[:grid]
        civ4_data[:grid].each_with_index do |row, y|
          row.each_with_index do |terrain_type, x|
            next if x >= width || y >= height
            elevation_map[y][x] = base_elevation_for_terrain(terrain_type)
          end
        end
      elsif civ4_data[:plots]
        # Handle plots-based format (legacy)
        civ4_data[:plots].each do |plot|
          x, y = plot[:x], plot[:y]
          next if x >= width || y >= height || x < 0 || y < 0

          elevation = calculate_elevation_from_plot(plot)
          elevation_map[y][x] = elevation
        end
      end

      # Smooth for continuity
      smooth_elevation_map(elevation_map)
    end

    # Extract biomes from Civ4 for Earth
    def extract_biomes_from_civ4(civ4_data)
      width = civ4_data[:width]
      height = civ4_data[:height]

      biome_grid = Array.new(height) { Array.new(width, 0.0) }

      # Handle grid-based format (from Civ4WbsImportService)
      if civ4_data[:grid]
        civ4_data[:grid].each_with_index do |row, y|
          row.each_with_index do |terrain_type, x|
            next if x >= width || y >= height
            # Convert terrain type to biome density
            biome_grid[y][x] = terrain_type == :ocean || terrain_type == :deep_sea ? 0.0 : 0.8
          end
        end
      elsif civ4_data[:plots]
        # Handle plots-based format (legacy)
        civ4_data[:plots].each do |plot|
          x, y = plot[:x], plot[:y]
          next if x >= width || y >= height || x < 0 || y < 0

          biome_density = calculate_biome_density_from_plot(plot)
          biome_grid[y][x] = biome_density
        end
      end

      biome_grid
    end

    # Generate fallback elevation when no Civ4 data available
    def generate_fallback_elevation(terrain_grid)
      return nil unless terrain_grid

      height = terrain_grid.length
      width = terrain_grid.first.length

      elevation_map = Array.new(height) do |y|
        Array.new(width) do |x|
          terrain_type = terrain_grid[y][x]
          base_elevation_for_terrain(terrain_type) + random_variation
        end
      end

      smooth_elevation_map(elevation_map)
    end

    # FreeCiv terrain code to Galaxy Game terrain type
    def freeciv_to_galaxy_terrain(code)
      case code
      when 'a' then :arctic
      when ':' then :deep_sea
      when 'd' then :desert
      when 'f' then :forest
      when 'p' then :plains
      when 'g' then :grasslands
      when 'h' then :mountains  # hills
      when 'j' then :jungle
      when '+' then :ocean      # lake
      when 'm' then :mountains
      when ' ' then :ocean
      when 's' then :swamp
      when 't' then :tundra
      else :plains
      end
    end

    # Calculate elevation from Civ4 plot data
    def calculate_elevation_from_plot(plot)
      plot_type = plot[:plot_type]
      terrain_type = plot[:terrain_type]

      # Base elevation from PlotType
      base = case plot_type
      when 0 then 0.45  # Flat
      when 1 then 0.35  # Coastal
      when 2 then 0.70  # Hills
      when 3 then        # Water or peaks
        case terrain_type
        when 'TERRAIN_OCEAN' then 0.10
        when 'TERRAIN_COAST' then 0.20
        when 'TERRAIN_SNOW' then 0.90
        else 0.10
        end
      else 0.50
      end

      # Terrain adjustments
      base += 0.30 if terrain_type&.include?('SNOW')
      base += 0.10 if terrain_type&.include?('TUNDRA')

      [[base, 0.0].max, 1.0].min
    end

    # Calculate biome density for Earth (fully habitable)
    def calculate_biome_density_from_plot(plot)
      terrain_type = plot[:terrain_type]
      feature_type = plot[:feature_type]

      # Earth has full biome development
      density = 1.0

      # Some terrains are less densely developed
      density *= 0.7 if terrain_type == 'TERRAIN_DESERT'
      density *= 0.8 if terrain_type == 'TERRAIN_TUNDRA'
      density *= 0.9 if terrain_type == 'TERRAIN_SNOW'

      # Features can enhance density
      density *= 1.2 if feature_type&.include?('FOREST')
      density *= 1.1 if feature_type&.include?('JUNGLE')

      [[density, 0.0].max, 1.0].min
    end

    # Base elevation for terrain types
    def base_elevation_for_terrain(terrain_type)
      case terrain_type
      when :ocean, :deep_sea then 0.1
      when :arctic, :tundra then 0.6
      when :grasslands, :plains then 0.4
      when :forest, :jungle then 0.5
      when :desert then 0.3
      when :mountains then 0.8
      when :swamp then 0.2
      else 0.4
      end
    end

    def random_variation
      (rand - 0.5) * 0.2  # ±0.1 variation
    end

    # Simple smoothing algorithm
    def smooth_elevation_map(elevation_map)
      height = elevation_map.length
      width = elevation_map.first.length

      smoothed = Array.new(height) do |y|
        Array.new(width) do |x|
          neighbors = []
          [-1, 0, 1].each do |dy|
            [-1, 0, 1].each do |dx|
              ny, nx = y + dy, x + dx
              if ny >= 0 && ny < height && nx >= 0 && nx < width
                neighbors << elevation_map[ny][nx]
              end
            end
          end

          if neighbors.any?
            (neighbors.sum / neighbors.size)
          else
            elevation_map[y][x]
          end
        end
      end

      smoothed
    end
  end
end