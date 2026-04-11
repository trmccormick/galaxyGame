# TASK: AI Manager :full_space_station Symbol Cleanup
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Symbol replacement across two service files. All
locations are explicitly listed. No architectural inference required.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Settlement::SpaceStation` has been retired (see
`2026-04-10-HIGH-REFACTOR-RETIRE-SPACESTATION-ORBITALDEPOT.md`).

The AI Manager services still reference `:full_space_station` as a
construction type symbol across 19 locations in two files. These need
to be updated to reflect the new architecture where an orbital station
is an `OrbitalSettlement` owning one or more `OrbitalStructure` instances.

The symbol `:full_space_station` becomes `:orbital_station` — a construction
type that creates an `OrbitalSettlement` with a fitted `OrbitalStructure`.

---

## Problem Statement

**Current behavior**: AI Manager uses `:full_space_station` symbol to plan
and analyze orbital station construction. This symbol maps to the retired
`Settlement::SpaceStation` model.

**Expected behavior**: AI Manager uses `:orbital_station` symbol which maps
to creating an `OrbitalSettlement` with an `OrbitalStructure` fitted per
blueprint.

---

## Files Involved

### Primary Files — you will edit
| File | Locations |
|---|---|
| `app/services/ai_manager/station_cost_benefit_analyzer.rb` | Lines 163, 243, 264, 297, 313, 335, 463, 611 |
| `app/services/ai_manager/station_construction_strategy.rb` | Lines 207, 292, 297, 629, 789, 811, 826, 843, 862, 877, 925 |

### Reference Files — read but do not edit
| File | Why |
|---|---|
| `app/models/settlement/orbital_settlement.rb` | Target model |
| `app/models/structures/orbital_structure.rb` | Target structure |

---

## Implementation Steps

### Step 1 — Verify all locations
```bash
grep -n "full_space_station" app/services/ai_manager/station_cost_benefit_analyzer.rb
grep -n "full_space_station" app/services/ai_manager/station_construction_strategy.rb
```
Confirm line numbers match the list above. Report any additional locations.

### Step 2 — Replace symbol in both files
In both files, replace every instance of:
```ruby
:full_space_station
```
with:
```ruby
:orbital_station
```

Also replace any string versions:
```ruby
'full_space_station'
```
with:
```ruby
'orbital_station'
```

### Step 3 — Update construction instantiation
In `station_construction_strategy.rb`, find any location that instantiates
`Settlement::SpaceStation` or `Settlement::OrbitalDepot` and replace with
`Settlement::OrbitalSettlement`.

### Step 4 — Verify no remaining references
```bash
grep -rn "full_space_station\|SpaceStation\|OrbitalDepot" \
  app/services/ai_manager/station_cost_benefit_analyzer.rb \
  app/services/ai_manager/station_construction_strategy.rb
```
Expected: zero results.

---

## Synthesis Report Format

```
LOCATIONS FOUND
station_cost_benefit_analyzer.rb: [N locations]
station_construction_strategy.rb: [N locations]
Any additional files: [list or "none"]

PROPOSED CHANGE
Replace :full_space_station → :orbital_station in both files
Replace any Settlement::SpaceStation instantiation → Settlement::OrbitalSettlement

RISK
[any case/when branches that need more than symbol rename]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

### 1. AI Manager specs in isolation
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/station_cost_benefit_analyzer_spec.rb spec/services/ai_manager/station_construction_strategy_spec.rb 2>&1 | tail -10'
```

### 2. Full AI Manager suite
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/ 2>&1 | tail -5'
```

### 3. Full suite — redirect, never stream
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```
Report final summary line only + any new failures.

---

## Acceptance Criteria
- [ ] `:full_space_station` replaced with `:orbital_station` in both files
- [ ] No remaining `SpaceStation` or `OrbitalDepot` references in either file
- [ ] AI Manager specs pass at same rate as before
- [ ] No new failures in full suite

---

## Stop Conditions — escalate immediately if:
- Any `case/when :full_space_station` branch contains logic that cannot
  be trivially renamed — list the branch and stop
- Symbol is used as a database value or serialized anywhere — flag before
  changing
- More than 2 additional files found with `:full_space_station` references

---

## Commit Instructions
```bash
git add app/services/ai_manager/station_cost_benefit_analyzer.rb \
        app/services/ai_manager/station_construction_strategy.rb
git commit -m "refactor: replace :full_space_station with :orbital_station in AI Manager services"
git push
```

---

## Dependencies
**Blocked by**: `2026-04-10-HIGH-REFACTOR-RETIRE-SPACESTATION-ORBITALDEPOT.md`
**Blocks**: nothing
**Related tasks**:
- `2026-04-10-MEDIUM-ARCHITECTURE-ORBITAL-SETTLEMENT-LOCATION.md`
- `2026-04-10-HIGH-ARCHITECTURE-ORBITAL-MARKET-SYSTEM.md`

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
