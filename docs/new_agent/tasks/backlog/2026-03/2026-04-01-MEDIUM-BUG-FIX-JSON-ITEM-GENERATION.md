---

# TASK: Fix JSON Item Generation in Game Data Generator
**Status**: BACKLOG  
**Priority**: MEDIUM  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Model fix, single generator, spec-driven  
**Supervision Level**: watched carefully  

---

## Context
Test failure in game data generator JSON item generation logic.

---

## Problem Statement
**Error output**: See overnight log for details.

Current behavior: JSON item generation logic is incorrect
Expected behavior: JSON item generation works as intended

---

## Files Involved
- lib/generators/game_data_generator.rb (generation logic)
- spec/lib/generators/game_data_generator_spec.rb (test case)

---

## Steps
1. Run diagnostic: grep -n "json|item|generate" lib/generators/game_data_generator.rb
2. Review and correct JSON item generation logic
3. Refactor and test until targeted spec passes

---

## Acceptance Criteria
- The test passes and JSON item generation works as intended

---

## Stop Conditions
- All acceptance criteria met
- No regressions in item generation

---

## Commit Message
fix: correct JSON item generation in GameDataGenerator
