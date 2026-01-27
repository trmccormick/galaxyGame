# app/services/terrain_analysis/terrain_decomposition_service.rb

require_relative 'hydrosphere_volume_service'

module TerrainAnalysis
  class TerrainDecompositionService
    # Decomposes mixed terrain data into separate dynamic layers
    # Enables realistic terraforming with independent geological, hydrological, and biological systems

    # Terrain type classifications for layer separation
    GEOLOGICAL_TERRAIN = [:rocky, :mountains, :desert, :plains, :tundra, :arctic].freeze
    HYDROLOGICAL_TERRAIN = [:ocean, :deep_sea, :coast, :swamp].freeze
    BIOLOGICAL_TERRAIN = [:grasslands, :forest, :jungle, :boreal_forest].freeze

    # Elevation ranges for different terrain types (normalized 0.0-1.0)
    ELEVATION_RANGES = {
      deep_sea: 0.0..0.1,
      coast: 0.1..0.2,
      plains: 0.2..0.4,
      grasslands: 0.3..0.5,
      forest: 0.4..0.6,
      jungle: 0.4..0.6,
      desert: 0.2..0.7,
      rocky: 0.3..0.8,
      mountains: 0.7..1.0,
      tundra: 0.5..0.8,
      arctic: 0.8..1.0,
      swamp: 0.1..0.3,
      boreal_forest: 0.5..0.8
    }.freeze

    attr_reader :terrain_data

    def initialize(terrain_data)
      @terrain_data = terrain_data
    end

    # Decompose terrain into separate layers with elevation and water volume
    def decompose
      grid = @terrain_data['grid'] || @terrain_data[:grid]
      width = @terrain_data['width'] || @terrain_data[:width] || grid&.first&.size || 0
      height = @terrain_data['height'] || @terrain_data[:height] || grid&.size || 0

      return {} unless grid && width > 0 && height > 0

      # Generate elevation map from terrain types
      elevation_map = generate_elevation_map(grid, width, height)

      # Separate terrain into layers
      layers = separate_into_layers(grid, width, height)

      # Initialize water volume (can be modified by terraforming)
      initial_water_volume = calculate_initial_water_volume(layers['hydrological'])

      # Create decomposed terrain map
      decomposed_map = {
        'width' => width,
        'height' => height,
        'elevation' => elevation_map,
        'water_volume' => initial_water_volume,
        'layers' => layers,
        'biome_counts' => @terrain_data['biome_counts'] || @terrain_data[:biome_counts] || {}
      }

      # Apply dynamic water distribution
      hydrosphere_service = TerrainAnalysis::HydrosphereVolumeService.new(decomposed_map)
      hydrosphere_service.update_water_bodies
    end

    private

    # Generate elevation map based on terrain types
    def generate_elevation_map(grid, width, height)
      elevation_map = Array.new(height) { Array.new(width) }

      height.times do |y|
        width.times do |x|
          terrain_type = grid[y][x]
          elevation_map[y][x] = generate_elevation_for_terrain(terrain_type)
        end
      end

      elevation_map
    end

    # Generate realistic elevation for a terrain type
    def generate_elevation_for_terrain(terrain_type)
      range = ELEVATION_RANGES[terrain_type] || (0.2..0.6)
      # Add some randomness within the range for natural variation
      min_elev, max_elev = range.min, range.max
      min_elev + (max_elev - min_elev) * rand()
    end

    # Separate terrain grid into geological, hydrological, and biological layers
    def separate_into_layers(grid, width, height)
      geological = Array.new(height) { Array.new(width) }
      hydrological = Array.new(height) { Array.new(width) }
      biological = Array.new(height) { Array.new(width) }

      height.times do |y|
        width.times do |x|
          terrain_type = grid[y][x]

          if GEOLOGICAL_TERRAIN.include?(terrain_type)
            geological[y][x] = terrain_type
          elsif HYDROLOGICAL_TERRAIN.include?(terrain_type)
            hydrological[y][x] = terrain_type
          elsif BIOLOGICAL_TERRAIN.include?(terrain_type)
            biological[y][x] = terrain_type
          else
            # Default to geological for unrecognized terrain
            geological[y][x] = :rocky
          end
        end
      end

      {
        'geological' => geological,
        'hydrological' => hydrological,
        'biological' => biological
      }
    end

    # Calculate initial water volume from hydrological layer
    def calculate_initial_water_volume(hydrological_layer)
      return 0.0 unless hydrological_layer

      total_tiles = hydrological_layer.flatten.size
      return 0.0 if total_tiles == 0

      water_tiles = hydrological_layer.flatten.compact.count do |terrain|
        [:ocean, :deep_sea, :coast, :swamp].include?(terrain)
      end

      water_tiles.to_f / total_tiles
    end
  end
end