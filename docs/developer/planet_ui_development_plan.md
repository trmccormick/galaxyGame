# Planet UI Development Plan - Admin Monitoring Interface

## Executive Summary

This document outlines the development plan for Galaxy Game's planet visualization system, designed as an **internal development/debugging tool** to monitor AI Manager operations, visualize geological features, and track planetary simulation states.

**Target Users:** Developers and testers (not players)
**Primary Purpose:** Visualize AI Manager decisions and system operations
**Current Status:** Planning phase
**Estimated Timeline:** 1-2 weeks for MVP

---

## Game Context

### Core Game Loop
```
Sol System (AI builds foundation)
    ↓
AI Manager establishes DC bases on planets/moons
    ↓
Natural Wormholes discovered → New systems
    ↓
AI scouts system → Applies pattern (Venus-like, Mars-like, etc.)
    ↓
AI deploys Cycler with mission-specific equipment
    ↓
AI establishes DC base (Foothold Pattern)
    ↓
System ready for future player expansion
```

### Current Development Status
- **No players yet** - Pure AI testing environment
- **AI Manager building Sol** - Luna, Mars, Venus, Titan footholds
- **Testing patterns** - Validating mission configurations
- **Tuning systems** - Optimizing AI decision-making

### Why We Need This UI
1. **Visualize AI decisions** - Why did AI choose Marius Hills over Shackleton?
2. **Monitor mission progress** - Where is AI in the phase sequence?
3. **Debug failures** - Why did a mission get stuck?
4. **Validate patterns** - Does Venus pattern behave correctly?
5. **Explore data** - What geological features exist on Luna?

---

## UI Design Philosophy

### Not SimEarth
- Players won't control planets (AI does)
- This is a **monitoring tool**, not a game interface
- Focus: Observe and debug, not play

### Not Eve Online (Yet)
- No player economy visualization
- No contract system
- No market data
- Future: Economic view comes later when players exist

### What It IS
**A development dashboard for AI Manager operations**
- Real-time mission tracking
- Geological data exploration
- Sphere simulation monitoring
- AI decision visualization
- Pattern testing tools

---

## Architecture Overview

### Three-Panel Layout

```
┌─────────────────────────────────────────────────────────────────┐
│ GALAXY GAME - AI MANAGER DEVELOPMENT MONITOR                    │
├──────────────────┬──────────────────────────┬───────────────────┤
│                  │                          │                   │
│ AI MISSION LOG   │    PLANETARY MAP         │  SPHERE DATA      │
│ (Left Panel)     │    (Center Canvas)       │  (Right Panel)    │
│                  │                          │                   │
│ • Mission status │  • Geological features   │  • Atmosphere     │
│ • Phase progress │  • DC base locations     │  • Geosphere      │
│ • Task list      │  • AI scoring overlay    │  • Hydrosphere    │
│ • Decision log   │  • Interactive markers   │  • Biosphere      │
│ • Controls       │  • Layer toggles         │  • Live updates   │
│                  │                          │                   │
└──────────────────┴──────────────────────────┴───────────────────┘
│ CONSOLE OUTPUT (Bottom)                                          │
│ • AI activity log                                                │
│ • Task completions                                               │
│ • Error messages                                                 │
└──────────────────────────────────────────────────────────────────┘
```

### Technology Stack

**Backend:**
- Rails 7.0 (existing)
- PostgreSQL (existing)
- Admin namespace for routes
- Service layer for data aggregation

**Frontend:**
- HTML5 Canvas for map rendering
- Vanilla JavaScript (no framework)
- CSS Grid for layout
- Optional: WebSocket for live updates (or polling)

**Data Sources:**
- JSON files: `lava_tubes.json`, `craters.json`, `craters_catalog.json`
- Database: `settlements`, `celestial_bodies`, sphere models
- Mission files: `lunar_precursor_ai_*.json` and similar
- TaskExecutionEngine: Live mission state

---

## Data Architecture

### Existing Data Assets ✅

#### 1. Geological Features (JSON Files)
Located: `data/json-data/star_systems/sol/celestial_bodies/earth/luna/geological_features/`

**Lava Tubes** (`lava_tubes.json`):
```json
{
  "celestial_body": "luna",
  "feature_type": "lava_tube",
  "tier": "strategic",
  "features": [
    {
      "id": "luna_lt_001",
      "name": "Marius Hills Skylight",
      "coordinates": { "latitude": 14.1, "longitude": -56.8 },
      "dimensions": { "diameter_m": 65, "estimated_volume_m3": 11780972 },
      "priority": "high",
      "strategic_value": ["Natural Base", "Radiation Shielding"]
    }
  ]
}
```
- 12 strategic lava tubes with full specifications
- Exact coordinates, dimensions, priorities
- Strategic value assessments

**Craters** (`craters.json` + `craters_catalog.json`):
```json
{
  "id": "luna_cr_001",
  "name": "Shackleton Crater",
  "coordinates": { "latitude": -89.9, "longitude": 0.0 },
  "dimensions": { "diameter_m": 21000, "depth_m": 4200 },
  "resources": { "water_ice_tons": 600000000 },
  "priority": "critical"
}
```
- Strategic: 1 feature (Shackleton)
- Catalog: 1,577 total craters

#### 2. Mission Configurations (JSON Files)
Located: `data/json-data/missions/tasks/`

**Mission Profile** (`lunar-precursor-ai_profile_v1.json`):
- Mission ID, description
- AI decision framework
- Phase sequence
- Resource constraints
- Success metrics

**Mission Phases** (e.g., `lunar_precursor_ai_site_analysis_v1.json`):
- Task definitions
- AI actions
- Completion criteria
- Expected outputs

**Mission Manifest** (`lunar_precursor_ai_manifest_v1.json`):
- Equipment list
- AI optimization parameters
- Cost constraints
- Contingency equipment

#### 3. Database Models (Rails)

**CelestialBody:**
- `name`, `identifier`, `type`
- `mass`, `radius`, `gravity`
- Relationships to spheres

**Spheres:**
- `Atmosphere`: pressure, temperature, composition
- `Geosphere`: geological_activity, crust_composition
- `Hydrosphere`: liquid bodies, ice
- `Biosphere`: biodiversity_index, biomes

**Settlement::BaseSettlement:**
- `name`, `settlement_type`
- `owner` (DC or player)
- `location` (CelestialLocation)
- `current_population`
- `inventory`

**Location::CelestialLocation:**
- `name`, `coordinates`
- `celestial_body_id`
- Optional: `metadata` (geological_feature_id)

#### 4. AI Manager System

**TaskExecutionEngine:**
- Loads mission profiles
- Executes phase tasks
- Tracks progress
- **Status:** Unknown if state is exposed or in-memory only

**Mission Execution:**
- See: `lib/tasks/ai_base_building.rake`
- See: `lib/tasks/lunar_base_pipeline.rake`
- Example workflows for testing

---

## Implementation Phases

### Phase 1: Minimal Viable Map (4-6 hours)

**Goal:** Proof-of-concept - visualize geological features

**Deliverables:**
- [ ] Admin route: `/admin/celestial_bodies/:id/monitor`
- [ ] Controller: `Admin::MonitoringController`
- [ ] Service: `Lookup::PlanetaryGeologicalFeatureLookupService` (existing service for loading JSON files)
- [ ] View: HTML page with Canvas element
- [ ] JavaScript: Plot markers at lat/lon coordinates
- [ ] Basic interaction: Click marker → Console log feature name

**Files to Create:**
```
app/controllers/admin/monitoring_controller.rb
app/views/admin/monitoring/show.html.erb
app/assets/javascripts/admin/planet_map.js
config/routes.rb (add admin namespace)
# Note: Use existing Lookup::PlanetaryGeologicalFeatureLookupService
```

**API Endpoints:**
```ruby
GET /admin/celestial_bodies/:id/monitor          # Main page
GET /admin/celestial_bodies/:id/geological_features.json  # Data API
```

**Success Criteria:**
- Can view Luna
- Lava tubes appear as blue markers at correct coordinates
- Craters appear as yellow markers
- Click marker shows feature name
- No errors in console

---

### Phase 2: Interactive Feature Map (8-12 hours total)

**Goal:** Usable exploration tool with info panels

**Builds on Phase 1, adds:**
- [ ] Info panel sidebar (displays feature details on click)
- [ ] Layer toggles (show/hide lava tubes, craters, DC bases)
- [ ] CSS styling (3-panel layout)
- [ ] Query settlements from database
- [ ] Display DC base locations (if any exist)
- [ ] Color coding by priority (high=green, medium=yellow, low=red)

**New Components:**
```
app/assets/stylesheets/admin/monitoring.css
app/views/admin/monitoring/_feature_panel.html.erb
app/views/admin/monitoring/_layer_controls.html.erb
```

**API Endpoints:**
```ruby
GET /admin/celestial_bodies/:id/settlements.json  # DC bases
```

**Success Criteria:**
- Click feature → Right panel shows full details
- Toggle lava tubes on/off
- Toggle craters on/off
- DC bases appear as green markers (if created by AI)
- Responsive layout works on different screen sizes

---

### Phase 3: AI Mission Tracking (2-3 days total)

**Goal:** Monitor live AI Manager operations

**Builds on Phase 2, adds:**
- [ ] Query TaskExecutionEngine for mission state
- [ ] Display current mission in left panel
- [ ] Show phase progress (Phase 2/5, 75% complete)
- [ ] Task list with completion status
- [ ] Console log panel at bottom
- [ ] "Advance Phase" debug button
- [ ] Real-time or polling updates

**Research Required:**
- [ ] How does TaskExecutionEngine expose state?
- [ ] Is mission progress stored in database or in-memory?
- [ ] Can we query active missions?
- [ ] What's the state format?

**New Components:**
```
app/controllers/admin/missions_controller.rb
app/services/ai_mission_status_service.rb
app/views/admin/monitoring/_mission_panel.html.erb
app/views/admin/monitoring/_console_log.html.erb
app/assets/javascripts/admin/mission_tracker.js
```

**API Endpoints:**
```ruby
GET  /admin/celestial_bodies/:id/mission_status.json  # Current mission
POST /admin/missions/:id/advance_phase                 # Testing control
GET  /admin/missions/:id/console_log.json             # Activity log
```

**Potential Challenges:**
1. **TaskExecutionEngine integration**
   - May need refactoring to expose state
   - Could add `current_phase`, `progress` attributes
   - Store state in database for persistence

2. **Live updates**
   - Option A: Polling every 5 seconds (simple)
   - Option B: WebSocket connection (complex)
   - Recommendation: Start with polling

**Success Criteria:**
- Can see current mission for a celestial body
- Phase progress updates live
- Task list shows completion status
- Console shows AI activity log
- "Advance Phase" button works for testing

---

### Phase 4: AI Decision Visualization (4-5 days total)

**Goal:** Understand why AI made specific choices

**Builds on Phase 3, adds:**
- [ ] AI site scoring algorithm implementation
- [ ] Heatmap overlay showing site scores
- [ ] Click site → View factor breakdown
- [ ] Comparison view (Marius Hills vs Shackleton)
- [ ] Decision explanation panel
- [ ] Historical decision log

**New Components:**
```
app/services/ai_decision_analyzer_service.rb
app/assets/javascripts/admin/decision_visualizer.js
app/views/admin/monitoring/_decision_panel.html.erb
```

**API Endpoints:**
```ruby
GET /admin/celestial_bodies/:id/ai_decisions.json  # Scoring data
```

**Scoring Algorithm** (from `lunar_precursor_ai_site_analysis_v1.json`):
```ruby
class AIDecisionAnalyzerService
  WEIGHTING_FACTORS = {
    power_generation_potential: 0.30,
    thermal_moderation: 0.25,
    resource_extraction_efficiency: 0.20,
    communication_reliability: 0.15,
    operational_safety: 0.10
  }
  
  def score_site(geological_feature, celestial_body)
    factors = calculate_factors(geological_feature, celestial_body)
    total_score = factors.sum { |k, v| v * WEIGHTING_FACTORS[k] }
    
    {
      total_score: total_score,
      factors: factors,
      reasoning: explain_score(factors)
    }
  end
  
  private
  
  def calculate_factors(feature, body)
    {
      power_generation_potential: solar_exposure_score(feature),
      thermal_moderation: thermal_stability_score(feature),
      resource_extraction_efficiency: resource_score(feature),
      communication_reliability: los_score(feature, body),
      operational_safety: safety_score(feature)
    }
  end
end
```

**Success Criteria:**
- All geological features have calculated scores
- Heatmap shows color gradient (green=high, red=low)
- Click site shows detailed factor breakdown
- Can explain why AI chose Marius Hills over Shackleton
- Matches AI's actual decision

---

### Phase 5: Sphere Data Integration (5-6 days total)

**Goal:** Monitor planetary simulation states

**Builds on Phase 4, adds:**
- [ ] Query sphere models (atmosphere, geosphere, etc.)
- [ ] Display live sphere data in right panel
- [ ] Historical change tracking
- [ ] Sphere data export (CSV/JSON)
- [ ] Optional: Sphere heatmap overlays on map

**New Components:**
```
app/services/sphere_data_aggregator_service.rb
app/views/admin/monitoring/_sphere_panel.html.erb
app/assets/javascripts/admin/sphere_monitor.js
```

**API Endpoints:**
```ruby
GET /admin/celestial_bodies/:id/sphere_data.json  # All spheres
GET /admin/celestial_bodies/:id/sphere_history.json  # Changes over time
POST /admin/celestial_bodies/:id/sphere_data/export  # Download data
```

**Data Structure:**
```json
{
  "celestial_body_id": 1,
  "timestamp": "2026-01-13T14:35:22Z",
  "atmosphere": {
    "pressure": 3.0e-15,
    "temperature": 250,
    "composition": {"vacuum": true},
    "status": "stable"
  },
  "geosphere": {
    "geological_activity": 5,
    "tectonic_activity": false,
    "crust_composition": {
      "SiO2": 43.0,
      "Al2O3": 24.0,
      "FeO": 13.0
    }
  },
  "hydrosphere": {
    "total_liquid_mass": 0,
    "ice_caps": "polar_only",
    "liquid_bodies": null
  },
  "biosphere": {
    "biodiversity_index": 0.0,
    "habitable_ratio": 0.0,
    "status": "none"
  }
}
```

**Historical Tracking:**
- Option A: Store snapshots on every sphere update
- Option B: Log changes only (delta tracking)
- Recommendation: Start with Option B

**Success Criteria:**
- Can view current sphere states
- Data updates when spheres change
- Can export sphere data for analysis
- Historical view shows changes over time
- No performance issues querying sphere models

---

### Phase 6: Pattern Testing Interface (Optional, 3-4 days)

**Goal:** Test different AI patterns

**Builds on Phase 5, adds:**
- [ ] Pattern selector (Lunar, Venus, Mars, Titan, Belt)
- [ ] Pattern comparison tool
- [ ] Expected vs actual outcome validation
- [ ] Pattern test runner
- [ ] Results export

**New Components:**
```
app/controllers/admin/pattern_tests_controller.rb
app/services/pattern_testing_service.rb
app/views/admin/monitoring/_pattern_tester.html.erb
```

**Success Criteria:**
- Can select and run different patterns
- Compare expected vs actual results
- Validate pattern behavior
- Export test results

---

## File Structure

```
galaxy_game/
├── app/
│   ├── controllers/
│   │   └── admin/
│   │       ├── monitoring_controller.rb        # Phase 1
│   │       ├── missions_controller.rb          # Phase 3
│   │       └── pattern_tests_controller.rb     # Phase 6
│   │
│   ├── services/
│   │   ├── lookup/
│   │   │   └── planetary_geological_feature_lookup_service.rb  # Existing - Phase 1
│   │   ├── ai_mission_status_service.rb        # Phase 3
│   │   ├── ai_decision_analyzer_service.rb     # Phase 4
│   │   ├── sphere_data_aggregator_service.rb   # Phase 5
│   │   └── pattern_testing_service.rb          # Phase 6
│   │
│   ├── views/
│   │   └── admin/
│   │       └── monitoring/
│   │           ├── show.html.erb               # Phase 1
│   │           ├── _feature_panel.html.erb     # Phase 2
│   │           ├── _layer_controls.html.erb    # Phase 2
│   │           ├── _mission_panel.html.erb     # Phase 3
│   │           ├── _console_log.html.erb       # Phase 3
│   │           ├── _decision_panel.html.erb    # Phase 4
│   │           ├── _sphere_panel.html.erb      # Phase 5
│   │           └── _pattern_tester.html.erb    # Phase 6
│   │
│   └── assets/
│       ├── javascripts/
│       │   └── admin/
│       │       ├── planet_map.js               # Phase 1
│       │       ├── mission_tracker.js          # Phase 3
│       │       ├── decision_visualizer.js      # Phase 4
│       │       └── sphere_monitor.js           # Phase 5
│       │
│       └── stylesheets/
│           └── admin/
│               └── monitoring.css              # Phase 2
│
├── config/
│   └── routes.rb                               # Add admin routes
│
└── docs/
    └── developer/
        └── planet_ui_development_plan.md       # This file
```

---

## API Specification

### Admin Monitoring Routes

```ruby
# config/routes.rb
namespace :admin do
  resources :celestial_bodies, only: [] do
    member do
      # Phase 1-2: Map & Features
      get :monitor
      get :geological_features
      get :settlements
      
      # Phase 3: Mission Tracking
      get :mission_status
      get :console_log
      
      # Phase 4: AI Decisions
      get :ai_decisions
      
      # Phase 5: Sphere Data
      get :sphere_data
      get :sphere_history
      post 'sphere_data/export', to: 'monitoring#export_sphere_data'
    end
  end
  
  resources :missions, only: [] do
    member do
      post :advance_phase  # Testing control
      post :reset          # Testing control
    end
  end
  
  resources :pattern_tests, only: [:index, :create, :show] # Phase 6
end
```

### Response Formats

**Geological Features:**
```json
GET /admin/celestial_bodies/1/geological_features.json

{
  "celestial_body": "Luna",
  "lava_tubes": [
    {
      "id": "luna_lt_001",
      "name": "Marius Hills Skylight",
      "type": "lava_tube",
      "lat": 14.1,
      "lon": -56.8,
      "priority": "high",
      "strategic_value": ["Natural Base", "Radiation Shielding"],
      "dimensions": {
        "diameter_m": 65,
        "volume_m3": 11780972
      },
      "status": "unclaimed"
    }
  ],
  "craters": [
    {
      "id": "luna_cr_001",
      "name": "Shackleton Crater",
      "type": "crater",
      "lat": -89.9,
      "lon": 0.0,
      "priority": "critical",
      "resources": {
        "water_ice_tons": 600000000
      },
      "status": "unclaimed"
    }
  ]
}
```

**Mission Status:**
```json
GET /admin/celestial_bodies/1/mission_status.json

{
  "mission_id": "lunar_precursor_ai_driven",
  "celestial_body": "Luna",
  "status": "in_progress",
  "current_phase": {
    "id": "power_grid_establishment",
    "name": "Automated Power Grid Establishment",
    "number": 2,
    "total_phases": 5,
    "progress": 0.75
  },
  "tasks": [
    {
      "id": "ai_power_system_design",
      "priority": 0,
      "status": "completed",
      "completion_time": "2026-01-13T14:32:18Z"
    },
    {
      "id": "solar_array_deployment",
      "priority": 1,
      "status": "completed",
      "completion_time": "2026-01-13T14:33:45Z"
    },
    {
      "id": "power_distribution_network",
      "priority": 3,
      "status": "in_progress",
      "progress": 0.75
    },
    {
      "id": "dust_mitigation_systems",
      "priority": 4,
      "status": "pending",
      "progress": 0.0
    }
  ],
  "console_log": [
    {
      "timestamp": "2026-01-13T14:35:22Z",
      "level": "info",
      "message": "Deploying solar arrays..."
    }
  ]
}
```

**AI Decisions:**
```json
GET /admin/celestial_bodies/1/ai_decisions.json

{
  "mission_id": "lunar_precursor_ai_driven",
  "decision_type": "site_selection",
  "timestamp": "2026-01-13T14:32:16Z",
  "site_scores": {
    "luna_lt_001": {
      "name": "Marius Hills Skylight",
      "total_score": 8.7,
      "factors": {
        "power_generation_potential": 9.2,
        "thermal_moderation": 8.5,
        "resource_extraction_efficiency": 8.0,
        "communication_reliability": 9.0,
        "operational_safety": 7.5
      },
      "reasoning": "Excellent solar exposure and thermal stability. Good resource access with moderate radiation environment."
    },
    "luna_cr_001": {
      "name": "Shackleton Crater",
      "total_score": 7.2,
      "factors": {
        "power_generation_potential": 8.9,
        "thermal_moderation": 4.0,
        "resource_extraction_efficiency": 10.0,
        "communication_reliability": 6.0,
        "operational_safety": 7.5
      },
      "reasoning": "Exceptional water ice resources but extreme temperature variations. Polar location complicates operations."
    }
  },
  "selected_site": "luna_lt_001",
  "selection_reasoning": "Marius Hills provides better operational conditions despite lower resource concentration. Thermal stability critical for long-term base viability."
}
```

---

## Development Workflow

### Iteration Strategy

**Week 1: Foundation**
- Day 1-2: Phase 1 (Minimal map)
- Day 3-4: Phase 2 (Interactive features)
- Day 5: Testing, bug fixes, documentation

**Week 2: Integration**
- Day 1-3: Phase 3 (Mission tracking)
- Day 4-5: Testing with actual AI missions

**Week 3+: Advanced Features** (as needed)
- Phase 4: AI decision visualization
- Phase 5: Sphere data integration
- Phase 6: Pattern testing (optional)

### Testing Approach

**Unit Tests:**
- Lookup::PlanetaryGeologicalFeatureLookupService (JSON loading - already exists)
- AIMissionStatusService (state queries)
- AIDecisionAnalyzerService (scoring algorithm)

**Integration Tests:**
- Can load geological features from files
- Can query settlements from database
- Can display mission progress

**Manual Testing:**
- Verify map coordinates are accurate
- Test all layer toggles
- Verify decision scores match AI choices
- Monitor live mission execution

### Git Workflow

```bash
# Feature branches
git checkout -b feature/admin-monitoring-phase1
git checkout -b feature/admin-monitoring-phase2
# etc.

# Merge to develop when phase complete
git checkout develop
git merge feature/admin-monitoring-phase1

# Deploy to staging for testing
git checkout staging
git merge develop
```

---

## Known Challenges & Mitigations

### Challenge 1: TaskExecutionEngine State Access

**Problem:** TaskExecutionEngine may be in-memory, not persisted

**Investigation Needed:**
```ruby
# Check current implementation
engine = AIManager::TaskExecutionEngine.new('lunar-precursor')
# How is state stored?
# Can we query active missions?
# Is progress tracked?
```

**Solutions:**
- **Option A:** Persist mission state to database (recommended)
- **Option B:** Add logging/instrumentation to track progress
- **Option C:** Re-run analysis to reconstruct state (slow)

**Mitigation:**
- Start with Phase 1-2 (no mission dependency)
- Research TaskExecutionEngine in Week 1
- Adapt Phase 3 based on findings

### Challenge 2: Geological Feature Coordinates

**Problem:** JSON uses lat/lon, need to convert to pixel coordinates

**Solution:**
```javascript
function latLonToPixel(lat, lon, mapWidth, mapHeight) {
  // Equirectangular projection
  const x = ((lon + 180) / 360) * mapWidth;
  const y = ((90 - lat) / 180) * mapHeight;
  return { x, y };
}
```

**Validation:**
- Plot known features (Marius Hills at 14.1°N, 56.8°W)
- Verify against NASA maps
- Test edge cases (poles, dateline)

### Challenge 3: Performance with 1,577 Craters

**Problem:** Rendering all craters may be slow

**Solutions:**
- **Option A:** Only render visible features (viewport culling)
- **Option B:** Filter by priority (strategic only by default)
- **Option C:** Use level-of-detail (zoom-based rendering)

**Recommendation:** Start with Option B (filter strategic), add Option A if needed

### Challenge 4: Real-time Updates

**Problem:** How to show live mission progress?

**Solutions:**
- **Polling:** Simple, fetch every 5-10 seconds (recommended for MVP)
- **WebSocket:** Complex, requires ActionCable setup
- **Server-Sent Events:** Middle ground

**Recommendation:** Start with polling, upgrade to WebSocket if needed

---

## Success Metrics

### Phase 1-2: Basic Map
- [ ] Can view all celestial bodies with geological features
- [ ] Map coordinates are accurate (verified against NASA data)
- [ ] Click interaction works smoothly
- [ ] No performance issues with 1,577 craters

### Phase 3: Mission Tracking
- [ ] Can monitor live AI missions
- [ ] Phase progress updates correctly
- [ ] Task completion reflects actual AI operations
- [ ] Console log shows AI activity in real-time

### Phase 4: AI Decisions
- [ ] Site scores match AI's actual choices
- [ ] Can explain why AI chose specific sites
- [ ] Visualization helps debug AI logic
- [ ] Decision factors align with mission parameters

### Phase 5: Sphere Data
- [ ] All sphere models display correctly
- [ ] Data updates when spheres change
- [ ] No performance degradation
- [ ] Export functionality works

### Overall Success
- [ ] Developers can debug AI missions faster
- [ ] Can validate AI patterns without manual inspection
- [ ] Visualization aids system understanding
- [ ] Tool becomes standard development workflow

---

## Future Enhancements

### After MVP (Not in Current Plan)

**Player View:**
- Economic opportunity map
- Supply contract system
- Player settlement management
- Market data visualization

**Advanced Features:**
- 3D globe projection (instead of flatmap)
- Time-lapse visualization (watch planet change)
- Multi-planet comparison view
- Pattern recommendation engine
- Automated testing framework

**Integration:**
- Terrain generation from sphere data
- Biome distribution visualization
- Resource deposit heatmaps
- Orbital infrastructure overlay

---

## Dependencies & Prerequisites

### Required Knowledge
- Rails routing and controllers
- JSON parsing in Ruby
- HTML5 Canvas API
- JavaScript event handling
- CSS Grid layout

### Required Access
- Geological feature JSON files (already exist ✅)
- Mission configuration files (already exist ✅)
- Database models (already exist ✅)
- TaskExecutionEngine code (need to investigate)

### External Resources
- NASA lunar maps (for validation)
- Coordinate system references
- Canvas rendering tutorials
- Admin UI design patterns

---

## Timeline & Resource Estimates

### Conservative Estimate (1 Developer)

| Phase | Duration | Complexity | Dependencies |
|-------|----------|------------|--------------|
| Phase 1 | 4-6 hours | Low | None |
| Phase 2 | 4-6 hours | Medium | Phase 1 |
| Phase 3 | 2-3 days | Medium-High | TaskExecutionEngine access |
| Phase 4 | 2-3 days | Medium | Phase 3, scoring algorithm |
| Phase 5 | 2-3 days | Medium | Sphere models |
| Phase 6 | 2-3 days | Medium | All previous |

**Total: 1.5-2 weeks for complete admin dashboard**

**MVP (Phase 1-3): ~1 week**

### Aggressive Estimate (Focused Developer)

- Phase 1-2: 1 day
- Phase 3: 2 days
- Phase 4-5: 3-4 days
- **Total: ~1 week for full dashboard**

### Recommended Approach

**Week 1: Build Foundation**
- Days 1-2: Phase 1-2 (working map)
- Days 3-4: Research TaskExecutionEngine
- Day 5: Start Phase 3 or polish Phase 2

**Week 2: Add Intelligence**
- Complete Phase 3 (mission tracking)
- Decision on Phase 4-5 based on needs

**Week 3+: Polish & Advanced**
- Only if needed for development

---

## Approval & Next Steps

### Decision Points

**Before Starting:**
- [ ] Approve overall approach
- [ ] Confirm technology choices (Canvas vs SVG?)
- [ ] Allocate developer time
- [ ] Set priority (urgent vs nice-to-have)

**After Phase 1:**
- [ ] Evaluate proof-of-concept
- [ ] Decide: Continue or pivot?
- [ ] Adjust timeline based on actual time

**After Phase 3:**
- [ ] Assess utility for development
- [ ] Decide: Add advanced features or ship MVP?

### Go/No-Go Criteria

**Go if:**
- AI Manager needs debugging visibility
- Geological data exploration would help
- Pattern testing is important
- Team will use this regularly

**No-Go if:**
- Command-line tools sufficient
- Focus should be elsewhere
- Other priorities more urgent
- Won't use regularly

---

## Appendix

### Reference Materials

**Existing Documentation:**
- `docs/architecture/ai_manager/` - AI Manager architecture
- `docs/architecture/planetary_patterns/` - Mission patterns
- `docs/developer/ai_testing_framework.md` - Testing approaches
- `lib/tasks/ai_base_building.rake` - Example mission execution

**External Resources:**
- Equirectangular projection: https://en.wikipedia.org/wiki/Equirectangular_projection
- HTML5 Canvas API: https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API
- NASA Lunar Maps: https://lunar.gsfc.nasa.gov/

### Glossary

- **DC Base:** Development Corporation base (AI-managed settlement)
- **Geological Feature:** Lava tube, crater, or other natural formation
- **Mission Phase:** Step in AI Manager's deployment sequence
- **Pattern:** AI Manager configuration template (Venus-like, Mars-like, etc.)
- **Sphere:** Planetary layer (atmosphere, geosphere, hydrosphere, biosphere)
- **TaskExecutionEngine:** AI Manager's mission execution system

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-13 | AI Assistant | Initial planning document |
| 1.1 | 2026-01-13 | AI Assistant | Phase 1 implementation completed |

---

## Implementation Status

### ✅ Phase 1: Minimal Viable Map (COMPLETED)

**Implementation Date:** January 13, 2026
**Time to Complete:** ~30 minutes

**Files Created:**
- `app/views/celestial_bodies/map.html.erb` - Planet map viewer (from prototype)
- Updated `app/controllers/celestial_bodies_controller.rb` - Added map actions using existing `Lookup::PlanetaryGeologicalFeatureLookupService`
- Updated `config/routes.rb` - Added map routes
- Updated `spec/controllers/celestial_bodies_spec.rb` - Added map action tests

**Note:** Uses existing `Lookup::PlanetaryGeologicalFeatureLookupService` for loading geological data instead of creating a new service.

**Routes Added:**
```ruby
GET  /celestial_bodies/:id/map               # Map viewer HTML
GET  /celestial_bodies/:id/geological_features # Geological data JSON API
```

**Features Implemented:**
- ✅ Interactive canvas map with zoom controls
- ✅ Loads geological features from JSON files (lava tubes, craters)
- ✅ Plots features at correct lat/lon coordinates
- ✅ Color-coded markers by priority (critical=magenta, high=green, medium=yellow)
- ✅ Click markers to view feature details
- ✅ Layer toggles (lava tubes, craters, settlements)
- ✅ Info panel showing dimensions, resources, strategic value
- ✅ Grid overlay for coordinate reference
- ✅ Uses planet-type-prototype.html color scheme (#1a1a2e dark theme)

**Data Integration:**
- Reads from `/app/data/json-data/star_systems/sol/celestial_bodies/earth/luna/geological_features/`
- Supports `lava_tubes.json` (12 strategic features)
- Supports `craters.json` (strategic features)
- Auto-formats features with coordinates, priorities, dimensions

**Testing:**
- Controller specs validate map rendering
- Controller specs validate JSON API responses
- Service specs validate geological feature loading
- Service specs validate data formatting

**Usage:**
```
# View Luna map
http://localhost:3000/celestial_bodies/1/map

# API endpoint (for AJAX calls)
http://localhost:3000/celestial_bodies/1/geological_features.json
```

**Next Phase:** Phase 2 (Interactive Feature Map) - pending decision

---

**Next Action:** ~~Review and approve plan, then begin Phase 1 implementation.~~ **COMPLETED - Phase 1 shipped!**

