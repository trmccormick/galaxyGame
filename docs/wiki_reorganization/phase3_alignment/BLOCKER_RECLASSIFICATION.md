# Phase 3 Blocker Review — Canonical Intent Alignment

**Created**: 2026-07-16  
**Purpose**: Review all blockers from Phases 1–2 against the 12 canonical design intent statements. Reclassify each blocker per its true category.  
**Authority**: The 12 canonical design intent statements are authoritative. If documentation disagrees with canonical intent, report the documentation issue — not a design problem.

---

## Classification System (per Phase 3 rules)

| Category | Meaning | Action Required |
|----------|---------|-----------------|
| **A — CANONICAL CONFIRMED** | Documentation aligns with intent; no action needed | None |
| **B — CLARIFICATION NEEDED** | Minor terminology or cross-reference issue | Low-priority doc cleanup |
| **C — DOCUMENTATION REWRITE** | Doc no longer reflects current architecture | Medium-priority rewrite |
| **D — GENUINE DESIGN DECISION** | True unresolved game design question | Requires human decision |
| **E — FALSE BLOCKER** | Was flagged as blocker but canonical intent resolves it | Remove from backlog; mark done |

---

## Blocker Review Results

### Blocker 1: "AI Manager docs outdated (8 core files vs 80+ services)"

- **Phase 2 Classification**: P0 Foundation Blocker
- **Canonical Intent #8**: "AI Manager expected to grow into many services; 'more services than documented' is NOT a blocker"
- **Evidence**: `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` describes 8 core files. `app/services/ai_manager/` has 80+ files. The architecture doc itself is titled "AI Manager Architecture (89→8 Core)" suggesting it was written as a target state, not current state.
- **Reclassification**: **E — FALSE BLOCKER** (the blocker claim is resolved by canonical intent) + **C — DOCUMENTATION REWRITE** (the doc needs updating)
- **Resolution**: Remove from P0 backlog. Add to "docs to rewrite" list as medium priority. The architecture doc should be updated to reflect the 80+ service reality, but this does not block development.

---

### Blocker 2: "Template version drift (v1-v7 across blueprint types)"

- **Phase 2 Classification**: P0 Foundation Blocker
- **Canonical Intent #6**: "Templates = design documents (not runtime assets); version drift is documentation housekeeping"
- **Evidence**: `data/json-data/templates/` contains component_blueprint v1.1-v1.4, craft_blueprint v1.1-v1.7, unit_blueprint v1.1-v1.4. These are JSON schema versions for design documents, not runtime-loaded classes.
- **Reclassification**: **E — FALSE BLOCKER** (canonical intent explicitly says this is documentation housekeeping, not a blocker) + **B — CLARIFICATION NEEDED** (consolidate to single canonical version as maintenance task)
- **Resolution**: Remove from P0 backlog. Consolidate to single schema version as low-priority maintenance. Not blocking any gameplay system.

---

### Blocker 3: "OrbitalDepot dual namespace"

- **Phase 2 Classification**: P0 Foundation Blocker
- **Canonical Intent #4**: "Orbital settlements manage constellations of structures; multiple Ruby models not automatically a conflict"
- **Evidence**: 
  - `app/models/orbital_depot.rb` — RETIRED (marked "RETIRED 2026-04-10 — legacy PORO replaced by Settlement::OrbitalSettlement. Kept for git history only.")
  - `app/models/settlement/orbital_depot.rb` — Active, inherits from BaseSettlement
- **Reclassification**: **E — FALSE BLOCKER** (the root-level file is explicitly retired; no actual dual namespace exists in active code)
- **Resolution**: Remove from P0 backlog. Consider removing the retired file during cleanup, but it's not a blocker.

---

### Blocker 4: "Colony vs Settlement relationship unclear"

- **Phase 2 Classification**: P0 Foundation Blocker
- **Canonical Intent #1**: "Colony = government entity of 2+ settlements (above Settlement in hierarchy)"
- **Canonical Intent #2**: "Settlements = administrative population centers that own/manage structures"
- **Evidence**: 
  - `app/models/colony.rb` line 6: `has_many :settlements, class_name: 'Settlement::BaseSettlement'` — Colony contains settlements
  - `app/models/colony.rb` has validation: `validate :must_have_multiple_settlements`
  - `app/models/settlement/base_settlement.rb` includes `SettlementCore` concern with `belongs_to :colony`
  - Code **already implements** the canonical intent correctly
- **Reclassification**: **E — FALSE BLOCKER** (code already matches canonical intent; the "blocker" was a documentation gap, not a design problem)
- **Resolution**: Remove from P0 backlog. The code is correct. Documentation should be updated to reflect Colony → Settlement hierarchy clearly.

---

### Blocker 5: "TL-to-MK relationship unresolved"

- **Phase 2 Classification**: P0 Foundation Blocker
- **Canonical Intent**: No explicit canonical statement addresses TL-to-MK relationship
- **Evidence**: `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` explicitly states this is an "open question." The 2026-07-15 analysis session suggests they are related but distinct (two-dimensional system: Tech Level × MK).
- **Reclassification**: **D — GENUINE DESIGN DECISION** (no canonical intent resolves this; it's a true unresolved game design question)
- **Resolution**: Keep as genuine design decision. This is the PRIMARY candidate for remaining genuine decisions list.

---

### Blocker 6: "Verify Job system code matches authoritative spec"

- **Phase 2 Classification**: P0 Foundation Blocker
- **Canonical Intent**: No explicit canonical statement; this is a code-vs-spec verification task
- **Evidence**: `docs/architecture/systems/job_system_mechanics_spec.md` marked as "source of truth." Spec exists and is authoritative.
- **Reclassification**: **B — CLARIFICATION NEEDED** (verify spec vs code alignment, update code if it diverges)
- **Resolution**: Low-priority verification task. Not a design blocker — just ensure code matches the spec.

---

### Blocker 7: "Implement Cryosphere simulation service"

- **Phase 2 Classification**: P1 Foundation Blocker
- **Canonical Intent**: No explicit canonical statement; sphere model completeness is implied by SimEarth inspiration
- **Evidence**: `app/models/celestial_bodies/spheres/cryosphere.rb` model exists but no corresponding simulation service in `app/services/terra_sim/`.
- **Reclassification**: **B — CLARIFICATION NEEDED** (model exists, service gap needs filling)
- **Resolution**: Implementation task for Phase 3+ when cryosphere-relevant gameplay is prioritized. Not a P0/P1 blocker.

---

## Summary of Reclassifications

| Original Blocker | Old Priority | New Category | New Priority | Action |
|-----------------|-------------|-------------|-------------|--------|
| AI Manager docs outdated | P0 | E + C | Low (doc rewrite) | Remove from blocker list; add to doc rewrite queue |
| Template version drift | P0 | E + B | Low (maintenance) | Remove from blocker list; consolidate as cleanup |
| OrbitalDepot dual namespace | P0 | E | None | Remove — root file is retired, no conflict |
| Colony vs Settlement | P0 | E | None | Remove — code already correct per canonical intent |
| TL-to-MK relationship | P0 | D | Design decision | Keep as genuine unresolved design question |
| Job system spec alignment | P0 | B | Low (verification) | Verify and update if needed |
| Cryosphere simulation service | P1 | B | Phase 3+ | Implementation task, not blocker |

**Result**: 4 of 7 original "P0 blockers" are false blockers resolved by canonical intent. Only 1 is a genuine design decision (TL-to-MK). The remaining 2 are low-priority verification/maintenance tasks.

---

## Remaining Genuine Design Decisions

Only **one** true unresolved game design decision remains:

### TL-to-MK Relationship
- **Question**: Is blueprint MK generation independent of Technology Level (two orthogonal axes), or derived from it?
- **Current State**: Art Bible explicitly states "open question." Analysis session suggests two-dimensional system (Tech Level × MK) but this is not codified.
- **Impact**: Affects data model design and visual asset generation for blueprints.
- **Recommendation**: Adopt the two-axis interpretation from the analysis session unless project owner specifies otherwise.
