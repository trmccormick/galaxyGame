---

# TASK: AI Manager — Strategically Align AI‑Managed Base Builds with SettlementDeploymentService (Design Only)
**Status**: BACKLOG
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-16
**Last Updated**: 2026-04-16

---

## Agent Assignment

**Assigned To**: Claude‑level agent (web or local)
**Why This Agent**: Requires architectural reasoning and design, not implementation
**Supervision Level**: 🟡 Standard

---

## Context

`SettlementDeploymentService.establish_from_craft` is now the shared, canonical settlement‑deployment primitive used by `BaseSettlement` and player‑driven deployments. It encapsulates manifest‑driven cargo verification, settlement creation, unit deployment, and cargo transfer.

The AI‑managed generic base‑build pipeline (via `AutonomousConstructionManager` and `lib/tasks/generic_base_build.rake`) currently creates settlements via `BaseSettlement.create!` and helpers like `create_generic_settlement`, duplicating settlement‑creation logic in a way that is not aligned with the new service.

This task is not to implement any change. It is to:
- Investigate the current AI‑manager codebase
- Design how the AI‑manager should integrate with `SettlementDeploymentService`
- Produce a concrete, scoping‑level recommendation that can later be turned into implementation tasks (possibly for GPT‑4.1 or another agent)

**Architectural Rationale:**
Moving initial settlement precursor missions to use `SettlementDeploymentService.establish_from_craft` enables shared resource pools and consistent deployment logic for both future players and the AI Manager. This aligns with the canonical intent and forbidden patterns described in `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` (see: "forbidden patterns" section), which prohibit direct model manipulation and require use of shared services for all deployment and resource management.

**Modular Task Library (tasks_v2):**
The `data/json-data/missions/tasks_v2/` directory provides a library of parameter-driven, reusable service tasks for missions. All logic is location-agnostic and free of hardcoded mission data. Both mission profiles and the AI Manager should reference these tasks and supply environment-specific parameters, enabling consistent, DRY logic for both player and AI-driven operations.

**Recommendation:**
The AI Manager’s integration plan should leverage `tasks_v2` for composing and executing settlement precursor and operational tasks. This ensures:
- Maximum code and logic reuse between player and AI missions
- Consistent resource and deployment logic
- Future extensibility as new tasks are added
Explicitly reference `tasks_v2` as the preferred source for repeatable mission/settlement logic in both training and execution.

**Related Documentation:**
- `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` — Canonical intent, forbidden patterns, and service usage mandates
- `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` — High-level orchestration and modularity
- `docs/architecture/ai_manager/AI_MANAGER_MASTER_PLAN.md` — Strategic architecture and mission profile integration
- Backlog tasks: `2026-04-07-HIGH-DATA-AI-MANAGER-MISSION-PROFILE-TRAINING-REFRESH.md`, `refine_mission_ai_manager_alignment.md` — Mission profile training, bootstrap/operational phase logic, and escalation gaps

**Output Location:**
Place the design/recommendation note in `docs/architecture/ai_manager/SETTLEMENT_DEPLOYMENT_INTEGRATION_DESIGN.md` (or append to this task file if preferred).

**Relevant Architecture Docs** — read before starting:
- `docs/agent/README.md`
- Any existing `docs/architecture/ai_manager/...` describing the AI‑manager and generic‑base‑build intent

---

## Problem Statement

**Current behavior**:
- AI‑managed generic base builds create settlements directly via `BaseSettlement.create!` and `create_generic_settlement` in `AutonomousConstructionManager` and `generic_base_build.rake`.
- The AI‑manager is being trained on JSON mission patterns (e.g., `planetary_precursor_initial_setup_v1.json`), but this pattern‑driven intent is not yet reflected in the Ruby‑layer deployment code.
- The newly extracted `SettlementDeploymentService.establish_from_craft` is not yet used by the AI‑manager, even though it encapsulates the same deployment logic in a shared way.

**Expected behavior**:
- After this design task, there should be a clear, documented path for how the AI‑manager will integrate with `SettlementDeploymentService`:
  - Which settlement‑creation sites should move to the service
  - Which can stay as‑is
  - How mission‑profile JSON patterns should drive `manifest_name` and `craft`‑related choices
  - Where AI‑manager‑specific behavior stays vs is shared
- The output should not be a PR or code change, but a concrete design plan that can be approved before any implementation is scheduled.

**No error output**; this is a design / scoping task, not a bug fix.

---

## Files Involved

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| app/services/ai_manager/autonomous_construction_manager.rb | To see the current AI‑managed base‑build logic and where settlements are created. |
| lib/tasks/generic_base_build.rake | To understand the generic‑base‑build pipeline and `create_generic_settlement`‑style helpers. |
| app/models/settlement/base_settlement.rb | To confirm `BaseSettlement#establish_from_craft` delegates to `SettlementDeploymentService`. |
| app/services/settlement_deployment_service.rb | To see the `manifest_name` default, expected behavior, and helper methods. |
| app/data/json-data/missions/*/planetary_precursor_initial_setup_v1.json | To see the AI‑manager pattern‑training context and mission‑profile structure. |

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| docs/architecture/ai_manager/SETTLEMENT_DEPLOYMENT_INTEGRATION_DESIGN.md | Design output | N/A |

### Migration (if needed)
- [x] No migration needed

---

## Implementation Steps

### Step 1 — Review AI‑manager code and current deployment sites
- Run:
  ```bash
  grep -n "create!.*BaseSettlement" app/services/ai_manager/
  grep -n "create_generic_settlement" lib/tasks/generic_base_build.rake
  ```
- List all settlement‑creation sites involved in the AI‑manager pipeline.

### Step 2 — Review the shared service and its contract
- Study:
  - app/services/settlement_deployment_service.rb
  - app/models/settlement/base_settlement.rb (to see the delegating `establish_from_craft`).
- Take note of:
  - Expected `craft` and `location` shapes
  - Default `manifest_name`
  - Any helper methods (`verify_deployment_craft`, etc.)

### Step 3 — Align with AI‑manager pattern‑training intent
- Review at least:
  - app/data/json-data/missions/*/planetary_precursor_initial_setup_v1.json
  - Any other relevant mission‑profile patterns used by the AI‑manager
- Determine how these patterns should influence:
  - The `manifest_name` chosen
  - The `craft` used (e.g., AI‑mission‑specific vs generic)
  - Any equipment‑level recommendations the AI‑manager can make without changing the deployment service

### Step 4 — Write the design / recommendation note
Produce a note that includes:
1. **Current state**: Short enumeration of all AI‑managed settlement‑creation sites and how they currently work.
2. **Proposed integration**: Which sites should move to `SettlementDeploymentService.establish_from_craft` and which can stay as‑is. A concrete example call pattern per site (what `craft`, `location`, and `manifest_name` should be in the AI‑manager context). Any minimal adjustments proposed to the service interface (e.g., new optional parameter, no structural changes).
3. **Pattern‑driven behavior**: How mission‑profile JSON patterns should drive choices (e.g., `manifest_name` or `craft` type), while keeping the service generic.
4. **Follow‑up implementation outline**: Short list of what a subsequent implementation task would need to do (file list, step‑by‑step), but without writing the implementation here.

*Do not generate any code changes or PR‑ready commits. This is a design and scoping output only.*

---

## Acceptance Criteria
- [ ] The AI‑manager’s relationship with `SettlementDeploymentService` is clearly documented: where integration happens, and where AI‑manager logic stays separate.
- [ ] The recommendation includes at least one concrete, implementable call pattern example (e.g., how `AutonomousConstructionManager` would call `SettlementDeploymentService.establish_from_craft`).
- [ ] The design respects the current AI‑manager training and JSON pattern architecture, and explicitly calls out when any breaking changes or new assumptions would be required.
- [ ] The output is a design / recommendation note, not code or a PR, and can be reviewed and approved by the human before scheduling any implementation tasks.

---

## Documentation
- [ ] Update `docs/architecture/ai_manager/autonomous_construction_manager.md` (or create it) with the new integration design summary.
- [ ] Flag any other doc gaps, but do not create multiple new architecture docs in this task.

---

## Dependencies
**Blocks**: a future implementation‑level task to reroute AI‑managed base‑builds through `SettlementDeploymentService`.
**Related tasks**:
- 2026-04-12-HIGH-BUG-FIX-BASE-SETTLEMENT-ESTABLISH-FROM-STARSHIP-BACKLOG.md — established `SettlementDeploymentService` and the player‑side deployment path