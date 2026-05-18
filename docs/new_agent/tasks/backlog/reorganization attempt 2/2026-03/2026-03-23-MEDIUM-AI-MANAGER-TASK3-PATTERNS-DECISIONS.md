# 2026-03-23-MEDIUM-AI-MANAGER-TASK3-PATTERNS-DECISIONS

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for AI manager patterns and decisions fixes
**Supervision Level**: 🔴 Watched carefully

## Context
Fix patterns page non-functional JavaScript alert() buttons with real form submission using existing planner route. Load actual pattern names from controller instead of hardcoded HTML options. Apply Task 1 layout classes to decisions page, fix stat cards to show real counts from @decisions.

## Problem Statement
Patterns page has non-functional JavaScript alert() buttons. Decisions page lacks Task 1 layout classes and stat cards show hardcoded data.

**Expected**: Patterns page buttons link to planner route, decisions page uses Task 1 layout and shows real decision counts.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/controllers/admin/ai_manager_controller.rb` | AI controller | Update patterns action with available_patterns array |
| `app/views/admin/ai_manager/patterns.html.erb` | Patterns view | Replace JS alerts with planner links, apply Task 1 layout |
| `app/views/admin/ai_manager/decisions.html.erb` | Decisions view | Apply Task 1 layout, wire stat cards to real @decisions data |

## Implementation Steps
1. **Update patterns controller**: Add @available_patterns array with pattern objects (id, label)
2. **Replace patterns view**: Use Task 1 layout, replace alert() buttons with links to planner route, display pattern test runner and types reference
3. **Update decisions view**: Apply Task 1 layout structure, wire stat cards to show real counts from @decisions (total, types, celestial bodies, most recent)

## Acceptance Criteria
- [ ] Patterns page buttons link to planner (no alert() popups)
- [ ] No JavaScript errors in console
- [ ] Decisions page stat cards show real counts
- [ ] Decision table renders real data or empty state message

## Stop Conditions
- Building real pattern management system
- Adding pattern activation/deactivation backend
- Controller changes beyond patterns action

## Commit Instructions
```bash
git add app/controllers/admin/ai_manager_controller.rb
git add app/views/admin/ai_manager/patterns.html.erb
git add app/views/admin/ai_manager/decisions.html.erb
git commit -m "feat: AI manager patterns decisions — fix patterns page alerts and decisions layout"
```