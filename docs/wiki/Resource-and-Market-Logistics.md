# Resource & Market Logistics — Technical Specification

> **How to use this template:** This page defines the canonical rules for how resources are priced, traded, and managed across Galaxy Game's market layer. It serves two audiences simultaneously: player-facing documentation explaining how market mechanics work, and developer-facing specification governing how `Market::NpcPriceCalculator`, `Market::TradeExecutionService`, and related services must behave.
>
> **Verify-against-source flags:** Sections marked `[VERIFY AGAINST SOURCE]` contain mechanics specified from design intent but not yet confirmed against the `NpcPriceCalculator` source file. These must be validated during next week's testing phase before this page is treated as fully authoritative.
>
> **Authoritative constants:** All numeric thresholds reference `config/initializers/game_constants.rb`. If a discrepancy exists between this page and the initializer, the initializer is authoritative.

---

## 1. Currency & Pricing Foundation

### The GCC / USD Bootstrap Peg

Galaxy Game operates with two currency systems during the bootstrap phase:

**USD (United States Dollars):** Used exclusively by Earth-side corporations and for Earth-origin imports. Terrestrial entities do not hold or trade in GCC. Earth-side corporate contracts, import invoices, and transportation costs are denominated in USD.

**GCC (Galactic Coin Credit):** The off-world transaction currency. All player accounts, colony budgets, courier contracts, and market orders are denominated in GCC.

**The Bootstrap Peg:**

```
GCC_TO_USD_INITIAL = 1.0
1 USD = 1 GCC  (bootstrap phase)
```

This 1:1 parity is enforced by `GameConstants::GCC_TO_USD_INITIAL`. No service may hardcode a numeric conversion rate — all references must use this constant or its designated successor.

**Earth Import Cost Anchor:**

```
INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00 USD/kg
```

This is the baseline cost ceiling for any resource that must be sourced from Earth. Local production and off-world harvesting are economically justified when their effective cost per kg falls below this ceiling. The `NpcPriceCalculator` uses this as the reference ceiling for Earth-import-dependent resources.

**Decoupling:** The fixed peg remains active until off-world market volume reaches a design-specified threshold. The decoupling mechanism and volume trigger are `[PENDING IMPLEMENTATION]` — do not treat GCC as a floating currency in any current service logic.

---

## 2. NPC Price Calculator

### Overview

`Market::NpcPriceCalculator` is the central price oracle for all NPC-side market interactions. It provides two price directions:

| Method | Direction | Used By |
|---|---|---|
| `.calculate_ask(settlement, resource, supply:)` | NPC selling to player | `Market::Marketplace.get_price`, `Market::Order#price_per_unit` (sell orders) |
| `.calculate_bid(settlement, resource, demand:)` | NPC buying from player | `Market::Marketplace#find_matching_orders`, `Market::Order#price_per_unit` (buy orders) |

Both methods take the settlement as context because pricing is settlement-relative — a resource's value depends on local supply scarcity, production capacity, and import dependency at the specific colony.

### Base Pricing Rules

**Rule 1 — Earth Import Ceiling.** For any resource that has no local production source at the settlement, the NPC ask price anchors to `INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00 USD/kg` converted at the current GCC peg. At `GCC_TO_USD_INITIAL = 1.0`, this means 1320.00 GCC/kg is the ceiling for Earth-import-dependent resources. `[VERIFY AGAINST SOURCE — confirm calculator uses this constant as ceiling]`

**Rule 2 — Local Production Override.** When a settlement has active local production facilities for a resource, the calculator switches from Earth import pricing to a locally-derived cost model. The local cost is computed from facility operational costs, energy consumption, and throughput capacity — not from the Earth import baseline. `[VERIFY AGAINST SOURCE — confirm local facility detection logic and cost model]`

Example: A settlement with an active `water_mining` facility will have water priced based on local extraction costs, not Earth import rates. The calculator detects the presence of `water_mining` (or equivalent facility type) and routes to local pricing. `[VERIFY AGAINST SOURCE — confirm `water_mining` as the facility key used in the check]`

**Rule 3 — Scarcity Premium.** When local supply is critically low, the NPC ask price scales upward from the base cost. Conversely, the NPC bid price scales downward when supply is abundant. The scarcity/abundance scaling is applied by the calculator before the warehouse cap check. `[VERIFY AGAINST SOURCE — confirm scarcity scaling exists and document the formula]`

### Pricing Formula Structure

`[VERIFY AGAINST SOURCE — fill in from NpcPriceCalculator source once available]`

The expected structure based on design intent:

```
calculate_ask(settlement, resource, supply:)
  1. Check for local production facility → use local cost model if present
  2. Fall back to Earth import ceiling (INITIAL_TRANSPORTATION_COST_PER_KG)
  3. Apply scarcity premium if supply is critically low
  4. Return final ask price in GCC

calculate_bid(settlement, resource, demand:)
  1. Check for local production facility → use local cost model if present
  2. Apply abundance discount if settlement supply is high
  3. Apply warehouse cap check → return 0 if settlement inventory exceeds 0.80 threshold
  4. Return final bid price in GCC, or 0 if NPC refuses to buy
```

---

## 3. Warehouse Constraints & the 0.80 Inventory Cap

### The NPC Refusal Threshold

NPCs will not purchase a resource from a player if the settlement's current inventory of that resource already exceeds **80% of warehouse capacity** for that resource type.

```
NPC_INVENTORY_EXCESS_CAP = 0.80
```

When `current_inventory / warehouse_capacity >= 0.80`, `NpcPriceCalculator.calculate_bid` returns `0`. A bid price of `0` causes `Market::Marketplace#find_matching_orders` to return an empty array, and no trade executes.

`[VERIFY AGAINST SOURCE — confirm the 0.80 threshold constant name and that calculate_bid returns 0 rather than raising]`

**Gameplay implication:** Players attempting to sell into a saturated market receive no NPC buy offer. The order is placed but finds no match and remains open until it expires (24 hours after creation, per `Market::Order#expires_at`). Players should monitor settlement inventory levels before committing large sell orders.

**AI Manager implication:** The `AutonomousConstructionManager` must check warehouse capacity before posting resource procurement orders through the market. Procurement orders for resources already at the 0.80 cap will silently fail to match. `[PENDING — AI Manager ↔ Market integration not yet implemented; this check must be added when that integration is built]`

### Warehouse Capacity Reference

`[VERIFY AGAINST SOURCE — document the warehouse capacity model and which model/service owns it]`

Warehouse capacity is settlement-relative and resource-type-relative. Known related constants from `GameConstants`:

```ruby
STORAGE_WORKERS_RATIO = 0.1       # 10% of population allocated to storage
STORAGE_CAPACITY_PER_WORKER = 1000 # kg per storage worker
```

Effective storage capacity for a settlement with population N:
```
storage_workers = N * STORAGE_WORKERS_RATIO
max_capacity_kg = storage_workers * STORAGE_CAPACITY_PER_WORKER
npc_refuses_to_buy_at = max_capacity_kg * 0.80
```

Example — 1,000-person colony:
- Storage workers: 100
- Max capacity: 100,000 kg
- NPC refusal threshold: 80,000 kg of any single resource

---

## 4. Local Manufacturing Override

### When Local Production Replaces Earth Import Pricing

The `NpcPriceCalculator` checks for the presence of active local production facilities before falling back to Earth import pricing. If a qualifying facility is detected at the settlement, the locally-derived cost model is used instead of `INITIAL_TRANSPORTATION_COST_PER_KG`.

`[VERIFY AGAINST SOURCE — confirm the full list of facility types and their resource mappings]`

**Known facility-to-resource mappings (design intent — verify against source):**

| Facility Type | Resource Produced | Pricing Switch |
|---|---|---|
| `water_mining` | Water / LOX (electrolytic) | Local extraction cost replaces Earth import ceiling |
| `atmospheric_processor` | O2, N2 (separated) | Local processing cost replaces Earth import ceiling |
| `solar_array` / `reactor` | Energy | Local generation cost replaces Earth import ceiling |
| `regolith_processor` | Construction materials | Local processing cost replaces Earth import ceiling |

**Override logic:** If the settlement has an active facility of the matching type, the calculator computes:
```
local_cost = facility.operational_cost_per_unit + facility.energy_cost_per_unit
```
And prices from this local cost rather than the Earth import ceiling. `[VERIFY AGAINST SOURCE — confirm cost model fields]`

### Implication for the Bootstrap Phase

During the Sol system bootstrap (Luna Pattern), the L1 orbital depot and moon-based facilities are the first local production sources. Until those facilities are online, all resources price at the Earth import ceiling. The economic incentive to build local production is therefore strongest in Phase 1 and decreases as local capacity grows — this is the intended pressure that drives the settlement progression arc.

---

## 5. Order Lifecycle Reference

*For full detail see `docs/wiki/Market-and-AI-Bootstrapping.md`. This section summarises the lifecycle rules relevant to resource logistics planning.*

### Order Types

| Enum Value | Integer | Description |
|---|---|---|
| `buy` | 0 | Player or AI purchasing resource from NPC |
| `sell` | 1 | Player or AI selling resource to NPC |

**Current matching status:**
- Sell orders: NPC synthetic buy order generated via `calculate_bid`. Active and working after Phase 3 enum bug fix.
- Buy orders: NPC sell matching not yet implemented. Returns empty array. `[PENDING]`

### Order Expiry

All orders expire 24 hours after creation (`Market::Order#expires_at = created_at + 24.hours`). Expired orders have status `'expired'` and are not matched. There is no automatic cleanup job documented yet — `[VERIFY AGAINST SOURCE — confirm whether an expiry sweep job exists]`.

### Key Pricing Rules Summary

| Condition | NPC Bid Result | NPC Ask Result |
|---|---|---|
| Settlement has local production facility | Local cost model | Local cost model |
| No local facility; Earth import required | Earth import ceiling (1320.00 GCC/kg at peg) | Earth import ceiling |
| Settlement inventory ≥ 80% warehouse capacity | 0 (NPC refuses to buy) | Normal (NPC still sells) |
| NPC bid returns 0 or nil | No match; order unfilled | N/A |
| NPC bid returns positive; volume > 0 | Synthetic NPC order created | N/A |

---

## 6. Resource Categories

*Document each resource category active in the current simulation. Add rows as new resource types are introduced.*

`[FILL IN FROM GAME DATA — resource list not confirmed from source files reviewed to date]`

| Resource | Category | Primary Source | Earth Import Eligible | Local Production Facility |
|---|---|---|---|---|
| LOX (Liquid Oxygen) | Life support | Atmospheric electrolysis / Earth import | Yes | `atmospheric_processor` |
| Water | Life support | Water mining / Earth import | Yes | `water_mining` |
| Nitrogen (N2) | Atmospheric | Titan-analog harvesting / Earth import | Yes | `atmospheric_processor` |
| Venusian Nitrogen | Atmospheric (premium) | Venusian-analog harvesting | No | N/A |
| Lunar Titanium | Construction | Lunar regolith processing | No | `regolith_processor` |
| Energy | Utilities | Solar / Reactor | No | `solar_array` / `reactor` |

---

## 7. Logistics & Transport Economics

### Earth Import Cost Model

All Earth-origin resources carry the base transport cost of `INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00 USD/kg`. At the bootstrap peg of 1 USD = 1 GCC, this equals **1,320.00 GCC/kg** for any Earth import.

This figure represents the break-even point above which local or off-world sourcing becomes economically rational. Any local production pathway with an effective cost below 1,320.00 GCC/kg generates positive economic value for the settlement.

### Off-World Harvesting Economics

*(See `docs/wiki/Atmospheric-Harvesting.md` for full detail on harvesting economics by source type.)*

| Source | Effective Cost Range | Notes |
|---|---|---|
| Titan-analog N2 (established pipeline) | ~400–800 GCC/kg | Distance-dependent; amortises over transit cycles |
| Asteroid volatile haul | ~200–600 GCC/kg | High variance; dependent on delta-v and belt proximity |
| Local electrolytic O2 (from water ice) | ~50–150 GCC/kg equivalent | Best long-term O2 source; power-limited |
| Venusian-analog processed N2 | ~2,640–3,960 GCC/kg | Only viable as CO2 harvest; N2 is byproduct |

---

## 8. AI Manager Market Integration — Current Status

The `AutonomousConstructionManager` does not currently interact with `Market::Marketplace`, `Market::Condition`, or `Market::Order`. The `Market::Condition` model contains an explicit TODO for this integration.

**Intended integration path (not yet implemented):**

1. AI Manager assesses resource shortfall for a construction phase.
2. AI Manager checks settlement warehouse inventory against the 0.80 cap before posting.
3. AI Manager posts a buy order via `Market::Marketplace#place_order` for the shortfall quantity.
4. NPC sell matching (currently unimplemented) fulfils the order.
5. AI Manager confirms resource receipt and proceeds with construction phase.

Until step 4 is implemented, AI Manager procurement operates outside the market system. This is the highest-priority market integration gap for Phase 4.

---

## 9. Gap Tracking & Known Issues

- [ ] **`NpcPriceCalculator` source not yet reviewed:** The pricing formula structure, local facility detection logic, scarcity scaling, and 0.80 warehouse cap implementation are documented from design intent only. All `[VERIFY AGAINST SOURCE]` flags in this page must be resolved once the source file is available.
- [ ] **Buy-side NPC matching not implemented:** `Market::Marketplace#find_matching_orders` returns `[]` for all buy orders. NPC sell-to-player matching is a confirmed open gap.
- [ ] **NPC buy capacity hardcoded at 1000:** `npc_capacity = 1000` in `find_matching_orders`. Must be driven by settlement state or a configurable market parameter.
- [ ] **Order expiry sweep job not confirmed:** Orders expire after 24 hours but no cleanup job has been identified. Expired orders may accumulate in `market_orders` table.
- [ ] **AI Manager ↔ Market integration missing:** `AutonomousConstructionManager` does not post orders through the market. Pre-player bootstrapping cannot respond to live price signals until this integration is built.
- [ ] **`supply` and `demand` columns on `Market::Condition` not confirmed:** Referenced in a code comment but not verified as actual database columns.
- [ ] **GCC decoupling mechanism not implemented:** No volume threshold or decoupling trigger has been found in source. The 1:1 peg is permanent until this is built.
- [ ] **Resource category list incomplete:** The resource table in Section 6 is based on game design intent, not an extracted resource registry. Verify and expand against actual game data.

---

## 10. Revision History

| Date | Author | Change Summary |
|---|---|---|
| [Date] | [Author] | Initial template — Phase 3 documentation sprint |
| [Date] | [Author] | [Description] |

---

*Last verified against: `app/models/market/marketplace.rb`, `app/models/market/condition.rb`, `app/models/market/order.rb`, `config/initializers/game_constants.rb` — Phase 3 (Integration & Restoration). Sections marked `[VERIFY AGAINST SOURCE]` require `NpcPriceCalculator` source review.*
