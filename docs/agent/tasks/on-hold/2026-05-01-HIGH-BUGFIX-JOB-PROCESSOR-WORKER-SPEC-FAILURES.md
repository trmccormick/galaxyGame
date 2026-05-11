# TASK: Fix JobProcessorWorker spec — 2 failing examples
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Two isolated spec fixes, fully self-contained, no architectural decisions required  
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agents: read every section carefully. Do not infer file paths or method names — they are provided explicitly below.

---

## Context

`JobProcessorWorker` is a Sidekiq worker that queries all in-progress `Job` and `ConstructionJob` records and advances those whose `completes_at` is in the past to `ready_to_claim`. The spec was written assuming both models share the same interface and error handling behaviour. Two failures exist — both are spec-level issues, not worker bugs.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md` — job system architecture decisions

---

## Problem Statement

**Failure 1 — Line 21:**  
`create(:construction_job, completes_at: 1.hour.ago)` blows up because the `construction_jobs` table has no `completes_at` column.  
`ConstructionJob` is a separate model/table from `Job` and does not share the `completes_at` attribute.

**Failure 2 — Line 33:**  
`allow_any_instance_of(Job).to receive(:update!).and_raise(StandardError, 'boom')` stubs `update!` on **every** `Job` instance — including `passing_job`. Both jobs raise, the test expectation that `passing_job` reaches `ready_to_claim` is never met.

**Error output:**
```
1) JobProcessorWorker#perform construction jobs processes ConstructionJob the same as Job
   Failure/Error: job = create(:construction_job, status: :in_progress, completes_at: 1.hour.ago)
   NoMethodError: unknown attribute 'completes_at' for ConstructionJob

2) JobProcessorWorker#perform error handling continues after job failure
   Failure/Error: expect(passing_job.reload.status).to eq('ready_to_claim')
   expected: "ready_to_claim"
        got: "in_progress"
```

**Current behavior**: Both examples fail  
**Expected behavior**: Both examples pass

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `spec/workers/job_processor_worker_spec.rb` | Worker spec with 2 failing examples | line 21, line 33 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/workers/job_processor_worker.rb` | Worker implementation — understand what is being tested |
| `spec/factories/jobs.rb` | `:job` factory definition |
| `spec/factories/construction_job.rb` | `:construction_job` factory — confirm it has no `completes_at` trait |

### Migration
- [ ] No migration needed

---

## Implementation Steps

### Step 1 — Fix line 21: replace `:construction_job` factory with `:job`

The `construction jobs` context is testing that the worker processes jobs created for construction scenarios. Since `ConstructionJob` has no `completes_at`, and we are moving toward a unified `Job` model, replace the factory. Use an existing `Job` with a construction-relevant `job_type` is not yet available — use `material_processing` as a placeholder `job_type`. The test still validates the worker's core behaviour (transitions to `ready_to_claim`).

```ruby
# BEFORE (line 19–24)
context 'construction jobs' do
  it 'processes ConstructionJob the same as Job' do
    job = create(:construction_job, status: :in_progress, completes_at: 1.hour.ago)
    described_class.new.perform
    expect(job.reload.status).to eq('ready_to_claim')
  end
end

# AFTER
context 'construction jobs' do
  it 'processes construction-type jobs via unified Job model' do
    job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
    described_class.new.perform
    expect(job.reload.status).to eq('ready_to_claim')
  end
end
```

> NOTE: Add a comment above the example:
> `# TODO: Update job_type to :crater_dome_construction once construction types are added to Job enum`
> `# See: docs/agent/tasks/backlog/2026-05-01-HIGH-REFACTOR-JOB-MODEL-ADD-CONSTRUCTION-JOB-TYPES.md`

### Step 2 — Fix line 33: scope the stub to the failing instance

`allow_any_instance_of` is too broad — it catches both jobs. Use instance-level stubbing instead.

```ruby
# BEFORE (line 31–37)
context 'error handling' do
  it 'continues after job failure' do
    failing_job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
    passing_job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
    allow_any_instance_of(Job).to receive(:update!).and_raise(StandardError, 'boom')
    described_class.new.perform
    expect(passing_job.reload.status).to eq('ready_to_claim')
  end
end

# AFTER
context 'error handling' do
  it 'continues after job failure' do
    failing_job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
    passing_job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
    allow(failing_job).to receive(:update!).and_raise(StandardError, 'boom')
    described_class.new.perform
    expect(passing_job.reload.status).to eq('ready_to_claim')
  end
end
```

> ⚠️ WARNING: The worker loads jobs via `Job.where(...)` which returns new AR objects from DB.
> The stub on `failing_job` (local variable) will NOT automatically apply to the object
> loaded inside the worker. Verify after running the spec whether this fix is sufficient.
>
> If the test still fails, the worker needs to be stubbed at a higher level, OR the spec
> needs to restructure. Report back with the exact failure — do not attempt a third fix.

### Step 3 — Run the spec in isolation

Run this exact command from the host terminal:

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/workers/job_processor_worker_spec.rb'
```

Expected result: `5 examples, 0 failures`

---

## Acceptance Criteria
- [ ] Line 21 failure resolved — no `NoMethodError` on `completes_at`
- [ ] Line 33 failure resolved — `passing_job` reaches `ready_to_claim`
- [ ] Isolation run: 5 examples, 0 failures
- [ ] No changes to `app/workers/job_processor_worker.rb`
- [ ] No changes to any factory file

---

## Stop Conditions — escalate to user immediately if:
- Step 2 stub fix still fails because worker loads fresh AR objects (report exact error)
- Any other spec in the file regresses
- You feel tempted to change the worker implementation — stop, report instead

---

## Commit Instructions
Run from **host** terminal:
```bash
git add galaxy_game/spec/workers/job_processor_worker_spec.rb
git commit -m "fix: job_processor_worker_spec — use :job factory for construction context, scope update! stub to instance"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: none  
**Blocks**: none  
**Related tasks**: `2026-05-01-HIGH-REFACTOR-JOB-MODEL-ADD-CONSTRUCTION-JOB-TYPES.md` (follow-on)

---

## Progress (as of 2026-05-08)

### Current Status
- This bugfix is **on hold**; not actively fixing at this time.
- The spec failures are well-understood and isolated to test code, not worker logic.
- No changes have been made to the worker or factories; the spec file remains as described above.
- No new regressions or related failures have been reported.

### Findings
- Failure 1: `completes_at` is not present on `ConstructionJob` — spec must use `:job` factory for construction context.
- Failure 2: `allow_any_instance_of(Job)` is too broad; must scope stub to failing instance, but AR reload may require further adjustment if the stub does not apply.
- The spec file contains clear instructions for the next implementer, including stop conditions and escalation points.

### Next Steps
- Leave task in BACKLOG until/unless spec failures block other work or requirements change.
- If reactivated: follow Implementation Steps above, focusing on correct factory usage and stub scoping.

---
