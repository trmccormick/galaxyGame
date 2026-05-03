# TASK: Build JobProcessorWorker — Sidekiq Job Ticking Infrastructure
**Status**: BACKLOG
**Priority**: CRITICAL
**Type**: architecture
**Created**: 2026-04-20
**Last Updated**: 2026-04-20

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Architectural build across multiple files, requires judgment on
job type association differences, Sidekiq configuration, and test environment setup.
**Supervision Level**: 🟢 Autonomous OK

---

## North Star

All in-progress jobs across all job types advance and complete correctly via a
Sidekiq worker. `game.rb#process_jobs` is removed. Integration specs that test
job completion are rewritten to use the worker. The job system is the execution
substrate for the AI Manager — this worker is the missing piece that makes
`TaskExecutionEngine` outputs real.

---

## Context

The game has 9 job model types, each with a self-contained `process_tick(hours_elapsed)`
method that advances progress and sets `status: 'completed'` when done. No external
service is needed to complete any job — the models handle their own lifecycle.

Sidekiq is fully installed and running (dedicated `workers` container, Redis connected,
queues: critical/default/low) but `app/workers/` does not exist. Nothing is being
ticked. Jobs created by `TaskExecutionEngine` or services sit at `in_progress` forever.

`game.rb#process_jobs` was an improvised substitute that only handles `ShellPrintingJob`
and uses the wrong pattern (inline blocking, settlement-scoped, bypasses `process_tick`).
It must be removed.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md` — full context
  on job system architecture decisions made this session
- `docs/agent/tasks/backlog/2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN.md`
  — AI Manager execution loop this worker supports

---

## Problem Statement

**Current behavior**: Jobs are created with `status: 'in_progress'` and never advance.
`game.rb#process_jobs` ticks only `ShellPrintingJob` via inline logic, bypassing
`process_tick`. All other job types never complete.

**Expected behavior**: A Sidekiq worker periodically queries all in-progress jobs
across all job types, calls `process_tick(hours_elapsed)` on each, and lets the
job model handle its own completion. Integration specs test job completion via the
worker, not via `game.rb`.

---

## The 9 Job Types

All have `process_tick(hours_elapsed)` — verified:

| Model | File | settlement association |
|---|---|---|
| `MaterialProcessingJob` | `app/models/material_processing_job.rb` | `belongs_to :settlement` |
| `ComponentProductionJob` | `app/models/component_production_job.rb` | `belongs_to :settlement` |
| `ShellPrintingJob` | `app/models/shell_printing_job.rb` | `belongs_to :settlement` |
| `SealPrintingJob` | `app/models/seal_printing_job.rb` | `belongs_to :settlement` |
| `ConstructionJob` | `app/models/construction_job.rb` | `belongs_to :settlement` |
| `SmeltingJob` | `app/models/smelting_job.rb` | no direct settlement — query by status only |
| `UnitAssemblyJob` | `app/models/unit_assembly_job.rb` | no direct settlement — query by status only |
| `EnvironmentJob` | `app/models/environment_job.rb` | no direct settlement — query by status only |
| `ResourceJob` | `app/models/resource_job.rb` | `belongs_to :settlement` |

**Important**: Do not query by settlement. Query all job types by `status: 'in_progress'`
only. Settlement scoping is wrong architecture — jobs belong to entities, not settlements.

---

## Files Involved

### Create these files
| File | Purpose |
|---|---|
| `app/workers/job_processor_worker.rb` | Sidekiq worker — ticks all in-progress jobs |
| `config/schedule.rb` OR sidekiq-scheduler config | Cron schedule for worker |

### Modify these files
| File | Change |
|---|---|
| `app/models/game.rb` | Remove `process_jobs` method, remove call from `advance_by_days` |
| `spec/rails_helper.rb` | Add Sidekiq inline mode for test environment |

### Mark pending — do not fix yet
| File | Lines | Reason |
|---|---|---|
| `spec/integration/manufacturing_pipeline_e2e_spec.rb` | 277, 544, 589 | Rewrite after worker exists |
| `spec/integration/component_production_game_loop_spec.rb` | 117, 148, 164 | Rewrite after worker exists |

### Reference — read but do not edit
| File | Why |
|---|---|
| `app/models/material_processing_job.rb` | Verify `process_tick` signature |
| `app/models/component_production_job.rb` | Verify `process_tick` signature |
| `app/models/shell_printing_job.rb` | Verify `process_tick` signature |
| `config/sidekiq.yml` | Existing queue configuration |

---

## Implementation Steps

### Step 1 — Create `app/workers/` directory and worker

```ruby
# app/workers/job_processor_worker.rb
class JobProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  JOB_CLASSES = [
    MaterialProcessingJob,
    ComponentProductionJob,
    ShellPrintingJob,
    SealPrintingJob,
    ConstructionJob,
    SmeltingJob,
    UnitAssemblyJob,
    EnvironmentJob,
    ResourceJob
  ].freeze

  def perform(hours_elapsed = 1.0)
    Rails.logger.info("JobProcessorWorker: ticking all in-progress jobs for #{hours_elapsed}h")

    JOB_CLASSES.each do |job_class|
      tick_jobs(job_class, hours_elapsed)
    end
  end

  private

  def tick_jobs(job_class, hours_elapsed)
    jobs = job_class.where(status: 'in_progress')
    Rails.logger.info("JobProcessorWorker: #{job_class.name} — #{jobs.count} in progress")

    jobs.each do |job|
      job.process_tick(hours_elapsed)
    rescue => e
      Rails.logger.error("JobProcessorWorker: failed to tick #{job_class.name}##{job.id} — #{e.message}")
    end
  end
end
```

### Step 2 — Configure Sidekiq inline mode for tests

Add to `spec/rails_helper.rb`:

```ruby
require 'sidekiq/testing'
Sidekiq::Testing.inline!
```

This makes workers execute synchronously in tests — no real queue needed.
Place after existing requires, before RSpec.configure block.

### Step 3 — Remove `process_jobs` from `game.rb`

In `app/models/game.rb`:
- Remove the `process_jobs(settlement, time_skipped)` method entirely
- Remove the `process_jobs(settlement, time_skipped)` call from `process_settlements`
- Do NOT remove `process_settlements`, `process_units`, or `process_planets`

```ruby
# BEFORE — process_settlements calls process_jobs
def process_settlements(time_skipped)
  Settlement::BaseSettlement.all.each do |settlement|
    settlement.base_units.each do |unit|
      unit.consume_resources(time_skipped) if unit.respond_to?(:consume_resources)
    end
    process_jobs(settlement, time_skipped)  # REMOVE THIS LINE
    puts "#{settlement.name} updated for #{time_skipped} days."
  end
end

# AFTER
def process_settlements(time_skipped)
  Settlement::BaseSettlement.all.each do |settlement|
    settlement.base_units.each do |unit|
      unit.consume_resources(time_skipped) if unit.respond_to?(:consume_resources)
    end
    puts "#{settlement.name} updated for #{time_skipped} days."
  end
end
```

Then remove the entire `process_jobs` method definition.

### Step 4 — Mark 6 integration specs pending

In `spec/integration/manufacturing_pipeline_e2e_spec.rb`, change `it` to `xit`
for lines 277, 544, 589 and add this comment above each:

```ruby
# PENDING: Requires JobProcessorWorker — Sidekiq inline must be configured
# and specs rewritten to call JobProcessorWorker.new.perform(hours) directly
# instead of relying on game.advance_by_days for job completion.
# See: docs/agent/tasks/backlog/2026-04-20-CRITICAL-ARCHITECTURE-JOB-PROCESSOR-WORKER.md
xit '...' do
```

Same for `spec/integration/component_production_game_loop_spec.rb` lines 117, 148, 164.

### Step 5 — Rewrite integration specs to use worker

After Steps 1-4 are verified green, rewrite the 6 pending specs.

Replace the pattern:
```ruby
game.advance_by_days(1)
expect(job.reload.status).to eq('completed')
```

With:
```ruby
JobProcessorWorker.new.perform(24)  # 24 hours elapsed
expect(job.reload.status).to eq('completed')
```

For specs that need game time to also advance, keep `game.advance_by_days` for
clock/planet/settlement processing but use the worker for job ticking:
```ruby
game.advance_by_days(1)               # advances clock, settlements, planets
JobProcessorWorker.new.perform(24)    # ticks jobs
expect(job.reload.status).to eq('completed')
```

### Step 6 — Scheduler configuration (Phase 1 — basic)

Check if `sidekiq-scheduler` or `sidekiq-cron` gem is already in Gemfile:
```bash
grep -n "sidekiq" Gemfile
```

If neither exists, add to Gemfile and configure. Minimum viable schedule:
every 5 real-time minutes in production, every game-hour equivalent in simulation.
Note: scheduler configuration detail is out of scope for this task if gem is missing —
flag in completion report and create follow-up task.

---

## Synthesis Report Format

Before applying any changes, produce:

```
CURRENT STATE
game.rb#process_jobs: [describe what it does]
Sidekiq inline configured: YES/NO
app/workers/ exists: YES/NO

PROPOSED CHANGES
1. [file] — [change]
2. [file] — [change]
...

RISK
[any shared code affected]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Worker unit test — verify it calls process_tick on each job type:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/workers/job_processor_worker_spec.rb'
```

2. Manufacturing service specs — confirm still green after game.rb change:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/'
```

3. Rewritten integration specs — confirm jobs now complete via worker:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/manufacturing_pipeline_e2e_spec.rb spec/integration/component_production_game_loop_spec.rb'
```

4. Full suite — confirm no regressions:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] `app/workers/job_processor_worker.rb` exists and includes `Sidekiq::Worker`
- [ ] Worker calls `process_tick` on all 9 job types
- [ ] Worker handles individual job failures gracefully (rescue per job, not per class)
- [ ] `game.rb#process_jobs` removed
- [ ] Sidekiq inline mode configured in `spec/rails_helper.rb`
- [ ] 6 integration specs rewritten and green via worker
- [ ] No regressions in manufacturing service specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate immediately if:
- Any job model is missing `process_tick` — do not add it, escalate
- Sidekiq inline mode causes unexpected failures outside manufacturing specs
- `game.rb` change causes failures in non-job specs
- Scheduler gem is missing and schedule config is needed — flag, don't add gem without approval

---

## Phase 2 — Do Not Implement Now
These are documented for future reference only:

- Add owner association to job models (player/NPC/corporation)
- Route jobs to critical/default/low queue by owner type
- AI Manager jobs → default queue
- Urgent player jobs → critical queue
- Background/maintenance jobs → low queue

---

## Commit Instructions
Run on host, not inside container:
```bash
git add app/workers/job_processor_worker.rb
git add app/models/game.rb
git add spec/rails_helper.rb
git add spec/integration/manufacturing_pipeline_e2e_spec.rb
git add spec/integration/component_production_game_loop_spec.rb
git commit -m "arch: JobProcessorWorker — Sidekiq job ticking infrastructure, remove game.rb#process_jobs"
git push
```

---

## Documentation
- [ ] Update `docs/agent/README.md` — add JobProcessorWorker to architecture overview
- [ ] Flag follow-up: sidekiq-scheduler configuration if gem missing

---

## Dependencies
**Blocked by**: none — can be built independently of TaskExecutionEngine cleanup
**Blocks**: 6 integration spec rewrites, AI Manager job dispatch via TaskExecutionEngine
**Related tasks**:
- `2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN.md`
- Session handoff `session_handoff_2026-04-20.md`

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
