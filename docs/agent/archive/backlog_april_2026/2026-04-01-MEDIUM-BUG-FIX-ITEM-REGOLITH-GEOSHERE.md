# MEDIUM PRIORITY BUG: Regolith Geoshere Item

**Date:** 2026-04-01
**Severity:** MEDIUM
**Area:** Regolith Geoshere Item Handling

---

## Summary
A test failure related to the handling or registration of the regolith geoshere item. (See detailed diagnostics in test logs.)

## Diagnostics

**Fail 1:**
- **Spec:** (see test logs for exact file/line)
- **Description:** Regolith geoshere item is not handled/registered correctly, causing test failure.
- **Error:** (see test logs for error message)

## Targeted RSpec Command

```
rspec [INSERT_SPEC_PATH_AND_LINE]
```

## Acceptance Criteria
- The regolith geoshere item is handled/registered as expected.
- The test passes and no related regressions are introduced.

## Implementation Steps

1. **Diagnostic:**
	- Run: `grep -n "geosphere\\|celestial_body" spec/models/item_spec.rb:290 app/models/item.rb`
	- Check for nil or missing delegation in geosphere/composition access.
2. **Fix Hint:**
	- Use safe navigation: `item.celestial_body&.geosphere&.composition`
3. Refactor and test until the targeted spec passes.
