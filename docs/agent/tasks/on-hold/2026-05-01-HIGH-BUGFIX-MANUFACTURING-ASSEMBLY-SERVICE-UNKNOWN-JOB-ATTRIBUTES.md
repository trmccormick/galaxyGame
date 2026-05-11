# TASK: Fix ManufacturingService + AssemblyService — Unknown Job Attributes
**Phase**: 3 — Promote to backlog ~May 15

**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-05-01
**Failure Count**: 4 failures

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Surgical service migration to `operational_data` pattern. Identical pattern to `MaterialProcessingService` (already completed — use it as reference).
**Supervision Level**: 🔴 Watched carefully

---

## Context

Two services use `Job.update` / `Job.create!` with attributes that don't exist on the `Job` model, triggering `ActiveModel::UnknownAttributeError`. This is the same class of problem as `ComponentProductionService` (see active task `2026-04-26-HIGH-REFACTOR-JOB-SCHEMA-JSON-MIGRATION.md`), but in different service files.

**Error 1 — `manufacturing_service.rb` (failures #79-81):**
```
ActiveModel::UnknownAttributeError: unknown attribute 'start_date' for Job.
# ./app/services/manufacturing_service.rb:76
```

The service calls `job.update(start_date: ..., estimated_completion: ...)` — neither column exists on `Job`.

**Error 2 — `assembly_service.rb` (failure #82):**
```
ActiveModel::UnknownAttributeError: unknown attribute 'base_settlement' for Job.
# ./app/services/manufacturing/assembly_service.rb
```

`Job.create!` call passes:
- `base_settlement:` → should be `settlement:`
- `unit_type:` → not a top-level Job column
- `count:` → not a top-level Job column
- `status: :materials_pending` → not in Job status enum (`{ in_progress: 0, ready_to_claim: 1, claimed: 2, failed: 3, cancelled: 4, pending: 5 }`)

---

## Files Involved

| File | Error | Change |
|---|---|---|
| `app/services/manufacturing_service.rb` | `unknown attribute 'start_date'` | Move `start_date`, `estimated_completion` to `operational_data`; add missing mandatory fields |
| `app/services/manufacturing/assembly_service.rb` | `unknown attribute 'base_settlement'` | Replace `base_settlement` with `settlement`; move `unit_type`, `count` to `operational_data`; fix invalid status |
| `spec/services/manfacturing_service_spec.rb` | Spec assertions | Update any `expect(job.start_date)` / `expect(job.estimated_completion)` to use `operational_data` |
| `spec/services/manufacturing/assembly_service_spec.rb` | Spec assertions | Update assertions for moved attributes |

---

## Implementation Steps

**Reference implementation**: `app/services/manufacturing/material_processing_service.rb` lines 35–52. Use it as the canonical pattern for all `Job.create!` calls in this codebase.

### Mandatory Job fields (ALL must be present on every `Job.create!`):
```ruby
job_type:      # symbol from Job.job_types enum
settlement:    # Settlement object (NOT base_settlement)
owner:         # settlement.owner
output_type:   # String (e.g. 'Unit', 'Component', 'Material')
completes_at:  # Time
status:        # :pending (use this as default)
```

### Step 1 — Fix `manufacturing_service.rb`

Read `app/services/manufacturing_service.rb` around line 70-80. Find the `job.update(start_date: ..., estimated_completion: ...)` call. Move these two values into `operational_data`:

```ruby
# Instead of job.update(start_date: ..., estimated_completion: ...)
job.update(
  operational_data: job.operational_data.merge(
    'start_date' => Time.current.iso8601,
    'estimated_completion' => (Time.current + manufacturing_time.hours).iso8601
  )
)
```

Also verify the initial `Job.create!` in this service includes all 5 mandatory fields. If `owner` or `output_type` or `completes_at` is missing, add them.

### Step 2 — Fix `assembly_service.rb`

Read `app/services/manufacturing/assembly_service.rb`. Find the `Job.create!` block. Apply these changes:

```ruby
Job.create!(
  job_type: :unit_assembly,
  settlement: settlement,          # was: base_settlement
  owner: settlement.owner,         # ADD
  output_type: 'Unit',             # ADD
  completes_at: calculated_time,   # ADD (derive from blueprint production_time or use a sensible default)
  status: :pending,                # was: :materials_pending (not in enum)
  operational_data: {
    'unit_type'   => blueprint_data['id'] || blueprint.name.downcase.gsub(' ', '_'),
    'count'       => 1,
    'priority'    => 'normal'
  }
)
```

### Step 3 — Update specs

In `spec/services/manfacturing_service_spec.rb` and `spec/services/manufacturing/assembly_service_spec.rb`:
- Any assertion like `expect(job.start_date)` → `expect(job.operational_data['start_date'])`
- Any assertion like `expect(job.unit_type)` → `expect(job.operational_data['unit_type'])`

### Step 4 — Verify

```
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manfacturing_service_spec.rb spec/services/manufacturing/assembly_service_spec.rb'
```

---

## Progress (as of 2026-05-08)

### Current Status
- This refactor is **on hold**; not actively fixing at this time.
- The errors are well-understood: both services attempt to set attributes on `Job` that are not columns, and must migrate these to `operational_data`.
- No changes have been made to the service or spec files yet; the file documents the full migration plan and acceptance criteria.
- No new related failures or regressions have been reported.

### Findings
- `manufacturing_service.rb` and `assembly_service.rb` both require migration of non-schema attributes to `operational_data` and must ensure all mandatory fields are present in `Job.create!`.
- The spec files will need to update assertions to check `operational_data` instead of direct attributes.
- The reference implementation in `material_processing_service.rb` is available and should be followed exactly when this task is resumed.

### Next Steps
- Leave task in BACKLOG until/unless these errors block other work or requirements change.
- If reactivated: follow Implementation Steps above, focusing on correct attribute migration and spec assertion updates.

---

## Acceptance Criteria
- [ ] No `ActiveModel::UnknownAttributeError` in manufacturing_service or assembly_service.
- [ ] `Job.create!` in both services includes all 5 mandatory fields.
- [ ] `status: :pending` used (valid enum value) — not `:materials_pending`.
- [ ] `settlement:` used (not `base_settlement:`).
- [ ] Moved attributes are in `operational_data`.
- [ ] Isolation spec: 0 failures for these two spec files.

---

## Commit Instructions
`git add app/services/manufacturing_service.rb app/services/manufacturing/assembly_service.rb spec/services/manfacturing_service_spec.rb spec/services/manufacturing/assembly_service_spec.rb`
`git commit -m "fix: manufacturing_service and assembly_service — remove unknown Job attributes, migrate to operational_data"`
