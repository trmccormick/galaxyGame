---

# TASK: Fix Regolith Geoshere Item Handling
**Status**: BACKLOG  
**Priority**: MEDIUM  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Model fix, single item handling, spec-driven  
**Supervision Level**: watched carefully  

---

## Context
Test failure related to regolith geoshere item handling/registration.

---

## Problem Statement
**Error output**: See test logs for details.

Current behavior: Regolith geoshere item not handled/registered correctly
Expected behavior: Item is handled/registered as expected

---

## Files Involved
- app/models/item.rb (item handling)
- spec/models/item_spec.rb (test case)

---

## Steps
1. Run diagnostic: grep -n "geosphere|celestial_body" spec/models/item_spec.rb:290 app/models/item.rb
2. Check for nil or missing delegation in geosphere/composition access
3. Use safe navigation: item.celestial_body&.geosphere&.composition
4. Refactor and test until targeted spec passes

---

## Acceptance Criteria
- The regolith geoshere item is handled/registered as expected
- The test passes and no related regressions are introduced

---

## Stop Conditions
- All acceptance criteria met
- No regressions in item handling

---

## Commit Message
fix: handle regolith geoshere item registration
