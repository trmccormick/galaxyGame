# 2026-03-27-HIGH-REFACTOR-ESCALATION-SERVICE-NO-MAGIC-ROBOT-DEPLOYMENT

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority refactor for escalation service no-magic robot deployment
**Supervision Level**: 🔴 Watched carefully

## Context
EscalationService#create_automated_harvester calls Units::Robot.create! directly, bypassing No-Magic Protocol. AI cannot conjure units from nothing. Robot must exist in inventory or be built from available materials/infrastructure. GCC only required when materials must be purchased from market.

## Problem Statement
create_automated_harvester uses Units::Robot.create! without checking inventory, manufacturing capability, or material availability. Violates No-Magic Protocol and bypasses load_unit_info for operational defaults.

**Expected**: Service follows No-Magic decision tree: check inventory for undeployed HRV-400, check if AI can build one, queue ManufacturingJob if materials available, escalate through 3-tier sourcing if needed, return BLOCKED status if all fail.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/services/ai_manager/escalation_service.rb` | Core escalation logic | Replace direct create! call with No-Magic decision tree |
| `spec/services/ai_manager/escalation_service_spec.rb` | Spec tests | Rewrite tests to validate correct No-Magic pattern |

## Implementation Steps
1. **Research phase**: Read all reference files to understand current patterns and requirements
2. **Decision tree implementation**: Replace direct create! with inventory check, manufacturing capability check, material availability check
3. **Manufacturing integration**: Queue ManufacturingJob when materials available, use GCC only when market purchase required
4. **Spec updates**: Rewrite tests to validate No-Magic decision tree behavior
5. **Blueprint compliance**: Ensure operational_data loaded from HRV-400 blueprint JSON

## Acceptance Criteria
- [ ] No direct Units::Robot.create! calls in escalation service
- [ ] Robot deployment follows No-Magic sourcing hierarchy
- [ ] Manufacturing jobs queued when materials available
- [ ] GCC costs only when market purchases required
- [ ] Operational data loaded from blueprint JSON
- [ ] All specs pass with new decision tree logic

## Stop Conditions
- Breaking existing escalation service functionality
- Changes beyond escalation service and related specs

## Commit Instructions
```bash
git add app/services/ai_manager/escalation_service.rb
git add spec/services/ai_manager/escalation_service_spec.rb
git commit -m "refactor: Escalation service no-magic robot deployment decision tree"
```