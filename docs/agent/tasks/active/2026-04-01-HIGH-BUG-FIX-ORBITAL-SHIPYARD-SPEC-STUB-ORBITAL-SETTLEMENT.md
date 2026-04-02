# TASK: Fix orbital_shipyard_service_spec — Stub OrbitalSettlement + Fix Broken Assertions
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-01
**Last Updated**: 2026-04-01

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Targeted spec fix + one stub model creation — fully specified, no inference needed
**Supervision Level**: 🔴 Watched carefully

---

## Context
`orbital_shipyard_service_spec` has 7 failures. The spec was written against
the old `Settlement::SpaceStation` conflated model. A full architectural
refactor is planned (see backlog task below) but is blocked until the suite
is under 10 failures.

The fix strategy: create a minimal `Settlement::OrbitalSettlement` stub now
that inherits from `BaseSettlement`. This costs almost nothing, moves the
spec toward the new architecture, and means zero rework when the real refactor
lands. Do NOT reference `Settlement::SpaceStation` anywhere in this fix.

**Relevant backlog task** (do not implement — reference only):
`2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md`

**Architecture constraint**: All fixes must move TOWARD the new architecture,
not away from it. The new architecture is:
- `Settlement::OrbitalSettlement` — settlement (economy, population, jurisdiction)
- `Structures::SpaceStation` — physical structure asset
- These are separate models. Do not conflate them.

---

## Problem Statement
7 failures in `spec/services/construction/orbital_shipyard_service_spec.rb`.

**Root causes identified:**

**1. Service `initialize` is outside the class block** — Ruby defines it on
Object instead of `Construction::OrbitalShipyardService`. This breaks every
test that instantiates the service with an argument.

Current (broken) structure in `app/services/construction/orbital_shipyard_service.rb`:
```ruby
def initialize(settlement = nil)   # ← OUTSIDE the class — wrong
  @settlement = settlement
end
module Construction
  class OrbitalShipyardService
    ...
```

**2. Spec uses undefined variable `settlement`** (line 21):
```ruby
expect(project.station).to eq(settlement.space_station)
# `settlement` is commented out at top of spec — NameError
# `space_station` is old architecture — do not use
```

**3. Spec calls phantom association `project.blueprint.blueprint_id`** (line 27):
```ruby
expect(project.blueprint.blueprint_id).to eq(blueprint_id)
# OrbitalConstructionProject has no `blueprint` association
# It has a plain string column: craft_blueprint_id
```

**4. Spec creates `station` as `base_settlement`** (line 6):
```ruby
let(:station) { create(:base_settlement) }
# Should be orbital_settlement per new architecture
```

**Current behavior**: 7 failures
**Expected behavior**: 0 failures, no regressions

---

## Files Involved

### Primary Files — you will CREATE
| File | Purpose |
|------|---------|
| `app/models/settlement/orbital_settlement.rb` | Stub model — inherits BaseSettlement |
| `spec/factories/settlement/orbital_settlement.rb` | Minimal factory for stub model |

### Primary Files — you will EDIT
| File | Change |
|------|--------|
| `app/services/construction/orbital_shipyard_service.rb` | Move `initialize` inside class block |
| `spec/services/construction/orbital_shipyard_service_spec.rb` | Fix lines 6, 21, 27 |

### Reference Files — read but do not edit
| File | Why You Need It |
|------|----------------|
| `app/models/settlement/base_settlement.rb` | Parent class for stub |
| `app/models/orbital_construction_project.rb` | Confirms `craft_blueprint_id` is a string column |
| `spec/factories/settlement/base_settlement.rb` | Pattern to follow for factory |

---

## Implementation Steps

> Follow these steps exactly in order. Do not skip. Do not apply anything
> before producing the Synthesis Report and receiving approval.

### Step 1 — Read these files first
```bash
head -20 app/models/settlement/base_settlement.rb
cat spec/factories/settlement/base_settlement.rb
head -30 app/services/construction/orbital_shipyard_service.rb
```
Report what you see. Confirm the `initialize` is outside the class block.

### Step 2 — Produce Synthesis Report and STOP (see format below)

### Step 3 — Create stub model (after approval)
Create `app/models/settlement/orbital_settlement.rb`:
```ruby
module Settlement
  class OrbitalSettlement < BaseSettlement
    # Stub — full implementation pending test suite restoration
    # See: docs/agent/tasks/backlog/2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md
  end
end
```

### Step 4 — Create factory
Create `spec/factories/settlement/orbital_settlement.rb`:
```ruby
FactoryBot.define do
  factory :orbital_settlement, class: 'Settlement::OrbitalSettlement' do
    # Inherits all traits from base_settlement
    # Stub factory — expand when OrbitalSettlement is fully implemented
  end
end
```

### Step 5 — Fix service constructor
In `app/services/construction/orbital_shipyard_service.rb`, move `initialize`
inside the class block. The correct structure is:
```ruby
module Construction
  class OrbitalShipyardService
    def initialize(settlement = nil)
      @settlement = settlement
    end
    # ... rest of class
  end
end
```
Do not change any other logic in the service.

### Step 6 — Fix spec
In `spec/services/construction/orbital_shipyard_service_spec.rb`:

**Line 6** — change station factory:
```ruby
# Before
let(:station) { create(:base_settlement) }
# After
let(:station) { create(:orbital_settlement) }
```

**Line 21** — fix station assertion:
```ruby
# Before
expect(project.station).to eq(settlement.space_station)
# After
expect(project.station).to eq(station)
```

**Line 27** — fix blueprint assertion:
```ruby
# Before
expect(project.blueprint.blueprint_id).to eq(blueprint_id)
# After
expect(project.craft_blueprint_id).to eq(blueprint_id)
```

### Step 7 — Verify in isolation
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/construction/orbital_shipyard_service_spec.rb --format documentation 2>&1 | tail -40"
```
Expected: 0 failures. Report summary line + any failures.

### Step 8 — Verify no regressions in settlement specs
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/ spec/services/construction/ 2>&1 | tail -20"
```
Report summary line only.

---

## Synthesis Report Format
Produce this before applying ANY fix. STOP and wait for approval.

```
FILES READ
service constructor location: [inside class / outside class — confirmed]
base_settlement factory pattern: [one line summary]

FIXES TO APPLY
1. [file] line [N]: [exact change]
2. [file] line [N]: [exact change]
3. [file]: [create stub model]
4. [file]: [create factory]

RISK
[any shared code affected — factories used elsewhere, etc.]

READY TO APPLY? — waiting for approval
```

---

## Docker Rules — mandatory
```bash
# Always unset DATABASE_URL
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ..."

# Never use docker-compose exec
# Never omit unset DATABASE_URL
# Git runs on HOST not inside container
```

---

## Acceptance Criteria
- [ ] `Settlement::OrbitalSettlement` stub created, inherits `BaseSettlement`
- [ ] `:orbital_settlement` factory created
- [ ] Service `initialize` is inside the class block
- [ ] Spec line 6 uses `orbital_settlement` factory
- [ ] Spec line 21 asserts `project.station` eq `station`
- [ ] Spec line 27 asserts `project.craft_blueprint_id`
- [ ] Isolation run: 0 failures
- [ ] No regressions in settlement or construction specs
- [ ] No reference to `Settlement::SpaceStation` introduced anywhere

---

## Stop Conditions — escalate immediately if:
- Fix causes new failures in specs you did not touch
- Same failure persists after one attempt
- Factory inheritance from `base_settlement` causes unexpected errors
- Any migration appears to be needed
- You are unsure whether a change moves toward or away from the new architecture

---

## Commit Instructions
Run on HOST after confirmed 0 failures:
```bash
git add app/models/settlement/orbital_settlement.rb \
        spec/factories/settlement/orbital_settlement.rb \
        app/services/construction/orbital_shipyard_service.rb \
        spec/services/construction/orbital_shipyard_service_spec.rb
git commit -m "fix: orbital_shipyard_service_spec — stub OrbitalSettlement, fix constructor scope, fix broken assertions"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: nothing — stub is additive only
**Related tasks**: `2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md`

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
