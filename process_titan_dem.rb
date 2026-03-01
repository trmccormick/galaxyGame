#!/usr/bin/env ruby
# process_titan_dem.rb
# Convert Titan PNG heightmap to proper DEM with negative lake basins

require 'chunky_png'
require 'zlib'

puts "Processing Titan DEM with Lake Basins"
puts "=" * 50

# Configuration
INPUT_PNG = 'data/geotiff/raw/titan_topography_pia16848.png'
OUTPUT_ASC = 'data/geotiff/processed/titan_1800x900.asc'
OUTPUT_GZ = 'data/geotiff/processed/titan_1800x900.asc.gz'

# Titan parameters (from Cassini data)
LAKE_REGIONS = [
  # North polar region (60N to 90N) - main lakes: Kraken Mare, Ligeia Mare, Punga Mare
  { lat_min: 60, lat_max: 90, lon_min: 0, lon_max: 360 },
  # South polar region (60S to 90S) - fewer, smaller lakes
  { lat_min: -90, lat_max: -60, lon_min: 0, lon_max: 360 }
]

LAKE_DEPTH_RANGE = { min: -200, max: -50 }  # Methane lake depths
UPLAND_RANGE = { min: 0, max: 3000 }         # Ice plains and dunes

# Target dimensions
TARGET_WIDTH = 1800
TARGET_HEIGHT = 900

def lat_lon_to_grid(lat, lon, height, width)
  # Convert lat/lon to grid coordinates
  # Latitude: 90 (top) to -90 (bottom)
  # Longitude: -180 (left) to 180 (right) wrapped to 0-360
  
  y = ((90 - lat) / 180.0 * height).round
  x = ((lon % 360) / 360.0 * width).round
  
  [y.clamp(0, height - 1), x.clamp(0, width - 1)]
end

def in_lake_region?(y, x, height, width)
  # Convert grid coords back to lat/lon
  lat = 90 - (y.to_f / height * 180)
  lon = (x.to_f / width * 360) - 180
  
  LAKE_REGIONS.any? do |region|
    lat >= region[:lat_min] && 
    lat <= region[:lat_max] &&
    (lon >= region[:lon_min] || lon <= region[:lon_max] - 360)
  end
end

begin
  # Load PNG
  puts "Loading PNG: #{INPUT_PNG}"
  image = ChunkyPNG::Image.from_file(INPUT_PNG)
  puts "  Dimensions: #{image.width}x#{image.height}"
  
  # Resample if needed
  if image.width != TARGET_WIDTH || image.height != TARGET_HEIGHT
    puts "Resampling to #{TARGET_WIDTH}x#{TARGET_HEIGHT}..."
    # Simple nearest-neighbor resampling
    resampled = ChunkyPNG::Image.new(TARGET_WIDTH, TARGET_HEIGHT)
    
    (0...TARGET_HEIGHT).each do |y|
      (0...TARGET_WIDTH).each do |x|
        src_x = (x * image.width / TARGET_WIDTH).clamp(0, image.width - 1)
        src_y = (y * image.height / TARGET_HEIGHT).clamp(0, image.height - 1)
        resampled[x, y] = image[src_x, src_y]
      end
    end
    
    image = resampled
  end
  
  # Convert to elevation grid
  puts "Converting to elevation grid with lake basins..."
  elevation_grid = Array.new(TARGET_HEIGHT) { Array.new(TARGET_WIDTH, 0) }
  
  stats = { min: Float::INFINITY, max: -Float::INFINITY, lake_cells: 0, land_cells: 0 }
  
  (0...TARGET_HEIGHT).each do |y|
    (0...TARGET_WIDTH).each do |x|
      # Get pixel brightness (0-255)
      pixel = image[x, y]
      brightness = ChunkyPNG::Color.r(pixel)  # Assuming grayscale
      
      # Normalize to 0-1
      normalized = brightness / 255.0
      
      # Check if in lake region
      is_lake_region = in_lake_region?(y, x, TARGET_HEIGHT, TARGET_WIDTH)
      
      if is_lake_region && normalized < 0.15  # Darkest 15% = ~1.5% total coverage
        # Map to negative depths (deeper = darker)
        depth_range = LAKE_DEPTH_RANGE[:max] - LAKE_DEPTH_RANGE[:min]
        elevation = LAKE_DEPTH_RANGE[:min] + (normalized * depth_range)
        stats[:lake_cells] += 1
      else
        # Map to positive heights (higher = brighter)
        height_range = UPLAND_RANGE[:max] - UPLAND_RANGE[:min]
        elevation = UPLAND_RANGE[:min] + (normalized * height_range)
        stats[:land_cells] += 1
      end
      
      elevation_grid[y][x] = elevation.round(1)
      
      stats[:min] = elevation if elevation < stats[:min]
      stats[:max] = elevation if elevation > stats[:max]
    end
    
    print "\rProgress: #{((y + 1) * 100.0 / TARGET_HEIGHT).round(1)}%" if y % 10 == 0
  end
  
  puts "\n"
  puts "Statistics:"
  puts "  Min elevation: #{stats[:min].round(1)}m"
  puts "  Max elevation: #{stats[:max].round(1)}m"
  puts "  Lake cells: #{stats[:lake_cells]} (#{(stats[:lake_cells] * 100.0 / (TARGET_WIDTH * TARGET_HEIGHT)).round(2)}%)"
  puts "  Land cells: #{stats[:land_cells]}"
  
  # Write ASC format
  puts "\nWriting ASC file: #{OUTPUT_ASC}"
  File.open(OUTPUT_ASC, 'w') do |f|
    # ASC header
    f.puts "ncols #{TARGET_WIDTH}"
    f.puts "nrows #{TARGET_HEIGHT}"
    f.puts "xllcorner -180.0"
    f.puts "yllcorner -90.0"
    f.puts "cellsize #{360.0 / TARGET_WIDTH}"
    f.puts "NODATA_value -9999"
    
    # Data rows (top to bottom)
    elevation_grid.each do |row|
      f.puts row.join(' ')
    end
  end
  
  # Compress
  puts "Compressing to: #{OUTPUT_GZ}"
  Zlib::GzipWriter.open(OUTPUT_GZ) do |gz|
    gz.write(File.read(OUTPUT_ASC))
  end
  
  # Clean up uncompressed file
  File.delete(OUTPUT_ASC)
  
  puts "\n✓ Titan DEM created successfully!"
  puts "  Output: #{OUTPUT_GZ}"
  puts "  Lake coverage: #{(stats[:lake_cells] * 100.0 / (TARGET_WIDTH * TARGET_HEIGHT)).round(2)}%"
  
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end
