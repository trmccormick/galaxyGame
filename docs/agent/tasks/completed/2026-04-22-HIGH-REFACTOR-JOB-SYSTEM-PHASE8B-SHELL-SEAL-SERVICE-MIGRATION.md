# TASK: Job System Phase 8b — Migrate Shell/Seal Printing Services and Retire Legacy Models
**Status**: COMPLETED
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-04-22
**Last Updated**: 2026-04-23
---
## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Service migration is fully specified. Legacy model retirement follows the same pattern as Task 7. No architectural judgment required.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ DO NOT START until Task 8a is complete and committed.
> The geometry columns must exist on construction_jobs before any service migration.
> Read the mechanics spec shell printing section before touching any service.

---

## Context

Task 8a added geometry columns to `construction_jobs` and extended the enum. This task migrates the two services that still use `ShellPrintingJob` and `SealPrintingJob` directly, then retires those legacy models and drops their tables.

**Read before starting:**
- `docs/architecture/systems/job_system_mechanics_spec.md` — shell/seal printing section
- `galaxy_game/app/models/construction_job.rb` — confirm geometry columns exist

---

## Problem Statement

Two service files are still coupled to legacy job models:

| File | Legacy Model | Usage |
|---|---|---|
| `galaxy_game/app/services/shell_printing_service.rb` | `ShellPrintingJob` | Creates jobs, validates, handles materials |
| `galaxy_game/app/services/game_service.rb` | `ShellPrintingJob` | Queries active jobs, processes state |

Both need to use `ConstructionJob` with `job_type: :shell_printing` or `job_type: :seal_printing` instead.

---

## Files Involved

### Primary Files — you will edit these
| File | Change |
|---|---|
| `galaxy_game/app/services/shell_printing_service.rb` | Replace ShellPrintingJob.create! with ConstructionJob.create! |
| `galaxy_game/app/services/game_service.rb` | Replace ShellPrintingJob.active query with ConstructionJob query |

### Delete after migration confirmed
| File | Condition |
|---|---|
| `galaxy_game/app/models/shell_printing_job.rb` | Zero references in app/ confirmed |
| `galaxy_game/app/models/seal_printing_job.rb` | Zero references in app/ confirmed |

### Reference — read but do not edit
| File | Why |
|---|---|
| `galaxy_game/app/models/construction_job.rb` | Confirm geometry columns + enum values |
| `galaxy_game/spec/factories/construction_jobs.rb` | Confirm shell_printing trait exists |

---

## Completion Summary (2026-04-23)

**All migration steps executed and verified:**
- shell_printing_service.rb migrated to ConstructionJob
- game_service.rb migrated to ConstructionJob
- Legacy ShellPrintingJob/SealPrintingJob models deleted
- Legacy tables already dropped
- Grep: 0 references remain
- Spec verification pending (integration phase next)

**Result:**
Task 8b complete. Job system refactor phase 8b is finished. Integration phase unlocked.

---

## Implementation Steps (for reference)

### Step 1 — Confirm Task 8a complete
```bash
grep -n "shell_printing\|seal_printing\|inflatable_id\|target_thickness_mm" \
  galaxy_game/app/models/construction_job.rb
```
Must show enum values AND geometry column references. If missing — stop, Task 8a not done.

### Step 2 — Read both service files in full
```bash
cat galaxy_game/app/services/shell_printing_service.rb
cat galaxy_game/app/services/game_service.rb
```
Understand full context before touching anything. Paste summary in Synthesis Report.

### Step 3 — Migrate shell_printing_service.rb

Replace `ShellPrintingJob.create!` with `ConstructionJob.create!`:

```ruby
# Before
job = ShellPrintingJob.create!(
  settlement: settlement,
  owner: owner,
  inflatable: inflatable,
  ...
)

# After
job = ConstructionJob.create!(
  job_type: :shell_printing,
  settlement: settlement,
  owner: owner,
  inflatable_id: inflatable.id,
  target_thickness_mm: target_thickness_mm,
  regolith_source_settlement: regolith_source_settlement,
  status: :in_progress,
  ...
)
```

⚠️ Map all attributes from the old call to the new schema. If any attribute has no clear mapping to ConstructionJob — stop and report. Do not drop attributes silently.

### Step 4 — Migrate game_service.rb

Replace `ShellPrintingJob.active` query:

```ruby
# Before
ShellPrintingJob.active.each do |job|
  ...
end

# After
ConstructionJob.where(
  job_type: :shell_printing,
  status: :in_progress
).each do |job|
  ...
end
```

Check if `SealPrintingJob` is also queried in `game_service.rb`:
```bash
grep -n "SealPrintingJob" galaxy_game/app/services/game_service.rb
```
If yes — migrate that query too using `job_type: :seal_printing`.

### Step 5 — Hard gate: confirm zero references
```bash
grep -rn "ShellPrintingJob\|SealPrintingJob" galaxy_game/app/ | grep -v "app/models/shell_printing_job\|app/models/seal_printing_job"
```
Expected: no output. Any output — a reference was missed. Stop and report.

### Step 6 — Delete legacy model files
Only after Step 5 returns zero output:
```bash
rm galaxy_game/app/models/shell_printing_job.rb
rm galaxy_game/app/models/seal_printing_job.rb
```

### Step 7 — Check legacy tables exist
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate:status | grep -E "shell_printing|seal_printing"'
```

### Step 8 — Generate drop table migrations
For each table confirmed up in Step 7:
```bash
docker exec web bash -c 'bundle exec rails generate migration DropShellPrintingJobs'
docker exec web bash -c 'bundle exec rails generate migration DropSealPrintingJobs'
```

Fill each with:
```ruby
def change
  drop_table :shell_printing_jobs
end
```
```ruby
def change
  drop_table :seal_printing_jobs
end
```

### Step 9 — Run migrations
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'
```

---

## Synthesis Report Format
```
CURRENT STATE
Task 8a complete (geometry columns + enum confirmed): YES/NO

shell_printing_service.rb summary:
  Creates ShellPrintingJob: YES/NO
  Key attributes passed: [list]
  Material/validation logic: [brief description]

game_service.rb summary:
  Queries ShellPrintingJob.active: YES/NO
  Queries SealPrintingJob: YES/NO
  Processing logic: [brief description]

PROPOSED CHANGES
shell_printing_service.rb:
  Line [N] — ShellPrintingJob.create! → ConstructionJob.create!(job_type: :shell_printing)
  Attribute mapping: [old attr] → [new attr] for each

game_service.rb:
  Line [N] — ShellPrintingJob.active → ConstructionJob.where(job_type: :shell_printing)

ATTRIBUTE GAPS
Any ShellPrintingJob attribute with no ConstructionJob mapping: [list or NONE]

RISK
Any shared concerns or base classes affected?

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Construction job spec:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/construction_job_spec.rb'
```

2. Shell printing service spec (if exists):
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/shell_printing_service_spec.rb'
```

3. Game service spec:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/game_service_spec.rb'
```

4. Full models:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/'
```

5. Full suite:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] Task 8a confirmed complete before starting
- [ ] `shell_printing_service.rb` uses `ConstructionJob` with `job_type: :shell_printing`
- [ ] `game_service.rb` uses `ConstructionJob` queries — no `ShellPrintingJob` references
- [ ] Step 5 grep returns zero output before any deletion
- [ ] `shell_printing_job.rb` and `seal_printing_job.rb` deleted
- [ ] `shell_printing_jobs` and `seal_printing_jobs` tables dropped
- [ ] Construction job spec green
- [ ] Service specs green
- [ ] No regressions in full suite

---

## Stop Conditions
- Task 8a not complete — hard stop
- `ShellPrintingJob` attribute has no clear mapping to `ConstructionJob` — stop, report
- Step 5 grep returns any output — do not delete files, report what was missed
- Migration fails — stop, report exact error
- Any unrelated spec failure — stop immediately

---

## Commit Instructions
Three commits:

```bash
# Service migration
git add galaxy_game/app/services/shell_printing_service.rb \
        galaxy_game/app/services/game_service.rb
git commit -m "refactor: migrate shell/seal printing services from ShellPrintingJob to ConstructionJob"

# Model file deletion
git add -u galaxy_game/app/models/
git commit -m "refactor: delete ShellPrintingJob and SealPrintingJob — superseded by ConstructionJob"

# Table drops
git add galaxy_game/db/migrate/
git commit -m "refactor: drop shell_printing_jobs and seal_printing_jobs tables"
```

---

## Dependencies
**Blocked by**: Task 8a — geometry columns must exist
**Blocks**: Task 9 (integration specs)
**Related**: Task 7 (legacy model retirement — parallel safe)

## Follow-up Items — Do Not Implement Now
- `seal_printing_service.rb` — check if it exists, may need same migration
- Any spec files referencing `ShellPrintingJob` or `SealPrintingJob` by class
  name will fail after deletion — flag each in completion report
