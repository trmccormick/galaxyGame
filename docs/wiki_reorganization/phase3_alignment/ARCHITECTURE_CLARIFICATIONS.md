# ARCHITECTURE_CLARIFICATIONS.md

**Created**: 2026-07-16  
**Purpose**: Document systems where code and documentation both exist but the relationship between them is unclear. Includes hierarchy diagrams, namespace conventions, and integration points that need clarification.  
**Authority**: The 12 canonical intent statements are authoritative. Clarifications resolve ambiguity — they do not override design decisions.

---

## Classification System

| Category | Meaning | Action |
|----------|---------|--------|
| **A — Correct** | Documentation matches intent | No action |
| **B — Clarification** | Documentation is correct but unclear (missing diagrams, terminology, relationships) | Low-priority cleanup |
| **C — Outdated** | Documentation reflects previous architecture | Requires rewriting |
| **D — Missing** | Architecture exists but documentation does not | Add documentation |
| **E — True Design Decision** | No authoritative intent exists; genuine unresolved question | Requires human decision |

---

## Part 1: Hierarchy Clarifications

### 1.1 Colony → Settlement → Structure Hierarchy

**Canonical Intent**: #1 (Colony = governance entity of 2+ settlements), #2 (Settlements = administrative population centers), #3 (Structures = physical assets belonging to settlements)

**Code Evidence**:
```ruby
# app/models/colony.rb
class Colony < ApplicationRecord
  belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
  has_many :settlements, class_name: 'Settlement::BaseSettlement', foreign_key: 'colony_id', dependent: :destroy, inverse_of: :colony
  validates :must_have_multiple_settlements
end

# app/models/settlement/base_settlement.rb
module Settlement
  class BaseSettlement < ApplicationRecord
    has_one :marketplace
    has_one :location
    has_many :docked_crafts
    has_many :base_units
  end
end

# app/models/structures/worldhouse.rb (inherits from BaseStructure)
class Worldhouse < BaseStructure
  # Attached to settlement via settlement_id
end
```

**Canonical Intent Alignment**: **A — Correct**. Code perfectly matches canonical intent. Colony contains settlements; settlements contain/manage structures and units.

**Clarification Needed**: No documentation exists that shows this hierarchy visually for contributors. Add governance_hierarchy.md to wiki section 04.

---

### 1.2 Orbital Settlement Structure Collection

**Canonical Intent**: #4 (Orbital settlement = collection of orbital structures operating together; does not require single physical object)

**Code Evidence**:
```ruby
# app/models/settlement/orbital_depot.rb — Active, inherits from BaseSettlement
class OrbitalDepot < BaseSettlement
  # Represents operational entity managing constellation of structures
end

# app/models/settlement/space_station.rb — Also a settlement type
# app/models/orbital_depot.rb (root) — RETIRED legacy PORO
```

**Canonical Intent Alignment**: **A — Correct**. OrbitalDepot in Settlement namespace is the active model. Root-level file is retired. Multiple models for orbital entities are expected per intent #4.

**Clarification Needed**: Documentation should explicitly state that orbital settlements are operational entities managing constellations of structures, not single physical objects. Add to wiki section 04 (orbital_infrastructure.md).

---

### 1.3 Worldhouse as Structure (Not Settlement)

**Canonical Intent**: #5 (Worldhouses = structures built over natural terrain. Constructed, permanent, infrastructure. Not deployable units, settlements, or vehicles)

**Code Evidence**:
```ruby
# app/models/structures/worldhouse.rb
class Worldhouse < BaseStructure
  # Inherits from BaseStructure, attached to settlement via settlement_id
  # Built in-situ, transforms natural feature into pressurized volume
end
```

**Canonical Intent Alignment**: **A — Correct**. Worldhouse inherits from BaseStructure, not BaseSettlement. Code matches canonical intent perfectly.

**Clarification Needed**: No documentation explicitly states worldhouses are structures (not settlements). Add to wiki section 04 (structure_types.md).

---

## Part 2: Namespace Convention Clarifications

### 2.1 Settlement Namespace

**Canonical Intent**: #2/#3 (Settlements = administrative; Structures = physical)

**Code Evidence**:
```
app/models/settlement/
├── base_settlement.rb      ← Administrative container
├── orbital_depot.rb        ← Orbital settlement type
└── space_station.rb        ← Station settlement type

app/models/structures/
├── worldhouse.rb           ← Structure (not settlement)
├── crater_dome.rb          ← Structure
└── hangar.rb               ← Structure

app/models/orbital_depot.rb ← RETIRED (kept for git history only)
```

**Canonical Intent Alignment**: **A — Correct**. Settlement namespace contains administrative entities. Structures namespace contains physical assets. Root-level OrbitalDepot is retired.

**Clarification Needed**: No documentation explains the settlement vs structures namespace convention. Add to wiki section 01 (namespace_rules.md).

---

### 2.2 AI Manager Service Namespace

**Canonical Intent**: #9 (AI Manager expected to contain many services; documentation should explain responsibilities, architecture, decision flow, interfaces)

**Code Evidence**:
```
app/services/ai_manager/
├── ai_manager.rb                    ← Master orchestration
├── wormhole_coordinator.rb          ← BFS wayfinding
├── consortium_voting_engine.rb      ← ROI governance
├── hammer_protocol_service.rb       ← Snap control
├── brown_dwarf_hub_manager.rb       ← L3 anchors
├── em_harvesting_service.rb         ← EM fountains
├── expansion_assessment.rb          ← Scouting
├── multi_wormhole_event_handler.rb  ← AI learning
├── colony_manager.rb                ← Colony management (80+ more services)
├── system_intelligence_service.rb   ← System analysis
├── resource_flow_simulator.rb       ← Resource simulation
├── economic_forecaster_service.rb   ← Economic forecasting
├── task_execution_engine_v2.rb      ← Task execution
└── precursor_learning_service.rb    ← Precursor AI learning
```

**Canonical Intent Alignment**: **C — Outdated**. The architecture doc describes 8 core files but the system has 80+ services. Documentation is outdated per intent #9.

**Clarification Needed**: Architecture doc needs restructuring into "Orchestration Layer" (8 core) + "Services Inventory" (80+). Add service dependency map.

---

### 2.3 Cycler Model Location

**Canonical Intent**: No specific canonical statement for cycler namespace convention.

**Code Evidence**:
```
app/models/cycler.rb                    ← Root namespace (active)
docs/architecture/services/ai_manager/CYCLER_SYSTEM_ARCHITECTURE.md ← Documents as AI Manager subsystem
```

**Canonical Intent Alignment**: **B — Clarification**. Model exists at root namespace but is documented as AI Manager subsystem. Namespace convention needs clarification.

**Clarification Needed**: Is Cycler a standalone model or an AI Manager subsystem? Document the convention and enforce it consistently.

---

## Part 3: Integration Point Clarifications

### 3.1 Blueprint vs Template Relationship

**Canonical Intent**: #6 (Blueprints = data definitions), #7 (Templates = development/design documents)

**Code Evidence**:
```
data/json-data/templates/              ← Templates (v1-v7 across types)
├── component_blueprint_v1.1.json
├── craft_blueprint_v1.7.json
└── unit_blueprint_v1.4.json

data/json-data/blueprints/             ← Blueprints (runtime game data)
├── unit_blueprints/
├── structure_blueprints/
└── craft_blueprints/

app/models/blueprint.rb                ← Blueprint model class
```

**Canonical Intent Alignment**: **A — Correct**. Templates are in templates/ directory. Blueprints are in blueprints/ directory. Code separates them correctly per intents #6 and #7.

**Clarification Needed**: No documentation explains the template → blueprint workflow. Add to wiki section 06 (blueprint_schema.md).

---

### 3.2 Economy: NPC Creation → Player Participation

**Canonical Intent**: #10 (NPCs create initial economy), #11 (Imports expensive, transportation/fuel never free)

**Code Evidence**:
```
app/services/market/
├── demand_service.rb                  ← Market conditions calculation
└── npc_price_calculator.rb            ← NPC pricing logic

app/services/logistics/
└── transport_cost_service.rb          ← EM physics integration

app/models/financial/account.rb         ← Dual-currency (GCC/USD)
app/services/financial/exchange_rate_service.rb  ← Exchange rate management
```

**Canonical Intent Alignment**: **D — Missing**. Code exists but integration flow between NPC economy and player participation is undocumented.

**Clarification Needed**: Document how NPC pricing → market conditions → player contract opportunities flow through the system. Add to wiki section 07 (market_operations.md).

---

### 3.3 TerraSim: Sphere Simulation → Biome Classification → Regression

**Canonical Intent**: #5 (Worldhouses built over natural terrain), #12 (Earth Foundation first)

**Code Evidence**:
```
app/models/celestial_bodies/spheres/
├── atmosphere.rb
├── hydrosphere.rb
├── geosphere.rb
├── biosphere.rb
└── cryosphere.rb                      ← Model exists, no simulation service

docs/architecture/terrasim/OVERVIEW.md  ← "No explicit regression filter exists yet"
docs/architecture/starsim/OVERVIEW.md   ← "Civ4 Shoreline Flooding" known issue
```

**Canonical Intent Alignment**: **E — True Design Decision**. Regression/weathering engine is a core SimEarth feature not addressed by canonical intent. Implementation status needs decision.

**Clarification Needed**: Document the planned regression engine architecture and its dependency on the shoreline filter. Add to wiki section 03 (terra_sim_overview.md).

---

## Part 4: Summary by Category

### Overall Classification Across All Architecture Clarifications

| Category | Count | Key Items |
|----------|-------|-----------|
| **A — Correct** | 6 | Colony/Settlement/Structure hierarchy, OrbitalDepot namespace, Worldhouse as structure, settlement vs structures namespaces, blueprint vs template separation |
| **B — Clarification** | 2 | Cycler model location, Mk dependency enforcement |
| **C — Outdated** | 1 | AI Manager architecture doc (8 files → 80+ services) |
| **D — Missing** | 3 | NPC economy integration flow, template→blueprint workflow, governance hierarchy diagram |
| **E — True Design Decision** | 1 | Regression/weathering engine implementation |

### Key Clarifications Needed

1. **Governance hierarchy diagram** (Colony → Settlement → Structure) — Add to wiki section 04
2. **Orbital settlement documentation** — Clarify that orbital settlements manage constellations of structures, not single objects
3. **Namespace conventions** — Document settlement vs structures namespace separation in wiki section 01
4. **Template → Blueprint workflow** — Document the design document → runtime data pipeline in wiki section 06
5. **NPC economy integration** — Document how NPC pricing flows to player contract opportunities in wiki section 07
