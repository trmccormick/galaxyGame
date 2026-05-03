# Handoff Note — JobProcessorWorker Task
**For**: Next Claude Session Strategist
**Date**: 2026-04-20

---

## What Was Built This Session

A complete task file was written for the JobProcessorWorker:
`docs/agent/tasks/backlog/2026-04-20-CRITICAL-ARCHITECTURE-JOB-PROCESSOR-WORKER.md`

This is ready to move to `active/` and assign at the start of next session.
No code was written — the task file is the deliverable.

---

## Why This Task Exists

During today's session we discovered that `app/workers/` does not exist.
Sidekiq is fully installed and running but has zero workers. All job types
except `ShellPrintingJob` sit at `in_progress` forever because nothing ticks
them. `game.rb#process_jobs` was an improvised substitute — wrong pattern,
wrong scope, handles only one job type.

This is the root cause of 6 failing integration specs that were deferred today.

---

## What The Task Does

1. Creates `app/workers/job_processor_worker.rb` — queries all 9 job types
   by `status: 'in_progress'`, calls `process_tick(hours_elapsed)` on each
2. Configures Sidekiq inline mode in `spec/rails_helper.rb` for test environment
3. Removes `game.rb#process_jobs` entirely
4. Rewrites 6 deferred integration specs to use the worker directly
5. Marks those 6 specs pending until the worker is confirmed working

---

## Key Facts For Execution

- All 9 job models already have `process_tick(hours_elapsed)` — verified
- The worker code is fully written in the task file — no design work needed
- `game.rb` surgery is exact — specific lines identified
- Do NOT query jobs by settlement — query by `status: 'in_progress'` only
- Phase 2 (owner association, queue priority routing) is documented but gated

---

## What To Do First Next Session

1. Read full session handoff:
   `docs/agent/tasks/session-handoffs/session_handoff_2026-04-20.md`

2. Check blocker status for CRITICAL TaskExecutionEngine task:
   `docs/agent/tasks/backlog/2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN.md`
   Blocked by: StructureCore, Marketplace on Structure, Enclosed Atmosphere tasks
   Check completed/ folder for these before planning.

3. Move JobProcessorWorker task to active/ and assign to Claude

4. After worker is green — assign escalation_integration_spec:426 to GPT-4.1
   (strategy mismatch: `scheduled_import` vs `automated_harvesting` — uninvestigated,
   likely a quick win)

---

## Current Failure Count
~16 failures (down from 22 at session start)
6 of those are deferred pending this worker task.
Realistic target after next session: <10 failures.
