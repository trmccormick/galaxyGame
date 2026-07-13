# Planetary View Biome Rendering - Debug Test Plan

## Summary of Changes

I've added comprehensive diagnostic logging to `monitor.js` to identify why the biomes layer isn't rendering in the planetary view, even though:
- ✅ Biomes data EXISTS in the database (verified in Rails console)
- ✅ Biomes dimensions MATCH elevation (90x180 for both)
- ✅ Surface view WORKS (biomes render correctly)
- ✅ Other layers (heat, rainfall, hydrosphere) WORK in planetary view

## Enhanced Logging Added

1. **Initialization data inspection** - Shows what terrain data was received
2. **Biome grid validation errors** - Specific reason if grid isn't loaded
3. **Layer availability status** - Confirms biomes layer is ready
4. **Render statistics** - Tracks which layers are actually rendering

## Test Steps

### Step 1: Open Developer Tools
```
Press F12 or Cmd+Option+I
Click the "Console" tab
```

### Step 2: Navigate to Planetary View
```
Open http://localhost:3000/admin/celestial_bodies/2493/planetary
(This is Earth)
```

### Step 3: Check Initialization Logs
Look for messages like:
```
🌍 Received terrain_data for Earth {
  has_biomes: true,
  biomes_is_array: true,
  biomes_length: 16200,
  has_elevation: true,
  has_resources: true
}

✅ Biomes layer READY for rendering
```

### Step 4: Click Biomes Button (in sidebar)
Watch the console for:
- `Biomes overlay shown` or `Biomes overlay hidden`
- The render stats line showing biome status
- Any warning messages (❌ or ⚠️)

### Step 5: Check Other Layers for Comparison
Click Temperature, Rainfall buttons - note if they work and compare console output.

## Expected Behavior

### If biomes DATA loads correctly:
```console
🌍 Received terrain_data for Earth {
  has_biomes: true,
  biomes_is_array: true,
  biomes_length: 16200,  ← This should show 16200 (90x180)
  has_elevation: true,
  has_resources: true
}

✅ Biomes layer READY for rendering

Rendered stats: ✅ Biomes active, ✅ Hydrosphere active, ...
```

### If biomes DATA is missing:
```console
🌍 Received terrain_data for Earth {
  has_biomes: false,  ← FALSE means data not in JSON
  biomes_is_array: false,
  biomes_length: 'N/A',
  has_elevation: true,
  has_resources: true
}

⚠️  Biomes layer NOT available

❌ Biomes: terrainData.biomes is null/undefined
```

### If dimension mismatch:
```console
❌ Biomes: height mismatch - biomes: 90 vs elevation: 180
```

## Key Diagnostic Outputs

Copy-paste any relevant console messages when reporting issues, especially:
- The "🌍 Received terrain_data" block
- Any "❌" error messages
- The "Rendered stats:" line when you click biomes button

## Database Verification (Already Done)

Earth's biome distribution:
```
Biome distribution on Earth:
  ice: 2218 (40.13%)
  temperate_forest: 764 (13.82%)
  tundra: 740 (13.39%)
  desert: 685 (12.39%)
  tropical_seasonal_forest: 380 (6.88%)
  plains: 247 (4.47%)
  tropical_rainforest: 209 (3.78%)
  jungle: 186 (3.37%)
  wetlands: 61 (1.1%)
  grassland: 37 (0.67%)

Total biome cells: 5,527 (34.24%)
Nil cells (ocean): 10,673 (65.76%)
```

All these biome types have color mappings in the JavaScript code.

## Next Steps Based on Findings

**If data shows as missing (`biomes_is_array: false`):**
- Issue is in how ERB is serializing terrain_map to JSON
- Need to check if large arrays are being truncated

**If data loads but doesn't render:**
- Issue is in the rendering loop logic
- May be related to Turbo/Hotwire page state

**If rendering works on reload:**
- Timing issue with initialization
- Need better Turbo lifecycle handling

## Run This After Testing

After checking the console, run this command to verify data is still in DB:

```bash
cd /Users/tam0013/Documents/git/galaxyGame && \
docker-compose -f docker-compose.dev.yml exec -T web rails c << 'EOF'
earth = CelestialBodies::CelestialBody.find(2493)
puts "Biomes in DB: #{earth.geosphere.terrain_map['biomes'].present?}"
puts "Biomes length: #{earth.geosphere.terrain_map['biomes']&.length}"
puts "Elevation length: #{earth.geosphere.terrain_map['elevation']&.length}"
EOF
```

---

**Report Format**: Include:
1. Console log showing "🌍 Received terrain_data" message
2. Whether clicking biomes button works
3. Any error messages (❌ or 🔴)
4. Output from verification command above
