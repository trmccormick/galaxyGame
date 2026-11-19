---
title: Admin Celestial Body View
category: UI & Experience
status: DESIGN INTENT with current Rails 7 implementation snapshot
last_updated: 2026-11-15
---

# Admin Celestial Body View

This page records the intended Admin workspace for inspecting an individual celestial body, alongside a separately dated snapshot of the legacy Rails 7 implementation. These are deliberately distinct: the current main application is evidence of existing behavior and reusable work, not the final design specification for the UI being developed and ported.

## 1. Intended purpose and boundaries

**ESTABLISHED INTENT — 2026-11-15**

The **Admin Celestial Body View** is an Admin workspace for selecting and inspecting a celestial body and understanding its terrain, geology, environmental spheres, and related data. "Celestial body" is intentional: the workspace must cover planets, moons, asteroids, and other supported bodies rather than assuming every target is a planet.

The workspace belongs to the **Admin Dashboard**. It is not the Player's Planetary view, and it is not the AI Manager workspace. Its purpose is administrative inspection and understanding of the selected body's state and available data.

The view should make useful existing map, layer, sphere-data, geological, and inspection capabilities accessible through a coherent interface. The exact composition, panel arrangement, layer inventory, and interactions should be refined as the view is ported and reviewed in the UI prototype.

**Boundaries**

- Display and inspect authoritative body data; do not duplicate terrain generation, environmental simulation, or persistence logic in the UI.
- Map Studio is responsible for preparing or generating initial terrain/geographic data. The Celestial Body View may inspect that output but does not replace Map Studio.
- TerraSim is responsible for environmental simulation and projection. The view may present its results but is not the simulation engine.
- Digital Twin is a broader Admin/developer workspace for inspecting, comparing, evaluating, and tuning environmental simulations. Do not silently collapse Digital Twin into this body-inspection view.
- AI Manager owns autonomous operational decisions. This view may expose relevant operational context, but it is not the AI Manager.
- Do not assume unrestricted terrain editing, terraforming, simulation-speed control, or "god mode" controls belong here. Such authority requires a separate explicit design decision.

 
### Data quality, observations, and refinement visibility — DIRECTION

The Admin inspection workspace should make it possible to distinguish original/generated properties, values calculated from known inputs, survey observations, inferred estimates, and currently accepted body properties. Where the underlying data supports it, expose source/provenance, observation or calculation context, confidence/uncertainty, and unresolved conflicts. Do not present preliminary generated values as surveyed facts or hide conflicting evidence. The exact fields and presentation remain open until the data model and survey/calibration pipeline are inspected.

The view displays and helps administrators inspect this information; it does not independently perform scientific calibration, rewrite the StarSim generation seed, or replace the responsible game service.

See [Admin Dashboard and AI Manager](03_admin_and_ai_manager.md) for the wider Admin workspace boundaries and [Current UI State and Known Issues](04_current_ui_state_and_known_issues.md) for dated observations of existing screens.


### Map Studio and external map examples

**ESTABLISHED OWNER INTENT — 2026-11-15**

Map Studio remains the Admin capability for preparing, generating, reconstructing, and inspecting initial terrain/geographic data for a celestial body. External maps and scenarios from other games or fictional settings may inform GalaxyGame's existing AI-assisted learning and world-generation capabilities, but they are **examples and references—not playable maps to import directly into GalaxyGame**.

Their useful content may include terrain and biome patterns, resource distributions, candidate settlement locations, environmental arrangements, and designer explanations of hypothetical worlds or terraforming outcomes. These are not authoritative facts about the represented body. Real planetary observations should be used where available; simulation should evaluate proposed configurations and produce separate outcome evidence.

A map depicting a terraformed world does not establish that the corresponding GalaxyGame body should be terraformed. In particular, Titan's external game-map example must not be treated as a terraforming target or as a desired future state. Generation and administrative workflows must preserve the distinction between a body's natural/current representation and an explicitly requested hypothetical intervention.

The existing ingestion, training, and generator implementation is incomplete and must be audited before prescribing changes. This clarification records the intended use of examples; it does not assert that the current pipeline already preserves provenance, understands scenario descriptions, or passes learned options through to generation.

## 2. Naming and legacy navigation

**ESTABLISHED INTENT — 2026-11-15**

- **Celestial Body View** is the intended product/workspace name.
- **Monitor** is the name of a legacy route and a small current navigation/status entry page; it is not the intended name of the rich body-inspection workspace.
- **Planetary View** is the current legacy navigation label for the richer map-and-sphere-data page. It is too narrow for a workspace that must support moons, asteroids, and other celestial bodies. The intended UI label is **Celestial Body View**.

Do not rename legacy routes, controller actions, JavaScript modules, or spec filenames merely to make them match the product name during a focused bug fix. Treat those as implementation details and migrate them deliberately when the UI and routing work is planned.

## 3. Porting and future UI direction

**ESTABLISHED DIRECTION — 2026-11-15**

The main Rails 7 application contains existing behavior and views that should be assessed and reused where valuable. The separate Rails 8 UI prototype is the intended presentation workspace for the evolving interface. As views are ported, the objective is to move toward the approved GalaxyGame UI design—not to reproduce every legacy page, layout, label, or interaction unchanged.

For this view, porting should:

1. Preserve useful, verified behavior and meaningful data already provided by the main application.
2. Rework information hierarchy, navigation, layout, typography, and interactions to fit the intended Admin workspace and shared product design.
3. Use the product term **Celestial Body View** in the intended UI, while documenting legacy route and source names where needed for integration.
4. Keep the main application authoritative for domain state, simulation, calculations, validation, persistence, and authorization. The prototype must not create competing game logic.
5. Use explicit game-oriented API contracts when integration is implemented. Mock data may support UI design, but it must be identified as mock data.
6. Review the ported view with the owner before treating its layout and interactions as established design.

The UI prototype's current implementation is not automatically approved design. The wiki records intent; the main repository records legacy implementation; the prototype is where the intended experience is shaped and reviewed.

## 4. Current Rails 7 implementation snapshot

**CODE-VERIFIED SNAPSHOT — 2026-11-15**  
Inspected main-app commit: `a75edb6a2f443f62f4a3c1f208cca2cd7f916ff5`.

The current route/page chain distinguishes the legacy Monitor entry from the richer workspace:

1. The celestial-body catalog links to the legacy **Monitor** route at `/admin/celestial_bodies/:id/monitor`.
2. That Monitor page is a compact navigation/status hub. It links to the richer **Planetary View**, Surface View, and Edit Properties.
3. The map-and-sphere-data workspace is served by `Admin::CelestialBodiesController#planetary` at `/admin/celestial_bodies/:id/planetary`.
4. Its current template is `app/views/admin/celestial_bodies/planetary.html.erb`.
5. Its JavaScript is `app/javascript/admin/monitor.js`; the legacy filename does not define the intended product name.
6. The focused feature spec is `spec/features/admin/planetary_monitor_spec.rb`.

The planetary action loads the selected body, geological features, sphere data, AI mission information, and a sphere-presence summary. The view serializes initial body/terrain information into `#monitor-data`. The JavaScript initializes the canvas/layers/controls and polls `GET /admin/celestial_bodies/:id/sphere_data` every five seconds. The controller also exposes mission-log and AI-test endpoints. These are implementation observations, not a complete or approved future interaction specification.

### Existing lifecycle issue under investigation

The legacy workspace has exhibited intermittent blank first renders and sidebar values associated with a previously viewed body during navigation/reload. The inspected JavaScript has module-level state, a module-level initialization guard, Turbo load initialization, and a polling interval. At the inspected commit, there is no `turbo:before-cache` cleanup handler or protection visible for a polling response already in flight during navigation.

These source observations do not prove the root cause. Browser/network reproduction and request/response identity tracing are required. See the active draft task in `agent-tasks/projects/galaxy_game/tasks/drafts/` for the focused regression investigation. A separate earlier terrain-rendering issue caused by returning early when a body lacked a biosphere was corrected; do not conflate that fix with the remaining lifecycle issue.

The current feature spec covers initial canvas presence and selected data/configuration cases, but the inspected examples do not establish reliable repeated Turbo navigation, stale in-flight response handling, or browser-level first-render behavior.

## 5. Historical documentation conflicts

The retired developer documents are harvest sources, not current design authority. In particular, `docs/developer/ADMIN_MONITORING.md` describes a three-panel AI Mission Control interface and a legacy `/monitor` route. That description does not match the current route/page chain verified above: the current Monitor page is a small navigation/status hub, while the richer map-and-sphere workspace is the Planetary route.

Other retired UI documents contain proposed terraforming controls, time controls, and layouts that have not been established as current intent. Do not carry those proposals into the future Celestial Body View without owner review. Preserve the conflict as historical context; do not silently reinterpret the old three-panel description as the approved future layout.

The retired developer documents remain untouched. Harvest and conflict status are tracked in [Migration Log](../migration-log.md).

## 6. Open design questions

- Which sphere, geological, terrain, resource, and infrastructure details should be visible by default, and which belong in secondary panels or layers?
- Which inspection and administrative actions are authorized in this workspace, versus Map Studio, Digital Twin, TerraSim configuration, or other Admin tools?
- Which existing Rails 7 capabilities are verified and worth carrying forward, and which need redesign or replacement?
- What API resources and update cadence should supply the view once the Rails 8 prototype is integrated?
- How should the Celestial Body View relate to separate Orbital, Surface, and Digital Twin workspaces without duplicating their responsibilities?

Resolve these questions through view design and owner review. Do not infer answers from legacy code or retired proposals.

## Change history

- **2026-11-15** — Established Celestial Body View as the intended Admin workspace name; distinguished design intent, legacy Rails 7 route/page behavior, and future UI porting direction. Recorded the legacy Monitor/Planetary naming mismatch and lifecycle investigation separately.
