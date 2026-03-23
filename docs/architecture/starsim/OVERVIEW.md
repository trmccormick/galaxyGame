# StarSim Architecture — OVERVIEW

## The Weathering Engine
Intent: Regress 'Goal-State' (Lush) maps into Barren starting states using NASA-derived erosion and weathering patterns. This enables realistic planetary evolution and supports both forward (terraforming) and backward (regression) simulation.

## Fidelity Tiers

### Tier 1 (Static)
- Full JSON (Sol system)
- All planetary and system data is precomputed and stored as static JSON.

### Tier 2 (Hybrid)
- Local Bubble (e.g., Alpha Centauri)
- Static data for known systems, procedural gap-filling for missing or uncertain data.

### Tier 3 (Procedural)
- Exotic systems (beyond Local Bubble)
- Fully procedural generation using 4X-balanced heuristics for playability and diversity.

## Dynamic Population
Logic for spawning transient objects (Asteroids, KBOs, Comets, Interstellar Visitors) that are not permanently stored in the base seed. These objects have lifespans and spawn rates governed by simulation rules, supporting dynamic and evolving system content.

---

*This document is the master reference for StarSim's architecture, weathering logic, fidelity tiers, and dynamic population mechanisms.*

## Known Issues & Mitigation

- **Civ4 Shoreline Flooding:** Current NASA/Civ4 fusion logic can result in unrealistic shoreline flooding and water encroachment on land tiles. This is a known artifact of the Civ4 tile mapping and procedural noise. 
- **Mitigation:** Implementation of a Regression Filter (see TerraSim) is required to correct shorelines and ensure realistic land/water boundaries. All future terrain generation must route through this filter.
