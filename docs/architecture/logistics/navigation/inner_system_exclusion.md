# INNER_SYSTEM_EXCLUSION.md

## Orbital Protection Rule

Wormholes and interstellar links are prohibited from spawning within the 'Inner System Exclusion Zone'—typically defined as the region inside the Gas Giants (e.g., inside 5 AU, the Asteroid Belt in Sol). This protects habitable worlds from catastrophic gravitational and tidal disruptions.

- **Constant:** While no explicit `MIN_STABLE_DISTANCE_FROM_STAR` constant was found, orbital generation logic and planet classification routines in StarSim enforce minimum distances for major bodies and likely prevent wormhole endpoints from being placed inside the exclusion zone.
- **Why at the Gas Giants?** Gas Giants act as natural anchors for stable wormhole endpoints, minimizing risk to inner rocky planets.

## Tidal Signature Risk

- No direct 'Tidal Stress' or 'Earthquake' calculation is present in TerraSim, but biosphere and geosphere simulation services do factor in star distance and planetary type for climate and habitability.
- The risk of 'Atmospheric Stripping' or seismic disruption from a nearby wormhole is a documented design concern, but not yet implemented as a simulation hook.

## Summary of Exclusion Math
- Orbital and accretion logic in StarSim uses AU-based distance checks and orbital zone classification to keep major bodies and links outside the inner system.
- No hard-coded penalty or event for tidal stress from wormholes, but the architecture supports future hooks for these effects.

---

**See also:** WORMHOLE_NETWORK.md for network topology and tech progression.
