# Logic: Asteroid & Moon-to-Station Conversion

## 1. The "Mars Pattern" vs. "Earth Pattern"
- **Earth Pattern**: High-cost assembly of station components launched from a gravity well.
- **Mars Pattern (Preferred)**: Identifying local Phobos/Deimos-sized bodies and converting them into stations/depots to serve as orbital anchors before surface descent.

## 2. Conversion Mechanics (Rule B)
The conversion process follows the "Rule B" hollowing logic, where the natural mass of the body is repurposed into the station's structural shell.

- **Mass-to-Hull Efficiency**: 30%. For every 1,000kg of asteroid mass processed, 300kg is converted into usable internal hull/deck plating.
- **Resource Recovery**: The remaining 70% of mass is either vented as slag or processed into bulk shielding (radiation protection) and propellant.
- **Volume Scaling**: Internal volume is calculated based on the radius of the hollowed sphere/cylinder, minus a 5-meter structural "crust" for micrometeoroid protection.

## 3. Infrastructure Stages
1. **Anchor**: Installation of a `harvester_rig` to begin surface material extraction.
2. **Hollow**: Execution of the `HollowingJob` using thermal drills and plasma cutters.
3. **Pressurize**: Installation of `sealant_panels` and `life_support_units`.
4. **Final Fit**: Converting the hollowed void into a `Planetary Staging Hub` or `Orbital Depot` by installing standard internal modules.

## 4. Super-Mars Scenario
If a planet (like Super-Mars) lacks natural moons, the HLT (Icy Lander variant) is used to capture and move Phobos-sized asteroids into a stable orbit to initiate this conversion process, avoiding the need to import station frames.