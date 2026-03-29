# Intent: Units::Robot Implementation & Lifecycle

## 1. Architectural Role
A `Units::Robot` is a specialized, autonomous `BaseUnit`. Unlike static infrastructure (like a Habitat), a Robot is a mobile actor that consumes power based on its physical configuration and executes tasks from a managed queue.

## 2. The Lifecycle: Item vs. Unit
Robots exist in two distinct states within the game engine. Documentation and services must distinguish between them to avoid validation errors.

### State A: The Crated Item (Dormant)
* **Location**: `inventory.units` (Manifest) or `InventoryItem` (Database).
* **Behavior**: Static asset. No power consumption. No `identifier`.
* **Data**: Minimal metadata (e.g., `{ "name": "CAR-300", "count": 1 }`).

### State B: The Active Unit (Live)
* **Location**: `base_units` table, attached to a `Settlement` or `Craft`.
* **Behavior**: Active AI participant. Consumes battery. Has an `identifier`.
* **Transition**: Must be "unpacked" from an Item. This involves destroying the Item and calling `Units::Robot.create!`.

## 3. Mandatory Creation Contract
When activating a robot (e.g., via `EscalationService` or `UnpackingService`), the following attributes are **strictly required** to pass `BaseUnit` and `Robot` validations:

| Attribute | Type | Requirement | Origin |
| :--- | :--- | :--- | :--- |
| `name` | String | Required | Inherited from Blueprint (e.g., "CAR-300") |
| `identifier` | String | Required | Generated at Activation (e.g., `ROBOT-XXXX`) |
| `unit_type` | String | Required | Always `"robot"` |
| `owner` | Polymorphic | Required | The parent `Settlement` or `Organization` |
| `operational_data` | JSONB | **Critical** | Must contain `mobility_type` |

### The `operational_data` Payload
The `Robot` model performs a custom validation on `mobility_type`. This must be seeded during `create!`:
* **`mobility_type`**: `wheels`, `legs`, `treads`, or `hover`.
* **`task_queue`**: Should be initialized as an empty array `[]`.
* **`battery_level`**: Usually initialized to `100`.

## 4. Robot Variants & Asset Mapping
The `unit_type` and `model` in the operational data map directly to the 2:1 isometric sprite registry.

| Model | Role | Visual Features |
| :--- | :--- | :--- |
| **CAR-300** | Utility / Assembly | 6 wheels, 2 manipulator arms, orange/white paint. |
| **SMR-500** | Mapping / LIDAR | Compact, blue-glowing lenses, rotating turret. |
| **HRV-400** | Harvesting | Front scoop, large rear hopper, weathered metal. |
| **MRR-100** | Maintenance | Welding torch arm, tool-rack backplate. |

## 5. Functional Behaviors
Every active Robot inherits logic from the following modules:
* **`EnergyManagement`**: Handles power draw.
* **`BatteryManagement`**: Tracks charge levels.
* **`RechargeBehavior`**: Automates a "Needs Recharge" state when battery < 20%.
* **`StorageOperations`**: If the robot has a `storage` block in `operational_data`, it can use `store_resource` to act as a mobile harvester.

## 6. Implementation Guardrails
* **Inventory Check**: Do not call `Units::Robot.create!` without verifying the settlement or craft inventory contains the corresponding item.
* **Unpacking Protocol**: Use the `UnpackingService` (or equivalent `HasUnits` logic) to handle the `Item -> Unit` transition to ensure metadata is mapped correctly.
* **Association**: Always create through a collection (e.g., `settlement.base_units.create!`) to ensure the `owner` and `location` are inherited.