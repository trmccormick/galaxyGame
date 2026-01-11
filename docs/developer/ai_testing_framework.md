# AI Manager Luna Base Build Testing Framework

## Overview
This framework provides comprehensive testing for the AI Manager's ability to construct Luna bases using learned patterns. It includes detailed progress tracking, economic analysis, and comparison to expected mission patterns.

## Structured Testing Approach

### Phase 1: Initial Test Run
```bash
# Run basic Luna base build test
rake ai_manager:test_luna_base_build

# Run with detailed progress output
rake ai_manager:test_luna_base_build[1,true]

# Run multiple iterations for statistical analysis
rake ai_manager:test_luna_base_build[5,false]
```

### Phase 2: Pattern Analysis
```bash
# Analyze current learned patterns
rake ai_manager:analyze_mission_profiles

# Compare patterns for similarities
rake ai_manager:compare_patterns

# Validate patterns against game rules
rake ai_manager:validate_patterns
```

### Phase 3: Performance Analysis
```bash
# Analyze AI performance across settlements
rake ai_manager:analyze_performance

# Benchmark decision performance
rake ai:manager:benchmark_decisions[100]

# Tune AI behavior based on results
rake ai_manager:tune_ai_behavior
```

### Phase 4: Retraining (if needed)
If test results show issues:
```bash
# Extract new test scenarios
rake ai_manager:extract_test_scenarios

# Update mission files in data/json-data/missions/
# - Add lunar_precursor mission profiles
# - Include asteroid conversion patterns
# - Add detailed phase structures

# Re-validate patterns
rake ai_manager:validate_patterns_world_aware

# Re-test
rake ai_manager:test_luna_base_build[3,true]
```

## Expected Test Output Format

```
🌙 === AI MANAGER LUNA BASE BUILD TEST ===
Testing AI Manager's ability to construct Luna base using learned patterns
Iterations: 1, Progress Display: true
================================================================================

🔄 ITERATION 1/1
--------------------------------------------------

📊 PHASE 0: SETUP & ANALYSIS
🌙 Finding Luna in system data...
✅ Luna located: Luna (moon)

🤖 PHASE 1: AI ANALYSIS & PATTERN SELECTION
📊 Luna Analysis Results:
  Terraformability: 15%
  Resources: regolith, helium3, water_ice
  Difficulty: 60
  Priority Score: 75.0
🎯 AI Selected Pattern: lunar_precursor
  Score: 92
  Reasons: Direct body match, Resource alignment, High success rate (0.89)

🚀 PHASE 2: MISSION EXECUTION
📦 Initial Inventory: 3 items
💰 Initial GCC: 100000
🏗️ Phase 1: Landing & Setup
✅ Phase completed successfully
🏗️ Phase 2: Power & Infrastructure
✅ Phase completed successfully
🏗️ Phase 3: ISRU Setup
✅ Phase completed successfully
🏗️ Phase 4: Expansion
✅ Phase completed successfully
📦 Final Inventory: 12 items (+9)
💰 Final GCC: 85000 (spent: 15000)

💰 PHASE 3: ECONOMIC ANALYSIS
💰 Final GCC Balance: 85000
💸 GCC Spent: 15000

📈 PHASE 4: PERFORMANCE METRICS
⏱️ Mission Duration: 2.34 seconds
📊 Pattern Compliance: 95%

📊 ITERATION 1 SUMMARY:
  Duration: 3.45s
  Success: ✅
  Settlement Created: ✅
  Final GCC Balance: 85000
  Construction Jobs: 12
  ISRU Efficiency: 0.867

🎯 === OVERALL TEST RESULTS ===
================================================================================
Total Test Duration: 3.45 seconds
Success Rate: 100.0% (1/1)
Average Build Time: 3.45s
Average Final GCC: 85000
Average Construction Jobs: 12.0
Average ISRU Efficiency: 0.867

📈 PERFORMANCE ANALYSIS:
  Average Construction Jobs: 12.0
  Average ISRU Efficiency: 86.7%
  Best Build Time: 3.45s
  Worst Build Time: 3.45s

💡 RECOMMENDATIONS:
  ✅ High success rate - AI effectively learned lunar base construction

🔄 TO RETRAIN AI:
  1. Update mission files in data/json-data/missions/
  2. Run: rake ai_manager:extract_test_scenarios
  3. Run: rake ai_manager:analyze_performance
  4. Run: rake ai_manager:tune_ai_behavior
  5. Re-test: rake ai_manager:test_luna_base_build
```

## Key Metrics Tracked

### Construction Progress
- **Phase Completion**: Tracks each mission phase (Landing, Power, ISRU, Expansion)
- **Job Completion**: Counts construction jobs completed
- **Resource Changes**: Inventory changes during build

### Economic Tracking
- **GCC Balance**: Starting and ending account balances
- **Procurement Costs**: Costs by method (ISRU, Market, Imports)
- **Resource Values**: Economic value of produced resources

### Performance Metrics
- **ISRU Efficiency**: Ratio of local production vs. imports
- **Pattern Compliance**: How well AI follows expected patterns
- **Success Rate**: Percentage of successful builds

### AI Learning Validation
- **Pattern Selection**: Which patterns AI chooses and why
- **Decision Quality**: Comparison to expected outcomes
- **Adaptation**: How AI adjusts based on performance data

## Mission Pattern Structure

### Required Mission Files
```
data/json-data/missions/
├── lunar-precursor/
│   ├── lunar_precursor_profile_v1.json
│   └── phases/
│       ├── lunar_precursor_initial_setup_v1.json
│       ├── lunar_precursor_power_comms_v1.json
│       ├── lunar_precursor_resource_extraction_v1.json
│       ├── lunar_precursor_construction_infrastructure_v1.json
│       └── lunar_precursor_base_expansion_v1.json
└── asteroid-conversion-orbital-depot/
    ├── asteroid_conversion_orbital_depot_profile_v1.json
    └── phases/
        ├── asteroid_conversion_selection_relocation_v1.json
        ├── asteroid_conversion_surface_prep_v1.json
        ├── asteroid_conversion_internal_mod_v1.json
        ├── asteroid_conversion_depot_systems_v1.json
        └── asteroid_conversion_activation_testing_v1.json
```

### Pattern Learning Integration
- Mission profiles are automatically loaded as patterns
- Performance data updates pattern success rates
- AI adapts pattern selection based on historical performance

## Troubleshooting

### Low Success Rate (<80%)
1. Check mission file validity: `rake ai_manager:validate_patterns`
2. Review pattern learning: `rake ai_manager:analyze_performance`
3. Update training data: Add more lunar mission examples

### Poor ISRU Efficiency (<70%)
1. Verify ISRU equipment in mission profiles
2. Check resource procurement logic
3. Update economic models in settlement patterns

### Pattern Compliance Issues
1. Compare to expected patterns in luna_settlement_patterns.json
2. Review phase structures in mission files
3. Update AI training with corrected patterns

## Integration with Existing Systems

### AI Manager Components
- **OperationalManager**: Makes real-time decisions during builds
- **PatternLoader**: Loads learned patterns from JSON files
- **PerformanceTracker**: Records outcomes for learning
- **DecisionTree**: Handles priority-based construction decisions

### Economic Systems
- **ProcurementService**: Handles resource acquisition
- **FinancialService**: Manages GCC transactions
- **ResourcePlanner**: Optimizes resource flows

### Mission Execution
- **TaskExecutionEngine**: Executes mission phases
- **ConstructionService**: Manages construction jobs
- **ResourceTrackingService**: Monitors inventory changes

This framework provides a complete testing and iteration cycle for AI Luna base construction, ensuring the AI can effectively learn and apply construction patterns in a realistic game environment.