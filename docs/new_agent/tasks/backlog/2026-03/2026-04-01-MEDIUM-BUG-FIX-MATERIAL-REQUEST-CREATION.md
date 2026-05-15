---

# TASK: Fix MaterialRequest Creation Status Enum
**Status**: BACKLOG  
**Priority**: MEDIUM  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Model fix, enum validation, spec-driven  
**Supervision Level**: watched carefully  

---

## Context
Test failures due to invalid status values when creating MaterialRequest records.

---

## Problem Statement
**Error output**: ArgumentError: 'fulfilled_by_player' is not a valid status

Current behavior: Invalid status values used for MaterialRequest
Expected behavior: Only valid status values are used

---

## Files Involved
- app/models/material_request.rb (enum definition)
- spec/models/construction_job_spec.rb (test cases)

---

## Steps
1. Run diagnostic: grep -n "fulfilled_by_player|status" app/models/material_request.rb
2. Review and correct status enum values
3. Refactor and test until both targeted specs pass

---

## Acceptance Criteria
- Only valid status values are used for MaterialRequest
- Both tests pass and no related regressions are introduced

---

## Stop Conditions
- All acceptance criteria met
- No regressions in MaterialRequest logic

---

## Commit Message
fix: use valid status enum for MaterialRequest
