# Architecture Intent: Learning-Driven Unit Deployment

## 1. RSpec as Training Data
The AI Manager treats `spec/models/` and `spec/services/` as its primary source of "Successful Outcomes." 
* **Constraint:** All RSpec mocks must use the `Lookup::UnitLookupService` and `HasUnits#add_unit` patterns. 
* **Risk:** If a test manually mocks a `Units::Robot` incorrectly, the `TestScenarioExtractor` will propagate that "broken" pattern into `mission_profile_patterns.json`.

## 2. Dynamic Thresholds
The **0.8 Readiness Coefficient** is the baseline "Expansion" threshold, but it is subject to the `PerformanceTracker`.
* **Success-Based Learning**: If a `lunar_pattern` succeeds consistently, the `Confidence Score` increases, allowing the AI to trigger expansion faster (closer to 0.75).
* **Failure-Based Learning**: If a robot "Unpacking" fails due to energy depletion, the threshold for that specific pattern is increased (to 0.85 or 0.9).

## 3. Pattern-to-Unit Mapping
When the `OperationalManager` selects a pattern (e.g., `resource_acquisition_logic_v1.json`):
1. It validates the `equipment_requirements` against the Settlement's `inventory`.
2. It triggers the `UnpackingService` for any crated robots required.
3. It maps the `deployment_sequence` to the Robot's `task_queue`.

## 4. Implementation Guardrail
**Never manually override learned patterns.** If the AI is making "stupid" choices (e.g., deploying robots with low battery), do not fix the AI code; fix the **RSpec Test Scenario** and re-run `rake ai_manager:extract_test_scenarios`.