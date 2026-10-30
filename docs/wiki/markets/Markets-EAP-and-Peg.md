# Markets, EAP, and GCC/USD Peg — Canonical Specification

> **Wiki section:** Logistics · **Status:** CANONICAL CONSOLIDATION — this page merges the market pair from `Resource-and-Market-Logistics.md`, `market_and_ai_bootstrapping.md`, `Financial-Engine.md`, and `eap_and_ai_manager_escalation.md`. Each topic below grounds intent in verified code where present; TARGET DESIGN INTENT and OPEN markers are used explicitly.

> **Authoritative sources:**
> - Code: `galaxy_game/app/models/market/`, `galaxy_game/app/services/market/`, `galaxy_game/app/services/economic_config.rb`
> - Constants: `config/initializers/game_constants.rb` (GCC_TO_USD_INITIAL = 1.0, INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00)
> - Config: `config/economic_parameters.yml` (via EconomicConfig)
> - Legacy harvest source: [Resource-and-Market-Logistics](../logistics/Resource-and-Market-Logistics.md), [Market and AI Bootstrapping](../logistics/market_and_ai_bootstrapping.md), [Financial Engine](../logistics/Financial-Engine.md), [EAP & AI Manager Escalation](../logistics/eap_and_ai_manager_escalation.md)

---

## 1. Currency System — GCC / USD Bootstrap Peg

### Design Intent

Galaxy Game uses a two-currency system during the bootstrap phase:

| Currency | Scope |
|----------|-------|
| **USD** (United States Dollars) | Earth-side corporations, Earth-origin import invoicing and transport costs at the Luna/L1 interface only. Terrestrial entities do not hold or trade in GCC. |
| **GCC** (Galactic Crypto Currency) | All off-world player accounts, colony budgets, courier contracts, market orders, and inter-settlement trade denominated in GCC. |

### Verified Code — Bootstrap Peg

**CONFIRMED in `config/initializers/game_constants.rb`:**

```ruby
GCC_TO_USD_INITIAL = 1.0  # 1 USD per Galactic Credit Coin (GCC) initially
INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00  # USD/kg for Earth import baseline
```

**CONFIRMED in `EconomicConfig` (`app/services/economic_config.rb`):**

- `EconomicConfig.usd_to_gcc_peg` reads from `currency.usd_to_gcc_peg` in `economic_parameters.yml`; defaults to 1.0.
- This is the **single source of truth** for all peg conversions at runtime — no service may hardcode a numeric conversion rate.
- All references must use `EconomicConfig.usd_to_gcc_peg` or its designated successor constant.

### TARGET DESIGN INTENT — GCC Decoupling (Unpeg)

> **[TARGET DESIGN INTENT ONLY]** The fixed peg is dropped when the off-world economy matures — specifically when GCC-side volume and trade value rival the USD/Earth channel. After unpeg, USD and GCC floating rates diverge and seeded blueprint prices drift with play rather than remaining frozen to the Earth catalog.
>
> **Code status:** `GCC_TO_USD_INITIAL = 1.0` enforces a permanent bootstrap peg in the current codebase. No decoupling trigger or volume threshold logic exists in source. This must be designed, documented, and implemented before the peg is expected to float.

### GCC as Cryptocurrency — Verified Mining Parameters

**CONFIRMED in `EconomicConfig`:**

```ruby
# cryptocurrency.gcc_mining section (economic_parameters.yml)
gcc_max_supply              => 21_000_000,000   # capped deflationary total supply
gcc_halving_interval_days    => 730               # ~2 years per halving event
gcc_issuance_model           => 'capped_deflationary'
gcc_difficulty_scaling_enabled => true
gcc_initial_block_reward     => 1000
gcc_minimum_block_reward     => 1
```

### VERIFIED — Cryptocurrency Mining Infrastructure

**CONFIRMED files:** `galaxy_game/app/jobs/mine_gcc_job.rb` and `galaxy_game/app/models/concerns/cryptocurrency_mining.rb`. The mining pipeline exists as a working infrastructure layer; the issuance model above applies to it.

---

## 2. Earth Anchor Price (EAP) — Pricing Ceiling

### Verified Definition

**CONFIRMED in code:** EAP is computed via `Tier1PriceModeler.calculate_eap` which combines:
- `Earth USD reference cost` (from `EconomicConfig.earth_spot_price(material_id)` in `economic_parameters.yml`)
- `+ refining factor where applicable` (from `EconomicConfig.refining_factor(process_type)`)
- `+ transport cost to destination settlement` (via route modifiers and technology multiplier from config)

```ruby
# Simplified verified flow:
EAP = earth_spot_price + refining_factor * transport_cost(destination, source)
```

### Verified Properties

| Property | Detail | Code Source |
|----------|--------|-------------|
| World-dependent | Transport cost Earth→Luna ≠ Earth→Belt. Each destination has its own EAP per item. | `Tier1PriceModeler` takes `destination:` parameter |
| Item-dependent | Earth market price varies by resource type (via `earth_spot_price()` lookup) | `EconomicConfig.earth_spot_price(material_id)` |
| Dynamically calculated | Computed at pricing decision time — never stored as a static value. Snapshot via `ImportOrder.eap_at_order_time` for audit purposes. | `calculate_earth_import_cost()` → `Tier1PriceModeler.new(...).calculate_eap` |
| AI Manager ceiling | AI Manager's absolute price ceiling for all market purchases. Never pays above EAP unless `emergency: true`. | EAP enforcement verified in `NpcPriceCalculator.cost_based_ask` / `calculate_eap_reference` |

### Emergency Override — Verified

```ruby
# Normal behavior (strictly enforced): cost <= eap  → proceed with purchase
# Emergency override (explicitly logged and tracked): emergency: true  → AI Manager exceeds EAP — logs supply chain failure
```

The AI Manager dislikes emergency imports and adjusts future long-term planning to avoid situations that force them. Every emergency purchase is logged and tracked for chronic gap analysis.

### AstroLift Structural Enforcement

AstroLift (the seeded NPC corporation owning the cycler network) enforces EAP structurally across the market: if any seller (player or NPC) prices above EAP, rational buyers will wait for the next AstroLift shipment instead, keeping the market honest regardless of individual seller pricing behavior.

---

## 3. NPC Pricing Engine — Two Modes

### Verified Architecture

**CONFIRMED in `Market::NpcPriceCalculator` (`app/services/market/npc_price_calculator.rb`):**

The calculator switches between two pricing modes based on whether mature market data exists:

| Mode | Trigger | Price Basis |
|------|---------|-------------|
| **Cost-based** (bootstrap) | No market history for this resource/settlement | `EARTH_COST + transport` → markup/discount via EconomicConfig |
| **Market-based** (mature) | Market average exists for resource within last N days | Historical price average → markup/discount via EconomicConfig |

### Verified — Cost-Based Pricing (Bootstrap Phase)

```ruby
# calculate_ask(settlement, resource_name, context)  [NPC selling to player]
import_cost = calculate_import_cost(settlement, resource_name)
markup = context[:markup] || EconomicConfig.npc_sell_markup(market_exists: false)
minimum_price = import_cost * (1 + EconomicConfig.npc('cost_based.minimum_profit_margin') || 0.03)
ask_price = [import_cost * markup, minimum_price].max.round(2)

# calculate_bid(settlement, resource_name, context)  [NPC buying from player]
base_cost = is_deep_space ? calculate_extraction_floor : import_cost
discount = context[:discount] || EconomicConfig.npc_buy_discount(market_exists: false)
adjusted_discount = apply_inventory_adjustments(..., discount, ...)
bid_price = (base_cost * adjusted_discount).round(2)
```

### Verified — Market-Based Pricing (Mature Phase)

```ruby
# calculate_ask — market avg with markup, never below cost floor
market_avg = get_market_average(settlement, resource_name)  # last 30 days by default
ask_price = [market_avg * markup, cost_floor].max.round(2)

# calculate_bid — market avg with discount adjusted for inventory levels
bid_price = (market_avg * adjusted_discount).round(2)
```

### Verified — Inventory-Based Price Adjustment (EconomicConfig-driven)

**CONFIRMED thresholds in `economic_parameters.yml` via EconomicConfig:**

| Condition | Multiplier on Bid Price | Config Key | Default |
|-----------|------------------------|------------|---------|
| Inventory < critical threshold | ×1.2 (desperate — pay more) | `inventory_critical_multiplier` | 1.2 |
| Inventory < low threshold | ×1.1 (low stock — pay slightly more) | `inventory_low_multiplier` | 1.1 |
| Inventory normal | base discount (no adjustment) | — | 1.0 |

**CONFIRMED in code:** inventory excess threshold is `EconomicConfig.npc('inventory_high_threshold') || 0.70`.
> **⚠ CONFLICT with legacy wiki (`Resource-and-Market-Logistics.md`):** The legacy wiki page states the NPC refuses to buy at **0.80** (80%) warehouse capacity. Code verifies the threshold at **0.70** (70%). Code is authoritative — update `Resource-and-Market-Logistics.md` accordingly.

### VERIFIED — Settlement Capability Detection

Local production detection uses two checks:
1. `PrecursorCapabilityService.can_produce_locally?(resource_name)` on celestial body
2. `settlement_has_extraction_equipment?` — iterates settlement units for matching output resources

If local production is confirmed, pricing routes to local cost model via `EconomicConfig.local_production_cost(resource_id, maturity_stage)`.

### VERIFIED — Deep-Space Pricing

For settlements not on Earth or Luna, `calculate_extraction_floor()` is used as the base cost instead of Earth import cost. This prevents overcharging deep-space locations based on distant Earth pricing.

---

## 4. Market Layer — Order Lifecycle & Matching

### Verified Component Map

| Role | Class | Path | Status |
|------|-------|------|--------|
| Market entry point | `Market::Marketplace` | `app/models/market/marketplace.rb` | ACTIVE |
| Per-resource market state | `Market::Condition` | `app/models/market/condition.rb` | ACTIVE |
| Individual trade orders | `Market::Order` | `app/models/market/order.rb` | ACTIVE |
| Price history records | `Market::PriceHistory` | `app/models/market/price_history.rb` | ACTIVE |
| NPC price calculation | `Market::NpcPriceCalculator` | `app/services/market/npc_price_calculator.rb` | ACTIVE |
| Trade execution | `Market::TradeExecutionService` | `app/services/market/trade_execution_service.rb` | ACTIVE |
| Supply chain tracking | `Market::SupplyChain` | `app/models/market/supply_chain.rb` | ACTIVE |
| Market settings | `Market::Settings` | `app/models/market/settings.rb` | ACTIVE |
| Condition updater | `ConditionUpdaterService` | `app/services/market/condition_updater_service.rb` | ACTIVE |
| Transaction fee model | `Market::TransactionFee` | `app/models/market/transaction_fee.rb` | ACTIVE |

### VERIFIED — Order Placement & Matching Flow

```ruby
# Marketplace#place_order(params) → [Market::Order, nil]
place_order(params)
  → prepare_order_params       # strips :price; normalizes :volume to :quantity; resolves Market::Condition via find_or_create_by!
  → create_order               # condition.market_orders.create!(order_params) — creates Market::Order in DB
  → match_orders(order)        # find_matching_orders(order) + execute_trades if matches found
  → finalize_order_return      # returns nil if quantity == 0 (fully filled), order otherwise
```

**VERIFIED:** `:price` is stripped from params inside `prepare_order_params`. Callers must not set price — it is determined entirely by `NpcPriceCalculator` at execution time.

### VERIFIED — Sell-Side Matching (NPC Buy Orders)

```ruby
# Marketplace#find_matching_orders(new_order) for SELL orders only
npc_price = NpcPriceCalculator.calculate_bid(settlement, new_order.resource, demand: new_order.quantity)
trade_volume = [new_order.quantity, npc_capacity].min  # npc_capacity HARDCODED at 1000 ⚠ TODO
return [] unless trade_volume > 0 && npc_price && npc_price > 0
[create_synthetic_npc_order(new_order, trade_volume, npc_price)]
```

- **Enum predicate fix verified:** now uses `new_order.sell?` (enum value `{ buy: 0, sell: 1 }`) instead of the previous broken string comparison.
- NPC bid returns `nil` when inventory is at or above the excess threshold — this causes no match to be found.

### VERIFIED — Buy-Side Matching Status

```ruby
# Marketplace#find_matching_orders(new_order) for BUY orders → ALWAYS returns []
return [] unless new_order.sell?  # buy orders are excluded by design
```

**BUY-SIDE MATCHING IS NOT IMPLEMENTED.** This is a confirmed open gap. NPC sell-to-player matching does not exist yet. See the OPEN section below.

### VERIFIED — Trade Execution Path

`Market::TradeExecutionService.execute!(sell_order, trade_volume, trade_price, settlement)` performs:

1. **Tax collection:** `Financial::TaxCollectionService.collect_sales_tax(seller_organization, gross_revenue, currency)`
2. **Buyer routing:** Checks if buyer is NPC (`settlement.owner.is_npc?`) — routes through `GuaranteedMarketSale.execute(...)` for NPCs; normal fund transfer for player-to-player.
3. **Inventory update:** `seller_organization.remove_inventory(resource, trade_volume)`
4. **Record creation:** Trade record, price history snapshot, supply chain record

### VERIFIED — Order Status Enum & Expiry

```ruby
# Market::Order enum order_type: { buy: 0, sell: 1 }
# All orders expire 24 hours after creation
expires_at = created_at + 24.hours  # status becomes 'expired' when current time > expires_at
```

---

## 5. Autonomous Construction Manager (ACM) — Pre-Player Bootstrapping

### VERIFIED — ACM Architecture

**CONFIRMED in `lib/ai_manager/autonomous_construction_manager.rb`:**

```ruby
AutonomousConstructionManager.new(settlement, ai_service = nil)
# ai_service defaults to StubAIService.new when not provided

execute_adapted_mission(adapted_mission) → {
  tasks_completed:  Integer,   # count of successfully completed tasks
  resources_used:   Hash,      # { resource_name => total_amount } merged across all phases
  structures_built: Array,     # list of structure names built
  ai_interventions: Integer,   # count of AI failure-resolution attempts
  success_rate:     Float      # tasks_completed / total_tasks across all phases
}
```

### RETIRED / DO NOT USE — StubAIService

**CONFIRMED:** `StubAIService.analyze_task_failure(task, task_result, context)` is a **SIMULATION STUB** used only for placeholder behavior during pre-player development. It handles two failure patterns with hardcoded responses:

| Error string contains | Resolution | Additional resources |
|----------------------|------------|---------------------|
| `'resource'` | `'resource_reallocation'` | `{ 'spare_parts' => 10 }` |
| `'equipment'` | `'equipment_repair'` | `{ 'tools' => 5 }` |
| anything else | `can_resolve: false` | — |

> **RETIRED / DO NOT USE:** `StubAIService` is scaffolding only. A production AI service has not yet been implemented. Do not use for any live behavior. Task success rates are simulated with `rand` (90% success, 70% intervention resolution). No real construction logic, resource checks, or settlement state queries are performed.

### VERIFIED — AI Learning Hook (No Persistence)

`learn_from_phase_execution` logs a learning data hash per phase but **writes nothing to disk or database**. It is a hook for future AI learning integration:

```ruby
{
  phase_name:      String,
  tasks_attempted: Integer,
  tasks_completed: Integer,
  success_rate:    Float,
  context:         String,   # settlement.celestial_body.name
  timestamp:       Time
}
# → printed to log only. No persistence.
```

---

## 6. Market Lifecycle Phases

### Phase A — Earth Import Dependent (Bootstrap)

| Aspect | State |
|--------|-------|
| Local production | None online |
| Pricing engine | Cost-based via `EARTH_COST + transport` at `INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00 USD/kg` |
| GCC/USD peg | Fixed at `GCC_TO_USD_INITIAL = 1.0`, quoted 1:1 in GCC |
| Warehouse cap | Applies from day one (threshold verified at **0.70** by code) |

### Phase B — First Local Production Online (Luna Pattern)

| Aspect | State |
|--------|-------|
| Trigger | At least one facility (e.g., `water_mining`, `atmospheric_processor`) operational |
| Pricing engine | Switches to local cost model: `facility.operational_cost + energy_cost` |
| NPC ask price | Drops below 1,320 GCC/kg — players can undercut or match local production costs |
| NPC bid available | For excess output (capped by `npc_capacity = 1000` hardcoded) |

### Phase C — Full Sol Market Liquidity (Late Bootstrap / Pre-Player Transition)

| Aspect | State |
|--------|-------|
| Pricing engine | Scarcity premium + abundance discount active |
| GCC/USD peg | **[TARGET DESIGN INTENT]** Peg dropped when off-world volume rivals Earth channel; post-float USD/GCC diverge |
| ACM ↔ Market integration | **[PENDING]** AI Manager posts buy orders through `Market::Marketplace` — currently not implemented |

---

## 7. Trade Infrastructure — Verified Services

### VERIFIED — Tax Collection

| Component | Path |
|-----------|------|
| `Financial::TaxCollectionService.collect_sales_tax(seller, gross_revenue, currency)` | `app/services/financial/tax_collection_service.rb` |
| `TaxAuthority` (base organization) | `app/models/organizations/tax_authority.rb` |

### VERIFIED — Guaranteed Market Sale (NPC Fallback)

| Component | Path |
|-----------|------|
| `GuaranteedMarketSale.execute(player_settlement:, resource:, volume:, bid_price:, ldc_settlement:)` | `app/services/marketplace/guaranteed_market_sale.rb` |
| Used by: `TradeExecutionService` when buyer is NPC | — |

### VERIFIED — Economic Configuration

| Component | Path |
|-----------|------|
| `EconomicConfig` central access (dot-notation via YAML) | `app/services/economic_config.rb` |
| Config source | `config/economic_parameters.yml` |
| Raw constants fallback | `config/initializers/game_constants.rb` |

---

## 8. Cross-Reference Summary Table

| Topic | Canonical wiki page | Code ground truth |
|-------|-------------------|-------------------|
| GCC/USD peg & bootstrap | This page (§1) | `game_constants.rb:GCC_TO_USD_INITIAL`, `EconomicConfig.usd_to_gcc_peg` |
| EAP ceiling formula | This page (§2) | `Tier1PriceModeler.calculate_eap`, `EconomicConfig.earth_spot_price()` |
| NPC pricing engine (bid/ask) | This page (§3) | `NpcPriceCalculator` — cost-based + market-based modes |
| Market order lifecycle | This page (§4) | `Marketplace#place_order`, `Condition`, `Order` enum |
| GCC decoupling target | This page (§1, §6) | **[TARGET DESIGN INTENT]** — no code yet |
| GCC cryptocurrency mining | This page (§1) | `mine_gcc_job.rb`, `cryptocurrency_mining.rb`, config params |
| ACM & pre-player bootstrapping | This page (§5) | `AutonomousConstructionManager` + StubAIService (RETIRED) |
| Market lifecycle phases | This page (§6) | Phase A/B/C mapping to pricing engine state transitions |
| Trade infrastructure | This page (§7) | TaxCollectionService, GuaranteedMarketSale, EconomicConfig |

---

## OPEN — Needs Owner Confirmation

### Open Item 1: GCC Decoupling Trigger Mechanism
- **Question:** What specific volume threshold or scenario event triggers the peg-to-float transition?
- **Legacy source:** Harvested from [Resource-and-Market-Logistics.md §1](../logistics/Resource-and-Market-Logistics.md) and [market_and_ai_bootstrapping.md §2/§6](../logistics/market_and_ai_bootstrapping.md). Both confirm: "PEGGED — TARGET DESIGN INTENT ONLY."
- **Code status:** No decoupling trigger found in any source file. `GCC_TO_USD_INITIAL = 1.0` is permanent in the current codebase.

### Open Item 2: Fee Schedule (Broker/Sales/Surcharge Tiers)
- **Question:** What are the exact fee/tax tiers for NPC buy/sell friction?
- **Legacy source:** Harvested from [Financial Engine §4](../logistics/Financial-Engine.md). Older notes mention broker/sales/surcharge style tiers.
- **Code status:** `Market::TransactionFee` model exists but specific schedule values are in `economic_parameters.yml` — needs confirmation of which fees apply at which phase.

### Open Item 3: NPC Buy Capacity (Hardcoded 1000)
- **Question:** Should NPC buy capacity be driven by settlement state or a configurable market parameter instead of the hardcoded value?
- **Legacy source:** Harvested from [market_and_ai_bootstrapping.md §3.1](../logistics/market_and_ai_bootstrapping.md). Both pages note: `npc_capacity = 1000` is a TODO in source.
- **Code status:** `Marketplace#find_matching_orders` hardcodes `npc_capacity = 1000`. No config override exists.

### Open Item 4: Buy-Side NPC Matching
- **Question:** When will NPC sell-to-player matching be implemented? What is the scope?
- **Legacy source:** Harvested from [Resource-and-Market-Logistics.md §5](../logistics/Resource-and-Market-Logistics.md) and [market_and_ai_bootstrapping.md §4](../logistics/market_and_ai_bootstrapping.md). Both confirm: "BUY-SIDE MATCHING NOT IMPLEMENTED."
- **Code status:** `Marketplace#find_matching_orders` returns `[]` for all non-Sell orders by design. No implementation planned in current code.

### Open Item 5: `supply` and `demand` on `Market::Condition`
- **Question:** Are `supply` and `demand` actual database columns or just a comment artifact?
- **Legacy source:** Harvested from [market_and_ai_bootstrapping.md §3.2](../logistics/market_and_ai_bootstrapping.md). Comment in model says `"etc."` — never confirmed as DB columns.
- **Code status:** Model fields not verified against schema migrations. Do not treat as queryable fields until migration is reviewed.

### Open Item 6: Order Expiry Sweep Job
- **Question:** Is there an automated job that cleans up expired `Market::Order` records, or do they accumulate in `market_orders`?
- **Legacy source:** Harvested from [Resource-and-Market-Logistics.md §5](../logistics/Resource-and-Market-Logistics.md). "Order expiry sweep job not confirmed."
- **Code status:** Orders have `expires_at = created_at + 24.hours` but no cleanup job found in source.

### Open Item 7: AI Manager ↔ Market Integration
- **Question:** When will `AutonomousConstructionManager` interact with `Market::Marketplace` for live price signal response?
- **Legacy source:** Harvested from [market_and_ai_bootstrapping.md §7](../logistics/market_and_ai_bootstrapping.md). Model contains explicit TODO: "Integrate with AIManager."
- **Code status:** ACM has no calls into market models. `Market::Condition` model still has the integration TODO in source.

### Open Item 8: Resource Category List Completeness
- **Question:** What is the authoritative resource registry for pricing?
- **Legacy source:** Harvested from [Resource-and-Market-Logistics.md §6](../logistics/Resource-and-Market-Logistics.md). Table was based on game design intent, not extracted registry.
- **Code status:** `NpcPriceCalculator.resource_base_price()` has hardcoded base prices for: ibeam (100), aluminum_alloy (50), steel (30), titanium (200), carbon_fiber (150), solar_panel (500), battery (300), fuel_cell (400). All others default to 10.

---

## Migration Log — Page Consolidation

| Date | Action | Legacy pages consolidated |
|------|--------|--------------------------|
| 2026-10-29 | Created canonical markets page, merging all market/peg/EAP wiki material into one authoritative reference | [Resource-and-Market-Logistics.md](../logistics/Resource-and-Market-Logistics.md), [market_and_ai_bootstrapping.md](../logistics/market_and_ai_bootstrapping.md), [Financial-Engine.md](../logistics/Financial-Engine.md), [eap_and_ai_manager_escalation.md](../logistics/eap_and_ai_manager_escalation.md) |

All legacy pages remain for backward-link compatibility. This page is the new canonical authority for market, EAP, and peg mechanics.

---

*Last verified against: `galaxy_game/app/models/market/`, `galaxy_game/app/services/market/`, `galaxy_game/app/services/economic_config.rb`, `config/initializers/game_constants.rb`, `config/economic_parameters.yml` — 2026-10-29 consolidation pass.*
