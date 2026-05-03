# TASK: Raw Resource Extraction Pricing — Architecture Design
**Status**: BACKLOG
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-16
**Last Updated**: 2026-04-16

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires economic reasoning about break-even modeling,
integration with existing NpcPriceCalculator, and derivation logic from
existing material data fields.
**Supervision Level**: 🟡 Standard

---

## Context

Harvested raw resources (mined gases, raw ore from asteroids/moons) have
no material purchase cost — the resource itself is free. However the
true cost of extraction includes craft fuel, depreciation, energy, and
risk. Without a floor price model, NpcPriceCalculator has no basis for
valuing these resources and cannot determine whether local extraction is
economically viable vs Earth import.

The Earth Anchor Price (EAP) from `Tier1PriceModeler` serves as the
ceiling — if local extraction break-even exceeds EAP, importing from
Earth is cheaper and local mining doesn't make economic sense.

---

## Problem Statement

**Current**: `NpcPriceCalculator` has no model for raw harvested resources.
It falls back to Earth import cost which doesn't reflect extraction economics.

**Expected**: A break-even cost model that computes the minimum viable
sell price for a harvested resource based on actual mission costs.
This feeds into `cost_based_bid` as the floor price for NPC buyers.

---

## Break-Even Formula

```
floor_price_per_kg =
  (fuel_cost_round_trip +
   craft_depreciation_per_mission +
   energy_cost_during_extraction +
   risk_premium)
  ÷ kg_extracted_per_mission
```

### Components

**fuel_cost_round_trip**
- Fuel consumed × fuel price at origin
- Round trip: outbound + return leg
- Source: craft operational_data fuel consumption rate × distance

**craft_depreciation_per_mission**
- craft.replacement_value ÷ expected_mission_lifetime
- Expected lifetime = total mission hours craft is rated for
- Simple linear depreciation for MVP

**energy_cost_during_extraction**
- energy_kwh_consumed × energy_price_at_location
- Source: extraction unit operational_data energy consumption

**risk_premium**
- Percentage markup on total cost for mission failure probability
- Default: 5% (from economic_parameters.yml)
- AI Manager adjusts based on location hazard rating

**kg_extracted_per_mission**
- extraction_rate_kg_per_hour × mission_duration_hours
- Source: craft extraction unit operational_data

---

## Viability Check

```
If floor_price_per_kg < EAP → local extraction viable
  market price settles between floor and EAP
  NPC buyer bids at floor + margin

If floor_price_per_kg > EAP → import cheaper
  local extraction not economically viable
  NpcPriceCalculator returns nil (won't buy)
  AI Manager does not dispatch miners to this location
```

---

## Integration Point — NpcPriceCalculator

Add private method `calculate_extraction_cost(craft, resource, location)`
Called from `calculate_import_cost` when resource has no Earth purchase cost
or when local extraction is available.

```ruby
# Proposed addition to NpcPriceCalculator
def calculate_extraction_cost(craft, resource_name, location)
  # Returns floor_price_per_kg or nil if insufficient data
end
```

Feeds into existing `cost_based_bid` as the price floor.

---

## economic_parameters.yml Additions Needed

```yaml
extraction_pricing:
  default_risk_premium: 0.05      # 5% markup for mission risk
  depreciation_model: "linear"    # linear | accelerated
  fuel_cost_source: "local_market" # local_market | earth_anchor
```

---

## Material Data Consideration

Raw harvested resources will not have a `purchase_cost` in their JSON
or will have `amount: 0`. This is the signal to use extraction pricing
instead of Earth import pricing.

Flag in material data:
```json
"cost_data": {
  "purchase_cost": {
    "currency": "USD",
    "amount": 0
  },
  "extraction_pricing": true
}
```

This field does not exist yet — flag as data task dependency.

---

## Output — Design Document

Produce a design document covering:

```
BREAK-EVEN MODEL
================
Formula: [confirm or refine above]
Each component: [data source, fallback if missing]
Failure modes: [what happens if craft has no extraction unit data]

INTEGRATION WITH NpcPriceCalculator
=====================================
Method signature: [exact]
Call site: [where in existing code]
Return value: [floor price or nil]
Interaction with cost_based_bid: [describe]

VIABILITY CHECK
===============
Logic: [exact conditional]
What NpcPriceCalculator returns when not viable: [nil? 0? raise?]
AI Manager hook: [how AI Manager learns location is not viable]

ECONOMIC PARAMETERS
===================
New fields needed: [list with defaults]
Where defined: [economic_parameters.yml section]

MATERIAL DATA
=============
Signal for extraction-priced resources: [field name and value]
Which existing materials qualify: [list]

FOLLOW-UP TASKS
===============
[list implementation tasks with scope and agent tier]
```

---

## Acceptance Criteria
- [ ] Break-even formula fully specified with data sources for each component
- [ ] Integration point in NpcPriceCalculator described exactly
- [ ] Viability check logic defined
- [ ] economic_parameters.yml additions listed
- [ ] Material data signal defined
- [ ] No code changes made

## Dependencies
**Blocked by**: None
**Blocks**: DockingTransactionService implementation
**Related**: 2026-04-16-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE.md
