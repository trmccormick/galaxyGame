# 2026-03-30-LOW-CHORE-REMOVE-STALE-BASE-CRAFT-FILES

**Agent Assignment**: 0.33x (documentation/bugfix tasks)  
**Estimated Time**: 1 hour  
**Priority**: LOW  
**Status**: BACKLOG  

## Context
Previous editing sessions left behind stale backup files alongside `app/models/craft/base_craft.rb`. These files are not loaded by Rails but clutter the codebase and could cause confusion for future agents.

## Problem
Three stale files exist that should not be in the codebase:
- `app/models/craft/base_craft.rb.new`
- `app/models/craft/base_craft.rb.new2`
- `app/models/craft/base_craft.rb.new3`

**Current behavior**: Files exist, clutter codebase  
**Expected behavior**: Only `app/models/craft/base_craft.rb` exists

## Steps
1. **Verify files exist**
   ```bash
   ls -la app/models/craft/base_craft.rb*
   ```

2. **Diff against current base_craft.rb**
   ```bash
   diff app/models/craft/base_craft.rb app/models/craft/base_craft.rb.new
   diff app/models/craft/base_craft.rb app/models/craft/base_craft.rb.new2
   diff app/models/craft/base_craft.rb app/models/craft/base_craft.rb.new3
   ```
   If any diff shows content NOT in current `base_craft.rb` — STOP and escalate.

3. **Remove files (only if diffs are clean)**
   Run on host, not in container:
   ```bash
   rm app/models/craft/base_craft.rb.new
   rm app/models/craft/base_craft.rb.new2
   rm app/models/craft/base_craft.rb.new3
   ```

4. **Commit**
   ```bash
   git add -u app/models/craft/
   git commit -m "chore: remove stale base_craft.rb backup files"
   git push
   ```

## Acceptance Criteria
- [ ] Only `base_craft.rb` remains in `app/models/craft/`
- [ ] No unique content lost from backup files
- [ ] Committed and pushed

## Stop Condition
Escalate to user immediately if:
- Any diff shows content not present in current `base_craft.rb`
- Any other unexpected `.new` files found in the codebase

## Commit Message
`chore: remove stale base_craft.rb backup files

- Remove base_craft.rb.new, .new2, .new3 backup files
- Clean up codebase clutter from previous editing sessions
- Ensure only active base_craft.rb remains`