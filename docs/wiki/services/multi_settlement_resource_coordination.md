# Multi-Settlement Resource Coordination

> **Wiki section:** Services / Logistics  
> **Status:** architecture and implementation-gap reference; source inspected 2026-11-23  
> **Code evidence baseline:** `trmccormick/galaxyGame` `main`, commit `9fbb812df08af596e34e5e7d0c3c3055257395b9`.  
> **Evidence boundary:** findings below are source inspection, not runtime validation. No specs or simulation runs were executed for this review.

## Purpose and boundary

GalaxyGame already contains an AI Manager system-orchestration layer. Multi-settlement resource coordination is therefore not a greenfield feature and must not begin by adding a second top-level orchestrator or assuming that a new `ResourceCoordinator` class is required.

The missing capability is a **reliable, economically correct, route-aware network supply-planning and execution path** that can coordinate resource availability across settlements and, when the transport network supports it, across systems. It must use existing AI Manager orchestration and the established acquisition, market, contract, inventory, and transport ownership boundaries.

The intended responsibility is to:
- identify real, current settlement deficits and exportable surplus after protecting local operating and survival reserves;
- identify eligible source settlements and feasible routes;
- compare like-for-like delivered options against local production, market acquisition, and the Earth Anchor Price (EAP) fallback;
- expose dependencies and single-source/cascading supply risks;
- hand an approved plan to the existing owner of trade/contract and transport execution;
- revalidate the plan against current inventory, reservations, funds, market conditions, route availability, and delivery deadlines before execution.

This layer coordinates existing settlements. It does not establish footholds, create systems, authorize expansion, replace per-settlement acquisition, or silently redistribute resources outside the economic rules.

## Existing application structure — source verified

### AI Manager orchestration

The current path is:

`AIManager::Manager#advance_time`  
→ optional `AIManager::SystemOrchestrator#orchestrate_system`  
→ update `SystemState`  
→ analyze dependencies  
→ allocate system resources through `PriorityArbitrator` and `ResourceAllocator`  
→ identify and optimize transfers through `AIManager::LogisticsCoordinator`  
→ schedule transfers  
→ strategic planning.

Relevant source:
- `galaxy_game/app/services/ai_manager/manager.rb`
- `galaxy_game/app/services/ai_manager/system_orchestrator.rb`
- `galaxy_game/app/services/ai_manager/system_state.rb`
- `galaxy_game/app/services/ai_manager/settlement_manager.rb`
- `galaxy_game/app/services/ai_manager/priority_arbitrator.rb`
- `galaxy_game/app/services/ai_manager/resource_allocator.rb`
- `galaxy_game/app/services/ai_manager/logistics_coordinator.rb`

`Manager#advance_time` invokes system orchestration only when an orchestrator is supplied. The constructor registers its target settlement when that optional orchestrator exists. `SystemOrchestrator#identify_resource_transfers` iterates over ordered pairs of registered settlement managers and asks `ResourceAllocator#identify_transfers` for potential transfers. The pair iteration does not itself establish that a valid physical route exists or distinguish same-system from cross-system movement.

### Important implementation gaps in that path

The classes and call sequence exist, but the inspected implementation is not a production-ready network resource allocator:

- `SettlementManager#settlement_resources` returns a hard-coded sample hash; `settlement_health` returns a constant; `collect_resource_requests` emits a hard-coded quantity. These are not live inventory/need calculations.
- `SettlementManager#execute_resource_allocation` only logs. `reserve_resources` logs and returns true; it does not reserve or decrement inventory. `release_resources` only logs.
- `ResourceAllocator#identify_resource_gaps` and `identify_surplus_resources` use fixed thresholds over the sample resource hash. Its transport cost is a simplified body/distance factor, not a route quote or wormhole-aware delivered-cost calculation.
- `ResourceAllocator#allocate_resources` allocates from aggregate system totals; aggregate availability alone does not prove that a particular source can supply a particular destination or that local reserves are protected.
- `SystemState` has placeholder economic-stability and logistics-efficiency assessments. Its aggregate totals are only as reliable as the settlement data supplied to it.
- `AIManager::LogisticsCoordinator` uses hard-coded route capacities and transit durations, simplified route multipliers and in-memory `active_transfers`. It combines, splits, and schedules transfer hashes; its current reservation call reaches the logging-only `SettlementManager#reserve_resources`. It is not, by itself, a persisted contract or cargo execution system.

The inspected `resource_allocator.rb` also contains two definitions of `AIManager::ResourceAllocator`; the later class definition replaces the earlier one at Ruby load time. Treat this as a source-maintenance issue to understand during implementation, not as permission to perform unrelated cleanup.

**Conclusion:** the existing orchestration is a scaffold and a likely integration point, not evidence that cross-settlement resource coordination is already operational. Do not report this capability as complete merely because these classes and methods exist.

## Existing logistics and execution candidates — source verified

### `Logistics::ContractService`

Source: `galaxy_game/app/services/logistics/contract_service.rb`

- `create_internal_transfer(from_settlement, to_settlement, material, quantity, transport_method = :orbital_transfer)` validates the settlement pair and checks the source inventory's current stored quantity.
- It attempts a player-visible contract path first, then falls back to a direct NPC contract when that path returns no contract.
- The fallback contract records source, destination, material, quantity, transport method, status, scheduled time, arrival time, and provider.
- The current delivery-time calculation is simplified: same celestial body versus different celestial bodies, with a small fixed set of transport-method durations.
- Transfer execution removes material from the source inventory and adds it to the destination inventory.

This is a concrete execution candidate and its player-first intent matters. However, the inspected source does not establish atomic source reservation, destination-capacity reservation, idempotent duplicate prevention, route revalidation, cross-system wormhole routing, or a complete funds/quote check. The implementation task must verify the current player-contract path and transaction behavior before relying on them.

### Other logistics code that must not be conflated

- `Logistics::InternalTransferService` is another internal B2B contract path. It performs a simple source availability check and creates a pending contract; its transfer processing is a separate implementation. Investigate whether it is legacy, still called, or used by a distinct workflow before choosing an owner.
- `Logistics::ImportRequestGenerator.generate_import_request(source:, destination:, shortage:)` creates a manifest and an `ImportRequest` using `Settlements::CostAnalyzer.compare_costs`. It is not a verified network optimizer or a cross-system route API.
- The wiki's ImportOrder / cycler material is explicitly marked target design intent / future work. Do not assume an `ImportOrder` model or complete cycler booking path exists merely because the design document describes one.
- `Logistics::TransportCostService.calculate_transport_cost` contains a wormhole branch using `EconomicConfig.wormhole_cost` and `wormhole_time`, but it delegates route discovery to `RouteFinder.find_best_route`. The inspected repository path for `RouteFinder` was not found. `RouteCostCalculator` uses placeholder distance cases and simplified gravity-well arithmetic. Neither establishes a verified, end-to-end cross-system cargo route quote.

Relevant source:
- `galaxy_game/app/services/logistics/contract_service.rb`
- `galaxy_game/app/services/logistics/internal_transfer_service.rb`
- `galaxy_game/app/services/logistics/import_request_generator.rb`
- `galaxy_game/app/services/logistics/transport_cost_service.rb`
- `galaxy_game/app/services/logistics/route_cost_calculator.rb`
- `galaxy_game/app/models/logistics/contract.rb`

## Economic and player-market policy

Use these wiki documents as the policy sources; distinguish design intent from verified runtime behavior:

- [Earth Anchor Price & AI Manager Escalation](../logistics/eap_and_ai_manager_escalation.md)
- [Resource & Market Logistics](../logistics/resource_and_market_logistics.md)
- [Market & AI Bootstrapping](../logistics/market_and_ai_bootstrapping.md)
- [ImportOrder & Cycler Transport Models](../logistics/import_order_and_cycler_models.md)
- [Natural Wormholes and EM](../technical/natural_wormholes_and_em.md)

Key constraints:

1. **Player-first commerce:** preserve the established player-visible market/contract opportunity before NPC fallback where the applicable policy and execution service require it. The coordinator must not silently bypass player commerce.
2. **Real GCC and affordability:** compare actual eligible options using the current settlement budget/funds and applicable price/quote rules. Do not invent money or treat an unaffordable order as executable.
3. **EAP:** use the destination- and item-specific Earth reference cost plus transport cost as the fallback comparison. EAP is not a hard-coded universal price. Emergency exceptions must follow the existing escalation policy and be explicitly recorded.
4. **Regional market knowledge:** the market wiki states that price and inventory information is settlement-local and can become stale during travel. Do not assume a live, globally shared price feed. Revalidate at the appropriate decision/execution point.
5. **Acquisition remains layered:** local production/harvesting, market acquisition, scheduled resupply, and emergency escalation retain their existing ownership and precedence. Network coordination contributes candidate sources and transfer options; it does not reimplement the acquisition tree.
6. **NPC transfers and virtual-ledger treatment:** use only the documented player-visible contract or specifically authorized DC/NPC settlement mechanism. Virtual-ledger clearing is not a default replacement for player-facing market transactions.
7. **Survival and local reserves:** a settlement's apparent surplus is not exportable until its own survival, operating, maintenance, and already-committed requirements are protected. DC survival priorities continue to apply even when trade is economically imbalanced.
8. **Controlled expansion:** coordinate only settlements and routes already established and eligible. Resource coordination does not open systems, establish footholds, or create new demand to justify expansion.

The current task must verify which of these policies are enforced in code and which remain design intent. Where they conflict, preserve the documented owner-confirmed policy and report the implementation gap; do not silently convert design intent into a claim of current behavior.

## Wormhole and cross-system transport boundary

Wormhole traversal has its own physical constraints, including stability/traversability and remaining mass throughput. See [Natural Wormholes and EM](../technical/natural_wormholes_and_em.md) and [Wormhole Network Intent](../../architecture/intent/WORMHOLE_NETWORK_INTENT.md).

Those physical rules are not equivalent to a cargo logistics quote. A usable cross-system resource route must establish, through current code:
- connected and traversable endpoints at the relevant time;
- cargo/vehicle eligibility and remaining mass capacity;
- a transport mode and operator that can actually carry the cargo;
- transit duration and full delivered cost;
- route availability and any required infrastructure;
- what happens when the route becomes unavailable or its capacity changes.

The inspected transport-cost code does not currently prove that complete interface. If the prerequisite route/cost/capacity interface is missing or only a placeholder, keep cross-system execution blocked and create or request a separately scoped prerequisite. Do not invent a new wormhole physics model in this feature.

## Target capability and planning/execution split

The eventual capability should expose a read-only planning result before any trade or cargo commitment. The exact class and method names are deliberately undecided.

A candidate plan should carry enough evidence to be reviewed and revalidated:
- source and destination settlement IDs and system IDs;
- resource/material identity, quality/specification where relevant, and quantity;
- source stock, protected local reserve, existing reservations, and exportable amount;
- destination need, current stock, committed inbound quantity, storage capacity, and required-by time;
- acquisition alternative and comparable delivered-cost breakdown (resource price, transport, handling/fees, and any other verified cost components);
- route identity, mode, feasibility, capacity, transit duration, and quote timestamp/source;
- funding eligibility and applicable player-first/market policy;
- deterministic ranking rationale, assumptions, and stale/blocked reason.

The read-only planner must not create contracts, reserve stock, move inventory, spend GCC, or schedule transport.

Execution belongs to the existing verified owner selected during investigation. Before any execution, that owner must revalidate the plan against current inventory, reservations, destination capacity, funds, quote/market state, route connectivity/capacity, and deadline. The task must not create a parallel execution path if an existing component can safely own the action.

### Safety requirements

- **No over-allocation:** source exportable stock is current stock minus protected reserve, existing reservations, and prior allocations in the same planning/execution batch.
- **No duplicate commitments:** repeated coordinator runs must not create duplicate active contracts for the same need/source/quantity/time window. Use an existing idempotency mechanism if present; otherwise propose the smallest safe addition.
- **Atomicity:** reservation and contract creation must be transactionally safe against concurrent requests. A log-only reservation is not sufficient.
- **Stale-state handling:** plans are proposals, not durable permission. Changed inventory, funds, destination demand/capacity, quotes, or routes must invalidate or trigger a fresh evaluation before execution.
- **No silent shortfall:** if no eligible route/source exists, report the unmet need and reason; do not fabricate a route or substitute a disconnected source.
- **Determinism:** equal inputs and state produce stable ranking and conflict outcomes, with an explicit tie-break rule.

## Known gaps and open questions

The following are confirmed from source inspection at the evidence baseline above; they are not claims about later uninspected commits:

- The current AI Manager network classes contain mock resource state, hard-coded needs, simplified cost and route values, log-only reservation/allocation behavior, and in-memory transfer tracking.
- The system orchestration path is optional at the Manager constructor and is not proof that every settlement is registered or that all systems are covered.
- The pairwise transfer discovery does not establish physical route reachability.
- A production-grade cross-system transport cost/capacity interface was not verified.
- Existing contract services differ in ownership and behavior; their active call sites and player-contract implementation must be traced before choosing one.
- Existing market/EAP documents contain both design intent and source-verification flags. The task must not treat all described rules as already enforced.
- No runtime test execution was performed during this wiki review.

## Validation scenarios required before claiming completion

At minimum, use deterministic fixtures for:

1. Two settlements on the same body with a valid local transfer.
2. Two settlements in one system on different bodies with a verified transport option.
3. Two settlements in different systems with a connected, traversable, capacity-sufficient wormhole route.
4. Two systems with no route: no transfer or contract may be proposed/executed.
5. A source with stock above its operating reserve but less than the requested amount after existing reservations.
6. Multiple destinations competing for the same source surplus; priority and allocation are deterministic and total allocation never exceeds exportable stock.
7. A supplier that is a single point of failure for multiple critical consumers; risk is reported without inventing an alternate supplier.
8. A local production or market option that is cheaper or faster than network transfer.
9. A network transfer that is cheaper but misses the destination deadline; it must not be ranked as a valid fulfillment.
10. A player-visible contract opportunity before NPC fallback.
11. Repeated planner/execution runs; no duplicate active commitment.
12. Inventory, funds, quote, destination capacity, or route changes between planning and execution; stale plans are rejected/replanned.
13. Single-settlement acquisition and shortage behavior remain unchanged.

## Related architecture

- [AI Manager & Autonomous Coordinators](./ai_manager.md)
- [Earth Anchor Price & AI Manager Escalation](../logistics/eap_and_ai_manager_escalation.md)
- [Resource & Market Logistics](../logistics/resource_and_market_logistics.md)
- [ImportOrder & Cycler Transport Models](../logistics/import_order_and_cycler_models.md)
- [Natural Wormholes and EM](../technical/natural_wormholes_and_em.md)
