# AI Manager & Autonomous Coordinators

> **Wiki section:** Services · **Status:** canonical — consolidated from 6 scattered wiki pages + ~35 legacy architecture docs + direct code inspection.
> 
> **Code ground truth:** `galaxy_game/app/services/ai_manager/*.rb`, `galaxy_game/app/jobs/*_job.rb`. Every section below explicitly flags whether it reflects verified code (🟢) or target design intent (🔵).

> **Cross-link:** For terraforming demand financing through GCC budgets, Seed vs. Brute-Force contracts, and player economic participation, see **[Terraforming Economic Integration](../logistics/terraforming_economic_integration.md)**.
> 
> **Cross-link:** For the planet-class map, bootstrap peg, NPC price calculator, and order-matching models the AI Manager consumes, see **[Market & AI Bootstrapping](../logistics/market_and_ai_bootstrapping.md)**.

---

## 1. Role & Scope

The **AI Manager** (`AIManager::Manager`) is Galaxy Game's automated economy-and-logistics governor. It does not generate celestial or terrain data — that is StarSim's role. Instead it reads game state (settlement inventories, market order queues, colony populations) and issues high-level work orders to existing services.

| Domain | What it does | Code reality |
|--------|-------------|--------------|
| **Logistics orchestration** | Routes freight, schedules transfers between settlements via `LogisticsCoordinator`. Dispatches harvesters & construction tugs through `TaskExecutionEngine`. | 🟢 Active — `logistics_coordinator.rb`, `task_execution_engine.rb` (92-line service directory) |
| **Market stabilization** | NPC buyer/producer/importer of last resort; guarantees liquidity for essential items. No formal "EAP ceiling" enforcement in code. | 🟢 Partial — `market_stabilization_service.rb` implements essential-item guarantees but **not** the EAP-price-ceiling mechanism described in legacy docs |
| **Strategic planning** | Evaluates settlement state, scores mission options via `StrategySelector → StateAnalyzer + MissionScorer`, and executes via `ServiceCoordinator`. | 🟢 Active — `strategy_selector.rb`, `state_analyzer.rb`, `mission_scorer.rb` |
| **Inter-settlement orchestration** | Manages the settlement network: priority arbitration, resource allocation, logistics scheduling. | 🟢 Active — `system_orchestrator.rb` (registers settlements, coordinates them) |
| **Terraforming coordination** | Phase detection & orbital depot management for planetary programs. | 🔵 Partial intent — `terraforming_manager.rb` has skeleton `determine_terraforming_phase()` with an unresolved TODO |
| **Expansion & wormhole** | Foothold placement, wormhole scouting/placement, multi-wormhole event handling. | 🟢 Active — `expansion_service.rb`, `foothold_planner.rb`, `wormhole_*` series (3 files) |

> **Cross-link:** For early Sol build order and terraforming priority (what the AI Manager serves), see **[Sol Core Buildup](../../gameplay/sol_core_buildup.md)** and **[Terraforming](../../gameplay/terraforming.md)**.
> 
> **Cross-link:** For life-support, Seed vs. Brute-Force pathways, and residual biological risk: **[Biological Terraforming Seeds](../technical/biology/terraforming_seeds.md)**.

---

## 2. Core Service Architecture (Verified Code)

The active codebase has **92 service files** in `galaxy_game/app/services/ai_manager/`. Below are the authoritative classes organized by responsibility.

### 2.1 Top-Level Manager

```
AIManager::Manager (275 lines)
├── @service_coordinator     → ServiceCoordinator     (mission dispatch, resource requests)
├── @system_orchestrator     → SystemOrchestrator     (inter-settlement coordination)
├── @strategy_selector       → StrategySelector       (next-action evaluation)
└── @game_data_generator     → Generators::GameDataGenerator
```

**Primary entry point:** `Manager#advance_time` — called per game tick:

1. If system orchestrator present → orchestrate all settlements
2. Service orchestrator coordinates service states
3. Strategy selector evaluates next action for the target entity
4. Execute action with service orchestration

### 2.2 Mission Execution Layer

| Class | Lines | Responsibility | Verified? |
|-------|------|----------------|-----------|
| `TaskExecutionEngine` | 822 | Sequential mission task execution (current) | 🟢 Yes |
| `TaskExecutionEngineV2` | 866 | Rewritten engine with v2 patterns | 🟢 Yes (coexists) |
| `ServiceCoordinator` | — | Mission lifecycle: start, advance, status, resource acquisition | 🟢 Yes |

### 2.3 System-Wide Coordination

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `SystemOrchestrator` | Inter-settlement coordination, priority arbitration, logistics scheduling | 🟢 Yes |
| `ServiceOrchestrator` | Service state tracking (active/idle per service), coordinated operations | 🟢 Yes |
| `PriorityArbitrator` | Critical(4) / High(3) / Medium(2) / Low(1) priority levels; crisis escalation/de-escalation | 🟢 Yes |
| `ResourceAllocator` | Resource distribution across settlements | 🟢 Yes |

### 2.4 Logistics & Transport

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `LogisticsCoordinator` | Inter-settlement transfer scheduling, capacity management, route optimization | 🟢 Yes |
| `SkimmerCyclerHandshakeService` | Skimmer-cycler interface | 🟢 Yes |
| `TransitFeeService` | Transit fee calculation | 🟢 Yes |
| `UniversalDockingService` | Docking coordination across locations | 🟢 Yes |

### 2.5 Market Services

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `MarketStabilizationService` | NPC buyer/producer/importer of last resort; essential-item guarantees | 🟢 Yes |
| `EconomicForecasterService` | Economic trend prediction | 🟢 Yes |
| `FinancialService` | Financial operations | 🟢 Yes |

### 2.6 ISRU & Resource Extraction

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `ISRUEvaluator` | ISRU unit evaluation, material processing assessment | 🟢 Yes |
| `ISROptimizer` | ISRU optimization | 🟢 Yes |
| `AtmosphericExtractionService` | Atmospheric extraction logic | 🟢 Yes |
| `AtmosphericHarvesterService` | Atmospheric harvesting operations | 🟢 Yes |

### 2.7 Strategic Planning & Decision-Making

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `StrategySelector` | Next-action evaluation, mission scoring, trade-off analysis | 🟢 Yes |
| `StateAnalyzer` | Settlement state analysis | 🟢 Yes |
| `MissionScorer` | Mission option scoring | 🟢 Yes |
| `DecisionTree` | Decision-tree based AI reasoning | 🟢 Yes |
| `StrategicEvaluator` | Strategic evaluation logic | 🟢 Yes |

### 2.8 Expansion & Colonization

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `ExpansionService` | Planetary expansion planning | 🟢 Yes |
| `ExpansionDecisionService` | Expansion decision logic | 🟢 Yes |
| `FootholdPlanner` | Foothold placement strategy (13KB) | 🟢 Yes |
| `ScoutLogic` | System scouting logic | 🟢 Yes |
| `WorldKnowledgeService` | World knowledge management (10KB+) | 🟢 Yes |

### 2.9 Construction & Infrastructure

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `StationConstructionStrategy` | Orbital station construction planning (45KB) | 🟢 Yes |
| `StationCostBenefitAnalyzer` | Station cost-benefit analysis | 🟢 Yes |
| `StationPlacementService` | Station placement logic | 🟢 Yes |

### 2.10 Wormhole Network

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `WormholeCoordinator` | Wormhole network coordination (25KB) | 🟢 Yes |
| `WormholeManager` | Wormhole lifecycle management | 🟢 Yes |
| `WormholePlacementService` | Strategic wormhole placement | 🟢 Yes |
| `WormholeScoutingService` | Wormhole scouting operations | 🟢 Yes |
| `MultiWormholeEventHandler` | Multi-wormhole event processing (18KB) | 🟢 Yes |

### 2.11 Learning & Pattern Systems

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `PatternLoader` | Pattern loading from JSON/external sources | 🟢 Yes |
| `PatternTargetMapper` | Pattern-to-target mapping | 🟢 Yes |
| `PatternValidationService` | Pattern validation logic | 🟢 Yes |
| `PatternValidator` | Pattern validation (dual-class pattern) | 🟢 Yes |
| `PerformanceTracker` | AI performance tracking across iterations | 🟢 Yes |
| `PrecursorLearningService` | Precursor pattern learning | 🟢 Yes |
| `PrecursorCapabilityService` | Precursor capability assessment | 🟢 Yes |
| `LLMPlannerService` | LLM-based planning support | 🟢 Yes |

### 2.12 Other Services

| Class | Responsibility | Verified? |
|-------|----------------|-----------|
| `EscalationService` | Resource acquisition escalation (30KB) | 🟢 Yes |
| `ResourceAcquisitionService` | Direct resource acquisition | 🟢 Yes |
| `ResourceFulfillmentService` | Resource order fulfillment | 🟢 Yes |
| `ResourcePositioningService` | Strategic resource positioning | 🟢 Yes |
| `ConstructionService` | Construction task management | 🟢 Yes |
| `ContractCreationService` | AI-initiated contract generation | 🟢 Yes |
| `CorporateRoles` | Corporate role assignments | 🟢 Yes |
| `ConsortiumManager` | Consortium governance coordination | 🟢 Yes |
| `ProbeDeploymentService` | Probe deployment operations | 🟢 Yes |
| `SurfaceSuitabilityAnalyzer` | Surface condition analysis | 🟢 Yes |
| `PlanetaryMapGenerator` | Planetary map generation | 🟢 Yes |
| `EarthMapGenerator` | Earth-side mapping | 🟢 Yes |
| `SystemArchitect` | Overall system architecture decisions (31KB) | 🟢 Yes |
| `ResourceFlowSimulator` | Resource flow simulation (17KB) | 🟢 Yes |
| `BootstrapResourceAllocator` | Bootstrap resource allocation (15KB) | 🟢 Yes |
| `SettlementPlanGenerator` | Settlement planning templates | 🟢 Yes |
| `SettlementManager` | Settlement state management | 🟢 Yes |
| `SystemState` | Global system state tracking | 🟢 Yes |
| `SharedContext` | Shared state across services | 🟢 Yes |
| `SimEvaluator` | Simulation evaluation | 🟢 Yes |
| `TestScenarioExtractor` | Test scenario extraction | 🟢 Yes |
| `Testing` | Testing utilities | 🟢 Yes |
| `Errors` | Error definitions | 🟢 Yes |
| `HammerProtocol` | Protocol definitions | 🟢 Yes |
| `DepotAdapter` | Depot system adapter | 🟢 Yes |
| `ColonyManager` | Colony state management | 🟢 Yes |
| `AIcolonyManager` | Alternative colony manager variant | 🟢 Yes |
| `AtmosphericHarvesterService` | Atmospheric harvesting | 🟢 Yes |

---

## 3. Autonomous Coordinator Responsibilities (Verified)

### 3.1 Manager → ServiceCoordinator (Per-Settlement Mission Dispatch)

🟢 **Verified in code:** `Manager#start_mission`, `#acquire_resource`, `#check_resource_availability`, `#scout_system`. The `ServiceCoordinator` handles mission lifecycle through `TaskExecutionEngine`.

```ruby
# Pseudocode derived from actual ServiceCoordinator source:
service_coordinator.start_mission(mission_data)
  → task_engine = TaskExecutionEngine.new(identifier)
  → shared_context.register_active_mission(identifier, task_engine)
  → task_engine.start           # sequential task execution
  → while current_task < task_list.length
        execute_next_task         # material check → build → complete
      end
```

### 3.2 SystemOrchestrator (Inter-Settlement Coordination)

🟢 **Verified in code:** Registers settlements, updates system-wide state, analyzes inter-settlement dependencies, then delegates to `ResourceAllocator`, `PriorityArbitrator`, and `LogisticsCoordinator`.

### 3.3 StrategySelector (Autonomous Decision-Making)

🟢 **Verified in code:** Each tick:
1. `StateAnalyzer.analyze_state(settlement)` — inventory, production capacity, survival status
2. `generate_mission_options` — builds candidate actions from available unit types
3. `MissionScorer.score_mission_options` — scores by strategic value
4. Returns highest-scored action with type: `:wait`, `:construct`, `:produce`, `:scout`, etc.

### 3.4 PriorityArbitrator (Priority Conflicts)

🟢 **Verified in code:** Priority levels are numeric: Critical(4), High(3), Medium(2), Low(1). When conflicts arise, it groups requests by resource and resolves highest-priority wins. Crisis escalation sets `resolution_deadline` to +1 hour.

### 3.5 LogisticsCoordinator (Transfer Scheduling)

🟢 **Verified in code:** Groups transfers by route → optimizes each route → schedules with transport capacity constraints. Tracks transfer lifecycle: status, progress, estimated_completion per transfer.

### 3.6 MarketStabilizationService (NPC Market Making)

🟢 **Verified in code — but NOT the EAP ceiling pattern described in legacy docs.** Actual behavior:

1. **New Player Essentials** (first 30 days): Always guarantees O₂, water, structural panels, life-support filters
2. **Buyer of Last Resort**: Purchases unsold player goods at current market price
3. **Producer of Last Resort**: Manufactures essential items when player production lags
4. **Importer of Last Resort**: Sources items from various locations during shortages
5. **Logistics Coordination**: Manages delivery priorities

> **⚠️ OPEN — needs owner confirmation:** No code implements the EAP (Earth Anchor Price) as a structural price ceiling or the 6-step AI Manager escalation ladder. Legacy docs describe this as design intent only. The `MarketStabilizationService` operates without an explicit price ceiling check.

---

## 4. Class-0..4 Safety Gates (Design Intent Only — NOT in Code)

The existing wiki page `ai_manager_logic.md` describes safety gates as absolute pre-conditions before any priority scoring. **These gates exist only in design intent.** There is no corresponding code class (`Class0Gate`, `Class1Gate`, etc.) or enforcement mechanism in the 92 service files.

### Target Design Intent (🔵 NOT implemented)

| Gate | What it enforces | Code reality |
|------|-----------------|--------------|
| **Class-0** Sanctuary hard blocks — No construction/ISU within protected zones | Not in code | 🔵 OPEN |
| **Class-1/2** Environmental caps — Atmospheric density thresholds, body-specific extraction limits (e.g., Titan 5% volatile cap) | Partial — `AtmosphericExtractionService` exists but no caps enforced | 🔵 OPEN |
| **Structural dependency chains** — Sequential phases (Luna → L1 shipyard → deep-space) before AWS/WS deployment | Not in code | 🔵 OPEN |

### What DOES Exist (🟢 Code-Grounded Safety Mechanisms)

| Mechanism | Location | Verified behavior |
|-----------|----------|-------------------|
| PriorityArbitrator crisis escalation | `priority_arbitrator.rb` | Critical priority items get resolution deadlines; conflicts resolved by highest priority |
| MarketStabilizationService essential-item guarantee | `market_stabilization_service.rb` | Essential survival items always provided to new settlements regardless of market conditions |
| SafetyNetLogisticsJob fallback | `jobs/safety_net_logistics_job.rb` | If settlement orders remain unfilled, triggers AstroLift logistics contract from Earth Base |

> **⚠️ OPEN — needs owner confirmation:** Who decides when Class-0 sanctuary zones should apply? Is this a game-design constant (e.g., `SANCTUARY_ZONES = [Mars_North_Pole_Class0]`) or dynamically generated at world creation?

---

## 5. Priority Hierarchy (Partially Verified)

### Target Design Intent (🔵 From Legacy Docs)

Legacy docs describe a 3-tier priority system:
- **Tier 1 — Survival & Resupply** (life support, critical atmospheric pressure, emergency backstops)
- **Tier 2 — Market Liquidity & Economic Stability** (player-first order fulfillment, liquidity guarantee, EAP enforcement)
- **Tier 3 — Expansion & Construction** (early Sol buildout, terraforming demand, deep-space expansion)

### Verified Code Reality (🟢)

The actual code uses a **4-level numeric priority system** in `PriorityArbitrator`:

| Level | Value | Triggered by |
|-------|-------|-------------|
| Critical | 4 | Survival-critical shortages, crisis escalation, emergency missions |
| High | 3 | Market stabilization for essential items, construction priorities |
| Medium | 2 | Standard logistics transfers, expansion planning |
| Low | 1 | Long-term infrastructure, exploratory scouting |

The `MarketStabilizationService` implicitly enforces player-first by providing NPC fallback only when player activity is insufficient. There is **no explicit code tiering** matching the legacy Tier 1/2/3 model — the numeric system above is what actually exists.

> **⚠️ OPEN — needs owner confirmation:** Should the priority hierarchy be refactored to match the documented Tier 1/2/3 intent, or is the current numeric system sufficient and the legacy docs should be retired?

---

## 6. Economic Mechanics Cross-References

### Earth Anchor Price (EAP) — Status: INTENT ONLY

🔵 **Target design:** EAP = Earth market price + transport cost to destination. The AI Manager never pays above EAP because importing from Earth would be cheaper. Emergency override (`emergency: true`) allows bypass with logging.

🟡 **Code reality:** No `EapCalculator` or equivalent exists in the service directory. Legacy docs (`eap_and_ai_manager_escalation.md`) promulgated requirements from a logistics architecture spec but no runtime enforcement code was ever implemented. The `MarketStabilizationService` has no price-ceiling checks.

### ImportOrder Data Schema — Status: INTENT ONLY

🔵 **Target design:** Defined in legacy docs with fields: `destination_settlement_id`, `origin_settlement_id`, `item_type`, `quantity`, `status`, `cost_gcc`, `eap_at_order_time`, `emergency`, `arrives_at`. Lifecycle: `pending → in_transit → delivered` or `cancelled`.

🟡 **Code reality:** No `ImportOrder` model class exists. The `SafetyNetLogisticsJob` creates `Logistics::Contract` records as a partial substitute for inter-settlement transport requests.

### 6-Step Escalation Ladder — Status: INTENT ONLY

🔵 **Target design:** Post buy order → Offer player mission → Scan market → Self-manufacture → Dispatch robot harvesting → Import (last resort). Each step's failure triggers the next.

🟡 **Code reality:** `EscalationService` (30KB) handles resource acquisition escalation but not as a strict step ladder. The `MarketStabilizationService`'s 5-step process (new-player essentials → buyer of last resort → producer of last resort → importer of last resort → logistics coordination) is the closest mapping but does not enforce sequential failure ordering.

> **⚠️ OPEN — needs owner confirmation:** Is the 6-step escalation ladder still a design requirement, or was the market stabilization service's implicit behavior sufficient and the step-ladder spec should be marked RETIRED?

---

## 7. Terraforming Coordination (Partial Code)

🔵 **TerraformingManager** (`terraforming_manager.rb`) — Partial implementation:
- `determine_terraforming_phase(world_key)` — skeleton method with TODO for pattern-based phase detection; currently falls back to temperature/liquid-water threshold comparison
- Orbital depot management (`@orbital_depots`)
- Pattern loading from `PatternLoader.load_terraforming_patterns`

🟡 **Code reality:** Phase detection logic is incomplete. The terraforming simulation runs but decision-making defaults to simple thermodynamic thresholds rather than pattern-based learning.

---

## 8. Jobs Layer (Background Operations)

| Job | Queue | Verified behavior |
|-----|-------|-------------------|
| `SafetyNetLogisticsJob` | default | Checks for unfilled buy orders → triggers AstroLift logistics contract from Earth Base if provider exists |
| `LocationOperationsCoordinatorJob` | coordination | Sidekiq job queuing per-location and inter-location operations; re-schedules itself hourly |

> **⚠️ OPEN — needs owner confirmation:** Are there additional Sidekiq jobs for AI Manager scheduling (e.g., periodic market stabilization, priority recalculation)? Current code only shows these two.

---

## 9. Harvested From Legacy Sources

The following content was harvested from frozen legacy architecture docs in `docs/architecture/ai_manager/` and related trees. It represents design intent and historical context but must be verified against live code before use in implementation decisions:

| Legacy Source | What it covered |
|--------------|-----------------|
| `AI_MANAGER_ORCHESTRATOR_SPEC.md` | Core 8-file orchestration pattern (manager → market_monitor → task_execution_engine → cycler_optimizer → emergency_dispatch); rake-as-delegation tool mapping |
| `AI_MANAGER_ROLE.md` | EVE-style market structure, player-first economy, EAP enforcement intent |
| `AI_MANAGER_INTENT.md` | High-level design intent and behavioral constraints |
| `AI_PRIORITY_SYSTEM.md` | Priority scoring methodology (legacy) |
| `AI_MANAGER_CODE_REVIEW_PROTOCOL.md` | File classification system: CORE / VALUABLE / BLOAT / UNKNOWN; 89→8 surgical refactoring criteria |
| `AI_MANAGER_BLOAT_AUDIT.md` | Audit of hardcoded constants vs. service delegation patterns |
| `RESUPPLY_AND_ESCALATION_ARCHITECTURE.md` | Full resupply logistics architecture (32KB) |
| `ASTROLIFT_CORPORATION.md` | NPC corporation operational model |
| `FOOTHOLD_PLANNER_ARCHITECTURE.md` | Early foothold deployment strategy |
| `NPC_INITIAL_DEPLOYMENT_SEQUENCE.md` | Initial NPC population and placement |
| `CONSORTIUM_VOTING_ENGINE.md` | Governance coordination model |
| `AI_MANAGER_CONSTRUCTION_ECONOMICS.md` | Construction cost-benefit analysis framework |
| `CYCLER_SYSTEM_ARCHITECTURE.md` | Cycler network topology and routing |
| `EMISSIONS_AND_CHAOS.md` | Chaos event governance patterns |
| `LEARNING_INTEGRATION.md` | Pattern learning system integration |

---

## 10. Code-to-Wiki Cross-Reference Map

| Wiki Concept | Legacy Source (ore) | Active Code | Code Status |
|-------------|-------------------|-------------|-------------|
| Manager orchestration loop | `AI_MANAGER_ORCHESTRATOR_SPEC.md` | `manager.rb` (275 lines) | 🟢 Verified |
| Mission execution engine | `AI_MANAGER_ORCHESTRATOR_SPEC.md` | `task_execution_engine.rb` (822L), `_v2.rb` (866L) | 🟢 Verified |
| Inter-settlement coordination | `RESUPPLY_AND_ESCALATION_ARCHITECTURE.md` | `system_orchestrator.rb` + `logistics_coordinator.rb` | 🟢 Verified |
| Service lifecycle management | — | `service_orchestrator.rb`, `shared_context.rb` | 🟢 Verified |
| Priority arbitration | `AI_PRIORITY_SYSTEM.md` | `priority_arbitrator.rb` | 🟢 Verified (numeric 1-4, NOT tiered) |
| Market stabilization | `EAP_AND_ESCALATION_ARCHITECTURE.md` | `market_stabilization_service.rb` | 🟢 Partial (no EAP ceiling) |
| Strategic planning | `AI_MANAGER_INTENT.md` | `strategy_selector.rb`, `state_analyzer.rb`, `mission_scorer.rb` | 🟢 Verified |
| ISRU evaluation | `AI_MANAGER_CONSTRUCTION_ECONOMICS.md` | `isru_evaluator.rb`, `isru_optimizer.rb` | 🟢 Verified |
| Expansion planning | `AI_MANAGER_EXPANSION_AND_WORMHOLE_NETWORK.md` | `expansion_service.rb`, `foothold_planner.rb` | 🟢 Verified |
| Wormhole network | `AI_MANAGER_WORMHOLE_EXPANSION.md` | `wormhole_coordinator.rb`, `*_placement*.rb`, `*_scouting*.rb` | 🟢 Verified |
| Construction strategy | — | `station_construction_strategy.rb` (45KB) | 🟢 Verified |
| EAP ceiling enforcement | `EAP_AND_ESCALATION_ARCHITECTURE.md` | **NOT IN CODE** | 🔵 Intent only |
| 6-step escalation ladder | `EAP_AND_ESCALATION_ARCHITECTURE.md` | **NOT IN CODE** (partial via `market_stabilization_service.rb`) | 🔵 Intent only |
| Class-0..4 safety gates | `AI_MANAGER_INTENT.md`, legacy wiki | **NOT IN CODE** | 🔵 Intent only |
| ImportOrder model | `EAP_AND_ESCALATION_ARCHITECTURE.md` | **NOT IN CODE** (partial via `SafetyNetLogisticsJob`) | 🔵 Intent only |

---

## 11. Design Intent vs. Code Gap Summary

### GAP 1: EAP Enforcement (CORRECTED)
- **Intent:** AI Manager never pays above Earth Anchor Price; structural market ceiling enforcement
- **Code:** `Tier1PriceModeler.calculate_eap` computes EAP via `earth_spot_price + refining_factor * transport_cost(destination, source)` (verified in `docs/wiki/markets/Markets-EAP-and-Peg.md`). The MarketStabilizationService and broader AI Manager still lack an explicit **price-ceiling check** that rejects purchases above EAP — the EAP is computed but may not be enforced as a rejection threshold.
- **Status:** 🟡 Partial (EAP exists; enforcement gate TBD)

### GAP 2: Strict Escalation Ladder
- **Intent:** Step-by-step escalation (buy order → mission → scan → manufacture → harvest → import)
- **Code:** `MarketStabilizationService` provides NPC fallback but without sequential step enforcement
- **Status:** 🔵 Target design intent only

### GAP 3: Class Safety Gates
- **Intent:** Hard pre-conditions (Class-0 sanctuary blocks, Class-1/2 caps, structural dependency chains)
- **Code:** `PriorityArbitrator` exists for priority conflicts but no class-gate enforcement
- **Status:** 🔵 Target design intent only

### GAP 4: ImportOrder Model
- **Intent:** Dedicated model for inter-settlement transport requests with EAP tracking
- **Code:** No ImportOrder; partial implementation via `SafetyNetLogisticsJob` → `Logistics::Contract`
- **Status:** 🔵 Target design intent only

### GAP 5: Terraforming Phase Detection
- **Intent:** Pattern-based terraforming phase detection from learned patterns
- **Code:** Fallback to temperature/liquid-water thresholds; TODO for pattern-based detection
- **Status:** 🟡 Partial implementation

---

## 12. Files Not Yet Classified by Code Review Protocol

The legacy `AI_MANAGER_CODE_REVIEW_PROTOCOL.md` classified files into CORE / VALUABLE / BLOAT / UNKNOWN categories as part of a proposed 89→8 refactoring. The following files from the current codebase were **not** classified under that protocol and should be reviewed:

| File | Suggested Review Category | Reason |
|------|--------------------------|--------|
| `resource_flow_simulator.rb` (17KB) | Possibly BLOAT | Standalone simulation not calling Rails models/services |
| `bootstrap_resource_allocator.rb` (15KB) | VALUABLE → REVIEW | Bootstrap-specific allocation logic, unclear if still needed |
| `system_intelligence_service.rb` (9KB) | UNKNOWN → AUDIT | Purpose unclear without deeper review |
| `hammer_protocol.rb` (2KB) | BLOAT candidate | Minimal file, may be vestigial protocol definition |

> **⚠️ OPEN — needs owner confirmation:** Was the 89→8 refactoring ever authorized? Should the current codebase be pruned to match that vision, or is the current breadth acceptable given the game's evolving scope?

---

## 13. Quick Reference for Contributors

### "I need to understand how the AI Manager works right now"
Start with: `docs/wiki/services/ai_manager.md` (this page) → then inspect code files directly.

### "I need to add a new AI Manager capability"
1. Check if an existing service handles it (scan this page's tables)
2. If not, create in `galaxy_game/app/services/ai_manager/` following the module pattern `AIManager::ClassName`
3. Register with `SystemOrchestrator` or `ServiceCoordinator` as appropriate
4. Update this wiki page

### "I'm reviewing changes to AI Manager code"
Follow the protocol from legacy doc: `docs/architecture/ai_manager/AI_MANAGER_CODE_REVIEW_PROTOCOL.md`.

### "I need to understand the market layer the AI Manager uses"
Start with: **[Market & AI Bootstrapping](../logistics/market_and_ai_bootstrapping.md)** → then inspect `app/models/market/*.rb` directly.

---

*Harvested from 6 wiki pages (all under `docs/wiki/logistics/`) + ~35 legacy architecture docs (`docs/architecture/ai_manager/`, `docs/architecture/services/ai_manager/`) + direct code inspection of 92 service files.*
