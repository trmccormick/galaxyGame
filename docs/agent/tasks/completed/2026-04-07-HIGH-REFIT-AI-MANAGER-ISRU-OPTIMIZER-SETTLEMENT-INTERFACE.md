# TASK: Refit AIManager::ISRUOptimizer to accept both Settlement models and plan Hashes
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-04-07
**Last Updated**: 2026-04-07


---

## Agent Assignment

**Assigned To**: Claude Sonnet (web free)
**Why This Agent**: Touches AI‑manager architecture, ISRU‑optimizer interface, and future‑settlement design. Requires reasoning.
**Supervision Level**: 🟡 Standard


---

## Context

`AIManager::ISRUOptimizer.optimize_isru_priorities(settlement)` currently expects a **real `Settlement` model**, but `AIManager::ExpansionService.expand_with_intelligence` wants to pass a **`settlement_plan` `Hash`** representing a future settlement.

This mismatch is causing **TypeError: can't cast Hash** in tests.

The goal is to:

- Refactor `ISRUOptimizer` so it can work with **both**:
  - `Settlement` models  
  - `FutureSettlement`‑style hashes  
- Keep the **interface** clean and model‑like.

---

## Problem Statement

**Current behavior**:
- `AIManager::ExpansionService.expand_with_intelligence` passes a `settlement_plan` hash to `optimize_isru_priorities(settlement_plan)`.
- `open_buy_orders(settlement_plan)` fails with `TypeError: can't cast Hash`.

**Expected behavior**:
- `ISRUOptimizer` should **accept either** a `Settlement` model **or** a `Settlement`‑like hash/POCO.
- The **same logic** (`open_buy_orders`, `assess_capabilities`, etc.) should run correctly on both.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/isru_optimizer.rb` | Refactor `optimize_isru_priorities` to accept Settlement‑like objects | `optimize_isru_priorities` |
| `app/services/ai_manager/expansion_service.rb` | Adjust call to `optimize_isru_priorities` | `expand_with_intelligence` |
| `spec/services/ai_manager/expansion_service_spec.rb` | Update expectations for `settlement_plan` handling | lines 44, 52, 60, 93, 101, 128, 136, 143 |


### Reference Files — read but not edit
| File | Why You Need It |
|---|---|
| `docs/ai_manager/` (architecture) | current AI‑manager design and expectations |
| `spec/services/ai_manager/manager_integration_spec.rb` | integration‑style tests that use `ExpansionService` |


---

## Implementation Steps

> Claude Sonnet — apply judgment.

### Step 1 — define Settlement‑like interface

- Decide on a **clean interface** for `Settlement`‑like objects:
  - `#id`
  - `#inventory`
  - `#open_buy_orders`
  - `#celestial_body`
- Either:
  - Make a `FutureSettlement` PORO that responds to these methods.  
  - Or modify `isru_optimizer` to duck‑type.

### Step 2 — refactor `optimize_isru_priorities`

In `isru_optimizer.rb`:

- Update `optimize_isru_priorities` to accept **either**:
  - A `Settlement` model **or** a `Settlement`‑like object.  
- Ensure `open_buy_orders(settlement)` works correctly on both.

### Step 3 — update `expand_with_intelligence`

In `expansion_service.rb`:

- If `settlement` is present, use:
  ```ruby
  isru_optimization = isru_optimizer.optimize_isru_priorities(settlement)
  ```
- If `settlement_plan` is present and `settlement` is nil, use:
  ```ruby
  isru_optimization = isru_optimizer.optimize_isru_priorities(settlement_plan)
  ```

### Step 4 — update specs

In `expansion_service_spec.rb`:

- Ensure tests that pass `settlement_plan` still pass.  
- Ensure tests that pass real `settlement` still pass.

### Step 5 — run full suite

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec'
```

---

## Synthesis Report Format

```text
CURRENT INTERFACE
Describe current settlement interface (id, inventory, open_buy_orders, etc.)

PROPOSED INTERFACE
How will ISRUOptimizer accept both Settlement models and hashes?

PLAN FOR EXPANSION_SERVICE
How will expand_with_intelligence decide which to pass?

FILES TO EDIT
[List all files]

RISK
[Any shared code that might be affected]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Run `expansion_service_spec.rb`.
2. Run `manager_integration_spec.rb`.
3. Run full suite.

---

## Acceptance Criteria
- [ ] `expansion_service_spec.rb` — 0 failures.
- [ ] `manager_integration_spec.rb` — 0 failures.
- [ ] No regressions in AI Manager suite.
- [ ] `ISRUOptimizer` works with both `Settlement` models and `settlement_plan` hashes.

---

## Stop Conditions
- If the refactor is larger than expected, stop and report.
- If new failures appear in unrelated specs, stop and report.

---

## Commit Instructions

```bash
git add app/services/ai_manager/isru_optimizer.rb app/services/ai_manager/expansion_service.rb spec/services/ai_manager/expansion_service_spec.rb
git commit -m "refactor: AIManager::ISRUOptimizer to accept both Settlement models and plan hashes"
git push
```

---

## Documentation

- [ ] Update `docs/ai_manager/` to document the new `Settlement`‑like interface.

---

## Dependencies

**Blocked by**: none  
**Blocks**: AI Manager expansion correctness  
**Related tasks**: AI Manager ISRU‑evaluation overhaul

---

## Completion Report

*Filled in by agent after completion*
Completed by: GitHub Copilot
Completion date: 2026-04-07
Final test result: All relevant specs green; 0 failures in expansion_service_spec.rb and manager_integration_spec.rb

What was changed
- app/services/ai_manager/isru_optimizer.rb — Refactored to accept both Settlement models and settlement_plan hashes, using duck-typing for required interface methods.
- app/services/ai_manager/expansion_service.rb — Updated to pass either a Settlement or settlement_plan hash to ISRUOptimizer as appropriate.
- spec/services/ai_manager/expansion_service_spec.rb — Updated/verified tests to ensure both input types are handled and all pass.

Issues discovered
- None outside the expected interface mismatch; no new regressions or unrelated failures.

Follow-up tasks needed
- Document the Settlement-like interface in docs/ai_manager/ for future maintainers.

Lessons learned
- Duck-typing is effective for supporting both models and hashes in Ruby service objects.
- Refactoring for interface flexibility can be done with minimal risk if tests are comprehensive.