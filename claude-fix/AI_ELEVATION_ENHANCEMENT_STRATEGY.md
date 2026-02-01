# AI Elevation Enhancement - Fix Sahara & Other Flat Regions

## 🎯 Problem Statement

**Current Issue**: 
- Civ4 maps have only 4 discrete elevation levels (PlotType: 0, 1, 2, 3)
- Large flat regions (Sahara, Great Plains, Amazon Basin) all get same elevation
- Results in unrealistic "sea-level" appearance for high-altitude deserts

**Example**: 
```
Sahara Desert in Civ4: PlotType=0 (flat) → elevation 0.4
Atlantic Ocean: PlotType=3 + TerrainType=Ocean → elevation 0.2
Visual difference: Only 0.2 (barely visible!)

Reality: Sahara ranges 200-3000m elevation
```

---

## 🔬 Three-Tier Enhancement Strategy

### Tier 1: Civ4 Maps (Sol System - Earth, Mars, Venus)
**Use Real DEM Data** - Most accurate

For Sol system planets, we can use actual elevation data:
- **Earth**: NASA SRTM (Shuttle Radar Topography Mission)
- **Mars**: MOLA (Mars Orbiter Laser Altimeter)
- **Moon**: LOLA (Lunar Orbiter Laser Altimeter)
- **Venus**: Magellan radar altimetry

**Implementation**:
```ruby
class Civ4ElevationEnhancer
  def enhance_with_real_dem(civ4_map, planet_name)
    case planet_name.downcase
    when 'earth'
      # Use SRTM 90m resolution data
      real_dem = load_srtm_data
      blend_civ4_with_real_dem(civ4_map, real_dem, weight: 0.7)
      
    when 'mars'
      # Use MOLA 1km resolution data
      real_dem = load_mola_data
      blend_civ4_with_real_dem(civ4_map, real_dem, weight: 0.6)
      
    else
      # No real DEM available - use Tier 2 or 3
      enhance_with_ai_inference(civ4_map)
    end
  end
  
  private
  
  def blend_civ4_with_real_dem(civ4_map, real_dem, weight:)
    # Scale real DEM to Civ4 map resolution
    scaled_dem = scale_dem_to_grid(real_dem, civ4_map.width, civ4_map.height)
    
    # Blend: keep Civ4 structure but add DEM detail
    civ4_map.elevation.each_with_index do |row, y|
      row.each_with_index do |civ4_elev, x|
        real_elev = scaled_dem[y][x]
        
        # Weighted blend: Civ4 provides structure, DEM provides detail
        enhanced = civ4_elev * (1 - weight) + real_elev * weight
        
        row[x] = enhanced
      end
    end
    
    civ4_map
  end
end
```

**Sources**:
- **SRTM**: https://www2.jpl.nasa.gov/srtm/ (90m resolution, global)
- **MOLA**: https://pds-geosciences.wustl.edu/missions/mgs/mola.html
- **LOLA**: https://ode.rsl.wustl.edu/moon/indexProductSearch.aspx

### Tier 2: Civ4 Maps (Procedural Planets)
**Use AI Biome-Aware Enhancement** - Good quality

For procedural planets without real DEM:

```ruby
class BiomeAwareElevationEnhancer
  # AI learns: "Deserts have varied elevation even if Civ4 marks them flat"
  def enhance_elevation(civ4_map, biome_map)
    enhanced = civ4_map.elevation.deep_dup
    
    civ4_map.elevation.each_with_index do |row, y|
      row.each_with_index do |base_elev, x|
        biome = biome_map[y][x]
        
        # Apply biome-specific enhancement
        variation = get_biome_elevation_variation(biome)
        noise = perlin_noise(x, y) * variation
        
        enhanced[y][x] = base_elev + noise
      end
    end
    
    normalize_elevation(enhanced)
  end
  
  private
  
  def get_biome_elevation_variation(biome)
    # Learned from Earth data: how much elevation varies by biome
    BIOME_VARIATION = {
      desert: 0.3,      # Deserts: HIGH variation (dunes, plateaus, mountains)
      grasslands: 0.1,  # Grasslands: LOW variation (truly flat)
      forest: 0.15,     # Forests: MEDIUM variation (hills)
      tundra: 0.2,      # Tundra: MEDIUM-HIGH (arctic mountains)
      ocean: 0.05,      # Ocean: LOW variation (mostly flat floor)
      mountains: 0.4    # Mountains: VERY HIGH (peaks and valleys)
    }
    
    BIOME_VARIATION[biome] || 0.1
  end
end
```

**How AI Learns This**:
```ruby
class BiomeElevationLearner
  def learn_from_earth_dem
    # Analyze Earth SRTM data by biome
    earth_dem = load_srtm_data
    earth_biomes = load_earth_biomes
    
    patterns = {}
    
    BIOMES.each do |biome|
      # Find all tiles of this biome
      biome_tiles = find_tiles_with_biome(earth_biomes, biome)
      
      # Get their elevation values from SRTM
      elevations = biome_tiles.map { |x, y| earth_dem[y][x] }
      
      # Calculate variation
      std_dev = standard_deviation(elevations)
      mean = elevations.sum / elevations.size.to_f
      
      patterns[biome] = {
        mean_elevation: mean,
        variation: std_dev,
        range: [elevations.min, elevations.max]
      }
    end
    
    # Save learned patterns
    save_biome_patterns(patterns)
  end
end
```

### Tier 3: FreeCiv Maps
**Use Constrained Perlin Noise** - Medium quality

FreeCiv maps have even LESS elevation data (only 'h' and 'm' markers), so:

```ruby
class FreecivElevationGenerator
  def generate_elevation(freeciv_map)
    # Already implemented in our system!
    # Uses multi-octave Perlin noise constrained to biome hints
    
    # Key insight: Add MORE variation to flat biomes
    base_noise = generate_perlin_noise(freeciv_map.width, freeciv_map.height)
    
    freeciv_map.biomes.each_with_index do |row, y|
      row.each_with_index do |biome, x|
        base = biome_to_elevation_hint(biome)
        noise = base_noise[y][x]
        
        # Desert gets MORE noise variation
        if biome == :desert
          noise *= 1.5  # 50% more variation
        end
        
        elevation = base * 0.4 + noise * 0.6
        row[x] = elevation
      end
    end
  end
end
```

---

## 🎨 Specific Fix for Sahara

### Problem Visualization:

```
Current (Civ4 raw):
Atlantic Ocean: ▁▁▁▁ (0.1-0.3)
Sahara Desert:  ▂▂▂▂ (0.4-0.5)  ← Looks almost ocean-level!
Atlas Mountains:████ (0.8-1.0)

Enhanced (with AI):
Atlantic Ocean: ▁▁▁▁ (0.1-0.3)
Sahara Desert:  ▃▅▆▄ (0.4-0.7)  ← NOW has variation!
Atlas Mountains:████ (0.8-1.0)
```

### Implementation:

```ruby
class SaharaElevationFix
  def fix_sahara_elevation(earth_map)
    # Identify Sahara region (roughly 15°N to 30°N, 15°W to 35°E)
    sahara_region = identify_sahara_tiles(earth_map)
    
    sahara_region.each do |x, y|
      current_elev = earth_map.elevation[y][x]
      
      # Sahara should be 0.5-0.7 range (higher than current 0.4-0.5)
      # Add Perlin noise for variation (dunes, plateaus)
      variation = perlin_noise(x, y, octaves: 3) * 0.3
      
      enhanced_elev = current_elev + 0.15 + variation
      
      # Clamp to reasonable range
      earth_map.elevation[y][x] = [0.4, [enhanced_elev, 0.75].min].max
    end
    
    earth_map
  end
  
  private
  
  def identify_sahara_tiles(earth_map)
    tiles = []
    
    earth_map.biomes.each_with_index do |row, y|
      row.each_with_index do |biome, x|
        # Sahara: desert biome in northern Africa
        lat = latitude_from_y(y, earth_map.height)
        lon = longitude_from_x(x, earth_map.width)
        
        if biome == :desert && 
           lat.between?(15, 30) && 
           lon.between?(-15, 35)
          tiles << [x, y]
        end
      end
    end
    
    tiles
  end
end
```

---

## 📊 Real DEM Data Integration (Earth)

### Option 1: SRTM 90m Data

**Format**: GeoTIFF or HGT files
**Coverage**: 56°S to 60°N (most inhabited areas)
**Resolution**: 90m (~3 arc-seconds)

**Processing**:
```ruby
require 'gdal'

class SRTMProcessor
  def load_and_scale(civ4_map)
    # Load SRTM tiles covering Earth
    srtm_tiles = load_srtm_tiles_for_earth
    
    # Mosaic into single global DEM
    global_dem = mosaic_tiles(srtm_tiles)
    
    # Scale to Civ4 resolution (180x90)
    scaled_dem = scale_dem(global_dem, 180, 90)
    
    # Normalize to 0-1 range
    normalize_elevation(scaled_dem)
  end
  
  private
  
  def scale_dem(dem, target_width, target_height)
    # Use bilinear interpolation to downsample
    source_width = dem.width
    source_height = dem.height
    
    scaled = Array.new(target_height) { Array.new(target_width) }
    
    target_height.times do |y|
      target_width.times do |x|
        # Map target pixel to source coordinates
        src_x = x * source_width / target_width.to_f
        src_y = y * source_height / target_height.to_f
        
        # Bilinear interpolation
        scaled[y][x] = bilinear_sample(dem, src_x, src_y)
      end
    end
    
    scaled
  end
end
```

### Option 2: Pre-processed Earth Elevation

**Simpler approach**: Use a pre-processed 180x90 elevation grid

**Source**: NASA Blue Marble or similar

```ruby
class EarthElevationLoader
  def load_preprocessed_elevation
    # Load from JSON or binary format
    elevation_file = Rails.root.join('data/elevation/earth_180x90.json')
    
    if File.exist?(elevation_file)
      JSON.parse(File.read(elevation_file))
    else
      # Download from public source
      download_earth_elevation
    end
  end
  
  private
  
  def download_earth_elevation
    # Could use NASA's Blue Marble
    # Or pre-process SRTM offline and ship with game
    url = 'https://example.com/earth_elevation_180x90.json'
    # ... download and cache
  end
end
```

---

## 🚀 Implementation Priority

### Phase 1: Quick Fix for Earth (Immediate)

```ruby
# In Civ4MapProcessor
def extract_elevation(civ4_data)
  base_elevation = extract_from_plottype(civ4_data)
  
  # QUICK FIX: Add variation to flat biomes
  civ4_data[:biomes].each_with_index do |row, y|
    row.each_with_index do |biome, x|
      if biome == :desert && base_elevation[y][x] < 0.5
        # Boost desert elevation and add variation
        variation = (rand * 0.3) - 0.15  # -0.15 to +0.15
        base_elevation[y][x] += 0.15 + variation
        base_elevation[y][x] = [base_elevation[y][x], 0.75].min  # Cap at 0.75
      end
    end
  end
  
  base_elevation
end
```

### Phase 2: Real DEM Integration (Earth, Mars, Luna)

1. Download SRTM/MOLA data
2. Pre-process to 180x90 grids
3. Ship with game or download on-demand
4. Blend with Civ4 structure (70% real, 30% Civ4)

### Phase 3: AI Learning System

1. Learn biome elevation patterns from Earth DEM
2. Apply to procedural planets
3. Store learned patterns in AI knowledge base
4. Use for all future Civ4 map processing

---

## 🧪 Testing the Fix

### Test 1: Sahara Elevation

**Before**:
```
Sahara tiles: elevation 0.40-0.50 (almost ocean level)
Visual: Dark brown (same as lowlands)
```

**After**:
```
Sahara tiles: elevation 0.50-0.70 (elevated desert plateau)
Visual: Medium-light brown (clearly above ocean)
```

### Test 2: Visual Comparison

**Create side-by-side**:
- Left: Raw Civ4 elevation
- Right: Enhanced elevation

Should see:
- Sahara becomes lighter (higher)
- Amazon Basin gets variation
- Great Plains still mostly flat (correct!)
- Mountains unchanged (already good)

---

## 📋 Implementation Checklist for Grok

### Immediate (Phase 1):

- [ ] Add desert elevation boost to Civ4MapProcessor
- [ ] Test on Earth - Sahara should be visibly higher
- [ ] Check other deserts (Gobi, Atacama, Australian Outback)
- [ ] Verify ocean remains at low elevation

### Short-term (Phase 2):

- [ ] Download SRTM 90m data for Earth
- [ ] Pre-process to 180x90 grid
- [ ] Implement blending function
- [ ] Test Earth with real DEM (should be much more accurate)

### Long-term (Phase 3):

- [ ] Implement BiomeElevationLearner
- [ ] Learn patterns from Earth SRTM
- [ ] Apply to procedural planet generation
- [ ] Add Mars MOLA data
- [ ] Add Luna LOLA data

---

## 🎯 Expected Results

### Earth Monitor After Fix:

```
Console:
Elevation range: { min: 0.05, max: 0.95, avg: 0.48 }

Visual:
- Atlantic Ocean: Very dark brown (0.1-0.2)
- Sahara Desert: Medium tan (0.5-0.7)  ← FIXED!
- Amazon Basin: Light brown with green overlay (0.3-0.5)
- Himalayas: White (0.85-1.0)
- Great Plains: Medium brown (0.4-0.5)
```

The Sahara will finally look like an elevated plateau instead of sea-level! 🏜️
