> **Wiki Section:** Engineering · **Status:** Draft — AI Manager backend protocol for Eden multi-node expansion

# System B Expansion Protocol (Eden Secondary Node)

> **Ground Truth Authority:** All AWS construction, asteroid anchoring, and cycler routing must conform to the Pre-Player Era dependency chain in [Station Construction Options](../engineering/station_construction_options.md). No AWS may be placed without verified planetary-mass counterbalance per Section 7 of that specification.

Backend operational sequence by which the AI Manager constructs a second Artificial Wormhole Station (AWS) opposite Gas Giant 17 in the Eden system, establishing a secondary interstellar corridor bridging outward toward System B. This document defines the deterministic construction, ignition, and multi-node routing pipeline — executed from Eden-side infrastructure with Sol supply-chain support during post-reconnection Act 2 handover.

---

## Overview

Following the successful completion of the Post-Snap Reconnection Protocol (Sol–Eden), the Eden system operates as a dual-node hub anchored by:

- **Primary Node:** Gas Giant 18 ($5.72 \times 10^{27}$ kg) — Sol trunk line, maximum passive gravitational tension.
- **Secondary Anchor:** Gas Giant 17 ($2.38 \times 10^{27}$ kg) — reserved for outward expansion toward System B.

With the Sol–Eden corridor stabilized and EM harvest/storage banks operational, the AI Manager initiates the **System B Expansion Protocol** to construct a second AWS opposite Gas Giant 17. This secondary node serves three strategic purposes:

1. **Network Expansion:** Bridges Eden outward to System B, enabling interstellar trade beyond the Sol–Eden axis.
2. **Load Balancing:** Distributes transit mass displacement across two apertures, reducing $M_{\text{max}}$ pressure on the primary Sol trunk line.
3. **Redundancy:** Provides an alternate access vector if the Sol link is severed again by a future Snap event.

The protocol operates within Eden's local resource economy and sol-supplied material chain, leveraging the existing WS infrastructure established during the reconnection protocol. Construction follows standard AWS parameters: 50,000 m³ volume, 2,000,000 kg dry mass, 1,440-hour build cycle.

---

## Phase 1: Orbital Placement & Gravitational Tension Analysis

### Objective

Calculate and execute the precise orbital placement of the secondary AWS opposite Gas Giant 17, establishing passive gravitational counterbalance that stabilizes the future aperture without active energy expenditure.

### Mechanics

**Gas Giant 17 Characterization:**

| Parameter | Value | Role in Protocol |
|-----------|-------|-----------------|
| **Mass** | $2.38 \times 10^{27}$ kg | Gravitational source for passive counterbalance |
| **Radius (estimated)** | ~60,000 km (Saturn-class) | Defines Hill sphere extent and stable orbital band |
| **Orbital Class** | Gas Giant | Provides GMST-compatible gravitational tension profile |
| **Proximity to Station Node** | Within capture radius of legacy WS array | Enables supply chain integration with Phase 2 infrastructure |

**Gravitational Tension Offset Calculation:**

The passive stabilization offset for the secondary aperture is derived from the Galactic Mass Standard Theory (GMST), which models gravitational counterbalance as a function of anchor mass and orbital distance:

$$
\Delta \theta_{\text{passive}} = k_g \cdot \frac{M_{\text{G17}}}{r_{\text{orbit}}^2} \cdot \sin(\phi)
$$

Where:
- $\Delta \theta_{\text{passive}}$ = passive gravitational tension offset (dimensionless manifold strain factor)
- $k_g$ = GMST coupling constant ($8.61 \times 10^{-47}$ kg⁻¹·m²)
- $M_{\text{G17}} = 2.38 \times 10^{27}$ kg (Gas Giant 17 mass)
- $r_{\text{orbit}}$ = orbital distance from Gas Giant 17 center to AWS placement position
- $\phi$ = angle between the aperture vector and the planet's gravity well axis (optimized at $\phi \approx 90^\circ$ for maximum perpendicular tension)

**Optimal Placement Coordinates:**

For Gas Giant 17's mass profile, GMST-derived calculations yield:

- **Preferred orbital band:** $r_{\text{orbit}} = 1.8 \times 10^9$ m (within G17's Hill sphere, outside Roche limit)
- **Angle relative to Sol vector:** $\phi \approx 87^\circ–93^\circ$ (perpendicular alignment for maximum counterbalance efficiency)
- **Expected passive stabilization factor:** $0.4x$ the maintenance EM cost of a standalone AWS (matching the Sol–Eden primary node efficiency band of $0.3x$–$0.5x$)

The AI Manager locks these coordinates as the **Secondary Target Apex** and deploys survey probes to confirm local spacetime curvature matches GMST predictions before construction begins.

### Telemetry Establishment

| Data Channel | Purpose |
|-------------|---------|
| **GMST Validation Feed** | Confirms G17's actual gravitational profile matches modeled counterbalance; flags divergence >5% before construction commit |
| **Hill Sphere Stability Map** | Verifies orbital band is free of debris, moon interference, or competing mass effects from nearby bodies |
| **Aperture Vector Alignment** | Tracks pre-construction orientation between the Secondary Target Apex and the projected System B transit vector |

### Operational Timeline

Survey probe deployment: **1–2 days**. GMST validation and coordinate lock: **2–4 hours** (purely computational). Construction authorization upon confirmation of $|\Delta \theta_{\text{passive}}|$ within design tolerance ($\pm 3\%$).

---

## Phase 2: Fabrication Logistics & Material Supply Chain

### Objective

Fulfill all material, component, and subsystem requirements for a standard AWS assembly at the Secondary Target Apex, sourcing from Eden terrestrial nodes and leveraging Sol-supplied baseline infrastructure established during the reconnection protocol.

### Standard AWS Parameters

| Specification | Value | Notes |
|---------------|-------|-------|
| **Volume** | 50,000 m³ | Standard modular envelope; identical to Sol-side AWS from Phase 1 of the reconnection protocol |
| **Dry Mass** | 2,000,000 kg | Base station structure without EM payload or active systems |
| **Build Cycle** | 1,440 hours (60 days) | Full assembly-from-kits; runs parallel to sol-supplied component delivery schedule |
| **Active Systems Mass** | ~350,000 kg | Focus arrays, synthetic field generators, EM storage, stabilization bus |

### Material Supply Chain Architecture

**Eden-Side Sourcing (Terrestrial Nodes):**

With the Sol–Eden corridor active and the legacy WS's retrofitted storage banks online, Eden's terrestrial infrastructure can supply structural materials locally:

| Material Category | Source Node Type | Supply Method | Estimated Delivery to Apex |
|-------------------|-----------------|---------------|---------------------------|
| **Primary Hull Plating** (Titanium-Carbide Composites) | Mars-class terrestrial processing stations | Heavy Tug cargo runs from Eden surface ports | Days 1–20 of build cycle |
| **Gravitational Counterbalance Blocks** (Depleted Exotic Matter Inerts) | Legacy WS residual EM capture arrays | Transfer via harvester-docked conduit lines | Available at Phase 3 start |
| **Focus Array Optics** (Photon-Conductive Crystal Lattices) | Sol-supplied via primary corridor | Dedicated cycler resupply run | Days 20–40 of build cycle |
| **Synthetic Field Generator Coils** (Superconducting Wire Bundles) | Luna-class orbital smelters (Sol side) | Corridor transit; integrated with Phase 1 telemetry assets | Days 30–50 of build cycle |

**Sol-to-Eden Supply Resupply Schedule:**

The AI Manager schedules Sol-side resupply runs through the stabilized primary corridor to deliver critical subsystems that cannot be sourced from Eden:

| Delivery Wave | Components | Transit Duration (via Corridor) | Build Cycle Integration |
|---------------|------------|-------------------------------|------------------------|
| **Wave Alpha** (Day 0–5 of fabrication) | Hull plating stockpiles, basic structural frames | 2–3 days (corridor-class tug speed) | Foundation assembly phase |
| **Wave Beta** (Day 15–25 of fabrication) | Focus array optics, synthetic field generator coils | 3–5 days (larger cycler cargo mass) | Subsystem integration phase |
| **Wave Gamma** (Day 40–50 of fabrication) | Final active systems, EM containment vessels, hot-swap satellite pods | 2–3 days (lighter final payload) | Power-up prep phase |

**Fabrication Execution:**

AWS construction proceeds at the Secondary Target Apex via automated assembler drones docked to supply stockpiles:

1. **Hull Assembly (Days 0–30):** Standard modular frame construction; structural plating applied in overlapping segments for manifold pressure tolerance.
2. **Subsystem Integration (Days 30–45):** Focus arrays, field generators, and EM storage installed and hardwired into the primary power bus.
3. **Active Systems Test (Days 45–55):** Pre-ignition diagnostics; synthetic field generator warm-up cycles; EM containment leak-check at $10^{-6}$ torr equivalent pressure rating.
4. **Final Seal & Armament (Days 55–60):** Hull sealing, hot-swap satellite stowage bay closure, and preparation for ignition sequence.

### Operational Timeline

Full fabrication cycle: **1,440 hours / 60 days**. Supply chain risk factors (corridor transit delays, EM harvest shortfalls) may extend to **70–85 days** under suboptimal conditions.

---

## Phase 3: Initialization Sequence & Aperture Ignition

### Objective

Bring the completed secondary AWS online through grid integration with the existing Eden-side stabilization infrastructure, spool-up of synthetic field generators to active manifold generation threshold, and ignition of an engineered aperture directed toward pre-mapped System B coordinates.

### Mechanics

**Grid Integration:**

Before any ignition attempt, the new AWS must integrate with the established Eden-side power and telemetry grid — the same infrastructure that supports the primary Sol–Eden node:

- **Power Bus Coupling:** The secondary AWS routes its active systems (focus arrays, field generators) through the legacy WS's redistributed power bus. This shared-grid approach reduces total EM draw for ignition by pooling storage banks from both nodes.
- **Telemetry Handshake:** The new station's navigation computer performs a full handshake with the primary node's telemetry feed, confirming aperture vector alignment and cross-node strain monitoring before ignition commit.
- **Stabilization Satellite Integration:** Three hot-swappable stabilization satellites previously reeled in during Phase 4 of the reconnection protocol are deployed to the Secondary Target Apex orbit band ahead of ignition — establishing a pre-ignition EM capture dome that reduces manifold shock at aperture open.

**Synthetic Field Generator Spool-Up:**

The synthetic field generators (SFGs) produce the active spacetime curvature required for aperture generation. Spool-up proceeds in three stages:

| Stage | Duration | Target SFG Output | Notes |
|-------|----------|-------------------|-------|
| **Field Pre-Charge** | 12–24 hours | 15% capacity | Capacitor banks charge; generator coils reach superconducting state |
| **Curvature Ramp** | 36–72 hours | 40% → 80% capacity | Active field topology maps to the pre-calculated System B transit vector; aperture geometry begins forming in simulation (not yet physical) |
| **Manifold Threshold Lock** | 6–12 hours | ~95% capacity (pre-ignition) | Field curvature matches the GMST-derived counterbalance profile from Phase 1; grid draws EM from shared storage banks to maintain threshold |

**Aperture Ignition Toward System B:**

At approximately $95\%$ SFG capacity, the ignition trigger is engaged:

- The synthetic field achieves critical curvature and collapses into a physical aperture on the far end — oriented toward System B's mapped coordinate vector (determined by prior deep-space cartography scans).
- The aperture opens to **high-strain single-node** status initially — identical to Phase 1 of the Sol–Eden reconnection, but now acting as the *secondary* node with the primary Sol–Eden link already providing grid stability.
- Pre-deployed stabilization satellites immediately begin EM capture at the new exit point, anchoring the manifold and bringing it from single-node toward dual-node balance within **1–3 days**.
- As EM density builds at the System B end (harvesting residual bloom or stabilizing a future NWH if one forms), the secondary aperture transitions to self-sustaining operation.

### Telemetry Establishment

| Data Channel | Purpose |
|-------------|---------|
| **Dual-Node Strain Monitor** | Tracks manifold strain between both AWS endpoints; ensures primary node load is not exceeded by secondary ignition event |
| **System B Vector Confirmation** | Validates that the new aperture's far-end coordinates align with mapped System B transit vector within $\pm 0.5^\circ$ tolerance |
| **EM Bloom Density at Exit** | Quantifies residual EM available at the System B end for stabilization satellite capture; determines self-sustainment timeline |
| **Grid Load Distribution** | Monitors power draw from shared EDEN-side bus; prevents over-draw during ignition peak |

### Operational Timeline

SFG spool-up: **2–4 days**. Ignition-to-stabilization: **1–3 days** (satellite EM capture). Aperture reaches stable dual-node status: **~5–7 days** from grid integration start. Total Phase 3 duration: **approximately 5–9 days**.

---

## Phase 4: Multi-Node Hub Routing & Act 2 Handover

### Objective

Finalize the secondary aperture's stabilization, integrate both nodes into a unified multi-node hub routing matrix for the AI Manager's macroeconomic simulation loop, and prepare the Eden-side infrastructure state for player handover at Act 2 start.

### Mechanics

**Aperture Stabilization & Asset Recovery:**

With the secondary node stabilized and both wormhole links operational:

- **Stabilization Satellite Roster:** The three satellites deployed to the Secondary Target Apex orbit are assessed for service life. Any requiring maintenance is swapped with the hot-swappable backup pods stored in the primary node's satellite stowage bay — maintaining a standing force of 6 stabilized apertures across both nodes (3 per node) for emergency redundancy.
- **EM Balance Equalization:** The shared power bus distributes EM between both nodes based on real-time manifold strain readings. If the secondary aperture experiences higher strain (due to lower anchor mass: $2.38 \times 10^{27}$ kg vs. $5.72 \times 10^{27}$ kg), the AI Manager allocates additional EM from primary node storage banks at a controlled exchange rate, preventing destabilization cascades.
- **Harvest Loop Continuation:** Residual EM bloom harvesting continues at both apex locations; surplus is stored in WS containment banks for network-wide emergency allocation.

**Multi-Node Hub Routing Configuration:**

The AI Manager's routing matrix now manages three transit vectors:

| Vector | Primary Node | Status | Capacity (Relative) |
|--------|-------------|--------|-------------------|
| **Sol ↔ Eden (Primary)** | Gas Giant 18 | Stable — Dual-Node, Full Corridor Class | 1.0x (baseline trunk line) |
| **Eden ↔ System B (Secondary)** | Gas Giant 17 | Stabilizing → Self-Sustaining | 0.6x–0.8x (gravity-dependent; matures as bloom stabilizes) |
| **Sol ↔ System B (Tertiary)** | *Emergent* | Contingency — via Eden relay only | Available through node hop at secondary gateway |

The hub routing matrix applies the following deterministic rules:

1. **Mass Displacement Aggregation:** Outgoing transit mass from Sol to System B is split across both vectors based on real-time $M_{\text{max}}$ headroom at each endpoint. The AI Manager dynamically adjusts cargo routing percentages to prevent either aperture from approaching collapse.
2. **Snap Event Resilience:** If the primary Sol–Eden link suffers a Snap, the secondary Eden–System B node remains operational and can serve as an emergency access vector for Eden-based operations — with limited cargo capacity until a new Sol-side AWS is constructed (minimum 60-day rebuild cycle).
3. **EM Commodity Arbitrage:** The AI Manager monitors EM density differentials across both nodes and directs harvester fleets to the higher-yield anchor, optimizing network-wide EM commodity value.

**Act 2 Handover State — Infrastructure Baseline:**

At Act 2 start, the AI Manager hands off the following state to the player for strategic decision-making:

| Handover Category | Delivered State |
|-------------------|-----------------|
| **Infrastructure Status** | Both AWS nodes online; secondary node in early self-sustainment phase (stabilization at ~70–90%); satellite force of 6 across both nodes |
| **EM Baselines** | Current storage bank capacity at each apex; projected bloom yield for next 30 days; emergency EM allocation thresholds per node |
| **Satellite Storage Status** | Service life remaining on deployed stabilization satellites; hot-swap pod inventory (capacity: 3 additional pods) |
| **Multi-Node Routing Matrix** | Active transit vectors, mass displacement headroom percentages, and AI Manager's automated cargo-splitting ratios |
| **Macro-Simulation Loop State** | Current network-wide EM economy model; commodity pricing projections; interstellar trade corridor utilization metrics |
| **Construction Capacity** | Remaining WS assembly capacity at Eden (one additional AWS can be initiated against any available planetary anchor in-system); current material stockpile levels at terrestrial nodes |

The player receives full control over:
- Prioritization of secondary node stabilization (accelerate via additional harvester deployment or defer to allow EM diversion to other network needs)
- Resource allocation for a third AWS (available planetary anchors in Eden system; construction against Gas Giant 16 or other identified bodies)
- Cargo routing strategy adjustments beyond the AI Manager's automated baseline
- Decision on whether to maintain Sol–Eden primary corridor focus or shift investment toward System B expansion

### Operational Timeline

Stabilization maturation and routing matrix finalization: **3–7 days** post-ignition. Act 2 handover executes immediately upon confirmation that both nodes carry stable cargo-class transit for a continuous period of **72 hours**.

---

## Appendix: Parameter Reference

| Symbol | Definition | Value / Notes |
|--------|-----------|---------------|
| $M_{\text{G18}}$ | Gas Giant 18 mass (Primary Anchor) | $5.72 \times 10^{27}$ kg |
| $M_{\text{G17}}$ | Gas Giant 17 mass (Secondary Anchor) | $2.38 \times 10^{27}$ kg |
| $k_g$ | GMST coupling constant | $8.61 \times 10^{-47}$ kg⁻¹·m² |
| $\Delta \theta_{\text{passive}}$ | Passive gravitational tension offset | Calculated per Phase 1; target $0.3x$–$0.5x$ EM cost reduction |
| $V_{\text{AWS}}$ | Standard AWS volume | 50,000 m³ |
| $M_{\text{dry}}$ | Standard AWS empty mass | 2,000,000 kg |
| $t_{\text{build}}$ | Standard AWS build cycle | 1,440 hours (60 days) |
| $S_{\text{sats}}$ | Stabilization satellite force per node | 3 deployed + 3 hot-swap reserve |
| $M_{\text{max}}$ | Mass Displacement Threshold (per aperture) | System-dependent; monitored dynamically by AI Manager |

---

## See Also

- [Post-Snap Reconnection Protocol](01_post_snap_reconnection_protocol.md) — Sol–Eden primary corridor establishment
- [AOL-732356: Eden Planetary Anchor Model] — Multi-node anchor designation and gas giant mapping
- [AI Manager Logic](../logistics/ai_manager_logic.md) — AI Manager simulation loop, macroeconomic modeling, and player handover protocols
- [Galactic Mass Standard Theory (GMST)] — Gravitational counterbalance derivation and passive stabilization models
