*** MOVED TO ../completed/2026-04-04-HIGH-BUG-FIX-AIMANAGER-TESTING-FILES-REMOVE-FROM-APP-AUTOLOAD.md ***
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: File moves only, no logic changes needed.
**Supervision Level**: 🔴 Watched carefully

---

## Context

Four agent-invented testing files exist in `app/services/ai_manager/testing/`:
- `sandbox_environment.rb`
- `bootstrap_controller.rb`
- `performance_monitor.rb`
- `validation_suite.rb`

Because they live in `app/`, Rails autoloads them in all environments including
test. `sandbox_environment.rb` monkey-patches `ActiveRecord::Base` via
`setup_mock_database`, contaminating the test suite. This causes
`FittingService` to fail with:

```
NoMethodError: undefined method 'double' for class Units::Battery
```

`double` is an RSpec method that only exists in spec context —
`sandbox_environment.rb` is injecting it into production `ActiveRecord::Base`.

**These files are NOT the digital twin system.** The real digital twin system
(Phase 4, Redis-based, cloning planetary data) has not been built yet. These
files are agent-invented testing infrastructure with no callers in production
code and no connection to `DigitalTwin` models or services.

**Confirmed:**
```bash
grep -rn "SandboxEnvironment\|bootstrap_controller\|performance_monitor\|validation_suite" \
  galaxy_game/app/ --include="*.rb" | grep -v "testing/"
# Returns: 0 results (nothing calls these files)
```

---

## Problem Statement

**Error output:**
```
NoMethodError: undefined method 'double' for class Units::Battery
# app/services/ai_manager/testing/sandbox_environment.rb:245
# app/services/fitting_service.rb:129 (klass.create)
```

**Current behavior**: Rails autoloads `sandbox_environment.rb` which
monkey-patches `ActiveRecord::Base.create` with an RSpec `double()` call,
breaking any real `create` call in test context.

**Expected behavior**: Testing utilities never loaded in production or test
context unless explicitly required. `FittingService` creates real records.

---

## Files Involved

### Files to move — do NOT delete yet
| Current Location | Move To |
|---|---|
| `app/services/ai_manager/testing/sandbox_environment.rb` | `spec/support/ai_manager/sandbox_environment.rb` |
| `app/services/ai_manager/testing/bootstrap_controller.rb` | `spec/support/ai_manager/bootstrap_controller.rb` |
| `app/services/ai_manager/testing/performance_monitor.rb` | `spec/support/ai_manager/performance_monitor.rb` |
| `app/services/ai_manager/testing/validation_suite.rb` | `spec/support/ai_manager/validation_suite.rb` |

Move, do not delete — preserve for reference in case any logic is needed
for the real digital twin system later.

### Files to verify after move
| File | Why |
|---|---|
| `app/services/fitting_service.rb` | Should work correctly after contamination removed |
| `spec/services/fitting_service_spec.rb` | Should pass after move |

---

## Implementation Steps

### Step 1 — Confirm no callers in app/
```bash
grep -rn "SandboxEnvironment\|AIManager::Testing\|bootstrap_controller\|performance_monitor\|validation_suite" \
  galaxy_game/app/ --include="*.rb" | grep -v "testing/"
```

Expected: 0 results. If any callers found — STOP and report before proceeding.

### Step 2 — Create target directory
```bash
mkdir -p galaxy_game/spec/support/ai_manager/
```

### Step 3 — Move all four files
```bash
mv galaxy_game/app/services/ai_manager/testing/sandbox_environment.rb \
   galaxy_game/spec/support/ai_manager/
mv galaxy_game/app/services/ai_manager/testing/bootstrap_controller.rb \
   galaxy_game/spec/support/ai_manager/
mv galaxy_game/app/services/ai_manager/testing/performance_monitor.rb \
   galaxy_game/spec/support/ai_manager/
mv galaxy_game/app/services/ai_manager/testing/validation_suite.rb \
   galaxy_game/spec/support/ai_manager/
```

### Step 4 — Remove empty directory
```bash
rmdir galaxy_game/app/services/ai_manager/testing/
```

### Step 5 — Verify FittingService specs pass
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  spec/services/fitting_service_spec.rb 2>&1 | grep "examples,"'
```

Expected: 0 failures.

### Step 6 — Confirm no regressions
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  spec/services/ai_manager/ 2>&1 | grep "examples,"'
```

---

## Synthesis Report Format

```
CALLERS CONFIRMED
grep result: [0 results or list any found]

FILES TO MOVE
[list all 4 with source and destination paths]

RISK
Low — no callers in production code. Files preserved in spec/support for reference.
The monkey-patch on ActiveRecord::Base will be removed from autoload path.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. `fitting_service_spec.rb` — should clear 2 failures
2. `spec/services/ai_manager/` — no regressions
3. Full suite grep to confirm improvement:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1 && \
  grep "examples," /home/galaxy_game/log/rspec_full_*.log | tail -1'
```

---

## Acceptance Criteria
- [ ] All 4 files moved to `spec/support/ai_manager/`
- [ ] `app/services/ai_manager/testing/` directory removed
- [ ] `fitting_service_spec.rb` — 0 failures
- [ ] No regressions in ai_manager suite
- [ ] No `NoMethodError: undefined method 'double'` anywhere in test output

---

## Stop Conditions
- Any caller found in `app/` — report before moving anything
- Moving files causes a NameError for a constant that was being used — report
- `fitting_service_spec.rb` still fails after move — report exact new error

---

## Important Note — Digital Twin System
These files are NOT the digital twin sandbox. The real digital twin system
is a Phase 4 initiative (Redis-based, cloning planetary data) that has not
been built yet. Do not confuse these agent-invented files with that design.
See: `docs/architecture/` for the real digital twin spec.

---

## Commit Instructions
```bash
git add galaxy_game/spec/support/ai_manager/
git rm galaxy_game/app/services/ai_manager/testing/sandbox_environment.rb
git rm galaxy_game/app/services/ai_manager/testing/bootstrap_controller.rb
git rm galaxy_game/app/services/ai_manager/testing/performance_monitor.rb
git rm galaxy_game/app/services/ai_manager/testing/validation_suite.rb
git commit -m "fix: move ai_manager testing files from app/ to spec/support — remove Rails autoload contamination"
git push
```

---

## Dependencies
**Blocked by**: none — simple file move
**Blocks**: `fitting_service_spec.rb` (2 failures clear after this)
**Related tasks**: Digital twin system (Phase 4, separate initiative)

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
