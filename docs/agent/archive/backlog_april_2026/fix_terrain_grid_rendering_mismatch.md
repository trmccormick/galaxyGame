# Terrain Rendering Pixelation Fix - Task Documentation

## Issue Summary
The terrain rendering system for small celestial bodies like Luna (the moon) does not display surface features like craters due to pixelation issues. The current adaptive grid system calculates tile sizes based on expected grid dimensions rather than actual terrain data dimensions, causing mismatches between generated grids and rendering parameters.

## Root Cause Analysis
1. **Grid Generation**: The backend correctly generates different map grids based on planetary diameter (Luna gets 60x37, Mars gets 90x56, etc.) for procedural generation, but uses fixed 80x50 dimensions when combining source maps.

2. **Rendering Mismatch**: The JavaScript `calculateAdaptiveGrid()` function calculates tile sizes based on expected grid dimensions from diameter calculations, but doesn't account for the actual grid dimensions present in the terrain data.

3. **Pixelation Result**: This mismatch results in incorrect canvas sizing and tile scaling, making small features like lunar craters invisible.

## Current System State
- **Backend**: `PlanetaryMapGenerator.rb` has `calculate_adaptive_grid_size()` method that scales grid dimensions by planetary diameter
- **Frontend**: `monitor.js` has `calculateAdaptiveGrid()` function that calculates tile sizes but ignores actual terrain data dimensions
- **Controller**: `map_studio_controller.rb` passes adaptive options to generation

## Required Fix
Modify the `calculateAdaptiveGrid()` function in `monitor.js` to:
1. Use the actual grid width from `terrainData` for base tile size calculation
2. Apply diameter-based adjustments for special cases (moons, small bodies, gas giants)
3. Ensure consistent canvas sizing while maintaining appropriate detail levels

## Implementation Steps
1. Update `calculateAdaptiveGrid(planetData, terrainData)` to prioritize `terrainData.width` over diameter-based grid size calculations
2. Add special case adjustments for celestial body types (moons get larger tiles for feature visibility)
3. Test rendering with Luna terrain data to verify crater visibility
4. Validate that Mars and other bodies maintain appropriate detail levels

## Success Criteria
- Luna craters are clearly visible in the monitor interface
- Canvas sizes are consistent across different body types
- Grid resolution scales appropriately with planetary size
- No performance degradation on large grids

## Files to Modify
- `galaxy_game/app/javascript/admin/monitor.js` - Update `calculateAdaptiveGrid()` function

## Testing Requirements
- Load Luna terrain in monitor interface
- Verify crater features are visible
- Test with Mars, Earth, and asteroid terrain
- Check canvas dimensions and rendering performance