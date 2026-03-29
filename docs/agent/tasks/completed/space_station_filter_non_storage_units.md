# [HIGH ISSUE] SpaceStation includes 6 generic units (1.0 capacity each)

**Created:** 2026-03-29
**Priority:** High
**Spec/Code:** units.sum → 50000 + 6×1.0 = 50006.0
**Expected:** storage units only → 50000.0 ✓

## Root Cause
- SpaceStation sums all units, including generic units with 1.0 capacity

## Fix Plan
- Change sum to:
  units.select { |u| u.storage_capacity.to_f > 1.0 }.sum(&:storage_capacity)

## Acceptance Criteria
- Only storage units are included in the sum
- Result is 50000.0 as expected
- Task is documented and committed

---
**See agent README for workflow.**
