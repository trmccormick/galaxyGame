# Portals & Artificial Wormhole Stations (AWS)
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-07  
> *Audit Summary:* Design intent specification (page status DIRECTION). Not audited against code; implementation pending or unverified as of audit baseline.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-07  
**Related**: [natural_wormholes_and_em.md](natural_wormholes_and_em.md), [eden_disconnect_and_emergent_history.md](../player/eden_disconnect_and_emergent_history.md), [terraforming_options.md](../infrastructure/terraforming_options.md), logistics pages

This page is the wiki home for **intra-system portals** and **Artificial Wormhole Stations (AWS)**. Natural wormhole physics, mass limits, and Exotic Matter (EM) harvesting live on [Natural Wormholes & EM](natural_wormholes_and_em.md).

Portals and AWS do not replace cyclers, freighters, or mass-driver bulk pipelines.

---

## Two Distinct Technologies

### Intra-System Portals
**DIRECTION**

- Standalone manufactured infrastructure. They do **not** require natural or artificial wormhole anchoring.
- Built as **quantum-entangled pairs**. Both halves are manufactured together, then shipped and deployed. Unpaired units are non-functional. Loss of one half ends the pair.
- Restricted to **low-mass** payloads for the arterial role: personnel, high-value components, emergency kits, small critical parts. Bulk ores, structural steel, and planetary-scale volatiles stay on freighters / cyclers / mass drivers.
- **Energy model:**
  - **EM** is used primarily as an **ignition burst** to open the aperture.
  - **Fusion / normal power + magnetic containment** keep the aperture open.
  - While held open, EM use is minimal. Day-to-day upkeep is fusion reliability, not continuous industrial EM bleed.
- **Emergency shutdown:** fusion brownout → capacitor-backed controlled pinch → dormant. No designed explosive blowout.
- **Operation** (owner, 2026-11-07):
  - **If the EM supply is unavailable, the link shuts down.** Nothing further is defined. The design task is to set how much EM a portal consumes.
  - Both halves are in the same system and linked by the data network, which confirms both are online before a transit opens. Signal lag across the network is expected.
  - One endpoint fires and opens the rift; the other locks on and stabilizes it, as in an AWS pair. Either half can fire; only one does for a given opening.
  - The firing side uses the most EM, at the opening. Portals also spend EM to reinforce the rift and reset mass limits, as wormhole stabilization does, because the stabilization technology is built into the portal. Fusion or electrical power runs the magnetic fields.
  - Once open, the rift stays open until either side closes it. This applies to portals and artificial wormholes. Natural wormholes are closed differently, by a controlled Snap ([Hammer Protocol](natural_wormholes_and_em.md)).
  - Counterbalance rules do not apply: the technology is miniaturized and needs no anchor mass.
- **Environmental variants:**
  - **Habitat-rated** — pressurized human spaces; pressure handshake before open; gas only as containerized freight.
  - **Industrial / surface-rated** — ruggedized; may run with intentional atmospheric bleed (“garden hose”) for pressure-first protection; not a bulk terraforming pipeline.
  - **Vacuum-rated** — station exterior / near-vacuum pairs.
- Structural mount must be serious (primary structure / keel-class). Not a light-hull bolt-on.
- **Tech tree placement** (from the legacy EM technology tree; owner to confirm): Level 4. Follows Level 3 AWS plus miniaturization research and unlocks through peacetime research after the Snap crisis is resolved. Relies on quantum entanglement, not planetary-scale mass anchors.

### Artificial Wormhole Stations (AWS)
**DIRECTION / OPEN**

- Full-scale inter-system (and large-scale) infrastructure.
- Built in pairs. One station initiates the rift; the paired station locks on and stabilizes it.
- Once open, the rift stays open until either station closes it. Natural wormholes are closed differently, by a controlled Snap ([Hammer Protocol](natural_wormholes_and_em.md)).
- Can move personnel and heavier cargo (exact mass envelope still OPEN).
- High capital, power, and EM cost to establish and maintain.
- **Counterbalance role:** Where a system lacks a natural mass anchor (gas giant class), AWS pairs can provide artificial counterbalance. An AWS can also be paired to a natural wormhole mouth to stabilize it and make EM management safer (see natural wormholes page).
- Opening a new inter-system AWS pair is a major corporate / late-game milestone.
- Eden reconnection is an example: early traffic limited to tug, EM harvesters, and stabilization sats until the Eden-side station is converted and operational ([Eden page](../player/eden_disconnect_and_emergent_history.md)).

**Caution:** Inter-system “portal-gate at AWS” concepts (sometimes called Level 4b) remain more open than intra-system portal pairs and should not be treated as established.

---

## Networks and Hubs

**DIRECTION**

- Each portal pair is one specific connection. A hub holds several pairs, and travelers transfer between them. Any major settlement can become a hub.
- No fixed hub list or hard link cap is set. Earth/L1 → Mercury → Mars → Ceres → Jupiter → Saturn → Pluto is an example of one possible network, not required topology.
- Other star systems can develop their own independent system-local portal networks.

---

## Institutional Control of the Network

**DIRECTION**

The primary arterial wormhole / AWS network is not left entirely to individual player monopolies. Development corporations and logistics entities form an institutional backbone (Wormhole Transit Union / equivalent consortium) that builds, maintains, and regulates core lanes, mass-limit policy, and stabilization standards.

Players operate as contractors, specialists, private logistics firms, or later private pair operators within that framework — not as sole owners of the entire network. Exact ownership and toll rules remain OPEN.

---

## What Portals / AWS Are Not

- Not a substitute for cyclers or heavy freighters for bulk mass.
- Not the primary Venus→Mars (or equivalent) atmospheric injection system — that remains mass-driver work under [Terraforming options](../infrastructure/terraforming_options.md).
- Not free of logistics: remote halves must be shipped; fusion reliability matters; habitat-rated links enforce pressure rules.

---

## Open Questions

- Exact Mark capacity tiers and numeric mass filters.
- Amount of EM a portal consumes: opening burst, stabilization and mass-limit reset, and any residual rate while open (must stay minimal). This is the main portal number to design.
- Fusion power draw by variant.
- Manufacturing recipes and facility requirements.
- Industrial bleed rate tunability.
- Inter-system portal-gate (Level 4b) scope, if any.
- Player ownership / toll limits relative to the institutional network.
- Portal mass limits and how the reset works. Never defined; the aperture is small, but no numbers are set.
- Whether both halves ship on one mission or two, and whether one half can be installed at an existing station while the other goes to a new settlement.
- Whether placing both halves activates the link or needs a separate commissioning step.
- How destroyed endpoints are repaired, replaced or re-paired. Today, losing one half ends the pair.
- What happens if the data network cannot confirm both ends, and how much signal lag matters.
- What happens to anything in transit when a link shuts down for lack of EM.
- What closes a portal or artificial rift: which side may close it, whether closing has a cost or a delay, and whether a link left idle is closed automatically.
- How many portal pairs a settlement or hub can host. No hard cap is set; numeric limits are OPEN.

All numerical values remain **OPEN**.
