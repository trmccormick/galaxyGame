# Portal Transportation Use Cases

**Status:** Design documentation — not implemented  
**Purpose:** What portals enable — personnel movement, settlement access, tourism, trade coordination, research collaboration, emergency response.  
**Created:** 2026-10-26  

---

## ⚠️ Disclaimers (Apply to This Page)

| Caveat | Impact |
|--------|--------|
| **No implementation exists.** Portal technology has NOT been implemented in the codebase. No wiki pages existed prior to this documentation. No blueprint or JSON is finalized. | Disclaimer in all pages |
| **Phase references are outdated.** Phase placement in older notes reflected a late-game plan (Phase 15+). Do not copy those phase numbers as current requirements. Preplanning and design documentation are not restricted by implementation phase. | Overview page disclaimer |

---

## Primary Use Case: Rapid Personnel Movement

Portals primarily provide rapid personnel movement and settlement access within a star system.

> *"Portal technology provides rapid personnel transportation between connected settlements within a star system."*  
> **Source:** `portal-technology-wiki-draft.md` §1 (Established)

### Key Design Points

| Point | Detail | Source |
|-------|--------|--------|
| **Instant transit** | Once both endpoints are placed and activated, transit is instant. No ship travel time required. | `em_technology_tree.md` § Level 4 (Established) |
| **Small aperture** | Only people and small cargo can transit — not bulk freight or large equipment. | `em_technology_tree.md` § Level 4 (Established) |
| **Paired endpoints required** | Both endpoints must be deployed and linked; single portals are non-functional. | `INTRA_SYSTEM_PORTALS.md` § Paired Constraint (Established) |
| **Mass limit enforced** | Any cargo exceeding `PORTAL_MAX_MASS` cannot transit. | `INTRA_SYSTEM_PORTALS.md` § Mass Limit (Established) |

---

## Documented Player Use Cases

The primary source clearly supports these use cases:

| Use Case | Description | Source |
|----------|-------------|--------|
| **Visiting multiple settlements** | Rapid transit between connected settlements for players who want to participate in multiple locations. | `portal-technology-wiki-draft.md` §5 (Established) |
| **Tourism and exploration** | Tourism within the portal network as a valid player activity. | `portal-technology-wiki-draft.md` §5 (Established) |
| **Trade coordination** | Coordinating trade across settlements requires rapid transit between nodes; portals enable this but do not replace bulk freight infrastructure. | `portal-technology-wiki-draft.md` §5 (Established) |
| **Research collaboration** | Researchers and specialists can travel rapidly to partner settlements. | `portal-technology-wiki-draft.md` §5 (Established) |
| **Emergency response** | Emergency evacuation routes and rapid deployment of critical personnel/resources. | `portal-technology-wiki-draft.md` §5 + `em_technology_tree.md` § Level 4 Gameplay Unlocks (Established) |

### Strategic Value (from em_technology_tree.md)

| Strategic Benefit | Detail | Source |
|-------------------|--------|--------|
| **Instant player movement** across known space within a system | Replaces shuttle runs for personnel and small cargo. First placement at a new outpost requires physical delivery mission, but subsequent transit is instant. | `em_technology_tree.md` § Level 4 (Established) |
| **Personnel rapid deployment for AI Manager** | AI Manager can leverage portal networks for NPC behavior coordination and multi-system operations. | `em_technology_tree.md` § Level 4 Gameplay Unlocks (Established) |
| **High-value low-mass cargo instant delivery** | Medicine, electronics, and other high-value small items delivered instantly via portal. | `em_technology_tree.md` § Level 4 Gameplay Unlocks (Established) |

---

## What Portals Do NOT Replace

### Cyclers Continue Bulk Freight Role

> *"Cyclers and other freight infrastructure continue to transport bulk cargo, resources, equipment, and terraforming supplies."*  
> **Source:** `portal-technology-wiki-draft.md` §5 (Established)

| Transport Type | Correct Method | Source |
|----------------|---------------|--------|
| Bulk ore, fuel, construction materials | Cyclers handle this | `em_technology_tree.md` § Level 4 (Established) |
| Large equipment or vehicles | Cyclers / heavy freight infrastructure | `em_technology_tree.md` § Level 4 (Established) |
| Anything that needs to move in volume | Cyclers / conventional freight | `em_technology_tree.md` § Level 4 (Established) |

> *"Portal technology does not eliminate distance-based bulk transportation economics or the need for local resource production and infrastructure. Settlements still require local ISRU and resource networks."*  
> **Source:** `portal-technology-wiki-draft.md` §5 (Established)

---

## Proposals Not Approved (Gemini Brainstorming Material)

The following additional use cases appear in Gemini brainstorming material (`gemini-research-portals.md`) and are **Proposed, not approved**. They have NOT been validated or established by developer decision.

| Claim | Detail | Source Section | Status |
|-------|--------|---------------|--------|
| Data transport via portals | "max_throughput_mass_kg_hr = 5000" — Gemini proposed data transport categories beyond personnel | `gemini-research-portals.md` operational_data_reference (proposed) | **"Proposed, not approved"** |
| High-value small cargo classification | Specific throughput values and cargo categories from Gemini blueprint JSON | `gemini-research-portals.md` §1 scope restriction + blueprint spec (proposed) | **"Proposed, not approved"** |

> **No claim appears in the matrix without a source citation.** These proposals cannot be treated as established rules.

---

## Network Topology: Emergent Design

Network expansion is constrained by available EM, not by mandatory hub assignments or fixed topologies:

> *"The supplied primary-source summary says any major settlement can become a hub if its EM budget permits."*  
> **Source:** `portal-technology-wiki-draft.md` §4 (Established)

> *"Do not impose a fixed hub list or hard link cap unless a stronger source establishes it."*  
> **Source:** `portal-technology-wiki-draft.md` §4 (Established)

**No mandatory named hub topology exists.** The Earth/L1 → Mercury → Mars → Ceres → Jupiter → Saturn → Pluto chain is an illustrative example only. Individual player factions may develop their own network topologies based on available EM budgets and settlement distribution.

---

## Unresolved Questions

| ID | Question | Severity | Status | Source |
|----|----------|----------|--------|--------|
| Q8 | Numerical network capacity limits and per-hub hardware constraints? | Medium | Deferred; no mandatory topology imposed | Consolidation planning task Q8 |
| D5 | Endpoint destruction, repair, replacement, and re-pairing procedures? | Low | Deferred | Consolidation planning task Q7 |

---

## Cross-References

| Document | Location | Role |
|----------|----------|------|
| Portal Overview | [overview](./overview.md) | High-level purpose, system-local scope, portal/cycler boundary |
| Portal Technology & Operations | [technology-operations](./technology-operations.md) | How portals work — constraints and capabilities |
| Portal & Wormhole Infrastructure Context | [wormhole-context](./wormhole-context.md) | Inter-system travel context for portal-based settlement access |

---

## Source Attribution Summary

| Category | Count | Sources Used |
|----------|-------|--------------|
| Established use cases | 5 uses + strategic benefits | `portal-technology-wiki-draft.md` §5; `em_technology_tree.md` § Level 4 Gameplay Unlocks |
| Established constraints | Portal/cycler/bulk freight boundaries | `INTRA_SYSTEM_PORTALS.md`; `portal-technology-wiki-draft.md` §5 |
| Proposals (unapproved) | 2 additional use cases | `gemini-research-portals.md` operational_data_reference, blueprint spec |
| Unresolved questions | 2 gaps | Consolidation planning task Q8; D5 |
