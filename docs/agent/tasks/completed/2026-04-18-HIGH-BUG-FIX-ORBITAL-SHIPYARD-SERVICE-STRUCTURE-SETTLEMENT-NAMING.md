# TASK: OrbitalShipyardService — Fix structure/settlement naming confusion
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-18
**Last Updated**: 2026-04-18

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single service file, all changes fully specified, no architectural decisions needed
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agent: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

---

## Context

`OrbitalShipyardService` was written with a naming confusion throughout.
The service was designed assuming its `station` argument is an
`OrbitalSettlement`, but the correct architecture is:

- **`OrbitalStructure`** — the physical shipyard structure where construction
  happens. This is what the service is initialized with.
- **`OrbitalSettlement`** — the settlement that owns the construction project.
  Reached via `structure.settlement`.
- **`OrbitalConstructionProject`** — belongs to the `OrbitalSettlement` via
  `belongs_to :station, class_name: 'Settlement::OrbitalSettlement'`

The specs are correctly written for this architecture. The service needs
to align with the specs.

---

## Problem Statement

**Current behavior:**
- `initialize(settlement = nil)` — parameter misnamed, spec passes an `OrbitalStructure`
- `create_shipyard_project` — passes `@settlement` (actually a structure) as `station:` to the project — type mismatch
- `deliver_materials(station, ...)` — calls `station.orbital_construction_projects` — only works on `OrbitalSettlement`, not `OrbitalStructure`
- `spawn_completed_craft` — `docked_at: project.station` sets `docked_at` to the settlement, should be the structure

**Error output:**
```
ActiveRecord::AssociationTypeMismatch:
  Settlement::OrbitalSettlement expected, got Structures::OrbitalStructure
```

**Expected behavior:** Service accepts `OrbitalStructure`, reaches settlement
via `structure.settlement`, creates project against settlement, queries
projects via settlement, docks craft at structure.

---

## Files Involved

### Primary Files — you will edit this
| File | Purpose | Key Methods |
|---|---|---|
| `galaxy_game/app/services/construction/orbital_shipyard_service.rb` | Shipyard service | `initialize`, `create_shipyard_project`, `deliver_materials`, `spawn_completed_craft` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/spec/services/construction/orbital_shipyard_service_spec.rb` | Shows exact spec setup — `station` is OrbitalStructure, `settlement` is OrbitalSettlement |
| `galaxy_game/app/models/orbital_construction_project.rb` | Confirms `belongs_to :station, class_name: 'Settlement::OrbitalSettlement'` |
| `galaxy_game/app/models/structures/orbital_structure.rb` | Confirms `belongs_to :settlement, class_name: 'Settlement::OrbitalSettlement'` |

### Migration
- [x] No migration needed

---

## Implementation Steps

> Follow these steps exactly in order.

### Step 1 — Verify current state
```bash
grep -n "def initialize\|@settlement\|station\|settlement" galaxy_game/app/services/construction/orbital_shipyard_service.rb | head -20
```

### Step 2 — Apply all four fixes

**Fix 1 — `initialize`:** Rename parameter from `settlement` to `structure`
```ruby
# FROM
def initialize(settlement = nil)
  @settlement = settlement
end

# TO
def initialize(structure = nil)
  @structure = structure
end
```

**Fix 2 — `create_shipyard_project`:** Pass `@structure.settlement` as station
```ruby
# FROM
OrbitalConstructionProject.create!(
  station: @settlement,
  craft_blueprint_id: blueprint_id.to_s,
  status: 'materials_pending',
  progress_percentage: 0
)

# TO
OrbitalConstructionProject.create!(
  station: @structure.settlement,
  craft_blueprint_id: blueprint_id.to_s,
  status: 'materials_pending',
  progress_percentage: 0
)
```

**Fix 3 — `deliver_materials`:** Query projects via `station.settlement`
```ruby
# FROM
def self.deliver_materials(station, material_type, quantity, source_settlement = nil)
  active_projects = station.orbital_construction_projects.where(status: ['materials_pending', 'in_progress'])

# TO
def self.deliver_materials(station, material_type, quantity, source_settlement = nil)
  active_projects = station.settlement.orbital_construction_projects.where(status: ['materials_pending', 'in_progress'])
```

**Fix 4 — `spawn_completed_craft`:** Dock craft at structure via project settlement's structures
```ruby
# FROM
craft = Craft::BaseCraft.create!(
  name: "#{blueprint['name']} #{Time.current.to_i}",
  craft_name: blueprint['id'],
  craft_type: blueprint['category'],
  owner: project.station.owner,
  operational_data: blueprint['operational_data'] || {},
  docked_at: project.station,
  status: :docked
)

# TO
craft = Craft::BaseCraft.create!(
  name: "#{blueprint['name']} #{Time.current.to_i}",
  craft_name: blueprint['id'],
  craft_type: blueprint['category'],
  owner: project.station.owner,
  operational_data: blueprint['operational_data'] || {},
  docked_at: project.station.structures.first,
  status: :docked
)
```

---

## Synthesis Report Format
Before applying any fix, produce a report in this format and **stop**:

```
THE FAILURE
Spec: orbital_shipyard_service_spec.rb + inventory_manager_spec.rb
Error: AssociationTypeMismatch — OrbitalSettlement expected, got OrbitalStructure
Expected: Service accepts OrbitalStructure, queries via settlement
Got: Service passes structure where settlement expected

ROOT CAUSE
Service initialize takes OrbitalStructure but stores as @settlement.
create_shipyard_project passes @settlement (structure) as station: on project.
deliver_materials calls station.orbital_construction_projects directly on structure.
spawn_completed_craft docks craft at settlement instead of structure.

PROPOSED FIX
1. Rename initialize parameter to @structure
2. create_shipyard_project passes @structure.settlement as station
3. deliver_materials queries via station.settlement.orbital_construction_projects
4. spawn_completed_craft docks at project.station.structures.first

RISK
Service is used in tug_construction_integration_spec (integration — hands off).
inventory_manager_spec passes station (OrbitalStructure) to deliver_materials
which aligns with Fix 3.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Isolation run — orbital_shipyard:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/construction/orbital_shipyard_service_spec.rb 2>&1 | grep -E "example|failure" | tail -5'
```
Expected: `25 examples, 0 failures`

2. **Isolation run — inventory_manager:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/inventory_manager_spec.rb 2>&1 | grep -E "example|failure" | tail -5'
```

3. **Models suite — confirm baseline:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ 2>&1 | grep -E "example|failure" | tail -3'
```
Expected: `1885 examples, 1 failure, 29 pending`

---

## Acceptance Criteria
- [ ] `orbital_shipyard_service_spec.rb` — 0 failures
- [ ] `inventory_manager_spec.rb` — reduced or 0 failures
- [ ] Models suite — 1885 examples, 1 failure (pre-existing only)
- [ ] No regressions

---

## Stop Conditions — escalate to user immediately if:
- `@structure.settlement` returns nil in tests
- `project.station.structures.first` returns nil
- Fix causes new failures outside these two spec files
- More than one service file needs changing

---

## Commit Instructions
```bash
git add galaxy_game/app/services/construction/orbital_shipyard_service.rb
git commit -m "fix: orbital_shipyard_service — fix structure/settlement naming confusion; query projects via settlement"
git push
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**: `2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.md`

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
