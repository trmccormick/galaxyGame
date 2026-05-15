# TASK: Remove Stale base_craft.rb Backup Files
**Status**: BACKLOG
**Priority**: LOW
**Type**: chore
**Created**: 2026-03-30
**Last Updated**: 2026-03-30

---

## Agent Assignment
**Assigned To**: GPT-4.1 0.33x
**Why This Agent**: Single command, no reasoning needed
**Supervision Level**: 🔴 Watched carefully

---

## Context
Previous editing sessions left behind stale backup files alongside `app/models/craft/base_craft.rb`. These files are not loaded by Rails but clutter the codebase and could cause confusion for future agents.

---

## Problem Statement
Three stale files exist that should not be in the codebase:
- `app/models/craft/base_craft.rb.new`
- `app/models/craft/base_craft.rb.new2`
- `app/models/craft/base_craft.rb.new3`

**Current behavior**: Files exist, clutter codebase  
**Expected behavior**: Only `app/models/craft/base_craft.rb` exists

---

## Implementation Steps

### Step 1 — Verify files exist
```bash
ls -la app/models/craft/base_craft.rb*
```

### Step 2 — Diff against current base_craft.rb
```bash
diff app/models/craft/base_craft.rb app/models/craft/base_craft.rb.new
diff app/models/craft/base_craft.rb app/models/craft/base_craft.rb.new2
diff app/models/craft/base_craft.rb app/models/craft/base_craft.rb.new3
```
If any diff shows content NOT in current `base_craft.rb` — STOP and escalate.

### Step 3 — Remove files (only if diffs are clean)
Run on host, not in container:
```bash
rm app/models/craft/base_craft.rb.new
rm app/models/craft/base_craft.rb.new2
rm app/models/craft/base_craft.rb.new3
```

### Step 4 — Commit
```bash
git add -u app/models/craft/
git commit -m "chore: remove stale base_craft.rb backup files"
git push
```

---

## Acceptance Criteria
- [ ] Only `base_craft.rb` remains in `app/models/craft/`
- [ ] No unique content lost from backup files
- [ ] Committed and pushed

---

## Stop Conditions — escalate to user immediately if:
- Any diff shows content not present in current `base_craft.rb`
- Any other unexpected `.new` files found in the codebase

---

## Dependencies
**Blocked by**: none  
**Blocks**: none  
**Related tasks**: `2026-03-30-HIGH-BUG-FIX-BLUEPRINT-PORTS-REMOVE-FALLBACK.md`

---

## Commit Instructions
**Commit message format**: `chore: remove stale base_craft.rb backup files`

**Files to commit**:
- `app/models/craft/base_craft.rb` (staged deletions)

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:  
**Completion date**:  
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned