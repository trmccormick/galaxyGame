# Architecture Intent: HasUnits Concern

## 1. Responsibility
The `HasUnits` concern provides a unified interface for any model (Settlement, Craft, or Hub) that can host or "plug in" a `BaseUnit`. It manages the relationship, capacity limits, and compatibility checks.

## 2. The `add_unit` Workflow
This is the **canonical method** for creating and attaching units. It should always be used instead of manual `BaseUnit.create!` calls.

1. **Lookup**: Calls `Lookup::UnitLookupService` to fetch the blueprint.
2. **Capacity Check**: Validates against `operational_data['max_units']` of the parent.
3. **Compatibility Check**: Ensures the `unit_id` is present in `operational_data['compatible_unit_types']`.
4. **Instantiation**: Maps blueprint data into the `BaseUnit` schema.
5. **Association**: Sets the `attachable` to `self` and inherits the `owner`.

## 3. Operational Data Inheritance
The concern explicitly maps `unit_data['operational_data']` from the JSON blueprint into the new unit record. For **Robots**, this ensures the `mobility_type` and `battery_level` are correctly seeded from the template.

## 4. Post-Attachment Logic
* **`apply_unit_effects(unit)`**: After a successful save, this method is triggered to update the parent's stats (e.g., adding cargo capacity, power draw, or life support bonuses).

## 5. Implementation Guardrails
* **Blueprint Dependency**: `add_unit` will fail if the `unit_blueprint_id` does not exist in the `data/json-data/` registry.
* **Return Values**: Returns the `unit` object on success, or a descriptive error string/nil on failure.