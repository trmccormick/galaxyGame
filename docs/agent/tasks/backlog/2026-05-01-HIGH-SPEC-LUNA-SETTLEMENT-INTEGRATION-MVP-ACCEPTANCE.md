# TASK: Luna Settlement Integration Spec — MVP Acceptance Test

**Status**: BACKLOG
**Priority**: HIGH
**Type**: spec
**Created**: 2026-05-01
**MVP Gate**: YES — this is the definition of "Luna settlement works"
**Depends On**: All 3 prior Luna MVP tasks must pass first

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Spec structure and all 4 examples are fully outlined in this task. Follow the setup notes exactly.
**Supervision Level**: 🔴 Watched carefully — this is the MVP acceptance test. Do not add extras. All 4 listed examples only.

---

## Why This Exists

The pattern from the archived backlog is clear: we've planned Luna settlement multiple times
(Feb 2026, April 2026, now May 2026) and never had a single test that definitively proves
"Luna ISRU works end to end." This spec is that test. When it passes, MVP is achieved.

---

## Spec to Create

**File**: `galaxy_game/spec/services/ai_manager/luna_settlement_integration_spec.rb`

```ruby
# Integration spec: proves the Luna settlement data-driven loop works end to end.
# This is the MVP acceptance test.
#
# Given: Luna exists in the DB with geosphere data
# When:  TaskExecutionEngineV2 loads luna_settlement_profile_v1.json
# Then:  The engine reads Luna's real world properties (not hardcoded)
#        The engine generates a task plan with ISRU phases
#        MaterialProcessingService can create a TEU job against Luna's settlement
```

### Required examples:

1. **World assessment reads real DB data**
   - Load Luna's `CelestialBody` record
   - Call `PrecursorCapabilityService.new(luna).production_capabilities`
   - Assert: `has_regolith: true`, `isru_capable: true`, no crash on nested Hash

2. **Engine loads Luna profile and builds task plan**
   - `engine = TaskExecutionEngineV2.new('LUNA-01', luna_profile_manifest)`
   - Call `engine.plan_tasks`
   - Assert: `engine.task_plan` contains phases for `power_comms`, `isru_deployment`, `gas_processing`

3. **MaterialProcessingService creates a TEU job**
   - Given a Luna settlement record
   - Call `MaterialProcessingService.new(settlement).create_processing_job`
   - Assert: Job created with correct `job_type`, `owner`, `settlement`, `output_type`, `completes_at`
   - Assert: `operational_data` contains material processing params

4. **Engine uses world properties, not hardcoded values**
   - Confirm `engine.environment['identifier']` equals `'LUNA-01'`
   - Confirm `engine.environment['has_regolith']` is `true` (from DB, not stub)
   - Confirm `engine.environment['atmosphere']` is `false` (from DB — Luna has no atmosphere)

---

## Progress (as of 2026-05-08)

### Current Status
- This MVP acceptance spec task is **on hold** and not yet started.
- No evidence that `luna_settlement_integration_spec.rb` exists or that the outlined examples have been implemented.
- The required spec structure, setup notes, and acceptance criteria remain fully relevant and actionable.
- Task is blocked until all 3 prior Luna MVP tasks are complete.

### Findings
- No integration spec exists to prove Luna ISRU works end to end.
- The task is **not stale** and should remain in the backlog until dependencies are resolved and the spec is prioritized.

### Next Steps
- Leave task in BACKLOG until all prior Luna MVP tasks are complete and this spec is ready to proceed.
- When reactivated: implement the spec exactly as outlined, with no extras.

---

## Setup Notes
- Use `let(:luna)` via the existing `:luna` factory (or seed data — check DatabaseCleaner except list)
- Use `let(:settlement)` — create a minimal settlement associated with luna
- Load the profile JSON from `data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json`
- Do NOT use `before(:all)` — use `let` / `before(:each)` to avoid identifier collision

---

## Acceptance Criteria
- All 4 examples pass in a single `rspec` run
- No hardcoded `'LUNA-01'` strings inside service code (only in test setup and JSON)
- Spec runs in under 5 seconds
- This spec is added to a `critical/` or named `smoke` tag for fast CI re-runs
