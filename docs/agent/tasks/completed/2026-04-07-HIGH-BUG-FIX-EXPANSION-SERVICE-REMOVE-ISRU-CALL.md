# TASK: Remove ISRUOptimizer call from AIManager::ExpansionService
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-07
**Last Updated**: 2026-04-07

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single file removal, no inference needed, rule is explicit.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`AIManager::ExpansionService.expand_with_intelligence` is a planning function.
It evaluates whether to expand to a target — no settlement exists at this stage.

`AIManager::ISRUOptimizer` requires a real `Settlement` model with inventory,
surface storage, and material piles. Calling it during planning with a
`settlement_plan` hash causes `TypeError: can't cast Hash`.

The canonical lifecycle is: planning → craft launched → craft lands →
settlement created → ISRU starts. ISRU optimization belongs post-landing,
not inside expansion evaluation.

---

## Problem Statement

**Error**: `TypeError: can't cast Hash` originating from `open_buy_orders`
inside `ISRUOptimizer` when called with a `settlement_plan` hash.

**Current behavior**: `expand_with_intelligence` calls
`isru_optimizer.optimize_isru_priorities(settlement_plan)` during planning.

**Expected behavior**: No ISRU call during planning. ISRU result is removed
from the expansion plan output entirely.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/expansion_service.rb` | Remove ISRU call | `expand_with_intelligence` |
| `spec/services/ai_manager/expansion_service_spec.rb` | Remove ISRU expectations | lines 44, 52, 60, 93, 101, 128, 136, 143 |

### Do Not Touch
| File | Reason |
|---|---|
| `app/services/ai_manager/isru_optimizer.rb` | Not broken — caller is wrong, not this file |
| `app/services/ai_manager/manager_integration_spec.rb` | Separate task |

---

## Implementation Steps

> Follow exactly in order. Do not infer.

### Step 1 — Read the file first
```bash
docker exec -it web bash -c 'cat app/services/ai_manager/expansion_service.rb'
```

Locate every reference to:
- `isru_optimizer`
- `optimize_isru_priorities`
- `isru_optimization`
- Any key in the return hash that contains ISRU data

### Step 2 — Produce Synthesis Report and STOP
SYNTHESIS REPORT
ISRU CALL LOCATION
File: app/services/ai_manager/expansion_service.rb
Line(s): [exact lines]
Code: [exact code block]
RETURN VALUE
Is isru_optimization included in the return hash? [yes/no]
Exact key name if yes: [key]
SPEC EXPECTATIONS
Which of lines 44,52,60,93,101,128,136,143 assert on ISRU data? [list]
PROPOSED REMOVAL
[exact lines to delete]
RISK
Any other callers of isru_optimizer in this file? [yes/no]
READY TO APPLY? — waiting for approval

Do not touch any file until the human approves.

### Step 3 — Apply the removal (after approval only)
- Delete the `isru_optimizer` call and any local variable that holds its result
- Remove the ISRU key from the return hash if present
- Do not add a nil guard, do not add a comment — just remove it cleanly

### Step 4 — Update specs
In `expansion_service_spec.rb`:
- Remove any `expect` assertions on ISRU data from the return value
- Do not delete entire examples — only remove the ISRU-specific assertions
- If an entire example exists solely to test ISRU output, remove the whole example

### Step 5 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/expansion_service_spec.rb'
```
Expected: 0 failures

### Step 6 — Check for regressions
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
```
Expected: no new failures beyond pre-existing baseline

---

## Acceptance Criteria
- [ ] `isru_optimizer` is not called anywhere in `expansion_service.rb`
- [ ] `expansion_service_spec.rb` — 0 failures
- [ ] No new failures in `spec/services/ai_manager/`
- [ ] No nil guards added — clean removal only

---

## Stop Conditions
- ISRU call is inside a shared concern or base class — stop and report
- Removing it causes failures outside `ai_manager/` — stop and report
- More than one ISRU call exists in the file — stop and report, do not guess which to remove

---

## Commit Instructions
```bash
git add app/services/ai_manager/expansion_service.rb spec/services/ai_manager/expansion_service_spec.rb
git commit -m "fix: remove ISRUOptimizer call from ExpansionService — ISRU belongs post-landing not during planning"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: none
**Related tasks**: 2026-04-07-HIGH-REFIT-AI-MANAGER-ISRU-OPTIMIZER-SETTLEMENT-INTERFACE.md (supersedes — that task is now obsolete and should be moved to completed/ or deleted)