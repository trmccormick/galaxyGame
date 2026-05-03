# [HIGH ISSUE] SpaceStation#calculate_storage_capacity bypasses BaseSettlement

**Created:** 2026-03-29
**Priority:** High
**Spec/Code:** SpaceStation line 73 sums all units → 50006.0
**Parent:** BaseSettlement#total_storage_capacity (line 133) → 50000.0 expected

## Root Cause
- Child method overrides correct parent implementation

## Fix Plan
1. Remove SpaceStation#calculate_storage_capacity (lines 73-82)
2. Use BaseSettlement#total_storage_capacity everywhere
3. Expected: 50000.0 ✓

## Diagnostic
- `grep -A 10 -B 2 "calculate_storage_capacity" app/models/settlement/space_station.rb`

## Acceptance Criteria
- SpaceStation no longer overrides storage capacity logic
- All code uses BaseSettlement#total_storage_capacity
- Spec returns 50000.0 as expected
- Task is documented and committed

---
**See agent README for workflow.**
