require 'json'
require 'set'

class MountainPatternExtractor
  def self.extract_patterns(elevation_data, threshold: 0.7)
    # Find all high-elevation tiles (peaks)
    peaks = find_peaks(elevation_data, threshold)

    return {} if peaks.empty?

    # Use simple flood-fill to find connected regions (chains)
    chains = flood_fill_clusters(peaks, elevation_data)

    return {} if chains.empty?

    {
      mountain_chains: {
        average_chain_length: chains.map(&:size).sum / chains.size.to_f,
        number_of_chains: chains.size,

        # Orientation: mostly N-S, E-W, or diagonal?
        dominant_orientation: calculate_chain_orientation(chains),

        # How clustered are mountains?
        clustering_factor: calculate_clustering(chains),

        # Size distribution
        chain_size_distribution: calculate_size_distribution(chains)
      },
      metadata: {
        extracted_at: Time.now.iso8601,
        elevation_threshold: threshold,
        total_peaks: peaks.size,
        chains_found: chains.size
      }
    }
  end

  private

  def self.find_peaks(elevation_data, threshold)
    peaks = []
    elevation = elevation_data[:elevation]
    height = elevation.size
    width = elevation.first.size

    height.times do |y|
      width.times do |x|
        value = elevation[y][x]
        next if value == elevation_data[:metadata][:nodata_value]
        next if value < threshold

        # Check if this is a local maximum
        is_peak = true
        [-1, 0, 1].each do |dy|
          [-1, 0, 1].each do |dx|
            next if dx == 0 && dy == 0

            ny, nx = y + dy, x + dx
            next if ny < 0 || ny >= height || nx < 0 || nx >= width

            neighbor = elevation[ny][nx]
            next if neighbor == elevation_data[:metadata][:nodata_value]

            if neighbor > value
              is_peak = false
              break
            end
          end
          break unless is_peak
        end

        peaks << [x, y] if is_peak
      end
    end

    peaks
  end

  def self.flood_fill_clusters(peaks, elevation_data)
    visited = Set.new
    clusters = []
    elevation = elevation_data[:elevation]
    height = elevation.size
    width = elevation.first.size

    peaks.each do |peak|
      next if visited.include?(peak)

      cluster = []
      queue = [peak]

      while queue.any?
        current = queue.shift
        next if visited.include?(current)

        visited.add(current)
        cluster << current

        # Add adjacent high-elevation neighbors
        neighbors = get_adjacent_peaks(current, peaks, visited, elevation_data)
        queue.concat(neighbors)
      end

      clusters << cluster if cluster.any?
    end

    clusters
  end

  def self.get_adjacent_peaks(current, all_peaks, visited, elevation_data)
    x, y = current
    elevation = elevation_data[:elevation]
    height = elevation.size
    width = elevation.first.size
    threshold = 0.6  # Slightly lower threshold for connectivity

    adjacent = []

    [-1, 0, 1].each do |dy|
      [-1, 0, 1].each do |dx|
        next if dx == 0 && dy == 0

        ny, nx = y + dy, x + dx
        next if ny < 0 || ny >= height || nx < 0 || nx >= width

        neighbor_pos = [nx, ny]
        next if visited.include?(neighbor_pos)

        neighbor_value = elevation[ny][nx]
        next if neighbor_value == elevation_data[:metadata][:nodata_value]
        next if neighbor_value < threshold

        adjacent << neighbor_pos
      end
    end

    adjacent
  end

  def self.calculate_chain_orientation(chains)
    return 'mixed' if chains.empty?

    orientations = chains.map do |chain|
      calculate_orientation(chain)
    end

    # Find most common orientation
    orientation_counts = orientations.group_by(&:itself).transform_values(&:size)
    dominant = orientation_counts.max_by { |_, count| count }&.first

    case dominant
    when 0 then 'north-south'
    when 1 then 'northeast-southwest'
    when 2 then 'east-west'
    when 3 then 'southeast-northwest'
    else 'mixed'
    end
  end

  def self.calculate_orientation(chain)
    return 0 if chain.size < 2

    # Calculate the main axis of the chain
    min_x = chain.map(&:first).min
    max_x = chain.map(&:first).max
    min_y = chain.map(&:last).min
    max_y = chain.map(&:last).max

    width = max_x - min_x
    height = max_y - min_y

    if width > height
      2  # east-west
    else
      0  # north-south
    end
  end

  def self.calculate_clustering(chains)
    return 0.0 if chains.size < 2

    # Calculate average distance between chain centers
    centers = chains.map { |chain| calculate_centroid(chain) }

    total_distance = 0.0
    count = 0

    centers.combination(2) do |c1, c2|
      distance = Math.sqrt((c2[0] - c1[0])**2 + (c2[1] - c1[1])**2)
      total_distance += distance
      count += 1
    end

    average_distance = total_distance / count

    # Lower average distance = more clustered
    # Normalize to 0-1 scale (arbitrary scaling)
    [1.0 - (average_distance / 100.0), 0.0].max
  end

  def self.calculate_centroid(chain)
    sum_x = chain.map(&:first).sum
    sum_y = chain.map(&:last).sum

    [sum_x / chain.size.to_f, sum_y / chain.size.to_f]
  end

  def self.calculate_size_distribution(chains)
    sizes = chains.map(&:size).sort

    {
      min: sizes.min,
      max: sizes.max,
      median: sizes[sizes.size / 2],
      quartiles: {
        q1: sizes[sizes.size / 4],
        q3: sizes[3 * sizes.size / 4]
      }
    }
  end
end

# Usage example:
# mountain_patterns = MountainPatternExtractor.extract_patterns(elevation_data, threshold: 0.7)
# File.write('data/ai_patterns/geotiff_mountain_patterns.json', JSON.pretty_generate(mountain_patterns))