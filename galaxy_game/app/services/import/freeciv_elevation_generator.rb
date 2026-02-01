# app/services/import/freeciv_elevation_generator.rb
module Import
  class FreecivElevationGenerator
    # Generate elevation data for FreeCiv maps using constrained random values based on biomes
    # Since FreeCiv maps only have biomes, we generate elevation probabilistically

    BIOME_ELEVATION_RANGES = {
      'a' => { min: 0.80, max: 1.0,  bias: :high },    # Arctic - high elevation
      'd' => { min: 0.20, max: 0.60, bias: :low },     # Desert - variable, often low
      'f' => { min: 0.30, max: 0.70, bias: :medium },  # Forest - moderate elevation
      'g' => { min: 0.25, max: 0.65, bias: :medium },  # Grasslands - moderate
      'h' => { min: 0.60, max: 0.90, bias: :high },    # Hills - high elevation
      'j' => { min: 0.10, max: 0.40, bias: :low },     # Jungle - low elevation
      'm' => { min: 0.70, max: 1.0,  bias: :high },    # Mountains - very high
      'p' => { min: 0.15, max: 0.55, bias: :low },     # Plains - low to medium
      's' => { min: 0.05, max: 0.35, bias: :low },     # Swamp - very low
      't' => { min: 0.40, max: 0.80, bias: :medium },  # Tundra - medium to high
      ' ' => { min: 0.0,  max: 0.15, bias: :water },   # Ocean - below sea level
      '+' => { min: 0.0,  max: 0.20, bias: :water },   # Lake - below sea level
      ':' => { min: 0.0,  max: 0.10, bias: :water }    # Deep sea - well below
    }.freeze

    def initialize(seed: nil)
      @random = seed ? Random.new(seed) : Random.new
    end

    # Generate elevation map for FreeCiv terrain data
    # @param terrain_grid [Array<Array<String>>] 2D array of FreeCiv terrain characters
    # @return [Hash] Elevation data with height map and metadata
    def generate_elevation(terrain_grid)
      return {} unless terrain_grid.is_a?(Array) && terrain_grid.any?

      height = terrain_grid.length
      width = terrain_grid.first.length

      elevation_map = Array.new(height) do |y|
        Array.new(width) do |x|
          biome = terrain_grid[y][x]
          generate_elevation_for_biome(biome)
        end
      end

      # Apply smoothing for continuity
      elevation_map = smooth_elevation_map(elevation_map)

      {
        elevation: elevation_map,
        quality: 'generated_50_70_percent',
        method: 'biome_constrained_random',
        seed: @random.seed
      }
    end

    private

    # Generate elevation for a specific biome
    def generate_elevation_for_biome(biome)
      range = BIOME_ELEVATION_RANGES[biome] || BIOME_ELEVATION_RANGES['g'] # Default to grasslands

      # Generate random value within biome range
      random_factor = @random.rand
      base_elevation = range[:min] + (random_factor * (range[:max] - range[:min]))

      # Apply bias adjustments
      base_elevation = apply_bias_adjustment(base_elevation, range[:bias])

      # Clamp to valid range
      [[base_elevation, 0.0].max, 1.0].min
    end

    # Apply bias adjustments for more realistic terrain
    def apply_bias_adjustment(elevation, bias)
      case bias
      when :high
        elevation * 1.1  # Boost high-biome elevations
      when :low
        elevation * 0.9  # Reduce low-biome elevations
      when :water
        elevation * 0.8  # Keep water areas low
      else
        elevation
      end
    end

    # Smooth elevation map for continuity
    def smooth_elevation_map(elevation_map)
      height = elevation_map.length
      width = elevation_map.first.length

      smoothed = Array.new(height) do |y|
        Array.new(width) do |x|
          neighbors = get_neighbors(elevation_map, x, y, width, height)
          current = elevation_map[y][x]

          if neighbors.size >= 4
            # Weighted average: 60% current, 40% neighbor average
            neighbor_avg = neighbors.sum / neighbors.size
            (current * 0.6) + (neighbor_avg * 0.4)
          else
            current
          end
        end
      end

      smoothed
    end

    # Get neighboring elevation values
    def get_neighbors(elevation_map, x, y, width, height)
      neighbors = []
      [-1, 0, 1].each do |dx|
        [-1, 0, 1].each do |dy|
          next if dx == 0 && dy == 0
          nx, ny = x + dx, y + dy
          if nx >= 0 && nx < width && ny >= 0 && ny < height
            neighbors << elevation_map[ny][nx]
          end
        end
      end
      neighbors
    end
  end
end