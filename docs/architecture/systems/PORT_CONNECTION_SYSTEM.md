# PORT_CONNECTION_SYSTEM.md

## Overview
This document defines the transition from legacy port-counting to a dynamic Bus-Topology. We are adopting a Hybrid/Bridge strategy to future-proof the architecture while ensuring existing CI/CD validation remains stable.

---

## 1. Handling Existing Schemas (Gas Storage)
For assets like `inflatable_gas_storage_bp.json` which already utilize a typed-port schema:
* **Resolution**: These assets will **stay as-is**. The `LegacyPortAdapter` is explicitly required to recognize this "pre-v1.9" schema and map it to the Bus-Topology framework without requiring a file-level migration.

## 2. Handling Port-less Units (Pressure Tank)
For units like `inflatable_pressure_tank` that currently have zero ports:
* **Resolution**: **Zero ports is a valid, handled state**. 
    * Under Bus-Topology, these units will not register to any bus.
    * The `LegacyPortAdapter` will explicitly return `0` for legacy port-count queries on these units, preventing the engine from forcing a non-zero port count.

---

## 3. The Three Options

### Option A: Pivot Now (Full Bus-Topology)
* **Action**: Immediate refactor of all systems to Bus-Topology.

### Option B: Fix MVP Blockers (Band-Aid)
* **Action**: Surgical fixes (e.g., increase port counts, rename units).

### Option C: The Hybrid "Bridge" (Recommended)
* **Action**: Implement a `LegacyPortAdapter` to bridge systems. New assets use the `v1.9` schema; legacy assets are projected by the adapter.

---

## Implementation Roadmap (Option C)

| Component | Est. Time | Task Description |
| :--- | :--- | :--- |
| **LegacyPortAdapter** | 2-3 hrs | Project `v1.9` schema into legacy port hashes; handle zero-port and legacy-typed cases. |
| **Engine Integration** | 1 hr | Wrap `BlueprintLookupService` to bridge schema resolution. |
| **Cryo Tank Migration** | 30 mins | Convert `inflatable_cryo_tank_bp.json` to `v1.9` schema. |
| **Gas Separator Task** | 1 hr | Shift task logic to `register_to_bus` calls. |
| **Validation** | 2 hrs | Run full `Luna V2` rake suite to confirm zero regressions. |

---

## Technical Specifications (v1.9)

### Blueprint Schema
Blueprints must include `connection_schema` to support dynamic fitting:
* `mounting_slots`: Physical slots (`type`, `location`, `fit_constraints`).
* `utility_ports`: Logical bus connections (`bus_id`, `link_type`).
* `storage_bays`: Cargo areas (`max_volume_m3`, `is_active_cargo`, `bus_power_draw_kw`).

### Operational Aggregation
Operational performance is a computed state:
* **Formula**: `Total_Operational_Data = Base_Craft_Data + Σ(Installed_Unit_Deltas) + Σ(Active_Cargo_Power_Draw)`
* **Pattern**: Recursive node-based aggregation; `Craft` is the root node; `Units`, `Rigs`, and `Modules` report deltas.

---

## Verification Checklist for Agents
- [ ] **Adapter Transparency**: Legacy engines detect "ports" (even 0) without knowing they are dynamically generated.
- [ ] **Dual-Mode Resolution**: Prioritize `Bus` registration if `v1.9` schema exists.
- [ ] **Regression Test**: Confirm legacy assets (including gas storage) function identically.
