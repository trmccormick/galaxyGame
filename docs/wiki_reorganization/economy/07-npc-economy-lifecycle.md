# NPC Economy Lifecycle & Data Models

**Status**: Reference (agent documentation)  
**Last Updated**: 2026-09-11  
**Supersedes**: `economy_models.md`, `npc_economy_lifecycle.md`  
**Derived from**: `economy_models.md` + `npc_economy_lifecycle.md`

---

## Part A: Data Model Inventory

### Economy Models Documentation

This document describes all data models involved in the NPC economy lifecycle. Models span three namespaces: `Market`, `Logistics`, and top-level `PlayerContract`. All statements are backed by code evidence from models, migrations, and specs.

---

### Market Namespace Models

#### Market::Marketplace

**Table**: `market_marketplaces`

**Purpose**: Represents a marketplace associated with a settlement. Acts as the entry point for order placement and trade matching.

**Associations:**
```ruby
belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
has_many :market_conditions, class_name: 'Market::Condition', foreign_key: :market_marketplace_id, dependent: :destroy
has_many :prices, through: :market_conditions
has_many :orders, through: :market_conditions, source: :orders
```

**Key Methods:**
| Method | Return | Description |
|---|---|---|
| `get_price(item, seller:, demand:)` | Float | Static price lookup — delegates to `NpcPriceCalculator.calculate_ask` |
| `place_order(params)` | Market::Order or nil | Creates order, matches against counter-orders, returns unmatched portion |
| `execute_trades(sell_order, matching_orders)` | void | Delegates to `TradeExecutionService.execute!` |
| `find_matching_orders(new_order)` | Array[OpenStruct] | Finds NPC buy orders for sell orders only; returns [] for buy orders |
| `create_synthetic_npc_order(...)` | OpenStruct | Creates synthetic NPC counter-order for matching |

**Migration history:**
- `20250214213217_create_market_marketplaces.rb` — initial table (name, timestamps)
- `20260112003325_add_settlement_id_to_market_marketplaces.rb` — added settlement FK

---

#### Market::Condition

**Table**: `market_conditions`

**Purpose**: Represents a resource's current state within a marketplace (price, supply, demand). Acts as the bridge between marketplaces and their orders/prices.

**Associations:**
```ruby
belongs_to :marketplace, class_name: 'Market::Marketplace', foreign_key: :market_marketplace_id
has_many :market_orders, class_name: 'Market::Order', foreign_key: :market_condition_id, dependent: :destroy
has_many :orders, class_name: 'Market::Order', foreign_key: :market_condition_id, dependent: :destroy
```

---

## Part B: NPC Economy Lifecycle Phases

### Overview

The NPC economy is a core gameplay loop where AI-managed NPCs initialize pricing, create buy/sell orders, and players can accept contracts to keep the economy moving. The system spans multiple service namespaces: the **AI Manager** drives economic decisions (pricing, order creation, market stabilization), while **NPC Economy services** act as consumers of those decisions.

The lifecycle flows through five phases: NPC Initialization → Price Setting (AI Manager) → Order Creation → Player Contract Acceptance → Fallback Mechanisms. Each phase is implemented across multiple files — there is no single "economy service" that encapsulates everything.

---

### Phase 1: NPC Initialization

**How NPCs enter the economy:**

NPCs in the galaxy_game economy are represented as **Settlement::BaseSettlement** entities with associated organizations (corporations, factions). They are initialized through:

- **AI Manager initialization**: `AIManager::Manager` is instantiated per settlement entity, coordinating all economic behavior for that settlement.
  - File: `app/services/ai_manager/manager.rb`
  
- **Service coordination**: Each AI Manager registers a `ServiceCoordinator` that manages missions, resource acquisition, and scouting.
  - File: `app/services/ai_manager/service_coordinator.rb`

- **Colony management**: `AIManager::ColonyManager` tracks all NPC colonies and the player colony, delegating autonomous tasks to each.
  - File: `app/services/ai_manager/ai_colony_manager.rb`

**NPC Roles:**
- **Buyer of last resort**: Purchases unsold player goods at fair minimum price
- **Producer of last resort**: Manufactures essential items when player production lags
- **Importer of last resort**: Sources items from various locations during shortages
- **Market maker**: Provides continuous bid/ask quotes via `NpcPriceCalculator`

**Key behavior:**
```ruby
# AI Manager tick loop (called each game tick)
def advance_time
  @service_orchestrator.orchestrate_services
  @strategy_selector.evaluate_next_action(@target_entity)
end
```

---

### Phase 2: Price Setting (AI Manager)

**How AI determines initial prices:**

Pricing is handled by `Market::NpcPriceCalculator` which supports two pricing modes:

1. **ISRU mode**: If settlement has local production, price = 95% of import cost
2. **Import mode**: If no local ISRU, price = baseline + transport cost

---

### Phase 3: Order Creation

NPCs create buy/sell orders based on their needs and the current market state. Orders are posted to the marketplace and become visible to players.

---

### Phase 4: Player Contract Acceptance

Players can accept NPC contracts within a time window. If no player accepts, the contract falls back to NPC execution.

---

### Phase 5: Fallback Mechanisms

If players don't fill orders within timeout windows, NPCs automatically fulfill them to maintain game progression. This ensures the economy never stalls.
