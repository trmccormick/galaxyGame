# GalaxyGame Operational and Economic Feedback Loop

> **Status:** OWNER-CONFIRMED DESIGN INTENT — cross-system operating model; implementation and detailed subsystem rules remain subject to their individual verification status.
>
> This page explains how the simulation's infrastructure, AI Manager, missions, ships, industrial operations, markets, and players affect one another. It is an architectural orientation page, not a replacement for the detailed subsystem specifications.

## Core principle

GalaxyGame is an interconnected, continuously operating universe. Infrastructure condition and strategic objectives create operational requirements. The AI Manager evaluates and coordinates responses using available assets, capabilities, materials, production, logistics, and markets. Those responses change the state of infrastructure, inventories, production capacity, transportation activity, and economic conditions. Player and NPC activity participates in the same world and can change the options and outcomes available to everyone.

These are not independent feature areas connected only by UI. They are related views and processes acting on shared authoritative universe state.

## The operating relationship

The general relationship is:

1. **The universe has a state and objectives.** Settlements, facilities, ships, spatial fields, resource stores, production systems, and other infrastructure have locations, capabilities, inventories, operating conditions, and needs. Strategic objectives establish desired outcomes such as survival, maintenance, construction, expansion, or terraforming.
2. **Conditions create requirements.** Wear, damage, shortages, recurring consumption, new construction, expansion, and changed operating objectives create requirements for work, materials, components, services, and transportation.
3. **The AI Manager evaluates and coordinates.** It considers priorities, dependencies, available capabilities, inventories, production capacity, ships, routes, time constraints, budgets, procurement options, and applicable authority. It determines which work can be performed internally, purchased, traded, imported, contracted, deferred, or blocked.
4. **Industrial operations provide goods and capabilities.** Harvesting obtains raw materials; processing converts them; fabrication produces components and equipment; construction assembles or deploys infrastructure; maintenance repairs, prepares, or replaces existing assets. These activities consume inputs, use facilities and labor/automation, and create outputs and new operating state.
5. **Missions and mobile assets connect operations in space.** Mission profiles describe reusable operational capabilities and work. Ships and other mobile assets travel between sources, facilities, infrastructure, and destinations to perform work or move materials, components, equipment, and supplies. Their current positions, destinations, routes, cargo, availability, and mission status matter to planning and execution.
6. **Markets connect economic participants and available supply.** When requirements cannot or should not be met solely through internal production or transfers, procurement and trade can create demand for goods and services. Actual inventories, productive capacity, competing demand, available offers, imports, transport costs, and transaction rules inform availability and pricing. AI Manager procurement is one source of market activity; player and NPC production, sales, purchases, and contracts are others.
7. **Outcomes change the next decision.** Deliveries, production, construction, repairs, failures, price changes, and new capacity update the universe. The AI Manager reevaluates from the changed state. The loop continues; multiple independent operations can proceed concurrently while respecting their real dependencies.

This is a feedback loop, not a mandatory linear pipeline. The AI Manager may choose different sourcing and execution paths, and a change in one part of the universe can affect several others.

## Infrastructure creates real operational demand

Infrastructure is not static scenery. It is an operating asset with condition, capabilities, capacity, location, and requirements. It may need recurring supplies and maintenance, repair after degradation or damage, replacement of worn or damaged components, or additional capacity to meet an expansion objective.

For example, a Venus solar shade or Mars reflector swarm may require inspection, repair, component replacement, reconfiguration, or expansion. A power-beaming installation or receiving station can create analogous operational requirements. The same principle applies to settlements, stations, factories, orbital facilities, and other infrastructure.

For generic spatial fields, the owner-confirmed conceptual record is deliberately minimal: a name, one spatial location, and metadata. Metadata can describe field type, dynamic area or volume, component blueprint references, configurations, quantities, and aggregate condition. The field may be simulated in aggregate rather than as thousands of independently simulated component entities. This spatial-field design intent is documented in [Modular Orbital Panel Swarms](../infrastructure/modular_orbital_panel_swarms.md); its schema and implementation remain open.

The field or infrastructure condition is an input to operational planning. It does not by itself prescribe one fixed mission or manufacturing recipe. Mission profiles, component definitions, capabilities, requirements, and current availability inform what work is appropriate.

## Missions and ships are part of the industrial system

Missions are how coordinated work is grouped and carried out; they are not the whole operating plan. Reusable mission profiles and task/capability definitions describe possible work, prerequisites, inputs, effects, constraints, and outcomes. The AI Manager selects, combines, sequences, and adapts them to the current situation rather than following one hardcoded recipe for every asset.

A maintenance example illustrates the connection:

- A spatial field's aggregate condition indicates that some reflector or shade components need repair or replacement.
- The AI Manager determines the work required and identifies the relevant component types and quantities.
- It checks replacement inventory, fabrication capability, raw-material availability, and transport capacity.
- It arranges production or procurement as needed, then assigns suitable repair or service ships through an appropriate mission profile.
- Ships travel to the field, perform authorized work, and report results.
- The field's condition and inventories are updated; remaining requirements are reevaluated.

This is why tracking ships moving within a star system is essential. The AI Manager needs current mobile-asset locations and operational status to determine whether a ship can reach a worksite, collect cargo, service an asset, or meet a delivery window. Space View also needs to represent in-system movement as part of the universe, not merely show ships as static markers or as player-piloted avatars. The Player Space navigation boundary and autonomous craft behavior are described in [Space and Surface Operations](../player/space_and_surface_operations.md).

## Materials connect harvesting, production, construction, and maintenance

Requirements must be traceable through the industrial chain. A replacement component may require fabricated subassemblies, processed feedstock, and harvested raw materials. Expansion may require the same components at a larger scale, additional production capacity, and transportation to the deployment site.

The AI Manager therefore needs to reason across:
- required finished components and equipment;
- local and network inventories, stockpile targets, and committed quantities;
- fabrication and processing recipes/capabilities, input requirements, throughput, and available capacity;
- raw-material deposits and harvesting capabilities;
- facilities, energy, maintenance, and other prerequisites for production;
- construction and deployment requirements;
- transport capacity, ship availability, routes, fuel, and delivery timing.

A shortage of a finished component may be resolved by fabrication; a fabrication shortage may require processing; a processing shortage may require raw-material harvesting; and a missing capability may require construction or import of equipment. These are related decisions. The exact path depends on local conditions, available capacity, cost, time, risk, and strategic policy.

See [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md), [Resource and Market Logistics](../logistics/resource_and_market_logistics.md), and [Logistics and Hauling](../logistics/logistics_and_hauling.md) for their respective details.

## The market is part of the operating loop

Market activity should emerge from real economic conditions and requirements rather than from arbitrary orders detached from the simulation.

When the AI Manager identifies a material or service requirement, it can compare internal production, existing inventory, inter-settlement transfers, player/NPC market supply, and imports according to the applicable procurement rules. If it places a buy order or requests a contract, that action creates demand for the needed quantity. If it chooses local harvesting or fabrication instead, that choice affects inventories, production utilization, and potentially future market supply. If local supply is unavailable or unsuitable, imports can create demand at the relevant external interface and incur transport and other costs.

Supply also comes from actual activity: harvesting, processing, fabrication, construction output where reusable goods are produced, and goods released from inventories or offered by economic participants. Players and NPCs can respond to prices and contracts by changing what they produce, where they sell, what they buy, and which services they provide. Their actions change the supply and demand conditions faced by the AI Manager and other participants.

Prices and procurement decisions must respect the established market, currency, import, and AI Manager economic rules. This page does not introduce a new pricing formula, guarantee that every operational requirement becomes a market order, or imply that internal NPC transfers must all pass through the public market. Existing inter-NPC clearing/ledger arrangements and player-facing liquid-currency requirements remain governed by the economic pages.

The AI Manager is not intended to compete with players for profit or dominate local markets. Its economic actions serve its operational objectives and existing policy constraints. Player businesses remain independent participants, not subordinate departments of the AI Manager.

See [AI Manager Economic Loops](../logistics/ai_manager_economic_loops.md), [Markets, EAP, and GCC/USD Peg](../markets/markets_eap_and_peg.md), and [Financial Engine](../logistics/financial_engine.md).

## Players participate in the same economy

Players can create supply and productive capacity through harvesting, processing, fabrication, construction, trade, transportation, maintenance, and other supported services. They can fulfill AI Manager or NPC demand through market orders and contracts, and they can also pursue independent economic activity.

Player activity is consequential because it changes the shared state:
- supplying a scarce component can satisfy an AI Manager requirement and reduce a shortage;
- adding fabrication or harvesting capacity can change local availability and import dependence;
- operating transport can make otherwise inaccessible supply usable;
- purchasing scarce materials can compete with other demand;
- building infrastructure can create new productive capacity, services, and future material requirements.

The AI Manager's procurement and player opportunities are therefore connected. The economy is not merely a reward screen or a separate trading minigame; it is one of the mechanisms through which players influence and participate in the evolving universe.

The same underlying AI Manager capabilities support NPC autonomous operations and player-authorized automation. The source of direction, asset scope, and authority differ; the underlying task and operational concepts are shared. See [AI Manager Logic](../logistics/ai_manager_logic.md).

## Continuous coordination, not a scripted production chain

The AI Manager continuously observes game state and active work, evaluates objectives and constraints, and creates or revises plans and tasks. Independent harvesting, processing, fabrication, transport, construction, maintenance, and procurement may proceed concurrently. True dependencies must be respected, but unrelated work should not be serialized simply because it contributes to the same strategic objective.

Missions and task definitions are reusable capabilities. Example buildouts and test scenarios demonstrate possible combinations; they are not mandatory hardcoded operating recipes. Development/test orchestration may invoke capabilities directly or advance time for validation, but it is distinct from the normal in-game simulation and AI feedback loop.

The current implementation status of each service, job, market integration, movement update, and result-reconciliation path must be verified independently. This document records design intent and does not claim the complete end-to-end model is implemented.

## Architectural and UI implications

Different interfaces expose different parts of the same operating model:

- **Space View** presents spatial context and mobile movement: systems, infrastructure and fields, ships, destinations, and routes. It is not a substitute for the operational decision engine.
- **AI Manager** presents objectives, conditions, decisions, plans, missions, asset assignments, requirements, blockers, and execution outcomes. It coordinates work across domain systems.
- **Admin** provides appropriate universe-wide oversight and configuration.
- **Player economic and asset interfaces** expose the player's own operations, inventory, production, contracts, market activity, and delegated automation.

These interfaces must not become disconnected sources of truth. They should present and act on the same authoritative simulation, operational, inventory, and economic state, subject to each audience's authority.

## Boundaries and unresolved details

This model establishes the relationships among systems; it does not finalize their implementation. Keep the following open until separately specified and verified:

- exact schemas and service ownership for operational requirements, maintenance needs, material reservations, and procurement provenance;
- how spatial-field metadata and component blueprint references feed aggregate condition and maintenance calculations;
- exact mission-profile/task composition and the relationship between work orders, missions, and individual execution records;
- ship movement update cadence, navigation/route feasibility, and the authoritative location/status contract;
- detailed inventory reservation, production scheduling, capacity planning, and dependency resolution;
- market price formation, order timing/quantities, import routing, and interactions between market procurement and internal transfers;
- accounting and transaction boundaries for public markets, NPC ledger transfers, contracts, and imports;
- exact player permissions, approvals, and AI delegation limits.

Do not infer implementation from this design intent. Preserve existing subsystem-specific decisions and status labels; where detailed pages conflict, record the conflict and resolve it explicitly rather than silently replacing them.
