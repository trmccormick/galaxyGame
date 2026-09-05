# Super-Mars (No Moons) — Foothold Planner Test Case

**Date**: 2026-09-05
**Status**: test case / design probe (NOT a full world implementation)
**Type**: resource-first foothold planning scenario
**Planner under test**: `app/services/ai_manager/foothold_planner.rb`
**Spec**: `spec/services/ai_manager/foothold_planner_spec.rb`
**Related**: `FOOTHOLD_PLANNER_ARCHITECTURE.md`

---

## What This Is

A **concrete, reusable test scenario** for the resource-first `FootholdPlanner`. It is a
design probe that forces the planner to **invent an asteroid-capture → depot-bootstrap
path** instead of matching a named "luna-first" or "mars-standard" pattern.

This is **not** a Super-Mars world, settlement pipeline, or service. It defines the
scenario inputs and the expected *class* of planner output.

---

## Scenario Definition

### Body properties (Mars-type, larger, closer orbit)
| Property | Value | Rationale |
|---|---|---|
| Class | Rocky / terrestrial solid body | `has_solid_surface? == true` (SolidBodyConcern) |
| Size | Larger than Mars | "Super-Mars" — more surface area, more regolith |
| Orbit | Closer to the star than Mars (~1.2 AU) | Lower transport cost, higher insolation |
| Atmosphere | Thin CO2-dominant (Mars-like) | `atmospheric` pattern is weak, not the answer |
| Regolith | Present, deep | Enables `surface_feature` as a fair competitor |
| Water | Polar/surface ice (stored volatiles) | `subsurface` is a secondary option |

### System topology (the defining constraints)
| Element | State | Effect on planner |
|---|---|---|
| **Moons** | **NONE** | `orbital_depot` scores ~0 (moon_count × 25 = 0) — the "luna-first" path is dead |
| **Nearby import nodes** (Earth/Venus analogs) | **NONE** | No cheap import source → import dependency is high → local/near-body leverage is the only viable bootstrap |
| **Nearby asteroids** | Present (small, accessible) | `captured_asteroid` becomes the top-ranked option |

### What is deliberately absent
- No moons → no pre-existing orbital transfer points.
- No Earth/Venus analogs → no "just import it" escape hatch.
- No pre-written pattern that fits cleanly → the planner must reason from the snapshot.

---

## Expected Planner Behavior Class

The planner should rank options in this reasoning order:

1. **Prefer local / near-body options** — the body's own regolith + ice, and the nearby
   asteroids, are the only low-import-dependency resources available.
2. **Asteroid capture & conversion** — move a small asteroid into orbit and convert it
   into a station/depot. This is the *invented* path (no named pattern).
3. **Depot bootstrap** — use the converted asteroid as the orbital depot / transfer hub
   that the surface settlement then grows from.

### Concrete assertions (see spec)
- `captured_asteroid` **is present** in the ranked options (the path was invented).
- `captured_asteroid` **ranks above** `orbital_depot` (which has no moons to leverage).
- `captured_asteroid` carries the task sequence
  `asteroid_survey → capture_operation → hollowing → depot_conversion`.
- `captured_asteroid` has a **high-local** bias.
- Contrast: adding a moon to the same body raises `orbital_depot`'s score (moons add
  transfer-point value) — proving the no-moon constraint is what drives the asteroid path.

---

## How This Differs From Named Patterns

| Pattern | Why it does NOT fit Super-Mars no-moon |
|---|---|
| **Luna-first** (`orbital_depot` on moons) | Requires moons as transfer points. Super-Mars has none. |
| **Mars-standard** (`surface_feature` only) | Ignores the strategic value of the nearby asteroids and the absence of import nodes; surface-only is viable but not the *best* bootstrap. |
| **Venus-style** (`atmospheric`) | Requires a dense, gas-rich atmosphere. Super-Mars has a thin CO2 atmosphere. |
| **Import-dependent** | Requires a nearby Earth/Venus analog. Super-Mars has none. |

The `captured_asteroid` path is the one that fits: it uses what is actually there
(nearby asteroids) and does not depend on any absent element (moons, import nodes, dense
atmosphere).

---

## Known Discrepancy (finding, not a blocker)

The planner's `accessible?` heuristic requires asteroid `mass < 1e12` kg. Real
Phobos/Deimos-class bodies are ~1e15–1e16 kg — **far above** that window. The spec uses
asteroids inside the planner's viable window so the `captured_asteroid` path is exercised.

This is a **documented skeleton limit** (see `FOOTHOLD_PLANNER_ARCHITECTURE.md` →
"Known Skeleton Limits"): the mass window is a placeholder heuristic, not a physical
model. A future task should reconcile the accessible-mass window with realistic
asteroid/Phobos-class masses before this scenario is used for real planning.

---

## Bugs Surfaced & Fixed (the test case did its job)

The `FootholdPlanner` had **never been executed** (no spec existed), so it carried
latent bugs. Writing this test case surfaced and fixed them:

| # | Bug | Location | Fix |
|---|---|---|---|
| 1 | `has_regolith?` was **private** but called by the planner | `precursor_capability_service.rb` | Moved to public section |
| 2 | `can_extract_water?` was **private** but called by the planner | `precursor_capability_service.rb` | Moved to public section |
| 3 | `evaluate_hybrid` called with **0 args** but defined with 1 required param | `foothold_planner.rb:75` | Pass `patterns` |
| 4 | `plan` sorted with `opt.score` but options are **Hashes** | `foothold_planner.rb:38` | Use `opt[:score]` / `opt.merge` |

All four were minimal, in-scope fixes (no behavior change beyond making the planner
actually runnable). `precursor_capability_service_spec.rb` still passes (18 examples).

---

## Acceptance Criteria (this task)

- [x] Scenario is written down clearly (this document).
- [x] Expected planner behavior class is stated (local/near-body → asteroid capture → depot bootstrap).
- [x] Explicitly marked as a test case for resource-first planning (header + spec).
- [x] Does not attempt full Super-Mars implementation (no new world/service/migration).
