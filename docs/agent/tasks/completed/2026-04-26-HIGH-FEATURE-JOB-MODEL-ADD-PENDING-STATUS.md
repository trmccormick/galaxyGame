# TASK: Add :pending state to Job status enum

**Status**: COMPLETED
**Priority**: HIGH
**Type**: feature
**Created**: 2026-04-26
**Last Updated**: 2026-05-01 (reviewed — work already applied, task file not moved)

> ⚠️ MOVE THIS FILE to `docs/agent/tasks/completed/`

## Context
The Job model currently lacks a `pending` status, which is required for the new queued job architecture. Current attempts to set `status: :pending` fail with an `ArgumentError`.

## Implementation Steps
1. Add `:pending` to the `enum :status` definition in `app/models/job.rb`.
2. Ensure the value is appended to the end of the enum definition to maintain backward compatibility with existing integers.
3. Run the following to verify: 
   `bundle exec rails runner "Job.new(status: :pending).valid?"`
4. Update services to use `status: :pending` for newly created jobs.

## Acceptance Criteria
- [x] `Job.defined_enums["status"]` includes "pending" — confirmed at `app/models/job.rb:23` (`pending: 5`)
- [x] `Job.new(status: :pending).valid?` returns true.
- [x] Manufacturing services successfully create jobs with `pending` status.