# TASK: 2026-02-11-HIGH-FEATURE-AI-MANAGER-AUTONOMOUS-EXPANSION
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: feature  
**Created**: 2026-02-11  
**Last Updated**: 2026-05-14  

---

## Agent Assignment

**Assigned To**: 0.33x (Gemini Flash)  
**Why This Agent**: Complex AI service creation, follows existing patterns  
**Supervision Level**: standard  

**Supervision Legend**:
- 🔴 Watched carefully = 0x/0.25x agents
- 🟡 Standard = 0.33x agents  
- 🟢 Autonomous OK = 1x agents

---

## Context
AI Manager lacks autonomous expansion capability. Currently can only handle settlement expansion within existing systems, but cannot discover, evaluate, or establish presence in new star systems through wormhole network.

**Relevant Architecture Docs** — read before starting:
- `docs/systems/ai-manager.md` — [AI manager system]
- `docs/systems/wormhole-network.md` — [wormhole network]

---

## Problem Statement
AI Manager cannot autonomously expand into new star systems. Missing system discovery, evaluation, foothold establishment, and strategic expansion logic.

**Current behavior**: AI handles settlement expansion within systems only  
**Expected behavior**: AI can discover, evaluate, and colonize new star systems autonomously  

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/autonomous_expansion_service.rb` | AI expansion service | new file |
| `app/services/ai_manager/system_discovery_service.rb` | System discovery | new file |
| `app/services/ai_manager/foothold_establishment_service.rb` | Foothold creation | new file |
| `spec/services/ai_manager/autonomous_expansion_service_spec.rb` | Tests | new file |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/ai_manager/mission_scorer.rb` | Existing scoring logic | expansion_readiness |
| `app/models/star_system.rb` | System model | for discovery queries |

---

## Implementation Steps

### Step 1 — Create system discovery service
Create app/services/ai_manager/system_discovery_service.rb with:
- Query unexplored star systems within wormhole range
- Distance calculations from current settlements
- System metadata analysis (planet count, resources, habitability)
- Discovery probability based on scouting investment

### Step 2 — Implement strategic evaluation algorithm
Add to autonomous expansion service:
- Multi-factor scoring: resources, position, threats, connectivity
- Comparative ranking against current capabilities
- Economic forecasting for long-term value
- Threat assessment and risk evaluation

### Step 3 — Develop foothold establishment service
Create app/services/ai_manager/foothold_establishment_service.rb with:
- Planetary site selection algorithm (habitability, resources, strategy)
- Automated resource allocation for new footholds
- Bootstrap resource packages (energy, life support, construction)
- Integration with logistics coordinator

### Step 4 — Create autonomous expansion service
Create app/services/ai_manager/autonomous_expansion_service.rb with:
- Mission generation for exploration and colonization
- AI-driven prioritization and scheduling
- Mission success prediction and risk assessment
- Wormhole network expansion planning

### Step 5 — Integrate with wormhole network
Add wormhole topology integration:
- Query active connections and ranges
- Pathfinding for multi-hop expansion routes
- Stability and capacity considerations
- Network centrality calculations

### Step 6 — Create comprehensive tests
Create spec/services/ai_manager/autonomous_expansion_service_spec.rb with:
- System discovery and evaluation tests
- Foothold establishment tests
- Mission generation and prioritization tests
- Wormhole integration tests

### Step 7 — Run tests
DO NOT INFER THE COMMAND. Run this exact string from the host terminal:

Bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/autonomous_expansion_service_spec.rb'
Expected result: X examples, 0 failures

---

## Acceptance Criteria
- [ ] System discovery service queries unexplored systems within range
- [ ] Strategic evaluation algorithm scores systems by multiple factors
- [ ] Foothold establishment service selects optimal colony sites
- [ ] Autonomous expansion service generates and prioritizes missions
- [ ] Wormhole network integration supports multi-hop expansion
- [ ] RSpec tests cover all major functionality
- [ ] No routing errors
- [ ] Consistent with existing AI manager patterns
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- System discovery requires complex astronomical calculations
- Foothold logic conflicts with existing settlement creation
- Mission generation conflicts with existing AI mission system

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add app/services/ai_manager/autonomous_expansion_service.rb app/services/ai_manager/system_discovery_service.rb app/services/ai_manager/foothold_establishment_service.rb spec/services/ai_manager/autonomous_expansion_service_spec.rb
git commit -m "feat: AI manager autonomous expansion system

- Create system discovery service for finding new star systems
- Implement strategic evaluation algorithm for system assessment
- Develop foothold establishment service for automated colonization
- Add autonomous expansion service with mission generation
- Integrate with wormhole network for expansion planning
- Add comprehensive RSpec test coverage"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: [none]  
**Blocks**: [galactic expansion features]  
**Related tasks**: [wormhole network updates, strategic evaluation algorithm]  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `app/services/ai_manager/autonomous_expansion_service.rb` — created expansion service
- `app/services/ai_manager/system_discovery_service.rb` — created discovery service
- `app/services/ai_manager/foothold_establishment_service.rb` — created foothold service
- `spec/services/ai_manager/autonomous_expansion_service_spec.rb` — created tests

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]