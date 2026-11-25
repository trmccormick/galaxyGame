# Portals & Artificial Wormhole Stations (AWS)
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-14  
> *Audit Summary:* Owner-confirmed technology lineage and player-arrival prerequisite reviewed. Related wormhole and consortium source paths inspected; existing code is only partially aligned and does not establish the post-Snap research, reconnection, portal-miniaturization, or player-entry sequence.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-14  
**Related**: [natural_wormholes_and_em.md](natural_wormholes_and_em.md), [eden_disconnect_and_emergent_history.md](../player/eden_disconnect_and_emergent_history.md), [terraforming_options.md](../infrastructure/terraforming_options.md), logistics pages

This page is the wiki home for **intra-system portals**, **Wormhole Stations (WS)**, and **Artificial Wormhole Stations (AWS)**. Natural wormhole physics, mass limits, the Snap, counterbalance, and Exotic Matter (EM) behavior live on [Natural Wormholes & EM](natural_wormholes_and_em.md). WS and AWS are station/infrastructure roles defined by the technologies they house and operate; neither station's physical mass creates wormhole counterbalance.

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
- **Primary purpose — personnel movement and limited mass transfer:** portals provide rapid movement for players and the wider human population, while also allowing a bounded amount of physical cargo to pass between the paired locations. They are not personnel-only connections.
- A portal is a physical doorway through a small rift, not a selective transporter. People, objects, materials, gases, and liquids can pass through in either direction while it is open; the aperture constrains the dimensions of what can pass. Atmospheric exchange is therefore possible, and pressure, temperature, and composition differences can create environmental hazards. Portals can transfer materials, but their small scale and wormhole-physics mass limits constrain practical throughput. They are not a substitute for ships or bulk industrial freight infrastructure. Exact aperture dimensions and mass limits remain OPEN.
- Portals supplement rather than replace cyclers, freighters, and mass drivers for moving most industrial and bulk material.
- **A portal pair connects two specific destinations.** The endpoints are deployed at the two locations the connection is intended to serve; a pair is not a general, freely addressable network gateway.

**DIRECTION**

- Standalone manufactured infrastructure. They do **not** require natural or artificial wormhole anchoring.
- Built as **quantum-entangled pairs**. Both halves are manufactured together, then shipped and deployed. Unpaired units are non-functional. Loss of one half ends the pair.
- **Location-to-location access — OWNER-CONFIRMED INTENT (2026-11-20):** each deployed pair provides rapid personnel access between its two host locations within the same star system. A settlement may establish a connection from its own base to another settlement or major facility, such as a large NPC base or an orbital station. The purpose is convenient movement for players and the wider human population between important inhabited locations.
- A settlement can establish additional pairs to reach additional destinations. A major station or settlement can therefore host endpoints for multiple separate connections; each pair still represents its own specific link.
- **Hosting and ownership — OWNER-CONFIRMED INTENT (2026-11-20):** a player settlement may own and deploy the portal infrastructure at its own base and arrange to place the paired endpoint at an NPC-owned station or settlement. The player can lease space or make another agreement with the NPC facility owner for that endpoint. Hosting an endpoint does not by itself transfer ownership of the portal hardware or the host facility; the host retains its station/settlement and premises, while portal ownership and operating rights follow the applicable authorization or agreement. The general intent is that the entity establishing/deploying an asset owns it unless WTC authorization or an agreement specifies otherwise.
- **Transfer limits:** portals are not categorically restricted to personnel or selected cargo types. The physical aperture limits object dimensions, and the shared wormhole mass-transfer physics limits how much mass can pass. This makes portals unsuitable as replacements for industrial bulk-freight systems in ordinary operation, without imposing an arbitrary cargo-category ban. Ships and large-scale freight remain the role of cyclers, freighters, and mass drivers.
- **Energy and transfer model — WORKING DIRECTION (2026-11-20):** EM is likely used to initiate/open the rift; fusion/electrical power and magnetic containment maintain the open aperture. EM may also be used to reinforce the rift and restore/reset available mass-transfer capacity. The amount of EM associated with transfer may scale with the mass passing through, following the same general wormhole physics. Exact equations, endpoint accounting, capacity behavior, and the role of EM during sustained operation remain OPEN.
- **Emergency shutdown:** fusion brownout → capacitor-backed controlled pinch → dormant. No designed explosive blowout.
- **Operation** (owner, 2026-11-07):
  - **If the EM supply is unavailable, the link shuts down.** Nothing further is defined. The design task is to set how much EM a portal consumes.
  - Both halves are in the same system and linked by the data network, which confirms both are online before a transit opens. Signal lag across the network is expected.
  - One endpoint fires and opens the rift; the other locks on and stabilizes it, as in an AWS pair. Either half can fire; only one does for a given opening.
  - The firing side uses the most EM, at the opening. Portals also spend EM to reinforce the rift and reset mass limits, as wormhole stabilization does, because the stabilization technology is built into the portal. Fusion or electrical power runs the magnetic fields.
  - Once open, the rift stays open until either side closes it or can no longer maintain it (see the next point). This applies to portals and artificial wormholes. Natural wormholes follow their own lifecycle: the historical Eden Snap is an uncontrolled failure caused by accumulated mass throughput without stabilization; the Hammer Protocol may separately use a deliberate final transit to force an exit shift. Do not call the historical Snap a planned or controlled closure ([Hammer Protocol](natural_wormholes_and_em.md)).
  - **Both ends maintain the rift** (owner brainstorm, 2026-11-14; DIRECTION, not locked): each end supplies the power, and a small amount of EM, to keep its magnetic confinement field running. If either end cannot, the rift destabilizes and closes. How the failure closes the rift (a controlled pinch or something rougher), any grace window, and the amounts remain OPEN.
  - **Shared wormhole physics — OWNER CLARIFICATION (2026-11-20):** portals are a smaller-scale implementation of the same rift technology and physical principles as full-scale wormholes, not a separate transport technology. Their smaller aperture and lower power budget limit them to intra-system connections. Mass transfer is expected to remain EM-bounded in a manner analogous to wormholes, with transfer accounted for at each endpoint/side. Do not assume the full-scale counterbalance implementation applies unchanged to portals; the precise scale-dependent counterbalance behavior remains OPEN.
- **Environmental variants:**
  - **Habitat-rated** — pressurized human spaces; pressure checks/controls may be needed before opening. The portal itself does not block gas flow: atmosphere can flow through the open aperture in either direction.
  - **Industrial / surface-rated** — ruggedized; may run with intentional atmospheric bleed (“garden hose”) for pressure-first protection; not a bulk terraforming pipeline.
  - **Vacuum-rated** — station exterior / near-vacuum pairs.
- Structural mount must be serious (primary structure / keel-class). Not a light-hull bolt-on.
- **Research lineage — ESTABLISHED INTENT:** Full-scale artificial wormhole technology is developed through aggressive post-Snap research and is used to open the artificial Sol–Eden connection. Miniaturization of that technology produces intra-system portals as an offshoot. Exact research stages, technology levels, prerequisites, and timing remain OPEN. Older technology-tree level labels are not authoritative until reconciled with this sequence.

### Wormhole Stations (WS)
**ESTABLISHED TECHNOLOGY ROLE — OWNER CLARIFICATION, 2026-11-22**

A WS is a station that houses and operates the technology used to stabilize a natural wormhole and recover its ejected Exotic Matter (EM). Its stabilization equipment captures ejected EM and returns it to the corresponding natural aperture, restoring that aperture's mass-transfer capacity as described in [Natural Wormholes & EM](natural_wormholes_and_em.md). The WS is the platform for this technology; its physical mass does not create counterbalance or solve the wormhole's gravitational disturbance.

### Artificial Wormhole Stations (AWS)
**DIRECTION / OPEN**

An AWS is a station that houses and operates the technology used to open and maintain an artificial wormhole connection. It is infrastructure for the artificial-wormhole technology, not the source of the gravitational counterbalance.

- Full-scale inter-system (and large-scale) infrastructure.
- Built in pairs. One station initiates the rift; the paired station locks on and maintains the artificial connection.
- Once open, the artificial rift remains open until either station closes it or can no longer maintain it. Natural wormholes follow their own lifecycle and may shift or snap; see [Natural Wormholes & EM](natural_wormholes_and_em.md).
- Can move personnel and heavier cargo (exact mass envelope still OPEN).
- High capital, power, and EM cost to establish and maintain.
- **Wormhole gravitational disturbance and counterbalance — ESTABLISHED DESIGN INTENT, clarified 2026-11-22:** The wormhole itself is the source of the gravitational disturbance that creates the counterbalance problem. Counterbalance is a physical effect of the gravitational configuration, not a property supplied by a station. A suitable natural mass arrangement can provide natural counterbalance. Alternatively, when an artificial wormhole is opened at an appropriately opposing location relative to a natural aperture, the artificial rift itself creates the artificial gravitational anchor; the natural and artificial rifts then provide the opposing-anchor arrangement. The AWS is simply the station housing and operating the technology that opens and maintains that artificial connection. Its physical mass is not the anchor, and artificial counterbalance is not a separate AWS module or station procedure. Effective counterbalance reduces the natural aperture's instability and associated stabilization burden and EM drain/loss; it does not make opening or closing a connection free or eliminate all EM requirements. A WS similarly houses and operates natural-wormhole stabilization and EM-recovery technology; it does not create counterbalance through its mass. The AI Manager evaluates the actual geometry and stability at each relevant aperture. Exact equations, thresholds, and quantitative performance remain OPEN.
- Opening an inter-system AWS pair is a major infrastructure and network-expansion investment.
- Eden reconnection is an example: early traffic is limited to the initial equipment and operations required to establish the connection and stabilize the Eden side ([Eden page](../player/eden_disconnect_and_emergent_history.md)).

**Hammer Protocol and frontier-network expansion — WORKING DESIGN DIRECTION — OWNER-PROPOSED LIKELY EXPANSION PATTERN, 2026-11-20**

The intended expansion pattern is a repeating survey → evaluate → exploit or integrate → release/shift cycle. A natural wormhole provides access to a candidate system; it may remain a temporary harvesting route for an extended period, or it may be replaced by a permanent AWS connection when the system merits settlement and long-term integration. A survey does not automatically trigger AWS construction or a Hammer Protocol event.

1. **Natural access changes.** A natural wormhole may shift as part of its lifecycle, potentially in response to reaching a mass limit, or its exit may be deliberately shifted through the Hammer Protocol. The precise relationship between mass-limit exhaustion, a natural shift, and an uncontrolled snap needs reconciliation with the natural-wormhole physics model; do not treat those events as interchangeable.
2. **AI Manager announces survey missions.** When a newly accessible frontier becomes available, the AI Manager can offer survey missions to players. Players explore the system and return information about its celestial bodies, resources, EM field, and terraforming/settlement potential. A system is not automatically a prize merely because it was discovered.
3. **Evaluate the prize system.** Survey results identify whether the system has unusually valuable resources, worthwhile terraforming targets, or other strategic value. The AI Manager evaluates the findings against Sol's needs, expansion costs, and the value of keeping the natural route open.
4. **Select AWS placement and counterbalance geometry.** For a valuable system, the AI Manager evaluates the natural counterbalance available at each relevant aperture and the placement of any proposed artificial connection. If the local natural mass arrangement is suitable, it may be preferable to preserve and exploit that naturally counterbalanced connection. If it is not suitable, an AWS artificial rift can be opened at an appropriately opposing location; that rift creates the artificial gravitational anchor that counterbalances the natural wormhole. The AWS endpoint's location therefore matters because of the rift it opens, not because the station's physical mass acts as a planet-scale anchor. Depending on the system's geometry and network requirements, the plan may require more than one AWS installation or route. Orbital movement, transit, construction, and resupply also matter.
5. **Build while natural access remains open.** The required AWS infrastructure is constructed and commissioned while the natural wormhole still provides access. This allows the temporary natural route to support deployment and construction logistics.
6. **Reassign an existing Sol network route.** Once the new frontier-side AWS endpoint is ready, an active Sol-side artificial route serving another system can be disconnected and reassigned to connect Sol to one of the new AWS stations. This makes the new prize system part of Sol's artificial network. The displaced route/connection can then be retargeted to another system as part of the same broader network reorganization. The intended outcome is a durable artificial logistics corridor from Sol to the new frontier, not a permanently expanding collection of fixed links.
7. **Choose what happens to the natural route.** The AI Manager is not required to hammer every discovered natural wormhole. If the system is not selected for permanent AWS reconnection or settlement, the AI Manager may keep the natural wormhole open and stabilized with stabilization satellites for as long as it remains useful, allowing players to continue harvesting its resources. When the AI Manager decides that access is no longer worth maintaining, it can either use the Hammer Protocol to force the natural exit to shift or remove the stabilization satellites and allow the wormhole to degrade naturally. If the system has been integrated through AWS and the natural route is no longer needed, the Hammer Protocol can move that natural connection on to a new location and create another survey opportunity.

The strategic payoff is that a temporary natural connection is used to discover and develop a valuable frontier, while a reconfigured artificial network connects that frontier to Sol's mature industrial and logistics base. Personnel, ships, equipment, construction materials, supplies, and later resource output can move through the AWS corridor. The process expands the network through successive discoveries and deliberate route reassignment rather than by assuming every discovered system receives a permanently additional Sol link.

This is the owner's likely expansion pattern, not yet a locked rule or a guarantee that every natural shift reveals a prize system or that every survey leads to AWS construction. The AI Manager makes those decisions from survey evidence, network priorities, available resources, harvesting value, stabilization requirements, and operating costs. A non-selected system may remain naturally accessible under satellite stabilization for an extended or indefinite period; hammering or allowing natural degradation is an operational choice, not an automatic cleanup step.

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

This is an example of intended network strategy, not a fixed mandatory sequence or a claim that every discovered system must receive an AWS. Natural access can remain useful while available. Stabilization satellites can keep a natural route open for continued player harvesting for as long as the AI Manager chooses to support it. The AI Manager can later use the Hammer Protocol to shift the exit deliberately, or remove the satellites and let the wormhole degrade naturally. Committing to AWS infrastructure is a separate strategic investment based on the value of settlement, extraction, and sustained logistics.

The network must distinguish a system's existence/discovery from its current route accessibility. Reassignment changes the active route topology; it does not delete the system or imply that its former natural connection never existed.

**Still OPEN:** the exact physical/operational procedure for reassigning an existing Sol-side AWS connection, whether a station endpoint is moved, shut down and recommissioned, or replaced by a newly built paired endpoint; transition downtime and traffic handling; commissioning requirements; capacity limits; and how the WTC schedules, authorizes, and records route changes. Do not infer that one AWS station can support multiple simultaneous pairs unless the actual design establishes that.

---


## Controlled network scalability exercise

**OWNER-CONFIRMED FUTURE TEST DIRECTION — 2026-11-20; implementation OPEN**

A future stress exercise may build an artificial wormhole network across a mixed batch of known Local Bubble systems and StarSim-generated test systems. The initial batch can be modest; a larger run approaching 1,000 systems is a scalability benchmark, not a production system-count decision.

Use complete standard AWS installations. Do not assume one AWS installation per system: the required number and placement depend on the network topology and the actual counterbalance/placement rules. Some systems may be simple endpoints with one installation, while junctions or systems supporting multiple links may require two or more. The test should create a connected network and validate each connection and its endpoint infrastructure.

EM resource availability/production restrictions may be bypassed for this controlled test so they do not block construction. Do not bypass placement geometry, counterbalance requirements, AWS pairing/endpoint rules, or connectivity checks. This is not a change to normal game economics or the physical design.

The exercise should measure generation/completion and deployment time, AWS placement success, network connectivity/topology, and the game's ability to display and manage the resulting network. Actual implementation capability and benchmark procedure remain to be established; no claim is made that this test currently exists.

## Institutional Control, Ownership, and Operation of the Network

**OWNER-CONFIRMED NETWORK ROLE; OWNERSHIP AND COMMERCIAL ARRANGEMENTS OPEN — 2026-11-20**

The **Wormhole Transit Consortium (WTC)** is responsible for maintaining and coordinating the artificial-wormhole and portal networks, including AWS, WS, and intra-system portal infrastructure. This network responsibility does **not** automatically establish that the WTC owns every connected portal, station, or facility, or that it directly operates every individual facility. The WTC's role in authorizing and coordinating network connections is distinct from ownership of locally deployed portal hardware and the premises hosting it.

Use the relationship between aircraft, ships, airlines/shipping companies, airports, and seaports as the model:

- **Vehicles and transport operators:** Player- and AI-operated spacecraft use the network; their owners/operators need not own the infrastructure they travel through.
- **Infrastructure ownership:** Multiple independent entities may own portals, AWS, WS, or associated facilities. Ownership need not be centralized in the WTC. The working default for locally established assets is ownership by the entity that establishes/deploys them, subject to WTC authorization and any agreement that assigns different rights.
- **Portal hosting agreements:** A player settlement may install one endpoint at its own base and lease space at an NPC station or settlement for the paired endpoint. The NPC owner retains the host facility and premises; the portal owner and host establish the applicable lease, access, support, and operating arrangements.
- **Facility operation:** An infrastructure owner may operate its own facility or contract another entity to operate it.
- **Network coordination and maintenance:** The WTC maintains and coordinates network-level infrastructure and services. This role is distinct from ownership and local facility operation.

A corporation could therefore own a portal, another entity could operate it, the WTC could maintain its network integration, and multiple independent transport operators could use it.

The WTC's exact maintenance arrangements, service contracts, funding, ownership distribution, access rules, transit charges, revenue flows, and any regulatory authority remain **OPEN**. Do not infer centralized WTC ownership from its network-maintenance responsibility, or assume that the WTC has authority to set fees or funding policy. Players and corporations may participate as transport operators, contractors, specialists, infrastructure owners, or facility operators. The confirmed portal-hosting example establishes the intended player/NPC relationship at a high level; detailed lease terms, power and support responsibilities, access rights, maintenance liability, and any fees remain unresolved.

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
- Portal EM model: opening/ignition cost, mass-transfer-related EM expenditure at each side, stabilization/reinforcement, capacity restoration/reset, and any ongoing operating cost. The relationship is expected to parallel full-scale wormhole physics, but equations and scale-specific behavior remain OPEN.
- The wider AWS/portal network depends on usable EM generated by natural wormholes. The natural-wormhole EM model must account separately for gross ejection, the EM returned to each aperture to restore its independent mass-transfer capacity, capture/return losses, and net EM available to operate AWS and portals. The candidate mass-throughput × instability-dependent modifier is still under discussion; no yield, recovery ratio, or operating budget is finalized. See [Natural Wormholes & EM](natural_wormholes_and_em.md).
- Fusion power draw by variant.
- Manufacturing recipes and facility requirements.
- Industrial bleed rate tunability.
- Inter-system portal-gate (Level 4b) scope, if any.
- Detailed WTC authorization and network-connection approval for privately established portal pairs.
- Lease terms and service obligations when a player-owned portal endpoint is hosted at an NPC station or settlement; power, support, access, maintenance liability, and fees.
- Whether any specific agreement changes the default ownership of portal hardware or grants operating rights to another entity.
- Exact commissioning and operational criteria that must be satisfied before player arrival is enabled.
- Portal aperture dimensions, per-side mass accounting, and the exact relationship between transferred mass and EM expenditure/capacity restoration. No numerical values or final equations are set.
- Whether both halves ship on one mission or two, and whether one half can be installed at an existing station while the other goes to a new settlement.
- Whether placing both halves activates the link or needs a separate commissioning step.
- How destroyed endpoints are repaired, replaced or re-paired. Today, losing one half ends the pair.
- What happens if the data network cannot confirm both ends, and how much signal lag matters.
- What happens to anything in transit when a link shuts down for lack of EM.
- What closes a portal or artificial rift: which side may close it, whether closing has a cost or a delay, and whether a link left idle is closed automatically.
- How many portal pairs a settlement or hub can host. No hard cap is set; numeric limits are OPEN.

All numerical values remain **OPEN**.
## EM supply requirements and WTC replenishment — ESTABLISHED DIRECTION / OPEN QUANTITIES

**Owner clarification — 2026-11-25**

AWS stations and portals are consumers of harvested EM; they do not create the natural EM resource. Natural wormholes generate EM, and systems that previously hosted a natural wormhole can retain finite, harvestable EM fields after the connection is gone. Players and AI Manager-operated harvesters can both collect from these fields.

Early harvesting should allow stations to build EM stockpiles for network establishment and operation. The WTC coordinates AWS supply and replenishment. The AI Manager should use its own harvesting operations where local EM is available and use existing market/procurement or import paths when local fields and reserves cannot meet demand. This supply model should not require players to perform most of the harvesting.

The amount of EM required by stations and portals, the split between establishment/ignition and ongoing operation, replenishment thresholds, stockpile targets, and allocation rules remain OPEN. Do not assign quantities or imply that the full EM consumption model is implemented.

For EM valuation and procurement, see [Markets, EAP, and GCC/USD Peg](../markets/markets_eap_and_peg.md). EM has no Earth reference price and therefore no EAP; initial AI Manager valuation needs either defensible real-world comparisons or a simplified modeled cost estimate, with a later transition to appropriate system- or settlement-level market-history averages once sufficient transactions exist.
