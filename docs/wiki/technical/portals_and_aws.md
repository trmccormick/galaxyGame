# Portals & Artificial Wormhole Stations (AWS)
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-14  
> *Audit Summary:* Owner-confirmed technology lineage and player-arrival prerequisite reviewed. Related wormhole and consortium source paths inspected; existing code is only partially aligned and does not establish the post-Snap research, reconnection, portal-miniaturization, or player-entry sequence.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-14  
**Related**: [natural_wormholes_and_em.md](natural_wormholes_and_em.md), [eden_disconnect_and_emergent_history.md](../player/eden_disconnect_and_emergent_history.md), [terraforming_options.md](../infrastructure/terraforming_options.md), logistics pages

This page is the wiki home for **intra-system portals** and **Artificial Wormhole Stations (AWS)**. Natural wormhole physics, mass limits, the Snap, and Exotic Matter (EM) harvesting live on [Natural Wormholes & EM](natural_wormholes_and_em.md).

## Technology lineage and player-arrival prerequisite

**ESTABLISHED DESIGN INTENT — owner, 2026-11-14**

The historical Snap is caused by accumulated mass transfer through a natural wormhole without the required stabilization technology. It is an emergent event shaped by the AI Manager's system-development decisions and the wormhole model, not a planned research milestone. The Snap drives Sol corporations and the AI Manager to pursue wormhole research more aggressively.

That post-Snap research develops full-scale artificial wormhole technology. It is used to open an artificial wormhole connection from Sol to the Eden system, reconnecting Sol with Eden's already-established settlements. The technology is then miniaturized into intra-system portal technology. Portals are therefore an offshoot of artificial wormhole research, not an unrelated invention or a technology that predates the Snap.

The **Wormhole Transit Consortium (WTC)** develops the artificial wormhole technology and manages the inter-system wormhole network. Intra-system portals are a derived technology for rapid movement within a solar system between bases equipped with portal endpoints; they do not replace the inter-system network's role. The Consortium's precise legal structure, ownership, and operating rules remain OPEN unless separately established.

**Player arrival is gated on this infrastructure being in place.** Players enter after the artificial wormhole connection to Eden has been opened and the wormhole network and portal technology have been established for use. This does not mean every individual base necessarily has a portal; rapid portal travel is available between bases equipped with the technology.

Portals and AWS do not replace cyclers, freighters, or mass-driver bulk pipelines.

> **Correction note:** An older frozen architecture document (`docs/architecture/logistics/navigation/INTRA_SYSTEM_PORTALS.md`, cited as plain text) says a portal pair needs a continuous supply of EM, and that its EM cost for a given mass must always exceed the cost of running a cycler. That is not the owner's model and is not carried here. The energy model below is the intent.
---

## Two Distinct Technologies

### Intra-System Portals
**ESTABLISHED INTENT (owner, 2026-11-11)**

- A portal uses some EM to open the rift. Fusion power and magnetic containment keep it open.
- A portal is low-mass. It cannot transfer ships or large materials, and it cannot replace cyclers or mass drivers for delivering most bulk.

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
  - Once open, the rift stays open until either side closes it or can no longer maintain it (see the next point). This applies to portals and artificial wormholes. Natural wormholes follow their own lifecycle: the historical Eden Snap is an uncontrolled failure caused by accumulated mass throughput without stabilization; the Hammer Protocol may separately use a deliberate final transit to force an exit shift. Do not call the historical Snap a planned or controlled closure ([Hammer Protocol](natural_wormholes_and_em.md)).
  - **Both ends maintain the rift** (owner brainstorm, 2026-11-14; DIRECTION, not locked): each end supplies the power, and a small amount of EM, to keep its magnetic confinement field running. If either end cannot, the rift destabilizes and closes. How the failure closes the rift (a controlled pinch or something rougher), any grace window, and the amounts remain OPEN.
  - Counterbalance rules do not apply: the technology is miniaturized and needs no anchor mass.
- **Environmental variants:**
  - **Habitat-rated** — pressurized human spaces; pressure handshake before open; gas only as containerized freight.
  - **Industrial / surface-rated** — ruggedized; may run with intentional atmospheric bleed (“garden hose”) for pressure-first protection; not a bulk terraforming pipeline.
  - **Vacuum-rated** — station exterior / near-vacuum pairs.
- Structural mount must be serious (primary structure / keel-class). Not a light-hull bolt-on.
- **Research lineage — ESTABLISHED INTENT:** Full-scale artificial wormhole technology is developed through aggressive post-Snap research and is used to open the artificial Sol–Eden connection. Miniaturization of that technology produces intra-system portals as an offshoot. Exact research stages, technology levels, prerequisites, and timing remain OPEN. Older technology-tree level labels are not authoritative until reconciled with this sequence.

### Artificial Wormhole Stations (AWS)
**DIRECTION / OPEN**

- Full-scale inter-system (and large-scale) infrastructure.
- Built in pairs. One station initiates the rift; the paired station locks on and stabilizes it.
- Once open, the artificial rift remains open until either station closes it or can no longer maintain it. Natural wormholes follow their own lifecycle and may shift or snap; see [Natural Wormholes & EM](natural_wormholes_and_em.md).
- Can move personnel and heavier cargo (exact mass envelope still OPEN).
- High capital, power, and EM cost to establish and maintain.
- **Counterbalance/stabilization role:** AWS infrastructure may provide artificial counterbalance where a suitable natural mass anchor is absent, and an AWS paired to a natural mouth may support stabilization and EM management. Exact placement and performance rules remain OPEN.
- Opening an inter-system AWS pair is a major infrastructure and network-expansion investment.
- Eden reconnection is an example: early traffic is limited to the initial equipment and operations required to establish the connection and stabilize the Eden side ([Eden page](../player/eden_disconnect_and_emergent_history.md)).

**Hammer Protocol and frontier-network expansion — OWNER-CONFIRMED STRATEGIC DIRECTION, 2026-11-20**

The intended expansion pattern is a repeating survey → evaluate → build AWS → reconfigure Sol's network → hammer/shift cycle. A natural wormhole provides temporary access to a candidate system; it is not necessarily the permanent route by which that system remains connected to Sol.

1. **Natural access changes.** A natural wormhole may shift as part of its lifecycle, including when its mass limit is reached, or its exit may be deliberately shifted through the Hammer Protocol. A shift changes the natural exit/connection; it is not the same event as an uncontrolled snap.
2. **AI Manager announces survey missions.** When a newly accessible frontier becomes available, the AI Manager can offer survey missions to players. Players explore the system and return information about its celestial bodies, resources, EM field, and terraforming/settlement potential. A system is not automatically a prize merely because it was discovered.
3. **Evaluate the prize system.** Survey results identify whether the system has unusually valuable resources, worthwhile terraforming targets, or other strategic value. The AI Manager evaluates the findings against Sol's needs, expansion costs, and the value of keeping the natural route open.
4. **Select AWS placement.** For a valuable system, the AI Manager determines suitable location(s) for the new AWS infrastructure. Depending on the system's geometry and connection requirements, this may involve one station or two stations in the new system. Placement must consider gravitational/counterbalance geometry, EM stabilization, orbital movement, transit, construction, and resupply. The precise station/pair topology is still subject to the AWS design.
5. **Build while natural access remains open.** The required AWS infrastructure is constructed and commissioned while the natural wormhole still provides access. This allows the temporary natural route to support deployment and construction logistics.
6. **Reassign an existing Sol network route.** Once the new frontier-side AWS endpoint is ready, an active Sol-side artificial route serving another system can be disconnected and reassigned to connect Sol to one of the new AWS stations. This makes the new prize system part of Sol's artificial network. The displaced route/connection can then be retargeted to another system as part of the same broader network reorganization. The intended outcome is a durable artificial logistics corridor from Sol to the new frontier, not a permanently expanding collection of fixed links.
7. **Hammer the natural wormhole to move on.** After the artificial connection is established and the frontier no longer depends on the natural route for access to Sol, operators use the Hammer Protocol to force the natural exit to shift to a new location. The AI Manager can then announce another survey opportunity and repeat the cycle.

The strategic payoff is that a temporary natural connection is used to discover and develop a valuable frontier, while a reconfigured artificial network connects that frontier to Sol's mature industrial and logistics base. Personnel, ships, equipment, construction materials, supplies, and later resource output can move through the AWS corridor. The process expands the network through successive discoveries and deliberate route reassignment rather than by assuming every discovered system receives a permanently additional Sol link.

This is the expected expansion pattern, not a guarantee that every natural shift reveals a prize system or that every survey leads to AWS construction. The AI Manager makes those decisions from survey evidence, network priorities, available resources, and operating costs.

The exact physical/operational mechanism for disconnecting and reassigning the Sol-side route, endpoint movement or replacement, downtime and traffic handling, commissioning, capacity, and WTC authorization remain OPEN. Do not assume one AWS station supports multiple simultaneous pairs unless the design establishes that.

**Caution:** Inter-system “portal-gate at AWS” concepts (sometimes called Level 4b) remain more open than intra-system portal pairs and should not be treated as established.

---

## Networks, Hubs, and Frontier Route Reconfiguration

**DIRECTION — OWNER-CONFIRMED EXPANSION INTENT**

- Each AWS pair provides a specific inter-system connection. A hub can host multiple pairs, with travelers/assets transferring between connections. Any suitable major settlement or station complex may become a hub.
- No fixed hub list or hard link cap is set. Earth/L1 → Mercury → Mars → Ceres → Jupiter → Saturn → Pluto is an example of one possible network, not required topology.
- Other star systems can develop their own independent system-local portal networks. Intra-system portals remain distinct from the full-scale AWS links that connect star systems.

### Frontier integration by reassignment

A key purpose of a reconfigurable AWS network is to let an established industrial system extend logistics into a newly discovered frontier without treating the original network layout as permanent.

A representative expansion scenario:

1. Sol scouts a previously unvisited/virgin system through a naturally shifting wormhole. Scouting and initial assessment can use the natural connection while it is available; discovery does not itself make the system permanently accessible.
2. If the system is a worthwhile settlement or resource-extraction target, the network operator establishes the required infrastructure there, potentially including a new AWS station and its paired endpoint.
3. The new frontier system is connected into Sol's existing artificial-wormhole network. An existing Sol-side artificial connection/route can be reassigned to serve the new system.
4. The route displaced by that reassignment can in turn be retargeted to a different system. This allows the network to be reorganized as new systems become strategically important, rather than only adding permanent branches to an immutable topology.
5. The resulting AWS corridor links the new frontier to an industrially developed system such as Sol, allowing personnel, ships, equipment, construction materials, and supplies to move much faster than relying on ordinary interstellar transit. It supports settlement and resource extraction by coupling frontier resources to mature industrial capacity.

This is an example of intended network strategy, not a fixed mandatory sequence or a claim that every discovered system must receive an AWS. Natural access can remain useful while available; committing to AWS infrastructure is a strategic investment based on the value of settlement, extraction, and sustained logistics.

The network must distinguish a system's existence/discovery from its current route accessibility. Reassignment changes the active route topology; it does not delete the system or imply that its former natural connection never existed.

**Still OPEN:** the exact physical/operational procedure for reassigning an existing Sol-side AWS connection, whether a station endpoint is moved, shut down and recommissioned, or replaced by a newly built paired endpoint; transition downtime and traffic handling; commissioning requirements; capacity limits; and how the WTC schedules, authorizes, and records route changes. Do not infer that one AWS station can support multiple simultaneous pairs unless the actual design establishes that.

---

## Institutional Control of the Network

**DIRECTION**

The primary arterial wormhole / AWS network is managed by the **Wormhole Transit Consortium (WTC)**, the organization that developed the artificial wormhole technology. It builds, maintains, and manages the inter-system network and its core connections. The consortium's exact governance, regulatory powers, ownership model, and commercial rules remain OPEN.

Players operate as contractors, specialists, private logistics firms, or later private pair operators within that framework — not as sole owners of the entire network. Exact ownership and toll rules remain OPEN.

---

## Current implementation comparison

**SOURCE INSPECTION — 2026-11-14; PARTIAL, NOT A COMPLETE AUDIT**

The current `Wormhole` model distinguishes natural and artificial connections with a boolean field and provides basic endpoint, mass-limit, stability, and stabilizer behavior. That is not evidence that the artificial technology-development and network lifecycle described above is implemented.

The inspected consortium/discovery path is also inconsistent with the current design intent:
- `StarSim::Wormholes::DiscoveryService` attempts consortium formation after a wormhole discovery, rather than as a demonstrated post-Snap research and technology-development outcome.
- Its formation check requires organizations `ASTROLIFT`, `ZENITH`, and `VECTOR`.
- `WormholeConsortiumFormationService` instead records `ASTROLIFT` and `LDC` as founding members and applies fixed equal investments.
- These paths do not establish the confirmed institutional history or prove that the Consortium develops artificial wormhole technology and operates the inter-system network.
- The inspected files do not demonstrate the full-scale artificial Sol–Eden research/reconnection sequence, portal miniaturization as a derived technology, or a player-arrival gate based on network/portal readiness.

Relevant source paths inspected:
- `galaxy_game/app/models/wormhole.rb`
- `galaxy_game/app/services/star_sim/wormholes/discovery_service.rb`
- `galaxy_game/app/services/wormhole_consortium_formation_service.rb`
- `galaxy_game/app/services/wormhole_expansion_service.rb`
- `galaxy_game/app/services/ai_manager/wormhole_scouting_service.rb`

This is a focused source comparison, not a complete audit of all AWS, portal, organization, research, and player-entry code. Do not infer implementation from class names or comments. The owner-confirmed sequence above remains the design authority; unresolved implementation gaps should be reviewed before tasks are created.

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
- Player ownership / toll limits relative to the Wormhole Transit Consortium (WTC)-managed network.
- Exact commissioning and operational criteria that must be satisfied before player arrival is enabled.
- Portal mass limits and how the reset works. Never defined; the aperture is small, but no numbers are set.
- Whether both halves ship on one mission or two, and whether one half can be installed at an existing station while the other goes to a new settlement.
- Whether placing both halves activates the link or needs a separate commissioning step.
- How destroyed endpoints are repaired, replaced or re-paired. Today, losing one half ends the pair.
- What happens if the data network cannot confirm both ends, and how much signal lag matters.
- What happens to anything in transit when a link shuts down for lack of EM.
- What closes a portal or artificial rift: which side may close it, whether closing has a cost or a delay, and whether a link left idle is closed automatically.
- How many portal pairs a settlement or hub can host. No hard cap is set; numeric limits are OPEN.

All numerical values remain **OPEN**.
