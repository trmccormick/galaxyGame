# 2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: Claude 1x — Critical architecture task requiring deep reasoning across AI Manager, mission generation, pattern learning systems
**Supervision Level**: 🟢 Autonomous OK

## Context
AI Manager autonomously builds Development Corporations on new worlds to establish footholds for players. As player base expands, AI Manager expands wormhole station infrastructure. TaskExecutionEngine cleanup and AI Manager training resumption architecture.

## Problem Statement
TaskExecutionEngine has hardcoded Luna/L1 logic bypassing pattern learning. Settlement/structure hierarchy wrong. Market system not connected to construction. No StructureCore. OrbitalConstructionProject associated with wrong settlement class.

**Expected**: Pure mission task runner that reads mission JSON, executes tasks from tasks_v2 library. Blueprint-driven material resolution. Clean separation of concerns.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/services/task_execution_engine.rb` | Task execution engine | Remove hardcoded logic, make blueprint-driven |
| `app/services/orbital_construction_logistics_service.rb` | New logistics service | Extract orbital_resupply_cycle logic |
| `app/services/mission_generator_service.rb` | New generator service | Pattern to mission JSON generation |
| `app/services/material_calculation_service.rb` | New calculation service | Property-driven material requirements |
| `app/services/development_corporation_service.rb` | New DC service | DC establishment on foothold completion |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/data/json-data/missions/tasks_v2/` | Task library |
| `docs/architecture/` | Architecture docs |

## Implementation Steps
1. **StructureCore extraction**: Unblock OrbitalStructure/OrbitalSettlement association
2. **Marketplace on structure**: Unblock DC establishment and market mode
3. **Extract orbital_resupply_cycle**: Move to OrbitalConstructionLogisticsService
4. **OrbitalConstructionLogisticsService**: Blueprint-driven, market-aware
5. **Mark failing specs pending**: 3 specs in task_execution_engine_spec.rb
6. **Verify tasks_v2 reading**: Ensure TaskExecutionEngine reads task library correctly
7. **MaterialCalculationService**: Property-driven requirements for asteroid conversion
8. **MissionGeneratorService**: Pattern to mission generation
9. **DevelopmentCorporationService**: DC establishment
10. **Sol validation test**: Observe AI Manager expansion behavior

## Acceptance Criteria
- [ ] Architecture document produced covering all components
- [ ] OrbitalConstructionLogisticsService fully designed
- [ ] MissionGeneratorService interface specified
- [ ] DC establishment flow designed
- [ ] Sol validation test criteria defined
- [ ] Implementation order confirmed
- [ ] No code changes in this task — design only
- [ ] 3 failing specs marked pending with correct reference

## Stop Conditions
- StructureCore not extracted
- Marketplace on structure not implemented

## Commit Instructions
```bash
git add app/services/orbital_construction_logistics_service.rb
git add app/services/mission_generator_service.rb
git add app/services/material_calculation_service.rb
git add app/services/development_corporation_service.rb
git commit -m "feat: task execution engine — blueprint-driven architecture for AI Manager training resumption"
```