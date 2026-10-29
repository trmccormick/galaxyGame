> **Wiki Section:** Engineering · **Status:** Draft — AI Manager backend protocol for Sol–Eden reconnection

# Post-Snap Reconnection Protocol (Sol–Eden)

> **Ground Truth Authority:** All AWS construction, anchor verification, and cycler routing must conform to the Pre-Player Era dependency chain in [Station Construction Options](../engineering/station_construction_options.md). The AI Manager's four-phase reconnection pipeline must respect all anchor mass thresholds defined therein.

Backend operational sequence by which the AI Manager restores the interstellar corridor after a Natural Wormhole Stochastic Exit ("the Snap") severs the Sol–Eden link. This document defines the deterministic four-phase pipeline executed autonomously by Sol-side infrastructure — no Eden local stockpiles, no external aid, no pre-existing exit-side infrastructure.

---

## Overview

A natural wormhole (NWH) provides the Sol–Eden interstellar corridor: a fixed anchor at Sol with a stochastic exit that drifts as transit mass accumulates. As outgoing cargo, ships, and infrastructure push toward the Mass Displacement Threshold ($M_{\text{max}}$), the aperture bleeds excess Exotic Matter (EM) into the surrounding spacetime. Stabilization satellites and Wormhole Stations (WS) capture this bleeding EM — redirecting a portion back into the aperture manifold to "re-knit" spacetime and reset mass counters, while boxing surplus as high-value commodity for network-wide portal trade.

The Snap occurs when the NWH exceeds $M_{\text{max}}$ without active EM management: the exit aperture collapses and repositions, severing the Sol–Eden corridor instantaneously. **Sol's broader interplanetary operations continue unaffected.** Luna settlements, Mars logistics, asteroid mining, and inner-system trade persist normally. Only the interstellar link is lost: outbound trade to Eden ceases, any WS at the legacy exit becomes orphaned, and stabilization assets across the former link are stranded.

Reconnection executes as an AI Manager protocol — four phases of deterministic infrastructure deployment and conversion:

1. **Sol-Side AWS Construction & High-Strain Single-Node Open**
2. **Fleet Convergence & Fuel Loop**
3. **Relocation & Deep Conversion**
4. **Handoff & Maintenance Loop**

---

## Phase 1: Sol-Side AWS Construction & High-Strain Single-Node Open

### Objective

Construct an Artificial Wormhole Station (AWS) at the Sol side and initiate the artificial rift toward pre-calculated Eden coordinates — then immediately stabilize the resulting manifold strain by deploying emergency satellites through the active portal.

### Mechanics

**Sol-Side AWS Deployment:**
Using prior cartography data from NWH monitoring, the AI Manager identifies optimal exit coordinates in Eden — positioned opposite a gas giant or large planetary body for gravitational counterbalance. Sol constructs an AWS positioned precisely opposite Saturn (or another large gas giant) within Sol's system to serve as the near-end portal anchor. This engineered aperture is not inherited from the collapsed NWH; it is built fresh with controlled parameters.

**High-Strain Single-Node Open:**
The artificial wormhole link to Eden is initiated through the Sol-side AWS node alone. Without a far-end counterbalance, the manifold experiences extreme tension across the full interstellar span. The aperture holds — but precariously. This phase creates the portal channel; it does **not** produce a stable corridor.

**Emergency Stabilization Satellite Deployment:**
Stabilization satellites deploy *through* the newly opened portal to the Eden-side target coordinates — not around the Sol-side aperture. They establish EM capture arrays at the new exit point first, anchoring the far-end manifold and dramatically reducing the strain that a single-node open imposes on the Sol-side anchor. Only after stabilization is confirmed does the corridor carry cargo-class assets.

### Telemetry Establishment

With the portal channel active and initial stabilization underway, telemetry instruments lock onto the corridor:

| Data Channel | Purpose |
|-------------|---------|
| **EM Density & Mass Displacement Flow** | Tracks bleed rate at each endpoint; feeds commodity storage and re-knit energy allocation calculations |
| **Exit Coordinates & Gravitational Offset** | Confirms Eden-side target alignment opposite the selected planetary anchor; verifies gravitational counterbalance positioning |
| **Residual EM Mass** | Quantifies total bloom yield available at both endpoints; determines EM harvest volume for Phase 2 operations and cycler refit fuel budget |
| **Transit Vector & Heavy Tug Positioning** | Maps the direct corridor path through the active portal to Eden's legacy anchor site; tracks tug transit progress toward stranded WS coordinates |

### Operational Timeline

Stabilization dome reaches nominal coverage in **2–5 days**. Telemetry feeds remain active throughout and are updated continuously. With stabilization confirmed, Phase 2 assets enter the corridor.

---

## Phase 2: Fleet Convergence & Fuel Loop

### Objective

Transit a Heavy Tug and EM Harvesters through the stabilized portal to the stranded legacy Wormhole Station (WS) in Eden; modify/retrofit the WS's storage arrays on-site and dump raw harvested EM into its containment banks to serve as a transport battery for relocation.

### Mechanics

**Fleet Transit:**
A single standard Heavy Tug and dedicated EM Harvesters depart Sol through the stabilized portal, traveling directly to Eden's legacy anchor coordinates — no intermediate waypoint required. Transit duration: **5–7 days** through the active corridor (versus conventional transit that would have been impossible without it).

**On-Site Storage Retrofit:**
EM Harvesters dock with the stranded WS and modify its storage arrays on-site, converting existing infrastructure to accept raw EM influx. The legacy WS was not built as an AWS; it must be upgraded before any relocation can occur.

**EM Harvesting & Transport Battery Charge:**
Harvesters deploy capture arrays into the residual EM bloom at the legacy anchor site — a "Hot Start" condition from the Shift Discharge. Raw harvested EM is dumped directly into the WS's newly retrofitted containment banks, turning the station itself into a transport battery:

- Each harvester condenses exotic matter into storable containment vessels within the WS
- Harvest rate scales with: residual EM mass, harvester density, bloom proximity to gravitational anchor (closer to Jupiter/Saturn-class bodies = slower dissipation = longer harvesting window)
- The WS's containment banks fill until the transport battery reaches capacity for the relocation journey

| Residual EM Yield | Consequence |
|-------------------|-------------|
| **Sufficient for AWS refit** (primary outcome) | WS conversion proceeds; permanent link established with local EM buffer for maintenance |
| **Partial yield** (below threshold) | WS relocation delayed until supplemental EM arrives via secondary harvester dispatch |
| **Insufficient or dissipated** (edge case: legacy site too distant, bloom consumed before harvesters arrive) | System classified as effectively Cold Start; permanent link requires ongoing EM supply chain from Sol |

### Operational Timeline

Harvesting window is time-limited by bloom dissipation. Initial harvester deployment and peak extraction: **3–10 days**. Full yield capture within **10–21 days** if gravitational counterbalance extends bloom lifetime. With transport battery charged, Phase 3 proceeds.

---

## Phase 3: Relocation & Deep Conversion

### Objective

Haul the EM-loaded legacy WS to the pre-calculated exit coordinates via Heavy Tug; deploy a Cycler with heavy focus arrays and refit modules to re-engineer the station into Eden's exit-side AWS — completing the dual-node architecture.

### Mechanics

**Heavy Tug Relocation:**
The Heavy Tug hauls the loaded legacy WS through the active portal from the legacy anchor site toward the pre-calculated target exit coordinates (identified during Phase 1 telemetry as opposite a gas giant or large planetary body for gravitational counterbalance). The tug aligns the station at the target site, positioning it for permanent AWS configuration:

- **Planetary Anchor Model:** Positioned opposite a large natural planetary body (Jupiter-class or Saturn-class) at 180° relative to the exit vector. The planet's mass provides passive gravitational tension that stabilizes the aperture and reduces maintenance costs by 0.3x to 0.5x.

**Cycler Deep Conversion Delivery:**
A dedicated Cycler departs Sol through the active portal carrying heavy focus arrays and refit modules, powered by the EM transport battery stored in the WS's containment banks. The Cycler arrives at the target exit coordinates and attaches directly to the relocated WS — re-engineering it into Eden's exit AWS:

| Phase | Duration (Typical) | Activities |
|-------|-------------------|------------|
| **Arrival** | 30 days | Dock with relocated WS; deploy refit drones; establish heavy focus array interface |
| **Module Integration** | 120–180 days | Install gravitational counterbalance mass blocks; deploy permanent EM capture & redistribution arrays; connect EM storage to WS portal engines and stabilization systems |
| **Power-Up** | 30 days | Activate AWS portal engine using stored EM payload; run deep conversion diagnostics; initialize telemetry feeds to Sol control |

### Operational Timeline

Full cycler mission: **180–240 days** (approximately 6–8 months). Power-up diagnostics and final confirmation add **30 more days**. Total from Phase 3 initiation to deep conversion complete: **~6–9 months**. With conversion confirmed, Phase 4 proceeds.

---

## Phase 4: Handoff & Maintenance Loop

### Objective

Ignite the new Eden AWS using its stored EM payload, lock in a permanent dual-node link, and reel in stabilization satellites for storage as hot-swappable emergency backups — completing the AI Manager reconnection protocol.

### Mechanics

**AWS Ignition & Dual-Node Lock:**
The newly converted Eden AWS ignites using the EM payload stored in its transport battery. Portal engine activation produces a stable exit aperture; gravitational counterbalance engagement (via planetary anchor) locks the manifold. The Sol-side AWS and Eden far-end AWS form a **permanent dual-node architecture** — balanced, self-sustaining, and operational for transit.

The artificial wormhole link is **officially active**. Both endpoints confirm:
- Engineered aperture dimensions within design parameters (aperture is built-to-spec, not inherited from the collapsed NWH)
- Gravitational counterbalance engaged at 180° position
- EM storage at minimum threshold for maintenance operations
- Stabilization arrays operational and transmitting telemetry to Sol

**Stabilization Satellite Retrieval & Storage:**
The newly stabilized AWS reels in all stabilization satellites deployed during Phase 1. These satellites — originally emergency deployment assets now surplus to requirements — are stored onboard as hot-swappable emergency backups for future station maintenance and repair cycles:

- Satellites remain powered and charged at the Eden AWS storage bays
- Deployment capability is retained for rapid emergency response to manifold strain events
- Maintenance scheduling integrates satellite swap-out cycles into the AI Manager's station health protocol

### Operational Timeline

AWS ignition and dual-node lock: **1–3 days** post-completion of Phase 3. Satellite retrieval and storage: integrated into final Power-Up phase, completing reconnection protocol.

---

## AI Manager System Handover State (Act 2 Start)

When the player enters the game world, the AI Manager's reconnection protocol has completed — or is in its final stages. The operational handover defines what infrastructure state and resource baseline the AI Manager cedes to the player at the start of Act 2:

| System | Handover State |
|--------|---------------|
| **Interstellar Link** | Active dual-node AWS architecture; stable outbound transit available across Sol–Eden corridor |
| **Trade Network** | Partially restored — initial contracts available via active portal, but full network coverage requires player-directed expansion of secondary links |
| **EM Supply** | Baseline buffer established from Phase 2 harvest yield; maintenance drains ongoing but manageable without supplemental shipments (Cold Start systems require player-directed EM delivery scheduling) |
| **Eden AWS Node** | Fully refitted and operational; serves as primary gateway for player expansion choices |
| **Stabilization Satellites** | Stored onboard Eden AWS as hot-swappable emergency backups — maintenance integration active but under AI Manager oversight |
| **AI Manager Status** | Internal recovery complete; cedes infrastructure assessment and expansion decisions to the player while continuing background monitoring of portal stability |

### Player Resource Baseline

The player inherits a system that has just survived an existential event — not a blank slate:

1. **Infrastructure to expand** — Dual AWS nodes are active but require player-directed counterbalance reinforcement and secondary link construction for network resilience
2. **Resources available** — EM baseline from Phase 2 harvest established; maintenance drains ongoing; player must decide whether to sustain current buffer or invest in expansion
3. **Strategic choices open** — Which systems to reconnect with (if other wormhole paths exist), which settlement patterns to deploy, and how to rebuild trade networks across restored interstellar capacity

The AI Manager does not restart the world for the player. It restores what it can autonomously, then hands off operational control at a defined resource state — constraining but enabling player agency from Act 2's first turn.

---

## Appendix: Terminology Reference

| Term | Definition |
|------|------------|
| **NWH** | Natural Wormhole — An uncontrolled, naturally occurring interstellar link featuring a localized anchor and a stochastic exit point that drifts as transit mass accumulates (with stability varying wildly depending on the local astronomical environment, such as Sol's unusually stable spawn point). |
| **AWS** | Artificial Wormhole Station — a constructed high-mass station that serves as an artificial gravitational counterbalance, enabling permanent wormhole links |
| **EM (Exotic Matter)** | Energy-dense spacetime material released by wormhole collapse events; primary fuel for artificial link construction and maintenance |
| **Hot Start** | A wormhole exit site with sufficient residual EM from a recent Snap to enable autonomous harvesting and rapid reconnection |
| **Cold Start** | A wormhole exit site with zero or negligible residual EM; requires permanent external EM supply chain |
| **Shift Discharge** | The massive EM release that occurs when a natural wormhole collapses, depositing exotic matter at both anchor and exit points simultaneously |
| **Stabilization Satellite (Harvest Mode)** | Stabilization satellite deployed in residual EM bloom to siphon exotic matter, reduce EM density via capture arrays, and "re-knit" spacetime by removing destabilizing concentration at the aperture zone |
| **Orphaned Asset** | Any mobile drone, satellite, or station left without link access during a Snap event |
| **Transport Battery** | Raw harvested EM stored in retrofitted WS containment banks for use as relocation fuel and AWS ignition payload |

---

## References

- Wormhole Mechanics: [`docs/architecture/logistics/wormhole_system.md`](../../architecture/logistics/wormhole_system.md)
- Cycler Mission Timelines: [`docs/architecture/services/ai_manager/CYCLER_MISSION_TIMELINES.md`](../../architecture/services/ai_manager/cycler_mission_timelines.md)
- Act 3 Snap Crisis / Story Arc: [`docs/storyline/01_story_arc.md`](../../storyline/01_story_arc.md)
- Wormhole Network Architecture: [`docs/architecture/logistics/navigation/WORMHOLE_NETWORK.md`](../../architecture/logistics/navigation/WORMHOLE_NETWORK.md)
