# Natural Wormholes & Exotic Matter (EM)

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-13  
> *Audit Summary:* Design intent specification. Owner design decisions reconciled 2026-11-13; runtime implementation not verified by this update.

**Status:** DIRECTION / OPEN  
**Last Updated:** 2026-11-13  
**Related:** [Portals & AWS](portals_and_aws.md), [Sol System Reference](../astronomy/sol_system_reference.md), [Eden disconnect and emergent history](../player/eden_disconnect_and_emergent_history.md)

This page is the wiki home for natural wormhole behavior, relative stability, mass throughput and limits, EM ejection and harvesting, EM stabilization, shifting/snapping, and the Hammer Protocol.

## 1. Natural wormholes are not permanently stable

**ESTABLISHED DESIGN INTENT — 2026-11-13**

No natural wormhole should be described as simply “stable” or permanently safe. Natural wormholes have different degrees of relative stability, and all remain subject to mass throughput, EM ejection, changing conditions, and the possibility of a shift or snap unless the scenario or available technology changes that outcome.

- A comparatively more stable wormhole still ejects some excess EM into local space.
- A less stable or increasingly stressed wormhole ejects much larger amounts of EM.
- The amount of mass pushed through contributes to the EM ejected; greater mass throughput produces greater ejection.
- As a wormhole approaches its mass limit, ejection and instability increase.
- Without suitable stabilization technology and an effective counterbalance, reaching the mass limit causes it to snap.
- A shift changes the natural exit/connection. A snap is the failure event described in the historical Eden case. Do not use “shift” and “snap” as interchangeable terms without regard to the event being described.

Exact physical equations, mass thresholds, stability curves, yields, and time windows remain OPEN.

## 2. Sol's natural wormhole and the Eden historical event

**ESTABLISHED SCENARIO INTENT — 2026-11-13**

Sol's natural wormhole is comparatively more stable because of its placement opposite Jupiter, whose mass provides a significant counterbalance. This does not make the wormhole intrinsically or permanently stable, and it still has natural EM ejection and mass-throughput behavior.

For the current human-expansion gameplay scenario, Sol's natural wormhole remains present and does not shift or snap. The narrative is also currently planned around Sol's wormhole continuing to exist. This is a scenario/narrative treatment, not a permanent limitation on the underlying simulation: future scenarios or design changes may allow different outcomes. Keep the special treatment configurable or otherwise separable from general natural-wormhole mechanics.

The Eden-side wormhole was less stable and snapped before EM stabilization technology was developed. That event is a key historical catalyst for the later technology. Do not imply that operators had the mature EM capture-and-return stabilization loop before the Eden snap.

## 3. EM ejection and harvesting

Natural wormholes produce excess EM in local space through their behavior:
- A comparatively more stable natural wormhole produces a smaller amount of excess EM.
- An unstable or heavily stressed wormhole ejects much more EM.
- Greater mass pushed through increases the amount of EM ejected.
- Ejected EM can be captured by suitable harvesting/containment equipment; ordinary mining equipment should not be assumed sufficient.

Distinguish the following quantities in simulation and AI Manager displays:
1. **EM ejected/locally available** — released by the wormhole.
2. **EM captured/harvested** — actually collected by equipment.
3. **EM stored** — captured EM retained in usable reserves.
4. **EM returned for stabilization** — captured EM directed back toward the wormhole.
5. **EM consumed elsewhere** — used by AWS, portals, and other supported systems.

These quantities are related but not interchangeable. Exact yield curves, capture efficiency, losses, storage limits, and units remain OPEN.

## 4. EM stabilization and mass-limit restoration

**ESTABLISHED DESIGN INTENT — 2026-11-13**

EM stabilization technology is developed after the Eden-side snap. The technology:
1. captures EM ejected into local space;
2. contains and directs captured EM back toward the wormhole;
3. counteracts the destabilizing effects associated with mass throughput;
4. restores/resets available mass-limit capacity; and
5. improves the wormhole's relative stability.

This creates a feedback loop: mass transit contributes to EM ejection; stabilization infrastructure captures that EM and returns it to the wormhole to restore capacity and improve stability.

The exact mechanism, required station/satellite arrangement, efficiency, buffer capacity, power demand, and operating thresholds remain OPEN. Do not imply that stabilization makes a natural wormhole permanently stable or invulnerable.

An AWS pair or other counterbalance infrastructure may support stabilization and network operations as described in [Portals & AWS](portals_and_aws.md); detailed placement and performance rules remain OPEN.

## 5. Shifting, snapping, and the Hammer Protocol

A natural exit can shift as part of the natural wormhole lifecycle. A snap is a failure event when the mass limit is reached without adequate counterbalance/stabilization. The historical Eden-side snap happened before the later EM stabilization technology existed.

**Hammer Protocol — ESTABLISHED STRATEGIC INTENT, 2026-11-13**

Hammer Protocol is part of the human expansion strategy using Sol as the current staging/scouting system. It is broader than simply forcing a snap and should not be described only as a controlled-closure mechanism.

The strategic workflow is:
1. Use Sol as the staging point for opening/exploiting a natural wormhole to a candidate system.
2. Survey the newly accessible system: its celestial bodies, EM field, resources, and settlement potential.
3. Treat a system discovered through this natural-wormhole scouting process as having a harvestable EM field.
4. Harvest EM and other available resources while the natural connection remains open, subject to capacity, logistics, and risk.
5. Decide whether to continue harvesting, invest in stabilization, establish an AWS connection, plan settlement, or complete the harvesting opportunity and hammer the natural exit to force a shift and begin scouting elsewhere.

Discovery does not automatically require an AWS pair or settlement. The AI Manager may use the natural connection while it remains open and defer the AWS decision.

If the system is selected for settlement or continuing network integration, the likely strategy is to build an AWS pair while the natural wormhole is still open. This creates a Sol connection and a logistics corridor for people, equipment, construction materials, and supplies. The connection can use a stabilized natural wormhole or an artificial connection as appropriate. Whether and when a connection is later moved is a strategic network decision, not an automatic consequence of discovery.

The Hammer Protocol may include a deliberate final mass transit to force a natural exit to shift when the system is to be abandoned. This is a strategic option, not a mandatory step for every discovered system. Do not conflate the deliberate hammer/shift operation with an uncontrolled snap.

## 6. Known and unknown systems

A system discovered through an open natural wormhole and surveyed under the Hammer Protocol is known to the operators and has a harvestable EM field under the current design.

Unvisited systems in the local bubble remain unknown. Do not assume that they have a known, accessible, or harvestable EM field before discovery and survey. Do not assign resource or EM knowledge to a system merely because it is nearby in astronomical space.

## 7. AI Manager responsibilities

AI Manager must monitor:
- natural wormhole relative stability and current state;
- mass throughput and remaining mass-limit capacity;
- EM ejection rate and locally available EM;
- harvesting/capture rate and captured reserves;
- EM returned for stabilization and stabilization effectiveness;
- EM consumption and projected reserves;
- candidate system resource/settlement value;
- AWS construction and operating cost;
- transit time, fuel, construction logistics, and supply access;
- the consequences of continuing, stabilizing, integrating, or leaving a system.

Its objective is to balance sustainable expansion, resource access, network value, and the risk/cost of losing a natural connection. It should not simply maximize the number of connected or occupied systems.

## 8. Open questions

- Exact mass-threshold units, accumulation window, and reset behavior.
- Quantitative relation between mass throughput and EM ejection.
- Relative stability calculation and the influence of mass placement/orbital geometry.
- EM capture efficiency, storage/buffer limits, return efficiency, and stabilization power demand.
- Exact physical distinction and transition rules between a shift and a snap.
- How a deliberate Hammer operation forces a shift and what happens to transit, harvesters, and equipment.
- Which natural connections can be stabilized, and how AWS pairing/counterbalance affects them.
- Ownership, licensing, and player access to EM harvesting.
- Exact AWS construction, commissioning, and relocation sequence.
- How AI Manager scores survey, harvesting, stabilization, AWS investment, and settlement opportunities.

All numerical values and unverified implementation details remain OPEN.
