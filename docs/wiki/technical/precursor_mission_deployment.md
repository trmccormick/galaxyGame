# Precursor Mission Deployment Sequence

> **Wiki section:** Technical · **Status:** target design intent — canonical precursor deployment sequence, power bridge mechanics, and tether transition; no runtime enforcement currently exists.

> **Cross-link:** For the ISRU fabrication chains (3D-printed and CNT) that are deployed during the precursor mission, see **[ISRU Fabrication Chain](./isru_fabrication_chain.md)**.

> **Cross-link:** For the Solar Tri-System volatile loop and atmospheric processing at L1 Depot, see **[Terraforming Economic Integration](../logistics/terraforming_economic_integration.md)** and **[Venus–Mars Ballistic Corridor (Brute-Force Loop)](./venus_mars_ballistic_corridor.md)**.

---

## Scope

This document defines the **mandatory deployment sequence** for all precursor missions — any world where human settlement begins. The sequence is strictly ordered, world-invariant, and gate-locked: each step must complete before the next can begin. It governs the transition from landed robotic deployment to powered surface operations to first 3D-printed structure.

**Authority:** This document promulgates requirements from `docs/architecture/isru/README.md`. The sequence is canonical for all worlds, regardless of equipment naming updates. If code contradicts this sequence, the code is wrong.

---

## 1. Canonical Precursor Deployment Sequence

Every precursor mission follows this exact four-step order:

```
Step 1: Land & deploy robots ──────────────────────────► Surface operations begin
Step 2: Comms + Power (RTG + Solar Expansion Rig) ───► Power online
Step 3: Regolith harvesting units deployed ─────────────► Raw feedstock available
Step 4: First 3D-printed structure (solar array support) ► Full solar farm construction
```

### Step 1 — Land & Deploy Robots

| Action | Detail |
|--------|--------|
| Precursor robotic mission lands on target world | Hard-coded landing and deployment |
| Robots deployed for surface operations | First operational capability of the mission |
| No construction possible yet | Dependent on Steps 2 and 3 completing first |

### Step 2 — Establish Comms & Power Infrastructure

This step has two sub-phases that happen in sequence:

#### 2a. Solar Expansion Rig Mounting (Temporary Power Bridge)

Immediately after landing, robots mount the **Solar Expansion Rig** to the HLT (lander):

| Property | Detail |
|----------|--------|
| **Purpose** | Temporarily expand available power for initial ISRU, robotics, and infrastructure setup |
| **Power source** | Additional solar panels deployed on the rig |
| **Duration** | Temporary — bridges the gap between RTG-only power and full solar farm construction |
| **Distinction** | The Solar Expansion Rig is **distinct from the permanent solar farm**; it is modular and early-deployed |
| **3D-printing status** | **NOT 3D-printed** — mounted directly by deployed robots |

#### 2b. Comms & Power Network Online

| Component | Detail |
|-----------|--------|
| RTG (Radioisotope Thermoelectric Generator) | Baseline power before solar panels deploy |
| Solar farm support structure | First thing produced after Step 3 (see Step 4) |
| Power management systems | Connect RTG, expansion rig, and solar farm |

### Step 3 — Deploy Regolith Harvesting & Extraction Units

| Action | Detail |
|--------|--------|
| Surface regolith collection units deployed | Automated harvesting begins |
| Regolith composition analyzed | SiO₂, FeO, and trace elements evaluated (see [ISRU Fabrication Chain](./isru_fabrication_chain.md)) |
| Additive blending as needed | Feedstock qualified for fabricator acceptance |

### Step 4 — First 3D-Printed Structure: Solar Array Support

The **first** 3D-printed structure on any world is always the **support array for the solar panels (solar farm)**:

| Property | Detail |
|----------|--------|
| Produced by | Mk1 I-beam printing unit using qualified regolith |
| Purpose | Enables full permanent solar farm buildout |
| Timing gate | Cannot begin until Step 3 (harvesting + feedstock qualification) completes |
| Significance | Marks the transition from temporary power (Solar Expansion Rig) to permanent power infrastructure |

### Sequence Gate Summary

```
[Land robots] ──► [Mount Solar Expansion Rig + Comms/RTG] ──► [Harvest regolith → qualify feedstock]
                                                                          │
                                                                          ▼
                                                    [Mk1 fabricator prints solar array support]
                                                                          │
                                                                          ▼
                                                   [Full permanent solar farm construction begins]
```

**Critical constraint:** Power and comms must be online **before** any major construction. The first use of 3D printing is always for the solar array/farm support — never for habitats or other infrastructure first.

---

## 2. Power Bridge: Solar Expansion Rig Mechanics

### Design Purpose

The Solar Expansion Rig solves the power gap problem during the earliest phase of settlement:

| Time Window | Power Source | Duration |
|------------|-------------|----------|
| **Phase 0:** Landing to rig deployment | RTG only | Very limited; enough for robots and comms |
| **Phase 1:** Rig deployed, solar farm under construction | RTG + Solar Expansion Rig panels | Adequate for ISRU setup and robotics |
| **Phase 2:** Full solar farm operational | Permanent solar farm (3D-printed support + panels) | Sustained power for settlement growth |

### Key Characteristics

| Characteristic | Detail |
|---------------|--------|
| Modular design | Rapid deployment by robots; no precision alignment required |
| Temporary solution | Intentionally bridging to permanent infrastructure, not a long-term fix |
| Distinct from permanent farm | Different hardware, different deployment method (robot-mounted vs 3D-printed) |
| Immediate power gain | Enables ISRU and robotics to scale up immediately after landing |

---

## 3. Tether Transition: From USD Dependency to Zero Import Ratio

### The Earth-Launch Constraint

During the precursor mission and early Phase 1 (Work Camp), settlement production is **100% dependent on Earth-side manufacturing** for high-complexity components.

### Component Tier System

| Tier | Source | Examples | Currency |
|------|--------|----------|----------|
| **Tier 1** | Local ISRU | Regolith, O₂, H₂O, I-Beams (3D-printed on-site) | GCC |
| **Tier 2** | Regional Sol trade | Refined Alloys, Glass (future orbital trade via L1/Depot) | GCC |
| **Tier 3** | Earth launch (import) | `ruggedized_electronics`, `high_strength_actuators` | USD (5× baseline transport cost) |

### USD Import Multiplier

All Earth-sourced Tier 3 transactions use **USD at a 5.0× multiplier** of the Earth baseline price. This is defined in `lunar-precursor-ai_profile_v1.json`. This elevated cost drives the AI Manager's prioritization of local production and tether severance.

### Maintenance Crate Requirement

Every CAR-300 deployment must include a **Maintenance Crate** with:
- **Minimum:** 250 kg of Tier 3 spares
- **Purpose:** Survival during transition to Phase 2 before local ISRU can produce replacements
- **Currency impact:** Consumes Earth-funded maintenance budget; each crate depletes the tether buffer

### Strategic Goal: Tether Severance

The AI Manager's primary long-term objective is to **decrease the USD Import Ratio toward zero** by transitioning as many Tier 2/3 requirements to local Tier 1 ISRU production before the initial Earth-funded maintenance crate is exhausted. Complete severance means:
- Zero USD imports — all components sourced via Tier 1 (ISRU) or Tier 2 (Sol trade)
- Full settlement self-sufficiency independent of Earth supply chains
- All transactions settled in GCC, not USD

### Tether Severance Progression

```
Phase 1: 100% Tier 3 (USD imports) — Maintenance crate depleting
    ↓
Phase 1.5: Tier 1 ISRU scales up — I-beams, panels, basic structures local
    ↓
Phase 2: Tier 2 Sol trade activates — refined alloys via L1/Depot orbital logistics
    ↓
Phase 3+: Tether Severance complete — Zero USD imports, full GCC economy
```

---

## 4. World-Invariant Deployment Rules

The deployment sequence is **canonical for all worlds**, not just Luna. The following rules apply universally:

| Rule | Detail |
|------|--------|
| Order cannot be reordered | Power/comms before construction; first print always solar array support |
| Equipment names may evolve | The intent (solar farm support as first structure) is fixed, even if item names change |
| Solar Expansion Rig always robot-mounted | Never produced by fabricators — it is a deployed hardware component |
| Tether severance is the AI Manager's priority | All ISRU expansion decisions are evaluated against their impact on reducing USD import ratio |

---

*Last verified against: `docs/architecture/isru/README.md` — canonical architecture spec. No runtime enforcement currently exists.*
