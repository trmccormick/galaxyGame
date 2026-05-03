# TASK: Docking Transaction Service
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-04-16
**Last Updated**: 2026-04-16

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Multi-file service implementation, fully specified,
requires careful ownership and routing logic.
**Supervision Level**: 🔴 Watched carefully

---

## Context

When a craft docks at a structure or surface settlement spaceport, it
needs a single entry point to buy and sell resources. The service must:
- Determine the physical inventory boundary (structure or spaceport)
- Check ownership to route to bypass or market path
- Enforce storage capacity before accepting sell orders
- Apply surface outdoor storage rules for surface settlements
- Route to `Marketplace#place_order` for market path transactions

This service is the unified docking transaction layer for both surface
and orbital docking points.

---

## Core Business Rules

```
Rule 1 — Docking is always free. No fee on arrival.

Rule 2 — Same owner bypass:
  craft.owner == docking_point.owner
  → direct inventory transfer
  → no broker fee, no transaction fee
  → energy/time cost recorded
  → optional internal accounting log

Rule 3 — Different owner market path:
  craft.owner != docking_point.owner
  → broker fee charged on order placement (goes to docking_point.owner)
  → transaction fee charged on fill (goes to docking_point.owner)
  → inventory moves only on fill
  → GCC settles via Financial::Account

Rule 4 — Storage capacity enforced:
  Orbital structure → hard limit from operational_data
  Surface pressurized → hard limit
  Surface outdoor → unlimited for outdoor-eligible materials only

Rule 5 — Outdoor storage eligibility:
  material.state_at_stp == 'solid' AND
  material.storage.stability == 'stable' AND
  material.import_config.transport_category NOT IN
    ['hazardous', 'cryogenic', 'biological', 'radioactive']
  → outdoor storage eligible
  All others → must be enclosed
```

---

## Service Interface

```ruby
# app/services/market/docking_transaction_service.rb
module Market
  class DockingTransactionService

    # @param craft [Craft::BaseCraft] the docking craft
    # @param docking_point [Structures::BaseStructure | Settlement::BaseSettlement]
    def initialize(craft, docking_point)
    end

    # Place a sell order or bypass transfer
    # @param resource_name [String]
    # @param amount [Float] kg
    # @param price [Float] GCC/kg — nil for market order
    # @param duration_days [Integer] 1, 3, 7, 30, 90
    def sell(resource_name, amount, price: nil, duration_days: 7)
    end

    # Place a buy order or bypass transfer
    # @param resource_name [String]
    # @param amount [Float] kg
    # @param price [Float] GCC/kg — nil for market order
    # @param duration_days [Integer] 1, 3, 7, 30, 90
    def buy(resource_name, amount, price: nil, duration_days: 7)
    end

    private

    def same_owner?
      craft.owner == docking_point.owner
    end

    def marketplace
      # Resolve marketplace from docking point
      # Structure → docking_point.marketplace
      # Settlement → docking_point.marketplace
    end

    def check_storage_capacity(resource_name, amount)
      # Returns true/false
      # Applies outdoor storage rules for surface settlements
    end

    def outdoor_eligible?(resource_name)
      # Derives from material data fields
    end

    def apply_bypass_transfer(resource_name, amount, direction)
      # direction: :in or :out
      # Moves inventory directly, records energy cost
    end
  end
end
```

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `app/services/market/docking_transaction_service.rb` | New service — create this file |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/market/marketplace.rb` | place_order interface |
| `app/models/market/npc_price_calculator.rb` | Pricing logic |
| `app/models/structures/base_structure.rb` | Inventory and owner |
| `app/models/settlement/base_settlement.rb` | Settlement marketplace |
| `config/economic_parameters.yml` | Default fees, order durations |

---

## Docking Point Resolution

```ruby
def resolve_inventory_boundary
  # Structure → use structure inventory directly
  if docking_point.is_a?(Structures::BaseStructure)
    docking_point
  # Settlement → use settlement spaceport/inventory
  elsif docking_point.is_a?(Settlement::BaseSettlement)
    docking_point
  end
end

def resolve_marketplace
  if docking_point.is_a?(Structures::BaseStructure)
    docking_point.marketplace ||
      docking_point.settlement&.marketplace
  elsif docking_point.is_a?(Settlement::BaseSettlement)
    docking_point.marketplace
  end
end
```

---

## Fee Resolution

```ruby
def broker_fee_rate
  docking_point.broker_fee_rate ||
    EconomicConfig.market('default_broker_fee')
end

def transaction_fee_rate
  docking_point.transaction_fee_rate ||
    EconomicConfig.market('default_transaction_fee')
end
```

Note: `broker_fee_rate` and `transaction_fee_rate` fields on
`Marketplace` do not exist yet — add them as part of this task
or flag as follow-up.

---

## Storage Capacity Check

```ruby
def check_storage_capacity(resource_name, amount)
  # Surface settlement + outdoor eligible material → always true
  if surface_settlement? && outdoor_eligible?(resource_name)
    return true
  end

  # Otherwise check operational_data capacity
  available = docking_point.available_storage(resource_name)
  available >= amount
end

def outdoor_eligible?(resource_name)
  material = load_material(resource_name)
  return false unless material

  material['state_at_stp'] == 'solid' &&
    material.dig('storage', 'stability') == 'stable' &&
    !%w[hazardous cryogenic biological radioactive].include?(
      material.dig('cost_data', 'import_config', 'transport_category')
    )
end
```

---

## Order Duration Validation

```ruby
VALID_DURATIONS = [1, 3, 7, 30, 90].freeze

def validate_duration(duration_days)
  raise ArgumentError, "Invalid duration" unless
    VALID_DURATIONS.include?(duration_days)
end
```

---

## Synthesis Report Format

```
THE FAILURE
Spec: none — new service
Error: none
Expected: DockingTransactionService routes correctly
Got: service does not exist

ROOT CAUSE
[describe gap]

PROPOSED IMPLEMENTATION
[confirm interface and routing logic]

RISK
[any existing code that touches inventory directly that this replaces]

READY TO BUILD? — waiting for approval
```

---

## Testing Sequence

1. Isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/market/docking_transaction_service_spec.rb'
```

2. Market services:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/market/'
```

3. Full models suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ > /home/galaxy_game/log/rspec_models_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] Same-owner bypass routes correctly — no fees, direct transfer
- [ ] Market path routes to Marketplace#place_order
- [ ] Storage capacity enforced before sell order placed
- [ ] Outdoor storage rule applied for surface settlements
- [ ] Order duration validated against VALID_DURATIONS
- [ ] Broker fee and transaction fee resolved from owner or default
- [ ] Spec file created with coverage of all rules
- [ ] No regressions in models suite

## Stop Conditions
- `available_storage` method missing on structure or settlement — flag
- `Marketplace#place_order` interface changed — flag before proceeding
- Fee fields not on Marketplace — add migration or flag as follow-up
- Same-owner bypass causes inventory to go negative — stop immediately

## Commit Instructions
```bash
git add galaxy_game/app/services/market/docking_transaction_service.rb
git add galaxy_game/spec/services/market/docking_transaction_service_spec.rb
git commit -m "feature: docking_transaction_service — ownership routing, bypass, market path, storage capacity, outdoor storage rules"
git push
```

## Dependencies
**Blocked by**: 2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.md
**Blocked by**: 2026-04-16-MEDIUM-DATA-ECONOMIC-PARAMETERS-MARKET-FEES.md
**Blocks**: All gas transfer implementation tasks
**Related**: 2026-04-16-HIGH-ARCHITECTURE-RAW-RESOURCE-EXTRACTION-PRICING.md
