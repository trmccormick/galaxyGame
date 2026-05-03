# Fix Terrain Pixelation and Resolution Issues

## Problem
Current terrain rendering uses a fixed 80×50 grid with 8-pixel tiles for ALL celestial bodies, causing severe pixelation. Small bodies like Luna cannot display craters because the grid resolution is too coarse relative to body size. The issue is grid resolution, not pixel resolution.

## Root Cause Analysis
1. **Fixed Grid Resolution**: 80×50 grid for all bodies regardless of diameter
2. **Fixed Tile Size**: 8×8 pixels per cell is too small for visible detail
3. **No Adaptive Scaling**: No size-based grid density adjustment
4. **Monitor vs Surface View**: Monitor uses pixel rendering, Surface uses tiles

## Current Implementation Issues
```javascript
// monitor.js - Problematic fixed resolution
const tileSize = 8;  // Always 8 pixels per cell
canvas.width = width * tileSize;  // 80 * 8 = 640px total
canvas.height = height * tileSize; // 50 * 8 = 400px total
```
This means Luna (diameter ~3,474km) uses the same grid as Earth (diameter ~12,742km), but features are much smaller relative to body size.

## Solution: Adaptive Resolution System

### Phase 1: Planet Size-Based Grid Scaling
```javascript
function calculateAdaptiveGrid(planetDiameterKm, targetMinResolution = 800) {
  // Scale grid size with planet diameter for consistent detail density
  const diameterRatio = planetDiameterKm / 12742; // Earth = 1.0
  const baseGridSize = Math.max(60, Math.min(200, 80 * Math.sqrt(diameterRatio)));

  // Calculate tile size to maintain minimum visible resolution
  const tileSize = Math.max(6, Math.min(20, targetMinResolution / baseGridSize));

  return {
    width: Math.floor(baseGridSize),
    height: Math.floor(baseGridSize * 0.625), // Maintain ~16:10 aspect
    tileSize: tileSize,
    totalWidth: baseGridSize * tileSize,
    totalHeight: baseGridSize * tileSize * 0.625
  };
}

// Examples:
// Earth (12742km): 80×50 grid, 12px tiles = 960×600px
// Mars (6792km): 60×37 grid, 16px tiles = 960×600px
// Luna (3474km): 45×28 grid, 20px tiles = 900×560px
// Phobos (22km): 30×19 grid, 24px tiles = 720×456px
```

### Phase 2: Enhanced Terrain Generation
- Modify `PlanetaryMapGenerator` to accept adaptive grid parameters
- Generate terrain at appropriate resolution for each body type
- Maintain backward compatibility with existing 80×50 data

### Phase 3: Multi-Level Rendering Pipeline
```javascript
function renderAdaptiveTerrain(canvas, terrainData, planetData) {
  const adaptive = calculateAdaptiveGrid(planetData.diameter);

  // Set canvas size based on planet characteristics
  canvas.width = adaptive.totalWidth;
  canvas.height = adaptive.totalHeight;

  // Render terrain with appropriate detail level
  renderTerrainWithDetail(canvas, terrainData, adaptive);
}
```

### Phase 4: Detail Enhancement for Small Bodies
- Implement crater detection algorithms for lunar surfaces
- Add surface texture overlays for rocky bodies
- Generate higher resolution elevation data for small moons/asteroids

## Implementation Plan

### Task 4.1: Adaptive Grid Calculation
- Implement `calculateAdaptiveGrid()` function
- Test with different planet sizes
- Validate detail scaling

### Task 4.2: Update Terrain Generation
- Modify `PlanetaryMapGenerator` for variable grid sizes
- Update terrain storage to handle different resolutions
- Ensure GeoTIFF processing works with adaptive grids

### Task 4.3: Enhanced Monitor Rendering
- Update `monitor.js` with adaptive tile sizing
- Implement smooth zoom with detail interpolation
- Add performance optimizations for large grids

### Task 4.4: Small Body Detail Enhancement
- Add crater generation for airless bodies
- Implement surface texture algorithms
- Test with Luna, Phobos, and asteroid belt objects

### Task 4.5: Quality Validation
- Compare crater visibility on lunar surfaces
- Test performance across different body sizes
- Validate zoom level detail progression
- Ensure FreeCiv compatibility maintained

## Success Criteria
- **Luna craters visible** at default zoom level
- **Earth maintains continental detail** without performance degradation
- **Gas giants show atmospheric bands** and storm systems
- **Zoom levels provide appropriate detail** progression (1x to 8x)
- **Rendering performance** remains smooth (60fps)
- **File sizes manageable** (< 100MB per high-detail planet)

## Files to Modify
- `app/services/ai_manager/planetary_map_generator.rb`
- `app/javascript/admin/monitor.js`
- `app/views/admin/celestial_bodies/monitor.html.erb`
- Terrain data storage and retrieval logic
- Surface view tile scaling (if needed)

## Testing Strategy
1. Generate test terrains for Earth, Mars, Luna, and Phobos
2. Compare crater visibility and surface detail
3. Performance benchmark rendering speeds
4. Validate zoom behavior and detail scaling
5. Test FreeCiv surface view compatibility

## Priority
High - Critical for terrain visualization quality and user experience