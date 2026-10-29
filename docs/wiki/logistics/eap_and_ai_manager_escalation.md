# Earth Anchor Price (EAP) & AI Manager Escalation

> **Wiki section:** Logistics · **Status:** target design intent — canonical architecture spec for pricing ceilings, import models, and AI decision escalation; no runtime enforcement currently exists.

> **Cross-link:** For how terraforming demand is financed through GCC budgets, Seed vs. Brute-Force contracts, and player economic participation, see **[Terraforming Economic Integration](./terraforming_economic_integration.md)**.

> **Cross-link:** For the hard physical mechanics of Venusian CO₂ cracking, CNT pod manufacturing, and mass driver ballistics, see **[Venus–Mars Ballistic Corridor (Brute-Force Loop)](../technical/venus_mars_ballistic_corridor.md)**.

---

## Scope

This document defines two foundational logistics mechanisms: the **Earth Anchor Price** (EAP), which is the AI Manager's hard price ceiling for all market purchases, and the **AI Manager Escalation Ladder**, which is the strict 6-step sequence the AI follows to acquire any needed resource. Together they form the economic backbone of every terraforming contract, buy order, and cycler shipment in the game.

**Authority:** This document promulgates requirements from `docs/architecture/logistics/logistics_architecture.md`. If code contradicts these rules, the code is wrong.

---

## 1. Earth Anchor Price (EAP) Dynamic Ceiling

### Definition

EAP = **Earth market price for an item + transport cost to destination**

EAP is the AI Manager's absolute price ceiling for all market purchases at a given settlement. The AI will never pay more than EAP because beyond that threshold it is cheaper to import from Earth directly.

### Key Properties

| Property | Detail |
|----------|--------|
| **World-dependent** | Transport cost from Earth to Luna ≠ transport cost from Earth to a belt asteroid. Each destination has its own EAP per item. |
| **Item-dependent** | Earth market price varies by item type (raw materials, refined goods, electronics). |
| **Calculated dynamically** | Computed at AI Manager decision time — never stored as a static value. |
| **Audited via snapshot** | Snapshot the EAP value on `ImportOrder.eap_at_order_time` for audit purposes. |

### Emergency Override

```ruby
# Normal behavior: strictly enforced
cost <= eap  # True → AI Manager proceeds with purchase

# Emergency override: explicitly logged and tracked
emergency: true  # AI Manager exceeds EAP — logs supply chain failure
```

The AI Manager **dislikes emergency imports** and adjusts future long-term planning to avoid situations that force them. Every emergency purchase is logged and tracked for chronic gap analysis.

### EAP as Structural Market Ceiling

AstroLift enforces EAP structurally across the entire market: if any seller (player or NPC) prices above EAP, rational buyers will wait for the next AstroLift shipment instead. This keeps the market honest regardless of individual seller pricing behavior.

---

## 2. AI Manager 6-Step Escalation Ladder

When the AI Manager needs a resource at a base, it follows this **strict escalation sequence**. It cannot skip steps or jump ahead — each step's failure triggers the next.

```
NEED: [item] at [destination]

Step 1 — Post buy order on market at destination
  Price ceiling: EAP
  
  ↓ nobody fills it (order expires)

Step 2 — Offer player mission
  Deliver [item], bonus rewards
  
  ↓ nobody takes it (mission expires)

Step 3 — Scan market for existing listings
  Can I buy [item] directly? Price <= EAP? → buy, done
  Can I buy input materials? Price <= EAP? → buy, then manufacture
  
  ↓ nothing available at or under EAP

Step 4 — Self-manufacture from local stock
  Check local inventory for all inputs in supply chain
  Manufacturing slots available?
  
  ↓ inputs not fully available locally

Step 5 — Dispatch robot harvesting fleet
  Run ISRU pipeline: raw_regolith → processed_regolith → depleted_regolith
  
  ↓ something in supply chain cannot be sourced locally at all

Step 6 — Import order (LAST RESORT)
  Check if another base on network has the item or inputs
  Source from nearest surplus node
  Earth is always the fallback supplier of last resort
  emergency: true if critical → EAP ceiling bypassed
  
  ⚠ AI Manager logs this as a supply chain failure
```

### Chronic Gap Analysis

The AI Manager tracks **import frequency** at Step 6 to identify chronic supply chain gaps and adjusts long-term production planning accordingly. Frequent imports of a given item signal the need for local infrastructure investment (Step 4/5 capability) rather than perpetual import dependency.

---

## 3. ImportOrder Data Schema

### What It Is

An `ImportOrder` is a request to move a specific item from an origin settlement to a destination settlement. It is fulfilled either by direct transport (Tier 1) or by booking space on a cycler (Tier 3 via Tier 2 rendezvous).

**Critical constraint:** An ImportOrder is **never** a `Job` record. It represents the movement of goods, not local production.

### Schema

```ruby
# db/migrate/TIMESTAMP_create_import_orders.rb
create_table :import_orders do |t|
  t.references :destination_settlement, null: false,
               foreign_key: { to_table: :settlements }
  t.references :origin_settlement, null: false,
               foreign_key: { to_table: :settlements }
  t.references :initiated_by, polymorphic: true, null: false
  t.string :item_type, null: false
  t.integer :quantity, null: false
  t.integer :status, default: 0, null: false
  t.decimal :cost_gcc, precision: 12, scale: 2
  t.decimal :eap_at_order_time, precision: 12, scale: 2
  t.boolean :emergency, default: false, null: false
  t.datetime :arrives_at
  t.timestamps
end

add_index :import_orders, :status
add_index :import_orders, [:destination_settlement_id, :status]
add_index :import_orders, [:initiated_by_type, :initiated_by_id]
```

### Status Lifecycle

```
pending → in_transit → delivered
        ↘ cancelled
```

### Do Not Violate

| Rule | Rationale |
|------|-----------|
| Do not hardcode `origin: 'earth'` as a string | Use `origin_settlement_id` for flexibility |
| Do not hardcode transit time as a magic number | Use named constant (e.g., `EARTH_LUNA_TRANSIT_DAYS = 3`) |
| Do not create a Job record for an import | ImportOrder ≠ Job — they represent fundamentally different concepts |

---

## 4. AstroLift Role in the Economic Engine

### Baseline Market Maker

**AstroLift** is the seeded NPC corporation that owns and operates the cycler network. It establishes structural market conditions:

| Function | Detail |
|----------|--------|
| Buys at surplus nodes, sells at deficit nodes | Core arbitrage mechanism across Sol |
| Never pays above EAP | Sets EAP structurally for the entire market |
| Manifest generated by AI Manager per cycler departure | Every departure has a computed cargo plan |
| Runs local feeder craft to cycler meetup points | Connects Tier 1 and Tier 3 transport |
| Competes with players | Players must be faster, cheaper, or more specialized |

### Player Competition Dynamics

Players compete with AstroLift by offering:
- **Lower prices** (under EAP, above AstroLift's buy price)
- **Faster delivery** (bypassing AstroLift's cycler schedule)
- **Specialization** (items AstroLift doesn't carry or isn't incentivized to source)

The **1.5× GCC multiplier** for player-filled orders (vs. NPC baseline) ensures players can earn profit while undercutting AstroLift on total cost.

---

## 5. Luna-First Constraints (Phase 1)

During the initial Phase 1 implementation scope:

| Constraint | Detail |
|------------|--------|
| Origin settlement | References Earth as a seeded settlement record |
| Transit time | Calculated from fixed Earth→Luna transit time constant |
| Route ID | No `route_id` yet — single route only |
| Cycler manifest integration | Not yet implemented — direct import only |
| Player interaction | Phase 1: AI Manager only; players interact via missions, not ImportOrders directly |

---

*Last verified against: `docs/architecture/logistics/logistics_architecture.md` — canonical architecture spec. No runtime enforcement currently exists.*
