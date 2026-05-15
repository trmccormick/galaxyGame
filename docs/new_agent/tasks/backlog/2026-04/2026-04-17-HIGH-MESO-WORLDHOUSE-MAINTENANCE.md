# 2026-04-17-HIGH-MESO-WORLDHOUSE-MAINTENANCE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority meso feature for worldhouse maintenance implementation
**Supervision Level**: 🔴 Watched carefully

## Context
Implements worldhouse maintenance challenge system including event simulation, repair logic, integration with construction and state schema.

## Problem Statement
No maintenance event simulation and repair logic implemented for worldhouses. No integration with construction and state schema.

**Expected**: Maintenance event simulation and repair logic integrated with construction and state schema, RSpec coverage for maintenance events.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/services/worldhouse_maintenance.rb` | Maintenance service | Implement event simulation, repair logic |
| `app/models/structures/worldhouse.rb` | Worldhouse model | Add maintenance state integration |
| `app/services/construction/worldhouse_construction_service.rb` | Construction service | Integrate maintenance events |
| `data/schemas/worldhouse_state.schema.json` | State schema | Add maintenance states |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/worldhouse_progression_system.md` | Progression system |
| `docs/architecture/construction_system.md` | Construction methodology |

## Implementation Steps
1. **Maintenance service**: Implement event simulation and repair logic
2. **Integration**: Integrate with construction and state schema
3. **Testing**: Write RSpec for maintenance events and repair actions
4. **Documentation**: Update architecture and docs as needed

## Acceptance Criteria
- [ ] Maintenance event simulation and repair logic implemented
- [ ] Integrated with construction and state schema
- [ ] RSpec coverage for maintenance events and repair actions

## Stop Conditions
- Architectural planning task not complete
- Duplicate maintenance logic exists elsewhere

## Commit Instructions
```bash
git add app/services/worldhouse_maintenance.rb
git add app/models/structures/worldhouse.rb
git add app/services/construction/worldhouse_construction_service.rb
git add data/schemas/worldhouse_state.schema.json
git add spec/services/worldhouse_maintenance_spec.rb
git commit -m "feat: worldhouse maintenance — implement event simulation and repair logic"
```