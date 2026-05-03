# TASK: Rewrite JobProcessorWorker Spec Against Unified Job Model
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-23
**Last Updated**: 2026-04-23

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single spec file rewrite. Pattern fully specified below.
**Supervision Level**: 🔴 Watched carefully

---

## Context

The `job_processor_worker_spec.rb` was never updated after Task 1 rebuilt the
worker. It still tests the old pattern:
- `perform(hours_elapsed)` — worker takes no arguments now
- `process_tick` on `ShellPrintingJob` — model deleted
- `process_tick` on `ComponentProductionJob` — model deleted

The new worker pattern:
- `perform` takes NO arguments
- Queries `Job.ready_to_process` (in_progress where completes_at <= now)
- Calls `complete!` on each — flips to `ready_to_claim`
- Queries `ConstructionJob.in_progress` — calls `advance!` on each

**Read before starting:**
- `docs/architecture/systems/job_system_mechanics_spec.md` — worker section
- `galaxy_game/app/workers/job_processor_worker.rb` — read actual implementation first

---

## Files Involved

### Primary — rewrite entirely
`galaxy_game/spec/workers/job_processor_worker_spec.rb`

### Reference — read but do not edit
`galaxy_game/app/workers/job_processor_worker.rb`
`galaxy_game/spec/factories/jobs.rb`

---

## Implementation Steps

### Step 1 — Read the actual worker implementation
```bash
cat galaxy_game/app/workers/job_processor_worker.rb
```
The spec must match what the worker actually does — not what the task file said
it should do. Read the real implementation first.

### Step 2 — Read the current spec
```bash
cat galaxy_game/spec/workers/job_processor_worker_spec.rb
```

### Step 3 — Rewrite the spec

The new spec should test:

```ruby
RSpec.describe JobProcessorWorker, type: :worker do
  describe '#perform' do
    context 'with overdue jobs' do
      it 'completes jobs where completes_at is in the past' do
        job = create(:job, :overdue)
        described_class.new.perform
        expect(job.reload.status).to eq('ready_to_claim')
      end

      it 'does not complete jobs where completes_at is in the future' do
        job = create(:job, status: :in_progress,
                     completes_at: 1.hour.from_now)
        described_class.new.perform
        expect(job.reload.status).to eq('in_progress')
      end
    end

    context 'with construction jobs' do
      it 'calls advance! on in_progress construction jobs' do
        job = create(:construction_job, status: :in_progress)
        expect_any_instance_of(ConstructionJob).to receive(:advance!)
        described_class.new.perform
      end
    end

    context 'error handling' do
      it 'does not raise if a job raises during complete!' do
        job = create(:job, :overdue)
        allow_any_instance_of(Job).to receive(:complete!).and_raise(StandardError)
        expect { described_class.new.perform }.not_to raise_error
      end

      it 'continues processing after one job fails' do
        failing_job = create(:job, :overdue)
        passing_job = create(:job, :overdue)
        call_count = 0
        allow_any_instance_of(Job).to receive(:complete!) do
          call_count += 1
          raise StandardError if call_count == 1
        end
        described_class.new.perform
        expect(call_count).to eq(2)
      end
    end

    context 'with no jobs due' do
      it 'does not raise' do
        expect { described_class.new.perform }.not_to raise_error
      end
    end
  end
end
```

⚠️ Adjust the above based on what you actually see in the worker implementation.
If the worker handles errors differently — match the spec to reality.
If `advance!` is not called on construction jobs in the current implementation
— do not add that test, flag it in the completion report instead.

### Step 4 — Confirm :overdue factory trait exists
```bash
grep -n "overdue" galaxy_game/spec/factories/jobs.rb
```
If the `:overdue` trait doesn't exist — add it to the jobs factory:
```ruby
trait :overdue do
  status { :in_progress }
  completes_at { 1.hour.ago }
end
```

---

## Synthesis Report Format
```
WORKER IMPLEMENTATION SUMMARY:
  perform takes arguments: YES/NO
  queries Job model: YES/NO — scope used: [scope name]
  calls complete!: YES/NO
  handles ConstructionJob: YES/NO — method called: [method]
  error handling: [describe]

CURRENT SPEC SUMMARY:
  Tests process_tick: YES/NO
  Tests hours_elapsed argument: YES/NO

:overdue factory trait exists: YES/NO

PROPOSED SPEC STRUCTURE:
  [list test cases]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/workers/job_processor_worker_spec.rb 2>&1 | tail -10'
```
Expected: 0 failures.

---

## Acceptance Criteria
- [ ] Worker spec tests actual worker behavior — no `process_tick`, no `hours_elapsed`
- [ ] All worker spec examples pass
- [ ] `:overdue` factory trait exists on Job factory
- [ ] No regressions

---

## Stop Conditions
- Worker implementation differs significantly from mechanics spec — stop, report
- `:overdue` trait requires columns that don't exist on Job — stop, report

---

## Commit Instructions
```bash
git add galaxy_game/spec/workers/job_processor_worker_spec.rb \
        galaxy_game/spec/factories/jobs.rb
git commit -m "fix: job_processor_worker_spec — rewrite against unified Job model, remove legacy process_tick tests"
```

---

## Dependencies
**Blocked by**: Nothing
**Parallel safe**: Yes
