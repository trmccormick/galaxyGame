# Physics & Topology: The Brown Dwarf Hub

## Documentation status (2026-10-14)

This file records **physics/topology intent**, not finished simulation constants. The mass-limit relationship, stability index, EM surplus, and AWS “mass-damper” effects are directional design. Exact numbers and live overload/reset behavior are **still in flux**.

AWS artificially manages links for more stability; it does **not** remove mass limits, counterbalance/topology rules, or EM as the energy required to open and hold a wormhole. Prefer in-system bulk for terraforming-scale feedstock; cross-wormhole bulk remains possible but impractical at planetary scale.

Snap backstory and maturity intent (thresholds not locked):

→ `docs/storyline/02_crisis_mechanics.md`

Terraforming logistics preference:

→ `docs/gameplay/terraforming.md`

EM harvesting, AWS, and interstellar network expansion are **not** early Sol priorities. Preferred early AI Manager ordering is the industrial spine in `docs/gameplay/sol_core_buildup.md` (Luna → shipyard → core cyclers → Mars hub). Network/EM systems matter for reconnection and later expansion; they must not displace depot, shipyard, or hub buildout in early ranking.

## Brown Dwarfs as Logistics Batteries

Brown Dwarfs act as unique "Logistics Batteries" due to their immense mass but lack of stellar radiation.

**Simple Analogy: The Failed Star Gas Station**
A Brown Dwarf is essentially a "failed star"—it has a massive gravitational pull like a star but doesn't produce enough heat or light to be habitable. This makes it the perfect Gas Station (Siphon) for the network.

## The Hub: L3 Lagrange Point
Because of its high mass, it provides a stable gravitational anchor for an Artificial Wormhole Station at the L3 Lagrange point (the "quiet spot" opposite the primary star).

## The Siphon: Volatile Resources
These systems are rich in volatiles (like Hydrogen and Nitrogen) but have no breathable atmosphere or sunlight.

## The Role: EM Fuel Production
The Consortium builds a hub here to stabilize natural wormholes and harvest Exotic Matter (EM) fuel exclusively from the wormhole throats via stabilization satellites. The system's volatiles (Hydrogen, Nitrogen) are siphoned to construct and maintain EM-capture infrastructure, but EM itself is harvested directly from the quantum instabilities of natural wormholes, not from planetary atmospheres.

## Strategic Importance
- **Primary Siphons**: Because they are rich in volatiles but "light-poor," the Consortium targets them as Primary Siphons to build EM harvesting infrastructure needed to power the network's EM Inductors.
- **Gateway Systems**: Enable deeper, more remote systems through stable connections.
- **Branching Hubs**: Systems with multiple gas giants (e.g., two) can support more links, becoming regional junctions. If a second natural wormhole appears in a remote system, the AI Manager upgrades it to a Secondary Branch Hub, enabling recursive scouting into parallel frontier systems.

## System Capacity
- **Standard Gas Giant**: 1 Slot (L3)
- **Jupiter-Class**: 2 Slots (L3 + Direct Anchor)
- **Brown Dwarf**: 1 High-Stability Slot (L3), often used as a "Gateway" to deeper, more remote systems

## The Mass-Limit Formula

### Natural Wormhole Stability Equation
The stability of natural wormholes is governed by the following equation:

$$Mass\_Limit = \frac{System\_Mass \times Stability\_Index}{EM\_Surplus}$$

**Variables:**
- **System_Mass**: Total mass of the star system (influences gravitational anchor strength)
- **Stability_Index**: A value from 0.1 to 1.0 (Natural wormholes start at 1.0 and decay over time due to quantum fluctuations)
- **EM_Surplus**: The amount of EM harvested and stored from the wormhole itself, which is then used to 'reinforce' the link and stabilize the throat

## The 'Snap' Logic

If the current transit mass exceeds the calculated Mass_Limit ($Current\_Transit\_Mass > Mass\_Limit$), the wormhole undergoes a "Snap" event where the Exit_Vector randomly shifts, orphaning the current destination and requiring rediscovery through scouting operations.

## The Dual-Link Solution: Artificial Counterbalancing

An Artificial Wormhole Station (AWS) positioned at the L3 Lagrange point acts as a 'Mass-Damper', creating a counterbalancing gravitational anchor that:
- Doubles the effective Mass_Limit for the system
- Reduces EM fuel costs by 50% through active stabilization
- Enables reliable two-way transit for heavy cyclers and industrial shipments

---

*Brown dwarf topology provides the physical foundation for sustainable wormhole networks.*