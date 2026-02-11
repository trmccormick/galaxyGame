# Hydrosphere Layer Display Issues - Task File

## Problem Description
The hydrosphere layer in the admin monitor view has two main issues:
1. The hydrosphere layer button appears dim and unselectable for planets that should have water
2. Planetary maps require a page refresh to load properly

## Root Cause Analysis
1. **Layer Button Availability**: The hydrosphere layer button is disabled when `has_hydrosphere` evaluates to false. This happens when:
   - The hydrosphere record doesn't exist, OR
   - All hydrosphere values (water_coverage, total_liquid_mass, ice) are 0 or null

2. **Water Layer Rendering**: The water layer is only calculated and rendered if `planetData.water_coverage > 0`, but the layer button availability is based on broader hydrosphere presence criteria.

3. **Map Loading Timing**: Terrain data appears to be generated asynchronously after page load, requiring a refresh to display maps.

## Required Fixes

### Fix 1: Align Layer Button Availability with Rendering Logic
**File**: `galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb`
**Location**: Lines ~25-30 (has_hydrosphere calculation)
**Change**: Modify `has_hydrosphere` to match the water layer rendering condition:
```ruby
# Current logic
has_hydrosphere = @celestial_body.hydrosphere.present? && (@celestial_body.hydrosphere.water_coverage.to_f > 0 || @celestial_body.hydrosphere.total_liquid_mass.to_f > 0 || @celestial_body.hydrosphere.ice.to_f > 0)

# New logic - align with water layer rendering
has_hydrosphere = @celestial_body.hydrosphere.present? && @celestial_body.hydrosphere.water_coverage.to_f > 0
```

### Fix 2: Add Terrain Data Polling
**File**: `galaxy_game/app/javascript/admin/monitor.js`
**Location**: Add to `updateSphereData()` function (around line 1270)
**Change**: Poll for terrain data updates and re-render map when terrain becomes available:
```javascript
// Add terrain data checking to updateSphereData
if (data.terrain_data && (!terrainData || JSON.stringify(data.terrain_data) !== JSON.stringify(terrainData))) {
  terrainData = data.terrain_data;
  console.log('Terrain data updated, re-rendering map');
  renderTerrainMap();
}
```

### Fix 3: Update Sphere Data Endpoint
**File**: `galaxy_game/app/controllers/admin/celestial_bodies_controller.rb`
**Location**: `sphere_data` action (around line 82)
**Change**: Include terrain data in the JSON response:
```ruby
def sphere_data
  render json: {
    atmosphere: atmosphere_data,
    hydrosphere: hydrosphere_data,
    geosphere: geosphere_data,
    biosphere: biosphere_data,
    planet_info: planet_info_data,
    terrain_data: @celestial_body.geosphere&.terrain_map  # Add this line
  }
end
```

## Testing Requirements
1. Test with planets that have hydrosphere data but 0 water coverage - layer should be disabled
2. Test with planets that have positive water coverage - layer should be enabled and render properly
3. Test map loading - maps should appear without requiring page refresh
4. Verify layer toggling works correctly for all layer types

## Validation Steps
- [ ] Hydrosphere layer button is enabled for planets with water_coverage > 0
- [ ] Hydrosphere layer button is disabled for planets with water_coverage = 0
- [ ] Water layer renders correctly when toggled on
- [ ] Maps load automatically without page refresh
- [ ] All other layer types continue to work as expected

## Files to Modify
1. `galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb`
2. `galaxy_game/app/controllers/admin/celestial_bodies_controller.rb`
3. `galaxy_game/app/javascript/admin/monitor.js`

## Commit Message
"Fix hydrosphere layer display and map loading issues in admin monitor"