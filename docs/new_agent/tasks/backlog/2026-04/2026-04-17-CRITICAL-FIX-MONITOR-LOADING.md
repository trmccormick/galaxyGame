# 2026-04-17-CRITICAL-FIX-MONITOR-LOADING

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Critical bug fix for monitor loading and canvas initialization
**Supervision Level**: 🔴 Watched carefully

## Context
Admin monitor page for celestial bodies fails to load map/canvas on first load, requiring manual refresh. Likely race condition or async/timing issue between data fetch and canvas rendering.

## Problem Statement
Monitor interface intermittently fails to display map/canvas on initial load. Blocking issue for system administration and monitoring.

**Expected**: Monitor loads map/canvas for all celestial bodies on first load, no refresh required.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/javascript/admin/monitor.js` | Canvas rendering | Fix async/data race conditions |
| `app/views/admin/celestial_bodies/monitor.html.erb` | UI template | Add loading indicators, error messages |
| `app/controllers/admin/celestial_bodies_controller.rb` | Data controller | Review data pipeline |
| `app/services/terrain_service.rb` | Data service | Check data availability |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/celestial_bodies/celestial_body.rb` | Data model |

## Implementation Steps
1. **Root cause analysis**: Audit monitor.js for async/data race conditions, DOMContentLoaded handling
2. **Implement fixes**: Refactor JS to ensure data loaded before canvas rendering, use async/await
3. **Add UI feedback**: Loading indicators and clear error messages
4. **Data validation**: Validate data before rendering, add fallback logic for incomplete data
5. **Testing**: Test monitor page for all celestial bodies, confirm first-load success

## Acceptance Criteria
- [ ] Monitor loads map/canvas for all celestial bodies on first load, no refresh required
- [ ] Loading indicators and error messages visible as appropriate
- [ ] No JS timing or async errors in browser console
- [ ] All monitor layers render correctly when data available
- [ ] Code changes documented and committed referencing this task

## Stop Conditions
- Root cause is architectural requiring major refactor
- Similar bug already fixed in newer commit

## Commit Instructions
```bash
git add app/javascript/admin/monitor.js
git add app/views/admin/celestial_bodies/monitor.html.erb
git add app/controllers/admin/celestial_bodies_controller.rb
git add app/services/terrain_service.rb
git commit -m "fix: monitor loading — resolve canvas initialization race condition, add loading states"
```