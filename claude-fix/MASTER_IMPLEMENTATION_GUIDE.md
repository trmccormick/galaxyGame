# MASTER IMPLEMENTATION GUIDE - Map Studio Fixes

## Executive Summary

The Map Studio generation system has **6 critical issues** across 3 files that prevent maps from being generated correctly. This guide provides complete fixes for Grok to implement.

---

## 🎯 The Root Cause

**Parameter name mismatch** → Empty sources array → Procedural generation instead of using selected maps

---

## 📋 Complete Fix Checklist

### File 1: MapStudioController (HIGH PRIORITY)

**Location**: `app/controllers/admin/map_studio_controller.rb`

#### Fix 1.1: Accept Both Parameter Names (Line 38)

**Current**:
```ruby
selected_maps = params[:selected_maps] || []
```

**Fixed**:
```ruby
# Accept both parameter names for compatibility
selected_maps = params[:selected_maps] || params[:source_map_ids] || []

# Add debug logging
Rails.logger.info "=== MAP GENERATION DEBUG ==="
Rails.logger.info "Received parameters: #{params.inspect}"
Rails.logger.info "selected_maps: #{params[:selected_maps].inspect}"
Rails.logger.info "source_map_ids: #{params[:source_map_ids].inspect}"
Rails.logger.info "Using: #{selected_maps.inspect}"
```

#### Fix 1.2: Validate Sources (After Line 56)

**Add**:
```ruby
# After sources = prepare_map_sources(selected_maps)
Rails.logger.info "Prepared #{sources.size} sources"

if sources.empty? && selected_maps.any?
  # User selected maps but none processed successfully
  redirect_to admin_map_studio_generate_path,
              alert: "Failed to process selected maps. Please check map files."
  return
end
```

#### Fix 1.3: Better Success Message (Line 68-69)

**Current**:
```ruby
redirect_to admin_map_studio_path,
            notice: "Successfully generated #{planet.name} map using #{sources.size} source maps..."
```

**Fixed**:
```ruby
notice_message = if sources.empty?
  "Generated procedural map for #{planet.name}. No source maps used. Map saved as '#{saved_map[:filename]}'."
else
  "Successfully generated #{planet.name} map using #{sources.size} source map(s). Map saved as '#{saved_map[:filename]}'."
end

redirect_to admin_map_studio_path, notice: notice_message
```

---

### File 2: PlanetaryMapGenerator (CRITICAL)

**Location**: `lib/ai_manager/planetary_map_generator.rb`

#### Fix 2.1: Get Dimensions Correctly (Line 48-49)

**Current**:
```ruby
width = base_data.dig(:lithosphere, :width) || 80
height = base_data.dig(:lithosphere, :height) || 50
```

**Fixed**:
```ruby
# Width/height are at root level, not in lithosphere!
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
```

#### Fix 2.2: Validate Sources (Line 58-66)

**Current**:
```ruby
sources.each_with_index do |source, index|
  source_data = source[:data]

  if source_data[:biomes].is_a?(Array)
    # ...
  end
end
```

**Fixed**:
```ruby
valid_sources = 0

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
  valid_sources += 1
end

# Check if any sources were valid
if valid_sources == 0
  Rails.logger.warn "[PlanetaryMapGenerator] No valid sources processed, using procedural fallback"
  return generate_procedural_map(planet, options.merge(width: width, height: height))
end
```

#### Fix 2.3: Scale Sources Properly (Line 94-116)

**Current**: Uses modulo offset approach (loses data if source bigger than target)

**Fixed**: Scale to fit
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
```

#### Fix 2.4: Add Biome Converter (After apply_source_to_grid)

**Add new method**:
```ruby
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

#### Fix 2.5: Return Monitor-Compatible Format (Line 22-37)

**Current**: Returns only terrain_grid, elevation_data format

**Fixed**: Return BOTH formats
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
  # Include BOTH old format (terrain_grid) AND new format (elevation, biomes) for compatibility
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

---

### File 3: EarthMapGenerator (OPTIONAL - Only if used)

**Location**: `app/services/ai_manager/earth_map_generator.rb`

#### Fix 3.1: Use Existing Data (Line 63-77)

**Current**: Always re-processes files

**Fixed**:
```ruby
def process_source_maps(sources)
  processed = []

  sources.each do |source|
    # USE EXISTING DATA if MapStudioController already processed it
    map_data = if source[:data]
                 Rails.logger.info "[EarthMapGenerator] Using pre-processed data for #{source[:filename]}"
                 source[:data]
               else
                 Rails.logger.info "[EarthMapGenerator] Processing #{source[:filename]}"
                 file_path = source[:path] || source[:file_path]
                 
                 unless file_path && File.exist?(file_path)
                   Rails.logger.error "[EarthMapGenerator] File not found: #{file_path}"
                   next
                 end
                 
                 case source[:type]
                 when :freeciv
                   @freeciv_processor.process(file_path)
                 when :civ4
                   @civ4_processor.process(file_path)
                 else
                   Rails.logger.warn "[EarthMapGenerator] Unknown source type: #{source[:type]}"
                   next
                 end
               end

    # Skip if processing failed
    next unless map_data && map_data.is_a?(Hash)

    processed << {
      source: source,
      data: map_data,
      analysis: analyze_imported_map(map_data, source[:type])
    }
  end

  processed
end
```

---

## 🧪 Testing Plan

### Test 1: Basic Generation

```bash
# In Rails console
planet = CelestialBody.find_by(name: 'Earth')
generator = AIManager::PlanetaryMapGenerator.new

# Simulate controller-prepared sources
sources = [{
  type: :freeciv,
  filename: 'earth-180x90.sav',
  path: Rails.root.join('data/maps/freeciv/earth-180x90.sav').to_s,
  data: {
    biomes: [[:grasslands, :ocean], [:desert, :forest]],
    lithosphere: { elevation: [[0.1, 0.2], [0.3, 0.4]] },
    width: 2,
    height: 2
  }
}]

result = generator.generate_planetary_map(
  planet: planet,
  sources: sources,
  options: {}
)

# Check results
puts "Keys: #{result.keys}"
puts "Has elevation: #{result[:elevation].present?}"
puts "Has terrain_grid: #{result[:terrain_grid].present?}"
puts "Has metadata: #{result[:metadata].present?}"
puts "Source maps in metadata: #{result[:metadata][:source_maps]}"
```

### Test 2: Via Controller

1. Go to Map Studio generate page
2. Select Earth as planet
3. Select 1-2 source maps
4. Click "Generate Map"
5. Check Rails logs for:
   ```
   === MAP GENERATION DEBUG ===
   Received parameters: {...}
   selected_maps: [...]  # Should NOT be empty!
   Using: [...]
   Prepared N sources    # Should be > 0
   ```
6. Check generated file exists in `data/maps/galaxy_game/`
7. Check metadata has source_maps populated

### Test 3: Verify JSON Structure

```bash
# Check generated file
cat data/maps/galaxy_game/earth_TIMESTAMP.json | jq '.metadata.source_maps'

# Should show:
# [
#   { "type": "freeciv", "filename": "earth-180x90.sav" }
# ]

# NOT empty array!
```

---

## 📊 Success Criteria

After implementing all fixes:

✅ **Controller receives selected maps** - Not empty array
✅ **Sources prepared successfully** - Files processed, data present
✅ **Generator uses sources** - Metadata shows source_maps populated
✅ **JSON saved correctly** - File created with all fields
✅ **Monitor can display** - Has elevation, terrain, biomes fields
✅ **Quality not 'procedural_generated'** - Shows 'combined_from_N_sources'

---

## 🚨 Common Pitfalls

### Pitfall 1: Parameter Names

**Issue**: Form sends `source_map_ids[]` but controller reads `selected_maps`

**Fix**: Accept BOTH names (Fix 1.1)

### Pitfall 2: Double Processing

**Issue**: Controller processes, then generator processes again

**Fix**: Check for `source[:data]` first (Fix 3.1)

### Pitfall 3: Wrong Data Access

**Issue**: Trying to access `data.dig(:lithosphere, :width)` when it's `data[:width]`

**Fix**: Check root level first (Fix 2.1)

### Pitfall 4: Size Mismatch

**Issue**: Source map 180x90 but target grid 80x50 - data lost

**Fix**: Scale properly (Fix 2.3)

### Pitfall 5: Monitor Can't Display

**Issue**: Generator returns `elevation_data` but monitor expects `elevation`

**Fix**: Return both names (Fix 2.5)

---

## 📝 Implementation Order

**Step 1**: Fix MapStudioController (Fixes 1.1-1.3)
- This is the entry point
- Must work first or nothing else matters

**Step 2**: Fix PlanetaryMapGenerator (Fixes 2.1-2.5)
- Core generation logic
- Most critical fixes

**Step 3**: Test basic generation
- Use Test 1 from testing plan
- Verify sources used, not procedural

**Step 4**: Test via UI
- Use Test 2 from testing plan
- Verify end-to-end flow

**Step 5**: (Optional) Fix EarthMapGenerator
- Only if it's actually being used
- Otherwise skip

---

## 🎯 Expected Results

### Before Fixes:

```json
{
  "metadata": {
    "source_maps": [],  // ← EMPTY!
    "quality": "procedural_generated"  // ← FALLBACK!
  }
}
```

### After Fixes:

```json
{
  "metadata": {
    "source_maps": [
      { "type": "freeciv", "filename": "earth-180x90.sav" },
      { "type": "civ4", "filename": "Earth.Civ4WorldBuilderSave" }
    ],
    "quality": "combined_from_2_sources"  // ← SUCCESS!
  },
  "elevation": [[0.1, 0.2, ...], ...],  // ← For monitor
  "terrain_grid": [["g", "o", ...], ...]  // ← For JSON
}
```

---

## 📖 Quick Reference

### Key Data Structures:

**Source (from MapStudioController)**:
```ruby
{
  type: :freeciv,
  filename: 'earth-180x90.sav',
  path: '/full/path/to/file.sav',
  data: {  # ← Already processed!
    biomes: [[symbols...], ...],
    lithosphere: { elevation: [[floats...], ...] },
    width: 180,
    height: 90
  }
}
```

**Processor Output**:
```ruby
{
  biomes: [[:grasslands, :ocean, ...], ...],  # ← Root level!
  lithosphere: {
    elevation: [[0.1, 0.2, ...], ...],
    method: 'freeciv_perlin_constrained',
    quality: 'medium_60_70_percent'
  },
  width: 180,   # ← Root level!
  height: 90    # ← Root level!
}
```

**Generator Output**:
```ruby
{
  # Old format
  terrain_grid: [['g', 'o', ...], ...],
  elevation_data: [[0.1, 0.2, ...], ...],
  biome_counts: { 'g' => 100, 'o' => 50 },
  
  # New format (aliases)
  elevation: [[0.1, 0.2, ...], ...],  # ← For monitor
  terrain: [['g', 'o', ...], ...],
  biomes: [['g', 'o', ...], ...],
  
  metadata: { ... }
}
```

---

This guide should give Grok everything needed to fix the Map Studio generation system! 🚀
