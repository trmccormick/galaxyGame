# TASK: Refactor Manufacturing Services to use operational_data JSON for Job attributes
**Phase**: 4 — Promote to backlog ~May 22

**Status**: ACTIVE
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-04-26
**Last Updated**: 2026-05-01 (partial progress — `MaterialProcessingService` complete; `ComponentProductionService` is the remaining scope)

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Requires precise refactoring of service-to-model interfaces across multiple files.
**Supervision Level**: 🔴 Watched carefully

---

## Context
The `Job` model requires 5 mandatory fields on every create: `owner`, `settlement`, `job_type`, `output_type`, `completes_at`. All dynamic job metadata beyond these must live in the `operational_data` JSON column — not as top-level attributes.

**Progress as of 2026-05-01:**
- ✅ `MaterialProcessingService` — fully migrated: uses `operational_data` hash, all 5 mandatory fields present, spec updated and passing.
- ❌ `ComponentProductionService` — NOT migrated: `create_production_job` (line 164) passes `component_blueprint_id`, `component_name`, `quantity`, `production_time_hours`, `printer_unit`, `materials_consumed` as direct top-level attributes, AND is missing `owner`, `completes_at`, `output_type`. This will raise `ActiveRecord::RecordInvalid`.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/job_model_architecture.md` (if available)

---

## Problem Statement
`ComponentProductionService#create_production_job` creates a `Job` with missing mandatory fields and incorrect attribute placement.

**Current `create_production_job` call (lines 164–175)**:
```ruby
Job.create!(
  job_type: :component_production,
  settlement: @settlement,
  printer_unit: printer_unit,              # ← not a Job column
  component_blueprint_id: blueprint['id'], # ← direct column, ok to keep
  component_name: blueprint['name'],       # ← not a Job column
  quantity: quantity,                      # ← not a Job column
  production_time_hours: production_time,  # ← not a Job column
  status: 'pending',
  materials_consumed: format_materials_for_storage(materials_consumed) # ← not a Job column
)
```

**Missing**: `owner`, `completes_at`, `output_type`.

**Expected behavior**: Non-column metadata moved to `operational_data`; all 5 mandatory fields present.

---

## Files Involved

### Primary Files
| File | Status | Purpose | Key Method |
|---|---|---|---|
| `app/services/manufacturing/material_processing_service.rb` | ✅ DONE | Processing service | `Job.create!`, `complete_job` |
| `app/services/manufacturing/component_production_service.rb` | ❌ TODO | Component assembly | `create_production_job` (private, line ~164) |
| `spec/services/manufacturing/component_production_service_spec.rb` | ❌ TODO | Service spec | Any `expect(job.x)` on non-columns |

---

## Implementation Steps

### Step 1 — Refactor `component_production_service.rb#create_production_job`

Replace the current `Job.create!` call with one that includes all 5 mandatory fields and moves non-column metadata into `operational_data`.

**Pattern to follow** (mirrors `material_processing_service.rb` lines 35–52):
```ruby
Job.create!(
  job_type: :component_production,
  settlement: @settlement,
  owner: @settlement.owner,
  output_type: 'Component',
  completes_at: production_time.hours.from_now,
  status: :pending,
  operational_data: {
    'component_blueprint_id' => blueprint['id'],
    'component_name'         => blueprint['name'],
    'quantity'               => quantity,
    'production_time_hours'  => production_time,
    'printer_unit_id'        => printer_unit.id,
    'materials_consumed'     => format_materials_for_storage(materials_consumed)
  }
)
```

Note: `component_blueprint_id` is also a real column on `Job` (confirmed via `Job.new.attributes`), but storing it in `operational_data` too is fine for consistency. Remove the direct column assignment to avoid duplication.

### Step 2 — Update `complete_job` in `component_production_service.rb`

`complete_job` calls `job.component_blueprint_id` (direct column — still valid). Also check `add_component_to_inventory` and `add_waste_products`: they reference `job.materials_consumed` directly (line ~186). Update to read from `job.operational_data['materials_consumed']` instead.

### Step 3 — Update `component_production_service_spec.rb`

Update any assertions that read non-column attributes directly off the job (e.g. `expect(job.materials_consumed)`) to use `expect(job.operational_data['materials_consumed'])`.

### Step 4 — Verify
```
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/component_production_service_spec.rb'
```

---

## Acceptance Criteria
- [ ] `create_production_job` provides all 5 mandatory fields (`owner`, `settlement`, `job_type`, `output_type`, `completes_at`).
- [ ] No `ActiveRecord::RecordInvalid` on component production job creation.
- [ ] All non-column metadata lives in `operational_data`.
- [ ] `complete_job` reads `materials_consumed` from `operational_data`, not direct attribute.
- [ ] Isolation spec: 0 failures.

---

## Commit Instructions
`git add app/services/manufacturing/component_production_service.rb spec/services/manufacturing/component_production_service_spec.rb`
`git commit -m "refactor: component_production_service — migrate job metadata to operational_data JSON"`