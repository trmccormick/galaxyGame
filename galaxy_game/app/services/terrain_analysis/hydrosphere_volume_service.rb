# app/services/terrain_analysis/hydrosphere_volume_service.rb

module TerrainAnalysis
  class HydrosphereVolumeService
    # Dynamic water volume management for terraforming
    # Calculates sea levels based on water volume and elevation maps
    # Enables realistic Mars terraforming with rising water levels from KBO impacts

    attr_reader :terrain_map

    def initialize(terrain_map)
      @terrain_map = terrain_map
    end

    # Calculate sea level based on water volume and elevation distribution
    # Returns the elevation threshold where water would reach
    def calculate_sea_level(water_volume = nil)
      water_volume ||= @terrain_map['water_volume'] || 0.0
      elevations = @terrain_map['elevation']

      return 0.0 unless elevations && elevations.any?

      # Flatten and sort elevations to find water distribution
      sorted_elevations = elevations.flatten.compact.sort
      total_tiles = sorted_elevations.length

      # Calculate how many tiles would be underwater at this volume
      water_tiles = (water_volume * total_tiles).round

      # Return the elevation at the water boundary
      # If water_tiles is 0, return minimum elevation
      # If water_tiles >= total_tiles, return maximum elevation
      if water_tiles <= 0
        sorted_elevations.first || 0.0
      elsif water_tiles >= total_tiles
        sorted_elevations.last || 0.0
      else
        sorted_elevations[water_tiles - 1] || 0.0
      end
    end

    # Update water bodies based on current water volume and elevation
    # Returns updated terrain grid with dynamic water distribution
    def update_water_bodies
      elevations = @terrain_map['elevation']
      water_volume = @terrain_map['water_volume'] || 0.0
      sea_level = calculate_sea_level(water_volume)

      return @terrain_map unless elevations

      width = @terrain_map['width'] || elevations.first&.size || 0
      height = @terrain_map['height'] || elevations.size

      # Create new grid with dynamic water distribution
      updated_grid = Array.new(height) { Array.new(width) }

      height.times do |y|
        width.times do |x|
          elevation = elevations[y][x]
          current_terrain = @terrain_map.dig('grid', y, x)

          if elevation && elevation < sea_level
            # Underwater - determine water depth and type
            depth = sea_level - elevation
            updated_grid[y][x] = determine_water_type(depth, current_terrain)
          else
            # Above water - keep original terrain or modify for coastal effects
            updated_grid[y][x] = determine_land_type(elevation, sea_level, current_terrain)
          end
        end
      end

      # Return updated terrain map
      @terrain_map.merge(
        'grid' => updated_grid,
        'sea_level' => sea_level,
        'water_coverage' => calculate_water_coverage(updated_grid)
      )
    end

    # Add water volume (e.g., from KBO impact) and recalculate distribution
    def add_water_volume(volume_increase)
      current_volume = @terrain_map['water_volume'] || 0.0
      new_volume = [1.0, current_volume + volume_increase].min # Cap at 100%

      @terrain_map['water_volume'] = new_volume
      update_water_bodies
    end

    # Remove water volume and recalculate distribution
    def remove_water_volume(volume_decrease)
      current_volume = @terrain_map['water_volume'] || 0.0
      new_volume = [0.0, current_volume - volume_decrease].max # Floor at 0%

      @terrain_map['water_volume'] = new_volume
      update_water_bodies
    end

    private

    # Determine water type based on depth
    def determine_water_type(depth, original_terrain)
      case depth
      when 0.0..0.1
        :coast      # Very shallow coastal water
      when 0.1..0.3
        :ocean      # Shallow ocean
      else
        :deep_sea   # Deep ocean
      end
    end

    # Determine land type with coastal modifications
    def determine_land_type(elevation, sea_level, original_terrain)
      # If very close to sea level, might be coastal
      if elevation && elevation < sea_level + 0.05
        case original_terrain
        when :desert, :rocky
          :coast  # Coastal terrain
        else
          original_terrain  # Keep original
        end
      else
        original_terrain  # Well above water, keep original
      end
    end

    # Calculate percentage of map covered by water
    def calculate_water_coverage(grid)
      return 0.0 unless grid && grid.any?

      total_tiles = grid.flatten.compact.size
      water_tiles = grid.flatten.compact.count { |terrain| [:ocean, :deep_sea, :coast].include?(terrain) }

      total_tiles > 0 ? (water_tiles.to_f / total_tiles) : 0.0
    end
  end
end