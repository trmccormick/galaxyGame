# MEDIUM PRIORITY BUG: Profits Transaction

**Date:** 2026-04-01
**Severity:** MEDIUM
**Area:** Base Organization Profits

---

## Summary
Test failure in base organization profit transaction logic.

## Diagnostics

- **Spec:** spec/models/base_organization_profit_spec.rb:13
- **Error:** (see overnight log for details)

## Diagnostic Command

```
grep -n "profit\|transaction" app/models/base_organization_profit.rb
```

## Targeted RSpec Command

```
rspec spec/models/base_organization_profit_spec.rb:13
```

## Fix Hint
- Review and correct profit transaction logic in BaseOrganizationProfit model.

## Acceptance Criteria
- The test passes and profit transactions are handled correctly.
