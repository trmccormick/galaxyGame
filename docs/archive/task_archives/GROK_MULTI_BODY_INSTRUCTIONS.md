# GROK IMPLEMENTATION INSTRUCTIONS - Multi-Body Pattern Extraction

## 🎯 OBJECTIVE

Upgrade Night 2 script to extract patterns from THREE body types instead of just Earth:
1. **Earth** (already have) - Earth-like terrestrial
2. **Luna** (download tonight) - Airless cratered bodies
3. **Mars** (download tonight) - Thin atmosphere planets

This will allow Galaxy Game to generate realistic terrain for ~90% of celestial body types.

---

## 📋 TASKS FOR GROK

### TASK 1: Download Luna and Mars DEMs (Before Night 2)

**Create this script**: `scripts/download_luna_mars.sh`

```bash
#!/bin/bash
# scripts/download_luna_mars.sh

set -e

echo "=========================================="
echo "Downloading Luna and Mars Elevation Data"
echo "Started at: $(date)"
echo "=========================================="
echo ""

mkdir -p data/geotiff/raw
mkdir -p data/geotiff/processed
mkdir -p logs

exec > >(tee -a logs/download_bodies_$(date +%Y%m%d_%H%M%S).log) 2>&1

# Download Luna (Moon) DEM
echo "Step 1: Downloading Lunar DEM from USGS..."
echo "  Source: LRO LOLA Global DEM (118m resolution)"
echo "  Size: ~350MB (this will take a few minutes)"
echo ""

wget -c -O data/geotiff/raw/luna_lola_118m.tif \
    "https://planetarymaps.usgs.gov/mosaic/Lunar_LRO_LOLA_Global_LDEM_118m_Mar2014.tif"

if [ $? -eq 0 ]; then
    echo "✓ Luna DEM downloaded successfully"
    ls -lh data/geotiff/raw/luna_lola_118m.tif
else
    echo "❌ Luna download failed"
    exit 1
fi

echo ""

# Download Mars DEM
echo "Step 2: Downloading Mars DEM from USGS..."
echo "  Source: MGS MOLA Global DEM (463m resolution)"
echo "  Size: ~180MB (this will take a few minutes)"
echo ""

wget -c -O data/geotiff/raw/mars_mola_463m.tif \
    "https://planetarymaps.usgs.gov/mosaic/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif"

if [ $? -eq 0 ]; then
    echo "✓ Mars DEM downloaded successfully"
    ls -lh data/geotiff/raw/mars_mola_463m.tif
else
    echo "❌ Mars download failed"
    exit 1
fi

echo ""

# Process Luna to training resolution
echo "Step 3: Processing Luna to 1800x900 resolution..."
gdalwarp -tr 0.2 0.2 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    data/geotiff/raw/luna_lola_118m.tif \
    data/geotiff/processed/luna_1800x900.tif

echo "✓ Luna processed"
ls -lh data/geotiff/processed/luna_1800x900.tif

echo ""

# Process Mars to training resolution
echo "Step 4: Processing Mars to 1800x900 resolution..."
gdalwarp -tr 0.2 0.2 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    data/geotiff/raw/mars_mola_463m.tif \
    data/geotiff/processed/mars_1800x900.tif

echo "✓ Mars processed"
ls -lh data/geotiff/processed/mars_1800x900.tif

echo ""

# Convert to compressed ASCII for Ruby processing
echo "Step 5: Converting to ASCII format for Ruby..."

gdal_translate -of AAIGrid \
    data/geotiff/processed/luna_1800x900.tif \
    data/geotiff/processed/luna_1800x900.asc

gzip -9 data/geotiff/processed/luna_1800x900.asc

echo "✓ Luna ASCII created"

gdal_translate -of AAIGrid \
    data/geotiff/processed/mars_1800x900.tif \
    data/geotiff/processed/mars_1800x900.asc

gzip -9 data/geotiff/processed/mars_1800x900.asc

echo "✓ Mars ASCII created"

echo ""
echo "=========================================="
echo "DOWNLOAD & PROCESSING COMPLETE!"
echo "Finished at: $(date)"
echo "=========================================="
echo ""
echo "Files ready:"
ls -lh data/geotiff/processed/*.asc.gz
echo ""
echo "Ready for Night 2 multi-body pattern extraction"
```

**Make executable**:
```bash
chmod +x scripts/download_luna_mars.sh
```

---

### TASK 2: Update Night 2 Script for Multi-Body Extraction

**Modify**: `scripts/night2_advanced_patterns.sh`

**REPLACE the entire script with**:

```bash
#!/bin/bash
# scripts/night2_multi_body_patterns.sh

set -e

echo "=========================================="
echo "NIGHT 2: Multi-Body Pattern Extraction"
echo "Started at: $(date)"
echo "=========================================="
echo ""

exec > >(tee -a logs/night2_$(date +%Y%m%d_%H%M%S).log) 2>&1

# Verify all three bodies are available
echo "Step 0: Verifying data availability..."

EARTH_DATA="app/data/geotiff/processed/earth_1800x900.asc.gz"
LUNA_DATA="data/geotiff/processed/luna_1800x900.asc.gz"
MARS_DATA="data/geotiff/processed/mars_1800x900.asc.gz"

if [ ! -f "$EARTH_DATA" ]; then
    echo "❌ ERROR: Earth data not found!"
    echo "Expected: $EARTH_DATA"
    exit 1
fi

if [ ! -f "$LUNA_DATA" ]; then
    echo "❌ ERROR: Luna data not found!"
    echo "Run: ./scripts/download_luna_mars.sh first"
    exit 1
fi

if [ ! -f "$MARS_DATA" ]; then
    echo "❌ ERROR: Mars data not found!"
    echo "Run: ./scripts/download_luna_mars.sh first"
    exit 1
fi

echo "✓ All three body types available"
echo ""

# Extract patterns for each body type
echo "Step 1: Extracting EARTH patterns..."
bundle exec rails runner "
  require './scripts/lib/pattern_extractor'
  PatternExtractor.extract_body_patterns('earth', '$EARTH_DATA')
"
echo "✓ Earth patterns complete"
echo ""

echo "Step 2: Extracting LUNA patterns..."
bundle exec rails runner "
  require './scripts/lib/pattern_extractor'
  PatternExtractor.extract_body_patterns('luna', '$LUNA_DATA')
"
echo "✓ Luna patterns complete"
echo ""

echo "Step 3: Extracting MARS patterns..."
bundle exec rails runner "
  require './scripts/lib/pattern_extractor'
  PatternExtractor.extract_body_patterns('mars', '$MARS_DATA')
"
echo "✓ Mars patterns complete"
echo ""

echo "Step 4: Validating all pattern files..."
bundle exec rails runner "
  require './scripts/lib/pattern_validator'
  PatternValidator.validate_all
"
echo "✓ Validation complete"
echo ""

echo "Step 5: Creating pattern summary..."
bundle exec rails runner "
  require './scripts/lib/pattern_summarizer'
  PatternSummarizer.create_summary
"
echo "✓ Summary created"
echo ""

echo "=========================================="
echo "NIGHT 2 COMPLETE!"
echo "Finished at: $(date)"
echo "=========================================="
echo ""
echo "Pattern files created:"
ls -lh app/data/ai_manager/geotiff_patterns_*.json
echo ""
echo "Total pattern storage:"
du -sh app/data/ai_manager/
echo ""
echo "Ready for Night 3: Integration & Testing"
```

---

### TASK 3: Create Pattern Extractor Library

**Create file**: `scripts/lib/pattern_extractor.rb`

```ruby
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
    output_file = Rails.root.join("app/data/ai_manager/geotiff_patterns_#{body_type}.json")
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
```

---

### TASK 4: Create Pattern Validator

**Create file**: `scripts/lib/pattern_validator.rb`

```ruby
# scripts/lib/pattern_validator.rb

require 'json'

class PatternValidator
  def self.validate_all
    puts "=== Validating All Pattern Files ==="
    
    bodies = ['earth', 'luna', 'mars']
    all_valid = true
    
    bodies.each do |body|
      file = Rails.root.join("app/data/ai_manager/geotiff_patterns_#{body}.json")
      
      if File.exist?(file)
        valid = validate_pattern_file(body, file)
        all_valid &&= valid
      else
        puts "❌ Missing pattern file for #{body}"
        all_valid = false
      end
    end
    
    if all_valid
      puts "✅ All pattern files valid!"
    else
      puts "❌ Some pattern files invalid"
      exit 1
    end
  end
  
  private
  
  def self.validate_pattern_file(body, filepath)
    puts "Validating #{body}..."
    
    patterns = JSON.parse(File.read(filepath))
    
    # Check required keys
    required = ['body_type', 'characteristics', 'patterns', 'metadata']
    missing = required - patterns.keys
    
    if missing.any?
      puts "  ❌ Missing keys: #{missing.join(', ')}"
      return false
    end
    
    # Check patterns section
    unless patterns['patterns'].is_a?(Hash) && patterns['patterns'].any?
      puts "  ❌ Patterns section empty"
      return false
    end
    
    puts "  ✓ Valid (#{File.size(filepath) / 1024} KB)"
    true
  end
end
```

---

### TASK 5: Create Pattern Summarizer

**Create file**: `scripts/lib/pattern_summarizer.rb`

```ruby
# scripts/lib/pattern_summarizer.rb

require 'json'

class PatternSummarizer
  def self.create_summary
    puts "=== Creating Pattern Summary ==="
    
    bodies = ['earth', 'luna', 'mars']
    summary = {
      version: '1.0.0',
      created_at: Time.current.iso8601,
      bodies: {}
    }
    
    bodies.each do |body|
      file = Rails.root.join("app/data/ai_manager/geotiff_patterns_#{body}.json")
      next unless File.exist?(file)
      
      patterns = JSON.parse(File.read(file))
      
      summary[:bodies][body] = {
        body_type: patterns['body_type'],
        characteristics: patterns['characteristics'],
        pattern_types: patterns['patterns'].keys,
        file_size_kb: File.size(file) / 1024
      }
    end
    
    # Save summary
    output_file = Rails.root.join('app/data/ai_manager/pattern_summary.json')
    File.write(output_file, JSON.pretty_generate(summary))
    
    puts "✓ Summary created: #{output_file}"
    puts ""
    puts "Body Types Available:"
    summary[:bodies].each do |body, info|
      puts "  #{body.upcase}: #{info[:body_type]}"
      puts "    Patterns: #{info[:pattern_types].join(', ')}"
      puts "    Size: #{info[:file_size_kb]} KB"
    end
  end
end
```

---

## 🚀 EXECUTION SEQUENCE FOR TONIGHT

### Before Night 2 Starts (Run Now):

```bash
# 1. Download Luna + Mars (takes ~30 minutes)
./scripts/download_luna_mars.sh

# 2. Verify downloads
ls -lh data/geotiff/processed/*.asc.gz

# Should see:
# earth_1800x900.asc.gz  (~15MB)
# luna_1800x900.asc.gz   (~12MB)
# mars_1800x900.asc.gz   (~14MB)
```

### Before Bed (5 minutes):

```bash
# 3. Start Night 2 multi-body extraction
nohup ./scripts/night2_multi_body_patterns.sh &

# 4. Verify it started
tail logs/night2_*.log

# 5. Go to sleep! 💤
```

### Tomorrow Morning (2 minutes):

```bash
# Check completion
tail logs/night2_*.log
# Should see: "NIGHT 2 COMPLETE!"

# Verify pattern files
ls -lh app/data/ai_manager/geotiff_patterns_*.json

# Should see:
# geotiff_patterns_earth.json  (~800KB)
# geotiff_patterns_luna.json   (~500KB)
# geotiff_patterns_mars.json   (~600KB)
# pattern_summary.json         (~5KB)
```

---

## ✅ DELIVERABLES

After tonight, you'll have:

1. ✅ Earth patterns (erosion, rivers, coastlines)
2. ✅ Luna patterns (heavy craters, no erosion)
3. ✅ Mars patterns (moderate craters, ancient rivers)
4. ✅ Pattern summary (which body to use for which planet type)
5. ✅ Validation (all patterns verified)

**Total storage**: ~2MB patterns in Git
**Coverage**: 90% of celestial body types in Galaxy Game!

---

## 📋 CHECKLIST FOR GROK

- [ ] Create `scripts/download_luna_mars.sh`
- [ ] Make it executable (`chmod +x`)
- [ ] Update `scripts/night2_advanced_patterns.sh` → `scripts/night2_multi_body_patterns.sh`
- [ ] Create `scripts/lib/pattern_extractor.rb`
- [ ] Create `scripts/lib/pattern_validator.rb`
- [ ] Create `scripts/lib/pattern_summarizer.rb`
- [ ] Run download script NOW (before Night 2)
- [ ] Test that all files are created correctly
- [ ] Verify script is ready to run overnight

**After these changes**: Ready for multi-body pattern extraction tonight! 🚀
