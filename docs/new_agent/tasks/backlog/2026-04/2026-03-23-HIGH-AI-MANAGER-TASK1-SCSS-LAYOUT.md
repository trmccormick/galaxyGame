# 2026-03-23-HIGH-AI-MANAGER-TASK1-SCSS-LAYOUT

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority feature for AI manager SCSS layout standardization
**Supervision Level**: 🔴 Watched carefully

## Context
Create dedicated _ai_manager.scss file with neon blue theme and standardize ALL AI Manager views to use consistent 2-pane layout. Remove all 3-pane layouts where 3rd pane has no content.

## Problem Statement
No dedicated AI Manager SCSS file with neon blue theme. AI Manager views don't use consistent 2-pane layout. 3-pane layouts exist where 3rd pane has no content.

**Expected**: Dedicated _ai_manager.scss with neon blue theme, all AI Manager views using consistent 2-pane layout, no 3-pane layouts with empty content.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/assets/stylesheets/admin/_ai_manager.scss` | AI Manager SCSS | Create neon blue theme and layout classes |

### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/assets/stylesheets/admin/dashboard.scss` | Dashboard SCSS | Add @import 'ai_manager' |
| `app/views/admin/ai_manager/index.html.erb` | Index view | Apply 2-pane layout structure |
| `app/views/admin/ai_manager/missions.html.erb` | Missions view | Apply 2-pane layout structure |
| `app/views/admin/ai_manager/decisions.html.erb` | Decisions view | Apply 2-pane layout structure |
| `app/views/admin/ai_manager/planner.html.erb` | Planner view | Apply 2-pane layout structure |
| `app/views/admin/ai_manager/patterns.html.erb` | Patterns view | Apply 2-pane layout structure |
| `app/views/admin/ai_manager/performance.html.erb` | Performance view | Apply 2-pane layout structure |
| `app/views/admin/ai_manager/testing/index.html.erb` | Testing index | Apply 2-pane layout structure |
| `app/views/admin/ai_manager/testing/performance.html.erb` | Testing performance | Apply 2-pane layout structure |
| `app/views/admin/ai_manager/testing/validation.html.erb` | Testing validation | Apply 2-pane layout structure |

## Implementation Steps
1. **Create _ai_manager.scss**: With neon blue theme, layout classes (ai-manager-layout, ai-manager-sidebar, ai-manager-header, ai-manager-main), cards, metrics grid, tables, buttons, badges, alerts, placeholder
2. **Add SCSS import**: Add @import 'ai_manager' to dashboard.scss
3. **Standardize layouts**: Apply 2-pane wrapper structure to all AI Manager views, replace existing sidebar/nav/header HTML with standardized version, keep existing content inside main area
4. **Update page titles**: Use appropriate titles for each page (GALAXY GAME — AI MANAGER, AI MANAGER — MISSIONS, etc.)

## Acceptance Criteria
- [ ] app/assets/stylesheets/admin/_ai_manager.scss exists with neon blue theme
- [ ] All AI Manager views use consistent 2-pane layout structure
- [ ] No 3-pane layouts with empty content
- [ ] Dark blue gradient background, blue-bordered sidebar, active nav link highlighted
- [ ] No green theme remnants

## Stop Conditions
- Changes to Ruby code, controller logic, or instance variables
- Removal of existing ERB content inside main content area
- Creation of .css files instead of SCSS

## Commit Instructions
```bash
git add app/assets/stylesheets/admin/_ai_manager.scss
git add app/assets/stylesheets/admin/dashboard.scss
git add app/views/admin/ai_manager/index.html.erb
git add app/views/admin/ai_manager/missions.html.erb
git add app/views/admin/ai_manager/decisions.html.erb
git add app/views/admin/ai_manager/planner.html.erb
git add app/views/admin/ai_manager/patterns.html.erb
git add app/views/admin/ai_manager/performance.html.erb
git add app/views/admin/ai_manager/testing/index.html.erb
git add app/views/admin/ai_manager/testing/performance.html.erb
git add app/views/admin/ai_manager/testing/validation.html.erb
git commit -m "feat: AI manager SCSS layout — create neon blue theme and standardize 2-pane layout"
```