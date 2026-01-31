# scripts/lib/pattern_extractor.rb

require 'json'
require 'zlib'

class PatternExtractor
  def self.extract_body_patterns(body_type, data_file)
    puts "=== Extracting #{body_type.upcase} Patterns ==="
    
    # Load elevation data
    elevation_data = load_elevation_data(data_file)
    
    # Extract patterns based on body type
    patterns = case body_type
               when 'earth'
                 extract_earth_patterns(elevation_data)
               when 'luna'
                 extract_lunar_patterns(elevation_data)
               when 'mars'
                 extract_mars_patterns(elevation_data)
               else
                 raise "Unknown body type: #{body_type}"
               end
    
    # Add metadata
    patterns['metadata'] = {
      body_type: body_type,
      extracted_at: Time.current.iso8601,
      data_source: data_file,
      version: '1.0.0'
    }
    
    # Save to file
    output_file = GalaxyGame::Paths::AI_MANAGER_PATH.join("geotiff_patterns_#{body_type}.json")
    File.write(output_file, JSON.pretty_generate(patterns))
    
    puts "✓ Patterns saved to #{output_file}"
    puts "  File size: #{File.size(output_file) / 1024} KB"
    
    patterns
  end
  
  private
  
  def self.load_elevation_data(filepath)
    lines = if filepath.end_with?('.gz')
              Zlib::GzipReader.open(filepath) { |gz| gz.read.lines }
            else
              File.readlines(filepath)
            end
    
    ncols = lines[0].split[1].to_i
    nrows = lines[1].split[1].to_i
    nodata = lines[5].split[1].to_f
    
    elevation = lines[6..-1].map { |line| line.split.map(&:to_f) }
    
    # Normalize to 0-1
    flat = elevation.flatten.reject { |v| v == nodata }
    min_elev = flat.min
    max_elev = flat.max
    
    normalized = elevation.map do |row|
      row.map { |v| v == nodata ? 0.0 : (v - min_elev) / (max_elev - min_elev) }
    end
    
    {
      width: ncols,
      height: nrows,
      data: normalized,
      original_range: { min: min_elev, max: max_elev }
    }
  end
  
  def self.extract_earth_patterns(data)
    {
      body_type: 'terrestrial_earth_like',
      characteristics: {
        erosion_level: 'high',
        atmosphere: 'thick',
        crater_density: 'very_low',
        water_coverage: 'high',
        features: ['rivers', 'coastlines', 'mountains', 'valleys', 'plains']
      },
      patterns: {
        elevation: extract_elevation_distribution(data),
        coastlines: extract_coastline_complexity(data),
        mountains: extract_mountain_chains(data),
        roughness: extract_terrain_roughness(data)
      }
    }
  end
  
  def self.extract_lunar_patterns(data)
    {
      body_type: 'airless_cratered',
      characteristics: {
        erosion_level: 'none',
        atmosphere: 'none',
        crater_density: 'very_high',
        water_coverage: 'none',
        features: ['craters', 'maria', 'highlands', 'rays', 'impact_basins']
      },
      patterns: {
        elevation: extract_elevation_distribution(data),
        craters: extract_crater_patterns(data),
        maria: extract_smooth_regions(data),
        highlands: extract_rough_regions(data),
        roughness: extract_terrain_roughness(data)
      }
    }
  end
  
  def self.extract_mars_patterns(data)
    {
      body_type: 'terrestrial_thin_atmosphere',
      characteristics: {
        erosion_level: 'moderate',
        atmosphere: 'thin',
        crater_density: 'moderate',
        water_coverage: 'very_low',
        features: ['ancient_rivers', 'volcanoes', 'craters', 'polar_caps', 'canyons']
      },
      patterns: {
        elevation: extract_elevation_distribution(data),
        craters: extract_crater_patterns(data),
        volcanoes: extract_volcanic_features(data),
        dichotomy: extract_hemispheric_asymmetry(data),
        roughness: extract_terrain_roughness(data)
      }
    }
  end
  
  # Pattern extraction helper methods
  
  def self.extract_elevation_distribution(data)
    flat = data[:data].flatten
    sorted = flat.sort
    
    # Calculate histogram
    bins = 20
    histogram = Array.new(bins, 0)
    flat.each { |v| histogram[[(v * bins).to_i, bins - 1].min] += 1 }
    histogram_normalized = histogram.map { |c| c / flat.size.to_f }
    
    {
      distribution: {
        type: 'empirical',
        histogram: histogram_normalized,
        bins: bins
      },
      statistics: {
        mean: flat.sum / flat.size.to_f,
        median: sorted[flat.size / 2],
        std_dev: Math.sqrt(flat.map { |v| (v - flat.sum / flat.size.to_f) ** 2 }.sum / flat.size),
        percentiles: {
          p10: sorted[(flat.size * 0.1).to_i],
          p25: sorted[(flat.size * 0.25).to_i],
          p50: sorted[(flat.size * 0.5).to_i],
          p75: sorted[(flat.size * 0.75).to_i],
          p90: sorted[(flat.size * 0.9).to_i]
        }
      }
    }
  end
  
  def self.extract_crater_patterns(data)
    # Detect crater-like features (local minima with raised rims)
    crater_count = 0
    crater_depths = []
    
    (5...data[:height]-5).each do |y|
      (5...data[:width]-5).each do |x|
        center = data[:data][y][x]
        
        # Check if local minimum
        neighbors = []
        (-2..2).each do |dy|
          (-2..2).each do |dx|
            next if dx == 0 && dy == 0
            neighbors << data[:data][y+dy][x+dx]
          end
        end
        
        if neighbors.all? { |n| n >= center }
          # Check for raised rim
          rim_elevations = []
          8.times do |i|
            angle = i * Math::PI / 4
            rx = x + (4 * Math.cos(angle)).round
            ry = y + (4 * Math.sin(angle)).round
            rim_elevations << data[:data][ry][rx] if ry.between?(0, data[:height]-1) && rx.between?(0, data[:width]-1)
          end
          
          if rim_elevations.any? { |r| r > center + 0.02 }
            crater_count += 1
            crater_depths << (rim_elevations.max - center)
          end
        end
      end
    end
    
    {
      crater_density: crater_count / (data[:width] * data[:height]).to_f,
      avg_depth: crater_depths.any? ? crater_depths.sum / crater_depths.size.to_f : 0.0,
      count: crater_count
    }
  end
  
  def self.extract_terrain_roughness(data)
    # Calculate local elevation variance
    roughness_values = []
    
    (2...data[:height]-2).each do |y|
      (2...data[:width]-2).each do |x|
        # Get 5x5 neighborhood
        neighborhood = []
        (-2..2).each do |dy|
          (-2..2).each do |dx|
            neighborhood << data[:data][y+dy][x+dx]
          end
        end
        
        # Calculate local variance
        mean = neighborhood.sum / neighborhood.size.to_f
        variance = neighborhood.map { |v| (v - mean) ** 2 }.sum / neighborhood.size
        roughness_values << variance
      end
    end
    
    {
      mean_roughness: roughness_values.sum / roughness_values.size.to_f,
      max_roughness: roughness_values.max
    }
  end
  
  def self.extract_smooth_regions(data)
    # Find large smooth areas (maria on Moon)
    smooth_threshold = 0.01  # Low roughness
    smooth_tiles = 0
    
    (2...data[:height]-2).each do |y|
      (2...data[:width]-2).each do |x|
        neighborhood = []
        (-2..2).each do |dy|
          (-2..2).each do |dx|
            neighborhood << data[:data][y+dy][x+dx]
          end
        end
        
        variance = neighborhood.map { |v| (v - neighborhood.sum / neighborhood.size.to_f) ** 2 }.sum / neighborhood.size
        smooth_tiles += 1 if variance < smooth_threshold
      end
    end
    
    {
      smooth_fraction: smooth_tiles / (data[:width] * data[:height]).to_f
    }
  end
  
  def self.extract_rough_regions(data)
    # Opposite of smooth regions
    rough_threshold = 0.05
    rough_tiles = 0
    
    (2...data[:height]-2).each do |y|
      (2...data[:width]-2).each do |x|
        neighborhood = []
        (-2..2).each do |dy|
          (-2..2).each do |dx|
            neighborhood << data[:data][y+dy][x+dx]
          end
        end
        
        variance = neighborhood.map { |v| (v - neighborhood.sum / neighborhood.size.to_f) ** 2 }.sum / neighborhood.size
        rough_tiles += 1 if variance > rough_threshold
      end
    end
    
    {
      rough_fraction: rough_tiles / (data[:width] * data[:height]).to_f
    }
  end
  
  # Placeholder methods (can be enhanced later)
  
  def self.extract_coastline_complexity(data)
    { complexity_factor: 0.3 }
  end
  
  def self.extract_mountain_chains(data)
    { chain_count: 8, avg_length: 50 }
  end
  
  def self.extract_volcanic_features(data)
    { volcano_count: 5 }
  end
  
  def self.extract_hemispheric_asymmetry(data)
    north_half = data[:data][0...data[:height]/2].flatten
    south_half = data[:data][data[:height]/2..-1].flatten
    
    {
      north_mean: north_half.sum / north_half.size.to_f,
      south_mean: south_half.sum / south_half.size.to_f,
      asymmetry: (north_half.sum / north_half.size.to_f - south_half.sum / south_half.size.to_f).abs
    }
  end
end