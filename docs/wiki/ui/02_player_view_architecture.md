> **Wiki section:** UI & Experience · **Status:** Established intent for view boundaries and navigation principles; detailed layouts remain DIRECTION or OPEN  
> **Last Updated:** 2026-11-13

# Player View Architecture

This page defines the Player Dashboard's four distinct contexts and how players navigate between systems and locations. It is not an implementation specification. The Player Dashboard is separate from the Admin Dashboard; administrative screens and operational tools are not player views.

## Design authority

The main `galaxyGame` repository is authoritative for product design intent and game-domain rules. The separate `galaxy-game-ui` repository is the presentation prototype and implementation workspace. Prototype appearance does not independently establish approved product design.

## Four Player contexts

**ESTABLISHED INTENT — 2026-11-13**

The Player Dashboard has exactly four primary contexts:

| Context | Purpose | Scope |
|---|---|---|
| **Space** | System-wide space operations and spatial awareness | Ships, trajectories, destinations, missions, orbital infrastructure, stations, depots, shipyards, wormholes, EM fields and space phenomena |
| **Planetary** | Whole-celestial-body conditions and change | Atmosphere, climate, hydrosphere, biosphere, geology, planetary-scale resources and environmental change |
| **Surface** | Civilization-level activity across a celestial body's surface | Territories, settlements, resource development, infrastructure, transportation, moving units and surface operations |
| **Settlement** | Management of one inhabited/developed settlement | Buildings and structures, population, services, utilities, production, inventory, logistics and development |

These are distinct interaction contexts, not nested menus or merely camera zoom levels. Navigation may move between related contexts, but each has its own purpose and information hierarchy.

**Space is separate from the three celestial-body contexts.** The three celestial-body contexts are exactly Planetary, Surface, and Settlement. Do not replace Settlement with Space or add Galaxy as a fifth Player view.

## Navigation and selection workspaces

Galaxy/system catalogs and system workspaces are navigation and selection tools, not additional Player views.

A player should be able to:
1. Browse and search galaxies or star systems through compact catalogs.
2. Select a system and inspect it as a whole.
3. Select a celestial body or orbital location.
4. Open the appropriate Player context: Space, Planetary, Surface, or Settlement.

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

Planetary is the whole-body view, inspired by SimEarth. It presents planetary conditions and change at global scale: atmosphere, climate, hydrosphere, biosphere, geology, biomes, terrain, and terraforming/environmental progress where supported.

Existing main-app Monitor/Planetary functionality is substantial and must be inspected, repaired, and evaluated for reuse or adaptation. Do not assume it is specification-only or rebuild it from scratch. The current screenshots show working Earth map/layer behavior, but also a coarse/blurry display; the cause and best data/rendering path remain to be investigated.

Candidate interactions include globe or projected-map pan/zoom, layer selection, selected-region inspection, and environmental data panels. Exact layer availability depends on the authoritative data and services.

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

The same broad management concepts should support:
- **Planetary settlements**, located on a planet or moon surface.
- **Orbital settlements**, located in orbit and potentially starting with one station or habitat structure, then expanding with modules, docking, depots, warehouses, shipyards, and other facilities.

Orbital Settlement is the current working term; future taxonomy for free-flying habitats or asteroid settlements remains open. A wormhole station, depot, or space station may be a founding structure, but it does not define the entire settlement.

## Three application responsibilities

The product has two primary dashboards:
- **Player Dashboard** — gameplay and player operations, using the four contexts above.
- **Admin Dashboard** — application, simulation, world, data, and operational administration.

The Admin Dashboard contains dedicated workspaces, including AI Manager, Map Studio, StarSim, TerraSim, Spawning System, and other administrative tools. AI Manager has a distinct operational workflow and may use a dedicated workspace layout, but it belongs within the Admin Dashboard. It is not a fifth Player context or a separate Player dashboard.

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
