# AstroLift Corporation Spec
**Location**: `docs/architecture/ai_manager/astrolift_corporation.md`
**Status**: Canonical — required reading before touching AstroLift NPC logic
**Written**: 2026-04-21
**Authority**: Developer design decisions 2026-04-21

> AstroLift is not a special case hardcoded into the game engine.
> It is a seeded NPC corporation with an AI Manager instance.
> Its behavior emerges from the same AI Manager logic as any NPC corporation
> — it just has cycler ownership as a unique capability.
> Do not hardcode AstroLift behavior. Model it as data and AI Manager rules.

---

## Who AstroLift Is

AstroLift is the dominant interplanetary logistics corporation in the game world.
It owns and operates the cycler network — the backbone of interplanetary commerce.
It is the baseline market maker for all goods that move between major worlds.

AstroLift is not a government, not a regulator, and not a monopoly enforcer.
It is a rational economic actor that buys low, sells high, and runs scheduled
transit infrastructure because it is profitable to do so.

Players are not enemies of AstroLift. They compete with it, undercut it,
hire it, and eventually potentially rival it. AstroLift is the economic
baseline that gives player activity meaning — without AstroLift setting
price floors and ceilings, market prices would have no anchor.

---

## What AstroLift Owns

**Phase 1 — Luna-first**
- Earth-Luna transport route (Tier 1 / direct import)
- Seeded corporation record in database
- AI Manager instance with logistics specialization

**Phase 3 — Cycler Network**
- All cycler ships on all active routes
- Cycler meetup point scheduling
- Local feeder craft to meetup points at each world node

**What AstroLift Does NOT Own**
- Local settlement transport (players compete here)
- Manufacturing facilities (it buys, not makes)
- Market infrastructure (markets are settlement-owned)
- Wormhole gates (those are a separate entity)

---

## AstroLift's AI Manager Behavior

AstroLift's AI Manager operates at the **network level**, not the base level.
It sees the entire trade network and optimizes across all nodes simultaneously.

### Core Loop (runs on schedule)

```
For each active cycler departure:
  1. Scan all stops for deficit items
     deficit = demand > (local supply + pending production)
  
  2. Identify surplus items at other stops on the route
     surplus = supply > demand + safety stock threshold
  
  3. Check if any base cannot produce a resource locally
     → Add to manifest as standing import from nearest producer
  
  4. Build manifest:
     buy_orders = surplus nodes (AstroLift buys before departure)
     sell_orders = deficit nodes (AstroLift sells on arrival)
  
  5. Price setting:
     buy price = local market price at surplus node (or EAP if no market)
     sell price = buy price + transport cost per kg + margin
     sell price NEVER exceeds EAP at destination
  
  6. Post market listings at each stop on arrival
```

### Manifest Adjustment Over Time

AstroLift's AI Manager tracks price history and adjusts manifests:
- Items with falling prices at destination → reduce manifest quantity
- Items with rising prices at destination → increase manifest quantity
- Chronic deficits at a node → flag for route adjustment or new route proposal
- New world opens → evaluate resource profile, propose route extension

### Import Order Behavior (Phase 1 / Luna-first)

Before the cycler network exists, AstroLift handles Earth→Luna imports directly:

```
AstroLift places ImportOrder when:
  - Luna settlement has chronic deficit for an item
  - No local production path exists
  - AI Manager escalation ladder reaches Step 6
  - emergency: true if settlement is critically short

ImportOrder cost = Earth price + EARTH_LUNA_TRANSIT_COST_PER_KG * quantity
AstroLift sells on arrival at cost + margin, never above EAP
```

---

## EAP — AstroLift's Role

AstroLift structurally enforces EAP across all markets it serves.

**Why**: If any seller prices above EAP, rational buyers wait for the next
AstroLift shipment. AstroLift's presence makes pricing above EAP irrational.

**Implication for players**: Players cannot sustainably price above EAP.
They compete by being faster (before cycler arrives), cheaper (undercut margin),
or more specialized (items AstroLift doesn't carry on its manifest).

**Implication for AI Manager**: AstroLift's own AI Manager never prices above
EAP because it is the entity that defines EAP. It sets prices at
`cost + margin ≤ EAP`. If it cannot be profitable at EAP, it stops carrying
that item and lets the market find another solution.

---

## Player Competition Model

Players can compete with AstroLift in several ways:

**Undercut on speed**
AstroLift cyclers run on fixed schedules. A player who spots a shortage
mid-cycle and delivers before the next cycler arrives captures premium pricing.
Window closes when AstroLift arrives and normalizes price.

**Undercut on price**
Produce locally for less than AstroLift's delivered price.
Requires efficient local ISRU + manufacturing.
This is the core driver for building up Luna's production capacity.

**Arbitrage**
Buy cheap at one node, transport on own craft, sell before AstroLift.
Requires route knowledge and timing skill.
Players who master meetup windows do this profitably.

**Specialization**
Produce items AstroLift doesn't prioritize on its manifest.
Niche goods, high-value low-volume items, custom components.
AstroLift optimizes for volume — players exploit the long tail.

**Own cycler routes (Phase 3+)**
Players can eventually own and operate competing cycler ships.
Run routes AstroLift ignores, or compete directly on high-volume routes.
Becomes a significant late-game player economy path.

---

## Seeding AstroLift in the Database

AstroLift must be seeded as a corporation record before any logistics code runs.

```ruby
# db/seeds.rb or a dedicated seed file
astrolift = Corporation.find_or_create_by!(identifier: 'astrolift') do |corp|
  corp.name = 'AstroLift Logistics'
  corp.corporation_type = :logistics_provider
  corp.description = 'Interplanetary logistics corporation. Owns and operates the cycler network.'
  corp.ai_managed = true
end

# Earth settlement — origin for all Earth imports
earth = Settlement::BaseSettlement.find_or_create_by!(identifier: 'earth_depot') do |s|
  s.name = 'Earth Depot'
  s.settlement_type = :logistics_hub
  s.owner = astrolift
end
```

⚠️ The exact class names and attributes above may need adjustment to match
the actual Settlement and Corporation model schemas. Check before seeding.

---

## What AstroLift Is NOT

**Not a hardcoded special case**: All AstroLift behavior should emerge from
AI Manager rules applied to its corporation record. Do not write
`if corporation.name == 'AstroLift'` anywhere.

**Not the only logistics provider**: Other NPC corporations can operate
local transport. Players can eventually operate cycler routes.
AstroLift is dominant, not exclusive.

**Not omniscient**: AstroLift's AI Manager operates on the same information
available to any AI Manager — settlement inventories, market listings, price
history. It does not have god-mode access to player plans.

**Not punitive**: AstroLift does not deliberately undercut players or respond
to player competition. It follows its own optimization logic. If a player
undercuts AstroLift, AstroLift adjusts its manifest over time — it doesn't
retaliate.

---

## Phase Roadmap

| Phase | AstroLift Capability |
|---|---|
| 1 — Luna | Seeded corporation, Earth→Luna ImportOrders, AI Manager escalation |
| 2 — Cis-Lunar | Local feeder craft, L1 waypoint routes, price history tracking |
| 3 — Cycler Network | CyclerRoute model, manifest generation, rendezvous scheduling |
| 4 — Expansion | Route proposals for new worlds, wormhole network integration |
| Future | Player-owned competing cycler routes |

---

## Dependencies
- `Corporation` model must exist and support `ai_managed: true`
- `Settlement` model must support `settlement_type: :logistics_hub`
- `ImportOrder` model (see `docs/architecture/logistics/logistics_architecture.md`)
- AI Manager infrastructure for NPC corporation instances
