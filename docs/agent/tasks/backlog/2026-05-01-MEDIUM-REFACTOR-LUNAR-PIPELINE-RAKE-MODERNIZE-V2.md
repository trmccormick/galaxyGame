# TASK: Modernize Lunar Pipeline Rake Tasks to Use V2 Engine and Proper Services
**Phase**: 2 — Promote to backlog ~May 8

**Status**: BACKLOG
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
...existing code...
