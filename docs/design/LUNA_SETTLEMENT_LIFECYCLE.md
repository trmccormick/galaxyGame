# LUNA_SETTLEMENT_LIFECYCLE.md

## Overview
This document outlines the three-phase industrial lifecycle of a lunar settlement in Galaxy Game. It details the evolution from an Earth-dependent outpost to a self-sufficient In-Situ Resource Utilization (ISRU) hub and ultimate primary mass exporter for orbital Lagrange depots (EML-1). Reference this document when designing surface tech trees, lunar module catalogs, mass driver logistics, and early-game progression mechanics.

## Source Basis
This model is based on NASA Artemis/Lunar architecture plans and ISRU mineral extraction physics (ilmenite reduction, volatile polar cold-trap harvesting). It leverages Luna's shallow gravity well (0.166g) to position surface bases as the primary bulk mass source for deep space human activities.

## The 3-Phase Bootstrapping Loop

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      PHASE 1: IMPORT & BOOTSTRAP                        │
│  • Earth Imports: Water, Nitrogen, Heavy Hardware, Pre-built Modules    │
│  • Primary Activity: Excavation, Regolith Shielding, Base Setup         │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       PHASE 2: SURFACE ISRU LOOP                        │
│  • Regolith Processing ──> Oxygen, Fe/Al/Si Metals, Anorthite           │
│  • Polar Ice Mining ──> Water, Volatiles Extraction                     │
│  • Base Output: Self-Sustaining Habitat Mass, Solar Panels, Fuel        │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      PHASE 3: L1 DEPOT & EXPORT                         │
│  • Mass Driver / Space Elevator ──> Launch Excess Mass to Earth/Moon L1   │
│  • L1 Depot Assembly: Station Components, Orbital Habitats, Fuel Depots │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phase 1: Import & Bootstrap
- **Focus:** Initial survival and infrastructure setup.
- **Dependencies:** 100% reliant on Earth-shipped payloads for water, nitrogen, pre-built inflatable habitats, and life support consumables.
- **Primary Tasks:** Digging subterranean trenches, positioning inflatable modules inside lava tubes, and covering surface frames with raw regolith for radiation and thermal protection.

### Phase 2: Surface ISRU Loop
- **Focus:** Local resource independence.
- **Dependencies:** Taps into local lunar geology.
- **Primary Tasks:**
  - **Regolith Oxygen Extraction:** Baking ilmenite soil to extract abundant surface O2.
  - **Polar Ice Mining:** Harvesting crater cold traps for water ice, trace ammonia, and methane.
  - **Sintering Foundries:** Melting regolith into structural blocks and metal I-beams (Fe/Al).

### Phase 3: L1 Depot & Export
- **Focus:** Off-world commerce and deep space expansion.
- **Dependencies:** Full self-sufficiency in oxygen, water, and building materials.
- **Primary Tasks:** Operating electromagnetic Mass Drivers to shoot bulk water, fuel, and metal beams to Earth-Moon Lagrange Point 1 (EML-1), supplying orbital station construction.

## Core Module Catalog & Specific Mechanics

### 1. Sub-Surface & Shielding Modules
- **Regolith Excavator & Sintering Rig:** Collects raw soil and uses laser/microwave heating to create structural bricks.
- **Buried Inflatable Habitat Shell:** Inflatable cores placed under 3–5 meters of sintered regolith to mitigate cosmic radiation and thermal swings (-130°C to +120°C).

### 2. Operational Hazards & Bottlenecks
- **The Nitrogen Bottleneck:** Nitrogen (N2) is extremely scarce in lunar regolith. Every atmosphere leak represents a loss of an imported commodity that must be replaced via expensive shipments from Earth or Venus skimmers.
- **Regolith Dust Contamination:** Lunar regolith consists of sharp, electrostatically charged glass fragments. Surface airlocks suffer accelerated FilterWear and seal damage, requiring regular replacement of HEPA filters and lock seals.

## Game Parameters / Constants

| Constant Name | Value | Source | Engine Notes |
| :--- | :--- | :--- | :--- |
| `MIN_REGOLITH_DEPTH_METERS` | `3.0` | NASA Radiation Limits | Depth required to eliminate thermal cycling penalty |
| `ILENITE_O2_YIELD_PERCENT` | `0.10` | USGS Lunar Geology Data | Mass ratio of extractable O2 per kg processed regolith |
| `DUST_ABRASION_DECAY_RATE` | `0.02` | Apollo EVA Telemetry | Accelerated seal decay per surface airlock cycle |
| `MASS_DRIVER_LAUNCH_COST_GCC` | `5.0` | Orbital Delta-V Calculation | Cost per ton to fling mass from Luna to EML-1 |

## Rails Implementation Notes & Schema

- Luna tiles maintain state for burial depth and abrasive dust accumulation.
- **Models:** `SurfaceSettlement`, `LunarTile`, `IsruPlant`, `MassDriver`.

### JSON Schema (Luna Surface Habitat Unit)

```json
{
  "unit_id": "luna_shackleton_base_hab_02",
  "unit_type": "surface_buried_habitat",
  "location": {
    "body": "Luna",
    "site": "Shackleton_Crater_Rim",
    "depth_meters_under_regolith": 4.5
  },
  "structural_status": {
    "hull_integrity": 0.98,
    "regolith_shielding_effective": true,
    "micro_leak_rate_per_tick": 0.0005,
    "dust_contamination_level": 0.12
  },
  "eclss_loop": {
    "gravity_mode": "surface_centrifuge_assisted",
    "effective_g_force": 1.0,
    "water_recycling_efficiency": 0.97,
    "nitrogen_loss_rate_per_day": 0.15,
    "thermal_rejection_sink": "subsurface_conduction"
  },
  "local_buffer": {
    "oxygen_kg": 4500.0,
    "nitrogen_kg": 1200.0,
    "water_kg": 8900.0,
    "regolith_dust_filters_count": 14
  }
}
```

## Open Design Questions

- **Lava Tube Expansion Limits:** Should structural expansion inside natural lava tubes offer infinite volume at reduced construction costs, bounded only by map geometry?
- **Volatile Trapping Ratios:** How variable should ice purity levels be across different polar crater coordinates on the lunar map grid?

## Related Files

- `ECONOMIC_ENGINE_SURFACE_VS_ORBITAL.md` — The macro economic impact of the EML-1 mass driver export pipeline.
- `HABITATION_NODE_ARCHITECTURE.md` — Shared frame and panel slot specs.
- `ECLSS_PARAMETERS.md` — Baseline consumption constants.
