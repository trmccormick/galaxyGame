# 2026-03-22-LOW-TASK-DOCS-AGENT-CLEANUP

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0x — Low priority documentation cleanup task
**Supervision Level**: Standard

## Context
docs/agent/ directory has accumulated old versioned files, misplaced assets, orphaned documents from previous sessions. New documentation system established with clean role-specific files.

## Problem Statement
Multiple .old versioned files cluttering docs/agent/ root. Several files at root belong in subdirectories. outputs/ folder contains misplaced files. completed/ folder at root should consolidate into tasks/completed/. RULES.md superseded by IMPLEMENTATION_AGENT_README.md. No tasks/session-handoffs/ folder exists.

**Expected**: Clean directory with only active files at root, old files in archive.

## Files Involved
### Primary Files — you will move/delete
| File | Purpose | Action |
|---|---|---|
| `docs/agent/ASSET_PROMPTS.md` | Misplaced file | Move to docs/agent/image-generation/ |
| `docs/agent/courier_network_plan.md` | Misplaced file | Move to docs/agent/planning/ |
| `docs/agent/CURRENT_WORK.md` | Old file | Move to docs/agent/archive/ |
| `docs/agent/RULES.md` | Superseded file | Move to docs/agent/archive/ |
| `docs/agent/TASK_PROTOCOL.md` | Protocol file | Move to docs/agent/rules/ |
| `docs/agent/completed/CONSTRUCTION_REFACTOR.md` | Completed task | Move to docs/agent/tasks/completed/ |
| `docs/agent/outputs/` | Misplaced folder | Disperse contents, remove folder |
| `docs/agent/gemni-chats/` | Old folder | Move to docs/agent/archive/ |

### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `docs/agent/tasks/session-handoffs/` | New folder | Create and consolidate session handoff files |

## Implementation Steps
1. **Move misplaced root files**: ASSET_PROMPTS.md, courier_network_plan.md, CURRENT_WORK.md to correct locations
2. **Archive superseded RULES.md**: Move to archive/
3. **Move TASK_PROTOCOL.md**: To rules/
4. **Consolidate completed/**: Move CONSTRUCTION_REFACTOR.md to tasks/completed/, remove completed/
5. **Disperse outputs/**: Move contents to correct locations, remove folder
6. **Archive gemni-chats/**: Move to archive/
7. **Create session-handoffs/**: Find and consolidate all session handoff files
8. **Verify structure**: Ensure clean directory structure

## Acceptance Criteria
- [ ] docs/agent/ root contains only 7 active files plus subdirectories
- [ ] No .old files anywhere in docs/agent/
- [ ] outputs/ folder no longer exists
- [ ] completed/ folder at root no longer exists
- [ ] gemni-chats/ folder moved to archive/
- [ ] TASK_PROTOCOL.md is in rules/
- [ ] CONSTRUCTION_REFACTOR.md is in tasks/completed/
- [ ] tasks/session-handoffs/ exists with all session handoff files

## Stop Conditions
- rmdir fails because directory not empty — report contents, don't delete unlisted files
- Uncertain about file destination — stop and ask

## Commit Instructions
```bash
git add -A docs/agent/
git commit -m "chore: docs/agent cleanup — archive old files, consolidate structure, add session-handoffs"
```