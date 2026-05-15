# TASK: 2026-02-11-HIGH-FEATURE-AI-MANAGER-RESOURCE-ALLOCATION-ENGINE
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: feature  
**Created**: 2026-02-11  
**Last Updated**: 2026-05-14  

---

## Agent Assignment

**Assigned To**: 0.33x (Gemini Flash)  
**Why This Agent**: Complex resource allocation algorithms, follows existing AI manager patterns  
**Supervision Level**: standard  

**Supervision Legend**:
- 🔴 Watched carefully = 0x/0.25x agents
- 🟡 Standard = 0.33x agents  
- 🟢 Autonomous OK = 1x agents

---

## Context
AI Manager needs automated resource allocation engine for bootstrap settlement logistics, ISRU priority calculation, and economic startup planning for new colonies.

**Relevant Architecture Docs** — read before starting:
- `docs/systems/ai-manager.md` — [AI manager resource allocation]
- `docs/economics/resource-management.md` — [resource flow systems]

---

## Problem Statement
No comprehensive resource allocation engine for colony bootstrap. Basic ResourceAllocator exists but lacks bootstrap logistics, ISRU optimization, and economic startup planning.

**Current behavior**: Basic resource allocation exists but no automated bootstrap planning  
**Expected behavior**: Complete resource allocation engine with bootstrap logistics and ISRU optimization  

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/resource_allocation_engine.rb` | Resource allocation engine | new file |
| `app/services/ai_manager/bootstrap_resource_allocator.rb` | Bootstrap logistics | enhance existing |
| `app/services/ai_manager/isru_priority_calculator.rb` | ISRU optimization | new file |
| `app/services/ai_manager/economic_startup_planner.rb` | Economic planning | new file |
| `spec/services/ai_manager/resource_allocation_engine_spec.rb` | Tests | new file |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/ai_manager/resource_allocator.rb` | Existing basic allocator | for integration |

---

## Implementation Steps

### Step 1 — Create resource allocation engine
Create app/services/ai_manager/resource_allocation_engine.rb with:
- Bootstrap settlement logistics (initial resource packages, transportation planning)
- Resource distribution algorithms (settlement scaling, risk mitigation)
- Dynamic reallocation support
- Integration with existing ResourceAllocator

### Step 2 — Implement ISRU priority calculator
Create app/services/ai_manager/isru_priority_calculator.rb with:
- Local resource assessment and extraction potential evaluation
- Extraction priority ranking by cost vs strategic value
- Technology requirements analysis for ISRU operations
- Economic optimization between imported vs local resources

### Step 3 — Develop economic startup planner
Create app/services/ai_manager/economic_startup_planner.rb with:
- Development budgeting and initial colonization cost calculation
- Revenue projections from resource extraction and trade
- Break-even analysis and timeline to self-sufficiency
- Investment prioritization by ROI and strategic impact

### Step 4 — Enhance bootstrap resource allocator
Update app/services/ai_manager/bootstrap_resource_allocator.rb with:
- Critical path analysis for essential settlement survival resources
- Supply chain establishment for ongoing resource flow
- Efficiency optimization for transportation costs
- Buffer resources for unexpected challenges

### Step 5 — Create comprehensive tests
Create spec/services/ai_manager/resource_allocation_engine_spec.rb with:
- Bootstrap logistics and resource package tests
- ISRU priority calculation and optimization tests
- Economic startup planning and budgeting tests
- Integration tests with existing resource allocator

### Step 6 — Run tests
DO NOT INFER THE COMMAND. Run this exact string from the host terminal:

Bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/resource_allocation_engine_spec.rb'
Expected result: X examples, 0 failures

---

## Acceptance Criteria
- [ ] Resource allocation engine manages bootstrap settlement logistics
- [ ] ISRU priority calculator optimizes local resource utilization
- [ ] Economic startup planner provides development budgeting and projections
- [ ] Bootstrap resource allocator handles critical path and supply chains
- [ ] RSpec tests cover all major functionality
- [ ] No routing errors
- [ ] Consistent with existing AI manager patterns
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Resource allocation conflicts with existing economic systems
- ISRU calculations affect game balance
- Economic planning impacts player economy

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add app/services/ai_manager/resource_allocation_engine.rb app/services/ai_manager/isru_priority_calculator.rb app/services/ai_manager/economic_startup_planner.rb spec/services/ai_manager/resource_allocation_engine_spec.rb
git commit -m "feat: AI resource allocation engine for colony bootstrap

- Create comprehensive resource allocation engine with bootstrap logistics
- Implement ISRU priority calculator for local resource optimization
- Develop economic startup planner for development budgeting
- Enhance bootstrap resource allocator with critical path analysis
- Add comprehensive RSpec test coverage"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: [none]  
**Blocks**: [AI autonomous expansion, colony management]  
**Related tasks**: [AI site selection algorithm, strategic evaluator]  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `app/services/ai_manager/resource_allocation_engine.rb` — comprehensive allocation engine
- `app/services/ai_manager/isru_priority_calculator.rb` — ISRU optimization
- `app/services/ai_manager/economic_startup_planner.rb` — economic planning
- `app/services/ai_manager/bootstrap_resource_allocator.rb` — enhanced bootstrap logic
- `spec/services/ai_manager/resource_allocation_engine_spec.rb` — comprehensive tests

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]