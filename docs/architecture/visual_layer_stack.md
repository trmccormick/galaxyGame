# Visual Layer Stack Architecture
**Status**: STUB — needs full documentation  
**Last Updated**: 2026-03-22  
**Author**: Session Strategist (Claude)  

> ⚠️ This is a stub document capturing verbal architectural decisions.
> A full documentation pass is needed — see bottom of this file for scope.

---

## Overview

The game rendering system has three distinct visual layers, each representing
a different zoom level and interaction mode. They are independent systems that
share underlying data but render it differently.

---

## Layer 1 — Planetary (Orbital View)

**Analogy**: SimEarth  
**Status**: ✅ Working  

What it shows:
- Colored biome tiles visible from orbit
- GeoTIFF heightmap terrain elevation
- Atmosphere, ice caps, ocean coverage
- Planet-scale features (continents, polar regions)

Key files:
- `app/services/ai_manager/planetary_map_generator.rb`
- `app/javascript/monitor.js`
- `app/views/admin/celestial_bodies/monitor.html.erb`
- `app/javascript/biome_renderer.js`
- `/public/tilesets/galaxy_game/biomes.json`

Data sources:
- NASA GeoTIFF elevation data for Sol bodies (Earth, Mars, Luna, Venus, Mercury, Titan)
- NASA pattern files for procedural exoplanet generation
- Biome JSON config at `/public/tilesets/galaxy_game/biomes.json`

Notes:
- FreeCiv/Civ4 assets are **reference data only** — not used directly
- BiomeRenderer loads 10 individual biome PNGs (142×142px, crisp nearest-neighbour)
- Fallback to solid colour when PNG unavailable

---

## Layer 2 — Surface (Ground View)

**Analogy**: FreeCiv / Civilization IV  
**Status**: 🔄 In Progress  

What it shows:
- Terrain tiles at ground level
- Unit movement and direction
- Settlements, infrastructure, resources visible on map
- Local area navigation

Key files:
- `app/javascript/surface_view.js`
- `app/views/admin/celestial_bodies/surface.html.erb`

Tileset definitions:
- `app/data/json-data/tilesets/surface/` — terrain tile sprite sheets
- `galaxy_regional_atlas.json` — defines terrain tiles (ocean, plains, desert,
  forest, mountains, tundra, grasslands, swamp, jungle) at 32px per tile

Notes:
- Uses custom JSON-based tileset system — not FreeCiv/Civ4 format directly
- FreeCiv/Civ4 biome and terrain data used as **reference** for tile design
- Tile size: 32px, sprite sheet format PNG

---

## Layer 3 — TerraForge (Settlement View)

**Analogy**: SimCity  
**Status**: 🔄 In Progress  

What it shows:
- Zone management (residential, industrial, agricultural etc.)
- Building placement and construction
- Settlement infrastructure density
- Resource flow within a settlement footprint

Key files:
- TBD — needs investigation

Notes:
- Zoomed in to a single settlement location
- Distinct from surface layer — different interaction model
- Connects to manufacturing, life support, and resource systems

---

## Layer Relationships

```
Orbital View (Layer 1)
  └─ Click on surface → enters Surface View (Layer 2)
       └─ Click on settlement → enters TerraForge View (Layer 3)
            └─ Back → returns to Surface View
```

Data flows down — planetary data informs surface terrain, surface terrain
informs settlement placement options in TerraForge.

---

## Shared Data Sources

| Data | Used By |
|---|---|
| GeoTIFF heightmaps | Layer 1 (elevation), Layer 2 (terrain type) |
| Biome classification | Layer 1 (tile color), Layer 2 (terrain tiles) |
| Settlement locations | Layer 1 (marker), Layer 2 (unit), Layer 3 (full view) |
| Resource deposits | Layer 2 (map icon), Layer 3 (extraction zone) |

---

## What Is NOT In Scope

- FreeCiv/Civ4 assets are reference only — no direct asset pipeline dependency
- Supercritical fluid simulation (Venus atmosphere) — deferred, flagged as extreme hazard
- Exotic layer configurations (Titan subsurface ocean etc.) — future enhancement

---

## Full Documentation Needed

This stub needs to be expanded with:
- [ ] Complete file inventory per layer
- [ ] Data flow diagrams between layers
- [ ] TerraForge layer file inventory
- [ ] Tileset system specification (JSON format, how tiles are defined)
- [ ] How biome data connects to surface tile selection
- [ ] Pan/zoom state management across layers
- [ ] Performance notes (20fps target, offscreen canvas approach)
- [ ] How new planets get their layer data generated

**Assign to**: Claude Sonnet (1x) — needs code review of all six layer files
**Reference files**: `monitor.js`, `surface_view.js`, `biome_renderer.js`,
  `monitor.html.erb`, `surface.html.erb`, `MAP_SYSTEM.md`
**Estimated effort**: 1 session
