# Natural Wormholes & Exotic Matter (EM)

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-07  
**Related**: [portals_and_aws.md](portals_and_aws.md), [eden_disconnect_and_emergent_history.md](../player/eden_disconnect_and_emergent_history.md), [terraforming_options.md](../infrastructure/terraforming_options.md)

This page is the wiki home for **natural wormhole physics**, mass-limit behavior, Exotic Matter ejection, harvesting, and the reset / stabilization loop. Artificial Wormhole Stations and intra-system portals live on [Portals & AWS](portals_and_aws.md).

---

## Core Physics (DIRECTION)

1. Natural wormholes are rare spatial events, not static free highways.
2. **Mass anchoring / counterbalance** matters. A large mass body (e.g. Jupiter-class) on a mouth dampens volatility and reduces uncontrolled EM ejection.
3. Mouths **without** adequate counterbalance are inherently more unstable (Eden-side historical example).
4. Traffic and mass through the aperture accumulate against a **mass capacity threshold**.
5. If the threshold is breached and not reset, the wormhole destabilizes and **ejects Exotic Matter (EM)** into the local region as a stress-relief mechanism.
6. Unmanaged runaway instability can culminate in a **Snap**: the spatial anchor shears and the terminus shifts (or the link is lost). The Sol–Eden Snap shifted the natural connection to System B.
7. **EM is tied to natural wormholes.** It is harvested from discharged / ejected EM associated with those mouths — not from arbitrary space.

---

## Stabilization and the Reset Loop

**DIRECTION**

- Stabilization satellites and wormhole stations can **capture ejected EM** and **feed EM back into the throat** to help restore mass-limit headroom and dampen instability.
- This is the primary industrial reset mechanism once the technology exists.
- An **AWS paired to a natural mouth** can act as a synthetic counterbalance, making the node safer and EM management more predictable.
- Artificial–artificial AWS pairs provide counterbalance in systems that lack a natural gas-giant-class anchor.

**Timeline constraint (aligned with Eden page):**  
EM harvesting and feed-back technology mature through AWS-era research. At the historical Snap, Eden-side operators did **not** yet have operational EM harvest / reset capability. Residual pre-Snap EM in Eden space is whatever was ejected before the aperture shifted away; it is not continuously produced after the mouth is gone.

---

## Controlled Snap (Hammer Protocol)

**DIRECTION**

- A natural wormhole can be closed on purpose by sending enough mass through it to cause a controlled Snap. This is the **Hammer Protocol**.
- It is the last resort when the reset loop cannot keep up. Stabilization stations and satellites hold a finite buffer of captured EM; once those buffers are full, no more EM can be recaptured and a controlled Snap is the only way to reset the system.
- The AI Manager can also use it to leave a depleted system, sending a final heavy shipment as the triggering mass and then looking for a new connection.
- A planned Snap is announced system-wide. The AI Manager also announces when the stabilization satellites and any NPC-deployed equipment or ships are due to return to Sol (owner, 2026-11-07).
- A degrading aperture ejects more EM the worse it gets, so the period before a Snap is an EM harvest window. Players can send harvesters, including automated ships, to collect it. A harvester that has not returned through before the Snap is lost.
- The AI Manager can let the wormhole degrade naturally, or let player ships harvest and return. Player transits add mass and could themselves cause the Snap, so a Snap does not have to be an AI Manager planned closure.
- Sol is EM-poor while stable, so its EM arrives in bursts around these events. Consumers such as portal pairs and AWS stabilization draw on a stockpile refilled by harvest windows, not on a steady flow. The Saturation Limit on station and satellite buffers caps how much of a harvest can be kept.
- What a controlled Snap leaves behind (terminus shift or lost link, and the effect on stations and traffic) is **OPEN**.

---

## Early History Pattern (DIRECTION)

- Early footholds at natural mouths followed the Phobos/Deimos pattern: tow a suitable asteroid to the throat and convert it into a station.
- Early operators treated the wormhole as a transit highway. Mass limits and EM physics were not yet understood.
- Sol-side stability (Jupiter counterbalance) vs Eden-side volatility was observed before the full theory existed; that disparity drove research that later became EM capture and AWS technology.
- The Snap (Eden isolation, shift to System B) is the catalyst that forces artificial wormhole development and eventual reconnection. Players enter after reconnection capability exists.

Exact duration of the Eden golden age, the isolation interval, and the precise post-reconnection state of Eden remain **OPEN** (see Eden page for emergent archetypes).

---

## Harvesting and Economics

**DIRECTION / OPEN**

- Specialized containment / station hardware is required; ordinary miners are insufficient.
- Harvested EM moves through normal logistics (tugs, depots, cyclers) into the wider market.
- Demand drivers include AWS stabilization, advanced manufacturing, and high-end transit support.
- Local supply is sparse and uneven until trade routes mature; price shocks follow discoveries, collapses, and containment accidents.
- Deliberately pushing a mouth toward instability to farm ejection spikes (“brinkmanship”) is a possible industrial strategy and a possible failure mode. It remains **DIRECTION** only — not required gameplay.

Numeric yields, loss rates, containment failure curves, and market elasticity remain **OPEN**.

---

## EM Yield and the EM Budget

**DIRECTION / OPEN**

- **EM Yield** is how much EM a natural wormhole releases over time. It depends on the size of the mouth, how stable it is, and residual EM from past activity. The AI Manager can use it to rank harvest sites and work out network fuel needs. This comes from early design notes; treat it as possible early design (owner, 2026-11-07).
- A degrading wormhole releases more EM than a stable one, and the worse the aperture gets, the higher the yield. A stable Sol is therefore EM-poor, and planned Snaps and harvest windows are where its EM comes from (see Controlled Snap above).
- Consumers such as AWS stabilization and portal pairs ([Portals & AWS](portals_and_aws.md)) draw on the stockpile that harvest windows refill.
- The numbers are all **OPEN**: yield as a function of instability, the units for EM, the stockpile cap, and how much AWS and portal pairs draw.

---

## Institutional Layer

**DIRECTION**

Core arterial natural mouths and primary AWS lanes are regulated by the institutional backbone (Wormhole Transit Union / development–logistics consortium), not by unbounded private monopoly. Players participate as contractors, private operators within policy, or specialists. See [Portals & AWS](portals_and_aws.md).

---

## Relationship to AI Manager Testing

**OPEN / process note**

Sol is the training environment for AI Manager expansion logic. Pre-snap infrastructure choices (closed local loops vs import reliance, buffer depth, long-horizon assets) shape how isolated managers behave when links are cut in simulation. Post-snap outcomes (ghost / remnant / expanding-style profiles) are emergent test results, not fixed lore for every system.

State snapshotting at major economic milestones is the preferred way to stress-test expansion thresholds without replaying history from year zero every time. Snapshot protocol and scoring weights belong in simulation / AI Manager design docs when formalized.

---

## Open Questions

- Exact mass-threshold units and time windows.
- Stabilization-satellite and feed-back rates.
- Containment loss and surge hazard curves.
- Whether brinkmanship farming is encouraged, neutral, or discouraged by institutional policy.
- Ownership and licensing of EM taps on regulated mouths.
- How much residual pre-Snap EM remains harvestable in Eden after reconnection.
- Formal AI Manager expansion scoring function and snapshot schema (implementation docs).
- Triggering mass for a controlled Snap, and how it relates to the mass threshold.
- Buffer size (Saturation Limit) per station and satellite.
- What a controlled Snap leaves behind at the terminus, and what happens to stations and traffic.
- Who may order a controlled Snap: the AI Manager only, players, or the institutional network.
- How long the notice before a planned Snap is, and how the AI Manager chooses between letting the wormhole degrade, allowing player harvests and forcing the closure.
- How much EM a degrading aperture ejects, and how much a Snap releases.
- Who bears the loss of a harvester caught by a Snap.
- EM budget: how many portal pairs and other consumers a given stockpile can sustain.
- The yield curve: how EM release rises as an aperture degrades, and what units EM is measured in.
- How AWS and portal pairs draw EM: per opening, per hour held open, per mass transited, or a mix.

All numerical values remain **OPEN**.
