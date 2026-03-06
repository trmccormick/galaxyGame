# Fix Mars Terrain Color Scheme in Monitor

## Assigned Agent
Gemini 3 Flash - JavaScript color scheme modification (very cost-effective at 0.033x)

## Overview
Update `getTerrainColorScheme` in `monitor.js` to use physical properties instead of name-based checks for Mars red tint. Add support for crust composition data to drive terrain colors properly.

## Issues Addressed
- Mars red tint currently driven by `name === 'mars'` check
- Fails for procedural rust worlds with similar composition
- Should use crust iron oxide percentage or surface color hint from planet data
- Need to add `surface_color_hint` or similar field to terrain generation metadata

## Technical Details
- Location: `monitor.js`, `getTerrainColorScheme` function
- Current: Checks `name === 'mars'` for red tint
- Target: Use `pData.crust_iron_oxide_percentage` or `pData.surface_color_hint`
- Fallback: Keep name check as last resort for Sol system worlds

## Implementation Steps
1. Check if `crust_iron_oxide_percentage` or similar field exists in planet model
2. If not, add `surface_color_hint` to terrain generation metadata in `automatic_terrain_generator.rb`
3. Update `getTerrainColorScheme` to prioritize physical properties over name
4. Test with Mars and procedural iron-rich worlds
5. Verify Earth/other worlds still get correct colors

## Success Criteria
- Mars gets red tint from iron oxide content, not name
- Procedural rust worlds display correctly
- Backward compatibility maintained for existing data
- No visual regression for other planetary bodies</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/fix_mars_terrain_color_scheme_monitor.md