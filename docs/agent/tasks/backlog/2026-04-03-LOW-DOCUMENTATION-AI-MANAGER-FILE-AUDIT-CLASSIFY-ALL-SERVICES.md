# TASK: AI Manager File Audit — Read and Classify All Services
**Status**: BACKLOG
**Priority**: LOW
**Type**: documentation
**Created**: 2026-04-03
**Last Updated**: 2026-04-03

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Read-only audit but requires judgment — classifying CORE/LEGITIMATE/INVENTED/DUPLICATE across ~78 files needs reasoning, not just pattern matching
**Supervision Level**: 🟢 Autonomous OK

---

## Context
The `app/services/ai_manager/` directory contains approximately 83 files.
A grep audit confirmed that only 5 files reference real application services
(`CraftFactoryService`, `LaunchPaymentService`, `MissionTaskRunnerService`,
`UnitLookupService`, `Market::Order`). The remaining ~78 files may contain
real game logic, invented parallel logic, or duplicates of existing services.

**Before any file is deleted or rewritten, every file must be read and
classified.** This task produces that classification. No code changes.
No deletions. Read only.

**The proven working foundation — do not touch these:**
```
task_execution_engine.rb       — proven via rake tasks
state_analyzer.rb              — fixed 2026-04-03
resource_acquisition_service.rb
decision_tree.rb
system_architect.rb
manager.rb
```

**Mandatory reading before starting:**
- `docs/agent/ai_manager/AI_MANAGER_COMMAND.md`
- `docs/agent/ai_manager/AI_MANAGER_ROLE.md`
- `docs/agent/ai_manager/AI_MANAGER_DAMAGE_INVENTORY.md`
- `docs/agent/README.md`

---

## What You Are Looking For

For each file, answer these four questions:

**1. Does it reference real application services?**
```bash
grep -n "CraftFactoryService\|LaunchPaymentService\|MissionTaskRunnerService\|UnitLookupService\|Market::Order\|settlement\.inventory\|settlement\.base_units" \
  app/services/ai_manager/[filename].rb
```

**2. Does it contain hardcoded constants or invented data models?**
```bash
grep -n "ISRU_UNITS\|GAS_COMPOSITION\|resource_profile\|atmosphere_composition\|water_ice\|energy_potential\|PVE_DATA" \
  app/services/ai_manager/[filename].rb
```

**3. Is there a spec file for it?**
```bash
ls spec/services/ai_manager/[filename_without_rb]_spec.rb 2>/dev/null && echo "HAS SPEC" || echo "NO SPEC"
```

**4. Does anything outside ai_manager/ call it?**
```bash
grep -rn "ClassName\|filename" app/ spec/ --include="*.rb" | grep -v "ai_manager/"
```

---

## Files to Audit

Work through these in batches. Do NOT read all 83 at once.

### Batch 1 — Decision Making Layer
```
decision_tree.rb
priority_heuristic.rb
priority_arbitrator.rb
ai_priority_system.rb
strategy_selector.rb
strategic_evaluator.rb
mission_scorer.rb
mission_planner_service.rb
mission_profile_analyzer.rb
```

### Batch 2 — Resource and ISRU Layer
```
isru_evaluator.rb
isru_optimizer.rb
resource_planner.rb
resource_allocator.rb
resource_acquisition_service.rb
resource_flow_simulator.rb
resource_fulfillment_service.rb
resource_positioning_service.rb
bootstrap_resource_allocator.rb
precursor_capability_service.rb
precursor_learning_service.rb
```

### Batch 3 — Construction and Settlement Layer
```
construction.rb
construction_service.rb
builder.rb
colony_manager.rb
ai_colony_manager.rb
settlement_manager.rb
settlement_plan_generator.rb
luna_development_planner.rb
station_construction_strategy.rb
station_cost_benefit_analyzer.rb
station_placement_service.rb
```

### Batch 4 — Logistics and Economics Layer
```
logistics_coordinator.rb
procurement_service.rb
financial_service.rb
economic_forecaster_service.rb
contract_creation_service.rb
market_stabilization_service.rb
transit_fee_service.rb
manifest_parser.rb
depot_adapter.rb
skimmer_cycler_handshake_service.rb
```

### Batch 5 — Wormhole and Expansion Layer
```
wormhole_coordinator.rb
wormhole_manager.rb
wormhole_placement_service.rb
wormhole_scouting_service.rb
expansion_service.rb
expansion_decision_service.rb
expansion_assessment.rb
probe_deployment_service.rb
network_optimizer.rb
system_discovery_service.rb
system_intelligence_service.rb
```

### Batch 6 — Infrastructure and Support Layer
```
shared_context.rb
system_state.rb
system_orchestrator.rb
service_orchestrator.rb
service_coordinator.rb
operational_manager.rb
performance_tracker.rb
pattern_loader.rb
pattern_validator.rb
pattern_validation_service.rb
pattern_target_mapper.rb
```

### Batch 7 — Remaining Files
```
escalation_service.rb
emergency_mission_service.rb
atmospheric_harvester_service.rb
terraforming_manager.rb
corporate_roles.rb
consortium_manager.rb
sim_evaluator.rb
llm_planner_service.rb
world_knowledge_service.rb
test_scenario_extractor.rb
earth_map_generator.rb
planetary_map_generator.rb
super_mars_settlement_service.rb
hammer_protocol.rb
multi_wormhole_event_handler.rb
brown_dwarf_hub_manager.rb
em_harvesting_service.rb
precursor_learning_service.rb
scout_logic.rb
universal_docking_service.rb
```

---

## Output Format

For each file produce exactly this format:

```
FILE: [filename.rb]
CLASS/MODULE: [class name]
SIZE: [approximate lines]
REAL SERVICES CALLED: [list or "none"]
HARDCODED DATA: [list constants/invented hashes or "none"]
EXTERNAL CALLERS: [list or "none found"]
HAS SPEC: [yes / no]
SPEC FILE: [path or "none"]

SUMMARY: [2-3 sentences — what does this file actually do?]
USEFUL LOGIC: [any logic worth preserving before deletion — be specific]
CLASSIFICATION:
  [ ] CORE — connected to real services, do not touch
  [ ] LEGITIMATE — real game intent, needs rewiring not deletion
  [ ] INVENTED — parallel data model, safe to archive
  [ ] DUPLICATE — duplicates an existing service
  [ ] UNKNOWN — needs human review before classification
```

---

## Rules for This Task

- **Read only — no code changes whatsoever**
- **No deletions — not even test files**
- **No rewrites — classification only**
- **If a file has real logic worth keeping, mark LEGITIMATE and describe it**
- **When in doubt, mark UNKNOWN — do not guess**
- **Do not run RSpec — read only**
- **Flag any file that calls `escalation_service` or `EscalationService`**
- **Flag any file that contains Luna, ISRU, TEU, or PVE logic specifically**

---

## Completion Report Format

Produce the full classification table for all files audited, then:

```
SUMMARY COUNTS
CORE:       [N files] — [list names]
LEGITIMATE: [N files] — [list names]
INVENTED:   [N files] — [list names]
DUPLICATE:  [N files] — [list names]
UNKNOWN:    [N files] — [list names]

FILES WITH LUNA/ISRU/TEU/PVE LOGIC:
[list with brief description of what each contains]

FILES WITH ESCALATION SERVICE REFERENCES:
[list or "none"]

RECOMMENDED NEXT ACTIONS:
[brief priority list — what to rewrite first, what to archive]
```

---

## Docker Rules
This task is read-only. All file reads happen on the HOST — no docker exec needed.

```bash
# Read files directly on host
cat galaxy_game/app/services/ai_manager/[filename].rb
head -50 galaxy_game/app/services/ai_manager/[filename].rb
grep -n "[pattern]" galaxy_game/app/services/ai_manager/[filename].rb
```

---

## Dependencies
**Blocked by**: none — read only
**Blocks**: 
- Task 2 update: `2026-04-03-HIGH-BUG-FIX-ISRU-EVALUATOR-DELEGATE-TO-UNITLOOKUPSERVICE.md`
- Task 3 update: `2026-04-03-HIGH-BUG-FIX-DELETE-REWRITE-ISRU-OPTIMIZER.md`
- Bloat deletion task (cannot be written until this audit completes)
- Escalation service task file

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:

### Full Classification Table
[paste here]

### Summary Counts
[paste here]

### Recommended Next Actions
[paste here]
