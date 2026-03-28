# Architecture Intent: AIManager::EscalationService

## 1. Namespace & Role
Located in `module AIManager`, this class handles the logic for expired buy orders and resource deficits. It determines whether to:
1. **ISRU-First**: Deploy an automated harvester (Local extraction).
2. **Emergency**: Create a Special Mission for players (High cost/High speed).
3. **Resupply**: Add to a long-term manifest (Scheduled imports/Cyclers).

## 2. Automated Harvester Protocol (The Fix)
The current implementation of `create_automated_harvester` manually calls `Units::Robot.create!`. 
* **REQUIRED CHANGE**: This must be refactored to use `settlement.add_unit(blueprint_id)`. 
* **Why?**: `add_unit` ensures that the `mobility_type`, `extraction_rate`, and `battery_levels` are pulled from the official JSON blueprints via `UnitLookupService`, preventing validation hallucinations.

## 3. "Time to Critical" (TTC) vs "Time to Resupply" (TTR)
The service uses a 0.8-style readiness check internally by comparing `ttc` (consumption rate) against `ttr` (next arrival).
* If `ttc < ttr`, the AI triggers an **Emergency Mission**.
* If human population is zero, the AI defaults to **Automated Harvesting**.

## 4. Emergency Requisition Hook
When `settlement_can_fund_emergency?` returns false, or the system is "Disconnected" (Eden scenario), the service is the logical place to trigger the **Emergency Requisition Protocol** (Forced Buy/Seizure).