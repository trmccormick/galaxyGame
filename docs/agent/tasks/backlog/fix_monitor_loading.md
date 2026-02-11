# Fix Monitor Loading

## Task Overview
Fix critical monitor loading issues that prevent proper display of celestial body data and layers in the admin interface. Issue: Map doesn't display on first page load, requires refresh.

## Background
The monitor interface is failing to load properly, preventing administrators from viewing and managing celestial body data. This is a critical blocking issue for system administration. Current behavior: Page loads but canvas appears blank/empty, requiring F5 refresh to display map correctly.

## Requirements

### Phase 1: Diagnose Loading Issues (Priority: Critical)
- **Root Cause Analysis**: Identify JavaScript timing issues (canvas renders before data loads)
- **Data Pipeline Audit**: Check terrain_map, geosphere, and atmosphere data availability
- **Race Condition Fixes**: Ensure data loads before canvas rendering attempts
- **Error Handling**: Add proper error messages for missing data scenarios

### Phase 2: Timing and Loading Fixes (Priority: Critical)
- **DOMContentLoaded Issues**: Fix canvas rendering before terrainData is available
- **Async Data Loading**: Implement proper async/await for data fetching
- **Loading States**: Add loading indicators and progress feedback
- **Data Validation**: Ensure terrain data exists before rendering attempts

### Phase 3: Data Source Integration (Priority: Critical)
- **Terrain Loading**: Fix terrain grid loading from geosphere.terrain_map
- **Layer Initialization**: Ensure all monitor layers initialize correctly
- **Canvas Setup**: Verify canvas dimensions and coordinate system setup
- **Fallback Logic**: Implement graceful degradation when data is incomplete

### Phase 4: UI/UX Improvements (Priority: High)
- **Error Messages**: Clear error display when data cannot be loaded
- **Loading Indicators**: Show progress during data loading
- **Data Validation**: Validate data integrity before rendering
- **Debug Information**: Add developer tools for troubleshooting loading issues

## Success Criteria
- [ ] Monitor loads successfully for all celestial bodies without requiring refresh
- [ ] Clear error messages when data is missing or loading fails
- [ ] Loading states are properly displayed with progress indicators
- [ ] All layers render correctly when data is available
- [ ] No JavaScript timing errors in browser console
- [ ] Canvas displays map immediately on page load

## Files to Create/Modify
- `galaxy_game/app/javascript/admin/monitor.js` - Fix loading logic and timing issues
- `galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb` - Add error handling and loading states
- `galaxy_game/app/controllers/admin/celestial_bodies_controller.rb` - Improve data preparation and validation
- `galaxy_game/app/services/terrain_service.rb` - Ensure data availability before rendering

## Estimated Time
1 hour

## Priority
CRITICAL