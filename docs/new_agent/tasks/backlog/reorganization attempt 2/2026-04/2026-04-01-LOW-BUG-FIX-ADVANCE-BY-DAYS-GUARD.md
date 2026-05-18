---

# TASK: Fix Advance By Days Guard Logic
**Status**: BACKLOG  
**Priority**: LOW  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Simple guard logic fix, single method, spec-driven  
**Supervision Level**: watched carefully  

---

## Context
Test failure in game advance-by-days guard logic.

---

## Problem Statement
**Error output**:
spec/models/game_spec.rb:72 (see overnight log for details)

Current behavior: Guard logic in Game#advance_by_days is incorrect
Expected behavior: Guard logic is correct and test passes

---

## Files Involved
- app/models/game.rb (guard logic)
- spec/models/game_spec.rb (test case)

---

## Steps
1. Run diagnostic: grep -n "advance_by_days|guard" app/models/game.rb
2. Review and correct guard logic in Game#advance_by_days
3. Refactor and test until targeted spec passes

---

## Acceptance Criteria
- The test passes and advance-by-days guard logic is correct

---

## Stop Conditions
- All acceptance criteria met
- No regressions in advance logic

---

## Commit Message
fix: correct advance-by-days guard logic in Game model
