--- ARCHIVED: STOP CONDITION TRIGGERED — ESCALATION REQUIRED ---  
Original task requested removal of stale base_craft.rb backup files (.new, .new2, .new3). **STOP condition met during audit** — all three backup files contain unique methods NOT present in current version. This file is preserved for historical reference only.

### What Was Discovered (Blocks Original Task)
- ⛔ `base_craft.rb.new` contains: crew_count(), mass() with inventory calculation, can_process_volatiles?, enhanced has_available_docking_port?  
- ⛔ `base_craft.rb.new2` contains: Alternative include pattern (Housing concern), different has_available_docking_port? logic path
- ⛔ `base_craft.rb.new3` contains: physical_properties() method, mass alias to total_mass, status attribute definition

### What Was Extracted as New Task(s) (Actionable Work Remaining)
📄 `docs/new_agent/projects/galaxy_game/tasks/backlog/phase5+/2026-06-15-MEDIUM-REFACTOR-BASE-CRAFT-BACKUP-METHOD-MERGE.md`  
New task created to document the four unique methods found and require human decision on merge vs. discard before backup files can be safely deleted.

### Implementation Evidence (For Reference)
See docs/new_agent/projects/galaxy_game/research/BACKLOG_TRIAGE_APRIL_2026_SESSION.md — File #9 section:
- All three backup files dated Feb 20, 2026 (before current version from May 27, 2026)  
- Unique methods suggest alternative implementations that may have been discarded during refactoring
- Human review required to determine if any valuable logic should be recovered before deletion

---

# TASK: Remove Stale base_craft.rb Backup Files
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single command, no reasoning needed
**Supervision Level**: 🔴 Watched carefully

---

## Context
Previous editing sessions left behind stale backup files alongside 
`app/models/craft/base_craft.rb`. These files are not loaded by Rails 
but clutter the codebase and could cause confusion for future agents.

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

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:  
**Completion date**:  
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned