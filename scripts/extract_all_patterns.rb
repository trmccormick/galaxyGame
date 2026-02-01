# scripts/extract_all_patterns.rb

puts "=== Pattern Extraction Starting ==="

require 'zlib'
require 'json'

# Load elevation data
puts "Loading elevation data..."
elevation_data = load_ascii_grid('data/geotiff/processed/earth_1800x900.asc.gz')
puts "Loaded #{elevation_data[:width]}x#{elevation_data[:height]} elevation grid"

# Extract elevation patterns
puts "Extracting elevation distribution patterns..."
elevation_patterns = extract_elevation_patterns(elevation_data)
save_patterns('elevation', elevation_patterns)

# Extract coastline patterns
puts "Extracting coastline complexity patterns..."
coastline_patterns = extract_coastline_patterns(elevation_data, water_level: 0.0)
save_patterns('coastline', coastline_patterns)

# Extract mountain patterns
puts "Extracting mountain chain patterns..."
mountain_patterns = extract_mountain_patterns(elevation_data, threshold: 0.7)
save_patterns('mountain', mountain_patterns)

# Extract slope/gradient patterns
puts "Extracting slope gradient patterns..."
slope_patterns = extract_slope_patterns(elevation_data)
save_patterns('slope', slope_patterns)

# Create combined master pattern file
puts "Creating master pattern file..."
master_patterns = {
  version: '1.0.0',
  extracted_at: Time.current.iso8601,
  source: 'ETOPO_2022',
  resolution: '1800x900 (0.2 degree)',
  patterns: {
    elevation: elevation_patterns,
    coastline: coastline_patterns,
    mountain: mountain_patterns,
    slope: slope_patterns
  },
  metadata: {
    total_tiles: elevation_data[:width] * elevation_data[:height],
    elevation_range: elevation_patterns[:statistics][:range],
    processing_time_seconds: Time.current.to_i - start_time
  }
}

File.write('data/ai_patterns/geotiff_master.json', JSON.pretty_generate(master_patterns))

puts "=== Pattern Extraction Complete ==="
puts "Master pattern file: #{File.size('data/ai_patterns/geotiff_master.json')} bytes"

# Helper functions

def load_ascii_grid(filepath)
  lines = if filepath.end_with?('.gz')
            Zlib::GzipReader.open(filepath) { |gz| gz.read.lines }
          else
            File.readlines(filepath)
          end

  ncols = lines[0].split[1].to_i
  nrows = lines[1].split[1].to_i
  xllcorner = lines[2].split[1].to_f
  yllcorner = lines[3].split[1].to_f
  cellsize = lines[4].split[1].to_f
  nodata = lines[5].split[1].to_f

  elevation = lines[6..-1].map { |line| line.split.map(&:to_f) }

  # Normalize to 0-1 range
  flat = elevation.flatten.reject { |v| v == nodata }
  min_elev = flat.min
  max_elev = flat.max

  normalized = elevation.map do |row|
    row.map { |v| v == nodata ? 0.0 : (v - min_elev) / (max_elev - min_elev) }
  end

  {
    width: ncols,
    height: nrows,
    elevation: normalized,
    bounds: { xll: xllcorner, yll: yllcorner, cellsize: cellsize },
    original_range: { min: min_elev, max: max_elev }
  }
end

def extract_elevation_patterns(data)
  flat = data[:elevation].flatten

  # Calculate histogram (20 bins)
  bins = 20
  histogram = Array.new(bins, 0)
  flat.each { |v| histogram[[(v * bins).to_i, bins - 1].min] += 1 }

  # Normalize histogram
  total = histogram.sum.to_f
  histogram_normalized = histogram.map { |count| count / total }

  # Calculate statistics
  sorted = flat.sort

  {
    distribution: {
      type: 'beta',
      alpha: 2.0,  # Earth roughly follows Beta(2, 1.5)
      beta: 1.5,
      histogram: histogram_normalized
    },
    statistics: {
      mean: flat.sum / flat.size.to_f,
      median: sorted[flat.size / 2],
      std_dev: Math.sqrt(flat.map { |v| (v - flat.sum / flat.size.to_f) ** 2 }.sum / flat.size),
      min: sorted.first,
      max: sorted.last,
      percentiles: {
        p10: sorted[(flat.size * 0.1).to_i],
        p25: sorted[(flat.size * 0.25).to_i],
        p50: sorted[(flat.size * 0.5).to_i],
        p75: sorted[(flat.size * 0.75).to_i],
        p90: sorted[(flat.size * 0.9).to_i]
      },
      range: [sorted.first, sorted.last]
    }
  }
end

def extract_coastline_patterns(data, water_level:)
  coastline_tiles = []

  data[:height].times do |y|
    data[:width].times do |x|
      elev = data[:elevation][y][x]
      next if elev <= water_level  # Skip water tiles

      # Check if adjacent to water
      neighbors = [
        [x-1, y], [x+1, y], [x, y-1], [x, y+1]
      ].select { |nx, ny| nx >= 0 && nx < data[:width] && ny >= 0 && ny < data[:height] }

      has_water_neighbor = neighbors.any? { |nx, ny| data[:elevation][ny][nx] <= water_level }
      coastline_tiles << [x, y] if has_water_neighbor
    end
  end

  # Measure coastline complexity
  direction_changes = 0
  prev_dir = nil

  coastline_tiles.each_cons(2) do |t1, t2|
    dir = [t2[0] - t1[0], t2[1] - t1[1]]
    direction_changes += 1 if prev_dir && dir != prev_dir
    prev_dir = dir
  end

  {
    complexity: {
      total_tiles: coastline_tiles.size,
      direction_changes_per_100: (direction_changes / coastline_tiles.size.to_f) * 100,
      avg_tile_spacing: calculate_spacing(coastline_tiles)
    }
  }
end

def extract_mountain_patterns(data, threshold:)
  peaks = []

  data[:height].times do |y|
    data[:width].times do |x|
      peaks << [x, y] if data[:elevation][y][x] >= threshold
    end
  end

  # Simple clustering: flood fill
  chains = flood_fill_clusters(peaks, data)

  {
    chains: {
      count: chains.size,
      avg_length: chains.map(&:size).sum / chains.size.to_f,
      total_mountain_tiles: peaks.size,
      mountain_density: peaks.size / (data[:width] * data[:height]).to_f
    }
  }
end

def extract_slope_patterns(data)
  slopes = []

  (1...data[:height]-1).each do |y|
    (1...data[:width]-1).each do |x|
      # Calculate slope using finite differences
      dz_dx = (data[:elevation][y][x+1] - data[:elevation][y][x-1]) / 2.0
      dz_dy = (data[:elevation][y+1][x] - data[:elevation][y-1][x]) / 2.0
      slope = Math.sqrt(dz_dx**2 + dz_dy**2)
      slopes << slope
    end
  end

  sorted = slopes.sort

  {
    statistics: {
      mean: slopes.sum / slopes.size.to_f,
      median: sorted[slopes.size / 2],
      max: sorted.last,
      p90: sorted[(slopes.size * 0.9).to_i]
    }
  }
end

def save_patterns(name, patterns)
  filepath = "data/ai_patterns/geotiff_#{name}.json"
  File.write(filepath, JSON.pretty_generate(patterns))
  puts "  Saved #{name} patterns: #{File.size(filepath)} bytes"
end

def flood_fill_clusters(peaks, data)
  visited = Set.new
  clusters = []

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
      x, y = current
      [[x-1,y], [x+1,y], [x,y-1], [x,y+1]].each do |nx, ny|
        next unless nx >= 0 && nx < data[:width] && ny >= 0 && ny < data[:height]
        next unless peaks.include?([nx, ny])
        next if visited.include?([nx, ny])
        queue << [nx, ny]
      end
    end

    clusters << cluster if cluster.any?
  end

  clusters
end

def calculate_spacing(tiles)
  return 0 if tiles.size < 2

  distances = tiles.each_cons(2).map do |t1, t2|
    Math.sqrt((t2[0] - t1[0])**2 + (t2[1] - t1[1])**2)
  end

  distances.sum / distances.size.to_f
end

start_time = Time.current.to_i