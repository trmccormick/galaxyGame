# 2026-03-01-HIGH-FEATURE-PHASE-2-REGIONAL-VIEW-IMPLEMENTATION

**Agent:** GPT-4.1 (0.33x)
**Priority:** HIGH
**Type:** FEATURE
**Status:** BACKLOG

## Context
Galaxy Game planetary rendering system transitioning from Phase 1 planetary overview (4K canvas) to Phase 2 regional gameplay view (16K canvas) with sprite-based terrain rendering.

## Problem
Current planetary view is static overview only. Need Civ4-style regional view with 16K canvas resolution, NASA biome to sprite mapping, unit movement layer preview, and city placement zones.

## Files
- app/assets/javascripts/regional_view.js
- app/assets/images/galaxy_surface.png
- data/galaxy_game_tileset.json
- spec/features/regional_view_spec.rb
- docs/TILESET_README.md
- docs/PLANETARY_VIEW_INTENT.md

## Steps
1. Update canvas dimensions to 16384x8192 in regional view JavaScript
2. Create galaxy_surface.png sprite atlas (288x32, 9 terrain sprites)
3. Update JSON tileset configuration for regional view
4. Implement NASA biome to sprite coordinate mapping logic
5. Add unit movement preview layer
6. Implement city placement zone visualization
7. Add viewport culling and performance optimizations
8. Create/update RSpec tests for regional view functionality

## Acceptance Criteria
- Regional view renders 16384x8192 canvas smoothly at 60fps
- NASA biomes map correctly to 32x32 sprites
- Unit movement paths display over terrain
- City placement zones highlight available areas
- All RSpec tests pass without database corruption

## Stop Condition
- Performance below 60fps at regional scale
- Sprite mapping fails for any NASA biome
- Database corruption during testing

## Commit Instructions
```
git add app/assets/javascripts/regional_view.js
git add app/assets/images/galaxy_surface.png
git add data/galaxy_game_tileset.json
git add spec/features/regional_view_spec.rb
git add docs/TILESET_README.md
git add docs/PLANETARY_VIEW_INTENT.md
git commit -m "feature: phase 2 regional view — 16K canvas with sprite-based terrain rendering"
```