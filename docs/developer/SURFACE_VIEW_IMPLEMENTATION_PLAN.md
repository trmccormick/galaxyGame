# Surface View Implementation Plan

## Overview
This document tracks the implementation of planetary map visualization in Galaxy Game, including the monitor view (admin terrain debugging) and surface view (gameplay map display).

## View Distinction [2026-02-05]

### Monitor View (Admin/Debug)
- **Purpose:** Verify terrain data is loading correctly
- **Rendering:** SimEarth-style layered system with toggleable overlays
- **Terrain Layer:** Always ON - elevation-based body-specific colors (cannot be disabled)
- **Other Layers:** Hydrosphere, Biosphere, Infrastructure - toggleable
- **Tileset:** Not used - direct pixel/canvas rendering
- **Location:** `app/views/admin/celestial_bodies/monitor.html.erb`

### Surface View (Gameplay)
- **Purpose:** Player interaction with planetary surface
- **Rendering:** FreeCiv tileset sprites for proper game UI
- **Tileset:** Required - uses 64×64 Trident tiles (or other FreeCiv tilesets)
- **Grid Size:** Diameter-based with 2:1 aspect ratio for cylindrical wrap
- **Location:** `app/views/admin/celestial_bodies/surface.html.erb`

**FreeCiv Tileset Constraints (Surface View Only):**
| Body | Grid Size | @64px tiles |
|------|-----------|-------------|
| Earth | 180×90 | 11,520×5,760 |
| Mars | 96×48 | 6,144×3,072 |
| Luna | 50×25 | 3,200×1,600 |

## Current State Analysis [2026-02-05]

### Monitor View Issues
- **Location:** `app/views/admin/celestial_bodies/monitor.html.erb`
- ❌ Loading FreeCiv/Civ4 data directly and converting terrain types to elevation
- ❌ Produces unrealistic elevation range (279-322m instead of real topography)
- ❌ "Water" label hardcoded instead of "Hydrosphere" with composition colors
- ❌ All bodies render brown (no body-specific colors)
- ✅ Water overlay working (not shown by default)
- ✅ Diameter-based grid sizing works correctly

### Surface View Status
- **Location:** `app/views/admin/celestial_bodies/surface.html.erb`
- ✅ Created with tileset loading
- ✅ Layer system implemented
- ✅ Controller tests passing

## Architecture Correction Required

### Data Source Hierarchy
```
Sol Bodies WITH NASA Data (Earth, Mars, Luna, Mercury):
  NASA GeoTIFF → Downsample to grid size → Display

Sol Bodies WITHOUT NASA Data (Titan, Europa, etc.):
  AI Manager generates terrain using:
  ├─ Body physical conditions (temp, pressure, composition)
  ├─ Learned patterns from NASA bodies
  └─ Civ4/FreeCiv hints for feature placement

FreeCiv/Civ4 Maps → TRAINING DATA ONLY
  ├─ Biome placement patterns
  ├─ Geographic feature names/locations
  ├─ Settlement viability hints
  └─ Geological feature checklist
```

## Implementation Tasks

### Phase 1: Monitor View Fixes 🔴 HIGH PRIORITY

| Task | Description | Status |
|------|-------------|--------|
| **1.1** | Load NASA GeoTIFF elevation data | ❌ Pending |
| **1.2** | Remove FreeCiv→elevation conversion | ❌ Pending |
| **1.3** | Rename "Water" → "Hydrosphere" | ❌ Pending |
| **1.4** | Color by liquid composition (H2O=blue, CH4=orange) | ❌ Pending |
| **1.5** | Body-specific base colors | ❌ Pending |
| **1.6** | Fix `primary_liquid` method | ❌ Pending |

### Phase 2: Surface View Enhancement 🟡 MEDIUM PRIORITY

| Task | Description | Status |
|------|-------------|--------|
| **2.1** | Integrate geological features overlay | ✅ Completed |
| **2.2** | Add feature markers with tooltips | 🔄 In Progress |
| **2.3** | Settlement planning integration | ❌ Pending |
| **2.4** | FreeCiv tileset compatibility (2:1 grid ratio) | ❌ Pending |

### Phase 3: Geological Data Completion 🟢 LOW PRIORITY

| Task | Description | Status |
|------|-------------|--------|
| **3.1** | Add Mars volcanoes (Olympus Mons, Tharsis) | ❌ Pending |
| **3.2** | Add Mars planitia (Hellas, Argyre) | ❌ Pending |
| **3.3** | Add Luna maria (Mare Tranquillitatis, etc.) | ❌ Pending |
| **3.4** | Add Luna montes (mountains) | ❌ Pending |

## File Modifications Required

### Monitor View (Phase 1) - No Tilesets
```
app/views/admin/celestial_bodies/monitor.html.erb
├─ Remove: FreeCiv/Civ4 direct loading
├─ Add: NASA GeoTIFF loader (simple heightmap rendering)
├─ Add: Hydrosphere composition colors
└─ Add: Body-specific color gradients
```

### Surface View (Phase 2) - FreeCiv Tileset Integration
```
app/views/admin/celestial_bodies/surface.html.erb
├─ Verify: 2:1 aspect ratio grid sizing
├─ Add: Tileset-based terrain rendering
└─ Add: Proper layer compositing over tiles
```
└─ Add: Body-specific color gradients

app/services/terrain/automatic_terrain_generator.rb
└─ Add: load_nasa_geotiff_elevation(body_name) method

app/models/concerns/hydrosphere_concern.rb
└─ Fix: primary_liquid to check liquid_name first
```

### Rendering Specifications

**Body-Specific Colors:**
```javascript
const bodyColors = {
  'Earth':   { low: '#006400', high: '#ffffff' },  // Green to snow
  'Luna':    { low: '#4a4a4a', high: '#d0d0d0' },  // Grey gradient
  'Mars':    { low: '#654321', high: '#cd853f' },  // Rust gradient
  'Mercury': { low: '#3a3a3a', high: '#a9a9a9' },  // Dark grey
  'Titan':   { low: '#8B4513', high: '#DEB887' },  // Brown-orange
  'Venus':   { low: '#b8860b', high: '#f0e68c' },  // Amber
};
```

**Hydrosphere Colors:**
```javascript
const liquidColors = {
  'H2O':                 '#0077be',  // Water blue
  'methane':             '#ff8c00',  // Orange
  'methane and ethane':  '#ff6600',  // Deeper orange
  'ammonia':             '#9370db',  // Purple
  'nitrogen':            '#87ceeb',  // Light blue (Triton)
};
```

## Testing Commands
```bash
# Run controller tests
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/admin/celestial_bodies_controller_spec.rb'

# Check terrain data
docker exec -it web bash -c 'cd /home/galaxy_game && rails runner "
  body = CelestialBodies::CelestialBody.find_by(name: \"Luna\")
  tm = body.geosphere&.terrain_map
  puts \"Grid: #{tm[\"elevation\"]&.size}x#{tm[\"elevation\"]&.first&.size}\"
  puts \"Elevation range: #{tm[\"elevation\"]&.flatten&.minmax}\"
"'
```

## Related Documentation
- [GUARDRAILS.md §7.5](../GUARDRAILS.md) - Terrain architecture principles
- [ELEVATION_DATA.md](./ELEVATION_DATA.md) - Data source details
- [FREECIV_INTEGRATION.md](./FREECIV_INTEGRATION.md) - Training data usage

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

## External References
- **FreeMars patterns:** See [EXTERNAL_REFERENCES.md](./EXTERNAL_REFERENCES.md) for TilePaintModel caching concept and layered rendering patterns (concepts only - no license)
- **FreeCiv tilesets:** GPL licensed, safe to use with attribution
- **NASA data:** Public domain elevation data

## Next Steps
1. Begin Phase 1: Create surface view
2. Run tests to ensure no regressions
3. Commit surface view implementation
4. Proceed to Phase 2: Monitor fixes</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/SURFACE_VIEW_IMPLEMENTATION_PLAN.md