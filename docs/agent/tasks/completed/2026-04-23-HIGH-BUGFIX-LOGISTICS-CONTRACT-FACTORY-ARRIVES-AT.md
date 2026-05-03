# TASK: Logistics Contract Factory — Add arrives_at Default + Fix mark_failed!
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-23
**Last Updated**: 2026-04-23

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single factory file + single model method. Fully specified. No inference needed.
**Supervision Level**: 🔴 Watched carefully

---

## Context

Task 4b added `arrives_at` as a required column to `logistics_contracts` with a
presence validation on pending/in_transit records. The existing `logistics_contract`
factory was not updated to include `arrives_at` — so every spec that uses the
base factory now fails with `Validation failed: Arrives at can't be blank`.

Additionally `mark_failed!` may still be writing to `operational_data` JSON instead
of the new `failure_reason` string column added in Task 4b.

**Read before starting:**
- `docs/architecture/logistics/logistics_architecture.md`

---

## Problem Statement

**Error:**
```
ActiveRecord::RecordInvalid: Validation failed: Arrives at can't be blank
```
Thrown by every `create(:logistics_contract)` call in specs.

**Root cause**: The base `logistics_contract` factory does not set `arrives_at`.
Task 4b added the column and validation but did not update the base factory —
only added new traits.

**Secondary issue**: `mark_failed!` in `Logistics::Contract` model — verify it
uses `failure_reason` column, not `operational_data` JSON merge.

---

## Files Involved

### Primary Files — you will edit these
| File | Change |
|---|---|
| `galaxy_game/spec/factories/logistics/contracts.rb` (or similar path) | Add `arrives_at` default to base factory |
| `galaxy_game/app/models/logistics/contract.rb` | Verify/fix `mark_failed!` |

### Step 1 — Find the factory file
```bash
find galaxy_game/spec/factories -name "*.rb" | xargs grep -l "logistics_contract\|LogisticsContract\|Logistics::Contract"
```
Paste path in Synthesis Report.

### Step 2 — Read the factory file in full
```bash
cat [factory file path]
```

### Step 3 — Add arrives_at to base factory
Add a default `arrives_at` to the base factory definition:

```ruby
# Add to base factory attributes
arrives_at { 3.days.from_now }
```

This must be in the BASE factory, not just in traits. Every `create(:logistics_contract)`
must work without specifying `arrives_at` explicitly.

### Step 4 — Verify mark_failed! uses failure_reason column
```bash
grep -n "mark_failed\|failure_reason\|operational_data" \
  galaxy_game/app/models/logistics/contract.rb
```

Current (wrong):
```ruby
def mark_failed!(reason = nil)
  update(status: :failed,
         operational_data: operational_data.merge(failure_reason: reason))
end
```

Correct:
```ruby
def mark_failed!(reason = nil)
  update(status: :failed, failure_reason: reason)
end
```

If already correct — note in Synthesis Report and skip.

### Step 5 — Verify mark_delivered! is correct
```bash
grep -n "mark_delivered" galaxy_game/app/models/logistics/contract.rb
```
Should use `update_columns(status: 2, completed_at: Time.current)` or similar.
If it references a column that doesn't exist — flag it.

---

## Synthesis Report Format
```
FACTORY FILE PATH: [path]

CURRENT BASE FACTORY — does it have arrives_at? YES/NO
CURRENT arrives_at default value (if present): [value]

mark_failed! — uses failure_reason column: YES/NO
mark_failed! — current implementation: [paste]

mark_delivered! — current implementation: [paste]

PROPOSED CHANGES:
1. Factory: add arrives_at { 3.days.from_now } to base
2. mark_failed!: [change needed or NONE]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/logistics/contract_spec.rb 2>&1 | tail -10'
```
Expected: 0 failures.

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/ 2>&1 | tail -10'
```
Expected: 0 failures.

---

## Acceptance Criteria
- [ ] Base factory includes `arrives_at` default
- [ ] All 4 `contract_spec` failures green
- [ ] All `internal_transfer_service_spec` failures green
- [ ] `mark_failed!` uses `failure_reason` column
- [ ] No regressions

---

## Stop Conditions
- Factory file not found — stop, report
- `arrives_at` validation is conditional and the condition is wrong — stop, report
- Any new failures introduced — stop immediately

---

## Commit Instructions
```bash
git add galaxy_game/spec/factories/ \
        galaxy_game/app/models/logistics/contract.rb
git commit -m "fix: logistics_contract factory — add arrives_at default, fix mark_failed! column"
```

---

## Dependencies
**Blocked by**: Nothing
**Blocks**: Nothing
**Parallel safe**: Yes — does not touch manufacturing specs
