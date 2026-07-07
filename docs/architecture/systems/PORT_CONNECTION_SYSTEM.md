# PORT_CONNECTION_SYSTEM.md

## Overview
This document defines the architecture for the transition from legacy port-counting to a dynamic Bus-Topology. We are utilizing a Hybrid/Bridge strategy to ensure that new **V2.1** topology-aware assets coexist with legacy hardcoded connections.

---

## 1. The Bridge Strategy (Revised)
To resolve the connection fragmentation in the `luna_mission` Rake suite, the system now distinguishes between **Topology Registration** and **Legacy Projection**:
* **V2.1 Tasks**: Use `register_to_bus` to attach to a `bus_id`.
* **LegacyPortAdapter**: Intercepts these registrations. If the unit is identified as "Legacy," the adapter projects the registration into the expected `port` hashes, allowing the existing Rake harness to validate the connection without modifying legacy task logic.

## 2. Updated Topology Logic
* **Task/Registry Decoupling**: Tasks no longer hardcode connections. Registry files now inject specific `target_bus_id`, `mounting_slot`, and `slot_location` parameters.
* **Operational State**: "Active" states are now derived from successful bus registration rather than manual state-setting.

## 3. Revised Implementation Roadmap

| Component | Status | Focus |
| :--- | :--- | :--- |
| **LegacyPortAdapter** | Refined | Bridging `register_to_bus` calls for the Rake harness. |
| **V2.1 Registry** | Updated | Parameter injection for `bus_id` and `slot_location`. |
| **TaskTemplates** | Updated | Removed hardcoded legacy ports in favor of dynamic bus registration. |
| **Validation** | Pending | Confirming `luna_mission` rake suite recognizes bridged ports. |

---

## Technical Specifications (v1.9 / v2.1 Hybrid)

### Blueprint Schema
Blueprints must include `connection_schema` to support dynamic fitting:
* **`mounting_slots`**: Define physical connection points for units like `Solar Expansion Rig`.
* **`utility_ports`**: Used by the adapter to map `bus_id` links to legacy ports.

### Operational Aggregation
* **Computed State**: `Total_Operational_Data` is now computed by the engine by summing units registered to specific `bus_id` nodes.

---

## Verification Checklist for Agents (Updated)
- [ ] **Adapter Transparency**: Legacy engines successfully detect "ports" via the `LegacyPortAdapter` projection.
- [ ] **Dynamic Injection**: Registry files correctly populate `$target_bus_id` and `$slot_location` variables for V2.1 tasks.
- [ ] **Regression Test**: Confirm that shifting to `register_to_bus` does not trigger "port not found" errors in legacy mission plans.
