# AI Manager & Autonomous Coordinators

> **Wiki section:** Services · **Status:** canonical — consolidated from 6 scattered wiki pages + ~35 legacy architecture docs + direct code inspection.
> 
> **Code ground truth:** `galaxy_game/app/services/ai_manager/*.rb`, `galaxy_game/app/jobs/*_job.rb`. Every section below explicitly flags whether it reflects verified code (🟢) or target design intent (🔵).

> **Cross-link:** For terraforming demand financing through GCC budgets, Seed vs. Brute-Force contracts, and player economic participation, see **[Terraforming Economic Integration](../logistics/terraforming_economic_integration.md)**.
> 
> **Cross-link:** For the planet-class map, bootstrap peg, NPC price calculator, and order-matching models the AI Manager consumes, see **[Market & AI Bootstrapping](../logistics/market_and_ai_bootstrapping.md)**.

---

## 1. Role & Scope

The **AI Manager** (`AIManager::Manager`) is Galaxy Game's automated economy-and-logistics governor. It does **not** generate star systems, celestial bodies, or initial terrain maps. **StarSim** generates systems and celestial bodies; **Map Studio** (and related generation services) prepare or generate **initial body terrain / geographic data**. The AI Manager reads game state (including world state produced elsewhere) and issues high-level work orders to existing services. As a **design capability**, it may use learned patterns or generated options when ranking strategies or requesting work. This describes intended capability, not verified current runtime behavior; whether AI Manager consumes map-learned patterns remains OPEN pending source inspection. The AI Manager does not own the world-generation pipeline.

### Survey missions and system-data refinement — remaining work (DIRECTION; implementation/ownership OPEN)

Survey missions are one way players improve the characterization of systems as they explore them. The game needs a complete path for observations to be returned, assessed, calibrated where appropriate, and incorporated into the active system maps and celestial-body properties. The AI Manager may prioritize and coordinate survey work and assess the resulting evidence; the actual calibration/reconciliation may belong in an existing domain service or a dedicated supporting service. Do not assume that the AI Manager itself must perform every scientific calculation, and do not move StarSim generation or Map Studio terrain generation into the AI Manager.

The implementation review must establish which properties can be recalculated from known stellar/orbital/body inputs during StarSim loading, which require survey observations, and which remain uncertain. Preserve raw observations, source/provenance, and uncertainty separately from accepted active values. The responsible workflow should update accepted values and system maps only when the evidence supports doing so, without rewriting the historical StarSim seed. Existing survey, mission, AI Manager, lookup/loading, and celestial-body model code must be inspected before assigning service ownership or claiming this workflow exists.

Incomplete early generated data is not a reason to block a system from being available to players. It is acceptable starting data when the system is sufficiently plausible to use; survey and model refinement are follow-on gameplay and simulation capabilities, not prerequisites for the landing page or initial system availability.

| Domain | What it does | Code reality |
|--------|-------------|--------------|
| **Logistics orchestration** | Routes freight, schedules transfers between settlements via `LogisticsCoordinator`. Dispatches harvesters & construction tugs through `TaskExecutionEngine`. | 🟢 Active — `logistics_coordinator.rb`, `task_execution_engine.rb` (92-line service directory) |
| **Market stabilization** | NPC buyer/producer/importer of last resort; guarantees liquidity for essential items. No formal "EAP ceiling" enforcement in code. | 🟢 Partial — `market_stabilization_service.rb` implements essential-item guarantees but **not** the EAP-price-ceiling mechanism described in legacy docs |
| **Strategic planning** | Evaluates settlement state, scores mission options via `StrategySelector → StateAnalyzer + MissionScorer`, and executes via `ServiceCoordinator`. | 🟢 Active — `strategy_selector.rb`, `state_analyzer.rb`, `mission_scorer.rb` |
| **Inter-settlement orchestration** | Manages the settlement network: priority arbitration, resource allocation, logistics scheduling. | 🟢 Active — `system_orchestrator.rb` (registers settlements, coordinates them) |
| **Terraforming coordination** | Phase detection & orbital depot management for planetary programs. | 🔵 Partial intent — `terraforming_manager.rb` has skeleton `determine_terraforming_phase()` with an unresolved TODO |
| **Expansion & wormhole** | Foothold placement, wormhole scouting/placement, multi-wormhole event handling. | 🟢 Active — `expansion_service.rb`, `foothold_planner.rb`, `wormhole_*` series (3 files) |

> **Cross-link:** For early Sol build order and terraforming priority (what the AI Manager serves), see **Sol Core Buildup** (`docs/gameplay/sol_core_buildup.md`) and **Terraforming** (`docs/gameplay/terraforming.md`).
> 
> **Cross-link:** For life-support, Seed vs. Brute-Force pathways, and residual biological risk: **[Biological Terraforming Seeds](../technical/biology/terraforming_seeds.md)**.

---

## ESTABLISHED INTENT — objective-led autonomous settlement development (2026-11-09)

### Immediate development focus: the core settlement simulation

The first major development and validation target is the **core settlement simulation and the AI Manager that operates it**. This is not a claim that the first milestone will validate the entire GalaxyGame simulation or every future subsystem. The wider galaxy, additional worlds, and broader simulation capabilities build on this core; they are not the scope of the initial integrated benchmark.

**Luna is the first complete operational benchmark for this core.** The objective is not merely to construct a lunar base. The Rake-driven Luna build must demonstrate that the settlement can be established, supplied, operated, and sustained as a connected system. Its initial scope includes:

- **Lunar base construction and management:** coordinate deployment, infrastructure, power, life support, production, storage, maintenance, and ongoing operations.
- **Earth-side resupply:** forecast needs, manage procurement and shipment timing, and account for transport capacity, delivery delays, and available funds.
- **Venus atmospheric gas harvesting:** operate the remote harvesting and processing supply chain and make its outputs available to the wider operation.
- **Fuel loops:** coordinate the resources, processing, storage, and transport needed to keep fuel production and consumption operating.
- **Human population survival:** keep the crew alive through reliable life support and the supplies, equipment, and maintenance on which it depends.
- **Financial sustainability:** balance the base's operational and development needs against USD income, cash on hand, expenses, and purchasing commitments. The AI Manager cannot assume unlimited funds or buy supplies it cannot afford. It must weigh immediate survival and continuity against revenue-generating activity, resupply, maintenance, and expansion.

These responsibilities are interdependent. A harvesting shortfall can constrain fuel production; a fuel or transport shortfall can delay resupply; a resupply delay can threaten crew survival; and an unaffordable purchase cannot solve a shortage. The AI Manager must manage those trade-offs across the operation rather than optimize construction, production, logistics, survival, or income in isolation.

### Luna Rake as the reference baseline and AI validation milestone

The Rake is first used to build and manage a working Luna operation. It is a development and testing instrument that demonstrates a viable operational approach and exposes the dependencies, resource flows, timing, costs, and failure modes. It is **not** intended to become the AI Manager's permanent operating script.

Once the Rake-driven operation is sufficiently correct, it becomes a reference baseline for the AI Manager:

1. Establish a working scripted baseline that builds and manages the Luna operation, including Earth resupply, Venus gas harvesting, fuel loops, crew survival, and USD financial constraints.
2. Provide the AI Manager with the relevant mission/profile and task definitions, operating context, constraints, Rake implementation, and observed results as knowledge to assess. This does not mean V2 has already been used for training; V2 training integration remains future work.
3. Test whether the AI Manager can independently develop and execute a plan that achieves the demonstrated operational result **without invoking or relying on the Rake scripts**.
4. Test whether it can handle changed conditions, shortages, failures, and competing priorities, rather than only reproduce the original baseline.
5. Use the results to judge whether the existing training/learning prototype can be salvaged, partially replaced, or needs a complete rewrite.

The key distinction is between **replicating an outcome** and **replaying the script that produced it**. The Rake supplies a benchmark and evidence; the AI Manager must make its own strategic decisions, generate its own deployment plan and cargo requirements, and manage the resulting operation. Sustained operation and recovery from disruption are part of the test, not optional follow-up polish.

This milestone validates the core settlement simulation and its AI management. It does not imply that the entire galaxy simulation, all world types, or every later gameplay system must be complete before this work is considered successful.


The AI Manager's purpose is to establish and manage the footholds, settlements, and stations that open locations for people and enable player expansion. It should make strategic decisions from the state of the world rather than merely replay a fixed construction script.

### Strategic selection versus mission/task execution

An operator-defined mission supplies the desired outcome, target context, starting conditions, available resources, and constraints. It does not prescribe the sequence of work. The AI Manager is responsible for evaluating the world and deciding **whether** an activity is needed, **where** it should occur, **when** it should occur, and **why** it should take priority over alternatives.

During development, we use Rake tasks as **mission profiles** to exercise and validate candidate settlement approaches. These profiles represent options considered and tested at the time; they are not an exhaustive catalog of valid settlements or scripts the AI Manager must reproduce. The AI Manager should assess the target location's properties and circumstances, then compose an appropriate deployment plan. This includes drafting a cargo manifest that selects the equipment, supplies, materials, spares, and quantities that make sense for that location and objective. A tested profile can inform that decision, but the AI Manager may combine, adapt, or choose a different approach when the location warrants it. The manifest and deployment plan are outputs of strategic planning, not fixed inputs copied from a Rake task.

The checked-in V2 data currently has a limited set of Luna testing examples under `data/json-data/missions_v2/`: one precursor profile and two arrival-task JSON files. The inspected `TaskExecutionEngineV2#load_task_library` resolves `GalaxyGame::Paths::TASKS_V2_PATH`, which points to `missions/tasks_v2/`; that directory is absent from the current tracked repository tree. The separate `MISSIONS_V2_TASKS_PATH` points to the checked-in `data/json-data/missions_v2/tasks/` examples, but the generic task-library loader does not use it. Therefore, the current generic loader does not discover those two checked-in arrival-task examples. Do not describe `missions/tasks_v2/` as a currently present tracked draft library without locating its files in a later revision. The checked-in Luna examples and any separately maintained draft library must remain distinct by purpose and maturity.

The `missions_v2` / `tasks` layer describes **how an activity is carried out once the AI Manager has selected it**. It provides executable deployment or activity procedures, requirements, and steps. It is not the strategic authority that decides whether a task is appropriate, which location needs it, when to invoke it, or whether another objective is more important. For example, a task may define how to harvest and process regolith or manufacture 3D-printed I-beams and panels; the AI Manager must independently determine whether those outputs are needed, where and when to produce them, in what quantity, and how that work fits the settlement's priorities.

Existing missions, tasks, settlement patterns, and tested buildouts may provide reusable capabilities, examples, and knowledge. Reusing an execution procedure is not the same as replaying a predetermined settlement script. Strategic selection must remain responsive to the actual location, available resources, equipment condition, dependencies, changing conditions, and mission objectives.

For example, a Luna foothold mission may require a usable lava-tube settlement. The AI Manager may determine that regolith harvesting, processing, 3D printing structural I-beams and panels, sealing, power, life support, and storage are necessary. It must select and prioritize the appropriate activities; the execution layer then carries out the selected work.

For example, a Luna foothold mission may require a usable lava-tube settlement. The AI Manager may decide that regolith harvesting, processing, 3D printing structural I-beams and panels, sealing, power, life support, and storage are necessary. The mission should not hardcode the exact order and quantity of every task in advance. Those are decisions and execution details to be evaluated. Existing settlement patterns, prior missions, and tested buildouts may inform the plan, but they are reusable knowledge and references—not a fixed sequence to replay. The AI Manager must assess current conditions and adapt its priorities and path.

### Pre-player simulation as an AI validation environment

Operators should be able to run assigned missions at a chosen observation speed, accelerate through routine work, pause, inspect the resulting state, intervene when needed, and resume. Time acceleration must still execute the complete simulation and all consequences of elapsed game time. It must not skip subsystem processing or simply change the calendar.

Inspection should make it possible to evaluate completed and remaining work, resource and volatile inventories, production and construction results, equipment condition, maintenance, failures, unexpected events, and the AI Manager's decisions and responses. Mission decisions and outcomes should provide training and validation data. The first major validation target is the integrated Luna settlement operation described above; broader world and scenario coverage follows after the core settlement simulation has been demonstrated.

This is pre-player operator supervision, not a player-facing universe-speed control. The shared-universe clock and lifecycle distinction are defined in [Game Time and Simulation Loop](../engineering/game_time_and_simulation_loop.md).

### Repeatable universe snapshots (DIRECTION)

The legacy Sol buildout plan describes database snapshots as a way to preserve known Sol/Eden simulation states and resume testing from a selected point instead of repeating a long NPC-only buildout after every AI Manager change. Candidate snapshot classes include early Luna / pre-shipyard, shipyard online, core cycler loop with Mars hub forming, pre-Snap Eden at different maturity, post-Snap pre-reconnection, reconnection underway, and surveyed Eden outcomes.

Snapshots may also provide candidate seeds for optional playable starting states. Their names, storage format, tooling, retention rules, and production use are not fixed by this design direction. A snapshot is a saved simulation state, not a scripted gameplay phase or a guarantee that every player starts at the same point.



### Development priorities

The initial objective is to establish access: footholds, stations, and the essential equipment and infrastructure that make a location usable by people and players. Once access is established, the AI Manager can continue NPC settlement management and consider secondary development such as population capacity, additional services, industrial capacity, and suitable terraforming.

Terraforming is a long-horizon development activity and an intentional resource / GCC sink. Players participate economically by supplying resources through harvesting, processing, hauling, and market sales; the AI Manager / NPC development program determines its own priorities and demand. See [Settlement Progression and Footholds](../player/settlement_progression_and_footholds.md) and [Terraforming Economic Integration](../logistics/terraforming_economic_integration.md).

The AI Manager does not own all future development. After access is established, players and player corporations can build their own bases and settlements. They may also lease suitable space at NPC settlements for portal infrastructure, subject to portal technology and payload constraints. NPC infrastructure remains in operation alongside player-owned development.

**Implementation boundary:** these are owner-confirmed gameplay goals. Existing mission/task execution and strategic-planning code must be evaluated against them; the presence of planners, scorers, patterns, or sequential task engines does not by itself prove that the AI independently selects an effective settlement strategy. Implementation gaps and the appropriate decision-record/training-data model remain to be reviewed.

### Existing mission-profile and learning foundation (verified code; developmental)

#### Why the V2 mission/task work exists

The original extractor and performance-tracking work was a first implementation of the idea: mission data and decision examples could be made available to the AI Manager, and decisions could be recorded and evaluated. It demonstrated a possible direction, but it was not a complete learning system or a sufficiently mature representation of settlement work.

The V2 mission/task work is a separate, newer evolution of how settlement activities are described and executed. The repository has a distinct `missions_v2` data area, including phase/task organization, and a `TaskExecutionEngineV2` that loads a task library and interprets task definitions and effects. V2 is intended to improve the descriptions and reusable execution building blocks available for settlement work.


**V2 task-library maturity — defined does not mean validated.** The task library contains a substantial amount of authored work, but only a limited subset has been exercised so far, primarily some initial deployment tasks. The current status must therefore be distinguished carefully:

- **Defined:** Many V2 task definitions and mission profiles exist as candidate capabilities and approaches.
- **Initially tested:** Only selected tasks—mainly parts of initial deployment—have received execution testing.
- **Not yet validated:** Most of the V2 library has not yet been exercised sufficiently to establish that its procedures, requirements, dependencies, effects, and outputs work as intended.

The library is still being developed and tested. Its purpose is to give the AI Manager a growing set of executable capabilities and options, not to impose a closed or exhaustive menu of everything it may ever need to do. Tasks describe activities and their execution requirements; mission profiles illustrate possible combinations and approaches; Rake experiments exercise selected combinations and reveal what works, what is missing, and what needs correction. The AI Manager remains responsible for deciding which capabilities are needed and how to compose them for the objective and current conditions. If the required capability is not yet represented or implemented, that should be identified as a development gap—not treated as a permanent limit on the AI Manager's strategic reasoning or as proof that an unimplemented activity can already be executed.

**V2 has not yet been used for AI training.** The existing learning prototype and its mission-profile extraction are earlier work. Do not describe V2 mission profiles or tasks as already ingested into the AI Manager's training data, evaluated as training examples, or connected to the existing learning pipeline.

A future integration may use V2 profiles and tasks as better-described examples and execution building blocks for settlement experiments and AI learning. That is a prospective direction, not current behavior. The intended relationship, once deliberately developed, is:

- **Mission profiles:** candidate settlement approaches and contextual examples.
- **V2 tasks:** reusable descriptions of activities and their execution requirements/effects.
- **Rake experiments and simulation:** exercise selected combinations and expose their actual consequences.
- **Learning/experience records:** preserve examples, conditions, decisions, outcomes, and lessons with their evaluation status.
- **AI Manager:** assess the actual target and objective, then select, adapt, combine, or devise an approach and draft the cargo manifest/deployment plan.

The current extractor inspected above still scans the legacy `MISSIONS_PATH` directory and looks for profile/manifest pairs there; it does not demonstrate ingestion of the `missions_v2` structure. The V2 task engine is a separate execution foundation. Connecting V2 mission/task definitions to Rake settlement experiments, learning records, and independent AI-generated manifests remains future work. This is an implementation boundary, not evidence that V2 has already contributed training data.

#### Current V2 codebase wiring — source inspection (2026-11-21)

The V2 data layout, executor, Luna integration test, and Rake harness must be described separately. The presence of V2 path constants and JSON examples does not mean the full template architecture is currently connected end to end.

**Data locations and path resolution**

- `game_data_paths.rb` defines both the older `MISSIONS_PATH` / `TASKS_V2_PATH` locations and the newer `MISSIONS_V2_PATH` family, including constants for profiles, phases, mission plans, tasks, registry, and manifests.
- The checked-in `missions_v2` directory currently contains `profiles/precursor_mission_profile_v1.json` and two task examples: `task_venus_harvest_arrival_v2.json` and `task_titan_harvest_arrival_v2.json`. The declared V2 phase, mission-plan, manifest, and registry locations have no corresponding files in that directory at this revision.
- `TaskExecutionEngineV2#load_task_library` reads `GalaxyGame::Paths::TASKS_V2_PATH`, which points to the older `missions/tasks_v2` location, rather than `MISSIONS_V2_TASKS_PATH`. That older directory is absent from the current repository tree. Consequently, the current generic loader does not discover the two task examples stored under `missions_v2/tasks`.
- The engine's `load_phase_tasks` helper also resolves phase and task files under the older `MISSIONS_PATH`. The current `plan_tasks` implementation records phase metadata from a manifest's inline `phases` array; it does not itself resolve a V2 `mission_plan_ref`, phase registry, phase files, or task references.

**What the current Luna Rake does**

`luna_mission:execute` contains a separate, mission-specific loading and orchestration path. It can look for a V2 profile and mission plan, and it checks the V2 phase directory before falling back to older mission paths. It also hardcodes an execution order for four Luna phase IDs. This is useful integration/test scaffolding, but it is not evidence that the generic V2 engine currently owns or dynamically composes that workflow.

There are additional path and data mismatches in this harness: the task-based inventory pre-seeding helper joins each `task_ref` against the older `MISSIONS_PATH`, even when the profile/phase reference is intended to be V2. The Rake's expected Luna profile and manifest filenames are not present in the current `missions_v2` tree. The checked-in `precursor_mission_profile_v1.json` is a different example, with its own inline phase list and a Venus arrival task reference. These inconsistencies should be reconciled before treating the Rake as proof of a working, general V2 data pipeline.

**Execution and verification boundaries**

- `TaskExecutionEngineV2` has a real effect-dispatch implementation for a set of actions, and its environment loader reads the target celestial body and delegates capability discovery to `PrecursorCapabilityService`. This supports the intended world-aware direction.
- The engine is still a prototype. Its generic planning path is not yet the full mission-plan/phase/task-reference composition described by the templates. The two checked-in V2 arrival tasks use `add_to_inventory`, `set_status_flag`, and `gate_open` effects; those actions are not in the current `execute_effect` dispatch table. They therefore fall through to the unknown-action branch, which logs and returns success without applying those effects. More generally, unknown effect actions currently return success rather than proving the requested effect occurred.
- The Luna integration spec verifies database-derived Luna capabilities, that an older Luna profile produces three expected phase keys, and a material-processing service call. It does not prove that the checked-in `missions_v2` profile and task examples are loaded and executed through the V2 directory structure.
- The dedicated V2 engine spec primarily exercises resource-import helper behavior and selected effect behavior. A passing unit spec should not be interpreted as end-to-end validation of mission-plan loading, task discovery, task composition, or AI learning.

**Other documentation found**

The codebase contains more than Rake examples, but the sources have different authority and maturity:

- This canonical AI Manager wiki page records the owner-confirmed objective-led, reusable-task intent and the distinction between examples, execution evidence, and future AI learning.
- `docs/planning/AI-MANAGER—LUNA-BEHAVIOR-GOALS.md` describes the intended Luna decision behavior and the goal of using the V2 task library as the single sequencing source. It is a planning/behavior document, not proof that all of that behavior is implemented.
- `docs/architecture/ai_manager/FOOTHOLD_PLANNER_ARCHITECTURE.md` describes a thin implemented planner skeleton. It explicitly says its v2-style task sequences are hardcoded vocabulary references, not lookups from the JSON task/phase registry.
- `docs/architecture/systems/PORT_CONNECTION_SYSTEM.md` and `docs/architecture/adrs/ADR-001-Bridge-Bus-Topology.md` describe the separate asset connection/legacy-port migration. They contain differing adapter names and status descriptions; neither document by itself establishes that the V2 mission/task templates are integrated with that asset-topology work.
- Completed agent tasks, the Luna MVP blocker checklist, and session handoffs preserve implementation history and test observations. They are useful historical evidence, but dated completion labels and earlier file counts must not override the current tree and code.

**Current conclusion:** the repository contains the beginnings of the intended V2 model, a real but prototype task-effect executor, separate mission/profile examples, and mission-specific Rake integration. It does not yet contain a verified, unified path from the supplied templates and examples through generic task discovery, mission-plan/phase resolution, flexible task composition, execution evidence, and AI Manager learning. Keep the intended architecture documented as intent; describe the current implementation as partial and identify the wiring gaps above rather than silently treating the templates as a completed schema or the Rake as the architecture.

#### How to interpret the training material

Mission profiles are **options and examples**, not approved recipes. They can be supplied to the AI Manager as early training material before their effectiveness is known. A profile can illustrate a possible deployment approach, equipment combination, sequence, or set of assumptions. It remains useful as an example even if it has not been run, proves only partially effective, or fails under the conditions tested.

Simulation adds a different kind of evidence. It can record the conditions in which an option was attempted and what resulted: successful, partially successful, unsuccessful, or not yet evaluated. Outcomes should inform later assessment, but a high score does not turn a profile into a mandatory recipe, and a failed attempt does not make the example useless. The AI should be able to consider why an option did or did not suit the circumstances.

The intended progression is:

1. Provide early mission profiles and other examples as candidate approaches.
2. Run selected profiles through Rake-driven settlement experiments and record the conditions, decisions, resource/cargo requirements, execution results, and consequences.
3. Make both the examples and the observed results available as experience for AI evaluation.
4. Give the AI Manager a settlement objective and the actual target location's properties and constraints.
5. Have the AI Manager independently determine a suitable approach and draft its own cargo manifest and deployment plan. It may adapt, combine, or reject prior examples, or devise another approach.
6. Execute and evaluate that AI-generated plan, then add the new experience to the body of examples and outcomes.

The goal is not to train the AI to select whichever historical profile has the highest score. It is to help it understand the available approaches, their assumptions, their trade-offs, and the conditions under which they may be useful.

#### Multiple profiles, shared objectives, and evolving designs (OWNER-CONFIRMED, 2026-11-21)

Mission profiles are **in-game experimental strategies for pursuing shared strategic objectives**. They are not alternative definitions of what the game is trying to accomplish, and they are not a closed menu of strategies from which the AI Manager must choose forever.

The current Sol infrastructure objectives remain established: develop the Luna industrial and habitation foundation, build the Earth–Moon L1 Depot first, build the separate near-LEO Depot second, and proceed to the main station and shipyards afterward. The objectives and their required order do not become optional because the development team is testing different ways to achieve them. The profiles vary the implementation, supply chain, transport architecture, investment timing, and operational plan.

Luna is the first shared benchmark for comparing those approaches. Candidate profiles can include, but are not limited to:

- **Earth-supported Luna:** use available HLT Mk1 transport to establish the base, importing resources and equipment that Luna cannot yet produce; omit remote harvesting for this baseline.
- **Venus-supported Luna:** establish the base and operate reusable Venus atmospheric harvesting. The returning craft delivers the actual current atmospheric mixture for local separation and use.
- **Hybrid supply:** import immediate or economical requirements while developing local production and remote harvesting as demand and capability justify them.
- **Mk1-first, remote harvesting later:** use Mk1 HLT and Earth imports to establish Luna before committing to remote harvesting operations.
- **Earth orbital shipyard first:** establish orbital manufacturing infrastructure and build a dedicated harvesting craft before or alongside the Luna expansion. This is a valid architecture to test, not an established preferred build order.
- **More capable HLT before remote harvesting:** investigate whether designing and building a later HLT mark before remote operations improves mission economics or expands practical destinations. A Mk2 HLT is a proposed option only; its design, specifications, capabilities, development cost, and operating cost have not been established.
- **Multi-destination harvesting:** evaluate Venus, Titan, or combined remote operations when the actual craft, propulsion, cryogenic retention, fuel, transit, and servicing capabilities make them feasible. Titan was an early option, but the initial Mk1 harvesting configuration could not support the long-duration Titan return mission because of its cryogenic-retention/boiloff limitation. That historical constraint is not a permanent judgment about Titan or later-generation craft.

These are examples for profile design, not an exhaustive list or a commitment to implement every variant immediately. A profile may be added, changed, combined with another, or retired as in-game capabilities and evidence develop. Initial spacecraft and infrastructure designs are likewise evolutionary starting points, not permanent specifications.

#### Supply alternatives and the preferred Luna resource pathway

Earth imports remain a legitimate supply option. A profile may import any required item that Luna cannot produce locally, including nitrogen for habitat pressurization. Venus harvesting is therefore **not a mandatory source of lunar nitrogen**. An Earth-supported profile can omit the Venus harvester entirely and should be measured as a real alternative, including the recurring launch and delivery burden.

The owner's preferred strategic pathway is to use reusable Venus harvesting as part of a longer-term Luna resource economy. The harvester is serviced and repaired at Luna between missions, repeats its collection mission, and produces most of its own LOX through its onboard CO₂ processing. Methane and repairs remain important replenishment requirements; actual consumption, losses, servicing demand, and production must be measured rather than assumed away. Venus intake is the source atmosphere's actual current mixture, not a selective N₂/CO₂-only collection. Its value therefore includes multiple gas constituents and downstream industrial opportunities, not only the immediate nitrogen requirement.

For this preferred pathway, Venus-derived N₂ supports completion of the intended habitat pressurization, while CO₂ becomes a feedstock for later lunar methane production. PSR water-ice mining supplies the water-derived hydrogen needed for that methane chain. PSR mining is intended to begin with the first human crew on Luna, after the Venus harvester has returned and habitat pressurization has been completed. This timing is specific to the preferred Venus-supported sequence; it must not be imposed on an Earth-import profile that supplies nitrogen by another route. See [Lunar ISRU and Remote Gas Operations](../technical/lunar_isru_and_remote_gas_operations.md).

The longer-term rationale is that Luna can progressively reduce Earth fuel imports, supply fuel to L1 and then LEO, and reduce the amount of propellant that must be lifted from Earth's surface for onward logistics. This is the preferred strategic hypothesis, not a measured economic result or a predeclared winner. Its advantage must be established through in-game outcomes.

#### Comparing profile outcomes

Profiles should be run under documented and comparable initial conditions where a fair comparison is possible. Preserve the profile/design version, starting state, target objectives, available technologies and assets, selected tasks, task dependencies and concurrency, cargo manifests, and AI decisions. Record at least:

- initial investment and establishment cost;
- recurring operating, maintenance, repair, and replacement costs;
- Earth-imported mass, launch count, delivery cost, launch-window constraints, and transport utilization;
- remote mission duration, throughput, delivered constituent masses, fuel consumption, LOX produced/used, boiloff, and turnaround time;
- local extraction, processing, manufacturing, and fuel-production outputs;
- shortages, inventory levels, crew-survival effects, failures, delays, and recovery;
- cash flow, available USD, and affordability of purchases;
- completion time and cumulative cost at common milestones, including Luna operations, L1, LEO, and later station/shipyard expansion.

The simulation has not yet established numeric costs or a break-even point for these strategies. Do not declare the Venus route, Earth imports, an orbital shipyard, a future HLT mark, or Titan harvesting economically superior before comparable runs provide evidence. Retain successful, partially successful, unsuccessful, and unevaluated results with their conditions and evaluation status; a failed or unsuitable run is still useful evidence about constraints.

The AI Manager should learn from both the proposed profile and what actually happened when it was executed. It must be able to select, adapt, combine, or reject known approaches according to current metrics and strategic needs, and to compose a new approach that was not one of the original profiles. A missing or unimplemented capability must be exposed as a development gap; the AI Manager must not be credited with executing an operation the game does not yet support.


#### Task V2 / V2.1 development status and intended operating model

The early Venus and Titan atmospheric-harvesting mission profiles were fully worked-out, repeatable mission designs. They were not abandoned when the V2 work began. Their operational patterns and mission-specific requirements were generalized into reusable task concepts, and new draft `tasks_v2` definitions were constructed from that work. The specific early profiles remain design evidence and examples; the direction is to express their reusable capabilities through the evolving task system rather than preserve each as a separate, fixed mission implementation.

The intended system is **composable and objective-led**:

- **Task definitions** describe reusable operational capabilities: what work can be performed, its objective and expected result, required equipment/craft capabilities and fittings, assets, materials, personnel and infrastructure, dependencies and environmental constraints, execution behavior, and success/failure conditions. The exact fields and supported behaviors are still being developed; this is the intended scope, not a claim that every draft task already captures or executes all of them.
- **Mission plans** combine applicable tasks into an objective-driven plan, including the relationships and dependencies between the work.
- **Registry / phase definitions** provide reusable operational groupings and connect mission-plan logic to task definitions.
- **Profiles** supply context for a particular operating environment and runtime defaults, such as the target body's conditions and available parameters.
- **AI Manager** evaluates the objective and actual conditions, chooses which capabilities are needed, determines suitable assets and fittings, and composes/adapts the work plan. Players should ultimately be able to use the same capability library when planning and directing their own operations.

For example, an asteroid-mining objective may require prospecting, capture or positioning where applicable, mining deployment, processing, storage, and cargo transport. The planner should identify the applicable tasks, determine which available craft and assets can perform them, establish the required fittings and supporting resources, and sequence the work according to dependencies and conditions. The task library is therefore not a fixed catalog of complete missions for the AI Manager merely to select and replay. It is a reusable capability system from which missions can be constructed.

The supplied V2.1 migration templates are **work in progress**, not a finalized or fully validated schema. They describe a proposed four-part organization: mission-plan blueprints, registry/phase definitions, environment/runtime profiles, and parameter-driven task units. The draft direction includes parameter interpolation, exclusive asset locking, Bus-Topology registration, and a LegacyPortAdapter bridge for compatibility with existing port-based execution. The migration notes identify corresponding engine and test-harness work that is still required. These capabilities must not be described as implemented or proven solely because they appear in templates. The early harvesting profiles are source material for this generalization; the templates and draft tasks are the current evolving representation.

#### Rake buildout benchmark — intended end state

The immediate practical objective is to build an integrated Rake-driven test harness that can **run and evaluate the Luna buildout as an operating system**, not just validate isolated mission files or demonstrate one-time construction. The Rake harness is a development/validation instrument and reference baseline. It should exercise the real application services, task execution, inventory/resource accounting, logistics, and settlement simulation wherever those are implemented; it should expose missing or stubbed behavior rather than silently treating simulated placeholders as production results.

The integrated benchmark is intended to cover the connected operational chain:

- establish the initial Luna foothold and deploy the required craft, equipment, cargo, and settlement infrastructure;
- execute construction and local industrial/ISRU work, including the regolith-processing and manufacturing chain;
- establish and operate the required power, storage, life-support, and resource-handling systems;
- coordinate Earth-side imports and resupply against delivery timing, available transport, inventory, and available USD;
- run the Venus atmospheric-gas harvesting and return supply chain, including the gases needed by the Luna operation;
- operate and validate the fuel-production, storage, transfer, and consumption loops;
- sustain the human population through ongoing operations, maintenance, and resupply; and
- track costs, income, cash constraints, shortages, production, losses, and operational outcomes over elapsed simulation time.

The benchmark should report measurable initial conditions, task/mission execution, resource and inventory changes, construction and production outputs, transport and timing results, import/purchase decisions, financial state, crew-survival conditions, failures, and final operating status. It should be repeatable enough to compare changes and to provide evidence about what works, what fails, and which task definitions or services need further development. The specific acceptance thresholds and scenario coverage remain to be defined as the harness is assembled.

The three supplied Rake examples show pieces of this work, but they are **separate and incomplete experiments, not yet the integrated benchmark**:

- `lunar_precursor_mission_validation.rake` checks selected bootstrap and interplanetary mission/profile/manifest structures, expected hardware and outputs, variance-based harvesting yields, and a modeled timeline. Its own comments distinguish modeled yield estimates from production calculations.
- `lunar_base_with_isru_pipeline.rake` creates a Luna settlement, loads a precursor manifest, invokes the existing task engine, and exercises construction and an ISRU/manufacturing example. The supplied version contains explicitly labeled stubbed production/inventory behavior and auto-fulfills construction material requests for the simulation.
- `luna_operations_simulation.rake` runs a daily-tick operations service against an already-deployed settlement and reports import decisions and tracked inventories. It depends on a prior deployment and does not itself construct or supply the complete operation.

These scripts are useful starting evidence and should be reviewed for reusable logic, dependencies, and gaps; they should not simply be treated as one finished test by concatenating them. The intended work is to connect the necessary capabilities into a coherent, repeatable buildout-and-operations benchmark and progressively replace validation-only or stubbed paths with verified application behavior.

**Relationship to AI Manager validation:** first use the Rake harness to establish and measure a viable reference operation. Then assess whether the AI Manager can independently select and compose the reusable tasks, determine assets and fittings, generate its own deployment/cargo plan, and sustain the same objective under the tested constraints—without invoking or replaying the Rake script. Later tests should vary conditions and introduce shortages or failures to evaluate adaptation. The Rake is the benchmark and evidence source; it is not the AI Manager's permanent operating logic.

**Current status:** task V2/V2.1 definitions and templates remain under development; the early Venus/Titan profiles have been generalized into this task direction; the supplied Rake files cover separate portions of the Luna bootstrap, ISRU, and operations problem; and the integrated end-to-end Luna buildout benchmark remains to be built and validated.



#### External world examples and world-generation learning

**ESTABLISHED OWNER INTENT — 2026-11-15**

GalaxyGame may use maps and scenarios from other games and creative projects—including Civ4, FreeCiv, SimEarth, and fictional-world examples—as **learning and reference material** to improve its own world-generation capabilities. These materials are not intended to be imported as playable GalaxyGame maps, copied directly into celestial-body terrain, or treated as authoritative planetary datasets.

The owner reports that some external examples have already been ingested into the existing generator/training work and that an initial AI-training effort has already been attempted. That work is incomplete: the current generator does not yet provide the expected results. This is therefore a direction for reviewing and improving existing ingestion, training, and generation capabilities—not a proposal to create a parallel training library or start the feature from scratch. The current implementation, data flow, and remaining gaps must be established by code inspection.

Examples may help **world-generation and planning workflows** recognize and propose options involving:

- Terrain, elevation, biome, and geographic arrangements or distributions.
- Resource types, density, and spatial distribution.
- Candidate settlement locations and settlement patterns.
- Environmental organization and relationships among terrain, resources, and habitability.
- Human-designed hypothetical worlds, including imagined terraforming outcomes.
- Designer descriptions, scenario notes, and stated reasoning where that context is available.

The intent is to learn **patterns, possibilities, and design approaches**, not to reproduce source maps, inherit their game mechanics, or treat their hand-authored placements as facts. Game-balanced resource placements and settlement starts are examples of human choices, not verified geology, resource surveys, or proof of settlement viability.

Interpretation must keep three evidence types distinct:

1. **Examples:** what a map author or scenario designer created, assumed, or considered desirable/plausible.
2. **Observations:** what real planetary, geological, elevation, atmospheric, and other source data establishes about the actual body.
3. **Simulation outcomes:** what GalaxyGame's Digital Twin/TerraSim produces when a proposed configuration or intervention is tested under modeled conditions.

These evidence types can inform one another but must not be conflated. Where real planetary data exists, it should constrain and contextualize learned examples. Where data is incomplete or unavailable, examples may broaden the options considered, but their uncertainty and provenance must remain visible. Simulation can then test proposed configurations and provide outcome evidence; a designer's scenario description remains evidence of design intent, not scientific validation.

A terraformed-world map can therefore be useful as an example of one possible future configuration and of the creator's assumptions. It is not an instruction that the target body should be terraformed. For example, a terraformed Mars scenario may help the AI Manager propose possible biome or water distributions for a hypothetical Mars intervention. The Digital Twin can evaluate such a proposal and report its consequences. By contrast, a Titan map may be useful for studying how a designer represented an unusual environment, terrain/resource patterns, or settlement ideas; it must not be interpreted as a recommendation to terraform Titan. The body's natural state and the actual objective must govern whether terraforming is appropriate at all.

The desired result is that learned patterns can inform **context-sensitive options** for GalaxyGame's own worlds—options that can be evaluated and selected in light of the target body's observed properties, intended natural or hypothetical state, and simulation evidence. **Map Studio and generation services** remain responsible for producing initial terrain. The **AI Manager**, as a design capability, may use such options when ranking or requesting work. This describes intended capability, not verified current runtime behavior; whether AI Manager consumes map-learned patterns remains OPEN pending source inspection. The system must not assume that every world is an Earth-like terraforming project.

**Implementation status:** The existence of prior ingestion and training attempts is owner-reported context, not a verified description of the current code path. The audit must identify which example formats and files are currently ingested, how their content and metadata are represented, whether designer/scenario descriptions are retained, where training or pattern extraction occurs, how the generator consumes the resulting knowledge, and what remains disconnected or incomplete. Do not claim a functioning end-to-end learning pipeline until the code demonstrates it.

#### Current implementation gaps and cautions

The following are observations about the inspected code, not changes to the intended design:

- The current test-scenario extractor supplies expected decisions and success criteria as predefined examples. That is useful for early scenario coverage, but it is not evidence that the AI has learned those decisions from execution.
- Mission extraction currently represents profile phases as a deployment sequence and extracts manifest information. This is an example/pattern extraction path; it does not establish that the AI independently derives the best manifest for a new target.
- The extraction task writes mission/test patterns to `AI_MISSION_PATTERNS_PATH`, while `OperationalManager#load_trained_patterns` reads JSON files from `AI_SETTLEMENT_PATTERNS_PATH`. The inspected paths therefore do not show a direct connection from that extraction output to the pattern set used by this manager.
- `PerformanceTracker` currently compares a small fixed set of settlement metrics and ranks actions from similar decision records. Its similarity and recommendation logic is a basic prototype, not a complete model of location properties, mission objectives, logistics, equipment capability, or strategic trade-offs.
- The tracker can record decisions before an outcome is available. Its current recommendation calculation does not explicitly exclude records with missing outcomes/scores, so unevaluated records must not be treated as measured successes or failures.
- The tracker writes per-settlement performance files under the AI Manager performance subdirectory, while the current `analyze_performance` Rake task searches for `performance_*.json` files directly under the AI Manager data directory. The inspected paths appear inconsistent and need implementation review.
- The current `SettlementPlanGenerator` selects a named mission-profile filename from broad system characteristics and creates a high-level plan. The inspected implementation does not yet produce the location-specific, itemized cargo manifest described in the established intent.
- The uploaded `performance_simulation_001.json` is an example of the existing decision-history shape: repeated decisions, recorded context, outcomes and scores where available, and lesson strings. Its mixture of evaluated and unevaluated records illustrates why provenance and evaluation status need to remain distinguishable.

These gaps should be reviewed against the owner-confirmed intent before implementation work is specified. Do not treat current hardcoded scenarios, profile selection, scoring, or file paths as design constraints. The codebase is the evidence of current behavior; this section records the intended direction and identifies where the two do not yet align.


---


## Mission execution records and operational observability

**OWNER-CONFIRMED DESIGN INTENT — 2026-11-23; implementation remains to be audited/built**

Mission execution must produce inspectable evidence of what the system actually did. This supports both live supervision of normal AI Manager operations and retrospective evaluation of development/test runs. The UI's scrolling terminal-style activity log is a presentation of this execution history; the current static mockup is not evidence that event capture, persistence, or live delivery already exists.

The operational record should distinguish at least:
- mission/run identity, objective, target/scope, start/end, and final status;
- task identity, provenance, dependencies, start/completion times, status, and outcome;
- significant AI Manager decisions and their recorded rationale/evidence, without fabricating reasoning that was not captured;
- domain events and resulting changes, including assets/structures created or commissioned, inventory and stockpile deltas, volatile production/consumption/transfers and storage levels, GCC flows, logistics/shipment events, financial effects, maintenance, warnings, and failures;
- links to the authoritative resulting world state and, where available, intermediate checkpoints or time-series measurements.

Task-completion events are important append points for the chronological scrolling activity log. Other significant events may also be recorded as they occur. Concurrent tasks report independently; the history must preserve actual event timestamps/order and task/run context rather than impose a false sequential mission narrative. Current mission/task status is a separate projection of the latest state and should not be reconstructed only by reading the log.

The same underlying records should support:
1. live activity/status views during normal gameplay operation; and
2. historical inspection of completed or interrupted development/test runs, including runs that use accelerated simulation time, deliberate time jumps, direct task/service execution, or other test orchestration.

Test harnesses may intentionally bypass the normal game loop or scheduler to exercise an end-to-end capability without waiting for ordinary elapsed game time. That is legitimate development infrastructure. Such runs should reuse the same domain services/capabilities wherever possible and capture the resulting execution evidence and authoritative world-state changes. They do not define the production operating loop. Normal production integration must still be verified independently: simulation-time checks/events, AI Manager decisions, task dispatch, asynchronous execution, state reconciliation, and subsequent evaluation.

For a Luna end-to-end run, inspection should make it possible to determine not merely whether the mission completed, but what was built, what remains operational, what was produced and consumed, what was imported or transferred, what was stockpiled, how volatile storage changed, how GCC flowed, what the operation cost/earned, and where failures or unexpected behavior occurred. The final result and intermediate history should be available for comparison against expected outcomes and prior runs.

Exact event schemas, retention policy, streaming mechanism, checkpoint cadence, and API contracts remain OPEN. Do not assume every domain already emits suitable events or that one generic log message is a substitute for authoritative inventory, storage, asset, or ledger records. Preserve provenance and references to the relevant domain records; keep source-verified implementation separate from this target design.

---

## 2. Core Service Inventory (Source-Verified; Runtime Maturity Varies)

The active codebase has **92 service files** in `galaxy_game/app/services/ai_manager/`. Below are the authoritative classes organized by responsibility.

> **Verification boundary (2026-11-23):** The 🟢 marker in this inventory confirms that a source class/file is present; it does not certify a production call site or a working end-to-end workflow. A focused audit found that network-scale coordination and several supporting inventory, acquisition, logistics, transport, and ledger paths remain scaffolding or partial implementations. See §2.13 and §3.2–3.5.

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

### 2.13 Network-scale coordination maturity (source audit 2026-11-23)

The current source does **not** satisfy the multi-settlement/multi-system coordination contract yet:

- **Runtime entry point:** `Manager` accepts an optional `SystemOrchestrator` and calls it when supplied, but no production construction/injection of `SystemOrchestrator` was found in the tracked application. The references found were the integration spec and a manual test script.
- **System state and allocation:** `SettlementManager` still supplies mock resource quantities and a default energy request; `SystemState` is in-memory and contains placeholder economic/logistics metrics. `ResourceAllocator` does not move or reserve inventory, and its reopened class definition overrides the older initializer while the legacy spec still uses the old keyword signature. `PriorityArbitrator` relies on hardcoded resource limits.
- **Logistics scheduling:** `LogisticsCoordinator` uses hardcoded route capacities, durations, and cost estimates. Its settlement-manager lookup returns `nil`, its combined/split transfer hashes do not match the scheduler's expected single-resource shape, and its reservation helper is only a logging stub. It is not connected to the wormhole route planner or a persistent contract lifecycle.
- **Per-settlement acquisition:** The current acquisition paths are fragmented. `StateAnalyzer` does not return several state keys expected by `StrategySelector`; existing specs stub those keys. The resource-request loop checks that inventory already meets the request before ordering acquisition. The pre-player tree method exists in `EscalationService` but is not wired into its shortage entry point; its inventory query does not match the actual `Inventory`/`Item` model. `ResourceFulfillmentService` calls a `MaterialRequestService.request_materials` method that is not present in current source.
- **Inventory reservations:** Settlement inventory is an `Inventory` record with associated `Item` rows. No authoritative reservation model/API was found; `SettlementManager#reserve_resources` is not a reservation implementation.
- **Wormhole and transport inputs:** `Mission::TransitEngine` deliberately handles intra-system transit and rejects cross-system routes. `WormholeNavigator` queries fields that do not match the current `Wormhole` model. `WormholeCoordinator` has prototype routing with fixed cost/time estimates and is not integrated into logistics. Current route-cost helpers do not provide a usable wormhole-aware delivery estimate.
- **Contracts and finance:** Multiple contract/fulfillment paths coexist, but no verified end-to-end provider reservation → cargo movement → arrival → settlement/payment flow was found. The virtual-ledger service records entries; it does not itself settle balances or move goods.

The current design direction remains: system-wide coordination sits **above** reliable per-settlement acquisition and transport. It must consume those decisions and capabilities rather than create a parallel acquisition system. The 2026-11-23 source audit and detailed file evidence are recorded in [the multi-system resource coordination research report](https://github.com/trmccormick/agent-tasks/blob/main/projects/galaxyGame/summaries/2026-11-23-ARCHITECTURE-MULTI-SYSTEM-RESOURCE-COORDINATION.md).

---

## 3. Autonomous Coordinator Responsibilities (Source Presence Verified; Behavior Varies)

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

🟡 **Class and method structure present; operational coordination not verified.** `Manager` invokes `orchestrate_system` only when an orchestrator is injected. No production construction/injection was found in the tracked application. The current `SettlementManager` data is mocked; allocation execution only logs; and `LogisticsCoordinator` cannot currently schedule a real transfer. See §2.13.

### 3.3 StrategySelector (Autonomous Decision-Making)

🟡 **Source path present; state contract is inconsistent.** `StateAnalyzer` currently returns inventory, surface storage, power availability, and cost analysis. `StrategySelector` expects additional keys such as `resource_needs`, `scouting_opportunities`, `expansion_readiness`, and capability scores; the existing StrategySelector specs stub those keys rather than obtaining them from the real analyzer. The decision path therefore needs reconciliation before it is treated as a reliable autonomous loop.

### 3.4 PriorityArbitrator (Priority Conflicts)

🟡 **Class present; policy execution is partial.** Priority levels and grouping exist, but resource limits are hardcoded, the grant check is not used by the main arbitration path, and the allocator is not backed by authoritative inventory or reservations.

### 3.5 LogisticsCoordinator (Transfer Scheduling)

🟡 **Class present; real scheduling is not operational.** Route capacities, durations, and costs are hardcoded; `find_settlement_manager` returns `nil`; combined transfer shapes do not match the scheduler's expected fields; and reservations are not persisted. No wormhole-aware route or contract-delivery integration is present.

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

**OWNER-CONFIRMED ARCHITECTURAL INTENT — 2026-11-23:** Sidekiq is part of the intended in-game execution architecture for delegated work that should run asynchronously and concurrently. The AI Manager decides what work is appropriate, evaluates dependencies and priorities, and dispatches eligible work; Sidekiq executes jobs. Job completion, failure, partial results, and resulting state changes must be reconciled into the continuing AI Manager/game simulation loop.

Not every operation should become a Sidekiq job. Lightweight simulation-time checks and event/condition evaluations—such as launch-window checks, elapsed production intervals, arrival/maintenance due checks—belong in simulation/game-loop processing where appropriate. A check can cause the AI Manager to schedule substantive work, but the check itself need not be a background job.

| Job | Queue | Verified behavior |
|-----|-------|-------------------|
| `SafetyNetLogisticsJob` | default | Checks for unfilled buy orders → triggers AstroLift logistics contract from Earth Base if provider exists |
| `LocationOperationsCoordinatorJob` | coordination | Sidekiq job queuing per-location and inter-location operations; re-schedules itself hourly |

**Implementation audit remains OPEN:** The table above records jobs verified in the source inspection represented by this page; it is not a claim that these are the only jobs in the repository or that the complete game-loop → AI decision → Sidekiq dispatch → result-reconciliation cycle is wired end to end. Inventory relevant jobs, queues, scheduling triggers, retry/failure behavior, idempotency, task/mission state transitions, and feedback into authoritative game state before making runtime-completeness claims. The architectural role of Sidekiq is resolved; the remaining question is how completely the existing implementation realizes it.

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
- **Code:** `Tier1PriceModeler.calculate_eap` computes EAP as `(earth_spot_price_usd * refining_factor) * usd_to_gcc_peg + transport_cost_GCC` in GCC/kg (see `markets/markets_eap_and_peg.md`). The MarketStabilizationService and broader AI Manager still lack an explicit **price-ceiling check** that rejects purchases above EAP — the EAP is computed but may not be enforced as a rejection threshold.
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

### GAP 6: Pre-Commit Expansion Scouting (NEW)
- **Intent:** AI Manager should scout and evaluate unconnected systems before deciding whether to establish permanent network connections.
- **Code:** `ScoutLogic` and `WorldKnowledgeService` exist but pre-commit evaluation is not implemented as a formal gate.
- **Status:** 🔵 Target design intent only

---

## ESTABLISHED INTENT — AI Manager expansion: scout before commit

Before committing resources to establish permanent network connections (AWS stations, stabilized wormholes) in unconnected systems, the AI Manager should:

1. **Scout** — Deploy probes to evaluate the target system's resources, stability, and strategic value.
2. **Evaluate** — Score the system against expansion criteria (resource richness, colonization potential, strategic value, exploration cost).
3. **Decide** — Only commit permanent infrastructure if the evaluation meets a threshold. Otherwise, maintain a temporary presence or abandon the system.

**Design implications:**
- Prevents wasteful investment in low-value systems.
- Creates natural expansion pacing — the AI Manager doesn't instantly connect every discovered wormhole.
- Players can observe and influence which systems get developed (e.g., by providing scout data or investment).
- Aligns with the "graduated investment" exploration strategy already noted in WORMHOLE_NETWORK_INTENT.md.

**Undecided implementation details:**
- What is the minimum scout data required before a commit decision?
- Can players override or accelerate the AI Manager's expansion decisions?
- Does the AI Manager revisit systems it previously rejected, or is that decision permanent?

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

## 2026-11-23 — Luna task execution: persisted game objects versus operational behavior

A focused source inspection of `luna_mission:execute` and `AIManager::TaskExecutionEngineV2` establishes that the Luna Rake is more than a report-only mock, but it does not yet demonstrate a fully operating settlement. The Rake invokes task effect handlers against Rails models; some handlers persist real records and state, while others only log intended work and return success.

### What the current runner really does

- The Rake resolves its four named Luna phases and follows each phase's `task_ref` entries to the selected task JSON files. It is a mission-specific execution harness; its explicit order is `power_comms`, `isru_deployment`, `gas_processing`, and `robot_logistics`.
- It creates or locates a Luna settlement and associated location, seeds inventory records from the manifest (and may create a HeavyLander record and cargo inventory in the launch-staging branch), then invokes `TaskExecutionEngineV2#execute_task` for each referenced task.
- `deploy_unit` consumes a matching settlement inventory item and creates persisted `Units::BaseUnit` records with blueprint-derived or fallback operational data.
- `connect_units`, `register_to_bus`, `set_unit_state`, `set_settlement_state`, and deployment-stage advancement persist selected topology or state data to unit/settlement records.

These are real database side effects. They establish that the task runner can create game objects and record some relationships/state; they do not establish that those objects are being operated by the ordinary simulation loop.

### Known execution gaps in the inspected V2 effect dispatcher

- `construct_structure` is explicitly unimplemented; it logs the requested structure and returns success.
- `transfer_resource` logs a transfer/configuration but does not move inventory or create a functioning transfer process.
- `manufacture` logs the output and quantity but does not invoke production or add manufactured inventory.
- `check_unit_state` logs a successful verification without checking the unit. The Rake has a separate post-execution verifier for some known actions, but its fallback labels unsupported actions as unverified; an unverified-only result is currently considered passed.
- Unknown effect actions are skipped and return success. This can make unsupported task effects appear successful.
- Some effect handlers return success when the settlement is absent, rather than failing the task.
- Deployment-stage advancement persists stage metadata, but that metadata alone does not prove that the physical operation represented by the stage occurred.
- The Rake's launch-staging branch creates a HeavyLander and cargo records and copies cargo into settlement inventory. This harness path does not, by itself, prove that an actual launch, transit, arrival, or cargo offload was simulated.
- The Rake pre-seeding helper that derives deployable inventory from task effects resolves task references through the older `MISSIONS_PATH`; this needs to be reconciled with the V2 task-ref convention before relying on it as a general inventory derivation mechanism.

### Correct interpretation

The current Luna Rake is a **database-backed integration harness**: it exercises selected task definitions, creates persisted settlement/unit/inventory records, and checks selected resulting state. It is not yet evidence of a complete physical/logistical simulation or sustained settlement operation. In particular, creating a deployed unit record is distinct from having the normal game loop recognize, schedule, and operate that unit.

The AI Manager's intended responsibility is broader than selecting task names. It must be able to plan, execute, and verify complete operations through the game's authoritative domain services. A task should only be reported successful when its requested outcome is reflected in authoritative game state. Unsupported effects, skipped work, log-only placeholders, and unverifiable outcomes must not silently count as success.

### Required implementation direction

The follow-on AI Manager work is tracked in `agent-tasks/projects/galaxyGame/tasks/backlog/ai-manager/2026-11-23-HIGH-FEATURE-AI-MANAGER-END-TO-END-TASK-EXECUTION.md`. The task is to inventory the effects used by the Luna-selected task set, connect each supported operation to existing authoritative game services/models, implement or explicitly reject unsupported effects, and add persistence-backed verification and targeted tests. The Luna Rake remains the benchmark harness and must not become the permanent hardcoded AI operating script.

This audit is limited to the inspected Rake and V2 executor paths. It does not claim that no other game services already implement the missing operations; the implementation task must locate and reuse those services before adding new logic.

