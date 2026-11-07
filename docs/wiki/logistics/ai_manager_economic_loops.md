# AI Manager Economic Loops

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-04  
> *Audit Summary:* DRAFT from an owner and Gemini brainstorm (2026-11-04), written up by Grok and Qwen. Not yet verified against code or frozen docs. Only points marked ESTABLISHED INTENT were stated by the owner.

**Status**: DIRECTION (with some ESTABLISHED anchors)  
**Last Updated**: 2026-11-04  
**Related**: [markets_eap_and_peg.md](../markets/markets_eap_and_peg.md), [eap_and_ai_manager_escalation.md](eap_and_ai_manager_escalation.md), [resource_and_market_logistics.md](resource_and_market_logistics.md), [financial_engine.md](financial_engine.md)

This page is the wiki home for how the AI Manager interacts with markets, players, debt, inter-entity transfers, and survival priorities. It harvests and consolidates intent from older design notes while adding the missing austerity and 80/90 band behavior.

Where older material is still valid it is brought forward. Where the new brainstorm extends or potentially conflicts with prior notes, the difference is marked for discussion.

---

## Core Principles

1. The AI Manager is **non-competitive** with players. It does not attempt to undercut or dominate local markets for profit.
2. Its primary mandate is to **keep the base alive** (life support, structural integrity, basic services).
3. Player capital (taxes, docking fees, portal tolls) is the preferred fuel for discretionary activity. In the absence of player activity the AI Manager falls back to self-reliance.
4. The same loops run in the pre-player phase and during isolation (e.g. Eden disconnect). There is no special “player-present” code path required for basic survival.

---

## Earth Anchor Price (EAP)

**ESTABLISHED INTENT** (harvested and restated)

EAP is the price ceiling the AI Manager will pay for a resource at a given location.

High-level formula (from existing markets work):

```
EAP = (earth_spot_price × refining_factor) × usd_to_gcc_peg + transport_cost
```

- The AI Manager will not pay more than EAP under normal conditions.
- If local player offers exceed EAP, the AI Manager falls back to internal harvest or import rather than accepting the gouge.

### Local NPC trading band (DIRECTION — accepted seed)

When the settlement has excess inventory it is willing to sell, and when it has a deficit it is willing to buy from players:

| Action                          | Price relative to EAP | Notes |
|---------------------------------|------------------------|--------|
| NPC **buys** from players       | **80 % of EAP**        | Guaranteed floor for early player sales |
| NPC **sells** excess to players | **90 % of EAP**        | Discount vs full import cost |
| Hard ceiling                    | **100 % of EAP**       | Above this the AI imports or self-supplies under normal conditions |

This 80/90 band is the accepted bootstrap seed (Luna and similar early hubs). It creates a 10% spread for player/NPC arbitrage while keeping the AI Manager's hard ceiling at full EAP.

The AI Manager will **not** pay above EAP under normal conditions. Emergency override remains the only exception (see markets EAP page and escalation ladder).

Buy orders remain **demand-driven**. The AI Manager only posts a buy order for the quantity needed to reach its target stockpile buffer. Once the buffer is met the order is removed or reduced to daily consumption.

---

## Virtual Ledger (Inter-NPC / Development Corps)

**DIRECTION** (concept existed; rules consolidated here)

Non-profit Development Corporations (LDC and regional DCs) and certain trusted logistics entities operate a Virtual Ledger.

- Inter-settlement transfers of critical goods (life support, structural materials, emergency packs) can be executed as ledger debits/credits **without liquid GCC**.
- The ledger exists to prevent death spirals caused by temporary GCC shortages.
- Player-facing market orders **always** require liquid GCC. The ledger is never used for player transactions.
- Accumulated ledger debt influences AI Manager decision-making once thresholds are crossed (see Austerity below).

**OPEN**
- Exact schema, clearing cycles, and amortization rules.
- Which for-profit logistics corps are granted ledger access and under what conditions.

---

## Stockpiles and Target Buffers

**DIRECTION**

Every settlement maintains target stockpile levels for critical resources (O₂, water, structural panels, power components, etc.).

- The AI Manager calculates deficits against these targets before deciding whether to post a player buy order, run internal harvesters, or request a ledger transfer.
- Deep stockpiles are the primary shock absorber so the base does not live hand-to-mouth.

**OPEN**
- Default buffer durations (example starting point: 30-day survival, longer expansion reserve).
- Which resources are treated as critical vs discretionary.

---

## Operating Modes

### Standard / Solvent Mode
- Full services maintained.
- Player buy orders posted for deficits at ≤ 80 % EAP.
- Discretionary missions and standing rewards available when liquid GCC is present.
- Expansion and civic upgrades proceed according to the settlement’s planned blueprint.

### Austerity / High-Debt or Zero-Capital Mode
**DIRECTION** (owner, 2026-11-04: with high debt the AI Manager runs its harvesters, does not buy, does not offer missions, and may raise taxes or take other steps to get out of debt; it can still export. Everything beyond that is a Gemini suggestion, not confirmed.)

Triggered when Virtual Ledger balance falls below a warning threshold or liquid GCC reaches zero.

Actions (in priority order):

1. Stop placing buy orders and stop offering discretionary missions (the base has no capital to pay for either).
2. Activate (or keep running) internal harvesters (PVEs, TEUs, skimmers, etc.).
3. Redirect production to **export**. Physical goods are shipped to solvent hubs; value is credited to the Virtual Ledger (or converted to GCC) to pay down debt.
4. Raise taxes and fees (docking, warehouse, tolls) to generate liquid GCC. Which fees, and how much, is OPEN.
5. Freeze non-essential expansion and cosmetic upgrades.

Goal remains survival and return to solvency, not liquidation of the base. Physical plant is preserved.

**Discussion point**: This austerity package extends the existing 6-step escalation ladder (post order → mission → market scan → self-manufacture → import → emergency). It describes what happens when even the emergency steps cannot be funded. Confirm that the ladder and this austerity state are intended to compose cleanly rather than conflict.

### Zero-Capital Edge Case
When liquid GCC is literally zero:
- The base cannot post buy orders or pay mission rewards.
- It continues to run existing physical assets and export product.
- It can still collect mandatory fees from visiting players.
- Distressed asset sales or exclusive mining rights become possible player opportunities.

---

## Pre-Player / Autonomous Bootstrapping

**DIRECTION**

The exact same loops run when no players are present.

- New footholds start with zero liquid GCC.
- They extract via internal assets, build stockpiles, and export surplus via the Virtual Ledger to establish baseline credit.
- Once stockpiles and planned civic capacity are reached, the settlement opens for human immigration (mini-portals powered, public services online).
- Luna and other early hubs follow this path under LDC direction before players arrive.

This ensures the universe is already alive and has economic history when the first players log in.

---

## LDC Role (Sovereign Mint & Sponsor)

**ESTABLISHED + DIRECTION**

- The Lunar Development Corporation is a non-profit entity whose mandate is human expansion.
- It acts as the GCC mint. New GCC issuance is conceptually tied to physical infrastructure growth and verified expansion (existing intent).
- **DIRECTION**: It can seed-fund and underwrite regional Development Corps via Virtual Ledger credit lines and grants.
- It does not liquidate viable footholds purely for commercial reasons; austerity and export recovery are preferred.

**OPEN**
- Exact minting rules, inflation controls, and relationship to EAP.
- Player corporation charter process for receiving LDC development grants.
- Detailed inter-corp sponsorship dynamics.

---

## Player Interaction Summary

| Condition                          | AI Manager Behavior                                      | Player Opportunity                          |
|------------------------------------|----------------------------------------------------------|---------------------------------------------|
| Solvent + player supply ≤ 80 % EAP | Buys from players, suppresses own harvest                | Reliable local sales, standing gains        |
| Player price > EAP                 | Rejects local offers, imports or harvests itself         | Must undercut or find other markets         |
| High debt / austerity              | No buy orders, no missions, exports product, raises fees | OPEN: what players can do for a broke base (owner has not confirmed) |
| Zero players                       | Full autonomous harvest + export loop                    | Arrive into an already-functioning economy  |

---

## Relationship to Existing Escalation Ladder

The 6-step ladder in `eap_and_ai_manager_escalation.md` remains the normal procurement sequence under solvent conditions. The austerity mode described above is the state the AI Manager enters when it can no longer fund even the later steps of that ladder. The two are intended to compose: ladder first, austerity when capital is exhausted.

If this composition is incorrect, the conflict should be resolved explicitly rather than left implicit.

---

## Implementation Notes (for later thin tasks)

- Market evaluation and order posting should be deterministic and cheap (background job or settlement tick).
- Virtual Ledger transfers should be recorded as first-class transactions that can later be audited or amortized.
- Austerity mode is a state-machine flag that overrides normal procurement and mission dispatch.
- Stockpile buffer targets and the precise 80/90 numbers need confirmation before code work.

All items not explicitly marked ESTABLISHED remain **DIRECTION** or **OPEN** until accepted.
