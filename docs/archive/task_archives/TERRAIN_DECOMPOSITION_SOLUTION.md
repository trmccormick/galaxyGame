# Separating Geological Structure from Biomes/Water - The Real Solution

## The Core Problem - NOW CRYSTAL CLEAR ✅

### What Civ4/FreeCiv Maps Contain:
```
TERRAIN_OCEAN     → Water feature (hydrosphere)
TERRAIN_GRASS     → Vegetation biome (biosphere)
TERRAIN_FOREST    → Vegetation biome (biosphere)
TERRAIN_JUNGLE    → Vegetation biome (biosphere)
TERRAIN_PLAINS    → Could be bare geology OR grasslands
TERRAIN_DESERT    → Geological feature (lithosphere)
TERRAIN_TUNDRA    → Cold biome (temperature-dependent)
```

**These are MIXED LAYERS** - geology + water + vegetation all combined!

### What Galaxy Game Needs:
```
Layer 0 (Lithosphere): Pure geology
  - Lowlands, highlands, mountains, valleys
  - No water, no vegetation
  - Elevation-based

Layer 1 (Hydrosphere): Water distribution
  - Ocean coverage from planetary data
  - Ice caps from temperature
  - Extracted separately

Layer 2 (Biosphere): Vegetation
  - Starts at 0.0 (bare)
  - Grows during terraforming
  - Extracted separately
```

## The Solution: Terrain Decomposition Service

### New Service: TerrainDecompositionService

```ruby
# app/services/import/terrain_decomposition_service.rb
module Import
  class TerrainDecompositionService
    
    # Decompose mixed Civ4/FreeCiv terrain into separate layers
    def self.decompose(terrain_grid, planetary_conditions)
      width = terrain_grid[0].length
      height = terrain_grid.length
      
      # Initialize layers
      lithosphere = Array.new(height) { Array.new(width) }
      hydrosphere_mask = Array.new(height) { Array.new(width, false) }
      biosphere_potential = Array.new(height) { Array.new(width, 0.0) }
      elevation = Array.new(height) { Array.new(width, 0.5) }
      
      # Process each tile
      terrain_grid.each_with_index do |row, y|
        row.each_with_index do |terrain_type, x|
          result = decompose_tile(terrain_type, y, height, planetary_conditions)
          
          lithosphere[y][x] = result[:geology]
          hydrosphere_mask[y][x] = result[:has_water]
          biosphere_potential[y][x] = result[:bio_potential]
          elevation[y][x] = result[:elevation]
        end
      end
      
      {
        lithosphere: {
          grid: lithosphere,
          elevation: elevation,
          description: "Pure geological structure (bare planet)"
        },
        hydrosphere: {
          water_mask: hydrosphere_mask,
          coverage: calculate_water_coverage(hydrosphere_mask),
          description: "Water distribution from map + planetary data"
        },
        biosphere: {
          potential: biosphere_potential,
          current_density: Array.new(height) { Array.new(width, 0.0) },
          description: "Vegetation potential (starts at 0.0)"
        },
        metadata: {
          source: "civ4_decomposition",
          planetary_conditions: planetary_conditions
        }
      }
    end
    
    private
    
    # Decompose a single terrain tile into layers
    def self.decompose_tile(terrain_type, y, height, conditions)
      temp = conditions[:temperature]
      pressure = conditions[:pressure]
      has_water_vapor = conditions[:has_water]
      latitude = (y.to_f / height - 0.5) * 180
      
      # Default values
      geology = :plains
      has_water = false
      bio_potential = 0.0
      elevation = 0.5
      
      case terrain_type
      
      # ====================================================================
      # WATER FEATURES - Extract to hydrosphere, determine underlying geology
      # ====================================================================
      when :ocean, :deep_sea
        # Water feature → Extract to hydrosphere layer
        has_water = true
        
        # Underlying geology (what's under the water)
        if terrain_type == :deep_sea
          geology = :basin      # Deep ocean basin (low elevation)
          elevation = 0.2
        else
          geology = :lowland    # Shallow sea floor
          elevation = 0.3
        end
        
        # Bio potential (if planet can support water)
        if temp > 273 && temp < 373 && pressure > 0.1
          bio_potential = 0.5  # Ocean areas can be fertile
        end
      
      when :coast
        # Coastal water → Extract to hydrosphere
        has_water = true
        geology = :coastal_plain
        elevation = 0.35
        bio_potential = 0.6  # Coasts are fertile
      
      # ====================================================================
      # VEGETATION FEATURES - Extract to biosphere, determine underlying geology
      # ====================================================================
      when :grasslands
        # Vegetation → Extract to biosphere potential
        geology = :plains        # Underlying is flat terrain
        elevation = 0.4
        bio_potential = 0.8      # High potential for life
        has_water = false
      
      when :forest
        # Forest → Extract to biosphere potential
        geology = :plains        # Moderate terrain
        elevation = 0.45
        bio_potential = 0.9      # Very high potential
        has_water = false
      
      when :jungle
        # Jungle → Extract to biosphere potential
        geology = :lowland       # Tropical lowlands
        elevation = 0.35
        bio_potential = 1.0      # Maximum potential (tropical)
        has_water = false
      
      when :swamp
        # Swamp → Both water and vegetation potential
        geology = :lowland
        elevation = 0.25
        has_water = true         # Wetland
        bio_potential = 0.7
      
      when :boreal
        # Boreal forest → Extract to biosphere, reveal hills
        geology = :hills
        elevation = 0.6
        bio_potential = 0.6      # Moderate (cold climate)
        has_water = false
      
      # ====================================================================
      # PURE GEOLOGY - Already geological features
      # ====================================================================
      when :plains
        # Already geology
        geology = :plains
        elevation = 0.4
        bio_potential = 0.5      # Moderate potential
        has_water = false
      
      when :desert
        # Already geology
        geology = :desert
        elevation = 0.45
        bio_potential = 0.2      # Low potential (arid)
        has_water = false
      
      when :tundra
        # Cold bare ground
        geology = :plains
        elevation = 0.5
        bio_potential = 0.3      # Low potential (cold)
        has_water = false
      
      when :arctic
        # Polar regions
        geology = :polar_plain
        elevation = 0.4
        
        # Ice caps are water (frozen)
        if temp < 273
          has_water = true       # Ice is water
        end
        
        bio_potential = 0.1      # Very low potential
      
      when :rocky, :mountains
        # High elevation geology
        geology = :mountains
        elevation = 0.8
        bio_potential = 0.2      # Low potential (elevation)
        has_water = false
      
      # ====================================================================
      # DEFAULT
      # ====================================================================
      else
        geology = :plains
        elevation = 0.5
        bio_potential = 0.5
        has_water = false
      end
      
      # Adjust based on planetary conditions
      # If planet has no water vapor, override water mask
      if !has_water_vapor
        has_water = false
      end
      
      # If planet is too hot/cold, reduce bio potential
      if temp > 350 || temp < 250
        bio_potential *= 0.1
      end
      
      {
        geology: geology,
        has_water: has_water,
        bio_potential: bio_potential,
        elevation: elevation
      }
    end
    
    def self.calculate_water_coverage(water_mask)
      total = water_mask.flatten.size
      water_tiles = water_mask.flatten.count(true)
      (water_tiles.to_f / total * 100).round(2)
    end
  end
end
```

## Updated Import Pipeline

### Step 1: Import Map
```ruby
# Import Civ4 map as usual
civ4_data = Civ4WbsImportService.new('Venus_100x50.wbs').import
# Result: { grid: [[:ocean, :grass, :desert, ...]], width: 100, height: 50 }
```

### Step 2: Get Planetary Conditions
```ruby
# Get actual planet conditions from JSON or database
planet_conditions = {
  temperature: celestial_body.surface_temperature,  # Venus: 737K
  pressure: celestial_body.atmosphere&.pressure,     # Venus: 92 bar
  has_water: celestial_body.hydrosphere&.water_coverage > 0
}
```

### Step 3: Decompose Terrain
```ruby
# Separate mixed terrain into pure layers
layers = TerrainDecompositionService.decompose(
  civ4_data[:grid], 
  planet_conditions
)

# Result:
{
  lithosphere: {
    grid: [[:basin, :plains, :desert, ...]]  # Pure geology
  },
  hydrosphere: {
    water_mask: [[true, false, false, ...]]  # Where water COULD be
  },
  biosphere: {
    potential: [[0.5, 0.8, 0.2, ...]]       # How fertile
    current_density: [[0.0, 0.0, 0.0, ...]] # Current vegetation (none)
  }
}
```

### Step 4: Apply to Planet
```ruby
celestial_body.geosphere.terrain_map = {
  # Pure geological structure (ALWAYS visible)
  lithosphere: layers[:lithosphere],
  
  # Water distribution (from map template + planet data)
  hydrosphere: {
    water_mask: layers[:hydrosphere][:water_mask],
    actual_coverage: planet_conditions[:has_water] ? layers[:hydrosphere][:coverage] : 0
  },
  
  # Vegetation potential and current state
  biosphere: {
    potential: layers[:biosphere][:potential],
    current_density: layers[:biosphere][:current_density],  # Starts at 0.0
    target_density: layers[:biosphere][:potential]          # Terraforming goal
  },
  
  # Source info
  metadata: {
    template: 'Venus_100x50.wbs',
    decomposed: true,
    planetary_conditions: planet_conditions
  }
}
```

## Rendering with Separated Layers

### Updated Rendering Logic

```javascript
function renderTerrainMap() {
    const lithosphere = terrainData.lithosphere.grid;
    const hydrosphere = terrainData.hydrosphere;
    const biosphere = terrainData.biosphere;
    const elevation = terrainData.lithosphere.elevation;
    
    const planetTemp = <%= @celestial_body.surface_temperature %>;
    const planetPressure = <%= @celestial_body.atmosphere&.pressure || 0 %>;
    const hasWater = <%= @celestial_body.hydrosphere&.water_coverage || 0 %> > 0;
    
    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            // ================================================================
            // STEP 1: Base geology (lithosphere - ALWAYS render)
            // ================================================================
            const geology = lithosphere[y][x];
            const elev = elevation[y][x];
            const latitude = (y / height - 0.5) * 180;
            
            let baseColor = getGeologyColor(geology, elev, planetTemp);
            
            // ================================================================
            // STEP 2: Water layer (hydrosphere - if planet has water)
            // ================================================================
            let finalColor = baseColor;
            
            if (visibleLayers.has('water') && hydrosphere.water_mask[y][x]) {
                // This tile has water POTENTIAL (from map)
                // But does planet actually have water?
                if (hasWater && planetTemp > 273 && planetTemp < 373) {
                    // Liquid water possible
                    const waterColor = '#004488';
                    finalColor = blendColors(baseColor, waterColor, 0.8);
                } else if (planetTemp < 273) {
                    // Ice
                    const iceColor = '#E0F0FF';
                    finalColor = blendColors(baseColor, iceColor, 0.7);
                } else if (!hasWater) {
                    // No water - show dry basin
                    // Keep base geology color (depression in terrain)
                    finalColor = adjustBrightness(baseColor, 0.8); // Slightly darker
                }
            }
            
            // ================================================================
            // STEP 3: Biosphere layer (if terraforming progress exists)
            // ================================================================
            if (visibleLayers.has('biomes') && biosphere.current_density[y][x] > 0) {
                const density = biosphere.current_density[y][x];
                const potential = biosphere.potential[y][x];
                
                // Vegetation color based on density
                const greenValue = Math.floor(255 * Math.min(density, 1.0));
                const vegColor = `rgb(0, ${greenValue}, 0)`;
                
                // Blend with current color
                finalColor = blendColors(finalColor, vegColor, density * 0.6);
            }
            
            // ================================================================
            // STEP 4: Other overlays (temperature, resources, etc.)
            // ================================================================
            if (visibleLayers.has('temperature')) {
                const tempColor = getTemperatureColor(latitude, elev, planetTemp);
                finalColor = blendColors(finalColor, tempColor, 0.3);
            }
            
            // Render final composited color
            ctx.fillStyle = finalColor;
            ctx.fillRect(x * tileSize, y * tileSize, tileSize, tileSize);
        }
    }
}

function getGeologyColor(geology, elevation, planetTemp) {
    // Base colors for geological features (bare planet)
    const baseGeology = {
        basin: '#6B5B4E',        // Dark brown (deep depression)
        lowland: '#8B7355',      // Medium brown (low elevation)
        plains: '#A0826D',       // Tan (flat terrain)
        coastal_plain: '#9C8B7A', // Light tan (near former water)
        hills: '#8B7D6B',        // Gray-brown (elevated)
        mountains: '#696969',    // Gray (high peaks)
        desert: '#D4A574',       // Sandy (arid region)
        polar_plain: '#B8A89A'   // Pale tan (polar)
    };
    
    let color = baseGeology[geology] || '#A0826D';
    
    // Adjust for elevation
    const elevationFactor = 0.8 + (elevation * 0.4);
    color = adjustBrightness(color, elevationFactor);
    
    // Apply planetary tint
    if (planetTemp > 700) {
        // Venus-like: yellow-orange tint
        color = applyYellowTint(color, 0.4);
    } else if (planetTemp < 250) {
        // Mars-like: red tint
        color = applyRedTint(color, 0.3);
    } else if (planetTemp < 200) {
        // Ice world: desaturate
        color = desaturate(color, 0.7);
    }
    
    return color;
}
```

## Example: Venus Map Transformation

### Input: Venus_100x50.wbs (Terraformed)
```
Tile [0,0]: TERRAIN_OCEAN (water feature)
Tile [0,2]: TERRAIN_GRASS (vegetation)
Tile [0,19]: TERRAIN_DESERT (geology)
```

### After Decomposition:
```javascript
{
  lithosphere: {
    grid: [
      [:basin, :plains, :plains, :desert, ...]  // Pure geology
    ],
    elevation: [
      [0.2, 0.4, 0.4, 0.45, ...]               // Elevation data
    ]
  },
  hydrosphere: {
    water_mask: [
      [true, false, false, false, ...]         // Water POTENTIAL
    ],
    actual_coverage: 0  // Venus has no water (too hot)
  },
  biosphere: {
    potential: [
      [0.5, 0.8, 0.8, 0.2, ...]               // Fertility potential
    ],
    current_density: [
      [0.0, 0.0, 0.0, 0.0, ...]               // No vegetation (start)
    ]
  }
}
```

### Rendering on Venus (737K, 92 bar, no water):
```javascript
Tile [0,0]: 
  Geology: basin (0.2 elevation)
  Water mask: true, but planet has no water
  → Render: Dark yellow-brown basin (dry)
  
Tile [0,2]:
  Geology: plains (0.4 elevation)
  Bio potential: 0.8 (high)
  Current density: 0.0 (none yet)
  → Render: Medium yellow-brown plains (bare)
  
Tile [0,19]:
  Geology: desert (0.45 elevation)
  → Render: Light yellow (volcanic desert)
```

### Result:
✅ Venus looks volcanic (yellow-brown geology)
✅ No blue water (hydrosphere layer has no actual water)
✅ No green vegetation (biosphere density = 0.0)
✅ Terrain structure preserved from map

### After Terraforming to 50%:
```javascript
Planet conditions: temp=450K, pressure=5 bar, water=15%

Tile [0,0]:
  Geology: basin
  Water mask: true, planet now has 15% water, temp allows liquid
  → Render: Dark blue-brown (shallow water forming)
  
Tile [0,2]:
  Geology: plains
  Bio density: 0.4 (growing from 0.0 → 0.8 potential)
  → Render: Tan with green tint (vegetation spreading)
```

## Complete Implementation

### Controller Action
```ruby
def import_civ4_map
  # Parse Civ4 file
  civ4_data = Civ4WbsImportService.new(params[:file].path).import
  
  # Get planetary conditions
  conditions = {
    temperature: @celestial_body.surface_temperature,
    pressure: @celestial_body.atmosphere&.pressure || 0,
    has_water: @celestial_body.hydrosphere&.water_coverage.to_f > 0
  }
  
  # Decompose into separate layers
  layers = TerrainDecompositionService.decompose(
    civ4_data[:grid],
    conditions
  )
  
  # Store separated layers
  @celestial_body.geosphere.terrain_map = {
    lithosphere: layers[:lithosphere],
    hydrosphere: layers[:hydrosphere],
    biosphere: layers[:biosphere],
    metadata: {
      source_file: params[:file].original_filename,
      decomposed: true,
      import_date: Time.current
    }
  }
  
  @celestial_body.save!
  
  flash[:success] = "Map imported and decomposed into geological layers"
  redirect_to monitor_admin_celestial_body_path(@celestial_body)
end
```

## Benefits of This Approach

### ✅ Solves Venus Problem
- Map says "ocean" → Decomposed to "basin" geology + water mask
- Venus has no water → Basin renders as dry depression
- Result: Yellow-brown volcanic appearance (correct!)

### ✅ Supports Terraforming
- Biosphere starts at 0.0 (bare)
- Gradually increases to potential (from map)
- Visual change: bare → vegetated

### ✅ Reuses Maps
- One Venus map works for:
  - Current Venus (bare, hot)
  - Mid-terraforming Venus (partial)
  - Fully terraformed Venus (habitable)

### ✅ Separates Concerns
- Lithosphere: Pure geology (permanent)
- Hydrosphere: Water distribution (conditional)
- Biosphere: Life (progressive)

### ✅ Respects Physics
- Planet temp/pressure determine rendering
- Same map, different planets = different appearance
- No "magic" conversion

## Summary

**Problem**: Civ4/FreeCiv maps mix geology + water + vegetation
**Solution**: Decompose into separate layers at import time
**Service**: TerrainDecompositionService extracts pure geology
**Result**: Venus looks volcanic, Mars looks red, Earth looks blue/green
**Terraforming**: Biosphere density gradually increases from 0.0 → potential

This is the **correct, elegant solution** that respects the layered planet model while using existing quality maps as templates!
