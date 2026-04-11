# TASK: SpinGravity spec fix — wire concern to OrbitalStructure and add gravity_g to CelestialLocation
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-09
**Last Updated**: 2026-04-09

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Three small additive changes, fully specified, no inference needed
**Supervision Level**: 🔴 Watched carefully

---

## Context
`SpinGravity` is a new concern for orbital structures that calculates
artificial gravity from rotation. It calls `location&.gravity_g` internally.
`gravity_g` does not exist on `Location::CelestialLocation` — it has `gravity`
(returns m/s²) but not the G-force equivalent. The spec uses
`instance_double('Location', ...)` which points at the `Location` namespace,
not a real class — RSpec rejects this. `OrbitalStructure` also does not yet
include `SpinGravity` despite being in the architecture spec.

---

## Problem Statement
All 7 examples in `spec/models/concerns/spin_gravity_spec.rb` fail with:
the Location class does not implement the instance method: gravity_g

**Three root causes:**
1. `instance_double('Location', gravity_g: 0.005)` — `Location` is a namespace, not a class. RSpec cannot verify instance methods against it.
2. `gravity_g` does not exist on `Location::CelestialLocation` — the real location class used by `OrbitalStructure`.
3. `SpinGravity` is not included in `Structures::OrbitalStructure`.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Change |
|---|---|---|
| `galaxy_game/app/models/location/celestial_location.rb` | Location model | Add `gravity_g` method |
| `galaxy_game/app/models/structures/orbital_structure.rb` | Orbital structure model | Add `include SpinGravity` |
| `galaxy_game/spec/models/concerns/spin_gravity_spec.rb` | Concern spec | Fix `instance_double` class name |

### Reference Files — read but do not edit
| File | Why |
|---|---|
| `galaxy_game/app/models/concerns/spin_gravity.rb` | The concern being tested — read to understand `gravity_g` usage |
| `galaxy_game/app/models/location/base_location.rb` | Parent class — confirm no `gravity_g` there either |

---

## Implementation Steps

### Step 1 — Add `gravity_g` to `Location::CelestialLocation`

Open `galaxy_game/app/models/location/celestial_location.rb`.

Find the existing `gravity` method (in the ORBITAL MECHANICS section). Add
`gravity_g` immediately after it:
```ruby
def gravity
  return celestial_body.surface_gravity if surface?
  return nil unless celestial_body.respond_to?(:mass) && celestial_body.respond_to?(:radius)

  gravitational_parameter = celestial_body.gravitational_parameter
  orbital_radius = celestial_body.radius + altitude

  gravitational_parameter / (orbital_radius ** 2)
end

# G-force at this location (gravity in m/s² divided by 9.81)
def gravity_g
  gravity.to_f / 9.81
end
```

### Step 2 — Add `include SpinGravity` to `OrbitalStructure`

Open `galaxy_game/app/models/structures/orbital_structure.rb`.

Add `include SpinGravity` to the INCLUDES block. Place it after `include Docking`:
```ruby
include Structures::Shell
include HasUnits
include Housing
include EnergyManagement
include AtmosphericProcessing
include Docking
include SpinGravity   # ← add this line
```

### Step 3 — Fix `instance_double` in the spec

Open `galaxy_game/spec/models/concerns/spin_gravity_spec.rb`.

Find all occurrences of:
```ruby
instance_double('Location', gravity_g: 0.005)
instance_double('Location', gravity_g: 1.0)
```

Replace with:
```ruby
instance_double('Location::CelestialLocation', gravity_g: 0.005)
instance_double('Location::CelestialLocation', gravity_g: 1.0)
```

Do not change anything else in the spec.

---

## Synthesis Report Format
Before applying any fix, produce this and STOP:
THE FAILURE
Spec: spec/models/concerns/spin_gravity_spec.rb
Error: the Location class does not implement the instance method: gravity_g
Root causes: [confirm all three]
PROPOSED FIX

gravity_g method: [show exact code]
include SpinGravity: [show exact line and position]
instance_double fix: [show before/after]

RISK

gravity_g on CelestialLocation: additive, no existing callers
SpinGravity include: additive, no existing behaviour changed
Spec change: mechanical rename only

READY TO APPLY? — waiting for approval

---

## Testing Sequence

1. Isolation run first:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/concerns/spin_gravity_spec.rb'
```
Expected: `7 examples, 0 failures`

2. Related specs — confirm no regressions:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/ spec/models/location/'
```

3. Do NOT run full suite — report back after step 2.

---

## Acceptance Criteria
- [ ] `spin_gravity_spec.rb` — 7 examples, 0 failures
- [ ] No regressions in structures or location specs
- [ ] `gravity_g` added to `CelestialLocation` only — no other files touched

---

## Stop Conditions — escalate immediately if:
- `gravity_g` already exists somewhere in the inheritance chain under a different name
- `include SpinGravity` causes a method conflict in `OrbitalStructure`
- Any regression in structures or location specs
- The spec file has more than the two `instance_double` patterns described above

---

## Commit Instructions
On host, not in container:
```bash
git add galaxy_game/app/models/location/celestial_location.rb \
        galaxy_game/app/models/structures/orbital_structure.rb \
        galaxy_game/spec/models/concerns/spin_gravity_spec.rb
git commit -m "fix: spin_gravity_spec — add gravity_g to CelestialLocation, include SpinGravity in OrbitalStructure, fix instance_double class"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: nothing immediately — SpinGravity concern is now wired
**Related tasks**: `2026-04-08-HIGH-FEATURE-ORBITAL-STRUCTURE-ORBITAL-SETTLEMENT-ADDITIVE-IMPLEMENTATION.md`

---

## Completion Report
*Filled in by agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned