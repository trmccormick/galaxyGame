# TASK: Implement population_capacity on BaseCraft, Remove Housing Concern
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: feature
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Mechanical changes — remove an include, add explicit methods,
delete two files. All file paths, method signatures, and exact code are specified
below. No architectural inference required.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Housing` is a confirmed stub concern created 2026-02-15. It sets
`@population_capacity = 100` via `attr_accessor` and `after_initialize`. It
provides no real behavior and no unit-based calculation. It has been removed
from `OrbitalStructure` and `ConvertedBase` already (2026-04-10 session).

Two models still include it actively:
- `Craft::BaseCraft` — needs real population capacity logic (see below)
- `Structures::BaseStructure` — needs real population capacity logic (see below)

The correct pattern is confirmed from `Settlement::BaseSettlement` — sum
`base_units` operational_data capacity. No fallback. No hardcoded default.
Zero units = zero capacity.

`population_capacity` is NOT a database column. `current_population` IS a
database column on craft and structure tables. `attr_accessor` from Housing
was silently providing an in-memory-only value, masking the real column.

---

## Problem Statement

**Current behavior**:
- `BaseCraft` includes `Housing` — every craft instance gets
  `@population_capacity = 100` as a hardcoded in-memory default
- `BaseStructure` includes `Housing` — same problem
- No overcrowding protection exists on crafts or structures
- Supply calculations that depend on population capacity get wrong values

**Expected behavior**:
- `BaseCraft#population_capacity` sums installed habitat unit capacity
  from `base_units` operational_data — identical logic to BaseSettlement
- `BaseCraft#available_capacity` returns `population_capacity - current_population`
- `BaseCraft#has_capacity_for?(n)` returns `available_capacity >= n`
- `BaseStructure` gets the same three methods
- `include Housing` removed from both models
- `app/models/concerns/housing.rb` deleted
- `spec/models/concerns/housing_spec.rb` deleted

---

## Files Involved

### Primary Files — you will edit or delete these
| File | Action | Detail |
|---|---|---|
| `app/models/craft/base_craft.rb` | Edit | Remove `include Housing`, add three methods |
| `app/models/structures/base_structure.rb` | Edit | Remove `include Housing`, add three methods |
| `app/models/concerns/housing.rb` | Delete | Stub — no longer needed |
| `spec/models/concerns/housing_spec.rb` | Delete | Tests the stub — invalid after removal |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/settlement/base_settlement.rb` | Canonical pattern — lines 136–162 |
| `app/models/structures/orbital_structure.rb` | Example of correct removal from this session |
| `app/models/structures/converted_base.rb` | Example of correct removal from this session |

---

## Implementation Steps

> Follow in order. Do not skip steps.

### Step 1 — Verify current state

Confirm Housing is still active in both files:
```bash
grep -n "include Housing" app/models/craft/base_craft.rb app/models/structures/base_structure.rb
```
Expected: one match in each file.

Confirm housing_spec.rb exists:
```bash
ls spec/models/concerns/housing_spec.rb
```

### Step 2 — Add population methods to BaseCraft

In `app/models/craft/base_craft.rb`, find the INCLUDES block at the top of
the class (around line 11). Remove this line:
```ruby
include Housing
```

In the INSTANCE METHODS section of `app/models/craft/base_craft.rb`, add
these three methods. Place them after `initialize_housing` removal, before
`add_equipment!`:

```ruby
# Population capacity calculated from installed habitat units.
# Returns 0 if no units provide capacity — no hardcoded fallback.
def population_capacity
  base_units.sum do |unit|
    capacity_data = unit.operational_data&.dig('capacity')
    if capacity_data.is_a?(Hash)
      capacity_data['passenger_capacity'] || capacity_data['capacity'] || 0
    else
      capacity_data&.to_i || 0
    end
  end
end

# Available capacity = total capacity - current population
def available_capacity
  population_capacity - current_population.to_i
end

# Check if craft has capacity for additional population
def has_capacity_for?(additional_population)
  available_capacity >= additional_population
end
```

### Step 3 — Add population methods to BaseStructure

In `app/models/structures/base_structure.rb`, remove:
```ruby
include Housing
```

Add the same three methods to the instance methods section of BaseStructure:

```ruby
# Population capacity calculated from installed habitat units.
# Returns 0 if no units provide capacity — no hardcoded fallback.
def population_capacity
  base_units.sum do |unit|
    capacity_data = unit.operational_data&.dig('capacity')
    if capacity_data.is_a?(Hash)
      capacity_data['passenger_capacity'] || capacity_data['capacity'] || 0
    else
      capacity_data&.to_i || 0
    end
  end
end

# Available capacity = total capacity - current population
def available_capacity
  population_capacity - current_population.to_i
end

# Check if structure has capacity for additional population
def has_capacity_for?(additional_population)
  available_capacity >= additional_population
end
```

### Step 4 — Delete Housing concern and its spec

Run on host (not in container — these are git operations):
```bash
git rm app/models/concerns/housing.rb
git rm spec/models/concerns/housing_spec.rb
```

If `git rm` fails because the files are untracked, use:
```bash
rm app/models/concerns/housing.rb
rm spec/models/concerns/housing_spec.rb
```

### Step 5 — Verify no remaining Housing references

```bash
grep -rn "include Housing\|require.*housing\|Housing\b" app/ spec/ --include="*.rb"
```

Expected: zero results, or only commented-out lines in OrbitalStructure and
ConvertedBase (those are acceptable — they document the removal).

---

## Synthesis Report Format

Before applying any fix, produce a report in this format and **stop**:

```
CURRENT STATE
BaseCraft include Housing: [line number]
BaseStructure include Housing: [line number]
housing_spec.rb exists: [yes/no]
housing.rb exists: [yes/no]

PROPOSED CHANGES
1. Remove include Housing from BaseCraft line [N]
2. Add population_capacity, available_capacity, has_capacity_for? to BaseCraft
3. Remove include Housing from BaseStructure line [N]
4. Add population_capacity, available_capacity, has_capacity_for? to BaseStructure
5. Delete housing.rb
6. Delete housing_spec.rb

RISK
[any shared concerns or unexpected references found]

READY TO APPLY? — waiting for approval
```

Do not apply any changes until the user explicitly approves.

---

## Testing Sequence

> Run in this order. Do not skip steps.

### 1. BaseCraft spec in isolation
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/craft/'
```
Expected: 0 failures

### 2. BaseStructure spec in isolation
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/'
```
Expected: 2 failures only — the known order-dependent false positives in
`base_structure_spec.rb`. Any new failures are regressions — stop and report.

### 3. Settlement suite
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/'
```
Expected: 0 failures except known refactor blocker at
`space_station_spec.rb:425`

### 4. Full suite — redirect output, never stream
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```
Report back: final summary line only + any new failures not in the
pre-existing 25.

---

## Acceptance Criteria
- [ ] `include Housing` removed from `BaseCraft`
- [ ] `include Housing` removed from `BaseStructure`
- [ ] `population_capacity`, `available_capacity`, `has_capacity_for?` added to both models
- [ ] `population_capacity` returns 0 when no habitat units installed — confirmed by isolation spec
- [ ] `housing.rb` deleted
- [ ] `housing_spec.rb` deleted
- [ ] No remaining active `include Housing` references in app/ or spec/
- [ ] Structures suite: only the 2 known false positives, no new failures
- [ ] Full suite: 25 failures, same pre-existing set, no regressions

---

## Stop Conditions — escalate to user immediately if:
- Any spec outside housing_spec.rb fails that was not in the pre-existing 25
- `population_capacity` is referenced anywhere else in app/ or spec/ that
  was not identified in the audit (grep Step 5 returns unexpected results)
- BaseStructure has associations or logic that differs significantly from
  BaseCraft — flag before adding methods, do not add blindly
- `current_population` is missing from the craft or structure table schema —
  `available_capacity` will break without it

---

## Commit Instructions

Run git commands on **host**, not inside container:
```bash
git add app/models/craft/base_craft.rb
git add app/models/structures/base_structure.rb
git rm app/models/concerns/housing.rb
git rm spec/models/concerns/housing_spec.rb
git commit -m "feat: replace Housing stub with real population_capacity on BaseCraft and BaseStructure — unit-based sum, no fallback"
git push
```

---

## Documentation
- [ ] No doc changes needed — audit findings captured in session handoff

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing
**Related tasks**:
- `2026-04-10-MEDIUM-ARCHITECTURE-HOUSING-CONCERN-BASECRAFT-INCLUDE-AUDIT.md` — this task is the follow-up to that audit

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed

### Issues discovered

### Follow-up tasks needed

### Lessons learned
