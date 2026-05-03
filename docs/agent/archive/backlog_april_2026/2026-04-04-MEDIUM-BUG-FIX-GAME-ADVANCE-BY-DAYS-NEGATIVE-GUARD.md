# TASK: Fix Game#advance_by_days — Guard Clause Not Preventing Negative Time Advance
**Status**: ACTIVE
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single method guard clause fix, fully specified.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Game#advance_by_days` should be a no-op when called with zero or negative
values. The spec confirms this intent — passing a negative value should leave
`elapsed_time` unchanged. Currently the method advances time by the negative
amount, resulting in `elapsed_time` going backwards.

---

## Problem Statement

**Error output:**
```
Failure/Error: expect(game.elapsed_time).to eq(initial_time)
  expected: 0.0
       got: -2.0
# ./spec/services/game_spec.rb:77
```

**Current behavior**: `advance_by_days(-2)` advances time by -2, setting
`elapsed_time` to -2.0.

**Expected behavior**: `advance_by_days(0)` and `advance_by_days(-2)` return
early without changing `elapsed_time`.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `app/services/game.rb` OR `app/models/game.rb` | Add/fix guard clause in `advance_by_days` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `spec/services/game_spec.rb` | Confirms expected behavior at line ~77 |

---

## Implementation Steps

### Step 1 — Find the method
```bash
grep -rn "def advance_by_days" galaxy_game/app/
```

### Step 2 — Read the current implementation
```bash
sed -n '[LINE-5],[LINE+15]p' galaxy_game/app/[path]/game.rb
```
Replace `[LINE]` with the line number from Step 1.

### Step 3 — Read the failing spec context
```bash
sed -n '70,85p' galaxy_game/spec/services/game_spec.rb
```

### Step 4 — Produce Synthesis Report and STOP

### Step 5 — Add or fix the guard clause

```ruby
# Before (missing or broken guard)
def advance_by_days(days)
  self.elapsed_time += days
  # ...
end

# After (correct guard)
def advance_by_days(days)
  return if days <= 0
  self.elapsed_time += days
  # ...
end
```

The guard `return if days <= 0` covers both zero and negative cases.

### Step 6 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/game_spec.rb 2>&1 | grep "examples,"'
```

---

## Synthesis Report Format

```
THE FAILURE
Spec: game_spec.rb:77
Error: expected 0.0, got -2.0 after advance_by_days(-2)

METHOD LOCATION
File: [path] line [N]

CURRENT IMPLEMENTATION
[paste current method body]

PROPOSED FIX
Add: return if days <= 0
Position: first line of method body

RISK
Low — guard clause only. No logic changes to the advance path.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/game_spec.rb 2>&1 | grep "examples,"'
```

2. Confirm no regressions — there are no other game specs expected, but verify:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/game* spec/services/game* 2>&1 | grep "examples,"'
```

---

## Acceptance Criteria
- [ ] `game_spec.rb` — 0 failures
- [ ] `advance_by_days(0)` — elapsed_time unchanged
- [ ] `advance_by_days(-2)` — elapsed_time unchanged
- [ ] `advance_by_days(1)` — still advances correctly (no regression)

---

## Stop Conditions
- `advance_by_days` not found in `app/` — report location before proceeding
- Guard clause already present but not working — report the exact current code
- Adding guard breaks a positive advance test — report before attempting further fixes

---

## Commit Instructions
```bash
git add galaxy_game/app/[path]/game.rb
git commit -m "fix: game#advance_by_days — add return guard for zero or negative days argument"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: nothing
**Related tasks**: none

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
