# 2026-04-17-MEDIUM-IMPLEMENT-STRATEGIC-DATA-DISPLAY.md

## Task Title
Implement Strategic Data Display Layer in Monitor UI

## Task Overview
Add a strategic data display layer to the admin monitor interface, visualizing economic zones, development priorities, and military considerations as overlays. Integrate with the .ggmap strategic layer and ensure UI, backend, and data schema alignment.

## Background & Context
- Strategic planning requires visualization of economic, development, and military overlays beyond basic terrain data.
- The monitor UI (monitor.html.erb, monitor.js) uses a canvas-based renderer with toggleable overlays (see UI_IMPLEMENTATION.md).
- Backend controllers (celestial_bodies_controller.rb, admin/dashboard_controller.rb) already aggregate some strategic and economic data.
- The .ggmap format and strategic layer tasks define the canonical schema and data sources for strategic overlays.

## Actionable Steps
1. BLOCKED: Do not begin until 2026-04-17-HIGH-IMPLEMENT-GGMAP-STRATEGIC-LAYER.md and .ggmap format are complete and approved.
2. Extend monitor.html.erb to add a strategic layer toggle in the UI controls.
3. Update monitor.js to support rendering the strategic overlay, following the pattern for other layers.
4. Aggregate strategic/economic/military data from backend endpoints (celestial_bodies_controller.rb, admin/dashboard_controller.rb).
5. Design overlay visuals for economic zones, trade routes, development hubs, and military/defense data.
6. Support multi-scale overlays (planetary, system, galactic).
7. Ensure performance remains acceptable with complex overlays.
8. Document all UI and code changes in UI_IMPLEMENTATION.md.

## STOP/REVIEW Conditions
- STOP if .ggmap strategic layer schema is not finalized or changes.
- STOP if monitor UI cannot support additional overlays without major refactor; escalate for review.

## Acceptance Criteria
- [ ] Strategic layer toggle available in monitor interface
- [ ] Economic, development, and military overlays display correctly
- [ ] Multiple overlays can be combined and toggled
- [ ] Layer supports planetary, system, and galactic scales
- [ ] Performance remains acceptable
- [ ] UI and code changes are documented

## Agent Assignment
- Agent: Senior frontend developer or advanced AI agent (Claude)

## Files to Create/Modify
- galaxy_game/app/javascript/admin/strategic_layer.js (new)
- galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb
- galaxy_game/app/javascript/admin/monitor.js
- galaxy_game/app/services/strategic_data_service.rb
- galaxy_game/app/controllers/celestial_bodies_controller.rb
- galaxy_game/app/controllers/admin/dashboard_controller.rb
- docs/developer/UI_IMPLEMENTATION.md

## Blockers / Dependencies
- BLOCKED: Do not begin until 2026-04-17-HIGH-IMPLEMENT-GGMAP-STRATEGIC-LAYER.md and .ggmap format are complete and approved.
- All overlays and data must comply with the canonical .ggmap strategic layer schema.
- Any changes to .ggmap format or strategic layer must be proposed and approved in the canonical task before implementation.

## Notes
- Follow the established pattern for layer toggles and overlays in monitor.js and monitor.html.erb.
- Coordinate with backend and data schema owners to ensure data availability and correctness.