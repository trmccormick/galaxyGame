# TASK: Fix base_organization_profit_spec — Add Financial::Account and Currency to Test Setup
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-06
**Last Updated**: 2026-04-06

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Spec-only change. All factories exist. No inference needed — exact wiring specified below.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`base_organization_profit_spec.rb` tests `distribute_consortium_profits` which
creates a `Financial::Transaction`. That model requires both `account` and
`currency` associations (validated presence: true on both).

The spec's `before` block does not set up these records, so the transaction
creation raises:

```
Validation failed: Account must exist, Currency must exist,
Currency can't be blank, Account can't be blank
```

All required factories already exist:
- `:financial_currency` with `:gcc` trait — `spec/factories/financial/currencies.rb`
- `:account` / `:financial_account` with `:for_organization` trait — `spec/factories/financial/accounts.rb`
- `:financial_transaction` — `spec/factories/financial/transactions.rb`

This is a test data wiring task only. No production code changes.

---

## Problem Statement

**Error output:**
```
Validation failed: Account must exist, Currency must exist,
Currency can't be blank, Account can't be blank
# app/models/financial/transaction.rb
```

**Current behavior**: `distribute_consortium_profits` tries to create a
`Financial::Transaction` but the spec provides no account or currency — validation fails.

**Expected behavior**: Spec sets up a `Financial::Account` owned by the consortium
and a `Financial::Currency` (:gcc) before the test runs. Transaction creates
successfully. Assertions on `tx.amount`, `tx.recipient`, `tx.account.owner`,
and `tx.transaction_type` all pass.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `spec/models/organizations/base_organization_profit_spec.rb` | Add currency and account to before block |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `spec/factories/financial/currencies.rb` | `:financial_currency` factory, `:gcc` trait |
| `spec/factories/financial/accounts.rb` | `:account` factory, `:for_organization` trait |
| `spec/factories/financial/transactions.rb` | Confirms association names expected by factory |
| `app/models/financial/transaction.rb` | Confirms `belongs_to :account` and `belongs_to :currency` |

---

## Implementation Steps

> Follow exactly in order. Do not infer.

### Step 1 — Read the current spec
```bash
cat galaxy_game/spec/models/organizations/base_organization_profit_spec.rb
```

### Step 2 — Confirm the account factory :for_organization trait
```bash
grep -A 3 "for_organization" galaxy_game/spec/factories/financial/accounts.rb
```

Note: `:for_organization` uses `factory: :organization`. Confirm whether
`:consortium` satisfies this or whether the account needs `accountable: consortium`
set explicitly.

### Step 3 — Produce Synthesis Report and STOP

### Step 4 — Add currency and account to the spec before block

Add `let` blocks above the existing `before` block:

```ruby
let(:gcc) { create(:financial_currency, :gcc) }
let(:consortium_account) { create(:account, accountable: consortium, currency: gcc) }
```

Then reference them in the `before` block to ensure they are created before
the test runs (FactoryBot `let` is lazy — force evaluation):

```ruby
before do
  gcc
  consortium_account
  ConsortiumMembership.create!(...)
  allow(consortium).to receive(:calculate_revenue).and_return(1_000_000)
  allow(consortium).to receive(:calculate_costs).and_return(100_000)
end
```

### Step 5 — Check how distribute_consortium_profits creates the transaction

```bash
grep -n "distribute_consortium_profits\|Financial::Transaction\|account\|currency" galaxy_game/app/models/organizations/base_organization.rb | head -40
```

If the method hardcodes account/currency lookup rather than accepting them,
you may need to confirm it will find `consortium_account` by owner. Report
this in the Synthesis Report — do not guess.

### Step 6 — Verify
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/organizations/base_organization_profit_spec.rb 2>&1 | grep "examples,"'
```

Expected: `1 example, 0 failures`

---

## Synthesis Report Format

```
THE FAILURE
Spec: base_organization_profit_spec.rb
Error: Validation failed: Account must exist, Currency must exist

FACTORIES CONFIRMED
:financial_currency :gcc — exists at spec/factories/financial/currencies.rb
:account :for_organization — exists at spec/factories/financial/accounts.rb

DISTRIBUTE_CONSORTIUM_PROFITS ACCOUNT LOOKUP
[How the method finds/creates the account — exact lines from base_organization.rb]

PROPOSED FIX
[exact let blocks and before block changes]

RISK
Spec-only change. No production code touched.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Isolation:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/organizations/base_organization_profit_spec.rb 2>&1 | grep "examples,"'
```

2. Related org specs — confirm no regressions:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/organizations/ 2>&1 | grep "examples,"'
```

---

## Acceptance Criteria
- [ ] `base_organization_profit_spec.rb` — 1 example, 0 failures
- [ ] No regressions in `spec/models/organizations/`
- [ ] No production code changed
- [ ] No new factories created — only existing ones wired in

---

## Stop Conditions — escalate immediately if:
- `distribute_consortium_profits` does not look up account by owner — report exact method before proceeding
- `:for_organization` trait on `:account` factory requires a different accountable type than consortium — report before guessing
- Fix passes isolation but breaks other org specs — report regression immediately

---

## Commit Instructions
```bash
git add galaxy_game/spec/models/organizations/base_organization_profit_spec.rb
git commit -m "fix: base_organization_profit_spec — add Financial::Account and Currency factory setup to before block"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: nothing
**Related tasks**: `2026-04-04-MEDIUM-BUG-FIX-BASE-ORGANIZATION-DISTRIBUTE-PROFITS-INVENTED-TRANSACTION-ATTRIBUTE.md` (supersedes — that file was never created)

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
