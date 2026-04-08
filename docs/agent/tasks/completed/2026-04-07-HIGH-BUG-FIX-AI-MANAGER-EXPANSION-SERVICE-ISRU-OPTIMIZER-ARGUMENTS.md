# TASK: Fix AIManager::ExpansionService.expand_with_intelligence — wrong number of arguments to ISRUOptimizer.optimize_isru_priorities
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-07
**Last Updated**: 2026-04-07


---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Simple args‑mismatch in service call; no JSON or schema changes, no shared‑core concerns.
**Supervision Level**: 🔴 Watched carefully


---

## Context

`AIManager::ExpansionService.expand_with_intelligence` calls `AIManager::ISRUOptimizer.optimize_isru_priorities(settlement, ...)` with **two arguments**, but the method now expects **one argument**.

This causes **8 failures** in `expansion_service_spec.rb`:

- `spec/services/ai_manager/expansion_service_spec.rb:44`
- `52`, `60`, `93`, `101`, `128`, `136`, `143`

They all **fail with the same error**:

```ruby
ArgumentError: wrong number of arguments (given 2, expected 1)
```


---

## Problem Statement

**Current behavior**:
- `ExpansionService.expand_with_intelligence` calls `optimize_isru_priorities(...)` with 2 arguments.
- `ISRUOptimizer.optimize_isru_priorities` expects 1 argument.
- Result: **ArgumentError** in all 8 specs.

**Expected behavior**:
- Both callers and callee match: either **2 args** or **1 arg**.
- No **ArgumentError**; specs pass with 0 failures.

**Error output** (example):
```ruby
ArgumentError: wrong number of arguments (given 2, expected 1)
from ./app/services/ai_manager/isru_optimizer.rb:70:in 'optimize_isru_priorities'
from ./app/services/ai_manager/expansion_service.rb:31:in 'AIManager::ExpansionService.expand_with_intelligence'
from ./spec/services/ai_manager/expansion_service_spec.rb:45:in 'block (3 levels) in <main>'
```


---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/expansion_service.rb` | Fix `expand_with_intelligence` call to `optimize_isru_priorities` | `AIManager::ExpansionService.expand_with_intelligence` near line 31 |
| `app/services/ai_manager/isru_optimizer.rb` | Confirm `optimize_isru_priorities` signature | `AIManager::ISRUOptimizer.optimize_isru_priorities` near line 70 |


### Reference Files — read but not edit
| File | Why You Need It |
|---|---|
| `spec/services/ai_manager/expansion_service_spec.rb` | current calls to `expand_with_intelligence` and `optimize_isru_priorities` |


---

## Implementation Steps

> 0x agent: follow these steps exactly in order.

### Step 1 — read both methods

Run:
```bash
docker exec -it web bash -c 'grep -n "def optimize_isru_priorities" app/services/ai_manager/isru_optimizer.rb'
docker exec -it web bash -c 'grep -n "def expand_with_intelligence" app/services/ai_manager/expansion_service.rb'
```

Record the current signatures.

### Step 2 — decide which is correct

- If `isru_optimizer.rb` defines:
  ```ruby
  def optimize_isru_priorities(settlement, options = {})
  ```
  then **caller** must pass 2 args.

- If it defines:
  ```ruby
  def optimize_isru_priorities(settlement)
  ```
  then **caller** must pass 1 arg.

**Do not change the method signature** unless you’re sure; only **align the caller**.

### Step 3 — fix the caller

In `app/services/ai_manager/expansion_service.rb`:

```ruby
# BEFORE — wrong number of args
result = AIManager::ISRUOptimizer.optimize_isru_priorities(settlement, some_options)

# AFTER — match signature
result = AIManager::ISRUOptimizer.optimize_isru_priorities(settlement)
```

Or vice versa, if the callee expects 2 args.

### Step 4 — run the 8 failing specs in isolation

Run:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/expansion_service_spec.rb:44 --failure-examples'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/expansion_service_spec.rb:52 --failure-examples'
# ... repeat for 60, 93, 101, 128, 136, 143
```

They should all pass.

### Step 5 — run full `expansion_service` spec

Run:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/expansion_service_spec.rb'
```

Expected: 0 failures.

### Step 6 — run related AI Manager specs

Run:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/manager_integration_spec.rb'
```


---

## Synthesis Report Format

Produce this before applying any fix and **STOP**:
CURRENT SIGNATURE
app/services/ai_manager/isru_optimizer.rb:70
def optimize_isru_priorities(settlement, options = {})

CALLER SIGNATURE
app/services/ai_manager/expansion_service.rb:31
AIManager::ISRUOptimizer.optimize_isru_priorities(settlement, some_options)

PROPOSED CHANGE
Change caller to:
AIManager::ISRUOptimizer.optimize_isru_priorities(settlement)

RISK
No new JSON, no schema changes, no shared base class.

READY TO APPLY? — waiting for approval

text


---

## Testing Sequence

1. Isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/expansion_service_spec.rb:44'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/expansion_service_spec.rb:52'
# ... etc.
```

2. Full expansion spec:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/expansion_service_spec.rb'
```

3. Related AI Manager specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/manager_integration_spec.rb'
```


---

## Acceptance Criteria
- [ ] All 8 failing specs in `expansion_service_spec.rb` pass.
- [ ] No regressions in `expansion_service_spec.rb`.
- [ ] No regressions in `manager_integration_spec.rb`.
- [ ] No new failures in AI Manager suite.


---

## Stop Conditions — escalate to user immediately if:
- Same error persists after two attempts.
- Root cause is in shared base class or concern.
- Method signature is different from what you expect.
- Any new failures appear in unrelated specs.


---

## Commit Instructions

Run on host:
```bash
git add app/services/ai_manager/expansion_service.rb app/services/ai_manager/isru_optimizer.rb
git commit -m "fix: AIManager::ExpansionService.expand_with_intelligence — wrong number of arguments to ISRUOptimizer.optimize_isru_priorities"
git push
```


---

## Documentation

- [ ] No doc changes needed.
- [ ] Flag doc gap:
  - `AIManager::ISRUOptimizer` signature should be documented in `docs/ai_manager/`.


---

## Dependencies

**Blocked by**: none  
**Blocks**: `AIManager::ExpansionService` correctness  
**Related tasks**: `AIManager::ManagerIntegrationSpec` (uses `ExpansionService`)


---

## Completion Report

*Filled in by agent after completion*
Completed by: GitHub Copilot
Completion date: 2026-04-07
Final test result: All 8 previously failing specs in expansion_service_spec.rb now pass; no regressions in related specs

What was changed
- app/services/ai_manager/expansion_service.rb — Updated the call to optimize_isru_priorities to match the method signature (now passes only one argument).
- app/services/ai_manager/isru_optimizer.rb — Confirmed method signature expects one argument; no changes needed.

Issues discovered
- No unexpected issues; the fix was mechanical and resolved the argument mismatch cleanly.

Follow-up tasks needed
- Document the ISRUOptimizer method signature in docs/ai_manager/ for clarity.

Lessons learned
- Keeping service call signatures aligned is critical for test stability.
- Mechanical bugfixes like this are low-risk when the test suite is comprehensive.

