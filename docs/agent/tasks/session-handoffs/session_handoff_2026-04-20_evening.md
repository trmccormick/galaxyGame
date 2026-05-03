# Session Handoff — 2026-04-20 (Evening Session)

## Session Metrics
Start: ~16 failures → End: ~10 failures
Commits: 2
- chore: mark 6 job-system integration specs pending — awaiting JobProcessorWorker
- arch: JobProcessorWorker — Sidekiq job ticking infrastructure, remove game.rb#process_jobs
Time: ~4 hours | Agents: GPT-4.1 (mechanical), Claude (strategy/architecture)
Branch: regional-view-phase2

---

## Current Baseline
3925 examples, ~10 failures, 50 pending (44 + 6 newly marked)
Previous baseline: ~16 failures
Change this session: -6 (marked pending, not fixed)

---

## What Was Done This Session

### 1. Marked 6 Integration Specs Pending
`spec/integration/manufacturing_pipeline_e2e_spec.rb` lines 277, 544, 589
`spec/integration/component_production_game_loop_spec.rb` lines 117, 148, 164
All marked `xit` with comment referencing JobProcessorWorker task.
These are not broken — they test job completion via `game.advance_by_days`
which was never correctly wired. Correct fix requires unified Job model first.

### 2. JobProcessorWorker — Partially Built, Now Superseded
Built `app/workers/job_processor_worker.rb` against 9 job model classes.
Added Sidekiq inline scoped hooks to `spec/rails_helper.rb`.
Removed `game.rb#process_jobs` and its call site.
Committed as 98b018d2.

**However**: During implementation, discovered the 9-model design is wrong.
The worker as committed is a placeholder — it will be replaced when the
unified Job model task executes. It is not harmful but should not receive
further work assignments.

### 3. Job System Architecture — Fully Resolved
After examining all job models, factories, concerns, and discussing game
mechanics, the correct architecture is now clear. See new task file.

---

## Architecture Decisions Made This Session

### Job System — Three Categories (locked)

**Category 1 — Small Manufacturing Jobs → unified `Job` model**
All share identical runtime behavior: materials consumed at submission,
timer runs, player/NPC claims outputs at completion. No partial state.
Replaces: MaterialProcessingJob, ComponentProductionJob, SmeltingJob,
UnitAssemblyJob, ResourceJob, EnvironmentJob.

**Category 2 — Surface Construction → `ConstructionJob`**
Progress tracked, can pause if materials run short (large jobs only).
Extend enum to include shell_printing: 5 and seal_printing: 6.
Retires: ShellPrintingJob, SealPrintingJob as standalone models.

**Category 3 — Orbital/Large Construction → `OrbitalConstructionProject`**
Already correctly modeled. No changes needed.

### Job Lifecycle — Small Jobs (locked)
- Materials consumed at submission by caller — job assumes materials gone
- status: in_progress → ready_to_claim → claimed
- completes_at set at submission, never changes
- Worker flips in_progress to ready_to_claim when completes_at <= Time.current
- Player claims manually via UI — outputs delivered at claim time
- NPC auto-claims via AI Manager

### Job Ownership (locked)
- Polymorphic owner — player, NPC, corporation
- Player must own blueprint to submit
- NPC has implicit blueprint access
- Jobs belong to owner, not settlement
- Settlement is facility context only

### Rebuilt Worker Design (locked)
```ruby
def perform
  Job.ready_to_process.each(&:complete!)
  ConstructionJob.where(status: :in_progress).each(&:advance!)
end
```
No hours_elapsed argument. Completion is time-based, not tick-based.

### What Was Wrong With The Old Design (for context)
- 9 separate job models — over-decomposed, 3 had no tables
- process_tick(hours_elapsed) — wrong pattern, time-based is correct
- game.rb#process_jobs — wrong scope, wrong pattern, now removed
- smelting_jobs.rb — broken duplicate file with invalid class name, delete it

---

## Remaining Failures

### ~10 failures — breakdown

**6 pending integration specs** — correctly parked, unblock after Job model exists

**escalation_integration_spec:426** — investigated, spec assertions are wrong:
- Iron assertion expects :automated_harvesting — wrong, iron requires ore→smelt
  path, correct answer is :scheduled_import
- Oxygen/water assertions conditionally correct for Luna — depends on factory
  creating correct processing units and geosphere data
- Debug puts lines in spec need removal after fix
- Do not assign to GPT-4.1 — requires game logic judgment
- Assign to Claude with Luna settlement factory file in context
- Estimated: 30–45 min

**covering_system_integration_spec:43** — not investigated this session
NoMethodError: undefined method 'cover!' for SegmentCoveringService
Independent of job system. Safe to assign next session.

**tug_construction_integration_spec lines 10, 64, 103, 141** — not investigated
OrbitalShipyardService#create_shipyard_project missing.
Needs Claude architecture pass before any agent touches it.

**item_spec:296** — pre-existing, do not touch

---

## New Task Files Written This Session

### CRITICAL — Unified Job Model
`docs/agent/tasks/backlog/2026-04-20-CRITICAL-ARCHITECTURE-UNIFIED-JOB-MODEL.md`
Full schema, migration, model, factory, rebuilt worker, rebuilt worker spec
all written in the task file. Ready to assign to Claude next session.
**This is Priority 1 for next session.**

### SUPERSEDED — Old Worker Task
`docs/agent/tasks/backlog/2026-04-20-CRITICAL-ARCHITECTURE-JOB-PROCESSOR-WORKER.md`
Status updated to SUPERSEDED. Do not assign.

---

## Files Modified This Session
- `spec/integration/manufacturing_pipeline_e2e_spec.rb` — 3 specs marked xit
- `spec/integration/component_production_game_loop_spec.rb` — 3 specs marked xit
- `app/workers/job_processor_worker.rb` — created (placeholder, will be replaced)
- `app/models/game.rb` — process_jobs removed
- `spec/rails_helper.rb` — Sidekiq inline scoped hooks added
- `spec/workers/job_processor_worker_spec.rb` — created (will be replaced)

## Files That Need Cleanup (backlog — do not touch yet)
- `app/models/smelting_jobs.rb` — broken duplicate, delete in unified Job task
- `app/models/craft/base_craft.rb.new` + .new2 + .new3 — leftover temp files

---

## Design Debt Note — Read Before Next Session

This session surfaced a recurring pattern: specs were written ahead of
explicit design decisions, and agents filled gaps with reasonable-looking
code that turned out to be wrong when examined closely.

**First task of next session before any implementation:**
Write a one-page Game Mechanics Spec for the job system covering:
- How a small job works start to finish (player flow)
- How a small job works for NPC (differences)
- How a construction job differs (pause/resume, progress display)
- What the worker does and when it runs
- What the player UI interaction is at claim time

This document goes in docs/ and is required reading for any agent touching
the job system. Without it the next agent will make the same guessing errors.
Assign to Claude. 30 minutes. Do this before moving the unified Job model
task to active.

---

## Next Session Priorities

1. **Write Job System Mechanics Spec** — Claude, 30 min, do this first
2. **Unified Job Model** — move to active, assign to Claude
   Full schema + migration + model + factory + rebuilt worker + specs
   Clears the placeholder worker, retires legacy models, unblocks 6 pending specs
3. **escalation_integration_spec:426** — Claude, with Luna factory in context
4. **covering_system_integration_spec:43** — investigate then assign
5. **tug_construction** [4 failures] — Claude architecture pass required

Target: <6 real failures after next session if unified Job model executes cleanly

---

## Notes
- Sidekiq is fully wired and running — dedicated container, Redis connected
- TaskExecutionEngine CRITICAL task still blocked by 3 backlog tasks
  (StructureCore, Marketplace, Enclosed Atmosphere) — check completed/ before planning
- Mission data refactor still in progress via Gemini — do not trigger AI Manager
  training until validated corpus is identified
- OrbitalConstructionProject advancement in worker is Phase 2 — not this session