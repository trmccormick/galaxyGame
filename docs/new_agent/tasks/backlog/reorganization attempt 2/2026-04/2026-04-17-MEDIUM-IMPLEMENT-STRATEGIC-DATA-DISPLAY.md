# 2026-04-17-MEDIUM-IMPLEMENT-STRATEGIC-DATA-DISPLAY

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for strategic data display implementation
**Supervision Level**: 🔴 Watched carefully

## Context
Add strategic data display layer to admin monitor interface, visualizing economic zones, development priorities, military considerations as overlays. Integrate with .ggmap strategic layer.

## Problem Statement
No strategic data display layer in monitor UI. No visualization of economic, development, military overlays beyond basic terrain data.

**Expected**: Strategic layer toggle in monitor interface with economic zones, trade routes, development hubs, military data overlays.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `galaxy_game/app/javascript/admin/strategic_layer.js` | Strategic layer JS | Implement overlay rendering |
| `galaxy_game/app/services/strategic_data_service.rb` | Data service | Aggregate strategic/economic data |
| `galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb` | Monitor view | Add strategic layer toggle |
| `galaxy_game/app/javascript/admin/monitor.js` | Monitor JS | Support strategic overlay rendering |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/developer/UI_IMPLEMENTATION.md` | UI implementation guide |
| `galaxy_game/app/controllers/celestial_bodies_controller.rb` | Data source |
| `galaxy_game/app/controllers/admin/dashboard_controller.rb` | Data source |

## Implementation Steps
1. **BLOCKED**: Wait for GGMAP strategic layer and format completion
2. **UI toggle**: Add strategic layer toggle in monitor.html.erb
3. **Overlay rendering**: Update monitor.js for strategic overlay support
4. **Data aggregation**: Aggregate strategic/economic/military data from backend
5. **Visual design**: Design overlay visuals for economic zones, trade routes, development hubs
6. **Multi-scale**: Support planetary, system, galactic scale overlays

## Acceptance Criteria
- [ ] Strategic layer toggle available in monitor interface
- [ ] Economic, development, and military overlays display correctly
- [ ] Multiple overlays can be combined and toggled
- [ ] Layer supports planetary, system, and galactic scales
- [ ] Performance remains acceptable
- [ ] UI and code changes are documented

## Stop Conditions
- GGMAP strategic layer schema not finalized
- Monitor UI cannot support additional overlays without major refactor

## Commit Instructions
```bash
git add galaxy_game/app/javascript/admin/strategic_layer.js
git add galaxy_game/app/services/strategic_data_service.rb
git add galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb
git add galaxy_game/app/javascript/admin/monitor.js
git add docs/developer/UI_IMPLEMENTATION.md
git commit -m "feat: strategic data display — implement monitor UI strategic layer overlay"
```