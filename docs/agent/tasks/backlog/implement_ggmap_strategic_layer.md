# Implement GGMap Strategic Layer

## Task Overview
Implement the strategic layer generation for .ggmap format, where AI analyzes terrain and recommends optimal settlement locations, expansion zones, and infrastructure corridors.

## Background
The .ggmap strategic layer contains AI-generated intelligence about where to build settlements, extract resources, and develop infrastructure. This makes the AI Manager intelligent about colonization decisions.

## Requirements

### Phase 1: Settlement Site Analysis (Priority: High)
- **Terrain Evaluation**: Analyze flatness, accessibility, and safety factors
- **Resource Proximity**: Score locations based on nearby resources
- **Geological Features**: Factor in lava tubes, aquifers, and stable bedrock
- **Multi-Criteria Scoring**: Combine factors into settlement suitability scores

### Phase 2: Expansion Zone Mapping (Priority: High)
- **Growth Corridors**: Identify paths for settlement expansion
- **Resource Hubs**: Map areas with multiple resource concentrations
- **Infrastructure Routes**: Plan transportation and utility corridors
- **Defense Considerations**: Evaluate strategic positioning

### Phase 3: AI Recommendation Engine (Priority: High)
- **Priority Ranking**: Classify sites as highest/medium/low priority
- **Reasoning Documentation**: Explain why each site is recommended
- **Development Sequencing**: Suggest order of settlement construction
- **ROI Calculations**: Estimate long-term value of each location

### Phase 4: GGMap Integration (Priority: Medium)
- **Layer Structure**: Implement strategic layer in .ggmap JSON format
- **Dynamic Updates**: Allow strategic analysis to be regenerated
- **Metadata Rich**: Include detailed reasoning and scoring data
- **AI Manager Integration**: Make strategic data available to AI Manager

## Strategic Layer JSON Structure
```json
"strategic_layer": {
  "settlement_sites": [
    {
      "location": { "x": 45, "y": 23 },
      "priority": "highest",
      "reasoning": "Lava tube + water + flat terrain + resource proximity",
      "suitability_scores": {
        "terrain_flatness": 0.95,
        "resource_access": 0.88,
        "safety": 0.92,
        "expansion_potential": 0.85,
        "overall": 0.90
      },
      "recommended_use": ["primary_settlement", "research_base"]
    }
  ],
  "expansion_zones": [
    {
      "area": { "x1": 40, "y1": 20, "x2": 60, "y2": 40 },
      "priority": "high",
      "development_potential": 0.82,
      "key_features": ["volcanic_region", "mineral_deposits"]
    }
  ],
  "infrastructure_corridors": [
    {
      "path": [{ "x": 45, "y": 23 }, { "x": 67, "y": 45 }],
      "type": "transport",
      "priority": "medium",
      "justification": "Connects settlement to resource deposits"
    }
  ]
}
```

## Success Criteria
- [ ] AI generates intelligent settlement recommendations
- [ ] Strategic analysis considers multiple terrain and resource factors
- [ ] Sites include detailed scoring and reasoning
- [ ] Strategic layer integrates with .ggmap format
- [ ] AI Manager can use strategic data for decision making

## Files to Create/Modify
- `galaxy_game/app/services/ggmap_strategic_generator.rb` - Strategic analysis logic
- `galaxy_game/app/services/settlement_scorer.rb` - Site evaluation algorithms
- `galaxy_game/lib/ggmap.rb` - Add strategic layer support
- `galaxy_game/app/services/ai_manager/strategic_planner.rb` - AI integration

## Estimated Time
4 hours

## Priority
HIGH