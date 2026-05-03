# TASK: Complete Job schema refactor for manufacturing services

**Status**: COMPLETED
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-04-26
**Last Updated**: 2026-05-01 (superseded — all work described here is complete; see `2026-04-26-HIGH-REFACTOR-JOB-SCHEMA-JSON-MIGRATION.md` for remaining scope)

> ⚠️ MOVE THIS FILE to `docs/agent/tasks/completed/`

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Routine service/spec updates based on established architectural decision.
**Supervision Level**: 🔴 Watched carefully

---

## Context
We have updated the `Job` model to support `pending` status and identified the missing `operational_data` schema requirement. The `Job` model now requires `owner`, `settlement`, `job_type`, `output_type`, and `completes_at` for validation.

## Problem Statement
Manufacturing services are still failing because they do not provide the mandatory `Job` attributes in `create!` calls and have not fully moved metadata into `operational_data`.

## Implementation Steps
1. **MaterialProcessingService**: Update `Job.create!` in both `#process` and `#complete_job` to include mandatory fields: `owner`, `settlement`, `job_type`, `output_type`, and `completes_at`.
2. **Operational Data**: Ensure all extra metadata (`processing_type`, `input_material`, etc.) is nested within the `operational_data` JSON hash.
3. **Spec Updates**: Update `material_processing_service_spec.rb` to provide these mandatory attributes in all `Job.create!` calls.
4. **Verification**: Run isolation spec: `bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb`

---

## Acceptance Criteria
- [ ] Service `create!` calls provide all 5 mandatory fields (`owner`, `settlement`, `job_type`, `output_type`, `completes_at`).
- [ ] No `ActiveRecord::RecordInvalid` errors remain.
- [ ] All manufacturing metadata is correctly encapsulated in `operational_data`.
- [ ] Isolation spec: 0 failures.