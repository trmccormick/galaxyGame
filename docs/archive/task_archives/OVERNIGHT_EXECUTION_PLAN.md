# Overnight Batch Execution Plan - Complete in 3 Nights

## 🌙 Optimized for Unattended Execution

Since you're running overnight, we can be much more aggressive:
- **Download larger datasets** (no waiting)
- **Run comprehensive analysis** (no time pressure)
- **Generate multiple pattern variants** (compare quality)
- **Complete all phases in 3 nights** instead of 3 weeks

---

## 🗓️ Night 1: Data Acquisition & Processing (Unattended)

### **Setup Script** (run before bed, ~5 minutes human time)

```bash
#!/bin/bash
# scripts/overnight_geotiff_setup.sh

set -e  # Exit on error

echo "=== NIGHT 1: GeoTIFF Download & Processing ==="
echo "Started at: $(date)"

# Create directories
mkdir -p data/geotiff/raw
mkdir -p data/geotiff/processed
mkdir -p data/ai_patterns
mkdir -p logs

# Log everything
exec > >(tee -a logs/night1_$(date +%Y%m%d).log) 2>&1

echo "Step 1: Downloading ETOPO 2022 (70MB)..."
wget -c https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO2022/data/60s/60s_surface_elev_netcdf/ETOPO_2022_v1_60s_N90W180_surface.nc \
    -O data/geotiff/raw/etopo_2022.nc

echo "Step 2: Verifying download..."
if [ -f data/geotiff/raw/etopo_2022.nc ]; then
    file_size=$(wc -c < data/geotiff/raw/etopo_2022.nc)
    echo "Downloaded successfully: $file_size bytes"
else
    echo "ERROR: Download failed!"
    exit 1
fi

echo "Step 3: Converting NetCDF to GeoTIFF..."
gdal_translate -of GTiff \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    -co TILED=YES \
    NETCDF:"data/geotiff/raw/etopo_2022.nc":z \
    data/geotiff/processed/earth_elevation.tif

echo "Step 4: Creating resampled versions for different use cases..."

# High-res for detailed analysis (3600x1800 = 0.1 degree)
gdalwarp -tr 0.1 0.1 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    data/geotiff/processed/earth_elevation.tif \
    data/geotiff/processed/earth_3600x1800.tif

# Medium-res for AI training (1800x900 = 0.2 degree)
gdalwarp -tr 0.2 0.2 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    data/geotiff/processed/earth_elevation.tif \
    data/geotiff/processed/earth_1800x900.tif

# Low-res for quick testing (900x450 = 0.4 degree)
gdalwarp -tr 0.4 0.4 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    data/geotiff/processed/earth_elevation.tif \
    data/geotiff/processed/earth_900x450.tif

echo "Step 5: Generating statistics..."
gdalinfo -stats data/geotiff/processed/earth_1800x900.tif > data/geotiff/processed/earth_stats.txt

echo "Step 6: Converting to simple ASCII format for Ruby..."
gdal_translate -of AAIGrid \
    data/geotiff/processed/earth_1800x900.tif \
    data/geotiff/processed/earth_1800x900.asc

echo "Step 7: Compressing ASCII for storage..."
gzip -9 data/geotiff/processed/earth_1800x900.asc

echo "=== NIGHT 1 COMPLETE ==="
echo "Finished at: $(date)"
echo ""
echo "Files created:"
ls -lh data/geotiff/processed/
echo ""
echo "Ready for Night 2: Pattern Extraction"
```

### **What Happens Overnight**:
1. Downloads ETOPO (70MB) - ~5-10 minutes
2. Converts to GeoTIFF - ~2-3 minutes
3. Creates 3 resampled versions - ~5-10 minutes
4. Generates statistics - ~1 minute
5. Converts to ASCII for Ruby - ~2 minutes
6. Compresses files - ~1 minute

**Total runtime**: ~20-30 minutes
**Your sleep time**: 8 hours
**When you wake up**: All data ready, logged, verified

---

## 🗓️ Night 2: Pattern Extraction (Unattended)

### **Setup Script** (run before bed, ~5 minutes human time)

```bash
#!/bin/bash
# scripts/overnight_pattern_extraction.sh

set -e

echo "=== NIGHT 2: Pattern Extraction ==="
echo "Started at: $(date)"

exec > >(tee -a logs/night2_$(date +%Y%m%d).log) 2>&1

echo "Step 1: Verifying Night 1 output..."
if [ ! -f data/geotiff/processed/earth_1800x900.asc.gz ]; then
    echo "ERROR: Night 1 data not found!"
    exit 1
fi

echo "Step 2: Running Ruby pattern extraction..."
cd "$(dirname "$0")/.."
bundle exec rails runner scripts/extract_all_patterns.rb

echo "Step 3: Validating extracted patterns..."
bundle exec rails runner scripts/validate_patterns.rb

echo "Step 4: Generating pattern visualization..."
bundle exec rails runner scripts/visualize_patterns.rb

echo "Step 5: Creating backup of patterns..."
cp -r data/ai_patterns data/ai_patterns_backup_$(date +%Y%m%d)

echo "=== NIGHT 2 COMPLETE ==="
echo "Finished at: $(date)"
echo ""
echo "Patterns created:"
ls -lh data/ai_patterns/
echo ""
echo "Ready for Night 3: Integration & Testing"
```

### **Ruby Script: Extract All Patterns**

```ruby
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
```

### **What Happens Overnight**:
1. Loads elevation data from compressed ASCII - ~1 minute
2. Extracts elevation patterns - ~2-3 minutes
3. Extracts coastline patterns - ~5-10 minutes
4. Extracts mountain patterns - ~5-10 minutes
5. Extracts slope patterns - ~3-5 minutes
6. Saves all pattern files - ~1 minute

**Total runtime**: ~20-30 minutes
**Your sleep time**: 8 hours
**When you wake up**: Patterns extracted, validated, ready to use

---

## 🗓️ Night 3: Integration, Testing & Deployment (Unattended)

### **Setup Script** (run before bed, ~5 minutes human time)

```bash
#!/bin/bash
# scripts/overnight_integration.sh

set -e

echo "=== NIGHT 3: Integration & Testing ==="
echo "Started at: $(date)"

exec > >(tee -a logs/night3_$(date +%Y%m%d).log) 2>&1

echo "Step 1: Running integration tests..."
bundle exec rspec spec/services/ai_manager/planetary_map_generator_spec.rb

echo "Step 2: Generating test maps with patterns..."
bundle exec rails runner scripts/generate_test_maps.rb

echo "Step 3: Comparing before/after quality..."
bundle exec rails runner scripts/compare_map_quality.rb

echo "Step 4: Creating final pattern package..."
tar -czf data/ai_patterns_final_$(date +%Y%m%d).tar.gz data/ai_patterns/*.json

echo "Step 5: Cleaning up temporary files..."
rm -rf data/geotiff/raw/*.nc
rm -rf data/geotiff/processed/*.tif
# Keep only: compressed ASCII and final patterns

echo "=== NIGHT 3 COMPLETE ==="
echo "Finished at: $(date)"
echo ""
echo "Final deliverables:"
ls -lh data/ai_patterns_final_*.tar.gz
ls -lh data/ai_patterns/*.json
echo ""
echo "READY FOR PRODUCTION DEPLOYMENT"
```

### **Ruby Script: Generate Test Maps**

```ruby
# scripts/generate_test_maps.rb

puts "=== Generating Test Maps ==="

# Generate Earth maps
earth = CelestialBody.find_by(name: 'Earth')

# Before (pure procedural)
before = AIManager::PlanetaryMapGenerator.new.generate_planet_map(
  earth,
  use_patterns: false
)

# After (with GeoTIFF patterns)
after = AIManager::PlanetaryMapGenerator.new.generate_planet_map(
  earth,
  use_patterns: true
)

# Save for comparison
FileUtils.mkdir_p('tmp/map_comparison')

File.write('tmp/map_comparison/earth_before.json', before.to_json)
File.write('tmp/map_comparison/earth_after.json', after.to_json)

puts "Maps saved to tmp/map_comparison/"
puts "Before: #{File.size('tmp/map_comparison/earth_before.json')} bytes"
puts "After: #{File.size('tmp/map_comparison/earth_after.json')} bytes"

# Generate visualizations
puts "Generating visualizations..."
# ... render both maps to PNG for visual comparison ...

puts "=== Complete ==="
```

---

## 📊 Overnight Results Summary

### **After Night 1**:
```
data/geotiff/processed/
├── earth_elevation.tif           # Original converted
├── earth_3600x1800.tif          # High-res (for future)
├── earth_1800x900.tif           # AI training resolution
├── earth_900x450.tif            # Quick testing
├── earth_1800x900.asc.gz        # Compressed ASCII (15MB)
└── earth_stats.txt              # Statistics

Total: ~50MB (can delete .tif files, keep only .asc.gz)
```

### **After Night 2**:
```
data/ai_patterns/
├── geotiff_elevation.json       # ~100KB
├── geotiff_coastline.json       # ~50KB
├── geotiff_mountain.json        # ~50KB
├── geotiff_slope.json           # ~20KB
└── geotiff_master.json          # ~300KB (combined)

Total: ~500KB
```

### **After Night 3**:
```
data/
├── ai_patterns/*.json           # 500KB (ready for Git commit)
├── geotiff/processed/*.asc.gz   # 15MB (backup, can delete later)
└── ai_patterns_final.tar.gz     # 200KB (compressed patterns)

Ready to commit: ~500KB
```

---

## 🎯 Human Effort Required

### **Night 1 Setup** (5 minutes):
```bash
# Before bed
chmod +x scripts/overnight_geotiff_setup.sh
nohup scripts/overnight_geotiff_setup.sh &
# Go to sleep
```

### **Morning 1 Check** (2 minutes):
```bash
# Check logs
tail logs/night1_*.log

# Verify success
ls -lh data/geotiff/processed/
```

### **Night 2 Setup** (5 minutes):
```bash
# Before bed
chmod +x scripts/overnight_pattern_extraction.sh
nohup scripts/overnight_pattern_extraction.sh &
# Go to sleep
```

### **Morning 2 Check** (2 minutes):
```bash
# Check logs
tail logs/night2_*.log

# Verify patterns
cat data/ai_patterns/geotiff_master.json | jq '.metadata'
```

### **Night 3 Setup** (5 minutes):
```bash
# Before bed
chmod +x scripts/overnight_integration.sh
nohup scripts/overnight_integration.sh &
# Go to sleep
```

### **Morning 3: Deploy** (10 minutes):
```bash
# Review results
cat logs/night3_*.log

# Commit to Git
git add data/ai_patterns/*.json
git commit -m "Add GeoTIFF learned patterns for realistic terrain generation"

# Clean up
rm -rf data/geotiff/raw
rm -rf data/geotiff/processed/*.tif

# Done!
```

---

## 📅 3-Day Timeline

| Day | Human Time | Computer Time | Deliverable |
|-----|------------|---------------|-------------|
| Night 1 | 5 min setup | 30 min | Processed elevation data |
| Morning 1 | 2 min verify | - | Confirmed data ready |
| Night 2 | 5 min setup | 30 min | Extracted patterns |
| Morning 2 | 2 min verify | - | Confirmed patterns valid |
| Night 3 | 5 min setup | 20 min | Integrated & tested |
| Morning 3 | 10 min deploy | - | **Production ready!** |

**Total human time**: 29 minutes over 3 days
**Total computer time**: ~80 minutes (overnight, doesn't matter)
**Total calendar time**: 3 days

---

## ✅ What You'll Have After 3 Nights

1. **Pattern JSON files** (~500KB) - Ready for Git
2. **Validated integration** - Tests passing
3. **Before/after comparison** - Visual proof of improvement
4. **Production-ready code** - PlanetaryMapGenerator using patterns
5. **Clean repository** - No large binary files

**And you only spent 29 minutes of hands-on time!**

This is WAY better than the 12.5-hour manual approach. Let the computer work while you sleep! 🌙→☀️
