# Implement TerrainForge Routes and Controllers

**ARCHITECTURAL CORRECTION**: TerrainForge routes and controllers must support Admin and Player Corporation modes within the Surface View, not a separate admin interface. Endpoints should enforce access controls based on user mode and corporation membership.

## Overview
This task implements the backend API endpoints and controller logic for the TerrainForge civilization layer within the Surface View. The routes provide mode-aware access to settlement data, construction projects, and AI management controls with appropriate access restrictions.

## Phase 1: Mode-Aware Routes Configuration (3 days)
### Tasks
- Add terrainforge routes to Surface View with mode parameters
- Implement resource routes for index and show actions with access controls
- Add member routes for project actions with mode validation
- Create collection routes for construction queue with corporation filtering
- Test route generation and path helpers with mode parameters

### Success Criteria
- Routes properly defined with mode support
- Path helpers work correctly with access controls
- Mode isolation maintained with corporation scoping
- No route conflicts with existing surface routes

## Phase 2: Controller Creation with Access Controls (1 week)
### Tasks
- Create SurfaceTerrainforgeController class with mode-aware methods
- Implement index action with settlement and project data loading filtered by access
- Build show action for individual settlement details with corporation restrictions
- Add project actions with validation, logging, and access constraints
- Implement priority controls with AI Manager integration for Admin mode

### Success Criteria
- Controller follows Rails conventions with access awareness
- Actions handle parameters correctly including mode filters
- Error handling implemented with access validation
- Authentication/authorization enforced with corporation-based permissions

## Phase 3: Data Loading Optimization with Access Controls (1 week)
### Tasks
- Optimize index action queries with proper includes and corporation indexing
- Implement efficient settlement data loading with access-based partitioning
- Add construction queue ordering and filtering by corporation and mode
- Create AI status data aggregation with access-appropriate metrics
- Build terrain data access for settlement views with mode-appropriate data sources

### Success Criteria
- Database queries optimized (N+1 prevention) with access-based query planning
- Data loading performance acceptable across multiple celestial bodies
- Memory usage controlled for large multi-location datasets
- Response times under 500ms with location filtering

## Phase 4: Override and Control Actions with Location Context (1 week)
### Tasks
- Implement project action logic with validation and access constraints
- Add action logging and audit trail with corporation context
- Build priority adjustment parameter validation for Admin mode
- Create AI Manager priority update integration with access controls
- Add confirmation and rollback mechanisms with access-aware recovery

### Success Criteria
- Actions properly validated with access constraints
- Actions logged for audit with corporation context
- Priority changes affect AI behavior appropriately for Admin mode
- Error recovery mechanisms in place with access-specific fallbacks

## Phase 5: API Response Formatting with Access Data (3 days)
### Tasks
- Create JSON response formatters for frontend consumption with access metadata
- Implement pagination for large settlement lists with corporation grouping
- Add filtering and sorting parameters including access-based options
- Build real-time update endpoints with mode-specific event channels
- Create API documentation with access parameter examples

### Success Criteria
- JSON responses match frontend expectations with access context
- Pagination works for large settlement lists with corporation boundaries
- Filtering and sorting functional with access-based criteria
- API documented and testable with mode scenarios

## Phase 6: Integration Testing with Access Scenarios (1 week)
### Tasks
- Test controller actions with various access-based scenarios
- Verify AI Manager integration works correctly with mode restrictions
- Test action functionality end-to-end with access constraints
- Validate priority adjustment effects for Admin mode
- Performance test with realistic multi-corporation data volumes

### Success Criteria
- All controller actions work correctly with access parameters
- Integration with AI Manager functional with mode restrictions
- Actions properly logged with access context
- Performance meets requirements for multi-corporation operations

## Technical Specifications

### Mode-Aware Routes Structure
```ruby
# Generated routes with access support:
GET    /surface/terrainforge?mode=:mode           # index with mode filter
GET    /surface/terrainforge/:id                  # show with access context
POST   /surface/terrainforge/:id/action           # project actions with access validation
PATCH  /surface/terrainforge/adjust_priorities    # Admin mode priorities
GET    /surface/terrainforge/construction_queue?mode=:mode  # queue with access filter
GET    /surface/terrainforge/ai_status            # AI status for Admin mode
GET    /surface/terrainforge/corporation_summary  # corporation-specific summary
```

### Access-Aware Controller Actions
```ruby
class SurfaceTerrainforgeController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_terrainforge_access
  before_action :set_mode_filter, only: [:index, :construction_queue]
  
  def index
    @settlements = policy_scope(Settlement)
      .includes(:active_projects, :corporation)
      .accessible_by(current_user)
      .order(:name)
    
    if admin_mode?
      @ai_status = AIManager::StatusReporter.current_status
      @megaprojects = ConstructionProject.megaprojects
    end
    
    @construction_queue = ConstructionProject.accessible_by(current_user)
      .active
      .includes(:settlement)
      .order(priority: :desc, estimated_completion: :asc)
      .limit(50)
      
    @corporation_summary = calculate_corporation_summary
  end
  
  def show
    @settlement = Settlement.includes(:corporation).find(params[:id])
    authorize @settlement
    
    @terrain_data = @settlement.celestial_body.geosphere.terrain_map_for_location(@settlement.location)
    @structures = @settlement.structures.includes(:construction_project)
    @active_projects = @settlement.construction_projects.accessible_by(current_user)
  end
  
  def project_action
    project = ConstructionProject.includes(:settlement).find(params[:id])
    authorize project
    
    # Validate action against access constraints
    unless can_perform_action?(project, params[:action])
      return render json: { success: false, errors: ['Action not permitted for your access level'] }, 
                   status: :forbidden
    end
    
    result = TerrainForgeActionService.new(
      project: project,
      user: current_user,
      action: params[:action],
      reason: params[:reason]
    ).execute
    
    if result.success?
      render json: { success: true, project: project.as_json(include: :settlement) }
    else
      render json: { success: false, errors: result.errors }, status: :unprocessable_entity
    end
  end
  
  def adjust_priorities
    return render json: { error: 'Admin access required' }, status: :forbidden unless admin_mode?
    
    priorities = params.require(:priorities).permit(
      :resource_security, :population_growth, :expansion_speed,
      :trade_network, :research_focus
    )
    
    result = AIManager::PriorityManager.update_priorities(priorities)
    
    if result.success?
      render json: { success: true, new_priorities: result.priorities }
    else
      render json: { success: false, errors: result.errors }, status: :unprocessable_entity
    end
  end
  
  def construction_queue
    projects = ConstructionProject.accessible_by(current_user)
      .active
      .includes(:settlement)
      .order(priority: :desc, estimated_completion: :asc)
    
    render json: projects.as_json(include: { settlement: { include: :corporation } })
  end
  
  def ai_status
    return render json: { error: 'Admin access required' }, status: :forbidden unless admin_mode?
    
    status = AIManager::StatusReporter.detailed_status
    render json: status
  end
  
  def corporation_summary
    summary = calculate_corporation_summary
    render json: summary
  end
  
  private
  
  def set_mode_filter
    @mode = params[:mode] || (admin_mode? ? 'admin' : 'player')
  end
  
  def admin_mode?
    current_user.admin? || session[:terrainforge_mode] == 'admin'
  end
  
  def calculate_corporation_summary
    if admin_mode?
      {
        total_settlements: Settlement.count,
        operational_settlements: Settlement.operational.count,
        construction_projects: ConstructionProject.active.count,
        corporations_active: Corporation.with_settlements.count
      }
    else
      {
        corporation: current_user.corporation.name,
        settlements: current_user.corporation.settlements.count,
        projects: ConstructionProject.where(corporation: current_user.corporation).active.count
      }
    end
  end
  
  def can_perform_action?(project, action)
    case action
    when 'override'
      admin_mode?
    when 'claim', 'build'
      project.corporation == current_user.corporation || project.restricted_to_dc == false
    else
      false
    end
  end
end
```

### Access-Aware Security Considerations
- Mode-based access with proper authorization and corporation permissions
- Audit logging for all actions with corporation context
- Input validation and sanitization with access-specific constraints
- Rate limiting for sensitive operations with corporation-based quotas
- CSRF protection for state-changing actions with access validation

## Mode-Specific API Features
- **Admin Mode**: Full system access, AI controls, megaproject management
- **Player Corporation Mode**: Corporation assets only, base/unit/road building, resource claiming
- **DC Base Access**: Temporary access for non-corporation players
- **Membership Requirements**: Corporation enrollment required for full access

## Testing Requirements
- Route accessibility and security with mode parameters
- Controller action responses for different access levels
- AI Manager integration with mode restrictions
- Action functionality with access constraints
- Priority adjustment effects for Admin mode
- Performance with large multi-corporation datasets

## Risk Mitigation
- Implement gradual rollout of new endpoints with access testing
- Add comprehensive error handling with access-specific fallbacks
- Create rollback mechanisms for failed operations with access recovery
- Monitor performance and add access-based caching as needed

## Success Metrics
- All routes respond correctly with proper data and access context
- AI Manager integration works seamlessly with mode restrictions
- Actions logged and auditable with corporation information
- Response times under 200ms for typical requests with access filtering
- System handles large settlement counts with corporation boundaries