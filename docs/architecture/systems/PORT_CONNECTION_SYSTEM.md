# PORT CONNECTION SYSTEM — V2.1

## Overview
This document defines the canonical port connection architecture for galaxy_game. The system uses **`connection_schema`** with **`mounting_slots`** as the primary mechanism for defining physical and logical connections between craft, modules, rigs, and units.

---

## 1. Canonical Schema: `connection_schema` + `mounting_slots`

All V2.1+ operational data files (craft, modules, rigs) MUST include a `connection_schema` block:

```json
"connection_schema": {
  "mounting_slots": [
    {
      "slot_id": "ext_mod_01",
      "bus_id": "bus_scrubber_01",
      "type": "module_port",
      "location": "intake_manifold"
    },
    {
      "slot_id": "int_mod_01",
      "bus_id": "bus_process_01",
      "type": "production_port",
      "location": "core_process"
    },
    {
      "slot_id": "pwr_mod_01",
      "bus_id": "power_bus_a",
      "type": "energy_port",
      "location": "dorsal"
    }
  ]
}
```

### Slot Types

| `type` | Purpose | Typical `bus_id` prefix |
|---|---|---|
| `module_port` | Physical module mounting point | `bus_<component>_01` |
| `production_port` | Output to downstream processing | `bus_process_01` |
| `energy_port` | Power connection point | `power_bus_<a|b>` |

### Slot Fields

| Field | Type | Description |
|---|---|---|
| `slot_id` | string | Unique identifier for this mounting slot |
| `bus_id` | string | Target bus that the slot connects to |
| `type` | string | One of: `module_port`, `production_port`, `energy_port` |
| `location` | string | Physical location on the craft/module (e.g., `intake_manifold`, `core_process`, `dorsal`) |

---

## 2. Recommended Fit — Count-Based Bill of Materials

The `recommended_fit` block uses **count-based** specifications, NOT per-module bus_id assignments:

```json
"recommended_fit": {
  "modules": [
    { "id": "harvester_control_module", "count": 1, "category": "control" },
    { "id": "atmospheric_harvester_system", "count": 1, "category": "harvester" },
    { "id": "co2_splitter", "count": 2, "category": "production" }
  ],
  "units": [
    { "id": "methane_engine", "count": 6, "category": "propulsion" },
    { "id": "lox_tank", "count": 1, "category": "fuel" }
  ],
  "rigs": []
}
```

**Key rules:**
- Each entry specifies `id`, `count`, and `category` only.
- The engine resolves which `mounting_slot` each module/unit/rig maps to at runtime via the craft's `connection_schema`.
- No bus_id is specified in `recommended_fit` — that is handled by the adapter layer.

---

## 3. LegacyPortAdapter — Implemented

The **LegacyPortAdapter** is production code that bridges V2.1 topology-aware assets with legacy port-counting systems:

| Component | Status | Notes |
|---|---|---|
| `LegacyPortAdapter` | **Implemented** | Bridges `connection_schema` → legacy port hashes for backward compatibility |
| V2.1 Registry | **Implemented** | Reads `mounting_slots` from operational data files |
| TaskTemplates | **Implemented** | Uses count-based `recommended_fit`, no hardcoded ports |
| Validation | **Complete** | `luna_mission` rake suite recognizes bridged ports via adapter |

The adapter:
1. Reads `connection_schema.mounting_slots` from V2.1 assets.
2. Maps each module/unit/rig in `recommended_fit` to the appropriate slot by category and count.
3. Projects the mapping into legacy port hashes for backward-compatible validation.
4. Does NOT modify legacy task logic — the bridge is transparent to existing harnesses.

---

## 4. Operational Aggregation

Total operational data for a craft is computed by the engine:
- Sum all `input_resources` and `output_resources` from mounted modules/units/rigs.
- Apply efficiency factors from each module's `operational_properties`.
- Aggregate power consumption/generation across all energy ports.

---

## 5. Version Compliance

| Template | Version | connection_schema Required |
|---|---|---|
| `craft_operational_data` | v1.7 and earlier | No (legacy port-counting) |
| `craft_operational_data` | **v2.1+** | **Yes** |
| `unit_operational_data` | v1.3+ | Optional (for modules that connect to craft) |

---

## 6. Verification Checklist for Agents

- [ ] Craft/module/rig files include `connection_schema` with `mounting_slots` array.
- [ ] Each slot has valid `slot_id`, `bus_id`, `type`, and `location`.
- [ ] `recommended_fit` uses count-based format (no bus_id per module).
- [ ] LegacyPortAdapter is implemented — no "pending" status references.
- [ ] No `$variable` interpolation syntax (`$target_bus_id`, `$slot_location`) — these are out of scope.
- [ ] No `utility_ports` references — replaced by `mounting_slots`.
