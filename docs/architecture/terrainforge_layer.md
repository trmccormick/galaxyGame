# TerrainForge Layer - Civilization Layer Interaction Mode

## Overview
TerrainForge IS the Civilization Layer (Layer 4) on the Surface View — not a separate view. It provides two interaction modes within the existing Surface View: Admin mode and Player Corporation mode.

## Key Architecture Correction
- **Surface View** = Single unified view with multiple interaction modes
- **TerrainForge** = Civilization Layer interaction mode within Surface View (NOT a separate view)
- **Two Modes**: Admin (DC base direction, AI Manager training, full visibility) and Player Corporation (base placement, unit deployment, road building, resource claiming)

## Interaction Modes

### Admin Mode
Primary user: System administrators and AI developers
- DC base direction and oversight
- AI Manager training and priority adjustment
- Full visibility across all settlements and corporations
- Megaproject monitoring (Worldhouse, terraforming) — DC/AI Manager only

### Player Corporation Mode
Secondary user: Player corporations (requires corporation membership)
- Base placement and colony development
- Unit deployment and road building
- Resource claiming and infrastructure construction
- Restricted to own corporation assets and territories
- DC bases provide player home base before corporation level

## Access Requirements
- Players must be part of a player corporation to access TerrainForge mode
- DC bases serve as temporary home bases for individual players before corporation formation
- Corporation membership unlocks full TerrainForge capabilities

## Scope Boundaries

### Current Scope: Surface Operations Only
- Planetary surface construction and development
- Colony establishment and expansion
- Resource extraction and processing
- Local infrastructure (roads, landing pads, habitats)
- Corporation-level strategic planning

### Future Scope: Orbital Civilization Layer (Not in Current Scope)
- Orbital infrastructure (AWS, depots, cycler routes)
- Interplanetary logistics networks
- Space station construction
- Fleet operations and tug networks
- Cislunar economic systems

## Technical Specifications
### ConstructionEvent Schema
```json
{
  "event": "ConstructionEvent",
  "type": "building|mining|infrastructure",
  "location": {"x": 45, "y": 22, "celestial_body_id": 123},
  "ai_manager_decision": true,
  "priority": "high|medium|low",
  "estimated_completion": "2026-03-15T10:00:00Z",
  "resources_required": {"steel": 100, "concrete": 50},
  "timestamp": "2026-03-02T12:00:00Z"
}
```

## Implementation Roadmap
- Phase 1: Foundation (TerrainForge mode integration into Surface View)
- Phase 2: Admin Mode (DC base direction, AI Manager training, full visibility)
- Phase 3: Player Corporation Mode (base placement, unit deployment, road building, resource claiming)
- Phase 4: Corporation Access Control (membership requirements, asset restrictions)

## Display Requirements

### Mode Switching
- Toggle between Admin and Player Corporation modes within Surface View
- Admin mode: Full system visibility and control
- Player Corporation mode: Restricted to corporation assets and territories

### Admin Mode Display
- Total DC bases: count (e.g., "847 active colonies")
- Construction status breakdown:
  - Operational (self-sustaining)
  - Under construction (active projects)
  - Planning phase (surveying/planning)
  - Critical issues (resource shortages, etc.)
- Megaproject monitoring (Worldhouse, terraforming) — DC/AI Manager only

### Player Corporation Mode Display
- Corporation territory visualization
- Available construction sites within corporation boundaries
- Resource claims and infrastructure projects
- Unit deployment and road network management
- Restricted visibility to own corporation assets

### Construction Queue View (Admin Mode)
List all active construction projects across all colonies:
- Colony identifier (e.g., "Mars DC-Alpha")
- Project type (e.g., "Seal lavatube", "Build landing pad")
- Progress percentage
- Estimated completion time
- Resource requirements vs available
- Worker allocation
- Critical path items

### Corporation Construction View (Player Mode)
List corporation-specific projects:
- Project type and location
- Progress and resource status
- Corporation resource allocation
- Inter-corporation coordination (future)

### Colony Detail View (Admin Mode)
When admin clicks a specific colony, show:
- Location (planet, coordinates)
- Construction phase (Precursor / Industrial / Surface)
- Completed structures list
- Active projects with detailed progress
- Resource stockpiles
- NPC worker count
- Supply chain status
- Constraint violations (if any)

### Base Detail View (Player Mode)
When player clicks their base, show:
- Corporation affiliation
- Available construction options
- Resource stockpiles and claims
- Unit deployment status
- Road network connections

### AI Manager Priority Controls (Admin Mode)
Admin can adjust global AI priorities:
- Resource security (LOW/MEDIUM/HIGH)
- Population growth rate
- Expansion speed (conservative/moderate/aggressive)
- Trade network development
- Research/experimentation focus

### Project Override Interface
When AI Manager proposes a project, admin can:
- View AI's reasoning (why this location, why now)
- See constraint analysis (slope, stability, resources)
- Approve/reject decision
- Suggest alternative location
- Adjust resource allocation
- Change priority (rush/delay)

## Data Models

### ConstructionProject Model
```javascript
ConstructionProject {
  id: string
  settlement_id: string  // Corrected: belongs to settlement, not colony
  project_type: enum (SEAL_LAVATUBE, BUILD_PAD, INSTALL_POWER, etc)
  phase: enum (PLANNING, RESOURCE_GATHERING, CONSTRUCTION, COMPLETION)
  progress_percent: number
  start_date: timestamp
  estimated_completion: timestamp
  resources_required: {
    concrete: { required: number, available: number }
    steel: { required: number, available: number }
    // etc
  }
  workers_assigned: number
  ai_reasoning: string (why AI chose this project/location)
  constraints: {
    terrain_slope: number
    geological_stability: number
    resource_proximity: number
    // etc
  }
  admin_override: boolean
  priority: enum (LOW, NORMAL, HIGH, CRITICAL)
}
```

### DCSettlement Model (Development Corporation Settlement)
```javascript
DCSettlement {  // Renamed from DCColony - represents individual corporate base
  id: string
  colony_id: string  // Government entity that owns this settlement
  planet_id: string
  name: string (e.g., "Lunar Development Corporation Base Alpha")
  phase: enum (PRECURSOR, INDUSTRIAL, ORBITAL, OPERATIONAL)
  location: { lat: number, lng: number }
  structures: Array<Structure>
  active_projects: Array<ConstructionProject>
  resource_stockpiles: Object
  npc_population: number
  supply_chains: Array<SupplyChain>
  economic_health: number (0-100)
  owner: polymorphic (corporation like LDC)
}
```

## Settlement Pattern Implementation

**Note**: Settlement patterns vary by celestial body. The following shows the Luna pattern. Mars, Venus, and other locations have different sequences documented in mission profiles.

### Luna Pattern: Precursor Mission (Automated)
AI Manager executes these steps in order:

1. **Survey & Site Selection**
   - Analyze planet terrain data (GeoTIFF)
   - Find suitable lavatube locations
   - Check: structural stability, size (min 100m length), accessibility
   - Select best candidate site

2. **Deploy Precursor Equipment**
   - Virtual construction: power grid (solar/nuclear)
   - Virtual construction: resource extractors (regolith processors)
   - Virtual construction: tank farms (O2, H2, fuel storage)
   - Virtual construction: communications array
   - Virtual construction: landing pad (basic, unpressurized)

3. **Begin Lavatube Work**
   - Virtual excavation of entrance
   - Virtual stabilization of walls
   - Track construction time (days/weeks)
   - Track resource consumption

### Luna Pattern: Industrial Bootstrap
AI Manager transitions to local production:

1. **Establish 3D Printing**
   - Use local regolith + extracted metals
   - Begin printing I-beams
   - Begin printing panels
   - Track production rate vs needs

2. **Seal Lavatube**
   - Virtual construction: airlock at entrance
   - Virtual construction: pressure walls at far end
   - Virtual construction: structural reinforcement
   - Pressurize gradually (simulate time)
   - Test seal integrity

3. **Build Internal Structures**
   - Place habitation modules
   - Install life support systems
   - Create work areas (workshops, labs)
   - Establish living quarters
   - Mark as: "Human-habitable"

### Luna Pattern: Surface Expansion (Current Scope)
AI Manager focuses on surface development and resource export:

1. **Expand Surface Operations**
   - Additional habitat modules
   - Extended resource processing facilities
   - Surface transportation networks
   - Export preparation infrastructure

### Luna Pattern: Orbital Infrastructure (Future Scope - Not Implemented)
AI Manager would shift to cislunar/orbital construction:

1. **Build L1 Depot FIRST**
   - Why first: Prevent surface landings by harvesters
   - Construct docking bays
   - Install fuel storage
   - Create cargo transfer system
   - Enable: Venus/Mars harvesters → Depot direct

2. **Establish Cargo Operations**
   - Deploy cargo transports (Luna surface ↔ L1 Depot)
   - Schedule automated runs
   - Track efficiency/loss rates

3. **Build L1 Station**
   - Construct ship repair bays
   - Build tug construction facilities
   - Build cycler construction facilities
   - Enable fleet operations

### Mars Pattern (From Mission Profiles)
- **Phase 0**: Orbital establishment (moons conversion)
- **Phase 1**: Surface outposts & resource mining
- **Phase 2**: Resource infrastructure & tank farms
- **Phase 3**: Advanced mining & material stockpiling

### Venus Pattern (From Mission Profiles)
- **Phase 1**: Orbital depot establishment
- **Phase 2**: Atmospheric resource harvesting
- **Phase 3**: Cloud city operations
- **Phase 4**: Foundry establishment
- **Phase 5**: Industrial integration
- **Phase 6**: Interplanetary logistics network

### Settlement Pattern Architecture
Settlement patterns are location-specific and loaded from mission profile JSON files. The AI Manager selects appropriate patterns based on:
- Celestial body characteristics (atmosphere, gravity, resources)
- Strategic priorities (resource extraction, colonization, research)
- Existing infrastructure availability
- ROI calculations for different approaches

## Constraint Validation System

### Construction Site Validation
AI Manager must check these constraints before building:

```javascript
validateConstructionSite(planet, location, structure_type) {
  const constraints = {
    // Terrain constraints
    max_slope: 30,              // degrees (can't build on steep slopes)
    min_stability: 0.7,         // geological stability (0-1)
    
    // Environmental constraints  
    max_temperature: 400,       // K (too hot = no construction)
    max_radiation: 100,         // rads/day (human safety limit)
    
    // Resource constraints
    min_resource_proximity: 50, // km (must have resources nearby)
    
    // Structural constraints (for lavatubes)
    min_tube_length: 100,       // meters
    min_tube_width: 20,         // meters
    min_tube_height: 15,        // meters
    max_tube_instability: 0.3,  // (0-1, risk of collapse)
    
    // Logistics constraints
    max_supply_distance: 200,   // km (from other bases/depots)
  }
  
  // Return: { valid: boolean, violations: Array<string>, score: number }
}
```

## Time & Resource Simulation System

### Construction Duration
Each project type has realistic timeframes:

```javascript
PROJECT_DURATIONS = {
  // Phase 1: Precursor (automated robots)
  INSTALL_POWER_GRID: { min_days: 14, max_days: 30 },
  DEPLOY_EXTRACTORS: { min_days: 7, max_days: 14 },
  BUILD_TANK_FARM: { min_days: 21, max_days: 45 },
  CONSTRUCT_LANDING_PAD: { min_days: 10, max_days: 20 },
  
  // Phase 2: Industrial (local production)
  SEAL_LAVATUBE_SMALL: { min_days: 90, max_days: 180 },  // 100m tube
  SEAL_LAVATUBE_LARGE: { min_days: 180, max_days: 365 }, // 500m tube
  BUILD_HABITAT_MODULE: { min_days: 30, max_days: 60 },
  INSTALL_LIFE_SUPPORT: { min_days: 14, max_days: 30 },
  
  // Phase 3: Orbital (export construction)
  BUILD_L1_DEPOT: { min_days: 365, max_days: 730 },      // 1-2 years
  BUILD_L1_STATION: { min_days: 730, max_days: 1460 },   // 2-4 years
  CONSTRUCT_TUG: { min_days: 90, max_days: 180 },
  CONSTRUCT_CYCLER: { min_days: 180, max_days: 365 },
}
```

### Resource Consumption
Track materials used during construction:

```javascript
RESOURCE_REQUIREMENTS = {
  SEAL_LAVATUBE_SMALL: {
    concrete: 5000,      // tons
    steel_ibeams: 500,   // tons
    panels: 2000,        // units
    airlocks: 2,         // units
    life_support: 1,     // system
    power: 2000,         // kWh/day during construction
    workers: 50,         // person-days
  },
  
  BUILD_L1_DEPOT: {
    structural_steel: 10000,  // tons
    hull_plating: 5000,       // tons  
    docking_systems: 10,      // units
    fuel_tanks: 20,           // large tanks
    power_systems: 50,        // MW capacity
    workers: 500,             // person-days
  }
}
```

### Progress Tracking
Simulate day-by-day progress:

```javascript
simulateConstructionProgress(project, elapsed_days) {
  // Factors affecting progress:
  const factors = {
    resource_availability: 0.9,  // 90% of needed resources on-hand
    worker_efficiency: 0.85,      // 85% efficiency (fatigue, breaks)
    equipment_uptime: 0.92,       // 92% equipment operational
    weather_delays: 0.95,         // 5% delay from dust storms/etc
  }
  
  const effective_progress = 
    (elapsed_days / project.duration) * 
    factors.resource_availability *
    factors.worker_efficiency *
    factors.equipment_uptime *
    factors.weather_delays
  
  return Math.min(1.0, effective_progress) // Cap at 100%
}
```

### Supply Chain Simulation
Track logistics and loss rates:

```javascript
calculateSupplyChainLoss(origin, destination, cargo_type) {
  const distance_km = calculateDistance(origin, destination)
  
  // Base loss rate: 1% per 100km
  const base_loss_rate = (distance_km / 100) * 0.01
  
  // Modifiers:
  const terrain_modifier = getTerrainDifficulty(origin, destination) // 1.0-2.0
  const cargo_fragility = CARGO_FRAGILITY[cargo_type] // 1.0-1.5
  
  const total_loss_rate = base_loss_rate * terrain_modifier * cargo_fragility
  
  return Math.min(0.50, total_loss_rate) // Cap at 50% loss
}
```

## View Implementation

### Integration with Existing Views
TerrainForge sits alongside Monitor and Surface views:
```
View Switcher:
[🌍 Monitor] [🌱 Surface] [🔨 TerrainForge]
                                    ↑ active
```

### Layout Structure
```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Colony Filter & Controls                             │
├─────────────────┬───────────────────────────────────────────┤
│                 │                                             │
│   SIDEBAR:      │   MAIN CANVAS:                             │
│                 │                                             │
│   - Colony List │   - 3D or top-down view of construction   │
│   - Filters     │   - Show structures being built           │
│   - AI Status   │   - Progress indicators                   │
│   - Priorities  │   - Resource flows                        │
│                 │   - Worker activity                        │
│                 │                                             │
│                 │                                             │
├─────────────────┴───────────────────────────────────────────┤
│ FOOTER: Selected Project Details & Override Controls         │
└─────────────────────────────────────────────────────────────┘
```

### Visual Representation
Options for showing construction:

1. **Grid Overlay on Terrain**
   - Show terrain (from GeoTIFF)
   - Overlay construction zones (semi-transparent)
   - Highlight active work areas (pulsing/animated)
   - Show completed structures (solid icons)

2. **Schematic View**
   - Top-down blueprint style
   - Color-coded by phase (Precursor=blue, Industrial=orange, Orbital=purple)
   - Progress bars on each structure
   - Connection lines showing supply routes

3. **3D Isometric** (future enhancement)
   - Minecraft-style 3D view
   - See structures in 3D
   - Rotate/zoom camera
   - Click structures for details

### Interaction Model

User can:
- Click colony in sidebar → Load colony view
- Click structure in view → Show project details
- Click "Adjust Priorities" → Open priority controls
- Click "Override" on project → Show override dialog
- Filter colonies by: phase, status, planet type
- Search: "Find all colonies with critical resources"

## UI Wireframe
```
┌─────────────────────────────────────────────────────────────┐
│ TERRAINFORGE - AI MANAGER CONSTRUCTION MONITOR              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ 🏗️ ACTIVE COLONIES: 847                                      │
│ ├─ Operational: 621 ✅                                        │
│ ├─ Under Construction: 183 🏗️                                │
│ └─ Critical Resources: 43 ⚠️                                  │
│                                                               │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                               │
│ 🔨 CONSTRUCTION QUEUE (Top 10)                               │
│ ┌───────────────────────────────────────────────────────┐   │
│ │ Mars DC-Alpha    │ Seal Lavatube   │ 85% │ 12 days   │   │
│ │ Luna DC-Beta     │ Build Pad #4    │ 45% │ 6 days    │   │
│ │ Titan DC-Alpha   │ Methane Storage │ 92% │ 3 days    │   │
│ │ Europa DC-Alpha  │ Ice Drill       │ 12% │ 45 days   │   │
│ └───────────────────────────────────────────────────────┘   │
│                                                               │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                               │
│ ⚙️ AI MANAGER PRIORITIES                                     │
│ Resource Security:    ████████░░ HIGH                        │
│ Population Growth:    █████░░░░░ MEDIUM                      │
│ Expansion Rate:       █████░░░░░ MEDIUM                      │
│ Trade Network:        ████████░░ HIGH                        │
│                                                               │
│ [Adjust Priorities] [View Colony Details] [Override Project] │
└─────────────────────────────────────────────────────────────┘
```

## Routes & Controllers

### Routes Configuration
```ruby
# config/routes.rb
namespace :admin do
  resources :terrainforge, only: [:index, :show] do
    member do
      post :override_project
      patch :adjust_priorities
    end
    
    collection do
      get :construction_queue
      get :ai_status
    end
  end
end
```

### Controller Implementation
```ruby
# app/controllers/admin/terrainforge_controller.rb
class Admin::TerrainforgeController < ApplicationController
  def index
    @colonies = DCColony.includes(:active_projects).all
    @ai_status = AIManager.current_status
    @construction_queue = ConstructionProject.active.order(:priority, :estimated_completion)
  end
  
  def show
    @colony = DCColony.find(params[:id])
    @terrain_data = @colony.celestial_body.geosphere.terrain_map
    @structures = @colony.structures
    @active_projects = @colony.active_projects
  end
  
  def override_project
    project = ConstructionProject.find(params[:project_id])
    project.admin_override(params[:decision], params[:reason])
    # Log admin action for audit
  end
  
  def adjust_priorities
    AIManager.update_priorities(params[:priorities])
    # Triggers AI Manager recalculation
  end
end
```

## Decision Audit Trail

### What to Log
Every AI Manager decision should be recorded:
```javascript
AIDecisionLog {
  id: uuid
  timestamp: datetime
  decision_type: enum (
    SITE_SELECTION,
    PROJECT_INITIATION,
    RESOURCE_ALLOCATION,
    PRIORITY_CHANGE,
    PHASE_TRANSITION
  )
  
  colony_id: string
  project_id: string (if applicable)
  
  decision_data: {
    chosen_option: string
    alternatives_considered: Array<string>
    reasoning: string
    confidence_score: number (0-1)
  }
  
  constraints_evaluated: {
    terrain_slope: { value: number, threshold: number, pass: boolean }
    resource_proximity: { value: number, threshold: number, pass: boolean }
    // etc for all constraints
  }
  
  admin_override: boolean
  override_reason: string (if overridden)
}
```

### Admin Review Interface

Allow admin to:
- View all decisions for a colony
- Filter by decision type
- See AI's reasoning
- Identify patterns (is AI always choosing steep slopes?)
- Override with feedback (AI learns from overrides)

### Analytics Dashboard

Show metrics:
- Decision success rate (completed projects / initiated)
- Override frequency (admin intervention rate)
- Constraint violation patterns
- Resource efficiency trends
- Time estimation accuracy

## Related Tasks
- `implement_terrainforge_layer.md` (active)
- Dynamic terrain system roadmap integration
- AI Manager operational escalation