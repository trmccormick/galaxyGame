# Terraforming Economic Integration

> **Wiki section:** Logistics · **Status:** target design intent — document how terraforming drives the AI Manager economic engine; no runtime enforcement currently exists.

> **Cross-link:** For the hard physical mechanics of the brute-force terraforming loop, see **[Venus–Mars Ballistic Corridor](../technical/venus_mars_ballistic_corridor.md)**.

> **Cross-link:** For planetary protection classes governing extraction and atmospheric injection limits, see **[Planetary Protection & Environmental Governance](../infrastructure/planetary_protection_environmental_governance.md)**.

---

## Scope

This document specifies how terraforming operations are financed, contracted, and integrated into the AI Manager's economic engine. Terraforming is an **AI Manager background simulation** operating through Development Corporation foothold bases under real GCC budget constraints. Players participate economically by fulfilling the resulting orders and contracts — they do not directly control terraforming projects.

---

## 1. Mars-Buyer / Venus-Supplier Loop

### Development Corporation Footholds

Terraforming infrastructure and demand flows through **Development Corporation (DC) foothold bases**:

> *"Early footholds and new settlements are generally sponsored by the LDC (Lunar Development Corporation), the first Earth-sponsored Development Corporation. LDC is expansion-focused, non-profit, and is also the GCC mint."*
> — `docs/gameplay/terraforming.md`

Foothold bases serve as:
- **Budget holders:** Mars footholds hold and manage GCC budgets for terraforming investment.
- **Demand issuers:** Development Corp bases issue structured market demand (buy orders) for gases, materials, and hardware.
- **Player gates:** A foothold opens a world for player access; without one, planetary markets are not reachable.

### LDC's Dual Role

The Lunar Development Corporation operates as both:
1. **Expansion sponsor** — funding the initial DC foothold deployment on Mars
2. **GCC mint** — via the Lunar Currency Authority Satellite (LCAS), creating new GCC into circulation

### GCC as Denomination and Constraint

All foothold and terraforming budgets are denominated in **GCC (Galactic Crypto Currency)**:
- At game start, USD is pegged 1:1 to GCC for Earth-facing dealings.
- The peg is removed later so GCC can diverge with in-game conditions.
- Real GCC budget constraints prevent unlimited terraforming — the AI Manager ranks options and allocates budgets accordingly.

### Mars-Buyer / Venus-Supplier Flow

```
[LDC] ──(GCC funding)──► [Mars Foothold Budget Holder]
                                │
                                ▼
                        [Market Demand Issuance]
                        (gases, materials, hardware)
                                │
              ┌─────────────────┼─────────────────┐
              ▼                 ▼                  ▼
       [Venus Supplier]  [Player Haulers]   [NPC Ops]
    (CO₂/O₂/CNT feed)   (1.5× GCC rate)   (90% efficiency baseline)
```

---

## 2. Seed Path vs. Brute-Force Contracts

### The Two Terraforming Phases in Economic Terms

| Phase | Contract Type | Upfront Cost | Ongoing Cost | Speed of Effect | Player Role |
|-------|--------------|-------------|-------------|-----------------|-------------|
| **Seed path** | Recurring gas buy orders | Low (per-order) | Continuous GCC drain | Gradual, ongoing | Fill AI Manager market orders |
| **Brute-force** | Industrial infrastructure contracts | High (mass drivers, CNT plants, cracking arrays) | Lower per-unit cost after build-out | Rapid pulses once operational | Haul feedstock to foothold bases |

### Seed Path Economics

The seed path is the AI Manager's ongoing terraforming mechanism:
- **Demand issuance:** The AI Manager continuously posts buy orders for terraforming gases and materials.
- **Economic sink:** Terraforming is a "long-horizon resource and GCC sink that creates player earning opportunities through orders and contracts."
- **GCC budget cap:** LDC-sponsored Mars footholds hold finite GCC; the AI Manager ranks terraforming options by planetary benefit, timeline, residual risk, and cost.

> **Cross-link:** For EAP pricing ceilings, AI Manager escalation ladders, and structural market mechanics, see **[Earth Anchor Price & AI Manager Escalation](./eap_and_ai_manager_escalation.md)**.

> **Cross-link:** For ImportOrder schemas, cycler transport tiers, and L1 Depot logistics triangle, see **[ImportOrder & Cycler Transport Models](./import_order_and_cycler_models.md)**.

### Brute-Force Path Economics

Brute-force contracts represent large-scale infrastructure procurement:
- **Capital intensity:** Mass drivers, CNT manufacturing plants, CO₂ cracking arrays require substantial one-time GCC expenditure.
- **Contract types:** These appear as structured industrial procurement orders rather than recurring commodity buy orders.
- **Economic catalyst:** Once built, brute-force infrastructure provides lower per-unit cost and rapid atmospheric impact — making it economically efficient at scale.

### Digital Twin Ranking Logic

The AI Manager's Digital Twin ranks terraforming options using:
1. **Planetary benefit** — atmospheric density gain, biosphere viability
2. **Timeline** — time to measurable results
3. **Residual risk** — contamination safety boundaries (Class-0 through Class-4)
4. **GCC cost** — real budget constraint under Development Corp accounting
5. **Confidence** — projection reliability

---

## 3. Sol Tri-System Volatile Loop

### Outer-System Feedstock Supply Chain

The preferred volatile supply chain preserves Mars and Luna water reserves:

```
[Saturn Harvester] ─────(H₂)────────────────────────► [Martian Sabatier]
         │
         │ (H₂)
         ▼
[Venus Sabatier Plant] ──(CH₄, O₂)────────────────► [Mars]
```

| Feedstock | Preferred Source | Alternative | Policy |
|-----------|-----------------|-------------|--------|
| Hydrogen (H₂) | Saturn skimmers | Jupiter extraction | Saturn preferred due to Titan proximity |
| Methane (CH₄) | Titan harvesting | Luna (from CO₂) | Titan canonical preference; 5% volatile cap |
| Water ice | **Reserved** — do not consume | Mars/Luna for habitation only | Explicitly preserved |

### Titan Conservation Mandate

Titan's total volatile extraction is capped at **5% of initial mass**, enforced as a dual-cap architecture (rate limit + total reserve cap). This creates long-term scarcity pressure on the H₂/methane supply chain.

---

## 4. Player Economic Participation

### How Players Earn GCC from Terraforming

Players do not control terraforming projects, but they earn substantial GCC by participating in the supply chain:

| Activity | GCC Multiplier | Constraint |
|----------|---------------|------------|
| Fill AI Manager buy orders (gases, materials) | 1.5× vs NPC baseline | Market order volume and timing |
| Fulfill foothold contracts | 1.5× vs NPC baseline | Escrow threshold: 10,000 GCC; max contract: 10% of GCC supply |
| Haul feedstock to Venus/Mars processing stations | Per-kg transport rate | Available contracts and cycler capacity |

### NPC Fallback

When player activity is insufficient, NPC operations provide baseline service:
- **Efficiency cap:** NPC operations run at 90% efficiency vs. player-driven operations
- **Economic impact:** NPCs fill orders at the base GCC rate (no multiplier), creating price pressure that incentivizes player participation

---

## 5. AI Manager Integration

### Priority Stack Placement

Terraforming demand fulfillment operates within the AI Manager's three-tier priority hierarchy:

| Tier | Priority | Terraforming Relevance |
|------|----------|----------------------|
| **Tier 1** | Survival & Resupply | Terraforming is blocked until survival needs are met |
| **Tier 2** | Market Liquidity & Economic Stability | Market stability gates terraforming procurement pace |
| **Tier 3** | Expansion & Construction | Terraforming demand fulfillment lives here (gases, materials, hardware, fuel under Development Corp GCC budgets) |

### Safety Gates

Terraforming execution is blocked by ACM safety gates:
- **Class-0:** Hard block — no terraforming until resolved (e.g., active contamination event)
- **Class-1/2 caps:** Pace constraints on extraction and injection rates
- **Dependency chains:** Cycler capacity and H₂ supply must exist before brute-force deployment

---

## 6. Explicit Design Boundaries

### Terraforming Is AI Manager Background Simulation

The following mechanisms are **explicitly excluded** from player control:

| Exclusion | Design Rationale |
|-----------|-----------------|
| Direct player planetary budget allocation | Terraforming is a long-horizon GCC sink; players earn through orders, not wallets |
| Population/labor allocation sliders | Population is a soft local modifier on base capacity, not a direct labor mechanism |
| Player-set terraforming priorities | Players monitor conditions and markets; they do not set planetary priorities |
| Player-run NPC corporation programs | Tutorial teaches extraction → processing → sale, not economy control |

### Wormholes/Portals Excluded from Bulk Terraforming Logistics

> *"Bulk feedstock stays in-system. Anchors handle reconnection, not logistics."*

Portals and wormholes are infrastructure for **reconnection** (e.g., Eden), not bulk transport:
- All early-game bulk terraforming logistics are handled by **cyclers and mass drivers**
- EM harvesting via wormholes is **not** an early Sol capability
- Anchor Law constraints apply to portal-mediated operations

---

## 7. Economic Lifecycle Summary

```
LDC mints GCC → Mars foothold holds budget → AI Manager ranks options (Digital Twin)
    → Development Corp issues market demand (Seed path buy orders / Brute-force contracts)
    → Players extract, process, haul, fill orders (1.5× GCC rate)
    → NPC ops provide 90% efficiency fallback at base rate
    → GCC spent on terraforming = economic sink; new GCC minted by LDC as needed
    → Peg to USD removed; GCC floats with in-game conditions
```

---

*Last verified against: `docs/gameplay/terraforming.md`, `docs/architecture/ai_manager/FOOTHOLD_PLANNER_ARCHITECTURE.md`, `docs/wiki/logistics/AI-Manager-Logic.md` — target design intent. No runtime enforcement currently exists.*
