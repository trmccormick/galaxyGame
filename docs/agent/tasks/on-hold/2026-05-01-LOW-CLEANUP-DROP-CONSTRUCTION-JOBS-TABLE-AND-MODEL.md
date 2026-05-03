# TASK: Drop construction_jobs table and remove ConstructionJob model — final cleanup
**Phase**: 4 — Promote to backlog ~May 22
**Status**: ❌ CANCELLED  
**Priority**: LOW  
**Type**: refactor  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-03  

> **CANCELLED 2026-05-03**: Architectural review confirmed `ConstructionJob` is a permanent separate model. The table must NOT be dropped. `ConstructionJob` handles surface construction (crater domes, shell printing, skylight covers, worldhouse sealing) with a gathering phase, polymorphic jobable, geometry attributes, and 8-state lifecycle — fundamentally different from the timer-based manufacturing `Job` model. See cancellation note in ADD-CONSTRUCTION-JOB-TYPES task for full reasoning.

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Mechanical cleanup — drop table, delete model file, verify no remaining references. All prior unification steps must be complete first.  
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agents: do NOT run this task until all tasks 1–5 in the unification series are marked COMPLETED.
> Check `docs/agent/tasks/backlog/` and `docs/agent/tasks/completed/` before starting.

---

## Context

This is the final step of the Job model unification. All `ConstructionJob` references in code and specs have been removed by prior tasks. This task removes the model file and drops the table from development and test databases.

We are in development — no production data at risk.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md` — job system architecture decisions

---

## Problem Statement

After tasks 1–5 complete:
- `app/models/construction_job.rb` still exists but is unused
- `construction_jobs` table still exists in test and development DBs
- Migrations for `construction_jobs` still exist in `db/migrate/`

These must be cleaned up to remove dead code and prevent confusion.

**Current behavior**: Orphan model file and table remain after unification  
**Expected behavior**: No trace of `ConstructionJob` in codebase or schema

---

## Files Involved

### Primary Files — you will edit/delete these
| File | Action |
|---|---|
| `app/models/construction_job.rb` | Delete via `git rm` |
| `db/migrate/` | Write DROP migration for the table |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `db/migrate/20250612231348_create_construction_jobs.rb` | Know what the original table looked like |

### Pre-flight check — run BEFORE doing anything
```bash
grep -rn "ConstructionJob\|construction_job" galaxy_game/app/ galaxy_game/spec/
```

**Expected result: 0 matches.**  
If ANY matches are found, STOP. Do not proceed. Report to user — prior tasks are not fully complete.

### Migration
- [ ] Migration needed: drop `construction_jobs` table
  ```bash
  docker exec web bash -c 'unset DATABASE_URL && bundle exec rails generate migration DropConstructionJobsTable'
  ```

---

## Implementation Steps

### Step 1 — Pre-flight check (MANDATORY before any other step)

```bash
grep -rn "ConstructionJob\|construction_job" galaxy_game/app/ galaxy_game/spec/
```

If result is NOT 0 matches: **STOP. Report to user. Do not proceed.**

### Step 2 — Generate and write the drop migration

```bash
docker exec web bash -c 'unset DATABASE_URL && bundle exec rails generate migration DropConstructionJobsTable'
```

Edit the generated file:

```ruby
class DropConstructionJobsTable < ActiveRecord::Migration[7.0]
  def change
    # Final cleanup — ConstructionJob unified into Job model
    # See: docs/agent/tasks/ series 2026-05-01-HIGH-REFACTOR-JOB-MODEL-*
    drop_table :construction_jobs
  end
end
```

### Step 3 — Run migration in both test and development environments

```bash
# Test
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'

# Development
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=development bundle exec rails db:migrate'
```

### Step 4 — Delete the model file

```bash
git rm galaxy_game/app/models/construction_job.rb
```

### Step 5 — Update the worker to stop calling `process_jobs(ConstructionJob)`

Read `app/workers/job_processor_worker.rb`. Remove the `process_jobs(ConstructionJob)` line:

```ruby
# BEFORE
def perform
  Rails.logger.info("JobProcessorWorker: processing all in-progress jobs (Job, ConstructionJob)")
  process_jobs(Job)
  process_jobs(ConstructionJob)
end

# AFTER
def perform
  Rails.logger.info("JobProcessorWorker: processing all in-progress jobs")
  process_jobs(Job)
end
```

### Step 6 — Verify clean state

```bash
# No ConstructionJob references anywhere
grep -rn "ConstructionJob\|construction_job" galaxy_game/app/ galaxy_game/spec/

# Schema no longer has construction_jobs
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "puts ActiveRecord::Base.connection.tables.include?(\"construction_jobs\")"'
```

Expected: `false`

### Step 7 — Run worker spec

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/workers/job_processor_worker_spec.rb'
```

Expected: 5 examples, 0 failures

---

## Acceptance Criteria
- [ ] `grep -rn "ConstructionJob" galaxy_game/` returns 0 matches (excluding `db/migrate/` old files — those can remain as historical record)
- [ ] `construction_jobs` table does not exist in test DB
- [ ] `app/models/construction_job.rb` does not exist
- [ ] Worker no longer calls `process_jobs(ConstructionJob)`
- [ ] Worker spec: 5 examples, 0 failures

---

## Stop Conditions — escalate to user immediately if:
- Pre-flight grep returns ANY matches — prior tasks are not complete
- Drop migration fails because of foreign key constraints — report exact error
- Worker spec fails after removing `process_jobs(ConstructionJob)` line

---

## Commit Instructions
Run from **host** terminal:
```bash
git rm galaxy_game/app/models/construction_job.rb
git add galaxy_game/app/workers/job_processor_worker.rb
git add galaxy_game/db/migrate/
git commit -m "refactor: drop construction_jobs table and remove ConstructionJob model — unification complete"
git push
```

---

## Documentation
- [ ] No doc changes needed — update `docs/agent/CURRENT_STATUS.md` to note Job model unification complete

---

## Dependencies
**Blocked by**: `2026-05-01-HIGH-REFACTOR-JOB-MODEL-UPDATE-FACTORIES-AND-SPECS.md` (ALL prior tasks must be COMPLETED)  
**Blocks**: nothing  
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
