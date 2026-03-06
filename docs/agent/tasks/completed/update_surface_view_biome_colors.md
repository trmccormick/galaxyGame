# Update Surface View Biome Color Map

## Assigned Agent
Gemini 3 Flash - JavaScript biome mapping modification (very cost-effective at 0.033x)

## Overview
Make biome color mapping in `surface_view.js` exhaustive and exact based on canonical biome list. Remove substring guessing and ensure all 15 valid biomes are properly handled.

## Issues Addressed
- Current biome color logic uses substring matching and guessing
- Not all biomes from canonical list are explicitly handled
- Should use exact matches for the 15 valid biome types

## Canonical Biome List
From `normalize_biome_type` and `classify_earth_biome_realistic`:
- arctic, tundra, ice, boreal_forest, temperate_forest
- tropical_rainforest, tropical_seasonal_forest, desert
- grassland, plains, savanna, jungle, wetlands, swamp

## Technical Details
- Location: `surface_view.js`, `_getBiomeColor` and `_biomeTileKey` methods
- Current: Uses includes() and substring logic
- Target: Exact string matching with comprehensive switch/case or object lookup
- Remove fallback guessing logic

## Implementation Steps
1. Review current `_getBiomeColor` implementation
2. Create exhaustive mapping for all 15 biome types
3. Update `_biomeTileKey` to use exact matches
4. Test with various biome grids to ensure no missing colors
5. Verify no visual regression in surface view rendering

## Success Criteria
- All 15 canonical biomes have explicit color mappings
- No substring guessing or fallback logic
- Consistent biome rendering across all planetary types
- Improved visual accuracy for terrain display</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/update_surface_view_biome_colors.md