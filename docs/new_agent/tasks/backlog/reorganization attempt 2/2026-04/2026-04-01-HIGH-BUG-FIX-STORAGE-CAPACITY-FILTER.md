---

# TASK: Fix Storage Capacity Filter in Space Station
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Targeted model fix, single filter logic, spec-driven  
**Supervision Level**: watched carefully  

---

## Context
Test failure in space station storage capacity filtering logic.

---

## Problem Statement
**Error output**:
spec/models/space_station_spec.rb:422 (see overnight log for details)

Current behavior: Storage capacity filter does not work as intended
Expected behavior: Storage capacity filtering works as intended

---

## Files Involved
- app/models/space_station.rb (filter logic)
- spec/models/space_station_spec.rb (test case)

---

## Steps
1. Run diagnostic: grep -n "capacity|storage|filter" app/models/space_station.rb
2. Review and correct storage capacity filter logic
3. Refactor and test until targeted spec passes

---

## Acceptance Criteria
- The test passes and storage capacity filtering works as intended

---

## Stop Conditions
- All acceptance criteria met
- No regressions in storage logic

---

## Commit Message
fix: correct storage capacity filter logic in SpaceStation model
