# ECLSS_SOURCE_REFERENCE.md

## Overview
This document serves as the primary foundational reference for the ECLSS mechanics and resource dynamics in Galaxy Game. It documents real-world spaceflight baselines—specifically from the International Space Station (ISS) and historical NASA programs—and maps planetary services to their mechanical hardware equivalents. Reference this document to understand the engineering rationale behind game design parameters, failure modes, and industrial balancing decisions.

## Source Basis
This document aggregates operational data, historical failure logs, and environmental control research from NASA, Apollo, Gemini, and ISS technical reports.

## Historical Mission Paradigms

```
  SHORT-DURATION MISSIONS               LONG-DURATION MISSIONS
  ┌───────────────────────────────┐     ┌───────────────────────────────┐
  │  • Duration: Days to Weeks    │     │  • Duration: Years to         │
  │  • Goal: Prevent Death        │ VS  │    Generations                │
  │  • Strategy: Store Supplies,  │     │  • Goal: Sustain Life & Society│
  │    Endure Discomfort          │     │  • Strategy: Total Systemic   │
  │  • Safety Net: Earth is Close │     │    Recycling & Self-Reliance  │
  └───────────────────────────────┘     └───────────────────────────────┘
```

### Mercury/Gemini/Apollo (Short-Duration)
Vehicles acted as simple survival capsules. They stored all consumable supplies upfront and relied on immediate abort options if systems failed.

### ISS (Hospital Model)
Keeps crew alive through intensive ground supervision, continuous cargo resupply flights, and active repair shifts.

### Deep Space Habitats (Civilization Model)
Closed-loop ecosystems that must generate their own resources, repair internal components, and operate independently without Earth resupply or abort safety nets.

## Planetary Services vs. Mechanical Equivalents

Earth performs continuous life support services automatically through natural planetary buffers. Space habitats must replace every natural service with high-maintenance mechanical hardware:

| Natural Planetary Service | Earth's Mechanism | Habitat Mechanical Equivalent |
|---|---|---|
| Water Purification | Solar evaporation, precipitation, rock percolation | Distillation assemblies, ion-exchange beds, catalytic reactors |
| Atmospheric Recycling | Global photosynthesis, oceanic algae | Water electrolysis arrays, Sabatier reactors, molecular sieves |
| Radiation Shielding | Planetary magnetosphere, dense atmosphere | Compacted regolith layers, thick water walls, heavy metal shielding |
| Thermal Dissipation | Atmospheric convection, ocean currents, planetary mass | Coolant pumps, heat pipes, external radiator panel arrays |
| Gravity Realism | Planetary mass (9.81 m/s^2) | Centripetal acceleration via continuous hull rotation |
| Waste Processing | Biological decay, soil microbiomes, tectonic cycles | Bioreactors, composter units, chemical oxidation beds |

## Real-World Operational Failure Cases

Historical ISS hardware issues serve as direct inspiration for random station events and maintenance sinks in the game engine:

- **Micro-Leaks under Thermal Cycling:** Millimeter-wide joints leak small volumes of atmosphere continuously. Searching for microscopic cracks across expansive surface areas while metals expand and contract under solar deltas is an ongoing operational challenge.
- **Microgravity Toilet & Distillation Clogging:** Solid precipitation in high-acid urine blocks distillation assemblies, requiring manual cleaning and filter replacement.
- **Scrubber Subsystem Outages:** Mechanical failures in molecular sieve beds cause rapid CO2 buildup, inducing severe headaches, fatigue, and cognitive decline in crew members.

## Cascading Interdependence Schema

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

## Related Files

- `ECLSS_PARAMETERS.md` — The concrete game constants derived from these sources.
- `ECLSS_SYSTEM_ARCHITECTURE.md` — Hardware implementation of these planetary service replacements.
- `ECONOMIC_ENGINE_SURFACE_VS_ORBITAL.md` — How mechanical inefficiencies create macro-economic loops.
