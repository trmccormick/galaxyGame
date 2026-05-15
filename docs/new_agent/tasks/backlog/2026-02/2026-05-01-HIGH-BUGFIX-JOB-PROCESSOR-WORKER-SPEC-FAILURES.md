# 2026-05-01-HIGH-BUGFIX-JOB-PROCESSOR-WORKER-SPEC-FAILURES.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: BUGFIX
**Name**: Fix JobProcessorWorker Spec 2 Failing Examples

## Context
JobProcessorWorker is a Sidekiq worker that queries in-progress Job and ConstructionJob records and advances those past completes_at to ready_to_claim. The spec assumes both models share the same interface and error handling behavior. Two spec failures exist - both are spec-level issues, not worker bugs.

## Problem
JobProcessorWorker spec has 2 failing examples due to spec assumptions about shared interfaces between Job and ConstructionJob models that don't hold true. Spec was written assuming identical behavior but models have different error handling.

## Files
- Target: spec/workers/job_processor_worker_spec.rb
- Related: JobProcessorWorker, Job model, ConstructionJob model

## Steps
1. Identify the 2 failing spec examples
2. Fix spec assumptions about shared model interfaces
3. Update error handling expectations to match actual model behavior
4. Ensure specs accurately test the worker functionality

## Acceptance Criteria
- JobProcessorWorker spec passes all examples
- Spec correctly handles differences between Job and ConstructionJob models
- Worker functionality properly tested without false assumptions

## Stop Condition
- JobProcessorWorker spec has 0 failures
- All spec examples pass
- Worker behavior correctly validated

## Commit
`fix: resolve JobProcessorWorker spec failures for shared model interfaces`