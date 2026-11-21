> **Status: DESIGN INTENT** — owner-confirmed gameplay direction; detailed mechanics and implementation remain in progress  
> **Last Updated:** 2026-11-21

# Space and Surface Operations

This page records the intended gameplay distinction between spacecraft-based operations in space and operations conducted on a celestial body's surface. It captures the current design direction, not a complete simulation specification. Some examples and activity types are established intent while detailed rules, capabilities, and execution mechanics remain open.

## Game identity and use of references

**ESTABLISHED INTENT — 2026-11-21**

GalaxyGame is its own game with its own goals, simulation model, mechanics, and player experience. It may draw useful ideas from many games, simulations, and applications, but it is not an attempt to recreate or combine EVE Online, SimEarth, Civilization, SimCity, or any other existing title.

References are evaluated at the level of the particular idea they demonstrate: a map interaction, information layout, planning workflow, visualization, or other useful pattern. A reference does not establish GalaxyGame gameplay rules, terminology, progression, data models, or architecture. Adapt useful ideas to GalaxyGame's requirements rather than importing the reference product's assumptions.

## Craft and remote command model

**ESTABLISHED INTENT — 2026-11-19; reaffirmed 2026-11-21**

Spacecraft are autonomous operational assets, not player-character avatars. Players assign objectives, destinations, missions, or activity plans remotely when a communication path is available; the player does not need to be aboard or represented by a pilot/character record.

Craft automation and the AI Manager may continue previously authorized work when the player is away or communication is unavailable, subject to the craft's capabilities and assigned authority. A lost or delayed communication path does not automatically stop an already authorized operation. New instructions and changes cannot be assumed to arrive instantly.

The UI must distinguish a command or assignment being issued from its receipt, acceptance, execution, and reported completion. It must also distinguish current craft-reported state from the player's last-known information and its age, and from projected future events.

## Space-based operations

**ESTABLISHED INTENT — 2026-11-21**

Space operations are activities carried out by spacecraft and space-based infrastructure. They can take place in orbit, at orbital facilities, around asteroids and other small bodies, or in a planetary atmosphere when a spacecraft or skimmer is performing atmospheric harvesting.

Examples include:

- Asteroid and other small-body resource extraction, including electromagnetic (EM) harvesting.
- Atmospheric gas harvesting by spacecraft/skimmers operating in a planetary atmosphere. This is a spacecraft operation, not a planetary surface operation.
- Transport of materials, supplies, fuel, and equipment between orbital locations, asteroids, stations, depots, and other space work sites.
- Orbital and asteroid-based construction, assembly, servicing, and logistics.
- Inter-system travel through natural wormhole connections and in-system travel between space locations.
- Planned rendezvous, resupply, unloading, inspection, repair, and support activities associated with a space operation.

The examples establish the kinds of activities the game should support; they do not yet define every craft capability, resource rule, activity lifecycle, or simulation calculation.

## Planetary surface operations

**ESTABLISHED INTENT — 2026-11-21**

Planetary Surface Operations are activities performed on the surface of a celestial body. They have a different operating environment, asset context, spatial representation, and activity vocabulary from spacecraft-based Space Operations.

Examples include:

- Terrain-based resource exploration and mining.
- Surface settlements, facilities, infrastructure, and construction.
- Surface vehicles, equipment, and mobile units moving between surface locations.
- Surface transport, hauling, supply, maintenance, and construction logistics.
- Coordination of multiple surface units and facilities across terrain and between settlements.

Surface operations belong to the Player Surface context and its own operational interface. They should not be folded into the Space Fleet Manager simply because both involve assigning assets, sequencing work, moving resources, or coordinating autonomous activity.

## Shared operational concepts, distinct activity models

**ESTABLISHED INTENT — 2026-11-21**

Space and surface operations may share underlying planning concepts:

- Assigning an asset or group of assets to an objective.
- Defining ordered activities, destinations, and waypoints.
- Establishing dependencies, conditions, or completion criteria where supported.
- Moving resources between work sites.
- Coordinating independent assets and planned rendezvous.
- Allowing authorized automation to continue work while the player is absent.
- Reporting delayed status and distinguishing last-known information from estimates.

Shared concepts do not make the two operating contexts interchangeable. Space Operations and Surface Operations require distinct activity models and interfaces that reflect their respective assets, environments, locations, and tasks. Reusable planning or status components may be shared where appropriate, but one overloaded UI must not obscure the distinction.

## Operational groups and fleet assignments

**ESTABLISHED INTENT — 2026-11-21**

A fleet is an optional operational grouping of spacecraft assigned to a shared objective or coordinated operation. Fleet membership is an operational relationship, not a claim that craft are physically together, travel in formation, follow the same route, or remain in one system.

Participating craft may work at different locations and perform different activities while contributing to the same objective. A construction operation, for example, may include craft assembling infrastructure at an asteroid, harvesters collecting EM elsewhere, transport craft delivering harvested material and supplies, and support craft providing fuel or maintenance.

Not every craft must belong to a permanent fleet. Individual craft can operate independently or be associated with an operation for a particular purpose. Fleet grouping must not become a prerequisite for assigning or tracking an individual craft.

The same high-level concept of grouping and coordinating assets may apply to surface operations, but surface units and their tasks belong to the separate surface operating context. Do not assume spacecraft fleet rules automatically define surface-unit organization.

## Navigation routes and operational itineraries

**ESTABLISHED INTENT — 2026-11-21; detailed mechanics OPEN**

Space travel and work planning involve related but distinct layers:

- **Inter-system route:** an ordered sequence of systems and intended wormhole transitions.
- **System-specific in-system route:** local locations and waypoints within a solar system.
- **Operational activity plan:** what assigned craft do at destinations and waypoints, including harvesting, unloading, delivery, resupply, market transactions, inspection, repair, construction support, waiting, and rendezvous.

A fleet operation can combine an inter-system route with different in-system itineraries for different craft. Some craft may proceed toward a departure wormhole while others visit an asteroid, station, or planet to perform work. Craft may later meet at a planned rendezvous before continuing.

A reusable preferred route is a navigation plan; it is not by itself a complete fleet work schedule, a guarantee that a connection remains available, or confirmation that a craft can execute it. Activity order, resource handling, dependencies, timing, and rendezvous are part of the operational plan.

A planned arrival or departure time is an estimate or coordination target, not a guarantee. Actual feasibility and execution depend on game rules and current conditions that remain to be defined or verified.

## Asynchronous execution and communications

**ESTABLISHED INTENT — 2026-11-21**

The player may prepare and send an operation without remaining present to watch every activity. Craft automation and the AI Manager can continue authorized work within their capabilities and the available authority/communications model.

Communications and data updates can be delayed. The player interface must not imply universal real-time observation or instant remote intervention. It should distinguish:

- Last-known craft state and the age/source of that information.
- A command or assignment sent, received, or acknowledged, where those states are available.
- Reported activity progress or completion.
- Estimated future arrival, readiness, rendezvous, or departure events.

The exact communication protocol, command lifecycle, autonomy limits, and reporting cadence remain implementation/design details to be resolved against the authoritative game systems.

## Relationship to Player interfaces

**ESTABLISHED INTERFACE DIRECTION — 2026-11-21**

- **Space context:** system-wide awareness and spacecraft-based operations.
- **Player Fleet Manager:** coordinates spacecraft assigned to a shared space operation, including distributed activities, local itineraries, resource movements, and rendezvous.
- **Player Route Planner:** creates, names, saves, and reuses preferred navigation routes; it does not author the full activity schedule.
- **Individual Craft Tracking:** follows one spacecraft, its assigned route, status, and reported progress; it is not the fleet-planning or route-authoring workspace.
- **Player Surface context:** presents terrain and surface-based activity. A dedicated Surface Operations interface is a separate design concern from Space Fleet Manager.
- **Settlement context:** presents the management of one settlement; it is related to surface activity but is not a substitute for the broader Surface Operations view.

Player asset-management workflows remain distinct from Admin and AI Manager oversight. The AI Manager's autonomous operations and the player's ability to assign or inspect work must respect the same underlying game authority and communications model.

## Open details

The following remain in progress and must not be invented by UI implementation:

- Exact activity definitions, lifecycle states, capability requirements, and completion rules.
- How operational groups are created, assigned, modified, and dissolved.
- Detailed task dependency and conditional-execution semantics.
- How resource sale, purchase, transfer, reservation, and supply limits are specified and resolved.
- How rendezvous readiness, missed rendezvous, and departure windows are evaluated.
- Exact route availability, pathfinding, travel-time, fuel, and feasibility rules.
- Craft autonomy limits, command authority, communications routing, and reporting cadence.
- The detailed Surface Operations interface and how surface-unit groupings map to underlying game systems.
- Which shared planning concepts should be implemented as common domain services versus context-specific behavior.

Resolve these details against current code and the relevant authoritative game wiki pages before treating them as implemented mechanics.

## Related gameplay and interface references

These pages provide more detailed domain intent for particular systems. This page defines the cross-context gameplay distinction and operational concepts; it does not replace their specialized rules.

- [Logistics and hauling](../logistics/logistics_and_hauling.md) — transport and hauling intent.
- [Atmospheric harvesting](../infrastructure/atmospheric_harvesting.md) — atmospheric extraction context and processing.
- [Natural wormholes and EM](../technical/natural_wormholes_and_em.md) — natural wormhole behavior and EM.
- [Interstellar communications](../engineering/interstellar_communications.md) — delayed communications and store-and-forward relay intent.
- [AI Manager and autonomous coordinators](../services/ai_manager.md) — autonomous operations and coordinator responsibilities.
- [Player View Architecture](../ui/02_player_view_architecture.md) — Player Space, Fleet Manager, Route Planner, Craft Tracking, and Surface interface boundaries.

