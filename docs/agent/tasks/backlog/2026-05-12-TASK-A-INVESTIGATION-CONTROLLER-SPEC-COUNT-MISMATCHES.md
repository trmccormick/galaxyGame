# TASK A: Controller Specs Investigation Phase
**Status**: READY
**Priority**: HIGH
**Type**: investigation
**Created**: 2026-05-12
**Parent Task**: 2026-05-12-MEDIUM-BUGFIX-CONTROLLER-SPEC-COUNT-MISMATCHES (decomposed)

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0.5x)
**Why This Agent**: Systematic data collection and pattern analysis work
**Supervision Level**: 🟡 Moderate oversight

---

## Context
Part of decomposed controller spec fix task. This phase focuses on investigation and data collection only.

---

## Problem Statement

**Failure 1 — MapStudioController celestial bodies count:**
```
expected: 5
     got: 21
spec/controllers/admin/map_studio_controller_spec.rb:35
```

**Failure 2 — MapStudioController target planets:**
```
expected: 3
     got: 19
spec/controllers/admin/map_studio_controller_spec.rb:55
```

**Failure 3 — GameController planet count:**
```
expected: 2
     got: 12
spec/controllers/game_controller_spec.rb:94
```

**Failure 4 — TerrestrialPlanetsController invalid params response:**
```
expected: :unprocessable_entity (422)
     got: :ok (200)
spec/controllers/terrestrial_planets_spec.rb:108
```

---

## Files Involved

### Primary Files
| File | Purpose |
|---|---|
| `spec/controllers/admin/map_studio_controller_spec.rb` | Count mismatch failures |
| `spec/controllers/game_controller_spec.rb` | Planet count mismatch |
| `spec/controllers/terrestrial_planets_spec.rb` | 422 vs 200 response |

### Reference Files
| File | Why |
|---|---|
| `app/controllers/admin/map_studio_controller.rb` | Understand how count is queried |
| `app/controllers/game_controller.rb` | Understand planet_count query |
| `app/controllers/terrestrial_planets_controller.rb` | Understand validation response |

---

## Implementation Steps

### Step 1 — Run all four failing specs and capture full output
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/admin/map_studio_controller_spec.rb:32 spec/controllers/admin/map_studio_controller_spec.rb:51 spec/controllers/game_controller_spec.rb:92 spec/controllers/terrestrial_planets_spec.rb:105 2>&1'
```

### Step 2 — Check database isolation in count specs
For each count spec read:
- How many records does the spec create in `let` or `before` blocks
- Does the spec use `DatabaseCleaner` or `around(:each)`
- Is there a `described_class.delete_all` or scope limiting the count query

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && cat spec/controllers/admin/map_studio_controller_spec.rb | head -60'
```
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && cat spec/controllers/game_controller_spec.rb | head -60'
```

### Step 3 — Check controller query scope
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && grep -n "celestial_bodies_count\|target_planets\|planet_count" app/controllers/admin/map_studio_controller.rb app/controllers/game_controller.rb'
```

### Step 4 — Check validation response for terrestrial planets
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && grep -n "render\|respond_to\|unprocessable\|422" app/controllers/terrestrial_planets_controller.rb'
```
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && sed -n "100,115p" spec/controllers/terrestrial_planets_spec.rb'
```

### Step 5 — Produce Investigation Report
```
INVESTIGATION REPORT

COUNT MISMATCH ANALYSIS (3 failures):

Spec: map_studio_controller_spec.rb:35
- Records created in spec: [count]
- Database isolation: [YES/NO - details]
- Controller query scope: [details]

Spec: map_studio_controller_spec.rb:55
- Records created in spec: [count]
- Database isolation: [YES/NO - details]
- Controller query scope: [details]

Spec: game_controller_spec.rb:94
- Records created in spec: [count]
- Database isolation: [YES/NO - details]
- Controller query scope: [details]

VALIDATION RESPONSE ANALYSIS (1 failure):

Spec: terrestrial_planets_spec.rb:108
- Controller action: [update/create]
- Validation logic: [present/missing]
- Response rendering: [details]

EVIDENCE OF DATA LEAKAGE:
- [Specific findings about record leakage between tests]

POTENTIAL ROOT CAUSES:
1. [Database isolation issue]
2. [Query scope issue]
3. [Factory leakage]
```

---

## Acceptance Criteria
- [ ] All four failing specs run and output captured
- [ ] Spec setup analysis complete (record counts, isolation patterns)
- [ ] Controller query analysis complete
- [ ] Validation logic analysis complete
- [ ] Investigation report produced with findings

## Stop Conditions
- Cannot access required files or run commands
- Investigation reveals complex interdependencies requiring human judgment

## Completion Report
**Completed by**:
**Completion date**:
**Deliverable**: Complete investigation report
**Next Step**: Human synthesis phase (Task B)