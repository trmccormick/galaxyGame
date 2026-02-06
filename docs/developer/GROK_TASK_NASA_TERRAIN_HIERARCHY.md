# Grok Task: Fix Terrain Data Source Hierarchy

## Status: IMPLEMENTED ✅

**Completed on 2026-02-06:**
- ✅ NASA-first hierarchy implemented for Earth (Priority 1)
- ✅ NASA-first hierarchy implemented for Mars, Luna, Venus, Mercury (Priority 1)
- ✅ Civ4 terrain generation method implemented (Priority 2)
- ✅ FreeCiv pattern generation method implemented (Priority 2b)
- ✅ Bathtub logic honors Civ4 water placement
- ✅ All Sol bodies now use NASA GeoTIFF as ground truth when available
- ✅ Tests passing: 12 examples, 0 failures

**Remaining Work:**
- Clean up monitor view to remove FreeCiv/Civ4 loading code
- Test Civ4/FreeCiv fallbacks with actual map files
- Validate bathtub logic with real hydrosphere data

## Problem Statement

The `AutomaticTerrainGenerator` currently uses **FreeCiv/Civ4 data as PRIMARY source** for Sol bodies, which produces fake elevation (279-322m uniform range). Real NASA GeoTIFF data exists but isn't being used.

## Required Data Source Hierarchy

### Priority 1: NASA GeoTIFF (Ground Truth)
**For:** Earth, Mars, Luna, Venus, Mercury, Titan (any body with real NASA data)

- **Source files:** `data/geotiff/processed/{body}_1800x900.tif`
- **Contains:** Real elevation data in meters
- **Example ranges:**
  - Earth: -9,625m to +6,042m
  - Mars: -8,200m to +21,229m (Olympus Mons)
  - Luna: -9,100m to +10,760m
- **Action:** Load GeoTIFF, downsample to grid size, store real elevation

### Priority 2: Civ4 Maps (Elevation + Land Shape)
**For:** Bodies WITH Civ4 maps but WITHOUT NASA data

- **Civ4 HAS elevation data** via `Civ4ElevationExtractor` (PlotType 0-3, TerrainType, FeatureType)
- **Problem:** Civ4 elevation is game-balanced, not realistic (bathtub issues)
- **Process:**
  1. Extract Civ4 elevation data (already 70-80% accurate for shape)
  2. **Honor existing water areas** - Civ4 PlotType=3 is water, keep as water
  3. Adjust elevation to work with bathtub logic (water fills to coverage %)
  4. AI Manager can help tweak heightmap generation from Civ4 patterns
- **Key insight:** Bathtub must honor Civ4's water placement, not override it
- **Example:** Mars Civ4 map → extract elevation + water → adjust ranges for Mars → bathtub fills additional areas to match coverage

### Priority 2b: FreeCiv Maps (Patterns Only - NO Elevation)
**For:** Bodies WITH FreeCiv maps but WITHOUT NASA data or Civ4 maps

- **FreeCiv has NO elevation data** - only terrain type characters (a,d,f,g,h,j,m,o,p,s,t)
- **Process:**
  1. Read terrain patterns (land types, water positions)
  2. Generate elevation that **conforms to bathtub logic**
  3. Water areas get low elevation, land gets higher
  4. AI Manager learns from NASA patterns to generate realistic heights
- **Example:** Earth FreeCiv → read pattern → generate elevation where bathtub fills oceans correctly

### Priority 3: AI-Generated (Procedural)
**For:** Bodies with NO maps (exoplanets, minor moons, etc.)

- **Uses:** Learned patterns from NASA data + FreeCiv/Civ4 map analysis
- **Based on:** Body type (rocky, icy, volcanic, oceanic, etc.)
- **Produces:** New but realistic terrain matching physical properties

## Current Bug Location

**File:** `galaxy_game/app/services/star_sim/automatic_terrain_generator.rb`

### Broken Method (line ~510)
```ruby
# Generate Earth terrain using FreeCiv/Civ4 map data as PRIMARY source  # <-- WRONG!
def generate_earth_terrain(body)
  # ... loads FreeCiv as primary
  elevation = generate_elevation_from_freeciv_structure(...)  # <-- FAKE ELEVATION
```

### What It Should Do
```ruby
def generate_earth_terrain(body)
  # Priority 1: NASA GeoTIFF
  if nasa_geotiff_available?('earth')
    return load_nasa_terrain('earth', body)
  end
  
  # Priority 2: Civ4 map (has elevation data, needs adjustment)
  if civ4_map_available?('earth')
    return generate_terrain_from_civ4('earth', body)
  end
  
  # Priority 2b: FreeCiv map (patterns only, generate elevation)
  if freeciv_map_available?('earth')
    return generate_terrain_from_freeciv_patterns('earth', body)
  end
  
  # Priority 3: AI-generated
  generate_procedural_terrain(body)
end
```

## Bathtub Logic Issue

**Current Problem:** Bathtub was overriding Civ4 water placement instead of honoring it.

**Required Behavior:**
1. If Civ4 map says PlotType=3 (water), it STAYS water
2. Bathtub fills ADDITIONAL areas to reach target coverage
3. Elevation must be adjusted so existing water is below sea level

```ruby
# Pseudocode for honoring Civ4 water
def adjust_elevation_for_bathtub(civ4_elevation, civ4_water_mask, target_coverage)
  # Ensure all Civ4 water areas are below sea level
  sea_level = calculate_sea_level_for_coverage(civ4_elevation, target_coverage)
  
  civ4_elevation.each_with_index do |row, y|
    row.each_with_index do |elev, x|
      if civ4_water_mask[y][x] == :water && elev >= sea_level
        # Push water areas below sea level
        civ4_elevation[y][x] = sea_level - 100  # Well below sea level
      end
    end
  end
  
  civ4_elevation
end
```

## Files to Modify

### 1. `app/services/star_sim/automatic_terrain_generator.rb`

**Add new method:** `load_nasa_terrain(body_name, celestial_body)`
```ruby
def load_nasa_terrain(body_name, celestial_body)
  geotiff_path = find_geotiff_path(body_name)
  return nil unless geotiff_path && File.exist?(geotiff_path)
  
  # Use existing GeoTIFFReader
  raw_data = GeoTIFFReader.read_elevation(geotiff_path)
  
  # Downsample to game grid size
  grid_dims = calculate_diameter_based_grid_size(celestial_body)
  elevation = downsample_elevation(raw_data[:elevation], grid_dims[:width], grid_dims[:height])
  
  {
    elevation: elevation,
    grid: nil,  # No biome grid from NASA - generate separately
    biomes: generate_biomes_from_elevation(elevation, celestial_body),
    generation_metadata: {
      source: 'nasa_geotiff',
      original_resolution: "#{raw_data[:width]}x#{raw_data[:height]}",
      game_resolution: "#{grid_dims[:width]}x#{grid_dims[:height]}",
      elevation_range: { min: elevation.flatten.min, max: elevation.flatten.max }
    }
  }
end

def find_geotiff_path(body_name)
  name = body_name.downcase
  name = 'luna' if name == 'moon'
  
  paths = [
    Rails.root.join('..', 'data', 'geotiff', 'processed', "#{name}_1800x900.tif"),
    Rails.root.join('..', 'data', 'geotiff', 'temp', "#{name}_900x450.tif")
  ]
  
  paths.find { |p| File.exist?(p) }
end

def nasa_geotiff_available?(body_name)
  find_geotiff_path(body_name).present?
end
```

**Add new method:** `generate_terrain_from_civ4(body_name, celestial_body)`
```ruby
# Use Civ4 map elevation data, adjusted for bathtub logic
def generate_terrain_from_civ4(body_name, celestial_body)
  # Load Civ4 data
  civ4_path = find_civ4_map(body_name)
  return nil unless civ4_path
  
  processor = Import::Civ4MapProcessor.new(civ4_path)
  civ4_data = processor.parse
  
  # Extract elevation using existing Civ4ElevationExtractor
  extractor = Import::Civ4ElevationExtractor.new
  elevation_data = extractor.extract(civ4_data)
  
  # Extract water mask from PlotType=3
  water_mask = extract_civ4_water_mask(civ4_data)
  
  # Get target water coverage for this body
  target_coverage = celestial_body.hydrosphere&.water_coverage || 0
  
  # Adjust elevation so:
  # 1. Civ4 water areas stay underwater
  # 2. Bathtub can fill additional areas to reach coverage
  adjusted_elevation = adjust_elevation_for_bathtub(
    elevation_data[:elevation], 
    water_mask, 
    target_coverage,
    celestial_body
  )
  
  {
    elevation: adjusted_elevation,
    biomes: generate_biomes_from_civ4(civ4_data, celestial_body),
    generation_metadata: {
      source: 'civ4_adjusted',
      civ4_map: civ4_path,
      bathtub_honored: true,
      water_coverage_target: target_coverage
    }
  }
end

def extract_civ4_water_mask(civ4_data)
  width = civ4_data[:width]
  height = civ4_data[:height]
  mask = Array.new(height) { Array.new(width, :land) }
  
  civ4_data[:plots].each do |plot|
    x, y = plot[:x], plot[:y]
    next if x >= width || y >= height
    
    # PlotType 3 = water in Civ4
    mask[y][x] = :water if plot[:plot_type] == 3
  end
  
  mask
end

def adjust_elevation_for_bathtub(elevation, water_mask, target_coverage, body)
  height = elevation.size
  width = elevation.first.size
  
  # Calculate sea level for target coverage
  flat = elevation.flatten.sort
  sea_level_idx = (flat.size * target_coverage).floor
  sea_level = flat[sea_level_idx] || flat.last
  
  # Ensure all Civ4 water is below sea level
  height.times do |y|
    width.times do |x|
      if water_mask[y][x] == :water && elevation[y][x] >= sea_level
        # Push water areas well below sea level
        elevation[y][x] = sea_level - 500  # 500m below sea level
      end
    end
  end
  
  elevation
end
```

**Add new method:** `generate_terrain_from_freeciv_patterns(body_name, celestial_body)`
```ruby
# FreeCiv has NO elevation - generate from patterns using AI Manager
def generate_terrain_from_freeciv_patterns(body_name, celestial_body)
  # Load FreeCiv pattern data
  processor = Import::FreecivMapProcessor.new
  freeciv_data = processor.load_map(body_name)
  return nil unless freeciv_data
  
  # Extract terrain pattern (land vs water)
  terrain_grid = freeciv_data[:grid]
  water_mask = extract_freeciv_water_mask(terrain_grid)
  
  # Use AI Manager to generate elevation that conforms to bathtub
  target_coverage = celestial_body.hydrosphere&.water_coverage || 0
  elevation = ai_generate_elevation_for_pattern(
    water_mask,
    target_coverage,
    celestial_body
  )
  
  {
    elevation: elevation,
    biomes: terrain_grid,  # FreeCiv terrain types become biomes
    generation_metadata: {
      source: 'freeciv_ai_generated',
      pattern_source: body_name,
      ai_elevation: true
    }
  }
end

def extract_freeciv_water_mask(terrain_grid)
  water_types = ['o', ' ', 'ocean', 'deep_sea', 'coast']  # FreeCiv water codes
  
  terrain_grid.map do |row|
    row.map { |cell| water_types.include?(cell.to_s.downcase) ? :water : :land }
  end
end
```

**Fix existing methods:**
- `generate_earth_terrain` → Use hierarchy
- `generate_mars_terrain` → Use hierarchy  
- `generate_luna_terrain` → Use hierarchy
- `generate_venus_terrain` → Use hierarchy
- `generate_mercury_terrain` → Use hierarchy

### 2. `app/views/admin/celestial_bodies/monitor.html.erb`

**Remove:** FreeCiv/Civ4 loading code from monitor view
- Lines referencing `freecivData`, `civ4Data` for elevation display
- Keep only for historical/debug purposes if needed

**The monitor should display:** Whatever is stored in `geosphere.terrain_map.elevation`

### 3. `lib/geotiff_reader.rb` (Existing - verify it works)

Already exists at `galaxy_game/lib/geotiff_reader.rb`. Verify:
- Can read `.tif` files from `data/geotiff/processed/`
- Returns proper elevation arrays
- Handles different resolutions

## Testing Commands

### 1. Verify GeoTIFF files exist
```bash
ls -la /Users/tam0013/Documents/git/galaxyGame/data/geotiff/processed/*.tif
```

### 2. Check GeoTIFF statistics
```bash
gdalinfo -stats data/geotiff/processed/earth_1800x900.tif | grep -E "Min|Max"
# Expected: Minimum=-9625, Maximum=6042
```

### 3. Test GeoTIFFReader in Rails
```bash
docker exec -it web bash -c 'rails runner "
require \"geotiff_reader\"
path = \"/home/galaxy_game/../data/geotiff/processed/earth_1800x900.tif\"
if File.exist?(path)
  data = GeoTIFFReader.read_elevation(path)
  flat = data[:elevation].flatten
  puts \"Size: #{data[:width]}x#{data[:height]}\"
  puts \"Elevation range: #{flat.min} to #{flat.max}\"
else
  puts \"File not found: #{path}\"
end
"'
```

### 4. After fixing, regenerate Earth terrain
```bash
docker exec -it web bash -c 'rails runner "
body = CelestialBodies::CelestialBody.find_by(name: \"Earth\")
body.geosphere.update!(terrain_map: nil)  # Clear old data
generator = StarSim::AutomaticTerrainGenerator.new
generator.generate_terrain_for_body(body)

# Verify new data
tm = body.reload.geosphere.terrain_map
flat = tm[\"elevation\"].flatten
puts \"Source: #{tm[\"generation_metadata\"][\"source\"]}\"
puts \"Elevation range: #{flat.min} to #{flat.max}\"
"'
```

### 5. Verify in monitor view
```bash
# Open browser: http://localhost:3000/admin/celestial_bodies/1/monitor
# Expected: Blue oceans, green/brown land, elevation range -9625m to +6042m
```

## Expected Outcomes

### Before Fix
```
Earth terrain keys: [...elevation...]
Elevation range: 279 to 322  ← FAKE (44 unique values)
Source: freeciv_primary
```

### After Fix
```
Earth terrain keys: [...elevation...]
Elevation range: -9625 to 6042  ← REAL NASA data
Source: nasa_geotiff
```

## Architecture Summary

```
Sol Body Terrain Generation
├── Has NASA GeoTIFF? ─────────────► Load real elevation data
│   (earth, mars, luna, etc.)         ↓
│                                   Downsample to grid size
│                                     ↓
│                                   Store in terrain_map
│
├── Has Civ4 map? ─────────────────► Extract Civ4 elevation (70-80% accurate)
│   (has elevation data!)              ↓
│                                   Extract water mask (PlotType=3)
│                                     ↓
│                                   Adjust elevation to honor water placement
│                                     ↓
│                                   Bathtub fills additional areas
│                                     ↓
│                                   Store in terrain_map
│
├── Has FreeCiv map? ──────────────► Extract terrain PATTERNS only (no elevation!)
│   (no elevation data)                ↓
│                                   AI Manager generates elevation
│                                     ↓
│                                   Elevation conforms to bathtub logic
│                                     ↓
│                                   Store in terrain_map
│
└── No maps available ─────────────► AI-generated procedural
    (exoplanets, minor moons)         ↓
                                    Use learned patterns from NASA + Civ4
                                      ↓
                                    Generate based on body type
                                      ↓
                                    Store in terrain_map
```

## Key Differences: Civ4 vs FreeCiv

| Aspect | Civ4 | FreeCiv |
|--------|------|---------|
| **Has elevation?** | YES (PlotType 0-3) | NO |
| **Extraction** | Use `Civ4ElevationExtractor` | Read terrain chars (a,d,f,g,h,j,m,o,p,s,t) |
| **Water detection** | PlotType=3 | Character 'o' or ' ' |
| **Elevation generation** | Adjust existing | AI generates from scratch |
| **Bathtub** | Honor existing water, fill more | Generate elevation that fills correctly |

## Reference Files

| File | Purpose |
|------|---------|
| `app/services/star_sim/automatic_terrain_generator.rb` | Main generator to fix |
| `lib/geotiff_reader.rb` | Existing GeoTIFF reader |
| `data/geotiff/processed/*.tif` | NASA elevation data |
| `app/views/admin/celestial_bodies/monitor.html.erb` | Display view to clean up |
| `docs/GUARDRAILS.md` | Architecture rules (§7.5) |

## Constraints

1. **All tests inside Docker container** with `unset DATABASE_URL`
2. **Atomic commits** - only changed files
3. **Don't break existing functionality** - fallbacks must work
4. **Bathtub must honor Civ4 water** - PlotType=3 stays water, fill additional
5. **FreeCiv = patterns only** - never use terrain codes as elevation
6. **NASA = ground truth** - always use if available

## Existing Code to Reuse

| File | What to Reuse |
|------|---------------|
| `lib/geotiff_reader.rb` | NASA GeoTIFF loading |
| `app/services/import/civ4_elevation_extractor.rb` | Civ4 elevation extraction |
| `app/services/import/civ4_map_processor.rb` | Civ4 file parsing |
| `app/services/import/freeciv_map_processor.rb` | FreeCiv file parsing |
| `app/services/terrain_analysis/hydrosphere_analyzer.rb` | Flood fill logic |
