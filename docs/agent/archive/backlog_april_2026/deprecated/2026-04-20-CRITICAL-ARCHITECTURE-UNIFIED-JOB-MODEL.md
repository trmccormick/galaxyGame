# TASK: Unified Job Model — Consolidate Small Manufacturing Jobs
**Status**: BACKLOG
**Priority**: CRITICAL
**Type**: architecture
**Created**: 2026-04-20
**Last Updated**: 2026-04-20

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Schema design, migration, model consolidation, requires judgment
on job type classification and legacy model retirement strategy.
**Supervision Level**: 🟢 Autonomous OK — but produce Synthesis Report before
touching any migration or destroying any model file.

---

## North Star

One unified `Job` model handles all small manufacturing jobs. `ConstructionJob`
handles all surface construction including shell and seal printing.
`OrbitalConstructionProject` handles orbital/large craft construction.
`JobProcessorWorker` is rebuilt against these three clean models.
Legacy separate job models are retired in an orderly migration.

---

## Context

During the 2026-04-20 session, architectural review revealed that the current
9 separate job model design is over-decomposed. All small manufacturing jobs
share identical runtime behavior: materials consumed at submission, timer runs,
player or NPC claims outputs at completion. There is no meaningful difference
between `MaterialProcessingJob`, `ComponentProductionJob`, `SmeltingJob`,
`UnitAssemblyJob`, `ResourceJob`, and `EnvironmentJob` at the model level —
they are all blueprint execution instances with a completion timestamp.

`ShellPrintingJob` and `SealPrintingJob` were found to be construction-category
jobs — `coverable.rb` and `shell.rb` both create `ConstructionJob` records
directly, suggesting these models are legacy or parallel implementations.

`OrbitalConstructionProject` already correctly models large structure
construction with material delivery gating and progress percentage tracking.

**Read before starting:**
- `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md`
- `docs/agent/tasks/backlog/2026-04-20-CRITICAL-ARCHITECTURE-JOB-PROCESSOR-WORKER.md`
  — current worker task, superseded by this task
- `app/models/concerns/structures/coverable.rb` — creates ConstructionJob directly
- `app/models/concerns/structures/shell.rb` — creates ConstructionJob directly

---

## Problem Statement

**Current behavior**: 9 separate job models, 3 missing database tables
(`smelting_jobs`, `environment_jobs`, `resource_jobs`), one duplicate file
(`smelting_jobs.rb` with broken class name), and `JobProcessorWorker` built
against all 9 models including the missing ones. Worker fails in test
environment with `PG::UndefinedTable` errors.

**Expected behavior**: Three job model categories, each with a clear table,
clear lifecycle, and clear worker responsibility. Small jobs unified. Worker
rebuilt against clean models. Legacy models retired with a migration path.

---

## Architecture Decisions — Locked For This Task

### Category 1 — Small Manufacturing Jobs → unified `Job` model
These all share identical runtime behavior. Unify into one model:
- `MaterialProcessingJob` → `Job` with `job_type: :material_processing`
- `ComponentProductionJob` → `Job` with `job_type: :component_production`
- `SmeltingJob` → `Job` with `job_type: :smelting`
- `UnitAssemblyJob` → `Job` with `job_type: :unit_assembly`
- `ResourceJob` → `Job` with `job_type: :resource_processing`
- `EnvironmentJob` → `Job` with `job_type: :environment_processing`

### Category 2 — Surface Construction → extend `ConstructionJob`
Add two new enum values:
- `shell_printing: 5`
- `seal_printing: 6`

Retire `ShellPrintingJob` and `SealPrintingJob` as standalone models after
verifying `coverable.rb` and `shell.rb` already use `ConstructionJob` directly.

### Category 3 — Orbital/Large Construction → `OrbitalConstructionProject`
Already correctly modeled. No changes to this model in this task.

### Job Lifecycle — Small Jobs
- Materials consumed at submission (caller responsibility — job assumes materials gone)
- `status`: `in_progress` → `ready_to_claim` → `claimed`
- `completes_at` set at submission, never changes
- Worker flips `in_progress` to `ready_to_claim` when `completes_at <= Time.current`
- Player or NPC claims manually — outputs delivered to inventory at claim time
- NPC auto-claims via AI Manager, player claims via UI action

### Job Ownership
- Polymorphic `owner` — player, NPC, corporation
- Player must own blueprint to submit
- NPC has implicit blueprint access
- Settlement scoped for facility context but jobs belong to owner not settlement

---

## Unified `Job` Model Schema

```ruby
# db/migrate/TIMESTAMP_create_jobs.rb
create_table :jobs do |t|
  t.references :owner, polymorphic: true, null: false
  t.references :settlement, null: false,
               foreign_key: { to_table: :settlements }
  t.references :blueprint, null: true,
               foreign_key: { to_table: :blueprints }
  t.integer :job_type, null: false
  t.integer :status, default: 0, null: false
  t.string :output_type, null: false
  t.integer :output_quantity, null: false, default: 1
  t.datetime :completes_at, null: false
  t.datetime :claimed_at
  t.timestamps
end

add_index :jobs, [:status, :completes_at]
add_index :jobs, [:owner_type, :owner_id]
add_index :jobs, :settlement_id
```

```ruby
# app/models/job.rb
class Job < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  belongs_to :blueprint, optional: true

  enum status: {
    in_progress: 0,
    ready_to_claim: 1,
    claimed: 2,
    failed: 3
  }

  enum job_type: {
    material_processing: 0,
    component_production: 1,
    smelting: 2,
    unit_assembly: 3,
    resource_processing: 4,
    environment_processing: 5
  }

  validates :output_type, presence: true
  validates :output_quantity, numericality: { greater_than: 0 }
  validates :completes_at, presence: true

  scope :ready_to_process, -> {
    in_progress.where('completes_at <= ?', Time.current)
  }

  def complete!
    update!(status: :ready_to_claim)
  end

  def claim!(claimant)
    return false unless ready_to_claim?
    # Output delivery to claimant inventory handled by caller
    update!(status: :claimed, claimed_at: Time.current)
  end
end
```

---

## Rebuilt `JobProcessorWorker`

Replace the current worker content entirely:

```ruby
# app/workers/job_processor_worker.rb
class JobProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform
    Rails.logger.info("JobProcessorWorker: processing at #{Time.current}")
    complete_small_jobs
    advance_construction_jobs
  end

  private

  def complete_small_jobs
    jobs = Job.ready_to_process
    Rails.logger.info("JobProcessorWorker: #{jobs.count} small jobs ready to complete")
    jobs.each do |job|
      job.complete!
    rescue => e
      Rails.logger.error("JobProcessorWorker: failed to complete Job##{job.id} — #{e.message}")
    end
  end

  def advance_construction_jobs
    jobs = ConstructionJob.where(status: :in_progress)
    Rails.logger.info("JobProcessorWorker: #{jobs.count} construction jobs in progress")
    jobs.each do |job|
      job.advance!
    rescue => e
      Rails.logger.error("JobProcessorWorker: failed to advance ConstructionJob##{job.id} — #{e.message}")
    end
  end
end
```

**Note**: `OrbitalConstructionProject` advance is out of scope for Phase 1 of
this task. Add in Phase 2 once orbital construction worker behavior is defined.

---

## Files Involved

### Create
| File | Purpose |
|---|---|
| `db/migrate/TIMESTAMP_create_jobs.rb` | New unified jobs table |
| `app/models/job.rb` | Unified Job model |
| `spec/models/job_spec.rb` | Model spec |
| `spec/factories/jobs.rb` | Factory |

### Modify
| File | Change |
|---|---|
| `app/workers/job_processor_worker.rb` | Rebuild against Job + ConstructionJob |
| `app/models/construction_job.rb` | Add shell_printing and seal_printing enum values |
| `spec/workers/job_processor_worker_spec.rb` | Rewrite against new worker |

### Verify then retire (do not delete until verified)
| File | Condition for retirement |
|---|---|
| `app/models/shell_printing_job.rb` | Verify coverable.rb + shell.rb use ConstructionJob only |
| `app/models/seal_printing_job.rb` | Same verification |
| `app/models/material_processing_job.rb` | No references outside legacy specs |
| `app/models/component_production_job.rb` | No references outside legacy specs |
| `app/models/unit_assembly_job.rb` | No references outside legacy specs |
| `app/models/resource_job.rb` | No references outside legacy specs |
| `app/models/environment_job.rb` | No references outside legacy specs |

### Delete immediately — confirmed duplicate/broken
| File | Reason |
|---|---|
| `app/models/smelting_jobs.rb` | Broken class name `smelting_jobs`, duplicate of `smelting_job.rb` |
| `app/models/smelting_job.rb` | Superseded by unified Job model — delete after Job model exists |

### Reference — read but do not edit
| File | Why |
|---|---|
| `app/models/concerns/structures/coverable.rb` | Verify ConstructionJob usage |
| `app/models/concerns/structures/shell.rb` | Verify ConstructionJob usage |
| `app/models/orbital_construction_project.rb` | Reference only — no changes |
| `config/sidekiq.yml` | Queue configuration reference |

---

## Implementation Steps

### Step 1 — Delete broken duplicate
```bash
rm app/models/smelting_jobs.rb
```
Verify:
```bash
ls app/models/ | grep smelting
# Should show only smelting_job.rb
```

### Step 2 — Verify shell/seal concerns use ConstructionJob
```bash
grep -n "ShellPrintingJob\|SealPrintingJob" \
  app/models/concerns/structures/coverable.rb \
  app/models/concerns/structures/shell.rb
```
Expected: no matches. If matches found — stop and escalate.

### Step 3 — Add shell_printing and seal_printing to ConstructionJob enum
In `app/models/construction_job.rb`, extend the job_type enum:
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

### Step 4 — Generate and run migration
```bash
docker exec -it web bash -c 'bundle exec rails generate migration CreateJobs'
```
Fill in migration with schema above. Then:
```bash
docker exec -it web bash -c 'RAILS_ENV=test bundle exec rails db:migrate'
```

### Step 5 — Create Job model
Use schema above exactly.

### Step 6 — Create factory
```ruby
# spec/factories/jobs.rb
FactoryBot.define do
  factory :job do
    association :owner, factory: :player
    association :settlement, factory: :settlement
    job_type { :material_processing }
    status { :in_progress }
    output_type { 'iron_plate' }
    output_quantity { 10 }
    completes_at { 1.hour.from_now }

    trait :ready_to_claim do
      status { :ready_to_claim }
      completes_at { 1.hour.ago }
    end

    trait :claimed do
      status { :claimed }
      completes_at { 2.hours.ago }
      claimed_at { 1.hour.ago }
    end

    trait :overdue do
      status { :in_progress }
      completes_at { 1.minute.ago }
    end
  end
end
```

### Step 7 — Rebuild worker
Replace `app/workers/job_processor_worker.rb` with rebuilt version above.

### Step 8 — Rewrite worker spec
```ruby
# spec/workers/job_processor_worker_spec.rb
require 'rails_helper'

RSpec.describe JobProcessorWorker, type: :worker do
  describe '#perform' do
    context 'small job completion' do
      it 'completes overdue in-progress jobs' do
        job = create(:job, :overdue)
        described_class.new.perform
        expect(job.reload.status).to eq('ready_to_claim')
      end

      it 'does not complete jobs not yet due' do
        job = create(:job, status: :in_progress,
                     completes_at: 1.hour.from_now)
        described_class.new.perform
        expect(job.reload.status).to eq('in_progress')
      end

      it 'does not raise if a job fails' do
        job = create(:job, :overdue)
        allow(job).to receive(:complete!).and_raise(StandardError, 'boom')
        allow(Job).to receive(:ready_to_process).and_return([job])
        expect { described_class.new.perform }.not_to raise_error
      end
    end

    context 'construction job advancement' do
      it 'calls advance! on in-progress construction jobs' do
        job = create(:construction_job, status: :in_progress)
        expect(job).to receive(:advance!)
        allow(ConstructionJob).to receive(:where)
          .with(status: :in_progress).and_return([job])
        described_class.new.perform
      end
    end
  end
end
```

### Step 9 — Verify legacy model references before retiring
```bash
grep -rn "MaterialProcessingJob\|ComponentProductionJob\|SmeltingJob\|UnitAssemblyJob\|ResourceJob\|EnvironmentJob" app/ | grep -v "_spec\|\.md"
```
Any reference outside spec files must be updated to use `Job` before retiring
legacy models. Do not delete legacy model files until all references are gone.

---

## Synthesis Report Format
CURRENT STATE
Jobs table exists: YES/NO
Broken smelting_jobs.rb deleted: YES/NO
ShellPrintingJob/SealPrintingJob used in concerns: YES/NO (grep output)
Legacy model references in app/: [list]
PROPOSED CHANGES

[file] — [change]
...

MIGRATION RISK
[any data migration needed for existing records]
READY TO APPLY? — waiting for approval

---

## Testing Sequence

1. Model spec:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/job_spec.rb'
```

2. Worker spec:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/workers/job_processor_worker_spec.rb'
```

3. Construction job specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/construction_job_spec.rb'
```

4. Full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] `smelting_jobs.rb` deleted
- [ ] `jobs` table created and migrated in test environment
- [ ] `Job` model exists with correct enum values and scopes
- [ ] `spec/factories/jobs.rb` exists with in_progress, ready_to_claim, overdue traits
- [ ] `ConstructionJob` enum includes shell_printing and seal_printing
- [ ] `JobProcessorWorker` rebuilt — queries Job and ConstructionJob only
- [ ] Worker spec green — 0 failures
- [ ] No legacy job model references remain in app/ code
- [ ] Full suite run completed and logged — no regressions

---

## Stop Conditions — escalate immediately if:
- `ShellPrintingJob` or `SealPrintingJob` are referenced in concerns directly
  (not via ConstructionJob) — do not proceed with retirement
- Any legacy job model has records in production DB — data migration required
  before model retirement, escalate for migration plan
- `ConstructionJob#advance!` does not exist — stop, flag, do not stub it
- Migration fails — do not retry, report exact error

---

## Phase 2 — Do Not Implement Now
- `OrbitalConstructionProject` advancement in worker
- NPC auto-claim logic in AI Manager
- Player claim UI action
- Job queue priority routing by owner type
- Material delivery gating for large construction jobs

---

## Dependencies
**Supersedes**: `2026-04-20-CRITICAL-ARCHITECTURE-JOB-PROCESSOR-WORKER.md`
  — that task built a worker against the wrong model structure. Park it.
**Blocked by**: none
**Blocks**: TaskExecutionEngine cleanup, AI Manager job dispatch,
  6 deferred integration spec rewrites
**Related**:
- `2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN.md`
- `session_handoff_2026-04-20.md`

---

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned