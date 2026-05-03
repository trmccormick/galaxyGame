# TASK: Add construction job_types to unified Job model enum
**Status**: ❌ CANCELLED  
**Priority**: HIGH  
**Type**: refactor  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-03  

> **CANCELLED 2026-05-03**: Architectural review confirmed `ConstructionJob` and `Job` are structurally incompatible. `ConstructionJob` has a gathering phase (material_requests, equipment_requests), polymorphic `jobable`, geometry attributes (`target_thickness_mm`, `structure_port_id`), 8-state lifecycle, and pause/resume. `Job` is a timer-based manufacturing work order with 5 mandatory fields and no gathering phase. Merging them would bloat both models with nullable columns and destroy their semantics. `ConstructionJob` stays as a permanent separate model.

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x  
**Why This Agent**: Requires architectural reasoning — must extend the Job enum and migration without breaking existing job_type consumers across services and specs  
**Supervision Level**: 🟢 Autonomous OK

---

## Context

`Job` is the intended unified job model for all work orders in the system (see session handoff 2026-04-20). Currently the `job_type` enum on `Job` only covers manufacturing/processing types. `ConstructionJob` is a separate model with its own `job_type` enum covering construction-specific types. This task extends `Job`'s enum to include all construction types, making the single model capable of representing both.

This is step 2 of the Job model unification. Step 1 (spec fix) is:  
`docs/agent/tasks/backlog/2026-05-01-HIGH-BUGFIX-JOB-PROCESSOR-WORKER-SPEC-FAILURES.md`

**Relevant Architecture Docs** — read before starting:
- `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md` — job system architecture decisions

---

## Problem Statement

`Job#job_type` enum currently contains:
```ruby
enum job_type: {
  material_processing: 0,
  component_production: 1,
  smelting: 2,
  unit_assembly: 3,
  resource_processing: 4,
  environment_processing: 5
}
```

`ConstructionJob#job_type` enum contains:
```ruby
enum job_type: {
  crater_dome_construction: 0,
  skylight_cover: 1,
  access_point_conversion: 2,
  habitat_expansion: 3,
  structure_upgrade: 4,
  shell_printing: 5,
  seal_printing: 6
}
```

These need to be merged into `Job` using non-overlapping integer values (6–12 for construction types to avoid colliding with existing 0–5).

**Current behavior**: `Job` cannot represent construction work orders  
**Expected behavior**: `Job#job_type` can represent all work order types

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/models/job.rb` | Unified job model | `enum job_type` |
| `db/migrate/` | New migration to update enum comment only (enum is app-side) | — |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/construction_job.rb` | Source of construction job_types to merge |
| `db/migrate/20250612231348_create_construction_jobs.rb` | Original construction_jobs schema |
| `spec/factories/jobs.rb` | Factory needs trait additions after this task |

### Migration
- [ ] Migration needed: add a comment migration documenting the extended enum (Rails enums are app-side; no DB column change needed unless you add a check constraint)
  ```bash
  docker exec web bash -c 'unset DATABASE_URL && bundle exec rails generate migration ExtendJobTypeEnumWithConstructionTypes'
  ```
  Migration body: empty `change` method with a comment documenting the enum values — this serves as a paper trail in schema history.

---

## Implementation Steps

### Step 1 — Extend Job enum

```ruby
# app/models/job.rb — BEFORE
enum job_type: {
  material_processing: 0,
  component_production: 1,
  smelting: 2,
  unit_assembly: 3,
  resource_processing: 4,
  environment_processing: 5
}

# AFTER — construction types start at 6 to avoid collision
enum job_type: {
  material_processing: 0,
  component_production: 1,
  smelting: 2,
  unit_assembly: 3,
  resource_processing: 4,
  environment_processing: 5,
  # Construction types (unified from ConstructionJob — see unification task)
  crater_dome_construction: 6,
  skylight_cover: 7,
  access_point_conversion: 8,
  habitat_expansion: 9,
  structure_upgrade: 10,
  shell_printing: 11,
  seal_printing: 12
}
```

### Step 2 — Add construction status values to Job

`ConstructionJob` has statuses (`scheduled`, `materials_pending`, `equipment_pending`, `workers_pending`) not present in `Job`. Add them:

```ruby
# app/models/job.rb — current status enum
enum status: {
  in_progress: 0,
  ready_to_claim: 1,
  claimed: 2,
  failed: 3,
  cancelled: 4,
  pending: 5
}

# AFTER — add construction lifecycle statuses (start at 6)
enum status: {
  in_progress: 0,
  ready_to_claim: 1,
  claimed: 2,
  failed: 3,
  cancelled: 4,
  pending: 5,
  scheduled: 6,
  materials_pending: 7,
  equipment_pending: 8,
  workers_pending: 9
}
```

> ⚠️ Check all existing `Job` status consumers before adding. Run:
> `grep -rn "\.scheduled\|\.materials_pending\|\.equipment_pending\|\.workers_pending" galaxy_game/app/`
> If any collisions exist in existing code, report before proceeding.

### Step 3 — Add empty paper-trail migration

```bash
docker exec web bash -c 'unset DATABASE_URL && bundle exec rails generate migration ExtendJobTypeEnumWithConstructionTypes'
```

Edit the generated migration to be an empty `change` with a comment:
```ruby
class ExtendJobTypeEnumWithConstructionTypes < ActiveRecord::Migration[7.0]
  # Job#job_type enum extended to include construction types (6-12)
  # Job#status enum extended to include construction lifecycle statuses (6-9)
  # These are app-side enums — no DB column changes needed.
  # See: docs/agent/tasks/backlog/2026-05-01-HIGH-REFACTOR-JOB-MODEL-ADD-CONSTRUCTION-JOB-TYPES.md
  def change
  end
end
```

Run: `docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'`

### Step 4 — Add factory traits for construction job_types

In `spec/factories/jobs.rb`, add traits:

```ruby
trait :crater_dome_construction do
  job_type { :crater_dome_construction }
  output_type { "Structure" }
end

trait :shell_printing do
  job_type { :shell_printing }
  output_type { "Structure" }
end
```

### Step 5 — Run worker spec to confirm nothing regressed

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/workers/job_processor_worker_spec.rb'
```

Expected: 5 examples, 0 failures

---

## Acceptance Criteria
- [ ] `Job.new(job_type: :crater_dome_construction)` does not raise
- [ ] `Job.new(job_type: :shell_printing)` does not raise
- [ ] `Job.new(status: :scheduled)` does not raise
- [ ] Worker spec: 5 examples, 0 failures
- [ ] No regressions in `spec/models/` for Job
- [ ] Migration runs cleanly in test env

---

## Stop Conditions — escalate to user immediately if:
- Any existing service or spec uses an integer value directly for `job_type` (not symbol) — collision risk
- Status enum has a name collision with existing code
- More than 3 files need changes beyond what is listed here

---

## Commit Instructions
Run from **host** terminal:
```bash
git add galaxy_game/app/models/job.rb
git add galaxy_game/spec/factories/jobs.rb
git add galaxy_game/db/migrate/
git commit -m "refactor: Job model — extend job_type and status enums with construction types for unified model"
git push
```

---

## Documentation
- [ ] No doc changes needed — architecture intent already documented in session_handoff_2026-04-20.md

---

## Dependencies
**Blocked by**: `2026-05-01-HIGH-BUGFIX-JOB-PROCESSOR-WORKER-SPEC-FAILURES.md` (assign first)  
**Blocks**: `2026-05-01-HIGH-REFACTOR-JOB-MODEL-MIGRATE-CONSTRUCTION-JOB-COLUMNS.md`  
**Related tasks**: all unification tasks in this series

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:  
**Completion date**:  
**Final test result**:  

### What was changed

### Issues discovered

### Follow-up tasks needed

### Lessons learned
