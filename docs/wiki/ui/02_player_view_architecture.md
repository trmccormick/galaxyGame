> **Wiki section:** UI & Experience · **Status:** Established intent for view boundaries and navigation principles; detailed layouts remain DIRECTION or OPEN  
> **Last Updated:** 2026-11-15

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

## Space context

**DIRECTION**

Space is the system-wide operational view. It should represent the selected solar system and the physical relationships among bodies, ships, stations, and other orbital infrastructure.

Candidate content includes:
- ships at current locations, in transit, or assigned to destinations and missions;
- orbital settlements and infrastructure, including L1 depots, orbital stations, shipyards, wormhole stations, and industrial platforms;
- trajectories, travel distances, launch windows, and estimated travel times where supported by simulation data;
- natural wormholes, AWS connections, portals, EM fields, and relevant space phenomena.

The view must distinguish inter-system wormhole network connections from in-system spatial relationships. EVE Dashboard's map interactions may inform pan/zoom, selection, routes, markers, and topology presentation, but its EVE-specific mechanics and inter-system map are not a substitute for a literal solar-system view. Existing GalaxyGame `system_renderer.js` is an early baseline to inspect, not a finalized design.

## Planetary context

**DIRECTION grounded in existing capability**

Planetary is the whole-body view, inspired by SimEarth. It presents the selected body's conditions and change at global scale: atmosphere, climate, hydrosphere, biosphere, geology, biomes, terrain, and terraforming/environmental progress where supported. Available data and layers depend on the celestial body's type and the sphere data actually modeled for it; the view must not assume that every body has an Earth-like set of active spheres or identical environmental processes.

Existing main-app Monitor/Planetary functionality is substantial and must be inspected, repaired, and evaluated for reuse or adaptation. Do not assume it is specification-only or rebuild it from scratch. The current screenshots show working Earth map/layer behavior, but also a coarse/blurry display; the cause and best data/rendering path remain to be investigated.

Candidate interactions include globe or projected-map pan/zoom, layer selection, selected-region inspection, and environmental data panels. Exact layer availability depends on the authoritative data and services.

## Irregular and repurposed body visualization

**OPEN DESIGN CONSIDERATION — 2026-11-15**

The Planetary View should not be treated as the universal whole-body visualization. It is suited to spherical bodies; irregular bodies such as asteroids may need a different representation. More importantly, an irregular body's intended use can change what needs to be visualized.

The asteroid tug's job is to prepare and relocate the asteroid shell, not to complete the station. The intended sequence is:

1. **Hollow and relocate:** The tug excavates the asteroid and uses the excavated slag as propellant to move the body to its destination.
2. **Prepare the shell:** The hollowed void provides usable interior volume. Remaining asteroid material forms the exterior shell and structural mass; processed material may be used to reinforce the interior and provide mounting/support points.
3. **Initial outfitting by the tug:** Once the asteroid is in position, the tug transfers some of its own modules to the shell. This is initial outfitting, not completion of the station.
4. **Cycler arrival and docking:** Cyclers subsequently arrive and dock with the positioned asteroid.
5. **Main station deployment:** The cyclers begin deploying the main station parts and modules. This is the primary station-construction stage, distinct from the tug's shell preparation and initial module transfer.

The hollowed interior is intended to become useful station volume for units, modules, equipment, and facilities. It may also be large enough for smaller spacecraft to enter and dock, including for maintenance or repair. The exterior surface may have limited activity and may not be the most important operational area.

This is a possible conversion into a protected, hollowed station or habitat, not a requirement that every asteroid be converted this way. The exact tug-carried modules, shell preparation and reinforcement details, cycler payloads and deployment process, interior layout, docking capacity, and ship-size limits remain matters for the relevant game-domain design.

The UI may ultimately need to distinguish the exterior shell, interior or cutaway, tug-installed initial modules, and the main station components deployed by cyclers. Whether these are separate views, layers, or modes remains OPEN. Do not assume that a conventional surface view adequately represents a hollowed asteroid.

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
