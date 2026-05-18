# 2026-04-17-MEDIUM-IMPLEMENT-SCIENTIFIC-DATA-DISPLAY

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for scientific data display implementation
**Supervision Level**: 🔴 Watched carefully

## Context
Add scientific data display layer to admin monitor interface, visualizing atmospheric, geological, orbital, and research data as overlays. Integrate with .ggmap scientific layer and ensure UI, backend, data schema alignment.

## Problem Statement
No scientific data display layer in monitor UI. No visualization of atmospheric, geological, orbital, research data as overlays.

**Expected**: Scientific layer toggle in monitor interface with atmospheric, geological, orbital data display, clear visualizations, proper integration.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `galaxy_game/app/javascript/admin/scientific_layer.js` | Scientific layer JS | Implement overlay rendering |
| `galaxy_game/app/services/scientific_data_service.rb` | Data service | Aggregate scientific data |
| `galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb` | Monitor view | Add scientific layer toggle |
| `galaxy_game/app/javascript/admin/monitor.js` | Monitor JS | Support scientific overlay rendering |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/developer/UI_IMPLEMENTATION.md` | UI implementation guide |
| `galaxy_game/app/controllers/celestial_bodies_controller.rb` | Data source |
| `galaxy_game/app/controllers/terrestrial_planets_controller.rb` | Data source |

## Implementation Steps
1. **BLOCKED**: Wait for GGMAP scientific layer and format completion
2. **UI toggle**: Add scientific layer toggle in monitor.html.erb
3. **Overlay rendering**: Update monitor.js for scientific overlay support
4. **Data aggregation**: Aggregate data from backend endpoints
5. **Visual design**: Design overlay visuals for atmospheric, geological, orbital data
6. **Performance**: Implement caching, lazy loading optimizations

## Acceptance Criteria
- [ ] Scientific layer toggle available in monitor interface
- [ ] Atmospheric, geological, and orbital data display correctly
- [ ] Data visualizations are clear and scientifically accurate
- [ ] Layer integrates properly with existing terrain layers
- [ ] Performance impact is minimal when layer is inactive
- [ ] UI and code changes are documented

## Stop Conditions
- GGMAP scientific layer schema not finalized
- Monitor UI cannot support additional overlays without major refactor

## Commit Instructions
```bash
git add galaxy_game/app/javascript/admin/scientific_layer.js
git add galaxy_game/app/services/scientific_data_service.rb
git add galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb
git add galaxy_game/app/javascript/admin/monitor.js
git add docs/developer/UI_IMPLEMENTATION.md
git commit -m "feat: scientific data display — implement monitor UI scientific layer overlay"
```