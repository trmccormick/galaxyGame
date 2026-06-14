# TASK: Refresh AI Manager Mission Profile Training Data
**Status**: BACKLOG
**Priority**: HIGH
**Type**: data
**Created**: 2026-04-07
**Last Updated**: 2026-04-07

---

## Agent Assignment

**Assigned To**: Claude Sonnet (web free)
**Why This Agent**: Requires reasoning about NPC behavioral correctness,
not just running a script. Must evaluate what changed in mission profiles
since January and whether the AI Manager is learning the right patterns.
**Supervision Level**: 🟡 Standard

---

## Context

The AI Manager learns expansion behavior from mission profile JSON files
via `AIManager::MissionProfileAnalyzer`. The last training run was
2026-01-19 and produced 5 failed patterns out of 10. Since January the
following have changed materially:

- ISRU interface and lifecycle (planning vs post-landing boundary)
- Manufacturing service BOM refactor (NpcPriceCalculator, dynamic pricing)
- Lunar precursor mission profile refinements
- Venus patterns (CNT elevators, forge operations — added late January)

The NPC is currently making expansion decisions based on three-month-old
training data that predates these architectural changes.

---

## Problem Statement

**Current state**: `training_results.json` dated 2026-01-19, 5/10 patterns
failed validation, recent architecture changes not reflected in training data.

**Expected state**: All mission profiles pass validation against current
architecture. AI Manager trained on patterns that reflect current ISRU
lifecycle, BOM structure, and economic model.

---

## Files Involved

### Primary Files
| File | Purpose |
|---|---|
| `app/services/ai_manager/mission_profile_analyzer.rb` | Training engine |
| `app/data/json-data/missions/` | Mission profile JSON files (source of truth) |
| `app/data/ai_manager/training_results.json` | Output — will be regenerated |
| `app/data/ai_manager/enhanced_training_report.json` | Output — will be regenerated |

### Reference Files
| File | Why You Need It |
|---|---|
| `docs/ai_manager/` | Current AI Manager architecture |
| `docs/architecture/precursor_mission_bootstrap_architecture.md` | Precursor mission canonical flow |
| `docs/architecture/life_support_waste_recycling_architecture.md` | ISRU and life support intent |

---

## Implementation Steps

> Claude — apply judgment. This is analysis before execution.

### Step 1 — Audit what changed since January
Compare current mission profile JSON files against the January training
report. Identify which patterns failed and why. Cross-reference against
architecture changes made since 2026-01-19.

### Step 2 — Validate MissionProfileAnalyzer is current
Read `mission_profile_analyzer.rb`. Confirm it reflects current interfaces:
- Does it understand the current BOM structure?
- Does it correctly handle ISRU as post-landing only?
- Does it use NpcPriceCalculator for cost estimation?

Flag any mismatches before running training.

### Step 3 — Fix any analyzer mismatches
If the analyzer itself is stale, fix it before retraining. Do not retrain
against a stale analyzer — garbage in, garbage out.

### Step 4 — Re-run training
```bash
docker exec -it web bash -c 'rails runner scripts/ai_manager_training_integration_test.rb'
```
Expected: 10/10 patterns pass validation.

### Step 5 — Review output
Read the new `training_results.json`. Confirm:
- All 10 patterns trained
- 0 failed patterns
- Recent updates reflect current architecture

### Step 6 — Document behavioral changes
In the session handoff, note what changed between January and now in terms
of NPC expansion behavior. What will the AI Manager do differently with
current training vs January training?

---

## Acceptance Criteria
- [ ] All 10 mission patterns pass validation (0 failed)
- [ ] `training_results.json` dated 2026-04-07 or later
- [ ] Analyzer correctly reflects current ISRU lifecycle
- [ ] Analyzer correctly reflects current BOM/NpcPriceCalculator structure
- [ ] Behavioral change summary documented in session handoff

---

## Stop Conditions
- More than 3 patterns require JSON changes to pass — escalate to human,
  may indicate deeper architecture drift
- `MissionProfileAnalyzer` requires significant refactoring — create
  separate task, do not combine with training refresh
- Any mission profile JSON requires changes that conflict with
  architectural constraints in README.md — stop and escalate

---

## Commit Instructions
```bash
git add app/data/ai_manager/training_results.json
git add app/data/ai_manager/enhanced_training_report.json
git commit -m "data: refresh AI Manager mission profile training — updated to current ISRU and BOM architecture"
git push
```

---

## Dependencies
**Blocked by**: ISRU removal from ExpansionService (2026-04-07-HIGH-BUG-FIX-EXPANSION-SERVICE-REMOVE-ISRU-CALL.md) — train after interfaces are clean
**Blocks**: AI Manager behavioral correctness at runtime
**Related tasks**: 2026-04-07-HIGH-REFIT-AI-MANAGER-ISRU-OPTIMIZER-SETTLEMENT-INTERFACE.md (obsolete — superseded by ISRU removal task)

---

## Completion Report
*Filled in by agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed

### Patterns that required fixes

### Behavioral changes vs January training

### Follow-up tasks needed