---

# TASK: Fix Profits Transaction in Base Organization
**Status**: BACKLOG  
**Priority**: MEDIUM  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Model fix, single transaction logic, spec-driven  
**Supervision Level**: watched carefully  

---

## Context
Test failure in base organization profit transaction logic.

---

## Problem Statement
**Error output**: See overnight log for details.

Current behavior: Profit transaction logic is incorrect
Expected behavior: Profit transactions are handled correctly

---

## Files Involved
- app/models/base_organization_profit.rb (transaction logic)
- spec/models/base_organization_profit_spec.rb (test case)

---

## Steps
1. Run diagnostic: grep -n "profit|transaction" app/models/base_organization_profit.rb
2. Review and correct profit transaction logic
3. Refactor and test until targeted spec passes

---

## Acceptance Criteria
- The test passes and profit transactions are handled correctly

---

## Stop Conditions
- All acceptance criteria met
- No regressions in profit logic

---

## Commit Message
fix: correct profit transaction logic in BaseOrganizationProfit
