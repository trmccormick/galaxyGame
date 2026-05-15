# 2026-04-01-LOW-BUG-FIX-ADVANCE-BY-DAYS-GUARD

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Bug fix in game advance-by-days guard logic
**Supervision Level**: 🔴 Watched carefully

## Context
Game model has advance-by-days functionality with guard logic that is failing tests.

## Problem Statement
Test failure in game advance-by-days guard logic.

**Spec:** spec/models/game_spec.rb:72
**Error:** Guard logic not working correctly

## Files Involved
### Primary Files — you will edit
| File | Purpose | Key Method |
|---|---|---|
| `app/models/game.rb` | Game model | `#advance_by_days` |
| `spec/models/game_spec.rb` | Test cases | line 72 |

## Implementation Steps
1. **Diagnostic:** Grep for advance_by_days and guard logic in Game model
2. **Fix:** Correct guard logic in Game#advance_by_days
3. **Test:** Run targeted spec

## Acceptance Criteria
- [ ] Targeted test passes (line 72)
- [ ] Advance-by-days guard logic works correctly
- [ ] No regressions in game advancement functionality

## Stop Conditions
- Guard logic requires broader game state refactoring
- Changes affect other game advancement features

## Commit Instructions
```bash
git add app/models/game.rb spec/models/game_spec.rb
git commit -m "fix: Game advance_by_days guard logic bug"
```