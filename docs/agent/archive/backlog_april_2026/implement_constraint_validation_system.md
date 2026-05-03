# Implement Construction Constraint Validation System

> **Agent Suitability Note:**
> This task is well-suited for GPT-4.1. It involves systematic service/model implementation, JSON parsing, and validation logic. Assign to GPT-4.1 unless advanced reasoning or cross-service refactoring is required.

## Overview
This task implements the comprehensive constraint validation system that the AI Manager uses to evaluate construction sites before building. **Corrected**: Constraints vary by celestial body and structure type. The system must load location-specific constraint definitions and validate sites appropriately for each environment.

## Dependencies
- Terrain data access (GeoTIFF processing)
- Environmental data systems (temperature, radiation)
- Resource proximity mapping
- Mission profile JSON files for constraint definitions
- AI Manager decision-making integration
- TerrainForge monitoring (for admin visibility of constraint violations)

## Phase 1: Location-Aware Validation Framework (1 week)
### Tasks
- Create ConstraintValidator service class with location awareness
- Implement JSON-based constraint loading from mission profiles
- Add validation result format (valid, violations, score, location_factors)
- Create constraint inheritance system (global → celestial body → structure type)
- Integrate with existing terrain analysis systems

### Success Criteria
- ConstraintValidator loads constraints from mission profile JSON files
- Location-specific constraints override global defaults
- Validation returns structured results with location context
- Framework extensible for new celestial bodies and structure types

## Phase 2: Luna-Specific Constraints (1 week)
### Tasks
- Implement lavatube structural validation (100m length, 20m width, 15m height)
- Add lunar geological stability checking (regolith, seismic activity)
- Create radiation shielding requirements (surface vs subsurface)
- Build thermal regulation constraints (extreme temperature swings)
- Add Luna-specific terrain compatibility (craters, maria, highlands)

### Success Criteria
- Lavatube dimensions validated for subsurface construction
- Geological stability prevents construction in unstable areas
- Radiation constraints enforce proper shielding
- Thermal constraints account for lunar day/night cycles

## Phase 3: Mars-Specific Constraints (1 week)
### Tasks
- Implement dust storm impact assessment (visibility, deposition)
- Add water ice proximity validation (resource availability)
- Create atmospheric pressure constraints (surface vs elevated sites)
- Build radiation protection requirements (thin atmosphere)
- Add terrain constraints for different Mars regions (valleys, craters, plains)

### Success Criteria
- Dust storm risks properly assessed for construction timing
- Water ice proximity affects site scoring
- Atmospheric constraints validated for different elevations
- Radiation protection requirements enforced

## Phase 4: Venus-Specific Constraints (2 weeks)
### Tasks
- Implement extreme temperature validation (735K surface, varying altitudes)
- Add atmospheric pressure constraints (92 bar surface, decreasing with altitude)
- Create sulfuric acid corrosion protection requirements
- Build cloud city altitude optimization (50-60km sweet spot)
- Add orbital depot radiation shielding (no atmosphere)

### Success Criteria
- Temperature constraints prevent surface construction
- Pressure constraints validated for different altitudes
- Corrosion protection required for all surface-exposed structures
- Cloud city altitude optimization implemented

## Phase 5: Resource and Logistics Constraints (1 week)
### Tasks
- Implement resource proximity validation (location-specific distances)
- Add supply chain distance checking (orbital vs surface logistics)
- Create resource availability scoring with local extraction
- Build logistics feasibility analysis (transport methods, costs)
- Add interplanetary supply route optimization

### Success Criteria
- Resource proximity requirements vary by celestial body
- Supply distance calculations account for transport methods
- Resource availability affects site scoring appropriately
- Logistics constraints prevent economically unviable construction

## Phase 6: Generic Constraint Framework (1 week)
### Tasks
- Create extensible constraint definition system
- Implement constraint inheritance and override mechanisms
- Build constraint validation for custom celestial bodies
- Add constraint testing and validation tools
- Create constraint performance optimization

### Success Criteria
- New celestial bodies can define custom constraints
- Constraint inheritance works (global → specific)
- Custom constraints validated correctly
- Constraint evaluation performance optimized

## Phase 7: AI Manager Integration (1 week)
### Tasks
- Integrate constraint validation into site selection process
- Add constraint violation reporting to ConstructionProject
- Implement constraint-based scoring for site ranking
- Create admin override mechanisms for constraint violations
- Add constraint validation to TerrainForge display

### Success Criteria
- AI Manager uses location-specific constraint validation
- Constraint violations stored with construction reasoning
- Site scoring improves selection quality by location
- Admin can override constraints with justification

## Technical Specifications

### Location-Aware ConstraintValidator
```ruby
class ConstraintValidator
  CONSTRAINTS_PATH = Rails.root.join('data/json-data/missions')
  
  def initialize(celestial_body, structure_type)
    @celestial_body = celestial_body
    @structure_type = structure_type
    @constraints = load_constraints
  end
  
  def load_constraints
    global_constraints = load_global_constraints
    body_constraints = load_body_constraints(@celestial_body)
    structure_constraints = load_structure_constraints(@structure_type)
    
    # Merge with inheritance: global < body < structure
    global_constraints.deep_merge(body_constraints).deep_merge(structure_constraints)
  end
  
  def validate(site)
    violations = []
    score = 100
    
    @constraints.each do |category, rules|
      violations += validate_category(site, category, rules)
    end
    
    score -= violations.length * 10
    
    {
      valid: violations.empty?,
      violations: violations,
      score: [score, 0].max,
      location_factors: @constraints.keys
    }
  end
end
```

### Constraint Definition JSON Structure
```json
{
  "celestial_body": "mars",
  "constraints": {
    "terrain": {
      "max_slope": 25,
      "dust_accumulation_risk": "medium"
    },
    "environmental": {
      "max_temperature": 293,
      "min_temperature": 148,
      "atmospheric_pressure": "variable"
    },
    "structural": {
      "wind_load_resistance": "high",
      "dust_storm_protection": true
    }
  }
}
```

### Validation Result Integration
```ruby
# In ConstructionProject
class ConstructionProject < ApplicationRecord
  # ...
  store :constraint_analysis, coder: JSON

  def constraint_analysis
    self[:constraint_analysis] || {}
  end

  def constraint_violations
    constraint_analysis['violations'] || []
  end

  def site_score
    constraint_analysis['score'] || 0
  end
  
  def location_factors
    constraint_analysis['location_factors'] || []
  end
end
```

## Location-Specific Constraint Examples
- **Luna**: Lavatube dimensions, radiation shielding, thermal cycling, regolith stability
- **Mars**: Dust deposition, water ice access, atmospheric pressure, radiation exposure
- **Venus**: Temperature gradients, pressure zones, acid corrosion, altitude optimization
- **Generic**: Resource proximity, logistics distances, environmental hazards

## Testing Requirements
- Constraint validation for all major celestial bodies
- Edge cases (extreme environments, marginal sites)
- Performance testing with large terrain datasets
- Integration testing with AI Manager decision flow
- Admin override functionality with audit trails

## Risk Mitigation
- Start with permissive constraints, tighten gradually
- Add comprehensive logging for constraint evaluations
- Implement constraint override audit trail
- Create fallback site selection if no valid sites found
- Extensive testing with real mission profile data

## Success Metrics
- 95% of AI-selected sites pass all location-specific constraints
- Constraint violations reduced by 80% vs random selection
- Site scoring improves construction success rates by location
- Admin override usage stays under 5% of projects
- Constraint system extensible for new celestial bodies