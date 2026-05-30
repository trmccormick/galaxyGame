# TASK: TaskExecutionEngine Cleanup + AI Manager Training Resumption Architecture
**Status**: BACKLOG
**Priority**: CRITICAL
**Type**: architecture
**Created**: 2026-04-18
**Last Updated**: 2026-04-18

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires deep architectural reasoning across AI Manager, mission generation, pattern learning, DC establishment, and wormhole expansion systems
**Supervision Level**: 🟢 Autonomous OK

---

## North Star

The AI Manager autonomously builds **Development Corporations** on new worlds
to establish footholds for players. As the player base expands, the AI Manager
expands wormhole station infrastructure to open access to new systems. Players
operate within the footholds the AI Manager creates — buying from DC markets,
contracting with DC logistics, building on top of DC infrastructure.

**The full expansion loop:**
1. AI Manager surveys a new system via wormhole
2. Matches system properties to learned patterns (Phobos Pattern, Luna Precursor, etc.)
3. Generates a mission autonomously from `tasks_v2` building blocks
4. `TaskExecutionEngine` executes the mission — pure runner, no hardcoded knowledge
5. AI Manager establishes a Development Corporation at the foothold
6. DC creates initial market infrastructure — players can now participate
7. Players expand from the foothold — buy from DC markets, contract logistics
8. As player base grows — AI Manager identifies next wormhole expansion target
9. Builds wormhole station infrastructure to open new system access
10. Repeat in new system

---

## Background — January 2026 Test

The first AI Manager training test in January 2026 validated the core concept
but exposed fundamental codebase problems that blocked correct operation:

- `TaskExecutionEngine` had hardcoded Luna/L1 logic bypassing pattern learning
- Settlement/structure hierarchy was wrong — SpaceStation/OrbitalDepot mixed concerns
- Market system not connected to construction projects
- No `StructureCore` — structures couldn't associate with correct settlement types
- `OrbitalConstructionProject` associated with wrong settlement class
- No blueprint-driven material resolution — materials hardcoded in engine

**The last several months have been fixing this foundation.** AI Manager
training cannot resume until the remaining blockers are resolved.

---

## What Has Been Fixed (Foundation Work Complete)

- ✅ `SettlementCore` extracted — settlement hierarchy clean
- ✅ `OrbitalSettlement` properly separated from `BaseSettlement`
- ✅ `SpaceStation`/`OrbitalDepot` retired — rewired to `OrbitalSettlement`
- ✅ `OrbitalConstructionProject` association fixed to `OrbitalSettlement`
- ✅ `OrbitalSettlement` has `has_many :orbital_construction_projects`
- ✅ Marketplace architecture designed (April 16 sessions)
- ✅ Docking transaction system designed
- ✅ Material storage classification in design

---

## Remaining Blockers Before AI Training Resumes

### Blocker 1 — `StructureCore` not extracted
`BaseStructure` has hardcoded `belongs_to :settlement, class_name: 'Settlement::BaseSettlement'`.
`OrbitalStructure` can't associate with `OrbitalSettlement`. Blocks all
orbital construction and DC establishment in orbital scenarios.
**Task**: `2026-04-18-HIGH-ARCHITECTURE-STRUCTURE-CORE-CONCERN.md`

### Blocker 2 — `orbital_resupply_cycle` in wrong place
`TaskExecutionEngine.orbital_resupply_cycle` is hardcoded Luna/L1 logic
sitting inside the pure task runner. Poisons AI Manager testing — bypasses
pattern learning and forces hardcoded outcomes. Must be extracted.
**Fix**: Extract to `OrbitalConstructionLogisticsService`

### Blocker 3 — `TaskExecutionEngine` not reading `tasks_v2`
Engine needs to properly read and execute task definitions from
`app/data/json-data/missions/tasks_v2/`. Currently uses hardcoded logic
instead of task library.
**Fix**: Verify/repair task library integration

### Blocker 4 — Marketplace on structure not implemented
Players can't fill construction buy orders without a marketplace on the
depot structure. DC establishment requires this.
**Task**: `2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.md`

### Blocker 5 — `OrbitalConstructionLogisticsService` doesn't exist
No clean service for blueprint-driven material ferry and market order
placement. Bootstrap mode (no marketplace yet) vs market mode (marketplace
active) logic not implemented.
**New task needed**: See below

### Blocker 6 — Mission generation layer not designed
AI Manager can learn patterns but can't yet generate mission JSON
autonomously from pattern knowledge + system survey. The generation
layer sits between pattern learning and `TaskExecutionEngine`.
**New task needed**: See below

---

## TaskExecutionEngine — Correct Architecture

### What it IS
A pure mission task runner. Reads a mission JSON, executes tasks in
sequence from the `tasks_v2` library, tracks progress, passes outputs
to next task as inputs. **No knowledge of specific worlds, materials,
or construction scenarios.**

### What it is NOT
- Not a logistics service
- Not a construction manager
- Not a market order placer
- Not a material calculator

### Task execution flow
```
Mission JSON
  → sequence of task_ids
  → for each task_id: load tasks_v2/task_[id].json
  → resolve inputs from current game state
  → execute task handler (deploy_unit, excavate, ferry, survey, etc.)
  → capture outputs
  → pass outputs as inputs to next task
  → track progress on OrbitalConstructionProject or Mission record
```

### `orbital_resupply_cycle` extraction
Move to `OrbitalConstructionLogisticsService`. Rewrite as blueprint-driven,
market-aware, world-neutral. See design spec below.

---

## OrbitalConstructionLogisticsService — Design Spec

### Responsibility
Manage material delivery to active `OrbitalConstructionProject` records.
Two modes based on marketplace existence:

### Bootstrap Mode (no marketplace yet — first structure at location)
```
1. Find active OrbitalConstructionProject with unfilled material needs
2. Check: OrbitalSettlement.structures.any? with marketplace → NO
3. Read project.required_materials - project.delivered_materials = needed
4. Materials come from blueprint_data.materials (Strategy A)
   OR calculated from body properties (Strategy B — asteroid conversion)
5. Find surface settlement with surplus of needed materials
6. Find available HLT craft at that settlement
7. Schedule ferry mission — materials delivered via deliver_materials
```

### Market Mode (marketplace active — depot exists)
```
1. Find active OrbitalConstructionProject with unfilled material needs
2. Check: OrbitalSettlement.structures.any? with marketplace → YES
3. Place buy orders on marketplace for needed materials
4. Players fill orders — player-first economy enforced
5. NPC ferry only as fallback after configurable timeout
6. Materials flow through marketplace → deliver_materials
```

### Material Resolution Strategies

**Strategy A — Blueprint driven:**
```
structure_blueprint.blueprint_data.materials
  → OrbitalConstructionProject.required_materials
```
Used for: All standard orbital structures (depot, shipyard, habitat ring)

**Strategy B — Property driven (asteroid/moon conversion):**
```
CelestialBody.properties (mass, radius, composition, porosity)
  + ExcavatedCavity.dimensions
  + atmospheric volume calculation
  → MaterialCalculationService.calculate(cavity, body)
  → OrbitalConstructionProject.required_materials
```
Used for: Asteroid conversion, moon base conversion, body-derived habitats.
Geosphere composition determines what's locally available vs needs ferrying.

---

## Mission Generation Layer — Design Spec

### Responsibility
Bridge between AI Manager pattern knowledge and `TaskExecutionEngine`.
Surveys a system, matches to learned patterns, generates mission JSON.

### Flow
```
1. AI Manager surveys new system
   → WorldKnowledgeService reads celestial body properties
   → AtmosphericEvaluator assesses habitability
   → SystemArchitect identifies infrastructure opportunities

2. Pattern matching
   → MissionProfileAnalyzer compares system to learned patterns
   → Phobos Pattern: asteroid belt + L1 point available?
   → Luna Precursor: rocky moon with water ice near habitable zone?
   → Venus Aerostat: dense atmosphere, high insolation?

3. Mission generation
   → Select matched pattern as template
   → Customize task sequence for this system's specific properties
   → Assemble mission JSON from tasks_v2 building blocks
   → Set inputs/outputs based on system survey results

4. DC establishment trigger
   → On mission completion: create Development Corporation entity
   → Set up DC accounts, marketplace, initial buy/sell orders
   → Enable player participation
```

---

## Development Corporation Establishment

When AI Manager completes a foothold mission:

```ruby
DevelopmentCorporationService.establish!(
  system: solar_system,
  location: celestial_location,
  settlement: orbital_settlement,
  pattern: :phobos_pattern  # or :luna_precursor, :venus_aerostat etc.
)
```

This creates:
- `Organizations::DevelopmentCorporation` entity
- DC `Financial::Account` with initial GCC
- Initial marketplace buy/sell orders for player goods
- Mission contracts available for players
- Wormhole station infrastructure if at wormhole location

---

## Wormhole Expansion Integration

AI Manager prioritizes wormhole station infrastructure because:
- Each new system requires a wormhole station before access
- Station mass contributes to wormhole stability (STE ratio)
- L1 positioning of hollowed asteroids reduces wormhole tax
- As player base grows → more systems needed → more wormhole stations

Wormhole expansion triggers when:
- Current system player population exceeds threshold
- Adjacent system survey shows expansion value
- DC in current system is self-sustaining (market orders filling via players)

---

## Sol as Validation Environment

Sol is the AI Manager's first test case:
- AI Manager starts with only learned patterns — no hardcoded Sol knowledge
- Surveys Sol system using `WorldKnowledgeService`
- Should identify Luna as Luna Precursor pattern candidate
- Should identify asteroid belt as Phobos Pattern candidate
- Should build L1 depot before shipyard (bootstrap sequence)
- Should establish LDC (Lunar Development Corporation) as first DC
- We observe and measure against expected expansion logic

**Success criteria for Sol test:**
- AI Manager proposes Luna foothold without being told
- AI Manager sequences depot before shipyard correctly
- AI Manager places market orders before scheduling NPC ferries
- AI Manager establishes DC with correct marketplace and contracts
- AI Manager identifies next expansion target (Mars or L1 shipyard)

---

## New Services Needed

| Service | Purpose | Blocked By |
|---|---|---|
| `OrbitalConstructionLogisticsService` | Material ferry + market orders for construction | StructureCore, Marketplace |
| `MissionGeneratorService` | Pattern → mission JSON generation | Pattern learning review |
| `MaterialCalculationService` | Property-driven material requirements for asteroid conversion | ExcavatedCavity design |
| `DevelopmentCorporationService` | DC establishment on foothold completion | OrbitalSettlement marketplace |

---

## Failing Specs — Mark Pending

These 3 specs test hardcoded behavior that will be removed:

```ruby
# spec/services/ai_manager/task_execution_engine_spec.rb
# Lines 648, 654, 666 — orbital_resupply_cycle
# PENDING: orbital_resupply_cycle extraction to OrbitalConstructionLogisticsService
# See: 2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN.md
xit 'schedules a material ferry mission' do ... end
xit 'updates craft status' do ... end
xit 'does not schedule missions' do ... end
```

---

## Implementation Order

1. `StructureCore` extraction — unblocks OrbitalStructure/OrbitalSettlement association
2. `Marketplace on Structure` — unblocks DC establishment and market mode
3. Extract `orbital_resupply_cycle` → `OrbitalConstructionLogisticsService`
4. `OrbitalConstructionLogisticsService` — blueprint-driven, market-aware
5. Mark 3 failing specs pending
6. Verify `TaskExecutionEngine` reads `tasks_v2` correctly
7. `MaterialCalculationService` — property-driven requirements
8. `MissionGeneratorService` — pattern → mission generation
9. `DevelopmentCorporationService` — DC establishment
10. Sol validation test — observe AI Manager expansion behavior

---

## Dependencies

**Blocked by:**
- `2026-04-18-HIGH-ARCHITECTURE-STRUCTURE-CORE-CONCERN.md`
- `2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.md`
- `2026-04-17-CRITICAL-ARCHITECTURE-ENCLOSED-ATMOSPHERE-FAILURE-PREDICTION-PLANNING.md`
  (for asteroid conversion / worldhouse)

**Blocks:**
- AI Manager training resumption
- Sol validation test
- Wormhole expansion implementation
- New system DC establishment

---

## Acceptance Criteria
- [ ] Architecture document produced covering all components
- [ ] `OrbitalConstructionLogisticsService` fully designed
- [ ] `MissionGeneratorService` interface specified
- [ ] DC establishment flow designed
- [ ] Sol validation test criteria defined
- [ ] Implementation order confirmed
- [ ] No code changes in this task — design only
- [ ] 3 failing specs marked pending with correct reference

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:

### Design decisions made
### New services specified
### Implementation tasks created
### Open questions remaining
