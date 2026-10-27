# Portal Technology & Operations

**Status:** Design documentation — not implemented  
**Purpose:** How portals work — paired endpoints, deployment model, networks, EM constraints.  
**Created:** 2026-10-26  

---

## ⚠️ Disclaimers (Apply to This Page)

| Caveat | Impact |
|--------|--------|
| **No implementation exists.** Portal technology has NOT been implemented in the codebase. No wiki pages existed prior to this documentation. No blueprint or JSON is finalized. | Disclaimer in all pages |
| **Phase references are outdated.** Phase placement in older notes reflected a late-game plan (Phase 15+). Do not copy those phase numbers as current requirements. Preplanning and design documentation are not restricted by implementation phase. | Overview page disclaimer |
| **Numerical EM rate discrepancy unresolved.** The Gemini material shows `0.0125 kg/hr` in narrative/operational inputs and `12.5 mg/hr` in the blueprint JSON data — a factor-of-1,000 discrepancy. Do not use either value as approved until reconciled. | Operations page; unresolved questions section |

---

## Paired Endpoints

Portal connections use matching quantum-entangled endpoints.

### Core Rules (Established)

| Rule | Detail | Source |
|------|--------|--------|
| **Paired deployment** | Portals must be deployed in pairs. Each portal has a `partner_id` or `destination_portal_id` linking it to its fixed exit. | `INTRA_SYSTEM_PORTALS.md` § Paired Constraint (Established) |
| **Unpaired portals are non-functional** | Single, unpaired portals cannot be used for transit. | `INTRA_SYSTEM_PORTALS.md` § Paired Constraint (Established) |
| **Mass limit enforcement** | Each portal has a strict maximum mass limit (`PORTAL_MAX_MASS`). Any ship or cargo exceeding this limit cannot transit. | `INTRA_SYSTEM_PORTALS.md` § Mass Limit (Established) |
| **EM operating cost > Cycler cost** | The EM cost to operate a portal pair for a given mass must always **exceed** the cost of running a Cycler for bulk goods transport. This ensures portals are reserved for high-priority, low-mass, or time-sensitive cargo and personnel. | `INTRA_SYSTEM_PORTALS.md` § EM Maintenance Cost (Established) |

### Deployment Model (Established)

The current deployment concept follows this 5-step sequence:

1. Construct the paired endpoints
2. Transport the endpoints to their intended locations
3. Deploy the endpoints at those locations
4. Establish the portal connection
5. Make the connection available for transportation

> *"Gates are manufactured as entangled pairs. One gate physically transported to destination (deployment mission). Once both gates are placed, transit is instant and cheap to operate."*  
> **Source:** `em_technology_tree.md` § Level 4 (Established)

---

## Deployment: Unresolved Questions

The exact transportation arrangement remains unresolved. The following are known open questions:

| ID | Question | Severity | Status | Source |
|----|----------|----------|--------|--------|
| D1 | Do both endpoints travel together on one mission or on separate missions? | High | Deferred | `portal-technology-wiki-draft.md` §3 |
| D2 | Does deployment activate the link automatically, or does it require another operation? | Medium | Deferred | `portal-technology-wiki-draft.md` §3 |
| D3 | Can an endpoint be installed at an existing station while the other is delivered to a new settlement? | Medium | Deferred | `portal-technology-wiki-draft.md` §3 |
| D4 | Exact endpoint transportation and installation procedure? | High | Deferred | Consolidation planning task Q1 |
| D5 | Endpoint destruction, repair, replacement, and re-pairing procedures? | Low | Deferred | Consolidation planning task Q7 |
| D6 | Whether proposed safety and mounting practices are mandatory or recommended? | Low | Deferred | Consolidation planning task Q10 |

> **Do not assume that one endpoint automatically appears at the destination. Do not turn the likely transport of both endpoints into a more detailed confirmed procedure without source evidence.**  
> **Source:** `portal-technology-wiki-draft.md` §3

---

## Developer-Attributed Clarifications (Unverified by Primary Source)

The prior synthesis records the following from developer input, but these are attributed notes rather than independently verified primary-source rules:

| Clarification | Attribution | Verification Status |
|---------------|-------------|---------------------|
| Portals are generally built together as a pair | Prior synthesis records developer wording | Attributed; not reproduced verbatim from source |
| Either endpoint can initiate operation | Prior synthesis records developer clarification | Attributed; not independently verified |
| Portal operation requires electrical power as well as EM | Prior synthesis records developer clarification | Attributed; exact relationship to EM consumption not proven by primary source |
| **Ownership and access rules are only partially clarified** | Developer clarified partially in prior synthesis; full ownership and access control rules remain undefined | **Unresolved** — partial developer clarification only; complete rules deferred |

> **Caveat 7 (ownership/access):** The consolidated draft (§10, Item 7) records that "Developer clarified partially; full ownership and access rules undefined." This caveat is preserved here. Do not invent ownership, permissions, access-control, or governance mechanics.

---

## Networks and Hubs

### Hub Concept (Established)

Any major settlement can become a hub if its EM budget permits. The network is defined organically — no mandatory topology or fixed hub list exists.

> *"Each portal pair provides a specific connection. A hub can contain multiple portal connections. Travelers may arrive through one connection and transfer to another to reach a different settlement."*  
> **Source:** `portal-technology-wiki-draft.md` §4 (Established)

The previously documented Earth/L1, Mercury, Mars, Ceres, Jupiter, Saturn, Pluto arrangement is an **example** of a possible network. It is NOT established as mandatory topology. Do not impose a fixed hub list or hard link cap unless a stronger source establishes it.

> *"Do not impose a fixed hub list or hard link cap unless a stronger source establishes it."*  
> **Source:** `portal-technology-wiki-draft.md` §4 (Established)

### Network Constraints

| Constraint | Detail | Source |
|------------|--------|--------|
| **EM limits concurrent operations** | Operating portal pairs continuously consume EM. Portal operation and wormhole stabilization compete for the available EM supply. EM availability limits how many portal pairs can operate simultaneously. | `portal-technology-wiki-draft.md` §6 (Established) |
| **No mandatory topology imposed** | The supplied primary source establishes an EM-limited network, not a hard link cap or fixed hub count. Consolidation planning task Q8 notes: "Numerical network capacity limits and per-hub hardware constraints" are unresolved. | `portal-technology-wiki-draft.md` §4; consolidation planning task |

---

## Energy Requirements

### EM Consumption (Established)

Portal pairs use Exotic Matter harvested from natural wormholes. Portal operation and wormhole stabilization compete for the available EM supply.

| Constraint | Detail | Source |
|------------|--------|--------|
| **EM operating cost rule** | The EM cost to operate a portal pair must always exceed the cost of running a Cycler for bulk goods transport. This ensures portals are reserved for high-priority, low-mass, or time-sensitive cargo and personnel. | `INTRA_SYSTEM_PORTALS.md` § EM Maintenance Cost (Established) |

### Electrical Power (Developer Clarification — Unverified)

Developer-attributed: Portals require electrical power as well as EM. Exact relationship to EM consumption is not proven by the primary source available here. Preserve this distinction until the original note is recovered.

---

## Proposals Not Approved (Gemini Brainstorming Material)

The following values and requirements appear in Gemini brainstorming material (`gemini-research-portals.md`) and are **Proposed, not approved**. They have NOT been validated against repository schemas or established by developer decision.

| Claim | Detail | Source Section | Notes |
|-------|--------|---------------|-------|
| EM consumption rate: 0.0125 kg/hr | Intra-system Mk I gate operational input | `gemini-research-portals.md` input_resources (proposed value) | **"Proposed, not approved"** — inconsistent with 12.5 mg/hr in same document's blueprint data; unresolved discrepancy |
| EM consumption rate: 12.5 mg/hr | Blueprint JSON operational_data_reference (`portal_gate_mk1_ops.json`) | `gemini-research-portals.md` blueprint spec (proposed value) | **"Proposed, not approved"** — factor-of-1,000 difference from the 0.0125 kg/hr figure above; unresolved discrepancy |
| Electrical power: 1,200 kW operational power | Operational processing capabilities reference | `gemini-research-portals.md` processing_capabilities (proposed value) | **"Proposed, not approved"** — Gemini brainstorming only |
| Throughput capacity: 5,000 kg/hr max mass | Max throughput claim in blueprint data | `gemini-research-portals.md` operational_data_reference (proposed value) | **"Proposed, not approved"** — sample schema not validated against repository schemas |
| **Three-Link structural constraint** | Gemini mentions this as a solar system constraint model | `gemini-research-portals.md` §1 scope restriction (proposed) | **"Proposed, not approved"** — primary source establishes EM-limited network, NOT a hard link cap |
| Hull class minimums / mounting requirements | Portals cannot be mounted to arbitrary lightweight hulls; requires capital-class vessels | `gemini-research-portals.md` §2 (proposed) | **"Proposed, not approved"** — Gemini brainstorming only |
| Specific airlock vestibule and pressure isolation requirements | Bulkhead-isolated airlock vestibule, emergency bulkheads, gas recovery ports | `gemini-research-portals.md` blueprint spec (proposed) | **"Proposed, not approved"** — detailed engineering requirements from brainstorming only |

> **Critical note on EM rates:** The Gemini material shows two different EM consumption values: `0.0125 kg/hr` (narrative/operational inputs) and `12.5 mg/hr` (blueprint JSON data). This is a factor-of-1,000 discrepancy. Do not use either value as approved until reconciled.

---

## Unresolved Questions

| ID | Question | Severity | Status | Source |
|----|----------|----------|--------|--------|
| Q4 | Exact EM consumption and electrical power requirements? | High | Deferred; EM rate inconsistency noted above | Consolidation planning task Q4 |
| Q5 | Idle, standby, closure, and shutdown behavior models? | Medium | Deferred | `portal-technology-wiki-draft.md` §9 |
| Q6 | Complete ownership and access control rules? | Medium | Partial developer clarification; full rules deferred | `portal-technology-wiki-draft.md` §8.2; consolidated draft §10 Item 7 |
| Q8 | Numerical network capacity limits and per-hub hardware constraints? | Medium | Deferred; no mandatory topology imposed | Consolidation planning task Q8 |

---

## Cross-References

| Document | Location | Role |
|----------|----------|------|
| Portal Overview | [overview](./overview.md) | High-level purpose, system-local scope |
| Transportation Use Cases | [transportation-use-cases](./transportation-use-cases.md) | What portals enable — use cases for this technology |
| Portal & Wormhole Infrastructure Context | [wormhole-context](./wormhole-context.md) | System-level context; distinction from WS/AWS |

---

## Source Attribution Summary

| Category | Count | Sources Used |
|----------|-------|--------------|
| Established rules | 4 claims | `INTRA_SYSTEM_PORTALS.md` §§EM Cost, Mass Limit, Paired Constraint; `portal-technology-wiki-draft.md` §§3–4 |
| Developer clarifications | 4 notes (including partial ownership/access) | Prior synthesis records (attributed) |
| Proposals (unapproved) | 6 claims | `gemini-research-portals.md` (§1 scope restriction, §2 structural constraints, blueprint spec, operational data) |
| Unresolved questions | 6 known gaps (including Q6 ownership/access) | `portal-technology-wiki-draft.md` §3; consolidation planning task Q4/Q5/Q6/Q8 |
