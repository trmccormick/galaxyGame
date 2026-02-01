# Multi-Body-Type Training Data Strategy

## 🎯 The Problem You Identified

**Earth patterns don't work for everything!**

- ❌ Earth has erosion → Asteroids don't
- ❌ Earth has atmosphere → Moon doesn't (more craters!)
- ❌ Earth has water → Mars has different geology
- ❌ Earth is large → Small bodies have different tectonics

**One pattern set ≠ realistic variety**

---

## 🌍 Planetary Body Categories

### Category 1: Earth-Like (Terrestrial with Atmosphere & Water)
**Examples**: Earth, exoplanets in habitable zone
**Characteristics**:
- Active erosion (wind, water)
- Smooth terrain (weathering)
- Few visible craters (atmosphere protection)
- Active tectonics (mountains, valleys)
- Rivers, coastlines, vegetation

**Training Data Needed**:
- ✅ ETOPO Earth (already have from Night 1!)

---

### Category 2: Mars-Like (Terrestrial with Thin Atmosphere)
**Examples**: Mars, ancient dried planets
**Characteristics**:
- Moderate erosion (wind only)
- Mixed terrain (some craters, some weathering)
- Ancient river valleys (dried)
- Volcanic features (Olympus Mons)
- Polar ice caps
- Dust storms

**Training Data Available**:
- **MOLA Mars DEM** - Mars Orbiter Laser Altimeter
- **Source**: https://pds-geosciences.wustl.edu/missions/mgs/mola.html
- **Resolution**: 463m/pixel global
- **Size**: ~2GB full resolution, ~50MB resampled
- **Format**: IMG, convertible to GeoTIFF

**Download**:
```bash
# Mars global topography (463m/pixel)
wget https://planetarymaps.usgs.gov/mosaic/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif

# Or lower resolution for quick start
wget https://astrogeology.usgs.gov/search/map/Mars/Topography/HRSC_MOLA_Blend/Mars_HRSC_MOLA_BlendDEM_Global_200mp
```

---

### Category 3: Moon-Like (Airless, Heavily Cratered)
**Examples**: Luna, Mercury, Callisto, airless moons
**Characteristics**:
- NO erosion (no atmosphere)
- HEAVILY cratered (billions of years preserved)
- Sharp features (no weathering)
- Impact basins
- Ray systems (ejecta patterns)
- No rivers, no coastlines

**Training Data Available**:
- **LOLA Lunar DEM** - Lunar Orbiter Laser Altimeter
- **Source**: https://ode.rsl.wustl.edu/moon/indexProductSearch.aspx
- **Resolution**: 118m/pixel
- **Size**: ~3GB full, ~80MB resampled
- **Format**: GeoTIFF

**Download**:
```bash
# Lunar global DEM
wget https://planetarymaps.usgs.gov/mosaic/Lunar_LRO_LOLA_Global_LDEM_118m_Mar2014.tif
```

---

### Category 4: Asteroid-Like (Small Bodies, Low Gravity)
**Examples**: Ceres, Vesta, asteroids, small moons
**Characteristics**:
- Irregular shape (not spherical)
- Deep craters (low gravity, no rebound)
- No erosion (no atmosphere)
- Angular features
- Rubble pile texture
- Impact-dominated

**Training Data Available**:
- **Vesta Shape Model** - Dawn mission
- **Source**: https://sbn.psi.edu/pds/resource/dawn/dwnvshp.html
- **Resolution**: 93m/pixel
- **Size**: ~500MB
- **Format**: OBJ, IMG (convertible)

**Download**:
```bash
# Vesta shape model
wget https://sbnarchive.psi.edu/pds3/dawn/vesta/DWNVSHP_2/DATA/VTK/VESTA_SHAPE_HAMO_2012_07_18_512.VTK
```

---

### Category 5: Icy Bodies (Europa, Enceladus, Titan-like)
**Examples**: Europa, Enceladus, Titan, icy moons
**Characteristics**:
- Smooth ice surface (cryovolcanism)
- Linear features (ice cracks, faults)
- Few craters (resurfacing)
- Chaotic terrain
- Subsurface ocean signs

**Training Data Available**:
- **Europa Galileo DEM** - Limited coverage
- **Source**: https://astrogeology.usgs.gov/search/map/Europa
- **Resolution**: Varies (200m-1km)
- **Size**: ~100MB
- **Format**: GeoTIFF

---

### Category 6: Volcanic Bodies (Io-like)
**Examples**: Io, highly volcanic worlds
**Characteristics**:
- Active volcanism
- Lava flows
- Calderas
- NO craters (constant resurfacing)
- Colorful deposits (sulfur)

**Training Data Available**:
- **Io Voyager/Galileo mosaics**
- **Source**: https://astrogeology.usgs.gov/search/map/Io
- **Resolution**: ~1km/pixel
- **Size**: ~50MB
- **Format**: GeoTIFF

---

## 📊 Pattern Differences by Body Type

| Feature | Earth-like | Mars-like | Moon-like | Asteroid | Icy | Volcanic |
|---------|-----------|-----------|-----------|----------|-----|----------|
| Crater density | Very low | Moderate | Very high | Extreme | Low | None |
| Erosion | High | Low | None | None | None | High |
| Mountains | Tectonic | Volcanic | Impact rim | Irregular | None | Volcanic |
| Smooth areas | Common | Moderate | Maria only | None | Common | Recent flows |
| Linear features | Rivers | Dried channels | Fractures | Fault lines | Ice cracks | Rifts |

---

## 🎯 Recommended Download Strategy

### **Phase 1: Essential 3 (This Week)**

Download the most different body types:

```bash
# 1. Earth (DONE - Night 1)
# ✓ Already have ETOPO

# 2. Moon (Tonight - airless cratered)
wget https://planetarymaps.usgs.gov/mosaic/Lunar_LRO_LOLA_Global_LDEM_118m_Mar2014.tif \
    -O data/geotiff/raw/luna_lola.tif
gdalwarp -tr 0.2 0.2 -r bilinear data/geotiff/raw/luna_lola.tif \
    data/geotiff/processed/luna_1800x900.tif

# 3. Mars (Tomorrow - thin atmosphere)
wget https://planetarymaps.usgs.gov/mosaic/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif \
    -O data/geotiff/raw/mars_mola.tif
gdalwarp -tr 0.2 0.2 -r bilinear data/geotiff/raw/mars_mola.tif \
    data/geotiff/processed/mars_1800x900.tif
```

**Storage**: ~150MB raw, ~50MB processed, ~2MB patterns
**Covers**: 90% of common planet types

---

### **Phase 2: Special Cases (Next Week)**

```bash
# 4. Vesta (asteroid type)
# Download from Dawn mission archive

# 5. Europa (icy moon type)
# Download from Galileo archive
```

**Storage**: +100MB
**Covers**: Exotic body types

---

## 🔧 Modified Night 2 Script - Multi-Body Support

```bash
#!/bin/bash
# scripts/night2_multi_body_patterns.sh

echo "=== NIGHT 2: Multi-Body Pattern Extraction ==="

# Extract patterns for each body type
echo "Processing Earth patterns..."
bundle exec rails runner scripts/extract_patterns.rb earth data/geotiff/processed/earth_1800x900.asc.gz

echo "Processing Moon patterns..."
bundle exec rails runner scripts/extract_patterns.rb luna data/geotiff/processed/luna_1800x900.tif

echo "Processing Mars patterns..."
bundle exec rails runner scripts/extract_patterns.rb mars data/geotiff/processed/mars_1800x900.tif

echo "✓ All body types processed"
```

### Updated Ruby Script:

```ruby
# scripts/extract_patterns.rb
# Usage: rails runner scripts/extract_patterns.rb <body_type> <dem_file>

body_type = ARGV[0]  # 'earth', 'luna', 'mars'
dem_file = ARGV[1]

puts "=== Extracting #{body_type.upcase} Patterns ==="

# Load elevation data
elevation_data = load_elevation(dem_file)

# Extract patterns specific to body type
patterns = case body_type
           when 'earth'
             extract_earth_patterns(elevation_data)
           when 'luna'
             extract_lunar_patterns(elevation_data)
           when 'mars'
             extract_mars_patterns(elevation_data)
           else
             extract_generic_patterns(elevation_data)
           end

# Save to separate file
output_file = Rails.root.join("app/data/ai_manager/geotiff_patterns_#{body_type}.json")
File.write(output_file, JSON.pretty_generate(patterns))

puts "✓ #{body_type} patterns saved to #{output_file}"

# Pattern extraction methods

def extract_earth_patterns(data)
  {
    body_type: 'terrestrial_earth_like',
    characteristics: {
      erosion_level: 'high',
      atmosphere: 'thick',
      crater_density: 'very_low',
      features: ['rivers', 'coastlines', 'mountains', 'valleys']
    },
    patterns: {
      elevation: extract_elevation_distribution(data),
      coastlines: extract_coastline_patterns(data),
      mountains: extract_mountain_chains(data),
      rivers: extract_river_networks(data),
      erosion: extract_erosion_patterns(data)
    }
  }
end

def extract_lunar_patterns(data)
  {
    body_type: 'airless_cratered',
    characteristics: {
      erosion_level: 'none',
      atmosphere: 'none',
      crater_density: 'very_high',
      features: ['craters', 'maria', 'highlands', 'rays']
    },
    patterns: {
      elevation: extract_elevation_distribution(data),
      craters: extract_crater_patterns(data),
      maria: extract_smooth_regions(data),
      highlands: extract_rough_regions(data),
      impact_basins: extract_large_craters(data)
    }
  }
end

def extract_mars_patterns(data)
  {
    body_type: 'terrestrial_thin_atmosphere',
    characteristics: {
      erosion_level: 'moderate',
      atmosphere: 'thin',
      crater_density: 'moderate',
      features: ['ancient_rivers', 'volcanoes', 'craters', 'polar_caps']
    },
    patterns: {
      elevation: extract_elevation_distribution(data),
      volcanoes: extract_volcanic_features(data),
      ancient_channels: extract_dried_rivers(data),
      craters: extract_crater_patterns(data),
      dichotomy: extract_hemispheric_difference(data)
    }
  }
end

def extract_crater_patterns(data)
  # Detect circular depressions (craters)
  craters = detect_circular_features(data)
  
  {
    crater_count: craters.size,
    size_distribution: calculate_crater_size_dist(craters),
    density: craters.size / (data[:width] * data[:height]).to_f,
    clustering: measure_crater_clustering(craters),
    depth_to_diameter_ratio: calculate_depth_diameter_ratio(craters, data)
  }
end

def detect_circular_features(data)
  # Simplified crater detection
  # Real implementation would use Hough transform or similar
  
  potential_craters = []
  
  # Look for local minima surrounded by higher elevation
  (5...data[:height]-5).each do |y|
    (5...data[:width]-5).each do |x|
      center_elev = data[:data][y][x]
      
      # Check if this is a local minimum
      is_minimum = true
      ring_elevations = []
      
      # Check surrounding ring
      8.times do |i|
        angle = i * Math::PI / 4
        rx = x + (5 * Math.cos(angle)).round
        ry = y + (5 * Math.sin(angle)).round
        
        next if rx < 0 || rx >= data[:width] || ry < 0 || ry >= data[:height]
        
        ring_elev = data[:data][ry][rx]
        ring_elevations << ring_elev
        
        is_minimum = false if ring_elev < center_elev
      end
      
      # If local minimum with raised rim, likely a crater
      if is_minimum && ring_elevations.any? { |e| e > center_elev + 0.05 }
        potential_craters << {
          x: x,
          y: y,
          depth: ring_elevations.max - center_elev,
          diameter: 10  # Approximate
        }
      end
    end
  end
  
  potential_craters
end
```

---

## 🎮 How to Use Multi-Body Patterns

### In PlanetaryMapGenerator:

```ruby
class PlanetaryMapGenerator
  def generate_planet_map(planet:, sources:, options: {})
    # Determine body type
    body_type = classify_planet_type(planet)
    
    # Load appropriate patterns
    patterns = load_patterns_for_type(body_type)
    
    # Generate using type-specific patterns
    case body_type
    when :earth_like
      generate_earth_like_terrain(planet, patterns)
    when :moon_like
      generate_cratered_terrain(planet, patterns)
    when :mars_like
      generate_mars_like_terrain(planet, patterns)
    end
  end
  
  private
  
  def classify_planet_type(planet)
    # Decision tree based on planet properties
    
    if planet.atmosphere&.pressure > 0.5
      # Thick atmosphere = Earth-like
      :earth_like
      
    elsif planet.atmosphere&.pressure > 0.01
      # Thin atmosphere = Mars-like
      :mars_like
      
    elsif planet.radius < 2_000_000  # < 2000km
      # Small + no atmosphere = asteroid-like
      :asteroid_like
      
    elsif planet.surface_temperature < 150
      # Cold + no atmosphere = icy moon
      :icy_moon
      
    else
      # No atmosphere, not small, not cold = Moon-like
      :moon_like
    end
  end
  
  def load_patterns_for_type(body_type)
    pattern_files = {
      earth_like: 'geotiff_patterns_earth.json',
      mars_like: 'geotiff_patterns_mars.json',
      moon_like: 'geotiff_patterns_luna.json',
      asteroid_like: 'geotiff_patterns_vesta.json',
      icy_moon: 'geotiff_patterns_europa.json'
    }
    
    file = Rails.root.join('app/data/ai_manager', pattern_files[body_type])
    
    if File.exist?(file)
      JSON.parse(File.read(file))
    else
      Rails.logger.warn "Pattern file not found for #{body_type}, using default"
      load_default_patterns
    end
  end
  
  def generate_cratered_terrain(planet, patterns)
    # Use lunar patterns for heavily cratered bodies
    
    # Base elevation
    elevation = generate_base_elevation(planet)
    
    # Add craters based on learned patterns
    crater_density = patterns.dig('patterns', 'craters', 'density') || 0.05
    add_craters_to_terrain(elevation, crater_density, patterns)
    
    elevation
  end
  
  def add_craters_to_terrain(elevation, density, patterns)
    height = elevation.size
    width = elevation[0].size
    
    crater_count = (width * height * density).to_i
    
    # Get size distribution from patterns
    size_dist = patterns.dig('patterns', 'craters', 'size_distribution') || {}
    
    crater_count.times do
      # Random location
      x = rand(width)
      y = rand(height)
      
      # Random size from learned distribution
      diameter = sample_from_distribution(size_dist)
      depth = diameter * 0.2  # Depth/diameter ratio from patterns
      
      # Carve crater
      carve_crater(elevation, x, y, diameter, depth)
    end
  end
end
```

---

## 📋 Recommended Overnight Schedule

### **Tonight (Night 2)**: Download Luna + Mars

```bash
# Before bed
./scripts/download_luna_mars.sh  # Downloads ~150MB
./scripts/process_luna_mars.sh   # Processes overnight
./scripts/extract_multi_body_patterns.sh  # Extracts patterns
```

### **Tomorrow**: Have Earth + Luna + Mars patterns

**Result**: Can generate:
- ✅ Earth-like planets (erosion, rivers, coastlines)
- ✅ Airless moons (heavy craters, no erosion)
- ✅ Mars-like planets (moderate craters, ancient rivers)

**Covers**: ~90% of celestial bodies in your game!

---

## 🎯 Final Pattern Library

```
app/data/ai_manager/
├── geotiff_patterns_earth.json   (~800KB) - Earth-like
├── geotiff_patterns_luna.json    (~500KB) - Airless cratered
├── geotiff_patterns_mars.json    (~600KB) - Thin atmosphere
├── geotiff_patterns_vesta.json   (~300KB) - Asteroid (optional)
└── geotiff_patterns_europa.json  (~400KB) - Icy moon (optional)

Total: ~2-3MB (with optional bodies ~3-4MB)
```

Still tiny for Git! And covers ALL planet types! 🎯

This is way better than one-size-fits-all! 🚀
