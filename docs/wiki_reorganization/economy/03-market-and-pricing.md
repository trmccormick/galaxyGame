# Market & Pricing

**Status**: Canonical  
**Last Updated**: 2026-09-11  
**Supersedes**: `PRICE_DISCOVERY_LIFECYCLE.md`, `ISRU_PRICING_MODEL.md`, `MARKET_OPERATIONS.md` (EAP section)  
**Derived from**: `PRICE_DISCOVERY_LIFECYCLE.md` (primary), `ISRU_PRICING_MODEL.md`, `MARKET_OPERATIONS.md`, `gcc_coupling_status.md`

---

## 1. Price Discovery Lifecycle

**Date:** 2026-03-14  
**Status:** Active — foundational architecture  
**Author:** Planning Agent (Claude)  
**Intended Audience:** All agents, developers

Prices in Galaxy Game are not static. They start at Earth Anchor Price (EAP) and decrease as infrastructure matures. This creates a living economy where AI Manager investment decisions have real economic consequences, and players arrive to a market that reflects the actual state of development.

### LDC as the Mint

LDC is the sole issuer of GCC. GCC supply is backed by Luna's productive capacity — resource extraction output, infrastructure value, and settlement economic activity. Other DCs earn GCC through productivity; they do not create it.

The virtual ledger is the monetary base — GCC seeded into DC accounts before real revenue flows exist. It bootstraps the early game economy and is wound down gradually as real revenue replaces virtual credits.

See `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md` for the full DC financial model.

### GCC/USD Peg — The Market Primer

#### Initial State: Hard Peg (1 GCC = 1 USD)
At game launch, GCC is pegged 1:1 to USD. This is intentional — it primes the space economy with a stable, Earth-anchored price baseline. All EAP calculations work identically in both currencies at launch.

**Why peg?**
- GCC supply is tiny at launch (only LDC mining satellites producing it)
- No independent space economy exists yet to set GCC value
- Earth prices provide the only reliable reference point
- Pegging prevents hyperinflation/deflation before market depth develops

**Implementation:** `Financial::ExchangeRateService` defaults to 1:1. The rate hash `{ ["USD", "GCC"] => 1.0 }` is set at seed time.

#### The Decoupling Progression
As the space economy grows, GCC supply increases and space-side demand develops independently of Earth. The peg loosens in stages:

**Stage 1: Soft Peg (early game)**
- GCC still roughly 1:1 with USD
- Small fluctuations allowed (±10%)
- LDC mining satellites primary GCC source
- All space transactions use GCC, Earth transactions use USD

**Stage 2: Managed Float (mid game)**
- GCC supply sufficient to support independent pricing
- Exchange rate set by market forces with AI Manager stabilization
- Space-produced goods priced in GCC below EAP
- Earth imports still anchored in USD, converted at current rate

**Stage 3: Full Float (late game / Act 3+)**
- GCC trades freely against USD
- Wormhole activity, infrastructure ROI, and GCC mining rate drive value
- Space economy fully self-sustaining
- Wormhole Transit Consortium fees ($1,000 USD/transit) create USD demand
- GCC appreciation possible if space economy outgrows Earth anchor

### Currency Conversion in EAP Calculations
EAP is calculated in USD (Earth spot prices). When GCC ≠ USD:

```
EAP_gcc = EAP_usd / exchange_rate(USD → GCC)
```

Example at 1.3 GCC/USD (GCC depreciation scenario from integration tests):
- Titanium EAP: $187.50 USD = 243.75 GCC
- Players selling titanium to NPCs get paid in GCC at current rate
- NPC buy orders update when exchange rate changes

**Implementation:** `Financial::ExchangeRateService.convert(amount, from, to)` handles all conversions. `NpcPriceCalculator` must use this service when posting buy/sell orders rather than assuming 1:1.

### Practical Impact on Market Priming
At launch with 1:1 peg:
- EAP in USD = EAP in GCC (simple)
- All initial NPC buy orders posted in GCC at USD-equivalent prices
- Players earn GCC at Earth-equivalent rates early on
- As infrastructure matures and GCC supply grows, space prices drop in GCC terms even if USD prices stay flat — GCC becomes more valuable

### Bond Risk Note
LDC can issue USD-denominated bonds for major capital projects. If GCC depreciates against USD after bond issuance, the debt burden increases in GCC terms. This is the intended credit risk mechanic — DCs must manage their USD exposure carefully. See [04-bonds-and-financing.md](./04-bonds-and-financing.md) for bond mechanics.

---

## 2. The Earth Anchor Price (EAP)

EAP is the price ceiling for any resource at any destination. If a resource costs more than EAP, an NPC will always choose to import from Earth instead.

**Formula:**
```
EAP = (Earth spot price × refining factor) + transport cost to destination
```

**Implementation:** `Tier1PriceModeler` calculates EAP per material per destination using:
- Earth spot prices from `config/economic_parameters.yml`
- Transport rates by category (bulk: $100/kg, manufactured: $150/kg, high_tech: $200/kg)
- Route modifiers via `Logistics::TransportCostService`

**Categories:**
- `bulk_material` — $100/kg transport (LOX, water, regolith products)
- `manufactured` — $150/kg transport (components, equipment)
- `high_tech` — $200/kg transport (electronics, precision instruments)

**Note:** EAP rates in `economic_parameters.yml` are the **initial priming values** only. They represent the pre-infrastructure baseline. As infrastructure matures, actual transaction prices fall below EAP.

---

## 3. Infrastructure Progression & Price Impact

### Phase 0: Pre-Deployment (EAP Era)
Everything imported from Earth. All prices at full EAP.

| Resource | Price | Source |
|----------|-------|--------|
| LOX | ~$100/kg | Earth import |
| Water | ~$100/kg | Earth import |
| I-beams | ~$250/kg | Earth manufactured + transport |
| Electronics | ~$240/kg | Earth high-tech + transport |

### Phase 1: Luna ISRU Online (LDC)
Luna base established. TEU → PVE → Gas Separator → Cryo Storage pipeline producing LOX, water, metals locally.

**Price impacts:**
- LOX on Luna: drops to ~$5-10/kg (local production cost: energy + equipment amortization)
- Water on Luna: drops to ~$8/kg
- Regolith-derived components (3d_printed_ibeam etc.): drop to local production cost
- Earth imports still needed for: N2, electronics, precision equipment

**Key:** Luna can't produce N2 locally — always imported from Earth. LDC uses USD from Earth grants and Helium-3 exports to fund N2 imports.

### Phase 2: LEO Depot Operational (AstroLift + LDC)
AstroLift fills LEO depot with Luna-sourced LOX and methane. Earth-departing craft refuel at LEO instead of launching fully fueled.

**Price impacts:**
- Transport cost to Luna: drops ~30% (ships carry more cargo per launch)
- Transport cost to Mars: drops ~20%
- AstroLift `base_fee_per_kg` update: 150 → ~100 GCC/kg
- All downstream prices drop proportionally

### Phase 3: L1 Shipyard Operational (LDC + AstroLift joint venture)
Heavy Lift Transports built locally from Luna materials (titanium alloy, stainless steel, electronics still imported). No Earth launch costs for ships.

**Price impacts:**
- AstroLift fleet expansion without Earth launch cost
- Transport cost to Luna: drops ~50% from Phase 0 baseline
- AstroLift `base_fee_per_kg` update: ~100 → ~60 GCC/kg
- Manufactured goods from Luna reach Earth-competitive pricing

### Phase 4: Earth-Mars Cycler Established (Vector Hauling)
Permanent bulk cargo route between Earth and Mars. Cycler carries 200,000 kg pressurized + 500,000 kg unpressurized per transit.

**Price impacts:**
- Mars bulk cargo costs: drop ~60% from Phase 0
- Vector Hauling becomes dominant interplanetary provider
- Vector `base_fee_per_kg` update: ~120 → ~30 GCC/kg for Mars routes
- Mars settlement viability improves dramatically

### Phase 5: Gas Giant Cycler + Titan Operations
Saturn/Titan route established. Methane, ethane, nitrogen from Titan. Helium-3 harvesting from gas giant atmospheres.

**Price impacts:**
- Fuel costs across entire inner system drop (Titan methane supply)
- Helium-3 enables fusion research economy
- Gas Giant Cycler: 300,000 kg pressurized per transit
- Long-haul transport economics transform

### Phase 6: Full Maturity
Multiple DCs, full ISRU everywhere, shipyards at Luna/Mars/Belt, cyclers on all major routes.

**Price stabilization:**
- Commodity prices stabilize at local production cost + small margin
- Transport costs become negligible for bulk goods on established routes
- High-tech electronics remain Earth-import dependent (for now)
- Player economy flourishes with abundant cheap resources

---

## 4. How the AI Manager Uses EAP

### Resource Acquisition Decision Logic
```
IF local_production_cost < EAP:
  source locally (ISRU or local market)
ELSIF npc_market_price < EAP:
  buy from NPC market (Virtual Ledger if GCC scarce)
ELSE:
  import from Earth (requires USD)
```

### NPC Pricing Logic (`NpcPriceCalculator`)
- NPC buy orders: posted at EAP ceiling (won't pay more)
- NPC sell orders: posted slightly below EAP (undercuts Earth import)
- Local production available: posted at production cost + margin
- Players can sell to NPCs at any price up to EAP

### Construction Cost Evaluation

Before posting buy orders or importing for construction, the AI Manager evaluates profitability:
```
proceed_if: (acquisition_cost + transport + overhead) < construction_value
            OR strategic_necessity == true
```

Build priority order:
1. Local resources + robot labor (zero GCC cost)
2. Player buy orders (GCC spent, players get first opportunity)
3. NPC imports (last resort)

Excess side-effect resources (volatiles from regolith, etc.) listed at 5% below lowest import cost.

See `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md` for the complete construction economics model.

### Price Ceiling Enforcement
If a player posts a sell order above EAP, AI Manager:
1. Rejects the order (won't pay more than import cost)
2. Schedules an Earth import instead
3. Creates a logistics contract for import delivery

---

## 5. Market Operations

### Market vs. Build Decision Logic
- **AI Manager Resource Acquisition:**
  - If local production cost < EAP: source locally (ISRU or local market)
  - Else if NPC market price < EAP: buy from NPC market (Virtual Ledger if GCC scarce)
  - Else: import from Earth (requires USD)
- **Price Ceiling Enforcement:**
  - NPC buy orders posted at EAP ceiling
  - NPC sell orders posted slightly below EAP
  - Player sell orders above EAP are rejected; imports are scheduled instead

### Contract Ceiling Limits (from GUARDRAILS.md §8)
- **Maximum Contract Value**: No single player contract may exceed 10% of current GCC money supply to prevent economic distortion
- **Daily Contract Limits**: Players limited to 5 active contracts per day to ensure market distribution
- **Contract Duration Caps**: Maximum 90 Earth days for any contract to prevent long-term economic commitments

### Market Dynamics and Resource Flow
- **Buy/Sell Order System:** All bases and stations maintain active buy and sell orders for essential materials, creating natural resource flow incentives
- **Player Logistics Role:** Players and logistics NPCs bridge resource gaps by transporting materials from production sites to consumption sites as the game expands
- **Multi-Modal Transport:** Cycler routes provide slow but reliable bulk transport, while players enable faster, more flexible logistics
- **Construction Buy Orders:** Orbital stations and depots create buy orders for construction materials (e.g., L1 station buying 1000 3D printed ibeams), allowing players to participate in infrastructure development
- **Player Supply Chain:** Players can build or purchase materials from locations like Luna and sell them at demand centers like L1 Station for profit
- **NPC Fallback System:** If players don't fill orders within timeout windows, NPCs like AstroLift automatically fill them to maintain game progression
- **Baseline Price Setting:** NPC order fulfillment establishes market prices and ensures economic activity continues even without player participation
- **Early Game Critical:** NPC fallbacks are especially important early in the game when player logistics infrastructure is limited

---

## 6. ISRU Pricing Model

This document describes the pricing logic for materials in the Galaxy Game economy, focusing on the distinction between local ISRU (In-Situ Resource Utilization) production and interplanetary import costs. It is intended to clarify how NpcPriceCalculator and related services determine market prices for settlements and manufacturing.

### Pricing Logic

#### NpcPriceCalculator.calculate_ask(settlement, material)
- **If the settlement has a local ISRU source:**
  - The market price is set to **95% of the current import cost (EAP)**, regardless of actual production cost. This ensures local production is always competitive, helps offset high import costs, and allows the settlement to balance its books over time—not to maximize profit or gouge buyers.
- **Otherwise (no local ISRU):**
  - `import_cost = Luna_baseline + transport_cost(settlement ↔ Luna)`

### Example Scenarios
- **Luna N2:** import_cost = $40k+/m² (lunar colony reference)
- **Titan N2:** production_cost ≈ 0 (98.4% atmosphere harvest)
- **Mars H2O:** ISRU electrolysis enables low local cost

### ManufacturingService Flow
1. **Blueprint BOM:** Each blueprint defines `required_materials` (JSON Bill of Materials).
2. **Material Pricing:** For each material, call `NpcPriceCalculator.ask(settlement, material)` to get the market price.
3. **Total BOM Cost:** `bom_cost = sum(all material prices × required amounts)`
4. **Final Charge:** `final_charge = bom_cost × settlement.construction_cost_percentage`

### Example Calculation
If a Methane Engine requires 1600kg of materials, and each kg costs 100 GCC:

```
1600 kg × 100 GCC = 160,000 GCC (BOM cost)
160,000 × 0.004 (0.4%) = 640 GCC (final charge)
```

### Test Harness Example
```ruby
before do
  create(:blueprint, name: 'Methane Engine', player: player, licensed_runs_remaining: 999)
  settlement.inventory.items.create!(name: 'titanium_alloy', amount: 1000, ...) # ×4 for all required materials
  allow(NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)
  player.credit(500_000)
end
# Methane Engine: 1600kg BOM × 100 = 160k → 640 GCC (0.4%)
```

---

## 7. Transport Cost Service

`Logistics::TransportCostService` is the source of truth for current transport costs. It should NOT return static config values permanently — it must reflect actual infrastructure state.

**Current implementation:** Static rates from `economic_parameters.yml`  
**Intended implementation:** Dynamic rates based on:
- Active `Logistics::Provider` records and their `base_fee_per_kg`
- Operational status of LEO depot, L1 shipyard, cyclers
- Route availability (direct vs. relay)

**Backlog:** Update `TransportCostService` to query provider records instead of static config when infrastructure milestone tracking is implemented.

---

## 8. Currency Flow Summary

```
Earth grants (USD) → LDC → GCC mining satellites → GCC supply
Luna exports (He-3, samples) → USD revenue → Earth imports (N2, electronics)
AstroLift transport fees (GCC) → AstroLift fleet expansion
LEO depot fuel sales (USD) → LDC USD revenue
L1 shipyard construction → local ships → transport cost reduction
Cycler operations → bulk cargo economics → price stability
```

---

## 9. Player Economic Opportunities by Phase

| Phase | Player Opportunity |
|-------|--------------------|
| 0 | Sell harvested resources to LDC at EAP |
| 1 | Fill LDC buy orders for ISRU components |
| 2 | Courier contracts: Luna → LEO depot fuel runs |
| 3 | Component supply for L1 shipyard construction |
| 4 | Mars courier contracts, resource arbitrage |
| 5 | Titan fuel harvesting, Helium-3 trading |
| 6 | Specialized high-tech supply, exploration contracts |

---

## Appendix: GCC Coupling Status Tracker

> **Note**: This is dynamic state data that changes frequently. See `gcc_coupling_status.md` in the original location for the latest values.

### SOL System (Solar System)
- **GCC/USD Base Rate**: 1.0 (stable parity)
- **Market Status**: Mature economy
- **Key Indicators**:
  - Wormhole Tax Rate: 0.8 (80% of standard)
  - Transport Cost Modifier: 1.0 (baseline)
  - Infrastructure Cost Modifier: 1.0 (baseline)
- **Resource Status**: Helium-3 abundant, Silicates stable, Rare Earth Metals high demand

### AOL System (Alpha Orionis)
- **GCC/USD Base Rate**: 1.0 (stable parity)
- **Market Status**: Developing economy
- **Key Indicators**:
  - Wormhole Tax Rate: 0.7 (70% of standard)
  - Transport Cost Modifier: 1.1 (+10% due to distance)
  - Infrastructure Cost Modifier: 1.2 (+20% due to remoteness)

### AC System (Alpha Centauri)
- **GCC/USD Base Rate**: 1.0 (newly initialized parity)
- **Market Status**: Bootstrap economy (post-Super-Mars Relocation)
- **Key Indicators**:
  - Wormhole Tax Rate: 0.6 (60% of standard, optimized STE ratio)
  - Transport Cost Modifier: 0.9 (-10% slag propulsion efficiency)
  - Infrastructure Cost Modifier: 0.8 (-20% orbital depot leverage)
