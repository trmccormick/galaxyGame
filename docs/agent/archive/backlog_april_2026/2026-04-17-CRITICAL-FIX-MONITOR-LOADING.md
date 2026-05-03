# 2026-04-17-CRITICAL-FIX-MONITOR-LOADING.md

## Task Title
Fix Monitor Loading and Canvas Initialization in Admin Interface

## Task Overview
Resolve the critical bug where the admin monitor page for celestial bodies fails to load the map/canvas on first load, requiring a manual refresh. Ensure robust async data loading, error handling, and user feedback for all monitor layers.

## Background & Context
- The admin monitor interface intermittently fails to display the map/canvas for celestial bodies on initial load.
- Root cause is likely a race condition or async/timing issue between data fetch and canvas rendering.
- This is a blocking issue for system administration and monitoring.
- Related files: monitor.js, monitor.html.erb, celestial_bodies_controller.rb, terrain_service.rb.

## Actionable Steps
1. **Root Cause Analysis**
   - Audit monitor.js for async/data race conditions and DOMContentLoaded handling.
   - Check data pipeline: terrain_map, geosphere, atmosphere data availability.
   - Review error handling for missing/incomplete data.
2. **Implement Fixes**
   - Refactor JS to ensure data is loaded before canvas rendering.
   - Use async/await or Promises for all data fetches.
   - Add loading indicators and clear error messages in UI.
   - Validate data before rendering; add fallback logic for incomplete data.
3. **Testing & Validation**
   - Test monitor page for all celestial bodies; confirm map loads on first try.
   - Check browser console for JS errors.
   - Confirm all layers render and loading states are visible.
4. **Documentation & Commit**
   - Document changes in code comments and commit message.
   - Reference this task in commit.

## STOP/REVIEW Conditions
- STOP if root cause is architectural (requires major refactor) and escalate to planning.
- STOP if similar bug is already fixed in a newer commit; archive this task with reference.

## Acceptance Criteria
- [ ] Monitor loads map/canvas for all celestial bodies on first load, no refresh required.
- [ ] Loading indicators and error messages are visible as appropriate.
- [ ] No JS timing or async errors in browser console.
- [ ] All monitor layers render correctly when data is available.
- [ ] Code changes are documented and committed referencing this task.

## Agent Assignment
- **Agent:** Frontend/Fullstack Engineer (JS, Rails)

## Files to Modify
- `app/javascript/admin/monitor.js`
- `app/views/admin/celestial_bodies/monitor.html.erb`
- `app/controllers/admin/celestial_bodies_controller.rb`
- `app/services/terrain_service.rb`

## Estimated Time
1-2 hours

## Priority
CRITICAL

## Audit/Verification
- Confirm no duplicate or superseding task exists.
- Verify bug is still present before starting work.
- Reference commit or PR in task file upon completion.
