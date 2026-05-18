---

# TASK: Fix JSON Parsing in Material Lookup Service
**Status**: BACKLOG  
**Priority**: LOW  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Simple JSON parsing fix, single method, spec-driven  
**Supervision Level**: watched carefully  

---

## Context
Test failure in material lookup service JSON parsing logic.

---

## Problem Statement
**Error output**:
spec/services/lookup/material_lookup_service_spec.rb:254 (see overnight log for details)

Current behavior: JSON parsing in MaterialLookupService is incorrect
Expected behavior: JSON parsing works as intended and test passes

---

## Files Involved
- app/services/lookup/material_lookup_service.rb (JSON parsing logic)
- spec/services/lookup/material_lookup_service_spec.rb (test case)

---

## Steps
1. Run diagnostic: grep -n "json|parse" app/services/lookup/material_lookup_service.rb
2. Review and correct JSON parsing logic in MaterialLookupService
3. Refactor and test until targeted spec passes

---

## Acceptance Criteria
- The test passes and JSON parsing works as intended

---

## Stop Conditions
- All acceptance criteria met
- No regressions in parsing logic

---

## Commit Message
fix: correct JSON parsing in MaterialLookupService
