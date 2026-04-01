# LOW PRIORITY BUG: Advance By Days Guard

**Date:** 2026-04-01
**Severity:** LOW
**Area:** Game Advance By Days

---

## Summary
Test failure in game advance-by-days guard logic.

## Diagnostics

- **Spec:** spec/models/game_spec.rb:72
- **Error:** (see overnight log for details)

## Diagnostic Command

```
grep -n "advance_by_days\|guard" app/models/game.rb
```

## Targeted RSpec Command

```
rspec spec/models/game_spec.rb:72
```

## Fix Hint
- Review and correct guard logic in Game#advance_by_days.

## Acceptance Criteria
- The test passes and advance-by-days guard logic is correct.
