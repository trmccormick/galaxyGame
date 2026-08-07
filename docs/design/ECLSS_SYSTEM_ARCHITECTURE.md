# ECLSS_SYSTEM_ARCHITECTURE.md

## Overview
This document details the functional architecture of the six interconnected life support subsystems in Galaxy Game. It outlines resource transformation loops, hardware module requirements, and the event-driven cascading failure model that propagates localized mechanical breakdowns across entire station ecosystems. Reference this document when implementing backend ECLSS processing pipelines, hardware failure events, or life support module chains.

## Source Basis
This model is built upon closed-loop life support principles from NASA space station documentation and system interdependence theory. It replaces abstract "life support percentages" with concrete inputs, outputs, and hardware dependencies.

## The 6 Core Life Support Loops

```
                  ┌─────────────────────────────────────────┐
                  │          POWER & THERMAL LOOP           │
                  │   (Reactor / Solar ──> Radiator Grid)   │
                  └────────────────────┬────────────────────┘
                                       │ Power & Heat Management
     ┌─────────────────────────────────┼─────────────────────────────────┐
     ▼                                 ▼                                 ▼
┌──────────────┐              ┌─────────────────┐              ┌──────────────────┐
│ WATER LOOP   │              │ ATMOSPHERE LOOP │              │  FOOD/AGRI LOOP  │
│ Gray/Black   │ ──Water───>  │ Electrolysis &  │ ──Oxygen───> │ Hydroponics &    │
│ Distillation │ <──Moisture─ │ Sabatier React. │ <──CO2────── │ Biomass Recycler │
└──────────────┘              └─────────────────┘              └──────────────────┘
     │                                 │                                 │
     └─────────────────────────────────┼─────────────────────────────────┘
                                       │
                                       ▼
                  ┌─────────────────────────────────────────┐
                  │            GRAVITY & HEALTH             │
                  │ (Rotation Hull ──> Crew Maintenance/SANS│
                  └─────────────────────────────────────────┘
```

### 1. Water Loop (Hydration & Electrolysis)
- **Commodities:** GrayWater, BlackWater (Brine/Urine), PurifiedWater.
- **Hardware:** WaterDistillationUnit, BrineProcessor, IonExchangeFilter.
- **Mechanic:** Processes human waste and condensation back into drinkable water. Suffers an unrecoverable loss per cycle, requiring raw water ice resupply.

### 2. Atmospheric Loop (Gases & Pressure)
- **Commodities:** Oxygen (O2), Nitrogen (N2), CarbonDioxide (CO2), Methane (CH4).
- **Hardware:** ElectrolysisArray, SabatierReactor, MolecularSieveScrubber, HullSealant.
- **Mechanic:** Water electrolysis generates O2 while Sabatier reactors synthesize methane byproduct from exhaled CO2 and hydrogen. Micro-leaks bleed nitrogen and oxygen, requiring active pressure monitoring.

### 3. Thermal Loop (Heat Management)
- **Commodities:** ThermalCoolant, HeatUnits (kW).
- **Hardware:** HeatExchanger, CoolantPump, RadiatorPanel.
- **Mechanic:** Electronics, lighting, and human metabolic activity generate excess heat. Undersized or damaged radiator arrays cause internal temperatures to rise, accelerating food spoilage and increasing crew stress.

### 4. Food & Biomass Loop (Agriculture)
- **Commodities:** NutrientSlurry, CropBiomass, Rations.
- **Hardware:** HydroponicTray, VerticalFarmArray, ComposterUnit.
- **Mechanic:** Hydroponic units consume purified water, fertilizer, and CO2 to generate rations and supplementary O2 production.

### 5. Gravity & Health Loop
- **Commodities:** CalciumSupplements, MedicalSupplies.
- **Hardware:** CentrifugalHabitatRing, RCSThrusterArray (for spin upkeep), MedicalBay.
- **Mechanic:** Zero gravity triggers progressive health penalties (1%/month bone loss, SANS vision damage). Hull rotation eliminates decay but requires RCS propellant or mechanical bearing maintenance.

### 6. Structural Integrity & Micro-Leak Loop
- **Commodities:** HullSealant, SparePanels.
- **Hardware:** UltrasonicSensorArray, MaintenanceDroneBay.
- **Mechanic:** Continuous tracking and patching of millimeter-wide cracks caused by micrometeorites and thermal expansion cycling.

## Cascading Failure Logic Model

Unlike open terrestrial ecosystems, closed space habitats link all subsystems directly. A failure in one module cascades through the network if unaddressed:

```
[ Clogged Water Filter ]
          │
          ▼
[ Reduced Crop Irrigation ]
          │
          ▼
[ Lower Oxygen Output from Plants ]
          │
          ▼
[ Increased Load on Mechanical Electrolysis ]
          │
          ▼
[ Higher Power Consumption ]
          │
          ▼
[ Increased Waste Heat Production ]
          │
          ▼
[ Thermal Radiator Stress & Internal Warming ]
          │
          ▼
[ Accelerated Microbial Oxygen Consumption in Soil ]
          │
          ▼
[ Further Oxygen Level Drop ]
```

## Game Parameters / Constants

| Constant Name | Value | Source | Engine Notes |
| :--- | :--- | :--- | :--- |
| `SABATIER_METHANE_YIELD_RATIO` | `0.25` | Stoichiometric Data | CH4 generated per unit CO2 processed |
| `ELECTROLYSIS_POWER_KW_PER_KG` | `4.5` | ISS Performance Specs | Power required to extract 1 kg O2 from water |
| `HYDROPONIC_O2_YIELD_KG_DAY` | `0.8` | Plant Physiology Data | O2 produced per active farm tray daily |
| `MAX_CABIN_TEMP_CELSIUS` | `38.0` | Crew Safety Standard | Threshold where heat-induced crop failure begins |

## Rails Implementation Notes

- The system uses an event-driven tick architecture where each module processes inputs from node storage and writes outputs back to the buffer.
- **Models:** `EclssModule`, `StorageBuffer`, `SystemFailureEvent`.

### JSON Data Schema (Full Node ECLSS State)

```json
{
  "node_id": "station_alpha_habitat_01",
  "hull_integrity": 0.94,
  "micro_leak_rate_per_tick": 0.002,
  "eclss_status": {
    "water_recovery_efficiency": 0.98,
    "co2_scrubber_operational": true,
    "radiator_capacity_kw": 450,
    "current_heat_load_kw": 410
  },
  "storage_buffers": {
    "water": 1250.5,
    "oxygen": 840.0,
    "nitrogen": 3200.0,
    "co2": 45.2,
    "waste_sludge": 88.1
  }
}
```

## Open Design Questions

- **Graph vs. Procedural Ticks:** Should failure cascades be calculated using a directed acyclic graph (DAG) network or through sequential procedural buffer checks?
- **Fire and Contamination Spreading:** How should localized toxic gas spikes (CO or ammonia) spread through adjacent module ducting?

## Related Files

- `ECLSS_PARAMETERS.md` — Quantitative baseline numbers for all formulas.
- `HABITATION_NODE_ARCHITECTURE.md` — Physical frame housing these ECLSS modules.
- `LUNA_SETTLEMENT_LIFECYCLE.md` — ECLSS deployment across Luna phases.
