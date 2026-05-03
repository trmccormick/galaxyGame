# TASK: Update factories and specs to use unified Job model — remove ConstructionJob
**Status**: ❌ CANCELLED  
**Priority**: HIGH  
**Type**: refactor  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-03  

> **CANCELLED 2026-05-03**: Architectural review confirmed `ConstructionJob` is a permanent separate model. ConstructionJob factories and specs must be kept, not removed. See cancellation note in ADD-CONSTRUCTION-JOB-TYPES task for full reasoning.

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Mechanical spec/factory updates — well-scoped, all file paths and substitutions provided explicitly  
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agents: read every section carefully. Do not infer — use only paths and patterns provided below.

---

## Context

This is step 5 of the Job model unification. Production code now uses the unified `Job` model (task 4). This task updates all `spec/` files and factories to stop referencing `ConstructionJob` and use `Job` instead.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md` — job system architecture decisions

---

## Problem Statement

The following `spec/` files reference `ConstructionJob` and need to be updated:

| File | References |
|---|---|
| `spec/models/construction_job_spec.rb` | Entire file — replace with Job-based tests |
| `spec/models/material_request_spec.rb` | Line 72: `requestable_type == "ConstructionJob"` |
| `spec/services/manufacturing/construction/hangar_service_spec.rb` | Lines 170, 233 |
| `spec/services/manufacturing/construction/dome_service_spec.rb` | Lines 174, 230, 285, 334, 346 |
| `spec/services/manufacturing/construction/covering_service_spec.rb` | Lines 106, 128 |
| `spec/services/manufacturing/shell_printing_service_spec.rb` | Lines 133, 135, 161 |
| `spec/services/crater_dome_construction_service_spec.rb` | Lines 136, 150 |
| `spec/factories/construction_job.rb` | Entire file — to be deleted |
| `spec/factories/material_request.rb` | Line 3: `factory: :construction_job` |

**Current behavior**: Specs reference deleted/obsolete `ConstructionJob` model  
**Expected behavior**: All specs use `Job` with appropriate `job_type`

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `spec/models/construction_job_spec.rb` | Replace ConstructionJob tests with Job-based equivalents | entire file |
| `spec/models/material_request_spec.rb` | Update requestable_type assertion | line 72 |
| `spec/services/manufacturing/construction/dome_service_spec.rb` | Update ConstructionJob.new calls | lines 174, 230, 285, 334, 346 |
| `spec/services/manufacturing/construction/covering_service_spec.rb` | Update ConstructionJob assertions | lines 106, 128 |
| `spec/services/manufacturing/shell_printing_service_spec.rb` | Update ConstructionJob queries | lines 133, 135, 161 |
| `spec/services/crater_dome_construction_service_spec.rb` | Update ConstructionJob.new | lines 136, 150 |
| `spec/factories/material_request.rb` | Update factory association | line 3 |

### Files to DELETE
- `spec/factories/construction_job.rb` — factory is no longer needed after unification

> ⚠️ Delete via git, not file system, so the deletion is tracked:
> ```bash
> git rm galaxy_game/spec/factories/construction_job.rb
> ```

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `spec/factories/jobs.rb` | Use `:job` factory with traits for construction types |
| `app/models/job.rb` | Confirm `job_type` enum values available |

### Migration
- [ ] No migration needed

---

## Implementation Steps

### Step 1 — Delete the construction_job factory

```bash
git rm galaxy_game/spec/factories/construction_job.rb
```

### Step 2 — Update `spec/factories/material_request.rb` line 3

```ruby
# BEFORE
association :requestable, factory: :construction_job

# AFTER
association :requestable, factory: :job
```

### Step 3 — Update `spec/models/material_request_spec.rb` line 72

```ruby
# BEFORE
expect(job_request.requestable_type).to eq("ConstructionJob")

# AFTER
expect(job_request.requestable_type).to eq("Job")
```

### Step 4 — Replace `spec/models/construction_job_spec.rb`

This file tests `ConstructionJob` directly. Replace the entire `RSpec.describe ConstructionJob` block with a `RSpec.describe Job` block testing the same construction-related behaviours using `job_type: :crater_dome_construction`. Keep the same example count where possible.

For each `ConstructionJob.new(...)` call, substitute `Job.new(job_type: :crater_dome_construction, output_type: 'Structure', completes_at: 1.hour.from_now, ...)`.

If a test was specific to `ConstructionJob`-only logic that no longer exists on `Job`, mark it with:
```ruby
xit 'original description' do
  # REMOVED: ConstructionJob-specific logic no longer exists on unified Job model
end
```

### Step 5 — Update service specs: replace `ConstructionJob.new` / `ConstructionJob.where`

For each remaining spec file, replace:
```ruby
# BEFORE
job = ConstructionJob.new(job_type: :shell_printing, ...)

# AFTER
job = Job.new(job_type: :shell_printing, output_type: 'Structure', completes_at: 1.hour.from_now, ...)
```

For count/query assertions:
```ruby
# BEFORE
}.to change { ConstructionJob.where(job_type: :shell_printing).count }.by(1)

# AFTER
}.to change { Job.where(job_type: :shell_printing).count }.by(1)
```

For type assertions:
```ruby
# BEFORE
expect(result[:construction_job]).to be_a(ConstructionJob)

# AFTER
expect(result[:construction_job]).to be_a(Job)
```

### Step 6 — Verify: no remaining `ConstructionJob` references in `spec/`

```bash
grep -rn "ConstructionJob\|construction_job" galaxy_game/spec/
```

Expected: 0 matches

### Step 7 — Run targeted specs

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/construction_job_spec.rb spec/models/material_request_spec.rb spec/workers/job_processor_worker_spec.rb'
```

Expected: 0 failures

---

## Acceptance Criteria
- [ ] `grep -rn "ConstructionJob" galaxy_game/spec/` returns 0 matches
- [ ] `spec/factories/construction_job.rb` no longer exists
- [ ] Worker spec: 5 examples, 0 failures
- [ ] `spec/models/material_request_spec.rb` passes
- [ ] No new failures introduced

---

## Stop Conditions — escalate to user immediately if:
- A spec cannot be rewritten because the service still returns a `ConstructionJob` object (task 4 may be incomplete)
- More than 5 new test failures appear after substitutions
- Any spec tests behaviour that only made sense on `ConstructionJob` and has no equivalent on `Job`

---

## Commit Instructions
Run from **host** terminal:
```bash
git rm galaxy_game/spec/factories/construction_job.rb
git add galaxy_game/spec/
git commit -m "refactor: remove ConstructionJob from all spec factories and spec files — unified Job model"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: `2026-05-01-HIGH-REFACTOR-JOB-MODEL-REPLACE-CONSTRUCTION-JOB-REFERENCES.md`  
**Blocks**: `2026-05-01-LOW-CLEANUP-DROP-CONSTRUCTION-JOBS-TABLE-AND-MODEL.md`  
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
