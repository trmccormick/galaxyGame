# Session Handoff — 2026-04-20

## Session Metrics
- Start: 22 failures → End: ~16 failures (6 integration specs deferred, explained below)
- Commits: 1 (unit factory default `basic_unit` → `solar_panel`)
- Tasks completed: 1 cascade root fix (manufacturing service specs green)
- Agents: GPT-4.1 (factory fix), Claude (strategic/architectural)
- Branch: regional-view-phase2

---

## Current Baseline
3925 examples, ~16 failures, 44 pending
Previous: 22 failures
Change this session: -6 (manufacturing service layer clean)

---

## What Was Discovered This Session

This session pivoted from spec fixing to architectural discovery. The 6 remaining
manufacturing integration failures exposed foundational gaps that need to be understood
before more specs are fixed.

### 1. Unit Factory Bad Default — Fixed
`spec/factories/units/units.rb:6` had `unit_type: "basic_unit"` — a placeholder that
was never updated. `basic_unit` has no JSON data file and doesn't exist as a game entity.
Changed to `solar_panel` which has complete operational data. Manufacturing service specs
now clean.

### 2. Job System Architecture Gap — Discovered
`game.rb#process_jobs` only ticks `ShellPrintingJob`. All other job types
(`MaterialProcessingJob`, `ComponentProductionJob`, etc.) never get ticked — they sit
at `in_progress` forever. This is why 6 integration specs fail.

Root cause is deeper than a missing job type in a list. The correct architecture is:
- Jobs are entity-owned work orders (player, NPC, corporation) — not settlement-scoped
- Ticking was always intended to be a Sidekiq cron worker — not inline in `game.rb`
- `app/workers/` directory does not exist yet
- Sidekiq is fully installed, wired, and running (dedicated container, Redis connected,
  queues configured: critical/default/low) but has zero workers

### 3. TaskExecutionEngine Is Wrong — Known, Task Exists
`AIManager::TaskExecutionEngine` runs missions synchronously in a blocking while loop.
This was a temporary scaffold. The correct architecture is Sidekiq-backed async task
execution.

CRITICAL task file already exists:
`docs/agent/tasks/backlog/2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN.md`

This task is blocked by:
- `2026-04-18-HIGH-ARCHITECTURE-STRUCTURE-CORE-CONCERN.md`
- `2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.md`
- `2026-04-17-CRITICAL-ARCHITECTURE-ENCLOSED-ATMOSPHERE-FAILURE-PREDICTION-PLANNING.md`

Blocker status was not checked this session — verify before planning next session.

### 4. AI Manager Execution Loop — Full Picture Established

```
Game Data (unit blueprints, body properties)
    ↓ AI Manager reads and learns
Pattern Library (Phobos Pattern, Luna Precursor, etc.)
    ↓ matched against system survey
Mission Profile (AI Manager generates autonomously)
    ↓ references
tasks_v2 (144 files — generic, system-agnostic building blocks)
  + manifests_v2 (hardware archetypes with task_affinity links)
    ↓ executed by
TaskExecutionEngine (pure runner — needs cleanup)
    ↓ creates
Job Models (process_tick exists on all job types)
    ↓ ticked by
JobProcessorWorker (DOES NOT EXIST YET — needs to be built)
    ↓ outcomes feed back to
AI Manager (refine patterns, admin tunes early runs)
```

Data layer is mature: 144 tasks_v2 files, 665 mission JSONs (see mission data note below).
The AI Manager has substantial learning material. The gap is execution infrastructure.

---

## Remaining Failures

### 6 Manufacturing Integration Specs — Deferred (infrastructure gap)
```
spec/integration/manufacturing_pipeline_e2e_spec.rb:277, 544, 589
spec/integration/component_production_game_loop_spec.rb:117, 148, 164
```

These are not broken code. They test job completion via `game.advance_by_days` which
was never correctly wired to all job types. The correct fix requires building
`JobProcessorWorker` first, then rewriting specs to use it. Do not patch with direct
`process_tick` calls — that tests the wrong thing.

Mark pending with this note:
```ruby
# PENDING: Depends on JobProcessorWorker (Sidekiq) — not yet built
# See: docs/agent/tasks/backlog/2026-04-20-CRITICAL-ARCHITECTURE-JOB-PROCESSOR-WORKER.md
# game.advance_by_days does not tick MaterialProcessingJob or ComponentProductionJob
# Fix: build worker, configure Sidekiq inline for test env, rewrite specs
```

### escalation_integration_spec:426 — Independent, Not Investigated
Strategy mismatch: `scheduled_import` vs `automated_harvesting`. Not touched this
session. Independent of job system — safe to assign next session.

### covering_system_integration_spec:43 — Independent, Not Investigated
`NoMethodError: undefined method 'cover!' for SegmentCoveringService`. Not touched
this session. Independent of job system — safe to assign next session.

### tug_construction_integration_spec [10,64,103,141] — Architecture Gap
`OrbitalShipyardService#create_shipyard_project` missing. Needs Claude design pass
before any agent touches it.

### item_spec:296 — Pre-existing, Do Not Touch

---

## New Task Files Needed (write before next session)

### Priority 1 — JobProcessorWorker
File: `2026-04-20-CRITICAL-ARCHITECTURE-JOB-PROCESSOR-WORKER.md`

Design spec:
- Build `app/workers/job_processor_worker.rb` — Sidekiq worker
- Query all in_progress jobs across all 9 job types
- Call `process_tick(hours_elapsed)` on each
- All 9 job models already have `process_tick` — worker just needs to find and call them
- Jobs associate to settlement differently across types — worker queries by
  `status: 'in_progress'` not by settlement
- Configure Sidekiq inline mode in `spec/rails_helper.rb` for test environment
- Queue: `default` for Phase 1, priority routing in Phase 2 when owner association added
- Remove or stub `game.rb#process_jobs` — replace with worker enqueue call
- Phase 2 (later): add owner association to job models, route to critical/default/low
  by owner type

### Priority 2 — Mark 6 specs pending
One-line task for GPT-4.1: add `xit` + pending comment to 6 integration specs
referencing the worker task file.

---

## Architecture Decisions Established This Session

1. Job ownership: Jobs belong to commissioning entity (player/NPC/corporation) — not
   settlement. Owner association not yet on models — Phase 2 work.

2. Job ticking: Sidekiq `JobProcessorWorker` only. `game.rb#process_jobs` is the wrong
   pattern — remove it.

3. Sidekiq queue priority:
   - critical: GCC transfers, market orders, urgent player jobs, wormhole/megaproject milestones
   - default: AI Manager dispatch, production/construction jobs, resource consumption
   - low: planetary sim, atmospheric, long-horizon planning, economy aggregates

4. TaskExecutionEngine: Pure runner only. No hardcoded world knowledge. Reads tasks_v2,
   resolves inputs from game state, creates real jobs, passes outputs to next task.
   Cleanup blocked by StructureCore + Marketplace tasks.

5. manifests_v2 + tasks_v2: `task_affinity` field links manifest hardware to generic
   task types. Engine resolves which unit performs which task from manifest — no
   hardcoding in the engine.

6. AI Manager role: Player-first infrastructure provider. Runs DC bases, logistics,
   megaprojects, wormhole expansion. Not a competitor — a game master and infrastructure
   layer. Largest single user of the job system.

7. Mission profiles: AI Manager generates these autonomously from pattern learning +
   system survey. Admin observes and tunes early runs. 144 tasks_v2 + 665 mission JSONs
   exist as training/execution material (see mission data note below).

---

## Files Modified This Session
- `spec/factories/units/units.rb` — `basic_unit` → `solar_panel` default

## Files That Need Cleanup (backlog — do not touch yet)
- `app/models/craft/base_craft.rb.new`
- `app/models/craft/base_craft.rb.new2`
- `app/models/craft/base_craft.rb.new3`
Leftover temp files from a previous agent edit. Add a cleanup task to backlog.

---

## Next Session Priorities
1. Verify blocker status for CRITICAL TaskExecutionEngine task (StructureCore,
   Marketplace, Enclosed Atmosphere) — check completed/ folder before planning
2. Write `JobProcessorWorker` task file and assign to Claude
3. Mark 6 integration specs pending — GPT-4.1, 15 minutes max
4. `escalation_integration_spec:426` — investigate and assign to GPT-4.1
5. `covering_system_integration_spec:43` — investigate, then assign
6. `tug_construction` [4 failures] — Claude architecture pass required

Target: <12 failures by end of next session if worker task is scoped correctly
and blocker status is favorable.

---

## Notes for Next Session Strategist

### Session Context
This session was architectural triage, not spec grinding. The manufacturing cascade
exposed a foundational Sidekiq gap that would have caused confusion for weeks if not
surfaced now. The job system, TaskExecutionEngine, and AI Manager execution loop are
now fully mapped. Next session has a clear plan.

Do not let agents touch `game.rb#process_jobs` or `TaskExecutionEngine` without
reading the CRITICAL task file first:
`docs/agent/tasks/backlog/2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN.md`

### Mission Data — Partially Stale, Refactor In Progress
The 665 mission JSON files are not all current. A significant portion predate recent
architecture changes and need refactoring. Refactor work is ongoing — primarily Gemini.
Do not treat the mission JSON count as a measure of readiness.

Before any agent reads or trains on mission profiles:
- Confirm with the human which mission profiles are current/validated
- Do not assume older files conform to tasks_v2 / manifests_v2 conventions
- The tasks_v2 files (144) are more reliable — built with current architecture in mind

Do not assign MissionGeneratorService or AI Manager training tasks until:
1. Mission data refactor has a known completion state
2. A validated corpus of mission profiles is identified
3. Gemini's refactor work is reviewed and merged

The AI Manager cannot train on stale patterns without learning the wrong behaviors.
The data quality gate must be explicit before anyone triggers a training run.
