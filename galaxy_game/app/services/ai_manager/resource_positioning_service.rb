# app/services/ai_manager/resource_positioning_service.rb
# AI-powered resource placement using Civ4-style terrain analysis
# Learns from imported maps to place resources realistically

module AIManager
  class ResourcePositioningService
    def initialize
      @resource_rules = load_resource_placement_rules
    end

    # Place resources on a generated map using learned patterns
    def place_resources_on_map(map_data, planet_name: nil, options: {})
      Rails.logger.info "[ResourcePositioningService] Placing resources on #{planet_name} map"

      elevation_grid = map_data[:elevation] || map_data[:elevation_data]
      terrain_grid = map_data[:terrain] || map_data[:terrain_grid] || map_data[:biomes]

      return map_data unless elevation_grid && terrain_grid

      height = elevation_grid.size
      width = elevation_grid.first&.size || 0

      # Initialize resource grid
      resource_grid = Array.new(height) { Array.new(width, nil) }

      # Apply resource placement rules
      @resource_rules.each do |resource_type, rules|
        place_resource_type(resource_type, rules, elevation_grid, terrain_grid, resource_grid, planet_name)
      end

      # Add strategic markers for settlements, lava tubes, etc.
      strategic_markers = identify_strategic_locations(elevation_grid, terrain_grid, resource_grid, planet_name)

      # Return enhanced map data
      map_data.merge(
        resource_grid: resource_grid,
        strategic_markers: strategic_markers,
        resource_counts: count_resources(resource_grid)
      )
    end

    private

    # Load resource placement rules learned from Civ4/FreeCiv maps
    def load_resource_placement_rules
      {
        # Strategic resources (learned from Civ4 placement)
        'ore_deposits' => {
          terrain_types: ['hills', 'mountains'],
          elevation_range: [0.6, 0.95],
          rarity: 0.1,  # 10% of suitable tiles
          clustering: 0.3  # Some clustering
        },
        'rare_metals' => {
          terrain_types: ['mountains', 'peaks'],
          elevation_range: [0.8, 1.0],
          rarity: 0.05,
          clustering: 0.2
        },
        'volatiles' => {
          terrain_types: ['plains', 'grassland'],
          elevation_range: [0.3, 0.7],
          rarity: 0.15,
          clustering: 0.4
        },
        'minerals' => {
          terrain_types: ['hills', 'grassland', 'plains'],
          elevation_range: [0.4, 0.8],
          rarity: 0.2,
          clustering: 0.5
        },
        # Energy resources
        'geothermal' => {
          terrain_types: ['mountains', 'volcanic'],
          elevation_range: [0.7, 1.0],
          rarity: 0.08,
          clustering: 0.1
        },
        'solar_farms' => {
          terrain_types: ['desert', 'plains'],
          elevation_range: [0.3, 0.7],
          rarity: 0.12,
          clustering: 0.6
        }
      }
    end

    # Place a specific resource type based on rules
    def place_resource_type(resource_type, rules, elevation_grid, terrain_grid, resource_grid, planet_name)
      height = elevation_grid.size
      width = elevation_grid.first&.size || 0

      # Find suitable locations
      suitable_tiles = []

      height.times do |y|
        width.times do |x|
          terrain = terrain_grid[y][x]
          elevation = elevation_grid[y][x]

          if suitable_for_resource?(terrain, elevation, rules) && resource_grid[y][x].nil?
            suitable_tiles << [x, y]
          end
        end
      end

      # Place resources based on rarity
      target_count = (suitable_tiles.size * rules[:rarity]).to_i
      selected_tiles = select_resource_locations(suitable_tiles, target_count, rules[:clustering])

      # Mark on resource grid
      selected_tiles.each do |x, y|
        resource_grid[y][x] = resource_type
      end

      Rails.logger.debug "[ResourcePositioningService] Placed #{selected_tiles.size} #{resource_type} on #{planet_name}"
    end

    # Check if a tile is suitable for a resource
    def suitable_for_resource?(terrain, elevation, rules)
      return false unless terrain && elevation

      terrain_suitable = rules[:terrain_types].include?(terrain) ||
                        rules[:terrain_types].include?('any') ||
                        terrain_match_fuzzy(terrain, rules[:terrain_types])

      elevation_suitable = elevation >= rules[:elevation_range][0] &&
                          elevation <= rules[:elevation_range][1]

      terrain_suitable && elevation_suitable
    end

    # Fuzzy terrain matching (e.g., 'grassland' matches 'grass')
    def terrain_match_fuzzy(terrain, allowed_types)
      allowed_types.any? do |allowed|
        terrain.downcase.include?(allowed.downcase) ||
        allowed.downcase.include?(terrain.downcase)
      end
    end

    # Select resource locations with clustering
    def select_resource_locations(suitable_tiles, target_count, clustering_factor)
      return [] if suitable_tiles.empty? || target_count <= 0

      selected = []

      # Always place at least one if possible
      if suitable_tiles.size > 0
        selected << suitable_tiles.sample
        target_count -= 1
      end

      # Place remaining resources with clustering
      target_count.times do
        if rand < clustering_factor && !selected.empty?
          # Cluster near existing resources
          selected << select_nearby_tile(suitable_tiles, selected)
        else
          # Place randomly
          available = suitable_tiles - selected
          selected << available.sample if available.any?
        end
      end

      selected.compact.uniq
    end

    # Select a tile near existing resources
    def select_nearby_tile(all_tiles, existing_tiles)
      candidates = []

      existing_tiles.each do |ex, ey|
        # Check adjacent tiles
        (-1..1).each do |dx|
          (-1..1).each do |dy|
            next if dx == 0 && dy == 0  # Skip self

            nx, ny = ex + dx, ey + dy
            if all_tiles.include?([nx, ny])
              candidates << [nx, ny]
            end
          end
        end
      end

      candidates.sample || all_tiles.sample
    end

    # Identify strategic locations for settlements, lava tubes, etc.
    def identify_strategic_locations(elevation_grid, terrain_grid, resource_grid, planet_name)
      markers = []
      height = elevation_grid.size
      width = elevation_grid.first&.size || 0

      height.times do |y|
        width.times do |x|
          terrain = terrain_grid[y][x]
          elevation = elevation_grid[y][x]
          resource = resource_grid[y][x]

          marker = identify_marker_type(x, y, terrain, elevation, resource, planet_name)
          markers << marker if marker
        end
      end

      markers
    end

    # Identify what type of strategic marker this location should have
    def identify_marker_type(x, y, terrain, elevation, resource, planet_name)
      case planet_name&.downcase
      when 'mars'
        identify_mars_marker(x, y, terrain, elevation, resource)
      when 'moon', 'luna'
        identify_lunar_marker(x, y, terrain, elevation, resource)
      when 'earth', 'terra'
        identify_earth_marker(x, y, terrain, elevation, resource)
      else
        identify_generic_marker(x, y, terrain, elevation, resource)
      end
    end

    def identify_mars_marker(x, y, terrain, elevation, resource)
      # Mars-specific strategic locations
      if elevation > 0.8 && ['mountains', 'peaks'].include?(terrain)
        return { type: 'volcanic_cone', x: x, y: y, priority: 'high' }
      elsif elevation < 0.3 && terrain == 'lowlands'
        return { type: 'potential_lava_tube', x: x, y: y, priority: 'medium' }
      elsif resource == 'rare_metals'
        return { type: 'mining_outpost', x: x, y: y, priority: 'high' }
      end
      nil
    end

    def identify_lunar_marker(x, y, terrain, elevation, resource)
      # Lunar strategic locations
      if elevation < 0.4 && ['maria', 'lowlands'].include?(terrain)
        return { type: 'lunar_mare_settlement', x: x, y: y, priority: 'high' }
      elsif elevation > 0.8
        return { type: 'highland_observatory', x: x, y: y, priority: 'medium' }
      end
      nil
    end

    def identify_earth_marker(x, y, terrain, elevation, resource)
      # Earth strategic locations (learned from Civ4)
      if elevation > 0.7 && ['mountains', 'peaks'].include?(terrain)
        return { type: 'mountain_pass', x: x, y: y, priority: 'medium' }
      elsif elevation < 0.4 && terrain == 'ocean'
        return { type: 'coastal_city', x: x, y: y, priority: 'high' }
      elsif ['plains', 'grassland'].include?(terrain) && elevation.between?(0.4, 0.7)
        return { type: 'agricultural_heartland', x: x, y: y, priority: 'high' }
      end
      nil
    end

    def identify_generic_marker(x, y, terrain, elevation, resource)
      # Generic strategic locations
      if resource
        return { type: 'resource_site', x: x, y: y, priority: 'medium' }
      elsif elevation.between?(0.4, 0.7) && ['plains', 'grassland'].include?(terrain)
        return { type: 'settlement_site', x: x, y: y, priority: 'low' }
      end
      nil
    end

    # Count resources for metadata
    def count_resources(resource_grid)
      counts = Hash.new(0)
      resource_grid.flatten.compact.each { |resource| counts[resource] += 1 }
      counts
    end
  end
end