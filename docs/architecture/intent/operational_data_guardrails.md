# Intent: Operational Data as Source of Truth

## 1. Anti-Hardcoding Directive
The behavior of a unit (e.g., how much O2 a skimmer produces) must **never** be hard-coded into a Ruby model or Service. It must always be fetched from the unit's `operational_data` or its parent `Blueprint`.

## 2. Dynamic Scaling
Because units are guided by data:
- **Leveling/Upgrades**: To improve a unit, the code modifies the `output_multiplier` in its `operational_data`.
- **Environmental Impact**: Penalties (like Lunar Dust or Venusian Acid) are applied as a `malus` to the Input/Output ratio in the `operational_data`.

## 3. Data-Driven Intent
When GPT-4.1 or other agents audit the code, they must verify that `process_tick` is reading from the `operational_data` hash. If the code contains `if unit.type == 'Skimmer'`, it is a violation of the Universal Unit Interface.