# Fix Sol System GeoTIFF Usage in Terrain Generation

## Problem
During database reseeding, Sol system bodies like Titan are generating poor quality procedural terrain instead of using available high-quality GeoTIFF elevation data. This occurs because the `AutomaticTerrainGenerator#generate_sol_world_terrain` method only checks for GeoTIFF data for explicitly listed planets (Earth, Mars, Venus, Mercury, Luna), falling back to procedural generation for other bodies like Titan.

## Root Cause
The case statement in `generate_sol_world_terrain` handles specific planets with custom logic, but the `else` clause performs procedural generation without checking for available GeoTIFF data. Titan has `titan_1800x900.tif` available in `/data/geotiff/processed/`, but the seeding process bypasses it.

## Current State
- Titan loads with procedural terrain despite GeoTIFF availability
- GeoTIFF detection works (`nasa_geotiff_available?('titan')` returns true)
- Other Sol system bodies may have similar issues if not explicitly cased
- Affects terrain quality in admin monitor and gameplay

## Required Changes

### Phase 1: Modify Fallback Logic
Update the `else` clause in `generate_sol_world_terrain` to check for GeoTIFF data before falling back to procedural generation:

```ruby
else
  # Check for NASA GeoTIFF data first for any Sol system world
  if nasa_geotiff_available?(body.name.downcase)
    Rails.logger.info "[AutomaticTerrainGenerator] Using NASA GeoTIFF for #{body.name}"
    terrain_data = load_nasa_terrain(body.name.downcase, body)
    return store_generated_terrain(body, terrain_data) if terrain_data
  end
  
  # Fallback to procedural generation
  terrain_params = analyze_planet_properties(body)
  generate_base_terrain(body, terrain_params)
end
```

### Phase 2: Test GeoTIFF Detection
Verify GeoTIFF availability for all Sol system bodies:
- Earth: ✅ Available
- Mars: ✅ Available  
- Venus: ✅ Available
- Mercury: ✅ Available
- Luna: ✅ Available
- Titan: ✅ Available (`titan_1800x900.tif`)
- Other moons: Check for additional GeoTIFF files

### Phase 3: Regenerate Affected Terrain
For bodies with existing procedural terrain that should use GeoTIFF:
1. Clear existing terrain data (`geosphere.terrain_map = nil`)
2. Regenerate terrain using updated logic
3. Verify GeoTIFF data is loaded and processed correctly

### Phase 4: Validation and Testing
- Confirm Titan displays high-quality terrain in admin monitor
- Test terrain rendering and elevation data accuracy
- Run RSpec tests for terrain generation
- Verify no regressions for explicitly handled planets

## Success Criteria
- All Sol system bodies with available GeoTIFF data use it during seeding
- Titan terrain quality improves from procedural to GeoTIFF-based
- No breaking changes to existing planet-specific terrain logic
- Terrain generation passes all RSpec tests
- Admin monitor shows correct terrain data for all bodies

## Dependencies
- Access to `AutomaticTerrainGenerator` service
- GeoTIFF files in `/data/geotiff/processed/`
- Rails runner access for testing
- RSpec test suite for validation

## Risk Assessment
- **Low Risk**: Change only affects the fallback case, preserves existing logic
- **Testing Required**: Full RSpec suite + manual terrain verification
- **Rollback**: Revert the else clause modification if issues arise

## Priority
Critical - Affects core terrain quality for seeded Sol system, impacts user experience in admin interface.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/critial/fix_sol_system_geotiff_usage.md