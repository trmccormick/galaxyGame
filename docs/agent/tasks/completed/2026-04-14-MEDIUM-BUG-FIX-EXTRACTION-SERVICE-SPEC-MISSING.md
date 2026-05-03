# TASK: Create Missing Spec for ExtractionService Argon Logic
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-14
**Last Updated**: 2026-04-14

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Spec creation, fully specified, no architectural decisions required.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`ExtractionService#extract_argon_on_mars` was refactored on 2026-04-14 as part
of the Phase 1 Sol world names data-driven refactor. The hardcoded Mars name
check was replaced with an atmosphere composition threshold check:

```ruby
body = settlement.location&.celestial_body
return false unless body&.atmosphere_composition&.dig('Ar').to_f > 0.01
```

No spec file exists for this service. The refactor is unverified by tests.
This task creates the missing spec covering the new logic.

**Do not modify `extraction_service.rb` during this task.** Spec only.

---

## Problem Statement

**Current behavior**: `spec/services/extraction_service_spec.rb` does not exist.
**Expected behavior**: Spec exists and covers the argon threshold logic with
passing examples.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `spec/services/extraction_service_spec.rb` | Create this file |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/extraction_service.rb` | Full service — read before writing specs |
| `spec/factories/settlement/base_settlement.rb` | Factory structure for settlement |
| `spec/factories/celestial_bodies/` | Factory structure for celestial bodies |

---

## Implementation Steps

### Step 1 — Read the full service file
```bash
cat galaxy_game/app/services/extraction_service.rb
```
Report the full method signatures and any other methods in the file.
Do not write a single line of spec until you have read the full service.

### Step 2 — Check existing factories
```bash
ls galaxy_game/spec/factories/
ls galaxy_game/spec/factories/celestial_bodies/ 2>/dev/null
grep -rn "atmosphere_composition\|atmosphere" galaxy_game/spec/factories/ | head -20
```

Report what factories are available for celestial bodies and whether
atmosphere_composition can be set via factory or requires a mock.

### Step 3 — Check existing service specs for patterns
```bash
ls galaxy_game/spec/services/
cat galaxy_game/spec/services/ai_manager/depot_adapter_spec.rb 2>/dev/null | head -40
```

Use the existing spec style and patterns — do not invent a new style.

### Step 4 — Write the spec

Cover these cases for `extract_argon_on_mars`:

1. **Returns false when settlement has no location**
   - `settlement.location` returns nil

2. **Returns false when location has no celestial body**
   - `settlement.location.celestial_body` returns nil

3. **Returns false when atmosphere_composition has no Ar key**
   - Body exists, `atmosphere_composition` returns `{}` or `{ 'N2' => 99.0 }`

4. **Returns false when Ar is below threshold**
   - `atmosphere_composition` returns `{ 'Ar' => 0.005 }` (below 0.01)

5. **Returns false when Ar is exactly at threshold**
   - `atmosphere_composition` returns `{ 'Ar' => 0.01 }` (not strictly greater)

6. **Proceeds past the guard when Ar is above threshold**
   - `atmosphere_composition` returns `{ 'Ar' => 0.019 }` (Mars-like)
   - This case tests that the guard passes — mock or stub remaining
     method body as needed to prevent database calls

Use instance_double or allow_any_instance_of for celestial body mocks
if factories are not practical. Keep mocks minimal — test the guard
logic, not the full extraction pipeline.

### Step 5 — Run the spec in isolation
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/extraction_service_spec.rb 2>&1 | tail -10'
```

Expected: all examples pass, 0 failures.

### Step 6 — Run related specs to check for regressions
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ 2>&1 | tail -5'
```

Report summary line only.

---

## Synthesis Report Format
SERVICE METHODS FOUND
[list all public methods in extraction_service.rb]
FACTORIES AVAILABLE
[list what can be used for settlement and celestial body]
SPEC PATTERN
[one line — which existing spec file you are matching style to]
PROPOSED SPEC OUTLINE
[list the 6 describe/it blocks with one line each]
RISK
[any shared code or factory that could cause side effects]
READY TO APPLY? — waiting for approval

---

## Acceptance Criteria
- [ ] `spec/services/extraction_service_spec.rb` exists
- [ ] All 6 cases covered
- [ ] Isolation run: 0 failures
- [ ] No regressions in related service specs
- [ ] Spec style matches existing service specs

## Stop Conditions — escalate immediately if:
- `extraction_service.rb` has been modified since 2026-04-14 — flag before writing spec
- Factory for celestial body requires database writes that cause transaction issues —
  use mocks instead, flag in completion report
- More than 2 spec failures after two attempts — escalate, do not attempt a third fix

---

## Commit Instructions
```bash
git add spec/services/extraction_service_spec.rb
git commit -m "test: add missing spec for ExtractionService argon atmosphere threshold guard"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: none
**Related tasks**: `2026-04-12-MEDIUM-BUG-FIX-PHASE1-SOL-WORLD-NAMES-DATA-DRIVEN.md`

---

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned