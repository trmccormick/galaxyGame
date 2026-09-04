# Foothold Planner Architecture Note

**Date**: 2026-09-03  
**Status**: implemented (thin skeleton)  
**File**: `app/services/ai_manager/foothold_planner.rb`

---

## Design Line — Consistent with Prior Art

This planner extends the same resource-first, world-agnostic design vision established in:

1. **RESUPPLY_AND_ESCALATION_ARCHITECTURE.md** — State-based triggers (not hardcoded classifications); ISRU-first even inside emergency response; `time_to_critical` vs resupply window
2. **AI_MANAGER_CONSTRUCTION_ECONOMICS.md** — Build priority: local resources + robot labor → player contracts → NPC import last; AI Manager checks local extraction cost against import EAP
3. **CYCLER_SYSTEM_ARCHITECTURE.md** — Generic base platform + mission fits as operational data; same cycler reconfigured per mission
4. **construction_system.md** — Generic regolith I-beam + panel methodology; pressurization adapts to body resources
5. **v2 task/phase registry** — Tasks are reusable, parameterized, event-completed; phases compose `task_ref`s

**This is one design vision, not a parallel track.** The foothold planner applies the same principles to initial settlement planning where the current pattern-first entry point (`MissionPlannerService`) handles poorly.

---

## Input Contract

```ruby
FootholdPlanner.new(celestial_body, system_context: {
  moons:           [CelestialBody, ...],       # orbiting moons
  asteroids:       [{ mass:, composition:, ... }, ...],  # nearby asteroids
  distance_from_sun: Float,                     # AU
  parent_body:     CelestialBody | nil,        # if this body orbits another
  nearby_nodes:    [CelestialBody, ...]         # other settled/accessible bodies
})
```

**No `pattern_name` required.** The planner evaluates the body's actual resources, moons/asteroids, accessibility, and logistics distance at runtime.

---

## Output Contract

Returns `Array<FootholdOption>` (ranked best first). Each option:

```ruby
{
  pattern:              :surface_feature | :orbital_depot | :captured_asteroid |
                        :atmospheric | :subsurface | :hybrid,
  location_type:        :surface | :orbital_depot | :atmospheric | :subsurface | :multi_location,
  score:                Integer,                 # higher = better
  preferred_location:   String,                  # human-readable description
  task_sequence:        Array<{ phase:, tasks: }>,# v2-style phase/task refs
  local_vs_import_bias: :very_high_local | :high_local | :moderate_local | :low_local,
  rationale:            String                   # why this option ranked here
}
```

---

## Ranking Criteria (aligned with existing principles)

| Criterion | Weight | Rationale |
|---|---|---|
| Local resource count | +10 per resource | Aligns with local-first principle |
| ISRU options available | +15 per option | ISRU-first from escalation architecture |
| Regolith presence | +20 | Enables generic I-beam construction |
| Moon count (orbital) | +25 per moon | Transfer point value (cycler architecture) |
| Asteroid viability | +35 per viable asteroid | Moving small asteroids > 1e12 kg is infeasible |
| Atmospheric density | pressure × 5 + gas bonuses | Free gas extraction value |
| Water/ocean presence | +40 / +30 | Direct ISRU pathway for fuel/life support |
| Hybrid complexity penalty | × 0.6 | Multi-location adds logistics overhead |

---

## Non-Goals (explicit)

- **No full costing** — scoring is heuristic, not a financial model
- **No contract generation** — that belongs to `MissionPlannerService` / `ContractCreationService`
- **No pattern deletion** — `MissionPlannerService` with `pattern_name` remains valid; this complements it
- **No live game-tick wiring** — planner is callable on-demand; integration into the game loop is later
- **No Super-Mars full implementation** — design considers no-moon reasoning (captured asteroid pattern) but does not implement a specific Super-Mars scenario
- **No rewriting existing systems** — `PrecursorCapabilityService` is called, not reimplemented; v2 task vocabulary is referenced, not redefined

---

## Service Skeleton

```ruby
# Entry point
options = FootholdPlanner.new(body, system_context: ctx).plan

# Lightweight checks
planner.isru_feasible?          # => Boolean
planner.local_resources         # => Array<String>
```

Patterns evaluated (all scored, sorted by score descending):
1. `surface_feature` — surface settlement on geological feature
2. `orbital_depot` — orbital depot leveraging moons/transfer points
3. `captured_asteroid` — move small asteroid into orbit and convert
4. `atmospheric` — floating platform in dense atmosphere
5. `subsurface` — subsurface ice/water exploitation
6. `hybrid` — multi-location composition (only when ≥2 patterns viable)

---

## Super-Mars / No-Moon Reasoning

The captured_asteroid pattern explicitly handles bodies with no moons:
- Checks `system_context[:asteroids]` for viable targets (mass > 100 kg, < 1e12 kg)
- Scores based on composition diversity (H2O, CO2, Fe, Ni = more ISRU pathways)
- Task sequence includes hollowing + propellant extraction + depot conversion

This is the design line in action: evaluate what's actually there, don't force a named pattern.

---

## Known Skeleton Limits

These are intentional limitations of the thin skeleton, not bugs. They are documented so future work knows where to go.

1. **Cross-pattern scores are unnormalized**
   Each pattern uses its own heuristic scale. Sorting by raw score means a body with many local resources can outrank a strategically better `captured_asteroid` option. Acceptable for this skeleton. Future ranking should normalize axes or apply context boosts (e.g. prefer `captured_asteroid` when `system_context[:moons]` is empty) rather than relying on raw score alone.

2. **v2 task sequences are vocabulary references, not registry lookups**
   Phase/task ids (`site_prep_foundation`, `deploy_lspu`, `power_comms`, etc.) match v2 naming but are hardcoded Ruby arrays, not loaded via `task_ref` from the JSON registry. Correct for a thin skeleton. Future work should resolve sequences from v2 task/phase data so composition stays data-driven.

3. **Reserved system_context keys**
   `distance_from_sun`, `parent_body`, and `nearby_nodes` are documented in the input contract but not yet read by scoring. Intentional until transport-cost estimation exists; do not treat as bugs.
