# HABITATION_NODE_ARCHITECTURE.md

## Overview
This document defines the unified object architecture, structural frame specifications, and modular panel slot system shared across all human habitats in Galaxy Game. Whether instantiated as a lunar crater base, an orbital Lagrange depot, or an interplanetary cycler, all habitats utilize identical structural logic and interface contracts. Reference this document when implementing habitat models, tile map renderers, or docking connection handlers.

## Source Basis
This architecture leverages modular software patterns and standardized aerospace structural engineering concepts. By utilizing unified I-beam frame grids and interchangeable panel slots, the codebase eliminates duplicate logic between surface and space entities while enabling UI asset reuse across different environmental contexts.

## Architectural Overview

```
                          ┌───────────────────────────┐
                          │     HABITATION NODE       │
                          │ (Base Hull & ECLSS Loop)  │
                          └─────────────┬─────────────┘
                                        │
             ┌──────────────────────────┼──────────────────────────┐
             ▼                          ▼                          ▼
   ┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
   │   LUNA SURFACE    │      │   CYCLER CRAFT    │      │    L1/L2 DEPOT    │
   │  • Regolith Shield│      │  • Docked Skimmers│      │  • Docked Skimmers│
   │  • Fixed Sinks    │      │  • RCS Spin Array │      │  • Zero-G Framing │
   └───────────────────┘      └───────────────────┘      └───────────────────┘
```

### 1. Structural Frame & I-Beam Grid
All habitation nodes are constructed around a standardized structural grid made of heavy structural I-beams (sourced from titanium or refined lunar anorthite). This grid provides mounting slots for internal ECLSS machinery and external environmental panels.

### 2. The Interchangeable Panel System
Each grid slot on a node's exterior perimeter must be fitted with a panel type suited for its local environment:

- **Transparent Glass Panels:** Low cost, high crew morale bonus. Offers zero radiation protection and high thermal transfer. Suitable only for interior plazas or underground shielded caverns.
- **Rugged Armor Panels:** High structural integrity and micrometeorite resistance. Expensive; used on outer cycler hulls.
- **Photovoltaic Integrated Panels:** Generates power directly from solar exposure but possesses lower structural integrity.
- **Sintered Regolith Shield Panels:** Locally manufactured surface panels deployed over I-beam frames to insulate against radiation and extreme thermal swings.

### Environmental & Structural Comparison Matrix

| System / Feature | Luna Surface Base | Deep-Space Cycler | Orbital Depot (EML-1) |
|---|---|---|---|
| Structural Frame | Standard I-Beam (Buried/Surface) | Standard I-Beam (Spin Rigged) | Standard I-Beam (Open Lattice) |
| Docking Interface | Surface Pad / Tower | Universal Umbilical Port | Universal Umbilical Port |
| Artificial Gravity | Local 0.166g + Centrifuge | Rotational Hull / Tether (1g) | Microgravity (0g) / Centrifuge |
| Thermal Dissipation | Conduction into crust | External Radiator Wings | External Radiator Wings |
| Primary Shielding | Sintered Regolith / Lava Tube | Water Walls / Lead Polymer | Water Tanks / Armor Plates |
| Thermal Cycling Risk | Low (if buried) | Extreme (Direct Solar Delts) | Moderate (Orbital Shadowing) |

## Unified Docking & Cargo Transfer Architecture

All orbiting nodes and surface towers expose a standardized Universal Docking Interface. When volatile collection craft (e.g., Atmospheric Skimmers) dock with any node, the transaction executes through a single unified service:

```
Skimmer Cargo Buffer (N2 / O2) =[Docking Umbilical]=> Node ECLSS Storage Buffer

                          ┌────────────────────────┐
                          │     SKIMMER CRAFT      │
                          │ (Volatile/Gas Hauler)  │
                          └───────────┬────────────┘
                                      │
                         [Standard Docking Interface]
                                      │
             ┌────────────────────────┴────────────────────────┐
             ▼                                                 ▼
┌─────────────────────────┐                       ┌─────────────────────────┐
│     CYCLER HABITAT      │                       │     EML-1 DEPOT HAB     │
│ Transfer: N2/O2/Water   │                       │ Transfer: N2/O2/Water   │
│ Buffer: Gas Top-Off     │                       │ Buffer: Market Storage  │
└─────────────────────────┘                       └─────────────────────────┘
```

## Game Parameters / Constants

| Constant Name | Value | Source | Engine Notes |
| :--- | :--- | :--- | :--- |
| `IBEAM_GRID_SLOT_CAPACITY` | `100` | Architectural Spec | Max module units per frame cluster |
| `GLASS_PANEL_MORALE_BONUS` | `+0.15` | Habitat Comfort Index | Applied to crew inside transparent zones |
| `GLASS_PANEL_RADIATION_MULT` | `3.5` | Radiation Transport Model | Increases radiation exposure penalty |
| `ARMOR_PANEL_INTEGRITY` | `500` | Structural Test Data | Hit points against micro-meteorites |
| `UNIVERSAL_DOCK_FLUID_RATE` | `50.0` | Umbilical Flow Spec | Transfer rate (kg/second) for gases/liquids |

## Rails Implementation Notes & Data Schemas

- Nodes use polymorphic associations or single-table inheritance to manage shared slot behaviors.
- **Models:** `HabitationNode`, `StructuralSlot`, `InstalledPanel`, `DockingPort`.

### JSON Schema (Node Configuration Data)

```json
{
  "node_id": "node_cycler_hermes_01",
  "base_tileset_id": "i_beam_frame_large",
  "environment_context": "cycler_transit",
  "structural_integrity": {
    "hull_wear": 0.05,
    "total_slots": 4,
    "installed_panels": [
      {"slot_position": "north", "type": "panel_solar_integrated", "durability": 0.92},
      {"slot_position": "south", "type": "panel_transparent_cheap", "durability": 0.88},
      {"slot_position": "east", "type": "panel_rugged_armored", "durability": 0.99},
      {"slot_position": "west", "type": "panel_rugged_armored", "durability": 0.99}
    ]
  },
  "docking_ports": [
    {
      "port_id": "port_01",
      "interface_type": "skimmer_universal_umbilical",
      "status": "docked",
      "connected_craft_id": "skimmer_venus_04"
    }
  ]
}
```

## Open Design Questions

- **Dynamic Panel Destruction:** Should catastrophic panel failures (e.g., meteor impact on a glass panel) instantly depressurize adjacent grid sections or trigger a timed emergency response window?
- **Modular Visual Kitbashing:** How should the 2D tile system visually render mixed panel configurations on a single sprite frame without generating excessive texture assets?

## Related Files

- `ECLSS_PARAMETERS.md` — Micro-leak and thermal cycling formulas applied to panel types.
- `ECONOMIC_ENGINE_SURFACE_VS_ORBITAL.md` — Explains resource supply chains for structural panels.
- `ECLSS_SYSTEM_ARCHITECTURE.md` — Details life support subsystems housed inside node frames.
