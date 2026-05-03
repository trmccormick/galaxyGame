# TASK: Decouple OrbitalSettlement from BaseSettlement — Extract SettlementCore
**Status**: ACTIVE
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-12
**Last Updated**: 2026-04-12

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires architectural judgment about shared boundary
between surface and orbital settlement models. Several judgment calls
in the SettlementCore extraction that a 0x agent will get wrong without
explicit guidance on every edge case.
**Supervision Level**: 🟡 Standard

---

## Context

`Settlement::OrbitalSettlement` was recently created to replace the
retired `Settlement::SpaceStation` and `Settlement::OrbitalDepot` models.
It currently inherits from `Settlement::BaseSettlement`, which was
designed for surface settlements — it carries surface-specific concerns
(life support per-person rates, surface storage, docking at settlement
level, population-type adjustment callbacks) that are wrong for orbital
settlements.

`OrbitalSettlement` must be decoupled from `BaseSettlement`. The shared
behaviour (account, GCC, structures, missions, owner, colony) must be
extracted into a `Settlement::SettlementCore` concern that both models
include independently.

**Key constraint**: `BaseSettlement` must not change behaviour. All
existing `BaseSettlement` specs must continue to pass without
modification.

**Key constraint**: `OrbitalSettlement` is new — no legacy service layer
depends on it yet. This is the right moment to fix the inheritance before
anything is built on top of it.

---

## Problem Statement

**Current behavior**: `OrbitalSettlement < BaseSettlement` inherits
surface-specific callbacks, concerns, and associations that are wrong
for orbital contexts:
- `after_update :adjust_settlement_type_based_on_population` fires on
  orbital settlements, forcing type to base/outpost/settlement/city
  based on population — incorrect, orbital settlements are always station
- `after_initialize :set_life_support_defaults` sets food/water/energy
  per-person rates on orbital settlements — life support is per-structure
  not per-settlement for orbital
- `has_one :location` creates a settlement-level CelestialLocation —
  orbital settlements get location from their structures, not directly
- `has_many :docked_crafts` — crafts dock at structures, not the
  settlement
- `has_one :marketplace` — belongs at structure level for orbital
- `include LifeSupport`, `EnergyManagement`, `HasUnitStorage`,
  `CryptocurrencyMining` — all structure-level concerns for orbital

**Expected behavior**: `OrbitalSettlement < ApplicationRecord` includes
only `SettlementCore` (shared) plus orbital-specific logic. Surface
behaviour stays entirely in `BaseSettlement`.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Action |
|---|---|---|
| `app/models/concerns/settlement_core.rb` | NEW — shared concern | Create |
| `app/models/settlement/orbital_settlement.rb` | Orbital model | Rewrite |
| `app/models/settlement/base_settlement.rb` | Surface model | Include SettlementCore, remove duplicated code only |
| `spec/models/settlement/orbital_settlement_spec.rb` | Orbital spec | Update/extend |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/settlement/base_settlement.rb` | Source of truth for shared boundary |
| `db/schema.rb` | Confirm settlements table columns |
| `spec/models/settlement/base_settlement_spec.rb` | Must still pass unchanged |
| `spec/factories/settlement/orbital_settlement.rb` | Factory structure |

### Migration
- [ ] No migration needed — schema unchanged

---

## SettlementCore — Exact Boundary

Extract ONLY the following into `SettlementCore`. Do not add anything
not listed here without flagging it first.

```ruby
# app/models/concerns/settlement_core.rb
module Settlement
  module SettlementCore
    extend ActiveSupport::Concern

    included do
      include GameConstants
      include FinancialManagement

      belongs_to :owner, polymorphic: true, optional: true
      belongs_to :colony,
                 class_name: 'Colony',
                 foreign_key: 'colony_id',
                 optional: true

      has_one :account,
              as: :accountable,
              class_name: 'Financial::Account',
              dependent: :destroy
      has_many :accounts,
               as: :accountable,
               class_name: 'Financial::Account'
      has_many :structures,
               class_name: 'Structures::BaseStructure',
               foreign_key: 'settlement_id'
      has_many :missions,
               class_name: 'Mission',
               foreign_key: 'settlement_id'

      validates :name, presence: true
      validates :current_population,
                numericality: {
                  only_integer: true,
                  greater_than_or_equal_to: 0
                }

      after_create :create_gcc_account
    end

    def orbital?
      is_a?(Settlement::OrbitalSettlement)
    end

    def gcc_account
      accounts.find_or_create_by(
        currency: Financial::Currency.find_by(symbol: 'GCC')
      )
    end

    def age_in_days
      ((Time.current - created_at) / 1.day).to_i
    end

    def accessible_by?(player)
      owner == player
    end

    private

    def create_gcc_account
      default_currency = Financial::Currency.find_by(
        symbol: 'GCC', is_system_currency: true
      ) || Financial::Currency.first
      return unless default_currency
      return if Financial::Account.exists?(
        accountable: self, currency: default_currency
      )
      create_account!(currency: default_currency)
    end
  end
end
```

---

## OrbitalSettlement — Target State

```ruby
# app/models/settlement/orbital_settlement.rb
module Settlement
  class OrbitalSettlement < ApplicationRecord
    include SettlementCore

    # Location delegates to first deployed structure.
    # OrbitalSettlement is a constellation of structures —
    # each structure owns its own CelestialLocation.
    # Convention: one structure per OrbitalSettlement until
    # multi-structure routing is implemented.
    def location
      structures.first&.celestial_location
    end

    def celestial_body
      structures.joins(:celestial_location)
                .first&.celestial_location&.celestial_body
    end

    def total_storage_capacity
      structures.sum(&:total_storage_capacity)
    end

    # Population capacity aggregated from habitat units
    # installed across all structures.
    def population_capacity
      structures.sum(&:habitat_capacity)
    end

    def available_capacity
      population_capacity - current_population.to_i
    end

    def has_capacity_for?(additional_population)
      available_capacity >= additional_population
    end

    # Hook for AI-driven expansion — creates a planned structure record.
    def add_specialized_structure!(blueprint_id)
      structures.create!(
        identifier: blueprint_id,
        shell_status: 'planned'
      )
    end
  end
end
```

---

## BaseSettlement — Changes Required

`BaseSettlement` must:
1. Add `include SettlementCore` at the top of includes
2. Remove the methods and callbacks now provided by `SettlementCore`:
   - `orbital?` — now in SettlementCore. Keep the `settlement_type == 'station'`
     fallback: `is_a?(Settlement::OrbitalSettlement) || settlement_type.to_s == 'station'`
   - `gcc_account` — now in SettlementCore
   - `age_in_days` — now in SettlementCore
   - `accessible_by?` — now in SettlementCore
   - `create_gcc_account` private method — now in SettlementCore
3. Keep `create_account_and_inventory` — it does more than just GCC account,
   it also creates the inventory. Call `create_gcc_account` from within it
   rather than duplicating.
4. Keep ALL other surface-specific code untouched.

**Do not remove anything from BaseSettlement that is not explicitly
listed above.**

---

## Implementation Steps

### Step 1 — Read files
```bash
cat app/models/settlement/base_settlement.rb
cat app/models/settlement/orbital_settlement.rb
cat db/schema.rb | grep -A 30 "create_table \"settlements\""
cat spec/factories/settlement/orbital_settlement.rb
```

### Step 2 — Create SettlementCore concern
Create `app/models/concerns/settlement_core.rb` using the exact
code in the SettlementCore boundary section above.

### Step 3 — Rewrite OrbitalSettlement
Replace `app/models/settlement/orbital_settlement.rb` with the
target state above.

### Step 4 — Update BaseSettlement
Add `include SettlementCore` to BaseSettlement includes.
Remove only the methods listed in the BaseSettlement changes section.
Preserve `orbital?` with the `settlement_type == 'station'` fallback.

### Step 5 — Run BaseSettlement specs in isolation
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/base_settlement_spec.rb'
```
Expected: 0 failures. If any failures, stop and report — do not proceed.

### Step 6 — Run OrbitalSettlement specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/orbital_settlement_spec.rb'
```
Expected: 0 failures.

### Step 7 — Run full settlement specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/'
```
Expected: 0 failures.

### Step 8 — Run models suite
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ > /home/galaxy_game/log/rspec_models_$(date +%s).log 2>&1'
```
Report final summary line only.

---

## Synthesis Report Format

Before touching any file, produce this report and STOP:

```
SHARED BOUNDARY CONFIRMED
Methods moving to SettlementCore: [list]
Methods staying in BaseSettlement only: [list]
Any unexpected dependencies found: [describe or NONE]

ORBITAL_SETTLEMENT TARGET
Inherits from: ApplicationRecord
Includes: SettlementCore
Methods: [list]
Any factory changes needed: [yes/no — describe]

RISK ASSESSMENT
BaseSettlement regression risk: [low/medium/high — why]
Any stop conditions triggered: [yes/no]

READY TO APPLY? — waiting for approval
```

---

## Stop Conditions — escalate immediately if:
- `BaseSettlement` specs fail after adding `include SettlementCore`
- Any model outside `settlement/` does `OrbitalSettlement.superclass`
  or type-checks against `BaseSettlement` in a way that breaks
- `SettlementCore` cannot be included in both models due to
  association name conflicts
- Schema does not have a `settlements` table shared by both models
  (would mean separate tables, different approach needed)
- `create_account_and_inventory` in BaseSettlement depends on methods
  that would move to SettlementCore in a circular way

---

## Commit Instructions
```bash
git add app/models/concerns/settlement_core.rb
git add app/models/settlement/orbital_settlement.rb
git add app/models/settlement/base_settlement.rb
git commit -m "architecture: extract SettlementCore concern — decouple OrbitalSettlement from BaseSettlement"
git push
```

---

## Documentation
- [ ] Flag for future task: `BaseSettlement#establish_from_starship` is
  incorrect — starship deployment is no longer the pattern. Settlements
  are established by craft in precursor or cycler missions. Do not fix
  in this task, add to backlog.
- [ ] Flag for future task: `BaseSettlement#calculate_life_support_requirements`
  is defined three times in the same file — pre-existing bug, add to backlog.

---

## Dependencies
**Blocked by**: nothing
**Blocks**:
- `2026-04-10-MEDIUM-ARCHITECTURE-ORBITAL-SETTLEMENT-LOCATION.md`
- `2026-04-10-HIGH-ARCHITECTURE-ORBITAL-MARKET-SYSTEM.md`
**Related tasks**:
- `2026-04-10-MEDIUM-REFACTOR-HARDCODED-SOL-WORLD-NAMES-DATA-DRIVEN.md`

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
