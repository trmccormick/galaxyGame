---
title: Admin Planetary Monitor
category: UI & Experience
status: PARTIALLY IMPLEMENTED — current implementation snapshot; lifecycle behavior under investigation
last_updated: 2026-11-15
---

# Admin Planetary Monitor

> **Code alignment:** Current implementation inspected at commit `a75edb6a2f443f62f4a3c1f208cca2cd7f916ff5` (2026-11-15). This snapshot records observed code, not a claim that every legacy feature description is implemented or working.

## Purpose and boundary

The Admin Planetary Monitor is an administrative workspace for inspecting a selected celestial body's terrain visualization and environmental sphere data. It belongs to the Admin Dashboard; it is not a Player planetary view.

The broader Admin/AI Manager responsibilities and workspace boundaries are recorded in [Admin Dashboard and AI Manager](03_admin_and_ai_manager.md).

## Monitor capabilities

The existing planetary page combines:

- A canvas-based planetary terrain map.
- Selectable visualization layers, including terrain, hydrosphere/liquid, biomes, geological features, temperature, rainfall, and resources where corresponding data is available.
- Celestial-body environmental information organized by sphere (atmosphere, hydrosphere, geosphere, and biosphere).
- Administrative/AI test controls and an activity console in the existing view.

This is an inventory of the current page and historical monitor documentation, not approval to expand the monitor into a general simulation-control or unrestricted world-editing interface. Any additional operational authority must be established separately.

## Data flow and endpoints

### Initial page load

1. `Admin::CelestialBodiesController#planetary` loads the selected body, geological features, sphere data, AI mission information, and a sphere-presence summary.
2. `app/views/admin/celestial_bodies/planetary.html.erb` serializes the initial body and terrain information into the `#monitor-data` JSON script element.
3. `app/javascript/admin/monitor.js` reads that element and initializes the canvas, layers, controls, and polling.

The page's initial terrain map comes from the selected body's geosphere terrain map. The monitor displays and interprets this data; it is not the authoritative terrain-generation or terrain-storage system.

### Live sphere-data polling

The current JavaScript starts a five-second interval and requests:

- `GET /admin/celestial_bodies/:id/sphere_data`

The controller response includes atmosphere, hydrosphere, geosphere, biosphere, planet information, and the body's geosphere terrain map. The JavaScript updates the corresponding sidebar values and re-renders terrain when the returned terrain data differs from its current in-memory data.

Other controller endpoints present in the current implementation include:

- `GET /admin/celestial_bodies/:id/mission_log` — returns mission activity information.
- `POST /admin/celestial_bodies/:id/run_ai_test` — invokes a selected administrative AI test and returns its result.

These endpoints are separate from the five-second sphere-data polling path.

## Turbo and JavaScript lifecycle

**Code-verified implementation snapshot — 2026-11-15**

- The monitor module keeps body identity, terrain, layer, viewport, initialization, and polling state in module-level variables.
- When Turbo is present, the script registers `AdminMonitor.init` on `turbo:load`; otherwise it uses `DOMContentLoaded`.
- `init()` uses a module-level `initialized` guard to skip subsequent initialization calls.
- The polling interval is cleared when polling is restarted and is also cleared by a `beforeunload` handler.
- The current source does not register a `turbo:before-cache` cleanup handler and does not show cancellation or response-identity protection for a polling request already in flight when navigation occurs.

These are observations about the inspected source, not a diagnosis of the reported regression. The interaction among Turbo navigation, module state, interval cleanup, initialization, and outstanding fetch responses requires browser-level verification. See the active Admin Planetary monitor lifecycle task for the focused investigation.

## Known issue under investigation

The Admin Planetary view has exhibited intermittent blank first renders and, during navigation/reload, sidebar values that appear to belong to a previously viewed celestial body. A separate terrain-rendering regression caused by returning early when a body lacked a biosphere was corrected by removing that early return.

The remaining cross-navigation behavior is not yet attributed to a confirmed root cause. Do not assume that interval cleanup alone is sufficient, or that the lifecycle hypothesis is proven. The active task should establish the actual event sequence and request/response behavior before changing code.

## Verification coverage

The repository contains a feature spec at `galaxy_game/spec/features/admin/planetary_monitor_spec.rb` covering initial canvas presence, injected monitor data, terrain-data absence, and selected sphere configurations. The inspected examples do not by themselves establish correct behavior across repeated Turbo visits, stale in-flight responses, or real-browser first-visit/reload timing. Add focused lifecycle coverage as part of the active fix where practical.

## Historical source harvest and limits

The retired `docs/developer/ADMIN_MONITORING.md` was used as a harvest source for the monitor's purpose, panel/capability inventory, endpoint map, polling description, and testing context. Its sample JSON payloads, color palette, fixed layout dimensions, test counts, and Rake command examples are not copied as current contracts: they require independent verification and may be stale.

The wiki is the maintained reference. Do not update or synchronize the retired developer document.

## Open questions

- Which monitor capabilities are still intended and operational, beyond what the current page and code demonstrate?
- Should mission activity be actively polled by this view, or is its current data intentionally initial-load only?
- What lifecycle contract should the monitor follow when Turbo replaces or caches the page?
- What browser-level regression coverage is practical for navigation between different celestial bodies?
