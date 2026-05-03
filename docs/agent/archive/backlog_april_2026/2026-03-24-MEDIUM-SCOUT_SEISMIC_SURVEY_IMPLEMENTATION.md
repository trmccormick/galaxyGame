# TASK: Implement Seismic Survey Logic for Scout Ships
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: feature
**Created**: 2026-03-24
**Last Updated**: 2026-03-26

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Cross-service feature touching model, two AI manager services, and migration — requires architectural reasoning to wire seismic mode correctly into existing execute_scouting_mission without breaking surrounding logic
**Supervision Level**: 🟢 Autonomous OK

---

## Context
Scout-class ships perform scouting missions via `WormholeScoutingService`. The AI Manager uses scouting results to evaluate asteroid conversion candidates via `StationCostBenefitAnalyzer`. This task adds a seismic survey mode that classifies asteroids as Rubble Piles or Solid Anchors — a mandatory prerequisite for the AI Manager's Asteroid Conversion strategy. Without this classification, the cost-benefit analyzer cannot safely approve Eden AWS Anchor placement.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/systems/asteroid_conversion_physics.md` — physics thresholds for structural integrity and thermal risk classification
- `docs/architecture/systems/survey_and_handshake_protocol.md` — survey result handshake format between scouting and AI manager
- `docs/developer/WORMHOLE_SCOUTING_INTEGRATION.md` — integration pattern for WormholeScoutingService extensions

> If a doc doesn't exist for this area, do not create one during this task.
> Flag the gap in your completion report instead.

---

## Problem Statement
Scout ships have no seismic survey capability. The AI Manager's Asteroid Conversion strategy requires structural integrity data before approving an asteroid as an Eden AWS Anchor candidate. Currently `StationCostBenefitAnalyzer` has no way to reject low-integrity asteroids because that data is never collected.

**Current behavior**: `WormholeScoutingService#execute_scouting_mission` has no seismic mode. Asteroids have no `structural_integrity_score` or `surveyed_at` fields. `StationCostBenefitAnalyzer` cannot filter on integrity.

**Expected behavior**: When called with `:seismic_mode`, the scouting mission classifies the asteroid's structural integrity and thermal risk. The analyzer rejects any asteroid with `integrity_score < 0.5` for Eden AWS Anchor placement.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/models/asteroid.rb` | Asteroid model | add new fields after migration |
| `app/services/ai_manager/wormhole_scouting_service.rb` | Scouting mission execution | `#execute_scouting_mission` line ~52 |
| `app/services/ai_manager/station_cost_benefit_analyzer.rb` | Asteroid candidate evaluation | `#analyze` line — grep for Eden/anchor logic |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/architecture/systems/asteroid_conversion_physics.md` | Source of truth for density/ice/integrity thresholds |
| `docs/architecture/systems/survey_and_handshake_protocol.md` | Required handshake format for survey results |
| `docs/developer/WORMHOLE_SCOUTING_INTEGRATION.md` | Established pattern for extending scouting service |

### Migration
- [ ] Migration needed: add `surveyed_at` (datetime) and `structural_integrity_score` (float) to asteroids table
```bash
  docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rails generate migration AddSeismicFieldsToAsteroids surveyed_at:datetime structural_integrity_score:float'
```
  Review the generated migration before running it. Then:
```bash
  docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rails db:migrate'
  docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'
```

---

## Implementation Steps

> 1x agent: use as a guide, apply judgment. Read all three reference docs before touching any file.

### Step 1 — Generate and run migration
Generate migration as shown above. Verify schema.rb reflects both new columns before proceeding.

### Step 2 — Add seismic fields to Asteroid model
Add any necessary validations or scopes for `structural_integrity_score` and `surveyed_at`. Check existing model for established patterns before adding.

### Step 3 — Add seismic mode to WormholeScoutingService
Inside `#execute_scouting_mission` (line ~52), add a conditional block for `:seismic_mode`. Logic per `asteroid_conversion_physics.md`:
```ruby
# seismic mode classification
if mode == :seismic_mode
  integrity_score = asteroid.density < 1.5 ? rand(0.0..0.2) : rand(0.5..1.0)
  thermal_risk = asteroid.composition&.fetch('ice_percentage', 0).to_f > 20.0

  asteroid.update!(
    structural_integrity_score: integrity_score,
    surveyed_at: Time.current,
    metadata: asteroid.metadata.merge(
      'thermal_risk' => thermal_risk,
      'classification' => integrity_score < 0.2 ? 'rubble_pile' : 'solid_anchor'
    )
  )
end
```

> Verify the exact field names and composition data structure against the actual Asteroid model and existing scouting result format before applying. Adjust if the model uses different accessors.

### Step 4 — Add integrity gate to StationCostBenefitAnalyzer
Locate the Eden AWS Anchor evaluation logic in `station_cost_benefit_analyzer.rb`. Add a rejection condition:
```ruby
# Reject asteroids with insufficient structural integrity
if asteroid.structural_integrity_score.present? && asteroid.structural_integrity_score < 0.5
  return rejection_result('structural_integrity_below_threshold')
end
```

Match the existing rejection pattern used elsewhere in the analyzer — do not invent a new return format.

### Step 5 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/wormhole_scouting_service_spec.rb'
```

---

## Synthesis Report Format
Before applying any fix, produce a report in this format and **stop**:
```
THE TASK
Target files: [list]
Insertion points confirmed: [yes/no — list method names and line numbers]
Migration verified: [yes/no]

PROPOSED IMPLEMENTATION
[brief description of each change]

RISKS
[any shared code affected, any pattern deviations]

READY TO APPLY? — waiting for approval
```

Do not apply anything until the user explicitly approves.

---

## Testing Sequence

> Run in this order. Do not skip steps.

1. **Isolation run** — scouting service spec:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/wormhole_scouting_service_spec.rb'
```

2. **Related specs** — AI manager service layer:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
```

3. **Full suite** — only after steps 1 and 2 are green:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] Migration runs cleanly on both dev and test databases
- [ ] `Asteroid` model has `structural_integrity_score` and `surveyed_at` fields
- [ ] `execute_scouting_mission` with `:seismic_mode` sets integrity score and thermal risk correctly
- [ ] Asteroids with `integrity_score < 0.5` are rejected by `StationCostBenefitAnalyzer` for Eden AWS Anchor
- [ ] Isolation run: 0 failures
- [ ] No regressions in `spec/services/ai_manager/`
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Migration generates unexpected schema changes beyond the two new columns
- `execute_scouting_mission` signature or mode-handling pattern differs significantly from what this task assumes
- `StationCostBenefitAnalyzer` rejection pattern is not obvious — do not invent a new one
- Fix causes new failures in specs you did not touch
- Same failure persists after two attempts
- Any architectural decision is required beyond what the reference docs cover

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add app/models/asteroid.rb
git add app/services/ai_manager/wormhole_scouting_service.rb
git add app/services/ai_manager/station_cost_benefit_analyzer.rb
git add db/migrate/[timestamp]_add_seismic_fields_to_asteroids.rb
git add db/schema.rb
git commit -m "feature: asteroid seismic survey — add structural integrity classification and analyzer gate"
git push
```

---

## Documentation
- [ ] No additional doc changes needed — reference docs already cover this feature

---

## Dependencies
**Blocked by**: none
**Blocks**: AI Manager Asteroid Conversion strategy tasks
**Related tasks**: none known

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed

### Issues discovered

### Follow-up tasks needed

### Lessons learned