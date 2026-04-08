# TASK: Fix AIManager::StrategySelector nil state_analysis — add safe defaults and guards
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-07
**Last Updated**: 2026-04-07


---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Mechanical nil‑guarding and default‑shape fix; no JSON, no architecture.
**Supervision Level**: 🔴 Watched carefully


---

## Context

`AIManager::StrategySelector` uses a `state_analysis` hash to summarize resource needs, risks, and opportunities for the AI Manager’s advance‑time loop. [web:91]

After the `ExpansionService` ISRU‑fix, the integration spec now fails with:

```ruby
NoMethodError: undefined method '[]' for nil
state_analysis[:resource_needs][:critical]
```

This means `state_analysis` is `nil` in some scenarios, but the code assumes it is a hash with nested keys. [web:91]

Goal of this task:
- Ensure `state_analysis` is **never nil** in the expected call path.
- Provide a **safe default shape** (empty but present keys) so downstream reads like:
  ```ruby
  state_analysis[:resource_needs][:critical]
  ```
  do not crash.

Use GPT‑4.1 only for **local, mechanical guards and defaults**, not for:
- Redesigning the `StrategySelector` scoring model.
- Restructuring `state_analysis` shape (that’s a Claude‑level refactor).

---

## Problem Statement

**Current behavior**:
- In some `AIManager::Manager.advance_time` scenarios, `state_analysis` is `nil`.
- Then `StrategySelector` attempts:
  ```ruby
  state_analysis[:resource_needs][:critical]
  ```
  → `NoMethodError: undefined method '[]' for nil`.

**Expected behavior**:
- `state_analysis` is:
  - Either a hash with at least:
    - `:resource_needs`
    - `:resource_needs[:critical]` (array or similar)
  - Or `nil` is **never** passed to that line.
- Downstream code treats `nil` safely (via `&.dig` or defaulting to empty).

**Error output (example)**:
```ruby
Failure/Error: state_analysis[:resource_needs][:critical]
NoMethodError: undefined method '[]' for nil
# ./app/services/ai_manager/strategy_selector.rb:67
# ./spec/services/ai_manager/manager_integration_spec.rb:194
```


---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/strategy_selector.rb` | Fix nil `state_analysis` and its structure | `#select_strategy` / `#advance_time` near line 67 |
| `spec/services/ai_manager/manager_integration_spec.rb` | Confirm all 4 “Advance Time Integration” failures disappear | section “Advance Time Integration” |


### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/ai_manager/manager.rb` | where `state_analysis` is originally built for advance_time |
| `spec/services/ai_manager/strategy_selector_spec.rb` | unit tests for `StrategySelector` alone (if present) |


---

## Implementation Steps

> 0x agent: follow these steps exactly in order.

### Step 1 — find the `state_analysis` source

In `app/services/ai_manager/manager.rb`:

- Identify how and where `state_analysis` is built for `advance_time`.
- If it can be `nil`, decide whether:
  - It should be defaulted at **construction** (already a hash), or
  - Defaulted at **use** in `StrategySelector`.

### Step 2 — ensure `state_analysis` has a non‑nil shape

In `app/services/ai_manager/strategy_selector.rb`:

Change:

```ruby
critical_needs = state_analysis[:resource_needs][:critical]
```

to something like:

```ruby
critical_needs = state_analysis&.dig(:resource_needs, :critical) || []
```

Do the same for any other accesses of `state_analysis[:resource_needs]` or `state_analysis[:...][:...]` that appear in the same block.

If you discover that `state_analysis` is `nil` in more places, apply the same pattern:

- Prefer `&.dig` or `|| {}` / `|| []` at the point of access, **not** fabricating a complex fake object.

### Step 3 — run the isolated failures

Run:

```bash
docker exec -it web bash -c \
  'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/manager_integration_spec.rb:194 --failure-examples'
```

(Adjust the line numbers to the 4 failing scenarios in “Advance Time Integration”.)

They should now pass or change (no `NoMethodError`).

### Step 4 — run full integration spec

Run:

```bash
docker exec -it web bash -c \
  'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/manager_integration_spec.rb'
```

Expected: 0 failures in that file.

### Step 5 — run AI Manager suite

Run:

```bash
docker exec -it web bash -c \
  'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
```

Ensure no regressions in `strategy_selector_spec.rb` or elsewhere.

---

## Synthesis Report Format

Produce this before applying any fix and **stop**:

```text
CURRENT FAILURE LOCATION
File: app/services/ai_manager/strategy_selector.rb:67
Code: state_analysis[:resource_needs][:critical]

WHAT GENERATES state_analysis IN manager.rb
Describe where state_analysis is built (method name, line range).

CURRENT DEFAULT SHAPE OF state_analysis
If present, what keys does it normally have? (e.g., :resource_needs, :critical, :risk, etc.)

PROPOSED CHANGE
Propose code change to:
- Ensure state_analysis is never nil, OR
- Guard all accesses with &.dig or || [].

FILES TO EDIT
- app/services/ai_manager/manager.rb (if defaulting shape there)
- app/services/ai_manager/strategy_selector.rb (nil guards)

RISK
- No new JSON or DB schema changes.
- Only nil guards and default shapes.

READY TO APPLY? — waiting for approval
```

Do not apply any fix until the user explicitly approves.

---

## Testing Sequence

1. Isolation:
   ```bash
   docker exec -it web bash -c \
     'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/manager_integration_spec.rb:194 --failure-examples'
   ```
   (repeat for each failing line).

2. Full integration spec:
   ```bash
   docker exec -it web bash -c \
     'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/manager_integration_spec.rb'
   ```

3. AI Manager suite:
   ```bash
   docker exec -it web bash -c \
     'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
   ```

4. If all green, run a full suite log (optional, but report):
   ```bash
   docker exec -it web bash -c \
     'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
   ```

---

## Acceptance Criteria
- [ ] All 4 “Advance Time Integration” failures in `manager_integration_spec.rb` pass.  
- [ ] No new failures in `strategy_selector_spec.rb` or other AI Manager specs.  
- [ ] All accesses to `state_analysis[:resource_needs][:critical]` (or similar) are safely guarded against `nil`.  
- [ ] No new JSON or DB schema changes.  
- [ ] No new faked `state_analysis` complex shapes; only simple defaults or `nil`‑safe reads.

---

## Stop Conditions — escalate to user immediately if:
- Fix causes new failures in specs you did not touch.  
- Root cause is in `manager.rb`’s resource‑analysis structure rather than simple nil handling.  
- `state_analysis` is used in many places and the pattern is not obvious.  
- Any architecture‑level change to `StrategySelector` scoring is required.

---

## Commit Instructions

Run from **host**, not in container:

```bash
git add \
  app/services/ai_manager/strategy_selector.rb \
  app/services/ai_manager/manager.rb
git commit -m "fix: AIManager::StrategySelector – nil state_analysis guards with safe defaults"
git push
```

---

## Documentation

- [ ] No doc changes needed.  
- [ ] Flag doc gap:
  - “AIManager::StrategySelector state_analysis shape and nil‑safety” — add to backlog for later documentation.

---

## Dependencies

**Blocked by**: none  
**Blocks**:  
- `AIManager::Manager advance_time` greenness  
**Related tasks**:  
- Future `Claude` refactor of `state_analysis` shape if needed.

---

## Completion Report
*Filled in by the implementing agent after completion*

```text
**Completed by**: [agent name]
**Completion date**: YYYY-MM-DD
**Final test result**: X examples, Y failures

### What was changed
- [File] — [description of change, e.g., added &.dig guard on state_analysis[:resource_needs][:critical].]
- [If more spots, list them.]

### Issues discovered
[Any unexpected behavior revealed.]

### Follow-up tasks needed
[Any new tasks identified, e.g., document state_analysis shape.]

### Lessons learned
[What worked/didn’t in this area.]
```