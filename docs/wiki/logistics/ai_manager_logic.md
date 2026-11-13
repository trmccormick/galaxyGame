# 🤖 AI Manager Logic & High-Level Execution Rules

> **Code Alignment Status:** `PARTIALLY IMPLEMENTED`  
> *Last Audited:* 2026-11-01  
> *Audit Summary:* Core service `galaxy_game/app/services/ai_manager/task_execution_engine.rb` exists (~800 lines). Other referenced coordinators require verification (e.g., `logistics_coordinator.rb`, `market_stabilization_service.rb`, `emergency_mission_service.rb`). Priority scoring, safety gates, and tier logic represent target design intent — verify against source before assuming runtime behavior.

## STATUS: TARGET DESIGN INTENT & CANONICAL FRONT DOOR

This document is the single canonical wiki entry for AI Manager intent, priority loops, and system boundaries. **All content — including priority scoring, decision loops, ACM boundaries, and safety gates — represents TARGET DESIGN INTENT ONLY.** These rules describe the target architecture rather than active runtime code calculations. Verify against live code in `galaxy_game/app/services/ai_manager/` before treating any detail as implemented behavior. Detailed architectural specs live in `docs/architecture/ai_manager/`.

> **Cross-link:** For how terraforming demand is financed and contracted through the AI Manager (GCC budgets, Seed vs. Brute-Force contracts, Mars-Buyer/Venus-Supplier loop), see **[Terraforming Economic Integration](./terraforming_economic_integration.md)**.

**Related:** For the AI Manager's economic behavior — debt-driven austerity modes, Virtual Ledger clearing between Development Corps, NPC buy/sell bands (80/90%), and stockpile buffer targets — see **[AI Manager Economic Loops](./ai_manager_economic_loops.md)**.

---

## 1. Canonical Role & Scope

The **AI Manager** is the game's automated economy and logistics governor. Its responsibilities fall into three domains:

| Domain | What it does | Where to verify intent |
|--------|-------------|----------------------|
| **Logistics orchestration** | Routes freight, schedules cyclers, dispatches harvesters & construction tugs across Sol bodies. | `galaxy_game/app/services/ai_manager/task_execution_engine.rb`, `services/ai_manager/logistics_coordinator.rb` |
| **Market balancing** | Acts as an active market maker — places counter-orders to guarantee liquidity, enforces EAP (Earth Anchor Price) ceilings, fills gaps when no player order exists. | `docs/architecture/ai_manager/AI_MANAGER_ROLE.md`, `services/market/npc_price_calculator.rb`, `services/ai_manager/market_stabilization_service.rb` |
| **Automated fleet / construction actions** | Assigns and prioritizes AI-managed fleets for early Sol buildout, terraforming demand fulfillment, and emergency backstops (critical shortages, Eden Snap events). | `docs/architecture/ai_manager/AI_MANAGER_ORCHESTRATOR_SPEC.md`, `services/ai_manager/emergency_mission_service.rb`, `galaxy_game/app/services/manufacturing/construction/access_point_installation_service.rb` |

**Boundary note:** The AI Manager does **not** generate celestial or terrain data — that is StarSim's role. It reads game state (settlement inventories, market order queues, colony populations) and issues high-level work orders to existing services.

## 1.1 Wormhole network, EM economy, and strategic expansion

**TARGET DESIGN INTENT — OWNER-CLARIFIED 2026-11-13; NOT A CLAIM OF IMPLEMENTED BEHAVIOR**

The AI Manager is responsible for strategic exploration and expansion through the natural-wormhole network and AWS connections, in addition to logistics, markets, and construction coordination. It must evaluate whether to scout, harvest, stabilize, connect, settle, or move on.

### Wormhole and EM monitoring

The AI Manager monitors the authoritative wormhole state and keeps these quantities distinct:
- natural EM ejection / locally available EM;
- EM actually captured or harvested;
- stored EM reserves;
- EM directed back into a natural wormhole for stabilization;
- EM consumed by AWS, portals, and other supported systems.

It also monitors relative wormhole stability, mass throughput, remaining mass-limit capacity, and stabilization effectiveness. Greater mass pushed through a natural wormhole produces greater EM ejection. A comparatively more stable natural wormhole still produces some excess EM; an unstable wormhole ejects substantially more. Mature EM stabilization captures ejected EM and returns it to the wormhole to restore mass-limit capacity and improve relative stability.

No natural wormhole is permanently or absolutely stable. Sol's natural wormhole is comparatively more stable because of its placement opposite Jupiter. For the current human-expansion scenario it remains present and does not shift or snap; this is a scenario-level rule, not a permanent restriction on future simulation scenarios. The Eden-side snap occurred before EM stabilization technology was developed.

### Hammer Protocol and discovery

Hammer Protocol is a strategic scouting, harvesting, and expansion workflow, not merely a controlled-snap command.

Sol is the current human-expansion staging/scouting system. A natural wormhole opening to a candidate system allows it to be surveyed. Systems discovered and surveyed through this process have a harvestable EM field under the current design. Other resources and settlement potential are learned through survey. Unvisited systems in the local bubble remain unknown; the AI Manager must not assume their EM fields or resources are known or harvestable before discovery.

After survey, the AI Manager can continue harvesting through the natural connection without immediately constructing an AWS pair. It evaluates whether to keep harvesting, invest in stabilization, build an AWS connection, plan settlement, or finish the harvesting opportunity and hammer the natural exit to force a shift and scout another system. Discovery alone does not mandate an AWS pair or settlement.

For a system selected for settlement or continuing network integration, the likely approach is to build an AWS pair while the natural wormhole remains open. The resulting Sol connection provides a logistics corridor for personnel, equipment, construction materials, and supplies, using a stabilized natural connection or an artificial connection as appropriate. Whether the connection is retained, reconfigured, or moved later is a strategic decision.

### Expansion evaluation

The AI Manager should weigh:
- system EM ejection, harvestable quantity, capture capacity, and stored reserves;
- EM required for stabilization, AWS construction/operation, and other commitments;
- system resources, celestial bodies, and settlement potential;
- network value and available natural/AWS routes;
- mass capacity, relative stability, and risk of shift or snap;
- ship travel time, orbital/transfer windows, fuel, construction, resupply, and maintenance costs.

The objective is to maximize sustainable long-term expansion capability, not simply the number of systems occupied or connected. Candidate decisions and outcomes should be recorded for operator oversight and training/evaluation. Numerical scoring and policy weights remain OPEN until formalized.

The natural-wormhole mechanics and current scenario rules are authoritative in [Natural Wormholes & EM](../technical/natural_wormholes_and_em.md); AWS behavior and pairing are documented in [Portals & AWS](../technical/portals_and_aws.md).

---

## 2. ACM Boundaries (Autonomous Construction Manager)

The ACM handles **physical construction** tasks that flow from AI Manager priorities:

| What ACM owns | What core AI Manager retains |
|---------------|------------------------------|
| Orbital shipyard scheduling (`orbital_shipyard_service.rb`) | Priority scoring & work-order dispatch (`task_execution_engine.rb`) |
| Module assembly sequencing (`unit_module_assembly_service.rb`) | Market liquidity, EAP enforcement, cycler routing |
| Construction-phase gating (dependency chains, safety caps) | Economic policy decisions and budget allocation |

> **TARGET DESIGN INTENT ONLY** — All entries above describe target architecture. No entry claims verified runtime behavior; confirm against source code before treating as implemented.

**Pre-task safety policies — absolute pre-conditions (short-circuit all priority evaluation):**

The following safety checks execute as **hard pre-conditions BEFORE any Tier 1/2/3 priority scoring or task allocation occurs**. If any check fails, the task is blocked regardless of its priority rank:

1. **Class-0 sanctuary hard blocks** — No construction, ISRU extraction, or infrastructure within protected zones. Absolute prohibition; no priority tier can override.
2. **Class-1/2 environmental caps** — Automated harvesting cannot exceed regulated atmospheric density thresholds or body-specific extraction limits (e.g., Titan's 5% volatile cap). These caps are enforced by planetary protection governance rules as design intent; runtime enforcement is tracked separately.
3. **Structural dependency chains** — Every station construction must pass sequential phases (Luna industrial bootstrapping → L1 shipyards → deep-space deployment) before AWS/WS deployment. Earlier phases not yet complete → task blocked.

These safety gates **short-circuit** the Tier 1 (Survival), Tier 2 (Liquidity), and Tier 3 (Expansion) evaluation loops entirely. A task that fails any pre-condition never reaches priority scoring.

---

## 3. Priority Hierarchy

**Important:** The pre-task safety gates defined in Section 2 (Class-0 sanctuary hard blocks, Class-1/2 environmental caps, and structural dependency chains) act as **absolute pre-conditions that short-circuit all priority evaluation tiers**. No Tier 1, Tier 2, or Tier 3 scoring or task allocation occurs until a task has passed all safety checks. A task failing any safety gate is blocked regardless of its priority rank — the safety gates execute *before* these loops begin.

The AI Manager evaluates all pending tasks through a three-tier priority loop:

### Tier 1 — Survival & Resupply (highest)
1. **Life support maintenance** — oxygen, water, food, energy delivery to any colony below metabolic thresholds. This is the hard ceiling; no other task runs until life-support emergencies are resolved.
2. **Critical atmospheric pressure** — prevent habitat depressurization or CO₂ poisoning across all colonies.
3. **Emergency backstops** — Eden Snap recovery, debris avoidance, structural collapse remediation.

### Tier 2 — Market Liquidity & Economic Stability
1. **Player-first order fulfillment** — player buy/sell orders get priority over all NPC activity. Players undercut NPCs → guaranteed profit.
2. **Liquidity guarantee** — AI places counter-orders to maintain tight spreads (default ~0.5%) and prevent market stalls.
3. **EAP enforcement** — prevents gouging by enforcing Earth Anchor Price ceilings; if player price exceeds EAP, AI ignores the order and imports from Earth instead.

### Tier 3 — Expansion & Construction (lowest)
1. **Early Sol buildout** — Luna industry → LEO/L1 depots → L1 shipyard → tugs/cyclers → core stations (sequential). See `docs/gameplay/sol_core_buildup.md`.
2. **Terraforming demand fulfillment** — planetary program supply (gases, materials, hardware, fuel) under Development Corp GCC budgets.
3. **Deep-space expansion** — wormhole stabilization, cycler route optimization, exoplanet corridor scouting.

### Dynamic Weight Tuning
Static base weights (`GameConstants::AI_PRIORITIES`) are scaled by `AI_PRIORITY_MULTIPLIERS` for testing phases. The intent is to move toward dynamic weight shifts based on faction status and localized events (future gap).

---

## 4. Economic Mechanics Cross-References

For market pricing, liquidity models, and bootstrapping logic that the AI Manager consumes:

| Page | Why it matters |
|------|---------------|
| [Resource & Market Logistics](resource_and_market_logistics.md) | Supply chains between Sol bodies; material costs the AI uses for routing decisions. |
| [Market & AI Bootstrapping](market_and_ai_bootstrapping.md) | Early market formation models; how initial liquidity seeds feed into AI market maker behavior. |

---

## 5. Deep Detail Links

This page holds **intent and boundaries**. For implementation specifics, read the architectural specs in `docs/architecture/ai_manager/`:

| Spec file | Covers |
|-----------|--------|
| AI Manager Role (`docs/architecture/ai_manager/AI_MANAGER_ROLE.md`, frozen doc) | EVE-style market structure, player-first economy, EAP enforcement. |
| Orchestrator Spec (`docs/architecture/ai_manager/AI_MANAGER_ORCHESTRATOR_SPEC.md`, frozen doc) | Rake task delegation, core 8-file orchestration pattern, deletion criteria. |
| Intent (`docs/architecture/ai_manager/AI_MANAGER_INTENT.md`, frozen doc) | High-level design intent and behavioral constraints. |
| Economic Logic Update (`docs/architecture/ai_manager/AI_MANAGER_ECONOMIC_LOGIC_UPDATE.md`, frozen doc) | Market pricing and dynamic spread adjustments. |
| Event Flow (`docs/architecture/ai_manager/AI_MANAGER_EVENT_FLOW.md`, frozen doc) | Task lifecycle from detection to completion. |
| Escalation Architecture (`docs/architecture/ai_manager/RESUPPLY_AND_ESCALATION_ARCHITECTURE.md`, frozen doc) | Crisis escalation paths (survival gaps, critical shortages). |
| Wormhole Expansion (`docs/architecture/ai_manager/AI_MANAGER_WORMHOLE_EXPANSION.md`, frozen doc) | Wormhole station construction, safety dependency chains. |
| Pricing Intent (`docs/architecture/ai_manager/AI_MANAGER_PRICING_INTENT.md`, frozen doc) | NPC pricing, dynamic spread tuning, EAP anchor logic. |
| Agent Reading Order (`docs/architecture/ai_manager/AGENT_READING_ORDER.md`, frozen doc) | Recommended reading sequence for new contributors. |

---

## 6. Legacy Priority Seed (Archival Reference — Not Live)

The static urgency weights below are **archived reference material only**. They represent the original seed weights from `GameConstants::AI_PRIORITIES` that were used in earlier development phases. These values are **NOT the current target design hierarchy** and do NOT reflect the 3-tier structure described in Section 3 above.

> **Do not use this table for design decisions.** The 3-tier priority hierarchy (Section 3) is the active target architecture. This section exists solely to document historical baseline weights for contributors who encounter them in older code or commit messages.

| Category | System Vector | Base Score | Engine Response |
|----------|--------------|-----------|-----------------|
| **Critical** | `life_support` | 1000 | Halts non-essential consumption; routes all logistics to oxygen/water transport. |
| **Critical** | `atmospheric_maintenance` | 900 | Prioritizes greenhouse gas adjustment and pressure stabilization. |
| **Critical** | `debt_repayment` | 800 | Forces local market liquidation or commodity trading to service corporate debt. |
| **Operational** | `resource_procurement` | 500 | Orchestrates standard industrial extraction pipelines (e.g., raw regolith processing). |
| **Operational** | `construction` | 300 | Triggers infrastructure building loops (crater dome covers, shell assembly). |
| **Operational** | `expansion` | 100 | Deploys automated deep space scout craft or initializes wormhole stabilization scans. |

**These are legacy weights only.** The current target hierarchy uses the 3-tier model in Section 3 with dynamic scaling via `AI_PRIORITY_MULTIPLIERS`. Static base weights may shift as priority logic matures.

---

## 7. Open Gaps

| Gap | Current state | Resolution path |
|-----|--------------|-----------------|
| **Dynamic priorities** | Still static base weights in `GameConstants::AI_PRIORITIES` | Shift weights dynamically based on faction status and localized events. |
| **Debt liquidation interactions** | Unclear how `debt_repayment` at 800 interacts with thin market sell books | Audit against low-liquidity cycles to prevent fire-sale collapses. |

---

## Section Status

> **DESIGN INTENT & CANONICAL FRONT DOOR** — Priority tiers, ACM boundaries, and economic logic represent target architecture. Verify against live code in `galaxy_game/app/services/ai_manager/` before treating any detail as implemented behavior.