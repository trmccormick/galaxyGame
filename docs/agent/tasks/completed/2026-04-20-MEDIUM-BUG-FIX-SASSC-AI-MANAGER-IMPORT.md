# TASK: SassC ai_manager import error in feature spec
**Status**: ACTIVE  
**Priority**: MEDIUM  
**Type**: bug-fix  
**Created**: 2026-04-20  
**Last Updated**: 2026-04-20  

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Asset pipeline bug, single file, mechanical fix  
**Supervision Level**: 🔴 Watched carefully  

---

## Context
The feature spec for terrestrial planets fails due to a SassC::SyntaxError when compiling SCSS assets. The error is triggered by an @import 'ai_manager'; statement in app/assets/stylesheets/admin/dashboard.scss. The asset pipeline cannot find ai_manager.scss. This breaks feature specs that require admin dashboard assets.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/WORKFLOW_README.md` — workflow, spec/asset pipeline conventions
- `docs/agent/TASK_TEMPLATE.md` — task file format and acceptance criteria

---

## Problem Statement
Feature spec fails due to missing SCSS import.

**Error output** (from spec/features/terrestrial_planets_feature_spec.rb:4):
```
SassC::SyntaxError: File to import not found: ai_manager
  on line 5 of app/assets/stylesheets/admin/dashboard.scss
>> @import 'ai_manager';
```

**Current behavior**: Feature spec fails with SassC::SyntaxError on missing import.  
**Expected behavior**: Feature spec passes; asset pipeline finds all imports or import is removed.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/assets/stylesheets/admin/dashboard.scss` | Admin dashboard styles | `@import 'ai_manager'` line ~5 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/assets/stylesheets/` | Check for ai_manager.scss presence |

### Migration (if needed)
- [x] No migration needed

---

## Implementation Steps

### Step 1 — Confirm missing file
Check for ai_manager.scss:
```bash
ls -la app/assets/stylesheets/ai_manager*
```

### Step 2 — Run isolation
```bash
docker exec -it web bash -c "unset DATABASE_URL RAILS_ENV=test bundle exec rspec spec/features/terrestrial_planets_feature_spec.rb"
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
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/features/terrestrial_planets_feature_spec.rb'
```

2. **Related specs** — verify no regressions in nearby area:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/features/'
```

---

## Acceptance Criteria
- [ ] Feature spec passes with 0 failures
- [ ] No regressions in spec/features
- [ ] No asset pipeline errors

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
git add app/assets/stylesheets/admin/dashboard.scss
# or git add app/assets/stylesheets/ai_manager.scss if created
# or both if both are changed

git commit -m "fix: terrestrial_planets_feature SassC ai_manager import"
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
