> **Wiki section:** UI & Experience · **Status:** design intent — evolving with reviewed prototype views

# UI & Experience

This section records the intended user experience and visual design of Galaxy Game's interface. It is part of the main `galaxyGame` repository because the interface is a product feature of Galaxy Game, even when a separate repository is used to prototype its implementation.

The wiki is the design authority. The `galaxy-game-ui` repository is an implementation/prototype workspace; its current appearance does not independently establish approved product design. Work orders in `agent-tasks` should reference these pages rather than restating design discussions.

## Current scope

| Page | Purpose |
|------|---------|
| [Branding and entry experience](01_branding_and_entry_experience.md) | Shared branding, landing page, and sign-in experience |
| [Player view architecture](02_player_view_architecture.md) | Three primary Player views, the separate Space context, and navigation boundaries |
| [Admin and AI Manager interfaces](03_admin_and_ai_manager.md) | Player/Admin dashboard separation, Admin workspaces, the shared NPC/player AI Manager operating model, Map Studio, and Digital Twin workflows |
| [Current UI state and known issues](04_current_ui_state_and_known_issues.md) | Dated observations of the running main UI, visual inconsistencies, working views, and known rendering issues |
| [Admin Celestial Body View](05_admin_celestial_body_view.md) | Intended Admin body-inspection workspace, legacy Rails 7 route/page facts, porting direction, and lifecycle issue under investigation |
| [Catalog, Blueprint & Visual Asset Architecture](06_catalog_blueprint_and_visual_assets.md) | Player Catalog and Blueprint experience, blueprint-driven visual generation, the RH-400 complete asset sheet as the primary visual target, and deployed-unit operational inspection |
| [Mission profiles, templates, tasks & execution](07_mission_profiles_tasks_and_execution.md) | Shared task/template libraries, template-first Player profile creation, custom JSON editing, location and survey prerequisites, operational mission oversight, and shared API boundaries |

The [Current UI State and Known Issues](04_current_ui_state_and_known_issues.md) page records observed behavior and defects separately from design intent. The review principle is to preserve, complete, and standardize useful existing application views—not discard unfinished work and start over. Celestial Body View (currently labeled Planetary View in the legacy app), Surface, Map Studio, Monitor entry/navigation, resource, and infrastructure views are candidates for prototype review and porting. Port them toward the approved experience rather than copying legacy layouts and labels unchanged.

The product has two primary dashboards: **Player Dashboard** and **Admin Dashboard**. They share a visual language and domain context but serve different audiences and workflows. AI Manager is a dedicated workspace within Admin. The Player interface has exactly three primary views described in page 02: Planetary, Surface, and Settlement. Space is a separate Player context, not a fourth primary view. Galaxy/system catalogs and system workspaces are navigation and selection workspaces, not additional Player views.

## Working lifecycle

1. Discuss the experience and alternatives.
2. Record approved intent, current direction, open questions, and relevant visual references here.
3. Create a narrow implementation task that references the wiki page.
4. Review the rendered prototype with the owner before moving to the next view.
5. Update this page with the actual reviewed result and any decisions that changed.

A proposed mockup or prototype screenshot is not automatically an approved design. Keep the distinction between **ESTABLISHED INTENT**, **DIRECTION**, and **OPEN** visible.

## Organizing and presenting simulation information

**CROSS-CUTTING DESIGN DIRECTION — 2026-11-15**

GalaxyGame has substantial and interconnected simulation data. The interface should make that information understandable and useful without requiring users to understand every underlying data structure or displaying every available value at once. Information should be organized around the audience's context, responsibilities, questions, and decisions.

### Audience and purpose

The same authoritative simulation data may need different presentations for different users and workspaces:

- **Player:** Understand current conditions, activity, available actions, and relevant consequences in the player's context.
- **AI Manager:** Understand conditions requiring attention, objectives, available options, priorities, constraints, and evidence relevant to operational decisions.
- **Admin:** Inspect application and simulation health, data quality, system behavior, configuration, and operational problems.
- **Map Studio:** Understand source data, geographic coverage, classifications, assumptions, derived information, processing, and generated results.

These are different workflows and information needs, not merely different permission levels. Respect the established boundaries among Player views, Admin workspaces, and the simulation and operational systems behind them.

### Reusable presentation techniques to consider

The following are useful design techniques to evaluate as individual views and workflows are developed. They are principles and options, not mandatory controls or finalized layouts:

- **Progressive disclosure:** Present the most useful information first and make deeper detail available when requested.
- **Layered visualization:** Allow relevant environmental, geographic, resource, infrastructure, and activity information to be examined independently or in combination.
- **Contextual inspection:** Let users select a body, location, resource, structure, unit, or other object to inspect its relevant properties and relationships.
- **Historical and comparative views:** Where data permits, compare current conditions with previous states, alternative configurations, and projections.
- **Provenance and confidence:** Distinguish observations, imported information, derived values, estimates, assumptions, and hypothetical configurations. Preserve source and transformation context where it matters.
- **Alerts and exceptions:** Bring important changes, unusual conditions, failures, and items requiring attention to the appropriate audience rather than making users discover every issue manually.
- **Appropriate aggregation and detail:** Use summaries, maps, lists, tables, trends, and object-level inspection according to the task and scale. Avoid overwhelming users with undifferentiated data or hiding important detail behind excessive navigation.

### One authoritative source, multiple useful presentations

A data value or simulation result should not be tied to one particular screen. For example, temperature might appear as a planetary visualization layer, a local settlement reading, a historical trend, an AI Manager threshold condition, or an administrative diagnostic. Each presentation should serve its audience while relying on authoritative data and calculations rather than duplicating domain logic or creating competing versions of the underlying information.

The UI should make the meaning, units, time context, and relevant uncertainty of displayed information clear. Numeric runtime values must follow the UI Data Sourcing Rule below.

## Learning from other projects

**CROSS-PROJECT RESEARCH AND REUSE PRINCIPLE — 2026-11-15**

GalaxyGame has its own goals, domain model, architecture, and intended experience. Other games, simulations, visualization tools, libraries, papers, and software projects are valuable sources of knowledge and potential reusable work. They should not be treated as unquestionable blueprints or authorities over GalaxyGame's design. Many engineering, simulation, data-organization, and user-interface problems are shared across projects. Studying how others address those problems can help GalaxyGame identify options, evaluate existing implementations, and develop solutions suited to its own requirements.

Reviewing another project does not imply that GalaxyGame should copy its overall architecture, mechanics, or product direction. However, **reuse of someone else's code is a legitimate option, not something to avoid simply because it was written by someone else.** A suitable open-source library, gem, component, algorithm, or implementation may be used as-is, adapted, combined with other solutions, or used as a reference for an independent implementation. Reuse should be evaluated on technical suitability, compatibility, maintenance, security, performance, license terms, and the needs of GalaxyGame. Do not reinvent useful, well-supported work without a reason.

When reviewing external work or research:

1. Understand the source project's goals and the context in which its approach makes sense.
2. Identify the specific problem, idea, technique, data, library, or code worth examining.
3. Verify the source and inspect the relevant material; do not rely on a generated description or an unverified citation as proof.
4. Distinguish what the source actually demonstrates from the agent's interpretation, recommendation, or proposed GalaxyGame application.
5. Compare the finding with GalaxyGame's established architecture, existing code, unfinished capabilities, and open design questions.
6. Record useful findings, alternatives, trade-offs, and unresolved questions. Adopt, adapt, reuse, or reject them based on GalaxyGame's needs.

### Source citation and evidence integrity

Agents must cite the sources of external information used to support research, recommendations, design proposals, and technical conclusions. This applies to papers, documentation, repositories, source files, standards, datasets, and other material—not only to code that is ultimately adopted.

Citations must be real, traceable, and relevant to the claim they support. Agents must not invent papers, authors, titles, publication details, repository URLs, links, quotations, or other references. A source that has merely been mentioned or discovered but not checked must not be presented as verified. If a source cannot be located or inspected, state that limitation clearly.

Keep these things distinct:

- **Source:** The identifiable work, author or organization, version/date where relevant, and a stable URL or other locator.
- **Evidence:** The specific content, code, data, or behavior inspected, with a page, section, file path, line range, commit, or other locator when available.
- **Interpretation:** What the agent believes the evidence means, including uncertainty and limitations.
- **GalaxyGame implication:** How the finding might inform a design, implementation, or decision here.
- **Verification status:** Whether the source and the relevant supporting material were actually checked, or remain unverified.

A citation must support the claim attached to it. Do not cite a source merely because it is topically related. Distinguish source-verified facts from agent inference, proposals, and unresolved questions. When evidence is unavailable or inconclusive, say so rather than filling the gap with a plausible-sounding reference.

### Code reuse, attribution, and provenance

When incorporating an external library or identifiable third-party code:

- Record the original project, author or copyright holder where identified, source location, version or commit when practical, and applicable license.
- Follow the actual license terms. Preserve copyright, license, and attribution notices and meet any other obligations that apply; do not assume all open-source licenses have identical requirements.
- Document what GalaxyGame uses, where and why it is used, and whether it is used unchanged, configured, wrapped, modified, or adapted.
- Describe significant GalaxyGame changes and maintain a clear distinction between upstream work and our own contributions.
- Record the upstream relationship and how updates or local modifications will be handled when relevant.

Do not invent or infer authorship from names or headers encountered in unrelated examples or generated output. New GalaxyGame work must not be attributed to an unrelated author. Conversely, do not remove or misrepresent legitimate third-party notices from reused code.

Agents should not present generated code as independently authored merely because it was generated by a model. If output contains substantial or distinctive material that appears to reproduce an identifiable external work, flag it for provenance and license review before treating it as original GalaxyGame code. Similarity in a conventional pattern or common solution is not, by itself, proof of copying; assess the actual evidence.

This research and reuse practice is intended to help GalaxyGame make informed choices while it still has substantial capabilities to build and many open questions. It is not a requirement to cite every commonplace programming pattern or to maintain an exhaustive list of everything a model may have encountered during training. Focus on sources that materially inform a claim, decision, or incorporated work.

## UI Data Sourcing Rule

**All numeric values displayed in the runtime UI/HUD must be sourced from either:**
- Live code (`app/` models, services, controllers)
- The `operational_data` JSON configuration system

**Placeholder tables and estimates in this wiki are NOT valid data sources for live UI display.** Wiki tables, mass balances, and power budgets serve as design documentation and architectural reference only. Any wiki table marked `[PROPOSED / PLACEHOLDER]` must be replaced with code-grounded or `operational_data`-sourced values before being rendered to players.

## Change History

- **2026-11-23** — Clarified that NPC and player-directed autonomous operations use one shared AI Manager; recorded the distinct sources of direction, asset scope, delegated authority, and task provenance in the AI Manager design and Admin UI documentation.
- **2026-11-23** — Added [Mission Profiles, Templates, Tasks, and Execution](07_mission_profiles_tasks_and_execution.md): shared Admin/Player views, Admin-managed task/template libraries, template-first Player profile cloning, custom JSON editing, task reuse by reference, body/site selection, survey prerequisites, and operational mission oversight.

- **2026-11-04** — Created the UI & Experience section as the home for Galaxy Game interface design intent.
- **2026-11-11** — Expanded the architecture to document dashboard responsibilities, system/body workspaces, Admin/AI Manager direction, dated current-state issues, and preservation/completion of existing views.
- **2026-11-13** — Corrected the Player architecture to three primary views plus a separate Space context and clarified Admin workspace boundaries.
- **2026-11-14** — Clarified StarSim, TerraSim, AI Manager, and Digital Twin responsibilities; left small-body spawning and resource-generation ownership open.
- **2026-11-15** — Established Admin Celestial Body View terminology and documented the distinction between legacy Rails 7 implementation and future UI porting intent.
- **2026-11-15** — Added cross-cutting principles for organizing simulation information, learning from and responsibly reusing external work, and requiring traceable sources and evidence for agent research and conclusions.
