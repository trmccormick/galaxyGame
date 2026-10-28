# Station Construction & Retrofitting Options

## Pre-Player Era Engineering Specification — Infrastructure

**Document Version:** 2.0 (Ground Truth Aligned)
**Effective Phase:** Sol–Eden Reconnection Protocol — All Phases
**Authority:** AI Manager Directive / Pre-Player Era Logistics Pipeline
**Cross-References:** [pre_player_era_logistics_pipeline.md](../infrastructure/pre_player_era_logistics_pipeline.md), [SYNTHETIC_MEGA_STATIONS.md](../../architecture/stations/SYNTHETIC_MEGA_STATIONS.md), [CONVERTED_ROCK_STATIONS.md](../../architecture/stations/CONVERTED_ROCK_STATIONS.md), [SPECIALIZED_WH_STATIONS.md](../../architecture/stations/SPECIALIZED_WH_STATIONS.md), [asteroid_conversion_logic.md](../../architecture/asteroid_conversion_logic.md), [asteroid_conversion_physics.md](../../architecture/systems/asteroid_conversion_physics.md), [settlement_patterns.md](../../architecture/patterns/settlement_patterns.md)

---

## Critical Architectural Note

> **Construction ≠ Operation:** Building a station requires localized or imported mass, heavy equipment, and dedicated staging phases. Stations cannot be "spawned" or instantly toggled into existence. Every AWS (Artificial Wormhole Station) and WS (Wormhole Station) must follow the deterministic dependency chain defined below. Failure to respect this chain — particularly in moonless or deep-space environments where planetary anchoring is mandatory — produced the catastrophic Eden Snap Event: a structural collapse caused by installing a wormhole anchor without an asteroid-mass counterbalance, leading to tether snap and colony orphaning.

---

## 1. Pre-Player Era Sequential Expansion Tree (Dependency Chain)

All station construction must pass through four sequential phases before any AWS or WS can be physically realized. Each phase gates the next.

### Phase 1: Sol Core & Luna Industrial Bootstrapping

| Element | Purpose | Gate Requirement |
|---------|---------|-----------------|
| **Heavy Lift Transports (HLT)** | Initial lifts from Earth surface to LEO and Luna; all outbound crew, materials, and equipment | First HLT reaches Luna surface with ≥ 50 t payload |
| **Luna Surface Industry** | Mining and refining of structural silicates, metals, and PSR water ice ($\text{H}_2\text{O}$) | Lunar mine produces continuous stream of refined structural panels and ingots |
| **Venus Atmospheric Skimmers** | Harvest atmospheric $\text{CO}_2$ and $\text{N}_2$ for Sabatier synthesis | ≥ 2 skimmer variants operational, each yielding ≥ 120 t/day volatile capture |
| **Lunar Volatile Processing** | Sabatier reaction processing: $\text{CO}_2 + 4\text{H}_2 \rightarrow \text{CH}_4 + 2\text{H}_2\text{O}$, producing Methalox ($\text{CH}_4/\text{LOX}$) propellant and nitrogen/oxygen breathing gas | Sabatier plant produces ≥ 80 t/day Methalox; first HLT fleet refuel completed |
| **LEO / Earth-L1 Depot Network** | Orbital fuel depots for outbound HLT fleets (eliminates Earth-ascent fuel overhead) | L1 depot operational with ≥ 20,000 t cryo-storage capacity |

**Phase 1 Prerequisites Summary:** The Venus-Luna Sabatier feedback loop is a **non-negotiable gate**. Without Methalox propellant synthesis from Luna-derived hydrogen (PSR ice) and Venusian $\text{CO}_2$, no HLT can reach Mars, the Belt, or any exoplanet system. The phase completes only when the first outbound HLT fleet, fueled at L1 depots, is verified capable of trans-Mars injection.

### Phase 2: Earth-L1 Shipyards & Fleet Scaling

| Element | Purpose | Gate Requirement |
|---------|---------|-----------------|
| **Earth-L1 Orbital Depot** | First facility constructed at L1; resource processing, storage, transfer operations. High automation (~98%), minimal crew (1 habitat module). Blueprint: `orbital_depot_mk1_bp` | Operational with 12 cryogenic tank modules and 5 volatiles processing units online |
| **Earth-L1 Planetary Staging Hub** | Heavy manufacturing and spacecraft construction mega-station. High crew capacity, advanced manufacturing. Blueprint: `planetary_staging_hub_mk1_bp` | Shipyard operational; first capital craft (Heavy Tug) assembled in-orbit |
| **Capital Craft Manufacturing** | L1 shipyards produce specialized Heavy Tugs and deep-space Cyclers (up to 8.5M kg mega-station mass class) | ≥ 3 Heavy Tugs verified on standby at L1 with tug propulsion economy confirmed |

**Key Principle:** Two distinct facilities with mandatory sequencing — the Orbital Depot must be operational *before* construction begins on the Planetary Staging Hub, because all shipyard materials arrive via depot logistics. Stations built at this phase (L1 orbital depots) use Luna-sourced raw materials assembled in pure orbital vacuum; no planetary anchoring is required.

### Phase 3: Mars Moon Conversion

| Element | Purpose | Gate Requirement |
|---------|---------|-----------------|
| **Heavy Tug Deployment to Mars System** | Tugs manufactured at L1 deploy via cycler routes to Mars orbit | ≥ 2 Heavy Tugs established in Martian Lagrange operations |
| **Phobos/Deimos Capture & Hollowing** | Identify, capture, and progressively hollow out Mars' natural moons using Rule B conversion mechanics (see Section 4) | At least one moon achieves structural stabilization with internal void ≥ 40% and I-Beam reinforcement complete |
| **Moon-to-Station Integration** | Converted Phobos/Deimos serves as orbital anchor, depot, and potential WS/AWS mount point | First converted rock station pressurized and operational with ≥ 25 crew capacity |

**Planetary Anchored Construction Pattern:** Mars uses the "Mars Pattern" — identifying local moons (Phobos/Deimos) and converting them into stations/depots. This is the preferred approach over launching station components from Earth's gravity well ("Earth Pattern"), because it leverages existing planetary mass for radiation shielding and structural stability, minimizing imported materials by >70%.

### Phase 4: Belt Expansion & Asteroid Repositioning (Moonless / Deep-Space)

| Element | Purpose | Gate Requirement |
|---------|---------|-----------------|
| **Belt Capture Operations** | Heavy tugs move into Asteroid Belt to identify and capture suitable Phobos-class asteroids ($1.0$–$2.0 \times 10^{16}$ kg) | ≥ 3 qualified asteroids identified with cohesion density ≥ 1.5 g/cm³ and volatile content < 20% |
| **Asteroid Repositioning to Moonless Bodies** | Captured asteroids relocated into stable orbit around moonless planets (Venus, Eden, System B bodies) or Lagrange points as structural anchors | First asteroid anchored at target L1 point; slag propulsion economy confirmed (>90% propellant reduction) |
| **Asteroid-to-Depot Conversion** | Hollowed asteroids converted to functional depots (100,000 m³ storage, 500 t/day processing, 50 MW fusion power per unit) | ≥ 3 converted depots operational; cycler network lock achieved |
| **Cycler Network Lock** | Regular cycler transit routes fully operational across Sol–Eden–System B | Pre-player infrastructure network complete; player handoff at Phase 4 end-state |

**Moonless / Deep-Space Pattern:** Bodies without natural moons (Venus, Eden, System B analogs) *must* use captured asteroids as structural anchors. This is the only path to permanent AWS/WS placement — pure orbital stations cannot sustain wormhole anchor loads without an asteroid-mass counterbalance. Placing a WS/AWS at a Lagrange point or in planetary orbit without such counterbalance is the **direct root cause of the Eden Snap Event**.

---

## 2. Pure Orbital Builds vs. Planetary-Anchored Conversions

This section defines two mutually exclusive construction pathways based on the deployment environment.

### 2A. Pure Orbital Build (L1/LEO Pattern)

| Attribute | Specification |
|-----------|---------------|
| **Applicable to** | Earth-Moon L1 depots, LEO stations, any gravity-well-adjacent orbital installation |
| **Mass source** | Luna-sourced structural silicates, metals, and volatiles; imported from surface via HLT |
| **Assembly method** | In-orbit assembly of manufactured components at L1 shipyard (blueprint-driven: `orbital_depot_mk1_bp` / `planetary_staging_hub_mk1_bp`) |
| **Structural shell** | Imported TiNT composite panels or equivalent, fully fabricated at Luna ISRU facility before launch |
| **Radiation shielding** | Active shielding + imported bulk shielding material; no natural mass advantage |
| **Construction timeline** | Phase-gated: Depot first (Phase 2), Staging Hub second (Phase 2). No independent parallelization. |
| **Snap-event resilience** | Not applicable at Earth-L1 — stable planetary counterbalance (Earth) provides inherent L1 stability. Rock stations at L3 require major planetary mass; true stability only achievable with Jupiter-class counterbalance. |

### 2B. Planetary-Anchored Conversion (Moon Pattern / Asteroid Pattern)

| Attribute | Specification |
|-----------|---------------|
| **Applicable to** | Mars Phobos/Deimos conversion, Venus-anchored AWS, Eden/Super-Mars anchor asteroids, System B station nodes |
| **Mass source** | *Local body* — the asteroid or moon being converted. Import cost reduced by >70% vs. Earth Pattern. |
| **Assembly method** | Tug-led hollowing + I-Beam reinforcement using Rule B conversion mechanics (Section 4) |
| **Structural shell** | Natural mass of the converted body, processed at 30% mass-to-hull efficiency. Remaining 70% vented as slag or bulk shielding. |
| **Radiation shielding** | Superior natural mass provides inherent protection; no active shielding required for habitable volume. |
| **Construction timeline** | Variable: governed by tug thrust capability, asteroid cohesion, and hollowing depth. See Section 4 dynamic logistics. |
| **Snap-event resilience** | *Dependent on anchor mass integrity.* Properly converted bodies with ≥ 10$^{15}$ kg anchor mass provide structural counterbalance preventing tether snap. Inadequate anchoring caused the Eden Snap Event. |

### 2C. Decision Matrix: Which Pattern Applies?

| Deployment Target | Natural Moons Available? | Required Pattern | Reason |
|-------------------|-------------------------|-----------------|--------|
| Earth-Moon L1 / LEO | Yes (Moon) | Pure Orbital (2A) | Luna materials supply sufficient; L1 inherently stable with Earth counterbalance |
| Mars orbit | Yes (Phobos, Deimos) | Planetary-Anchored (2B) — Mars Pattern | Local moons eliminate import burden; established template |
| Venus orbit | No | Planetary-Anchored (2B) — Asteroid Pattern | No natural moons; captured Belt asteroid mandatory as anchor |
| Eden Gas Giant 17/18 orbit | No | Planetary-Anchored (2B) — Asteroid Pattern | Moonless system; captured/Super-Mars HLT asteroid mandatory as anchor |
| System B exoplanet orbit | No | Planetary-Anchored (2B) — Super-Mars Pattern | No moons; settlement_patterns.md Phobos relocation pattern with L1 positioning |

---

## 3. Infrastructure Pathways: WS vs. AWS Construction

### 3A. WS (Natural Wormhole Station) — Deployed at Natural Wormhole Exits

WS stations are deployed at naturally occurring wormhole exits. They serve as temporary EM harvesting rigs and initial infrastructure nodes before potential permanent AWS upgrade.

| Attribute | Specification |
|-----------|---------------|
| **Deployment trigger** | Natural wormhole exit detected during system survey |
| **Construction type** | Deployed via Phase 3 or Phase 4 conversion pipeline depending on anchor availability (Moon Pattern vs. Asteroid Pattern) |
| **Configuration** | Dumb depot mode: minimal automation, storage/logistics only, low maintenance |
| **EM capability** | Basic EM harvesting rig; temporary resource extraction until AWS upgrade eligibility confirmed |
| **Upgrade path** | Not always eligible for permanent AWS upgrade — depends on `wh-expansion.md` Scout/Harvest logic (probe assessment of anchor mass, tether stability, and ROI) |
| **Snap-event note** | WS at natural exits are inherently unstable without counterbalance. If no asteroid/moon anchor is mounted, the station risks Exit-side Snapping (orphaned infrastructure). |

### 3B. AWS (Artificial Wormhole Station) — Permanent High-Mass Anchor

AWS stations are permanent, high-mass installations built for long-term wormhole stabilization and network integration. They require confirmed high System_ROI and resource yield before construction authorization.

| Attribute | Specification |
|-----------|---------------|
| **Deployment trigger** | Confirmed high System_ROI; anchor mass > 5.0 × 10¹⁶ kg counterbalance present or installable |
| **Construction type** | Planetary-Anchored conversion via Phase 3 (Mars moons) or Phase 4 (Belt asteroids), *never* Pure Orbital (AWS requires planetary-mass anchoring for stability) |
| **Configuration** | EM harvesting rig with knowledge gate capability; supports data/logistics hub operations and interstellar transit routing |
| **Mass class** | ≥ 8.5M kg equivalent (converted rock station internal mass); supports full crew complement and power grid |
| **Knowledge Gate role** | Pre-Snap: data/logistics hub connecting consortium systems. Post-Snap: critical reconnection node for orphaned systems, enabling tech/experience transfer and colony re-establishment. |
| **Snap-event note** | AWS with proper anchor counterbalance resists tether snap. AWS without verified counterbalance = structural liability equal to WS risk. |

---

## 4. Planetary Conversion Pipeline Mechanics

### 4.1 Rule B Hollowing (Conversion Process)

All planetary-anchored conversions follow the standardized "Rule B" hollowing mechanics, applicable whether converting Mars moons or Belt asteroids.

| Parameter | Value / Rule |
|-----------|-------------|
| **Mass-to-Hull Efficiency** | 30%. For every 1,000 kg of body mass processed, 300 kg becomes usable internal hull/deck plating. |
| **Resource Recovery (70%)** | Vented as slag or processed into bulk shielding (radiation protection) and station maneuvering propellant. |
| **Volume Scaling** | Internal volume calculated from radius of hollowed sphere/cylinder, minus 5 m structural "crust" for micrometeoroid protection. |
| **Crust Thickness** | Fixed at 5 m; cannot be reduced regardless of construction urgency. |

### 4.2 Conversion Pipeline Stages (Applicable to All Anchor Bodies)

The conversion pipeline applies uniformly to Phobos/Deimos hollowing and Belt asteroid relocation, with tug-class scaling for distance:

| Stage | Duration | Description | Prerequisite Gate |
|-------|----------|-------------|-------------------|
| **1. Anchor** | Variable (depends on discovery phase) | Install `harvester_rig` to begin surface material extraction; deploy survey probes if not already done | Qualification checks pass (Section 4.3) |
| **2. Hollow** | Phase-gated (see Section 5 dynamic logistics) | Execute `HollowingJob` using thermal drills and plasma cutters; process mass at Rule B 30% efficiency | Harvester rig operational with ≥ 50 t/day extraction rate |
| **3. Pressurize** | Phase-gated | Install `sealant_panels` and `life_support_units`; test hull integrity across all seams | Hollowing produces void > 40%; I-Beam bracing complete if required |
| **4. Final Fit** | Phase-gated | Convert hollowed void into functional `Planetary Staging Hub` or `Orbital Depot` by installing standard internal modules (power, hab, processing) | Pressurization verified at > 95% target atmosphere retention rate |

### 4.3 Asteroid Qualification — The Disqualifiers

Before any conversion pipeline begins, the AI Manager must execute a Discovery & Qualification phase. An asteroid or moon candidate is **disqualified** if it meets *any* of these criteria:

#### Disqualifier 1: Cohesion Check (The "Rubble Pile")
- **Criteria:** Density < 1.5 g/cm³
- **Physics:** Loosely bound aggregates respond to tug thrust by structural dissipation, not movement.
- **Result:** Cannot mount I-Beam frames; conversion pipeline fails at Stage 1.

#### Disqualifier 2: Thermal Check (The "Ice" Rule)
- **Criteria:** Volatile/ice composition > 20%
- **Physics:** High-output station equipment (quantum arrays, power cores) generates heat that sublimates the ice core, causing uncontrolled outgassing and structural destabilization.
- **Result:** Requires additional "Thermal Shielding" sub-phase consuming extra panels; disqualified if heat output is rated EXTREME.

#### Disqualifier 3: Mass-to-Void Ratio (The "Hollow" Rule)
- **Criteria:** `is_hollow: true` — internal void > 40% at time of initial survey
- **Physics:** Pre-existing cavities risk structural buckling/collapse under tug thrust loads.
- **Result:** Mandatory Internal Bracing phase (consuming I-Beams) must complete before Towing Phase begins, adding to timeline but does not disqualify the candidate.

### 4.4 Dynamic Towing Logistics

Tug operations for asteroid/moon relocation use a dynamic, property-based timeline rather than fixed placeholders. The actual transit duration depends on material type and tug count:

| Material Class | Stress Tolerance Multiplier | Max Thrust Allowed | Recommended Transit Profile |
|----------------|----------------------------|--------------------|-----------------------------|
| **Metallic (M-Type)** | 1.0 (High) | Full tug thrust; aggressive acceleration possible | Fast transit; shortest timeline |
| **Stony (S-Type)** | 0.7 (Moderate) | Reduced thrust; structural limits apply | Moderate transit time; requires staged acceleration |
| **Carbonaceous (C-Type)** | 0.4 (Low) | Low thrust only; fragile structure | Slow transit; longest timeline; minimum tug count needed |

**Tug Multiplier:** Additional tug units deployed to the relocation operation allow better force distribution, increasing the safe acceleration cap: $a = \text{Thrust} / \text{Mass}$, where effective thrust scales with tug count. Each additional tug adds linearly to the safe acceleration envelope.

### 4.5 Slag Propulsion Economy

A key economic and operational advantage of the conversion pipeline: hollowing byproduct (slag) serves as reaction mass for the station's own maneuvering.

| Metric | Value |
|--------|-------|
| **Propellant Source** | Asteroid/moon hollowing slag (70% of excavated mass, per Rule B) |
| **Propellant Mass Reduction** | 90% vs. imported propellant |
| **Economic Impact** | Reduces relocation costs by 90% compared to importing fuel for tug operations |
| **Implementation** | ResourcePlanner auto-prioritizes slag economy for all L1 and anchor operations |

### 4.6 I-Beam Reinforcement

All converted rock stations require internal structural reinforcement:

- **Method:** ISRU-printed or in-situ assembled I-beam framework spanning the hollowed void
- **Purpose:** Provides support for habitats, cryogenic tanks, power systems, and equipment arrays against gravitational and thrust loads
- **Material source:** Processed from local body mass where possible; supplemental import only if Rule B recovery insufficient
- **Placement:** Grid pattern aligned with anticipated load vectors (tug thrust axis, habitat weight distribution, tank center-of-mass)

---

## 5. Construction Timelines & Dynamic Logistics

### 5.1 Super-Mars / Settlement Patterns Timeline (Per Converted Anchor Body)

Applicable to Belt asteroid-to-depot conversion for moonless planets:

| Phase | Duration | Description |
|-------|----------|-------------|
| **Phase 1: Survey & Selection** | 24 hours | Deploy system survey probes; identify optimal Phobos-class asteroids (1.0–2.0 × 10¹⁶ kg each); calculate L1 trajectories |
| **Phase 2: Tug Deployment** | 12 hours | Launch Asteroid Relocation Tugs; establish hollowing operations at anchor point; begin slag collection for propulsion |
| **Phase 3: L1 Positioning** | 168 hours | Execute precision orbital transfers to planetary L1 Lagrange point; apply slag propulsion for final positioning; maintain 90% fuel efficiency |
| **Phase 4: Depot Conversion** | 240 hours | Convert hollowed asteroid to functional depot; install nuclear fusion power systems (50 MW); establish crew quarters, processing facilities, and life support |
| **Total (baseline)** | **444 hours** (~18.5 days continuous) | Variable by tug count, material class, and distance from Belt source |

### 5.2 Mars Moon Conversion Timeline (Per Converted Body)

Applicable to Phobos/Deimos hollowing (shorter haul from L1; different starting mass):

| Phase | Duration | Description |
|-------|----------|-------------|
| **Phase 1: Survey & Qualification** | 48 hours | Deploy probes to Mars moons; run cohesion, thermal, and hollow-rule disqualifier checks |
| **Phase 2: Tug Deployment & Capture** | Variable (dependent on tug count × body mass) | Heavy tugs capture and establish harvester rig operations at target moon |
| **Phase 3: Hollowing & I-Beam Reinforcement** | Phase-gated (depends on moon size; Rule B processing rate) | Thermal drills + plasma cutters at 30% mass-to-hull efficiency |
| **Phase 4: Pressurization & Final Fit** | Phase-gated | Sealant panels, life support systems, habitat modules, and power grid installation |

### 5.3 Construction Timeline Summary by Pattern

| Pattern | Anchor Source | Timeline Type | Key Variable | Snap-Event Risk if Skipped |
|---------|---------------|---------------|-------------|---------------------------|
| **Earth Pattern (imported)** | Luna→LEO/L1 materials via HLT | Phase-gated fixed duration | Launch cadence from Earth surface | Low (L1 inherently stable) |
| **Mars Pattern (moons)** | Phobos/Deimos local conversion | Phase-gated + tug-variable | Moon mass, tug count, cohesion type | Medium (moon conversion defects) |
| **Asteroid Pattern (Belt→Venus)** | Belt asteroid → Venus L1 | Phase-gated + dynamic towing | Tug stress tolerance (M/S/C-Type), distance from Belt | High (no anchor = tether snap) |
| **Super-Mars Pattern (Belt→Eden)** | Belt asteroid → Eden L1 | Phase-gated + dynamic towing | Same as Asteroid Pattern + interstellar distance | Critical (Eden Snap Event root cause: no counterbalance) |

---

## 6. Logistical Deployment Rules

### 6.1 Site Constraints by Construction Type

#### Pure Orbital (L1/LEO Deployments)
- **Hill Sphere:** Not applicable — L1 is inherently defined by Earth-Moon gravitational equilibrium
- **Solar Aspect Angle:** Solar arrays must maintain incidence < 30° from normal for ≥ 85% of orbit
- **Communication LoS:** Unobstructed radio line-of-sight to parent body and adjacent network nodes required; blocked sites need relay satellite constellation

#### Planetary-Anchored (Moon/Asteroid Conversions)
- **Anchor Mass Requirement:** Converted body must provide ≥ $10^{15}$ kg structural counterbalance for WS stability, ≥ $5.0 \times 10^{16}$ kg for AWS station stability
- **Lagrange Point Preference:** L1/L4/L5 Lagrange points within the host planet's Hill sphere are preferred for network integration and stability. Trojan-L3 moves possible for rock stations but true L3 stability requires a major planetary counterbalance (e.g., Jupiter)
- **Gravitational Gradient Tolerance:** The deployment orbit must not exceed the converted body's I-Beam structural capacity under tidal loads; S-Type and C-Type bodies require additional margin
- **Solar Aspect Angle:** Same as orbital — ≥ 85% of orbital period at < 30° incidence for photonic efficiency

### 6.2 Tug Assembly Workflow

All planetary-anchored construction is tug-led, not drone-swarmed:

1. **Tug Deployment:** Asteroid Relocation Tugs (from L1 shipyard) deploy to the anchor body with harvester rigs, thermal drills, and plasma cutters
2. **Anchor Installation:** Harvester rig mounts to body surface; extraction begins at ≥ 50 t/day rate
3. **Hollowing Execution:** Continuous `HollowingJob` cycle — material removal at Rule B efficiency, slag collection for propulsion economy
4. **I-Beam Reinforcement:** Concurrent with hollowing when void approaches 20% threshold (pre-buckling measure)
5. **L1 Positioning:** Tugs use combined thrust + slag propulsion to transfer converted body to target orbital point
6. **Final Fit:** Internal module installation — power systems, habitat modules, processing facilities, life support

### 6.3 Power-Grid Integration Constraints

Each station node integrates with the local generation and storage grid:

| Constraint | Value / Rule |
|------------|-------------|
| **Conversion Phase Draw** | Variable: thermal drills + plasma cutters at ~2 MW total during active hollowing |
| **Post-Conversion Standby** | Depends on station class — dumb depot (~500 kW), EM harvesting rig (~3.2 GW fusion tap equivalent) |
| **Power Generation** | 50 MW nuclear fusion per converted depot unit; scalable with additional fusion reactors |
| **Cryo-Storage** | 12 cryogenic tank modules (orbital depot class); zero-boil-off systems for Methalox propellant storage |

---

## 7. Integration with Multi-Node Routing — Snap-Event Resilience

### 7.1 Root Cause: The Eden Snap Event

The Eden Snap Event was a structural collapse caused by placing a WS/AWS anchor without adequate planetary-mass counterbalance in a moonless system. Without an asteroid or moon conversion providing the required mass, tether loads exceeded structural limits during transit events, resulting in catastrophic snap and colony orphaning.

**Design Rule:** All AWS/WS stations in Sol, Eden, and System B *must* use verified anchor counterbalances — either natural moons (Mars Pattern) or converted Belt asteroids (Asteroid/Super-Mars Pattern). Pure orbital deployment of wormhole infrastructure is only permissible at Earth-L1 where planetary gravity provides inherent stability.

### 7.2 Network-Level Routing Impact by Station Class

| Station Type | Minimum Anchor Mass | Snap-Event Resistance | Recovery from Perturbation |
|--------------|-------------------|----------------------|----------------------------|
| **AWS (properly anchored)** | ≥ $5.0 \times 10^{16}$ kg | High — stable counterbalance absorbs tether loads | Automatic realignment; < 180 seconds to full recovery |
| **WS (no anchor / under-massed)** | Insufficient — disqualifying condition | Critical — Exit-side snapping risk during any transit event | Manual inspection required; potential total infrastructure loss |
| **Dumb Depot** | ≥ $1.0 \times 10^{15}$ kg | Moderate — minimal EM loads, stable if anchor present | Autonomous stabilization; ≤ 90 seconds |
| **EM Harvesting Rig** | ≥ $5.0 \times 10^{16}$ kg (same as AWS) | Same as AWS — dependent on anchor integrity | Automatic + manual inspection of weld joints and structural mounts |

### 7.3 Routing Optimization Guidelines for the Player

At Act 2 handoff (post-Pre-Player Era completion), the player inherits a fully-mapped but not-yet-activated Sol–Eden–System B routing graph. Use these rules when managing station infrastructure:

1. **AWS at high-throughput nodes only** — Stations on routes carrying > 500 t monthly throughput must be AWS-class with verified anchor counterbalance. WS-class or unanchored stations on these routes risk cascading outage events.

2. **Never skip anchor verification before AWs placement** — If no natural moons exist at the deployment target, Phase 4 Belt asteroid relocation is mandatory. Proceeding without it reproduces the Eden Snap Event.

3. **Cluster depots near generation-rich sites** — Converted rock stations with EM harvesting capability should be positioned adjacent to active power assets (fusion taps, solar arrays) to minimize grid integration losses.

4. **Monitor converted body integrity continuously** — During conversion and post-deployment, track cohesion, thermal, and hollow-rule status of all anchor bodies. Degradation in any metric below qualification thresholds requires immediate tug-assisted stabilization or anchor replacement.

5. **Pre-Depot EM tax baseline** — Pre-depot transit routes cost 752.5 EM/hour (SOL-AC-01). Post-depot routing achieves ~451.5 EM/hour (40% Sabatier reduction + ballast stabilization). All anchor depots directly reduce network-wide routing costs.

---

## Appendix A: Acronyms & Nomenclature

| Term | Definition |
|------|------------|
| **AWS** | Artificial Wormhole Station — permanent, high-mass station with verified anchor counterbalance |
| **WS** | Wormhole Station — deployed at natural wormhole exits; often temporary EM harvesting rig |
| **HLT** | Heavy Lift Transport — starship-type craft for Earth/Luna/Venus interplanetary logistics |
| **Methalox** | CH₄/LOX propellant produced via Venus-Luna Sabatier reaction |
| **Rule B** | Hollowing conversion standard: 30% mass-to-hull efficiency, 70% slag recovery |
| **I-Beam** | ISRU-printed internal structural reinforcement framework for converted rock stations |
| **Slag Propulsion Economy** | Using hollowing byproduct as reaction mass; 90% propellant reduction vs. imported fuel |
| **Disqualifier Cohesion** | Density < 1.5 g/cm³ — rubble pile bodies cannot be converted |
| **Disqualifier Thermal** | Volatile/ice > 20% — sublimation risk under station heat loads |
| **Disqualifier Hollow** | Pre-existing internal void > 40% — mandatory I-Beam bracing required before towing |
| **Lagrange Point** | Gravitational equilibrium point; L1 preferred for depots, L3 requires major planetary counterbalance |
| **Sabatier Reaction** | CO₂ + 4H₂ → CH₄ + 2H₂O — Venusian CO₂ + lunar H₂ produces Methalox propellant |

---

*End of Specification.*
*Document status: GROUND TRUTH ALIGNED — v2.0. Replaces v1.0 (Drone Swarm / GSU architecture). Supersedes all prior construction documentation with dependency-chain, Sabatier-gate, Rule B hollowing, and anchor-verification mechanics.*

