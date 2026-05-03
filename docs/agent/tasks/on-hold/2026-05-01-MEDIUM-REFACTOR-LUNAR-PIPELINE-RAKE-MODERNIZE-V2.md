# TASK: Modernize Lunar Pipeline Rake Tasks to Use V2 Engine and Proper Services
**Phase**: 2 — Promote to backlog ~May 8

**Status**: ON-HOLD — Phase 2 (May week 2)
**Priority**: MEDIUM
**Type**: refactor
**Created**: 2026-05-01
**MVP Gate**: NO — but validates the full chain works end-to-end in a runnable form
**Depends On**: Luna settlement profile JSON + TaskExecutionEngineV2 world-driven fix

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Mechanical service substitution following patterns already in codebase.
**Supervision Level**: 🟡 Standard

---

## Context

Two rake files exist as prototypes of the Luna pipeline:
- `galaxy_game/lib/tasks/lunar_base_pipeline.rake`
- `galaxy_game/lib/tasks/lunar_base_with_isru_pipeline.rake`

These are valuable smoke tests but contain several anti-patterns that need correcting
now that the V2 engine and proper services exist:

### Anti-patterns to fix

| Anti-pattern | Where | Fix |
|---|---|---|
| `LunarBaseProductionService` class defined inside the rake file | `lunar_base_with_isru_pipeline.rake` lines 4-80 | Delete — use `Manufacturing::MaterialProcessingService` |
| Direct `ConstructionJob.create!` | `lunar_base_pipeline.rake` line ~169 | Replace with `ConstructionJobService.create_job(skylight, 'skylight_cover', settlement:)` |
| `AIManager::TaskExecutionEngine.new('lunar-precursor')` | Both files | Replace with `AIManager::TaskExecutionEngineV2.new('LUNA-01', luna_profile)` |
| Hardcoded `Luna` creation with inline attributes | Both files step 2 | Replace with `CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01')` — Luna is seeded |
| `engine.instance_variable_set(:@settlement, ...)` | Both files step 7 | Pass through proper `initialize` parameters |

### What to keep

- Overall pipeline structure (steps 1-13) — this is correct and valuable
- `ResourceTrackingService.track_procurement` calls — keep all of these
- `ConstructionJobService.create_job` calls for skylight/airlock — these are correct
- The final status printout block

---

## Steps

1. Read both rake files fully before touching anything
2. Read `galaxy_game/app/services/ai_manager/task_execution_engine_v2.rb` to understand the V2 API
3. Read `galaxy_game/app/services/manufacturing/material_processing_service.rb` to understand the correct ISRU job call
4. Update `lunar_base_pipeline.rake`:
   - Remove inline Luna creation, use `find_by!(identifier: 'LUNA-01')`
   - Replace `TaskExecutionEngine.new` with `TaskExecutionEngineV2.new`
   - Replace direct `ConstructionJob.create!` with `ConstructionJobService.create_job`
5. Update `lunar_base_with_isru_pipeline.rake`:
   - Delete the `LunarBaseProductionService` class definition (lines 4-80)
   - Replace `manufacturing_service.manufacture_component(...)` with
     `Manufacturing::MaterialProcessingService.new(settlement).process(teu_unit, 'raw_regolith', staging_amount)`
   - Same engine and Luna lookup fixes as above
6. Run the updated rake task in docker to verify:
   ```
   docker exec -it web bash -c 'bundle exec rake lunar_base:with_isru'
   ```
7. Report pass/fail with any error output

---

## Acceptance Criteria
- Both rake files run without errors in docker
- No `LunarBaseProductionService` class in any rake file
- No inline `CelestialBodies::Satellites::Moon.create!` calls — uses seeded data
- `TaskExecutionEngineV2` used (not v1) for mission execution
- `Manufacturing::MaterialProcessingService` used for all ISRU processing jobs
