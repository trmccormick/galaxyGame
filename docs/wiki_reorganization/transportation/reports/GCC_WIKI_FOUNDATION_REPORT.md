# GCC Wiki Foundation — Build Craft, Satellite, and Currency Foundation

**Date**: 2026-09-15  
**Session**: wiki_reorganization — Build Craft, Satellite, and Currency Foundation  
**Status**: Complete — human review required before any canonical adoption  

---

## A. Canonical Paths and Authority Check

### Existing Phase 4 Page Ownership

| Phase 4 Document | Location | Relevance to This Session |
|-----------------|----------|--------------------------|
| CANONICAL_DOCUMENT_INDEX.md | `phase4/` | Defines CRAFT as canonical in Section 10 (Transportation) |
| WIKI_SITE_MAP.md | `phase4/` | Maps Transportation section; CRAFT is canonical page |
| CONTRIBUTOR_GUIDE.md | `phase4/` | Governs creation of new wiki pages, naming conventions, status blocks |
| DOCUMENT_CLASSIFICATION.md | `phase4/` | Classifies craft/satellite/rig documents as Canonical/Supporting/Merge/Redirect |
| MISSING_WIKI_PAGES.md | `phase4/` | Identifies CRAFT as a missing P0/P1 canonical page |
| CROSS_REFERENCE_PLAN.md | `phase4/` | Defines cross-section links for Transportation → Economy |
| DOCUMENT_RELOCATION_PLAN.md | `phase4/` | Maps skimmer_craft_intent, rig_system, base_rig_intent to Transportation |

### Pages Created in This Session

| Page | Path | Authority |
|------|------|-----------|
| Craft Taxonomy | `transportation/craft.md` (now `01-craft-taxonomy.md`) | **New canonical** — craft taxonomy, entity boundaries, attachment terminology, natural vs manufactured satellite distinction, GCC mining boundary, currency governance models |
| GCC Mining Satellite | `transportation/gcc_mining_satellite.md` (now `02-gcc-mining-satellite.md`) | **New limited entry** — status-labeled proper asset name entry with implementation-alignment notes |
| Transportation Hub | `transportation/README.md` | **New hub** — documentation map and cross-references for transportation section |

### Pages Revised in This Session

| Page | Path | Authority |
|------|------|-----------|
| Currencies & Accounts | `economy/02-currencies-and-accounts.md` | **Revised** — appended Section 9 (Currency Governance Models) with settled design decisions, multi-currency architecture, GCC issuance vs physical extraction boundary |

### Index/Site-Map Changes Required

The Phase 4 WIKI_SITE_MAP.md and CANONICAL_DOCUMENT_INDEX.md should eventually be updated to reflect the new Transportation section pages. However, per the contributor guide's "Step 5: Update the Canonical Document Index" requirement, this is a future maintenance task that should be done when the wiki_reorganization structure is formally adopted into Phase 4 canonical references.

**Required updates (future):**
- WIKI_SITE_MAP.md Section 10 (Transportation): Add `craft` and `gcc_mining_satellite` entries
- CANONICAL_DOCUMENT_INDEX.md Section 10: Add CRAFT and GCC_MINING_SATELLITE canonical entries
- transportation/README.md as the Transportation section hub

---

## B. File-by-File Change Summary

| Path | Action | Purpose | Claim Categories |
|------|--------|---------|------------------|
| `transportation/craft.md` | Created | Canonical craft taxonomy: entity boundaries (craft vs unit/module/rig/station/structure), natural vs manufactured satellite terminology, GCC mining satellite boundary, currency governance models | Settled design decisions (21 items), verified source-level evidence (8 items), explicit exclusions, terminology convention table |
| `transportation/gcc_mining_satellite.md` | Created | Limited status-labeled entry for GCC mining satellite: terminology, classification, issuance vs extraction boundary, implementation-alignment notes | Settled design decisions (6 items), verified source-level evidence (4 items), what cannot be claimed yet (5 items), explicit exclusions |
| `transportation/README.md` | Created | Transportation documentation hub: maps canonical pages, lists key models/services, cross-references to economy and Phase 4 | Documentation map, model inventory, cross-reference links |
| `economy/02-currencies-and-accounts.md` | Revised (appended) | Added Section 9 — Currency Governance Models: multi-currency principle, GCC/USD/future categories, per-currency policy definition, compute vs mint authority distinction, GCC issuance vs physical extraction table, implementation alignment callout | Settled design decisions (16 items), currency governance models, GCC issuance vs extraction boundary |

---

## C. Terminology and Cross-Reference Matrix

| Term | Canonical Owner Page | Pages That May Only Reference It |
|---|---|---|
| Craft | `transportation/craft.md` (now `01-craft-taxonomy.md`) | All transportation pages; economy pages referencing craft-based mining |
| Natural satellite | `transportation/craft.md` (now `01-craft-taxonomy.md`) | Universe Generation pages; Planetary Simulation pages |
| Manufactured satellite | `transportation/craft.md` (now `01-craft-taxonomy.md`) | Transportation pages; GCC mining satellite entry |
| GCC mining satellite | `transportation/gcc_mining_satellite.md` (now `02-gcc-mining-satellite.md`) | Economy pages (02-currencies-and-accounts, 04-bonds-and-financing); craft taxonomy |
| Unit | `transportation/craft.md` (now `01-craft-taxonomy.md`) | Craft taxonomy only; attachment documentation |
| Module | `transportation/craft.md` (now `01-craft-taxonomy.md`) | Craft taxonomy only; attachment documentation |
| Rig | `transportation/craft.md` (now `01-craft-taxonomy.md`) | Craft taxonomy only; rig-specific future pages |
| Recommended fit | `transportation/craft.md` (now `01-craft-taxonomy.md`) | Craft taxonomy only; GCC mining satellite entry |
| Station | `transportation/craft.md` (now `01-craft-taxonomy.md`) | Settlements pages (SpaceStation is a settlement, not craft) |
| Issuance | `economy/02-currencies-and-accounts.md` (Section 9) | All economy pages; GCC mining satellite entry |
| Extraction (Physical) | `economy/02-currencies-and-accounts.md` (Section 9) | Manufacturing pages; ISRU documentation; GCC mining satellite entry |

---

## D. Implementation-Alignment Register

### Item 1: GCC Recipient Routing

| Aspect | Detail |
|--------|--------|
| **Current source behavior** | Inspected GCC mining paths show inconsistent recipient routing and lack a demonstrated LDC authorization guard |
| **Settled design policy** | Newly issued GCC is intended to flow to the existing LDC GCC account; LDC circulates via explicit transfers, liquidity, contracts, services, rewards, and authorized disbursements |
| **Exact safe wiki wording** | "Source-level review identified generic mining paths with differing recipient routing and no demonstrated LDC authorization guard. This documentation does not claim that the intended policy is currently enforced." |
| **What cannot be claimed yet** | Runtime enforcement of LDC-only GCC recipient routing; unified mining cadence across satellite types |
| **Required future reviewer** | Tracy (source-level verification), Gemini (routing path audit) |

### Item 2: Mining Rate Fields as Runtime Controls

| Aspect | Detail |
|--------|--------|
| **Current source behavior** | Satellite-level `*_per_hour` mining-rate fields and configured cap/halving/difficulty/block-reward values exist in data but no verified active consumer is shown |
| **Settled design policy** | These are data definitions; their runtime consumption must be verified before documentation as controls |
| **Exact safe wiki wording** | "Satellite-level `*_per_hour` mining-rate fields and configured cap/halving/difficulty/block-reward values must not be documented as active runtime controls unless a verified active consumer is shown." |
| **What cannot be claimed yet** | Active consumption of these fields by any mining service or scheduled job |
| **Required future reviewer** | Qwen (scheduled-job alignment), Claude (service-level verification) |

### Item 3: Compute Capacity Versus Mint Authority

| Aspect | Detail |
|--------|--------|
| **Current source behavior** | Craft compute units produce processing effects; mining paths deposit to ledger accounts |
| **Settled design policy** | Compute capacity alone is not GCC mint authority. Eligible infrastructure must be explicitly LDC-authorized. |
| **Exact safe wiki wording** | "Compute capacity alone is not GCC mint authority. Initial GCC issuance infrastructure is LDC-operated crypto-mining satellites. Later eligible infrastructure may include explicitly LDC-authorized compute facilities." |
| **What cannot be claimed yet** | Runtime enforcement of LDC authorization for compute-based GCC issuance |
| **Required future reviewer** | Tracy (authorization guard verification), Gemini (infrastructure eligibility model) |

### Item 4: Mining Trigger Alignment

| Aspect | Detail |
|--------|--------|
| **Current source behavior** | Tick, scheduled-job, and mission mining triggers coexist in the codebase |
| **Settled design policy** | No unified mining cadence is established. Timing and settlement semantics remain under alignment. |
| **Exact safe wiki wording** | "Tick, scheduled-job, and mission mining triggers coexist; their timing and settlement semantics remain under alignment." |
| **What cannot be claimed yet** | One unified mining cadence or recipient route across all satellite types |
| **Required future reviewer** | Qwen (trigger coordination), Claude (settlement semantics) |

### Item 5: GCC Mining Path — No Physical Output

| Aspect | Detail |
|--------|--------|
| **Current source behavior** | Inspected GCC mining path uses computer-unit output and power/thermal/processing effects, plus ledger-account deposits; no physical material output was identified in that path |
| **Settled design policy** | Physical extraction produces material/cargo and never directly creates GCC. GCC issuance is virtual ledger only. |
| **Exact safe wiki wording** | "The inspected GCC mining path uses computer-unit output and power/thermal/processing effects, plus ledger-account deposits; no physical material output was identified in that path." |
| **What cannot be claimed yet** | Full verification across all satellite types and mining configurations |
| **Required future reviewer** | Tracy (comprehensive path audit), Gemini (material output verification) |

---

## E. Explicit Exclusions

### Numeric Mining Claims — EXCLUDED
- All numeric mining-rate, cap, halving, difficulty, block-reward, and daily output claims are excluded from this documentation session.
- The existing economy doc (02-currencies-and-accounts.md) references values like "1,000 GCC/hour" and "250M pre-seeded" — these are NOT re-verified or re-authored in this session.

### Unenforced Authorization/Routing Claims — STATUS-LABELED ONLY
- All claims about LDC-only GCC recipient routing are status-labeled as "not currently enforced."
- No runtime enforcement is claimed for any authorization guard.

### Unsupported Lifecycle/Player-Fitting Claims — DEFERRED
- Maintenance, repair, and lifecycle decommissioning are not established as implemented craft behavior.
- Player fitting architecture is explicitly deferred.
- Do not claim these are currently runtime-enforced unless source evidence proves it.

### Mars/Future-Only Material — EXCLUDED
- All Mars/future-only material is excluded or clearly deferred.
- Future off-Earth currency governance models are listed as categories only, not implemented systems.

### Full System Documentation — OUT OF SCOPE
- Every craft type enumeration: excluded
- Full logistics network documentation: excluded
- Player UI documentation: excluded
- Fusion power taxonomy: excluded
- Full market architecture: excluded
- All Mars/future-only material: deferred

---

## F. Open Questions

### Human Design Decisions Required

1. **GCC Mining Satellite as Proper Asset Name** — Is "GCC mining satellite" the final approved proper asset name, or should it be refined (e.g., "GCC issuance satellite," "compute-mining satellite")? The settled decision preserves the established term but this is a design choice requiring human confirmation.

2. **Future Currency Governance Model Selection** — Which of the deferred governance models (system-managed, corporate, regional, consortium, protocol, permissionless, service/asset-credit) should be prioritized for Phase 1+ documentation? Currently all are listed as categories without priority.

3. **Rig Port/Compatibility Documentation Scope** — Rig-port/compatibility evidence exists only where supported by operational data. Should rig compatibility be documented as a settled design decision or deferred pending source verification?

4. **Station Classification Boundary** — `Settlement::SpaceStation` is classified as a settlement type, not a craft. Is this the final classification, or should there be a hybrid "orbital station" category that bridges Settlement and Transportation domains?

### Implementation Verification/Code-Alignment Questions

5. **Mining Rate Field Consumer** — Which service (if any) consumes satellite-level `*_per_hour` mining-rate fields? No verified active consumer was identified.

6. **LDC Authorization Guard Location** — If an LDC authorization guard exists for GCC issuance, where in the codebase is it implemented? Source-level review found no demonstrated guard.

7. **Mining Trigger Coordination** — How do tick, scheduled-job, and mission mining triggers coordinate to avoid double-counting or conflicting deposits?

8. **`recalculate_stats` vs `mine_gcc` Path Disconnection** — The existing economy doc notes that `recalculate_stats` computes a stored rate but the current `mine_gcc` path independently aggregates fitted computer units. These are two disconnected code paths. Should this be documented as an alignment gap or resolved before canonical adoption?

### Documentation-Structure Questions

9. **Transportation Section Placement** — The Phase 4 site map places CRAFT in Section 10 (Transportation). Is this the correct canonical location, or should craft taxonomy live in Section 5 (Game World Model) as part of the world hierarchy?

10. **GCC Mining Satellite Entry Depth** — Is the current limited-entry approach (terminology + boundary only) sufficient, or should a more detailed entry be created pending source verification?

11. **Currency Governance Page Location** — Section 9 was appended to `economy/02-currencies-and-accounts.md`. Should currency governance have its own canonical page per Phase 4 site map (which lists CURRENCY as a Supporting page in Section 7)?

---

## G. Recommended Next Action

### Immediate: Gemini Alignment Review

The next best action is **Gemini alignment review** of the following items:

1. Verify that `transportation/craft.md` terminology conventions align with Phase 4 DOCUMENT_CLASSIFICATION.md classifications for craft/satellite/rig documents.
2. Confirm that the GCC mining satellite limited-entry approach matches the depth expected by Phase 4 MISSING_WIKI_PAGES.md priorities.
3. Validate that Section 9 additions to `economy/02-currencies-and-accounts.md` are consistent with existing economy documentation authority levels.
