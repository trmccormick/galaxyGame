# AIManager::MissionScorer

## Intent

The `MissionScorer` is responsible for evaluating and ranking possible mission options for the AI Manager. It provides a quantitative scoring system that enables the AI to prioritize actions based on urgency, value, risk, and strategic context. This class is central to the AI's ability to make rational, context-aware decisions.

## Core Logic Pipeline

1. **Scoring**  
   Calculates a numeric score for each mission option using a combination of weighted factors (priority, resource value, risk, urgency, capability, etc.).

2. **Prioritization**  
   Assigns a priority level (critical, high, medium, low) based on the score and mission analysis.

3. **Dependency & Sequencing**  
   Identifies dependencies for each mission and determines if it can be executed immediately or requires prerequisites.

4. **Sequencing**  
   Orders missions to respect dependencies and maximize overall efficiency.

## Integration Points

- **StrategySelector**  
  Uses `MissionScorer` to rank and select the best mission options during the decision cycle.

- **StateAnalyzer**  
  Provides the state context and analysis data used in scoring and prioritization.

## Main Methods

- `calculate_score(mission_option, state_analysis)`  
  Returns a numeric score for a given mission option.

- `prioritize_missions(mission_options, state_analysis)`  
  Returns a sorted and sequenced list of mission options with scores and priority levels.

- `determine_priority_level(analysis, score)`  
  Assigns a priority level based on mission analysis and score.

- `determine_sequencing_info(mission, state_analysis)`  
  Identifies dependencies and readiness for execution.

- `apply_dependency_sequencing(prioritized_missions, state_analysis)`  
  Orders missions to respect dependencies.

## Scoring Weights & Factors

- **Priority Multipliers**: critical, high, medium, low
- **Resource Value**: Importance of the resource to the settlement
- **Strategic Value**: Long-term benefit
- **Risk Penalty**: Reduces score for risky missions
- **Urgency Bonus**: Increases score for urgent needs
- **Capability Bonus**: Rewards missions that match current capabilities

## Tuning & Extension

- **Adjust Weights**: Modify `SCORING_WEIGHTS` to tune AI behavior for different scenarios.
- **Add Factors**: Extend scoring logic to include new considerations (e.g., morale, threat level).
- **Custom Sequencing**: Implement advanced sequencing for complex mission chains.

---

This documentation serves as a base reference for tuning and extending the mission scoring logic in the AI Manager.
