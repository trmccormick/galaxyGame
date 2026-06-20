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
// ...existing code...
