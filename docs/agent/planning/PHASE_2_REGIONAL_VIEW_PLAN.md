# Phase 2: Regional View Implementation Plan

**Regional View - Phase 2 (Mar 2026 READY)**

**PURPOSE:** Civ4-style regional gameplay view with unit movement and city placement

**RESOLUTION:** 16384x8192 canvas (100m/pixel resolution)

**LAYERS:**
- NASA biome → 32x32 sprite atlas mapping
- Unit movement layer preview
- City placement zones (worldhouses)
- Terrain features and resources

**DELIVERABLES:**
- Canvas scaling: 16384x8192 (16K regional view)
- JSON tileset: galaxy_surface.png (288x32, 9 terrain sprites)
- NASA biome → sprite mapping logic implementation
- Viewport culling optimization for performance
- Unit movement preview layer
- City placement zone visualization

**TECHNICAL REQUIREMENTS:**
1. **Canvas Scale:** 16384x8192 pixels (100m/pixel)
2. **Tileset:** galaxy_surface.png sprite sheet (288x32 dimensions, 9 terrain types)
3. **Biome Mapping:** NASA biome data → sprite atlas coordinates
4. **Performance:** Viewport culling for large canvas rendering
5. **Layers:** Terrain base + unit movement overlay + city zones

**SUCCESS CRITERIA:**
- Smooth 60fps rendering at 16K resolution
- Accurate NASA biome → sprite mapping
- Unit movement paths visible
- City placement zones clearly marked
- Viewport culling prevents performance issues