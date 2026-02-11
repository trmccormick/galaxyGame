# The Real Data Problem - What Maps Actually Contain

## The Fundamental Issue - NOW CRYSTAL CLEAR ✅

### What Grok THINKS FreeCiv/Civ4 Maps Contain:
```
Grok's Assumption:
- FreeCiv: Terrain (physical geography) + water
- Civ4: Biomes + resources

This is WRONG!
```

### What FreeCiv/Civ4 Maps ACTUALLY Contain:
```
BOTH formats primarily contain: BIOME DATA (ecological/climate zones)

FreeCiv .sav:
- 'a' = arctic (biome/climate zone)
- 'd' = desert (biome/climate zone)
- 'g' = grasslands (biome/vegetation)
- 'f' = forest (biome/vegetation)
- 'j' = jungle (biome/vegetation)
- ':' = ocean (water feature)

Civ4 .wbs:
- TERRAIN_GRASS = grasslands biome
- TERRAIN_FOREST = forest biome
- TERRAIN_JUNGLE = jungle biome
- TERRAIN_DESERT = desert biome
- TERRAIN_OCEAN = water feature
- PlotType = crude elevation (0=flat, 1=coastal, 2=hills, 3=WATER)
```

**The Reality**: These are **TERRAFORMED, HABITABLE** maps showing what planets look like AFTER terraforming, with established biomes and climate zones.

## What Data We HAVE vs What We NEED

### What FreeCiv/Civ4 Maps Provide:

**✅ Good Data**:
- Biome distribution (where forests, deserts, grasslands are)
- Water features (ocean, coast locations)
- Crude elevation hints (Civ4: PlotType 0/1/2/3, FreeCiv: hills/mountains markers)

**❌ Missing Data**:
- **Precise elevation values** (no height map!)
- **Physical terrain structure** (just biomes, not geology)
- **Barren/pre-terraformed state** (only terraformed state)

### What Galaxy Game NEEDS for Rendering:

**Layer 0 (Lithosphere)**: Pure elevation data
```
Required: Elevation values (0.0 to 1.0) for every tile
Have: Crude hints (plains=flat, hills=elevated, mountains=high)
Missing: Actual elevation numbers
```

**Layer 1 (Hydrosphere)**: Water collection zones
```
Required: Basin identification (where water would collect)
Have: Current water locations (ocean tiles)
Missing: Dry basin locations (ancient sea beds on Mars)
```

**Layer 2 (Biosphere)**: Climate zones and vegetation potential
```
Required: Temperature/rainfall-dependent biome potential
Have: Actual biomes (forests, deserts - from terraformed state)
Missing: Bare planet → current planet progression
```

## The Extrapolation Problem

### Current Approach (Grok's "Extraction"):
```javascript
// Grok tries to "extract" layers from biome data
extractTerrainLayer(freecivData) {
    // But freecivData is BIOMES, not terrain!
    // Can't extract physical terrain from climate zones
}
```

### What We Actually Need to Do: INFER/GENERATE

#### Option 1: Infer Elevation from Biomes (Crude)
```ruby
def infer_elevation_from_biome(biome_type)
  # Rough estimates based on typical biome elevations
  BIOME_ELEVATION_HINTS = {
    ocean: 0.0,          # Sea level
    deep_sea: 0.1,       # Below sea level
    swamp: 0.25,         # Low wetlands
    grasslands: 0.4,     # Flat plains
    plains: 0.4,         # Flat
    desert: 0.45,        # Slightly elevated (arid)
    forest: 0.5,         # Moderate
    jungle: 0.35,        # Tropical lowlands
    tundra: 0.6,         # Cold elevated
    boreal: 0.65,        # Forested hills
    arctic: 0.7,         # Polar highlands OR sea level (ambiguous!)
    rocky: 0.75,         # Rocky outcrops
    mountains: 0.9       # High peaks (FreeCiv 'm')
  }
  
  BIOME_ELEVATION_HINTS[biome_type] || 0.5
end
```

**Problem**: This is VERY crude. Arctic could be sea-level ice or high-altitude ice. Desert could be low basin or high plateau.

#### Option 2: Generate Elevation Using Noise (Better)
```ruby
def generate_elevation_map(width, height, seed: nil)
  # Use Perlin/Simplex noise to generate realistic elevation
  noise = PerlinNoise.new(seed)
  
  elevation_map = Array.new(height) do |y|
    Array.new(width) do |x|
      # Generate base elevation using noise
      base = noise.octave_noise_2d(x / 30.0, y / 30.0, 4, 0.5)
      
      # Normalize to 0.0 - 1.0
      (base + 1.0) / 2.0
    end
  end
  
  elevation_map
end
```

**Then**: Constrain generated elevation to match biome hints:
```ruby
def constrain_elevation_to_biomes(generated_elevation, biome_grid)
  constrained = generated_elevation.dup
  
  biome_grid.each_with_index do |row, y|
    row.each_with_index do |biome, x|
      gen_elev = generated_elevation[y][x]
      
      # Constrain based on biome requirements
      case biome
      when :ocean, :deep_sea
        # MUST be low elevation
        constrained[y][x] = gen_elev * 0.3  # Force 0.0 - 0.3 range
      when :mountains, :rocky
        # MUST be high elevation
        constrained[y][x] = 0.7 + (gen_elev * 0.3)  # Force 0.7 - 1.0 range
      when :grasslands, :plains
        # Should be relatively flat (mid-low elevation)
        constrained[y][x] = 0.3 + (gen_elev * 0.3)  # Force 0.3 - 0.6 range
      # ... other biomes
      end
    end
  end
  
  constrained
end
```

#### Option 3: Hybrid Approach (Best for Galaxy Game)
```ruby
class ElevationMapGenerator
  def generate(biome_grid, civ4_plot_types: nil)
    width = biome_grid[0].length
    height = biome_grid.length
    
    # STEP 1: Start with noise-generated base
    base_elevation = generate_noise_elevation(width, height)
    
    # STEP 2: If we have Civ4 PlotType data, use it to guide
    if civ4_plot_types
      base_elevation = apply_plot_type_constraints(base_elevation, civ4_plot_types)
    end
    
    # STEP 3: Constrain to match biome requirements
    constrained_elevation = constrain_to_biomes(base_elevation, biome_grid)
    
    # STEP 4: Smooth and ensure realism
    smoothed = smooth_elevation(constrained_elevation)
    
    smoothed
  end
  
  private
  
  def apply_plot_type_constraints(elevation, plot_types)
    # Civ4 PlotType gives us crude elevation hints
    # 0 = flat → force low-mid
    # 1 = coastal → force low
    # 2 = hills → force mid-high
    # 3 = water → force very low
    
    elevation.each_with_index do |row, y|
      row.each_with_index do |elev, x|
        plot_type = plot_types[y][x]
        
        case plot_type
        when 0  # Flat
          elevation[y][x] = 0.3 + (elev * 0.3)  # 0.3 - 0.6
        when 1  # Coastal
          elevation[y][x] = 0.2 + (elev * 0.2)  # 0.2 - 0.4
        when 2  # Hills
          elevation[y][x] = 0.6 + (elev * 0.3)  # 0.6 - 0.9
        when 3  # Water
          elevation[y][x] = elev * 0.3           # 0.0 - 0.3
        end
      end
    end
    
    elevation
  end
end
```

## The Complete Data Flow for Galaxy Game

### For Imported Maps (FreeCiv/Civ4):

```ruby
# STEP 1: Import biome data (what we have)
imported_data = Civ4WbsImportService.new(file).import
# Result: { grid: [[:grasslands, :ocean, :desert, ...]], plot_types: [[0, 3, 0, ...]] }

# STEP 2: Generate elevation map (what we need)
elevation_generator = ElevationMapGenerator.new
elevation_map = elevation_generator.generate(
  imported_data[:grid],
  civ4_plot_types: imported_data[:plot_types]  # Use if available
)
# Result: [[0.4, 0.2, 0.45, ...], [0.5, 0.3, ...]]

# STEP 3: Decompose biomes into layers
decomposer = TerrainDecompositionService.new
layers = decomposer.decompose(
  biome_grid: imported_data[:grid],
  elevation_map: elevation_map,
  planetary_conditions: {
    temperature: planet.surface_temperature,
    pressure: planet.atmosphere.pressure,
    has_water: planet.hydrosphere.water_coverage > 0
  }
)

# Result:
{
  lithosphere: {
    elevation: [[0.4, 0.2, 0.45, ...]],  # Generated
    structure: [[:plains, :basin, :plains, ...]]  # Inferred from elevation
  },
  hydrosphere: {
    water_mask: [[false, true, false, ...]],  # Where water COULD collect (basins)
    current_coverage: planet.hydrosphere.water_coverage  # Actual water amount
  },
  biosphere: {
    potential: [[:grassland, :none, :desert, ...]],  # From imported biomes
    current_density: [[0.0, 0.0, 0.0, ...]]  # Start bare
  }
}

# STEP 4: Store separated layers
planet.geosphere.terrain_map = {
  lithosphere: layers[:lithosphere],
  hydrosphere: layers[:hydrosphere],
  biosphere: layers[:biosphere],
  source: {
    original_file: file_path,
    type: 'civ4_with_generated_elevation'
  }
}
```

### For Procedural Planets (No Maps):

```ruby
# For planets like Topaz in AOL-732356 (no imported map)

# STEP 1: Generate pure elevation map from scratch
elevation = ElevationMapGenerator.generate_pure_noise(180, 90, seed: planet.id)

# STEP 2: Determine biome potential from planetary conditions
biome_potential = BiomePotentialGenerator.generate(
  elevation: elevation,
  temperature: planet.surface_temperature,
  pressure: planet.atmosphere.pressure,
  composition: planet.atmosphere.composition
)

# STEP 3: Identify water collection zones
water_zones = HydrosphereAnalyzer.identify_basins(elevation)

# STEP 4: Assemble layers
planet.geosphere.terrain_map = {
  lithosphere: {
    elevation: elevation,              # Generated
    structure: infer_structure(elevation)  # Derived from elevation
  },
  hydrosphere: {
    water_mask: water_zones,
    current_coverage: planet.hydrosphere.water_coverage
  },
  biosphere: {
    potential: biome_potential,        # Climate-based
    current_density: zeros              # Start bare
  },
  source: {
    type: 'procedural_generation',
    seed: planet.id
  }
}
```

## Rendering with Generated Elevation

### SimEarth-Style Rendering (Now Possible):

```javascript
function renderTerrainMap() {
    const elevation = terrainData.lithosphere.elevation;
    const waterMask = terrainData.hydrosphere.water_mask;
    const bioPotential = terrainData.biosphere.potential;
    const bioDensity = terrainData.biosphere.current_density;
    
    const planetWater = <%= @celestial_body.hydrosphere&.water_coverage || 0 %>;
    const waterLevel = planetWater / 100.0;
    
    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            const elev = elevation[y][x];
            const latitude = (y / height - 0.5) * 180;
            
            // LAYER 0: Elevation-based color (SimEarth style!)
            let baseColor = getElevationColor(elev);
            
            // LAYER 1: Water fills basins (bathtub!)
            if (waterMask[y][x] && elev < waterLevel) {
                const depth = waterLevel - elev;
                baseColor = getWaterDepthColor(depth);
            }
            
            // LAYER 2: Biomes overlay (if life exists)
            if (visibleLayers.has('biomes') && bioDensity[y][x] > 0) {
                const temp = calculateTemp(latitude, elev, planetTemp);
                const viableBiome = determineBiome(temp, rainfall, elev);
                const biomeColor = getBiomeColor(viableBiome);
                baseColor = blendColors(baseColor, biomeColor, bioDensity[y][x]);
            }
            
            // LAYER 3: Planetary tint
            if (planetName.includes('Venus')) {
                baseColor = applyVenusTint(baseColor);
            } else if (planetName.includes('Mars')) {
                baseColor = applyMarsTint(baseColor);
            }
            
            renderTile(x, y, baseColor);
        }
    }
}

function getElevationColor(elevation) {
    // SimEarth-style elevation colors
    if (elevation > 0.8) return '#F0F0F0';  // White peaks
    if (elevation > 0.6) return '#C8C8C8';  // Light gray
    if (elevation > 0.4) return '#A09080';  // Gray-brown
    if (elevation > 0.2) return '#8C7860';  // Tan-brown
    return '#706050';                        // Dark brown
}
```

## Summary - The Real Solution

### ❌ What Grok CANNOT Do:
```
Extract "terrain" from FreeCiv maps
  → FreeCiv has BIOMES, not terrain
  
Extract "physical geography" from biomes
  → Biomes are CLIMATE ZONES, not geology
```

### ✅ What Grok MUST Do:
```
1. Import biomes (what maps actually contain)
2. GENERATE elevation (what maps don't contain)
   - Use Perlin noise
   - Constrain to biome hints
   - Use Civ4 PlotType if available
3. Decompose into layers:
   - Lithosphere: Generated elevation
   - Hydrosphere: Basins (from elevation) + planet water amount
   - Biosphere: Imported biomes as POTENTIAL (starts at 0.0)
4. Render based on layers + planetary conditions
```

### 🎯 The Key Services Needed:

**NEW** (Critical):
```ruby
ElevationMapGenerator
  - generate_from_biomes(biome_grid, plot_types)
  - generate_pure_noise(width, height, seed)
  - constrain_to_biomes(elevation, biomes)
  - smooth_elevation(elevation)
```

**REVISED**:
```ruby
TerrainDecompositionService
  - decompose(biome_grid, elevation_map, planetary_conditions)
  - extract_water_zones(elevation_map)
  - extract_biome_potential(biome_grid, planetary_conditions)
```

**REMOVE**:
```ruby
TerrainTerraformingService  # Wrong approach - can't reverse-engineer geology from biomes
```

### 🌍 Example: Venus Map Fix (With Generated Elevation)

```ruby
# Import Venus Civ4 map
biomes = Civ4Import.import('Venus_100x50.wbs')
# Result: { grid: [[:ocean, :grasslands, :desert, ...]] }

# Generate elevation (FreeCiv/Civ4 don't provide this!)
elevation = ElevationMapGenerator.generate(
  biomes[:grid],
  plot_types: biomes[:plot_types]
)
# Result: [[0.2, 0.4, 0.5, ...]] (ocean=low, grasslands=mid, desert=high)

# Decompose into layers
layers = decompose(
  biomes: biomes[:grid],
  elevation: elevation,
  conditions: { temp: 737, water: 0 }
)

# Render
# - Lithosphere: Gray/brown elevation colors
# - Hydrosphere: No water (Venus dry) → basins stay gray/brown
# - Biosphere: Too hot → no biomes survive → no overlay
# - Tint: Yellow-orange volcanic
# Result: Yellow-brown volcanic terrain ✅
```

This is the **complete, correct solution** for Galaxy Game!
