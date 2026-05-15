# TASK: Fix Game#advance_by_days — Guard Clause Not Preventing Negative Time Advance
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-05-15

---

## Agent Assignment

**Assigned To**: Implementation Agent
**Why This Agent**: Single method guard clause fix, fully specified.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Game#advance_by_days` should be a no-op when called with zero or negative values. The spec confirms this intent — passing a negative value should leave `elapsed_time` unchanged. Currently the method advances time by the negative amount, resulting in `elapsed_time` going backwards.

---

## Problem Statement

**Error output:**
```
Failure/Error: expect(game.elapsed_time).to eq(initial_time)
	expected: 0.0
			 got: -2.0
# ./spec/services/game_spec.rb:77
```

**Current behavior**: `advance_by_days(-2)` advances time by -2, setting `elapsed_time` to -2.0.

**Expected behavior**: `advance_by_days(0)` and `advance_by_days(-2)` return early without changing `elapsed_time`.

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

1. Find the method definition for `advance_by_days` in the game class.
2. Add a guard clause: `return if days <= 0` as the first line of the method.
3. Confirm with spec at `spec/services/game_spec.rb:77`.

---

## Acceptance Criteria
- Guard clause prevents negative or zero day advances.
- All related specs pass.
- No regression in time advancement logic.

# 2026-04-04-MEDIUM-BUG-FIX-GAME-ADVANCE-BY-DAYS-NEGATIVE-GUARD

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Bug fix for game advance_by_days guard clause
**Supervision Level**: 🔴 Watched carefully

## Context
Game#advance_by_days should be a no-op when called with zero or negative values. Currently it advances time by negative amounts, causing elapsed_time to go backwards.

## Problem Statement
advance_by_days(-2) advances time by -2, setting elapsed_time to -2.0 instead of leaving it unchanged.

**Spec failure**: expected 0.0, got -2.0 after advance_by_days(-2)
**Expected behavior**: advance_by_days(0) and advance_by_days(-2) return early without changing elapsed_time

## Files Involved
### Primary Files — you will edit
| File | Purpose |
|---|---|
| `app/services/game.rb` OR `app/models/game.rb` | Add/fix guard clause in advance_by_days |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `spec/services/game_spec.rb` | Confirms expected behavior at line ~77 |

## Implementation Steps
1. **Find the method**: Grep for def advance_by_days
2. **Read current implementation**: Get method body and context
3. **Read failing spec**: Understand expected behavior
4. **Add guard clause**: return if days <= 0 as first line of method
5. **Verify**: Run game_spec.rb

## Acceptance Criteria
- [ ] game_spec.rb — 0 failures
- [ ] advance_by_days(0) — elapsed_time unchanged
- [ ] advance_by_days(-2) — elapsed_time unchanged
- [ ] advance_by_days(1) — still advances correctly (no regression)

## Stop Conditions
- advance_by_days not found in app/
- Guard clause already present but not working
- Adding guard breaks positive advance test

## Commit Instructions
```bash
git add app/[path]/game.rb
git commit -m "fix: game#advance_by_days — add return guard for zero or negative days argument"
```