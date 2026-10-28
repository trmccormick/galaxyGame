# 🤖 AI Manager Logic & High-Level Execution Rules

## STATUS: DESIGN INTENT & CANONICAL FRONT DOOR

This document is the single canonical wiki entry for AI Manager intent, priority loops, and system boundaries. Detailed architectural specs live in `docs/architecture/ai_manager/`.

---

## 1. Canonical Role & Scope

The **AI Manager** is the game's automated economy and logistics governor. Its responsibilities fall into three domains:

| Domain | What it does | Where to verify intent |
|--------|-------------|----------------------|
| **Logistics orchestration** | Routes freight, schedules cyclers, dispatches harvesters & construction tugs across Sol bodies. | `galaxy_game/app/services/ai_manager/task_execution_engine.rb`, `cycler_optimizer.rb` |
| **Market balancing** | Acts as an active market maker — places counter-orders to guarantee liquidity, enforces EAP (Earth Anchor Price) ceilings, fills gaps when no player order exists. | `docs/architecture/ai_manager/AI_MANAGER_ROLE.md`, `market_monitor.rb`, `npc_price_engine.rb` |
| **Automated fleet / construction actions** | Assigns and prioritizes AI-managed fleets for early Sol buildout, terraforming demand fulfillment, and emergency backstops (critical shortages, Eden Snap events). | `docs/architecture/ai_manager/AI_MANAGER_ORCHESTRATOR_SPEC.md`, `emergency_dispatch.rb`, `construction/access_point_installation_service.rb` |

**Boundary note:** The AI Manager does **not** generate celestial or terrain data — that is StarSim's role. It reads game state (settlement inventories, market order queues, colony populations) and issues high-level work orders to existing services.

---

## 2. ACM Boundaries (Autonomous Construction Manager)

The ACM handles **physical construction** tasks that flow from AI Manager priorities:

| What ACM owns | What core AI Manager retains |
|---------------|------------------------------|
| Orbital shipyard scheduling (`orbital_shipyard_service.rb`) | Priority scoring & work-order dispatch (`task_execution_engine.rb`) |
| Module assembly sequencing (`unit_module_assembly_service.rb`) | Market liquidity, EAP enforcement, cycler routing |
| Construction-phase gating (dependency chains, safety caps) | Economic policy decisions and budget allocation |

**Pre-task safety policies** that ACM must enforce before starting any build:
- **Class-0 sanctuaries** — no construction, ISRU extraction, or infrastructure within protected zones. Respects hard planetary caps on environmental modification.
- **Atmospheric caps** — automated harvesting cannot exceed regulated atmospheric density thresholds.
- **Structural dependency chains** — every station construction must pass sequential phases (Luna industrial bootstrapping → L1 shipyards → deep-space deployment) before AWS/WS deployment.

---

## 3. Priority Hierarchy

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
| [Resource & Market Logistics](Resource-and-Market-Logistics.md) | Supply chains between Sol bodies; material costs the AI uses for routing decisions. |
| [Market & AI Bootstrapping](Market-and-AI-Bootstrapping.md) | Early market formation models; how initial liquidity seeds feed into AI market maker behavior. |

---

## 5. Deep Detail Links

This page holds **intent and boundaries**. For implementation specifics, read the architectural specs in `docs/architecture/ai_manager/`:

| Spec file | Covers |
|-----------|--------|
| [AI Manager Role](../../architecture/ai_manager/AI_MANAGER_ROLE.md) | EVE-style market structure, player-first economy, EAP enforcement. |
| [Orchestrator Spec](../../architecture/ai_manager/AI_MANAGER_ORCHESTRATOR_SPEC.md) | Rake task delegation, core 8-file orchestration pattern, deletion criteria. |
| [Intent](../../architecture/ai_manager/AI_MANAGER_INTENT.md) | High-level design intent and behavioral constraints. |
| [Economic Logic Update](../../architecture/ai_manager/AI_MANAGER_ECONOMIC_LOGIC_UPDATE.md) | Market pricing and dynamic spread adjustments. |
| [Event Flow](../../architecture/ai_manager/AI_MANAGER_EVENT_FLOW.md) | Task lifecycle from detection to completion. |
| [Escalation Architecture](../../architecture/ai_manager/RESUPPLY_AND_ESCALATION_ARCHITECTURE.md) | Crisis escalation paths (survival gaps, critical shortages). |
| [Wormhole Expansion](../../architecture/ai_manager/AI_MANAGER_WORMHOLE_EXPANSION.md) | Wormhole station construction, safety dependency chains. |
| [Pricing Intent](../../architecture/ai_manager/AI_MANAGER_PRICING_INTENT.md) | NPC pricing, dynamic spread tuning, EAP anchor logic. |
| [Agent Reading Order](../../architecture/ai_manager/AGENT_READING_ORDER.md) | Recommended reading sequence for new contributors. |

---

## 6. Preserved Priority Seed (Legacy Reference)

The original static urgency weights remain as a baseline seed (see below). These are **not** the active runtime weights — dynamic scaling supersedes them.

| Category | System Vector | Base Score | Engine Response |
|----------|--------------|-----------|-----------------|
| **Critical** | `life_support` | 1000 | Halts non-essential consumption; routes all logistics to oxygen/water transport. |
| **Critical** | `atmospheric_maintenance` | 900 | Prioritizes greenhouse gas adjustment and pressure stabilization. |
| **Critical** | `debt_repayment` | 800 | Forces local market liquidation or commodity trading to service corporate debt. |
| **Operational** | `resource_procurement` | 500 | Orchestrates standard industrial extraction pipelines (e.g., raw regolith processing). |
| **Operational** | `construction` | 300 | Triggers infrastructure building loops (crater dome covers, shell assembly). |
| **Operational** | `expansion` | 100 | Deploys automated deep space scout craft or initializes wormhole stabilization scans. |

---

## 7. Open Gaps

| Gap | Current state | Resolution path |
|-----|--------------|-----------------|
| **Dynamic priorities** | Still static base weights in `GameConstants::AI_PRIORITIES` | Shift weights dynamically based on faction status and localized events. |
| **Debt liquidation interactions** | Unclear how `debt_repayment` at 800 interacts with thin market sell books | Audit against low-liquidity cycles to prevent fire-sale collapses. |

---

## Section Status

> **DESIGN INTENT & CANONICAL FRONT DOOR** — Priority tiers, ACM boundaries, and economic logic represent target architecture. Verify against live code in `galaxy_game/app/services/ai_manager/` before treating any detail as implemented behavior.