# Separate Biome Data from Geosphere

**Priority:** Medium
**Type:** Refactor/Data Integrity
**Status:** Not Started

## Problem
Biome data is currently mixed into geosphere data (terrain_map.biomes), which may cause simulation and modularity issues, especially for TerraGen and future biosphere extensions.

## Goals

## Goals
- Refactor planetary data structures so biome/ecological data is stored in biosphere, not geosphere.
- Ensure terrain_map in geosphere only contains physical/geological data (no biomes).
- Link biome grid to geosphere grid via coordinates, not embedding.
- Update monitor view and TerraGen logic to use separated data.
- Only generate/store biome data for worlds with an active biosphere (e.g., Earth).
- For barren worlds, omit biome grid entirely from geosphere/terrain_map.
- Clean up existing geosphere data for non-biosphere worlds by removing biome grids.

## Acceptance Criteria
1. Update terrain generation logic:
	- Only generate biome grid if biosphere is active.
	- Store biome grid in biosphere model/data, not geosphere.
2. Refactor geosphere/terrain_map:
	- Remove biomes key for worlds without biosphere.
	- Ensure monitor view and TerraGen reference biosphere for biome data.
3. Migration/cleanup:
	- Write script to remove biome grids from geosphere/terrain_map for all worlds except those with active biosphere.
	- Move any relevant biome data to biosphere for Earth or other biosphere worlds.
4. Documentation:
	- Update docs to clarify separation of geosphere and biosphere data.
5. Testing:
	- Validate monitor view, TerraGen, and simulation logic with new structure.
	- Check performance and memory usage improvements.
- No biome data stored in geosphere model or terrain_map.
- Biome data is accessible via biosphere or biome layer.
- Coordinate with TerraGen and biosphere simulation maintainers.
- Test for performance and rendering impacts.

---
Created: 2026-02-22
