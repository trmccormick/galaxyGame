# TerraSim Architecture — OVERVIEW

## TerraSim Core
TerraSim is responsible for simulating planetary surface and climate evolution. Its core function is to take a StarSim-generated heightmap (representing the 'goal state' or future terraformed world) and apply regression logic—using Civ4/FreeCiv-inspired patterns—to simulate the transition from a lush, habitable state back to a barren, pre-terraforming baseline.

- **Regression/Weathering:**
  - No explicit public method named 'regress' or 'weather', but weathering and state-shifting are handled via:
    - `weathering_rate` in Geosphere/Biosphere interfaces
    - `state_distribution` in HydrosphereSimulationService (solid/liquid/vapor transitions)
    - `determine_state` and `calculate_state_distributions` for material and water phase changes
  - Seasonal and long-term state changes are handled in PlanetUpdateService (e.g., ice ages, extreme weather)

- **Painting/Regressing the World State:**
  - TerraSim currently 'paints' the world state by updating state distributions (e.g., water/ice/vapor) and material states in geosphere/hydrosphere layers, but does not yet implement a full regression filter from lush to barren.

## Radiolytic Degradation Math
- The radiolytic degradation logic (resource loss over time due to radiation) found in the StarSim archives is not present in TerraSim and is more appropriate for StarSim's resource/decay modeling, not surface painting.

## Intent Gaps
- No explicit regression filter or lush-to-barren state-shifting method exists yet; only indirect weathering and state updates.

---

*This document summarizes the current structure and intent of TerraSim, highlighting the need for a direct regression/weathering engine for world state transitions.*

## Known Issues & Mitigation

- **Civ4 Shoreline Flooding:** The current NASA/Civ4 fusion process can cause excessive shoreline flooding and unrealistic water/land boundaries. This is a known issue with Civ4 tile mapping and procedural noise.
- **Mitigation:** A dedicated Regression Filter is required to post-process all generated terrain, correcting shorelines and enforcing realistic transitions. This filter is a critical dependency for all Biome and DigitalTwin work.
