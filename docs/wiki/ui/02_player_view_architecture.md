> **Wiki section:** UI & Experience · **Status:** ESTABLISHED INTENT for the view split and navigation principles; remaining details DIRECTION or OPEN, clearly marked  
> **Last Updated:** 2026-11-09

# Player View Architecture

This page records the clarified player-view design intent for Galaxy Game. It defines five distinct player-facing views, their purposes, interaction models, and boundaries. It is not an implementation specification; it is design intent that guides future implementation tasks.

Labels on this page follow the [UI & Experience](README.md) convention: **ESTABLISHED INTENT** (owner-confirmed, dated), **DIRECTION** (current working direction, not yet confirmed), and **OPEN** (unresolved).

---

## Design Authority

**ESTABLISHED INTENT — 2026-11-04**

UI design intent lives in the main `galaxyGame` repository under `docs/wiki/ui/`. The `galaxy-game-ui` prototype repository is an implementation workspace; its appearance does not independently establish approved product design. Implementation tasks should reference this page and focus on specific work and acceptance criteria. See [UI & Experience](README.md) and [Branding and entry experience](01_branding_and_entry_experience.md).

---

## Five Player Views

**ESTABLISHED INTENT — 2026-11-09** (owner decision made a few days earlier; recorded on this date)

Galaxy Game has **five distinct player views**, each with a different purpose and interaction model. These are not nested menus or zoom levels — they are separate interfaces for different scopes of play.

| View | Design Reference | Purpose | Interaction Model |
|------|-----------------|---------|-------------------|
| [Planetary](#planetary-view) | SimEarth | Global planetary conditions overview | Globe/2D map rotation and pan; click to drill down |
| [Surface](#surface-view) | Civilization IV / FreeCiv | Operational map: terrain, resources, settlements, mines, mobile units, movement, exploration, surface activity | Tile-based tactical map with layer toggles, unit orders, improvement placement |
| [Settlement](#settlement-view) | SimCity | Management of an individual settlement: infrastructure, construction, production, logistics | Building-placement interface with operational parameters, pipeline/road connections, yield management |
| [Space](#space-view) | EVE Dashboard (initial reference only) | Orbital and interplanetary operations | TBD — separate from Surface; different interaction model |
| [Galaxy](#galaxy-view) | TBD | Interstellar navigation and wormhole-network view | TBD — separate from Space |

**Important:** Names are working names. They may change as design matures. The distinction between these five views is established; the details within each view are DIRECTION or OPEN where marked.

### Celestial-Body Views (carried forward)

**DIRECTION — details carried forward from prior architecture work** (their place in the five-view split is established, above)

The three celestial-body views (Planetary, Surface, Settlement) come from the earlier architecture specification in [`docs/architecture/three_layer_views.md`](../../architecture/three_layer_views.md), written by an implementation agent in July 2026. That document calls the Settlement view *TerrainForge*; this page uses "Settlement View" as the working name for the same view. They cover the zoom hierarchy for exploring and operating on individual celestial bodies:

```
Planetary View (global overview)
  └─ Click region / drill down
       ↓
Surface View (tactical map of a region)
   └─ Double-click settlement tile / enter button
        ↓
    Settlement View (detail of one settlement tile)
```

This page adds context about how these three fit into the broader player-view architecture and introduces the two additional views (Space, Galaxy).

---

## View Details

### Planetary View

**Working name.** SimEarth-inspired global planetary conditions overview.

**Purpose:** See an entire celestial body at macro scale — atmospheric layers, cloud formations, weather systems, biome distribution, terraforming progress monitoring.

**Interaction model:** Globe rotation and pan (3D) or 2D flattened projection with pan/zoom. Click a region to drill down to Surface View.

**Scope boundaries:**
- **IN SCOPE:** Atmospheric data visualization, biome heatmap, elevation projection, cloud formations, weather systems, terraforming progress overlay.
- **OUT OF SCOPE:** Settlement-level detail (tiles, improvements, units, settlement markers). No terrain_data fields specific to Planetary View beyond shared data.

**Data source:** `celestial_body.atmosphere_layers`, `terrain_data.biomes`, `planet_data.weather_grid`, `planet_data.clouds`, `terrain_data.elevation` (full grid). See `docs/architecture/three_layer_views.md` for the full data contract.

**Implementation state:** Specification only, per `docs/architecture/three_layer_views.md`.

### Surface View

**Working name.** Civilization IV / FreeCiv-inspired operational map.

**Purpose:** Tactical-level surface operations — terrain display, resource/improvement overlay, unit movement and orders, city/yield management, layer toggles for clarity.

**Interaction model:** Tile-based tactical map with pan/zoom, layer toggles (terrain, liquid, biomes, resources, civilization, units), unit order commands, improvement placement.

**Operator and player contexts:** The same map rendering can serve operator (AI planning) and player (unit orders) contexts, with different overlays. This does not merge the interfaces: access is enforced server-side, and the Admin Console remains a separate interface from the player views.

**Scope boundaries:**
- **IN SCOPE:** Terrain rendering (elevation, liquid, biomes, resources), civilization overlay (spaceports, bases, roads, worldhouse panels), mobile unit movement and orders, settlement tile markers, yield management per tile.
- **OUT OF SCOPE:** Individual building configuration (that is Settlement View). Global atmospheric data (that is Planetary View).

**Implementation state:** Partially implemented in `galaxy_game/app/assets/javascripts/surface_view.js`. See `docs/architecture/three_layer_views.md` for the full architecture spec, rendering pipeline, and layer system.

### Settlement View

**Working name.** SimCity-inspired individual settlement management. Called *TerrainForge* in `docs/architecture/three_layer_views.md`.

**Purpose:** Detailed management of a single settlement — infrastructure planning, building placement and configuration, production scheduling, logistics routing, population/morale tracking.

**Interaction model:** Building-placement interface at readable scale. Click a building to configure operational parameters (production rate, staffing, inventory). Drag-place new structures. Connect pipelines/roads between buildings. View yield management per building.

**Scope boundaries:**
- **IN SCOPE:** Individual building configuration, production scheduling, logistics routing within the settlement, population/morale metrics, infrastructure planning (power, life support, water).
- **OUT OF SCOPE:** Multi-settlement operations (that is Surface View). Global planetary data (that is Planetary View). Interstellar navigation (that is Galaxy View).

**Architecture note:** Per the architecture spec, Settlement View shares the same rendering pipeline as Surface View. It is `surface_view.js` with the camera zoomed 10-100x on a single settlement tile. Same sprites, same layer system, different camera state. See `docs/architecture/three_layer_views.md`.

**Implementation state:** Specification only — not yet implemented, per `docs/architecture/three_layer_views.md`.

### Space View

**Working name.** Separate view with a different interaction model from Surface.

**Purpose:** Orbital and interplanetary operations — station management, orbital logistics, atmospheric harvesting, fleet coordination, space-based construction.

**Interaction model:** **TBD** — separate from Surface; different interaction model. EVE Dashboard is an initial interface reference only, not an EVE Online game or mechanics specification.

**Scope boundaries:**
- **IN SCOPE:** Orbital station management, interplanetary fleet operations, atmospheric harvesting coordination, space-based construction planning.
- **OUT OF SCOPE:** Surface operations (that is Surface View). Interstellar navigation (that is Galaxy View). Individual settlement management (that is Settlement View).

**OPEN:**
- Detailed interaction model and scope boundaries require further design work.
- Relationship to Surface View (how players transition between them) is unresolved.
- Whether Space View is a single unified interface or multiple sub-views is unresolved.

### Galaxy View

**Working name.** Interstellar navigation and wormhole-network view.

**Purpose:** Interstellar travel planning, wormhole network management, galaxy-scale overview of settled systems, inter-system logistics coordination.

**Interaction model:** **TBD** — separate from Space. Wormhole-based navigation between star systems.

**Scope boundaries:**
- **IN SCOPE:** Wormhole network visualization and management, inter-system travel planning, galaxy-scale settlement distribution overview, inter-system logistics coordination.
- **OUT OF SCOPE:** Intra-system navigation (that is Surface/Space View). Individual planetary data (that is Planetary View). Settlement-level detail (that is Settlement View).

**OPEN:**
- Detailed interaction model and scope boundaries require further design work.
- Whether wormholes are the sole interstellar travel method or one of several is unresolved.
- Relationship to Space View (how players transition between them) is unresolved.
- Whether Galaxy View includes galaxy-scale resource/market data is unresolved.

---

## Navigation Between Views

### Navigation Principles

**ESTABLISHED INTENT — 2026-11-09** (owner decision made a few days earlier; recorded on this date)

These principles describe how players should be able to reach things. They are not a fixed layout: the arrangement of primary navigation, secondary navigation, and detail areas is **OPEN**, and the terms below are illustrative.

1. **Primary navigation gives direct access to major features.** Players should reach Systems, Settlements, and Trade directly, without navigating through Galaxies first. Galaxies are metadata, not a navigation requirement.

2. **Secondary navigation organizes workflows within a feature.** It changes contextually based on the active primary section.

3. **Contextual content presents details and actions for the selected object.** A detail area shows object-specific data with relevant actions.

4. **Do not translate database hierarchy into menus.** A Star System belonging to a Galaxy does not mean players must navigate through Galaxies to reach Star Systems.

### View Transition Matrix

**DIRECTION — 2026-11-09**

| From | To | Transition Method |
|------|-----|-------------------|
| Planetary | Surface | Click region / drill-down button |
| Surface | Settlement | Double-click settlement tile / enter button |
| Settlement | Surface | Close / ESC / zoom out / back button |
| Surface | Planetary | Zoom out to full globe / back button |
| Any | Space | Global nav link (scope TBD) |
| Any | Galaxy | Global nav link (scope TBD) |

**OPEN:** Transition methods for Space and Galaxy views are unresolved.

---

## Relationship to Existing Documentation

| Document | Relationship |
|----------|-------------|
| [`docs/architecture/three_layer_views.md`](../../architecture/three_layer_views.md) | Architecture spec for the Planetary → Surface → Settlement (TerrainForge) zoom hierarchy. This page supersedes it as the **player-view design authority**; the architecture doc remains valid for implementation details (rendering pipeline, data flow, layer system). |
| [`docs/wiki/ui/01_branding_and_entry_experience.md`](01_branding_and_entry_experience.md) | Branding and entry experience. Complementary — this page covers view structure and navigation; the branding page covers visual identity. |
| [`docs/wiki/player/first_hour_and_entry_state.md`](../player/first_hour_and_entry_state.md) | Player entry state. Complementary — describes what players see at entry (dashboard, active starts); this page defines the broader view architecture they navigate between. |
| [`docs/wiki/player/settlement_progression_and_footholds.md`](../player/settlement_progression_and_footholds.md) | Settlement mechanics. Complementary — describes settlement evolution stages; this page defines the UI view for managing settlements. |
| [`docs/wiki/player/player_roles_and_alignment.md`](../player/player_roles_and_alignment.md) | Faction standing model. Deferred — unimplemented, overly complex for MVP. Not addressed by this page. |

---

## Open Questions

| Question | Notes | Priority |
|----------|-------|----------|
| Space View interaction model | TBD — separate from Surface; different interaction model | HIGH |
| Galaxy View interaction model | TBD — separate from Space | HIGH |
| Space ↔ Surface transition | How players move between these views is unresolved | MEDIUM |
| Space ↔ Galaxy transition | How players move between these views is unresolved | MEDIUM |
| Whether Space and Galaxy are unified or split | Single interface vs. multiple sub-views is unresolved | MEDIUM |
| Wormhole travel mechanics in Galaxy View | Whether wormholes are the sole interstellar method is unresolved | LOW |
| Galaxy View resource/market data scope | Whether it includes galaxy-scale economic data is unresolved | LOW |
| Working names may change | All five view names are working names and may be revised | N/A |

---

## Change History

- **2026-11-09** — Created this page to clarify the five-player-view architecture. Introduced Space and Galaxy as separate views with TBD interaction models. Marked all unresolved questions explicitly.
- **2026-11-09** — Revised after review: fixed the `three_layer_views.md` link path; dated the five-view split and navigation principles as ESTABLISHED INTENT (owner decision made a few days earlier, recorded 2026-11-09) and kept layout, view-internal details, and transitions as DIRECTION or OPEN; clarified that Surface View's shared rendering does not merge operator and player interfaces; added implementation-state lines for Planetary and Settlement; noted that Settlement View is TerrainForge in the architecture spec.
