> **Wiki section:** UI & Experience · **Status:** ESTABLISHED DESIGN INTENT; editor, API, and execution integration are not yet implemented as a complete workflow
> **Last Updated:** 2026-11-23

# Mission Profiles, Templates, Tasks, and Execution

This page defines how Admins and Players assemble reusable mission guidance from existing GalaxyGame templates and task definitions, assign operational targets, and observe execution. It complements [Admin Dashboard and AI Manager](03_admin_and_ai_manager.md), [Player View Architecture](02_player_view_architecture.md), and [AI Manager & Autonomous Coordinators](../services/ai_manager.md).

## 1. Core model

**ESTABLISHED INTENT — OWNER-CONFIRMED 2026-11-23**

Mission authoring is assembly of existing GalaxyGame building blocks. It is not a requirement to hand-write a new mission engine, duplicate task definitions, or manually prescribe every execution step.

Keep three related but distinct layers:

1. **Reusable task definitions:** Individual operational capabilities maintained in the shared Task Library. A task describes a unit of work and its requirements, inputs, parameters, constraints, and expected result as appropriate. Tasks are referenced by missions; mission profiles do not create private duplicate task definitions.
2. **Mission templates:** Reusable starting structures for common operational objectives and flows. Templates are location-independent where the operation permits and can organize task references, objectives, requirements, and relationships. Admins curate the shared template catalog.
3. **Mission profiles and configured runs:** A mission profile is a named, reusable set of guidance assembled from one or more templates and existing task definitions. A deployed mission/run is a particular execution configured for its actual target body/site, available assets, and current conditions. Runtime progress, task state, decisions, and outcomes belong to the run, not to the reusable template.

A mission is a repeatable operational flow toward an outcome—often establishing, supplying, or expanding a settlement—not merely one task or a rigid checklist. The AI Manager uses the profile as guidance, then selects, sequences, combines, and adapts available tasks to current conditions, dependencies, resources, capabilities, and delegated authority. The profile does not force a fixed sequence when conditions require a different valid plan.

**Example:** A Venus atmospheric-harvesting mission is a repeatable flow: dispatch a suitably configured harvester, collect the atmosphere's current composition, return to the receiving location, offload into available storage, assess turnaround requirements, and repeat when operational conditions permit. Individual tasks implement reusable actions; the mission profile expresses the larger repeatable objective and operating guidance.

## 2. Admin and Player responsibilities

**ESTABLISHED INTENT — OWNER-CONFIRMED 2026-11-23**

Admin and Player are different audiences and permission scopes over shared game capabilities and authoritative resources. They must not become duplicate applications with separate copies of the same domain logic or game views.

- **Shared views:** Where Admin and Player inspect the same game object or operation, reuse the same underlying view and data contract. Admin may see broader context, additional telemetry, diagnostics, cross-player/global scope, and additional authorized controls. Player sees the subset relevant to their own assets, settlements, missions, and permissions.
- **Admin-only capabilities:** Admin manages the shared Task Library and predefined Mission Template Library; creates, edits, validates, tests, and maintains reusable definitions; and has global operational oversight and administrative diagnostics.
- **Player capabilities:** Players create and manage their own mission profiles to guide the shared AI Manager's deployment and operation of their assets. Players do not edit shared task definitions or administer the shared template catalog. They select from existing tasks and templates and configure their own objectives, preferences, constraints, target scope, and delegated authority.
- **AI Manager:** One shared autonomous-management system handles NPC and player-directed operations. The source of direction, asset scope, and delegated authority differ; task planning and execution capabilities are shared.

Admin mission tooling has two connected responsibilities: authoring shared reusable tasks/templates and observing live/recent mission runs. Authoring screens do not replace operational monitoring.

## 3. Template-first Player profile creation

**ESTABLISHED INTENT — OWNER-CONFIRMED 2026-11-23**

Creating a new Player mission profile begins by loading the available template catalog, not by opening a blank document.

1. Load and present all available mission templates supported by the profile builder.
2. Let the Player choose a new name for the mission profile and select the template material to use as its starting point.
3. Copy the selected template definition(s) into a new, independently editable Player profile. Never edit or overwrite the shared source templates.
4. Preserve the template's structure, objectives, requirements, and task references as applicable.
5. Let the Player adapt the profile and select additional existing task definitions from the shared Task Library. Store references to those tasks; do not fork or duplicate their definitions.
6. Configure mission-specific parameters, constraints, preferences, and permitted asset scope.
7. Assign or discover the target location according to the mission type (Section 5).
8. Validate the assembled profile and save it as a Player-owned reusable mission profile.

Whether a particular profile is based on one template or combines selected reusable template material must follow the existing mission/template format; do not invent a new composition schema before auditing the source files. The copy operation creates the Player's own profile, not ownership of or edit rights to shared templates and task definitions. Later changes to shared definitions require an explicit compatibility/version policy; do not silently rewrite saved Player profiles.

## 4. Admin authoring and JSON editing

**ESTABLISHED INTENT — OWNER-CONFIRMED 2026-11-23**

Admin needs tools to maintain both shared tasks and reusable mission templates/profiles. The authoring interface must work with existing GalaxyGame JSON definitions and schemas rather than introducing a parallel Rails-only data model.

Use a **custom JavaScript JSON editor** integrated into the existing Rails/Stimulus UI. This is a GalaxyGame editor component, not a commitment to a particular third-party gem or editor package. It should support:

- loading an existing task, template, or profile document;
- readable structured editing for common fields and relationships;
- direct raw JSON editing for advanced users;
- synchronized structured and raw representations of the same document;
- formatting and syntax validation;
- schema- and reference-aware validation where authoritative schemas exist;
- useful validation messages for missing task references, incompatible parameters, unresolved locations, and unmet prerequisites;
- preview/diff before saving and clear save/cancel behavior;
- preservation of source identity, version/provenance, and ownership boundaries.

Admin Task Editor edits shared task definitions. Admin Mission/Template Designer assembles reusable flows by selecting task definitions and expressing relationships, conditions, and desired outcomes supported by the actual format. Player Mission Profile Editor reuses the component but restricts editing to Player-owned profile fields and permitted references. The Player does not receive the shared Task Editor or shared Template Manager.

The editor must load and preserve existing formats. Before implementation, audit the actual template catalog, mission profile files, task files, schema/version mechanisms, and missions_v2 structure. Do not infer that similarly named legacy and V2 directories are interchangeable.

## 5. Mission target and location assignment

**ESTABLISHED INTENT — OWNER-CONFIRMED 2026-11-23**

A mission's target is not always a generic location string. Location selection depends on the mission environment and the information currently known about the target.

For a surface mission:

1. Select the **celestial body** (planet, moon, or other supported body).
2. Determine whether the intended surface site is already known and sufficiently characterized.
3. If known, select the specific site using the location representation supported by the game: for example a named region/site, coordinates, settlement, natural feature, or discovered deposit.
4. If the site is unknown or insufficiently characterized, select or create a prerequisite **survey mission** for that body/area. The follow-on operational mission must retain a dependency on the survey result rather than pretending the target is already known.
5. After survey results are available, select the discovered/validated site and configure the follow-on mission.

Other mission environments may target an orbital location, station, route, system, settlement, or other supported object. The editor should present target selectors appropriate to mission and task types rather than forcing every mission through a surface-site picker.

### Survey as a prerequisite and discovery operation

Survey is an operational mission in its own right, not merely a UI search step. It deploys suitable survey assets to gather information and can establish persistent discoveries for later operations. For geological deposits, survey characterizes/discovers a deposit record; it does not create the underlying material. Subsequent mining or extraction must debit the authoritative geological inventory and transfer extracted material through the normal resource-accounting path. Repeated surveys should update the same persistent deposit/discovery record rather than create duplicate deposits.

A mission profile may express a dependency such as: survey the selected body/region → evaluate discovered sites → use a qualifying site for the follow-on surface operation. The AI Manager should recognize unresolved target knowledge and missing survey prerequisites, recommend or arrange the survey when authorized, and keep the dependent mission blocked or pending until the required evidence exists.

**Example:** To create a lunar polar-resource mining mission, the Player selects Luna. If a suitable PSR deposit/site is already surveyed, they can select it. If not, they first create or select a survey mission for the relevant polar region, using suitable survey robots. Once the survey identifies and characterizes a qualifying deposit, the mining mission can use that discovered target.

## 6. Operational mission views

**ESTABLISHED INTENT — OWNER-CONFIRMED 2026-11-23**

Admin must retain mission execution and oversight views in addition to library and authoring tools. These screens observe actual running and recent mission runs; they are not replaced by template-building screens.

The operational workspace should support, as available from authoritative execution data:

- **Missions:** running, queued, completed, delayed, blocked, and failed runs.
- **Mission detail:** current task, progress, execution events, assets, resources, target, dependencies, exceptions, and results.
- **Planner:** proposed plans and replanning activity.
- **Decisions:** recorded AI Manager choices, rationale, evidence, constraints, and authority.
- **Patterns / learning:** reusable strategies and evidence from outcomes, without fabricating learning claims.
- **Performance:** operational outcomes and metrics.
- **Task Workbench:** task-level planning, assignment, execution, and troubleshooting.

Player operational views are scoped to the Player's own missions and assets. Admin may inspect broader/global operations and additional diagnostics using the same underlying records and, where appropriate, shared view components.

Clearly distinguish reusable mission definitions from mission runs. Editing a profile must not mutate an already-running execution; a run should retain the profile/template/task versions or equivalent provenance used to create it.

## 7. Shared API and domain boundary

**ESTABLISHED ARCHITECTURAL DIRECTION — OWNER-CONFIRMED 2026-11-23**

The API should expose shared game resources and operations with role- and ownership-aware authorization/projections. Do not build separate Player and Admin APIs that duplicate business rules.

Candidate resource concepts include world/system/celestial-body and discovered-location data; settlements and infrastructure; task definitions and task-library references; mission templates and Player-owned mission profiles; mission runs, task executions, dependencies, events, and outcomes; AI Manager decisions, policies, delegated authority, and evidence; asset/craft/rover availability and capability information; and survey observations and persistent discoveries.

The Player and Admin clients may receive different projections and authorized actions over the same underlying resources. Admin has shared-library management and global oversight permissions; Player has ownership-scoped profile management and asset-delegation permissions. Authorization and validation belong in the authoritative game application, not only in client-side visibility rules.

The prototype may use fixture data to design and test these workflows. A screen that needs information unavailable from the proposed API should expose that requirement during UI/API planning, before backend contracts are finalized.

## 8. Existing implementation and verification boundary

**SOURCE-VERIFIED DOCUMENTATION SNAPSHOT — 2026-11-23; not a complete runtime audit**

The repository contains legacy mission-profile and task work, a missions_v2 path family, mission/task JSON examples, and an older placeholder Mission Profile Builder controller. The existing Admin AI Manager mission, planner, decisions, patterns, and performance views are operational-oversight foundations, not a complete shared template/task authoring system.

The two V2 directories have distinct roles and must not be conflated: `data/json-data/missions_v2/` contains a limited set of Luna missions and task definitions assembled for the current testing setup; `missions/tasks_v2/` contains the broader task library in draft form. The inspected `TaskExecutionEngineV2#load_task_library` resolves `missions/tasks_v2`, so that path is consistent with loading the broader draft task library; it is not evidence that the Luna test fixtures under `data/json-data/missions_v2/` are misplaced or obsolete. The implementation audit must separately establish how the Luna test mission data is loaded and exercised, how draft task definitions are promoted/validated for use, and whether the V2 planner resolves all proposed phase/mission-plan references. Do not describe the full draft library as production-ready or assume every draft task is already integrated and executable.

The prototype's Admin Task Library, Mission Library, Player My Missions, Player detail/form, and operational oversight screens are UI foundations/fixtures. The Player form is not yet a persisted mission-profile editor. A complete custom JSON editor, template-copy workflow, task selection, target discovery, validation, persistence, and API integration remain to be implemented and reviewed.

Before implementation, inspect the current main-game source and data files again. Code wins for current behavior; owner-confirmed design intent in this page wins over stale placeholder comments or older proposed workflows when defining the target. Record unresolved schema and loader conflicts rather than silently choosing one.

## 9. Open implementation details

- Exact canonical template directories and the relationship between legacy mission templates, mission profiles, the Luna test fixtures under `data/json-data/missions_v2/`, and the broader draft task library under `missions/tasks_v2`.
- The actual schemas and version/compatibility rules for templates, profiles, phases, tasks, and mission runs.
- Whether and how multiple templates can contribute to one profile under the existing formats.
- The location/site identity and survey-result contracts used by the mission/task data.
- How survey missions publish persistent discoveries and how dependent missions consume them.
- The custom editor's structured controls and validation implementation.
- Save/versioning, profile cloning, task/template update compatibility, and mission-run provenance.
- Exact API endpoints and response projections, after shared resource and authorization requirements are mapped.

These are implementation and schema questions; they do not reopen the established task/template/profile separation, template-first creation, shared AI Manager, or survey-before-unknown-site workflow.


## 10. Prototype UI mapping and current checkpoint

**PROTOTYPE DESIGN / IMPLEMENTATION NOTE — 2026-11-23**

The UI prototype should express the workflows above as navigable workspaces, not create one page per task file or treat task definitions as executable mission plans.

Current Admin AI Manager prototype destinations include:

- **Operations overview:** selected-system context, work requiring attention, current objectives, and links into operational work.
- **Task Workbench:** task queue, task detail/provenance, proposed plan review, and execution/activity inspection. These are replaceable mock fixtures and do not dispatch assets or alter simulation state.
- **Decision Log:** decision rationale, source, authority, outcome, and linked task context.
- **Mission Monitor / run detail:** operational runs and history, kept distinct from reusable definitions.
- **Shared Task Library:** reusable task catalog and task inspection.
- **Mission Library:** reusable mission/template examples and their task references.

The Task Library now has a navigable task-detail route in the prototype. That detail view exposes capability, category, dependencies, source, maturity, and the distinction between a reusable definition and a configured execution. It is read-only fixture presentation, not the planned JSON editor.

The next design/implementation work is to build the Admin authoring workflow around the existing source formats: task definition inspection/editing, mission-template assembly from existing task references, validation, preview/diff, and version/provenance handling. Keep that authoring workflow separate from live/recent mission-run monitoring. The custom structured/raw JSON editor and its validation remain planned; do not imply they are implemented by the current detail view.

The legacy AI Manager performance, planner, and patterns screens remain in the prototype inventory but contain placeholder/mock presentation and controls. Do not label fixture values as live performance or claim that inert controls perform real simulation actions. Reconcile these pages against the established operational workspace requirements before deciding whether to retain, reshape, or retire them.
