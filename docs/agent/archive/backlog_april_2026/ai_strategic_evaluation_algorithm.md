# AI Strategic Evaluation Algorithm Implementation

**Priority:** HIGH (MVP Critical - Task 2 of 5)
**Estimated Time:** 6-8 hours
**Risk Level:** MEDIUM (Algorithm design, integration with existing services)
**Dependencies:** AI System Discovery Logic (Task 1) completed and operational

## 🎯 Objective
Implement comprehensive strategic evaluation algorithms that analyze discovered systems using multi-factor assessment to identify Prize Worlds, Resource Worlds, Brown Dwarf hubs, and other strategic opportunities for AI autonomous expansion.

## 📋 Requirements

### Multi-Factor Strategic Assessment
- **TEI Integration**: Use Task 1's TEI scores for terraformability evaluation
- **Resource Analysis**: Evaluate metal richness, volatile availability, rare earth potential
- **Wormhole Connectivity**: Assess network centrality and strategic positioning
- **Energy Potential**: Analyze solar, geothermal, and fusion fuel opportunities
- **Threat Assessment**: Evaluate environmental hazards and competitive risks

### Strategic Classification System
- **Prize Worlds**: TEI > 80% (optimal terraforming targets)
- **Resource Worlds**: High resource scores with strategic value
- **Brown Dwarf Hubs**: Systems with brown dwarf stars offering unique advantages
- **Transit Hubs**: High wormhole connectivity for logistics
- **Energy Worlds**: Exceptional energy generation potential

### Decision Support Framework
- **Comparative Ranking**: Compare systems against current settlement capabilities
- **Risk Assessment**: Evaluate colonization difficulty and success probability
- **Economic Forecasting**: Project long-term value and resource returns
- **Expansion Sequencing**: Determine optimal colonization order

## 🔍 Current Implementation Analysis

### Existing Components (From Task 1)
```ruby
# SystemDiscoveryService provides:
{
  tei_score: 85.3,
  resource_profile: {
    metal_richness: 0.8,
    volatile_availability: 0.6,
    rare_earth_potential: 0.3
  },
  wormhole_data: { has_wormholes: true, network_centrality: 0.7 },
  strategic_value: 0.82
}
```

### Required Strategic Logic
```ruby
# StrategicEvaluator should add:
{
  classification: :prize_world,
  colonization_priority: :critical,
  risk_assessment: :low,
  economic_projection: :high,
  expansion_sequence: 1,
  recommended_strategy: :immediate_colonization
}
```

## 🛠️ Implementation Plan

### Phase 1: Core Evaluation Engine (2-3 hours)
- Create StrategicEvaluator service class
- Implement multi-factor scoring algorithms
- Add system classification logic
- Integrate with SystemDiscoveryService output

### Phase 2: Advanced Classification (2-3 hours)
- Implement Prize World detection (TEI > 80%)
- Add Brown Dwarf hub recognition
- Create Resource World identification
- Develop Transit Hub analysis

### Phase 3: Decision Support Integration (2-3 hours)
- Add risk assessment algorithms
- Implement economic forecasting
- Create expansion sequencing logic
- Integrate with StateAnalyzer for decision making

## 📁 Files to Create/Modify
- `galaxy_game/app/services/ai_manager/strategic_evaluator.rb` (new)
- `galaxy_game/app/services/ai_manager/state_analyzer.rb` (modify - integrate strategic evaluation)
- `galaxy_game/spec/services/ai_manager/strategic_evaluator_spec.rb` (new)
- `galaxy_game/spec/services/ai_manager/state_analyzer_spec.rb` (modify - update tests)

## ✅ Success Criteria
- StrategicEvaluator correctly classifies systems (Prize Worlds, Resource Worlds, etc.)
- Multi-factor assessment produces consistent, logical rankings
- Risk assessment accurately evaluates colonization difficulty
- Economic forecasting provides realistic long-term projections
- StateAnalyzer uses strategic evaluation for expansion decisions
- All RSpec tests pass (existing + new)

## 🧪 Testing Requirements
- Test Prize World detection with TEI > 80%
- Verify Brown Dwarf hub recognition
- Validate Resource World classification
- Test risk assessment accuracy
- Confirm economic projection logic
- Integration tests with StateAnalyzer

## 🔗 Integration Points
- **SystemDiscoveryService**: Consumes discovery data for evaluation
- **StateAnalyzer**: Uses strategic evaluation for scouting decisions
- **StrategySelector**: Incorporates strategic rankings in action selection
- **Economic Forecaster**: Provides economic projection data

## 🎮 Gameplay Integration
- **AI Decision Making**: Strategic evaluation drives autonomous expansion choices
- **Prize World Priority**: AI prioritizes optimal terraforming targets
- **Risk-Aware Planning**: AI avoids high-risk colonization attempts
- **Economic Optimization**: AI selects systems with best long-term value

## 📊 Expected Impact
- **Smarter AI**: Expansion decisions based on comprehensive strategic analysis
- **Prize World Focus**: AI identifies and prioritizes optimal colonization targets
- **Risk Mitigation**: AI avoids colonization failures through risk assessment
- **Economic Efficiency**: AI maximizes long-term value through strategic choices

## 🔄 Relationship to Other Tasks
- **Task 1 (Complete)**: Provides system discovery data for evaluation
- **Task 3 (Next)**: Uses strategic evaluation for site selection decisions
- **Task 4**: Incorporates strategic evaluation in resource allocation planning
- **Task 5**: Uses strategic evaluation for wormhole network planning</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/ai_strategic_evaluation_algorithm.md