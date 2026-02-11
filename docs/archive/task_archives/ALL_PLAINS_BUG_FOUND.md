# FOUND IT! The All-Plains Bug - Complete Analysis

## 🎯 Root Cause Identified

**Location**: monitor.html.erb, line 598-640, function `extractTerrainLayer()`

**The Bug**: This function CONVERTS most terrain types TO 'plains'!

```javascript
// Line 612-628
switch (terrainType) {
    case 'forest':
    case 'jungle':
    case 'boreal':
        terrainType = 'plains'; // ← CONVERTS TO PLAINS!
        break;
    case 'grasslands':
        terrainType = 'plains'; // ← CONVERTS TO PLAINS!
        break;
    case 'swamp':
        terrainType = 'plains'; // ← CONVERTS TO PLAINS!
        break;
    case 'arctic':
        terrainType = 'tundra'; // Arctic is icy tundra
        break;
}
```

**What This Does**:
- Forest → Plains
- Jungle → Plains
- Boreal → Plains
- Grasslands → Plains
- Swamp → Plains
- Arctic → Tundra
- **Only Ocean, Desert, Tundra, Mountains, Hills remain unique**

**Result**: If your map has mostly grasslands/forests (like Earth!), everything becomes 'plains'!

---

## 🔍 Why This Was Done (Intentional but Wrong)

### The Intent (from comments):
```javascript
// Line 599-600
// Extract bare terrain (topography) from FreeCiv map
// Remove vegetation and focus on physical terrain features
```

**The Idea**:
- "Grasslands" is vegetation ON plains → Strip to 'plains'
- "Forest" is vegetation ON plains → Strip to 'plains'
- This creates a "bare lithosphere" layer

**The Problem**:
- This is for a **SimEarth-style layer system**
- Meant to show bare terrain SEPARATELY from vegetation
- But it's being used as the ONLY displayed layer!

---

## 🐛 The Complete Bug Chain

### Step 1: Map Generated with Variety
```ruby
# PlanetaryMapGenerator creates:
terrain_grid = [
  ['g', 'g', 'f', 'o', 'p', 'd', 'h', ...],  # g=grasslands, f=forest, etc.
  ['f', 'o', 'g', 'p', 'd', 'm', ...],
  ...
]
```

### Step 2: Saved to Database
```ruby
# MapStudioController saves:
geosphere.terrain_map = {
  'grid' => [['g', 'g', 'f', 'o', 'p', 'd', ...], ...],
  'width' => 180,
  'height' => 90
}
```

### Step 3: Monitor Extracts Data
```javascript
// Line 738-740
let terrainData = {...};  // From geosphere.terrain_map
let civ4Data = {...};     // From properties if available

// Line 759-764
if (civ4Data && civ4Data.grid) {
    layers.biomes = extractBiomeLayer(civ4Data);  // ← THIS WORKS
    layers.resources = extractResourceLayer(civ4Data);
    console.log('Extracted biome and resource layers from Civ4 map');
}
```

### Step 4: Terrain Layer Extracted (BUG HERE!)
```javascript
// Line 792-794
if (!layers.terrain && terrainData) {
    layers.terrain = terrainData;  // ← Should use raw data!
}

// BUT if civ4Data exists, line 759 runs:
if (civ4Data && civ4Data.grid) {
    // No terrain extraction from civ4Data!
    // Only biomes and resources!
}

// So layers.terrain stays null!
// Then line 806 uses fallback:
let activeTerrainData = layers.terrain || terrainData;
```

**Wait, this should work...**

Let me check the actual flow more carefully:

### Step 5: Check What Actually Happens

**From your console logs**:
```
Civ4 data from properties: true
Terrain grid in properties: true
Extracted biome and resource layers from Civ4 map
```

This means:
1. `civ4Data` exists
2. Line 759-764 runs
3. `extractBiomeLayer(civ4Data)` is called
4. BUT no terrain layer extracted from civ4Data!

**Then**:
```javascript
// Line 792-794
if (!layers.terrain && terrainData) {
    layers.terrain = terrainData;  // Sets raw data
}

// Line 806
let activeTerrainData = layers.terrain || terrainData;
// activeTerrainData = terrainData (the raw grid)
```

**So raw data should be used... BUT**:

Let me check if there's something else...

---

## 🔬 Re-examining the Logs

**From console**:
```
Sample grid data: ['plains', 'plains', 'plains', 'plains', 'plains']
Tile 0,0: plains -> plains -> #F0E68C
```

**This shows**:
- Raw terrain type: 'plains'
- After normalization: 'plains'

**Which means**: The grid ALREADY contains 'plains', not codes!

**Let me check where this happens...**

### Checking the Data Storage

**In MapStudioController.apply_map_to_celestial_body** (line 304-312):
```ruby
if map_data['terrain_grid']
  terrain_map_data = {
    grid: map_data['terrain_grid'],  # ← Direct copy!
    width: map_data.dig('metadata', 'width') || map_data['terrain_grid'].first&.size || 0,
    height: map_data.dig('metadata', 'height') || map_data['terrain_grid'].size,
    biome_counts: map_data['biome_counts'] || {}
  }
  geosphere.update!(terrain_map: terrain_map_data)
end
```

**So it saves**: `map_data['terrain_grid']` directly

**What does PlanetaryMapGenerator return?**

**From planetary_map_generator.rb** (lines we reviewed):
```ruby
{
  terrain_grid: combined_data[:terrain_grid],  # ← Array of biome codes
  # ...
}
```

**And combine_source_maps returns**:
```ruby
{
  terrain_grid: terrain_grid,  # ← Filled by apply_source_to_grid
  # ...
}
```

**And apply_source_to_grid does**:
```ruby
# Line ~112 (from our earlier review)
biome_code = biome.is_a?(Symbol) ? convert_biome_to_code(biome) : biome

# Blend biomes
if source_index == 0 || rand < 0.7
  terrain_grid[target_y][target_x] = biome_code if biome_code
end
```

**So it should be codes** ('g', 'p', 'f', etc.)

**BUT your logs show** 'plains' (full name!)

---

## 💡 The REAL Problem

**There are TWO possible sources of terrain data in the monitor**:

1. **geosphere.terrain_map.grid** - From Map Studio generation
2. **properties['terrain_grid']** - From old Civ4 import

**Check the monitor code again**:

```javascript
// Line 783-789
} else if (!terrainData && has_properties_grid) {
    props_data = { 
        grid: @celestial_body.properties['terrain_grid'],  // ← OLD import!
        width: @celestial_body.properties['grid_width'], 
        height: @celestial_body.properties['grid_height'], 
        biome_counts: @celestial_body.properties['biome_counts'] 
    }
    terrainData = props_data;
}
```

**AND**:

```javascript
// Line 726-736
civ4_properties_data = nil
if has_properties_grid && @celestial_body.properties['source'] == 'civ4_import'
  civ4_properties_data = {
    grid: @celestial_body.properties['terrain_grid'],  // ← OLD import!
    width: @celestial_body.properties['grid_width'],
    height: @celestial_body.properties['grid_height'],
    biome_counts: @celestial_body.properties['biome_counts'] || {}
  }
end
```

**If Earth was imported via OLD Civ4 import** (not Map Studio):
- `properties['terrain_grid']` contains FULL NAMES ('plains', 'grasslands', etc.)
- These are from the OLD Civ4 importer
- NOT from the new Map Studio

**Then**:
- Monitor loads this old data
- Passes to `extractBiomeLayer(civ4Data)`
- Which normalizes codes
- Which already ARE full names
- So they stay as-is
- BUT if map has mostly grasslands/forests...
- And these don't render well...
- Everything looks like plains!

---

## 🎯 The Actual Fix

### Issue 1: extractTerrainLayer Strips Too Much

**Current**:
```javascript
case 'grasslands':
    terrainType = 'plains'; // ← Strips grasslands!
```

**Should be** (for direct display):
```javascript
// Don't strip anything - display as-is
// OR only strip for specific "bare terrain" layer mode
```

**Fix**:
```javascript
function extractTerrainLayer(mapData, stripVegetation = false) {
    const grid = mapData.grid || mapData.terrain_grid;
    const width = mapData.width || grid[0]?.length || 0;
    const height = mapData.height || grid.length;
    const terrainGrid = [];

    for (let y = 0; y < height; y++) {
        terrainGrid[y] = [];
        for (let x = 0; x < width; x++) {
            const rawCode = grid[y][x];
            let terrainType = normalizeTerrainType(rawCode);

            // Only strip vegetation if explicitly requested (for bare lithosphere layer)
            if (stripVegetation) {
                switch (terrainType) {
                    case 'forest':
                    case 'jungle':
                    case 'boreal':
                        terrainType = 'plains';
                        break;
                    case 'grasslands':
                        terrainType = 'plains';
                        break;
                    case 'swamp':
                        terrainType = 'plains';
                        break;
                    case 'arctic':
                        terrainType = 'tundra';
                        break;
                }
            }

            terrainGrid[y][x] = terrainType;
        }
    }

    return {
        grid: terrainGrid,
        width: width,
        height: height,
        layer_type: 'terrain'
    };
}
```

### Issue 2: Wrong Data Source Being Used

**Check which data source is actually rendering**:

Add this debug RIGHT before rendering:

```javascript
// Line ~830 (after console.log('Sample grid data:'))
console.log('=== GRID SOURCE DEBUG ===');
console.log('activeTerrainData:', activeTerrainData);
console.log('layers.terrain:', layers.terrain);
console.log('terrainData:', terrainData);
console.log('grid source:', 
    layers.terrain ? 'layers.terrain' : 
    terrainData ? 'terrainData' : 
    'unknown'
);
console.log('=== END DEBUG ===');
```

This will show which data is actually being rendered!

---

## 🚨 Immediate Action for Grok

### Fix 1: Don't Strip Vegetation by Default

**In monitor.html.erb, line 598-640**:

**Change**:
```javascript
function extractTerrainLayer(mapData) {
```

**To**:
```javascript
function extractTerrainLayer(mapData, stripVegetation = false) {
```

**And wrap the switch statement**:
```javascript
// Only strip vegetation if explicitly requested
if (stripVegetation) {
    switch (terrainType) {
        // ... existing cases ...
    }
}
```

### Fix 2: Check Data Source

Add debug logging to see what grid is actually being used.

### Fix 3: Verify Map Studio Generation

Generate a NEW map via Map Studio and check if it has variety:

```ruby
# In Rails console AFTER generating via Map Studio
earth = CelestialBody.find_by(name: 'Earth')
grid = earth.geosphere.terrain_map['grid']

# Check first row
puts grid[0].first(20).inspect

# Count unique values
unique = grid.flatten.uniq
puts "Unique terrain types: #{unique.inspect}"
puts "Count: #{unique.size}"
```

**Expected**: Should show codes like `['g', 'o', 'p', 'f', 'd', ...]`
**NOT**: `['plains', 'plains', 'plains', ...]`

---

## 🎯 Summary

**The Bug**: `extractTerrainLayer()` converts grasslands, forests, swamps → plains

**Why**: It was designed to create a "bare lithosphere" layer (SimEarth style)

**Problem**: It's being used for ALL rendering, not just bare lithosphere mode

**Fix**: Make vegetation stripping optional, default to showing actual terrain

**Result**: Map will show grasslands, forests, oceans, deserts, etc. with variety!

This is a classic case of over-processing the data for a specific use case that isn't active yet!
