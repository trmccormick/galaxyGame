# ISRU Fabrication Chain (3D-Printed + CNT Fabricators)
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-03  
> *Audit Summary:* Expanded specification — added mass-balance staging, power/thermal profiles per tier, maintenance degradation cycles, and failure mode taxonomy. Code implementation pending or unverified as of audit baseline.

> **Wiki section:** Technical · **Status:** target design intent — canonical ISRU production mechanics, feedstock qualification, fabricator upgrade trees, mass-balance equations, power/thermal profiles, automated maintenance cycles, and system failure modes; no runtime enforcement currently exists.

> **Cross-link:** For the Venus–Mars ballistic corridor that uses CNT shell containment pods, see **[Venus–Mars Ballistic Corridor (Brute-Force Loop)](venus_mars_ballistic_corridor.md)**.

> **Cross-link:** For atmospheric harvesting of CO₂ and N₂ from Venus/Titan, see **[Atmospheric Harvesting](../infrastructure/atmospheric_harvesting.md)**.

> **Cross-link:** For settlement infrastructure, structure types, and orbital logistics integration, see **[Settlement Infrastructure](../infrastructure/settlement_infrastructure.md)**.

> **Cross-link:** For Terraforming Economic Integration and the Sol Tri-System Volatile Loop, see **[Terraforming Economic Integration](../logistics/terraforming_economic_integration.md)**.

---

## Scope

This document defines the In-Situ Resource Utilization (ISRU) production chain that converts raw planetary resources into manufactured components. Two parallel fabrication trees operate: **3D-printed fabricators** for structural components (panels, I-beams) and **CNT fabricators** for advanced composites and infrastructure materials. Both follow a Mk1 → Mk2 → Mk3 upgrade path with strict component dependencies and blueprint canonicalization.

**Authority:** This document promulgates requirements from `docs/architecture/isru/README.md`, `docs/architecture/isru/cnt_production.md`, and `docs/architecture/logistics/SYSTEM_INDUSTRIAL_CHAINS.md`. Mismatches between documentation and implementation are logged as architectural gaps for human review.

---

## 1. Regolith Feedstock Qualification

### Composition Analysis Requirements

Raw surface regolith **must be analyzed for composition** before it can be accepted by any fabricator blueprint. Key compositional parameters include:

| Parameter | Significance |
|-----------|-------------|
| **SiO₂ (Silicon Dioxide)** | Primary structural component; determines printability and binder compatibility |
| **FeO (Iron Oxide)** | Affects material strength and thermal properties of printed components |
| **Other trace elements** | May require additive blending to meet blueprint specifications |

### Additive Blending

When regolith composition does not meet blueprint thresholds:
- **Additives are blended** into the feedstock stream to compensate for compositional deficits
- Additives target specific parameters: printability, structural strength, thermal resistance
- The exact additive formulas and blending ratios are defined in each blueprint's `required_materials`

### Blueprint Acceptance Gate

```
Raw regolith harvested → Composition analysis → Qualified vs. Unqualified feedstock?
    → Qualified: accepted by fabricator blueprint
    → Unqualified: additives blended → re-analyzed → loop until qualified
```

**Only qualified feedstock is accepted by canonical blueprints.** Fabricators reject unqualified regolith without warning or partial acceptance — this is a hard gate, not a soft constraint.

---

## 2. Mass-Balance Stages (Regolith to Structural Components)

### Stage 1 — Bulk Regolith Extraction

Raw regolith is excavated by surface extractors (mechanical scoops or vacuum harvesters depending on surface gravity and dust cohesivity). The extraction system delivers bulk feedstock to the ISRU processing hopper.

| Parameter | Design-Baseline Value | Grounding |
|-----------|-----------------------|-----------|
| Extraction yield (Mk1 extractor) | 500 kg/hr per unit | **[PROPOSED / PLACEHOLDER]** — no direct architecture spec backing; requires confirmation from operational data JSON |
| Extraction yield (Mk2 extractor) | 800 kg/hr per unit | **[PROPOSED / PLACEHOLDER]** — no direct architecture spec backing; requires confirmation from operational data JSON |
| Extraction yield (Mk3 extractor) | 1,200 kg/hr per unit | **[PROPOSED / PLACEHOLDER]** — no direct architecture spec backing; requires confirmation from operational data JSON |
| Bulk density of regolith feedstock | ~1,600 kg/m³ | **[PROPOSED / PLACEHOLDER]** — derived from Mars regolith literature estimates (3.0–3.5 g/cm³ bulk); not from game constants |
| Moisture content (raw, pre-sieve) | 0–5% w/w (variable by site) | **[PROPOSED / PLACEHOLDER]** — no direct architecture spec backing |

### Stage 2 — Sieving and Pre-Processing

Extracted regolith passes through a multi-stage sieving system:

| Substage | Function | Output Specification |
|----------|----------|---------------------|
| Primary sieve | Remove macro-debris (>50 mm) | Oversize diverted to waste stream |
| Secondary sieve | Classify grain-size distribution | Target fraction: 100 µm – 5 mm (70% of feed by mass) |
| Magnetic separation | Extract free iron and ferromagnetic minerals | Iron recovered as byproduct; ~2–4% of feed mass |
| Vacuum drying | Remove adsorbed moisture | Residual moisture <0.1% w/w |

**Mass balance at Stage 2:**

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures. They have not been validated against `operational_data/units/processing/sieve_unit_mk*_data.json` files. See the audit summary above for code alignment status.

```
Input:  500 kg/hr raw regolith (Mk1 baseline)
Output:
  - Processable fines:   350 kg/hr (70%)
  - Magnetic iron:        12 kg/hr  (~2.4% Fe recovery)
  - Macro-debris waste:  100 kg/hr (20%)
  - Vacuum loss/dust:     38 kg/hr  (~7.6% handling loss)
```

### Stage 3 — Composition Analysis and Additive Blending

The processable fines stream enters a composition analyzer (spectroscopic XRF unit). The analyzer outputs elemental weight fractions for Si, Fe, Mg, Al, Ca, Ti, and K. The blueprint matcher compares these against the required material profile.

**Additive blending equations:**
```
m_additive_i = m_feed × (C_target_i - C_actual_i) / C_additive_i

Where:
  m_additive_i  = mass of additive species i to inject
  m_feed        = mass flow rate of processable fines
  C_target_i    = target weight fraction for species i (from blueprint)
  C_actual_i    = measured weight fraction (from analyzer)
  C_additive_i  = weight fraction of species i in the additive source
```

**Typical additive inventory per fabrication tier:**

> **Note:** Delivery rates below are **[PROPOSED / PLACEHOLDER]** estimates with no direct architecture spec backing. Validate against blueprint `required_materials` tables before treating as authoritative.

| Additive | Source | Purpose | Delivery Rate (per Mk1 fabricator) |
|----------|--------|---------|-------------------------------------|
| Calcium sulfate (CaSO₄) | Deposited on Mars/Earth | Binder agent for regolith sintering | 8 kg/hr |
| Sodium silicate solution | Imported or lunar polar extraction | Glass-phase promoter | 4 kg/hr |
| Nickel powder | Asteroid belt import | Enhance FeO compatibility | 1.5 kg/hr |

### Stage 4 — Feedstock Storage and Dispatch

Processed and blended feedstock is stored in sealed hopper silos before dispatch to fabricator units:

| Parameter | Value |
|-----------|-------|
| Feedstock storage capacity per unit | 2,000 kg |
| Silo venting requirements | Argon blanket atmosphere (O₂ <10 ppm) to prevent oxidation of reactive additives |
| Dispatch rate to fabricator | Continuous, regulated by fabricator draw |

### Stage 5 — Structural Component Fabrication

The qualified feedstock enters the 3D-printed fabricator. For Mk1:

**Mass balance at fabrication (Mk1):**

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures. They have not been validated against `operational_data/units/production/fabricators/printer_fabricator_unit_mk*_data.json` files. See the audit summary above for code alignment status.

```
Feedstock input:    200 kg/hr qualified regolith + additives
Print output:
  - Structural panels:   160 kg/hr
  - I-beams:              35 kg/hr
  - Binders/loss:          4 kg/hr (vaporized binder residue)
  - Dust/unsintered:       1 kg/hr (recycled back to hopper)
```

---

## 3. Power Draw Profiles and Thermal Energy Rejection

### 3D-Printed Fabricator — Per-Tier Power and Thermal Profile

Each fabrication tier has a cumulative power draw that includes both the fabricator's core operation and its auxiliary systems (vacuum pumps, analyzers, feedstock conveyors).

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from thermal engineering estimates. They have not been validated against `operational_data/units/production/fabricators/*.json` files. See the audit summary above for code alignment status.

| Tier | Core Load (kW) | Auxiliary Systems (kW) | Total Draw (kW) | Thermal Rejection (kW) | Duty Cycle |
|------|----------------|------------------------|-----------------|------------------------|------------|
| Mk1 | 250 | 80 | 330 | 264 | Continuous |
| Mk2 | 400 | 140 | 540 | 432 | Continuous |
| Mk3 | 650 | 230 | 880 | 704 | Continuous (pulsed at 90% peak) |

**Thermal rejection methodology:** All power not converted to mechanical or electromagnetic work within the fabricator becomes waste heat. The standard thermal rejection ratio is **80%** of total draw, handled by radiator panels or loop-heat-pipe networks vented to space. For planet-bound units, heat may be dissipated into the local regolith via thermosyphon arrays.

### CNT Fabricator — Per-Tier Power and Thermal Profile

CNT fabricators consume more power due to plasma arc CO₂ splitting and catalyst activation chemistry.

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from thermal engineering estimates for plasma-based synthesis systems. They have not been validated against `operational_data/units/production/fabricators/cnt_fabricator_unit_mk*_data.json` files.

| Tier | Core Load (kW) | Catalyst Prep (kW) | Auxiliary Systems (kW) | Total Draw (kW) | Thermal Rejection (kW) |
|------|----------------|--------------------|------------------------|-----------------|------------------------|
| Mk1 | 500 | 200 | 50 | 750 | 600 |
| Mk2 | 700 | 300 | 80 | 1,080 | 864 |
| Mk3 | 950 | 420 | 120 | 1,490 | 1,192 |

**Catalyst prep power note:** The catalyst preparation load scales with tier because higher tiers require finer particle dispersion and tighter composition control for the carbon deposition catalyst.

### Combined Base Power Budget (Single Settlement, One of Each Fabricator per Tier)

| System | Total Power Draw |
|--------|-----------------|
| Mk1 3D-printed fabricator | 330 kW |
| Mk2 3D-printed fabricator | 540 kW |
| Mk3 3D-printed fabricator | 880 kW |
| Mk1 CNT fabricator | 750 kW |
| Mk2 CNT fabricator | 1,080 kW |
| Mk3 CNT fabricator | 1,490 kW |
| **Total (all six units)** | **5,070 kW** |

> **Note:** This combined power budget figure is **[PROPOSED / PLACEHOLDER]** and represents the sum of placeholder values in the tables above. It has not been validated against actual `operational_data` configurations or complete settlement operational profiles.

A settlement running all six fabrication tiers simultaneously requires a base power generation capacity of approximately **5.1 MW continuous**. This figure does not include extractor loads, habitat systems, or terraforming infrastructure, which compound on the same generation bus.

---

## 4. Automated Maintenance Degradation Cycles and System Failure Modes

### 4.1 Maintenance Degradation Model

All ISRU units degrade over operational time according to tier-dependent exponential decay curves. Degradation affects throughput, quality yield, power efficiency, and failure probability.

**Degradation formula:**
```
Throughput(t) = Throughput_0 × e^(-λt)
Quality_Yield(t) = Quality_0 × e^(-μt)

Where:
  t     = operational hours since last maintenance
  λ     = throughput degradation rate (tier-specific)
  μ     = quality yield degradation rate (tier-specific)
```

| Tier | Degradation Rate λ | Quality Rate μ | Maintenance Interval (hours) | Maintenance Duration (hours) | Maintenance Effect | Grounding |
|------|-------------------|----------------|------------------------------|-----------------------------|---------------------|-----------|
| Mk1 3D-printed | 0.0008 | 0.0012 | 500 | 8 | Reset throughput to 95% of nominal | **[PROPOSED / PLACEHOLDER]** — exponential decay parameters are synthetic estimates; no architecture backing |
| Mk2 3D-printed | 0.0010 | 0.0015 | 400 | 12 | Reset throughput to 92% of nominal | **[PROPOSED / PLACEHOLDER]** — exponential decay parameters are synthetic estimates; no architecture backing |
| Mk3 3D-printed | 0.0014 | 0.0020 | 300 | 16 | Reset throughput to 90% of nominal | **[PROPOSED / PLACEHOLDER]** — exponential decay parameters are synthetic estimates; no architecture backing |
| Mk1 CNT | 0.0009 | 0.0013 | 450 | 10 | Reset throughput to 94% of nominal | **[PROPOSED / PLACEHOLDER]** — exponential decay parameters are synthetic estimates; no architecture backing |
| Mk2 CNT | 0.0012 | 0.0017 | 350 | 14 | Reset throughput to 90% of nominal | **[PROPOSED / PLACEHOLDER]** — exponential decay parameters are synthetic estimates; no architecture backing |
| Mk3 CNT | 0.0015 | 0.0021 | 280 | 18 | Reset throughput to 88% of nominal | **[PROPOSED / PLACEHOLDER]** — exponential decay parameters are synthetic estimates; no architecture backing |

*(Remaining original failure-mode content continues here unchanged from the source page.)*

---

## 5. Modular Orbital Panel Technology (CNT Downstream Product)

> **Status:** DIRECTION  
> *Candidate design intent. Not yet ESTABLISHED INTENT. Geometry, exact placement distances, and full performance numbers remain open.*

CNT output from the fabricators above is the primary structural feedstock for a family of modular orbital panels. These panels form the shared technology base used for both Venus solar-shade functions and Mars solar-reflector functions.

**Core design principles**
- Panels are produced primarily from Venus-sourced carbon (local atmospheric CO₂ cracking → CNT).
- One underlying modular frame family; configuration is additive rather than unique per planet.
- Frames can be adjusted, expanded, or partially replaced over time.
- Venus shade construction is optional / progressive (may be partial or absent depending on game progression).
- Mars reflector path has clearer intent that the capability is built.

**Candidate frame form**
- Octagonal (or equivalent modular) CNT structural frames.
- Multiple designs remain allowed; the octagonal form is the current working assumption, not a hard lock.

**Optional / additive configurations (same base frame)**
| Configuration | Primary function | Notes |
|---------------|------------------|-------|
| Basic shade / structural | Solar-constant reduction (Venus) or structural backbone | Core CNT frame |
| Solar-collector equipped | Local power generation | Panels can carry photovoltaic layers |
| Hydrogen-capture equipped | Atmospheric or depot H₂ collection | Useful near Venus or at gas depots |
| Reflective (Mars) | Surface insolation boost | Lunar aluminum or equivalent reflective layer applied to the same frame family |
| Energy-beaming capable | Directed power transfer | Enables Venus → Mars (or other location) energy beaming as an optional later capability |

**Tracking & representation model**
- Individual panels, struts, I-beams, and similar components are **never** tracked as discrete entities.
- Representation uses a **swarm model**. Each swarm entry records:
  - Spatial location of the swarm.
  - Counts of panels by type / configuration (metadata).
- Panel mixes are allowed and expected. Technology available at the time a panel was deployed can differ from later panels in the same swarm, so the swarm must track the quantity of each distinct type (e.g., plain Mk1 shade-only panels versus later panels that include power-beaming capability, solar collection, hydrogen capture, etc.).
- Aggregate state (damaged, under repair, queued for replacement + recycling) is tracked against those counts.
- Events and effects are expressed at the swarm level (e.g., “solar flare damaged electronics in X panels of type Y → output reduced by Z”).
- Blueprint + location together determine the functional properties of the swarm.

**Operations (local station support)**
- Local stations deploy service craft that carry bots.
- Bots travel to the swarm to perform repairs on damaged panels.
- For hydrogen-capture panels, bots can extract hydrogen from the panels’ temporary storage and return it to the station.
- Replacement of failed panels and recycling of recovered material are also handled through the same station → craft → bot loop.

**Production & deployment notes**
- Fabrication is intended to occur in orbit (or at high-altitude Venus facilities) using local carbon feedstock.
- Panels produced at Venus can be adapted and shipped/configured for Mars use.
- Exact orbital distance of any Venus shade remains unspecified.
- Energy-beaming capability is treated as an optional addon path that can grow from the same panel family; it is not required for the basic shade or reflector roles.

**Open items (do not invent)**
- Precise geometry tolerances and structural load numbers.
- Exact power-beaming efficiency, wavelength, or aperture requirements.
- Detailed degradation / repair-drone rules for large arrays.
- Whether energy beaming is gated behind a later tech unlock or available as a progressive addon.
- Final data schema for the swarm aggregate (counts, percentages, integrity model, etc.).

---

*Last verified against: `docs/architecture/isru/README.md`, `docs/architecture/isru/cnt_production.md`, `docs/architecture/logistics/SYSTEM_INDUSTRIAL_CHAINS.md` — canonical architecture spec. No runtime enforcement currently exists.*
```