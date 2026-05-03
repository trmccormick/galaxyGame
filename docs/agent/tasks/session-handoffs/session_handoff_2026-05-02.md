# Session Handoff — 2026-05-02
Written by: Claude (Session Strategist)
Branch: regional-view-phase2

## Session Metrics
Start: 91 failures (stale pre-Task-1 log) → 64 (morning baseline)
End: ~54 failures (estimated, overnight run will confirm)
Commits this session: 4
Time: ~10 hours across two days

## Current Baseline
Estimated ~54 failures (64 - 10 fixed this session)
Overnight run will confirm exact number.
Previous baseline: 68 (end of 2026-05-01 session)

## Branch
regional-view-phase2

## Commits This Session
6d8efd1a — refactor: PrecursorCapabilityService — chemical formula
           consistency, exact matching, early ISRU filter,
           data-driven metals; satellite — move SolidBodyConcern
           to base Satellite class
05c668fc — docs: add CELESTIAL_BODY_DATA_CONVENTIONS.md
7e78a3c7 — fix: job factory — rename specifications to
           operational_data; worker — remove ConstructionJob
           processing; worker spec — fix update! stub scope
697084c2 — fix: use volatile_amount helper for nested hash safety
           in surface_resources and regolith_composition

---

## What Was Accomplished

### Data Integrity — sol.json and sol-complete.json
- Established `psr_deposits` as standard key for PSR ice on
  airless bodies (replaces polar_craters, ice_caps)
- Removed Luna cross-sphere contamination:
  H2O.oceans (physically impossible)
  H2O.groundwater (unconfirmed, wrong term)
  N2.atmosphere (wrong sphere)
- Renamed H2O.ice_caps → H2O.psr_deposits on Luna
- Renamed H2O.polar_craters → H2O.psr_deposits on Mercury
- Removed inline lava tube data from both files
  (already exists in separate geological features files)
- Both files validated clean

### Documentation
- Created /docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md
  Full sphere separation rules, psr_deposits standard,
  volatile conventions, TerraSim integration notes,
  generated world conventions, agent rules

### Job System Fixes
- Job factory: renamed specifications → operational_data
  (specifications column never existed on Job model)
- JobProcessorWorker: removed ConstructionJob processing
  (ConstructionJob uses completion_percentage not completes_at)
- Worker spec: fixed update! stub scope using
  and_wrap_original pattern

### PrecursorCapabilityService Refactor
- Full chemical formula consistency throughout service
- Exact matching only in can_produce_locally? (no substring)
- EARLY_ISRU_STORAGE_MECHANISMS = %w[regolith].freeze
  (psr_deposits excluded — PSR mining is mid-tier, not early ISRU)
- METAL_OXIDE_FORMULAS constant — data-driven metal detection
- surface_resources filters stored_volatiles by ISRU accessibility
- extract_local_resources adds O2 and H2 for solid bodies with
  crust composition (PVE and TEU bakeout pathways)
- can_extract_fuel? — H2 from regolith TEU is primary Luna
  fuel pathway (LH2/LOX), not water electrolysis
- Spec updated: Titan uses seeded world constant TITAN-01
  not factory-created stub

### SolidBodyConcern Architecture Fix
- Moved SolidBodyConcern from large_moon.rb to satellite.rb
- All satellite subtypes (moon, ice_moon, small_moon,
  large_moon) now correctly return has_solid_surface? = true
- This was root cause of Luna and Titan regolith/O2 failures

---

## Architecture Decisions Made This Session

### Early ISRU Definition (Luna MVP)
Early ISRU accesses regolith only:
- O2 — PVE breaks metal oxides (FeO, Al2O3 etc.)
- H2 — TEU bakeout releases solar-wind implanted hydrogen
- He3 — TEU bakeout releases from regolith
- Metals — PVE byproduct
PSR ice mining is MID-TIER — requires dedicated power
infrastructure and equipment to operate in permanently
shadowed regions. Research confirms this (LCROSS, Artemis).

### H2O Priority on Luna
H2O from PSR mining is rationed for human consumption.
Fuel strategy is LH2/LOX from regolith — NOT water electrolysis.
CH4/LOX is a Mars strategy (CO2 atmosphere → Sabatier).
Luna has no carbon source for CH4 early game.

### Chemical Formulas in Backend
All backend service code uses chemical formulas exclusively.
Common names (oxygen, methane, nitrogen) reserved for UI only.
Non-chemical storage mechanism keys (regolith, psr_deposits,
clathrates) are acceptable as location descriptors.

### stored_volatiles as Scientific Reference Layer
Field records what exists and estimated amounts based on
confirmed science. Does not define deposit locations.
Physical state determined at runtime from world conditions.
AI Manager spawns deposit locations procedurally on survey.

---

## Luna/L1 Supply Chain Architecture (documented for Task 3)

### Resource Priority Hierarchy
1. O2 — regolith PVE (early ISRU)
2. H2 — regolith TEU bakeout (early ISRU)
3. He3 — regolith TEU bakeout (early ISRU, high value export)
4. Metals — regolith PVE byproduct
5. H2O — PSR mining (mid-tier, rationed for humans)
6. CH4 — imported via HLT skimmer (Titan) or Earth tanker
7. N2 — imported via HLT skimmer (Titan) or Earth tanker
8. CO2 — imported via HLT skimmer (Venus)

### Skimmer Craft Fuel Profiles
Venus Skimmer (HLT fitted):
- Onboard CO2 separator → CO + O2 (self-generates LOX)
- Arrives at Luna needing: CH4 only
- Delivers: CO2, CO, Venus atmosphere gases
- Key value: CO2 enables Sabatier → Luna CH4 self-sufficiency

Titan Skimmer (HLT fitted):
- Onboard CH4 separator → fills own tank at Titan
- Arrives at Luna needing: LOX only (available from regolith day 1)
- Delivers: CH4, N2 in bulk
- Key value: N2 for habitat atmosphere mix, CH4 for fuel

Earth Skimmer (optional, AI Manager decision):
- Onboard O2 separator → self-generates LOX
- Arrives at Luna needing: CH4 only
- Delivers: N2, O2, Ar, other Earth atmosphere gases
- AI Manager calculates if cost justified vs direct Earth imports

### Craft Taxonomy by Role
| Craft | Route | Role |
|---|---|---|
| HLT | Earth → LEO | Heavy lift, high gravity workhorse |
| Cycler | LEO Depot → L1 Depot | Bulk transit, people/cargo |
| Tanker (custom) | Luna → L1 | Material runs, L1 Shipyard built |
| Skimmer (custom) | L1 → Venus/Titan → L1 | Atmospheric harvesting |
| Construction shuttle | Depot ↔ Shipyard | Local assembly/maintenance |
| Mass launcher payload | Luna → L1 position | Components only |

HLT is not retired — stays on Earth→LEO role permanently.
Specialized craft replace HLT on all other routes as L1
Shipyard comes online.

### Luna→L1 Build Sequence (prerequisites)
Luna must have before L1 can be built:
- Regolith ISRU operational
- 3D printer operational (mk1 I-beams and panels)
- Mass launcher operational (throws components to L1 position)
- HLT available (moves components into final position)

L1 Phase 1 — Depot:
- Shell from Luna components, HLT assembly
- Pressurized via atmosphere concern (same as lava tube)
- Refueling established
- HLT skimmers dock here, no longer land on Luna

L1 Phase 2 — Shipyard (after Depot operational):
- Purpose-built skimmers constructed (Luna materials + Earth fittings)
- Purpose-built tankers replace HLT on Luna→L1 route
- Construction shuttles built here for local L1 operations

### AI Manager Decision Framework
Mission profiles encode OPTIONS not fixed sequences.
AI Manager reads live game state and selects path:
- What's locally available (PrecursorCapabilityService)
- What's needed (mission profile requirements)
- Gap = import requirement
- Cost-benefit per supply route (delta-v, gravity well,
  cargo value, craft availability)
- Luna is training ground — learned patterns apply to Mars+
  but with different body properties and longer supply lines

---

## Backlog Tasks Created This Session
- docs/agent/tasks/on-hold/2026-05-01-MEDIUM-ARCHITECTURE-
  AI-MANAGER-RESOURCE-SPAWNING-SYSTEM.md

---

## Next Session Priorities

### Task 2 — READY TO HAND OFF (GPT-4.1, Sunday 8pm reset)
File: docs/agent/tasks/active/2026-05-02-HIGH-REFACTOR-
      TASK-EXECUTION-ENGINE-V2-WORLD-DRIVEN.md
Handoff command: prepared and ready to paste
Depends on: Task 1 ✅ PrecursorCapabilityService now clean

### Task 3 — READY TO HAND OFF (parallel with Task 2)
File: docs/agent/tasks/backlog/2026-05-01-HIGH-DATA-LUNA-
      SETTLEMENT-MISSION-PROFILE-JSON.md
Scope expanded: V2 mission profile must encode options not
fixed sequence. Review existing V1 manifests in
data/json-data/missions/ and venus_harvester_mission/
titan_harvester_mission profiles before writing V2.
Reference NPC_INITIAL_DEPLOYMENT_SEQUENCE.md in
docs/patterns/deployment/ for precedence gate pattern.

### Documentation Updates Needed (Claude appropriate)
NPC_INITIAL_DEPLOYMENT_SEQUENCE.md needs updating:
- L1 = two stations (Depot first, Shipyard second)
- Luna infrastructure prerequisites before L1 build
- HLT role clarification (not retired, stays Earth→LEO)
- Construction shuttle role at L1

### Known Pre-existing Failures (do not touch)
- Integration specs (escalation, covering, shell_printing,
  terraforming) — 10 failures, pre-existing
- mission_planner_service_spec — Phase 3
- system_discovery_service_spec — Phase 3
- item_spec:296 — pre-existing

## Agent Notes
- GPT-4.1 cannot safely edit large JSON files directly —
  manual VSCode edits only for JSON data files
- GPT-4.1 consistently appends instead of replaces when
  patching spec files — verify example count after any
  spec edit (grep -c "it '" specfile)
- SolidBodyConcern was missing from Moon/IceMoon/SmallMoon —
  now fixed at Satellite base class level
- EARLY_ISRU_STORAGE_MECHANISMS = %w[regolith].freeze —
  psr_deposits is mid-tier, confirmed by NASA research
- Chemical formulas required in all backend code —
  see CELESTIAL_BODY_DATA_CONVENTIONS.md

## Notes for Next Session
Start with overnight RSpec run to confirm ~54 failure baseline.
GPT-4.1 resets Sunday May 3 at 8pm — Task 2 handoff ready.
Task 3 scope review needed before handoff — V2 format
requires understanding existing V1 manifests first.
NPC_INITIAL_DEPLOYMENT_SEQUENCE.md update is Claude work —
can be done before GPT-4.1 is available.