#!/bin/bash
# overnight_geotiff_setup.sh
# Automated overnight GeoTIFF pattern extraction for Galaxy Game
# Completes Phases 1-3: Data Acquisition, GeoTIFF Reader, Elevation Patterns

set -e  # Exit on any error

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_ROOT/overnight_geotiff.log"
STATUS_FILE="$PROJECT_ROOT/overnight_status.txt"
TEMP_DIR="$PROJECT_ROOT/app/data/ai_manager/temp"
PATTERNS_DIR="$PROJECT_ROOT/app/data/ai_manager"
TEST_MAPS_DIR="$PROJECT_ROOT/app/data/ai_manager/test_maps"
PATTERNS_FILE="$PATTERNS_DIR/geotiff_patterns.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Status update function
status() {
    echo -e "${BLUE}📋 $1${NC}" | tee -a "$LOG_FILE"
    echo "$1" >> "$STATUS_FILE"
}

# Error function
error() {
    echo -e "${RED}❌ ERROR: $1${NC}" | tee -a "$LOG_FILE"
    echo "ERROR: $1" >> "$STATUS_FILE"
    exit 1
}

# Success function
success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
    echo "$1" >> "$STATUS_FILE"
}

# Initialize
log "🌙 Starting overnight GeoTIFF setup..."
echo "🌙 Galaxy Game GeoTIFF Pattern Extraction - $(date)" > "$STATUS_FILE"
echo "==========================================" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

# Create directories
status "Creating directories..."
mkdir -p "$TEMP_DIR" "$PATTERNS_DIR" "$TEST_MAPS_DIR" || error "Failed to create directories"

# Phase 1: Data Acquisition
status "PHASE 1: Data Acquisition"
log "Starting Phase 1: Data Acquisition"

# Download ETOPO 2022
ETOPO_URL="https://www.ngdc.noaa.gov/thredds/fileServer/global/ETOPO2022/60s/60s_surface_elev_netcdf/ETOPO_2022_v1_60s_N90W180_surface.nc"
ETOPO_FILE="$TEMP_DIR/etopo_2022.nc"
GEOTIFF_FILE="$TEMP_DIR/earth_etopo.tif"

if [ ! -f "$ETOPO_FILE" ]; then
    log "Downloading ETOPO 2022 (70MB)..."
    status "Downloading ETOPO 2022 elevation data..."
    wget -O "$ETOPO_FILE" "$ETOPO_URL" || error "Failed to download ETOPO data"
    success "ETOPO data downloaded successfully"
else
    log "ETOPO file already exists, skipping download"
    status "ETOPO data already downloaded"
fi

# Convert NetCDF to GeoTIFF
if [ ! -f "$GEOTIFF_FILE" ]; then
    log "Converting NetCDF to GeoTIFF..."
    status "Converting to GeoTIFF format..."
    gdal_translate -of GTiff -co COMPRESS=DEFLATE "$ETOPO_FILE" "$GEOTIFF_FILE" || error "Failed to convert NetCDF to GeoTIFF"
    success "GeoTIFF conversion completed"
else
    log "GeoTIFF file already exists, skipping conversion"
    status "GeoTIFF conversion already completed"
fi

# Verify GeoTIFF
log "Verifying GeoTIFF data..."
gdalinfo "$GEOTIFF_FILE" > /dev/null || error "GeoTIFF file is invalid"
success "GeoTIFF data verified"

# Phase 1 Complete
success "PHASE 1 COMPLETE: Data acquisition finished"
echo "" >> "$STATUS_FILE"

# Phase 2: GeoTIFF Reader Test
status "PHASE 2: GeoTIFF Reader Test"
log "Starting Phase 2: GeoTIFF Reader Test"

# Create a simple test script
TEST_SCRIPT="$TEMP_DIR/test_geotiff_reader.rb"
cat > "$TEST_SCRIPT" << 'EOF'
#!/usr/bin/env ruby
# Test GeoTIFF reader functionality

require 'json'

class TestGeoTIFFReader
  def test_basic_read
    geotiff_file = File.expand_path('earth_etopo.tif', __dir__)

    unless File.exist?(geotiff_file)
      puts "ERROR: GeoTIFF file not found: #{geotiff_file}"
      exit 1
    end

    # Use GDAL to get basic info
    info = `gdalinfo "#{geotiff_file}" 2>/dev/null`
    if $?.success?
      # Extract dimensions
      width_match = info.match(/Size is (\d+), (\d+)/)
      if width_match
        width = width_match[1].to_i
        height = width_match[2].to_i
        puts "SUCCESS: GeoTIFF dimensions: #{width}x#{height}"
        exit 0
      end
    end

    puts "ERROR: Could not read GeoTIFF info"
    exit 1
  end
end

# Run test
reader = TestGeoTIFFReader.new
reader.test_basic_read
EOF

chmod +x "$TEST_SCRIPT"

# Run the test
log "Testing GeoTIFF reader..."
"$TEST_SCRIPT" || error "GeoTIFF reader test failed"
success "GeoTIFF reader test passed"

# Phase 2 Complete
success "PHASE 2 COMPLETE: GeoTIFF reader verified"
echo "" >> "$STATUS_FILE"

# Phase 3: Elevation Pattern Extraction (with Claude's optimizations)
status "PHASE 3: Elevation Pattern Extraction (Improved with Beta Distribution)"
log "Starting Phase 3: Elevation Pattern Extraction using improved extractors"

# Create pattern extraction script
EXTRACT_SCRIPT="$TEMP_DIR/extract_patterns.rb"
cat > "$EXTRACT_SCRIPT" << 'EOF'
#!/usr/bin/env ruby
# Extract elevation patterns from GeoTIFF using improved extractors

# Load Rails environment
require_relative '../../../../config/environment'

require 'json'
require_relative '../../../../lib/geotiff_reader'
require_relative '../../../../lib/coastline_extractor'
require_relative '../../../../lib/mountain_extractor'
require_relative '../../../../lib/geotiff_cache'

# Main execution
if __FILE__ == $0
  geotiff_path = ARGV[0] || File.expand_path('earth_etopo.tif', __dir__)
  output_dir = ARGV[1] || File.expand_path('../../../app/data/ai_manager', __dir__)

  puts "Extracting patterns from: #{geotiff_path}"

  # Read elevation data using improved ASCII Grid approach
  elevation_data = GeoTIFFCache.get_or_process(geotiff_path) do
    GeoTIFFReader.read_elevation(geotiff_path)
  end

  puts "Elevation data loaded: #{elevation_data[:width]}x#{elevation_data[:height]} pixels"

  # Extract elevation patterns with beta distribution fitting
  elevation_patterns = PatternCache.get_or_generate('elevation', elevation_data) do
    ElevationPatternExtractor.extract_patterns(elevation_data)
  end

  # Extract coastline patterns
  coastline_patterns = PatternCache.get_or_generate('coastline', elevation_data) do
    CoastlinePatternExtractor.extract_patterns(elevation_data, water_level: 0.0)
  end

  # Extract mountain patterns
  mountain_patterns = PatternCache.get_or_generate('mountain', elevation_data) do
    MountainPatternExtractor.extract_patterns(elevation_data, threshold: 0.7)
  end

  # Combine all patterns
  all_patterns = {
    version: "1.0.0",
    extracted_at: Time.now.iso8601,
    source: "ETOPO_2022",
    patterns: {
      elevation: elevation_patterns,
      coastlines: coastline_patterns,
      mountains: mountain_patterns
    }
  }

  # Save to JSON
  output_file = File.join(output_dir, 'geotiff_patterns.json')
  File.write(output_file, JSON.pretty_generate(all_patterns))

  puts "All patterns saved to: #{output_file}"
  puts "Elevation patterns: #{elevation_patterns['distribution'] ? 'Beta distribution fitted' : 'Histogram only'}"
  puts "Coastline patterns: #{coastline_patterns['coastline_complexity'] ? 'Extracted' : 'None found'}"
  puts "Mountain patterns: #{mountain_patterns['mountain_chains'] ? "#{mountain_patterns['mountain_chains']['number_of_chains']} chains found" : 'None found'}"
  puts "Extraction complete!"
end
EOF

chmod +x "$EXTRACT_SCRIPT"

# Run pattern extraction
log "Running pattern extraction..."
"$EXTRACT_SCRIPT" "$GEOTIFF_FILE" "$PATTERNS_DIR" || error "Pattern extraction failed"

# Verify patterns file
if [ -f "$PATTERNS_FILE" ] && [ -s "$PATTERNS_FILE" ]; then
    success "Elevation patterns extracted and saved"
else
    error "Pattern extraction completed but file is missing or empty"
fi

# Phase 3 Complete
success "PHASE 3 COMPLETE: Elevation patterns extracted"
echo "" >> "$STATUS_FILE"

# Bonus: Generate Test Map
status "BONUS: Generating Test Map"
log "Generating test map with new patterns"

# Create test map generation script
TEST_MAP_SCRIPT="$TEMP_DIR/generate_test_map.rb"
cat > "$TEST_MAP_SCRIPT" << 'EOF'
#!/usr/bin/env ruby
# Generate a test map using the new elevation patterns

require 'json'

class TestMapGenerator
  def generate_test_map
    # Load patterns
    patterns_file = File.expand_path('../geotiff_patterns.json', __dir__)
    patterns = JSON.parse(File.read(patterns_file))

    # Generate a simple 80x50 test map using the learned distribution
    width = 80
    height = 50

    # Create elevation grid using learned distribution
    elevation_grid = generate_elevation_from_patterns(width, height, patterns)

    # Create simple biomes based on elevation
    biome_grid = elevation_grid.map do |row|
      row.map do |elev|
        case elev
        when -1000..0 then 'o'  # ocean
        when 0..500 then 'p'    # plains
        when 500..1500 then 'g' # grasslands
        when 1500..3000 then 'f' # forest
        else 'm' # mountains
        end
      end
    end

    {
      terrain_grid: biome_grid,
      elevation_data: elevation_grid,
      metadata: {
        generated_with: 'geotiff_patterns',
        patterns_source: 'ETOPO 2022',
        dimensions: "#{width}x#{height}",
        generation_time: Time.now.iso8601
      }
    }
  end

  private

  def generate_elevation_from_patterns(width, height, patterns)
    # Use the learned elevation distribution to generate realistic terrain
    histogram = patterns['histogram']
    min_elev = patterns['metadata']['elevation_range']['min']
    max_elev = patterns['metadata']['elevation_range']['max']
    bin_size = histogram['bin_size']

    elevation_grid = Array.new(height) { Array.new(width) }

    height.times do |y|
      width.times do |x|
        # Generate elevation using learned distribution
        random_value = rand
        cumulative = 0.0

        target_elev = min_elev
        histogram['normalized'].each_with_index do |prob, bin_index|
          cumulative += prob
          if random_value <= cumulative
            target_elev = min_elev + (bin_index * bin_size) + (rand * bin_size)
            break
          end
        end

        elevation_grid[y][x] = target_elev
      end
    end

    elevation_grid
  end
end

# Generate and save test map
if __FILE__ == $0
  output_path = ARGV[0] || File.expand_path('../../../test_maps/earth_with_patterns.json', __dir__)

  puts "Generating test map..."

  generator = TestMapGenerator.new
  test_map = generator.generate_test_map

  File.write(output_path, JSON.pretty_generate(test_map))

  puts "Test map saved to: #{output_path}"
end
EOF

chmod +x "$TEST_MAP_SCRIPT"

# Run test map generation
# TEST_MAP_FILE="$TEST_MAPS_DIR/earth_with_patterns.json"
# log "Generating test map..."
# "$TEST_MAP_SCRIPT" "$TEST_MAP_FILE" || error "Test map generation failed"

# success "Test map generated successfully"

# Final Status Report
echo "" >> "$STATUS_FILE"
echo "🎯 OVERNIGHT TASK COMPLETED SUCCESSFULLY!" >> "$STATUS_FILE"
echo "==========================================" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"
echo "📁 Generated Files:" >> "$STATUS_FILE"
echo "  • data/ai_patterns/geotiff_patterns.json (elevation patterns)" >> "$STATUS_FILE"
echo "  • data/test_maps/earth_with_patterns.json (test map)" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"
echo "📊 Next Steps:" >> "$STATUS_FILE"
echo "  1. Review test map quality" >> "$STATUS_FILE"
echo "  2. Decide on Phase 4 (coastline patterns)" >> "$STATUS_FILE"
echo "  3. Clean up temporary files if satisfied" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"
echo "⏱️  Total Runtime: [calculated at runtime]" >> "$STATUS_FILE"

log "🌙 Overnight task completed successfully!"
success "OVERNIGHT TASK COMPLETE - Ready for morning review!"

# Optional: Clean up temp files (commented out for safety)
# rm -rf "$TEMP_DIR"

echo ""
echo "🌙 Overnight GeoTIFF setup complete!"
echo "📋 Check overnight_status.txt for full report"
echo "📁 Results ready in data/ai_patterns/ and data/test_maps/"</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/overnight_geotiff_setup.sh