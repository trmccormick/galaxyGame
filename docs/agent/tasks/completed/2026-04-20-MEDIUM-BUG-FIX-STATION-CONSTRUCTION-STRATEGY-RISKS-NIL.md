# TASK: station_construction_strategy assess_implementation_risks returns nil
**Status**: ACTIVE  
**Priority**: MEDIUM  
**Type**: bug-fix  
**Created**: 2026-04-20  
**Last Updated**: 2026-04-20  

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Single-method bug, explicit spec failure, mechanical fix  
**Supervision Level**: 🔴 Watched carefully  

---

## Context
The AI Manager's station construction strategy service is responsible for evaluating risks in construction plans. The method assess_implementation_risks is expected to return an array of hashes, each with a :risk key. The spec fails when this method returns nil or an empty array, causing .first to be nil and .have_key(:risk) to fail.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/WORKFLOW_README.md` — workflow, spec/AI Manager conventions
- `docs/agent/TASK_TEMPLATE.md` — task file format and acceptance criteria

---

## Problem Statement

**Error output** (from spec/services/ai_manager/station_construction_strategy_spec.rb:305):
```
Failure/Error: expect(technical_risks.first).to have_key(:risk)

NoMethodError:
  undefined method `have_key' for nil:NilClass
```

**Current behavior**: assess_implementation_risks returns nil or an empty array, so technical_risks.first is nil.  
**Expected behavior**: assess_implementation_risks returns an array of hashes, each with a :risk key.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/station_construction_strategy.rb` | Station construction risk assessment | `def assess_implementation_risks` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `spec/services/ai_manager/station_construction_strategy_spec.rb` | Tests risk assessment output |

### Migration (if needed)
- [x] No migration needed

---

## Implementation Steps

### Step 1 — Run isolation
```bash
docker exec -it web bash -c "unset DATABASE_URL RAILS_ENV=test bundle exec rspec spec/services/ai_manager/station_construction_strategy_spec.rb:305"
```

### Step 2 — Check method
```bash
grep -A20 -B5 "def assess_implementation_risks" app/services/ai_manager/station_construction_strategy.rb
```

### Step 3 — Synthesis Report
Produce a Synthesis Report before applying any fix.

---

## Synthesis Report Format
Before applying any fix, produce a report in this format and **stop**:

```
THE FAILURE
Spec: [file:line]
Error: [exact message]
Expected: [value]
Got: [value]

ROOT CAUSE
[one paragraph]

PROPOSED FIX
[exact code change]

RISK
[any shared code affected]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Isolation run** — spec file only:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/station_construction_strategy_spec.rb:305'
```

2. **Related specs** — verify no regressions in nearby area:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
```

---

## Acceptance Criteria
- [ ] assess_implementation_risks returns array of hashes with :risk key
- [ ] Isolation run: 0 failures
- [ ] No regressions in spec/services/ai_manager

---

## Stop Conditions — escalate to user immediately if:
- Fix causes new failures in specs you did not touch
- Same failure persists after two attempts — report exact error, do not attempt a third fix
- Root cause is in a shared concern, base class, or factory used across many specs
- A database migration is needed that wasn't anticipated
- Any architectural decision is required

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add app/services/ai_manager/station_construction_strategy.rb
# and any other files changed

git commit -m "fix: station_construction_strategy_spec assess_implementation_risks nil return"
git push
```

---

## Documentation
- [x] No doc changes needed

---

## Dependencies
**Blocked by**: none  
**Blocks**: none  
**Related tasks**: none  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `[file]` — [description of change]

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]
