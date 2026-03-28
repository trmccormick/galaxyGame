# AI Learning System

The AI Manager implements a sophisticated learning system that extracts patterns from RSpec tests, tracks performance across decisions, and continuously adapts behavior based on outcomes.

## System Architecture

### Core Components

#### 1. TestScenarioExtractor
**Purpose:** Converts RSpec test mocks into AI training scenarios
**Location:** `app/services/ai_manager/test_scenario_extractor.rb`
**Function:** Parses test files to extract realistic settlement scenarios with confidence ratings

#### 2. PerformanceTracker
**Purpose:** Tracks AI decisions, outcomes, and provides adaptation recommendations
**Location:** `app/services/ai_manager/performance_tracker.rb`
**Function:** Records decision history, analyzes pattern performance, and generates tuning recommendations

#### 3. OperationalManager
**Purpose:** Core AI decision engine with integrated learning capabilities
**Location:** `app/services/ai_manager/operational_manager.rb`
**Function:** Makes decisions using learned patterns, tracks outcomes, and applies behavior tuning

### Learning Pipeline

```
Test Execution → Scenario Extraction → Pattern Learning → Decision Making → Performance Tracking → Behavior Tuning
```

## Learning Process

### Phase 1: Test Scenario Extraction
```bash
bundle exec rake ai_manager:extract_test_scenarios
```

**What it does:**
- Scans RSpec test files for mock settlement data
- Extracts critical/operational/expansion scenarios
- Converts to structured training format
- Integrates into AI pattern database

**Output:** `mission_profile_patterns.json` with extracted scenarios

### Phase 2: Performance Analysis
```bash
bundle exec rake ai_manager:analyze_performance
```

**What it does:**
- Analyzes decisions across all settlements
- Calculates success rates by pattern
- Identifies problematic patterns
- Generates tuning recommendations

**Output:** Performance reports with success metrics and recommendations

### Phase 3: Behavior Tuning
```bash
bundle exec rake ai_manager:tune_ai_behavior
```

**What it does:**
- Applies performance-based adjustments
- Updates pattern confidence scores
- Modifies decision thresholds
- Refines pattern matching logic

**Output:** Updated AI behavior parameters

### Phase 4: Adaptation Simulation
```bash
bundle exec rake ai_manager:simulate_adaptation
```

**What it does:**
- Runs AI in test environment
- Processes simulated decisions
- Learns from outcomes
- Demonstrates adaptation capabilities

## Data Structures

### Pattern Format
```json
{
  "pattern_id": "lunar_pattern",
  "deployment_sequence": [...],
  "resource_dependencies": {...},
  "equipment_requirements": {...},
  "learned_from": "mission_json_analysis",
  "learned_at": "2026-01-09T13:56:27Z",
  "confidence_score": 0.85
}
```

### Performance Data Format
```json
{
  "settlement_id": "simulation_001",
  "decisions_made": 30,
  "success_rate": 0.30,
  "pattern_performance": {
    "venus_pattern": 0.0,
    "lunar_pattern": 0.45
  },
  "lessons_learned": [
    "emergency_procurement_failed_consider_alternatives",
    "expansion_pattern_highly_effective"
  ]
}
```

## Decision Categories

### Critical Priorities (Immediate Action)
1. **Life Support** - Oxygen/water/food procurement
2. **Atmospheric Maintenance** - Gas level monitoring
3. **Debt Management** - Financial stability

### Operational Priorities (Scheduled)
4. **Resource Procurement** - Material shortages
5. **Construction** - Infrastructure expansion
6. **Growth** - Economic development

## Pattern Matching Logic

### Context Similarity Matching
```ruby
def find_similar_patterns(context)
  patterns.select do |pattern|
    similarity_score(context, pattern) > CONFIDENCE_THRESHOLD
  end.sort_by { |p| -p[:confidence_score] }
end
```

### Confidence Scoring
- **High (0.8-1.0):** Exact context match
- **Medium (0.5-0.8):** Similar conditions
- **Low (0.2-0.5):** Partial relevance
- **Experimental (0.0-0.2):** Unproven patterns

## Adaptation Rules

### Success-Based Learning
- **Success Rate > 80%:** Increase pattern confidence +10%
- **Success Rate 50-80%:** Maintain current confidence
- **Success Rate < 50%:** Decrease confidence -5%, flag for review

### Pattern Evolution
```json
{
  "improvements": ["optimize_resource_timing"],
  "refinements": ["add_backup_procurement"],
  "success_rate": 0.92,
  "last_updated": "2026-01-09T13:57:02Z"
}
```

## Integration Points

### With Mission System
- Extracts patterns from mission profiles
- Learns from mission execution outcomes
- Adapts deployment strategies

### With Settlement Management
- Tracks settlement performance
- Learns optimal resource allocation
- Adapts to changing conditions

### With Economic System
- Learns profitable trade patterns
- Adapts pricing strategies
- Optimizes resource procurement

## Usage Examples

### Training the AI
```bash
# Extract scenarios from tests
bundle exec rake ai_manager:extract_test_scenarios

# Analyze current performance
bundle exec rake ai_manager:analyze_performance

# Apply tuning recommendations
bundle exec rake ai_manager:tune_ai_behavior

# Test adaptation
bundle exec rake ai_manager:simulate_adaptation
```

### Monitoring Learning Progress
```ruby
# Check current patterns
ai_manager = AIManager::OperationalManager.new(settlement)
patterns = ai_manager.available_patterns

# View performance data
tracker = AIManager::PerformanceTracker.new(settlement.id)
report = tracker.get_performance_report

# See adaptation recommendations
recommendations = tracker.get_adapted_decision_recommendation(context)
```

## Performance Metrics

### Current System Status
- **Total Patterns Learned:** 11
- **Test Scenarios Extracted:** 3
- **Average Success Rate:** 34.3%
- **Decisions Processed:** 35 (simulation)

### Key Performance Indicators
- **Pattern Confidence:** Average confidence score across patterns
- **Decision Accuracy:** Success rate of AI decisions
- **Learning Rate:** Rate of pattern improvement over time
- **Adaptation Speed:** Time to adjust to changing conditions

## Future Enhancements

### Advanced Learning Features
- **Reinforcement Learning:** Reward-based pattern optimization
- **Neural Networks:** Complex pattern recognition
- **Transfer Learning:** Apply patterns across different contexts
- **Meta-Learning:** Learn how to learn more effectively

### Integration Improvements
- **Real-time Learning:** Learn from live gameplay
- **Collaborative Learning:** Share patterns across settlements
- **Predictive Modeling:** Forecast outcomes before decisions
- **Explainable AI:** Provide reasoning for decisions

## Troubleshooting

### Common Issues

**Low Success Rates:**
- Check pattern relevance to current context
- Verify test scenario quality
- Review decision thresholds

**Pattern Conflicts:**
- Multiple patterns match same context
- Conflicting recommendations
- Solution: Implement pattern prioritization

**Performance Degradation:**
- Outdated patterns
- Changed game mechanics
- Solution: Regular pattern retraining

### Debug Commands
```bash
# View current patterns
bundle exec rake ai_manager:validate_patterns

# Compare pattern effectiveness
bundle exec rake ai_manager:compare_patterns

# Benchmark decision performance
bundle exec rake ai:manager:benchmark_decisions[100]
```

## File Structure

```
data/json-data/ai-manager/
├── mission_profile_patterns.json    # Learned patterns
├── performance_*.json              # Performance tracking
├── corporate_patterns.json         # Business patterns
├── terraforming_patterns.json      # Terraforming knowledge
├── resource_acquisition_logic_v1.json # Procurement logic
└── learned_patterns.json           # Construction patterns

app/services/ai_manager/
├── operational_manager.rb          # Core AI engine
├── performance_tracker.rb          # Performance tracking
├── test_scenario_extractor.rb      # Test learning
└── pattern_loader.rb               # Pattern management

lib/tasks/
└── ai_manager.rake                 # Learning tasks
```

This learning system enables the AI Manager to continuously improve its decision-making capabilities, adapting to new situations and optimizing performance across the expanding wormhole network.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/galaxy_game/docs/AI_MANAGER/AI_LEARNING_SYSTEM.md