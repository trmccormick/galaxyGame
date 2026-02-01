# app/services/terrain_analysis/hydrosphere_analyzer.rb

module TerrainAnalysis
  class HydrosphereAnalyzer
    # Water analysis for terrain grids
    # Identifies water distribution, aquifers, and collection opportunities

    WATER_TERRAIN_TYPES = [:ocean, :deep_sea].freeze
    ICE_TERRAIN_TYPES = [:arctic, :tundra].freeze
    AQUIFER_POTENTIAL_TERRAIN = [:desert, :rocky, :mountains].freeze

    def initialize(terrain_grid, planet_characteristics = {})
      @grid = terrain_grid
      @planet_type = determine_planet_type(planet_characteristics)
      @width = @grid.first&.size || 0
      @height = @grid.size
    end

    def analyze
      {
        surface_water_zones: identify_surface_water_zones,
        subsurface_water_potential: analyze_subsurface_water,
        ice_distribution: map_ice_distribution,
        water_collection_sites: identify_collection_sites,
        hydrosphere_summary: generate_summary
      }
    end

    private

    def determine_planet_type(characteristics)
      # Data-driven planet classification based on properties, not names

      # Check for explicit planet type override
      return characteristics[:type].to_sym if characteristics[:type] && characteristics[:type] != 'terrestrial_planet'

      # Analyze planet properties to determine hydrosphere characteristics
      planet_props = characteristics[:properties] || {}

      # Check atmosphere for water indicators
      atmosphere = characteristics[:atmosphere]
      has_water_vapor = atmosphere&.dig(:composition)&.key?(:water_vapor)

      # Check hydrosphere data
      hydrosphere = characteristics[:hydrosphere]
      has_surface_water = hydrosphere&.dig(:water_bodies)&.any?

      # Check surface temperature (very cold planets might have ice but no liquid water)
      surface_temp = characteristics[:surface_temperature]
      is_very_cold = surface_temp && surface_temp < 273  # Below freezing

      # Check body category/type
      body_category = characteristics[:body_category] || characteristics[:type]

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

    def identify_surface_water_zones
      zones = []
      visited = Array.new(@height) { Array.new(@width, false) }

      @grid.each_with_index do |row, y|
        row.each_with_index do |terrain, x|
          next if visited[y][x] || !WATER_TERRAIN_TYPES.include?(terrain)

          # Flood fill to find connected water zones
          zone = flood_fill_water(x, y, visited)
          zones << zone if zone[:size] > 0
        end
      end

      zones.sort_by { |zone| -zone[:size] } # Largest first
    end

    def flood_fill_water(start_x, start_y, visited)
      return { size: 0, coordinates: [] } unless valid_coordinates?(start_x, start_y)

      terrain = @grid[start_y][start_x]
      return { size: 0, coordinates: [] } unless WATER_TERRAIN_TYPES.include?(terrain)

      zone = { size: 0, coordinates: [], type: terrain }
      queue = [[start_x, start_y]]

      while !queue.empty?
        x, y = queue.shift
        next if visited[y][x] || !valid_coordinates?(x, y)

        current_terrain = @grid[y][x]
        next unless WATER_TERRAIN_TYPES.include?(current_terrain)

        visited[y][x] = true
        zone[:coordinates] << [x, y]
        zone[:size] += 1

        # Check adjacent cells (4-way connectivity)
        [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |dx, dy|
          nx, ny = x + dx, y + dy
          queue << [nx, ny] if valid_coordinates?(nx, ny) && !visited[ny][nx]
        end
      end

      zone
    end

    def analyze_subsurface_water
      potential_zones = []

      @grid.each_with_index do |row, y|
        row.each_with_index do |terrain, x|
          if AQUIFER_POTENTIAL_TERRAIN.include?(terrain)
            # Analyze surrounding terrain for aquifer potential
            aquifer_score = calculate_aquifer_potential(x, y)
            if aquifer_score > 0.3 # Threshold for viable aquifers
              potential_zones << {
                coordinates: [x, y],
                potential: aquifer_score,
                terrain: terrain,
                depth_estimate: estimate_aquifer_depth(terrain)
              }
            end
          end
        end
      end

      potential_zones.sort_by { |zone| -zone[:potential] }
    end

    def calculate_aquifer_potential(x, y)
      score = 0.0
      sample_radius = 2

      # Check surrounding area for water proximity
      (-sample_radius..sample_radius).each do |dy|
        (-sample_radius..sample_radius).each do |dx|
          nx, ny = x + dx, y + dy
          next unless valid_coordinates?(nx, ny)

          distance = Math.sqrt(dx**2 + dy**2)
          next if distance > sample_radius

          nearby_terrain = @grid[ny][nx]
          if WATER_TERRAIN_TYPES.include?(nearby_terrain)
            # Closer water = higher aquifer potential
            score += 1.0 / (distance + 1)
          elsif ICE_TERRAIN_TYPES.include?(nearby_terrain)
            # Ice can indicate subsurface water
            score += 0.5 / (distance + 1)
          end
        end
      end

      # Normalize score
      [score / 10.0, 1.0].min
    end

    def estimate_aquifer_depth(terrain)
      case terrain
      when :desert then 50..200   # Shallow in arid regions
      when :rocky then 100..500   # Deeper in rocky terrain
      when :mountains then 200..1000 # Deepest in mountains
      else 100..300
      end
    end

    def map_ice_distribution
      ice_zones = []

      @grid.each_with_index do |row, y|
        row.each_with_index do |terrain, x|
          if ICE_TERRAIN_TYPES.include?(terrain)
            ice_zones << {
              coordinates: [x, y],
              type: terrain,
              stability: calculate_ice_stability(x, y)
            }
          end
        end
      end

      ice_zones
    end

    def calculate_ice_stability(x, y)
      # Simple stability calculation based on surrounding terrain
      stability = 1.0

      # Check for nearby heat sources (volcanic terrain would reduce stability)
      (-1..1).each do |dy|
        (-1..1).each do |dx|
          nx, ny = x + dx, y + dy
          next unless valid_coordinates?(nx, ny)

          nearby_terrain = @grid[ny][nx]
          if [:mountains, :rocky].include?(nearby_terrain)
            stability -= 0.1 # Slightly less stable near geological features
          end
        end
      end

      [stability, 0.0].max
    end

    def identify_collection_sites
      sites = []

      case @planet_type
      when :arid
        # For arid planets (Mars-like): Focus on ice and potential aquifers
        # Ice mining sites
        ice_zones = map_ice_distribution
        ice_zones.each do |zone|
          if zone[:stability] > 0.7
            sites << {
              coordinates: zone[:coordinates],
              type: :ice_mining,
              resource: :water,
              yield_potential: :high,
              accessibility: :surface
            }
          end
        end

        # Aquifer drilling sites
        subsurface_zones = analyze_subsurface_water
        subsurface_zones.each do |zone|
          if zone[:potential] > 0.5
            sites << {
              coordinates: zone[:coordinates],
              type: :aquifer_drilling,
              resource: :water,
              yield_potential: :medium,
              accessibility: :subsurface,
              depth: zone[:depth_estimate]
            }
          end
        end

      when :oceanic, :temperate
        # For water-rich planets: Surface water collection
        surface_zones = identify_surface_water_zones
        surface_zones.each do |zone|
          if zone[:size] > 10 # Minimum viable size
            sites << {
              coordinates: zone[:coordinates].first, # Use first coordinate as representative
              type: :surface_collection,
              resource: :water,
              yield_potential: :very_high,
              accessibility: :surface,
              zone_size: zone[:size]
            }
          end
        end

      when :ice_world
        # For ice worlds: Focus on stable ice deposits
        ice_zones = map_ice_distribution
        ice_zones.each do |zone|
          sites << {
            coordinates: zone[:coordinates],
            type: :ice_harvesting,
            resource: :water,
            yield_potential: zone[:stability] > 0.8 ? :high : :medium,
            accessibility: :surface
          }
        end

      else
        # Default: Look for any available water sources
        # Surface water first
        surface_zones = identify_surface_water_zones
        surface_zones.each do |zone|
          if zone[:size] > 5
            sites << {
              coordinates: zone[:coordinates].first,
              type: :surface_collection,
              resource: :water,
              yield_potential: :high,
              accessibility: :surface,
              zone_size: zone[:size]
            }
          end
        end

        # Then ice if no surface water
        if sites.empty?
          ice_zones = map_ice_distribution
          ice_zones.first(5).each do |zone| # Limit to top 5
            sites << {
              coordinates: zone[:coordinates],
              type: :ice_mining,
              resource: :water,
              yield_potential: :medium,
              accessibility: :surface
            }
          end
        end
      end

      sites
    end

    def generate_summary
      surface_water = identify_surface_water_zones
      subsurface_water = analyze_subsurface_water
      ice_zones = map_ice_distribution
      collection_sites = identify_collection_sites

      {
        total_surface_water_coverage: surface_water.sum { |z| z[:size] },
        subsurface_water_sites: subsurface_water.size,
        ice_zones_count: ice_zones.size,
        viable_collection_sites: collection_sites.size,
        planet_type: @planet_type,
        water_availability: calculate_water_availability_score(collection_sites)
      }
    end

    def calculate_water_availability_score(collection_sites)
      return :none if collection_sites.empty?

      high_yield_sites = collection_sites.count { |s| s[:yield_potential] == :high || s[:yield_potential] == :very_high }
      total_sites = collection_sites.size

      ratio = high_yield_sites.to_f / total_sites

      if ratio > 0.7 then :abundant
      elsif ratio > 0.4 then :moderate
      elsif ratio > 0.1 then :limited
      else :scarce
      end
    end

    def valid_coordinates?(x, y)
      x >= 0 && x < @width && y >= 0 && y < @height
    end
  end
end