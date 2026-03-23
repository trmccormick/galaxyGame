# StarSim — PROCEDURAL_INTENT.md

## Data Fusion Goal
The objective is to merge 'Civ4 Intel' (tile-based, playability-focused maps) with 'NASA-style Procedural Heightmaps' (realistic elevation and erosion patterns) to generate planetary surfaces that are both scientifically plausible and gameplay-balanced.

### Mapping Strategy
- **Civ4/FreeCiv Data:** Provides tile-based biome, resource, and terrain distribution patterns, emphasizing playability, balance, and recognizable landforms (continents, islands, etc.).
- **NASA GeoTIFFs:** Supply high-fidelity elevation data and multi-octave erosion/shoreline realism, preventing unrealistic flooding and supporting natural coastlines.
- **Fusion Approach:**
  - (Planned) Normalize NASA elevation data to Civ4 tile grid, assigning average elevation to each tile.
  - Use Civ4 patterns to seed biome/resource placement, then overlay NASA-style heightmap for elevation and shoreline realism.
  - Avoid 'noisy' output by introducing multi-octave erosion and smoothing, as found in NASA datasets, rather than pure random/procedural generation.

## Current Gaps
- No direct normalization or mapping logic found in lib/training_data/ or app/models/ai_manager/.
- ProceduralGenerator in StarSim does not yet mimic NASA patterns for non-Solar systems; it uses random sampling and template variation, leading to noisy, less coherent worlds.
- Multi-octave erosion and shoreline logic are missing, resulting in flooding and unnatural coastlines in procedural output.

## Intent
- The next generation of the generator should:
  - Map NASA elevation to Civ4 tiles for all training and procedural output.
  - Use Civ4/FreeCiv patterns to guide biome/resource placement.
  - Apply NASA-style erosion and smoothing to all heightmaps, especially for non-Solar systems.
  - Ensure shorelines and landforms are both playable and physically plausible.

---

*This document defines the intent and strategy for fusing AI training data and procedural logic to achieve realistic, balanced planetary generation.*
