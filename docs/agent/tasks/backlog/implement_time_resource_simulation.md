# Implement Time & Resource Simulation System

**ARCHITECTURAL CORRECTION**: Time and resource simulation must support corporation-based access controls and mode-specific restrictions. Simulation applies to surface operations only (current scope), with orbital infrastructure as future scope.

> **Agent Suitability Note:**
> This task is ideal for GPT-4.1. It requires structured model/service work, config file management, and simulation logic. Assign to GPT-4.1 unless complex multi-agent coordination is needed.

## Overview
This task implements the comprehensive time and resource simulation system for construction projects within TerrainForge. The system provides realistic duration estimates, resource consumption tracking, progress simulation, and supply chain logistics with corporation-based access controls.

## Phase 1: Duration System with Access Controls (1 week)
### Tasks
- Create PROJECT_DURATIONS configuration for surface operations
- Implement duration calculation based on project type and environmental factors
- Add corporation-based access validation for duration estimates
- Create duration estimation service with mode awareness
- Integrate with ConstructionProject model and access controls

### Success Criteria
- All surface project types have appropriate durations
- Duration calculations account for environmental factors
- Access controls prevent unauthorized duration queries
- Duration service provides accurate estimates with restrictions

## Phase 2: Resource Consumption Tracking with Corporation Boundaries (1 week)
### Tasks
- Implement RESOURCE_REQUIREMENTS configuration for surface operations
- Create resource consumption calculation methods with corporation restrictions
- Add resource availability checking within corporation territories
- Build resource reservation system with corporation supply chains
- Integrate with inventory management and corporation logistics

### Success Criteria
- All construction projects have resource requirements
- Resource consumption respects corporation boundaries
- Availability checking prevents over-commitment within corporations
- Inventory integration works with corporation logistics

## Phase 3: Progress Simulation Engine with Access Validation (2 weeks)
### Tasks
- Implement simulateConstructionProgress function with environmental factors
- Add corporation access validation for progress updates
- Create progress update mechanisms with real-time adjustments
- Build completion detection logic with access-appropriate notifications
- Add progress persistence and recovery across environmental events

### Success Criteria
- Progress simulation accounts for location-specific factors
- Daily progress updates work correctly across environments
- Completion detection triggers appropriately
### Success Criteria
- Progress data persists across sessions with access controls
- Environmental factors applied within corporation boundaries

## Phase 4: Supply Chain Simulation within Corporation Territories (2 weeks)
### Tasks
- Implement calculateSupplyChainLoss function with terrain factors
- Add distance and terrain loss calculations within corporation areas
- Create cargo fragility modifiers for surface transport
- Build supply chain optimization within corporation territories
- Integrate with corporation logistics planning

### Success Criteria
- Loss rates accurately calculated for surface transport
- Terrain and distance modifiers applied within territories
- Supply chain optimization reduces losses within corporation
- Logistics integration provides reliable delivery estimates

## Phase 5: Environmental Impact Simulation with Access Controls (1 week)
### Tasks
- Implement environmental disruption simulation (dust storms, radiation events)
- Add construction delay calculations for environmental factors
- Create resource degradation modeling with corporation restrictions
- Build equipment failure rate adjustments by environment
- Integrate environmental monitoring with access-appropriate progress tracking

### Success Criteria
- Environmental disruptions properly delay construction within access
- Resource degradation affects project timelines for authorized users
- Equipment failure rates reflect environmental conditions
- Environmental monitoring integrates with simulation for valid users

## Phase 6: Integration and Monitoring with Mode Support (1 week)
### Tasks
- Integrate simulation with TerrainForge display modes
- Add real-time progress monitoring with access context
- Create simulation controls for testing different scenarios
- Build performance metrics collection by corporation
- Add simulation logging and debugging with access data

### Success Criteria
- TerrainForge shows accurate progress and resource data by mode
- Real-time monitoring works without performance impact
- Simulation controls allow testing different environmental scenarios
- Comprehensive logging aids troubleshooting with access context

## Technical Specifications

## Technical Specifications

### Project Duration Configuration with Access Controls
```ruby
PROJECT_DURATIONS = {
  # Surface operations only (current scope)
  seal_lavatube_small: { min_days: 90, max_days: 180, environmental_factor: 1.0 },
  build_power_grid: { min_days: 14, max_days: 30, environmental_factor: 0.9 },
  build_surface_outpost: { min_days: 60, max_days: 120, environmental_factor: 1.2 },
  deploy_resource_extractors: { min_days: 30, max_days: 60, environmental_factor: 1.1 },
  build_habitat: { min_days: 45, max_days: 90, environmental_factor: 1.0 },
  construct_landing_pad: { min_days: 10, max_days: 20, environmental_factor: 0.8 },
  # Megaprojects (DC/AI only)
  worldhouse: { min_days: 1000, max_days: 2000, environmental_factor: 2.0 },
  terraform: { min_days: 5000, max_days: 10000, environmental_factor: 3.0 }
}.freeze
```

### Resource Requirements with Corporation Restrictions
```ruby
RESOURCE_REQUIREMENTS = {
  seal_lavatube: {
    concrete: 5000, steel_ibeams: 500, panels: 2000,
    airlocks: 2, life_support: 1, power: 2000, workers: 50,
    restricted_to_dc: false  # Available to corporations
  },
  build_habitat: {
    concrete: 3000, steel_ibeams: 300, panels: 1500,
    airlocks: 1, life_support: 1, power: 1000, workers: 25,
    restricted_to_dc: false
  },
  worldhouse: {
    exotic_materials: 100000, energy_cores: 500, ai_processors: 1000,
    workers: 10000, restricted_to_dc: true  # DC/AI only
  }
}.freeze
```

### Access-Controlled Progress Simulation Service
```ruby
class ConstructionProgressSimulator
  ENVIRONMENTAL_FACTORS = {
    default: {
      temperature_stability: 0.95,
      radiation_exposure: 0.90,
      dust_interference: 0.98,
      gravity_efficiency: 1.0
    },
    mars: {
      temperature_stability: 0.85,
      radiation_exposure: 0.80,
      dust_storms: 0.75,
      gravity_efficiency: 0.95
    },
    venus: {
      temperature_extremes: 0.70,
      atmospheric_corrosion: 0.80,
      pressure_differentials: 0.85,
      gravity_efficiency: 0.90
    }
  }.freeze

      gravity_efficiency: 0.95
    }
  }.freeze

  def simulate_progress(project, elapsed_days, environmental_factors = {})
    base_progress = elapsed_days.to_f / project.estimated_duration
    
    effective_progress = base_progress
    
    environmental_factors.each_value { |factor| effective_progress *= factor }
    
    [1.0, effective_progress].min
  end
end
```

### Corporation-Aware Supply Chain Loss Calculator
```ruby
class SupplyChainLossCalculator
  BASE_LOSS_RATES = {
    corporation_territory: 0.01,    # 1% per 100km within corporation
    inter_corporation: 0.05,        # 5% for cross-corporation transport
    dc_base_access: 0.02            # 2% for DC base temporary access
  }.freeze
  
  ENVIRONMENTAL_MODIFIERS = {
    dust_storms: 1.3, radiation: 1.1, temperature: 1.2,
    corrosion: 1.5, thermal_cycling: 1.1
  }.freeze

  def calculate_loss(origin, destination, cargo_type, transport_method, corporation_context)
    distance = calculate_distance(origin, destination)
    base_rate = BASE_LOSS_RATES[transport_method] || 0.01
    
    base_loss = (distance / 100.0) * base_rate
    
    env_modifier = environmental_modifier(origin, destination)
    fragility_modifier = cargo_fragility(cargo_type)
    corporation_modifier = corporation_modifier(corporation_context)
    
    total_loss = base_loss * env_modifier * fragility_modifier * corporation_modifier
    
    [0.50, total_loss].min  # Cap at 50%
  end
  
  def corporation_modifier(context)
    case context
    when :same_corporation
      0.8  # Better logistics within corporation
    when :dc_base
      1.0  # Standard for DC bases
    else
      1.2  # Higher loss for cross-corporation
    end
  end
end
```

## Mode-Specific Simulation Factors
- **Admin Mode**: Full access to all simulation data, megaproject visibility
- **Player Corporation Mode**: Restricted to corporation assets, surface operations only
- **DC Base Access**: Temporary access for non-corporation players
- **Environmental Factors**: Applied universally but with access controls

## Testing Requirements
- Duration calculations for all project types with access validation
- Resource consumption accuracy within corporation boundaries
- Progress simulation with environmental factors and access controls
- Supply chain loss calculations within corporation territories
- Integration testing with settlement construction and mode restrictions

## Risk Mitigation
- Start with simplified simulation, add complexity gradually
- Implement progress validation to prevent unrealistic advancement
- Add simulation bounds checking with access limits
- Create fallback calculations for edge cases and access restrictions

## Success Metrics
- Construction durations match realistic engineering estimates
- Resource consumption accurately reflects project scale and corporation boundaries
- Progress simulation provides reliable completion estimates with access controls
- Supply chain losses reduce with improved corporation logistics (target <5% within corporation, <15% cross-corporation)