# TASK: Controller Specs — Count Mismatches and Invalid Response Codes
**Status**: DECOMPOSED
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-05-12
**Last Updated**: 2026-05-12
**Decomposed**: 2026-05-12

---

## Task Decomposition Notice

**This monolithic task has been decomposed into smaller, executable units** to enable GPT-4.1 participation and improve efficiency.

### Decomposition Rationale
- Original task was too large for single-agent execution
- Investigation phase can be automated by GPT-4.1
- Human judgment still required for synthesis and risk assessment
- Implementation can be executed by GPT-4.1 with approved strategy

### New Task Structure
- **Task A**: Investigation Phase (GPT-4.1 - 0.5x)
- **Task B**: Synthesis & Approval (Human)
- **Task C**: Implementation Phase (GPT-4.1 - 0.75x)

### Archived Location
This task has been archived to: `docs/agent/tasks/deprecated/2026-05-12-MEDIUM-BUGFIX-CONTROLLER-SPEC-COUNT-MISMATCHES.md`

---

## Original Task Content (Preserved for Reference)

---

## Context
Four controller specs are failing with count mismatches and an unexpected
response code. The count mismatches (expected 5, got 21 / expected 3, got 19 /
expected 2, got 12) strongly suggest factory-created records from other tests
are leaking into these specs. The 422 vs 200 issue is a separate validation
response problem.

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

**Current behavior**: Counts inflated by leaked records; invalid params returns 200 instead of 422
**Expected behavior**: Counts match spec setup; invalid params returns 422

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

### Step 5 — Produce Synthesis Report and STOP
```
SYNTHESIS REPORT

COUNT MISMATCHES (3 failures):
Root cause: [database isolation / query scope / both]
Spec creates N records, query returns M — why the difference:
Fix direction: [add scope to controller query OR add cleanup to spec]

422 vs 200 (1 failure):
Controller update action with invalid params: [what does it render]
Validation failing: [YES/NO]
Fix direction: [add render :unprocessable_entity OR fix validation]

Recommended fix order:
1. [first fix]
2. [second fix]

Risk: [shared factories or controllers affected]
Questions: [anything unclear]
```
Wait for approval before changing anything.

### Step 6 — Apply fixes
Address count mismatches and 422 response separately.
Do not change controller behavior beyond what the specs require.

### Step 7 — Verify all four specs
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/ 2>&1 | tail -15'
```

### Step 8 — Commit from host
```bash
git add [specific files only]
git commit -m "fix: controller specs — resolve count mismatches and 422 response for invalid params"
git push
```

---

## Acceptance Criteria
- [ ] `map_studio_controller_spec.rb` lines 32 and 51 pass
- [ ] `game_controller_spec.rb` line 92 passes
- [ ] `terrestrial_planets_spec.rb` line 105 passes
- [ ] No regressions in other controller specs

## Stop Conditions
- Count mismatch caused by a missing `DatabaseCleaner` strategy — escalate, do not add it without review
- 422 fix requires adding a rescue block or changing model validations — escalate
- Fix affects more than 2 controller files — escalate

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
