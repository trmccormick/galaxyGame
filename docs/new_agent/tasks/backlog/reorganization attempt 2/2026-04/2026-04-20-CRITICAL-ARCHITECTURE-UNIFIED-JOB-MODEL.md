# 2026-04-20-CRITICAL-ARCHITECTURE-UNIFIED-JOB-MODEL

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: Claude 1x — Critical architecture task requiring schema design, migration, model consolidation judgment
**Supervision Level**: 🟢 Autonomous OK

## Context
One unified Job model handles all small manufacturing jobs. ConstructionJob handles surface construction including shell/seal printing. OrbitalConstructionProject handles orbital/large craft construction. JobProcessorWorker rebuilt against clean models.

## Problem Statement
9 separate job models, 3 missing database tables (smelting_jobs, environment_jobs, resource_jobs), duplicate file (smelting_jobs.rb with broken class name), JobProcessorWorker built against all 9 models including missing ones. Worker fails with PG::UndefinedTable errors.

**Expected**: Three job model categories with clear tables, lifecycles, worker responsibility. Small jobs unified. Worker rebuilt against clean models. Legacy models retired with migration path.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `db/migrate/TIMESTAMP_create_jobs.rb` | Jobs table migration | Create unified jobs table |
| `app/models/job.rb` | Unified Job model | Polymorphic owner, job_type enum, status enum |
| `spec/models/job_spec.rb` | Model spec | Test enums, scopes, methods |
| `spec/factories/jobs.rb` | Factory | Test data factory |

### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/workers/job_processor_worker.rb` | Worker | Rebuild against Job + ConstructionJob |
| `app/models/construction_job.rb` | Construction model | Add shell_printing, seal_printing enum values |
| `spec/workers/job_processor_worker_spec.rb` | Worker spec | Rewrite against new worker |

### Primary Files — you will delete
| File | Purpose | Action |
|---|---|---|
| `app/models/smelting_jobs.rb` | Broken duplicate | Delete immediately |
| `app/models/smelting_job.rb` | Legacy model | Delete after Job model exists |

## Implementation Steps
1. **Delete broken duplicate**: rm app/models/smelting_jobs.rb
2. **Verify concerns**: Confirm coverable.rb/shell.rb use ConstructionJob only
3. **Extend ConstructionJob enum**: Add shell_printing: 5, seal_printing: 6
4. **Generate migration**: rails generate migration CreateJobs
5. **Run migration**: RAILS_ENV=test bundle exec rails db:migrate
6. **Create Job model**: With polymorphic owner, settlement, blueprint associations
7. **Create factory**: With in_progress, ready_to_claim, claimed, overdue traits
8. **Rebuild worker**: Query Job.ready_to_process and ConstructionJob.where(status: :in_progress)
9. **Rewrite worker spec**: Test small job completion and construction job advancement
10. **Verify legacy references**: grep for legacy model usage before retirement

## Acceptance Criteria
- [ ] smelting_jobs.rb deleted
- [ ] jobs table created and migrated in test environment
- [ ] Job model exists with correct enum values and scopes
- [ ] spec/factories/jobs.rb exists with required traits
- [ ] ConstructionJob enum includes shell_printing and seal_printing
- [ ] JobProcessorWorker rebuilt — queries Job and ConstructionJob only
- [ ] Worker spec green — 0 failures
- [ ] No legacy job model references remain in app/ code
- [ ] Full suite run completed and logged — no regressions

## Stop Conditions
- ShellPrintingJob/SealPrintingJob referenced in concerns directly — escalate
- Legacy job model has production DB records — data migration required
- ConstructionJob#advance! does not exist — escalate
- Migration fails — report exact error

## Commit Instructions
```bash
git add db/migrate/TIMESTAMP_create_jobs.rb
git add app/models/job.rb
git add spec/models/job_spec.rb
git add spec/factories/jobs.rb
git add app/workers/job_processor_worker.rb
git add app/models/construction_job.rb
git add spec/workers/job_processor_worker_spec.rb
git commit -m "arch: unified job model — consolidate small manufacturing jobs into Job model"
```