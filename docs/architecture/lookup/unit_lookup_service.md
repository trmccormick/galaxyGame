## 1. Responsibility
The `UnitLookupService` is the registry for all unit definitions. It is responsible for loading static JSON blueprints from the `data/json-data/` directory and transforming them into the `operational_data` hashes required by `BaseUnit` and `Robot`.

## 2. Search Strategy (The Priority Chain)
The service performs a fuzzy-to-exact match when requested for a unit. It resolves units in this specific order:
1. **Primary Type**: Matches the `unit_type` key in the JSON.
2. **Identifier**: Matches the `id` field.
3. **Name**: Matches the `name` string (e.g., "CAR-300").
4. **Aliases**: Scans the `aliases` array within the JSON for secondary names (e.g., "assembler").

## 3. Robot-Specific Categories
The service specifically monitors the following sub-paths for robot units:
* `robots_deployment`
* `robots_construction`
* `robots_maintenance`
* `robots_resource` (Harvesters)
* `robots_logistics`

## 4. Integration Guardrail
**Never hardcode operational_data.** When a service needs to create a robot, it must first call:
`lookup_data = Lookup::UnitLookupService.new.find_unit('car_300')`

The resulting `lookup_data` should then be merged with instance-specific data (like `identifier` and `owner`) before calling `create!`.

## 5. Blueprint Compliance
If a JSON blueprint is updated in `data/json-data/`, the `UnitLookupService` will reflect the changes immediately upon the next call, ensuring that all new robots inherit the updated stats (e.g., new battery capacity or mobility types).