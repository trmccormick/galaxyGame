# AI Manager Construction Economics
## docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md
## Status: Authoritative — March 15, 2026

---

## Core Principle

**Player participation is always preferred. DC self-sufficiency exists to
prevent failure, not to replace player opportunity.**

Every economic decision the AI Manager makes follows this order:
1. Post player mission/contract first
2. Wait for player fulfillment window
3. DC robot workforce produces if unfulfilled AND GCC available
4. DC robot workforce produces in survival mode if no GCC
5. NPC import as absolute last resort

---

## Overview

This document defines the economic model governing how the AI Manager builds,
operates, and participates in the colonial economy. It covers Development
Corporation financial structure, GCC monetary policy, construction cost
calculation, market participation, the inter-DC sponsorship model, and the
full logistics network.

This document is the authoritative reference for:
- `AIManager::PriorityHeuristic`
- `AIManager::StrategySelector`
- `Manufacturing::AssemblyService`
- `MegaProjectService` (planned)
- `Market::NpcPriceCalculator`
- `docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md`

---

## 1. Development Corporation Financial Structure

### Non-Profit, Not No-Profit

Development Corporations (DCs) are non-profit in structure:
- No shareholder dividends
- Profits reinvested into operations and infrastructure
- Mission-driven: develop the settlement, not maximize returns

But DCs absolutely have operating costs and must cover them. A DC that cannot
cover its expenses will slow operations, reduce robot workforce, cut imports,
and ultimately fail — which is catastrophic for the colonial economy (see
Section 8).

### Revenue Streams
- Settlement fees from players using DC facilities
- Market sales of excess locally-produced resources
- Filling stale player buy orders at margin
- Logistics contract fees
- Inter-DC transfer payments for resource sharing
- **Earth exports** — He-3, lunar samples, scientific data, rare minerals
- **Refueling services** — Earth craft pay for LOX/CH4 on return journey
- **Research grants and sponsorships** — Earth governments and institutions

### Expense Categories
- Robot maintenance and power
- Energy consumption (construction, operations)
- Import costs for non-locally-available materials
- Construction equipment depreciation
- Virtual ledger repayments to LDC
- AstroLift shipping fees for Earth supply runs

### Surplus Disposition
All surplus above operating costs goes into a capital reserve fund used for:
- Major infrastructure projects
- Megastructure construction
- Sponsoring new DCs in expanding systems
- Emergency reserves

### Margin Target
DCs target 5-10% margin above operating costs — sufficient to cover expenses
and build reserves without price-gouging players.

---

## 2. GCC Monetary Policy — LDC as the Mint

### LDC is the Mint

The Lunar Development Corporation (LDC) is the sole issuer of GCC (Galactic
Crypto Currency). LDC mints GCC backed by Luna's productive capacity:
- Resource extraction output
- Infrastructure value
- Settlement economic activity

### Why This Matters
- GCC supply grows with the colonial economy, not arbitrarily
- Inflation is naturally constrained — LDC only mints what the economy supports
- The 1:1 GCC/USD peg at launch is LDC's price stability commitment while
  the market matures (see PRICE_DISCOVERY_LIFECYCLE.md)
- Other DCs earn GCC through productivity — they do not create it

### Virtual Ledger
The virtual ledger is the monetary base — GCC seeded into DC accounts before
real revenue flows. It:
- Bootstraps the early game economy before player participation
- Acts as a sovereign backstop (effectively the colonial central bank)
- Gets wound down gradually as real revenue replaces virtual credits
- Is LDC's primary tool for sponsoring new DCs

### Payment Preference Order
Real currency is always preferred over virtual ledger:
1. Real GCC — preferred for space-side transactions
2. Real USD — preferred for Earth-side transactions
3. Virtual ledger — only when real currency insufficient

During the GCC/USD peg period, NPC-to-NPC transactions (LDC↔AstroLift) are
equivalent in either currency — no exchange risk between NPC entities.

---

## 3. LDC Earth Revenue Streams

LDC maintains multiple Earth-side revenue streams that fund operations and
reduce virtual ledger dependency:

### Exports to Earth (USD revenue)
- **Helium-3** — fusion research premium, small mass huge value
- **Lunar samples** — scientific value, high USD per kg early game
- **Scientific data** — pure revenue, no transport cost
- **Rare minerals** — from regolith processing side effects

### Services to Earth Craft (USD/GCC)
Every Earth supply ship that arrives at Luna needs to return:
- LDC charges for LOX refueling (reliable recurring revenue)
- LDC charges for CH4 refueling
- Maintenance and repair services
- Crew accommodation and transfer

**The supply run loop:**
```
Earth ship arrives (supplies + settlers + equipment)
  → LDC receives supplies
    → LDC charges refueling for return journey (USD/GCC revenue)
      → Ship departs with He-3, samples, research data
        → Earth orgs pay USD for exports
          → LDC has USD for next AstroLift supply run
```

### Grants and Sponsorships (USD)
- Government space agencies (NASA, ESA, JAXA, etc.)
- Research institutions wanting lunar access
- Commercial partners wanting naming rights/access
- Initial bootstrap funding for infrastructure

### He-3 as the Strategic Export
He-3 is the premium export — small mass, enormous Earth value. Mining He-3
is a key early player mission opportunity since LDC needs it for export
revenue but prefers players to mine it rather than diverting robots.

---

## 4. The Harvester Supply Chain

### AstroLift's Role
AstroLift owns and operates the harvester skimmer fleet:
- Launched from Earth (USD cost — Earth-side operations)
- Harvest atmospheric gases at Titan/Venus (near-zero extraction cost)
- Transit to Luna (fuel cost paid by AstroLift)
- Sell gases to LDC at Luna (GCC transaction)
- LDC refuels skimmers with LOX/CH4 (GCC revenue for LDC)
- Skimmers redeploy for next harvest run

### The Symbiotic Dependency
- LDC needs AstroLift — can't get N2/CH4 to Luna without the harvester fleet
- AstroLift needs LDC — Luna is the only customer and refueling depot
- Both have virtual ledger access in early game
- Both benefit from GCC/USD peg — no currency risk between NPC entities
- Neither can succeed without the other

### AstroLift Pricing Model
```
min_price = (earth_launch_amortization + transit_fuel + operations)
            / cargo_mass + margin
```
AstroLift prices below EAP (Earth spot + direct transport) to win LDC
contracts over direct Earth import. LDC won't pay more than EAP — that's
the natural price ceiling.

### Gas Abundance by Source
- Titan: N2 and CH4 — near-zero extraction cost (abundant atmosphere/lakes)
- Venus: CO2 and N2 — near-zero extraction cost (dense atmosphere)
- Mars: CO2 — near-zero local extraction (95.3% atmosphere, free to pump)
- Luna: none — permanent import dependency for N2, CH4

Regional prices fluctuate based on local abundance. A resource that is
abundant on one body is cheap there and expensive where it must be imported.
The AI Manager always checks local extraction cost against import EAP and
chooses the cheaper option.

---

## 5. Player-First Economics

### Mission/Contract Posting Logic
```
DC identifies need (resource, construction, service)
  ↓
Post player mission contract (preferred — GCC flows to players)
  ↓ (fulfillment window expires or no GCC available)
DC robot workforce produces
  ↓ (can't produce locally)
NPC import arranged (AstroLift or other provider)
```

### GCC Gate on Robot Production
```ruby
def post_mission_or_produce?(resource, quantity)
  if account_negative?
    :robot_production      # No GCC — robots produce, no player contract
  elsif player_contract_open?(resource)
    :waiting               # Contract posted, wait for player fulfillment
  else
    :post_player_contract  # Always try players first
  end
end
```

### DC as Buyer of Last Resort
The DC maintains standing buy orders for anything players can produce:
- Always something a new player can do to earn first GCC
- Floor price on player labor and basic resources
- Prevents cold-start problem for new players arriving with no GCC

**Design note:** This is a side effect of normal DC market participation,
not a separate mechanic. DC posts buy orders because it needs things. New
players fill those orders because they need GCC. Both benefit naturally.

### What DC Robots Are For
DC robot workforce and import capability exist to:
- Keep settlement alive when players aren't available
- Prevent cascade failure when player participation is low
- Bootstrap new settlements before player population arrives
- Handle things players genuinely can't do (megastructures, harvesters)

DC robots do NOT compete with players, undercut prices, or take
opportunities players could fill.

---

## 6. Construction Cost Model

### Build Priority Order
1. **Local resources + robot labor** — zero GCC cost
2. **Player buy orders** — GCC spent, players get first opportunity
3. **NPC imports** — last resort

### Profitability Evaluation
```
proceed_if: (acquisition_cost + transport + overhead) < construction_value
            OR strategic_necessity == true
```

### Side-Effect Resource Pricing
```
price = lowest_available_import_cost × 0.95
```

---

## 7. The Logistics Network

### Network as Circulatory System
Every settled body is a node. Price differentials between nodes create
player arbitrage opportunities:

```
Earth (USD origin, supply source)
  ↓ AstroLift supply ships
Luna (LDC — mint, first node)
  ↓ player contracts, market, He-3/sample exports
  ↓ surplus → logistics contracts → Mars
Mars (MDC — second major node)
  ↓ CO2 free locally, water from ice
  ↓ Mars exports ↔ Luna imports
Titan harvesters → Luna/Mars (N2, CH4 supply)
Venus harvesters → Luna (CO2, N2 supply)
Belt mining → metals → Luna/Mars shipyards
Gas giants → He-3 → Earth export premium
Wormhole network → new system DCs → expand
```

### Price Discovery Across Network
```
Price on body X = MIN(
  local_extraction_cost,            # If locally abundant
  cheapest_supply_node + transport  # From nearest surplus node
)
```

### AI Manager Network Role
- Monitors inventory levels at every connected settlement
- Identifies surpluses and deficits across network
- Posts inter-settlement logistics contracts for players first
- Falls back to NPC logistics (AstroLift, Vector, Zenith) if unfulfilled
- Optimizes routing (direct vs relay)
- Creates cycler routes when volume justifies permanent logistics

### The Full Player Economy Loop
```
Player arrives at Luna
  → Takes AI Manager mission contract
    → Earns GCC
      → Spends GCC at LDC facilities
        → Trades with other players on market
          → Eventually starts own corporation
            → Competes and collaborates with LDC
              → Act 2 begins
```

---

## 8. The Dependency Chain — Why DC Failure is Catastrophic

```
LDC mints GCC
  → LDC funds bootstrap (virtual ledger)
    → DCs established, settlements operational
      → Players arrive, market develops
        → Logistics corps have cargo and destinations
          → AstroLift, Zenith, Vector profitable
            → More routes open
              → More settlements viable
                → DC expands, LDC mints more GCC
```

LDC failure is total collapse — the mint stops, GCC freezes, the entire
colonial economy seizes. LDC is the Federal Reserve of the colonial economy.

---

## 9. Inter-DC Sponsorship Model

### Expansion Sequence
```
LDC established (Luna) → GCC surplus
  → sponsors Mars DC with virtual ledger allocation
    → Mars DC self-sustaining
      → LDC + Mars DC sponsor outer system DCs
        → Network effect builds
```

### Sponsorship Terms
- LDC provides initial virtual ledger allocation
- New DC repays from operating surplus (nominal rate)
- Inter-DC loans are non-profit to non-profit
- LDC retains advisory role, not ownership

### Precursor Mission Connection
LDC funds the Precursor Mission Sequence:
- LDC funds Heavy Lift Transport launches
- LDC contracts AstroLift for logistics
- LDC is the customer that makes early logistics corps viable
- Without LDC sponsorship, outer system DCs never get started

---

## 10. Megastructure Economics

### Cost Model
- `total_construction_cost` in blueprint JSON = planning estimate only
- Actual cost computed at construction time from current material prices
- Financing: organizational bonds, corporate investment, DC capital reserve
- AI Manager drives construction when DC capital reserve is sufficient
- Robot workforce + local resources first; player supply chain second

### Bond Financing
When DC needs capital beyond reserves:
- Issues bonds (GCC or USD denominated)
- Players/organizations can purchase bonds
- DC repays from operating surplus or in-kind resource delivery
- Default risk increases with distance from LDC sponsorship

See `docs/agent/tasks/backlog/dc_bond_financing_system.md`

---

## 11. Tenant Fee Architecture

### Correct Architecture
- AI Manager-owned bases: fees set based on DC financial health
- When `account_negative?`: fees increase to restore balance
- When flush: fees decrease to attract players
- Player corporation bases: corps set their own fees

See `docs/agent/tasks/backlog/settlement_tenant_fee_architecture.md`

---

## Related Documents
- `docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md`
- `docs/architecture/LOGISTICS_PROVIDER_INTENT.md`
- `docs/architecture/ai_manager/AI_PRIORITY_SYSTEM.md`
- `docs/architecture/ai_manager/PLAYER_EMERGENCY_MISSION.md`
- `docs/architecture/ai_manager/ai_manager_expansion_and_wormhole_network.md`
- `docs/agent/tasks/backlog/megaproject_service_manufacturing_pipeline.md`
- `docs/agent/tasks/backlog/dc_bond_financing_system.md`
- `docs/agent/tasks/backlog/population_morale_wellbeing_system.md`
- `docs/agent/tasks/backlog/geosphere_initializer_procedural_architecture.md`
