# AI System Discovery Logic Implementation

**Priority:** HIGH (MVP Critical)
**Estimated Time:** 6-8 hours
**Risk Level:** MEDIUM (Database integration, algorithm design)
**Dependencies:** Star system database populated, wormhole network operational

## 🎯 Objective
Replace mock scouting opportunities in StateAnalyzer with real system discovery logic that queries the star systems database and evaluates systems based on actual characteristics and wormhole connectivity.

## 📋 Requirements

### Real System Database Integration
- **Database Queries**: Query star_systems table for unexplored systems within wormhole range
- **Distance Calculations**: Implement spatial calculations from current settlements
- **Metadata Analysis**: Analyze system metadata (planet count, resource indicators, habitability hints)
- **Discovery Probability**: Create probability-based discovery based on scouting investment

### Strategic Evaluation Algorithm
- **Multi-Factor Scoring**: Resource potential, strategic position, habitability, wormhole connectivity
- **Threat Assessment**: Hostile environments, resource competition analysis
- **Comparative Ranking**: Compare against current system capabilities
- **Economic Forecasting**: Long-term value assessment with economic modeling

### Wormhole Topology Integration
- **Active Connections**: Query current wormhole connections and stability
- **Range Calculations**: Determine systems within reachable distance
- **Pathfinding**: Multi-hop route analysis for expansion planning
- **Network Analysis**: Centrality and connectivity assessments

## 🔍 Current Implementation Analysis

### Existing Mock Logic (StateAnalyzer)
```ruby
def analyze_scouting_opportunities(settlement)
  # Mock opportunities - REPLACE THIS
  if assess_economic_health(settlement) > 0.7
    strategic_systems << { id: 'nearby_system_1', estimated_value: :high }
  end
  # Returns fake system IDs
end
```

### Required Real Implementation
```ruby
def analyze_scouting_opportunities(settlement)
  # Query actual star systems database
  candidate_systems = find_explorable_systems(settlement)
  evaluated_systems = candidate_systems.map do |system|
    {
      id: system.identifier,
      strategic_value: calculate_strategic_value(system, settlement),
      wormhole_distance: calculate_wormhole_distance(system, settlement),
      resource_potential: assess_resource_potential(system),
      habitability_index: calculate_habitability_index(system)
    }
  end
  # Return prioritized real opportunities
end
```

## 🛠️ Implementation Plan

### Phase 1: Database Integration (2-3 hours)
- Add star system queries to StateAnalyzer
- Implement distance calculation methods
- Create system metadata extraction
- Add wormhole connectivity checks

### Phase 2: Strategic Evaluation (2-3 hours)
- Implement multi-factor scoring algorithm
- Add threat assessment logic
- Create comparative ranking system
- Integrate economic forecasting

### Phase 3: Wormhole Integration (2-3 hours)
- Add wormhole topology queries
- Implement pathfinding algorithms
- Create network centrality calculations
- Add connectivity-based prioritization

## 📁 Files to Create/Modify
- `galaxy_game/app/services/ai_manager/state_analyzer.rb` (modify - replace mock logic)
- `galaxy_game/app/services/ai_manager/system_discovery_service.rb` (new)
- `galaxy_game/app/services/ai_manager/strategic_evaluator.rb` (new)
- `galaxy_game/spec/services/ai_manager/state_analyzer_spec.rb` (modify - update tests)

## ✅ Success Criteria
- StateAnalyzer returns real system opportunities from database
- Strategic evaluation accurately prioritizes systems
- Wormhole connectivity properly considered in expansion planning
- Discovery probability scales with scouting investment
- No more mock 'nearby_system_1' or 'resource_system_1' references

## 🧪 Testing Requirements
- Test with Sol system as baseline (known systems)
- Test with Eden system (generated system discovery)
- Verify wormhole range calculations
- Validate strategic scoring accuracy
- Test discovery probability scaling

## 🔗 Integration Points
- **StrategySelector**: Consumes evaluated opportunities for mission generation
- **Wormhole Network**: Provides connectivity data for range calculations
- **Star System Database**: Source of system metadata and characteristics
- **Economic Forecaster**: Provides long-term value assessments</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/ai_system_discovery_implementation.md