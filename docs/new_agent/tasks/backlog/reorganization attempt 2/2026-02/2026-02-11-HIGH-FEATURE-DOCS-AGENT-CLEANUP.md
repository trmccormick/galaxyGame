# TASK: Docs Agent Cleanup
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: feature  
**Created**: 2026-02-11

---

## Problem Statement
Legacy documentation files, outdated agent instructions, and duplicate/obsolete content present in docs/agent/.

## Goals
- Identify and list all legacy/obsolete files
- Remove or archive non-essential files
- Commit: "chore: cleanup legacy agent docs and obsolete files"

## Acceptance Criteria
- [ ] All legacy/obsolete files identified and listed
- [ ] Non-essential files removed or archived
- [ ] Feature is committed with correct message

## Implementation Notes
- List files matching old/backup/obsolete/duplicate patterns
- Remove or archive as appropriate
- Validate with file review

## Diagnostic/Debugging
- ls docs/agent/ | grep -i 'old\|backup\|obsolete\|duplicate'

## Related Files/Paths
- docs/agent/

## References
- Synthesis Report (2026-02-11)

---

