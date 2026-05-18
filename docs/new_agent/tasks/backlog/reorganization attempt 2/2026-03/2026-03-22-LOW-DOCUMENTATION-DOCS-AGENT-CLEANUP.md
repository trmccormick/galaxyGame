# 2026-03-22-LOW-DOCUMENTATION-DOCS-AGENT-CLEANUP

**Agent:** GPT-4.1 (0.33x)
**Priority:** LOW
**Type:** DOCUMENTATION
**Status:** BACKLOG

## Context
The docs/agent/ directory has accumulated old versioned files, misplaced assets, and orphaned documents from previous sessions. A new documentation system has been established with clean role-specific files.

## Problem
Multiple .old versioned files cluttering root of docs/agent/, several files sitting at root that belong in subdirectories, outputs/ folder contains misplaced files, completed/ folder at root should be consolidated, RULES.md is superseded, no tasks/session-handoffs/ folder exists.

## Files
- docs/agent/ASSET_PROMPTS.md
- docs/agent/courier_network_plan.md
- docs/agent/CURRENT_WORK.md
- docs/agent/RULES.md
- docs/agent/TASK_PROTOCOL.md
- docs/agent/completed/CONSTRUCTION_REFACTOR.md
- docs/agent/outputs/PHASE_2_SPRITE_SHEET_PROMPT.md
- docs/agent/outputs/CODE_REVIEW_STRATEGY_SELECTOR.md
- docs/agent/outputs/galaxy_regional_atlax.json
- docs/agent/gemni-chats/

## Steps
1. Move misplaced root-level files to appropriate subdirectories
2. Archive superseded RULES.md
3. Move TASK_PROTOCOL.md to rules/
4. Consolidate completed/ into tasks/completed/
5. Disperse outputs/ contents and remove folder
6. Archive gemni-chats/
7. Create session-handoffs/ folder and consolidate session handoff files
8. Verify final directory structure

## Acceptance Criteria
- docs/agent/ root contains only active files plus subdirectories
- No .old files anywhere in docs/agent/
- outputs/ folder no longer exists
- completed/ folder at root no longer exists
- gemni-chats/ folder moved to archive/
- TASK_PROTOCOL.md is in rules/
- CONSTRUCTION_REFACTOR.md is in tasks/completed/
- tasks/session-handoffs/ exists with all session handoff files

## Stop Condition
- rmdir fails because directory is not empty
- Uncertain about file destination

## Commit Instructions
```
git add -A docs/agent/
git commit -m "chore: docs/agent cleanup — archive old files, consolidate structure, add session-handoffs"
```