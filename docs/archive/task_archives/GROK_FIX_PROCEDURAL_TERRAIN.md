# CRITICAL FIX: Procedural Terrain Generation Using NASA Patterns

## Problem Statement

**Current Issue:** Procedurally generated terrain for exoplanets (like AOL-732356) shows obvious grid patterns - "neat rows of impact craters" instead of realistic terrain.

**Root Cause:** `planetary_map_generator.rb` uses algorithmic sine waves when no NASA GeoTIFF exists:
```ruby
noise = Math.sin(x * 0.1) * Math.cos(y * 0.1) + rand * 0.5
```

This creates artificial-looking patterns instead of realistic barren worlds.

## Architecture Context

### What We Have (Working):

**NASA GeoTIFF Data (7 bodies):**
- Earth, Mars, Luna, Mercury, Venus, Titan, Vesta
- Location: `app/data/geotiff/processed/`
- **Purpose:** Ground truth elevation for Sol system bodies

**Pattern Files (7 bodies):**
- Location: `app/data/ai_manager/geotiff_patterns_*.json`
- **Purpose:** Extracted statistical patterns (crater density, elevation variance, terrain roughness)
- Created by: `scripts/lib/pattern_extractor.rb`

**Civ4/FreeCiv Maps:**
- Location: `app/data/maps/civ4/` and `app/data/maps/freeciv/`
- **Purpose:** Landmass shapes, continent/ocean patterns, biome placement
- Earth maps show realistic continent shapes

### What Doesn't Work:

**Procedural Generation for Exoplanets:**
- When a planet has NO GeoTIFF (most planets), the AI generates terrain procedurally
- Current method: sine wave patterns → creates grid artifacts
- **Missing:** Use of learned NASA patterns + Civ4 landmass shapes

## Game Design Intent

### For Sol System Bodies:
- Use **NASA GeoTIFF data** as ground truth (real elevation)
- Use **Civ4/FreeCiv maps** for biosphere overlay only (vegetation, settlements)
- Example: Earth uses real ETOPO 2022 elevations + Civ4 cities

### For Exoplanets (No Real Data):
- Use **Civ4/FreeCiv Earth maps** for realistic landmass SHAPES (continents, islands, ocean basins)
- Use **NASA pattern files** for realistic elevation VARIANCE and terrain characteristics
- Result: Continent-shaped barren worlds with Mars-like realistic terrain

### Example Workflow for AOL-732356 "Topaz":

**Planet Type:** Terrestrial (Venus-like, 331K, 22 bar CO2)
**Should Generate:**
1. Load Earth Civ4 map → Extract continent/ocean mask (where land vs water is)
2. Load `geotiff_patterns_mars.json` → Get barren terrain patterns (hot, volcanic)
3. Generate elevation:
   - Ocean areas: -3000m to 0m (varied depths)
   - Land areas: 0m to +8000m with Mars-like variance
   - Add crater patterns from Luna data
   - Add volcanic features from Venus data
4. Result: Realistic barren terrestrial world ready for terraforming

## Required Changes

### Step 1: Update Pattern Loader to Support Terrain Type Matching

**File:** `app/services/ai_manager/planetary_map_generator.rb`

Add method to select appropriate NASA patterns based on planet characteristics:

```ruby
def select_nasa_patterns_for_planet(planet)
  patterns = []
  
  # Temperature-based pattern selection
  temp = planet.surface_temperature
  
  if temp < 100
    # Icy world - use Titan patterns
    patterns << load_pattern_file('titan')
  elsif temp < 200
    # Cold/airless - use Luna patterns
    patterns << load_pattern_file('luna')
  elsif temp < 300
    # Temperate - use Earth + Mars patterns
    patterns << load_pattern_file('earth')
    patterns << load_pattern_file('mars')
  elsif temp < 400
    # Hot - use Venus patterns
    patterns << load_pattern_file('venus')
  else
    # Very hot/volcanic - use Venus + Mercury patterns
    patterns << load_pattern_file('venus')
    patterns << load_pattern_file('mercury')
  end
  
  # Combine patterns (average the statistics)
  combine_patterns(patterns)
end

def load_pattern_file(body_name)
  file_path = Rails.root.join('app/data/ai_manager', "geotiff_patterns_#{body_name}.json")
  
  return {} unless File.exist?(file_path)
  
  JSON.parse(File.read(file_path))
end

def combine_patterns(pattern_files)
  return {} if pattern_files.empty?
  
  # Average the statistical patterns
  combined = {
    'elevation_stats' => {},
    'crater_patterns' => {},
    'terrain_roughness' => {}
  }
  
  # Simple averaging of statistics
  # (Can be made more sophisticated later)
  pattern_files.each do |patterns|
    combined['elevation_stats']['mean'] ||= 0
    combined['elevation_stats']['mean'] += patterns.dig('elevation_stats', 'mean').to_f
    
    combined['elevation_stats']['variance'] ||= 0
    combined['elevation_stats']['variance'] += patterns.dig('elevation_stats', 'variance').to_f
    
    # Add other pattern combinations as needed
  end
  
  # Average by count
  count = pattern_files.size
  combined['elevation_stats']['mean'] /= count
  combined['elevation_stats']['variance'] /= count
  
  combined
end
```

### Step 2: Load Reference Landmass Shapes from Civ4/FreeCiv

Add method to extract continent/ocean patterns from Earth maps:

```ruby
def load_earth_landmass_reference(target_width: 80, target_height: 50)
  # Try Civ4 Earth map first
  civ4_path = Rails.root.join('app/data/maps/civ4/earth/Earth.Civ4WorldBuilderSave')
  
  if File.exist?(civ4_path)
    return extract_landmass_from_civ4(civ4_path, target_width, target_height)
  end
  
  # Fall back to FreeCiv Earth map
  freeciv_path = Rails.root.join('app/data/maps/freeciv/earth/earth-180x90-v1-3.sav')
  
  if File.exist?(freeciv_path)
    return extract_landmass_from_freeciv(freeciv_path, target_width, target_height)
  end
  
  # Last resort: generate simple landmass pattern
  Rails.logger.warn "No Earth reference maps found, using simple landmass generation"
  generate_simple_landmass(target_width, target_height)
end

def extract_landmass_from_civ4(file_path, width, height)
  # Read Civ4 file
  content = File.read(file_path)
  
  # Extract plot types (PlotType 0-3: peak/hills/plains/ocean)
  # We just need land (0,1,2) vs water (3) distinction
  landmass = []
  
  content.scan(/PlotType=(\d+)/).each do |plot_type|
    # 0,1,2 = land, 3 = ocean
    is_land = plot_type[0].to_i < 3
    landmass << is_land
  end
  
  # Reshape to 2D grid and resample to target size
  # (Simplified - implement proper resampling)
  landmass
end

def extract_landmass_from_freeciv(file_path, width, height)
  # Read FreeCiv .sav file
  content = File.read(file_path)
  
  # Extract terrain characters (t0="...", t1="...", etc.)
  terrain_lines = content.scan(/t\d+="([^"]+)"/).flatten
  
  landmass = []
  terrain_lines.each do |line|
    line.chars.each do |char|
      # FreeCiv terrain: ' ' or ':' = ocean, anything else = land
      is_land = ![' ', ':'].include?(char)
      landmass << is_land
    end
  end
  
  # Resample to target size
  # (Implement proper resampling)
  landmass
end

def generate_simple_landmass(width, height)
  # Fallback: create simple continent pattern using Perlin noise
  # (Better than sine waves, but not as good as real reference)
  landmass = []
  
  (0...height).each do |y|
    (0...width).each do |x|
      # Use Perlin-like noise for more natural landmass
      noise = perlin_noise(x * 0.1, y * 0.1)
      is_land = noise > 0.3  # 70% ocean, 30% land (Earth-like)
      landmass << is_land
    end
  end
  
  landmass
end

def perlin_noise(x, y)
  # Simplified Perlin noise implementation
  # (Use proper Perlin library in production)
  Math.sin(x) * Math.cos(y) + 
    Math.sin(x * 2.3) * Math.cos(y * 1.7) * 0.5 +
    Math.sin(x * 5.1) * Math.cos(y * 4.8) * 0.25
end
```

### Step 3: Generate Realistic Terrain Using Patterns + Landmass

Replace the sine wave generation with pattern-based generation:

```ruby
def generate_planetary_map_with_patterns(planet:, sources:, options: {})
  width = options[:width] || 80
  height = options[:height] || 50
  
  # Step 1: Get landmass reference (where continents should be)
  landmass_mask = load_earth_landmass_reference(target_width: width, target_height: height)
  
  # Step 2: Get NASA patterns for this planet type
  nasa_patterns = select_nasa_patterns_for_planet(planet)
  
  # Step 3: Generate elevation grid using patterns + landmass
  elevation_grid = generate_elevation_from_patterns(
    landmass_mask: landmass_mask,
    patterns: nasa_patterns,
    width: width,
    height: height
  )
  
  # Step 4: Generate biomes (barren by default, can be terraformed later)
  biome_grid = generate_barren_biomes(
    elevation_grid: elevation_grid,
    planet: planet
  )
  
  # Step 5: Add resource markers and strategic locations
  resources = generate_resource_locations(elevation_grid, planet)
  strategic_markers = generate_strategic_markers(elevation_grid, landmass_mask)
  
  {
    elevation: elevation_grid,
    biomes: biome_grid,
    resources: resources,
    strategic_markers: strategic_markers,
    metadata: {
      source: 'nasa_patterns_with_landmass',
      patterns_used: nasa_patterns.keys,
      generation_method: 'learned_from_nasa_data'
    }
  }
end

def generate_elevation_from_patterns(landmass_mask:, patterns:, width:, height:)
  elevation_grid = Array.new(height) { Array.new(width, 0) }
  
  # Get elevation statistics from patterns
  land_mean = patterns.dig('elevation_stats', 'mean') || 500
  land_variance = patterns.dig('elevation_stats', 'variance') || 800
  ocean_mean = -2000
  ocean_variance = 1000
  
  (0...height).each do |y|
    (0...width).each do |x|
      index = y * width + x
      is_land = landmass_mask[index]
      
      if is_land
        # Generate land elevation with realistic variance
        # Use Gaussian distribution around mean
        elevation = gaussian_random(land_mean, land_variance)
        
        # Clamp to realistic ranges
        elevation_grid[y][x] = elevation.clamp(-500, 8000)
      else
        # Generate ocean depth with variance
        depth = gaussian_random(ocean_mean, ocean_variance)
        elevation_grid[y][x] = depth.clamp(-11000, 0)
      end
    end
  end
  
  # Apply smoothing to remove sharp edges
  smooth_elevation_grid(elevation_grid)
end

def gaussian_random(mean, variance)
  # Box-Muller transform for Gaussian distribution
  u1 = rand
  u2 = rand
  
  z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math::PI * u2)
  
  mean + z * Math.sqrt(variance)
end

def smooth_elevation_grid(grid)
  # Apply 3x3 smoothing kernel to remove sharp transitions
  height = grid.size
  width = grid[0].size
  smoothed = Array.new(height) { Array.new(width, 0) }
  
  (0...height).each do |y|
    (0...width).each do |x|
      # Average with neighbors
      sum = 0
      count = 0
      
      (-1..1).each do |dy|
        (-1..1).each do |dx|
          ny = y + dy
          nx = x + dx
          
          if ny >= 0 && ny < height && nx >= 0 && nx < width
            sum += grid[ny][nx]
            count += 1
          end
        end
      end
      
      smoothed[y][x] = (sum / count.to_f).round
    end
  end
  
  smoothed
end

def generate_barren_biomes(elevation_grid:, planet:)
  # For barren worlds, biomes based on elevation only
  # (No vegetation, just terrain types)
  
  height = elevation_grid.size
  width = elevation_grid[0].size
  
  biome_grid = Array.new(height) { Array.new(width) }
  
  (0...height).each do |y|
    (0...width).each do |x|
      elev = elevation_grid[y][x]
      
      # Classify based on elevation
      biome_grid[y][x] = case elev
        when -Float::INFINITY..-2000 then 'deep_ocean'
        when -2000..0 then 'ocean'
        when 0..500 then 'plains'
        when 500..1500 then 'hills'
        when 1500..3000 then 'mountains'
        else 'high_mountains'
      end
    end
  end
  
  biome_grid
end
```

### Step 4: Update Main Terrain Generator to Use New Method

**File:** `app/services/star_sim/automatic_terrain_generator.rb`

Update `generate_base_terrain` to use the new pattern-based generation:

```ruby
def generate_base_terrain(celestial_body)
  body_name = celestial_body.name.downcase
  
  # Priority 1: NASA GeoTIFF (real data for Sol bodies)
  if nasa_geotiff_available?(body_name)
    Rails.logger.info "Using NASA GeoTIFF data for #{celestial_body.name}"
    return load_nasa_terrain(body_name, celestial_body)
  end
  
  # Priority 2: Pattern-based generation using learned data
  Rails.logger.info "Generating terrain for #{celestial_body.name} using NASA patterns"
  result = planetary_map_generator.generate_planetary_map_with_patterns(
    planet: celestial_body,
    sources: [],  # No specific sources, use learned patterns
    options: {
      width: 80,
      height: 50
    }
  )
  
  # Convert to standard format
  {
    elevation: result[:elevation],
    biomes: result[:biomes],
    resources: result[:resources] || [],
    strategic_markers: result[:strategic_markers] || [],
    generation_metadata: result[:metadata]
  }
end
```

## Testing Approach

**DO NOT write RSpec tests yet.** First verify the generation works:

### Manual Testing Steps:

1. **Test in Rails console:**
```ruby
# In container
docker exec -it web rails console

# Generate terrain for AOL-732356 planet
planet = CelestialBodies::CelestialBody.find_by(name: 'Topaz')
generator = StarSim::AutomaticTerrainGenerator.new
terrain = generator.generate_base_terrain(planet)

# Check results
puts "Elevation grid size: #{terrain[:elevation].size}x#{terrain[:elevation][0].size}"
puts "Elevation range: #{terrain[:elevation].flatten.min} to #{terrain[:elevation].flatten.max}"
puts "Biomes: #{terrain[:biomes].flatten.uniq}"
puts "Generation method: #{terrain[:generation_metadata][:generation_method]}"

# Verify it's NOT a grid pattern
# Check that adjacent cells have realistic variance
sample_x, sample_y = 10, 10
neighbors = [
  terrain[:elevation][sample_y][sample_x],
  terrain[:elevation][sample_y][sample_x + 1],
  terrain[:elevation][sample_y + 1][sample_x]
]
puts "Sample elevations (should vary naturally): #{neighbors.inspect}"
```

2. **View in monitor:**
```
Navigate to /admin/celestial_bodies/[topaz_id]/monitor
Toggle layers to see if terrain looks realistic
Should see: continent shapes, varied elevation, NO grid patterns
```

3. **Compare to Mars:**
```
View Mars in monitor
View Topaz in monitor
Topaz should look similarly barren but with different landmass shapes
```

## Success Criteria

- [ ] Pattern loading works for all 7 NASA bodies
- [ ] Landmass reference loads from Civ4/FreeCiv Earth maps
- [ ] Generated elevation shows realistic variance (not sine wave grid)
- [ ] Continents have recognizable shapes (not random noise)
- [ ] Ocean depths and land elevations in realistic ranges
- [ ] Monitor view shows smooth terrain (no neat rows of craters)
- [ ] Works for different planet types (hot/cold/temperate)

## What NOT to Do

- ❌ Don't write RSpec tests until generation works
- ❌ Don't try to make it perfect - get it working first
- ❌ Don't worry about performance optimization yet
- ❌ Don't try to handle every edge case

## What TO Do

- ✅ Get basic pattern-based generation working
- ✅ Use actual NASA pattern files we already have
- ✅ Use actual Civ4/FreeCiv maps we already have
- ✅ Test manually in Rails console first
- ✅ Verify in monitor view second
- ✅ Only then write tests

## Time Estimate

- Pattern loading logic: 1 hour
- Landmass extraction: 1.5 hours
- Pattern-based generation: 2 hours
- Integration with terrain generator: 1 hour
- Manual testing and fixes: 1.5 hours
- Total: 7 hours

This is the critical fix that makes procedurally generated exoplanets look realistic instead of artificial!
