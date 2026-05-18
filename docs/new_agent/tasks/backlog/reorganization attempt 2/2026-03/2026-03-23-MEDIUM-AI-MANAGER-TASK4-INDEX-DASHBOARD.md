# 2026-03-23-MEDIUM-AI-MANAGER-TASK4-INDEX-DASHBOARD

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for AI manager index dashboard fixes
**Supervision Level**: 🔴 Watched carefully

## Context
Fix AI Manager index dashboard layout and missing features. Controller already has real data (@system_status, @active_missions, @performance_metrics, @system_alerts, @quick_actions). Issues are wrong stylesheet, old layout classes, missing system alerts display, missing Testing link in sidebar nav.

## Problem Statement
index.html.erb uses wrong stylesheet (celestial_bodies) instead of ai_manager, uses old layout classes instead of Task 1 layout classes, missing system alerts display, missing Testing link in sidebar nav.

**Expected**: Index dashboard uses Task 1 layout classes, displays system alerts, includes Testing link in sidebar, uses correct stylesheet.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/views/admin/ai_manager/index.html.erb` | Index dashboard view | Apply Task 1 layout classes, add system alerts display, add Testing link in sidebar |

## Implementation Steps
1. **Replace entire view**: Use Task 1 layout structure with ai-manager-layout, ai-manager-sidebar, ai-manager-header, ai-manager-main
2. **Add system alerts section**: Display @system_alerts if any exist
3. **Update sidebar nav**: Include Testing link in sidebar navigation
4. **Wire real data**: Use existing controller data (@system_status, @active_missions, @performance_metrics, @quick_actions)

## Acceptance Criteria
- [ ] Index dashboard uses Task 1 layout classes
- [ ] System alerts display when failed/stalled missions exist
- [ ] Testing link included in sidebar navigation
- [ ] Real mission counts in metric cards
- [ ] Active missions table shows real data or empty state
- [ ] AI Services Status shows real service health

## Stop Conditions
- Controller changes or adding new data
- Changes to existing data structures

## Commit Instructions
```bash
git add app/views/admin/ai_manager/index.html.erb
git commit -m "feat: AI manager index dashboard — apply Task 1 layout and add missing features"
```