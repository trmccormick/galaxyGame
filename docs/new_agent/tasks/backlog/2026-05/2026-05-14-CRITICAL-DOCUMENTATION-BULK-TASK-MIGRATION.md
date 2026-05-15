# TASK: 2026-05-14-CRITICAL-DOCUMENTATION-BULK-TASK-MIGRATION
**Status**: BACKLOG  
**Priority**: CRITICAL  
**Type**: documentation  
**Created**: 2026-05-14  
**Last Updated**: 2026-05-14  

---

## Agent Assignment

**Assigned To**: GPT-4.1 (0x)  
**Why This Agent**: Bulk processing of repetitive task migration work, can handle autonomous execution  
**Supervision Level**: autonomous OK  

**Supervision Legend**:
- 🔴 Watched carefully = 0x/0.25x agents
- 🟡 Standard = 0.33x agents  
- 🟢 Autonomous OK = 1x agents

---

## Context
We need to migrate remaining tasks from legacy folders to the new agent backlog structure. This involves processing 29 remaining validated tasks and ~150 archive tasks, comparing them to codebase, and creating new task files using the current template.

**Relevant Architecture Docs** — read before starting:
- `docs/new_agent/tasks/migration.md` — [migration tracker and process]
- `docs/new_agent/TASK_TEMPLATE.md` — [template for new task files]

---

## Problem Statement
Remaining tasks in docs/agent/tasks/validated (29 files) and docs/agent/archive/backlog_april_2026 (~150 files) need to be migrated to docs/new_agent/tasks/backlog/ with proper folder structure (YYYY-MM folders) and template formatting.

**Current behavior**: Tasks exist in legacy format  
**Expected behavior**: All tasks migrated to new structure with proper validation  

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `docs/new_agent/tasks/migration.md` | Migration tracker | update progress |
| `docs/new_agent/tasks/backlog/YYYY-MM/` | New task folders | create as needed |
| `docs/agent/tasks/validated/*` | Source validated tasks | read and process |
| `docs/agent/archive/backlog_april_2026/*` | Source archive tasks | read and process |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/new_agent/TASK_TEMPLATE.md` | Template format | use for new tasks |

---

## Implementation Steps

### Step 1 — Process remaining validated tasks (29 files)
For each file in docs/agent/tasks/validated/:
- Read the task file
- If incomplete, search docs/agent/archive/backlog_april_2026/ for matching task
- Compare to current codebase to verify relevance
- Create new task file in docs/new_agent/tasks/backlog/2026-02/ using template
- Update migration.md with progress

### Step 2 — Process archive tasks (~150 files)
Group archive tasks by creation date (YYYY-MM):
- Create folders: 2026-02/, 2026-03/, 2026-04/, 2026-05/
- For each task, validate against codebase
- Skip if obsolete or not needed (document in migration.md)
- Create new task files using template

### Step 3 — Update migration tracker
After each batch of 5 tasks:
- Update docs/new_agent/tasks/migration.md with progress
- Mark completed tasks and any skips with reasons

### Step 4 — Final verification
- Ensure all folders created with proper naming
- Verify migration.md is complete
- No source files moved or deleted

### Step 5 — Run validation
DO NOT INFER THE COMMAND. Run this exact string from the host terminal:

Bash
ls -la docs/new_agent/tasks/backlog/2026-*/ | wc -l
Expected result: Count of migrated task files

---

## Acceptance Criteria
- [ ] All 29 validated tasks processed and migrated or documented as skipped
- [ ] Archive tasks grouped by date folders and migrated
- [ ] migration.md updated with complete progress tracking
- [ ] No source files moved from legacy folders
- [ ] New task files follow template format
- [ ] Folders named correctly (2026-02, 2026-03, etc.)
- [ ] Isolation run: migration.md accurately reflects all work
- [ ] No regressions in existing structure
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Task content requires architectural decisions
- Codebase investigation reveals complex dependencies
- Template format needs modification
- Migration tracker becomes inconsistent

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add docs/new_agent/tasks/
git commit -m "docs: bulk migrate remaining tasks to new backlog structure

- Migrated 29 validated tasks to 2026-02 folder
- Processed archive tasks into date-based folders
- Updated migration tracker with progress
- All tasks now follow current template format"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: [none]  
**Blocks**: [task management system completion]  
**Related tasks**: [individual task migrations]  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `docs/new_agent/tasks/backlog/` — added date folders and task files
- `docs/new_agent/tasks/migration.md` — updated with complete progress

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]