> **Wiki section:** UI & Experience · **Status:** ESTABLISHED INTENT and DIRECTION, with unresolved implementation details marked OPEN
> **Last Updated:** 2026-11-11

# Admin and AI Manager Interfaces

This page records the intended responsibilities and interface boundaries for the Admin and AI Manager areas of Galaxy Game. It complements [Player View Architecture](02_player_view_architecture.md): the three application interfaces are separate from the five views available within the Player interface.

## 1. Three distinct interfaces

**ESTABLISHED INTENT — 2026-11-11**

Galaxy Game has three distinct interfaces for different audiences and workflows:

| Interface | Audience / purpose | Primary concern |
|---|---|---|
| Main Game / Player | People and organizations participating in the shared universe | Player context, assets, decisions, permitted actions, and gameplay |
| Admin | Game operators and administrators | Simulation, infrastructure, world data, system health, configuration, and operational oversight |
| AI Manager | Operators supervising autonomous game management | Missions, decisions, plans, resource priorities, deployments, execution, and learning evidence |

They share a coherent visual language and may share reusable components, data visualizations, and domain context. They are not one dashboard with different permission levels. Their navigation, density, workspaces, and actions should fit their distinct responsibilities.

**Current development direction:** Admin and AI Manager interfaces are being developed before the Player interface. Mock data and JSON-backed examples are acceptable while the workflows and presentation are being established. A prototype screen must not imply that its mocked action is connected to live simulation behavior.

## 2. Shared visual language

**ESTABLISHED INTENT — 2026-11-11**

Use the shared dark charcoal/navy and cyan visual direction recorded in [Branding and Entry Experience](01_branding_and_entry_experience.md). Keep the three interfaces visually related while allowing different workspace layouts.

- Cyan is the primary interaction/accent color.
- Green communicates success, healthy state, or operational status; it is not the dominant application theme.
- Amber communicates warnings; red communicates errors or critical conditions.
- Maintain readable, compact typography and clear separation between labels, values, descriptions, and actions.
- Use tables, lists, maps, charts, detail panes, and contextual actions where they suit the work. Do not force every page into large cards or a fixed dashboard grid.

## 3. Admin interface

**DIRECTION — 2026-11-11**

Admin is the operator's workspace for understanding and managing the simulation and the infrastructure that supports it. It should make it possible to inspect the state of the world, investigate conditions, configure or validate systems, and access appropriate administrative operations.

Relevant areas include:

- simulation and world-state oversight;
- celestial-body data and planetary Digital Twin inspection;
- terrain, hydrosphere, atmosphere, resource, and map-generation tools;
- infrastructure, depots, stations, logistics, and operational status;
- system health, data integrity, and administrative controls;
- AI Manager oversight and access to its evidence and decisions.

This is not a requirement for one universal Admin dashboard. Use focused workspaces with summaries and drill-down where appropriate. Exact navigation labels and page layouts remain subject to review.

## 4. Map Studio and the planetary Digital Twin

**ESTABLISHED INTENT — 2026-11-11**

Map Studio belongs in the Admin toolset as part of a connected planetary-data pipeline. It is not merely a map viewer or an isolated map-painting application.

There are two complementary paths into the shared planetary Digital Twin:

### Known-world reconstruction

Use observational data and available planetary/geological evidence to reconstruct or refine a known world's geography and related layers. Source data may include elevation/terrain products and other relevant observations. The UI should make source, coverage, assumptions, and uncertainty inspectable where the data supports it.

### Extrasolar-world generation

Use geographic patterns extracted from source maps (including playable FreeCiv/Civ4 maps and real-world geographic examples) as training/source material. Extract useful structures such as continent and coastline forms, mountain ranges, basins, and drainage patterns; do not copy a source map wholesale. Generate a plausible initial geography constrained by the target world's properties.

The existing generator did produce maps and established a working baseline. Output quality was poor and needs review; do not describe the pipeline as having produced no output or discard the existing generated map as evidence. The cause of quality problems (source material, extraction, generation, constraints, or their combination) remains to be established through review.

### Shared Digital Twin

Both paths feed the same authoritative planetary Digital Twin. The Digital Twin represents the evolving state of a celestial body and is used by simulation, Admin, and relevant player interfaces. Map Studio creates, reconstructs, inspects, or applies initial geographic data; simulation processes such as hydrosphere change and terraforming evolve that shared state.

For example, elevation data can support estimates of the water volume needed to reach a target shoreline or inundation level. Such calculations should use the actual terrain data and clearly distinguish a modeled requirement from water that is available or accessible. This is an example of a connected Digital Twin capability, not a claim that a particular calculation is already implemented.

**Boundary:** Map Studio and the generator are not a current UI-prototype repair task by themselves. Preserve the existing baseline and document the intended pipeline; generator quality work can be planned separately when requested.

## 5. AI Manager interface

**ESTABLISHED INTENT — 2026-11-11**

The AI Manager interface is an operator-supervision and evidence workspace. It should help an operator understand what the AI Manager is trying to accomplish, what it has decided, what it is doing, and whether intervention or review is warranted.

Useful areas include:

- mission selection, objectives, starting conditions, and constraints;
- current plans and priorities;
- decisions and the rationale/evidence behind them;
- resource needs, shortages, inventories, and dependencies;
- asset, craft, fleet, and infrastructure deployments;
- execution progress, completed work, failures, and unexpected events;
- warnings, blocked work, and opportunities for operator intervention;
- performance review and retained training/validation evidence.

The early AI Manager views in the main application are reference material and starting points, not a mature or complete interface. Review and adapt their useful content and workflows; do not assume they should be copied wholesale. Mock data is acceptable in the prototype while the presentation and navigation are developed.

The AI Manager interface must not imply that a displayed decision, mission action, pause, reset, or deployment is live unless it is actually connected to the relevant service and authorization path.

See [AI Manager Logic & High-Level Execution Rules](../logistics/ai_manager_logic.md) for game-domain intent and implementation caveats. That page remains the domain authority; this page defines interface responsibilities.

## 6. Relationship to the Player interface

The Player interface is a separate experience for people acting within the game. Admin and AI Manager may display the same underlying celestial body, settlement, craft, or resource information, but the purpose and available actions differ by audience.

For example, an operator may inspect a planetary dataset or supervise an AI construction mission; a player may inspect a world and issue permitted gameplay orders. Shared rendering or data does not merge the interfaces. Access and permitted operations remain enforced by the application/backend.

## 7. Open details

The following are not settled by this page:

- final Admin and AI Manager navigation labels and exact page layouts;
- which existing Admin/AI Manager views or scripts are safe and useful to reuse;
- exact Map Studio source-data catalog, quality metrics, and generation controls;
- detailed Digital Twin data contracts and the boundary between source observations and simulated state;
- exact AI Manager decision-explanation and training-evidence presentation;
- which prototype actions are mock-only versus connected to live services.

Do not silently turn these open details into approved requirements.

## Change history

- **2026-11-11** — Recorded the three-interface model, Admin and AI Manager responsibilities, Map Studio's role in the known-world/extrasolar pipeline, and the shared planetary Digital Twin direction.

## 8. Preserve, complete, and standardize existing views

**ESTABLISHED REVIEW PRINCIPLE — 2026-11-11**

The existing main application contains substantial and useful interface work. It is incomplete and inconsistent in places; that is not a reason to discard it or treat the prototype as a replacement built from scratch.

The prototype review should identify and carry forward useful existing views, visualizations, controls, data relationships, and workflows, then complete and standardize their presentation. In particular, review the existing Planetary/Orbital, Surface, Map Studio, Monitor, resource, infrastructure, and other useful operational/world-inspection views. The exact inventory and functional status must be verified against current code and runtime evidence rather than inferred from names or screenshots alone.

- Preserve working behavior and useful information architecture before refactoring.
- Record what is working, incomplete, broken, or not yet assessed.
- Complete missing pieces and investigate regressions as focused work.
- Standardize navigation, terminology, layout conventions, controls, typography, spacing, and status presentation without forcing every view into one dashboard template.
- Keep each workspace appropriate to its task: planetary/orbital inspection, surface exploration, map authoring, operations, and so on.
- Use the prototype's stronger visual direction and interaction patterns where they improve the experience, while retaining the main application's useful domain-specific capabilities.

The objective is consolidation and completion, not wholesale replacement.

## 9. Integration direction: presentation first, service boundary informed by existing capabilities

The prototype may initially use mock or JSON-backed data to establish the view design and interaction model. Once the UI and workflows are clear, integration can proceed by either backporting the refined views into the main application or exposing suitable main-application capabilities through an API consumed by the prototype.

This is an implementation choice to evaluate against the actual code and service boundaries; it is not yet a decision to build a particular API or to duplicate simulation logic in the prototype. The main application remains authoritative for game state, domain rules, calculations, permissions, and operations. Prefer reusing existing services and data access over reimplementing behavior in the UI.

