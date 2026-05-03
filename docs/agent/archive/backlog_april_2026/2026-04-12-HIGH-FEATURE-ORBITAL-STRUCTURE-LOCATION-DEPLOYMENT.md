# TASK: OrbitalStructure — CelestialLocation Created on Deployment
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-04-12
**Last Updated**: 2026-04-12

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Well-scoped, single model, reference implementation
already exists in depot_adapter.rb. Explicit paths and before/after
provided.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`OrbitalSettlement#location` delegates to
`structures.first&.celestial_location`. For this to work, each
`OrbitalStructure` must have a `CelestialLocation` created when it
is deployed.

Currently no code creates a `CelestialLocation` for `OrbitalStructure`
on deployment — `location` returns nil for all orbital settlements
until a structure has one manually created.

The reference implementation is `AIManager::DepotAdapter#create_depot`
which creates a `CelestialLocation` after creating the depot structure.
This pattern must become the standard for all `OrbitalStructure`
deployment.

**Bridge convention in effect**: One structure per `OrbitalSettlement`
until multi-structure routing is implemented. Document this in code.

---

## Problem Statement

**Current**: `OrbitalStructure` has no `CelestialLocation` after creation.
`settlement.location` returns nil. ~40 service layer calls that do
`settlement.location&.celestial_body` silently return nil for all
orbital settlements.

**Expected**: `OrbitalStructure` gets a `CelestialLocation` created
when deployed to orbit around a celestial body. `settlement.location`
returns a valid location. Service layer calls work correctly.

---

## Reference Implementation

```ruby
# app/services/ai_manager/depot_adapter.rb
unless depot.location
  Location::CelestialLocation.create!(
    celestial_body: world,
    latitude: 0.0,
    longitude: 0.0,
    altitude: calculate_orbital_altitude(world),
    locationable: depot,
    environmental_data: { 'context' => 'orbital' }
  )
end
```

Note: `environmental_data: { 'context' => 'orbital' }` distinguishes
orbital locations from surface locations. Always set this for orbital
structure locations.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Action |
|---|---|---|
| `app/models/structures/orbital_structure.rb` | Orbital structure model | Add deployment method |
| `app/services/ai_manager/depot_adapter.rb` | Reference only | Do not change |

### Reference Files — read but do not edit
| File | Why |
|---|---|
| `app/models/structures/base_structure.rb` | Understand existing callbacks |
| `db/schema.rb` | Confirm celestial_locations columns |
| `app/models/location/celestial_location.rb` | Confirm required fields |

---

## Implementation Steps

### Step 1 — Read current OrbitalStructure
```bash
cat app/models/structures/orbital_structure.rb
grep -n "after_create\|after_initialize\|celestial_location\|location" \
  app/models/structures/orbital_structure.rb
grep -n "after_create\|after_initialize\|celestial_location" \
  app/models/structures/base_structure.rb
```

### Step 2 — Confirm CelestialLocation schema
```bash
grep -A 15 "create_table \"celestial_locations\"" db/schema.rb
```

Confirm these columns exist:
- `celestial_body_id` (required)
- `latitude`, `longitude` (required, use 0.0 for orbital)
- `altitude` (required for orbital)
- `environmental_data` jsonb (for context flag)
- `locationable_type`, `locationable_id` (polymorphic)

### Step 3 — Add deploy_to_orbit! method to OrbitalStructure

```ruby
# Add to app/models/structures/orbital_structure.rb

# Deploy this structure to orbit around a celestial body.
# Creates a CelestialLocation record associating the structure
# with the body at the given orbital altitude.
#
# Convention: one structure per OrbitalSettlement until
# multi-structure routing is implemented.
#
# @param celestial_body [CelestialBodies::CelestialBody]
# @param altitude_m [Float] orbital altitude in metres
def deploy_to_orbit!(celestial_body, altitude_m)
  return if celestial_location.present?

  Location::CelestialLocation.create!(
    celestial_body: celestial_body,
    latitude: 0.0,
    longitude: 0.0,
    altitude: altitude_m,
    locationable: self,
    environmental_data: { 'context' => 'orbital' }
  )
end
```

### Step 4 — Run specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && \
  RAILS_ENV=test bundle exec rspec \
  spec/models/structures/ \
  2>&1 | grep "examples"'
```

### Step 5 — Run models suite
```bash
docker exec -it web bash -c 'unset DATABASE_URL && \
  RAILS_ENV=test bundle exec rspec spec/models/ \
  > /home/galaxy_game/log/rspec_models_$(date +%s).log 2>&1'
docker exec -it web bash -c 'grep "examples" \
  $(ls -t /home/galaxy_game/log/rspec_models_*.log | head -1) | tail -3'
```

---

## Synthesis Report Format

```
ORBITAL_STRUCTURE CURRENT STATE
Has celestial_location association: [yes/no]
Has existing deploy method: [yes/no — describe]
Existing callbacks on create: [list]

CELESTIALLOCATION SCHEMA
Required fields confirmed: [list]
environmental_data column exists: [yes/no]
Unique constraint risk: [describe — lat 0.0/lng 0.0 per body]

PROPOSED ADDITION
Method: deploy_to_orbit!(celestial_body, altitude_m)
Location in file: [describe]
Risk: [any shared code affected]

READY TO APPLY? — waiting for approval
```

---

## Acceptance Criteria
- [ ] `deploy_to_orbit!` method added to `OrbitalStructure`
- [ ] Method creates `CelestialLocation` with `context: orbital`
- [ ] Method is idempotent (returns if location already exists)
- [ ] `depot_adapter.rb` still works correctly (do not change it)
- [ ] Structure specs pass
- [ ] No regressions in models suite

## Stop Conditions
- `celestial_locations` unique index on `(celestial_body_id, coordinates)`
  will conflict when two structures orbit same body at same coordinates.
  Flag immediately — coordinate strategy needed before implementing.
- `OrbitalStructure` already has a location creation callback — flag,
  may conflict.

---

## Commit Instructions
```bash
git add app/models/structures/orbital_structure.rb
git commit -m "feature: add deploy_to_orbit! to OrbitalStructure — creates CelestialLocation on deployment"
git push
```

---

## Dependencies
**Blocked by**:
- `2026-04-12-HIGH-ARCHITECTURE-ORBITAL-SETTLEMENT-DECOUPLE-FROM-BASE.md` — completed ✓
- `2026-04-12-MEDIUM-BUG-FIX-PHASE1-SOL-WORLD-NAMES-DATA-DRIVEN.md` — depot_adapter
  orbital altitude should be data-driven before this task runs
**Blocks**:
- `2026-04-10-MEDIUM-ARCHITECTURE-ORBITAL-SETTLEMENT-LOCATION.md` — supersedes parts of this
- All service layer location routing work
**Related**:
- `2026-04-12-HIGH-ARCHITECTURE-UNIFIED-DOCKING-EXCHANGE-MARKET-SYSTEM.md`
