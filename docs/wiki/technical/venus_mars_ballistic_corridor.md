# Venus–Mars Ballistic Corridor (Brute-Force Terraforming Loop)

> **Wiki section:** Technical · **Status:** target design intent — document hard physical mechanics; no runtime enforcement currently exists.

> **Cross-link:** For high-level governance context, planetary protection classes, and policy toggles governing these operations, see **[Planetary Protection & Environmental Governance](../infrastructure/planetary_protection_environmental_governance.md)**.

> **Cross-link:** For the Sol Tri-System Volatile Loop (outer-system $H_2$/methane supply chain), see **[Terraforming Economic Integration](../logistics/terraforming_economic_integration.md#sol-tri-system-volatile-loop)** and **[Atmospheric Harvesting](../infrastructure/Atmospheric-Harvesting.md)**.

---

## Scope

This document specifies the **brute-force terraforming loop** — a mass-driver-based, bulk-transport pathway that delivers engineered gas-pods from Venusian processing infrastructure into Martian atmosphere. It is distinct from the Seed path (recurring low-volume AI Manager buy orders) and operates on a vastly different scale, budget, and timeline.

The ballistic corridor is gated behind **cycler operations**: real terraforming programs do not begin until sustained logistics (Mars–Saturn/Titan cycler) are established so that outer-system volatiles and hydrogen feedstock are available.

---

## 1. Venusian CO₂ Cracking

### Raw Gas Extraction

Venus's atmosphere is extracted at scale through high-altitude aerostat stations:

| Component | Volume % | Role in Terraforming |
|-----------|----------|----------------------|
| Carbon Dioxide (CO₂) | ~96% | Primary feedstock; splits into free O₂ and carbon |
| Nitrogen (N₂) | ~3.5% | Extracted for habitat life support and Mars atmospheric import |
| Trace gases (SO₂, Ar, H₂O vapor) | <0.5% | Byproducts or waste streams |

### Thermal / Chemical Splitting

Extracted CO₂ is fed into thermal cracking arrays:

1. **Thermal decomposition:** CO₂ → C (solid carbon) + O₂ (free oxygen)
2. **Energy source:** Solar concentrators and Venus orbital shade reflection provide the high-temperature input (~2,500 K).
3. **Oxygen handling:** Free O₂ is cryogenically chilled and compressed into solid/frozen pods for transport.
4. **Carbon capture:** Solid carbon is processed into precursor feedstock for CNT manufacturing.

> **Design note:** Venus under **Option B (Pure Industrial Powerhouse)** operates uncapped N₂ and CO₂ skimming without terraforming tariffs. Under **Option A (Terraforming Reserve)**, N₂ exports are managed against a 1-bar buffer (~4 × 10¹⁸ kg N₂) with Hydrogen Import Credits required for outer-system freighters.

---

## 2. CNT Shell Manufacturing

### Carbon Nanotube Structural Pods

Processed carbon from CO₂ cracking is spun into high-strength **Carbon Nanotube (CNT)** material, which forms the structural containment shells for transport pods:

1. **CNT production:** Industrial-scale nanotube manufacturing in Venus orbital/industrial stations produces CNT yarns and weaves.
2. **Pod fabrication:** CNT shells are woven into multi-layered containment vessels rated to survive launch acceleration, interplanetary transit, and atmospheric reentry heating.
3. **Encapsulation:** The CNT shell encapsulates frozen O₂/N₂ gas pods, providing:
   - **Structural integrity** during mass driver launch (high G-forces)
   - **Thermal protection** during Martian atmospheric reentry
   - **Controlled failure envelope** designed to rupture at target altitude

### Pod Specifications (Target Design Intent)

| Parameter | Target Value | Notes |
|-----------|-------------|-------|
| Shell material | Multi-layer CNT weave | High tensile strength, low mass fraction |
| Payload composition | Frozen O₂ + N₂ mix | Ratio tailored to Mars atmospheric target |
| Containment rating | Survives launch Δv and transit | Designed for controlled reentry failure |
| Failure trigger | Thermal/structural threshold at altitude | Flash-releases gases in upper atmosphere |

> **Cross-link:** For the canonical CNT fabrication chain (Mk1–Mk3 upgrade trees, CO₂ + catalyst feedstock, 750 kW / 100 kg/hr throughput specs), see **[ISRU Fabrication Chain](./isru_fabrication_chain.md)**.

---

## 3. Mass Driver Ballistics

### Launch Architecture

Prepared gas pods are launched from Venus orbital mass driver arrays:

1. **Chilling & pressurization:** O₂ and N₂ gases are cryogenically frozen inside CNT-encapsulated pods at Venus processing stations.
2. **Magrail loading:** Pods are loaded into electromagnetic launchers (mass drivers) positioned at Venus orbital stations.
3. **Launch window targeting:** Mass driver firings are synchronized with **Venus–Mars alignment windows** to minimize transit time and delta-v requirements.
4. **Ballistic trajectory:** Fired pods follow interplanetary transfer trajectories toward Mars. No mid-course correction is needed for the early phase — bulk ballistic delivery relies on precision initial impulse.

### Mass Driver Infrastructure Requirements

- Orbital positioning (not surface-based, due to Venus gravity well)
- Power infrastructure for sustained electromagnetic acceleration
- Pod production and loading automation at industrial scale
- Coordination with cycler logistics for feedstock replenishment

---

## 4. Engineered Reentry Dispersion

### Pod Descent Sequence

The CNT-encapsulated gas pods are engineered to undergo **controlled thermal and structural failure** upon hitting the Martian upper atmosphere:

1. **Atmospheric interface:** Pods enter Mars exosphere at ballistic velocity (~6 km/s relative).
2. **Thermal activation:** Atmospheric friction heats the CNT shell beyond its structural threshold.
3. **Structural rupture:** The CNT containment fails at a pre-calculated altitude band in the upper atmosphere.
4. **Flash-release:** Frozen O₂ and N₂ gases sublimate and disperse directly into the Martian atmospheric column, providing **immediate localized atmospheric thickening**.

### Tactical Advantages of Engineered Reentry

| Advantage | Detail |
|-----------|--------|
| Immediate atmospheric effect | Gases release at altitude rather than surface, maximizing dispersion |
| No landing infrastructure needed | Pods are expendable; no recovery required |
| Distributed delivery | Multiple pods across a wide area prevent localized over-concentration |
| Scalable payload density | Launch cadence and pod count control atmospheric injection rate |

---

## 5. Sol Tri-System Volatile Loop

### Overview

The brute-force ballistic corridor requires significant hydrogen feedstock (for Sabatier methane synthesis and as a Mars greenhouse agent). The design **explicitly prefers outer-system sources over drawing down Mars or Luna water reserves**.

### Supply Chain Diagram

```
[Saturn Harvester] ─────(H₂)────────────────────────► [Martian Sabatier]
         │
         │ (H₂)
         ▼
[Venus Sabatier Plant] ──(CH₄, O₂)────────────────► [Mars]
         │
         └── CNT shell production ──► Mass Driver Pods ──╯
```

### Source Priorities

| Feedstock | Preferred Source | Alternative | Notes |
|-----------|-----------------|-------------|-------|
| **Hydrogen (H₂)** | Saturn skimmers | Jupiter extraction | Saturn preferred due to Titan proximity |
| **Methane (CH₄)** | Titan harvesting | Luna (from CO₂) | Titan is canonical preference |
| **Water ice** | Reserved — do not consume for terraforming | Mars/Luna reserves for habitation only | Explicitly preserved per conservation policy |

### Titan Conservation Mandate

Titan's total volatile extraction is capped at **5% of initial mass** (dual-cap architecture: rate limit + total reserve cap). This creates long-term scarcity pressure on the H₂/methane supply chain and reinforces the need for efficient Venus-based Sabatier processing.

---

## 6. Design Intent Boundaries

### Physical Mechanisms (Hard)

- CO₂ cracking energy scales with atmospheric mass — industrial-scale infrastructure required
- CNT production is a throughput bottleneck, not just cost constraint
- Mass driver launch cadence determines maximum injection rate into Mars atmosphere
- Reentry dispersion efficiency depends on pod design and target altitude band

### Non-Mechanisms (Explicitly Excluded)

| Exclusion | Reason |
|-----------|--------|
| Player-controlled terraforming budgets | Terraforming is AI Manager background simulation |
| Population/labor sliders | Population is a soft local modifier, not direct allocation mechanism |
| Wormholes/portals for bulk transport | In-system cyclers and mass drivers handle all bulk logistics |
| Early-game brute-force deployment | Requires cycler operations and outer-system feedstock first |

---

## 7. Relation to Other Terraforming Pathways

This brute-force ballistic corridor operates alongside (and after) the **Seed path** for terraforming:

| Factor | Seed Path | Brute-Force Ballistic |
|--------|-----------|----------------------|
| **Scale** | Low-volume, recurring | Bulk industrial deployment |
| **Front cost** | Low (recurring gas buy orders) | High (infrastructure build-out) |
| **Speed of effect** | Gradual, ongoing | Rapid atmospheric thickening pulses |
| **Infrastructure** | Market orders to AI Manager | Mass drivers, CNT plants, cracking arrays |
| **Gated by** | GCC liquidity | Cycler operations + outer-system H₂ |
| **Governance** | Planetary protection classes | Same protection classes apply |

---

*Last verified against: `docs/gameplay/terraforming.md`, `docs/architecture/biology/TERRAFORMING_SEED_AND_LIFE_DIRECTION.md` — target design intent. No runtime enforcement currently exists.*
