# 2026-03-30-HIGH-FEATURE-DIGITAL-TWIN-SCHEMA

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority feature for digital twin sandbox AI manager planning engine
**Supervision Level**: 🔴 Watched carefully

## Context
Digital Twin Sandbox is SimEarth-inspired planning layer providing consequence-free projection environment where TerraSim physics simulations run against cloned planetary state without affecting live world. Serves AI Manager for long-range planning decisions and admins for game balance validation.

## Problem Statement
Digital Twin Sandbox has no backend implementation — only stubbed admin views exist. No models, migrations, or service implementation in place. Without this AI Manager cannot plan ahead — can only react to current world state.

**Expected**: Full model layer, TerraSim integration, market-aware projection engine enabling AI Manager long-range planning.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/models/digital_twin.rb` | DigitalTwin model + associations | Create model for cloned planetary state |
| `app/models/simulation_run.rb` | SimulationRun model + associations | Create model for TerraSim scenario runs |
| `app/models/simulation_result.rb` | SimulationResult model + associations | Create model for projection outcomes |

### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/services/ai_manager/strategy_selector.rb` | AI Manager planning integration | Integrate digital twin projections into decision making |
| `app/services/terra_sim/terra_sim_service.rb` | TerraSim physics integration | Enable running simulations against digital twin state |

## Implementation Steps
1. **Research phase**: Read all architecture docs, understand TerraSim integration and AI Manager planning requirements
2. **Create models**: Implement DigitalTwin, SimulationRun, and SimulationResult models with proper associations
3. **Create migrations**: Generate database schema for digital twin sandbox tables
4. **Implement service layer**: Create DigitalTwinService for cloning planetary state and running projections
5. **Integrate AI Manager**: Connect digital twin projections to strategy selector decision making
6. **Add market intelligence**: Cross-reference projections with market cost history for resource planning
7. **Create admin interface**: Implement admin views for validating projections and tuning parameters

## Acceptance Criteria
- [ ] DigitalTwin model can clone planetary sphere state without affecting live world
- [ ] SimulationRun can execute TerraSim scenarios with different resource allocations
- [ ] SimulationResult stores projection outcomes for comparison
- [ ] AI Manager uses digital twin projections for long-range planning decisions
- [ ] Market cost history integrated into resource allocation planning
- [ ] Admin interface available for game balance validation

## Stop Conditions
- Implementing before test suite under 10 failures
- Breaking existing TerraSim or AI Manager functionality

## Commit Instructions
```bash
git add app/models/digital_twin.rb
git add app/models/simulation_run.rb
git add app/models/simulation_result.rb
git add app/services/digital_twin_service.rb
git add app/services/ai_manager/strategy_selector.rb
git add app/services/terra_sim/terra_sim_service.rb
git commit -m "feat: Implement Digital Twin Sandbox for AI Manager planning engine"
```