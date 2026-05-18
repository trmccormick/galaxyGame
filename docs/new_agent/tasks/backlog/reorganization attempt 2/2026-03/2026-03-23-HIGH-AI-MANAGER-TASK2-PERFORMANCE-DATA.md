# 2026-03-23-HIGH-AI-MANAGER-TASK2-PERFORMANCE-DATA

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority feature for AI manager performance data wiring
**Supervision Level**: 🔴 Watched carefully

## Context
Replace all hardcoded placeholder data in performance.html.erb with real data from database. Update controller performance action to pass real mission data. Remove non-functional UI controls.

## Problem Statement
performance.html.erb contains hardcoded placeholder data. Controller performance action has TODO comments. Non-functional UI controls exist.

**Expected**: Performance page shows real mission data from database, controller passes real metrics, no non-functional controls.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/controllers/admin/ai_manager_controller.rb` | AI controller | Update performance action with real data queries |
| `app/views/admin/ai_manager/performance.html.erb` | Performance view | Replace hardcoded content with real data display |

## Implementation Steps
1. **Update controller**: Replace performance action with real Mission data queries for success_rate, average_timeline, resource_efficiency, active/completed/failed/total missions, recent_missions, ai_services status
2. **Replace view content**: Use Task 1 layout classes, display real metrics in ai-metrics-grid, show recent missions table, display AI services health
3. **Remove non-functional controls**: Ensure no broken UI elements remain

## Acceptance Criteria
- [ ] Performance page shows real numbers from database (not 0% or --)
- [ ] Mission table displays real missions from database
- [ ] Controller performance action loads actual Mission data
- [ ] No non-functional UI controls

## Stop Conditions
- Model changes or database schema modifications
- Changes outside performance action and view

## Commit Instructions
```bash
git add app/controllers/admin/ai_manager_controller.rb
git add app/views/admin/ai_manager/performance.html.erb
git commit -m "feat: AI manager performance data — wire performance page to real mission data"
```