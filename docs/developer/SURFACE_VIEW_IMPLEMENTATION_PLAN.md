# Surface View Implementation Plan

## Overview
The current planetary map viewer (`/celestial_bodies/map.html.erb`) has layer controls but tilesets are incorrectly configured, leading to display failures. This plan outlines creating a new surface view that properly utilizes tilesets, fixing the monitor, and addressing failing maps.

## Current State Analysis
- **Monitor View**: Exists at `app/views/celestial_bodies/map.html.erb` with JavaScript layer toggles for lava tubes, craters, settlements
- **Tileset Issues**: Tilesets are not properly integrated, causing rendering failures
- **Failing Maps**: Maps are not displaying correctly due to tileset configuration problems
- **Layer System**: Layer controls exist but don't render properly

## Implementation Goals
1. Create a new surface view that correctly uses tilesets
2. Fix the existing monitor view display issues
3. Resolve failing map rendering
4. Ensure all layer toggles work properly
5. Maintain separation of terrain generation (NASA data) from rendering (tilesets)

## Phase 1: Surface View Creation ✅ COMPLETED
### Tasks:
- ✅ Create new `surface.html.erb` view in `app/views/admin/celestial_bodies/` (admin namespace)
- ✅ Implement proper tileset loading and rendering using TilesetLoader
- ✅ Add tileset-based layer overlays (terrain, biomes, resources)
- ✅ Integrate with existing geological feature data
- ✅ Add tileset selector and controls
- ✅ Add zoom and tile size controls

### Files Created/Modified:
- ✅ `app/views/admin/celestial_bodies/surface.html.erb` (new)
- ✅ `app/controllers/admin/celestial_bodies_controller.rb` (added surface action)
- ✅ `config/routes.rb` (added surface route)
- ✅ Integrated with existing `TilesetLoader` class

### Implementation Details:
- Surface view uses tilesets for proper planetary rendering
- Fallback color rendering when tileset images unavailable
- Layer system with terrain, water, biomes, features, resources, elevation
- Real-time tileset switching capability
- Performance statistics display (tiles rendered, render time, terrain distribution)
- Navigation between monitor and surface views

## Phase 2: Monitor View Fixes
### Tasks:
- Debug existing layer toggle functionality
- Fix tileset integration in current map view
- Ensure proper data loading from geological features API
- Resolve display failures

### Files to Modify:
- `app/views/celestial_bodies/map.html.erb` (fix rendering issues)
- `app/assets/javascripts/game_interface_enhanced.js` (if needed for tileset support)

## Phase 3: Failing Maps Resolution
### Tasks:
- Identify root cause of map display failures
- Fix terrain data loading and rendering
- Ensure tilesets load correctly for different planetary bodies
- Test layer overlays work properly

### Files to Check/Modify:
- `app/services/lookup/planetary_geological_feature_lookup_service.rb`
- Terrain data files in `data/json-data/star_systems/sol/celestial_bodies/`
- Tileset configuration files

## Phase 4: Testing and Validation
### Tasks:
- Run full test suite to ensure no regressions
- Test surface view with different planetary bodies
- Validate layer toggles work correctly
- Verify tileset rendering performance

### Testing Commands:
```bash
# Run tests in container
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'

# Check specific controller tests
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/celestial_bodies_controller_spec.rb'
```

## Phase 5: Documentation Updates
### Tasks:
- Update this plan with implementation details
- Document new surface view usage
- Update monitor view documentation
- Add tileset configuration guide

### Files to Update:
- This file (`docs/developer/SURFACE_VIEW_IMPLEMENTATION_PLAN.md`)
- `docs/GUARDRAILS.md` (if architectural changes)
- `docs/developer/GROK_TASK_PLAYBOOK.md` (if new protocols)

## Success Criteria
- Surface view renders correctly with tilesets
- Monitor view displays maps without failures
- All layer toggles function properly
- All tests pass (0 failures)
- Documentation reflects current implementation

## Constraints and Guardrails
- All RSpec testing must occur inside web docker container
- Tests must pass before proceeding to next phase
- Atomic commits: only changed files, not all uncommitted
- Update/create documentation for all changes
- Follow path configuration standards (use GalaxyGame::Paths)
- Maintain separation of terrain generation and rendering layers

## Timeline
- Phase 1: 1-2 days (surface view creation)
- Phase 2: 1 day (monitor fixes)
- Phase 3: 1-2 days (failing maps resolution)
- Phase 4: 1 day (testing and validation)
- Phase 5: 0.5 day (documentation)

## Risk Mitigation
- Backup all modified files before changes
- Run tests after each major change
- Document all architectural decisions
- Maintain compatibility with existing geological feature system

## Dependencies
- Existing geological feature lookup service
- Terrain data files for Sol system bodies
- Tileset assets and configuration
- Layer overlay system

## Next Steps
1. Begin Phase 1: Create surface view
2. Run tests to ensure no regressions
3. Commit surface view implementation
4. Proceed to Phase 2: Monitor fixes</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/SURFACE_VIEW_IMPLEMENTATION_PLAN.md