# ISRU Fabrication Chain (3D-Printed + CNT Fabricators)

> **Wiki section:** Technical · **Status:** target design intent — canonical ISRU production mechanics, feedstock qualification, and fabricator upgrade trees; no runtime enforcement currently exists.

> **Cross-link:** For the Venus–Mars ballistic corridor that uses CNT shell containment pods, see **[Venus–Mars Ballistic Corridor (Brute-Force Loop)](./venus_mars_ballistic_corridor.md)**.

> **Cross-link:** For atmospheric harvesting of CO₂ and N₂ from Venus/Titan, see **[Atmospheric Harvesting](../infrastructure/Atmospheric-Harvesting.md)**.

---

## Scope

This document defines the In-Situ Resource Utilization (ISRU) production chain that converts raw planetary resources into manufactured components. Two parallel fabrication trees operate: **3D-printed fabricators** for structural components (panels, I-beams) and **CNT fabricators** for advanced composites and infrastructure materials. Both follow a Mk1 → Mk2 → Mk3 upgrade path with strict component dependencies and blueprint canonicalization.

**Authority:** This document promulgates requirements from `docs/architecture/isru/README.md`, `docs/architecture/isru/cnt_production.md`, and `docs/architecture/logistics/SYSTEM_INDUSTRIAL_CHAINS.md`. If code contradicts these specs, the code is wrong.

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

## 2. 3D-Printed Fabricator Chain (Mk1–Mk3)

The 3D-printed fabricator chain is the backbone of early settlement construction. Each generation upgrades throughput, material compatibility, and automation — with **each upgrade requiring the previous generation as a component**.

### Mk1 — Entry-Level Fabricator

| Property | Detail |
|----------|--------|
| **Input** | Qualified regolith feedstock (composition-analyzed, additives blended as needed) |
| **Output** | Structural panels, I-beams (basic habitat and infrastructure components) |
| **Role** | Foundation of all early construction on any world |

### Mk2 — Advanced Fabricator

| Property | Detail |
|----------|--------|
| **Requirement** | Mk1 fabricator as a component |
| **New capabilities** | `advanced_composites`, `high_performance_electronics`, `drive_systems` |
| **Upgrade effect** | Higher throughput, expanded material palette |

### Mk3 — Smart Fabricator

| Property | Detail |
|----------|--------|
| **Requirement** | Mk2 fabricator as a component |
| **New capabilities** | `smart_composites`, `quantum_electronics` (upgrades existing materials) |
| **Upgrade effect** | Maximum throughput, precision manufacturing, advanced material processing |

### Upgrade Dependency Chain

```
Qualified Regolith → [Mk1 Fabricator] → Panels + I-Beams
                              ↓ (require Mk1 as component)
                         [Mk2 Fabricator] → Advanced Composites + Electronics + Drive Systems
                              ↓ (require Mk2 as component)
                         [Mk3 Fabricator] → Smart Composites + Quantum Electronics
```

---

## 3. CNT Fabricator Chain (Mk1–Mk3)

The CNT fabricator chain operates in parallel to the 3D-printed chain but processes **atmospheric CO₂ and catalyst** rather than regolith. It enables high-performance composites for orbital infrastructure, mass driver components, and ballistic corridor pod manufacturing.

### Mk1 — CNT Fabricator

| Property | Detail |
|----------|--------|
| **Inputs** | CO₂ (from local atmosphere or delivered precursor) + Catalyst (required input, defined in operational data) |
| **Output** | Raw Carbon Nanotubes |
| **Power** | 750 kW per fabricator unit |
| **Throughput** | 100 kg/hour from CO₂ feedstock |

### Mk2 — Advanced CNT Fabricator

| Property | Detail |
|----------|--------|
| **Requirement** | Mk1 CNT fabricator as a component |
| **New capabilities** | `advanced_composites`, `high_performance_electronics`, `drive_systems` (in addition to raw CNT output) |
| **Upgrade effect** | Higher throughput, expanded material compatibility |

### Mk3 — Smart CNT Fabricator

| Property | Detail |
|----------|--------|
| **Requirement** | Mk2 CNT fabricator as a component |
| **New capabilities** | `smart_composites`, `quantum_electronics` (upgrades existing materials) |
| **Upgrade effect** | Maximum throughput, precision nanotube fabrication for orbital infrastructure |

### CNT Production Economics

| Metric | Value | Detail |
|--------|-------|--------|
| Power per fabricator | 750 kW | Constant across Mk generations; higher-tier units may have additional systems load |
| Production rate | 100 kg/hr/unit (Mk1) | Higher rates for Mk2/Mk3 upgrades |
| Shipping value | 15,000 GCC/ton | Interplanetary CNT shipping price |
| Foundry prerequisite | Atmospheric processors + CNT fabricator on cycler platforms | Required before lunar megastructure CNT production |

### CNT Supply Chain Dependency for Lunar Space Elevator

```
Venus/Mars cyclers establish foundry operations → CO₂ extracted → CNTs produced from local atmospheric feedstock
    → CNTs transported to lunar construction sites → Lunar space elevator construction available (requires 500,000 kg CNT)
    → Completed elevator enables direct surface-to-orbit bulk transit
```

---

## 4. Operational Standards & Compliance

### Operational Data Requirements

Every fabricator unit **must have a matching operational data file**. The operational data defines:
- Power consumption (kW)
- Throughput rate (kg/hr or equivalent)
- Storage capacity
- Safety systems

**Compliance:** All active units (fabricators, extractors, printers) must have operational data files that are strictly enforced for ISRU compliance. Missing or mismatched operational data invalidates the unit.

### Blueprint Canonicalization Rules

| Rule | Enforcement |
|------|-------------|
| Only canonical blueprints/items from designated folders are valid for ISRU chains | Duplicates or misplaced files (e.g., non-canonical planetary_volatiles_extractor) are removed and must not be referenced |
| All `required_materials` are resolvable and validated against operational data | Any unresolvable material chain breaks the unit's validity |
| Each upgrade requires the previous generation as a component | Material chains are strictly canonical — no skipping tiers |

### Audit Status

All Mk1–Mk3 3D-printed fabricators, regolith shell printers, and CNT fabricators have been reviewed for:
- Canonical material chain alignment
- Operational data consistency
- Blueprint integrity
- `required_materials` resolvability

---

*Last verified against: `docs/architecture/isru/README.md`, `docs/architecture/isru/cnt_production.md`, `docs/architecture/logistics/SYSTEM_INDUSTRIAL_CHAINS.md` — canonical architecture spec. No runtime enforcement currently exists.*
