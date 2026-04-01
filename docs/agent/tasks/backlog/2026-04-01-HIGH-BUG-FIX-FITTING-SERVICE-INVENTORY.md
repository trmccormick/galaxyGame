# HIGH PRIORITY BUG: FittingService Inventory Fails

**Date:** 2026-04-01
**Severity:** HIGH
**Area:** FittingService (Inventory)

---

## Summary
Two test failures in FittingService related to inventory handling:
- Fitting all components from inventory
- Fitting components without inventory (when inventory is nil)

## Diagnostics

**Fail 1:**
- **Spec:** spec/services/fitting_service_spec.rb:30
- **Description:** FittingService fits all components from inventory
- **Error:**
  ```
  expected true
       got false
  ```

**Fail 2:**
- **Spec:** spec/services/fitting_service_spec.rb:47
- **Description:** FittingService fits components without inventory if inventory is nil
- **Error:**
  ```
  expected true
       got false
  ```

## Targeted RSpec Commands

```
rspec ./spec/services/fitting_service_spec.rb:30
rspec ./spec/services/fitting_service_spec.rb:47
```

## Acceptance Criteria
- Both tests pass with correct inventory logic.
- No regressions in related fitting logic.

## Implementation Steps

1. **Diagnostic:**
  - Run: `grep -n "inventory\\|has_item" app/services/fitting_service.rb`
  - Review all inventory and has_item? usages and delegation logic.
2. **Fix Hint:**
  - Ensure `has_item?` checks delegate to `inventory.has_item?` as needed.
  - Example: `station.inventory.has_item?(component.item_type)`
3. Refactor and test until both targeted specs pass.
