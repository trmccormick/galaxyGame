# 2026-04-01-HIGH-BUG-FIX-FITTING-SERVICE-INVENTORY

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Bug fix in fitting service inventory logic
**Supervision Level**: 🔴 Watched carefully

## Context
FittingService handles component fitting for stations and structures. Two test failures related to inventory handling logic.

## Problem Statement
Two test failures in FittingService related to inventory handling:
- Fitting all components from inventory
- Fitting components without inventory (when inventory is nil)

**Fail 1:**
- **Spec:** spec/services/fitting_service_spec.rb:30
- **Description:** FittingService fits all components from inventory
- **Error:** expected true, got false

**Fail 2:**
- **Spec:** spec/services/fitting_service_spec.rb:47
- **Description:** FittingService fits components without inventory if inventory is nil
- **Error:** expected true, got false

## Files Involved
### Primary Files — you will edit
| File | Purpose | Key Method |
|---|---|---|
| `app/services/fitting_service.rb` | Component fitting logic | inventory handling methods |
| `spec/services/fitting_service_spec.rb` | Test cases | lines 30, 47 |

## Implementation Steps
1. **Diagnostic:** Run grep to find inventory and has_item? usages
2. **Fix:** Ensure has_item? checks delegate to inventory.has_item? correctly
3. **Test:** Run targeted specs until they pass

## Acceptance Criteria
- [ ] Both targeted tests pass (lines 30, 47)
- [ ] No regressions in related fitting logic
- [ ] Inventory handling works correctly for both nil and populated inventories

## Stop Conditions
- Inventory logic requires broader refactoring beyond FittingService
- Changes affect other services unexpectedly

## Commit Instructions
```bash
git add app/services/fitting_service.rb spec/services/fitting_service_spec.rb
git commit -m "fix: FittingService inventory handling bugs"
```