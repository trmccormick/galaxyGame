# Portal Technology — Overview

**Status:** Design documentation — not implemented  
**Purpose:** High-level introduction to portal technology, its role in the game, and system-local scope.  
**Created:** 2026-10-26  
**Source Classification:** Consolidated from established design rules, developer clarifications, and verified proposals.

---

## ⚠️ Disclaimers (Apply to All Portal Documentation)

| Caveat | Impact |
|--------|--------|
| **No implementation exists.** Portal technology has NOT been implemented in the codebase. No wiki pages existed prior to this documentation. No blueprint or JSON is finalized. | Disclaimer in all pages |
| **Phase references are outdated.** Phase placement in older notes reflected a late-game plan (Phase 15+). Do not copy those phase numbers as current requirements. Preplanning and design documentation are not restricted by implementation phase. | Overview page disclaimer |
| **Numerical EM rate discrepancy unresolved.** The Gemini material shows `0.0125 kg/hr` in narrative/operational inputs and `12.5 mg/hr` in the blueprint JSON data — a factor-of-1,000 discrepancy. Do not use either value as approved until reconciled. | Operations page; unresolved questions section |

---

## What Portals Are

Portal technology provides rapid personnel transportation between connected settlements within a star system.

A portal connection consists of **paired endpoints** — two quantum-entangled gate units that link specific locations. Multiple portal connections can be combined into a network, allowing personnel to travel between settlements through designated hubs.

> *"Miniaturized wormhole technology using quantum entanglement to pair two gate endpoints. Low EM consumption. Small aperture — people and small cargo only, not bulk freight."*  
> **Source:** `em_technology_tree.md` § Level 4 (Established)

Portals are a **complement** to conventional transportation infrastructure:

- ✅ Portals do NOT replace cyclers for bulk cargo transport
- ✅ Portals do NOT eliminate the need for local ISRU and resource production
- ✅ Portals provide rapid transit for personnel, high-value low-mass cargo, and emergency response

---

## System-Local Scope

Portal connections operate **within the same star system**.

- A system may develop multiple portal connections linking settlements into a larger network.
- The network can include hubs where travelers transfer between connections.
- "System-local" does NOT mean "Sol-only." Other star systems may independently develop their own system-local portal networks.
- Each system's network develops organically — no mandatory topology is imposed by established rules.

> *"A system may develop multiple portal connections linking settlements into a larger network. The network can include hubs where travelers transfer between connections."*  
> **Source:** `portal-technology-wiki-draft.md` §2.1 (Established)

---

## What Portals Are NOT For

The following are explicitly outside portal scope:

| Category | Transport Method |
|----------|-----------------|
| Bulk ore, fuel, construction materials | Cyclers handle volume freight |
| Large equipment or vehicles | Cyclers / heavy freight infrastructure |
| Anything that needs to move in volume | Cyclers / conventional freight |
| Inter-system travel | Spacecraft + WS/AWS wormhole infrastructure |

> *"What portals are NOT for: Bulk ore, fuel, construction materials — cyclers handle this. Large equipment or vehicles. Anything that needs to move in volume."*  
> **Source:** `em_technology_tree.md` § Level 4 (Established)

---

## Key Constraints (Established Rules)

These constraints come from the older intra-system portal architecture document, which has been verified as existing:

| Constraint | Detail | Source |
|------------|--------|--------|
| **EM operating cost rule** | The EM cost to operate a portal pair must always **exceed** the cost of running a Cycler for bulk goods transport. This ensures portals are reserved for high-priority, low-mass, or time-sensitive cargo and personnel. | `INTRA_SYSTEM_PORTALS.md` § EM Maintenance Cost (Established) |
| **Paired constraint** | Portals must be deployed in pairs. Each portal has a `partner_id` or `destination_portal_id` linking it to its fixed exit. Single, unpaired portals are non-functional and cannot be used for transit. | `INTRA_SYSTEM_PORTALS.md` § Paired Constraint (Established) |
| **Mass limit** | Each portal has a strict maximum mass limit (`PORTAL_MAX_MASS`). Any ship or cargo exceeding this limit cannot transit. | `INTRA_SYSTEM_PORTALS.md` § Mass Limit (Established) |

---

## Technology Placement in the Tech Tree

Per the EM Technology Tree, portal technology sits at **Level 4**:

- **Prerequisite:** Level 3 AWS + miniaturization research
- **Unlocked by:** Peacetime research following Snap crisis resolution
- **Derivative of:** Quantum entanglement (unlike macro-scale natural wormholes or AWS rifts that require planetary-scale mass anchors)

> *"Miniaturized wormhole technology using quantum entanglement to pair two gate endpoints."*  
> **Source:** `em_technology_tree.md` § Level 4 (Established)

---

## Cross-References

| Document | Location | Role |
|----------|----------|------|
| Portal Technology & Operations | [technology-operations](./technology-operations.md) | How portals work — endpoints, networks, EM constraints |
| Transportation Use Cases | [transportation-use-cases](./transportation-use-cases.md) | What portals enable — personnel movement, settlement access |
| Portal & Wormhole Infrastructure Context | [wormhole-context](./wormhole-context.md) | Distinction from WS/AWS, inter-system travel, Level 4b proposal status |

---

## Source Attribution Summary

| Category | Count | Sources Used |
|----------|-------|--------------|
| Established rules | 6 claims | `em_technology_tree.md` §Level 4; `INTRA_SYSTEM_PORTALS.md`; `portal-technology-wiki-draft.md` §§1–2.1 |
| Developer clarifications | 3 notes | Prior synthesis records (attributed) |
| Proposals (unapproved) | See [technology-operations](./technology-operations.md) §5 | `gemini-research-portals.md` |
| Unresolved questions | See [technology-operations](./technology-operations.md) §7 | Per consolidation planning task |
