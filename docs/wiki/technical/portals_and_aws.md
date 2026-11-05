# Portals and Artificial Wormhole Stations (AWS)

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-04  
**Related**: [settlement_progression_and_footholds.md](../player/settlement_progression_and_footholds.md), logistics and engineering pages

This page is the wiki home for intra-system portals and inter-system Artificial Wormhole Stations. Prior transportation and portal notes already established the core constraints (pairing, mass limits, EM cost). Those constraints are restated here as the live source of truth; numerical values and ownership rules that were never finalized remain OPEN.

---

## Two Distinct Technologies

### Intra-System Portals
**DIRECTION** (aligns with existing established constraints)

- Miniaturized AWS-derived technology.
- Built and operated **in pairs**. An unpaired portal is non-functional.
- Restricted to **low-mass** payloads only: personnel, high-value components, emergency medical/repair kits, small critical parts.
- Do **not** move bulk ores, structural steel, large machinery, or significant quantities of volatiles. This is an intentional economic constraint that protects the freight layer.
- Require physical infrastructure and ongoing power / Exotic Matter (EM) cost at both ends. EM cost is higher than equivalent cycler transport (existing constraint).
- Operate on schedules or power windows rather than continuous open doors; missing a window means waiting for the next cycle.
- Create natural hub-and-spoke routing. A small foothold portal usually links only to a regional hub; further travel requires transfers.

### Artificial Wormhole Stations (AWS)
**DIRECTION / OPEN**

- Full-scale inter-system infrastructure.
- Also built in pairs.
- One station initiates the rift; the paired station locks on and helps stabilize it.
- Capable of moving both personnel and heavier cargo (exact mass limits still OPEN).
- High capital, power, and EM cost to establish and maintain.
- Opening a new inter-system AWS pair is a major late-game or corporate milestone.
- The Eden reconnection is an example of a newly activated AWS pair.

**Caution from prior notes**: Some older material flagged inter-system portal gates as proposal-only. The distinction maintained here is that intra-system low-mass portals are treated as established direction, while full inter-system AWS capability and its exact cargo envelope remain more open and should be confirmed before heavy implementation.

**OPEN**
- Precise mass thresholds that separate “portal” from “AWS-capable” cargo.
- EM consumption rates, power draw, and maintenance requirements for both scales.
- Whether player corporations can eventually own and toll private portal or AWS pairs.

---

## Design Intent Behind the Split

- Protects the physical freight and logistics layer of the game. If everything could portal, bulk shipping, cyclers, and skimmers would lose purpose.
- Allows rapid personnel and crisis response without collapsing travel times for industrial quantities of material.
- Creates meaningful infrastructure decisions: a remote outpost without a portal pair remains dependent on slow physical transit until someone hauls and installs the second frame.

---

## Operational Realities

**DIRECTION**

- Travel, even via portal, takes real time. Instantaneous god-mode movement across a solar system is not intended.
- Hub-and-spoke is the normal pattern (local foothold → regional hub → major system hub → destination).
- Layovers at transfer hubs are expected and create natural market and social interaction points.
- Portal access can be scheduled, tolled, or restricted by the owning entity (AI Manager, Development Corp, or later player corp).
- In austerity mode an AI Manager may reduce portal power windows to conserve energy (see economic loops page).

**OPEN**
- Exact transit times, scheduling UI, and booking mechanics.
- Fee structures and standing-based discounts or priority access.
- Failure modes (power loss, EM shortage, misalignment) and recovery procedures.

---

## Relationship to Population and Evacuation

Because portals move people efficiently, they also serve as the primary mechanism for immigration and emergency evacuation (see settlement progression page). A base that loses life-support reliability can see its population leave through the portal network, leaving a ghost shell behind.

---

## Implementation Notes (future thin tasks)

- Portal pairs should be first-class entities with location, power state, schedule, and ownership.
- Mass filtering must be enforced at the point of transfer so bulk cargo cannot exploit the fast path.
- AWS pair activation should be a visible, high-cost event that can be observed system-wide.
- Numeric values for PORTAL_MAX_MASS and EM consumption need to be decided and recorded here once chosen.

All numerical values and exact ownership rules remain **OPEN**.
