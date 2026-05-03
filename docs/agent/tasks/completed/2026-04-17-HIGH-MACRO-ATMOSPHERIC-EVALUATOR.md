# Atmospheric Evaluator (TerraSim Extension)

**Layer:** PLANETARY SIMULATION (TerraSim)
**Created:** 2026-04-17
**Priority:** HIGH
**Status:** TODO

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Requires explicit integration with simulation cycles and event logic, needs careful audit
**Supervision Level**: watched carefully

---

## Scope
Implement an Atmospheric Evaluator as a TerraSim extension/service. This module will monitor atmospheric retention (how well a planet retains its atmosphere), calculate and expose a retention metric, and trigger seasonal and dust storm events based on planetary and atmospheric state. It must integrate with existing TerraSim simulation cycles and support RSpec coverage for all logic.

## Target Files
- galaxy_game/app/services/terra_sim/atmospheric_evaluator_service.rb
- galaxy_game/spec/services/terra_sim/atmospheric_evaluator_service_spec.rb

## Acceptance Criteria
- Retention metric is calculated and exposed for any simulated planet
- Seasonal and dust storm event triggers are implemented based on planetary/atmospheric state
- Integrates with TerraSim simulation cycles (e.g., called from PlanetUpdateService)
- RSpec: full coverage for retention and event logic
- No duplication with existing TerraSim or planetary simulation logic

## Implementation Steps
1. Audit TerraSim and docs for any existing retention/event logic. STOP if found—refactor/extend instead of duplicating.
2. Create atmospheric_evaluator_service.rb with methods for:
   - retention_rate: returns a metric (0-1 or %) for atmospheric retention
   - trigger_events: triggers seasonal/dust storm events based on state
3. Integrate with PlanetUpdateService or appropriate TerraSim cycle
4. Write/extend RSpec for all logic branches and edge cases
5. Document formulas/assumptions in code comments and, if needed, in /docs/systems/ or /docs/agent/

## Stop Conditions
- Any existing implementation or task is found—STOP and refactor/extend instead
- Requirements are unclear or overlap with other TerraSim logic—STOP and clarify

## Risks
- Overlap with future TerraSim atmospheric modules
- Event triggers may require additional planetary state modeling

## Commit Instructions
```
git add docs/agent/tasks/backlog/2026-04-17-HIGH-MACRO-ATMOSPHERIC-EVALUATOR.md galaxy_game/app/services/terra_sim/atmospheric_evaluator_service.rb galaxy_game/spec/services/terra_sim/atmospheric_evaluator_service_spec.rb
mv docs/agent/tasks/backlog/2026-02-11-HIGH-MACRO-ATMOSPHERIC-EVALUATOR.md docs/agent/tasks/backlog/old/
git commit -m "feat: add TerraSim Atmospheric Evaluator for retention and event triggers"
git push
```
