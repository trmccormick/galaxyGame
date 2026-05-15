# 2026-05-06-HIGH-FEATURE-JOB-PROCESSOR-WORKER-CAPACITY.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: FEATURE
**Name**: Job Processor Worker Settlement Capacity and Job Promotion

## Context
JobProcessorWorker needs to handle settlement capacity and job promotion logic. The worker should promote pending jobs to in_progress status when settlement capacity allows, and complete jobs when they reach their completion time.

## Problem
The JobProcessorWorker currently only handles job completion but lacks logic for promoting pending jobs based on settlement capacity. Jobs need to be promoted from pending to in_progress when settlement workers are available.

## Files
- Target: `galaxy_game/app/workers/job_processor_worker.rb`
- Related: Job model, Settlement models

## Steps
1. Add promote_pending_jobs method to find settlements with pending jobs
2. Implement promote_jobs_for_settlement to check settlement capacity
3. Update job status from pending to in_progress when capacity allows
4. Set start_date and completes_at when job starts
5. Ensure existing job completion logic remains intact

## Acceptance Criteria
- Pending jobs are promoted to in_progress when settlement capacity allows
- Job start_date and completes_at are set correctly
- Existing job completion logic works unchanged
- RSpec tests verify job promotion and completion

## Stop Condition
- JobProcessorWorker handles both job promotion and completion
- Settlement capacity is properly checked before job promotion
- All job lifecycle states work correctly

## Commit
`feat: add job promotion logic to JobProcessorWorker`