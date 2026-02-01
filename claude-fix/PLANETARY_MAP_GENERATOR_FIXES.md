# PlanetaryMapGenerator Analysis - Complete Fix Guide

## Overview

The `PlanetaryMapGenerator` is the core map generation service called by MapStudioController. It's simpler than EarthMapGenerator but has similar data structure issues.

## Current Flow

```
MapStudioController
  ↓
prepare_map_sources (processes Civ4/FreeCiv maps)
  ↓
PlanetaryMapGenerator.generate_planetary_map
  ↓
combine_source_maps OR generate_procedural_map
  ↓
Returns JSON structure
```

## Identified Issues

### Issue 1: Data Structure Access (Same as EarthMapGenerator) ⚠️

**Current Code** (Line 45-50):
```ruby
def combine_source_maps(sources, planet, options)
  base_source = sources.first
  base_data = base_source[:data]

  width = base_data.dig(:lithosphere, :width) || 80
  height = base_data.dig(:lithosphere, :height) || 50
```

**Problem**: Assumes specific nested structure

**Actual Structure from Processors**:
```ruby
# FreecivMapProcessor returns:
{
  lithosphere: {
    elevation: [[0.1, 0.2, ...], ...],
    method: 'freeciv_perlin_constrained',
    quality: 'medium_60_70_percent'
    # NO width/height here!
  },
  biomes: [[:grasslands, :ocean, ...], ...],
  width: 180,   # ← At root level!
  height: 90    # ← At root level!
}

# Civ4MapProcessor returns similar
```

**Fix**:
```ruby
def combine_source_maps(sources, planet, options)
  base_source = sources.first
  base_data = base_source[:data]

  # Width/height are at root level, not in lithosphere
  width = base_data[:width] || 
          base_data.dig(:lithosphere, :width) || 
          base_data[:biomes]&.first&.size || 
          80
          
  height = base_data[:height] || 
           base_data.dig(:lithosphere, :height) || 
           base_data[:biomes]&.size || 
           50
```

### Issue 2: Sources Already Have Processed Data ⚠️

**Same issue as EarthMapGenerator!**

**MapStudioController** (line 252-269):
```ruby
sources << {
  type: type.to_sym,
  filename: filename,
  path: file_path,
  data: map_data  # ← ALREADY PROCESSED!
}
```

**PlanetaryMapGenerator** (line 58-63):
```ruby
sources.each_with_index do |source, index|
  source_data = source[:data]  # ← Good! Uses existing data

  if source_data[:biomes].is_a?(Array)
    source_biomes = source_data[:biomes]
    source_elevation = source_data.dig(:lithosphere, :elevation)
    # ...
  end
end
```

**Analysis**: ✅ This is CORRECT! It uses `source[:data]` properly.

**But**: It should validate the data exists and is correct type.

**Fix**: Add validation
```ruby
sources.each_with_index do |source, index|
  source_data = source[:data]
  
  # Validate source data
  unless source_data.is_a?(Hash)
    Rails.logger.warn "[PlanetaryMapGenerator] Invalid source data for #{source[:filename]}"
    next
  end

  # Extract biomes and elevation from source
  source_biomes = source_data[:biomes]
  source_elevation = source_data.dig(:lithosphere, :elevation)
  
  unless source_biomes.is_a?(Array) && source_biomes.any?
    Rails.logger.warn "[PlanetaryMapGenerator] No biomes in source #{source[:filename]}"
    next
  end

  # Apply source data to combined grid
  apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, index, sources.size)
end
```

### Issue 3: Grid Size Mismatch in apply_source_to_grid ⚠️

**Current Code** (Line 94-112):
```ruby
def apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, source_index, total_sources)
  height = terrain_grid.size
  width = terrain_grid.first.size

  # Apply with some offset/variation based on source index
  offset_x = (source_index * width / total_sources) % width
  offset_y = (source_index * height / total_sources) % height

  source_biomes.each_with_index do |row, y|
    next unless row.is_a?(Array)
    row.each_with_index do |biome, x|
      target_y = (y + offset_y) % height
      target_x = (x + offset_x) % width
      
      terrain_grid[target_y][target_x] = biome
      
      # Apply elevation if available
      if source_elevation && source_elevation[y] && source_elevation[y][x]
        elevation_grid[target_y][target_x] = source_elevation[y][x]
      end
    end
  end
end
```

**Problem**: If source map is different size than target grid, indices can be wrong!

**Example**:
- Target grid: 80x50
- Source map: 180x90
- Loop goes to y=89, x=179
- But after offset and modulo, might still be valid
- **HOWEVER**: Source map is BIGGER so some data is lost!

**Better Approach**: Scale source to fit target
```ruby
def apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, source_index, total_sources)
  target_height = terrain_grid.size
  target_width = terrain_grid.first.size
  
  source_height = source_biomes.size
  source_width = source_biomes.first&.size || 0
  
  return if source_height == 0 || source_width == 0
  
  Rails.logger.info "[PlanetaryMapGenerator] Applying #{source_width}x#{source_height} source to #{target_width}x#{target_height} grid"

  # Calculate scaling factors
  scale_x = source_width.to_f / target_width
  scale_y = source_height.to_f / target_height

  # Apply to each cell in target grid
  target_height.times do |target_y|
    target_width.times do |target_x|
      # Find corresponding source cell
      source_y = (target_y * scale_y).to_i
      source_x = (target_x * scale_x).to_i
      
      # Bounds check
      next if source_y >= source_height || source_x >= source_width
      
      row = source_biomes[source_y]
      next unless row.is_a?(Array) && source_x < row.size
      
      biome = row[source_x]
      
      # Blend biomes (prefer first source, blend others with probability)
      if source_index == 0 || rand < 0.7
        terrain_grid[target_y][target_x] = biome if biome
      end
      
      # Apply elevation if available
      if source_elevation && 
         source_elevation[source_y] && 
         source_elevation[source_y][source_x]
        elevation_grid[target_y][target_x] = source_elevation[source_y][source_x]
      end
    end
  end
end
```

### Issue 4: Return Structure Inconsistency ⚠️

**Current Code** (Line 22-37):
```ruby
def generate_planetary_map(planet:, sources:, options: {})
  # ...
  return {
    terrain_grid: combined_data[:terrain_grid],
    biome_counts: combined_data[:biome_counts],
    elevation_data: combined_data[:elevation_data],
    strategic_markers: combined_data[:strategic_markers],
    planet_name: planet.name,
    planet_type: planet.type,
    metadata: { ... }
  }
end
```

**Compared to generate_procedural_map** (Line 157-169):
```ruby
def generate_procedural_map(planet, options)
  return {
    terrain_grid: terrain_grid,
    biome_counts: biome_counts,
    elevation_data: Array.new(height) { Array.new(width, 0.5) },
    strategic_markers: [],
    planet_name: planet.name,
    planet_type: planet.type,
    metadata: { ... }
  }
end
```

**Analysis**: ✅ Both return same structure - GOOD!

**But**: MapStudioController expects this to save directly to JSON

**Check saved JSON** (earth_20260128_221726.json):
```json
{
  "terrain_grid": [["p", "p", "f", ...], ...],
  "biome_counts": {...},
  "elevation_data": [[0.5, 0.5, ...], ...],  // ← Not used in monitor!
  "strategic_markers": [],
  "planet_name": "Earth",
  "planet_type": "...",
  "metadata": {...}
}
```

**Monitor expects** (from our earlier work):
```javascript
const terrainData = {
  elevation: [[0.1, 0.2, ...], ...],  // ← Different name!
  terrain: [["plains", "ocean", ...], ...],
  biomes: [["grasslands", "desert", ...], ...]
}
```

**MAJOR MISMATCH!** 🔴

### Issue 5: Data Format for Monitor Display ⚠️

**Generator outputs**:
- `terrain_grid` - Array of biome codes ('p', 'g', 'f', 'd', etc.)
- `elevation_data` - Array of elevation values
- `biome_counts` - Hash of counts

**Monitor expects**:
- `elevation` - Array of elevation values ✅ (but wrong name)
- `terrain` - Array of terrain types (not biome codes)
- `biomes` - Array of biome types

**Fix**: Transform output for monitor compatibility
```ruby
def generate_planetary_map(planet:, sources:, options: {})
  # ... existing code ...
  
  combined_data = if sources.empty?
                    generate_procedural_map(planet, options)
                  else
                    combined_data = combine_source_maps(sources, planet, options)
                  end

  # Transform to monitor-compatible format
  {
    # For JSON storage (original format)
    terrain_grid: combined_data[:terrain_grid],
    biome_counts: combined_data[:biome_counts],
    elevation_data: combined_data[:elevation_data],
    
    # ALSO include monitor-compatible format
    elevation: combined_data[:elevation_data],  # Alias for monitor
    terrain: combined_data[:terrain_grid],      # Same as biomes for now
    biomes: combined_data[:terrain_grid],       # Biome codes
    
    strategic_markers: combined_data[:strategic_markers],
    planet_name: planet.name,
    planet_type: planet.type,
    metadata: {
      generated_at: Time.current.iso8601,
      source_maps: sources.map { |s| { type: s[:type], filename: s[:filename] } },
      generation_options: options,
      width: combined_data[:width],
      height: combined_data[:height],
      quality: combined_data[:quality],
      planet_name: planet.name,
      planet_type: planet.type,
      planet_id: planet.id
    }
  }
end
```

### Issue 6: Biome Code Translation Missing ⚠️

**Current Code**: Uses single-character codes
```ruby
terrain_grid = [
  ['p', 'p', 'f', 'g', 'o', ...],
  ['d', 'f', 'p', 'g', 'o', ...],
  ...
]
```

**Problem**: Monitor might expect full names or symbols

**From FreeCiv/Civ4 processors**:
```ruby
# FreeCiv returns symbols:
biomes: [[:grasslands, :plains, :forest, :ocean, ...], ...]

# But these are converted to codes somewhere?
```

**Need to check**: Are biomes already in correct format from processors?

**If not, add translation**:
```ruby
BIOME_CODE_MAP = {
  :ocean => 'o',
  :deep_sea => 'o',
  :grasslands => 'g',
  :plains => 'p',
  :forest => 'f',
  :desert => 'd',
  :tundra => 't',
  :arctic => 'a',
  :swamp => 's',
  :jungle => 'j',
  :boreal => 'f',
  :rocky => 'r',
  :mountains => 'm',
  :hills => 'h'
}.freeze

def convert_biome_to_code(biome)
  BIOME_CODE_MAP[biome] || 'p'  # Default to plains
end
```

## Complete Fixed Version

### Fixed combine_source_maps:

```ruby
def combine_source_maps(sources, planet, options)
  Rails.logger.info "[PlanetaryMapGenerator] Combining #{sources.size} source maps"

  # Validate we have sources
  if sources.empty?
    raise "No sources provided to combine_source_maps"
  end

  # Use the first source as base
  base_source = sources.first
  base_data = base_source[:data]

  # Get dimensions (check multiple locations)
  width = options[:width] ||
          base_data[:width] || 
          base_data.dig(:lithosphere, :width) || 
          base_data[:biomes]&.first&.size || 
          80
          
  height = options[:height] ||
           base_data[:height] || 
           base_data.dig(:lithosphere, :height) || 
           base_data[:biomes]&.size || 
           50

  Rails.logger.info "[PlanetaryMapGenerator] Target dimensions: #{width}x#{height}"

  # Initialize combined grid
  terrain_grid = Array.new(height) { Array.new(width, 'p') } # default to plains
  elevation_grid = Array.new(height) { Array.new(width, 0.5) }
  biome_counts = Hash.new(0)

  # Process each source map
  valid_sources = 0
  
  sources.each_with_index do |source, index|
    source_data = source[:data]
    
    unless source_data.is_a?(Hash)
      Rails.logger.warn "[PlanetaryMapGenerator] Invalid source data for #{source[:filename]}"
      next
    end

    # Extract biomes and elevation from source
    source_biomes = source_data[:biomes]
    source_elevation = source_data.dig(:lithosphere, :elevation)
    
    unless source_biomes.is_a?(Array) && source_biomes.any?
      Rails.logger.warn "[PlanetaryMapGenerator] No biomes in source #{source[:filename]}"
      next
    end

    # Apply source data to combined grid
    apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, index, sources.size)
    valid_sources += 1
  end

  if valid_sources == 0
    Rails.logger.warn "[PlanetaryMapGenerator] No valid sources processed, using procedural fallback"
    return generate_procedural_map(planet, options.merge(width: width, height: height))
  end

  # Count biomes
  terrain_grid.flatten.compact.each { |biome| biome_counts[biome] += 1 }

  # Extract strategic markers
  strategic_markers = extract_strategic_markers(terrain_grid)

  {
    terrain_grid: terrain_grid,
    elevation_data: elevation_grid,
    biome_counts: biome_counts,
    strategic_markers: strategic_markers,
    width: width,
    height: height,
    quality: "combined_from_#{valid_sources}_sources"
  }
end
```

### Fixed apply_source_to_grid:

```ruby
def apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, source_index, total_sources)
  return unless source_biomes.is_a?(Array)

  target_height = terrain_grid.size
  target_width = terrain_grid.first.size
  
  source_height = source_biomes.size
  source_width = source_biomes.first&.size || 0
  
  if source_height == 0 || source_width == 0
    Rails.logger.warn "[PlanetaryMapGenerator] Source has invalid dimensions"
    return
  end
  
  Rails.logger.info "[PlanetaryMapGenerator] Scaling #{source_width}x#{source_height} → #{target_width}x#{target_height}"

  # Calculate scaling factors
  scale_x = source_width.to_f / target_width
  scale_y = source_height.to_f / target_height

  # Apply to each cell in target grid
  target_height.times do |target_y|
    target_width.times do |target_x|
      # Find corresponding source cell (scaled)
      source_y = (target_y * scale_y).to_i
      source_x = (target_x * scale_x).to_i
      
      # Bounds check
      next if source_y >= source_height || source_x >= source_width
      
      row = source_biomes[source_y]
      next unless row.is_a?(Array) && source_x < row.size
      
      biome = row[source_x]
      
      # Convert biome to code if it's a symbol
      biome_code = biome.is_a?(Symbol) ? convert_biome_to_code(biome) : biome
      
      # Blend biomes (prefer first source, blend others with probability)
      if source_index == 0 || rand < 0.7
        terrain_grid[target_y][target_x] = biome_code if biome_code
      end
      
      # Apply elevation if available
      if source_elevation && 
         source_elevation.is_a?(Array) &&
         source_elevation[source_y].is_a?(Array) &&
         source_elevation[source_y][source_x]
        elevation_grid[target_y][target_x] = source_elevation[source_y][source_x]
      end
    end
  end
end

BIOME_CODE_MAP = {
  ocean: 'o',
  deep_sea: 'o',
  grasslands: 'g',
  plains: 'p',
  forest: 'f',
  desert: 'd',
  tundra: 't',
  arctic: 'a',
  swamp: 's',
  jungle: 'j',
  boreal: 'f',
  rocky: 'r',
  mountains: 'm',
  hills: 'h'
}.freeze

def convert_biome_to_code(biome)
  BIOME_CODE_MAP[biome] || 'p'  # Default to plains
end
```

### Fixed generate_planetary_map:

```ruby
def generate_planetary_map(planet:, sources:, options: {})
  Rails.logger.info "[PlanetaryMapGenerator] Generating map for #{planet.name} using #{sources.size} source maps"

  # Generate combined data
  combined_data = if sources.empty?
                    Rails.logger.info "[PlanetaryMapGenerator] No sources, using procedural generation"
                    generate_procedural_map(planet, options)
                  else
                    combine_source_maps(sources, planet, options)
                  end

  # Return comprehensive map data structure
  # Include BOTH old format (terrain_grid) and new format (elevation, biomes) for compatibility
  {
    # Original format (for JSON storage)
    terrain_grid: combined_data[:terrain_grid],
    biome_counts: combined_data[:biome_counts],
    elevation_data: combined_data[:elevation_data],
    strategic_markers: combined_data[:strategic_markers],
    
    # Monitor-compatible format (aliases)
    elevation: combined_data[:elevation_data],  # Monitor expects this name
    terrain: combined_data[:terrain_grid],      # Could be different from biomes later
    biomes: combined_data[:terrain_grid],       # Same for now
    
    # Planet info
    planet_name: planet.name,
    planet_type: planet.type,
    
    # Metadata
    metadata: {
      generated_at: Time.current.iso8601,
      source_maps: sources.map { |s| { type: s[:type], filename: s[:filename] } },
      generation_options: options,
      width: combined_data[:width],
      height: combined_data[:height],
      quality: combined_data[:quality],
      planet_name: planet.name,
      planet_type: planet.type,
      planet_id: planet.id
    }
  }
end
```

## Summary - All Three Files Together

### The Complete Generation Flow:

```
1. User selects planet + source maps in Map Studio UI

2. MapStudioController.generate_map
   ↓
   - Reads params (FIX: Accept both :selected_maps and :source_map_ids)
   - Calls prepare_map_sources
   ↓
   - prepare_map_sources processes each map with FreecivMapProcessor/Civ4MapProcessor
   - Returns sources array with :data field populated
   
3. Calls PlanetaryMapGenerator.generate_planetary_map
   ↓
   - Uses source[:data] (already processed - don't re-process!)
   - Combines sources into unified map
   - Scales sources to target size
   - Returns JSON structure

4. MapStudioController.save_generated_map
   ↓
   - Saves to data/maps/galaxy_game/planet_timestamp.json
   - Returns success

5. User can apply map to celestial body
   ↓
   - Loads JSON
   - Applies to geosphere.terrain_map
   - Monitor displays using elevation/terrain/biomes fields
```

### Critical Fixes Needed:

**MapStudioController**:
1. Accept both parameter names: `selected_maps || source_map_ids`
2. Add logging to see what's received
3. Validate sources before generation

**PlanetaryMapGenerator**:
1. Get width/height from root level: `data[:width]` not `data.dig(:lithosphere, :width)`
2. Scale sources to target grid size properly
3. Return both formats: `terrain_grid` AND `elevation`/`biomes`/`terrain`
4. Handle biome symbol → code conversion
5. Add validation for all data access

**EarthMapGenerator** (if used):
1. Don't re-process source[:data] if already present
2. Use source[:path] not source[:file_path]
3. Access biomes at root: `data[:biomes]` not `data.dig(:biomes)`
4. Add nil checks everywhere
5. Implement or remove placeholder methods

## Testing Checklist

```ruby
# Test 1: Single FreeCiv source
sources = [{
  type: :freeciv,
  filename: 'earth-180x90.sav',
  path: '/path/to/earth-180x90.sav',
  data: { biomes: [...], lithosphere: { elevation: [...] }, width: 180, height: 90 }
}]

result = generator.generate_planetary_map(planet: earth, sources: sources)
# Check: result has elevation, terrain_grid, biomes
# Check: Dimensions correct
# Check: No errors in logs

# Test 2: Multiple sources
sources = [freeciv_source, civ4_source]

result = generator.generate_planetary_map(planet: mars, sources: sources)
# Check: Sources combined
# Check: Metadata shows both sources

# Test 3: No sources (procedural)
result = generator.generate_planetary_map(planet: venus, sources: [])
# Check: Procedural map generated
# Check: metadata.quality == 'procedural_generated'

# Test 4: Save and load
saved = controller.save_generated_map(result, planet, sources)
loaded = JSON.parse(File.read(saved[:path]))
# Check: JSON valid
# Check: Has elevation, terrain_grid, metadata
```

This should get the entire map generation system working! 🎯
