# Portal & Wormhole Infrastructure Context

**Status:** Design documentation — not implemented  
**Purpose:** System-level context — distinction from WS/AWS, inter-system travel, Level 4b proposal status.  
**Created:** 2026-10-26  

---

## ⚠️ Disclaimers (Apply to This Page)

| Caveat | Impact |
|--------|--------|
| **No implementation exists.** Portal technology has NOT been implemented in the codebase. No wiki pages existed prior to this documentation. No blueprint or JSON is finalized. | Disclaimer in all pages |
| **Phase references are outdated.** Phase placement in older notes reflected a late-game plan (Phase 15+). Do not copy those phase numbers as current requirements. Preplanning and design documentation are not restricted by implementation phase. | Overview page disclaimer |
| **Level 4b gates are a Gemini proposal only, not approved design.** The boundary between intra-system portals (Level 4a) and inter-system portal travel is unresolved. Do NOT treat Level 4b as an established capability. | All pages; this section |

---

## Portal Networks vs. Wormhole Transportation: Different Roles

Portal networks and wormhole transportation serve fundamentally different roles in the established design:

| Aspect | Portals (Level 4a) | Wormhole Infrastructure |
|--------|---------------------|------------------------|
| **Scope** | Intra-system only — within a single star system | Inter-system — between star systems |
| **Infrastructure** | Paired quantum-entangled endpoints at settlements | Natural Wormhole Stations (WS) + Artificial Wormhole Stations (AWS) |
| **Transport method** | Instant transit between connected endpoints | Spacecraft travel through WS/AWS wormhole gates |
| **Capacity** | Personnel and small cargo only (small aperture) | Variable — cyclers handle bulk freight; craft handles passengers |

> *"Portal networks and wormhole transportation therefore serve different roles in the established design."*  
> **Source:** `portal-technology-wiki-draft.md` §7 (Established)

---

## Wormhole Stations (WS) and Artificial Wormhole Stations (AWS)

### Wormhole Stations (WS)

WS provide access to natural wormhole transportation.

| Detail | Information |
|--------|-------------|
| **Purpose** | Provide access to existing natural wormholes between star systems |
| **Nature** | Natural wormhole infrastructure — does not create or maintain the wormhole |
| **Inter-system role** | The established gateway for inter-system travel before AWS exists |

### Artificial Wormhole Stations (AWS)

AWS provide artificial wormhole infrastructure.

| Detail | Information |
|--------|-------------|
| **Purpose** | Create and maintain artificial wormholes between star systems |
| **Nature** | Constructed infrastructure — generates the wormhole connection |
| **Inter-system role** | Enables new inter-system connections that do not exist naturally |

### Inter-System Travel Model (Established)

The established model for inter-system travel uses this layered approach:

```
1. Depart origin system via local portal network → WS/AWS hub
2. Board spacecraft at AWS/Wormhole Station
3. Transit through wormhole infrastructure to destination system
4. Arrive at destination system — access local portal network (if one exists)
```

> *"The existing transportation model uses spacecraft to travel between star systems through wormhole infrastructure. Local portal networks can provide rapid transportation within a destination system."*  
> **Source:** `portal-technology-wiki-draft.md` §7 (Established)

---

## Level 4a vs. Level 4b: The Boundary Question

### Level 4a — Intra-System Portals (Established)

Level 4a is the current established scope for portal technology:

| Detail | Information |
|--------|-------------|
| **Scope** | Instant transit between bases within the same solar system |
| **Purpose** | Replaces shuttle runs for personnel and small cargo within a system |
| **Placement** | First placement at a new outpost requires physical delivery mission; subsequent transit is instant |

> *"Level 4a — Intra-system portals: Instant transit between bases within the same solar system. Replaces shuttle runs for personnel and small cargo."*  
> **Source:** `em_technology_tree.md` § Level 4a (Established)

### Level 4b — Inter-System Portal Hubs (Proposed, Not Approved) ⚠️

Level 4b is a **proposal** from Gemini brainstorming material. It has NOT been approved as an established design rule.

> *"Inter-system portal gates installed at AWS stations enable player jump travel across the wormhole network — EVE Online style gate travel."*  
> **Source:** `gemini-research-portals.md` §1 (Proposed, not approved)

| Aspect | Level 4a (Established) | Level 4b (Proposal Only) ⚠️ |
|--------|------------------------|----------------------------|
| **Scope** | Intra-system only | Inter-system hub-to-hub at AWS stations |
| **Status** | Approved design rule | Gemini brainstorming — NOT approved |
| **Travel pattern** | Portal jump between settlements within one system | Portal jump → AWS Station A → local shuttle → next AWS → portal jump → AWS Station B → portal jump to destination base |
| **Boundary impact** | Clear boundary: portals = intra-system, spacecraft/wormholes = inter-system | Proposes erasing this boundary — potentially changes the earlier boundary between system-local portals and craft-based wormhole travel |

> **Critical:** *"Gemini proposed a later inter-system portal-gate capability at AWS stations (sometimes described as Level 4b). This proposal potentially changes the earlier boundary between system-local portals and craft-based wormhole travel. It is not treated here as an approved rule."*  
> **Source:** `portal-technology-wiki-draft.md` §2.2 (Proposal notation)

### Level 4b Travel Pattern (Proposed, Not Approved) ⚠️

The following travel pattern comes from Gemini brainstorming and is NOT established:

```
Player travel pattern:
  Portal jump → AWS Station A
  Grab local shuttle to next AWS
  Portal jump → AWS Station B
  Portal jump to destination base within system
```

> **This cannot be treated as an approved or verified gameplay mechanic.**

---

## Strategic Implications of Level 4b (If Approved — Speculative)

The following implications are noted from the `em_technology_tree.md` section on Level 4b but should be read as part of the established Level 4 description, not as additional proof that Level 4b is approved:

| Strategic Effect | Detail | Source |
|-----------------|--------|--------|
| **First-mover advantage** | First player to place a portal gate at a new outpost controls instant access to that location | `em_technology_tree.md` § Level 4 (Established context) |
| **AWS doubly valuable** | AWS stations become both wormhole anchors AND portal hubs | `em_technology_tree.md` § Level 4 (Established context) |

> **Note:** These implications are documented in the tech tree's Level 4 section, which describes the potential strategic landscape if portals expand to inter-system use. They do not constitute approval of the expansion itself.

---

## Unresolved Questions

| ID | Question | Severity | Status | Source |
|----|----------|----------|--------|--------|
| Q9 | Will inter-system Level 4b gates be introduced at AWS stations? | High | Deferred; Gemini proposal only, not approved | Consolidation planning task Q9; `portal-technology-wiki-draft.md` §8.2 |
| D2 | Does deployment activate the link automatically, or does it require another operation? | Medium | Deferred | `portal-technology-wiki-draft.md` §3 |

### The Level 4a/4b Boundary (Unresolved)

The consolidation planning task notes:

> *"Boundary between system-local portals and inter-system travel is unresolved; Gemini proposal potentially changes earlier boundary."*  
> **Source:** `portal-technology-wiki-draft.md` §2.2 + §8.2

**This boundary question requires a developer decision.** Until such a decision is made:
- Portals are **intra-system only** (Level 4a)
- Level 4b cannot be treated as an approved or established capability
- Inter-system travel continues to use spacecraft + WS/AWS infrastructure exclusively

---

## Terminology Note

> *"Prior synthesis recommended replacing 'wormhole portal' with 'wormhole link'; terminology decision not confirmed as authoritative."*  
> **Source:** Consolidated draft §10

This documentation uses "portal" consistently (matching the task file naming and established usage). The proposed terminology change is noted but not applied, as it has not been confirmed by a developer decision.

---

## Cross-References

| Document | Location | Role |
|----------|----------|------|
| Portal Overview | [overview](./overview.md) | High-level purpose; portal/cycler/wormhole boundaries |
| Portal Technology & Operations | [technology-operations](./technology-operations.md) | Technical details of Level 4a; proposals flagged |
| Transportation Use Cases | [transportation-use-cases](./transportation-use-cases.md) | What portals enable within this system context |

---

## Source Attribution Summary

| Category | Count | Sources Used |
|----------|-------|--------------|
| Established rules | WS/AWS roles; inter-system travel model via spacecraft | `portal-technology-wiki-draft.md` §§2.2, 7 (Established) |
| Level 4a scope | Intra-system portals confirmed in tech tree | `em_technology_tree.md` § Level 4a (Established) |
| Proposals (unapproved) | Level 4b; gate travel pattern; AWS dual-role strategic value | `gemini-research-portals.md` (§1); `em_technology_tree.md` § Level 4 context |
| Unresolved questions | Boundary question + deployment activation | `portal-technology-wiki-draft.md` §§2.2, 8.2; consolidation planning task Q9 |
