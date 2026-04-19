# TASK: depot_adapter — CelestialLocation missing name on create
**Status**: ACTIVE
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-17
**Last Updated**: 2026-04-17

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Two-line fix in a single service file, fully specified
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agent: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

---

## Context

`AIManager::DepotAdapter` creates `OrbitalSettlement` depots for terraforming
gas storage. When the depot has no location, it creates a
`Location::CelestialLocation`. The `CelestialLocation` model requires a `name`
field (`null: false`, unique index). The current code does not pass a `name`,
causing a validation failure. `NameGeneratorService` already exists in the
codebase and provides collision-safe unique identifier generation via
`generate_identifier` — appropriate for auto-created orbital depot locations
that have not yet been named by a settlement.

---

## Problem Statement

`Location::CelestialLocation.create!` in `depot_adapter.rb` does not pass a
`name` attribute. `CelestialLocation` validates `name` presence and uniqueness.

**Error output:**
```
ActiveRecord::RecordInvalid:
  Validation failed: Name can't be blank
# ./app/services/ai_manager/depot_adapter.rb:24
# ./app/services/ai_manager/terraforming_manager.rb:456
```

**Current behavior**: `CelestialLocation.create!` raises `RecordInvalid` —
name can't be blank.

**Expected behavior**: Location is created with a unique auto-generated name
using `NameGeneratorService#generate_identifier`.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Section |
|---|---|---|
| `galaxy_game/app/services/ai_manager/depot_adapter.rb` | Creates depot and its location | `self.create_depot` — the `unless depot.location` block |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/services/name_generator_service.rb` | Confirm `generate_identifier` method exists and returns a unique string |
| `galaxy_game/app/models/location/celestial_location.rb` | Confirm name validation and uniqueness scope |

### Migration
- [x] No migration needed

---

## Implementation Steps

> Follow these steps exactly in order.

### Step 1 — Verify current state
```bash
sed -n '20,33p' galaxy_game/app/services/ai_manager/depot_adapter.rb
```
Expected: `CelestialLocation.create!` block without a `name:` attribute.

### Step 2 — Verify NameGeneratorService
```bash
grep -n "def generate_identifier" galaxy_game/app/services/name_generator_service.rb
```
Expected: method exists on approximately line 12.

### Step 3 — Apply the fix

```ruby
# BEFORE — the unless depot.location block
unless depot.location
  Location::CelestialLocation.create!(
    celestial_body: world,
    coordinates: '0.00°N 0.00°E',
    altitude: calculate_orbital_altitude(world),
    locationable: depot
  )
end

# AFTER
unless depot.location
  name_service = NameGeneratorService.new
  Location::CelestialLocation.create!(
    celestial_body: world,
    name: name_service.generate_identifier,
    coordinates: '0.00°N 0.00°E',
    altitude: calculate_orbital_altitude(world),
    locationable: depot
  )
end
```

---

## Synthesis Report Format
Before applying any fix, produce a report in this format and **stop**:

```
THE FAILURE
Spec: spec/services/ai_manager/terraforming_manager_spec.rb (12 failures)
Error: ActiveRecord::RecordInvalid — Validation failed: Name can't be blank
Expected: CelestialLocation created successfully
Got: RecordInvalid on create!

ROOT CAUSE
CelestialLocation.create! in depot_adapter.rb does not pass a name attribute.
CelestialLocation validates name presence. NameGeneratorService provides
collision-safe unique identifiers appropriate for auto-created orbital locations.

PROPOSED FIX
Instantiate NameGeneratorService and pass generate_identifier as name
in the CelestialLocation.create! call.

RISK
Low — only affects auto-created depot locations. find_or_create_by! on
the depot prevents duplicate depots so this block only runs once per world.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Isolation run:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/terraforming_manager_spec.rb 2>&1 | grep -E "example|failure" | tail -5'
```
Expected: `12 examples, 0 failures`

2. **Related specs:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/ 2>&1 | grep -E "example|failure" | tail -5'
```
Expected: no new failures vs baseline.

---

## Acceptance Criteria
- [ ] `terraforming_manager_spec.rb` — 0 failures
- [ ] No regressions in `spec/services/ai_manager/`
- [ ] No migration generated

---

## Stop Conditions — escalate to user immediately if:
- `NameGeneratorService` does not exist or `generate_identifier` method is missing
- Fix causes new failures in ai_manager specs
- `CelestialLocation` uniqueness constraint on name causes collision in test environment

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add galaxy_game/app/services/ai_manager/depot_adapter.rb
git commit -m "fix: depot_adapter — add NameGeneratorService name to CelestialLocation.create! (was missing required name attribute)"
git push
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing
**Related tasks**: `2026-04-16-HIGH-ARCHITECTURE-RAW-RESOURCE-EXTRACTION-PRICING.md`

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
