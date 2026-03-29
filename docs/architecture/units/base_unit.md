# Architecture Intent: Units::BaseUnit

## 1. Role & Responsibility
`Units::BaseUnit` is the abstract base class for all physical entities within a Settlement or Craft. It provides a standardized interface for persistence, location tracking, and resource storage. 

## 2. Core Persistence (The Database Contract)
Any subclass (Robot, Habitat, Extractor) must satisfy these ActiveRecord validations:

| Attribute | Type | Requirement | Description |
| :--- | :--- | :--- | :--- |
| `identifier` | String | Required | Unique WTC registry ID (e.g., IHU001). |
| `name` | String | Required | Human-readable label. |
| `unit_type` | String | Required | Categorical slug (e.g., "housing_unit"). |
| `owner` | Polymorphic | Required | Reference to a `Settlement` or `Organization`. |

## 3. Lifecycle Hooks
* **`after_create :create_inventory`**: Every `BaseUnit` is automatically assigned an `Inventory` record upon creation. This allows units to "hold" items or materials regardless of their specific type.

## 4. Operational Data (The JSONB Black Box)
The `operational_data` field is used to store complex, nested state that doesn't belong in the flat database schema. 
* **Storage Logic**: If `operational_data` contains a `storage` key, the unit gains access to `store_resource` and `available_capacity` methods.
* **Compatibility**: Material types (e.g., 'liquid' vs 'gas') are validated against the `storage -> type` defined in this hash.

## 5. Location & Association
* **`attachable`**: A polymorphic association allowing a unit to be "plugged into" a parent (a Settlement or a Craft).
* **`current_location`**: Direct access to the `CelestialLocation` or `SpatialLocation` via helper methods.

## 6. Storage Operations
The `BaseUnit` handles the logic for moving materials into the physical world:
* **`store_item`**: Synchronizes the internal `Inventory` with the `operational_data['resources']['stored']` hash.
* **`store_on_surface`**: Private logic that allows a unit to dump materials (like processed regolith) into a settlement's surface storage if the unit's internal capacity is full.

## 7. Implementation Note
When creating units via services (like `EscalationService`), use the keyword argument pattern. Avoid positional arguments unless a specific subclass (like an older Robot override) explicitly requires them.