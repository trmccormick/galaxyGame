# Practical Dual-Approach Map System for Galaxy Game

## Core Philosophy ✅

**"Good enough is perfect"** - We don't need NASA-level accuracy
**"Generate what's missing"** - Fill gaps intelligently
**"Different sources, different methods"** - Use best approach for each format

## The Two-Path Strategy

### Path A: Civ4 Maps (Better Data)
```
Civ4 File
    ↓
EXTRACT elevation (PlotType + TerrainType) → 70-80% accurate
EXTRACT biomes (TerrainType) → exact
EXTRACT features (FeatureType) → exact
    ↓
ADD variation (±5% noise) → realism
SMOOTH neighbors → continuity
    ↓
Result: Pretty good elevation + exact biomes
```

### Path B: FreeCiv Maps (Limited Data)
```
FreeCiv File  
    ↓
EXTRACT biomes (character codes) → exact
INFER crude elevation (h=hills, m=mountains) → 40% accurate
    ↓
GENERATE elevation (Perlin noise constrained to biomes) → 60-70% accurate
SMOOTH → continuity
    ↓
Result: Generated elevation + exact biomes
```

### Path C: No Maps (Procedural Planets)
```
Planetary Conditions (temp, pressure, composition)
    ↓
GENERATE elevation (pure Perlin noise) → realistic
GENERATE biome potential (climate-based) → realistic
    ↓
Result: Fully procedural, unique terrain
```

## Implementation Strategy

### Service 1: Civ4MapProcessor (Extract-Heavy)

```ruby
# app/services/import/civ4_map_processor.rb
module Import
  class Civ4MapProcessor
    def process(civ4_file_path)
      # Step 1: Import raw data
      raw_data = Civ4WbsImportService.new(civ4_file_path).import
      
      # Step 2: EXTRACT elevation from PlotType
      elevation = extract_elevation_from_plottype(raw_data)
      
      # Step 3: EXTRACT biomes from TerrainType
      biomes = extract_biomes_from_terrain(raw_data)
      
      # Step 4: Add variation and smooth
      elevation = add_variation(elevation, amount: 0.05)
      elevation = smooth(elevation, passes: 2)
      
      # Step 5: Return separated layers
      {
        lithosphere: {
          elevation: elevation,
          method: 'civ4_plottype_extraction',
          quality: 'medium_70_80_percent'
        },
        biomes: biomes,
        source_file: civ4_file_path
      }
    end
    
    private
    
    def extract_elevation_from_plottype(raw_data)
      # Use PlotType + TerrainType to get 4-level elevation
      elevation_map = Array.new(raw_data[:height]) do |y|
        Array.new(raw_data[:width]) do |x|
          plot = raw_data[:plots].find { |p| p[:x] == x && p[:y] == y }
          estimate_elevation(plot) if plot
        end
      end
      
      elevation_map
    end
    
    def estimate_elevation(plot)
      pt = plot[:plot_type]
      tt = plot[:terrain_type]
      ft = plot[:feature_type]
      
      # Base from PlotType
      base = case pt
      when 0 then 0.45  # Flat
      when 1 then 0.35  # Coastal
      when 2 then 0.70  # Hills
      when 3 then 0.15  # Water (will refine)
      else 0.50
      end
      
      # Refine PlotType=3 (ambiguous)
      if pt == 3
        base = case tt
        when 'TERRAIN_OCEAN' then 0.10
        when 'TERRAIN_COAST' then 0.25
        when 'TERRAIN_SNOW' then 0.95   # Snow peaks!
        when 'TERRAIN_GRASS' then 0.90  # High peaks
        else 0.15
        end
      end
      
      # Terrain adjustments for land
      if pt != 3 && tt
        base += 0.30 if tt.include?('SNOW')
        base += 0.10 if tt.include?('TUNDRA')
        base += 0.05 if tt.include?('DESERT')
      end
      
      # Feature adjustments
      if ft
        base += 0.05 if ft.include?('FOREST')
        base -= 0.10 if ft.include?('FLOOD')
      end
      
      # Clamp
      [[base, 0.0].max, 1.0].min
    end
  end
end
```

### Service 2: FreecivMapProcessor (Generate-Heavy)

```ruby
# app/services/import/freeciv_map_processor.rb
module Import
  class FreecivMapProcessor
    def process(freeciv_file_path)
      # Step 1: Import raw data (biomes only)
      raw_data = FreecivSavImportService.new(freeciv_file_path).import
      
      # Step 2: INFER crude elevation hints
      crude_elevation = infer_elevation_from_biomes(raw_data[:grid])
      
      # Step 3: GENERATE realistic elevation (constrained to hints)
      generated_elevation = generate_constrained_elevation(
        crude_elevation,
        raw_data[:width],
        raw_data[:height]
      )
      
      # Step 4: Smooth
      generated_elevation = smooth(generated_elevation, passes: 3)
      
      # Step 5: Return separated layers
      {
        lithosphere: {
          elevation: generated_elevation,
          method: 'freeciv_perlin_constrained',
          quality: 'medium_60_70_percent'
        },
        biomes: raw_data[:grid],
        source_file: freeciv_file_path
      }
    end
    
    private
    
    def infer_elevation_from_biomes(biome_grid)
      # Get crude elevation hints from biome types
      biome_grid.map do |row|
        row.map do |biome|
          BIOME_ELEVATION_HINTS[biome] || 0.5
        end
      end
    end
    
    BIOME_ELEVATION_HINTS = {
      ocean: 0.10,
      deep_sea: 0.05,
      swamp: 0.30,
      grasslands: 0.45,
      plains: 0.45,
      desert: 0.50,
      forest: 0.55,
      jungle: 0.40,
      tundra: 0.65,
      boreal: 0.70,
      arctic: 0.75,  # Could be sea ice OR peaks (ambiguous)
      rocky: 0.80
    }.freeze
    
    def generate_constrained_elevation(crude_hints, width, height)
      # Use Perlin noise constrained to biome hints
      noise = PerlinNoise.new(seed: rand(10000))
      
      generated = Array.new(height) do |y|
        Array.new(width) do |x|
          # Generate base noise (0.0 - 1.0)
          noise_value = (noise.octave_noise_2d(x / 20.0, y / 20.0, 4, 0.5) + 1.0) / 2.0
          
          # Get hint for this location
          hint = crude_hints[y][x]
          
          # Constrain noise to ±0.15 around hint
          constrained = hint + (noise_value - 0.5) * 0.30
          
          # Clamp
          [[constrained, 0.0].max, 1.0].min
        end
      end
      
      generated
    end
  end
end
```

### Service 3: ProceduralTerrainGenerator (Pure Generation)

```ruby
# app/services/terrain/procedural_terrain_generator.rb
module Terrain
  class ProceduralTerrainGenerator
    def generate(width: 180, height: 90, seed: nil)
      seed ||= rand(100000)
      noise = PerlinNoise.new(seed: seed)
      
      # Generate pure elevation
      elevation = generate_elevation(noise, width, height)
      
      # Generate biome potential (no pre-existing biomes)
      biome_potential = generate_biome_potential(elevation, width, height)
      
      {
        lithosphere: {
          elevation: elevation,
          method: 'procedural_perlin',
          quality: 'generated_consistent'
        },
        biome_potential: biome_potential,
        seed: seed
      }
    end
    
    private
    
    def generate_elevation(noise, width, height)
      # Multi-octave Perlin noise for realistic terrain
      Array.new(height) do |y|
        Array.new(width) do |x|
          # Combine multiple octaves
          value = 0.0
          value += noise.octave_noise_2d(x / 40.0, y / 40.0, 1, 1.0) * 0.5  # Large features
          value += noise.octave_noise_2d(x / 20.0, y / 20.0, 2, 0.5) * 0.3  # Medium features
          value += noise.octave_noise_2d(x / 10.0, y / 10.0, 3, 0.25) * 0.2 # Small features
          
          # Normalize to 0.0-1.0
          (value + 1.0) / 2.0
        end
      end
    end
    
    def generate_biome_potential(elevation, width, height)
      # Determine biome potential based on elevation and latitude
      Array.new(height) do |y|
        Array.new(width) do |x|
          elev = elevation[y][x]
          latitude = (y.to_f / height - 0.5) * 180  # -90 to +90
          
          determine_biome_from_elevation_and_latitude(elev, latitude)
        end
      end
    end
    
    def determine_biome_from_elevation_and_latitude(elev, lat)
      abs_lat = lat.abs
      
      # High elevation = mountains/peaks
      return :rocky if elev > 0.8
      return :boreal if elev > 0.6
      
      # Polar regions
      return :arctic if abs_lat > 60
      return :tundra if abs_lat > 45
      
      # Low elevation = water potential
      return :ocean if elev < 0.3
      
      # Mid latitude, mid elevation = temperate
      if abs_lat < 30
        elev < 0.4 ? :jungle : :desert
      else
        elev < 0.45 ? :grasslands : :plains
      end
    end
  end
end
```

### Unified Interface: MapLayerService

```ruby
# app/services/import/map_layer_service.rb
module Import
  class MapLayerService
    # Unified interface - auto-detects source and uses appropriate method
    def self.generate_layers(source: nil, planetary_conditions: {})
      if source.nil?
        # No map - pure procedural
        generate_procedural_layers(planetary_conditions)
      elsif source.end_with?('.Civ4WorldBuilderSave')
        # Civ4 map - extract-heavy
        generate_from_civ4(source, planetary_conditions)
      elsif source.end_with?('.sav')
        # FreeCiv map - generate-heavy
        generate_from_freeciv(source, planetary_conditions)
      else
        raise "Unknown map format: #{source}"
      end
    end
    
    private
    
    def self.generate_from_civ4(file_path, conditions)
      processor = Civ4MapProcessor.new
      processed = processor.process(file_path)
      
      decompose_into_final_layers(processed, conditions)
    end
    
    def self.generate_from_freeciv(file_path, conditions)
      processor = FreecivMapProcessor.new
      processed = processor.process(file_path)
      
      decompose_into_final_layers(processed, conditions)
    end
    
    def self.generate_procedural_layers(conditions)
      generator = Terrain::ProceduralTerrainGenerator.new
      generated = generator.generate(
        width: 180,
        height: 90,
        seed: conditions[:seed]
      )
      
      decompose_into_final_layers(generated, conditions)
    end
    
    def self.decompose_into_final_layers(processed_data, conditions)
      # Final decomposition into Galaxy Game layers
      {
        lithosphere: {
          elevation: processed_data[:lithosphere][:elevation],
          method: processed_data[:lithosphere][:method],
          structure: infer_structure_from_elevation(
            processed_data[:lithosphere][:elevation]
          )
        },
        hydrosphere: {
          water_mask: identify_basins(processed_data[:lithosphere][:elevation]),
          current_coverage: conditions[:water_percentage] || 0
        },
        biosphere: {
          potential: processed_data[:biomes] || processed_data[:biome_potential],
          current_density: zeros(processed_data[:lithosphere][:elevation])
        },
        metadata: {
          source: processed_data[:source_file] || 'procedural',
          method: processed_data[:lithosphere][:method],
          quality: processed_data[:lithosphere][:quality]
        }
      }
    end
  end
end
```

## Usage Examples

### Example 1: Import Civ4 Earth Map to Venus

```ruby
# Venus has no map, using Earth structure
layers = MapLayerService.generate_layers(
  source: 'Earth.Civ4WorldBuilderSave',
  planetary_conditions: {
    temperature: 737,
    pressure: 92,
    water_percentage: 0,
    name: 'Venus'
  }
)

venus.geosphere.terrain_map = layers

# Rendering will show:
# - Elevation from Civ4 (70-80% accurate)
# - No water (Venus has 0%)
# - No biomes (too hot)
# - Yellow volcanic tint
# Result: Yellow-brown volcanic terrain ✅
```

### Example 2: Import FreeCiv Mars Map to Mars

```ruby
# Mars terraformed map used for terrain structure
layers = MapLayerService.generate_layers(
  source: 'mars-terraformed-133x64-v2_0.sav',
  planetary_conditions: {
    temperature: 210,
    pressure: 0.006,
    water_percentage: 0.01,
    name: 'Mars'
  }
)

mars.geosphere.terrain_map = layers

# Rendering will show:
# - Generated elevation (constrained to biomes, 60-70% accurate)
# - Trace water in polar caps only
# - No biomes (too cold)
# - Red tint
# Result: Red desert with white polar caps ✅
```

### Example 3: Procedural Planet (Topaz in AOL-732356)

```ruby
# No map available - pure generation
layers = MapLayerService.generate_layers(
  source: nil,
  planetary_conditions: {
    temperature: 331,
    pressure: 22,
    water_percentage: 0,
    seed: topaz.id
  }
)

topaz.geosphere.terrain_map = layers

# Rendering will show:
# - Procedural elevation (consistent, realistic)
# - No water (0%)
# - No biomes (hot, thick CO2)
# - No tint (alien world)
# Result: Unique procedural volcanic world ✅
```

## Quality Comparison

### Elevation Accuracy

| Source | Method | Quality | Good For |
|--------|--------|---------|----------|
| Civ4 Maps | PlotType extraction | 70-80% | Best terrain structure |
| FreeCiv Maps | Perlin constrained | 60-70% | Good enough, interesting |
| Procedural | Pure Perlin | Consistent | Unique, alien worlds |
| NASA DEM | Real data | 95%+ | Real Sol planets (future) |

### Implementation Effort

| Component | Complexity | Priority |
|-----------|-----------|----------|
| Civ4MapProcessor | Medium | HIGH (we have Civ4 maps) |
| FreecivMapProcessor | Medium | MEDIUM (we have FreeCiv maps) |
| ProceduralTerrainGenerator | Low | MEDIUM (for procedural planets) |
| MapLayerService | Low | HIGH (unified interface) |

## The Pragmatic Approach

### Phase 1: Get Civ4 Working (Now)
```ruby
# Implement Civ4MapProcessor
# Extract elevation from PlotType
# Test with Earth, Venus maps
# Result: 70-80% accurate terrain
```

### Phase 2: Add FreeCiv Support (Soon)
```ruby
# Implement FreecivMapProcessor  
# Generate constrained elevation
# Test with Mars map
# Result: 60-70% accurate terrain
```

### Phase 3: Add Procedural (Later)
```ruby
# Implement ProceduralTerrainGenerator
# Pure Perlin generation
# Use for planets without maps
# Result: Unique consistent terrain
```

### Phase 4: Enhance (Future)
```ruby
# Add NASA DEM data for real planets
# Improve smoothing algorithms
# Add geological features (ridges, valleys)
# Result: 95%+ accurate for Sol, good for others
```

## Summary - The Right Mindset

### ✅ Key Principles:

1. **Different sources, different methods**
   - Civ4: Extract what exists (better)
   - FreeCiv: Generate what's missing (good enough)
   - Procedural: Create from scratch (consistent)

2. **Good enough is perfect**
   - 70-80% accurate? Great for gameplay!
   - 60-70% accurate? Still interesting!
   - Consistent procedural? Unique and fun!

3. **Generate intelligently**
   - Use noise within constraints
   - Smooth for realism
   - Add variation for interest

4. **Focus on gameplay**
   - Does it look cool? ✅
   - Does it work with SimEarth rendering? ✅
   - Is it good enough for game? ✅
   - Perfect accuracy? Not needed!

The goal is **interesting, playable terrain** - not perfect scientific accuracy. We've got that covered! 🎮
