# TASK: Replace ConstructionJob references in models, concerns, and services with unified Job
**Status**: ❌ CANCELLED  
**Priority**: HIGH  
**Type**: refactor  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-03  

> **CANCELLED 2026-05-03**: Architectural review confirmed `ConstructionJob` is a permanent separate model. Replacing ConstructionJob references with `Job` is architecturally wrong — construction work (crater domes, shell printing, skylight covers, worldhouse sealing) belongs on `ConstructionJob`. Only manufacturing/processing work belongs on `Job`. See cancellation note in ADD-CONSTRUCTION-JOB-TYPES task for full reasoning.

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x  
**Why This Agent**: Multi-file refactor across services, models, and concerns — requires understanding of context at each call site to substitute correctly  
**Supervision Level**: 🟢 Autonomous OK

---

## Context

This is step 4 of the Job model unification. After enum extensions (task 2) and column migration (task 3), all production code that creates or queries `ConstructionJob` can be switched to use the unified `Job` model. This task covers `app/` only — factories and specs are a separate task (task 5).

**Relevant Architecture Docs** — read before starting:
- `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md` — job system architecture decisions

---

## Problem Statement

The following `app/` files reference `ConstructionJob` directly and must be updated to use `Job` instead:

**Services:**
- `app/services/crater_dome_construction_service.rb` — line 20: `ConstructionJob.create!`
- `app/services/game_service.rb` — line 99: `ConstructionJob.where(job_type: :shell_printing, ...)`
- `app/services/autonomous_mission_service.rb` — line 428: `ConstructionJob.create!`
- `app/services/material_request_service.rb` — line 39: `ConstructionJobManager.start_construction`
- `app/services/construction/dome_service.rb` — line 19: `ConstructionJob.create!`
- `app/services/manufacturing/shell_printing_service.rb` — line 163: `ConstructionJob.create!`
- `app/services/manufacturing/material_request.rb` — line 39: `ConstructionJobManager.start_construction`
- `app/services/manufacturing/construction/access_point_installation_service.rb` — line 20: `ConstructionJob.create!`
- `app/services/manufacturing/construction/covering_service.rb` — line 32: `ConstructionJob.create!`
- `app/services/construction_job_service.rb` — entire file uses `ConstructionJob`
- `app/services/ai_manager/task_execution_engine.rb` — lines 326, 332, 617, 622, 643, 648: `ConstructionJobService`
- `app/services/ai_manager/construction.rb` — line 43: reference comment

**Model concerns:**
- `app/models/concerns/structures/shell.rb` — line 143: `ConstructionJob.create!`
- `app/models/concerns/structures/coverable.rb` — line 86: `ConstructionJob.create!`

**Current behavior**: Code creates/queries `ConstructionJob` records in the `construction_jobs` table  
**Expected behavior**: Code creates/queries `Job` records in the `jobs` table with appropriate `job_type`

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/construction_job_service.rb` | Service layer for construction jobs | entire file |
| `app/services/crater_dome_construction_service.rb` | Creates crater dome jobs | line 20 |
| `app/services/game_service.rb` | Ticks shell printing jobs | line 99 |
| `app/services/autonomous_mission_service.rb` | AI creates construction jobs | line 428 |
| `app/services/construction/dome_service.rb` | Creates dome jobs | line 19 |
| `app/services/manufacturing/shell_printing_service.rb` | Creates shell printing jobs | line 163 |
| `app/services/manufacturing/construction/covering_service.rb` | Creates covering jobs | line 32 |
| `app/services/manufacturing/construction/access_point_installation_service.rb` | Creates access point jobs | line 20 |
| `app/models/concerns/structures/shell.rb` | Creates construction job from shell concern | line 143 |
| `app/models/concerns/structures/coverable.rb` | Creates construction job from coverable concern | line 86 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/construction_job.rb` | Source of truth for what fields each `ConstructionJob.create!` call needs |
| `app/models/job.rb` | Confirm all needed fields exist after tasks 2 and 3 |
| `app/services/ai_manager/task_execution_engine.rb` | References `ConstructionJobService` — update calls |

### Migration
- [ ] No migration needed (handled in task 3)

---

## Implementation Steps

### Step 1 — Read all call sites before touching anything

For each file listed, read the `ConstructionJob.create!` call and note:
- Which `job_type` value it sets
- Which fields it sets
- What the return value is used for

This ensures each substitution is semantically correct.

### Step 2 — Replace `ConstructionJob.create!` with `Job.create!`

Pattern for each substitution:
```ruby
# BEFORE
construction_job = ConstructionJob.create!(
  job_type: :crater_dome_construction,
  status: :scheduled,
  settlement: settlement,
  jobable: some_structure,
  target_values: { ... }
)

# AFTER
construction_job = Job.create!(
  job_type: :crater_dome_construction,
  status: :scheduled,
  settlement: settlement,
  jobable: some_structure,
  target_values: { ... },
  owner: owner,           # required by Job — set to settlement or nil initially if not available
  output_type: "Structure" # required by Job — use "Structure" for all construction types
)
```

> ⚠️ `Job` has `validates :output_type, presence: true` — every `Job.create!` call must include `output_type`. Use `"Structure"` for all construction job types.
> ⚠️ `Job` has `validates :completes_at, presence: true` — every `Job.create!` call must include `completes_at`. Use `estimated_completion` value if available, or `Time.current + N.hours` as a reasonable default.

### Step 3 — Replace `ConstructionJob.where(...)` with `Job.where(...)`

```ruby
# BEFORE (game_service.rb)
ConstructionJob.where(job_type: :shell_printing, status: :in_progress).each do |job|

# AFTER
Job.where(job_type: :shell_printing, status: :in_progress).each do |job|
```

### Step 4 — Update `construction_job_service.rb`

This service is the main entry point. Replace all `ConstructionJob` with `Job` throughout. Keep the class name `ConstructionJobService` for now — renaming is a separate cleanup task to avoid cascading changes.

### Step 5 — Update `ai_manager/task_execution_engine.rb`

Lines 326, 332, 617, 622, 643, 648 call `ConstructionJobService`. These do not need to change if `ConstructionJobService` is updated in Step 4. Verify no direct `ConstructionJob` references remain in this file.

### Step 6 — Verify: no remaining `ConstructionJob` references in `app/`

```bash
grep -rn "ConstructionJob" galaxy_game/app/
```

Expected: 0 matches (or only the model file itself if not yet deleted)

### Step 7 — Run isolated specs for changed services

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/crater_dome_construction_service_spec.rb spec/services/manufacturing/shell_printing_service_spec.rb spec/services/manufacturing/construction/covering_service_spec.rb'
```

Note failures — do not fix spec files in this task (that is task 5). Report any new errors caused by the production code changes.

---

## Acceptance Criteria
- [ ] `grep -rn "ConstructionJob" galaxy_game/app/` returns 0 matches (excluding `app/models/construction_job.rb`)
- [ ] All changed services still load without `NameError`
- [ ] Worker spec: 5 examples, 0 failures
- [ ] No new `ArgumentError` or `ActiveRecord::RecordInvalid` errors in changed services from missing required fields

---

## Stop Conditions — escalate to user immediately if:
- Any `Job.create!` call raises `RecordInvalid` because of missing `owner`, `output_type`, or `completes_at` and the call site has no natural value to supply
- `ConstructionJobService` is referenced from more than 10 files (cascading rename risk — report first)
- Changes are needed in more than 15 files total

---

## Commit Instructions
Run from **host** terminal:
```bash
git add galaxy_game/app/services/
git add galaxy_game/app/models/concerns/
git commit -m "refactor: replace ConstructionJob with unified Job model in services and concerns"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: `2026-05-01-HIGH-REFACTOR-JOB-MODEL-MIGRATE-CONSTRUCTION-JOB-COLUMNS.md`  
**Blocks**: `2026-05-01-HIGH-REFACTOR-JOB-MODEL-UPDATE-FACTORIES-AND-SPECS.md`  
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
