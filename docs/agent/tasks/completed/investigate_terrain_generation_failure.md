# Investigate Terrain Generation Failure

## Task Overview
Diagnose and fix terrain generation failures affecting both reseeded/generated worlds and existing celestial bodies (e.g., Titan with GeoTIFF data). Current status: "NO TERRAIN DATA AVAILABLE" displayed for all planets, indicating complete terrain loading failure post-RSpec fix.

## Background
After RSpec infinite loop fix and application reseed:
- Generated worlds (Eden system) show no terrain
- Existing bodies (Titan) fail to load GeoTIFF maps
- Terrain worked previously, suggesting regression from recent changes

## Root Cause Hypotheses
1. **Stub Interference:** `disable_terrain_generation.rb` may be loaded in live environments, blocking terrain calls
2. **Pattern Loading Failure:** `load_nasa_patterns` or GeoTIFF access broken in `planetary_map_generator.rb`
3. **Generation Triggers:** Reseeded worlds not invoking terrain generation (missing callbacks)
4. **Data Dependencies:** Required geosphere/atmosphere data not populated during reseed

## Required Fixes

### Phase 1: Environment Isolation (30 minutes)
**Goal:** Ensure test stubs don't affect live application

**Actions:**
- Verify `spec/support/disable_terrain_generation.rb` is only loaded in test environment
- Check Rails environment detection in stub file
- Test terrain generation in development console

**Commands:**
```bash
# In Docker container:
cd /home/galaxy_game

# Check if stub is loaded in development
RAILS_ENV=development rails runner "puts 'Stub loaded?' if defined?(DisableTerrainGeneration)"

# Test terrain generation manually
RAILS_ENV=development rails runner "
planet = CelestialBody.find_by(name: 'Titan')
generator = StarSim::AutomaticTerrainGenerator.new
result = generator.generate_base_terrain(planet)
puts 'Terrain generated successfully' if result
"
```

### Phase 2: GeoTIFF Loading Audit (30 minutes)
**Goal:** Fix existing body terrain loading (Titan case)

**Actions:**
- Debug `load_nasa_patterns` method in `planetary_map_generator.rb`
- Verify GeoTIFF file paths and permissions
- Check pattern matching logic for planet types
- Add logging to identify failure points

**Files to Check:**
- `galaxy_game/app/services/ai_manager/planetary_map_generator.rb`
- `galaxy_game/data/geotiff/` directory structure
- `galaxy_game/app/services/terra_sim/terrain_service.rb`

### Phase 3: Generation Trigger Investigation (30 minutes)
**Goal:** Ensure reseeded worlds generate terrain

**Actions:**
- Verify `after_create` callbacks on `CelestialBody` models
- Check if reseed process calls terrain generation
- Test manual terrain generation on Eden Prime
- Review generation method calls in system builders

**Files to Check:**
- `galaxy_game/app/models/celestial_bodies/celestial_body.rb`
- `galaxy_game/db/seeds.rb`
- `galaxy_game/app/services/star_sim/system_builder_service.rb`

### Phase 4: Integration Testing (30 minutes)
**Goal:** Validate fixes across all scenarios

**Actions:**
- Test terrain loading for existing bodies (Titan, Mars, etc.)
- Test terrain generation for new/reseeded worlds
- Verify admin monitor displays terrain correctly
- Run targeted RSpec tests for terrain services

**Verification:**
- Load Titan in admin monitor → should show GeoTIFF terrain
- Load Eden Prime → should show generated terrain
- Check logs for successful pattern loading

## Success Criteria
- [x] Titan displays GeoTIFF terrain in admin monitor
- [x] Eden Prime shows generated terrain post-reseed
- [x] No "NO TERRAIN DATA AVAILABLE" messages
- [x] Terrain generation works in development environment
- [x] RSpec terrain tests pass (if applicable)

## Files to Create/Modify
- [x] `galaxy_game/spec/support/disable_terrain_generation.rb` (REVIEWED - not interfering)
- [x] `galaxy_game/app/services/ai_manager/planetary_map_generator.rb` (FIXED - diameter method access)
- [x] `galaxy_game/app/services/terra_sim/terrain_service.rb` (REVIEWED - not needed)

## Actual Results
**Root Cause Identified**: `planet.diameter` method called on Moon/TerrestrialPlanet objects that don't have this attribute, causing `NoMethodError` before fallback `|| planet.radius * 2` could execute.

**Fix Applied**: Changed `planet.diameter || planet.radius * 2` to `planet.respond_to?(:diameter) ? planet.diameter : (planet.radius * 2)` in both logging and calculation methods.

**Terrain Status After Fix**:
- Titan: pattern_based_realistic (GeoTIFF loaded successfully)
- Eden Prime: pattern_based_realistic (generated successfully)  
- Mars: generated (working)
- Earth: generated (working)

**System Builder**: Working correctly - terrain generation is triggered during world creation, but was failing due to diameter method error.

## Estimated Time
2 hours total

## Priority
CRITICAL - Blocks terrain functionality and admin monitoring

## Notes
- Work in Docker container for all commands
- Log all findings for documentation
- Test in development environment first
- Coordinate with RSpec stub to avoid conflicts