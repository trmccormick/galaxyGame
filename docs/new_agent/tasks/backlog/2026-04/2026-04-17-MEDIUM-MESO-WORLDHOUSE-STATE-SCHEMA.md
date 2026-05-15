# 2026-04-17-MEDIUM-MESO-WORLDHOUSE-STATE-SCHEMA

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority meso feature for worldhouse state schema definition
**Supervision Level**: 🔴 Watched carefully

## Context
Define and validate canonical JSON schemas for worldhouse construction, maintenance, failure states. All simulation and AI modules must use these schemas for state tracking and validation.

## Problem Statement
No canonical JSON schemas for worldhouse construction, maintenance, failure states. No standardized format for worldhouse state tracking and validation.

**Expected**: Canonical JSON schema for all worldhouse states with integration across construction, maintenance, failure, AI learning modules.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `data/schemas/worldhouse_state.schema.json` | Schema definition | Define canonical worldhouse state schemas |
| `app/models/structures/worldhouse.rb` | Worldhouse model | Integrate schema validation |
| `app/services/worldhouse_maintenance.rb` | Maintenance service | Integrate schema validation |
| `app/services/worldhouse_failure_analyzer.rb` | Failure analyzer | Integrate schema validation |
| `app/services/ai_manager/worldhouse_learning.rb` | AI learning | Integrate schema validation |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/worldhouse_progression_system.md` | Progression system |
| `docs/architecture/construction_system.md` | Construction methodology |

## Implementation Steps
1. **Schema draft**: Define canonical JSON schema for worldhouse states
2. **Integration**: Integrate schema validation with all relevant modules
3. **Testing**: Write RSpec for schema validation and integration
4. **Documentation**: Document schema and integration points

## Acceptance Criteria
- [ ] Canonical JSON schema for all worldhouse states defined and validated
- [ ] Integrated with construction, maintenance, failure, and AI learning modules
- [ ] RSpec coverage for schema validation and integration

## Stop Conditions
- Architectural plan not complete
- Schema conflicts with existing worldhouse data structures

## Commit Instructions
```bash
git add data/schemas/worldhouse_state.schema.json
git add app/models/structures/worldhouse.rb
git add app/services/worldhouse_maintenance.rb
git add app/services/worldhouse_failure_analyzer.rb
git add app/services/ai_manager/worldhouse_learning.rb
git add spec/models/structures/
git add spec/services/
git commit -m "feat: worldhouse state schema — define canonical JSON schemas for worldhouse states"
```