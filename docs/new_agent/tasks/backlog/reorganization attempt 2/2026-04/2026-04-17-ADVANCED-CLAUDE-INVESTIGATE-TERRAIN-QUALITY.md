# 2026-04-17-ADVANCED-CLAUDE-INVESTIGATE-TERRAIN-QUALITY

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Advanced investigation task for terrain quality issues audit
**Supervision Level**: 🔴 Watched carefully

## Context
Terrain rendering quality impacts gameplay, admin monitoring, scientific realism. Known issues: exoplanet terrain appears visually odd (too uniform/random), Earth terrain may have data/rendering fidelity problems. System uses NASA GeoTIFF for Sol bodies, learned patterns for exoplanets, sine wave fallback.

## Problem Statement
Terrain quality issues for both Earth (NASA GeoTIFF) and exoplanet procedural generation. Need clear baseline, root cause analysis, actionable recommendations.

**Expected**: Complete audit documenting all terrain quality issues with evidence, root causes, and improvement recommendations.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `docs/testing/terrain_quality_audit.md` | Audit findings | Create detailed documentation |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/javascript/admin/monitor.js` | Rendering code |
| `galaxy_game/app/services/terra_sim/terrain_service.rb` | Generation logic |
| `galaxy_game/app/services/star_sim/system_builder_service.rb` | Seed processing |

## Implementation Steps
1. **Earth terrain audit**: Verify NASA GeoTIFF loading, visual inspection, hydrosphere integration, performance
2. **Exoplanet investigation**: Check metadata, pattern loading, Civ4 reference, parameter analysis
3. **Visual quality assessment**: Identify specific issues, compare exoplanet vs Earth, verify planet-type matching
4. **Root cause documentation**: Catalog problems with evidence, trace code/data flow, provide recommendations

## Acceptance Criteria
- [ ] Earth NASA terrain loads and displays accurately
- [ ] Exoplanet terrain generation issues identified and documented
- [ ] Root causes evidenced with metadata/code/screenshots
- [ ] Clear distinction between code bugs and parameter/model issues
- [ ] Actionable recommendations for improvement provided
- [ ] Performance benchmarks established
- [ ] All findings documented in terrain_quality_audit.md

## Stop Conditions
- Root cause is architectural requiring major refactor
- Similar bug already fixed in newer commit

## Commit Instructions
```bash
git add docs/testing/terrain_quality_audit.md
git commit -m "docs: terrain quality audit — Earth and exoplanet terrain issues investigation and recommendations"
```