# 2026-04-17-HIGH-MESO-WORLDHOUSE-FAILURE-ANALYSIS

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority meso feature for worldhouse failure analysis implementation
**Supervision Level**: 🔴 Watched carefully

## Context
Implements failure cascade, time-to-repair (TTR), and salvage/resource recovery logic for worldhouses and orbital/asteroid conversions. Integrates with maintenance and state schema.

## Problem Statement
No failure cascade, TTR, salvage/resource recovery logic implemented for worldhouses. No integration with maintenance and state schema.

**Expected**: Failure cascade, TTR, salvage/resource recovery logic integrated with maintenance and state schema, RSpec coverage for failure scenarios.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/services/worldhouse_failure_analyzer.rb` | Failure analyzer service | Implement failure cascade, TTR, salvage logic |
| `app/models/structures/worldhouse.rb` | Worldhouse model | Add failure state integration |
| `app/services/worldhouse_maintenance.rb` | Maintenance service | Integrate failure analysis |
| `data/schemas/worldhouse_state.schema.json` | State schema | Add failure states |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/worldhouse_progression_system.md` | Progression system |
| `docs/architecture/construction_system.md` | Construction methodology |

## Implementation Steps
1. **Failure analyzer**: Implement failure cascade, TTR, salvage/resource recovery logic
2. **Integration**: Integrate with maintenance and state schema
3. **Testing**: Write RSpec for failure scenarios and recovery
4. **Documentation**: Update architecture and docs as needed

## Acceptance Criteria
- [ ] Failure cascade, TTR, and salvage/resource recovery logic implemented
- [ ] Integrated with maintenance and state schema
- [ ] RSpec coverage for failure scenarios and recovery

## Stop Conditions
- Architectural planning task not complete
- Duplicate failure analysis logic exists elsewhere

## Commit Instructions
```bash
git add app/services/worldhouse_failure_analyzer.rb
git add app/models/structures/worldhouse.rb
git add app/services/worldhouse_maintenance.rb
git add data/schemas/worldhouse_state.schema.json
git add spec/services/worldhouse_failure_analyzer_spec.rb
git commit -m "feat: worldhouse failure analysis — implement failure cascade, TTR, and salvage logic"
```