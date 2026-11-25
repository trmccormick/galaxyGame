> **Wiki section:** UI & Experience · **Status:** Established intent for view boundaries and navigation principles; detailed layouts remain DIRECTION or OPEN  
> **Last Updated:** 2026-11-24

# Player View Architecture

This page defines the Player Dashboard's three primary views, the separate Space context, and how players navigate between systems and locations. It is not an implementation specification. The Player Dashboard is separate from the Admin Dashboard; administrative screens and operational tools are not player views.

## Design authority

The main `galaxyGame` repository is authoritative for product design intent and game-domain rules. The separate `galaxy-game-ui` repository is the presentation prototype and implementation workspace. Prototype appearance does not independently establish approved product design.

## Three primary Player views and the separate Space context

**ESTABLISHED INTENT — 2026-11-13**

The Player Dashboard has exactly three primary views: Planetary, Surface, and Settlement. Space is a separate Player context for system-wide space operations; it is not a fourth primary view.

| Context | Purpose | Scope |
|---|---|---|
| **Planetary** | Whole-celestial-body conditions and change | Atmosphere, climate, hydrosphere, biosphere, geology, planetary-scale resources and environmental change |
| **Surface** | Civilization-level activity across a celestial body's surface | Territories, settlements, resource development, infrastructure, transportation, moving units and surface operations |
| **Settlement** | Management of one inhabited/developed settlement | Buildings and structures, population, services, utilities, production, inventory, logistics and development |

These three primary views are distinct interaction contexts, not nested menus or merely camera zoom levels. Navigation may move between related views, but each has its own purpose and information hierarchy.

**Space is separate from the three primary views.** It remains a Player context for system-wide spatial awareness and operations, but is not counted among Planetary, Surface, and Settlement. Do not replace Settlement with Space or add Galaxy as another Player view.

## Navigation and selection workspaces

Galaxy/system catalogs and system workspaces are navigation and selection tools, not additional Player views.

A player should be able to:
1. Browse and search galaxies or star systems through compact catalogs.
2. Select a system and inspect it as a whole.
3. Select a celestial body or orbital location.
4. Open the appropriate Player view or context: Planetary, Surface, Settlement, or the separate Space context.

Selection must not imply physical travel. The UI must distinguish the player's actual location from an object or system being inspected. Do not translate database hierarchy into deeply nested global menus. Players should have direct access to major workflows and use contextual selectors, breadcrumbs, maps, tables, and feature-specific secondary navigation as appropriate.

Large collections should favor compact, comparable tables and lists over repeated oversized cards. Detail panes, contextual actions, and comparisons should appear when an item is selected.

## Player account, distributed assets, and operating locality

**ESTABLISHED INTENT — 2026-11-21**

The Player experience should provide a unified account and management view for the player's orders, assets, inventory holdings, balances, transactions, and activity across the game universe. The player should be able to keep track of and manage one coherent portfolio rather than maintaining unrelated accounts for every settlement or star system.

This centralization is logical and managerial, not physical or instantaneous:
- Assets and inventory remain at their actual settlements, stations, ships, or other locations.
- Market orders remain associated with the settlement marketplace where they were placed.
- Local services and markets remain authoritative for their own current state and execution.
- The central Player interface aggregates the most recent information delivered to the player's current operating location.
- Remote information can be delayed or incomplete, and remote instructions can remain in transit before reaching the location where they can execute.

Most routine player activity is expected to take place within one primary star system, where local information and operations are more responsive. Players may establish additional operations or move assets to other systems and galaxies, but wider activity carries communications and logistics costs. The player can retain centralized oversight of those distributed holdings without receiving instantaneous updates or control.

The Player interface should distinguish the player's **operating location** from the location of the asset, market, or system being inspected. Selecting a remote location to inspect does not move the player there or grant a live connection to it. Market scope and other cross-location views can offer Settlement, System, Galaxy, and Universe discovery scopes, but wider scopes show only information that has propagated to the player's operating location.

### Possible operating strategies (gameplay examples)

Where a player chooses to concentrate their operations is an open-ended gameplay decision. The following are examples of approaches a player might discover useful; they are not prescribed roles, mutually exclusive paths, required strategies, or mechanics that the game assigns to players.

- A player especially interested in markets, inter-system trade, and managing robot or space-based fleets might choose an operating base near an AWS / WH station. Its network position could make nearby inter-system activity more convenient.
- A player more interested in planetary settlements, resource extraction, manufacturing, and local logistics might prefer to operate from a settlement or a nearby orbital facility.
- A player pursuing both kinds of activity might maintain a mixture of planetary and orbital operations while managing their distributed holdings through the centralized Player account.

These examples do not establish a universally best location or play style. The communications network still determines what information and commands can reach each location and how long delivery takes. Players can experiment with different arrangements and decide what best supports the activities they enjoy.

### Communications as an experienced gameplay constraint

**ESTABLISHED INTENT — 2026-11-21**

The Player should feel information propagation and command delivery delays during ordinary gameplay. Communications status is not merely decorative metadata. It affects when the player learns about remote events, when remote instructions can be executed, and when the player receives confirmation.

The shared communications network routes information hop by hop through available local relays and physical carriers. Within a system, data moves through the available local network. Intra-system portals can shorten the physical carrier's journey between connected endpoints, but do not provide instant data transfer. Between systems, data-carrying craft travel through natural wormholes or operational AWS connections; receiving stations then route the data onward through the destination system's network. Additional systems add further routing and carrier legs. There is no universal real-time market feed or instantaneous universe-wide player control.

For remote actions, the Player experience must distinguish:
- the time for relevant information to reach the player;
- the time for a command to reach its destination;
- execution at the destination against its actual current state;
- the time for acknowledgment to return.

A command can be delivered and executed before its confirmation reaches the player. The player can continue other activities while communications are pending. Existing craft automation and AI Manager authority may continue previously authorized work during communication gaps; this does not make newly issued player commands instantaneous.

The UI should present last-known state, source and receipt times, information age, pending communication status, and delivery/acknowledgment estimates where available. It must not silently replace stale information with live remote state. See [Interstellar Communications](../engineering/interstellar_communications.md) for the shared routing and delivery model.

## Space context

**ESTABLISHED SPACE VIEW ARCHITECTURE — 2026-11-24**

Space remains one Player context, with three coordinated but independent ways to understand astronomical space and operations:

1. **Galaxy View** — a selected-system-centered spatial neighborhood. For Sol, the initial view focuses on the Sun's nearby stellar neighborhood and uses known real-system positions. It may show larger Milky Way context as the player zooms out. Local Bubble information belongs to this physical spatial view.
2. **Wormhole Network** — a system-connectivity graph. It represents natural wormholes and operational network connections, not astronomical positions or galaxy membership. A wormhole may connect systems in different galaxies; remote endpoints remain visible regardless of the selected Galaxy View context.
3. **System View** — the selected star system's local spatial context: stars, celestial bodies, stations, facilities, spacecraft, orbits, and trajectories where supported by available data.

These are coordinated views, not three separate game worlds or a hierarchy of physical containment. Selecting a system synchronizes the selected-system context across views, but the views retain their own spatial meanings and data. Galaxy View must not filter or remove remote Wormhole Network endpoints.

### Stellar classification in system-node colors

**OWNER-CONFIRMED UI DIRECTION — 2026-11-24**

Galaxy View and Wormhole Network use the same primary-star color language for system nodes. Node fill communicates the documented spectral class of the system's designated primary/display star; it does not communicate wormhole access, connection state, ownership, selection, or route status.

- O/B: blue; A: cool white; F: pale yellow-white; G: golden yellow; K: orange; M: red/coral.
- L/T/Y brown dwarfs: muted brown-violet; white dwarfs: pale blue-white.
- Unknown or unclassified: neutral gray. Never infer a star class from a system name, generated-system label, or visual appearance.
- The system record must carry the classification and its provenance (for example, observed or procedurally generated). A generated star without an assigned classification remains unknown until the generator supplies one.
- Selection remains a separate cyan outer halo. A craft route remains a separate gold dashed overlay. Wormhole connectivity remains represented by edges, while access/baseline state uses a separate node ring; neither may recolor the stellar node fill.
- Multiple-star systems require an explicit designated display/primary component before assigning a single node color. Do not silently choose or blend component classes.

The palette is a compact UI classification key, not a claim that the displayed colors reproduce the star's exact perceived color. Both views must show a consistent legend.

### Astronomical geography and constellation context

**OWNER-CONFIRMED DESIGN INTENT — 2026-11-24**

Keep the following concepts distinct:

- **Astronomical geography:** the real 3D positions of star systems in the Milky Way or another galaxy.
- **Physical astronomical regions:** structures such as the Local Bubble, represented as spatial regions when supported by suitable source data.
- **Constellations:** the 88 IAU-defined areas of the apparent sky, bounded in celestial coordinates. They are observational sky regions, not physical 3D groupings of stars.
- **Wormhole connectivity:** a travel/network graph independent of physical distance, constellation, and galaxy membership.

For Sol, the constellation context is an angular sky projection as observed from Sol. It is a separate layer/view from the physical Local Bubble neighborhood. Do not draw IAU constellation boundaries as if they were 3D walls or Local Bubble borders. A star system's constellation is determined by its apparent direction from the observing system, not by its 3D proximity to another star.

### Real-system catalog and incomplete astronomical data

The existing curated real-system seed collection is the starting selection for Sol's nearby-system view. It is intentionally limited and is expected to expand. A real-system seed is incomplete starting information for StarSim, not a requirement that the system have a complete planetary inventory.

The UI may join those seed identities to a separate derived astronomical catalog containing right ascension, declination, distance, derived Cartesian positions, constellation boundary geometry, and source/provenance metadata. This derived UI fixture is not authoritative simulation state and does not establish a final main-application data model.

Use only source-supported positions. A system with a known position can be plotted even when its constellation assignment is unavailable. A known system with no usable position can remain in a catalog/list but must not be assigned an invented map location. If the source coordinate epoch, reference frame, or precision is incomplete, preserve that limitation and avoid presenting the resulting placement or constellation match as more precise than the source supports.

Constellation membership is optional. A known real system may have a known, provisional, or unknown assignment depending on available astrometry. Procedurally generated systems may have no real-world constellation association; `none` or `unknown` is valid and must not be treated as an error. Do not infer constellation membership from a wormhole, selected galaxy, or local spatial proximity.

A future main-application catalog may represent IAU constellation names, abbreviations, official boundary geometry, coordinate metadata, and physical astronomical regions such as the Local Bubble. How that information is persisted or related to system records remains OPEN. Do not assume a database table, JSON catalog, or a required constellation field on every system until that model is reviewed.

**DIRECTION**



Space is the system-wide operational view. It should represent the selected solar system and the physical relationships among bodies, ships, stations, and other orbital infrastructure.

Candidate content includes:
- ships at current locations, in transit, or assigned to destinations and missions;
- orbital settlements and infrastructure, including L1 depots, orbital stations, shipyards, wormhole stations, and industrial platforms;
- trajectories, travel distances, launch windows, and estimated travel times where supported by simulation data;
- natural wormholes, AWS connections, portals, EM fields, and relevant space phenomena.

### Celestial current positions and uninitialized spatial records — ESTABLISHED UI INTENT (owner, 2026-11-24)

The System View prefers authoritative current celestial positions from StarSim's active spatial state and its declared coordinate-frame metadata. It does not calculate authoritative ephemerides or future orbital motion in the browser. Supplied orbital elements may be rendered as orbit geometry, but an orbit path is not itself a current body position or an ephemeris.

A `Location::SpatialLocation` record is not automatically a valid current position. The current main-app body callback creates `(0,0,0)` placeholders before StarSim has calculated a position, and the current model does not expose a validity marker. The future API should expose explicit position validity (or equivalent source/status metadata). The UI ignores unmarked all-zero placeholders; a genuine object at the coordinate origin is accepted only when explicitly marked valid.

**Temporary UI starting-position fallback:** When no valid coordinates are supplied, the prototype may place a body at a temporary display-only point on a circular/elliptical orbit using its supplied orbital distance. Planets use distance from the star; moons use distance from their declared parent planet. If phase is supplied, use it; otherwise choose a stable pseudo-random phase derived from the system/body identity so the marker does not jump on rerender. This is only a visual starting placement for the prototype—not an authoritative StarSim position, ephemeris, or runtime simulation result. A missing parent or missing usable distance leaves the body unplaced.

Initialization fallback for new universes—known ephemerides first, then orbit-constrained randomized phase when unknown—is defined in [StarSim architecture](../design/starsim_and_protection_classes.md).

### Craft operation and remote command model

**ESTABLISHED INTENT — 2026-11-19**

GalaxyGame craft are autonomous operational assets, not player-character avatars. Most craft operate through onboard automation. Players direct their craft remotely by assigning commands, objectives, destinations, or missions when a communication path is available; the player does not need to be physically aboard or represented by a pilot/character record. Remote command availability and data freshness must respect GalaxyGame's communications model rather than implying universal instant control.

Craft automation and the AI Manager can continue authorized operations when a player is not connected or communication is unavailable. Loss of player communication does not imply that the craft simply stops or disappears from the operational model. The exact autonomy and authority of a particular craft depend on its capabilities and assigned operation.

Craft may operate independently or be grouped for a particular task or operation. Do not assume every craft belongs to a permanent fleet or that a fleet is the required unit of control. In the UI, identify assets by their GalaxyGame ship/craft names and identities—not by EVE-style character or pilot names. Show current location, operational state, assigned objective, and communication/data age as distinct facts where the source data supports them.

Player asset-management interactions and Admin/AI Manager operational oversight are related but distinct workflows. They may reuse generic selection, filtering, grouping, and status components, but should not be collapsed into one identical fleet-management screen.

The view must distinguish inter-system wormhole network connections from in-system spatial relationships. The supplied Pixel Nexus application screenshots and JavaScript may inform pan/zoom, selection, routes, markers, and topology presentation. Pixel Nexus is the user's friend's Python application for connecting to an API; it is not EVE Online. Its map topology and application-specific domain assumptions are not a substitute for GalaxyGame's wormhole network or a literal solar-system view. Existing GalaxyGame `system_renderer.js` is an early baseline to inspect, not a finalized design.

### Individual craft tracking workspace and route views

**ESTABLISHED PLAYER SPACE VIEW DIRECTION — 2026-11-21**

The initial Player Space workspace is an **individual craft tracking and route-planning view**, not a fleet-management screen. Adapt useful layout and interaction patterns from the supplied Pixel Nexus Fleet Manager reference, but do not carry over its specific fleet presentation or application-domain assumptions.

The full application screen retains the persistent main-game navigation at the far left. Space does not replace, duplicate, or absorb that navigation. To its right, the Space workspace has three coordinated panes (making four vertical areas across the full screen):

1. **Left workspace pane — craft selection:** a selectable list of the player's individual spacecraft. Selecting a craft loads that craft into the workspace. This is not a fleet list; craft can operate independently. Grouping multiple craft into fleets or other operational groups is a separate capability and must not define or constrain this individual-craft view.
2. **Center workspace pane — two stacked maps, both visible at the same time:**
   - **Wormhole Network map:** shows inter-system wormhole connections and the selected craft's planned route between systems, including the relevant system sequence and wormhole transitions.
   - **In-System Route map:** shows navigation within the relevant selected solar system, including the selected craft's position, destination, intermediate stops or waypoints, and planned local route.
   
   These are vertically stacked visualizations, not tabs, a toggle, or mutually exclusive map modes. They represent different spatial scales and must not be conflated. The in-system map is not a substitute for the wormhole network map, and the wormhole network map is not a substitute for solar-system navigation.
3. **Right workspace pane — selected craft information and route:** shows the selected craft's identity and supported operational details, including status, current position, destination, assigned objective/mission, condition, fuel or other relevant resources, cargo, and communication/data freshness where available. Show the planned route as an ordered sequence of stops/transitions as well as its map representation. Do not imply unavailable values or live updates.

Both maps and the right-hand information/route panel are driven by the same selected craft. Changing craft selection updates all three areas coherently. The two maps remain independently navigable/interactive (for example, their own pan/zoom and selection behavior) while representing the same craft and its related route. The route shown should distinguish the inter-system portion from the in-system portion; exact cross-map selection behavior and route editing controls remain open for later review.

**Craft-centered context and unavailable location data — ESTABLISHED UI INTENT (2026-11-24)**

The selected craft's reported current system is the active context for the entire Space workspace. Changing craft selection must update the System View, Galaxy View, Wormhole Network emphasis, system summary, and selected-craft information together. A separate system dropdown must not compete with this craft-centered focus; the current craft and system should remain visible as workspace context.

Current location, destination, and planned route are distinct. The UI must use the craft's reported current system for its physical context and must not substitute its destination or a route endpoint. If the current system is unknown, do not infer it from either.

Galaxy View provides a physical neighborhood map centered on the focused system. Populate it with sourced positions for nearby systems in that system's neighborhood; do not treat Sol's neighborhood as universal. If the focused system's nearby-system positions are unavailable, show an explicit neighborhood-data-unavailable state. A global galactic coordinate is not a prerequisite for displaying a system-centered local neighborhood. Constellation boundaries are observer-specific: the Sol sky chart is valid only as the sky observed from Sol; another selected system requires its own observer-specific sky data or an unavailable state.

System View must load only the selected system's own spatial and astronomical data. If no celestial-body or facility positions are available, show that limitation; do not retain objects from the previously selected system or plot a craft using an unrelated/general display coordinate as though it were a sourced local position. Center the in-system map on the primary star, or on a supplied system barycenter when appropriate. Use sourced orbital elements for parent-centered orbital paths; moons orbit their parent bodies rather than being drawn around the system star. When only illustrative display positions exist, derived rings are schematic guides and must not be represented as physical orbital elements or ephemerides. Wormhole Network may continue to show the broader network while emphasizing the selected system and the craft's route, because network connectivity is not physical galactic position.

### Reuse and prototype implementation direction

The supplied Pixel Nexus screenshots and JavaScript are **source material for adaptation**, not a final specification and not a request for a wholesale port. Inspect the forked Pixel Nexus fleet/map JavaScript and reuse or adapt useful craft selection, map rendering, pan/zoom, marker selection, route display, and selected-object panel behavior. Adapt the code to GalaxyGame's domain and the two stacked map requirements; do not assume one Pixel Nexus map module already implements both scales. Existing GalaxyGame `system_renderer.js` is an in-system rendering baseline to inspect and reuse where useful. The wormhole network map needs its own inter-system topology representation, potentially adapted from suitable EVE network/map JavaScript.

The prototype may use clearly identified mock craft and route data. Interactions, route calculations, data refresh, and source integration do not all need to work in this first presentation pass. The immediate goal is to establish the screen, layout, selection behavior where practical, and both map areas so they can be reviewed and refined. Do not rewrite existing JavaScript wholesale merely because the first adaptation is incomplete; preserve useful code and document what was reused, adapted, stubbed, or deferred.

GalaxyGame craft are autonomous operational assets, not player-character avatars. Do not introduce EVE pilots, characters, fleet commanders, EVE terminology, combat, or EVE backend/game rules. Player Space asset interaction remains distinct from Admin/AI Manager operational oversight.

Fleet organization and multi-craft coordination belong in the separate Fleet Manager view described below; they are not part of this individual-craft presentation. Authoritative route finding, navigation simulation, command execution, and production backend/API integration are also outside this initial presentation task.

### Fleet Manager and distributed fleet operations

**ESTABLISHED PLAYER SPACE VIEW DIRECTION — 2026-11-21**

GalaxyGame retains a Player **Fleet Manager** view, using the Pixel Nexus Fleet Manager as a layout and interaction reference. This is an operational coordination workspace, distinct from the individual-craft tracking workspace above. The reference is the user's friend's Python application used for an API connection, not EVE Online. Reuse and adapt useful layout and JavaScript where practical; do not reproduce Pixel Nexus-specific domain assumptions or treat its data model as authoritative for GalaxyGame.

An **operation** is the broad assignment context for one or more spacecraft. It may be coordinated as a fleet, or carried out by independently dispatched craft without a fleet grouping. A **fleet is an optional operational grouping of craft assigned to a shared objective or coordinated operation**. Fleet membership does not mean the craft are physically together, travelling in formation, or even located in the same solar system. Fleet members may be at different locations in one system or distributed across multiple systems, following independent routes and performing different tasks that contribute to the shared objective. Do not make proximity, formation, or simultaneous travel a requirement for fleet membership.

An independent craft operation is equally first-class. A single autonomous craft may be dispatched on a recurring mission and tracked directly without being wrapped in a one-craft fleet. For example, a robotic Venus atmospheric harvester may repeatedly travel from Luna to Venus, harvest atmospheric gases, return to Luna, unload and receive servicing as required, then repeat under its authorized plan. This is an organizational and UI example, not a specification of harvesting, cargo, fuel, or scheduling mechanics.

The Fleet Manager workspace should show optional fleet groupings and independently dispatched craft/operations together, without conflating them. Selecting a fleet focuses on its shared objective and distributed participating craft; selecting an independent operation focuses on its assigned craft, mission, route, and status. Fleet membership is not a prerequisite for assigning or tracking a craft. Persistence and lifecycle details for operations, fleet groupings, and assignments remain OPEN.

For example, a player may organize an asteroid-station construction fleet in which:
- construction and assembly craft work at the asteroid;
- separate harvesting craft operate elsewhere in the system collecting electromagnetic material (EM);
- transport craft carry harvested EM and other supplies to the construction site;
- support craft provide fuel, maintenance, replacement parts, or other services.

These craft are one fleet because their assignments and resource movements support the shared station-construction objective, not because they occupy the same location. The same principle applies when a player has multiple fleets conducting separate operations in different systems.

The Fleet Manager should retain the useful layout and interaction patterns of the Pixel Nexus reference while adapting its content to GalaxyGame. The reference's selected character (Neon Red) and character/pilot identity model are not GalaxyGame domain concepts; GalaxyGame spacecraft are autonomous assets, not player-character avatars. Do not import character portraits, pilot identities, or character-based command assumptions. The workspace lets the player oversee coordinated fleet operations and independent craft assignments, understand how distributed craft contribute, and identify work that needs attention. Relevant information includes:
- the selected fleet or independent operation identity, objective/mission, current status, and overall progress;
- participating craft for a fleet, or the assigned craft for an independent operation, with their roles/tasks, current locations, and operational states;
- the geographic distribution of participating assets across relevant locations and systems;
- planned or active movements between work sites;
- material/resource flows and deliveries supporting the objective;
- dependencies between tasks (for example, construction waiting on an EM delivery);
- delays, shortages, failures, communication limitations, or other issues requiring attention.

The view should make the shared objective and coordination relationships clear without implying that every detail is a live, authoritative simulation value. For the UI prototype, clearly identified mock fleet, craft, task, location, delivery, and progress data are acceptable. The first presentation pass should establish the screen and useful selection/overview interactions; backend persistence, real task orchestration, logistics simulation, authoritative route finding, and command execution are not prerequisites.

Fleet Manager and Individual Craft Tracking are complementary workspaces:
- **Fleet Manager** organizes by shared operation/objective, shows distributed fleet members, and lists independent dispatched craft/operations without requiring artificial one-craft fleets.
- **Individual Craft Tracking** organizes around one selected spacecraft and shows its own status, position, and route, whether it belongs to a fleet or is independently assigned.

Selecting a craft from a fleet should provide a path to inspect that craft in the individual-craft tracking workspace. The Fleet Manager must not replace or absorb that workspace, and the individual-craft workspace must not be expanded into a fleet-management screen. Fleet membership and operation assignments should be represented as operational relationships, not as physical formations.

This is a Player coordination interface, not the Admin or AI Manager oversight interface. The AI Manager and craft automation may continue authorized work subject to the communications and authority model; the Player Fleet Manager presents the player's view of the operation and does not imply unrestricted real-time control.



#### Fleet itineraries, independent craft assignments, and asynchronous execution

**ESTABLISHED INTENT — 2026-11-21**

A fleet operation is not just a shared destination or a route followed by every member together. It can contain a **planned sequence of activities and assignments** for different craft, at different locations, with different schedules. The player should be able to prepare this plan and send the fleet assignment without needing to remain present and watch each step occur. Craft automation / AI Manager continue authorized work within their capabilities and the available communication/command model.

A fleet itinerary combines two related navigation layers:
- **Inter-system wormhole route:** the ordered system-to-system journey and intended wormhole transitions.
- **System-specific in-system itineraries:** the local waypoints, layovers, rendezvous points, and activities planned in each system. These local routes are not necessarily the same for every craft, and may branch into separate tasks before rejoining at a later rendezvous or departure point.

A fleet may make operational layovers during transit. For example, after arriving in a system, some craft may proceed directly toward the next departure wormhole while harvesters visit an asteroid belt for light EM harvesting. A transport craft may independently travel to a planet, sell materials, purchase specified supplies needed by the fleet, and then return to a rendezvous. Other craft may remain at a construction site and continue work. These craft remain part of the same fleet operation because their assignments support its shared objective, not because they share a location or route.

The player should be able to build an ordered activity plan that can include:
- craft or craft-group assignment and role;
- destination, local waypoint, and intended activity (such as harvesting, unloading, delivery, resupply, inspection, repair, construction support, market sale/purchase, waiting, or rendezvous);
- activity order and, where needed, dependencies or conditions for proceeding;
- expected duration or completion criteria where supported;
- resource handling instructions, including what may be sold, what supplies may be purchased, and fleet needs or limits;
- intended rendezvous location and planned departure/jump window.

Craft may follow different local routes and schedules. A transport craft can leave for a planet and conduct market transactions while harvesters continue working elsewhere. A slower craft may proceed directly to a departure wormhole while other craft perform local activities, then meet it before the planned jump. The operation should show the expected arrival of the primary/lead craft, expected return or readiness of other participants, and whether they are projected to make the rendezvous. A planned jump time is an estimate/coordination target, not a guarantee that every craft will be ready or that a wormhole remains available.

Because player communications and data updates can be delayed, the player may need to send an assignment in advance and receive status later. The UI must distinguish the player's last known information and its age from estimated future events and current craft-reported state. Do not imply continuous real-time observation or instant remote intervention. When communication is unavailable, craft and AI Manager may continue previously authorized tasks within their autonomy; new player instructions or changes cannot be assumed to arrive instantly.

Fleet Manager should therefore present both the overall inter-system route and the selected system's local routes/activities, with the ability to inspect different craft assignments. Selecting a system along the wormhole route should expose that system's local itinerary; selecting a craft should reveal its own task sequence and route. The fleet view should make branching assignments, resource deliveries, dependencies, expected rendezvous, delays, and attention items understandable.

This operational activity plan is distinct from a reusable preferred route. The Route Planner authors and saves navigation routes; Fleet Manager combines route segments with craft-specific activities, logistics, timing, and rendezvous into an assigned operation. A saved route can be reused by one or more craft, but does not itself prescribe harvesting, market transactions, purchases, or the full fleet work schedule.

#### Space Operations and Planetary Surface Operations

**ESTABLISHED INTENT — 2026-11-21**

Space Fleet Manager is specifically for spacecraft-based Space Operations: asteroid and small-body harvesting, atmospheric gas harvesting by spacecraft/skimmers, orbital and asteroid construction/logistics, spacecraft transport, inter-system travel, and associated rendezvous and resupply. Atmospheric harvesting occurs in a planetary atmosphere but remains a spacecraft operation; it is not a surface activity.

Planetary Surface Operations are a separate operating context and interface. They concern terrain-based activities, surface mining, settlements and facilities, surface vehicles/units, construction, and surface logistics. These activities should not be added to or visually subsumed by the Space Fleet Manager. Shared concepts such as assignments, ordered work, dependencies, resource transfers, autonomous execution, rendezvous, and delayed status may inform both interfaces, but the activity models and UI contexts remain distinct.

The intended gameplay boundary and its open details are documented in [Space and Surface Operations](../player/space_and_surface_operations.md). The Player Surface context is already distinct from Space; a dedicated Surface Operations workspace remains a separate design task and is not part of the current Fleet Manager task.

### Player Route Planner

**ESTABLISHED PLAYER SPACE VIEW DIRECTION — 2026-11-21**

GalaxyGame should provide a distinct Player **Route Planner** where players can create, review, name, save, and reuse preferred travel routes. The supplied Pixel Nexus Chain Map is the initial visual and interaction reference for this capability. The intent is to adapt its Chain Map presentation and useful JavaScript into the Rails 8.1 UI prototype, then adapt its assumptions and behavior to GalaxyGame. It is a starting point for the route-planning interface, not a commitment to Pixel Nexus's network mechanics or data model.

The Route Planner supports both routing scales:
- **Inter-system / wormhole travel:** plan a journey through connected star systems and wormhole transitions, including chosen intermediate systems and preferred connections.
- **In-system travel:** plan movement among relevant locations within a solar system, such as orbital infrastructure, celestial bodies, asteroids, settlements, harvesting sites, and other supported destinations.

A journey may combine the two scales: an inter-system route to a destination system followed by an in-system route to a particular location. The interface should make the scale and transitions clear. The Chain Map's node-and-connection canvas, pan/zoom, node selection, connection editing/selection, route highlighting, and contextual detail panel are useful patterns to inspect and adapt. Do not assume its existing implementation already supports GalaxyGame's two routing scales; inspect the source and document what is actually reusable.

Players should be able to save named preferred routes and later reopen or revise them. A saved route is a reusable plan, not a guarantee that every connection or condition remains available when a craft is assigned to it. Actual route execution and feasibility depend on current network/system conditions and craft capabilities; the prototype must not imply that a saved route overrides those conditions.

Saved routes should be assignable to an individual spacecraft or used by a fleet operation when assigning participating craft. Fleet Manager remains responsible for presenting the operation and its distributed craft; Individual Craft Tracking remains responsible for showing one craft's assigned route and progress. Both may provide an entry point to choose or inspect a saved route, but neither replaces the Route Planner as the route-authoring workspace.

For the initial UI prototype, focus on porting the Chain Map view and adapting its presentation to GalaxyGame's route-planning purpose. Clearly identified mock systems, connections, locations, routes, saved-route records, and assignment interactions are acceptable. The prototype need not implement authoritative pathfinding, route feasibility, live wormhole availability, navigation simulation, persistence, or actual command execution. Do not invent route availability or physics rules; leave those to the authoritative game systems.

### Player feedback on wormhole-network strategy

**OWNER-RECALLED DESIGN DIRECTION — 2026-11-20; interaction details OPEN**

Players should have a way to provide feedback or express strategic preferences that the AI Manager can consider when managing the shared wormhole network. This is an indirect input into AI Manager policy and priorities, not direct control over natural wormholes or AWS infrastructure.

Possible feedback options may cover:
- favoring further network expansion or favoring consolidation of the existing network;
- favoring longer retention of natural wormhole connections for scouting and harvesting, where operationally viable;
- favoring preservation of existing routes or proposing network adjustments/reorganization;
- expressing the relative importance of exploration, settlement access, EM harvesting and market income, or conserving resources for stabilization and infrastructure.

These are preferences and recommendations, not binding commands or guarantees. AI Manager remains responsible for evaluating physical stability and counterbalance, player safety, network-wide effects, resources, costs, and competing priorities. It may follow, defer, modify, or decline a preference based on those conditions. Players should not be presented with controls that imply they can directly order a natural wormhole to snap/shift or force AWS construction.

Who can submit feedback, how it is scoped (individual, corporation, colony, route, or wider network), how conflicting preferences are handled, and how the AI Manager reports its response remain OPEN. Do not assume a voting mechanism or that every player has equal authority over network policy.

## Planetary context

**DIRECTION grounded in existing capability**

Planetary is the whole-body view, inspired by SimEarth. It presents the selected body's conditions and change at global scale: atmosphere, climate, hydrosphere, biosphere, geology, biomes, terrain, and terraforming/environmental progress where supported. Available data and layers depend on the celestial body's type and the sphere data actually modeled for it; the view must not assume that every body has an Earth-like set of active spheres or identical environmental processes.

Existing main-app Monitor/Planetary functionality is substantial and must be inspected, repaired, and evaluated for reuse or adaptation. Do not assume it is specification-only or rebuild it from scratch. The current screenshots show working Earth map/layer behavior, but also a coarse/blurry display; the cause and best data/rendering path remain to be investigated.

Candidate interactions include globe or projected-map pan/zoom, layer selection, selected-region inspection, and environmental data panels. Exact layer availability depends on the authoritative data and services.

### Planetary data source and frontend boundary

**ESTABLISHED PROTOTYPE ARCHITECTURE INTENT — 2026-11-19; clarified 2026-11-19**

The Rails controller is the boundary between the Planetary UI and the source of celestial-body data. The controller requests the selected body (Earth for the initial prototype), obtains its source data, selects the values the UI needs to display, and returns a focused display payload. The frontend consumes that payload; it does not read files, locate bodies in a system definition, or know which source supplied the data.

The initial prototype data path is:

```text
Local copy of StarSim's minimal sol.json
  → lookup the requested body (Earth)
  → Rails controller selects the UI display values
  → focused Planetary data payload
  → frontend JavaScript and UI
```

- Use the uploaded/main-app **minimal `sol.json` sample** as the initial source, not `sol-complete.json` and not a hand-authored Earth fixture. It is a sample of the data StarSim uses to build the Sol system, not the complete Sol dataset. Copy the actual source file into the prototype's corresponding `app/data/star_systems/sol.json` location.
- The lookup only needs to load the Sol sample and find the requested body entry (initially Earth). The source entry is nested under `celestial_bodies` and its relevant body collection. Do not build or load the entire system into the Planetary UI.
- The controller returns only the body values required by the Planetary UI. The UI's display requirements determine that selection; do not pass the entire Sol dataset or make the frontend responsible for filtering the source JSON.
- Keep the controller-to-frontend payload stable and independent of the source. Today the controller obtains the values from local JSON. In the future, that source lookup is replaced by an API request for the requested body; the controller still returns the same display payload, so the Planetary frontend does not need to be rewritten.
- Use only values actually present in the source. Missing values remain unavailable; do not invent or derive replacement values.

**Data-source distinction:** `sol.json` is StarSim's system/body definition input. This prototype task only reads the requested body's existing definition data for display; it does not run StarSim, run a simulation, or build the Sol system. It is not a terrain-map source or live simulation-state feed. Terrain and dynamic simulation values remain separate data concerns and must not be fabricated from this static sample.

No production API endpoint or contract is established by this intent. The required future compatibility is the stable controller-to-frontend display payload, not a general-purpose provider framework.

### Orbital-scale map layers and geographic identification

**ESTABLISHED UI DIRECTION — 2026-11-16**

The Planetary view is an orbital, whole-body observation interface. Its map layers should communicate large-scale natural conditions and the geographic footprint of civilization, rather than reproduce surface-level management or tactical detail.

Retain the established natural-world layer controls:
- Terrain
- Hydrosphere
- Biomes
- Features
- Temperature
- Rainfall
- Resources

Biomes remains an important planetary layer. No separate Life, Biodiversity, Vegetation, or Habitat overlay family is currently required for this view; detailed life and surface activity do not need to become additional orbital controls merely because SimEarth exposed them.

The Planetary interface should also provide a visible place for civilization and technology overlays, including:
- Cities / Settlements
- Population
- Infrastructure
- Industry
- Energy
- Transportation
- Communications

These controls establish the intended scope of the interface. Their presence does not assert that the corresponding data, map rendering, or simulation capability is implemented. Where functionality is not yet available, the prototype may show the controls as disabled or clearly marked as coming later. Do not invent data or imply that an unavailable overlay works.

The existing **Features** layer should support geographic identification when selected. This means rendering names directly on the planetary map, positioned at their corresponding geographic locations, as map-anchored labels—not merely listing feature names in a side panel or presenting a separate catalogue. The SimEarth reference shows labels such as Terra Ishtar, Tethys, Niobe Planitia, Aphrodite Terra, and Lavinia Planitia placed over the terrain. For Earth, examples include major regions such as North America and landmarks such as the Grand Canyon. Comparable labels should be appropriate to the selected celestial body. These labels are geographic map annotations, distinct from civilization/technology overlays.

### Civilization asset markers

Civilization visualization is not limited to broad-area overlays such as population, industry, or infrastructure. The Planetary view should also be able to show the geographic positions of individual constructed assets as map markers. The SimEarth Civilization screenshot supplied on 2026-11-16 illustrates this with a biome factory represented by a small green pixel on the planetary map.

For GalaxyGame, this establishes the visual distinction between:
- **Area overlays**, which communicate broad distributions or networks (such as population, industry, infrastructure, energy, transportation, and communications).
- **Asset markers**, which identify the locations of individual installations or facilities (for example, a biome factory).

The prototype need not implement asset data, marker semantics, or interaction now. This is a future-facing visualization requirement, not a request to add a detailed surface-management view or invent operational data.

These are orbital visualizations for observing the body as a whole. Detailed buildings, individual units, local operations, and settlement management belong in the Surface or Settlement contexts, not the Planetary view.

## Irregular and repurposed body visualization

**OPEN DESIGN CONSIDERATION — 2026-11-15**

The Planetary View should not be treated as the universal whole-body visualization. It is suited to spherical bodies; irregular bodies such as asteroids and small moons may need a different representation. More importantly, an irregular body's intended use can change what needs to be visualized.

### Multiple visualization types — long-term requirement

**OPEN ARCHITECTURE REQUIREMENT — 2026-11-17**

The current Planetary view is suitable for the present prototype and its initial terrestrial-planet-oriented use. It is not a complete, universal visualization solution for every celestial-body type, and the prototype's current renderer must not be treated as the final long-term architecture.

A one-size-fits-all map or globe presentation is unlikely to represent GalaxyGame's full range of celestial bodies accurately. A terrestrial planet, a small spherical moon, and an irregular asteroid do not have interchangeable geometry or necessarily the same useful ways of being inspected. In particular, an asteroid must not be assumed to be round or represented as a scaled-down terrestrial planet when its actual shape is irregular.

The long-term UI may therefore require multiple visualization types or modes, selected according to relevant characteristics such as:
- the body's actual shape and geometry (spherical, approximately spherical, irregular, elongated, or otherwise);
- its scale and physical characteristics;
- the available shape, elevation, terrain, imagery, and other source data;
- the purpose of the inspection, including natural-world observation, surface activity, mining, interior/cutaway inspection, or conversion into infrastructure.

Examples of possible visualization families include a global planetary projection or globe for suitable spherical bodies, and shape-aware 3D or other specialized representations for irregular asteroids and small bodies. These are examples for future investigation, not finalized renderer choices or a requirement to implement them now. Some bodies may need more than one view or mode, especially when their use changes—for example, an asteroid being mined, hollowed, or repurposed as a station.

Keep the distinction between a consistent application workspace and a universal visualization. Shared navigation, contextual information panels, and common interaction conventions may be reused, while the central visualization adapts to the body and task. Do not force all bodies into one fixed canvas geometry, aspect ratio, projection, or renderer merely to make their layouts consistent.

The current prototype may continue using its existing Planetary renderer for its intended scope. This open requirement does not expand the immediate prototype layout task into asteroid rendering, 3D model support, or a redesign of the Digital Twin. It ensures those future needs remain visible in the architecture and are not accidentally ruled out by prototype implementation decisions.

The visualization taxonomy, selection rules, data contracts, renderer boundaries, and relationship to the authoritative Digital Twin remain OPEN. Do not infer that body classification alone determines every view; intended use and available data also matter.

### Asteroid relocation and station construction option

One established deployment concept uses an Asteroid Relocation Tug to prepare and relocate an asteroid shell. The tug's job is not to complete the station:

1. **Hollow and relocate:** The tug excavates the asteroid and uses the excavated slag as propellant to move the body to its destination.
2. **Prepare the shell:** The hollowed void provides usable interior volume. Remaining asteroid material forms the exterior shell and structural mass; processed material may be used to reinforce the interior and provide mounting/support points.
3. **Initial outfitting by the tug:** Once the asteroid is in position, the tug transfers some of its own modules to the shell. This is initial outfitting, not completion of the station.
4. **Cycler arrival and docking:** A cycler subsequently arrives and docks with the positioned asteroid. The cycler can be parked there and used as a temporary station while the asteroid station is built out.
5. **Main station deployment and buildout:** Modules and units are transferred and deployed from the cycler to construct and equip the main station. The cycler provides a temporary operational base and support during this work; it is distinct from the tug and from the completed asteroid station.

The hollowed interior is intended to become useful station volume for units, modules, equipment, and facilities. It may also be large enough for smaller spacecraft to enter and dock, including for maintenance or repair. The exterior surface may have limited activity and may not be the most important operational area.

### Phobos and Deimos deployment alternatives

The original concept for Phobos and Deimos was to convert the moons themselves into station and depot infrastructure. The Mk1 cycler cannot relocate either moon, so the Mars deployment concept was also tuned to provide another option: use Phobos and/or Deimos as mining outposts, then construct separate orbital stations using an approach similar to the Earth–L1 deployment. A future Mk2 cycler could potentially make direct conversion viable while retaining the original concept as an option.

These are deployment options for the AI Manager to evaluate and combine—not mutually exclusive, fixed plans, or a single mandatory sequence. The AI Manager should be able to select, sequence, and mix available approaches according to current technology, vehicle capabilities, resources, infrastructure, and mission circumstances. For example, mining outposts could support construction of a separate station, while a more capable cycler could enable direct moon conversion; different approaches may also be used together where that makes operational sense. The Mk1 limitation explains why an alternative was developed; it does not invalidate or replace the original option. Do not assume that every asteroid or small moon must be hollowed, relocated, or converted into a station, nor that every Mars deployment must use a mining outpost followed by a separate station.

The exact tug-carried modules, shell preparation and reinforcement details, cycler payloads and deployment process, interior layout, docking capacity, ship-size limits, and selection criteria between these options remain matters for the relevant game-domain design.

The UI may ultimately need to distinguish an exterior body, an interior or cutaway, installed modules, mining activity, docking arrangements, and station construction progress. Whether these are separate views, layers, or modes remains OPEN. Do not assume that a conventional surface view adequately represents a hollowed or repurposed irregular body.
## Surface context

**DIRECTION grounded in existing partial implementation**

Surface is the civilization-level view across a celestial body's surface, not merely a terrain viewer or tactical unit-control screen.

It should support:
- terrain, elevation, liquid, biome, climate and resource layers;
- territories and settlements;
- mines, extraction and industrial development;
- infrastructure and transportation networks;
- moving units, exploration, and surface operations;
- inspection of locations and settlement markers.

Existing Surface implementation is partial. Earth has shown a coarse terrain/biome grid and cursor inspection of tile, biome, and elevation, but tile loading/status problems were visible. Mars showed a blank map and JavaScript initialization/tile-loading symptoms. Other worlds have reportedly worked previously and require individual checks. Do not assume all bodies share one failure cause.

## Settlement context

**DIRECTION**

Settlement is the detailed management view for an individual inhabited or developed place. It is SimCity-inspired, but GalaxyGame's settlement model and rules are authoritative.

A Settlement is a physical place where people live or work. It may be a mining outpost, research outpost, industrial settlement, town, city, or another form. A Colony is a government-like entity overseeing multiple settlements; ownership and governance are separate. A player or corporation may own a settlement while it is governed by a Colony.

Settlement management includes structures/facilities, population, services, utilities, construction, production, inventories, logistics, and development. Structures are individual buildings, stations, modules, or facilities within a settlement.

**EARLY EXPLORATION — NPC settlement connections and outside development (2026-11-13; not finalized gameplay)**

The following ideas were discussed as possibilities for how players and corporations might establish an operating presence alongside an autonomous NPC settlement. They are recorded to preserve the discussion, not as approved mechanics or implementation requirements:

- A player or player-owned corporation might lease a connection to an NPC settlement and build its own units connected to the settlement, potentially including warehouses, habitats, industrial units, and other structures.
- The key consideration is whether the settlement's base infrastructure can provide the connection and the services a proposed unit requires, such as power and other necessary utilities. Capacity may need to exist already or be expanded to support the request.
- A possible future alternative is independently supplied infrastructure owned by the player or corporation—for example, a solar farm or fusion plant—which could support its own units and perhaps supply surplus power to others.
- These ideas do not imply ownership of the NPC settlement, control of its population or operations, or authority over the settlement's own infrastructure.

Lease terms, connection and service models, capacity, expansion decisions, NPC approval, costs, utility distribution, and any energy market are all OPEN. Do not treat the examples above as confirmed game rules.

The same broad management concepts should support:
- **Planetary settlements**, located on a planet or moon surface.
- **Orbital settlements**, located in orbit and potentially starting with one station or habitat structure, then expanding with modules, docking, depots, warehouses, shipyards, and other facilities.

Orbital Settlement is the current working term; future taxonomy for free-flying habitats or asteroid settlements remains open. A wormhole station, depot, or space station may be a founding structure, but it does not define the entire settlement.

## Two dashboards and separate operational contexts

The product has two primary dashboards:
- **Player Dashboard** — gameplay and player operations, using the three primary views above plus the separate Space context.
- **Admin Dashboard** — application, simulation, world, data, and operational administration.

The Admin Dashboard contains dedicated workspaces, including AI Manager, Map Studio, StarSim, TerraSim, Digital Twin, and other administrative tools. The responsibility boundaries and unresolved ownership questions for these systems are documented in [Admin and AI Manager Interfaces](03_admin_and_ai_manager.md). AI Manager is an Admin workspace, not a Player view or a separate Player dashboard.
## Shared workspace layout pattern

**ESTABLISHED INTENT — 2026-11-17**

The following describes the agreed two-pane workspace structure for Planetary views (both Admin and Player). It establishes a reusable layout pattern that other GalaxyGame views may adopt where appropriate.

### Persistent navigation

The application has persistent main-game navigation on the far left. This navigation is separate from the individual workspace and persists across all views. It provides global access to major workflows (system catalog, assets, economy, research, etc.) and is not part of any single workspace's internal layout.

### Two-pane workspace structure

Each Planetary workspace uses two primary panes within its content area:

**Left / main pane — Visualization and working canvas**

- Primary visualization or map canvas occupies the upper portion.
- Controls belonging to that visualization are positioned **directly beneath the canvas**, not in the persistent navigation or in the right data panel.
- This lower area accommodates map layers, visualization layer toggles, zoom controls, identification tools, and other context-specific actions for the left-pane visualization.
- All visualization controls remain within this left pane.

**Right pane — Contextual data and supporting information**

- Extends the full height of the workspace alongside the left pane.
- Displays contextual data, body facts, environmental metrics, composition breakdowns, and supporting information relevant to the selected object or active layer.
- Does **not** contain controls belonging to the left-hand visualization.
- Uses a compact, readable information layout (section titles, data rows, progress bars) rather than large interactive elements.

### Planetary application

This structure applies to both **Admin Planetary** and **Player Planetary**. The two interfaces share the structural layout and appropriate visualization capabilities while allowing differences in:

- Available actions and permissions (admin controls vs. player observation).
- Operational versus observational information density.
- Admin-only functionality (terrain regeneration, property editing) — these must not appear in Player views.
- Data presentation depth appropriate to each audience.

### Reuse as a workspace pattern

This two-pane structure is documented as a **potential reusable workspace pattern** for other GalaxyGame views. It is not mandated for every view; different views may need different arrangements (tables, dashboards, multi-panel layouts). However, any view that combines a primary visualization with supporting data should consider this pattern:

1. Persistent global navigation on the far left (separate from workspace).
2. Left pane: visualization canvas + its controls beneath the canvas.
3. Right pane: full-height contextual data panel (no visualization controls).

### Important boundaries

Do not confuse these distinct areas:

- **Persistent main-game navigation** — global, persistent, separate from any workspace.
- **Workspace visualization controls** — belong beneath the canvas in the left pane.
- **Contextual data panels** — right pane only; informational, not interactive for visualization.
- **Admin-only actions** — must be clearly separated from Player controls and never appear in Player views.

A known deviation: the existing Admin Planetary implementation currently places some map controls in the left navigation area. That is **not** the intended final arrangement. Map controls belong underneath the canvas in the left pane, within the workspace content area.
See [Admin and AI Manager Interfaces](03_admin_and_ai_manager.md).

## Existing architecture references

| Document | Relationship |
|---|---|
| `docs/architecture/three_layer_views.md` | Existing Planetary/Surface/Settlement implementation architecture and rendering details; this page is the current Player-context design authority where they conflict. |
| [Branding and Entry Experience](01_branding_and_entry_experience.md) | Shared visual identity and entry experience. |
| [Admin and AI Manager Interfaces](03_admin_and_ai_manager.md) | Admin responsibilities and AI Manager workspace. |
| [Current UI State and Known Issues](04_current_ui_state_and_known_issues.md) | Dated screenshot observations and implementation status. |

## Open details

- Final layouts and navigation placement for each context.
- Exact Space map scales and relationship between in-system and inter-system maps.
- Planetary layer availability by body and data source.
- Surface tileset/rendering repair and the best source-resolution pipeline.
- Detailed Settlement workflows and the distinction between planetary and orbital settlement variants.
- Which existing JavaScript and services should be adapted, replaced, or exposed through an API.

Do not convert these open details into implementation assumptions without review.
