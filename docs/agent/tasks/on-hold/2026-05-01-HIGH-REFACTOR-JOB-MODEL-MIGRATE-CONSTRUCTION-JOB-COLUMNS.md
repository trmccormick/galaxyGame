# TASK: Migrate ConstructionJob-specific columns into the jobs table
**Status**: ❌ CANCELLED  
**Priority**: HIGH  
**Type**: refactor  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-03  

> **CANCELLED 2026-05-03**: Architectural review confirmed `ConstructionJob` and `Job` are structurally incompatible and must remain separate models. Column migration is moot. See cancellation note in ADD-CONSTRUCTION-JOB-TYPES task for full reasoning.

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x  
**Why This Agent**: Requires cross-schema reasoning, migration authoring, and careful column mapping between two different table structures  
**Supervision Level**: 🟢 Autonomous OK

---

## Context

This is step 3 of the Job model unification. The `construction_jobs` table has several columns not present in `jobs`. Before `ConstructionJob` references in code can be replaced with `Job`, the `jobs` table must be able to store construction-specific data.

We are in development — no production data to migrate. The goal is schema alignment, not data movement.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md` — job system architecture decisions
- `docs/agent/tasks/backlog/2026-05-01-HIGH-REFACTOR-JOB-MODEL-ADD-CONSTRUCTION-JOB-TYPES.md` — must be completed first

---

## Problem Statement

`construction_jobs` table columns that do not exist in `jobs`:

| Column | Type | Purpose |
|---|---|---|
| `jobable_type` / `jobable_id` | polymorphic | what structure is being built |
| `target_values` | jsonb | construction target parameters |
| `start_date` | datetime | when construction began |
| `completion_date` | datetime | actual completion |
| `estimated_completion` | datetime | estimated done time |
| `priority` | string | job priority level |
| `completion_percentage` | integer | progress tracker |
| `inflatable_id` | integer | shell printing: inflatable unit |
| `structure_port_id` | integer | seal printing: port reference |
| `target_thickness_mm` | decimal | shell/seal geometry |
| `regolith_source_settlement_id` | integer | shell printing: regolith source |
| `result_data` | jsonb | construction outcome data |

`jobs` table currently has `specifications` (jsonb) and `operational_data` (jsonb) which can absorb some of these. However, the polymorphic `jobable` reference and geometry columns need explicit columns.

**Current behavior**: `Job` cannot store construction-specific data  
**Expected behavior**: `Job` can represent any construction work order with full fidelity

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `db/migrate/` | New migration adding columns to `jobs` | — |
| `app/models/job.rb` | Add new associations and store declarations | `belongs_to :jobable` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `db/migrate/20250612231348_create_construction_jobs.rb` | Source of truth for construction columns |
| `db/migrate/20260423131010_add_shell_seal_columns_to_construction_jobs.rb` | Additional shell/seal columns |
| `app/models/construction_job.rb` | Current associations and validations |

### Migration
- [ ] Migration needed: add construction columns to `jobs` table
  ```bash
  docker exec web bash -c 'unset DATABASE_URL && bundle exec rails generate migration AddConstructionColumnsToJobs'
  ```

---

## Implementation Steps

### Step 1 — Generate and write the migration

```bash
docker exec web bash -c 'unset DATABASE_URL && bundle exec rails generate migration AddConstructionColumnsToJobs'
```

Edit the generated file:

```ruby
class AddConstructionColumnsToJobs < ActiveRecord::Migration[7.0]
  def change
    # Polymorphic jobable — what structure is being built
    add_reference :jobs, :jobable, polymorphic: true, null: true, index: true

    # Construction target/result data
    add_column :jobs, :target_values, :jsonb, default: {}
    add_column :jobs, :result_data, :jsonb, default: {}

    # Construction lifecycle dates
    add_column :jobs, :start_date, :datetime
    add_column :jobs, :completion_date, :datetime
    add_column :jobs, :estimated_completion, :datetime

    # Priority and progress
    add_column :jobs, :priority, :string, default: 'normal'
    add_column :jobs, :completion_percentage, :integer, default: 0

    # Shell/seal printing geometry
    add_column :jobs, :inflatable_id, :integer
    add_column :jobs, :structure_port_id, :integer
    add_column :jobs, :target_thickness_mm, :decimal
    add_column :jobs, :regolith_source_settlement_id, :integer
  end
end
```

### Step 2 — Run migration in test env

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'
```

### Step 3 — Add associations and stores to Job model

```ruby
# app/models/job.rb — add after existing belongs_to lines

belongs_to :jobable, polymorphic: true, optional: true
belongs_to :inflatable, class_name: 'Units::BaseUnit', foreign_key: :inflatable_id, optional: true
belongs_to :regolith_source_settlement, class_name: 'Settlement::BaseSettlement',
           foreign_key: :regolith_source_settlement_id, optional: true

store :target_values, coder: JSON
store :result_data, coder: JSON
```

> ⚠️ `store :target_values` will conflict if the column is `jsonb` and already accessed as a hash.
> Test that `Job.new.target_values` returns `{}` after migration. If it raises, report before proceeding.

### Step 4 — Verify Job.new.attributes contains all new columns

```bash
docker exec -i web bash -c "unset DATABASE_URL; RAILS_ENV=test bundle exec rails c -e test" <<EOF
Job.new.attributes.keys.sort
EOF
```

Confirm `jobable_type`, `jobable_id`, `target_values`, `result_data`, `inflatable_id`, `completion_percentage` appear.

### Step 5 — Run worker spec to confirm no regressions

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/workers/job_processor_worker_spec.rb'
```

Expected: 5 examples, 0 failures

---

## Acceptance Criteria
- [ ] Migration runs cleanly in test env
- [ ] `Job.new.attributes` contains all construction columns
- [ ] `Job.new(jobable: some_structure, job_type: :crater_dome_construction)` does not raise
- [ ] Worker spec: 5 examples, 0 failures
- [ ] No regressions in existing Job model specs

---

## Stop Conditions — escalate to user immediately if:
- `store :target_values` conflicts with jsonb column access
- Any existing spec breaks because of new `belongs_to :jobable` or `store` declarations
- Migration fails — paste exact error, do not attempt workaround

---

## Commit Instructions
Run from **host** terminal:
```bash
git add galaxy_game/app/models/job.rb
git add galaxy_game/db/migrate/
git commit -m "refactor: add construction columns to jobs table — unified job model step 3"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: `2026-05-01-HIGH-REFACTOR-JOB-MODEL-ADD-CONSTRUCTION-JOB-TYPES.md`  
**Blocks**: `2026-05-01-HIGH-REFACTOR-JOB-MODEL-REPLACE-CONSTRUCTION-JOB-REFERENCES.md`  
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
