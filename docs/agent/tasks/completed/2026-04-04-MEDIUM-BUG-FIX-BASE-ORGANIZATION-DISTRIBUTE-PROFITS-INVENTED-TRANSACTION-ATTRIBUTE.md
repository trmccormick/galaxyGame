# TASK: Fix base_organization#distribute_consortium_profits — Invented from_organization Attribute
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single method fix, schema is fully specified, no inference needed.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Organizations::BaseOrganization#distribute_consortium_profits` calls
`Financial::Transaction.create!` with a `from_organization` attribute that
does not exist in the schema.

The `transactions` table schema (confirmed from db/schema.rb):
```
account_id        — bigint, required
recipient_type    — string, required (polymorphic)
recipient_id      — bigint, required (polymorphic)
amount            — decimal, required
transaction_type  — string, required
description       — text, optional
currency_id       — bigint, default 1
```

No `from_organization` column exists or ever existed. It was added by an
agent inventing attributes not in the schema.

The consortium organization reference should map to the `recipient` polymorphic
association — the organization receiving or distributing the profit is the
recipient.

## Jan 8 Reference
The Jan 8 Time Machine backup of `ManufacturingService` shows the correct
pattern for financial transactions in this codebase. Request it from the
human if needed to understand the intended transaction pattern.

---

## Problem Statement

**Error output:**
```
ActiveModel::UnknownAttributeError: unknown attribute 'from_organization'
  for Financial::Transaction
```

**Current behavior**: `distribute_consortium_profits` fails with
`UnknownAttributeError` when creating a transaction.

**Expected behavior**: Transaction created using real schema attributes —
`account`, `recipient` (polymorphic), `amount`, `transaction_type`,
`currency_id`.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `app/models/organizations/base_organization.rb` | Fix `Financial::Transaction.create!` call around line 114 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/financial/transaction.rb` | Real model — `belongs_to :account`, `belongs_to :recipient, polymorphic: true` |
| `db/schema.rb` | Confirms exact columns available |
| `spec/models/organizations/base_organization_profit_spec.rb` | What the spec expects |

---

## Implementation Steps

### Step 1 — Read the full method
```bash
sed -n '105,130p' galaxy_game/app/models/organizations/base_organization.rb
```

### Step 2 — Read the spec to understand expected behavior
```bash
cat galaxy_game/spec/models/organizations/base_organization_profit_spec.rb
```

### Step 3 — Read Financial::Transaction model
```bash
cat galaxy_game/app/models/financial/transaction.rb
```

### Step 4 — Produce Synthesis Report and STOP

### Step 5 — Fix the Transaction.create! call

Remove `from_organization` and map correctly to real schema:

```ruby
# Before (invented attribute)
Financial::Transaction.create!(
  from_organization: consortium,
  ...
)

# After (real schema)
Financial::Transaction.create!(
  account: recipient_account,      # the account being credited
  recipient: consortium,           # polymorphic — the org distributing
  amount: profit_share,
  transaction_type: :transfer,
  description: "Consortium profit distribution",
  currency_id: 1                   # default GCC currency
)
```

The exact mapping depends on what `distribute_consortium_profits` is doing —
read the method carefully before applying.

### Step 6 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/organizations/base_organization_profit_spec.rb 2>&1 | grep "examples,"'
```

---

## Synthesis Report Format

```
THE FAILURE
Error: UnknownAttributeError — from_organization
Location: base_organization.rb line [N]

CURRENT TRANSACTION CREATE CALL
[paste exact current code]

REAL SCHEMA COLUMNS
account_id, recipient (polymorphic), amount, transaction_type,
description, currency_id

PROPOSED MAPPING
from_organization → [which real column]
[other attributes → which real columns]

RISK
[any other callers of distribute_consortium_profits]

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
- [ ] No `UnknownAttributeError` or `ActiveModel` errors
- [ ] Transaction created with real schema attributes only
- [ ] No regressions in `spec/models/organizations/`

---

## Stop Conditions
- `distribute_consortium_profits` requires a migration to add a legitimate
  column — stop, report, do not migrate without human approval
- Method has more than 3 callers in production code — report before proceeding
- Spec expects behavior that cannot be implemented with current schema — report

---

## Commit Instructions
```bash
git add galaxy_game/app/models/organizations/base_organization.rb
git commit -m "fix: base_organization#distribute_consortium_profits — remove invented from_organization, use real Financial::Transaction schema"
git push
```

---

## Dependencies
**Blocked by**: Financial::Transaction namespace fix (committed 2026-04-04) ✅
**Blocks**: nothing
**Related tasks**: Financial::Transaction namespace fix

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
