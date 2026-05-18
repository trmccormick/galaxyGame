# 2026-04-20-CRITICAL-ARCHITECTURE-JOB-PROCESSOR-WORKER

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: Claude 1x — Critical architecture task requiring judgment on job type association and Sidekiq configuration
**Supervision Level**: 🟢 Autonomous OK

## Context
All in-progress jobs across all job types advance and complete correctly via Sidekiq worker. game.rb#process_jobs removed. Integration specs rewritten to use worker. Job system is execution substrate for AI Manager.

## Problem Statement
Jobs created with status 'in_progress' never advance. game.rb#process_jobs ticks only ShellPrintingJob via inline logic, bypassing process_tick. All other job types never complete.

**Expected**: Sidekiq worker periodically queries all in-progress jobs across all job types, calls process_tick(hours_elapsed) on each, lets job model handle completion.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/workers/job_processor_worker.rb` | Sidekiq worker | Ticks all in-progress jobs |
| `config/schedule.rb` | Cron schedule | Worker scheduling |

### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/models/game.rb` | Game model | Remove process_jobs method |
| `spec/rails_helper.rb` | Test config | Add Sidekiq inline mode |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/material_processing_job.rb` | Verify process_tick signature |
| `app/models/component_production_job.rb` | Verify process_tick signature |
| `config/sidekiq.yml` | Queue configuration |

## Implementation Steps
1. **Create worker**: app/workers/job_processor_worker.rb with JOB_CLASSES array, perform method calling tick_jobs for each class
2. **Configure Sidekiq inline**: Add to spec/rails_helper.rb for test environment
3. **Remove process_jobs**: Remove method and call from game.rb
4. **Mark specs pending**: 6 integration specs in manufacturing_pipeline_e2e_spec.rb and component_production_game_loop_spec.rb
5. **Rewrite specs**: Replace game.advance_by_days with JobProcessorWorker.new.perform(hours)
6. **Scheduler config**: Configure sidekiq-scheduler if gem exists

## Acceptance Criteria
- [ ] app/workers/job_processor_worker.rb exists with Sidekiq::Worker include
- [ ] Worker calls process_tick on all 9 job types
- [ ] Worker handles individual job failures gracefully
- [ ] game.rb#process_jobs removed
- [ ] Sidekiq inline mode configured in spec/rails_helper.rb
- [ ] 6 integration specs rewritten and green via worker
- [ ] No regressions in manufacturing service specs
- [ ] Full suite run completed and logged

## Stop Conditions
- Job model missing process_tick — escalate
- Sidekiq inline causes unexpected failures outside manufacturing specs
- game.rb change causes failures in non-job specs
- Scheduler gem missing — flag, don't add gem without approval

## Commit Instructions
```bash
git add app/workers/job_processor_worker.rb
git add app/models/game.rb
git add spec/rails_helper.rb
git add spec/integration/manufacturing_pipeline_e2e_spec.rb
git add spec/integration/component_production_game_loop_spec.rb
git commit -m "arch: JobProcessorWorker — Sidekiq job ticking infrastructure, remove game.rb#process_jobs"
```