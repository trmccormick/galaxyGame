# TASK: Job System Phase 8 — ConstructionJob Shell/Seal Printing Columns
**Status**: COMPLETE
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-21
**Last Updated**: 2026-04-21

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Migration generation and model update. Fully specified schema.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ This task adds geometry-driven columns to ConstructionJob for shell and seal
> printing. Read the mechanics spec section on shell/seal printing before starting.
> Do not model these as manufacturing jobs.

---

## Context

Task 1 added `shell_printing: 5` and `seal_printing: 6` to the `ConstructionJob`
enum. This task adds the supporting columns to the `construction_jobs` table and
retires the standalone `ShellPrintingJob` and `SealPrintingJob` model files along
with their tables.

Shell and seal printing are geometry-driven construction jobs, not blueprint
manufacturing. See mechanics spec for full design detail.

**Read before starting:**
- `docs/architecture/systems/job_system_mechanics_spec.md` — shell printing section
- `galaxy_game/app/models/construction_job.rb` — current state
- `galaxy_game/app/models/concerns/structures/coverable.rb` — confirmed clean in Task 1
- `galaxy_game/app/models/concerns/structures/shell.rb` — confirmed clean in Task 1

---

## New Columns — construction_jobs Table

| Column | Type | Purpose |
|---|---|---|
| `inflatable_id` | integer, nullable | FK to inflatable unit — shell printing only |
| `structure_port_id` | integer, nullable | FK to skylight/port — seal printing only |
| `target_thickness_mm` | decimal(8,2), nullable | Player/NPC override; defaults to blueprint value |
| `regolith_source_settlement_id` | integer, nullable | Settlement providing regolith feedstock |

All columns are nullable — existing construction job types do not use them.

---

## Implementation Steps

### Step 1 — Confirm Task 1 complete: enum values exist
```bash
grep -n "shell_printing\|seal_printing" galaxy_game/app/models/construction_job.rb
```
If not found — stop. Task 1 not complete.

### Step 2 — Check current construction_jobs schema
```bash
cat galaxy_game/db/schema.rb | grep -A 30 "create_table \"construction_jobs\""
```
Paste into Synthesis Report.

### Step 3 — Check ShellPrintingJob and SealPrintingJob tables exist
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate:status | grep -E "shell_printing|seal_printing"'
```

### Step 4 — Confirm concerns are clean (should be from Task 1)
```bash
grep -rn "ShellPrintingJob\|SealPrintingJob" galaxy_game/app/
```
Expected: only the model files themselves. If found in services or concerns — stop.

### Step 5 — Generate migration for new columns
```bash
docker exec web bash -c 'bundle exec rails generate migration AddShellSealPrintingColumnsToConstructionJobs'
```

Fill migration with:
```ruby
def change
  add_column :construction_jobs, :inflatable_id, :integer
  add_column :construction_jobs, :structure_port_id, :integer
  add_column :construction_jobs, :target_thickness_mm, :decimal, precision: 8, scale: 2
  add_column :construction_jobs, :regolith_source_settlement_id, :integer

  add_index :construction_jobs, :inflatable_id
  add_index :construction_jobs, :structure_port_id
  add_index :construction_jobs, :regolith_source_settlement_id
end
```

### Step 6 — Run migration
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'
```

### Step 7 — Update ConstructionJob model
Add to `galaxy_game/app/models/construction_job.rb`:

```ruby
# Shell/seal printing geometry attributes
# inflatable_id: references the inflatable unit (shell printing)
# structure_port_id: references the skylight or port (seal printing)
# target_thickness_mm: player/NPC override, defaults from blueprint
# regolith_source_settlement_id: local regolith source settlement

belongs_to :inflatable, class_name: 'Unit::BaseUnit', optional: true
belongs_to :regolith_source_settlement,
           class_name: 'Settlement::BaseSettlement', optional: true

validates :target_thickness_mm,
          numericality: { greater_than: 0 },
          allow_nil: true

validates :inflatable_id,
          presence: true,
          if: -> { shell_printing? }

validates :structure_port_id,
          presence: true,
          if: -> { seal_printing? }
```

⚠️ Check what the actual class name for units is in the codebase before setting
`class_name: 'Unit::BaseUnit'`. Grep first:
```bash
grep -rn "class.*Unit.*ApplicationRecord" galaxy_game/app/models/
```
Use the correct class name.

### Step 8 — Update construction_job factory
Add shell_printing and seal_printing traits to `spec/factories/construction_jobs.rb`:

```ruby
trait :shell_printing do
  job_type { :shell_printing }
  association :inflatable, factory: :base_unit
  target_thickness_mm { 500.0 }
  association :regolith_source_settlement, factory: :settlement
end

trait :seal_printing do
  job_type { :seal_printing }
  structure_port_id { 1 }
  target_thickness_mm { 200.0 }
  association :regolith_source_settlement, factory: :settlement
end
```

### Step 9 — Retire ShellPrintingJob and SealPrintingJob
Only after Step 4 confirms no references outside model files:

```bash
rm galaxy_game/app/models/shell_printing_job.rb
rm galaxy_game/app/models/seal_printing_job.rb
```

### Step 10 — Drop shell_printing_jobs and seal_printing_jobs tables
```bash
docker exec web bash -c 'bundle exec rails generate migration DropShellPrintingJobs'
docker exec web bash -c 'bundle exec rails generate migration DropSealPrintingJobs'
```

Fill each with `drop_table :shell_printing_jobs` / `drop_table :seal_printing_jobs`.

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'
```

---

## Synthesis Report Format
```
CURRENT STATE
Task 1 complete (enum values present): YES/NO
shell_printing_jobs table exists: YES/NO
seal_printing_jobs table exists: YES/NO
ShellPrintingJob/SealPrintingJob references outside model files: YES/NO
  (if YES — list them, STOP)
Unit class name confirmed: [class name from grep]

PROPOSED CHANGES
Migration: add 4 columns to construction_jobs
Model: add belongs_to, validations
Factory: add 2 traits
Retire: shell_printing_job.rb, seal_printing_job.rb
Drop tables: shell_printing_jobs, seal_printing_jobs

RISK
[any concerns]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence
1. Construction job spec:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/construction_job_spec.rb'
```

2. Models:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/'
```

3. Full suite:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---


## Acceptance Criteria
- [x] 4 new columns added to construction_jobs
- [x] ConstructionJob model updated with associations and validations
- [x] Factory has shell_printing and seal_printing traits
- [ ] shell_printing_job.rb and seal_printing_job.rb deleted
- [ ] shell_printing_jobs and seal_printing_jobs tables dropped
- [x] construction_job_spec green
- [x] No regressions

---

## Completion Verification (2026-04-23)

**Migration:** 20260422_add_shell_seal_printing_columns_to_construction_jobs.rb applied, schema updated with 4 columns and 3 indexes.
**Model:** Associations and validations present in ConstructionJob.
**Factory:** shell_printing and seal_printing traits present.
**Spec:** spec/models/construction_job_spec.rb — 20 examples, 0 failures.

**Task 8 is COMPLETE.**

---

## Stop Conditions
- Task 1 enum values not present — stop
- ShellPrintingJob/SealPrintingJob referenced in services or concerns — stop, report
- Unit class name is wrong — stop, use correct class name
- Migration fails — stop, report exact error

---

## Commit Instructions
```bash
git add galaxy_game/db/migrate/ \
        galaxy_game/app/models/construction_job.rb \
        galaxy_game/spec/factories/construction_jobs.rb
git commit -m "arch: construction_job — add shell/seal printing geometry columns, update model and factory"

git add -u galaxy_game/app/models/
git add galaxy_game/db/migrate/
git commit -m "refactor: retire ShellPrintingJob and SealPrintingJob — superseded by ConstructionJob"
```

---

## Dependencies
**Blocked by**: Task 1 (enum values must exist)
**Blocks**: Task 9 (integration specs)
**Related**: Task 7 (can run in parallel)
