# WORMHOLE_NETWORK.md

## 4-Phase Tech Progression

1. **Settlement-Linked Wormholes**
   - Only natural wormholes are traversable.
   - Requires proximity to major settlements for safe passage.
   - No artificial stabilization; collapse risk is high.

2. **Natural Wormhole Stabilization**
   - Deployment of 'Wormhole Stabilization Satellites' enables stable, persistent links.
   - Exotic matter not required; relies on natural anchor points.
   - Used for early interstellar expansion (e.g., Alpha Centauri bridge).

3. **Artificial Wormhole Construction**
   - Artificial wormholes can be created between systems with sufficient energy and exotic matter.
   - Requires construction of stabilization stations and continuous energy input.
   - Enables custom network topology, but with higher maintenance and collapse risk.

4. **Intra-System Portals**
   - Advanced phase: portals within a single system (e.g., Sol) for rapid travel.
   - Requires mastery of artificial stabilization and abundant exotic matter.
   - Strict link limits (e.g., Three-Link Limit for Sol) enforced for network stability.

---

## Model & Constraint Summary
- Wormhole model supports `natural` (true/false) and `stability` (unstable, stabilizing, stable).
- Stabilization satellites are required for persistent links, especially for Alpha Centauri expansion.
- No explicit `stability_type` or `energy_source` attribute; natural/artifical is a boolean, and energy/exotic matter is implied in artificial construction logic.
- The 'Three-Link Limit' for Sol is not a model validation, but is likely enforced in controller/service logic.

## Known Gaps
- No direct model attribute for energy source or exotic matter.
- No hard-coded validation for link limits in the System model; likely enforced elsewhere.
- Stabilization satellite logic is present for Alpha Centauri bridge.

## See also: StarSim/TerraSim for network evolution and dynamic population.

## Live Query Pathfinding

The WormholeNavigator service provides dynamic, live-query pathfinding across the current wormhole network. It adapts to all Counterbalance and Stabilization states, always reflecting the latest network topology, link status, and mass constraints. No path is cached; every route proposal is recalculated in real time, ensuring accurate navigation as the network evolves.
