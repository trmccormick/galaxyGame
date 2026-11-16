> **Wiki section:** UI & Experience · **Status:** Established dashboard separation; individual workspaces and layouts remain DIRECTION / OPEN  
> **Last Updated:** 2026-11-14

# Admin Dashboard and AI Manager

This page records the responsibilities of the Admin Dashboard and its dedicated workspaces. It complements [Player View Architecture](02_player_view_architecture.md). Player and Admin dashboards are different products for different audiences; their screens, navigation, information density, permissions, and actions must not be conflated.

## 1. Player Dashboard versus Admin Dashboard

**ESTABLISHED INTENT — 2026-11-13**

- **Player Dashboard:** supports people and organizations participating in the shared universe. It provides three primary Player views—Planetary, Surface, and Settlement—plus the separate Space context.
- **Admin Dashboard:** supports administrators operating the web application and managing the simulation, world generation, data, configuration, users, and operational systems.

The Admin Dashboard is not a player dashboard with extra permissions. It has its own home/overview, navigation, workspaces, monitoring, and administrative workflows.

AI Manager is a major dedicated workspace within the Admin Dashboard. It has a distinct operational purpose and may have its own navigation and page layouts; it is not a Player view or a separate player-facing dashboard.

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

Map Studio is retained as an Admin capability. Exact Admin navigation, routes, and entry points are **not fully verified** in this wiki and remain part of the map/world-generation pipeline audit (see [Status and gaps](../status-and-gaps.md)).

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

Digital Twin is an Admin/developer workspace for projecting, inspecting, evaluating, and tuning the environmental simulation and terraforming systems. It uses TerraSim for environmental projections; it is not itself the environmental calculation engine and is not the autonomous terraforming actor. It should support scenario projections and comparisons, examination of consequences over time, evaluation of AI Manager strategies/plans, and validation/tuning of TerraSim configuration and AI Manager capabilities. Where supported, Admins may adjust TerraSim model parameters and presets through an appropriate TerraSim configuration interface.

Digital Twin is not Map Studio or a world-generation system. It must not provide arbitrary “god mode” control or permit unrestricted rewriting of environmental outcomes; projections and interventions remain bounded by physical constraints, simulation rules, available resources, authorization, and consequences.

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

Administrators need a way to export/unload a solar system to a JSON file and import/load a prepared or pre-tuned system. The spawning/creation path must be able to use the prepared system instead of invoking the StarSim procedural generator when that is the selected source.

This requires clear workflows for:
- exporting an existing system and its relevant data;
- importing and validating a prepared system;
- maintaining a library/catalog of prepared systems;
- selecting procedural generation versus a prepared system for system creation/spawning;
- previewing and validating the selected system before it enters the game.

The export/import workflow and the decision about which source the spawning path uses are related but distinct administrative operations.

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

### Mission and operations management

- mission objectives, selection, planning, constraints, and priorities;
- asset, craft, fleet, rover, settlement, and infrastructure deployment;
- logistics, resupply, construction, and execution progress;
- blockers, failures, recovery, and outcomes;
- decision records, rationale/evidence, operator review, and training/validation evidence.

The UI should expose actual decision and execution records. It must not fabricate AI reasoning or imply that mock controls are connected to live services.

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
