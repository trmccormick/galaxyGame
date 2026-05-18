# TASK: Escalation Fix Water Escalation ISRU Chain
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: documentation  
**Created**: 2026-02-11  
**Last Updated**: 2026-05-14  

---

## Agent Assignment

**Assigned To**: GPT-4.1 (0x)  
**Why This Agent**: Bulk migration, explicit documentation of escalation ISRU chain fix  
**Supervision Level**: autonomous OK  

**Supervision Legend**:
- 🔴 Watched carefully = 0x/0.25x agents
- 🟡 Standard = 0.33x agents  
- 🟢 Autonomous OK = 1x agents

---

## Context
EscalationService water escalation logic uses generic robots for ice extraction instead of correct ISRU chain (TEU + PVE). Luna water production logic is architecturally wrong. This task documents the requirements and migration for the new agent backlog.

---

## Problem Statement
- Current state: Water escalation logic uses incorrect units and architecture
- Expected: Document and migrate requirements for TEU/PVE ISRU chain and correct Luna water production logic

---

## Implementation Steps
1. Update EscalationService to use TEU/PVE units
2. Trigger precursor ISRU deployment if missing
3. Update spec for correct architecture
4. Remove ice_extraction robots for water escalation

---

## Acceptance Criteria
- [ ] EscalationService uses TEU/PVE units documented
- [ ] Precursor ISRU deployment logic documented
- [ ] Spec updated for correct architecture
- [ ] Ice_extraction robots removed for water escalation

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- Documented requirements for escalation ISRU chain fix

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]
