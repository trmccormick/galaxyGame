# Implement Settlement Pattern Logic in AI Manager

## Overview
This task implements the automated settlement construction pattern that TerrainForge will monitor. **Corrected**: Settlement patterns vary by celestial body. The AI Manager must load appropriate patterns from mission profile JSON files and execute location-specific construction sequences.

## Dependencies
- TerrainForge data models (DCSettlement, ConstructionProject)
- Mission profile JSON files for different celestial bodies
- AI Manager service integration
- Terrain analysis capabilities (GeoTIFF processing)
- Orbital construction system (existing L1 Depot logic)

## Phase 1: Settlement Pattern Loader (1 week)
### Tasks
- Create SettlementPatternLoader service
- Implement JSON parsing for mission profile patterns
- Build pattern selection logic based on celestial body characteristics
- Add pattern validation and fallback mechanisms
- Integrate with AI Manager decision system

### Success Criteria
- Patterns load correctly from mission profile JSON files
- Celestial body characteristics determine pattern selection
- Fallback patterns available for undefined locations
- Pattern validation prevents invalid configurations

## Phase 2: Luna Pattern Automation (1 week)
### Tasks
- Implement Luna-specific precursor mission logic
- Build industrial bootstrap sequence for Luna
- Create orbital infrastructure shift for cislunar space
- Add Luna-specific constraint checking
- Integrate with existing L1 Depot construction

### Success Criteria
- Luna precursor equipment deployment works
- Lavatube sealing and pressurization simulated
- L1 Depot priority construction implemented
- Luna pattern completes to operational status

## Phase 3: Mars Pattern Implementation (2 weeks)
### Tasks
- Implement Mars orbital establishment (moons conversion)
- Build surface outposts and resource mining logic
- Create resource infrastructure and tank farm development
- Add advanced mining and stockpiling phases
- Integrate with Mars mission profiles

### Success Criteria
- Mars orbital infrastructure established first
- Surface operations follow orbital preparation
- Resource stockpiling scales appropriately
- Mars pattern reaches operational status

## Phase 4: Venus Pattern Development (2 weeks)
### Tasks
- Implement Venus orbital depot establishment
- Build atmospheric resource harvesting sequence
- Create cloud city operations logic
- Add foundry establishment and industrial integration
- Integrate interplanetary logistics network

### Success Criteria
- Venus atmospheric harvesting operational
- Cloud city infrastructure developed
- CNT foundry becomes materials hub
- Venus pattern supports industrial operations

## Phase 5: Generic Pattern Framework (1 week)
### Tasks
- Create extensible pattern framework for new locations
- Implement pattern phase transition logic
- Build pattern completion and operational status detection
- Add pattern customization based on strategic priorities
- Create pattern testing and validation tools

### Success Criteria
- New celestial bodies can have custom patterns defined
- Pattern transitions work across different sequences
- Operational status detection is location-aware
- Pattern framework supports future expansion

## Phase 6: AI Manager Integration (1 week)
### Tasks
- Integrate pattern selection into AI settlement decisions
- Add pattern progress tracking and reporting
- Implement pattern-based resource allocation
- Create pattern override capabilities for admins
- Build pattern performance analytics

### Success Criteria
- AI selects appropriate patterns for each location
- Pattern progress tracked in TerrainForge
- Admin can override pattern selections
- Analytics show pattern effectiveness

## Technical Specifications

### SettlementPatternLoader
```ruby
class SettlementPatternLoader
  PATTERNS_PATH = Rails.root.join('data/json-data/missions')
  
  def load_pattern_for_celestial_body(celestial_body)
    pattern_file = find_pattern_file(celestial_body)
    return default_pattern unless pattern_file
    
    JSON.parse(File.read(pattern_file))
  rescue JSON::ParserError
    default_pattern
  end
  
  def find_pattern_file(celestial_body)
    # Search mission directories for appropriate pattern
    # Return nil if no specific pattern found
  end
  
  def default_pattern
    # Luna pattern as fallback
  end
end
```

### Pattern Execution Engine
```ruby
class SettlementPatternExecutor
  def initialize(settlement, pattern)
    @settlement = settlement
    @pattern = pattern
    @current_phase = 0
  end
  
  def execute_next_phase
    phase_config = @pattern['phases'][@current_phase]
    return false unless phase_config
    
    success = execute_phase_tasks(phase_config)
    @current_phase += 1 if success
    success
  end
  
  def execute_phase_tasks(phase_config)
    # Execute tasks based on phase configuration
    # Create ConstructionProjects as needed
    # Track progress and completion
  end
end
```

## Location-Specific Patterns
- **Luna**: Precursor → Industrial → Orbital (surface-first)
- **Mars**: Orbital → Surface Outposts → Resource Infra → Advanced Mining (orbital-first)
- **Venus**: Orbital Depot → Atmospheric Harvesting → Cloud Cities → Foundry → Industrial (atmospheric focus)
- **Other**: Custom patterns loaded from mission profiles

## Testing Requirements
- Pattern loading for all major celestial bodies
- Phase execution for each pattern type
- Pattern transitions and completion detection
- Integration with AI Manager and TerrainForge
- Performance with multiple concurrent settlements

## Risk Mitigation
- Comprehensive fallback to Luna pattern
- Pattern validation before execution
- Progress rollback capabilities
- Extensive logging for pattern execution

## Success Metrics
- All documented settlement patterns executable
- AI selects appropriate patterns for locations
- Settlement construction follows realistic sequences
- TerrainForge displays location-specific progress
- Pattern system extensible for new celestial bodies