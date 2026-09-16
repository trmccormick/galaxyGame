# Craft Taxonomy

**Status**: Canonical design decision with implementation-alignment notes  
**Scope**: Luna bootstrap and extensible future infrastructure  
**Implementation status**: Mixed — source-level evidence and planned alignment  
**Decision authority**: Human design decisions recorded 2026-09-15  
**Last evidence review**: 2026-09-15  
**Related pages**: [Currency Governance](../economy/02-currencies-and-accounts#currency-governance)

---

## 1. Overview

This page defines the craft taxonomy and entity boundaries for Galaxy Game. It establishes terminology conventions, distinguishes manufactured craft from natural celestial bodies, and documents attachment categories (units, modules, rigs).

---

## 2. Terminology Convention

| Term | Required Meaning |
|---|---|
| Craft | Manufactured mobile or independently operating vehicle/asset category |
| Unit | Attachable functional equipment entity hosted by compatible craft, settlements, or structures |
| Module | Attachable structural/functional assembly distinct from a unit |
| Rig | Host-preserving attachable/deployable modification, not a loadout |
| Recommended fit | NPC/test/reference assembly configuration, not a rig or final player fitting |
| Station | Settlement type, not a craft |
| Structure | Physical asset belonging to settlement, distinct from mobile craft |
| Component | Standardized hardware part; identity does not vary by manufacturing location |
| Natural satellite | Celestial body orbiting a parent celestial body |
| Manufactured satellite | Constructed orbital craft, distinct from a natural satellite |
| GCC mining satellite | Established proper asset name for a manufactured satellite used in simulated compute-based GCC issuance |
| Issuance | Creation/settlement of new currency units under a currency policy |
| Physical extraction | Production of physical materials/cargo; never GCC issuance |

---

## 3. Entity Boundaries

### Craft

Manufactured mobile or independently operating vehicle/asset category. Craft are constructed orbital vessels capable of independent operation (subject to operational constraints defined elsewhere).

**Verified source-level evidence:**
- `Craft::BaseCraft` is the active reported craft base class.
- The top-level `Ship` status remains unverified/legacy-uncertain; do not represent it as canonical craft taxonomy.

### Unit

Attachable functional equipment entity hosted by compatible craft, settlements, or structures. Units provide specific capabilities to their host without modifying the host's structural identity.

**Verified source-level evidence:**
- Craft has reported associations for units.

### Module

Attachable structural/functional assembly distinct from a unit. Modules modify the host's structure, capacity, or internal layout rather than adding discrete functional capability.

**Verified source-level evidence:**
- Craft has reported associations for modules.

### Rig

Host-preserving attachable/deployable modification. Rigs preserve the host blueprint identity and Mk/design revision. Rigs are EVE-inspired attachable/deployable host modifications, not loadouts.

**Settled design decision:**
- Rigs preserve the host blueprint identity and Mk/design revision.
- A rig is not a loadout and does not change the craft's fundamental classification.

**Verified source-level evidence:**
- `Rigs::BaseRig` and rig attachment/effect concerns exist; rig effects are tracked in operational data.
- Rig-port/compatibility evidence exists only where supported by operational data.

### Recommended Fit

NPC/test/reference assembly configuration parsed from manifest/operational data. Used to provision initial satellite units, modules, and rigs.

**Settled design decision:**
- `recommended_fit` is an NPC/test/reference configuration, not a rig and not a finalized player-fitting architecture.
- Player fitting is explicitly deferred.

**Verified source-level evidence:**
- `recommended_fit` is parsed from manifest/operational data and used to provision initial satellite units, modules, and rigs.

### Station

> **Retired source:** `Settlement::SpaceStation` was retired on 2026-04-10.
> Its file is retained for Git history only and must not be used as current
> implementation evidence. The retirement notice names
> `Settlement::OrbitalSettlement` with `Structures::OrbitalStructure` as the
> replacement model direction.

Orbital settlements are settlement types, not craft. An orbital settlement is
a constellation of structures rather than a single fixed object.

**Current source-level evidence:**
- `Structures::OrbitalStructure < Structures::BaseStructure` belongs to
  `Settlement::OrbitalSettlement`.
- The active orbital-settlement model accesses its constituent structures for
  settlement-level behavior; exact association declarations and specialization
  lifecycle should be cited only where separately verified.

**Canonical design intent:**
- An orbital settlement can directly contain multiple specialized orbital
  structures, such as depots and shipyards.
- "Station" is a gameplay/documentation term for this composite orbital
  infrastructure, not an active alias for the retired
  `Settlement::SpaceStation` class.

### Structure

Physical asset belonging to a settlement. Distinct from mobile craft in both class hierarchy and operational role.

---

## 4. Natural Versus Manufactured Satellites

Galaxy Game maintains a strict boundary between natural satellites (celestial bodies) and manufactured satellites (craft):

| Category | Class Hierarchy | Domain |
|---|---|---|
| Natural satellite | `CelestialBodies::Satellites::Satellite < CelestialBody` | Universe Generation / Planetary Simulation |
| Manufactured satellite | `Craft::Satellite::BaseSatellite < Craft::BaseCraft` | Transportation / Craft |

### Natural Satellites

Celestial bodies orbiting a parent celestial body. Part of the StarSim universe generation pipeline and TerraSim planetary simulation. Managed by the `CelestialBody` hierarchy.

### Manufactured Satellites

Constructed orbital craft, distinct from natural satellites. Part of the craft taxonomy managed by the `Craft::BaseCraft` hierarchy. Includes GCC mining satellites and other constructed orbital vessels.

**Settled design decision:**
- "GCC mining satellite" remains the established proper asset name for a manufactured satellite used in simulated compute-based GCC issuance.
- This is a lore/asset name, not a description of physical extraction activity.

---

## 5. GCC Mining Satellite — Limited Entry

> **GCC mining satellite** is the established proper asset name for a manufactured satellite used in simulated compute-based GCC issuance.

This entry provides terminology and boundary context only. Numeric yields, rates, caps, halving schedules, difficulty values, block rewards, and daily output are excluded from this documentation (see Explicit Exclusions below).

### Verified Source-Level Evidence

- `Craft::Satellite::BaseSatellite < Craft::BaseCraft` is a manufactured satellite class.
- The inspected GCC mining path uses computer-unit output and power/thermal/processing effects, plus ledger-account deposits; no physical material output was identified in that path.
- Current mining source paths show inconsistent recipient routing and lack a demonstrated LDC authorization guard.

### What Cannot Be Claimed Yet

- Maintenance, repair, and lifecycle decommissioning are not established as implemented craft behavior by the current evidence.
- Satellite-level `*_per_hour` mining-rate fields and configured cap/halving/difficulty/block-reward values must not be represented as active runtime controls without verified source evidence.
- Tick, scheduled-job, and mission mining triggers coexist; their timing and settlement semantics remain under alignment.

### GCC Issuance Versus Physical Extraction

| Aspect | GCC Issuance | Physical Extraction |
|---|---|---|
| Output type | Virtual ledger credits (GCC) | Physical materials/cargo |
| Mechanism | LDC-controlled simulated compute mining | Material extraction from celestial bodies |
| Currency creation | Yes (under currency policy) | No — never directly creates GCC |
| Governance | Per-currency policy definition | Resource/blueprint definitions |

> **Implementation alignment note**  
> GCC's canonical policy is LDC-controlled simulated-compute issuance, with newly issued GCC intended for the existing LDC GCC account. Source-level review identified generic mining paths with differing recipient routing and no demonstrated LDC authorization guard. This documentation does not claim that the intended policy is currently enforced.

---

## 6. Attachments and Reference Fits

### Units

Units are attachable functional equipment entities. Craft have reported associations for units. Units provide discrete capabilities to their host craft.

### Modules

Modules are attachable structural/functional assemblies. Distinct from units in that they modify structure/capacity rather than adding functional capability.

### Rigs

`Rigs::BaseRig` and rig attachment/effect concerns exist; rig effects are tracked in operational data. Rigs preserve host blueprint identity and Mk/design revision. Rig-port/compatibility evidence exists only where supported by operational data.

### Recommended Fit Boundaries

- Parsed from manifest/operational data.
- Used to provision initial satellite units, modules, and rigs.
- Represents an NPC/test/reference configuration.
- **Not a rig** and **not a finalized player-fitting architecture**.
- Player fitting is explicitly deferred.

---

## 7. Currency Governance Models

Galaxy Game uses a multi-currency economy. Per-currency policy defines governance, issuance authority, issuer eligibility, recipient routing, supply rules, audit rules, and exchange behavior. These are NOT implied by account existence, compute hardware, or craft type.

### Supported Currencies (Initial)

| Currency | Role | Issuer | Governance |
|---|---|---|---|
| GCC | Primary space-side numeraire | LDC (Luna Development Corporation) | Centralized, LDC-controlled |
| USD | Earth-side import/export anchor | System (pre-defined) | Fixed, system-managed |

### Future Currency Categories (Deferred)

Additional currencies may use different governance models:
- System-managed
- Corporate
- Regional
- Consortium
- Protocol
- Permissionless
- Service/asset-credit

> **Compute capacity alone is not GCC mint authority.** Eligible infrastructure must be explicitly LDC-authorized.

---

## 8. Settled Design Decisions

The following are recorded as canonical design decisions, not inferred source behavior:

1. Galaxy is a multi-currency economy.
2. GCC and USD are the initial supported currencies.
3. Additional Earth currencies may be added when required.
4. Future off-Earth currencies may use different governance models (listed above).
5. Governance, issuance authority, issuer eligibility, recipient routing, supply rules, audit rules, and exchange behavior are defined per currency policy; they are not implied by account existence, compute hardware, or craft type.
6. GCC is centrally managed, crypto-inspired, nonphysical virtual-ledger currency with eight-decimal precision.
7. During initial launch and Luna bootstrap, 1 GCC = 1 USD.
8. Future GCC uncoupling is deferred. A narrow LDC-managed parity band is a nonbinding future design reference only.
9. GCC issuance uses LDC-controlled simulated compute mining.
10. Compute capacity alone is not GCC mint authority.
11. Initial GCC issuance infrastructure is LDC-operated crypto-mining satellites.
12. Later eligible infrastructure may include explicitly LDC-authorized compute facilities.
13. Newly issued GCC is intended to flow to the existing LDC GCC account.
14. LDC circulates already-issued GCC through explicit transfers, liquidity, contracts, services, rewards, and other authorized disbursements.
15. Physical extraction produces material/cargo and never directly creates GCC.
16. A future permissionless/protocol currency is possible but deferred; do not describe it as current gameplay or enable it through GCC wording.
17. Standardized component identity does not vary by manufacturing location.
18. Mk/Mark means hardware design revision, not place of manufacture or fitted configuration.
19. Rigs are EVE-inspired attachable/deployable host modifications, not loadouts. They preserve the host blueprint identity and Mk/design revision.
20. `recommended_fit` is an NPC/test/reference configuration, not a rig and not a finalized player-fitting architecture.
21. A craft undergoing construction, repair, upgrade, or refit is not in normal operations. Do not claim this is currently runtime-enforced unless source evidence proves it.

---

## 9. Explicit Exclusions

The following are explicitly excluded from this page:

- All numeric mining-rate, cap, halving, difficulty, block-reward, and daily output claims.
- All unenforced authorization/routing claims (status-labeled only).
- All unsupported lifecycle/player-fitting claims (deferred).
- All Mars/future-only material (deferred).
- Player fitting architecture (deferred).
- Full logistics network documentation.
- Every craft type enumeration.
- Player UI documentation.
- Fusion power taxonomy.
- Full market architecture.

---

## See Also

- [GCC Mining Satellite](./02-gcc-mining-satellite) — GCC mining satellite entry: terminology, classification, issuance vs extraction boundary, implementation-alignment notes
- [Currency Governance](../economy/02-currencies-and-accounts#currency-governance) — Multi-currency architecture and per-currency policy vocabulary
- [Glossary](../../reference/glossary) — Terminology definitions
- [Cross References](../../phase4/CROSS_REFERENCE_PLAN) — Topic map

---

## Change History

- **2026-09-15**: Created as canonical craft taxonomy page per Phase 4 wiki construction (Phase 4).
- **2026-09-15**: Normalized to Economy pattern: numbered filename, numbered major headings (`## N.`), simplified status block with extended implementation-alignment metadata retained for code/design boundary tracking, Key Models & Services table added, relative links updated (Transportation normalization).
