# GRINDER_PROTOCOL.md

## Protocol Overview
Systematic approach: target the spec file with the highest failure count, analyze root cause, fix, and verify. Focus on factory/schema fixes over test-specific patches for maximum impact. Success example: reduced 393 failures to 0 in construction services.

## Construction Services Victory (100% Operational)

```
skylight_service_spec.rb: 11 examples, 0 failures ✅
dome_service_spec.rb: 24 examples, 0 failures ✅
hangar_service_spec.rb: 23 examples, 0 failures ✅
covering_service_spec.rb: 24 examples, 0 failures ✅
dome_calculator_spec.rb: 10 examples, 0 failures ✅
TOTAL: 112 examples, 0 failures
```

### Key Pattern - Root Cause Cascade

#### Gas Factory molar_mass Fix

- CO2: 44.01 g/mol
- N2: 28.02 g/mol
- O2: 32.0 g/mol
- Ar: 39.95 g/mol
- Created gas traits: `:co2`, `:n2`, `:o2`, `:ar`
- Result: Fixed atmosphere factory validation across ALL specs
- Lesson: One factory fix can cascade to 20+ spec fixes

### Account Reference Pattern
- Wrong: `:account` factory
- Right: `:financial_account` factory
- Always use namespaced factories for clarity

### Next Target Selection
- Overall suite: 449 failures (down from 500+)
- Method: `grep "rspec ./spec" $LATEST_LOG | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -5`
- Attack highest count first
