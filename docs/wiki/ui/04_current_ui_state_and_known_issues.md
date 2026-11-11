> **Wiki section:** UI & Experience · **Status:** Current-state observations from owner-provided screenshots; implementation causes not yet diagnosed
> **Last reviewed:** 2026-11-11
> **Evidence:** Screenshots of the running main GalaxyGame application supplied during the UI review on 2026-11-10. These are observations of that captured state, not a guarantee that every issue remains unchanged.

# Current UI State and Known Issues

This page records the observed state of the existing main GalaxyGame UI so that design work and future implementation tasks start from a shared, evidence-based understanding. It is separate from the approved UI direction: a current defect is not a design requirement, and a proposed design is not proof that an existing feature works.

The UI prototype is also a separate reference. It has stronger visual work in several areas and should not be judged solely against the legacy main-app presentation. See [Branding and Entry Experience](01_branding_and_entry_experience.md), [Player View Architecture](02_player_view_architecture.md), and [Admin and AI Manager Interfaces](03_admin_and_ai_manager.md).

## 1. Visual consistency and presentation

### Main Game

**OBSERVED — 2026-11-10**

- The current `/game` view retains the older bright-green-on-black terminal/hacker appearance, including monospaced typography and green borders/headings.
- This differs from the newer dark charcoal/navy and cyan direction established in the UI design wiki and carried into the prototype.
- The legacy treatment should not be assumed to be the desired visual standard for future work.

### Admin

**OBSERVED — 2026-11-10**

- The `/admin/resources` view shows a partial transition toward dark charcoal/cyan styling.
- Older green buttons, borders, and status treatments remain alongside newer styling.
- Native controls and custom-styled controls appear together, producing an inconsistent presentation.

### General usability review

**REVIEW NEEDED**

The prototype review has also identified presentation concerns in some newer screens: typography can be too large, text can run together, and layouts need better spacing and information hierarchy. These are review observations, not a claim that every prototype page has the same problem.

**Direction:** Continue the shared dark charcoal/navy + cyan design language. Retain green for success and operational status rather than using it as the dominant theme. Refine typography, spacing, controls, and reusable components consistently across Main Game, Admin, and AI Manager. Do not treat a global recoloring exercise as a substitute for improving each screen's layout and workflow.

## 2. Planetary view

**OBSERVED WORKING — Earth, 2026-11-10**

The Earth Admin Planetary view was demonstrated running with a GeoTIFF data loader. The screenshot showed:

- the planetary map rendering;
- terrain, biome, and hydrosphere/temperature layer selections changing the displayed map;
- map controls and supporting information/mission panels;
- a lower console area.

This is useful evidence that the Earth Planetary view and at least the demonstrated layer-loading/rendering path are operational in the captured environment. It does not establish that every body, dataset, layer, or interaction is working.

**Preserve:** This is a useful existing capability and functional reference. Future UI work should improve presentation and integration without casually replacing working map/data behavior.

## 3. Surface view and tileset loading

### Earth

**OBSERVED INCOMPLETE — 2026-11-10**

- The Earth Surface view displayed part of its tile map.
- The visible tileset status reported `0/12`.
- The screenshot therefore does not demonstrate a fully loaded or healthy Earth Surface tileset.

### Mars

**OBSERVED BROKEN — 2026-11-10**

- The Mars Surface view displayed a blank map.
- The tileset status alternated between `Ready` and `Initializing`.
- No surface tiles were visibly loaded in the captured view.

The user noted that Surface views for Mars, Luna, and other bodies had worked previously, but the path subsequently broke. This historical report is useful context; it does not identify when the regression occurred or its cause.

**Investigation needed:** Determine whether the problem is in tileset discovery/configuration, asset availability, data shape, loading lifecycle/state, rendering, or an interaction among those parts. Do not assume a root cause from the screenshots alone. The Earth and Mars symptoms may or may not share the same cause.

**Scope boundary:** The Surface rendering/tileset problem is recorded here as a known issue. It is not automatically part of the current visual cleanup or prototype porting task. Diagnose and repair it as a focused task when prioritized.

## 4. Main application views as references

The existing main application contains useful functional work that should be evaluated before porting or replacing screens:

- **Planetary:** demonstrated Earth GeoTIFF/layer rendering and operational panels.
- **Surface:** separate tile-based rendering and tileset-loading path; current Earth/Mars symptoms are recorded above.
- **Monitor:** body overview and navigation/quick-action concepts.
- **AI Manager:** early views and workflow stubs that can inform the prototype, but should not be treated as a mature or complete interface.

Static source inspection can reveal architecture and dependencies, but it does not prove that a view currently works in the running application. Prefer current runtime evidence when recording functional status.

## 5. How to use this issue record

- Keep observations dated and tied to screenshots, runtime checks, or code evidence.
- Separate **OBSERVED WORKING**, **OBSERVED INCOMPLETE**, **OBSERVED BROKEN**, and **REVIEW NEEDED**.
- Do not claim a root cause until it has been verified in code or through a focused reproduction.
- When an issue is fixed, record the verification evidence and date; do not silently erase the history.
- When a new screenshot or runtime check changes the assessment, update the status and evidence.
- Convert prioritized issues into focused implementation tasks that link back to this page.
- Do not let a defect become a permanent design constraint. The approved direction remains in the other UI wiki pages.

## 6. Existing views: preserve and bring forward

**ESTABLISHED REVIEW PRINCIPLE — 2026-11-11**

The screenshots and existing application demonstrate that meaningful interface work already exists beyond the early AI Manager screens. The application is unfinished and inconsistent; it is not an empty or disposable legacy UI.

The prototype review should assess and preserve useful existing view setups, including (where confirmed in the current code/runtime):

- **Planetary / Orbital:** planetary and orbital context, map/layer presentation, environmental data, and supporting inspection panels. Determine whether the current implementations are distinct views or related perspectives; do not collapse them without review.
- **Surface:** tile-based surface presentation, terrain and geographic context, and associated inspection/selection interactions.
- **Map Studio:** existing map generation/reconstruction and inspection workflows, considered as part of the Admin-to-Digital-Twin pipeline.
- **Monitor and other world-inspection views:** useful overview, navigation, selection, and contextual-action patterns.
- **Resource and infrastructure views:** operational data and controls that already express meaningful game concepts.
- **Other useful visualizations:** preserve any view that communicates real game state or supports a distinct workflow better than a generic replacement screen.

This is a review inventory, not a claim that every listed view is currently complete or working. The Planetary Earth and Surface Earth/Mars observations above remain the dated screenshot evidence; other view status must be verified separately.

For each view, record its useful behavior and data, what is incomplete or broken, what should be carried into the prototype, and what needs visual or interaction refinement. A view should not be discarded merely because its styling is old or its implementation is unfinished.

## 7. Prototype and integration strategy

The prototype is an opportunity to establish a consistent visual language, layout system, navigation, and usable workflows before committing to the final integration shape.

After the UI is sufficiently reviewed, there are two viable implementation paths to evaluate:

1. Backport the refined presentation and interaction patterns into the main application, reusing its existing behavior and services.
2. Keep the prototype as the UI application and expose suitable main-application capabilities through an API for it to consume.

These are alternatives to evaluate, not a settled architecture decision. In either case, preserve the main application's authority over simulation state, domain behavior, calculations, authorization, and operations. Avoid duplicating those rules in client-side code or a separate prototype backend.

The review record should therefore document both the useful existing capability and the intended improved presentation. This makes it possible to choose a backport or API integration later without losing the knowledge of what already exists.

## 8. Change history

- **2026-11-11** — Recorded the current main-app visual inconsistencies, demonstrated Earth Planetary functionality, and observed Earth/Mars Surface tileset issues from the owner-provided screenshots captured 2026-11-10.
- **2026-11-11** — Added the explicit preserve/complete/standardize principle and documented existing view families as candidates for prototype porting and later backport/API integration.
