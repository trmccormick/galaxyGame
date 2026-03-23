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
