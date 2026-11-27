> **Wiki section:** UI & Experience · **Status:** Established dashboard separation; individual workspaces and layouts remain DIRECTION / OPEN  
> **Last Updated:** 2026-11-27

# Admin Dashboard and AI Manager

This page records the responsibilities of the Admin Dashboard and its dedicated workspaces. It complements [Player View Architecture](02_player_view_architecture.md). Player and Admin serve different audiences and authority scopes; shared game-domain models and presentation patterns do not imply shared management rights. Admin manages NPC-controlled bases and simulation/world operations. Players manage their own bases and assets. Developer tools for patch development and technical debugging are separate from the Admin Dashboard. See [Mission Profiles, Templates, Tasks, and Execution](07_mission_profiles_tasks_and_execution.md) for the detailed shared mission/task model.

## 1. Player Dashboard versus Admin Dashboard

**ESTABLISHED INTENT — 2026-11-13**

- **Player Dashboard:** supports people and organizations participating in the shared universe. It provides three primary Player views—Planetary, Surface, and Settlement—plus the separate Space context.
- **Admin Dashboard:** supports administrators operating the application and managing the simulation, world generation, data, configuration, users, and operational systems.

The dashboards have distinct entry points, navigation, audience context, and authority. They may reuse domain models, data services, and visual patterns, but their management targets are not interchangeable:

- **Player:** manages the bases and settlements the player owns, along with the player's own assets and businesses. Player settlement controls are scoped to those holdings.
- **Admin:** has authority to inspect, configure, and adjust NPC-controlled bases and other simulation/world systems within the Admin role. Admin settlement-management tools are for NPC bases, not player-owned bases; routine Admin workflows have no reason to inspect or adjust a player's base.
- **Developer:** patch-development and technical debugging tools are separate developer tooling, not an additional Admin permission level or a reason to expose player bases in the Admin interface.

A player may be allowed to operate a business or owned assets at an NPC foothold, but that does not give the player control of the NPC settlement or its shared infrastructure. Conversely, Admin authority over NPC bases does not imply operational authority over player bases.

Admin also has genuinely administrative-only workspaces, including shared Task and Mission Template Library management, global operational monitoring, configuration, diagnostics, and application administration. Those do not need Player duplicates.

AI Manager is a major workspace within Admin for system-wide supervision and shared-library administration. Players use the same underlying AI Manager capabilities through a Player-scoped control surface for their own objectives, policies, missions, and assets. It is one autonomous-management system, not separate NPC and Player implementations.

Use the shared dark charcoal/navy and cyan design language across the product. Cyan is the primary interaction accent; green is for success/healthy/operational state; amber for warnings; red for errors or critical conditions. Keep typography compact and readable, with clear hierarchy and adequate spacing. Do not force every Admin tool into one generic card dashboard.

## 2. Admin Dashboard work areas

**ESTABLISHED SCOPE DIRECTION — 2026-11-13; individual screens OPEN**

The following is an administrative capability inventory, not a finalized navigation tree or a one-screen-per-bullet commitment. We will decide the exact screens and grouping one workspace at a time.

### Admin overview and system panels

The Admin landing dashboard should summarize application and simulation health and provide access to major workspaces. Candidate panels include service status, active simulation processes, background jobs, data-processing/import/export activity, alerts, recent administrative events, and items requiring attention.

### AI Manager

AI Manager supervision and strategic operations are described in Section 3.

### Map Studio

Map Studio is an Admin tool in the connected planetary-data pipeline. It supports known-world reconstruction from observational data and generation of plausible extrasolar geography. Preserve existing generation work as evidence; its output quality and pipeline need review. The Admin UI should expose source data, coverage, assumptions, quality, processing status, and appropriate generation/inspection controls as supported by actual services.

Map Studio and Digital Twin have different responsibilities: Map Studio concerns planetary data and geography preparation; Digital Twin concerns environmental projection, evaluation, and simulation-system tuning (see below).

Map Studio is retained as an Admin capability. The legacy Rails 7 route and controller action set are source-verified: `GET /admin/map_studio` (index), `GET /admin/map_studio/generate`, `POST /admin/map_studio/generate_map`, `GET /admin/map_studio/browse`, `POST /admin/map_studio/apply_map/:id`, and `GET /admin/map_studio/analyze/:id`. Whether the current Admin navigation exposes every entry point is a separate UI check. See the code snapshot below and [Status and gaps](../status_and_gaps.md).

### Map Studio — current Rails 7 implementation snapshot

**SOURCE-VERIFIED PARTIAL AUDIT — 2026-11-20.** Inspected `Admin::Map StudioController`, the Admin routes, `AIManager::PlanetaryMapGenerator`, and `StarSim::AutomaticTerrainGenerator`. This is evidence of the legacy implementation, not approval of every current behavior as the final design.

**Map Studio controller flow**

1. The Map Studio index inventories source maps and previously generated map JSON files, reports generation statistics, and reads a planetary-map learning-status JSON file when present.
2. The generation page selects a target celestial body and available source maps.
3. The generation action processes selected FreeCiv `.sav` and Civ4 WorldBuilder files through `Import::FreecivMapProcessor` and `Import::Civ4MapProcessor`, then calls `AIManager::PlanetaryMapGenerator#generate_planetary_map`.
4. The generated map is saved as a separate JSON artifact under `GalaxyGame::Paths::GENERATED_MAPS_PATH`, with metadata including target body, source-map references, and generation time.
5. The browse/analyze actions inspect those generated artifacts. Applying a map is a separate action: it writes the generated terrain grid, dimensions, and biome counts to the selected body's `geosphere.terrain_map`, and records `applied_map` metadata and `map_source` in body properties.

This means Map Studio first creates a reusable/prepared map artifact and only changes a body's stored terrain when the separate apply action is used. The controller comment describes map generation as independent of celestial bodies, but the actual workflow still uses a selected target body for generation parameters and later applies the result to a body.

**Generation paths visible in current code**

- When source maps are selected and successfully processed, `PlanetaryMapGenerator` combines source biome grids and available source elevation data into a new terrain grid. This is generation from processed reference inputs, not simply attaching the original game map as the playable body map.
- When no source maps are supplied, the generator follows a pattern-based path. It attempts to load planet-specific elevation data; if unavailable, it constructs a body-specific landmass/elevation pattern from reference statistics, then derives barren biomes, resource locations, and strategic markers.
- `StarSim::AutomaticTerrainGenerator` is a separate automatic path. It skips bodies that already have populated terrain data and bodies outside its supported planet/major-moon scope; it has special handling for Sol worlds and otherwise derives generation parameters from body properties before calling the planetary map generator and storing terrain on the geosphere.
- The existence of these services does not prove that every newly created body automatically receives terrain. The invocation points and full end-to-end lifecycle still need verification.

**Additional source-verified experimental paths — 2026-11-21**

The current code contains more than one map-analysis/generation experiment. They must not be described as a single integrated learning pipeline:

- **Map Studio / `PlanetaryMapGenerator`:** The selected-source path uses the first processed map as the base, scales its categorical biome grid to the target dimensions, and overlays subsequent sources cell-by-cell with a 70% replacement probability. Available source elevation values are copied at corresponding scaled cells. This is probabilistic map blending; the inspected method does not perform the intended geographical regression/reconstruction or demonstrate a trained model.
- **Resource placement:** `ResourcePositioningService` is invoked after source-map combination. Its current rules are hard-coded terrain/elevation ranges, rarity percentages, and clustering factors, followed by random selection of suitable cells. Strategic markers are generated from simple body-name/terrain/elevation/resource heuristics. These are experimental heuristics, not geological deposit modeling or validated settlement-site analysis.
- **Earth-specific experiment:** A separate Admin celestial-body workflow (`select_maps_for_analysis` / `generate_earth_map`) calls `AIManager::EarthMapGenerator`. That service processes FreeCiv/Civ4 maps, extracts terrain/elevation/strategic patterns, builds an Earth map, applies heuristic optimizations, and records learning data. Its code reads/writes an Earth-map learning JSON file and reads an Earth template JSON file. This is a distinct legacy/experimental path; it is not the Map Studio controller flow and must not be assumed to share its artifacts or training state.
- **NASA DEM helper methods:** `PlanetaryMapGenerator` contains `add_nasa_dem_training_source` and `generate_with_nasa_training` methods. The inspected Map Studio controller does not call these methods. Their presence is not proof that NASA DEMs are incorporated into the selected-source learning workflow.
- **Learning-status display:** The Map Studio index optionally reads `data/ai_learning/planetary_map_learning.json`. In the inspected controller, this is a status-display read; the generation action does not load that file or pass its contents to `PlanetaryMapGenerator`.

The repository therefore contains several pieces of experimental map analysis, pattern extraction, resource heuristics, and learning-data persistence, but this source pass does **not** establish a connected, reusable training pipeline that feeds learned geographical knowledge into Map Studio generation. The intended geographical learning/reconstruction capability remains a design goal; the current experiments are evidence to inspect and selectively reuse, not proof that the goal has been achieved.

### Map Studio — desired capabilities and generation options

**OWNER-CONFIRMED DESIGN DIRECTION — 2026-11-21; implementation and detailed ownership OPEN**

Map Studio should ultimately support game-generated planetary geography and the identification of useful natural resources and settlement opportunities. The goal is not to require a person to hand-author a map for every celestial body, nor to manually specify every resource deposit or settlement location. As with StarSim's system generation, the game should be able to generate a plausible starting world from the information and constraints available for that body.

The intended output is more than a colored terrain grid. It should establish an initial geographic/world dataset that can include terrain and elevation, relevant geological and hydrological characteristics, natural features, resource-deposit candidates, and candidate locations that may be useful for settlements or other operations. These outputs become part of the body's initial world state and are then available to the Geosphere, TerraSim, AI Manager, and other systems according to their responsibilities. Map Studio creates/prepares the initial state; it does not perform ongoing environmental evolution or decide to terraform the world.

#### Generation approaches to support

These are complementary approaches, not mutually exclusive competing designs. Which approach is appropriate depends on the target world and the quality of available information:

1. **Reconstruction from real planetary data.** For known worlds, use available elevation, geology, imagery, and other observational or derived datasets to reconstruct a plausible initial geography. Preserve source provenance, resolution, coverage, assumptions, and uncertainty. For Earth, Mars, Luna, Venus, and other bodies with usable data, this should prefer relevant evidence over generic procedural assumptions.
2. **Procedural generation from planetary characteristics.** For extrasolar, fictional, or poorly characterized worlds, generate plausible geography from the body's physical properties and available environmental constraints. This should be a normal game capability, not require a hand-authored map for every world. The relationship to StarSim is conceptual: StarSim generates systems and bodies; Map Studio generates their initial surface/geographic state.
3. **Learning from human-designed maps and examples.** Civ4, FreeCiv, Arda, and other human-created maps can provide examples of possible landform arrangements, terrain transitions, coastlines, hydrospheric features, and designed or terraformed landscapes. In particular, developed FreeCiv/Civ4 geography should be treated as designed or effectively terraformed examples, not as untouched natural-world observations. These maps are training/reference material for GalaxyGame to learn geographic patterns and develop its own generation capability—not authoritative planetary data, fixed templates to import into live worlds, or proof that a pattern is geologically valid. Their gameplay resource placements are not geological truth.

4. **Hybrid generation and reconstruction.** Combine observational data, geological/physical constraints, procedural methods, and learned patterns where appropriate. A known world may use measured elevation as a strong constraint while learning or procedural methods help fill gaps; a fictional world may rely more heavily on procedural generation and learned examples. The selected method and its inputs should remain inspectable.

#### Learning from designed geography toward natural planetary conditions

A specific design goal is for GalaxyGame to learn from developed/terraformed map examples and **regress or transform their geographic patterns toward plausible natural planetary conditions**. This does not mean simply deleting green terrain, reversing terraforming by a fixed rule, or copying a source map with minor edits. The system should learn reusable geographic relationships from many examples, then condition its own generated/reconstructed result on the target body's physical characteristics, environmental state, and available planetary evidence.

Planetary examples provide different reference conditions rather than one Earth-like template:

- **Earth** provides observed coastlines, continental arrangements, hydrology, and extensive geographic data that can inform reconstruction and calibration.
- **Mars** provides both its present natural state and evidence for an ancient, wetter world. An ancient-wetter-Mars scenario is a useful example of how developed/terraformed geography might be interpreted or transformed toward a plausible earlier natural condition; it must remain a scenario grounded in evidence, not a claim that a game map is an accurate reconstruction.
- **Venus** provides a different terrestrial-planet archetype and helps prevent the generator from treating Earth's current geography or hydrology as universal.
- **Titan** provides an example of a world with recognizable Earth-like hydrospheric landforms and processes in a very different planetary and material context. Its geography must be conditioned on Titan's actual environment rather than copied from Earth.

The intended learning material is broader than source maps alone: planetary observations and derived datasets, multiple designed maps, generation examples, and outcomes from relevant TerraSim simulations can all inform training, evaluation, and refinement of GalaxyGame's own system. The aim is to learn how plausible geography relates to planetary conditions—not to build a library of maps that are copied into generated worlds.

This is a design objective, not a description of a currently verified regression model or end-to-end training pipeline. The inspected Map Studio experiments include probabilistic source-map blending and separate pattern-extraction/learning-data experiments, but they do not establish that this intended transformation or learning loop is implemented.

Historical examples identified in repository references include the Civ4 Mars WorldBuilder map `MARS1.22b.Civ4WorldBuilderSave` (80×57), the FreeCiv `mars-terraformed-133x64-v2.0.sav` map (133×64), and the early GalaxyGame-native `earth_20260128_221726.json` artifact using a `terrain_grid` representation. These demonstrate different source/output formats and are useful historical references, not a final map schema or a claim that those source files are present in every checkout. The early JSON artifact is not the final Geosphere terrain contract.

The system should not assume there is one universally correct map. It may need to produce and compare multiple plausible alternatives when the available evidence or future scenario permits more than one reasonable result. Keep distinct: an observed or evidence-based natural baseline; a reconstructed or hypothesized past state; a proposed human-designed/terraformed state; and a state subsequently projected or evolved by TerraSim. Do not silently turn a designed map into a scientifically established natural baseline.

#### Geological resources and natural-feature identification

Map generation should be connected to identification of meaningful geological features and resource opportunities. Resource placement should not be limited to randomly assigning game-resource markers to terrain categories, nor should Civ4/FreeCiv bonus-resource locations be treated as geological truth.

The desired capability is to infer or identify plausible deposits and useful natural features from the generated/reconstructed world data and its geological context. The exact resource types, evidence sources, confidence model, spatial resolution, and degree of geological detail remain OPEN and must be established from the intended simulation scope. A game-level resource representation may be needed, but it should retain a distinction between a real/inferred geological deposit and a gameplay abstraction or strategic opportunity.

Natural features matter in their own right, not only as visual terrain. Examples relevant to settlement planning include lava tubes and skylights, caves or other subsurface voids, impact structures, volcanic features, sheltered terrain, and accessible deposits of water ice or other useful volatiles. Which features can be detected or generated depends on the available data and model capability; do not imply that every feature can be reliably identified from a coarse global map.

#### Candidate settlement locations

The game should identify and evaluate candidate locations for settlements rather than requiring players or developers to manually place every initial settlement opportunity. A candidate may be valuable because of a natural feature that provides shelter or reduces construction requirements, because of nearby resources, or because its terrain and access make operations practical.

For example, the Mars settlement planning already uses a lava tube near the Marius Hills Skylight as a preferred natural shelter. The map/world-generation capability should be able to represent or identify such a feature and expose it as a candidate. It should not simply label an arbitrary lowland or resource-rich grid cell as an equivalent settlement site.

Candidate evaluation may consider, as appropriate to the body and mission:
- natural shelter and other useful geological features;
- access to water ice, volatiles, minerals, and other required resources;
- terrain, slope, elevation, hazards, and construction/access constraints;
- power and energy opportunities;
- local environmental conditions and exposure;
- proximity and logistics relationships to other useful locations.

The generated result should preserve candidate locations, the reasons they were selected, the supporting data, and uncertainty/confidence. Candidate identification is not the same as creating a settlement or committing to a site. The AI Manager should be able to consider candidates against its strategic objectives, mission requirements, available assets, logistics, and economics; TerraSim and other relevant simulation capabilities can help assess environmental and operational viability. The exact service boundary and degree of automation remain OPEN, but Map Studio must not silently become the settlement-construction manager.

The Mars lava-tube example is a useful validation case: can the game represent or identify the Marius Hills Skylight/lava-tube area as a natural shelter opportunity, explain why it is useful, and make it available to settlement planning? The same capability should generalize to other natural features and worlds rather than hard-code the Mars example.

#### Desired outputs and quality expectations

The intended initial-world output should be capable of carrying, as supported by the model:
- the initial terrain/elevation and related geographic layers;
- geological context and natural-feature records;
- inferred or known resource-deposit locations and attributes;
- ranked or categorized candidate settlement/operations sites with supporting rationale;
- source data, generation method, assumptions, provenance, and uncertainty;
- quality/coverage information and any unresolved gaps.

This is a capability direction, not a declaration that the current Geosphere schema already supports all these records. The existing model and data contracts must be inspected before deciding where each output belongs.

**OPEN design questions:** how much of the process is deterministic versus stochastic; when to generate one result versus multiple alternatives; how learned examples influence procedural generation without overriding physical constraints; which natural features can be detected at global versus local/site resolution; how geological resource inference is represented; how candidate sites are scored and validated; and which service owns each calculation. Resolve these questions by evaluating existing experiments and model capabilities before selecting an architecture.

**Important boundaries and unresolved quality questions**

- Map Studio's Admin responsibility is initial terrain/geographic preparation. StarSim's primary star-system generation, TerraSim's environmental evolution, and Digital Twin's projection/evaluation remain separate capabilities.
- **Player surface settlement view (DIRECTION; early name "TerrainForge"):** A SimCity-style 2.5D isometric / orthographic surface grid for local settlement construction — structure placement, power/utility links, ISRU units, pads, and local stockpiles. Resources and products on this grid feed depots, skimmers, and surface-to-orbit logistics. Distinct from Admin **Map Studio**, which prepares planetary geography, terrain, and resource/settlement *candidates*. Map Studio builds the underlying world data; the settlement view is the player-facing construction layer on top of it. Detailed UX, tile architecture, and implementation path remain OPEN.
- The legacy generator class is namespaced under `AIManager`, and the automatic terrain wrapper is namespaced under `StarSim`. Do not infer final service ownership or strategic decision authority from these historical class namespaces alone.
- The older frozen `MAP_SYSTEM.md` and terrain architecture documents contain detailed grid sizes, service inventories, and layer behavior that are not all confirmed by this source pass. In particular, the current automatic generator's diameter-based grid calculation applies minimum and maximum bounds; do not copy older per-body grid-size tables as current guarantees.
- The current Map Studio controller and generator are substantial existing work, but their output quality, source-data provenance, terrain/elevation semantics, and consistency with the owner-confirmed Map Studio intent still require review. No claim is made here that the full NASA/AI learning pipeline is complete.

### StarSim Generator

StarSim is responsible for procedural generation of stars and planetary systems. Its scope may also include generating/populating additional celestial objects in space that are not part of the major system-generation pass, such as asteroids, comets, Kuiper Belt objects, Oort Cloud objects, and other small bodies. Keep the distinction between initial system generation and any additional population process visible.

Admin capabilities should include appropriate generator configuration and controls, generation runs, parameter inspection, generated-system review, and management of generated or prepared systems. The UI must invoke authoritative backend behavior rather than duplicate generator logic.

### TerraSim

TerraSim is the general-purpose planetary/environmental simulation engine. It models a world's existing natural state and evolution, environmental events and disturbances, and the consequences of intentional environmental modification. **Terraforming is one application of TerraSim, not its defining purpose.**

The foundational design intent, including historical calibration against Earth, Mars, and Venus; generalization to procedural and poorly characterized worlds; uncertainty handling; and the distinction between sphere data and cross-sphere processes, is recorded in [TerraSim — Environmental Simulation, Calibration & Evolution](../technical/terrasim.md) and [Celestial-Body Sphere Models & Environmental Interactions](../technical/sphere_models_and_interactions.md).

The sphere models organize detailed physical and environmental data for different kinds of celestial bodies. TerraSim models the processes and interactions among those systems. The architecture should remain extensible; body-specific processes and interactions can be added when their use cases are prioritized. Broader ice-moon modeling is a future consideration, not a reason to expand current implementation scope prematurely.

TerraSim calculates environmental results and consequences; it does not choose terraforming objectives or autonomously operate terraforming programs. AI Manager owns autonomous operational decisions. Digital Twin provides an Admin/developer workspace for inspecting, comparing, evaluating, and tuning simulations.

Admin controls should expose supported model configuration, parameter/preset tuning, run state, inspection, and operational options. The exact screen breakdown and supported editable parameters remain OPEN.

### AI Manager

AI Manager is the autonomous terraforming operator. It uses environmental information and projections from TerraSim, pursues the approved long-term terraforming plan and objectives, and adapts its actions based on observed results. It should be capable of autonomous execution within its authority rather than requiring constant Admin direction. Admins may adjust long-term objectives, plans, and appropriate constraints; Players do not directly control terraforming. AI Manager is not the environmental calculation engine—that is TerraSim.

### Digital Twin

**OWNER-CONFIRMED DESIGN DIRECTION — 2026-11-21; detailed workflow and controls OPEN**

Digital Twin creates an isolated duplicate of an existing celestial body's world state and supports accelerated what-if experiments against that copy. The experiment must not alter the original/live world. A scenario may introduce or remove atmospheric gases, change other planetary conditions, or apply other specified interventions. TerraSim runs the environmental simulation on the duplicated state and calculates the resulting projected state over the selected simulation interval.

The Digital Twin is therefore both a working copy of an existing world and an environment for scenario-based projection. It is not a second environmental simulation engine: **TerraSim supplies the simulation code and calculates the environmental response; Digital Twin supplies the isolated scenario state and projection capabilities.** The original body remains the baseline against which scenario inputs and projected outcomes can be compared. Admin and AI Manager use these shared capabilities through different workflows and interfaces.

#### Relationship to the Player Planetary view

The Digital Twin workspace should look and feel related to the Player Planetary view, reusing its planetary visualization, layer presentation, and general visual language where appropriate. It is not simply the Player view with an Admin label. It should add more SimEarth-inspired scenario controls for setting up and adjusting what-if experiments, selecting the intervention inputs and simulation interval, running accelerated projections, and inspecting or comparing resulting states. The exact controls, panel arrangement, and degree of interactive manipulation have not been designed or approved yet.

These controls specify scenario inputs and parameters; they do not provide arbitrary “god mode” or directly dictate the environmental outcome. TerraSim calculates the consequences within the modeled physical processes and constraints.

#### Different workflows for Admin and AI Manager

The two audiences must not be designed as though they use the same Digital Twin screen with different permissions. They use the same underlying scenario, projection, and result capabilities, but interact with them in fundamentally different ways.

**Admin — visual, exploratory workflow**

Admin works directly with the planetary presentation. The experience should be visual and interactive, building on the Player Planetary view's appearance and visualization layers, but adding the controls needed for scenario experimentation. Admin should be able to inspect the world, choose and adjust scenario interventions, set projection parameters, run accelerated what-if experiments, observe changes, and compare projected outcomes. This is the SimEarth-inspired laboratory experience. Its detailed controls and layout remain OPEN.

**AI Manager — structured, programmatic workflow**

AI Manager should not need to operate the visual Admin interface or imitate a human clicking through its controls. It should interact with Digital Twin through a structured, callable scenario/projection interface, conceptually closer to defining and running an RSpec test or Rake task. It supplies a baseline world and explicit scenario inputs, parameters, constraints, and requested outputs; invokes a projection; then receives structured results it can evaluate and compare.

For example, an AI Manager evaluation could define several candidate atmospheric-import strategies as separate scenarios, request projections for each, and compare their environmental outcomes, resource requirements, estimated costs, execution times, and uncertainties. It should be able to run these evaluations repeatably and inspect machine-readable results as part of its planning and decision process. This is an architectural analogy for the interaction style, not a decision that the implementation must literally use RSpec, Rake, or a particular file format.

The shared scenario/projection contract should support both workflows. Admin's visual controls should ultimately invoke the same underlying capabilities that AI Manager calls programmatically; the two paths should not grow separate simulation logic. Exact API/service boundaries, scenario schema, result format, orchestration, and validation approach remain OPEN.

#### Projection, cost, and time estimates

Digital Twin projections should eventually help Admins and AI Manager compare not only environmental outcomes but also the practical implications of carrying out different interventions or plans. For a proposed intervention or combined strategy, the system should aim to provide:

- **Environmental projections:** how the duplicated world and relevant planetary systems are expected to change over the selected simulated interval.
- **Implementation cost estimates:** the estimated resources, materials, manufacturing, transport, infrastructure, and other applicable economic costs required to carry out the proposed work, to the extent supported by the game's economic and logistics systems.
- **Implementation time estimates:** estimated time to acquire or produce required inputs, transport them, deploy/build the intervention, and complete the relevant operational work, as supported by production, logistics, and construction systems.
- **Environmental response timeline:** how quickly the modeled planetary conditions respond and what intermediate and ending states are projected.

Keep the time required to execute an intervention distinct from the accelerated simulation interval and the time over which its environmental effects develop. Likewise, TerraSim's environmental calculations should not be treated as the source of economic prices or delivery schedules: cost and execution-time estimates will need to draw on the appropriate economic, manufacturing, construction, and logistics capabilities. The exact breakdown, confidence/uncertainty presentation, and integration points remain OPEN.

Where practical, estimates should be inspectable at the level of individual interventions or work packages as well as rolled up for a combined plan. This lets Admin and AI Manager compare which parts drive cost or schedule, evaluate alternatives, and see how individual changes affect the overall estimate.

These estimates should be useful to both Admin and AI Manager. Admins need them to inspect and compare proposed scenarios; AI Manager should be able to use them alongside projected environmental outcomes when evaluating strategies, priorities, and operational plans. This is a desired capability, not a claim that the complete cost/time projection workflow currently exists.

#### Responsibilities and boundaries

Digital Twin should support scenario projections and comparisons, examination of consequences over time, evaluation of AI Manager strategies/plans, and validation/tuning of TerraSim configuration and AI Manager capabilities. Where supported, Admins may adjust TerraSim model parameters and presets through an appropriate configuration interface.

- **Map Studio** prepares or generates initial geography and world data; it does not create or run the what-if experiment.
- **Digital Twin** duplicates an existing world state, holds isolated scenario changes, and presents projections and comparisons.
- **TerraSim** calculates environmental responses and projected states from the scenario state and inputs.
- **Economic, manufacturing, construction, and logistics systems** provide the basis for implementation cost and execution-time estimates.
- **AI Manager** evaluates options and plans using environmental outcomes together with cost, time, resources, and operational constraints.

Interventions and projections remain bounded by physical constraints, simulation rules, available resources, authorization, and consequences. The Digital Twin is not a world-generation system, the environmental calculation engine, or the autonomous terraforming actor.

#### Current implementation status — source-verified partial audit (2026-11-21)

The legacy Rails 7 code contains scaffolding, but the inspected Digital Twin path is not an operational TerraSim-backed what-if system:

- Admin::DigitalTwinsController has placeholder behavior: the index supplies an empty list; the show path can return hard-coded mock planetary data; creation makes a shallow isolated attribute copy; and the simulation tick currently returns the existing data rather than advancing a TerraSim projection.
- The controller includes intervention names and some methods that directly alter mock/cache values. These are not evidence of physics-based simulation; many intervention methods are empty stubs.
- app/services/digital_twin_service.rb contains placeholder methods that raise NotImplementedError, including cloning and running an accelerated simulation.
- lib/services/digital_twin_service.rb is also a stub whose core methods raise NotImplementedError.
- The inspected Digital Twin spec is marked as a placeholder. The old service comments describe a proposed 100:1 accelerated-time ratio and transient Redis storage, but those comments do not establish implemented behavior.

Accordingly, do not describe the current code as already cloning complete sphere state, integrating interventions with TerraSim, running accelerated projections, comparing scenarios, or calculating cost/time estimates. The implementation needs a focused audit and design before those capabilities can be claimed.

**Open design questions:** what constitutes a complete world snapshot and how it is isolated/versioned; how scenarios are branched and compared; which interventions and input units are supported; how accelerated simulation time is selected and related to game time; which environmental outputs and intermediate checkpoints are exposed; how cost and execution-time estimates are assembled from existing services; how uncertainty is communicated; and which controls belong in the Digital Twin workspace versus TerraSim configuration or AI Manager. Keep these open until the relevant existing models, services, and UI are reviewed.

### Spawning and resource generation — ownership OPEN

StarSim may also be involved in generating/populating additional celestial objects beyond the primary star-system generation pass. Whether there should be a separate Spawning System, or whether some of these responsibilities belong within StarSim, remains OPEN. Do not assume a finalized division of ownership.

Resource generation ownership is also OPEN. StarSim may generate initial resource locations/distributions as part of world generation—for example, geological deposits on planets and moons, lunar permanently shadowed region (PSR) ice, and resources associated with asteroids or other small bodies—but this requires further architectural planning. Existing design material has described AI Manager-triggered deposit placement when a region is surveyed. That prior direction must be reconciled rather than silently treated as final ownership.

Keep these responsibilities distinct when evaluating the architecture:
- generation of initial resource distributions or plausible deposit locations;
- survey-triggered discovery/placement of deposits not already represented as confirmed data;
- resource quantities, accessibility, and geological/environmental plausibility;
- extraction, depletion, replenishment, and economic use after generation.

Which system owns each responsibility—and how StarSim, TerraSim, AI Manager, and any separate spawning/resource service coordinate—remains OPEN. Do not convert the examples above into approved mechanics or implementation commitments.

### Solar System Management and prepared systems

Administrators need a way to export/unload a solar system to a JSON file and import/load a prepared or pre-tuned system. This is also part of the intended runtime lifecycle for reducing simulation/database load: a system that no longer has an active player presence and is no longer connected through the artificial wormhole network or a live natural wormhole does not need to remain loaded and continuously processed.

**System unload/reload lifecycle — OWNER-CONFIRMED DESIGN INTENT (2026-10-31; clarified 2026-11-20)**

- A system remains active while it has an active player presence or an active connection through the wormhole network, including a live natural wormhole. A natural connection maintained by stabilization satellites therefore keeps the system accessible and available for harvesting; it is not eligible for routine unloading merely because it has not been permanently integrated through AWS.
- When the system has no active player presence and no active natural or artificial wormhole connection—for example, an explored but unsettled system after its natural exit has been shifted away—the system can be exported to JSON and unloaded from the active database/simulation.
- Export the system's current state and all relevant information that can practically be retained, so unloading does not discard the system's accumulated history/state.
- If the system is later reconnected or selected for settlement, reload it from its saved JSON into the database and resume active simulation. Reconnection must use the current wormhole/network topology; the archived system record does not itself create an active route.
- The export/unload capability is intended to reduce ongoing processing and persistence load. It is an Admin/dashboard operational capability and is not yet fully implemented.

This requires clear workflows for:
- exporting an existing active system's current state before unloading it;
- importing/reloading an archived system and validating its reconstructed state;
- maintaining a library/catalog of prepared systems and archived live-system exports, without confusing those two purposes;
- selecting procedural generation versus a prepared/archived system for system creation or reactivation;
- previewing and validating a system before it enters or re-enters the active simulation.

The runtime archive/reactivation lifecycle and the separate choice of prepared input versus procedural generation for a newly created system are related but distinct administrative operations.

### Blueprint Management

Blueprints define what game objects are and how they are built. Units and assets belong here as blueprint-defined objects, not as a separate top-level content category solely because they are mobile or operational.

Admin capabilities may include browsing, inspecting, validating, comparing, importing/exporting, and managing versions/dependencies for spacecraft, rovers, vehicles, structures, habitats, stations, equipment, machinery, components, and other blueprint-defined objects. The UI should expose the actual blueprint format and dependency rules found in the game repository.

### Material Management

Material definitions are distinct from blueprints. Admin capabilities should support inspection and controlled editing of material JSON definitions, classifications, physical/chemical properties, resource characteristics, and relevant relationships to processing, refining, manufacturing, and blueprints. Validation should identify malformed, missing, duplicated, or inconsistent definitions.

### Configuration and Operational Data Management

JSON is a storage format, not a reason to require manual file editing. Administrators need UI access to tune operational data files that configure how game systems behave.

Examples include StarSim parameters, TerraSim settings, spawning distributions and composition rules, resource/processing configuration, economy and balance settings, and other system-specific operational options. Some data needs a purpose-built editor; other data may use a structured JSON editor with schema-aware validation, diff/preview, and safe apply/rollback behavior.

Do not collapse all JSON into one generic editor. Distinguish:
- blueprint definitions;
- material definitions;
- operational configuration;
- generated/prepared world data;
- live world state and player data.

### Template and Version Management

The project already has some template-version-control files and mechanisms. The Admin UI must make the existing capability accessible rather than inventing a parallel versioning system.

Potential UI capabilities include template catalog and version history, current/deprecated/supported version status, schema/compatibility inspection, validation of files against template versions, version comparisons, migration readiness and results, and links to affected blueprints/data files. First audit the existing files and behavior; do not assume every capability is implemented.

### User and Account Management

The Admin Dashboard must include ordinary web-application account administration:
- search and inspect player accounts;
- view account status and relevant account details;
- initiate password-reset workflows or reset links (never display or retrieve passwords);
- enable, disable, suspend, or restore accounts where authorized;
- review last login and relevant activity;
- manage roles and permissions;
- inspect account-related reports/issues and administrative history.

Sensitive account data must be minimized and access-controlled. All actions require backend authorization, validation, and auditability.

### Other application administration

Additional areas to consider include resource/content catalogs, economy configuration, world-state inspection, background jobs, application/service health, data integrity and validation, logs/audit history, backup/recovery, and administrative roles/permissions. Their exact scope and screens remain open.

## 3. AI Manager workspace

**ESTABLISHED SCOPE DIRECTION — 2026-11-13; screen breakdown OPEN**

AI Manager is not limited to mission selection and asset deployment. It is the autonomous operations, logistics, network-expansion, and strategic resource-management system supervised through the Admin Dashboard.



### Shared AI Manager, different sources of direction

**OWNER-CONFIRMED DESIGN INTENT — 2026-11-23; player interface is future scope**

There is one AI Manager system, not separate NPC and player automation implementations. The AI Manager completely manages NPC operations under game-level objectives and NPC operating policies. Players will use the same underlying AI Manager capabilities to direct and automate operations for their own assets. The difference is who supplies the direction, which assets are in scope, and what authority the AI Manager has been given—not a different task engine or a second AI.

- **NPCs:** the AI Manager receives the governing objectives and policies for NPC-controlled assets and autonomously plans, assigns, coordinates, and executes their work.
- **Player-owned assets:** the player supplies objectives, standing policies, priorities, and individual instructions. The same AI Manager capabilities turn those inputs into tasks and plans and manage authorized execution for the player's assets.
- **Admin:** the Admin workspace supervises NPC-controlled operations and provides appropriate configuration/oversight of NPC bases and game-level systems. It is not the player-facing asset-management interface and does not manage player-owned bases; Admins should not need to manually create every NPC task.

Keep the inputs distinct: an **objective** describes the outcome to pursue; a **standing policy** defines persistent rules and limits for repeated decisions; an **individual instruction** requests a particular action; and a **condition or trigger** (for example, a shortage or maintenance need) may cause the AI Manager to generate work under the applicable objectives and policies. Tasks, plans, decisions, and executions are shared concepts across NPC and player operations. Their records should preserve the source/provenance of the work and the applicable asset scope and authority, so operators can tell why a task exists, whose direction governs it, and what the AI Manager was authorized to do.

The future Player AI Manager should therefore be a player-scoped control surface over shared capabilities, limited to the player's assets and the automation/decisions the player may delegate. It is not a separate AI implementation and should not expose Admin-only or game-level authority. The current prototype remains focused on the Admin AI Manager workspace; this shared-system model is an architectural constraint, not authorization to implement the Player interface now.

### Mission, task, and profile authoring

**ESTABLISHED INTENT — OWNER-CONFIRMED 2026-11-23**

Admin maintains the shared Task Library and predefined Mission Template Library. Admin can author, edit, validate, test, and maintain reusable task definitions and mission templates/profiles. Players do not edit shared task definitions or administer the shared template catalog; they create their own reusable mission profiles by loading available templates, naming a new profile, copying selected template material, and selecting references to existing task files.

Mission profiles describe repeatable operational objectives and guidance. The AI Manager selects, sequences, combines, and adapts the referenced tasks to actual conditions and delegated authority. A profile is not a rigid task checklist or a deployed execution. Keep reusable task definitions, mission templates, Player-owned profiles, and configured mission runs distinct.

The authoring UI should use a custom JavaScript JSON editor integrated with the existing Rails/Stimulus interface. Provide structured editing for common fields and task relationships as well as direct raw JSON editing, with both modes synchronized against the same document. Validate syntax, schema, task references, compatibility, dependencies, and target/location requirements where authoritative contracts exist. Preserve existing JSON formats and versioning; do not introduce a parallel data model or duplicate task definitions.

Player profile creation is template-first: load the available template catalog, let the Player choose a new profile name and starting template material, copy that material into an independently editable Player profile, then allow adaptation and task selection from the existing shared Task Library. The original templates and task definitions remain unchanged.

For surface missions, select the celestial body first, then a known/characterized surface site. If the target is unknown or insufficiently characterized, the profile/run must support a prerequisite survey mission. Survey results can establish persistent discoveries for follow-on operations; a survey characterizes a deposit but does not create its material, and subsequent extraction must debit authoritative geological inventory. Other mission environments require target selectors appropriate to orbital, station, route, settlement, or system operations.

See [Mission Profiles, Templates, Tasks, and Execution](07_mission_profiles_tasks_and_execution.md) for the full authoring, target-selection, survey dependency, and API design.

### Mission and operations management

Task and work-order presentation should make task provenance inspectable. Depending on the scenario, work may originate from an objective, a standing policy, an individual instruction, a detected condition/trigger (such as a shortage or maintenance need), or a higher-level AI Manager decision. Preserve the distinction between the source of direction, the asset scope, and the authority under which the task is planned and executed. Do not imply that every task was manually entered by an Admin.

- mission objectives, selection, planning, constraints, and priorities;
- asset, craft, fleet, rover, settlement, and infrastructure deployment;
- logistics, resupply, construction, and execution progress;
- blockers, failures, recovery, and outcomes;
- decision records, rationale/evidence, operator review, and training/validation evidence.

The UI should expose actual decision and execution records. It must not fabricate AI reasoning or imply that mock controls are connected to live services.

**Craft operations — established intent (2026-11-19):** Craft are autonomous assets, not pilot/character avatars. Players may issue remote commands or assign objectives when communications permit; onboard automation and the AI Manager continue authorized operations when the player is unavailable or out of communication range. Admin/AI Manager screens supervise deployments, assignments, decisions, and execution rather than presenting direct piloting controls. Craft are identified by ship/craft names. They may operate independently or be grouped for a specific task/operation; do not assume every craft belongs to a permanent fleet. Keep requested objectives, current craft state, and confirmed execution outcomes distinct.


### Mission status, activity stream, and completed-run inspection

**OWNER-CONFIRMED UI DESIGN INTENT — 2026-11-23; data/event integration not yet implemented**

The AI Manager workspace should let an operator quickly understand the current state of missions and inspect what happened during a mission. This is an operational workbench, not merely a mission launcher or a collection of static status cards.

**Mission status** should provide a concise overview of active, pending, completed, blocked, and failed missions, with useful progress and current-state information. Opening a mission should show its objectives, associated tasks, dependencies, task states, blockers, and relevant outcomes. Status answers **where the mission stands now**.

**Chronological scrolling activity log** is an intentional part of the AI Manager presentation. The existing terminal-style view is a static visual example of this intended presentation, not a working live log. In the completed design, the log is populated from actual execution/activity records. It scrolls as significant events occur and new entries are appended in chronological order—especially when tasks complete—rather than printing fabricated progress or continuously generating placeholder output.

Entries should identify the time, event type/source, mission or task context, and concise result. Relevant events include task start/completion/failure/deferment, AI Manager decisions where recorded, construction and commissioning, production and extraction, shipment/transfer/arrival, inventory and volatile-storage changes, GCC generation/consumption/transfers, maintenance outcomes, and significant warnings or blockers. Independent tasks may report as they complete, so concurrent work appears in the order events actually occur. The log explains **what happened**; it complements rather than replaces current mission/task status.

**Completed mission and test-run inspection** must remain available after execution ends. An operator should be able to open a completed mission/run and review its chronological activity history, task outcomes, created structures/assets, final inventories and stockpiles, volatile quantities and storage, material/resource flows, GCC flows, production/consumption, logistics, costs and financial results, and relevant failures or deviations. Where supported by recorded data, inspection should include intermediate checkpoints and changes over the run, not only a final success flag or final snapshot.

The same underlying execution/activity records should support both:
- normal AI Manager operation, where the log reflects events as they happen and mission status reflects current state; and
- development/test runs, including accelerated time, deliberate time jumps, direct service/task invocation, or other test orchestration used to reach and validate an end-to-end mission outcome.

Development/test orchestration is allowed to bypass normal scheduling when that is the purpose of the test. It must exercise the real domain capabilities and preserve enough execution evidence and resulting state for inspection. It is not a second production scheduler, and test-only shortcuts must not be mistaken for missing normal game-loop behavior. Conversely, the existence of a test runner does not prove that normal gameplay dispatch and feedback are connected.

Keep mission status, chronological activity history, and final/intermediate world-state inspection as related but distinct views. Do not treat the existing static terminal mockup as proof that event capture, persistence, live updates, or historical run inspection is implemented. Those integrations remain future work and must use authoritative task, mission, inventory, storage, asset, and economic data rather than invented UI values.

### Wormhole network management

AI Manager monitors and coordinates the evolving natural-wormhole and AWS network:
- discovered/open natural connections and their current state;
- relative stability, mass throughput, remaining mass capacity, and risk;
- EM ejection, captured EM, EM returned for stabilization, and available reserves;
- AWS pair construction, commissioning, operation, and network connectivity;
- candidate routes, system access, logistics constraints, and network changes.

The wormhole simulation remains authoritative for physical state and behavior. AI Manager observes that state and decides what operations to request.

### Expansion, exploration, and Hammer Protocol

Hammer Protocol is a strategic system-scouting, harvesting, and expansion workflow—not merely an instruction to snap every natural wormhole.

Sol is the current human-expansion staging/scouting system. When a natural wormhole opens to an otherwise unknown system, the system can be surveyed. A system discovered through this route has a harvestable EM field and can be assessed for other resources, celestial bodies, and settlement potential. This does **not** imply that unvisited systems in the local bubble have known or harvestable EM fields; those systems remain unknown until discovered and surveyed.

After survey, AI Manager may:
- harvest EM and other available resources while the natural connection remains open;
- continue using the natural connection without immediately building an AWS pair;
- decide whether the system merits a permanent/continuing AWS connection;
- identify it as a settlement candidate and plan the infrastructure and logistics needed;
- or complete the harvesting opportunity and use the Hammer Protocol to force the natural exit to shift, then begin scouting another system.

Discovery does not automatically require an AWS pair or settlement. AWS construction is a strategic investment decision based on system value, settlement plans, resource availability, EM/stabilization capacity, transport cost, and network priorities.

For a planned settlement, the likely approach is to build an AWS pair while the natural wormhole is still open, connecting the new system to Sol and providing a dependable logistics corridor. Settlement equipment, people, construction materials, and supplies can then be moved through a stabilized natural connection or an artificial connection. The connection can be reconsidered or moved later as the network develops. Exact sequencing and connection mechanics remain subject to the authoritative wormhole/AWS design.

### EM economy and resource strategy

AI Manager must distinguish:
- **natural EM ejection/production:** EM released locally by natural wormhole behavior;
- **harvesting/capture:** EM actually collected by available equipment;
- **stored reserves:** captured EM available for use;
- **stabilization return:** captured EM directed back into a wormhole;
- **consumption:** EM spent by stabilization, AWS, portals, and other systems.

It must monitor production/ejection trends, harvesting capacity, captured quantities, returned quantities, reserves, throughput, and projected expenditure. It uses this information to decide how much exploration, stabilization, network construction, settlement, and expansion can be supported.

The objective is not simply to occupy the greatest number of systems. AI Manager should balance long-term expansion capability, system value, harvesting opportunities, infrastructure investment, logistics, and the risk of losing a natural connection.

### Strategic choices

For a discovered system, AI Manager may choose to:
- exploit/harvest while the natural connection remains available;
- invest in stabilization and preserve the natural connection;
- build an AWS pair and incorporate the system into the network;
- establish a settlement and maintain a supply corridor;
- or complete the harvest and trigger a shift to move on.

These are strategic alternatives, not automatic stages every system must pass through.

### Natural wormhole preservation, network expansion, and decision oversight

**OWNER-CONFIRMED STRATEGIC DESIGN DIRECTION — 2026-11-20; detailed mechanics OPEN**

AI Manager must treat natural wormhole management as an ongoing strategic and economic decision, not a fixed sequence in which every discovery is either immediately converted to AWS or discarded. Sometimes the best first action is to stabilize both apertures and assess the opportunity before committing to permanent infrastructure.

- A natural wormhole may connect an accessible system to a genuinely unknown system, to a previously scouted/archived system, or to another already-known system such as one in the local bubble. Discovering a connection does not necessarily mean discovering or generating a new system.
- Natural wormhole pairs are not inherently Sol-originating. For operational generation, at least one endpoint should be reachable by players or the AI Manager; a pair between two completely unknown, isolated systems has no immediate gameplay/simulation value without a route to reach it.
- A system with multiple active natural wormholes can have multiple distinct aperture locations for EM harvesting. The AI Manager must account for the EM and strategic value of each connection, not treat the system as having only one generic wormhole resource source.
- On discovering a potentially valuable connection, an initial response may be to deploy stabilization satellites at both apertures to preserve the route while players are inside and scouting. This is a protective measure, not a commitment to permanent infrastructure at both ends.
- Players scout both sides so the AI Manager can compare relative stability and counterbalance conditions. It may then select the more suitable side for a permanent WS station and AWS construction, connecting that system to the main artificial network while retaining the stabilized natural route for further scouting into the next system.
- A retained natural connection can continue to provide access and EM harvesting opportunities even after an AWS route to its system is operational. AWS integration does not automatically make the natural route redundant.
- Players may potentially harvest excess EM for market sale. The AI Manager must first account for EM needed for stabilization/return, operational reserves, and planned infrastructure; only genuine surplus should be treated as available for commercial harvesting.

AI Manager should weigh route access, future exploration, resource and scientific value, per-aperture EM production, stabilization effectiveness, market income, AWS investment and operating costs, logistics, and the risk of a shift or snap. Its available responses include stabilize-and-assess, retain and operate, integrate through AWS while retaining the natural route, harvest surplus, deliberately shift through Hammer Protocol, or remove stabilization and allow natural degradation. These are alternatives, not mandatory steps. Deliberate Hammer shifts, natural shifts, and uncontrolled snaps remain distinct outcomes.

When evidence is incomplete or conflicting, the AI Manager should be able to defer an irreversible decision, preserve the connection while gathering information, or request Admin guidance. An escalation should expose the observed state, evidence and uncertainty, available options, likely consequences/costs, and its provisional recommendation. Admin guidance and subsequent outcomes should become learning/training evidence. Confidence thresholds, escalation triggers, decision-record structure, and learning implementation remain OPEN; this records intended behavior, not a claim that it is implemented.

### Biological discovery and scientific network value

**OPEN STRATEGIC DIRECTION — 2026-11-15; existing biology models present in code**

System value should not be assessed only through extractable resources, industrial potential, logistics, or settlement capacity. A world may also be worth surveying, connecting, or keeping accessible because of its biological and scientific significance.

A survey may identify evidence of:
- present life, from microbial organisms through more complex ecosystems;
- past life, including possible fossil or other preserved evidence;
- unusual biological diversity, biochemistry, or adaptations;
- organisms or traits that could support further biological research and, where appropriate, genetic engineering.

A system with important biological discoveries may justify continued wormhole-network access even when its immediate economic or industrial return is limited. The AI Manager could weigh the scientific value, research opportunities, access costs, available resources, network capacity, and competing expansion needs when deciding whether to preserve or establish a connection. This is an option for strategic evaluation, not an automatic rule that every life-bearing world must be permanently connected or protected.

#### Existing implementation evidence and limits

The main Rails 7 application contains biological model support:
- `Biology::LifeForm` represents natural life forms and includes population, environmental adaptation, ecological, and biosphere-interaction behavior.
- `Biology::HybridLifeForm` represents engineered life forms and exposes `engineered_traits` and `creator_species`.
- `Biology::LifeFormParent` records parent/child relationships, and `Biology::LifeFormDeployment` tracks a life form's deployment on a world.
- The biosphere model associates life forms with a celestial body's biosphere.

These code structures establish that natural and engineered/hybrid life forms are represented in the application. They do not, by themselves, establish that all biological processes, genetic-engineering workflows, life-detection surveys, or AI Manager research decisions are fully implemented or validated.

The existing [Biosphere Simulation](../technical/biology/biosphere_simulation.md) page describes possible native-life interactions and rare useful-trait discovery, but explicitly marks detailed event behavior as unverified design proposals. [Planetary Protection and Environmental Governance](../infrastructure/planetary_protection_environmental_governance.md) describes biological protection classes and native-organism hybridization, but its governance and AI hooks are explicitly target design intent, not current runtime enforcement.

A focused review of the current code and active wiki pages did not establish a dedicated implementation for detecting or cataloguing past life/fossils, nor a complete survey-to-research-to-AI-network-retention workflow. Those remain OPEN and should be investigated before being described as implemented.

### Player strategic feedback on network policy

**OWNER-RECALLED DESIGN DIRECTION — 2026-11-20; interaction details OPEN**

Players should have a way to provide strategic feedback or express preferences that the AI Manager can consider when making wormhole-network expansion and retention decisions. This is indirect influence, not direct player control of the shared network and not an instruction that the AI Manager must obey.

Possible player-facing preference areas include:
- expansion pace and appetite for opening additional systems versus consolidating existing network access;
- how long to favor retaining natural wormhole connections for scouting, harvesting, and future opportunities;
- preferences about adjusting/reorganizing network routes versus preserving established connections;
- relative emphasis on exploration, settlement access, EM harvesting/market income, and reserving EM/resources for stabilization or infrastructure.

These should be expressed as policy preferences, feedback, or recommendations at an appropriate player/corporate level—not as guaranteed commands to snap, shift, stabilize, or build a particular route. The AI Manager remains responsible for evaluating the shared network, physical conditions, safety, available resources, operating costs, competing priorities, and the consequences for other players. It may accept, defer, modify, or decline feedback and should be able to explain the relevant constraints and rationale where supported.

The design must still determine who may submit feedback (individual player, corporation, colony, or another authorized group), whether preferences are global or scoped to a region/route, how conflicting player preferences are reconciled, how feedback is weighted against operational needs, and how the AI Manager communicates its response. These details remain OPEN; do not assume a voting system, binding referendum, or direct network-control permission.

Player feedback, the AI Manager's evaluation, its resulting decision, and observed outcomes may provide useful learning evidence. This complements Admin escalation: players can express preferences and observations, while Admins can provide higher-level guidance when the AI Manager encounters uncertainty or an exceptional situation.

### Learning and oversight

The Admin workspace should make objectives, candidate systems, resource forecasts, network assessments, selected strategies, decisions, alternatives where actually recorded, actions, outcomes, and training evidence inspectable. Operators need appropriate review and intervention controls, subject to actual authorization and service support.

## 4. Existing implementation and integration boundaries

The main application contains existing Planetary, Surface, Monitor, resource, infrastructure, and early AI Manager work. Preserve and assess useful behavior; repair broken paths; adapt incomplete work; reuse reference patterns where appropriate; build new capabilities where they do not exist. Do not assume everything must be ported unchanged, and do not assume the prototype should be a wholesale rewrite.

**Proposed integration direction, not yet implemented:** the main Rails 7 GalaxyGame application remains authoritative for game state, simulation, calculations, validation, persistence, and authorization. The separate Rails 8.1 UI prototype is the presentation/client layer and would consume deliberate game-oriented API contracts. The API boundary may change how data is loaded and presented; it does not justify duplicating game logic in the UI. Mock data may be used during design, but must be clearly labeled.

### Admin Celestial Body View

**ESTABLISHED INTENT — 2026-11-15**

The Admin Dashboard includes a **Celestial Body View** for inspecting a selected celestial body's terrain, geology, environmental spheres, and related data. The name is deliberate: the workspace must cover planets, moons, asteroids, and other supported celestial bodies. It is distinct from the Player's Planetary view, AI Manager, Map Studio, TerraSim, and Digital Twin.

The main Rails 7 application contains legacy implementation work that should be assessed and reused where valuable. Its current **Monitor** route/page is a small navigation/status hub; its **Planetary View** route/page is the richer map-and-sphere-data workspace. Those are legacy implementation names, not the intended product terminology. The future UI should call the workspace **Celestial Body View**.

As views are ported into the separate Rails 8 UI prototype, adapt the useful behavior and data to the intended Admin experience rather than copying legacy layouts, labels, or interactions unchanged. Preserve the main application's authority over game state, simulation, calculations, validation, persistence, and authorization. The exact panel layout, detailed layer inventory, and authorized administrative actions remain OPEN and must be settled through view design and owner review.

**Layout direction — two-pane workspace pattern (2026-11-17):** Admin Celestial Body View follows the shared Planetary workspace layout documented in [Player View Architecture](02_player_view_architecture.md): persistent global navigation on the far left, left pane with map canvas and visualization controls beneath it, right pane with full-height contextual data panel. Map controls belong underneath the canvas, not in the persistent navigation area.

See [Admin Celestial Body View](05_admin_celestial_body_view.md) for the separation of design intent, current Rails 7 route/page facts, porting direction, historical conflicts, and open questions.

## 5. Screen planning and task granularity

Each intended screen/page should receive its own small draft task when planning is ready. Each page task must state:
1. its Admin workspace and user purpose;
2. expected layout, information hierarchy, behavior, and interactions;
3. candidate source code in the main app, UI prototype, or reusable reference projects;
4. what is working, broken, incomplete, reusable, or new;
5. data/API dependencies and authority boundaries;
6. acceptance criteria, dependencies, and open decisions.

Shared components may have separate tasks where useful, but do not replace page-specific tasks with a broad “build Admin” task. Main GalaxyGame wiki design intent must be updated before tasks are drafted. Draft tasks remain non-actionable until independently reviewed and explicitly approved.

## 6. Open details

The exact dashboard navigation, grouping, page count, layouts, permission matrix, and implementation order remain OPEN. The detailed behavior of some StarSim, TerraSim, Spawning System, template-versioning, and account-administration operations must be audited against existing code before screens are specified. Do not silently convert this capability inventory into a finalized screen list.
