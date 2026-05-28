# Market Architecture & AI Manager Bootstrapping

> **Scope:** Verified specification for Galaxy Game's market layer and autonomous pre-player construction system. All class names, method signatures, field names, and associations are sourced directly from `marketplace.rb`, `condition.rb`, `order.rb`, and `autonomous_construction_manager.rb`. Fields or models not confirmed in source are explicitly marked `[PENDING]`.

---

## 1. Component Map

| Role | Class | Path |
|---|---|---|
| Market entry point | `Market::Marketplace` | `app/models/market/marketplace.rb` |
| Per-resource market state | `Market::Condition` | `app/models/market/condition.rb` |
| Individual trade orders | `Market::Order` | `app/models/market/order.rb` |
| Price history records | `Market::PriceHistory` | `app/models/market/price_history.rb` |
| NPC price calculation | `Market::NpcPriceCalculator` | `[PENDING — path not confirmed]` |
| Trade execution | `Market::TradeExecutionService` | `[PENDING — path not confirmed]` |
| Pre-player construction | `AutonomousConstructionManager` | `lib/ai_manager/autonomous_construction_manager.rb` |
| Settlement anchor | `Settlement::BaseSettlement` | `app/models/settlement/base_settlement.rb` |

> **Not confirmed in source:** `Market::SupplyChain` appears in Gemini's brief but is not referenced in any of the uploaded source files. Do not treat it as an existing model until verified.

---

## 2. Macro-Economic Framework & Currency Peg

The Sol system bootstrap phase enforces a strict financial boundary between Earth-side and off-world markets, grounded in `game_constants.rb`:

**Earth entities do not trade in GCC.** Terrestrial corporations operating on Earth are compensated in USD. USD is used to finance Earth-side imports at the fixed transport rate of `INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00 USD/kg`.

**The GCC bootstrap peg** is enforced by `GCC_TO_USD_INITIAL = 1.0` — a direct 1:1 stable parity coupling:

```
1 USD = 1 GCC  (bootstrap phase only)
```

This fixed rate holds until lunar and off-world market infrastructure scales to a target volume threshold, at which point GCC decouples from USD and floats on open market exchanges. The decoupling mechanism and volume threshold are `[PENDING — not yet implemented in source]`.

---

## 3. Market Model Architecture

### 3.1 `Market::Marketplace`

**Table:** `market_marketplaces`

The marketplace is the top-level market entity. Each marketplace belongs to exactly one settlement and serves as the orchestration layer for order placement, NPC matching, and trade execution.

**Associations:**

| Association | Type | Details |
|---|---|---|
| `settlement` | `belongs_to` | `Settlement::BaseSettlement` |
| `market_conditions` | `has_many` | `Market::Condition`, FK: `market_marketplace_id` |
| `prices` | `has_many through` | Through `:market_conditions` |
| `orders` | `has_many through` | Through `:market_conditions`, source: `:orders` |

**Key methods:**

`self.get_price(item, seller:, demand: 1)` — Class method. Resolves the seller's settlement (handling three possible seller interfaces: `.settlement`, `.base_settlement`, or the seller object itself), extracts a resource name string, and delegates to `Market::NpcPriceCalculator.calculate_ask`. Returns `0.0` if the calculator returns nil.

`place_order(params)` — Places and immediately attempts to match an order. Runs inside a transaction. The full internal chain is:

```
place_order(params)
  → prepare_order_params      # strips :price, renames :volume to :quantity,
                              # resolves Market::Condition via find_or_create_by!
  → create_order              # creates Market::Order via condition.market_orders.create!
  → match_orders              # calls find_matching_orders, then execute_trades if matches found
  → finalize_order_return     # reloads order; returns nil if quantity == 0, order otherwise
```

**Important:** `:price` is stripped from the params hash inside `prepare_order_params`. Callers must not set price — it is determined entirely by `Market::NpcPriceCalculator` at execution time.

**Important:** The `:volume` key is renamed to `:quantity` internally. Callers may pass either key; the model normalises to `:quantity`.

`find_matching_orders(new_order)` — Only matches orders where `order_type == 'Sell'`. For sell orders, queries `Market::NpcPriceCalculator.calculate_bid` to get the NPC buy price, caps trade volume at `min(order.quantity, 1000)` (NPC buy capacity is currently hardcoded at 1000 — flagged as a TODO to make dynamic), and returns a synthetic NPC buy order as an `OpenStruct` if both volume and price are positive. Returns an empty array for buy orders — **buy-side matching is not yet implemented**.

`execute_trades(sell_order, matching_orders)` — Delegates all execution to `Market::TradeExecutionService.execute!(sell_order, trade_volume, trade_price, settlement)`. Trade volume is `min(sell_order.quantity, npc_order.quantity)`. Trade price is the NPC order's price. After service execution, `finalize_order` updates the sell order's remaining quantity.

`current_market_condition(resource)` — Returns the `Market::Condition` for a given resource string, creating it if it does not exist (`find_or_create_by!(resource: resource)`).

---

### 3.2 `Market::Condition`

**Table:** `market_conditions`

Represents the market state for a single resource within a marketplace. Acts as the parent record for all orders and price history entries related to that resource.

**Associations:**

| Association | Type | Details |
|---|---|---|
| `marketplace` | `belongs_to` | `Market::Marketplace`, FK: `market_marketplace_id` |
| `market_orders` | `has_many` | `Market::Order`, FK: `market_condition_id` |
| `orders` | `has_many` | `Market::Order`, FK: `market_condition_id` — legacy duplicate of `market_orders`; see gap tracker |
| `price_histories` | `has_many` | `Market::PriceHistory`, FK: `market_condition_id` |

**Confirmed fields:**

| Field | Type | Notes |
|---|---|---|
| `resource` | String | Resource name; used as lookup key |
| `price` | Decimal | Current listed price; see `current_price` method |

> **Not confirmed as DB columns:** `supply` and `demand` appear in a code comment as `"etc."` but are not confirmed as actual database columns on this model. Do not treat them as queryable fields until the schema migration is reviewed.

**Key methods:**

`current_price` — Returns the most recent price from `price_histories` ordered by `created_at` descending. Falls back to `10` (integer literal) if no price history exists.

**Open TODO in source:** The model contains an explicit comment: `TODO: Integrate with AIManager for automated buy/sell order listing and placement`. The `AutonomousConstructionManager` does not currently interact with `Market::Condition` directly.

---

### 3.3 `Market::Order`

**Table:** `market_orders`

> **Note on file naming:** The source file is named `market_order.rb` (legacy name) but the class is `Market::Order`. The table is `market_orders`.

**Associations:**

| Association | Type | Details |
|---|---|---|
| `market_condition` | `belongs_to` | `Market::Condition`, FK: `market_condition_id` |
| `orderable` | `belongs_to` | Polymorphic |
| `base_settlement` | `belongs_to` | `Settlement::BaseSettlement`, FK: `base_settlement_id` |

**Enum:**

```ruby
enum order_type: { buy: 0, sell: 1 }
```

> **Bug flag:** `Marketplace#find_matching_orders` checks `new_order.order_type == 'Sell'` (string comparison), but the enum stores integer values and returns symbol predicates (`buy?`, `sell?`). This string comparison will not behave as expected against the enum. Correct check should be `new_order.sell?` or `new_order.order_type == 'sell'`. This needs a fix and a spec covering the matching path.

**Validations:** `quantity`, `order_type`, `resource` — all required.

**Callbacks:** `before_validation :set_resource_from_market_condition` — sets `resource` from the associated condition if not already present.

**Confirmed DB fields:** `quantity`, `order_type` (integer via enum), `resource`, `base_settlement_id`, `market_condition_id`, `orderable_type`, `orderable_id`, `fulfilled_at`, `created_at`.

**Virtual attributes (no DB columns — computed on demand):**

| Method | Returns | Notes |
|---|---|---|
| `price_per_unit` | Float | `NpcPriceCalculator.calculate_bid` (buy) or `.calculate_ask` (sell) |
| `total_cost` | Float | `price_per_unit * quantity` |
| `expires_at` | DateTime | `created_at + 24.hours` |
| `expired?` | Boolean | `Time.current > expires_at` |
| `status` | String | `'expired'` or `'pending'` |

**Key methods:**

`fulfill!` — Sets `fulfilled_at` to `Time.current`. Logs an error if the update fails but does not raise.

---

### 3.4 `Market::PriceHistory`

**Table:** `market_price_histories` `[PENDING — table name not confirmed]`

Referenced by `Market::Condition#price_histories` and `Market::Condition#current_price`. Confirmed fields: `price` (Decimal), `market_condition_id` (FK), `created_at`. Full schema `[PENDING — source file not uploaded]`.

---

### 3.5 `Market::NpcPriceCalculator`

Referenced throughout `Marketplace` and `Order` but source not uploaded. Confirmed interface:

| Method | Signature | Used by |
|---|---|---|
| `.calculate_ask` | `(settlement, resource_name, supply:)` | `Marketplace.get_price`, `Order#price_per_unit` (sell) |
| `.calculate_bid` | `(settlement, resource, demand:)` | `Marketplace#find_matching_orders`, `Order#price_per_unit` (buy) |

Full implementation `[PENDING — source file not uploaded]`.

---

### 3.6 `Market::TradeExecutionService`

Referenced in `Marketplace#execute_trades`. Confirmed interface:

| Method | Signature | Notes |
|---|---|---|
| `.execute!` | `(sell_order, trade_volume, trade_price, settlement)` | `settlement` is passed as the buyer entity |

Full implementation `[PENDING — source file not uploaded]`.

---

## 4. Order Lifecycle

```
Player/AI calls place_order(params)
  │
  ├─ params[:price] stripped (price is NPC-determined, not caller-set)
  ├─ params[:volume] renamed to params[:quantity] if present
  ├─ Market::Condition resolved via find_or_create_by!(resource:)
  │
  ├─ Market::Order created via condition.market_orders.create!
  │
  ├─ [If Sell order] find_matching_orders called
  │     ├─ NpcPriceCalculator.calculate_bid → NPC buy price
  │     ├─ trade_volume = min(order.quantity, 1000)
  │     └─ Synthetic NPC OpenStruct returned if price > 0 and volume > 0
  │
  ├─ [If match found] execute_trades called
  │     ├─ TradeExecutionService.execute!(sell_order, volume, price, settlement)
  │     └─ sell_order.quantity decremented by trade_volume
  │
  └─ Returns nil (fully filled) or order (partially/unfilled)

Order expiry: created_at + 24.hours → status = 'expired'
Order fulfillment: order.fulfill! → sets fulfilled_at timestamp
```

**Buy orders are not matched.** `find_matching_orders` returns `[]` for any non-Sell order. Buy-side matching is a confirmed open gap.

---

## 5. `AutonomousConstructionManager`

**File:** `lib/ai_manager/autonomous_construction_manager.rb`

The `AutonomousConstructionManager` executes structured mission plans to build pre-player infrastructure (Development Corporation bases, Lunar Development Corporation facilities, Astrolift systems). It is initialized with a settlement reference and an optional AI service.

**Initialization:**

```ruby
AutonomousConstructionManager.new(settlement, ai_service = nil)
```

`ai_service` defaults to `StubAIService.new` when not provided. **The `StubAIService` is a simulation stub — it is not a real AI service.** It handles only two error string patterns (`'resource'` and `'equipment'`) and returns hardcoded resolution attempts. A production AI service has not yet been implemented.

**`execute_adapted_mission(adapted_mission)` — return value:**

```ruby
{
  tasks_completed:  Integer,   # count of successfully completed tasks
  resources_used:   Hash,      # { resource_name => total_amount } merged across all phases
  structures_built: Array,     # list of structure names built
  ai_interventions: Integer,   # count of AI failure-resolution attempts
  success_rate:     Float      # tasks_completed / total_tasks across all phases
}
```

**Expected mission hash structure:**

```ruby
{
  'name'          => String,
  'target_system' => String,   # stored in context but not currently acted upon
  'phases'        => [
    {
      'name'  => String,
      'tasks' => [
        {
          'name'               => String,
          'required_resources' => { 'resource_name' => amount },  # Hash
          'builds_structure'   => String   # optional; structure name if task builds one
        }
      ]
    }
  ]
}
```

**Construction context (internal, passed between phase methods):**

```ruby
{
  settlement:          @settlement,     # Settlement::BaseSettlement instance
  target_system:       String,          # from mission['target_system']
  available_resources: {},              # populated during execution
  built_structures:    [],              # populated during execution
  current_phase:       0,               # phase index tracker
  start_time:          Time.current
}
```

### Execution Flow

```
execute_adapted_mission(mission)
  │
  ├─ initialize_construction_context(mission)
  │
  └─ For each phase in mission['phases']:
        execute_phase(phase, context)
          │
          └─ For each task in phase['tasks']:
                execute_task(task, context)
                  ├─ SUCCESS (90% probability via rand > 0.1)
                  │     → tasks_completed += 1
                  │     → resources_used merged from task['required_resources']
                  │     → structures_built << task['builds_structure'] if present
                  │
                  └─ FAILURE (10% probability)
                        ai_intervene_in_task_failure(task, result, context)
                          ├─ StubAIService.analyze_task_failure called
                          ├─ RESOLVED (70% probability via rand > 0.3)
                          │     → tasks_completed += 1
                          └─ UNRESOLVED
                                → task counted as failed
```

**Success and intervention rates are simulated with `rand`.** These are not driven by real resource availability, settlement state, or construction logic. This is Phase 3 scaffolding intended to be replaced with real service calls.

### `learn_from_phase_execution`

Logs a learning data hash per phase:

```ruby
{
  phase_name:      String,
  tasks_attempted: Integer,
  tasks_completed: Integer,
  success_rate:    Float,
  context:         String,   # @settlement.location.celestial_body.name
  timestamp:       Time
}
```

Data is currently only printed to log. **There is no persistence of learning data** — no database writes, no knowledge base update. The method is a hook for future AI learning integration.

### `StubAIService`

`StubAIService#analyze_task_failure(task, task_result, context)` handles two failure patterns:

| Error string contains | Resolution method | Additional resources |
|---|---|---|
| `'resource'` | `'resource_reallocation'` | `{ 'spare_parts' => 10 }` |
| `'equipment'` | `'equipment_repair'` | `{ 'tools' => 5 }` |
| anything else | `can_resolve: false` | — |

---

## 6. AI Manager ↔ Market Integration Status

The `Market::Condition` model contains an explicit TODO: `Integrate with AIManager for automated buy/sell order listing and placement`. As of Phase 3, **this integration does not exist**. The `AutonomousConstructionManager` has no calls into `Market::Marketplace`, `Market::Condition`, or `Market::Order`. The two systems are currently independent.

The intended integration path — where the AI manager posts buy orders for construction resources through the marketplace — is the bridge that will connect pre-player bootstrapping to the live market price signals. This must be implemented before the AI manager can respond to real resource scarcity.

---

## 7. Gap Tracking & Known Issues

- [ ] **`find_matching_orders` order_type string comparison bug:** `new_order.order_type == 'Sell'` will not correctly match against the `{ buy: 0, sell: 1 }` enum. Should be `new_order.sell?`. Needs a fix and a covering spec before any sell-side matching logic is relied upon.
- [ ] **Buy-side order matching not implemented:** `find_matching_orders` returns `[]` for all non-Sell orders. NPC sell-to-player matching does not exist yet.
- [ ] **NPC buy capacity hardcoded at 1000:** `npc_capacity = 1000` in `find_matching_orders` is noted as a TODO. Should be driven by settlement state or a configurable market parameter.
- [ ] **`supply` and `demand` on `Market::Condition` not confirmed:** These fields are referenced in a comment as `"etc."` but are not confirmed as actual database columns. Schema migration must be checked before any code queries these fields.
- [ ] **`Market::SupplyChain` not found in source:** Referenced in Gemini's brief but not present in any uploaded source file. Confirm whether this model exists before documenting it.
- [ ] **`AutonomousConstructionManager` uses `StubAIService`:** All task success rates are simulated with `rand`. No real construction logic, resource checks, or settlement state queries are performed. Full implementation required before production use.
- [ ] **`learn_from_phase_execution` has no persistence:** Learning data is logged only. No database writes or knowledge base updates occur. AI learning is scaffolded but not functional.
- [ ] **AI Manager ↔ Market integration missing:** `AutonomousConstructionManager` does not interact with `Market::Marketplace` or `Market::Condition`. The TODO in `Market::Condition` must be actioned before pre-player bootstrapping can use live market price signals.
- [ ] **`Market::NpcPriceCalculator` and `Market::TradeExecutionService` source not reviewed:** Both services are central to price determination and trade execution but their source files have not been uploaded for review. Wiki documentation of their behaviour is based on call signatures only.
- [ ] **GCC decoupling mechanism not implemented:** `GCC_TO_USD_INITIAL = 1.0` enforces the bootstrap peg but no decoupling trigger or volume threshold logic has been found in source. This must be designed and documented before the peg is expected to float.

---

*Last verified against: `app/models/market/marketplace.rb`, `app/models/market/condition.rb`, `app/models/market/order.rb`, `lib/ai_manager/autonomous_construction_manager.rb`, `config/initializers/game_constants.rb` — Phase 3 (Integration & Restoration)*
