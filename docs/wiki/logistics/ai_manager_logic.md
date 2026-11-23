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



### Shared autonomous-management system and control model

**OWNER-CONFIRMED DESIGN INTENT — 2026-11-23; implementation and player-facing scope remain subject to existing capability and authority boundaries**

The AI Manager is one shared autonomous-management system. It completely manages NPC operations: it receives the governing objectives and policies for NPC-controlled assets, evaluates the game state, generates and prioritizes work, plans and coordinates operations, and executes those operations through the appropriate domain services. NPCs are not managed by a separate, simpler automation system.

Players use the same underlying AI Manager capabilities to direct and automate operations for their own assets. The player does not replace the AI Manager or introduce a second implementation. The player supplies the objectives, priorities, standing policies, and individual instructions governing player-owned assets; the shared AI Manager turns that direction into tasks and plans and carries out authorized work. The player's automation scope is limited to the assets and capabilities available to that player, and to the decisions the player is permitted to delegate. The AI Manager remains responsible for the actual autonomous task planning and execution.

The distinction between NPC and player operation is therefore the **source of direction, asset scope, and authority to act**, not a different AI system:

- **NPC operation:** the AI Manager operates NPC-controlled assets under game-level objectives, NPC policies, and simulation/economic rules. It has the operational authority needed to manage those NPCs autonomously.
- **Player operation:** the same AI Manager operates the player's assets under player-defined objectives, policies, and instructions, constrained by ownership, game rules, available capabilities, and the player's delegated authority. The player may retain approval requirements for selected decisions or exceptions.
- **Admin oversight:** Admins supervise the system and may configure or adjust appropriate game-level objectives, constraints, and operational settings. The Admin workspace is not the player control surface and does not imply that Admins must manually direct every NPC task.

Keep these inputs distinct because they have different lifetimes and meanings:

- **Objective:** an outcome or goal the AI Manager should pursue.
- **Standing policy:** persistent rules, priorities, thresholds, reserves, and boundaries that govern repeated decisions.
- **Individual instruction:** a specific requested action or assignment.
- **Condition or trigger:** a detected game-state circumstance—such as a shortage, maintenance need, or changed operating condition—that may cause the AI Manager to create or revise work under the applicable objectives and policies.

Tasks, plans, decisions, and executions are shared operational concepts. A task record should retain its provenance: the objective, standing policy, individual instruction, condition/trigger, or higher-level AI Manager decision that caused it. The model should also retain the applicable operating scope and authority so that the same task lifecycle can serve NPC and player-owned operations without conflating who directed the work or what the AI was authorized to do. Exact schemas and service boundaries remain implementation questions; do not create duplicate NPC/player task engines.

The future player-facing AI Manager is a player-scoped interface to this shared system, not a reduced copy of the Admin workspace. It exposes the capabilities appropriate to managing the player's own assets and the policies/permissions the player can set. This does not grant players direct control over terraforming objectives or other game-level responsibilities that remain outside player authority.


### In-game operating model: game time, AI decisions, and concurrent work

**OWNER-CONFIRMED DESIGN INTENT — 2026-11-23; runtime integration remains to be verified**

The AI Manager is intended to operate continuously as part of normal game simulation, not as a Rake-driven mission sequence. The game loop advances simulation time and provides opportunities to evaluate time- and state-dependent conditions. The AI Manager observes the resulting world state, evaluates objectives, policies, priorities, dependencies, and available capabilities, and decides what work should be created, changed, deferred, or stopped.

Not every operation requires a background job. Some are lightweight simulation-time checks or event/condition evaluations: for example, checking whether a launch window has opened, a transit or production interval has elapsed, a shipment is due, or maintenance has become necessary. These checks belong with simulation-time/game-loop processing where appropriate. When a check or decision requires substantive asynchronous work, the AI Manager can schedule it through the background-job system.

Sidekiq is part of the intended execution architecture for running independent mission/task work concurrently. It is an execution mechanism, not the decision-maker: the AI Manager determines what work is appropriate and how it relates to objectives and dependencies; jobs perform delegated work; task/mission status and resulting world changes must feed back into subsequent AI Manager evaluations. Work that is genuinely dependent must respect its prerequisites, while independent work should not be serialized merely because it belongs to the same strategic objective.

The intended operating cycle is therefore:

1. Advance simulation time and process relevant time-based checks/events.
2. Observe authoritative game state and active work, including job/task/mission outcomes.
3. Evaluate objectives, standing policies, current conditions, resource availability, dependencies, priorities, and constraints.
4. Create or revise plans and tasks; identify which work can proceed concurrently and which work must wait for prerequisites.
5. Dispatch eligible asynchronous work through the job system and let appropriate domain services perform it.
6. Reconcile completion, failure, partial results, resource consumption, and changed conditions into game state; reevaluate and adapt on subsequent cycles.

This is a continuous feedback loop, not a single mission runner that completes one mission before considering another. Multiple missions and tasks may remain active together—for example, Luna construction and expansion, local harvesting, material processing/fabrication, Venus atmospheric harvesting and return logistics, resupply, maintenance, and fuel production. Their resource flows and dependencies must be coordinated while independent work proceeds in parallel.

A mission is a useful grouping of related work, not necessarily an exclusive execution slot or the whole operational plan. Reusable task/capability definitions describe what operations can be performed, their prerequisites, effects, requirements, constraints, and outcomes. Plans and mission examples demonstrate possible combinations. The AI Manager must select, combine, sequence, and adapt capabilities to current conditions and objectives; examples and Rake scripts must not become mandatory hardcoded recipes.

**Rake tasks and integration tests are development and validation tools.** They may establish controlled initial conditions, exercise services, run repeatable experiments, and capture evidence. They are not the normal in-game scheduler, the authoritative operating loop, or a substitute for autonomous decision-making. Passing a Rake or integration test does not by itself prove that the game-loop/AI Manager/Sidekiq feedback cycle works end to end.

Implementation status must be reported separately for simulation-time checks, AI decision evaluation, task/mission persistence and lifecycle, Sidekiq dispatch, concurrent execution, dependency handling, and result reconciliation. The presence of a job class, orchestrator, or test does not prove that the complete loop is wired into normal gameplay.

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
3. **Structural dependency chains** — Infrastructure dependencies must be respected: establish the Luna industrial foundation, then the L1 Depot, then the separate near-LEO Depot, then orbital shipyard infrastructure before the Mars expansion objective. These are strategic dependencies, not a requirement to serialize independent construction, harvesting, fabrication, logistics, and maintenance work. Earlier phases not yet complete → task blocked.

These safety gates **short-circuit** the Tier 1 (Survival), Tier 2 (Liquidity), and Tier 3 (Expansion) evaluation loops entirely. A task that fails any pre-condition never reaches priority scoring.

---

## 3. Priority Hierarchy

**Important:** The pre-task safety gates defined in Section 2 (Class-0 sanctuary hard blocks, Class-1/2 environmental caps, and structural dependency chains) act as **absolute pre-conditions that short-circuit all priority evaluation tiers**. No Tier 1, Tier 2, or Tier 3 scoring or task allocation occurs until a task has passed all safety checks. A task failing any safety gate is blocked regardless of its priority rank — the safety gates execute *before* these loops begin.

The AI Manager evaluates all pending tasks through a three-tier priority loop:

### Tier 1 — Survival & Resupply (highest)
1. **Life support maintenance** — oxygen, water, food, energy delivery to any colony below metabolic thresholds. This is the highest-priority class of work. The AI Manager must protect life support and allocate the resources/assets needed to resolve emergencies; unrelated work may continue concurrently when it does not compromise safety, scarce resources, or emergency response.
2. **Critical atmospheric pressure** — prevent habitat depressurization or CO₂ poisoning across all colonies.
3. **Emergency backstops** — Eden Snap recovery, debris avoidance, structural collapse remediation.

### Tier 2 — Market Liquidity & Economic Stability

> **OPEN RECONCILIATION — 2026-11-21:** This legacy target hierarchy says the AI Manager guarantees tight spreads and player profit. The current [AI Manager Economic Loops](ai_manager_economic_loops.md) direction says the AI Manager is non-competitive and should not dominate player markets, with an accepted 80%/90% EAP seed band. Whether any active liquidity-support behavior is compatible with that non-competitive role, and what it means operationally, remains to be reconciled. Do not treat a guaranteed spread, guaranteed player profit, or market-maker behavior as settled gameplay solely from this section.

1. **Player-first order fulfillment** — player buy/sell orders get priority over all NPC activity. Players undercut NPCs → guaranteed profit.
2. **Liquidity guarantee** — AI places counter-orders to maintain tight spreads (default ~0.5%) and prevent market stalls.
3. **EAP enforcement** — prevents gouging by enforcing Earth Anchor Price ceilings; if player price exceeds EAP, AI ignores the order and imports from Earth instead.

### Tier 3 — Expansion & Construction (lowest)
1. **Early Sol buildout** — current owner-confirmed required progression: Luna industrial base → Earth–Moon L1 Depot → separate near-LEO Depot → orbital shipyards → Mars expansion. The two depots have distinct logistics roles; both precede shipyards and the Mars expansion objective. This supersedes older LEO-first or combined-depot sequencing in frozen references. See [Station Construction Options](../engineering/station_construction_options.md).
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