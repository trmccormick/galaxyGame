# AI Manager: Resupply & Escalation Architecture

**Status:** Authoritative design document  
**Date:** March 18, 2026  
**Author:** Planning Agent (Claude)  
**Intended Audience:** All agents, developers — read before touching EscalationService,
EmergencyMissionService, or any escalation spec

---

## Purpose

This document defines how the AI Manager handles resource shortages — from
detecting an expired buy order through deciding whether to escalate to an
emergency mission or add it to the next resupply manifest.

It exists because previous agents implemented `EscalationService` as a
standalone decision engine with hardcoded material classifications. That
approach cannot model a living universe where the same material can be
an emergency or a routine resupply item depending on settlement state.

**The AI Manager does not hardcode which materials are emergencies.
It evaluates the current state of the settlement and decides.**

---

## Core Principle: Earth as Supplier of Last Resort

Earth can supply anything. It may not be the cheapest or fastest, but a
colony can always get what it needs from Earth. There is no dead end in
the supply chain — only varying costs and delivery times.

This means:
- Emergency missions are about **speed**, not availability
- The resupply manifest is always buildable
- The AI Manager's job is to minimize time-to-resolution given current state

---

## Proactive Management: The Primary System

The AI Manager's goal is to **prevent shortages**, not react to them.
Escalation is the exception handler — it fires when proactive management
wasn't enough. At a well-managed settlement, critical resources should
never reach zero.

### The Seed Pattern

The initial mission JSON files are not just deployment instructions.
They are the **seed pattern** that teaches the AI Manager what a healthy
settlement looks like from day one:

- Deploy power grid and comms before anything else
- Build the tank farm before population arrives
- Start ISRU immediately — water, oxygen, volatiles
- Deploy robots in priority order (CAR-300 first, HRV-400 early)
- Build food production as population grows
- Expand storage as production increases
- Generate GCC to fund the next phase

The AI Manager learns from this pattern and scales it:

```
Phase 1 (precursor, no population):
  → Tank farm building, ISRU active, power stable
  → No people yet but everything ready for arrival

Phase 2 (early population, 20-500):
  → Greenhouse online, food production active
  → Buffer stock maintained for all critical resources
  → GCC coming in from market participation

Phase 3 (growth, 500-5000):
  → More greenhouses, more robots, more storage
  → Inter-settlement trade beginning
  → Expansion funded by GCC surplus

Phase N (mature):
  → Settlement self-sufficient for core resources
  → Exporting surplus to other settlements
  → Earth imports minimal or zero for basic materials
```

### Proactive Ordering

The AI Manager continuously monitors stock against consumption rate
and orders ahead of need — not when empty:

```
projected_stock_at_next_resupply_window < buffer_threshold?
  YES → order now
  NO  → continue monitoring
```

Buffer thresholds are learned from patterns and refined over time
by `PerformanceTracker`. The AI Manager gets better at predicting
consumption rates as operational data accumulates.

### GCC as a Constraint

The AI Manager manages a real budget. Every decision has a cost:
- Resupply contracts cost GCC
- Emergency missions cost more GCC (2x multiplier)
- ISRU is free once deployed but requires upfront investment
- Logistics providers charge route-dependent rates

Priority when GCC is low:
1. Keep humans alive (non-negotiable)
2. Maintain revenue-generating operations
3. Defer expansion until surplus restored

This is why `debt_repayment` is a Tier 1 priority in `AI_PRIORITY_SYSTEM.md`
— a settlement that runs out of GCC cannot fund emergency missions and
enters the most dangerous failure state in the game.

### When Escalation Fires

Escalation fires when proactive management wasn't enough:
- Unexpected equipment failure depleted a resource faster than predicted
- Supply chain disruption (wormhole instability, provider failure)
- Consumption spike from population growth outpacing production
- New settlement where patterns haven't been learned yet

For critical resources at a mature, well-managed settlement, escalation
should be rare. For new settlements in early phases, it may fire more
often as the AI Manager is still learning the local patterns.

---

## The Core Decision

When a buy order expires unfulfilled, the AI Manager asks one question:

```
Are humans present at this settlement?

  NO →
    Standby mode:
    - Assess what is broken or missing
    - Determine what operations can still run
    - Manage around the shortage with available resources
    - Add shortage to resupply manifest
    - Wait for next scheduled resupply

  YES →
    time_to_critical(settlement, resource) < time_to_next_resupply(settlement)?

      NO  → Add to resupply manifest, manage around shortage
      YES → Emergency response (player-first, NPC fallback)
```

**Standby mode does not mean no work is done.** The AI Manager continues
operating the settlement with whatever is available. It assesses what is
broken or missing, determines what can still function, suspends what cannot,
and builds the resupply manifest to restore full operations. Robots continue
their tasks where possible. Systems that depend on the missing resource are
managed down gracefully.

---

## Standby Mode: Managing Around a Shortage

When a resource is unavailable and no humans are present (or resupply
arrives before the critical threshold):

1. **Assess impact** — which systems and operations depend on this resource?
2. **Prioritize** — what keeps running, what gets suspended?
3. **Manage down gracefully** — reduce consumption where possible
4. **Continue available work** — robots keep doing what they can
5. **Build resupply manifest** — add shortage to next scheduled manifest

The AI Manager does not panic. It manages the settlement in a degraded
state until supplies arrive, then restores full operations. This is
pattern-driven — the AI Manager learns over time what the right
degraded-mode configuration looks like for each settlement type and phase.

---

## Resupply Manifest: The AI Manager's Living Plan

The resupply manifest is not a fixed list. It is built and updated
continuously by the AI Manager based on actual operational state:

```
Current stock
+ Consumption rate → projected shortfall by next resupply window
+ Broken/degraded equipment → parts and materials needed for repair
+ Planned expansion → additional requirements beyond current operations
+ Pattern learning → what a settlement at this phase typically needs
= Resupply manifest
```

The initial mission JSON files (`npc_base_deploy_manifest_v3.json` etc.)
are the **starting point** — the templates the AI Manager learns from.
As the settlement operates, the AI Manager generates its own manifests
dynamically, improving accuracy over time through `PerformanceTracker`
and the pattern learning system.

When a resupply ship is dispatched, the manifest becomes a logistics
contract. Players see this contract and can fulfill it for GCC —
player-first, NPC fallback if no player responds.

---

## Emergency Response: When Time Is the Problem

Emergency response triggers when humans are present AND the shortage
will become critical before the next resupply can arrive.

**This is a time calculation, not a material classification:**

```ruby
def self.emergency_required?(settlement, resource)
  return false unless humans_present?(settlement)

  ttc = time_to_critical(settlement, resource)
  ttr = time_to_next_resupply(settlement)

  return false unless ttc < ttr

  # Settlement must be able to fund the emergency mission reward.
  # If GCC account is negative, the AI Manager cannot post an emergency
  # mission. This is the most dangerous compounding failure state —
  # no GCC means no emergency procurement means life support at risk.
  # See: AI_PRIORITY_SYSTEM.md — debt_repayment is Tier 1 critical
  # specifically to prevent reaching this state.
  #
  # When GCC is insufficient: skip player offer, dispatch NPC directly
  # via Virtual Ledger if available, escalate to LDC sponsor if not.
  return true if settlement_can_fund_emergency?(settlement, resource)

  # Cannot fund player mission — log the financial distress and
  # attempt NPC dispatch via Virtual Ledger instead
  Rails.logger.warn "[EscalationService] Settlement #{settlement.id} " \
                    "cannot fund emergency mission for #{resource} — " \
                    "financial distress state"
  true # Still an emergency, just handled differently
end

def self.settlement_can_fund_emergency?(settlement, resource)
  # Use EmergencyMissionService reward calculation to check affordability
  reward = EmergencyMissionService.calculate_emergency_reward(resource.to_sym)
  required = reward * 1.2 # 20% buffer per EmergencyMissionService design

  gcc_currency = Financial::Currency.find_by(symbol: 'GCC')
  return false unless gcc_currency

  account = Financial::Account.find_or_create_for_entity_and_currency(
    accountable_entity: settlement,
    currency: gcc_currency
  )

  account.balance >= required
rescue => e
  Rails.logger.error "[EscalationService] GCC check failed: #{e.message}"
  false
end
```

**Note on financial distress:** When a settlement cannot fund an emergency
mission, the AI Manager has limited options — request emergency capital
from the sponsoring DC (LDC), attempt local production even if slow,
or reduce non-critical consumption to extend reserves. This failure state
is tracked in `AiDecisionLog` and surfaces as a priority alert.
See `AI_MANAGER_CONSTRUCTION_ECONOMICS.md` Section 5.

The same resource — `robot_repair_kit`, `medicine`, `food` — can be
an emergency or a routine resupply depending on:
- Current stock level
- Current consumption or degradation rate
- When the next resupply is scheduled
- Whether humans are present

**The pattern learning system improves these calculations over time:**
- Learns typical consumption rates for each settlement phase
- Learns what buffer stock prevents emergencies
- Learns optimal resupply cadence for each settlement type
- Builds more accurate `time_to_critical` predictions as operational
  data accumulates

---

## Emergency Mission Flow (Player-First)

When emergency response is required:

1. **Re-offer to players** as urgent contract with premium GCC reward
   - Shortened response window (hours, not days)
   - Displayed prominently as CRITICAL on mission board
   - 2x base GCC multiplier for urgency

2. **NPC fallback** if no player response
   - Logistics provider dispatched (AstroLift / Vector / Zenith)
   - Earth as backstop if no regional provider available
   - Virtual Ledger used if settlement GCC is insufficient

3. **Settlement manages in degraded state** until delivery arrives
   - AI Manager continues standby mode operations
   - Humans protected via priority resource allocation
   - Non-critical systems suspended to extend reserves

---

## EscalationService: Correct Role

`EscalationService` is the **trigger layer** — it detects expired orders
and routes them into the AI Manager's decision system. It is not a
decision engine itself.

Its job:
1. Detect expired buy orders
2. Gather settlement context (population, stock levels, consumption,
   resupply schedule)
3. Ask `emergency_required?`
4. Route to emergency response OR resupply manifest update
5. Emit `:resource_crisis` event to `SystemOrchestrator` for
   system-wide awareness

```ruby
def self.handle_expired_buy_orders(expired_orders)
  expired_orders.each do |order|
    settlement = order.base_settlement
    resource = order.resource

    # Notify system orchestrator of the shortage
    emit_crisis_event(settlement, resource)

    if emergency_required?(settlement, resource)
      create_special_mission_for_order(order)
    else
      add_to_resupply_manifest(order)
    end
  end
end
```

The strategy details — ISRU vs import vs emergency — emerge from the
AI Manager's priority and pattern systems, not from hardcoded logic
in this service.

---

## ISRU-First Within Emergency Response

When emergency response is triggered, the AI Manager still applies
ISRU-first logic before dispatching an import:

```
Can this resource be produced locally right now?
  YES → assign task to available robot, monitor production rate
        if production rate meets need → downgrade to resupply manifest
        if production rate insufficient → proceed with emergency import

  NO  → emergency import / player mission
```

Local production is always preferred when available. The `can_harvest_locally?`
check remains valid — but it is evaluated as part of the emergency
response, not as a separate routing decision before it.

---

## The Robot System and Escalation

Robots are not created by the escalation service. They are physical
units that exist in the settlement — either imported on the deployment
manifest or manufactured later via a `robotics_assembly_line` facility.

The initial deployment ships a specific robot fleet (HRV-400, CAR-300,
SMR-500, MRR-100, LTR-100) on the Starship manifest. The AI Manager
knows what robots are present, what tasks they are performing, and what
their operational state is. This is settlement state data — not something
escalation creates.

When a resource shortage affects robot operations, the AI Manager:
1. Assesses which robots are affected and how
2. Determines which tasks can still be performed with remaining capability
3. Reassigns available robots to highest-priority tasks
4. Adds repair materials to the resupply manifest
5. If humans are at risk before resupply arrives → emergency mission

`Units::Robot.create!` is never called by the escalation service.

---

## What the Tests Should Verify

The existing failing tests expect `Units::Robot.count` to change. This
is architecturally wrong — robots are not created by escalation.

The correct tests verify the routing decision:

### Test 1 — No humans: shortage goes to resupply manifest

```
Given: Settlement with no population
Given: Expired buy order for any resource
When: handle_expired_buy_orders called
Then: No emergency mission created
Then: add_to_resupply_manifest called
```

### Test 2 — Humans present, resupply arrives in time: manifest

```
Given: Occupied settlement
Given: time_to_critical > time_to_next_resupply
Given: Expired buy order for robot_repair_kit
When: handle_expired_buy_orders called
Then: No emergency mission created
Then: add_to_resupply_manifest called
```

### Test 3 — Humans present, critical before resupply: emergency

```
Given: Occupied settlement
Given: time_to_critical < time_to_next_resupply
Given: Expired buy order for medicine
When: handle_expired_buy_orders called
Then: EmergencyMissionService.create_emergency_mission called
Then: mission[:resource_type] == :medicine
Then: mission is not nil
```

### Test 4 — No humans, broken equipment: standby mode

```
Given: Unoccupied settlement
Given: Expired buy order for robot_repair_kit
When: handle_expired_buy_orders called
Then: No emergency mission
Then: add_to_resupply_manifest called
```

---

## Current Implementation Status

| Feature | Status | Notes |
|---|---|---|
| Expired order detection | ✅ Works | `handle_expired_buy_orders` |
| ISRU local check | ✅ Works | `can_harvest_locally?` |
| Scheduled import | ✅ Works | `schedule_cycler_import` |
| Emergency mission call | ✅ Exists | `create_special_mission_for_order` |
| `humans_present?` check | ❌ Missing | Primary gate — needed first |
| `emergency_required?` | ❌ Missing | Core routing decision |
| `time_to_critical` | ❌ Missing | Stub acceptable for now |
| `time_to_next_resupply` | ❌ Missing | Stub acceptable for now |
| `add_to_resupply_manifest` | ❌ Missing | Needed for non-emergency path |
| Medicine in `qualifies_for_emergency?` | ❌ Missing | `emergency_mission_service.rb` |
| SystemOrchestrator crisis event | ❌ Missing | Integration not wired |
| Pattern learning from outcomes | ❌ Missing | Future work |

---

## Sprint Scope: What to Implement Now

The full `time_to_critical` and `time_to_next_resupply` calculations
require consumption tracking and resupply scheduling data that may not
be fully implemented yet. For the current sprint:

**Implement:**
1. `humans_present?(settlement)` — query settlement population
2. `emergency_required?(settlement, resource)` — the core routing method,
   with `time_to_critical` and `time_to_next_resupply` stubbed initially
3. `add_to_resupply_manifest(order)` — placeholder that logs and records
   the shortage for now
4. Add `:medicine` to `EmergencyMissionService#qualifies_for_emergency?`
5. Rewrite the 3 failing specs to test routing behavior, not robot counts

**Document as stubs for future implementation:**
- `time_to_critical` — needs consumption rate tracking
- `time_to_next_resupply` — needs resupply scheduling model
- Pattern learning connection to escalation outcomes

**Target:** 3 failures → 0 failures, architecture correctly expressed
in both the service and the specs.

---

## Implementation Notes (Resolved)

**Population tracking:**
`current_population` is tracked via the `PopulationManagement` concern
included on `Settlement::BaseSettlement`. `humans_present?` is therefore:
```ruby
def self.humans_present?(settlement)
  settlement.current_population.to_i > 0
end
```

**Life support:**
The `LifeSupport` concern already calculates resource requirements per
population and handles shortage detection. `time_to_critical` should
eventually integrate with this — it knows `STARVATION_THRESHOLD`,
`FOOD_PER_PERSON`, `WATER_PER_PERSON` etc. For now, stub conservatively.

**Logistics infrastructure:**
`Logistics::Contract` and `Logistics::Provider` exist and are functional.
Provider cost and delivery time calculations are implemented.
`Market::SupplyChain` exists but is minimal.

**Dynamic resupply manifest:**
Not yet implemented. `add_to_resupply_manifest` should be stubbed as a
logged placeholder for now — record the shortage, note it needs fulfillment,
do not attempt to build the full manifest yet.

**`time_to_critical` stub:**
Until consumption rate tracking is implemented, use a conservative default:
```ruby
def self.time_to_critical(settlement, resource)
  # TODO: implement real consumption rate tracking
  # Conservative stub: assume 72 hours until critical for any shortage
  # when humans are present
  72.hours
end
```

**`time_to_next_resupply` stub:**
Until resupply scheduling is implemented:
```ruby
def self.time_to_next_resupply(settlement)
  # TODO: query actual scheduled resupply missions
  # Conservative stub: assume 7 days until next resupply
  # This means any shortage with time_to_critical < 7 days triggers emergency
  7.days
end
```

**Open question remaining:**
What is the shortened emergency response window for player contracts?
(suggest 4-6 hours — confirm before implementing)

---

## Luna as Foundation: The Seed Pattern for All Expansion

Luna is not just the first settlement — it is the AI Manager's classroom.
Every pattern learned on Luna becomes the template applied to Mars, Venus,
Titan, and eventually procedurally generated worlds beyond the wormhole
network. Getting Luna right is the prerequisite for everything else.

**Players do not enter the game until Luna is operational and the economy
is established.** The AI Manager must master the Luna pattern first.

---

### The Thermal Cascade: Luna's Core Production Chain

The entire initial settlement revolves around a single thermal process:

```
Regolith (raw, mined by RPR-200 / Mining Harvester)
        ↓
TEU — Thermal Extraction Unit (bakes regolith like a kiln)
        → Releases volatiles as gases: H2O vapor, CO2, trace gases
        → Hot depleted regolith (volatiles removed, still thermally active)
              │
              ├→ PVE — Planetary Volatiles Extractor
              │   Takes the HOT material, processes further:
              │   → Releases O2 from oxides (requires heat to work)
              │   → Extracts H2O from hydrated minerals
              │   → Gas outputs feed inflatable storage tanks
              │
              └→ Depleted regolith (after PVE, still hot) feeds:
                  ├→ 3D Shell Printer
                  │   → Protective regolith shells over inflatables
                  │   → Radiation shielding, structural protection
                  │
                  ├→ I-Beam Printer
                  │   → Structural I-beams (concrete equivalent)
                  │   → Framework for solar arrays, construction
                  │
                  ├→ Surface preparation
                  │   → Landing pads
                  │   → Flat lava tube floors for habitat sites
                  │
                  └→ Regolith panels
                      → Basic construction panels
                      → Everything on Earth made of concrete
```

**The heat is the key.** The TEU provides thermal energy that drives
every downstream process. The entire cascade is sequential — if TEU
breaks, PVE stops, printing stops, O2 production stops, water stops.
This is why the MRR-100 maintenance robot and repair kits are
survival-critical in early game. One equipment failure stops the
whole chain.

**What this means for `can_harvest_locally?`:**

The question is not just "does this body have this resource?" It is
"does this body have this resource AND does the settlement have the
equipment to extract it?"

For early Luna with TEU + PVE deployed:
- Oxygen → YES (PVE + regolith oxides + heat)
- Water → YES (TEU + hydrated minerals/ice deposits)
- I-beams, shells, panels → YES (depleted regolith + printers)
- Refined iron/metals → NO (no smelter — basic ISRU only)
- Medicine → NO (no biological production capability)
- Advanced electronics → NO (requires manufacturing not yet built)

`can_harvest_locally?` must check BOTH body composition AND deployed
equipment. A body with abundant iron oxide is useless without a
smelter. A TEU without regolith to process produces nothing.

---

### Luna's Import-to-Self-Sufficiency Progression

Luna cannot build everything immediately. What it cannot produce it
imports — from Earth initially, then from other settlements as the
network matures. The import dependency decreases as capability grows.

**Phase 1 — Initial Deployment (Day 1, no population):**
```
Producing locally:
  O2, H2O (TEU/PVE cascade)
  I-beams, shells, panels (regolith printers)
  Basic volatiles (gas storage filling)

Must import (from Earth):
  All robots (HRV-400, CAR-300, SMR-500, MRR-100, LTR-100)
  All electronics and modules
  Inflatable habitats, greenhouse units, tanks
  Medicine, food supplements
  Fuel (initially — until ISRU produces enough)
  Advanced components for L1 construction
```

**Phase 2 — Early Population (20-500 colonists):**
```
Producing locally:
  Above + food (greenhouses operational)
  More O2/H2O at scale
  Expanded structural materials

Must import:
  Advanced electronics
  Medicine (no local biological production)
  Specialized equipment
  L1 construction components
  
Beginning to export:
  Surplus I-beams and panels to L1 construction
```

**Phase 3 — Industrial Growth (500-5000):**
```
Producing locally:
  Most construction materials
  Food self-sufficient
  Basic manufactured goods
  Regolith-derived products at scale

Must import:
  High-tech components
  Medicine
  Biological materials
  
Actively exporting to L1:
  I-beams, panels, processed regolith
  Luna surplus funds L1 and cycler construction
```

**Phase 4 — Luna as Network Foundation:**
```
Luna feeds L1 Station construction with manufactured components
L1 builds tugs and cyclers from Luna materials
Tugs and cyclers enable Mars, Venus, Titan patterns
Earth imports minimal — only what Luna genuinely cannot produce
Luna GCC surplus funds wormhole network expansion
```

---

### The Learning Sequence

The AI Manager learns on Luna what it needs to know for every world:

```
Luna pattern mastered → teaches:
  - How TEU/PVE thermal cascade works
  - What buffer stock levels prevent cascade failure
  - How robot fleet scales with population growth
  - How GCC flows from market participation
  - When to expand vs when to consolidate
  - What to import vs what to produce locally at each phase
        ↓
L1 Station built from Luna surplus
        ↓
Ships built at L1 from Luna components
        ↓
Mars pattern applied:
  Similar TEU/PVE cascade, different regolith composition
  CO2 atmosphere changes what PVE produces (more CO2 processing)
  No lava tubes — different construction approach
        ↓
Venus pattern:
  No surface access — orbital only
  Atmospheric harvesting replaces regolith processing
        ↓
Titan pattern:
  Methane/nitrogen focus instead of oxygen
  Different gas processing chain
        ↓
Wormhole network — procedurally generated worlds:
  AI Manager recognizes which pattern fits
  Applies it, adapts based on actual body composition
  No new instructions needed — patterns generalize
```

**This is why the specs and the architecture must be correct.**
If tests encode wrong behavior — robot creation by escalation,
hardcoded material tiers, ignoring equipment capability — then
every agent that works on this codebase after today builds on
a wrong foundation. The AI Manager will learn wrong patterns.
Getting this right now is not just about passing tests.
It is about teaching the system correctly before players arrive.

---

The resupply manifest doesn't just ask "when does the next Earth ship arrive."
It asks "what is the optimal supply source given the current network topology."

For any shortage at settlement X, the AI Manager evaluates all available
sources and selects the best by minimizing cost + time:

```
1. Local ISRU
   Zero transport cost. Always preferred when available.
   Depends on body composition and operational equipment.

2. Same-body neighbor
   Minimal transport. Another settlement on the same celestial body.

3. Same-system settlement
   Short route. Another settlement in the same solar system.

4. Directly connected system (wormhole link)
   Medium route. A system with a direct wormhole connection.
   Cost depends on link stability and consortium fees.

5. Adjacent system via cycler route
   Established bulk transport. Lower cost for high-volume materials.
   Cycler schedules determine delivery timing.

6. Sol connection (if current network topology includes one)
   Earth anchor pricing available. High cost, long transit.
   Preferred for bootstrapping new systems in early development.

7. Earth direct
   Last resort. Available for most materials in Act 1.
   Capacity limits apply — Earth cannot supply everything
   indefinitely as the network grows.
   Role diminishes as regional specialization matures.
```

### How Earth's Role Evolves

**Act 1 — Earth Anchor Era:**
Earth is the backstop for almost everything. Luna is bootstrapping.
High cost, long transit, but available. ISRU is just starting.

**Act 2 — Regional Specialization:**
Settlements develop production advantages:
- Luna → regolith products, I-beams, panels, helium-3
- Mars → iron, regolith processing, CO2 chemistry
- Venus → atmospheric gases, hydrocarbons, CO2
- Titan → methane, nitrogen, hydrocarbons

Settlements begin trading with each other. Earth import costs are
undercut by regional supply. Logistics providers shift from
Earth-centric to inter-settlement routes.

**Act 3+ — Network Optimization:**
The wormhole network is restructured around supply and demand.
A system with excess methane connected directly to a fuel-hungry
colony is more valuable than routing through Sol. Brown dwarf
siphons between colony systems provide cheap volatiles to both.
Earth's role shrinks to exotic manufactured goods, advanced
electronics, and biological materials that genuinely cannot yet
be produced regionally.

**Late Game:**
Earth may not appear in resupply manifests at all for mature
settlements. The network has become self-sufficient. What one
system has too much of is exactly what another needs — and
direct connections make that trade fast and cheap.

### The Wormhole Network as Trade Route Optimizer

The Wormhole Transit Consortium's route proposals — voted on by
member corporations including players — directly affect which
supply sources exist for every settlement in the network.

A player consortium that votes to link a methane-rich system
directly to a fuel-hungry colony just changed the resupply
economics for everyone in that region. A new system connected
directly to Sol gets Earth anchor pricing as backstop and
established logistics providers on known routes — ideal for
bootstrapping. As it matures, that Sol link may be restructured
in favor of cheaper regional connections.

The AI Manager continuously evaluates the current network topology
when building resupply manifests. Network restructuring is not
just an exploration mechanic — it is supply chain optimization.

### The WormholeNavigator Dependency

**`docs/agent/tasks/backlog/legacy_tracy_bfs_pathfinding.md`**

The BFS pathfinding service (`WormholeNavigator`) is not an optional
enhancement. It is foundational infrastructure for intelligent
resupply routing.

Without it, the AI Manager cannot:
- Find the shortest path between a settlement and a potential supply source
- Evaluate whether a direct wormhole connection reduces resupply time
- Compare route costs across different network topologies
- Identify when a network restructuring would improve supply economics

Without optimal supply routing:
- Settlements over-depend on Earth longer than they should
- The economic evolution from Act 1 to Act 3 doesn't happen naturally
- The Wormhole Transit Consortium's route decisions have no measurable
  economic impact on resupply costs

The full dependency chain:

```
WormholeNavigator (BFS routing across live network topology)
        ↓
ResupplyManifest (finds optimal source for each shortage)
        ↓
EscalationService (triggers when time-to-critical < time-to-resupply)
        ↓
LogisticsProviders (AstroLift, Vector, Zenith execute contracts)
        ↓
PatternLearning (PerformanceTracker improves predictions over time)
        ↓
SettlementSpecialization (emerges from what each body produces best)
        ↓
Inter-system trade (replaces Earth dependency naturally)
        ↓
Wormhole network restructuring (Consortium optimizes routes)
        ↓ (feeds back — new routes change optimal supply sources)
WormholeNavigator re-evaluates with updated topology
```

This is why the escalation service cannot be a flat case statement.
It is one trigger point in a system that spans the entire galaxy.

---

## References

- `docs/ai_manager/03_resource_decisions.md` — resource disposition
  decision tree, ownership rules, standing orders
- `docs/architecture/PLAYER_CONTRACT_SYSTEM.md` — player-first contract
  flow, EAP enforcement
- `docs/architecture/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md` — deployment
  phases, market establishment
- `docs/architecture/LOGISTICS_PROVIDER_INTENT.md` — provider selection
- `docs/architecture/ai_manager/AI_PRIORITY_SYSTEM.md` — priority tiers
- `docs/architecture/ai_manager/AI_PATTERN_LEARNING_SYSTEM.md` — pattern
  learning system
- `docs/architecture/ai_manager/PLAYER_EMERGENCY_MISSION.md` — emergency
  mission design, reward calculation
- `docs/storyline/06_deployment_hierarchy.md` — ISRU-first philosophy
- `docs/gameplay/mechanics.md` — player-first task priority, AI Manager role
- `app/services/ai_manager/escalation_service.rb`
- `app/services/ai_manager/emergency_mission_service.rb`
- `app/services/ai_manager/system_orchestrator.rb`
- `data/json-data/missions/npc_base_deploy/` — initial deployment patterns
