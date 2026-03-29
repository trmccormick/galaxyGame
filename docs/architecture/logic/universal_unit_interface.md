# Logic: Universal Unit Interface (Input/Output Model)

## 1. The Core Engine
Every unit in the Galaxy Game (CAR-300, Refinery Module, Skimmer, Power Array) operates on a standardized I/O logic. The `Settlement::ProcessingEngine` does not need to know *what* the unit is, only *what it does* via its `operational_data`.

## 2. Standardized Schema
The `operational_data` for any unit must include:
- **Inputs**: Hash of resource IDs and quantities required per tick (e.g., `{ co2: 10, power_kw: 40 }`).
- **Outputs**: Hash of resource IDs and quantities produced per tick (e.g., `{ lox: 8, carbon: 2 }`).
- **Efficiency**: A float (0.0 to 1.0) impacted by wear-and-tear or environmental hazards.
- **State**: `standby`, `processing`, or `failed`.

## 3. Implementation Rule
**Do Not Subclass for Functionality.** If a new machine is needed, create a new **JSON Blueprint** with unique I/O data rather than writing a new Ruby class. The `Unit` model is a generic container for this data.