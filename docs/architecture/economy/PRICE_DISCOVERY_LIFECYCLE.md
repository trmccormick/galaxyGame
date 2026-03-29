# Price Discovery Lifecycle

**Date:** 2026-03-14
**Status:** Active — foundational architecture
**Author:** Planning Agent (Claude)
**Intended Audience:** All agents, developers

---

## Overview

Prices in Galaxy Game are not static. They start at Earth Anchor Price (EAP)
and decrease as infrastructure matures. This creates a living economy where
AI Manager investment decisions have real economic consequences, and players
arrive to a market that reflects the actual state of development.

---

economic activity. Other DCs earn GCC through productivity; they do not
down gradually as real revenue replaces virtual credits.

See `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md`
for the full DC financial model.

the space economy with a stable, Earth-anchored price baseline. All EAP
develops independently of Earth. The peg loosens in stages:


### Practical Impact on Market Priming
At launch with 1:1 peg:
- EAP in USD = EAP in GCC (simple)
- All initial NPC buy orders posted in GCC at USD-equivalent prices
- Players earn GCC at Earth-equivalent rates early on
- As infrastructure matures and GCC supply grows, space prices drop in GCC
  terms even if USD prices stay flat — GCC becomes more valuable

### Bond Risk Note
LDC can issue USD-denominated bonds for major capital projects. If GCC
depreciates against USD after bond issuance, the debt burden increases
in GCC terms. This is the intended credit risk mechanic — DCs must manage
their USD exposure carefully. See `docs/architecture/DUAL_ECONOMY_INTENT.md`
for bond mechanics.

---

destination using:

**Categories:**
- `bulk_material` — $100/kg transport (LOX, water, regolith products)
- `manufactured` — $150/kg transport (components, equipment)
- `high_tech` — $200/kg transport (electronics, precision instruments)

**Note:** EAP rates in `economic_parameters.yml` are the **initial priming
values** only. They represent the pre-infrastructure baseline. As infrastructure
matures, actual transaction prices fall below EAP.

---

## Infrastructure Progression & Price Impact

### Phase 0: Pre-Deployment (EAP Era)
Everything imported from Earth. All prices at full EAP.

| Resource | Price | Source |
|----------|-------|--------|
| LOX | ~$100/kg | Earth import |
| Water | ~$100/kg | Earth import |
| I-beams | ~$250/kg | Earth manufactured + transport |
| Electronics | ~$240/kg | Earth high-tech + transport |

### Phase 1: Luna ISRU Online (LDC)
Luna base established. TEU → PVE → Gas Separator → Cryo Storage pipeline
producing LOX, water, metals locally.

**Price impacts:**
- LOX on Luna: drops to ~$5-10/kg (local production cost: energy + equipment amortization)
- Water on Luna: drops to ~$8/kg
- Regolith-derived components (3d_printed_ibeam etc.): drop to local production cost
- Earth imports still needed for: N2, electronics, precision equipment

**Key:** Luna can't produce N2 locally — always imported from Earth.
LDC uses USD from Earth grants and Helium-3 exports to fund N2 imports.

### Phase 2: LEO Depot Operational (AstroLift + LDC)
AstroLift fills LEO depot with Luna-sourced LOX and methane.
Earth-departing craft refuel at LEO instead of launching fully fueled.

**Price impacts:**
- Transport cost to Luna: drops ~30% (ships carry more cargo per launch)
- Transport cost to Mars: drops ~20%
- AstroLift `base_fee_per_kg` update: 150 → ~100 GCC/kg
- All downstream prices drop proportionally

### Phase 3: L1 Shipyard Operational (LDC + AstroLift joint venture)
Heavy Lift Transports built locally from Luna materials (titanium alloy,
stainless steel, electronics still imported). No Earth launch costs for ships.

**Price impacts:**
- AstroLift fleet expansion without Earth launch cost
- Transport cost to Luna: drops ~50% from Phase 0 baseline
- AstroLift `base_fee_per_kg` update: ~100 → ~60 GCC/kg
- Manufactured goods from Luna reach Earth-competitive pricing

### Phase 4: Earth-Mars Cycler Established (Vector Hauling)
Permanent bulk cargo route between Earth and Mars.
Cycler carries 200,000 kg pressurized + 500,000 kg unpressurized per transit.

**Price impacts:**
- Mars bulk cargo costs: drop ~60% from Phase 0
- Vector Hauling becomes dominant interplanetary provider
- Vector `base_fee_per_kg` update: ~120 → ~30 GCC/kg for Mars routes
- Mars settlement viability improves dramatically

### Phase 5: Gas Giant Cycler + Titan Operations
Saturn/Titan route established. Methane, ethane, nitrogen from Titan.
Helium-3 harvesting from gas giant atmospheres.

**Price impacts:**
- Fuel costs across entire inner system drop (Titan methane supply)
- Helium-3 enables fusion research economy
- Gas Giant Cycler: 300,000 kg pressurized per transit
- Long-haul transport economics transform

### Phase 6: Full Maturity
Multiple DCs, full ISRU everywhere, shipyards at Luna/Mars/Belt,
cyclers on all major routes.

**Price stabilization:**
- Commodity prices stabilize at local production cost + small margin
- Transport costs become negligible for bulk goods on established routes
- High-tech electronics remain Earth-import dependent (for now)
- Player economy flourishes with abundant cheap resources

---

evaluates profitability:
```
proceed_if: (acquisition_cost + transport + overhead) < construction_value
            OR strategic_necessity == true
```

Build priority order:
1. Local resources + robot labor (zero GCC cost)
2. Player buy orders (GCC spent, players get first opportunity)
3. NPC imports (last resort)

Excess side-effect resources (volatiles from regolith, etc.) listed at
5% below lowest import cost.

See `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md`
for the complete construction economics model.


---

## Transport Cost Service

`Logistics::TransportCostService` is the source of truth for current
transport costs. It should NOT return static config values permanently —
it must reflect actual infrastructure state.

**Current implementation:** Static rates from `economic_parameters.yml`
**Intended implementation:** Dynamic rates based on:
- Active `Logistics::Provider` records and their `base_fee_per_kg`
- Operational status of LEO depot, L1 shipyard, cyclers
- Route availability (direct vs. relay)

**Backlog:** Update `TransportCostService` to query provider records
instead of static config when infrastructure milestone tracking is implemented.

---


## Player Economic Opportunities by Phase

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

## Code References

- `app/models/market/npc_price_calculator.rb` — NPC buy/sell pricing
- `app/services/financial/tier1_price_modeler.rb` — EAP calculation
- `app/services/logistics/transport_cost_service.rb` — Route costs
- `app/models/logistics/provider.rb` — Provider pricing
- `config/economic_parameters.yml` — Base rates and Earth spot prices
- `docs/architecture/LOGISTICS_PROVIDER_INTENT.md` — Provider architecture
- `docs/architecture/DUAL_ECONOMY_INTENT.md` — Full economic model
- `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md` — DC financial structure, construction economics, LDC mint model

---

## Open Questions

1. What triggers a provider `base_fee_per_kg` update? Infrastructure milestone
   events? AI Manager periodic recalculation? Admin override?
2. Should `TransportCostService` query live provider data or maintain its
   own infrastructure state tracker?
3. How does asteroid relocation (Asteroid Relocation Tug) affect pricing?
   (Relocated asteroids near Mars could provide local metal supply)
4. When do cycler construction costs become player-accessible?
   (Cyclers require orbital shipyard — Act 2+ content)
