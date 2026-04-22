# Logistics Architecture Spec
**Location**: `docs/architecture/logistics/logistics_architecture.md`
**Status**: Canonical — required reading before touching any logistics, import, or transport code
**Written**: 2026-04-21
**Authority**: Session Strategist + developer design decisions 2026-04-21

> This document captures the full logistics vision for the game.
> Luna-scoped implementation is described explicitly.
> Future phases are captured as context — do not implement ahead of schedule.
> If code contradicts this document, the code is wrong.
> Do not change this document during an implementation task — flag and escalate.

---

## Overview — What Logistics Is

Logistics is the movement of resources and cargo between locations.
It is fundamentally different from manufacturing (Job model) and must never
be modeled as a production job.

| Concept | Model | What it is |
|---|---|---|
| Manufacturing | `Job` | Blueprint execution, local materials, timer, claim output |
| Logistics | `ImportOrder` → `CyclerShipment` | Movement of goods between nodes |
| Market | `MarketOrder` | Buy/sell listings at a settlement |
| Mission | `Mission` | Player task with reward |

An `earth_import` is **not** a Job. It is an ImportOrder.
A cycler manifest is **not** a Job. It is a scheduled batch of ImportOrders.
Never create a `Job` record for resource transit. Ever.

---

## Three-Tier Transport Model

### Tier 1 — Local / Small Craft
**Scope**: Sub-planetary, cis-lunar, same-world base-to-base, orbital transfers
**Examples**: Earth ↔ Luna, Luna ↔ L1 station, base ↔ base on same world
**Operators**: Players (primary), AstroLift feeder runs (NPC)
**Cargo**: Small, frequent, player-scale
**Key mechanic**: Can rendezvous with cyclers at meetup points to transfer cargo or dock and ride along

### Tier 2 — Cycler Rendezvous
**Scope**: The handoff point between local craft and the interplanetary cycler network
**What it is**: A time-windowed meetup point in space where small craft intercept a passing cycler
**Window**: Opens and closes on a schedule — miss it, wait for next pass
**Options for players**:
- Fly own craft to meetup point, transfer cargo to cycler
- Dock own craft to cycler and ride along to destination
- Book cargo space on cycler without flying to meetup (AstroLift handles transfer)
- Sell cargo to AstroLift at origin (immediate GCC, AstroLift takes the margin)
- Hire another player to run the meetup on your behalf

**Key mechanic**: Timing skill and route knowledge create player skill expression.
A player who consistently hits meetup windows operates a more profitable logistics
business than one who always books AstroLift directly.

### Tier 3 — Cycler Network (Interplanetary)
**Scope**: Major world to major world only. Does not stop at moons, L-points, or stations.
**Examples**:
- Inner system: Earth → Mars → Venus (or optimal inner loop)
- Outer system: Mars → Titan → ? (route determined by expansion)
- Cross-system: wormhole network adds new routes as new systems open
**Operator**: AstroLift (owns and operates all cyclers)
**Cargo**: High volume, scheduled, manifest-driven
**Key mechanic**: AI Manager adjusts manifests per world needs. Players book
cargo space or transfer at rendezvous points.

---

## Earth Anchor Price (EAP)

**Definition**: EAP = Earth market price for an item + transport cost to destination

EAP is the AI Manager's price ceiling for market purchases. It will never pay
more than EAP because beyond that threshold it is cheaper to import from Earth directly.

**EAP is world-dependent**: Transport cost from Earth to Luna ≠ transport cost
from Earth to a belt asteroid. Each destination has its own EAP per item.

**EAP is item-dependent**: Earth market price varies by item type.

**EAP is calculated dynamically**: At AI Manager decision time, not stored on a model.
Snapshot the EAP value on `ImportOrder.eap_at_order_time` for audit purposes.

**Emergency override**: AI Manager can exceed EAP when `emergency: true`.
This is logged and tracked — the AI Manager dislikes emergency imports and
will adjust future planning to avoid situations that force them.

**EAP as market ceiling**: AstroLift enforces EAP structurally.
If any seller (player or NPC) prices above EAP, rational buyers will wait
for the next AstroLift shipment instead. This keeps the market honest.

---

## AstroLift Corporation

AstroLift is the seeded NPC corporation that owns and operates the cycler network.
It is the baseline market maker for interplanetary trade.

Full design: `docs/architecture/ai_manager/astrolift_corporation.md`

Key points for logistics modeling:
- AstroLift buys at surplus nodes, sells at deficit nodes
- AstroLift never pays above EAP (it sets EAP structurally)
- AstroLift manifest is AI Manager generated per cycler departure
- Players compete with AstroLift by being faster, cheaper, or more specialized
- AstroLift also runs local feeder craft to cycler meetup points

---

## AI Manager Escalation Ladder — Resource Acquisition

When the AI Manager needs a resource at a base, it follows this escalation sequence:

```
NEED: [item] at [destination]

Step 1 — Post buy order on market at destination
  Price ceiling: EAP
  Wait for order expiry
  ↓ nobody fills it

Step 2 — Offer player mission
  Deliver [item], bonus rewards
  Wait for expiry
  ↓ nobody takes it

Step 3 — Scan market for existing listings
  Can I buy [item] directly? Price <= EAP? → buy, done
  Can I buy input materials? Price <= EAP? → buy, then manufacture
  ↓ nothing available at or under EAP

Step 4 — Self-manufacture from local stock
  Check local inventory for all inputs in supply chain
  Manufacturing slots available?
  ↓ inputs not fully available locally

Step 5 — Dispatch robot harvesting fleet
  Run ISRU pipeline as needed
  raw_regolith → processed_regolith → depleted_regolith
  ↓ something in supply chain cannot be sourced locally at all

Step 6 — Import order
  Check if another base on network has the item or inputs
  Source from nearest surplus node
  Earth is always the fallback supplier of last resort
  emergency: true if critical — EAP ceiling bypassed
  AI Manager logs this as a supply chain failure
```

The AI Manager strongly prefers Steps 1-5. Step 6 is a last resort.
It tracks import frequency to identify chronic supply chain gaps
and adjusts long-term production planning accordingly.

---

## ImportOrder Model — Luna-First Implementation

### What It Is
An ImportOrder is a request to move a specific item from an origin settlement
to a destination settlement. It is fulfilled either by direct transport (Tier 1)
or by booking space on a cycler (Tier 3 via Tier 2 rendezvous).

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

### Luna-First Constraints
- `origin_settlement_id` references Earth as a seeded settlement record
- `arrives_at` calculated from a fixed Earth→Luna transit time constant
- No `route_id` yet — single route only
- No cycler manifest integration yet — direct import only
- Player cannot interact with ImportOrders in Phase 1 — AI Manager only

### Do Not
- Do not hardcode `origin: 'earth'` as a string — use `origin_settlement_id`
- Do not hardcode transit time as a magic number — use a named constant
  `EARTH_LUNA_TRANSIT_DAYS = 3` (or whatever is game-appropriate)
- Do not create a Job record for an import — it is never a Job

---

## CyclerRendezvous Model — Future (Phase 3)

Not implemented for Luna-first. Captured here for design continuity.

```ruby
CyclerRendezvous
  cycler_route_id
  meetup_location      # orbital coordinates or L-point reference  
  window_opens_at      # datetime — miss this, wait for next pass
  window_closes_at     # datetime
  cargo_capacity_remaining
```

Small craft dock or transfer cargo within the window.
Players who time meetup windows well operate more profitable logistics businesses.

---

## CyclerRoute Model — Future (Phase 3)

Not implemented for Luna-first. Captured here for design continuity.

```ruby
CyclerRoute
  name                 # 'Inner System Loop', 'Outer System Express'
  operator_id          # AstroLift corporation by default
  stops                # ordered list of world nodes
  schedule_days        # cycle time in days
  cargo_capacity_kg
  active               # boolean — routes activate as worlds open
```

Routes are flexible — AI Manager proposes new routes as new worlds open.
Wormhole network expansion adds new route possibilities.
Players can eventually own and operate competing cycler routes.

---

## AstroLift Manifest Logic — Future (Phase 3)

Not implemented for Luna-first. Captured here for design continuity.

For each cycler departure, AstroLift AI Manager:
1. Scans each stop for deficit items (demand > local supply)
2. Checks if a base on the route cannot produce a resource locally
3. Identifies surplus items at earlier stops
4. Builds manifest: buy at surplus nodes, sell at deficit nodes
5. Sets sell price = buy price + transport cost + margin (never exceeds EAP)
6. Adjusts manifest over time based on price history

Players can undercut AstroLift by:
- Producing locally before the cycler arrives
- Running their own Tier 1 craft faster than the cycler schedule
- Booking cargo space on cyclers and arbitraging between stops
- Specializing in items AstroLift doesn't prioritize

---

## Per-World Resource Profile — Future (Phase 3+)

Each world node will eventually need:
```
resource_profile      — what can be produced locally (world crust/atmosphere)
production_capacity   — current manufacturing capability  
population_demand     — consumption rates
deficit_items         — consistently needs imported
surplus_items         — consistently overproduces
connected_routes      — cycler stops + local transport links
price_history         — market data over time
```

This extends the existing `Settlement` operational data model.
Do not add these fields to `Settlement` until Phase 3 design is complete.

---

## Wormhole Network Integration — Future (Phase 4+)

Each wormhole opening is an economic shock event:
- New world node added to network
- AI Manager evaluates new world resource profile
- Proposes new cycler route or extends existing one
- New price discovery begins at new node
- EAP recalculates for all affected nodes
- Players who position early on new routes gain significant advantage

The logistics model is designed to extend naturally:
- `origin_settlement_id` works for any settlement, not just Earth
- `CyclerRoute.stops` is an ordered list — add stops as worlds open
- EAP calculation function takes distance as input — works for any distance

---

## Common Mistakes — Do Not Repeat

**Wrong**: Creating a `Job` record for an earth import or any resource transit.
Logistics is never a Job. Jobs are local production only.

**Wrong**: Hardcoding `origin: 'earth'` as a string.
Earth is a seeded `Settlement` record. Use `origin_settlement_id`.

**Wrong**: Modeling cycler cargo as a manufacturing job with `job_type: :logistics`.
Cycler cargo is a `CyclerShipment` (Phase 3), not a Job.

**Wrong**: Building cycler manifest logic before the Route model exists.
Implement ImportOrder first, Route + CyclerRoute in Phase 3.

**Wrong**: Assuming `resource/acquisition.rb` only handles manufacturing.
It currently handles both production jobs AND import orders conflated in
`ResourceJob`. They are being separated — production → `Job`, imports → `ImportOrder`.

**Wrong**: Assuming AstroLift is a special case.
AstroLift is the baseline market maker. Model it as a corporation NPC with
an AI Manager instance. Its behavior should emerge from the same AI Manager
logic as any other NPC corporation — just with cycler ownership as a capability.
