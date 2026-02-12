# Create AI Manager Landing Page

## Problem Description
The AI Manager has various sections (missions, planner, decisions, patterns, performance) but lacks a proper landing/index page. Users navigate directly to subsections without an overview of AI system status.

## Current State
- AI Manager routes exist: `/admin/ai_manager/missions`, `/admin/ai_manager/planner`, etc.
- No `/admin/ai_manager` index page
- Users access subsections directly without system overview
- Missing dashboard for AI health and status

## Required Implementation

### 1. **Create AI Manager Index Page**
Build `galaxy_game/app/views/admin/ai_manager/index.html.erb` with:
- **AI System Status**: Overall health, running state, last activity
- **Active Missions**: Current AI missions with status overview
- **Performance Metrics**: Response times, decision quality, success rates
- **Quick Actions**: Links to planner, decisions, patterns, performance
- **System Alerts**: AI errors, escalation events, performance issues

### 2. **Add Index Controller Action**
Update `Admin::AiManagerController`:
```ruby
def index
  @ai_status = check_ai_system_status
  @active_missions = Mission.where(status: :active).limit(5)
  @performance_metrics = load_performance_metrics
  @system_alerts = check_system_alerts
end
```

### 3. **Add Route**
Update `galaxy_game/config/routes.rb`:
```ruby
namespace :admin do
  get 'ai_manager', to: 'ai_manager#index'
  # existing ai_manager routes...
end
```

### 4. **Navigation Integration**
- Update admin dashboard to link to `/admin/ai_manager` instead of `/admin/ai_manager/missions`
- Add breadcrumb navigation within AI Manager sections
- Ensure consistent navigation flow

## Implementation Notes
- Follow admin interface design patterns
- Include real-time status updates where possible
- Add quick access to most-used AI functions
- Maintain SimEarth aesthetic

## Files to Create/Modify
- `galaxy_game/app/controllers/admin/ai_manager_controller.rb` (add index action)
- `galaxy_game/app/views/admin/ai_manager/index.html.erb` (new)
- `galaxy_game/config/routes.rb` (add index route)
- `galaxy_game/app/views/admin/dashboard/index.html.erb` (update navigation)

## Acceptance Criteria
- `/admin/ai_manager` shows AI system overview
- Clear navigation to all AI subsections
- Real-time status indicators
- Consistent with admin interface design
- No broken navigation links

## Benefits
- Provides AI system overview and health monitoring
- Better navigation flow for AI management
- Centralized access to AI functions
- Improved admin user experience

## Priority
Medium - Completes AI Manager interface

## Estimated Effort
2-3 hours (controller + view + navigation updates)