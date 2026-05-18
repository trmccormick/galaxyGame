# 2026-04-04-HIGH-ARCHITECTURE-DOCS AGENT CLEANUP

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# TASK: docs/agent Directory Cleanup
**Status**: BACKLOG  
**Priority**: LOW  
**Type**: documentation  
**Created**: 2026-03-22

---

## Original Content

# TASK: docs/agent Directory Cleanup
**Status**: BACKLOG  
**Priority**: LOW  
**Type**: documentation  
**Created**: 2026-03-22  
**Last Updated**: 2026-03-22  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Pure file operations — moves, deletes, no code changes, fully specified  
**Supervision Level**: Standard  

> ⚠️ This task involves only file moves and deletions. No application code changes.
> No RSpec runs needed. No docker exec needed.
> All operations run on HOST directly using standard shell commands.

---

## Context
The `docs/agent/` directory has accumulated old versioned files, misplaced assets,
and orphaned documents from previous sessions. A new documentation system has been
established with clean role-specific files. This task clears the old files, moves
misplaced ones to correct locations, and creates the session-handoffs folder.

**No architectural decisions required. Follow the file map below exactly.**

---

## Problem Statement
- Multiple `.old` versioned files cluttering root of `docs/agent/`
- Several files sitting at root that belong in subdirectories
- `outputs/` folder contains misplaced files, should be removed
- `completed/` folder at root should be consolidated into `tasks/completed/`
- `RULES.md` is superseded by `IMPLEMENTATION_AGENT_README.md`
- No `tasks/session-handoffs/` folder exists yet — needs creating
- Existing session handoff files are scattered, need consolidating

**Current behavior**: Cluttered directory, agents may read wrong/old files  
**Expected behavior**: Clean directory, only active files at root, old files in archive

---

## Files Involved

### No code files — host filesystem operations only
All operations are `mv`, `mkdir`, and `rm` commands on the host.
Working directory: project root (not inside docs/agent/).

---

## Implementation Steps

> Follow these steps exactly in order.
> Verify each step before continuing.
> If a file listed does not exist, note it and continue — do not stop.

### Step 1 — Move misplaced root-level files

```bash
mv docs/agent/ASSET_PROMPTS.md docs/agent/image-generation/
mv docs/agent/courier_network_plan.md docs/agent/planning/
mv docs/agent/CURRENT_WORK.md docs/agent/archive/
```

### Step 2 — Archive superseded RULES.md
RULES.md is superseded by IMPLEMENTATION_AGENT_README.md.

```bash
mv docs/agent/RULES.md docs/agent/archive/
```

### Step 3 — Move TASK_PROTOCOL.md to rules/
TASK_PROTOCOL.md is a planner reference. Belongs in rules/.

```bash
mv docs/agent/TASK_PROTOCOL.md docs/agent/rules/
```

### Step 4 — Consolidate completed/ into tasks/completed/

```bash
mv docs/agent/completed/CONSTRUCTION_REFACTOR.md docs/agent/tasks/completed/
rmdir docs/agent/completed/
```

### Step 5 — Disperse outputs/ contents and remove folder

```bash
mv docs/agent/outputs/PHASE_2_SPRITE_SHEET_PROMPT.md docs/agent/image-generation/
mv docs/agent/outputs/CODE_REVIEW_STRATEGY_SELECTOR.md docs/agent/archive/
mv docs/agent/outputs/galaxy_regional_atlax.json docs/agent/archive/
rmdir docs/agent/outputs/
```

If `rmdir` fails because the folder is not empty, run:
```bash
ls docs/agent/outputs/
```
Report the remaining contents — do not delete anything not listed above.

### Step 6 — Archive gemni-chats/

```bash
mv docs/agent/gemni-chats docs/agent/archive/
```

### Step 7 — Create session-handoffs/ folder

```bash
mkdir -p docs/agent/tasks/session-handoffs
```

Find all existing session handoff files wherever they currently live:

```bash
find docs/agent -name "session_handoff_*.md" -not -path "*/session-handoffs/*"
find docs/agent -name "*handoff*" -not -path "*/session-handoffs/*"
```

Move each file found to the new folder. Example:
```bash
# Adjust paths based on find output above
mv docs/agent/session_handoff_march13.md docs/agent/tasks/session-handoffs/
```

> There are at least 3 known session handoff files from previous sessions.
> Move all of them regardless of where they currently live.
> If find returns nothing, note it in the completion report.

### Step 8 — Verify final structure

```bash
ls -la docs/agent/
ls -la docs/agent/rules/
ls -la docs/agent/tasks/
ls -la docs/agent/tasks/session-handoffs/
ls -la docs/agent/tasks/completed/
ls -la docs/agent/image-generation/
ls -la docs/agent/archive/
```

**Expected root contents after cleanup:**
```
README.md
AGENT_ROUTING.md
CURRENT_STATUS.md
IMPLEMENTATION_AGENT_README.md
SESSION_STRATEGIST.md
TASK_TEMPLATE.md
WORKFLOW_README.md
archive/
image-generation/
planning/
reference/
rules/
tasks/
```

**Expected rules/ contents:**
```
ENVIRONMENT_BOUNDARIES.md
TASK_PROTOCOL.md        <- moved here in Step 3
```

**Expected tasks/ contents:**
```
active/
backlog/
completed/
critical/
session-handoffs/      <- created in Step 7
```

**Expected tasks/completed/ contents:**
```
CONSTRUCTION_REFACTOR.md   <- moved here in Step 4
[any existing completed tasks]
```

**Expected tasks/session-handoffs/ contents:**
```
session_handoff_march13.md
[any other session handoff files found in Step 7]
```

---

## Synthesis Report Format
Not applicable — this task has no diagnosis step.
If any file operation fails, stop and report:
```
FAILED OPERATION
Command: [exact command that failed]
Error: [exact error message]
Remaining steps: [list steps not yet completed]
```

---

## Testing Sequence
No RSpec required. Verification is the ls commands in Step 8.

---

## Acceptance Criteria
- [ ] `docs/agent/` root contains only the 7 active files plus subdirectories
- [ ] No `.old` files anywhere in `docs/agent/`
- [ ] `outputs/` folder no longer exists
- [ ] `completed/` folder at root no longer exists
- [ ] `gemni-chats/` folder moved to `archive/`
- [ ] `TASK_PROTOCOL.md` is in `rules/`
- [ ] `CONSTRUCTION_REFACTOR.md` is in `tasks/completed/`
- [ ] `tasks/session-handoffs/` exists
- [ ] All session handoff files are in `tasks/session-handoffs/`
- [ ] `galaxy_regional_atlax.json` is in `archive/`

---

## Stop Conditions
- If `rmdir` fails because directory is not empty — stop, report contents, do not delete
- Do not delete any file not explicitly listed in this task
- If uncertain about a file's destination — stop and ask

---

## Commit Instructions
Run on **host** after all steps verified:

```bash
# Verify only docs/agent/ paths appear before committing
git status

git add -A docs/agent/
git commit -m "chore: docs/agent cleanup — archive old files, consolidate structure, add session-handoffs"
git push
```

> `git add -A` is permitted here because this commit contains only
> file moves within `docs/agent/` — no application code is touched.
> Always verify with `git status` first.

---

## Documentation
No doc changes needed — this task IS the doc cleanup.

---

## Dependencies
**Blocked by**: None  
**Blocks**: None  
**Related tasks**: None  

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:  
**Completion date**:  
**Final structure verified**: yes/no  

### What was changed
[list of moves performed]

### Files not found (expected but missing)
[any files listed in steps that did not exist]

### Issues discovered
[anything unexpected]

### Follow-up tasks needed
[anything flagged during cleanup]

