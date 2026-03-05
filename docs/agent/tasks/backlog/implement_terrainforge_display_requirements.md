# Implement TerrainForge Display Requirements

**ARCHITECTURAL CORRECTION**: TerrainForge is NOT a separate admin monitoring interface. It is the Civilization Layer interaction mode within the existing Surface View, supporting both Admin and Player Corporation modes with appropriate access controls and display restrictions.

## Overview
This task focuses on implementing the UI components and data structures required for the TerrainForge civilization layer within the Surface View, supporting both Admin and Player Corporation interaction modes with appropriate display requirements and access controls.

## Phase 1: Mode-Aware Data Models and Backend (1 week)
### Tasks
- Create Settlement model with corporation ownership and access controls
- Implement ConstructionProject model with progress tracking and corporation restrictions
- Add AI Priority settings for Admin mode controls
- Create database migrations with corporation and access control support
- Build API endpoints for mode-specific data retrieval

### Success Criteria
- Models support both Admin and Player Corporation modes
- Database schema enforces access controls and corporation boundaries
- API endpoints return appropriate data based on user mode and permissions
- Models integrate with corporation membership system

## Phase 2: Admin Mode Display Components (1 week)
### Tasks
- Build overview panel for Admin mode with full system visibility
- Implement construction status breakdown for all settlements
- Add megaproject monitoring (Worldhouse, terraforming)
- Create real-time data updates for Admin controls

### Success Criteria
- Admin mode displays complete system overview
- Status breakdown shows all construction activities
- Megaprojects visible and controllable
- Data refreshes automatically for Admin users

## Phase 3: Player Corporation Mode Display Components (1 week)
### Tasks
- Create corporation-specific construction queue view
- Implement progress tracking for corporation projects
- Add resource management within corporation boundaries
- Build worker allocation visualization for corporation assets

### Success Criteria
- Corporation projects displayed with restrictions
- Progress updates for owned assets only
- Resources managed within corporation limits
- Worker allocation visible for corporation control
- Critical path items flagged for attention with interplanetary dependencies

## Phase 4: Colony Detail View with Environmental Context (1 week)
### Tasks
## Phase 4: Colony/Base Detail Views (1 week)
### Tasks
- Build detailed settlement information panels
- Implement construction phase indicators
- Create completed structures and active projects lists
- Add resource stockpile and worker count displays
- Build supply chain status monitoring

### Success Criteria
- Settlement details show appropriate information based on mode
- Construction phases accurately reflected
- Resource and worker data current
- Supply chain status visible within access limits

## Technical Specifications

## Technical Specifications

### Mode-Aware Data Structures
```ruby
# Settlement model with corporation ownership
class Settlement < ApplicationRecord
  belongs_to :corporation, optional: true  # nil for DC bases
  has_many :construction_projects
  enum construction_phase: [:precursor, :industrial, :surface]
  enum status: [:operational, :under_construction, :planning, :critical_issues]
  
  # Access control fields
  # owner_type: 'dc' | 'corporation'
  # access_requirements: JSON with membership requirements
end

# ConstructionProject model with corporation restrictions
class ConstructionProject < ApplicationRecord
  belongs_to :settlement
  belongs_to :corporation, optional: true
  
  enum project_type: {
    # Surface operations (current scope)
    seal_lavatube: 0, build_habitat: 1, install_power: 2, construct_pad: 3,
    deploy_extractor: 4, build_road: 5, place_unit: 6, claim_resource: 7,
    # Megaprojects (DC/AI only)
    worldhouse: 8, terraform: 9
  }
  
  enum priority: [:low, :medium, :high]
  
  # Access control
  # restricted_to_dc: boolean (megaprojects)
  # corporation_restricted: boolean
end
```

### Mode-Aware API Endpoints
- GET /surface/terrainforge/overview?mode=:mode - Settlement overview based on access
- GET /surface/terrainforge/construction_queue?mode=:mode - Projects visible to user
- GET /surface/settlements/:id - Settlement details with access controls
- PUT /surface/terrainforge/ai_priorities - Admin mode priority controls
- POST /surface/terrainforge/projects/:id/action - Mode-appropriate project actions

## UI Components with Mode Support
- OverviewPanel.vue - Statistics dashboard with mode-specific data
- ConstructionQueue.vue - Projects view with access restrictions
- SettlementDetail.vue - Detailed view with corporation boundaries
- PriorityControls.vue - Admin-only AI adjustment controls
- ProjectActionModal.vue - Mode-appropriate action interface
- AccessControl.vue - Corporation membership and permission checks

## Mode-Specific Display Requirements
- **Admin Mode**: Full system visibility, AI controls, megaproject access
- **Player Corporation Mode**: Corporation assets only, base/unit/road building, resource claiming
- **DC Base Access**: Temporary access for non-corporation players
- **Membership Requirements**: Corporation enrollment required for TerrainForge

## Testing Requirements
- Display components render correctly for each mode
- Access controls prevent unauthorized actions
- Admin controls affect AI behavior appropriately
- Corporation restrictions enforced properly
- Performance acceptable with large settlement counts

## Risk Mitigation
- Implement access control caching for performance
- Add corporation membership validation
- Use optimistic updates for user actions
- Comprehensive error handling for permission failures

## Success Metrics
- Users can access appropriate TerrainForge features based on mode
- Admin controls provide effective AI management
- Corporation restrictions prevent unauthorized access
- System maintains <2 second response times for all views