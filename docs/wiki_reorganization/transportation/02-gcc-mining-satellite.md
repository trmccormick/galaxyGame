# GCC Mining Satellite

**Status**: Canonical design decision with implementation-alignment notes  
**Scope**: Luna bootstrap and extensible future infrastructure  
**Implementation status**: Mixed — source-level evidence and planned alignment  
**Decision authority**: Human design decisions recorded 2026-09-15  
**Last evidence review**: 2026-09-15  
**Related pages**: [Craft Taxonomy](./01-craft-taxonomy), [Currency Governance](../economy/02-currencies-and-accounts#currency-governance), [GCC Issuance vs Physical Extraction](../economy/04-bonds-and-financing#gcc-mining)

---

## 1. Overview

**GCC mining satellite** is the established proper asset name for a manufactured satellite used in simulated compute-based GCC issuance. This page provides terminology, boundary context, and implementation-alignment notes only.

> **Status label**: This entry documents settled design decisions and verified source-level evidence boundaries. It does not claim that intended policy is currently enforced at runtime.

---

## 2. Terminology

| Term | Required Meaning |
|---|---|
| GCC mining satellite | Established proper asset name for a manufactured satellite used in simulated compute-based GCC issuance |
| GCC mining | LDC-authorized, processing-hardware-driven GCC issuance/settlement activity; not physical extraction, commodity production, or a full proof-of-work gameplay system |

> **"GCC mining satellite"** remains the established asset/lore name.  
> **"GCC mining"** means LDC-authorized, processing-hardware-driven GCC issuance/settlement activity. It is not physical extraction, commodity production, or a full proof-of-work gameplay system.

---

## 3. Craft Classification

GCC mining satellites are **manufactured satellites**, distinct from natural satellites:

| Category | Class Hierarchy | Domain |
|---|---|---|
| Natural satellite | `CelestialBodies::Satellites::Satellite < CelestialBody` | Universe Generation / Planetary Simulation |
| Manufactured satellite (GCC mining) | `Craft::Satellite::BaseSatellite < Craft::BaseCraft` | Transportation / Craft |

> **Shared terminology**: Terms defined in [Craft Taxonomy](./01-craft-taxonomy) apply here without duplication. See that page for full definitions of "craft," "manufactured satellite," and related terms.

---

## 4. GCC Issuance Versus Physical Extraction

| Aspect | GCC Issuance | Physical Extraction |
|---|---|---|
| Output type | Virtual ledger credits (GCC) | Physical materials/cargo |
| Mechanism | LDC-controlled simulated compute mining | Material extraction from celestial bodies |
| Currency creation | Yes (under currency policy) | No — never directly creates GCC |
| Governance | Per-currency policy definition | Resource/blueprint definitions |

---

## 5. Verified Source-Level Evidence

The following are verified source-level implementation facts, not full runtime/gameplay verification:

- `Craft::Satellite::BaseSatellite < Craft::BaseCraft` is a manufactured satellite class.
- The inspected GCC mining path uses computer-unit output and power/thermal/processing effects, plus ledger-account deposits; no physical material output was identified in that path.
- Current mining source paths show inconsistent recipient routing and lack a demonstrated LDC authorization guard.
- Tick, scheduled-job, and mission mining triggers coexist; their timing and settlement semantics remain under alignment.

---

## 6. What Cannot Be Claimed Yet

The following are NOT established as implemented craft behavior by the current evidence:

- Maintenance, repair, and lifecycle decommissioning.
- Satellite-level `*_per_hour` mining-rate fields and configured cap/halving/difficulty/block-reward values as active runtime controls.
- LDC-only runtime enforcement of GCC recipient routing.
- One unified mining cadence across all satellite types.

---

## 7. GCC Issuance Policy (Canonical)

> GCC's canonical policy is LDC-controlled simulated-compute issuance, with newly issued GCC intended for the existing LDC GCC account. Source-level review identified generic mining paths with differing recipient routing and no demonstrated LDC authorization guard. This documentation does not claim that the intended policy is currently enforced.

### Settled Design Decisions

1. GCC issuance uses LDC-controlled simulated compute mining.
2. Compute capacity alone is not GCC mint authority.
3. Initial GCC issuance infrastructure is LDC-operated crypto-mining satellites.
4. Later eligible infrastructure may include explicitly LDC-authorized compute facilities.
5. Newly issued GCC is intended to flow to the existing LDC GCC account.
6. LDC circulates already-issued GCC through explicit transfers, liquidity, contracts, services, rewards, and other authorized disbursements.

---

## 8. Explicit Exclusions

The following are explicitly excluded from this entry:

- All numeric mining-rate, cap, halving, difficulty, block-reward, and daily output claims.
- All unenforced authorization/routing claims (status-labeled only).
- All unsupported lifecycle/player-fitting claims (deferred).
- Full logistics network documentation.
- Player UI for satellite management.
- Mars/future-only material (deferred).

---

## See Also

- [Craft Taxonomy](./01-craft-taxonomy) — Craft classification, entity boundaries, attachment terminology
- [Currency Governance](../economy/02-currencies-and-accounts#currency-governance) — Multi-currency architecture and per-currency policy
- [GCC Issuance vs Physical Extraction](../economy/04-bonds-and-financing#gcc-mining) — GCC mining bond financing

---

## Change History

- **2026-09-15**: Created as limited status-labeled entry per Phase 4 wiki construction (Phase 4).
- **2026-09-15**: Normalized to Economy pattern: numbered filename, numbered major headings (`## N.`), simplified status block with extended implementation-alignment metadata retained for code/design boundary tracking, shared terminology cross-linked to [01-craft-taxonomy](./01-craft-taxonomy) instead of duplicating, relative links updated (Transportation normalization).
