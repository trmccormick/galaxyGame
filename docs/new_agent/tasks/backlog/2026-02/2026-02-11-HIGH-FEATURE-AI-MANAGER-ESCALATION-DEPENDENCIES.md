# TASK: 2026-02-11-HIGH-FEATURE-AI-MANAGER-ESCALATION-DEPENDENCIES
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: feature  
**Created**: 2026-02-11  
**Last Updated**: 2026-05-14  

---

## Agent Assignment

**Assigned To**: 0.33x (Gemini Flash)  
**Why This Agent**: AI service creation, follows existing mission service patterns  
**Supervision Level**: standard  

**Supervision Legend**:
- 🔴 Watched carefully = 0x/0.25x agents
- 🟡 Standard = 0.33x agents  
- 🟢 Autonomous OK = 1x agents

---

## Context
AI Manager escalation system has missing dependencies that prevent emergency mission creation and proper atmosphere simulation.

**Relevant Architecture Docs** — read before starting:
- `docs/systems/ai-manager.md` — [AI manager escalation system]
- `docs/systems/terra-sim.md` — [atmosphere simulation]

---

## Problem Statement
EscalationService calls EmergencyMissionService methods that don't exist, blocking emergency mission creation. Temperature clamping and greenhouse effect capping exist but EmergencyMissionService is missing.

**Current behavior**: EscalationService fails when trying to create emergency missions  
**Expected behavior**: EmergencyMissionService provides emergency mission creation and reward calculation  

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/emergency_mission_service.rb` | Emergency mission service | new file |
| `spec/services/ai_manager/emergency_mission_service_spec.rb` | Tests | new file |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/ai_manager/escalation_service.rb` | Calls EmergencyMissionService | lines 39, 303 |
| `app/services/ai_manager/special_mission_service.rb` | Mission service pattern | for compatibility |

---

## Implementation Steps

### Step 1 — Create EmergencyMissionService
Create app/services/ai_manager/emergency_mission_service.rb with:
- `calculate_emergency_reward(resource)` method for reward calculation
- `create_emergency_mission()` method for mission creation
- Follow existing SpecialMissionService patterns
- Proper error handling and logging

### Step 2 — Implement reward calculation
Add calculate_emergency_reward method:
- Takes resource symbol (:oxygen, :water, :energy, etc.)
- Calculates reward based on resource scarcity and urgency
- Returns reward amount in GCC

### Step 3 — Implement mission creation
Add create_emergency_mission method:
- Takes escalation parameters (settlement, resource, severity)
- Creates emergency mission record
- Sets appropriate mission parameters and deadlines
- Returns mission object or success status

### Step 4 — Create comprehensive tests
Create spec/services/ai_manager/emergency_mission_service_spec.rb with:
- Reward calculation tests for different resources
- Mission creation tests with various parameters
- Error handling tests
- Integration with escalation service

### Step 5 — Run tests
DO NOT INFER THE COMMAND. Run this exact string from the host terminal:

Bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/emergency_mission_service_spec.rb'
Expected result: X examples, 0 failures

---

## Acceptance Criteria
- [ ] EmergencyMissionService.calculate_emergency_reward() works for all resource types
- [ ] EmergencyMissionService.create_emergency_mission() creates valid missions
- [ ] EscalationService no longer fails with missing method errors
- [ ] RSpec tests cover all major functionality
- [ ] No routing errors
- [ ] Consistent with existing mission service patterns
- [ ] Isolation run: 0 failures
- [ ] No regressions in escalation service specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Mission creation conflicts with existing mission systems
- Reward calculation affects game economy balance
- Emergency missions duplicate existing mission types

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add app/services/ai_manager/emergency_mission_service.rb spec/services/ai_manager/emergency_mission_service_spec.rb
git commit -m "feat: AI manager emergency mission service

- Create EmergencyMissionService for escalation system
- Implement calculate_emergency_reward method for resource rewards
- Implement create_emergency_mission method for emergency mission creation
- Add comprehensive RSpec test coverage"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: [none]  
**Blocks**: [AI manager escalation functionality]  
**Related tasks**: [escalation service fixes, atmosphere simulation]  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `app/services/ai_manager/emergency_mission_service.rb` — created emergency mission service
- `spec/services/ai_manager/emergency_mission_service_spec.rb` — created comprehensive tests

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]