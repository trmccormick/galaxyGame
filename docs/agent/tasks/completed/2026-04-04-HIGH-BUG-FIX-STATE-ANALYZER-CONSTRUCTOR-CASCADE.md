# TASK: Fix StateAnalyzer Constructor Cascade — Update All Callers
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Fully mechanical — find callers, remove argument, verify. No inference needed.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agents: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

---

## Context

`StateAnalyzer` was rewired yesterday (Task 1, commit f7dc8e57) to remove its
hardcoded `resource_profile` hash. The new implementation takes **0 constructor
arguments** — `analyze_state(settlement)` is now an instance method called after
initialization.

Before the fix, `StateAnalyzer` was instantiated with a `shared_context` argument
in several callers. Those callers were not updated. The result is a cascade
`ArgumentError: wrong number of arguments (given 1, expected 0)` that surfaces
through `StrategySelector`, `Manager`, and any other caller that still passes
an argument to `StateAnalyzer.new`.

**The new correct signature:**
```ruby
# Correct — no args
analyzer = StateAnalyzer.new
result = analyzer.analyze_state(settlement)

# Wrong — causes ArgumentError
analyzer = StateAnalyzer.new(shared_context)  # ← remove the argument
```

---

## Problem Statement

**Error output:**
```
ArgumentError: wrong number of arguments (given 1, expected 0)
  ./app/services/ai_manager/strategy_selector.rb:12:in 'BasicObject#initialize'
  ./app/services/ai_manager/strategy_selector.rb:12:in 'Class#new'
  ./app/services/ai_manager/strategy_selector.rb:12:in 'AIManager::StrategySelector#initialize'
  ./app/services/ai_manager/manager.rb:166:in 'Class#new'
  ./app/services/ai_manager/manager.rb:166:in 'AIManager::Manager#initialize_service_coordination'
  ./app/services/ai_manager/manager.rb:20:in 'AIManager::Manager#initialize'
```

**Current behavior**: Any code path that instantiates `Manager` raises `ArgumentError`
because `Manager#initialize_service_coordination` creates a `StrategySelector`,
which creates a `StateAnalyzer.new(shared_context)`.

**Expected behavior**: All callers use `StateAnalyzer.new` with no arguments.
`analyze_state(settlement)` is called on the instance when state is needed.

---

## Files Involved

### Step 0 — Find All Callers First

Before touching anything, run:
```bash
grep -rn "StateAnalyzer.new" galaxy_game/app/services/ai_manager/
```

This is the complete list of files you must fix. Do not skip any.

Also confirm the current signature:
```bash
grep -n "def initialize\|def analyze_state" galaxy_game/app/services/ai_manager/state_analyzer.rb
```

Expected output from state_analyzer.rb:
- No `def initialize` line (uses default)
- `def analyze_state(settlement)` present

### Primary Files — you will edit these

| File | What to Change |
|---|---|
| `app/services/ai_manager/strategy_selector.rb` | Line ~12: `StateAnalyzer.new(shared_context)` → `StateAnalyzer.new` |
| Any other file returned by the grep above | Same fix: remove argument from `StateAnalyzer.new(...)` |

### Reference Files — read but do not edit

| File | Why You Need It |
|---|---|
| `app/services/ai_manager/state_analyzer.rb` | Confirms new 0-arg signature |

---

## Implementation Steps

> Follow these steps exactly in order.

### Step 1 — Run the grep diagnostic
```bash
grep -rn "StateAnalyzer.new" galaxy_game/app/services/ai_manager/
```

Record every file and line number returned. That is your fix list.

### Step 2 — Confirm state_analyzer.rb signature
```bash
grep -n "def initialize\|def analyze_state" galaxy_game/app/services/ai_manager/state_analyzer.rb
```

Confirm: no `def initialize`, and `def analyze_state(settlement)` exists.

### Step 3 — Produce Synthesis Report and STOP

Before touching any file, produce the report below and wait for approval.

### Step 4 — Apply the fix to each caller

For each file identified in Step 1, change:
```ruby
# Before
StateAnalyzer.new(shared_context)
# or
StateAnalyzer.new(@shared_context)
# or any variant with an argument

# After
StateAnalyzer.new
```

Do NOT change how `analyze_state` is called — only the constructor call.

If a caller stores the `shared_context` argument and passes it to `analyze_state`
later, that call site also needs updating:
```ruby
# Before (wrong pattern)
@state_analyzer = StateAnalyzer.new(shared_context)
@state_analyzer.analyze  # old method name

# After (correct pattern)
@state_analyzer = StateAnalyzer.new
@state_analyzer.analyze_state(settlement)  # passes settlement at call time
```

### Step 5 — Verify in isolation
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/strategy_selector_spec.rb 2>&1 | tail -5'
```

### Step 6 — Verify manager specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/manager_integration_spec.rb 2>&1 | tail -5'
```

### Step 7 — Run full ai_manager suite
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/ 2>&1 | tail -10'
```

---

## Synthesis Report Format

Produce this before applying any fix and **stop**:

```
THE FAILURE
Error: ArgumentError: wrong number of arguments (given 1, expected 0)
Triggered at: strategy_selector.rb:12 → manager.rb:166

CALLERS FOUND (grep results)
File: [path] Line: [N] — current call: StateAnalyzer.new([argument])
[repeat for each]

STATE_ANALYZER SIGNATURE CONFIRMED
def analyze_state(settlement) — present at line [N]
def initialize — [present/absent]

PROPOSED FIX
For each caller: remove argument from StateAnalyzer.new(...)
[list each change]

RISK
Low — constructor argument removal only. No logic changes.
Callers that stored shared_context solely to pass to StateAnalyzer can
have that dependency removed entirely.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Isolation** — strategy_selector_spec.rb only
2. **Manager specs** — manager_integration_spec.rb
3. **Full ai_manager suite** — spec/services/ai_manager/
4. **Full suite** — only after steps 1-3 are clean:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] `grep -rn "StateAnalyzer.new(" galaxy_game/app/services/ai_manager/` returns 0 results (all constructors are now argument-free)
- [ ] `strategy_selector_spec.rb` — 0 failures
- [ ] `manager_integration_spec.rb` — 0 `ArgumentError` failures
- [ ] Full `spec/services/ai_manager/` suite run completed
- [ ] No new failures in files not touched by this task

---

## Stop Conditions — escalate to user immediately if:
- `analyze_state` is called with wrong arity after the fix (different method signature issue)
- More than 5 callers found — report the full list before proceeding
- Any caller uses `StateAnalyzer` in a way other than `StateAnalyzer.new(...).analyze_state(...)` — report the pattern before touching it
- Fixing the constructor reveals a second broken interface (e.g., `analyze_state` called with 0 args)

---

## Commit Instructions

Run git commands on **host**, not inside container:
```bash
git add app/services/ai_manager/strategy_selector.rb
git add [any other files changed]
git commit -m "fix: state_analyzer cascade — remove shared_context arg from all StateAnalyzer.new callers"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: none
**Blocks**: all other ai_manager spec work this session
**Related tasks**: Task 1 from 2026-04-03 (state_analyzer rewire — commit f7dc8e57)

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
