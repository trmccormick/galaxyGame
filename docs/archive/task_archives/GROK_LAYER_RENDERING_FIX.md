# CRITICAL RENDERING FIX NEEDED - Layer System Not Working

## Problem Statement

The monitor view is rendering biomes directly into the base terrain, making it impossible to see the raw elevation heightmap. Layer toggles don't actually separate the data - everything is baked together.

## What We Need (SimEarth-Style Layers)

### BASE LAYER (Always Visible - Cannot Toggle Off)
**Pure Elevation Heightmap - No Biomes, No Water**

Color scheme based ONLY on elevation values:
- **Deep areas** (low elevation): Dark blue/black shades
- **Sea level to low land**: Dark browns
- **Medium elevations**: Lighter browns/tans
- **High elevations**: Light tans/grays
- **Peaks**: White/light gray

Example color mapping for Earth (-11000m to +8848m):
```javascript
function getElevationColor(elevationMeters) {
  if (elevationMeters < -8000) return '#0a0a1a';  // Deep ocean trenches - very dark
  if (elevationMeters < -4000) return '#1a1a3a';  // Deep ocean
  if (elevationMeters < -200)  return '#2a2a4a';  // Ocean floor
  if (elevationMeters < 0)     return '#3a3a5a';  // Shallow ocean
  if (elevationMeters < 200)   return '#4a3a2a';  // Coastal lowlands - dark brown
  if (elevationMeters < 500)   return '#5a4a3a';  // Plains - medium brown
  if (elevationMeters < 1000)  return '#6a5a4a';  // Hills - lighter brown
  if (elevationMeters < 2000)  return '#7a6a5a';  // Mountains - tan
  if (elevationMeters < 4000)  return '#8a7a6a';  // High mountains - light tan
  if (elevationMeters < 6000)  return '#9a8a7a';  // Very high - gray-tan
  return '#aaaaaa';                                // Peaks - light gray
}
```

This should look like a **topographic relief map** - purely physical terrain with NO life indicators.

### LAYER 1: Water (Toggleable)
When enabled:
- Read `hydrosphere` data from terrain_map
- Use bathtub physics: fill all areas below water level with blue
- Water level determined by hydrosphere volume
- Render semi-transparent blue over the base elevation colors
- When disabled: water areas show base elevation colors (dark because they're low)

### LAYER 2: Biomes (Toggleable)  
When enabled:
- Read `biomes` grid from terrain_map
- Render biome colors (green for forests, tan for deserts, etc.)
- Overlay on top of base elevation + water
- When disabled: only see elevation heightmap (and water if that's on)

### LAYER 3: Resources/Strategic Markers (Toggleable)
When enabled:
- Show resource locations, strategic markers, settlements
- When disabled: clean terrain view

## Current Problem

Looking at the recent fixes, it appears:
1. Biomes are being generated FROM elevation and baked into the rendering
2. The layer toggles don't actually separate the data sources
3. Everything renders as green because biomes are always applied
4. Cannot see the raw NASA elevation data as a pure heightmap

## Required Changes

### 1. Separate the Data Layers
```javascript
// Base elevation rendering (ALWAYS active)
function renderBaseElevation(ctx, terrainMap) {
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const elevationMeters = terrainMap.elevation[y][x];
      const color = getElevationColor(elevationMeters);
      // Draw pixel with elevation color ONLY
      ctx.fillStyle = color;
      ctx.fillRect(x * scale, y * scale, scale, scale);
    }
  }
}

// Water layer (ONLY if toggle is ON)
function renderWaterLayer(ctx, terrainMap, waterToggle) {
  if (!waterToggle) return;
  
  const waterLevel = calculateWaterLevel(terrainMap.hydrosphere);
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const elevation = terrainMap.elevation[y][x];
      if (elevation < waterLevel) {
        // Render semi-transparent blue over base color
        ctx.fillStyle = 'rgba(30, 58, 138, 0.7)';
        ctx.fillRect(x * scale, y * scale, scale, scale);
      }
    }
  }
}

// Biome layer (ONLY if toggle is ON)
function renderBiomeLayer(ctx, terrainMap, biomeToggle) {
  if (!biomeToggle) return;
  
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const biome = terrainMap.biomes[y][x];
      if (biome && biome !== 'none') {
        const color = getBiomeColor(biome);
        ctx.fillStyle = color;
        ctx.fillRect(x * scale, y * scale, scale, scale);
      }
    }
  }
}
```

### 2. Remove Biome Generation from Elevation
The code at lines ~703-764 that generates biomes from elevation should be REMOVED or only used as fallback if `terrain_map.biomes` is completely missing. It should NOT override real biome data.

### 3. Fix Layer Toggle Logic
```javascript
function renderTerrain() {
  clearCanvas();
  
  // ALWAYS render base elevation
  renderBaseElevation(ctx, terrainMap);
  
  // Conditionally render layers based on toggles
  if (layerToggles.water) {
    renderWaterLayer(ctx, terrainMap, true);
  }
  
  if (layerToggles.biomes) {
    renderBiomeLayer(ctx, terrainMap, true);
  }
  
  if (layerToggles.resources) {
    renderResourceLayer(ctx, terrainMap, true);
  }
}
```

### 4. Default State
When the monitor loads:
- Base elevation: Always visible (cannot disable)
- Water layer: OFF by default
- Biome layer: OFF by default  
- Resource layer: OFF by default

User can toggle each layer on to see additional information overlaid on the heightmap.

## Expected Result

**With all layers OFF:**
Should see a brown/tan/white topographic map showing mountains, valleys, ocean basins as different shades - like looking at a physical relief globe with no water or life.

**Water toggle ON:**
Low areas fill with blue (oceans, lakes) based on hydrosphere data.

**Biome toggle ON:**
Land areas show green (forests), tan (deserts), etc. based on actual biome data.

**All layers ON:**
Full colored map with water, vegetation, and terrain visible.

## Files to Check/Modify

1. **monitor.html.erb** - Main rendering logic, layer toggle handlers
2. **automatic_terrain_generator.rb** - Ensure it's storing elevation in METERS (not normalized 0-1)
3. **geotiff_reader.rb** - Verify it's extracting real elevation values from NASA data

## Validation

After fixes, test by:
1. Load Earth in monitor view
2. ALL layer toggles should be OFF initially
3. Should see brown/tan heightmap showing continents as raised areas, oceans as dark blue/black depressions
4. Toggle water ON → oceans fill with blue
5. Toggle biomes ON → land turns green/tan based on vegetation
6. Toggle each OFF individually → should revert to pure heightmap

The key is: **Base layer = pure topography, everything else = optional overlays**.

## Reference

This is how SimEarth rendered maps:
- Base = elevation relief (always visible)
- Water = bathtub fill (toggle)
- Life = biosphere layer (toggle)
- Civilization = settlements/cities (toggle)

We need the same clean separation.
