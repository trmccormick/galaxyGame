# MEDIUM PRIORITY BUG: Material Request Creation

**Date:** 2026-04-01
**Severity:** MEDIUM
**Area:** MaterialRequest Creation (ConstructionJob)

---

## Summary
Two test failures due to invalid status values when creating MaterialRequest records. The status 'fulfilled_by_player' is not a valid enum value, causing ArgumentError.

## Diagnostics

**Fail 1:**
- **Spec:** spec/models/construction_job_spec.rb:198
- **Description:** #materials_gathered? returns true when all material requests are fulfilled
- **Error:**
  ```
  ArgumentError: 'fulfilled_by_player' is not a valid status
  ```

**Fail 2:**
- **Spec:** spec/models/construction_job_spec.rb:214
- **Description:** #materials_gathered? returns false when some material requests are pending
- **Error:**
  ```
  ArgumentError: 'fulfilled_by_player' is not a valid status
  ```

## Targeted RSpec Commands

```
rspec ./spec/models/construction_job_spec.rb:198
rspec ./spec/models/construction_job_spec.rb:214
```

## Acceptance Criteria
- Only valid status values are used for MaterialRequest.
- Both tests pass and no related regressions are introduced.

## Implementation Steps

1. **Diagnostic:**
  - Run: `grep -n "materials\\|blueprint" spec/services/*material_request*`
  - Review how blueprint materials hashes are iterated and passed to request creation.
2. **Fix Hint:**
  - Ensure: `blueprint.materials.each { |type, qty| create_request(type, qty) }`
  - Validate hash format and status values.
3. Refactor and test until both targeted specs pass.
