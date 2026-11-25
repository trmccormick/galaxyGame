> **Status: DESIGN INTENT** — owner-confirmed gameplay direction; detailed mechanics and implementation remain in progress  
> **Last Updated:** 2026-11-24

# Space and Surface Operations

This page records the intended gameplay distinction between spacecraft-based operations in space and operations conducted on a celestial body's surface. It captures the current design direction, not a complete simulation specification. Some examples and activity types are established intent while detailed rules, capabilities, and execution mechanics remain open.

## Game identity and use of references

**ESTABLISHED INTENT — 2026-11-21**

GalaxyGame is its own game with its own goals, simulation model, mechanics, and player experience. It may draw useful ideas from many games, simulations, and applications, but it is not an attempt to recreate or combine EVE Online, SimEarth, Civilization, SimCity, or any other existing title.

References are evaluated at the level of the particular idea they demonstrate: a map interaction, information layout, planning workflow, visualization, or other useful pattern. A reference does not establish GalaxyGame gameplay rules, terminology, progression, data models, or architecture. Adapt useful ideas to GalaxyGame's requirements rather than importing the reference product's assumptions.

## Craft and remote command model

**ESTABLISHED INTENT — 2026-11-19; reaffirmed 2026-11-21**

Spacecraft are autonomous operational assets, not player-character avatars. The player does not pilot or directly steer craft. Players assign destinations, start missions whose plans contain programmed destinations and activities, and may change orders while a mission is underway. The player does not need to be aboard or represented by a pilot/character record.

The player may cancel a mission, issue a single high-level instruction, or provide a revised mission. Examples include rerouting to a location if fuel and other applicable constraints permit, docking at the closest suitable orbital settlement, or stopping at the nearest suitable settlement to refuel. A single instruction should not require the player to manually construct a complete replacement mission. The AI Manager evaluates the instruction against the craft's capabilities, available fuel, route feasibility, and available destination services, then manages execution or reports why it cannot comply. Exact instruction vocabulary and resolution rules remain OPEN.

Craft automation and the AI Manager may continue previously authorized work when the player is away or communication is unavailable, subject to the craft's capabilities and assigned authority. A lost or delayed communication path does not automatically stop an already authorized operation. A newly issued cancellation, instruction, or revised mission is not effective at a remote craft until it can be delivered and acted upon.

The UI and operational model must distinguish a command being issued from its delivery, receipt, acceptance, execution, and reported completion. They must also distinguish current craft-reported state from the player's last-known information and its age, and from projected future events.

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

An **operation** is the broad operational context for one or more craft carrying out an objective or mission. An operation may be coordinated as a **fleet**, or it may be carried out by one or more independently dispatched craft without creating a fleet. The UI must make both forms first-class; a craft must never need to be placed in a one-craft fleet merely to be assigned, monitored, or tracked.

A **fleet** is an optional operational grouping of spacecraft assigned to a shared objective or coordinated operation. Fleet membership is an operational relationship, not a claim that craft are physically together, travel in formation, follow the same route, or remain in one system. Fleet members may be distributed across locations and systems, perform different tasks, and follow different in-system itineraries while contributing to the shared objective.

An independent craft operation is appropriate when one spacecraft is dispatched to perform an autonomous mission. For example, a robotic Venus atmospheric harvester may operate on a recurring Luna–Venus cycle: depart Luna, travel to Venus, harvest atmospheric gases, return to Luna, unload and service as required, then repeat according to its authorized plan. It is tracked as an independently dispatched craft/operation; it does not require a fleet wrapper. This example illustrates the organizational distinction and does not establish the detailed harvesting, cargo, fuel, or scheduling mechanics.

A coordinated construction/logistics operation, by contrast, may use a fleet grouping containing craft assembling infrastructure at an asteroid, harvesters collecting EM elsewhere, transport craft delivering harvested material and supplies, and support craft providing fuel or maintenance. The grouping communicates their shared objective and coordination relationships, not physical proximity or a common route.

A craft may be assigned directly to an independent operation or associated with a fleet for a particular purpose. The UI should expose fleet groupings and independent dispatched craft/operations in the same operations workspace without conflating them. Fleet membership must not become a prerequisite for assigning or tracking an individual craft. How fleets and operation assignments are persisted, created, modified, or dissolved remains OPEN.

The same high-level concept of grouping and coordinating assets may apply to surface operations, but surface units and their tasks belong to the separate surface operating context. Do not assume spacecraft fleet rules automatically define surface-unit organization.

## Navigation routes and operational itineraries

**ESTABLISHED INTENT — 2026-11-21; detailed mechanics OPEN**

Space travel and work planning involve related but distinct layers:

- **Inter-system route:** an ordered sequence of systems and intended wormhole transitions.
- **System-specific in-system route:** local locations and waypoints within a solar system.
- **Operational activity plan:** what assigned craft do at destinations and waypoints, including harvesting, unloading, delivery, resupply, market transactions, inspection, repair, construction support, waiting, and rendezvous.

A fleet operation can combine an inter-system route with different in-system itineraries for different craft. Some craft may proceed toward a departure wormhole while others visit an asteroid, station, or planet to perform work. Craft may later meet at a planned rendezvous before continuing.

A reusable preferred route is a navigation plan; it is not by itself a complete fleet work schedule, a guarantee that a connection remains available, or confirmation that a craft can execute it. Activity order, resource handling, dependencies, timing, and rendezvous are part of the operational plan.

The player may set or change a destination/route independently of authoring a complete mission, or may revise the remaining mission plan. A one-time instruction such as "dock at the closest orbital settlement" or "stop at the nearest suitable settlement and refuel" expresses an outcome for the AI Manager to resolve into feasible actions. A reroute is conditional on available fuel and the other applicable travel constraints. The exact feasibility rules and command-resolution behavior remain OPEN; this page does not prescribe route-selection algorithms or UI controls.

A planned arrival or departure time is an estimate or coordination target, not a guarantee. Actual feasibility and execution depend on game rules and current conditions that remain to be defined or verified.

## Wormhole reach, unmapped destinations, and system generation

**OWNER-CONFIRMED GAMEPLAY CLARIFICATION — 2026-11-24**

Wormhole connectivity is not constrained by the currently mapped astronomical catalog, the Local Bubble, physical distance, or whether a destination system already has a complete record in the game library. A wormhole can lead to any location in the game universe. An unmapped or unrecorded destination is not an invalid destination and must not be treated as unreachable merely because GalaxyGame has not cataloged it yet.

This is a game, and its universe is intentionally flexible. Wormhole endpoints may connect already-known systems, real catalog stars that have not yet been mapped by the player, or systems that GalaxyGame generates when needed. A destination can be revealed or instantiated through discovery, travel, scouting, or other game processes. The navigation model must not require every endpoint to exist in a prebuilt Local Bubble fixture or static system list before a route can be represented.

Likewise, GalaxyGame may generate additional nearby stars and systems even when no corresponding real-world catalog record is available in its local data library. Where a real catalog star is selected as the anchor, retain and match its catalog identity and known astronomical properties, then generate a plausible planetary system if observational planetary data is absent or incomplete. Where no real catalog identity is available or intended, the game may generate the star and system. Generated planetary architecture is game content, not a claim that those planets have been observationally confirmed.

A generated system that corresponds to an identifiable real star must be matched to that star's catalog identity rather than represented as a duplicate fictional star. Incomplete real-world data is not a reason to discard a real star or prevent it from becoming a playable system. Preserve provenance so observed stellar facts remain distinguishable from procedurally generated game properties.

The physical astronomy map and the wormhole network remain separate representations. Galaxy View may show only systems with usable physical positions; a system without known coordinates may remain available through a catalog, discovery result, or network endpoint without receiving invented astronomical coordinates. The Wormhole Network may show or resolve a connection to that system independently of its physical map placement. Display-only graph layout coordinates must never be mistaken for real astronomical positions.

Mapping and survey missions can expand a civilization's known astronomical neighborhood. For example, a mapping satellite or survey craft deployed in Eden may be assigned a radius in light-years; the game can populate that region from available real star catalogs, match existing system records, and generate playable systems around catalog stars that lack known planetary data. It may also generate additional game stars where catalog coverage is unavailable or where the game needs them. Mapping is a gameplay path for acquiring and improving knowledge, not a prerequisite for a wormhole to exist or connect to an unmapped destination.

These rules establish flexible game-world behavior, not a requirement to simulate every real star or to limit generation to a specific catalog, radius, or mission type. Detailed discovery, survey, generation, and wormhole mechanics remain subject to their respective game systems.

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

- **Space context:** navigation only—showing craft locations, destinations, inter-system wormhole routes, and in-system itineraries. It is not a general operations dashboard or direct piloting interface.
- **Player Fleet Manager:** coordinates spacecraft assigned to a shared space operation, including distributed activities, local itineraries, resource movements, and rendezvous.
- **Player Route Planner:** creates, names, saves, and reuses preferred navigation routes; it does not author the full activity schedule.
- **Individual Craft Tracking:** follows one spacecraft, its assigned route, status, and reported progress; it is not the fleet-planning or route-authoring workspace.
- **Player Surface context:** presents terrain and surface-based activity. A dedicated Surface Operations interface is a separate design concern from Space Fleet Manager.
- **Settlement context:** presents the management of one settlement; it is related to surface activity but is not a substitute for the broader Surface Operations view.

Player asset-management workflows remain distinct from Admin and AI Manager oversight. The AI Manager's autonomous operations and the player's ability to assign or inspect work must respect the same underlying game authority and communications model.

## Open details

The following remain in progress and must not be invented by UI implementation:

- Exact activity definitions, lifecycle states, capability requirements, and completion rules.
- How operations and fleet groupings are created, assigned, modified, and dissolved; how craft move between independent assignments and fleet membership.
- Detailed task dependency and conditional-execution semantics.
- How resource sale, purchase, transfer, reservation, and supply limits are specified and resolved.
- How rendezvous readiness, missed rendezvous, and departure windows are evaluated.
- Exact route availability, pathfinding, travel-time, fuel, and feasibility rules.
- How single high-level instructions are translated into executable actions, how the AI Manager reports infeasible requests, and which constraints govern mission cancellation or rerouting.
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

