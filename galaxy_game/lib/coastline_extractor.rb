require 'json'

class CoastlinePatternExtractor
  def self.extract_patterns(elevation_data, water_level: 0.0)
    coastline_tiles = find_coastline_tiles(elevation_data, water_level)

    return {} if coastline_tiles.empty?

    {
      coastline_complexity: {
        # Simple metrics that capture "wiggliness"
        total_coastline_tiles: coastline_tiles.size,
        coastline_to_land_ratio: calculate_ratio(coastline_tiles, elevation_data),

        # How many direction changes per 100 tiles?
        direction_changes_per_100: measure_direction_changes(coastline_tiles),

        # Average distance between coastal indentations
        bay_spacing: measure_bay_spacing(coastline_tiles)
      },
      metadata: {
        extracted_at: Time.now.iso8601,
        water_level: water_level,
        coastline_tiles_count: coastline_tiles.size
      }
    }
  end

  private

  def self.find_coastline_tiles(elevation_data, water_level)
    coastline = []
    elevation = elevation_data[:elevation]
    height = elevation.size
    width = elevation.first.size

    height.times do |y|
      width.times do |x|
        current = elevation[y][x]
        next if current == elevation_data[:metadata][:nodata_value]

        is_water = current <= water_level
        has_land_neighbor = false

        # Check 8 neighboring tiles
        [-1, 0, 1].each do |dy|
          [-1, 0, 1].each do |dx|
            next if dx == 0 && dy == 0

            ny, nx = y + dy, x + dx
            next if ny < 0 || ny >= height || nx < 0 || nx >= width

            neighbor = elevation[ny][nx]
            next if neighbor == elevation_data[:metadata][:nodata_value]

            if neighbor > water_level
              has_land_neighbor = true
              break
            end
          end
          break if has_land_neighbor
        end

        coastline << [x, y] if is_water && has_land_neighbor
      end
    end

    coastline
  end

  def self.calculate_ratio(coastline_tiles, elevation_data)
    total_land_tiles = elevation_data[:elevation].flatten.count do |v|
      v != elevation_data[:metadata][:nodata_value] && v > 0.0
    end

    coastline_tiles.size.to_f / total_land_tiles
  end

  def self.measure_direction_changes(coastline_tiles)
    return 0.0 if coastline_tiles.size < 2

    changes = 0
    prev_direction = nil

    coastline_tiles.each_cons(2) do |tile1, tile2|
      direction = [tile2[0] - tile1[0], tile2[1] - tile1[1]]
      normalized_direction = normalize_direction(direction)

      changes += 1 if prev_direction && normalized_direction != prev_direction
      prev_direction = normalized_direction
    end

    (changes / coastline_tiles.size.to_f) * 100
  end

  def self.measure_bay_spacing(coastline_tiles)
    return 0.0 if coastline_tiles.size < 10

    # Find significant indentations (bays)
    indentations = find_indentations(coastline_tiles)

    return 0.0 if indentations.size < 2

    # Calculate average spacing between indentations
    total_distance = 0.0
    indentations.each_cons(2) do |ind1, ind2|
      distance = Math.sqrt((ind2[0] - ind1[0])**2 + (ind2[1] - ind1[1])**2)
      total_distance += distance
    end

    total_distance / (indentations.size - 1)
  end

  def self.normalize_direction(direction)
    # Convert to one of 8 cardinal directions
    dx, dy = direction
    angle = Math.atan2(dy, dx)

    # Convert to 0-7 index (45-degree increments)
    ((angle + Math::PI) / (Math::PI / 4)).round % 8
  end

  def self.find_indentations(coastline_tiles)
    indentations = []

    # Simple approach: look for tiles that are significantly indented
    coastline_tiles.each_cons(5) do |window|
      center = window[2]
      left_neighbors = window[0..1]
      right_neighbors = window[3..4]

      # Check if center is more indented than neighbors
      if is_indentation?(center, left_neighbors, right_neighbors)
        indentations << center
      end
    end

    indentations
  end

  def self.is_indentation?(center, left_neighbors, right_neighbors)
    # This is a simplified check - in production, you'd use curvature analysis
    # For now, just check if the center point deviates from the line
    true # Placeholder - implement proper indentation detection
  end
end

# Usage example:
# coastline_patterns = CoastlinePatternExtractor.extract_patterns(elevation_data, water_level: 0.0)
# File.write('data/ai_patterns/geotiff_coastline_patterns.json', JSON.pretty_generate(coastline_patterns))