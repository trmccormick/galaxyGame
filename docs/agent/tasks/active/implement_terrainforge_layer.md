# Implement TerrainForge Layer for Admin AI Monitoring

## Overview
TerrainForge is the construction/building layer that sits below Surface View. It provides realistic industrial construction monitoring and control for the AI Manager's automated colony building system.

## Architecture Integration
- **Layer Position**: Civilization layer in terrain layering model (fastest timescale)
- **Dependencies**: Requires completed Surface View and AI Manager service integration
- **EventBus Integration**: Extends terrain event system for construction events

## Phase 1: Foundation (1 week)
### Tasks
- Create TerrainForge view component (`terrainforge_view.js`)
- Implement basic construction queue display
- Add route and navigation from admin dashboard
- Define ConstructionEvent JSON schema extension

### Success Criteria
- TerrainForge view loads and displays placeholder construction data
- Navigation integrated into admin celestial bodies interface
- EventBus schema documented for construction events

## Phase 2: AI Monitoring (1 week)
### Tasks
- Implement AI Manager construction decision monitoring
- Add global AI priority adjustment controls
- Create construction progress visualization
- Build override interface for specific AI decisions

### Success Criteria
- Real-time display of AI Manager's construction activities
- Functional priority sliders affecting AI behavior
- Progress bars and status indicators for all colonies
- Override buttons with confirmation dialogs

## Phase 3: Advanced Features (1 week)
### Tasks
- Add construction metrics and analytics dashboard
- Implement construction event persistence
- Create player construction delegation interface (foundation)
- Add construction queue management tools

### Success Criteria
- Comprehensive monitoring dashboard with charts/metrics
- Construction events saved to database
- Basic player interface for custom base construction
- Queue prioritization and cancellation features

## Technical Specifications

### ConstructionEvent Schema
```json
{
  "event": "ConstructionEvent",
  "type": "building|mining|infrastructure",
  "location": {"x": 45, "y": 22, "celestial_body_id": 123},
  "ai_manager_decision": true,
  "priority": "high|medium|low",
  "estimated_completion": "2026-03-15T10:00:00Z",
  "resources_required": {"steel": 100, "concrete": 50},
  "timestamp": "2026-03-02T12:00:00Z"
}
```

### AI Priority Controls
- Global sliders: Exploration vs. Construction vs. Resource Gathering
- Colony-specific overrides
- Emergency pause/resume functionality

### Monitoring Metrics
- Construction completion rates
- Resource utilization efficiency
- AI decision success rates
- Colony expansion progress

## Dependencies
- `complete_admin_dashboard_navigation_integration.md` (Phase 1)
- `ai_manager_service_integration.md` (Phase 2)
- `implement_ai_manager_operational_escalation.md` (Phase 2)
- Dynamic terrain system roadmap (Phase 3)

## Testing
- Admin can monitor all AI construction activities
- Priority adjustments affect AI behavior within 5 minutes
- Construction events appear in real-time
- Override functionality works without breaking AI autonomy

## Future Extensions
- Player custom base construction tools
- Advanced AI training data from admin overrides
- Multi-colony construction coordination
- Construction blueprint system

## Files to Create/Modify
- `app/views/admin/celestial_bodies/terrainforge.html.erb`
- `app/assets/javascripts/terrainforge_view.js`
- `app/controllers/admin/terrainforge_controller.rb`
- `app/models/construction_event.rb`
- EventBus schema updates
- Admin dashboard navigation updates

## Risk Mitigation
- Start with read-only monitoring before adding controls
- Implement gradual AI priority changes to avoid disruption
- Add comprehensive logging for all override actions
- Test with single colony before multi-colony rollout

## Success Metrics
- Admin can view all active constructions across colonies
- AI priority adjustments show measurable behavior changes
- Construction progress updates in real-time
- System handles 100+ simultaneous constructions without performance issues