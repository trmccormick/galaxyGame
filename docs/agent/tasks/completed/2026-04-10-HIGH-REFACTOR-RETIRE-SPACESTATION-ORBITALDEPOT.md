# TASK: Retire Settlement::SpaceStation and Settlement::OrbitalDepot
**Status**: ACTIVE
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Mechanical rewiring — class references, factory updates,
spec updates. All call sites are explicitly listed. No architectural inference
required.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Settlement::SpaceStation` and `Settlement::OrbitalDepot` conflate settlement
and structure concerns. Both are being retired in favor of:

- `Settlement::OrbitalSettlement` — pure settlement, economy/population/jurisdiction
- `Structures::OrbitalStructure` — physical structure, shell/docking/atmosphere

Both replacement models already exist and are fully implemented. This task
rewires all call sites and retires the old models.

`app/models/orbital_depot.rb` is a legacy PORO that predates the ActiveRecord
model — it also gets deleted.

`Settlement::OrbitalDepot`'s gas methods (`add_gas`, `remove_gas`, `get_gas`,
`has_gas?`) are stubs for a future market system. They are deleted here — a
proper market order system is designed in a separate task.

---

## Problem Statement

**Current behavior**: `SpaceStation` and `OrbitalDepot` are active models
with call sites across the codebase. They include structural concerns
(`Structures::Shell`, `Docking`) that belong on `OrbitalStructure` not
on a settlement model.

**Expected behavior**: All orbital settlements use `Settlement::OrbitalSettlement`.
All orbital structures use `Structures::OrbitalStructure`. The old models
are retired but NOT deleted — they are emptied and marked as retired so
git history is preserved.

---

## Key Architectural Decision
`Settlement::OrbitalDepot` is NOT a special kind of settlement. A depot is
an `OrbitalSettlement` that owns one or more `OrbitalStructure` instances
fitted with gas storage units via blueprint. The blueprint and operational
data define what kind of installation it is — not the class name.

---

## Files to Retire (empty and mark — do NOT delete)

### `app/models/settlement/space_station.rb`
Replace entire contents with:
```ruby
# app/models/settlement/space_station.rb
# RETIRED 2026-04-10
# Use Settlement::OrbitalSettlement with Structures::OrbitalStructure instead.
# This file is kept for git history only. Do not use this class.
module Settlement
  class SpaceStation < BaseSettlement
  end
end
```

### `app/models/settlement/orbital_depot.rb`
Replace entire contents with:
```ruby
# app/models/settlement/orbital_depot.rb
# RETIRED 2026-04-10
# Use Settlement::OrbitalSettlement with Structures::OrbitalStructure instead.
# Gas storage operations belong to the market order system (separate task).
# This file is kept for git history only. Do not use this class.
module Settlement
  class OrbitalDepot < BaseSettlement
  end
end
```

### `app/models/orbital_depot.rb`
Replace entire contents with:
```ruby
# app/models/orbital_depot.rb
# RETIRED 2026-04-10 — legacy PORO replaced by Settlement::OrbitalSettlement
# Kept for git history only. Do not use this class.
class OrbitalDepot
end
```

---

## Files to Modify

### 1. `app/models/settlement/base_settlement.rb` line 70
**Find:**
```ruby
def orbital?
  is_a?(Settlement::SpaceStation) || settlement_type.to_s == 'station'
end
```
**Replace with:**
```ruby
def orbital?
  is_a?(Settlement::OrbitalSettlement) || settlement_type.to_s == 'station'
end
```

### 2. `app/models/scheduled_departure.rb` line 4
**Find:**
```ruby
belongs_to :space_station, class_name: 'Settlement::SpaceStation'
```
**Replace with:**
```ruby
belongs_to :space_station, class_name: 'Settlement::OrbitalSettlement'
```

### 3. `app/models/scheduled_arrival.rb` line 4
**Find:**
```ruby
belongs_to :space_station, class_name: 'Settlement::SpaceStation'
```
**Replace with:**
```ruby
belongs_to :space_station, class_name: 'Settlement::OrbitalSettlement'
```

### 4. `app/services/ai_manager/depot_adapter.rb`
This file wraps both PORO and AR depot. Rewrite to use
`Settlement::OrbitalSettlement` only — the PORO path is retired.

Replace the `create_depot`, `use_activerecord_depot?`, `create_ar_depot`,
and `create_poro_depot` methods:

```ruby
def self.create_depot(world_key, world)
  depot = Settlement::OrbitalSettlement.find_or_create_by!(
    name: "#{world.name} Orbital Depot"
  ) do |d|
    d.settlement_type = 'station'
    d.current_population = 0
    d.operational_data = {
      'world_key' => world_key.to_s,
      'purpose' => 'terraforming_gas_storage'
    }
  end

  unless depot.location
    Location::CelestialLocation.create!(
      celestial_body: world,
      latitude: 0.0,
      longitude: 0.0,
      altitude: calculate_orbital_altitude(world),
      locationable: depot
    )
  end

  depot
end
```

Remove `DepotWrapper` class entirely — it was bridging PORO and AR.
Replace all `DepotWrapper` call sites in `terraforming_manager.rb` with
direct `Settlement::OrbitalSettlement` calls (see below).

Replace gas method calls in `DepotWrapper` with direct inventory queries:
- `add_gas(gas_name, amount)` → `depot.inventory.add_item(gas_name, amount, depot)`
- `remove_gas(gas_name, amount)` → `depot.inventory.remove_item(gas_name, amount, depot)`
- `get_gas(gas_name)` → `depot.inventory.items.where(name: gas_name).sum(:amount)`
- `has_gas?(gas_name, amount)` → `depot.inventory.items.where(name: gas_name).sum(:amount) >= amount`
- `total_mass` → `depot.inventory.items.sum(:amount)`

### 5. `app/services/ai_manager/terraforming_manager.rb`
**Find:** `@orbital_depots[key] = OrbitalDepot.new`
**Replace with:** `@orbital_depots[key] = AIManager::DepotAdapter.create_depot(key, world)`

Replace all `depot.add_gas(...)`, `depot.remove_gas(...)`, `depot.get_gas(...)`
calls with direct inventory calls as specified above.

### 6. `app/services/star_sim/expansion_manager_service.rb`
**Lines 30, 74, 87** — Replace `Settlement::OrbitalDepot.create!` with
`Settlement::OrbitalSettlement.create!`

---

## Factories to Update

### `spec/factories/settlement/space_station.rb`
- Change `factory :space_station, class: 'Settlement::SpaceStation'` →
  `class: 'Settlement::OrbitalSettlement'`
- Change `factory :orbital_depot, class: 'Settlement::SpaceStation'` →
  `class: 'Settlement::OrbitalSettlement'`
- Keep factory names identical — `:space_station` and `:orbital_depot` —
  so existing specs don't break

---

## Specs to Update

### `spec/models/settlement/space_station_spec.rb`
- Update `RSpec.describe Settlement::SpaceStation` →
  `RSpec.describe Settlement::OrbitalSettlement`
- Remove any examples that test structural behavior (shell, docking, atmosphere)
  — those belong in `orbital_structure_spec.rb`
- Keep examples that test settlement behavior (population, economy, inventory)
- Line 425 (known refactor blocker) — assess whether it still fails after
  class rename. Report result, do not force green.
- Line 727 — update `Settlement::OrbitalDepot.create!` →
  `Settlement::OrbitalSettlement.create!`

### `spec/models/settlement/orbital_depot_spec.rb`
- Update `RSpec.describe Settlement::OrbitalDepot` →
  `RSpec.describe Settlement::OrbitalSettlement`
- Remove all gas method examples (`add_gas`, `remove_gas`, `get_gas`,
  `has_gas?`, `total_gas_mass`, `gas_inventory_summary`) — these methods
  are deleted, market system is a separate task
- Keep settlement behavior examples

---

## Synthesis Report Format

```
RETIRED FILES
space_station.rb: [emptied yes/no]
orbital_depot.rb (settlement): [emptied yes/no]
orbital_depot.rb (PORO): [emptied yes/no]

CALL SITES UPDATED
base_settlement.rb orbital?: [done yes/no]
scheduled_departure.rb: [done yes/no]
scheduled_arrival.rb: [done yes/no]
depot_adapter.rb: [done yes/no]
terraforming_manager.rb: [done yes/no]
expansion_manager_service.rb: [done yes/no]

FACTORIES UPDATED
space_station factory: [done yes/no]
orbital_depot factory: [done yes/no]

SPECS UPDATED
space_station_spec.rb: [done yes/no]
orbital_depot_spec.rb: [done yes/no]

RISK
[any unexpected references found]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

### 1. Settlement models in isolation
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/ 2>&1 | tail -10'
```
Expected: same failure count as pre-existing. `space_station_spec.rb:425`
remains the only known blocker. Report any new failures immediately.

### 2. Structure suite — confirm no regressions
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/ 2>&1 | tail -5'
```
Expected: 2 known false positives only.

### 3. AI Manager services
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/ 2>&1 | tail -10'
```
Report summary line and any new failures.

### 4. Full suite — redirect, never stream
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```
Report final summary line only + any failures not in pre-existing 25.

---

## Acceptance Criteria
- [ ] `SpaceStation` emptied and marked retired
- [ ] `OrbitalDepot` (settlement) emptied and marked retired
- [ ] `OrbitalDepot` (PORO) emptied and marked retired
- [ ] `base_settlement.rb#orbital?` updated
- [ ] `scheduled_departure.rb` and `scheduled_arrival.rb` updated
- [ ] `depot_adapter.rb` rewired to `OrbitalSettlement`
- [ ] `terraforming_manager.rb` gas calls replaced with inventory calls
- [ ] `expansion_manager_service.rb` updated
- [ ] Factories updated — names preserved
- [ ] `space_station_spec.rb` updated to describe `OrbitalSettlement`
- [ ] `orbital_depot_spec.rb` updated to describe `OrbitalSettlement`
- [ ] No new failures beyond pre-existing 25

---

## Stop Conditions — escalate immediately if:
- Any spec outside the listed files introduces a new failure
- `space_station_spec.rb:425` failure changes in nature (different error)
- `terraforming_manager.rb` gas calls cannot be replaced with inventory
  calls because inventory is nil or not initialized on depot
- `DepotWrapper` has call sites outside `terraforming_manager.rb` —
  list them all before proceeding

---

## Commit Instructions
```bash
git add app/models/settlement/space_station.rb \
        app/models/settlement/orbital_depot.rb \
        app/models/orbital_depot.rb \
        app/models/settlement/base_settlement.rb \
        app/models/scheduled_departure.rb \
        app/models/scheduled_arrival.rb \
        app/services/ai_manager/depot_adapter.rb \
        app/services/ai_manager/terraforming_manager.rb \
        app/services/star_sim/expansion_manager_service.rb \
        spec/factories/settlement/space_station.rb \
        spec/models/settlement/space_station_spec.rb \
        spec/models/settlement/orbital_depot_spec.rb
git commit -m "refactor: retire SpaceStation and OrbitalDepot — rewire to OrbitalSettlement"
git push
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**:
- `2026-04-10-HIGH-ARCHITECTURE-AI-MANAGER-FULL-SPACE-STATION-CLEANUP.md`
- `2026-04-10-MEDIUM-ARCHITECTURE-ORBITAL-SETTLEMENT-LOCATION.md`
**Related tasks**:
- `2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md` — this task
  is the first phase of that refactor

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
