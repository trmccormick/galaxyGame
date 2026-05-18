---

# TASK: Fix FittingService Inventory Handling
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment

**Assigned To**: Gemini Flash 0.33x  
**Why This Agent**: Straightforward spec fix, fully self-contained  
**Supervision Level**: standard  

---

## Context
Two test failures in FittingService related to inventory handling:
- Fitting all components from inventory
- Fitting components without inventory (when inventory is nil)

**Relevant Architecture Docs**  
- `app/services/fitting_service.rb` — Inventory and has_item? logic
- `spec/services/fitting_service_spec.rb` — Targeted specs

---

## Problem Statement
FittingService fails to fit components from inventory and when inventory is nil. Both targeted specs fail with `expected true, got false`.

**Error output**:
- spec/services/fitting_service_spec.rb:30 — expected true, got false
- spec/services/fitting_service_spec.rb:47 — expected true, got false

---

## Files Involved
- app/services/fitting_service.rb
- spec/services/fitting_service_spec.rb

---

## Steps
1. Run: `grep -n "inventory\|has_item" app/services/fitting_service.rb`
2. Review all inventory and has_item? usages and delegation logic
3. Refactor and test until both targeted specs pass

---

## Acceptance Criteria
- Both tests pass with correct inventory logic
- No regressions in related fitting logic

---

## Stop Conditions
- All acceptance criteria met
- No regressions in fitting logic

---

## Commit Message
fix: correct inventory handling in FittingService for all and nil cases
