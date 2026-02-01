# Layer System & Bare Planet Analysis

## Current Problems Identified

### Problem 1: Confusing Layer Toggle Logic

**Current Behavior** (Lines 960-984):
```javascript
function toggleLayer(layerName) {
    if (layerName === 'terrain') {
        visibleLayers.clear();
        visibleLayers.add('terrain');
    } else {
        if (visibleLayers.has(layerName)) {
            visibleLayers.delete(layerName);
        } else {
            // ❌ This is confusing!
            if (['biomes', 'water', 'features'].includes(layerName)) {
                visibleLayers.clear();      // Clears everything
                visibleLayers.add('terrain'); // Adds terrain back
            }
            visibleLayers.add(layerName);
        }
    }
}
```

**Issue**: When clicking a "base layer" (biomes, water, features), it clears all layers. This breaks SimEarth-style additive overlays.

**SimEarth Behavior**: Layers are ADDITIVE overlays, not exclusive modes.

### Problem 2: Layer Rendering Logic Doesn't Match Intent

**Current Rendering** (Lines 761-776):
```javascript
// Apply other layer overlays
for (const [layerName, overlay] of Object.entries(layerOverlays)) {
    if (visibleLayers.has(layerName) && overlay.terrainColors && overlay.terrainColors[terrainType]) {
        let overlayColor = overlay.terrainColors[terrainType];
        
        if (typeof overlayColor === 'function') {
            overlayColor = overlayColor(latitude);
        }
        
        // Blend overlay with current final color
        finalColor = blendColors(finalColor, overlayColor, 0.7);
        hasOverlay = true;
    }
}
```

**Issue**: This REPLACES terrain colors instead of overlaying them. Doesn't show base elevation terrain when layers are off.

### Problem 3: Missing "Bare Planet" Concept

**What Documentation Says**:
- FreeCiv/Civ4 maps are **terraformed/habitable** versions (jungles, forests, grasslands)
- Need **bare/current state** versions matching our JSON planetary data
- Example: Mars should show cold deserts, ice caps - not forests

**Current System**:
- Only has ONE terrain map
- No distinction between "current state" and "terraformed goal"
- No terrain transformation service being used

## The Intended System (From Documentation)

### Layer Architecture (LAYERED_RENDERING.md)

**Layer 0: Lithosphere** (Geological foundation - ALWAYS VISIBLE)
- Base elevation terrain (elevation-based gray scale)
- Desert, plains, mountains, rocky outcrops
- This is the "bare planet" state

**Layer 1: Hydrosphere** (Water overlay - TOGGLE)
- Blue overlay for oceans, ice caps
- Shows where water exists NOW
- Additive on top of lithosphere

**Layer 2: Biosphere** (Vegetation overlay - TOGGLE)
- Green overlay with alpha transparency (bio_density 0.0-1.0)
- Shows gradual vegetation expansion
- NOT binary switches - gradual growth

**Layer 3: Infrastructure** (Stations/depots - TOGGLE)
- Industrial sprites
- L1 depots, surface stations
- Added by AI decisions

### Data Structure (MAP_SYSTEM.md)

```ruby
# Current implementation (WRONG):
terrain_map: {
  grid: [[:jungle, :ocean, :grasslands]],  # Only terraformed state
  width: 180,
  height: 90
}

# Should be (CORRECT):
terrain_map: {
  grid: [
    [
      {
        type: 'desert',           # CURRENT bare terrain (lithosphere)
        elevation: 234,           # Real elevation
        bio_density: 0.3,         # Life coverage (0-1) for overlay
        infrastructure: nil       # Station data
      }
    ]
  ],
  terraformed_goal: 'jungle'  # What FreeCiv map says it could become
}
```

### The Missing Piece: TerrainTerraformingService

**File Exists**: `terrain_terraforming_service.rb` (uploaded earlier)

**Purpose**: Convert terraformed maps → bare planet state

**Logic**:
```ruby
# FreeCiv says: jungle
# Inference: Needs >25°C, >2000mm rain, tropical latitude
# Mars reality: -60°C, 0mm rain, thin atmosphere
# Result: Transform jungle → cold_desert (realistic starting state)
```

**Planet Type Mappings** (from service):
```ruby
arid: {  # Mars-like
  ocean: :arctic,        # Ocean basins → polar ice deposits
  grasslands: :desert,   # Grasslands → regolith desert
  jungle: :rocky,        # Jungles → rocky terrain
  forest: :rocky         # Forests → rocky highlands
}

temperate: {  # Earth-like
  ocean: :deep_sea,      # Oceans stay as water
  grasslands: :desert,   # Grasslands → bare regolith
  forest: :rocky         # Forests → rocky outcrops
}
```

## Correct Implementation Plan

### Step 1: Data Schema Update

**Add to terrain_map**:
```ruby
{
  current_state: {  # Bare planet (lithosphere layer)
    grid: [[:desert, :rocky, :arctic]],
    width: 180,
    height: 90
  },
  terraformed_goal: {  # FreeCiv/Civ4 import (future state)
    grid: [[:jungle, :ocean, :grasslands]],
    source: 'freeciv_import'
  },
  biosphere: {  # Vegetation overlay (layer 2)
    bio_density: [[0.0, 0.0, 0.1], ...]  # 0.0 = bare, 1.0 = full
  }
}
```

### Step 2: Import Pipeline Update

**Current**: FreeCiv → terrain_map.grid
**Should Be**: FreeCiv → TerrainTerraformingService → bare planet + goal

```ruby
# In controller import action
def import_civ4_map
  # Parse Civ4 file
  terraformed_data = Civ4WbsImportService.new(file).import
  
  # Get planet characteristics
  planet_chars = {
    type: @celestial_body.type,
    surface_temperature: @celestial_body.surface_temperature,
    atmosphere: @celestial_body.atmosphere&.to_h,
    hydrosphere: @celestial_body.hydrosphere&.to_h
  }
  
  # Generate realistic bare state
  terraform_service = TerrainTerraformingService.new(terraformed_data, planet_chars)
  bare_terrain = terraform_service.generate_barren_terrain
  
  # Store BOTH
  @celestial_body.geosphere.terrain_map = {
    current_state: bare_terrain,        # Show this by default
    terraformed_goal: terraformed_data, # Show when biosphere layer active
    biosphere: { bio_density: Array.new(height) { Array.new(width, 0.0) } }
  }
end
```

### Step 3: Layer Toggle Fix (SimEarth-Style)

**Replace current toggle logic**:
```javascript
// Layer visibility state - terrain ALWAYS visible as base
let visibleLayers = new Set(['terrain']); // Terrain is permanent base

// Toggle layer visibility (ADDITIVE, not exclusive)
function toggleLayer(layerName) {
    if (layerName === 'terrain') {
        // Terrain is the geological base - cannot be turned off
        // Clicking it just ensures we're back to base view
        visibleLayers.clear();
        visibleLayers.add('terrain');
        logConsole('Showing base terrain (lithosphere)', 'info');
    } else {
        // All other layers are ADDITIVE overlays
        if (visibleLayers.has(layerName)) {
            visibleLayers.delete(layerName);
            logConsole(`${layerName} layer hidden`, 'info');
        } else {
            visibleLayers.add(layerName);
            logConsole(`${layerName} layer shown`, 'info');
        }
    }
    
    renderTerrainMap(); // Re-render with new layers
    updateLayerButtons();
}
```

### Step 4: Rendering Fix (Show Base + Overlays)

**Replace current rendering**:
```javascript
function renderTerrainMap() {
    // ... canvas setup ...
    
    const currentState = terrainData.current_state || terrainData; // Bare planet
    const bioDensity = terrainData.biosphere?.bio_density || null;
    const grid = currentState.grid;
    
    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            const terrainType = grid[y][x];
            const latitude = (y / height - 0.5) * 180;
            const elevation = calculateElevation(terrainType, latitude);
            
            // STEP 1: Base terrain (lithosphere - ALWAYS render)
            let baseColor = getTerrainColor(terrainType, elevation, latitude);
            
            // STEP 2: Apply layer overlays if active
            let finalColor = baseColor;
            
            // Water layer overlay (blue tint on ocean/ice)
            if (visibleLayers.has('water') && ['ocean', 'deep_sea', 'arctic'].includes(terrainType)) {
                const waterColor = layerOverlays.water.terrainColors[terrainType];
                finalColor = blendColors(finalColor, waterColor, 0.6);
            }
            
            // Biomes layer overlay (green vegetation based on bio_density)
            if (visibleLayers.has('biomes') && bioDensity) {
                const density = bioDensity[y][x];
                if (density > 0) {
                    const greenValue = Math.floor(255 * density);
                    const vegColor = `rgba(0, ${greenValue}, 0, ${density * 0.7})`;
                    finalColor = blendColors(finalColor, vegColor, density * 0.7);
                }
            }
            
            // Features layer overlay (geological highlights)
            if (visibleLayers.has('features') && ['rocky', 'boreal'].includes(terrainType)) {
                const featureColor = layerOverlays.features.terrainColors[terrainType] || '#696969';
                finalColor = blendColors(finalColor, featureColor, 0.5);
            }
            
            // Temperature layer overlay (SimEarth red/blue)
            if (visibleLayers.has('temperature')) {
                const tempColor = layerOverlays.temperature.getOverlayColor(
                    latitude, elevation, planetTemp, planetPressure
                );
                finalColor = blendColors(finalColor, tempColor, 0.4);
            }
            
            // Resources layer overlay (gold highlights)
            if (visibleLayers.has('resources') && ['rocky', 'arctic'].includes(terrainType)) {
                const resourceColor = '#FFD700';
                finalColor = blendColors(finalColor, resourceColor, 0.5);
            }
            
            // Render tile with final composited color
            ctx.fillStyle = finalColor;
            ctx.fillRect(x * tileSize, y * tileSize, tileSize, tileSize);
        }
    }
}
```

### Step 5: Base Terrain Color Function

**Add planet-appropriate base colors**:
```javascript
function getTerrainColor(terrainType, elevation, latitude) {
    const isMars = planetName.toLowerCase().includes('mars');
    const isVenus = planetName.toLowerCase().includes('venus');
    const isLuna = planetName.toLowerCase().includes('luna') || planetName.toLowerCase().includes('moon');
    
    // Base terrain colors (bare planet lithosphere)
    const baseColors = {
        desert: isMars ? '#C1440E' : '#F4A460',      // Mars: red-orange, Earth: sandy
        rocky: isMars ? '#8B4513' : '#696969',       // Mars: dark red, Earth: gray
        arctic: '#FFFFFF',                            // Ice/snow (all planets)
        ocean: '#004488',                             // Deep blue water
        deep_sea: '#002244',                          // Very deep blue
        plains: isMars ? '#B85C3E' : '#D2B48C',      // Mars: red-tan, Earth: tan
        tundra: '#C0C0C0',                            // Gray-white cold
        boreal: '#556B2F'                             // Dark olive green (minimal)
    };
    
    let baseColor = baseColors[terrainType] || '#4A3C28';
    
    // Apply elevation shading (darker = lower, lighter = higher)
    const elevationFactor = 1.0 + (elevation - 0.5) * 0.3; // ±15% brightness
    baseColor = adjustBrightness(baseColor, elevationFactor);
    
    // Apply planetary filters
    if (isMars) {
        baseColor = applyRedTint(baseColor, 0.3);
    } else if (isVenus) {
        baseColor = applyYellowTint(baseColor, 0.2);
    } else if (isLuna) {
        baseColor = desaturate(baseColor, 0.8);
    }
    
    return baseColor;
}
```

## Testing Plan

### Test 1: Bare Mars Display
1. Import Civ4 Earth map
2. Apply to Mars celestial body
3. TerrainTerraformingService converts terraformed → bare
4. Display should show:
   - Red desert terrain (no jungles/forests)
   - White polar ice caps
   - Rocky highlands
   - No vegetation (bio_density = 0.0)

### Test 2: Layer Toggles (SimEarth Style)
1. Start: Terrain layer only (bare Mars)
2. Toggle Water ON: Ice caps highlighted in blue
3. Toggle Biomes ON: No change (bio_density = 0.0)
4. Toggle Temperature ON: Red/blue temperature overlay
5. Toggle ALL layers: Composite view
6. Toggle ALL off: Back to bare terrain

### Test 3: Biosphere Growth Simulation
1. Start with bare planet (bio_density = 0.0)
2. AI builds foothold, begins terraforming
3. bio_density gradually increases (0.0 → 0.1 → 0.3 → ...)
4. With Biomes layer ON: See green spreading
5. Eventually approaches terraformed goal

## Documentation Updates Needed

### MAP_SYSTEM.md
- Update schema to show current_state vs terraformed_goal
- Document TerrainTerraformingService integration
- Explain bare planet concept

### LAYERED_RENDERING.md
- Clarify lithosphere is ALWAYS visible
- Document additive overlay system
- Remove any exclusive layer logic

### FREECIV_INTEGRATION.md
- Update import pipeline to use TerrainTerraformingService
- Document bare planet generation
- Explain biosphere overlay rendering

## Summary

**The core issue**: System currently treats FreeCiv maps as "current state" when they're actually "terraformed goals". Need to:

1. ✅ Use TerrainTerraformingService to generate realistic bare state
2. ✅ Fix layer toggles to be additive, not exclusive
3. ✅ Always show lithosphere (bare terrain) as base
4. ✅ Overlay water, biosphere, features, etc. on top
5. ✅ Support gradual biosphere growth (bio_density overlay)

This matches SimEarth's design and your gameplay concept!
