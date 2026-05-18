# 2026-03-01-HIGH-PHASE-2-REGIONAL-VIEW-IMPLEMENTATION

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority feature for phase 2 regional view implementation
**Supervision Level**: 🔴 Watched carefully

## Context
Galaxy Game planetary rendering system transitioning from Phase 1 planetary overview (4K canvas) to Phase 2 regional gameplay view (16K canvas) with sprite-based terrain rendering.

## Problem Statement
Current planetary view is static overview only. Need Civ4-style regional view with 16K canvas resolution, NASA biome to sprite mapping, unit movement layer preview, city placement zones, performance optimizations.

**Expected**: 16K regional view with sprite-based terrain rendering and gameplay layers.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `galaxy_game/app/javascript/admin/regional_view.js` | Regional view JS | Update canvas dimensions to 16384x8192 |
| `galaxy_game/app/javascript/admin/monitor.js` | Monitor JS | Adjust viewport calculations for 100m/pixel |
| `galaxy_game/public/images/galaxy_surface.png` | Sprite atlas | Create 288x32 sprite atlas (9 terrain sprites) |
| `galaxy_game/app/assets/javascripts/tileset_config.json` | Tileset config | Update JSON for regional view sprites |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/GUARDRAILS.md` | Layer rendering constraints |
| `docs/CONTRIBUTOR_TASK_PLAYBOOK.md` | Git workflow, testing protocols |
| `docs/ENVIRONMENT_BOUNDARIES.md` | Docker container operations |

## Implementation Steps
1. **Canvas scaling**: Update canvas dimensions to 16384x8192 in regional view JavaScript
2. **Viewport calculations**: Adjust coordinate systems for regional scale (100m/pixel)
3. **Sprite atlas**: Create galaxy_surface.png with 9 terrain sprites
4. **Biome mapping**: Implement NASA biome to sprite coordinate mapping logic
5. **Layer enhancement**: Add unit movement preview and city placement zone visualization
6. **Performance**: Implement viewport culling and sprite rendering optimizations

## Acceptance Criteria
- [ ] Regional view renders 16384x8192 canvas smoothly
- [ ] NASA biomes map correctly to 32x32 sprites
- [ ] Unit movement paths display over terrain
- [ ] City placement zones highlight available areas
- [ ] No performance degradation at 16K resolution

## Stop Conditions
- Performance below 60fps at regional scale
- Sprite mapping incorrect for NASA biomes

## Commit Instructions
```bash
git add galaxy_game/app/javascript/admin/regional_view.js
git add galaxy_game/app/javascript/admin/monitor.js
git add galaxy_game/public/images/galaxy_surface.png
git add galaxy_game/app/assets/javascripts/tileset_config.json
git add docs/TILESET_README.md
git add docs/PLANETARY_VIEW_INTENT.md
git commit -m "feat: phase 2 regional view — implement 16K canvas with sprite-based terrain rendering"
```