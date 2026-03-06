# Implement SettlementPattern Progress Tracking Model

> **Agent Suitability Note:**
> This task is suitable for GPT-4.1. It involves model creation, checklist logic, and CRUD/database work. Assign to GPT-4.1 unless advanced cross-service integration is required.

## Overview
This task implements the SettlementPattern model to provide detailed progress tracking for the automated settlement construction process. While mission profiles exist for strategic operations and automated builds for manufacturing, this model specifically tracks the phased construction checklists for colony establishment. **Updated**: Checklists are location-specific and loaded from mission profile JSON files to support different construction patterns across celestial bodies.

## Codebase Analysis
### Existing Systems
- **Mission Profiles**: JSON-based strategic operation templates with location-specific patterns
- **Automated Builds**: Production jobs for manufacturing (production_job.rb)
- **Settlement Construction**: Basic AI-driven construction logic with location awareness
- **No Current Overlap**: SettlementPattern fills gap in detailed progress tracking for colony phases

### Enhancement Opportunity
- **Refinement**: Adds structured checklists to existing settlement construction with location context
- **Tracking**: Provides completion status and metrics for each construction phase by location
- **Monitoring**: Enables TerrainForge to display detailed settlement progress with environmental factors
- **Not Duplication**: Complements rather than replaces existing mission/build systems

## Phase 1: Location-Aware SettlementPattern Model Creation (1 week)
### Tasks
- Create SettlementPattern model with phase enum supporting location-specific phases
- Implement checklist structures loaded from mission profile JSON files
- Add progress tracking fields and completion dates with environmental context
- Create database migrations and relationships with celestial body support
- Build basic CRUD operations with location validation

### Success Criteria
- Model structure supports location-specific checklists from mission profiles
- Checklists properly store completion status with environmental factors
- Database schema supports all tracking fields across celestial bodies
- Model integrates with existing Settlement and location data

## Phase 2: Location-Specific Checklist Loading System (1 week)
### Tasks
- Implement checklist template loading from mission profile JSON files
- Create location-specific checklist validation and structure checking
- Add checklist inheritance system (global defaults + location overrides)
- Build checklist template caching for performance
- Create checklist update methods with location context

### Success Criteria
- Checklists load correctly from appropriate mission profile files
- Location-specific validation prevents invalid checklist structures
- Inheritance system allows global defaults with location customization
- Template caching improves performance without data staleness

## Phase 3: Luna Pattern Checklist Implementation (1 week)
### Tasks
- Implement Luna-specific precursor checklist (power_grid, resource_extraction, lavatube_prep)
- Add Luna industrial checklist (printing, ibeams, lavatube_sealing, pressurization)
- Create Luna orbital checklist (L1 depot, cislunar operations, fleet integration)
- Build Luna-specific validation and completion logic
- Add Luna environmental factors to checklist tracking

### Success Criteria
- Luna precursor checklist tracks subsurface preparation
- Industrial checklist monitors lavatube sealing and pressurization
- Orbital checklist tracks cislunar infrastructure development
- Environmental factors (radiation, thermal) included in tracking

## Phase 4: Mars Pattern Checklist Implementation (1 week)
### Tasks
- Implement Mars orbital establishment checklist (moons conversion, orbital infrastructure)
- Add Mars surface outposts checklist (habitat deployment, resource extraction)
- Create Mars resource infrastructure checklist (tank farms, mining operations)
- Build Mars advanced mining checklist (stockpiling, export operations)
- Add Mars environmental factors (dust storms, radiation, thin atmosphere)

### Success Criteria
- Mars orbital checklist prioritizes space-based infrastructure
- Surface operations checklist tracks outpost establishment
- Resource infrastructure monitors extraction and storage
- Environmental factors account for Mars-specific challenges

## Phase 5: Venus Pattern Checklist Implementation (1 week)
### Tasks
- Implement Venus orbital depot checklist (high-altitude station, radiation protection)
- Add Venus atmospheric harvesting checklist (gas extraction, processing)
- Create Venus cloud city checklist (altitude optimization, structural integrity)
- Build Venus foundry checklist (CNT production, materials processing)
- Add Venus environmental factors (extreme temperatures, corrosive atmosphere)

### Success Criteria
- Venus orbital checklist focuses on high-altitude operations
- Atmospheric harvesting tracks gas extraction efficiency
- Cloud city checklist monitors altitude and structural requirements
- Environmental factors account for Venus extreme conditions

## Phase 6: Generic Location Checklist Framework (1 week)
### Tasks
- Create extensible checklist framework for new celestial bodies
- Implement checklist validation for custom location patterns
- Add checklist performance metrics and completion analytics
- Build checklist comparison tools across locations
- Create checklist testing and validation framework

### Success Criteria
- New celestial bodies can define custom checklist patterns
- Checklist validation ensures structural integrity
- Performance metrics provide location-specific insights
- Framework supports future expansion without code changes

## Phase 7: Integration with Settlement Construction (1 week)
### Tasks
- Integrate SettlementPattern with location-aware settlement pattern logic
- Update AI Manager to use checklist tracking with location context
- Connect with TerrainForge display requirements for multi-location monitoring
- Add checklist-based progress reporting with environmental factors
- Create checklist update triggers with location-specific validation

### Success Criteria
- Settlement construction updates checklists automatically with location awareness
- TerrainForge displays checklist progress across celestial bodies
- AI Manager uses checklist status for location-appropriate decisions
- Progress reporting accurate and real-time with environmental context

## Technical Specifications

### Location-Aware SettlementPattern Model
```ruby
class SettlementPattern < ApplicationRecord
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  
  # Location-specific phase enums loaded from mission profiles
  enum current_phase: [:loading] # Dynamic enum based on location
  
  # JSON stores for location-specific checklists
  store :checklist_data, coder: JSON  # Complete checklist structure
  store :location_factors, coder: JSON # Environmental and location context
  
  validates :celestial_body, presence: true
  validate :checklist_matches_location_pattern
  
  def self.for_location(celestial_body)
    pattern_file = find_pattern_file(celestial_body)
    return default_pattern unless pattern_file
    
    JSON.parse(File.read(pattern_file))
  end
  
  def update_checklist_item(phase, item, complete: true, **data)
    checklist = checklist_data
    phase_key = "#{current_phase}_checklist"
    
    unless checklist[phase_key]
      checklist[phase_key] = {}
    end
    
    checklist[phase_key][item.to_s] = {
      complete: complete,
      completion_date: complete ? Time.current : nil,
      environmental_factors: location_factors
    }.merge(data)
    
    update(checklist_data: checklist)
  end
  
  def phase_complete?(phase)
    checklist = checklist_data["#{phase}_checklist"] || {}
    required_items = get_required_items_for_phase(phase)
    
    required_items.all? do |item| 
      checklist.dig(item.to_s, 'complete') && 
      environmental_constraints_met?(item, checklist[item.to_s])
    end
  end
  
  private
  
  def checklist_matches_location_pattern
    # Validate checklist structure against mission profile
  end
  
  def environmental_constraints_met?(item, item_data)
    # Check environmental factors for completion validity
  end
end
```

### Location-Specific Checklist Structures
```ruby
# Luna pattern loaded from mission profile
LUNA_CHECKLIST_TEMPLATE = {
  precursor_checklist: {
    'power_grid' => { complete: false, radiation_shielding: true },
    'resource_extraction' => { complete: false, subsurface_access: true },
    'lavatube_prep' => { complete: false, structural_integrity: 0.8 }
  },
  industrial_checklist: {
    'printing_operational' => { complete: false, production_rate: 0 },
    'ibeams_produced' => { count: 0, target: 100, material_strength: 'high' },
    'lavatube_sealed' => { complete: false, pressure_psi: 0, target_psi: 14.7 },
    'human_habitable' => { complete: false, radiation_levels: 'safe' }
  },
  orbital_checklist: {
    'l1_depot_complete' => { complete: false, capacity_tons: 0 },
    'cislunar_ops_active' => { complete: false, cycles_per_day: 0 }
  }
}

# Mars pattern with orbital-first approach
MARS_CHECKLIST_TEMPLATE = {
  orbital_checklist: {
    'moons_conversion' => { complete: false, infrastructure_type: 'orbital' },
    'orbital_depot' => { complete: false, capacity_tons: 0 }
  },
  surface_outposts_checklist: {
    'habitat_deployment' => { complete: false, dust_protection: true },
    'resource_extraction' => { complete: false, water_ice_access: true }
  },
  resource_infrastructure_checklist: {
    'tank_farms' => { complete: false, capacity_tons: 0 },
    'mining_operations' => { complete: false, ore_types: [] }
  },
  advanced_mining_checklist: {
    'stockpiling_ops' => { complete: false, export_capacity: 0 }
  }
}

# Venus pattern with atmospheric focus
VENUS_CHECKLIST_TEMPLATE = {
  orbital_depot_checklist: {
    'high_altitude_station' => { complete: false, altitude_km: 0 },
    'radiation_protection' => { complete: false, shielding_effectiveness: 0 }
  },
  atmospheric_harvesting_checklist: {
    'gas_extraction' => { complete: false, efficiency_percent: 0 },
    'processing_facility' => { complete: false, corrosion_resistance: true }
  },
  cloud_cities_checklist: {
    'altitude_optimization' => { complete: false, optimal_km: 50-60 },
    'structural_integrity' => { complete: false, wind_load_resistance: 'high' }
  },
  foundry_checklist: {
    'cnt_production' => { complete: false, output_tons_per_day: 0 }
  },
  industrial_checklist: {
    'materials_processing' => { complete: false, export_capacity: 0 }
  }
}
```

## Location-Specific Considerations
- **Luna**: Radiation shielding, thermal cycling, subsurface operations, vacuum conditions
- **Mars**: Dust deposition, water ice access, atmospheric pressure, orbital dependencies
- **Venus**: Temperature extremes, corrosive atmosphere, altitude optimization, pressure differentials
- **Generic**: Extensible framework for new celestial bodies with custom environmental factors

## Dependencies
- Settlement::BaseSettlement model with celestial body support
- Mission profile JSON files with location-specific patterns
- Settlement pattern logic implementation with location awareness
- AI Manager construction services with environmental factors
- TerrainForge display system with multi-location support

## Testing Requirements
- Checklist progression through all phases for each celestial body
- Completion status accuracy with environmental validation
- Phase transition validation with location constraints
- Integration with settlement construction across locations
- TerrainForge display of checklist data with location context

## Risk Mitigation
- Start with single settlement testing per celestial body
- Implement checklist validation against mission profiles
- Add rollback capability for incorrect updates with location recovery
- Comprehensive logging of checklist changes with environmental context

## Success Metrics
- 100% checklist accuracy for completed settlements across all locations
- Real-time progress tracking in TerrainForge with environmental factors
- AI Manager decisions informed by checklist status and location constraints
- Settlement establishment time optimized by 20% with location-aware tracking