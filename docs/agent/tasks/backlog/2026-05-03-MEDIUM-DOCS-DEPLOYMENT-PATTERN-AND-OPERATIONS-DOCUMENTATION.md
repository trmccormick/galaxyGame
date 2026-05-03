# TASK: Deployment Pattern and Operations Documentation
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: documentation
**Created**: 2026-05-03
**Last Updated**: 2026-05-03

---

## Agent Assignment
**Assigned To**: Gemini (docs agent)
**Why This Agent**: Pure documentation work, large context
cross-referencing, no code changes, no RSpec
**Supervision Level**: 🟡 Standard — human reviews before saving

---

## Context

During session 2026-05-02 significant architectural decisions
were made and captured in LUNA_BASE_ESTABLISHMENT.md. Three
additional documentation files need to be written based on
existing source material. All source files are referenced
below — do not invent content, only document what already
exists in the referenced files.

**Already completed (do not redo):**
- docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md ✅
- docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md ✅

---

## Task 1 — Update NPC_INITIAL_DEPLOYMENT_SEQUENCE.md

**File to update:**
`docs/patterns/deployment/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md`

**Source files — read before writing:**
- docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md
- data/json-data/missions/psyche_mining_hub/ (all files)
- data/json-data/missions/tasks_v2/task_body_survey_v1.json
- data/json-data/missions/tasks_v2/task_tug_capture_v1.json
- data/json-data/missions/tasks_v2/task_interplanetary_towing_v1.json
- data/json-data/missions/tasks_v2/task_rigid_spine_integration_v1.json
- data/json-data/missions/tasks_v2/task_modular_build_v1.json

**Changes needed:**

1. Add Earth special case — HLT permanent on Earth→LEO,
   never reassigned

2. Correct two-station structure:
   - Depot first, Shipyard second
   - LEO Depot is Depot ONLY — no shipyard at LEO
   - Shipyard only at L1 and beyond
   - Lower value locations may need single station only

3. Add three construction methods (high level — reference
   task files for implementation details, do not duplicate):

   **Method 1 — Prefab Shell (I-beam/Panel)**
   Best for: bodies with surface manufacturing capability
   References: task_modular_build_v1.json,
   task_rigid_spine_integration_v1.json
   Prerequisites: ISRU, 3D printer, mass launcher

   **Method 2 — Asteroid Conversion**
   Best for: locations near suitable asteroids, bodies
   with no surface manufacturing capability
   References: task_body_survey_v1.json,
   task_tug_capture_v1.json,
   task_interplanetary_towing_v1.json,
   task_rigid_spine_integration_v1.json
   Canonical implementation: Psyche Mining Hub V3
   Key mechanics:
   - Precursor delivery → automated hollowing begins
   - Spin adjustment → spine manufactured from asteroid
     material → slag accumulates as tug propellant
   - Cycler arrives with I-beams and construction shuttles
   - Spine assembled → Cycler connects to spine
   - Tug uses slag propellant to push asteroid to position
   - Cycler delivers fit-out units and crew
   - Depot achieves IOC

   **Method 3 — CNT In-Situ Manufacturing**
   Best for: bodies with carbon-rich atmosphere
   (Venus, Mars, Titan)
   Key mechanics:
   - CNT unit fitted to Cycler
   - Skimmer delivers mixed atmospheric gas to Cycler
   - CO2 → CNT components + LOX byproduct
   - Depot shell built first — LOX storage critical
   - Cycler delivers advanced fit-out units
   - Depot achieves IOC — becomes LOX export hub
   Note: Skimmers need imported CH4 for fuel

4. Add craft roles table — HLT, Cycler, Tug, Construction
   shuttle, Custom tanker, Custom skimmer

5. Add AI Manager decision criteria — method selection,
   supply chain decisions, timing decisions

6. Add reference to Psyche V3 as canonical Method 2
   implementation

**Do not duplicate mechanics already in task files.**
Reference them, summarize only.

---

## Task 2 — New File: ASTEROID_CONVERSION_PATTERN.md

**File to create:**
`docs/patterns/deployment/ASTEROID_CONVERSION_PATTERN.md`

**Source files — read before writing:**
- data/json-data/missions/psyche_mining_hub/ (all files)
- data/json-data/missions/tasks_v2/task_body_survey_v1.json
- data/json-data/missions/tasks_v2/task_tug_capture_v1.json
- data/json-data/missions/tasks_v2/task_interplanetary_towing_v1.json
- data/json-data/missions/tasks_v2/task_rigid_spine_integration_v1.json
- docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md

**Content to cover:**

1. Overview — asteroid conversion as station construction method

2. Candidate selection criteria:
   - Size appropriate for intended station
   - Composition — M-type preferred for metallic content
   - Orbital characteristics — can it be moved efficiently
   - Distance from destination — tug transit cost
   - Reference: task_body_survey_v1.json

3. Precursor delivery sequence:
   - HLT or Cycler delivers mining/processing units
   - CAR-300 robots for automated hollowing
   - Power units, comms equipment deployed
   - Automated operations begin — no crew needed yet

4. Hollowing and manufacturing (parallel operations):
   - CAR-300 robots hollow interior
   - Processing units manufacture I-beams and panels
     from asteroid material (denser than regolith-derived)
   - Slag accumulates as tug propellant
   - Spin adjustment to stable orientation

5. Spine assembly:
   - Spine manufactured from asteroid I-beams during
     hollowing phase
   - Spine extends from asteroid as docking interface
   - Spin stabilized before Cycler arrives
   - Cycler arrives with construction shuttles
   - Construction shuttles assemble spine connections
   - Cycler connects to spine — becomes push platform

6. Tug operations:
   - Tug connects to spine
   - Uses accumulated slag as propellant — self-sufficient
   - Pushes asteroid to target orbital position
   - Spine transfers force from tug to asteroid load
   - Same concept as river tug pushing a barge

7. Fit-out sequence:
   - Cycler delivers advanced units and crew
   - Solar panels, computers, life support installed
     (all Earth origin imports)
   - Pressurization via atmosphere concern
   - Depot achieves IOC

8. AI Manager decision criteria:
   - Is suitable asteroid in catalog within range?
   - Is tug available?
   - Can precursor delivery piggyback on existing mission?
   - When does tug need to depart to meet Cycler at destination?

9. Reference: Psyche Mining Hub V3 — canonical implementation
   of this pattern at scale

---

## Task 3 — New File: VENUS_OPERATIONS.md

**File to create:**
`docs/mission_profiles/VENUS_OPERATIONS.md`

**Source files — read before writing:**
- docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md
- data/json-data/missions/tasks/venus_harvester_mission/
- data/json-data/missions/tasks_v2/ (relevant task files)
- docs/patterns/deployment/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md

**Content to cover:**

1. Overview — Venus role in inner system economy

2. Venus as atmospheric resource source:
   - 96.5% CO2 atmosphere — unlimited CNT feedstock
   - SO2 — industrial chemical value
   - Mixed gas cargo — buyer processes on arrival
   - Venus skimmer delivers unprocessed mixed gas
   - Onboard processing only refills own LOX tank

3. Venus skimmer operations:
   - HLT fitted with CO2 separator (early game)
   - Self-generates LOX during Venus operations
   - Needs CH4 from Luna for return fuel
   - Early CH4 source: Earth or Titan import
   - Mid game: Luna Sabatier closes loop
   - Purpose-built skimmers from L1 Shipyard (later)

4. Venus station construction — Method 3 (CNT):
   - CNT unit fitted to Cycler
   - Cycler acts as mobile construction platform
   - Skimmers dock to Cycler — deliver mixed gas
   - CO2 processed → CNT I-beams and panels
   - Massive LOX byproduct — Depot built first
     to store LOX before Shipyard
   - Advanced units imported via Cycler cargo
   - Venus Depot becomes LOX export hub on
     Earth→Mars cycler route

5. Sabatier loop — Venus→Luna connection:
   - Luna H2 (regolith TEU) + Venus CO2 → CH4 + H2O
   - CH4 → refuels Venus skimmers
   - H2O → Luna human consumption (rationed)
   - Loop closes — Luna CH4 self-sufficient
   - Venus CO2 supply drives Luna Sabatier production

6. Venus economic role — mature game:
   - LOX export hub on Earth→Mars cycler route
   - CNT manufacturing for inner system construction
   - Industrial chemical processing (SO2 derivatives)
   - Cycler refueling waypoint

7. AI Manager decision criteria:
   - Is Luna ready to supply CH4 for Venus skimmer?
   - Is Sabatier loop producing enough CH4?
   - Is CNT construction more cost-effective than
     L1 prefab delivery for Venus station?
   - Is Venus Depot LOX export revenue justifying
     operations cost?

8. Note on gravity well:
   - Venus surface gravity 0.904g — skimmers do not land
   - Aerobraking into upper atmosphere — no surface ops
   - Delta-v calculation based on atmospheric skim
     not surface landing
   - Lower effective cost than gravity well suggests

---

## General Instructions for All Tasks

- Read all source files before writing anything
- Do not invent content — only document what exists
  in source files or was explicitly decided in session
- Flag any gaps or conflicts found during research
- Keep each doc focused — do not duplicate content
  already in LUNA_BASE_ESTABLISHMENT.md
- Cross-reference between docs rather than duplicating
- Mark any untested concepts clearly as
  "Design intent — untested"
- Produce each doc as a draft for human review
  before saving to final location
- STOP after producing each draft — wait for approval

---

## Acceptance Criteria
- [ ] NPC_INITIAL_DEPLOYMENT_SEQUENCE.md updated
- [ ] ASTEROID_CONVERSION_PATTERN.md created
- [ ] VENUS_OPERATIONS.md created
- [ ] All docs reference source files correctly
- [ ] No content duplicated across docs
- [ ] Untested concepts clearly flagged
- [ ] Human approved each doc before saving

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing — documentation only
**Related**:
- LUNA_BASE_ESTABLISHMENT.md ✅
- CELESTIAL_BODY_DATA_CONVENTIONS.md ✅
- Task 2 (TaskExecutionEngineV2) — code work
- Task 3 (Luna V2 mission profile) — code work

---

## Completion Report
*Filled in after completion*

**Completed by**:
**Completion date**:

### What was written
### Gaps found
### Follow-up tasks needed