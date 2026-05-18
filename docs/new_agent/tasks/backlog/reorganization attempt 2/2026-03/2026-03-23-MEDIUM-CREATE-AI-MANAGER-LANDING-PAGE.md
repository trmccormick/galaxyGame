# 2026-03-23-MEDIUM-CREATE-AI-MANAGER-LANDING-PAGE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for creating AI manager landing page
**Supervision Level**: 🔴 Watched carefully

## Context
AI Manager lacks proper landing/index page. Users navigate directly to subsections without overview of AI system status. Need to create /admin/ai_manager index page with AI system status, active missions, performance metrics, quick actions, system alerts.

## Problem Statement
AI Manager has various sections but no proper landing page. Users access subsections directly without system overview. Missing dashboard for AI health and status.

**Expected**: /admin/ai_manager shows AI system overview with status, active missions, performance metrics, quick actions, system alerts.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/views/admin/ai_manager/index.html.erb` | AI manager index view | Create landing page with system overview and navigation |

### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/controllers/admin/ai_manager_controller.rb` | AI manager controller | Add index action with @ai_status, @active_missions, @performance_metrics, @system_alerts |
| `config/routes.rb` | Routes configuration | Add get 'ai_manager' route to admin namespace |
| `app/views/admin/dashboard/index.html.erb` | Admin dashboard | Update navigation to link to /admin/ai_manager instead of /admin/ai_manager/missions |

## Implementation Steps
1. **Add index controller action**: Create index action loading AI status, active missions, performance metrics, system alerts
2. **Create index view**: Build landing page with AI system status, active missions overview, performance metrics, quick actions, system alerts
3. **Add route**: Add get 'ai_manager' route to admin namespace
4. **Update navigation**: Modify admin dashboard to link to /admin/ai_manager, add breadcrumb navigation within AI Manager sections

## Acceptance Criteria
- [ ] /admin/ai_manager shows AI system overview
- [ ] Clear navigation to all AI subsections
- [ ] Real-time status indicators
- [ ] Consistent with admin interface design
- [ ] No broken navigation links

## Stop Conditions
- Breaking existing AI manager routes
- Changes beyond index page creation and navigation updates

## Commit Instructions
```bash
git add app/controllers/admin/ai_manager_controller.rb
git add app/views/admin/ai_manager/index.html.erb
git add config/routes.rb
git add app/views/admin/dashboard/index.html.erb
git commit -m "feat: Create AI manager landing page — add index route and overview dashboard"
```