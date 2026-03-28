# Architecture Intent: AI Priority to Unit Lifecycle Mapping

## 1. Tier-to-Unit Integration
This document formalizes how the `AI_PRIORITY_SYSTEM.md` tiers interact with the `Units::BaseUnit` and `Units::Robot` models.

| AI Tier | Unit State | Action Required |
| :--- | :--- | :--- |
| **Tier 1 (Critical)** | Emergency | Shut down non-essential robots; prioritize `Atmosphere` units. |
| **Tier 2 (Operational)** | Maintenance | MRR-100 units prioritized for repair; robots restricted to ISRU. |
| **Tier 3 (Expansion)** | Activation | Trigger `HasUnits#add_unit` to unpack HLL Manifest inventory. |

## 2. Formalizing the 0.8 Readiness Coefficient
While the `AI_PRIORITY_SYSTEM.md` uses a tiered check, the transition to **Tier 3 (Expansion)** should be gated by a **0.8 Stability Score** across:
* **Energy**: `Current Supply / Demand > 0.8`
* **Treasury**: `Available GCC / Unit Operational Cost > 0.8`
* **Integrity**: `Average Unit Health > 0.8`

## 3. The "Unpacking" Economic Check
Before the `Expansion` tier activates a new robot (e.g., CAR-300), the `AI_MANAGER_CONSTRUCTION_ECONOMICS.md` logic must perform a "Cold Start" check:
1. **Upfront Cost**: Remove the Item from inventory.
2. **Operating Cost**: Verify the settlement can sustain the `energy_drain` (e.g., 2.0/tick) defined in the Unit Blueprint.
3. **Preference**: If a Player Contract for the same task is cheaper than the Robot's lifetime energy cost, the AI must post the contract first.

## 4. Implementation Guardrail
The `EscalationService` must never call `Robot.new` or `Robot.create` directly. It must query the `HasUnits` concern of the Settlement, which handles the `Lookup::UnitLookupService` synchronization.