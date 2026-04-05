# TASK: Fix construction_job Factory — Add Default Jobable Association
**Status**: ACTIVE
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single factory fix, fully specified, clears 2 specs at once.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`ConstructionJob` has a polymorphic `belongs_to :jobable` association that is
required by validation. The `construction_job` factory does not set a default
jobable, so `create(:construction_job)` always raises:

```
ActiveRecord::RecordInvalid: Validation failed: Jobable must exist
```

`ConstructionJob` accepts any model as jobable. Line 53 of the model confirms
`Settlement::BaseSettlement` is a valid jobable type:
```ruby
return jobable if jobable.is_a?(Settlement::BaseSettlement)
```

The factory already creates a `:base_settlement` association. The fix is to
reuse that settlement as the default jobable.

This single factory fix clears two failing specs:
- `spec/services/manufacturing/material_request_system_spec.rb`
- `spec/services/material_request_service_spec.rb`

---

## Problem Statement

**Error output:**
```
ActiveRecord::RecordInvalid: Validation failed: Jobable must exist
# factory_bot/.../evaluation.rb:15
# triggered by: let(:construction_job) { create(:construction_job, blueprint: blueprint) }
```

**Current behavior**: `create(:construction_job)` fails validation.
**Expected behavior**: Factory creates a valid `ConstructionJob` with a default jobable.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `spec/factories/construction_job.rb` | Add default jobable to base factory |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/construction_job.rb` | Confirms `belongs_to :jobable, polymorphic: true` |

---

## Implementation Steps

### Step 1 — Read the full factory
```bash
cat galaxy_game/spec/factories/construction_job.rb
```

### Step 2 — Confirm the validation
```bash
grep -n "validates.*jobable\|belongs_to :jobable" galaxy_game/app/models/construction_job.rb
```

### Step 3 — Produce Synthesis Report and STOP

### Step 4 — Add default jobable to base factory

The factory already has `association :settlement, factory: :base_settlement`.
Add the jobable using an `after(:build)` callback that reuses the settlement:

```ruby
FactoryBot.define do
  factory :construction_job do
    association :settlement, factory: :base_settlement
    job_type { :crater_dome_construction }
    status { :scheduled }

    # Add this block:
    after(:build) do |job|
      job.jobable ||= job.settlement
    end

    # ... rest of factory unchanged
  end
end
```

The `||=` guard ensures existing traits that set jobable explicitly are not
overridden.

### Step 5 — Verify both specs clear
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  spec/services/manufacturing/material_request_system_spec.rb \
  spec/services/material_request_service_spec.rb \
  2>&1 | grep "examples,"'
```

Expected: 0 failures across both.

---

## Synthesis Report Format

```
THE FAILURE
Specs: material_request_system_spec.rb, material_request_service_spec.rb
Error: ActiveRecord::RecordInvalid — Validation failed: Jobable must exist

VALIDATION CONFIRMED
belongs_to :jobable, polymorphic: true — line [N] of construction_job.rb

FACTORY CURRENT STATE
No jobable set in base factory. after(:create) in :in_progress trait references
job.jobable without it being assigned.

PROPOSED FIX
Add after(:build) { |job| job.jobable ||= job.settlement } to base factory.
Settlement is already created by the factory's association — safe reuse.

RISK
Low. The ||= guard preserves any explicit jobable set by traits or specs.
No production code changes.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Both target specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  spec/services/manufacturing/material_request_system_spec.rb \
  spec/services/material_request_service_spec.rb \
  2>&1 | grep "examples,"'
```

2. Confirm no factory regressions in construction-related specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  spec/services/manufacturing/ \
  spec/models/construction_job* \
  2>&1 | grep "examples,"'
```

---

## Acceptance Criteria
- [ ] `material_request_system_spec.rb` — 0 failures
- [ ] `material_request_service_spec.rb` — 0 failures
- [ ] No regressions in manufacturing specs
- [ ] `in_progress` trait still works (jobable not overridden)

---

## Stop Conditions
- Validation requires a specific jobable type other than settlement — report before proceeding
- Adding jobable causes a different validation failure — report exact error
- `in_progress` trait breaks after the change — report before attempting further fixes

---

## Commit Instructions
```bash
git add galaxy_game/spec/factories/construction_job.rb
git commit -m "fix: construction_job factory — add default jobable via after(:build) to resolve Jobable must exist validation"
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
