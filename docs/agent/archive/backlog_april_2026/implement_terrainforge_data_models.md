# Implement TerrainForge Data Models

**ARCHITECTURAL CORRECTION**: TerrainForge data models must support corporation ownership and access controls, not location-specific variations. Models should enforce Admin vs Player Corporation mode restrictions, with DC bases providing temporary access for non-corporation players.

## Overview
This task focuses on creating the data models for TerrainForge civilization layer, ensuring proper integration with corporation ownership, access controls, and mode-specific restrictions within the Surface View.

## Phase 1: Corporation-Aware Model Analysis and Planning (3 days)
### Tasks
- Review existing Settlement model for corporation ownership support
- Analyze access control requirements for Admin vs Player modes
- Determine corporation membership and DC base access patterns
- Plan database schema for corporation restrictions and permissions
- Identify integration points with corporation membership system

### Success Criteria
- Clear plan for corporation-based access controls
- Schema design supports mode-specific restrictions
- Integration strategy documented for corporation system
- Migration plan outlined with access control compatibility

## Phase 2: Settlement Model with Corporation Support (1 week)
### Tasks
- Add corporation ownership to Settlement model
- Implement access control fields for mode restrictions
- Add DC base temporary access support
- Create corporation membership validation
- Update validations and callbacks for access controls

### Success Criteria
- Settlement model supports corporation ownership
- Access controls work for Admin/Player modes
- DC bases provide temporary access appropriately
- Corporation membership enforced properly

## Phase 3: ConstructionProject Model with Access Controls (1 week)
### Tasks
- Create ConstructionProject model with corporation restrictions
- Implement project_type enums with surface operations only
- Add access control fields for Admin/Player modes
- Create megaproject restrictions (DC/AI only)
- Build corporation-based resource and priority controls

### Success Criteria
- ConstructionProject model enforces access controls
- Project types limited to surface operations
- Admin/Player mode restrictions implemented
- Megaprojects properly restricted to DC/AI
- Create constraints analysis fields specific to location and environment
- Build ai_reasoning and admin_override tracking with location context
- Add environmental_factor adjustments for different celestial bodies

### Success Criteria
- Model matches proposed specification with location support
- Enums and validations functional across celestial bodies
- Resource tracking works with local extraction and import requirements
- AI reasoning storage includes location-specific factors

## Phase 4: Database Integration with Access Controls (1 week)
### Tasks
- Create database migrations for corporation ownership and access controls
- Update existing data with corporation assignments
- Implement data seeding for test settlements with corporation ownership
- Add indexes for performance with corporation-based queries
- Create foreign key constraints and access control partitioning

### Success Criteria
- Migrations run without errors with corporation support
- Existing data preserved with corporation assignments
- New settlements can be created with proper ownership
- Queries perform well with corporation-based access controls

## Phase 5: API and Service Integration with Access Controls (1 week)
### Tasks
- Update AI Manager to respect corporation ownership and access restrictions
- Integrate with corporation membership services
- Add construction progress tracking with access validations
- Implement resource requirement calculations with corporation boundaries
- Create settlement status update mechanisms with access control criteria

### Success Criteria
- AI Manager respects corporation ownership restrictions
- Progress updates work with access control validation
- Resource calculations account for corporation boundaries
- Settlement status reflects access-appropriate operational criteria

## Technical Specifications

### Corporation-Aware Settlement Model
```ruby
class Settlement::BaseSettlement < ApplicationRecord
  # Existing fields...
  enum construction_phase: [:precursor, :industrial, :surface]
  enum owner_type: [:dc, :corporation]
  
  belongs_to :corporation, optional: true  # nil for DC bases
  has_many :construction_projects
  
  # Access control fields
  # access_requirements: JSON with membership requirements
  # restricted_operations: JSON with mode-specific restrictions
  
  # Validations
  validates :owner_type, presence: true
  validate :corporation_membership_required
  
  def corporation_membership_required
    return if owner_type == 'dc'  # DC bases allow temporary access
    
    # For corporation-owned settlements, validate membership
    # This would be checked at access time, not model level
  end
end
```

### Access-Controlled ConstructionProject Model
```ruby
class ConstructionProject < ApplicationRecord
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  belongs_to :corporation, optional: true
  
  # Surface operations only (current scope)
  enum project_type: {
    # Base construction
    seal_lavatube: 0, build_habitat: 1, install_power: 2, construct_pad: 3,
    # Unit and infrastructure
    deploy_extractor: 4, build_road: 5, place_unit: 6, claim_resource: 7,
    # Megaprojects (DC/AI only)
    worldhouse: 8, terraform: 9
  }
  
  enum phase: [:planning, :resource_gathering, :construction, :completion]
  enum priority: [:low, :normal, :high, :critical]

  # Access control
  # restricted_to_dc: boolean (for megaprojects)
  # corporation_restricted: boolean
  
  # Scopes for access control
  scope :accessible_by, ->(user) { 
    if user.admin?
      all
    elsif user.corporation_member?
      where(corporation: user.corporation).or(where(restricted_to_dc: false))
    else
      where(restricted_to_dc: false, corporation_restricted: false)  # DC bases only
    end
  }
  scope :surface_projects, -> { where.not(project_type: [:worldhouse, :terraform]) }
  scope :megaprojects, -> { where(project_type: [:worldhouse, :terraform]) }
end
```

## Corporation-Based Model Considerations
- **DC Bases**: Provide temporary access for non-corporation players
- **Corporation Settlements**: Full TerrainForge access for members
- **Admin Mode**: Complete system access for administrators
- **Player Mode**: Restricted to corporation assets and territories

## Dependencies
- Existing BaseSettlement model must support corporation ownership
- Corporation membership system for access validation
- Admin/Player mode authentication
- Access control system for mode restrictions

## Testing
- Existing settlement tests pass with corporation support
- New construction project creation works with access controls
- Corporation membership enforced appropriately
- Access restrictions work for Admin/Player modes
- Performance acceptable with corporation-based queries

## Risk Mitigation
- Create access control layer separate from core models
- Backup database before migrations with ownership preservation
- Test with small dataset first for each corporation type
- Rollback plan for failed migrations with access control recovery

## Success Metrics
- All proposed model fields implemented with corporation support
- No duplication with existing models while supporting access controls
- ConstructionProject properly belongs to settlement with corporation restrictions
- Corporation membership integration functional
- Access controls work end-to-end with mode-specific restrictions