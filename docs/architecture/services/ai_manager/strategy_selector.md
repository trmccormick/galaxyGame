# AIManager::StrategySelector

## Intent

The `StrategySelector` is the core decision-making engine for the AI Manager. Its purpose is to autonomously evaluate the current state of a settlement and select the optimal next action, balancing resource needs, expansion, scouting, and infrastructure priorities. This class is designed for extensibility and tuning, serving as the main point for strategic AI behavior.

## Core Logic Pipeline

1. **State Analysis**  
	 Uses `StateAnalyzer` to assess the settlement’s resource needs, readiness, and opportunities.

2. **Mission Generation**  
	 Identifies all available mission options (resource acquisition, scouting, expansion, infrastructure).

3. **Scoring & Strategy**  
	 Ranks mission options using `MissionScorer`, then applies strategic multipliers and risk/long-term value adjustments.

4. **Trade-off Analysis**  
	 Evaluates competing priorities (e.g., resource vs. scouting vs. building) to determine the dominant strategic focus.

5. **Selection**  
	 Picks the highest-scoring executable action, or a viable action requiring preparation, or falls back to a “wait” state if no action is possible.

## Integration Points

- **AIManager::Manager**  
	Calls `StrategySelector` during the `advance_time` cycle to determine the next action for each settlement.

- **ServiceCoordinator/ServiceOrchestrator**  
	Executes the chosen action (e.g., resource acquisition, scouting) as directed by the selector.

- **StateAnalyzer & MissionScorer**  
	Used internally for state evaluation and mission scoring.

## Main Methods

- `evaluate_next_action(settlement)`  
	Returns the best action hash for the current state.

- `execute_action(action, settlement)`  
	Dispatches the selected action to the appropriate service.

- Private helpers:  
	- `generate_mission_options`  
	- `score_mission_options`  
	- `perform_strategic_tradeoff_analysis`  
	- `apply_strategic_adjustments`  
	- `select_optimal_action_with_strategy`

## Tuning & Extension

- **Strategic Focus**: The trade-off logic can be tuned to favor resource, scouting, or building priorities.
- **Scoring Weights**: Adjust `MissionScorer` weights for different mission types or priorities.
- **State Inputs**: Extend `StateAnalyzer` to add new factors (e.g., threat assessment, morale).
- **Fallbacks**: Customize fallback/wait logic for more nuanced AI stalling or recovery.
