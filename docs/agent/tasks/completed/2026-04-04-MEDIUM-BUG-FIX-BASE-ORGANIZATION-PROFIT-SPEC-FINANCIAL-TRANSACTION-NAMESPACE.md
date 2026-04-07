# TASK: Fix base_organization_profit_spec — Wrong FinancialTransaction Constant Name
**Status**: ACTIVE
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single constant rename in one spec file. No inference needed.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Financial::Transaction` is the correct model class. It lives in
`app/models/financial/transaction.rb` under the `Financial` module with
`self.table_name = 'transactions'`.

The spec `base_organization_profit_spec.rb` references `FinancialTransaction`
— an unnamespaced constant that does not exist. Rails cannot resolve it,
raising `NameError: uninitialized constant FinancialTransaction`.

---

## Problem Statement

**Error output:**
```
NameError: uninitialized constant FinancialTransaction
# ./spec/models/organizations/base_organization_profit_spec.rb:16
```

**Current behavior**: `FinancialTransaction.count` raises NameError.
**Expected behavior**: `Financial::Transaction.count` resolves correctly.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `spec/models/organizations/base_organization_profit_spec.rb` | Replace `FinancialTransaction` with `Financial::Transaction` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/financial/transaction.rb` | Confirms correct constant: `Financial::Transaction` |

---

## Implementation Steps

### Step 1 — Confirm all occurrences in the spec
```bash
grep -n "FinancialTransaction" galaxy_game/spec/models/organizations/base_organization_profit_spec.rb
```

### Step 2 — Confirm the correct constant
```bash
grep -n "class.*Transaction\|module Financial" galaxy_game/app/models/financial/transaction.rb
```

### Step 3 — Produce Synthesis Report and STOP

### Step 4 — Replace all occurrences
```ruby
# Before
FinancialTransaction.count

# After
Financial::Transaction.count
```

Replace every occurrence found in Step 1. Do not change anything else in the file.

### Step 5 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/organizations/base_organization_profit_spec.rb 2>&1 | grep "examples,"'
```

Expected: `0 failures`

---

## Synthesis Report Format

```
THE FAILURE
Spec: base_organization_profit_spec.rb:16
Error: NameError — uninitialized constant FinancialTransaction

OCCURRENCES FOUND
Line [N]: [exact line content]
[repeat for each]

CORRECT CONSTANT CONFIRMED
Financial::Transaction — app/models/financial/transaction.rb line [N]

PROPOSED FIX
Replace FinancialTransaction → Financial::Transaction at lines: [list]

RISK
None — spec-only change, single constant rename.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/organizations/base_organization_profit_spec.rb 2>&1 | grep "examples,"'
```

2. Related org specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/organizations/ 2>&1 | grep "examples,"'
```

---

## Acceptance Criteria
- [ ] `base_organization_profit_spec.rb` — 0 failures
- [ ] No regressions in `spec/models/organizations/`
- [ ] No production code changed

---

## Stop Conditions
- `Financial::Transaction` also fails to resolve — report before proceeding
- More than 3 occurrences of `FinancialTransaction` in the file — report full list

---

## Commit Instructions
```bash
git add galaxy_game/spec/models/organizations/base_organization_profit_spec.rb
git commit -m "fix: base_organization_profit_spec — replace FinancialTransaction with Financial::Transaction namespace"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: nothing
**Related tasks**: none

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
