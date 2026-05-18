# Agent Documentation Cleanup

## Context
Legacy documentation files, outdated agent instructions, and duplicate/obsolete content present in docs/agent/ directory need cleanup.

## Problem
- Legacy and obsolete documentation files accumulating
- Outdated agent instructions and workflows
- Duplicate content across different files
- Archive directory may contain outdated information
- Documentation maintenance burden increasing

## Solution
Clean up docs/agent/ directory by identifying and removing/archiving non-essential legacy files.

## Files to Review
- `docs/agent/` - Entire directory structure
- `docs/agent/archive/` - Check for obsolete archived content
- `docs/agent/tasks/` - Verify task organization
- Various README and instruction files

## Implementation Steps
1. Audit all files in docs/agent/ for relevance and currency
2. Identify legacy/obsolete files using naming patterns (old, backup, obsolete, duplicate)
3. Review archive/ directory for files that can be permanently removed
4. Consolidate duplicate content where found
5. Update any references to removed files
6. Archive rather than delete important historical files
7. Update README files to reflect current structure

## Acceptance Criteria
- No old/backup/obsolete/duplicate files remaining
- Archive directory cleaned of truly obsolete content
- Documentation structure simplified and current
- No broken references to removed files
- README files updated to reflect cleanup

## Agent Assignment
0.33x - Documentation maintenance and cleanup specialist

## Priority
HIGH

## Stop Condition
Agent docs directory cleaned and organized

## Commit Message
chore: cleanup legacy agent docs and obsolete files</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/new_agent/tasks/backlog/2026-02/2026-02-11-HIGH-DOCUMENTATION-AGENT-CLEANUP.md