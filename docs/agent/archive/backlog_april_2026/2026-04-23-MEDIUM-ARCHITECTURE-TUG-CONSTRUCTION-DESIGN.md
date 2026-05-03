# TASK: Tug Construction System Design — Blueprint, Mission Profile, Service Fix
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: architecture
**Created**: 2026-04-23
**Last Updated**: 2026-04-23

---

## Agent Assignment
**Assigned To**: Claude (Session Strategist)
**Why This Agent**: Requires game design decisions from developer before any
implementation. Blueprint content, mission profile structure, and material
requirements must be approved before code is written.
**Supervision Level**: 🟢 Autonomous OK once design is approved

---

## Context

The tug construction integration spec was written ahead of implementation.
Four specs are currently marked `xit` pending this design work. Once complete,
unmark them and verify they pass.

The asteroid relocation tug is a large orbital craft built at an L1 station
orbital shipyard. It is used for capturing and relocating asteroids — a key
late-game industrial activity.

**Read before starting:**
- `docs/architecture/systems/job_system_mechanics_spec.md`
- `galaxy_game/app/services/construction/orbital_shipyard_service.rb`
- `galaxy_game/spec/integration/tug_construction_integration_spec.rb`

---

## Design Decisions Required From Developer

The following must be answered before implementation begins.
**Do not implement until these are confirmed.**

### 1. Asteroid Relocation Tug — What Does It Require?

The blueprint needs:
- Key materials and quantities for construction
- Required facility type (orbital shipyard bay count, robotic arms, etc.)
- Construction time estimate
- Category/craft_type value

### 2. Mission Profile — 3 Phases

The spec asserts `mission_profile['phases'].length == 3`.
What are the three phases of an `l1_tug_construction` mission?
Example candidates: procurement → construction → deployment

### 3. Adaptive Parameters

The spec asserts `mission_profile['adaptive_parameters']` is present.
What adaptive parameters should a tug construction mission support?
Example: radiation level adjustments, material substitutions, timeline extensions.

---

## Implementation Steps (After Design Approved)

### Step 1 — Fix OrbitalShipyardService.create_shipyard_project

Current implementation is an instance method. Spec calls it as a class method
with two arguments (station, blueprint_id). Fix to:

```ruby
def self.create_shipyard_project(station, blueprint_id)
  blueprint = load_craft_blueprint(blueprint_id)
  materials = calculate_required_materials(blueprint_id)

  OrbitalConstructionProject.create!(
    station: station,
    craft_blueprint_id: blueprint_id.to_s,
    status: 'materials_pending',
    progress_percentage: 0,
    required_materials: materials,
    delivered_materials: materials.transform_values { 0 },
    project_metadata: {}
  )
end
```

### Step 2 — Create blueprint JSON

Location: `galaxy_game/data/json-data/blueprints/crafts/space/spacecraft/asteroid_relocation_tug_bp.json`

Structure based on existing blueprint pattern:
```json
{
  "id": "asteroid_relocation_tug",
  "name": "Asteroid Relocation Tug",
  "category": "asteroid_relocation_tug",
  "required_materials": {
    "[material_id]": [quantity]
  },
  "production_data": {
    "time_hours": [value],
    "required_facility_type": "orbital_shipyard"
  }
}
```

⚠️ Validate JSON after writing:
```bash
python3 -c "import json; json.load(open('path/to/file.json'))"
```

### Step 3 — Create mission profile JSON

Location: determined by `GalaxyGame::Paths::TASKS_MISSIONS_PATH`

First find the path:
```bash
grep -rn "TASKS_MISSIONS_PATH" galaxy_game/app/ galaxy_game/config/ galaxy_game/lib/
```

Structure:
```json
{
  "id": "l1_tug_construction",
  "name": "L1 Tug Construction Mission",
  "phases": [
    { "name": "procurement", "description": "..." },
    { "name": "construction", "description": "..." },
    { "name": "deployment", "description": "..." }
  ],
  "adaptive_parameters": {
    "radiation_level": ["low", "medium", "high"],
    "material_substitutions": {},
    "timeline_extensions": {}
  }
}
```

### Step 4 — Add :station trait to base_settlement factory

```ruby
trait :station do
  settlement_type { :orbital_station }
  operational_data {
    {
      'infrastructure_level' => 3,
      'shipyard_bays' => 2,
      'robotic_assembly_arms' => 6,
      'quality_control_systems' => 3
    }
  }
end
```

⚠️ Confirm `:orbital_station` is a valid `settlement_type` enum value:
```bash
grep -n "settlement_type\|orbital_station" galaxy_game/app/models/settlement/base_settlement.rb
```

### Step 5 — Unmark specs and verify

Remove `xit` markers from all 4 examples in:
`galaxy_game/spec/integration/tug_construction_integration_spec.rb`

Run:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/tug_construction_integration_spec.rb 2>&1 | tail -10'
```
Expected: 0 failures.

---

## Acceptance Criteria
- [ ] Design decisions confirmed by developer
- [ ] `OrbitalShipyardService.create_shipyard_project` is a class method
- [ ] Blueprint JSON exists and is valid
- [ ] Mission profile JSON exists and is valid
- [ ] `:station` factory trait exists
- [ ] All 4 integration specs pass
- [ ] No regressions in orbital construction project specs

---

## Stop Conditions
- Design decisions not confirmed — do not implement
- Blueprint JSON fails validation — fix before continuing
- `settlement_type: :orbital_station` not a valid enum value — stop, report

---

## Commit Instructions
```bash
git add galaxy_game/app/services/construction/orbital_shipyard_service.rb \
        galaxy_game/data/json-data/blueprints/crafts/space/spacecraft/asteroid_relocation_tug_bp.json \
        galaxy_game/data/json-data/[mission_profile_path]/ \
        galaxy_game/spec/factories/ \
        galaxy_game/spec/integration/tug_construction_integration_spec.rb
git commit -m "arch: tug construction — blueprint, mission profile, service fix, factory trait, unblock integration specs"
```

---

## Dependencies
**Blocked by**: Developer design decisions (materials, phases, adaptive parameters)
**Blocked by**: 2026-04-23-MEDIUM-CHORE-TUG-CONSTRUCTION-SPEC-MARK-PENDING.md (must be pending first)
**Blocks**: Nothing
**Unblocks**: 4 integration specs currently marked xit
