
# 2026-04-17-ADVANCED-CLAUDE-REFINE-MISSION-AI-MANAGER-ALIGNMENT.md

## Task Title
Refine Mission Plans and AI Manager Alignment (Bootstrap & Operational Phases)

## Task Overview
Audit, clarify, and document the distinction and transition between AI Manager's bootstrap harvesting and operational fallback roles in all mission plans and code. Ensure all phases, triggers, and escalation logic are actionable, template-compliant, and reference the latest code and documentation. Assign to Claude or equivalent advanced agent.

## Background & Context
- The AI Manager's bootstrap harvesting logic is implemented and used for initial base setup and resource gathering.
- The distinction between bootstrap and operational phases is present in both code and documentation.
- The operational escalation system (handling expired buy orders, automated fallback harvesting) is fully documented but remains unimplemented in the codebase.
- Pattern documentation and explicit transition triggers are still missing or incomplete.

## Actionable Steps
1. **Bootstrap Phase Clarification**
  - Label and document all bootstrap harvesting phases in mission profiles.
  - Define and document transition conditions for when a base becomes "operational" (player-accessible).
  - Clearly document AI Manager behaviors in both bootstrap and operational modes.
2. **Transition Integration**
  - Define and implement handoff triggers for AI Manager to switch from bootstrap to operational mode.
  - Specify player integration points and resource buffer requirements for transition.
3. **Pattern Learning Enhancement**
  - Create or update pattern documentation for bootstrap harvesting techniques, success metrics, and failure scenarios.
4. **Operational Escalation Implementation (BLOCKER)**
  - Implement the documented operational escalation system:
    - handle_expired_buy_orders
    - EscalationService
    - Automated harvester deployment
    - Special mission creation for expired orders
    - Scheduled import coordination
  - Update ContractCreationService beyond stub level.
5. **Documentation & Review**
  - Document all changes, triggers, and patterns in new or updated markdown files in docs/architecture/ai_manager/ and data/json-data/missions/_metadata/.
  - STOP if architectural blockers or major refactors are required; escalate to planning.
  - STOP if similar work is already complete; archive this task with reference.

## STOP/REVIEW Conditions
- STOP if architectural blockers or major refactors are required; escalate to planning.
- STOP if similar work is already complete; archive this task with reference.

## Acceptance Criteria
- [ ] Bootstrap harvesting phases clearly labeled in all mission profiles
- [ ] Transition triggers and handoff logic defined and implemented
- [ ] Pattern learning documentation enhanced for bootstrap techniques
- [ ] Operational escalation system implemented and tested
- [ ] Clear distinction between bootstrap and operational AI harvesting roles
- [ ] Player integration points and resource buffer requirements documented

## Agent Assignment
- **Agent:** Claude (or equivalent advanced AI/ML agent)

## Files to Create/Modify
- docs/architecture/ai_manager/BOOTSTRAP_HARVESTING.md (new or updated)
- docs/architecture/ai_manager/AI_MODE_TRANSITIONS.md (new or updated)
- data/json-data/missions/_metadata/bootstrap_patterns.json (new or updated)
- All mission profiles (add/verify bootstrap phase labels and triggers)
- Update ContractCreationService and implement escalation logic in code

## Estimated Time
3-4 hours

## Priority
HIGH (Critical Role Clarification)