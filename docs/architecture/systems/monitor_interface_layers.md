# Monitor Interface & Layer System Guardrails
**Location:** `docs/architecture/systems/monitor_interface_layers.md`  
**Source:** Extracted from `docs/GUARDRAILS.md` Section 14 (lines 578-612) during GUARDRAILS consolidation, 2026-07-03

---

## Layer Toggle Logic - SimEarth Additive Overlays
- **Terrain Base Layer:** Terrain is ALWAYS visible as the geological foundation (lithosphere) and cannot be toggled off.
- **Additive Overlays:** All other layers (water, biomes, features, temperature, rainfall, resources) are additive overlays that can be combined freely.
- **Reset Behavior:** Clicking the Terrain button resets view to bare planet (terrain only, all overlays removed).
- **Button States:** Layer buttons show active state when their layer is visible; terrain button is always available for reset.
- **Implementation:** Layer visibility uses `Set` data structure for efficient add/remove operations.

## Terrain Data Sources
- **Primary:** Geosphere.terrain_map (structured data with current_state vs terraformed_goal)
- **Fallback:** Properties.terrain_grid (legacy flat array format)
- **Validation:** System checks both sources and provides clear error messages when no terrain data exists
- **Rendering:** Canvas-based tile rendering with 8px tiles, planet-specific color schemes (Mars red-tints, Earth topographic)

## Civ4/FreeCiv Import Integration
- **Terraformed Input:** Imports treat Civ4/FreeCiv maps as "terraformed goals" (lush, habitable versions)
- **Bare Planet Output:** TerrainTerraformingService converts to realistic barren states based on planet characteristics
- **Dual Storage:** Both barren terrain (for display) and terraformed goal (for AI progression) are stored
- **Planet Classification:** Arid (Mars-like), Oceanic (Earth-like), Temperate, Ice World transformation rules

## Layer Overlay Definitions
- **Water Layer:** Blue highlights for ocean/deep_sea terrain types from FreeCiv water layer data
- **Biomes Layer:** Vegetation/climate overlays using Civ4 biome extraction (forest, jungle, grasslands, plains, tundra, arctic, swamp, boreal) with terrain-specific colors
- **Features Layer:** Geological highlights (rocky areas)
- **Temperature Layer:** SimEarth-style red/blue thermal gradients based on planetary conditions
- **Rainfall Layer:** Blue wetness indicators for jungle/swamp/forest terrain types
- **Resources Layer:** Gold highlights for mineral-rich terrain from Civ4 resource layer data

## Performance Considerations
- **Tile Size:** Fixed 8px tiles for consistent rendering across zoom levels
- **Canvas Dimensions:** Dynamically calculated from terrain grid dimensions
- **Elevation Calculation:** Planet-specific algorithms considering temperature, pressure, latitude
- **Color Blending:** Alpha compositing for smooth layer overlays
