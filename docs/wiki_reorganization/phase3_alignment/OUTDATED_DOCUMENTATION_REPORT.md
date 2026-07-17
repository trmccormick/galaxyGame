# Phase 3 Documentation Rewrite Report

**Created**: 2026-07-16  
**Purpose**: List docs that no longer reflect current architecture, prioritized by importance.  
**Method**: Docs are ranked by how much they mislead a developer or contributor who reads them as authoritative.

---

## Priority System

| Priority | Meaning | Timeline |
|----------|---------|----------|
| **P1 — Critical** | Doc is fundamentally wrong about system architecture | Rewrite within 1-2 sessions |
| **P2 — Important** | Doc is partially outdated; misses major components | Rewrite within 3-5 sessions |
| **P3 — Moderate** | Doc is mostly correct but missing recent additions | Update incrementally |
| **P4 — Low** | Doc is accurate but could be clearer | Update as time permits |

---

## P1 — Critical Rewrites

### 1. `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md`
- **Current State**: Describes 8 core files as "the architecture." Title: "AI Manager Architecture (89→8 Core)."
- **Reality**: 80+ services exist in `app/services/ai_manager/`. The 8 files are the orchestration layer, not the complete system.
- **Why Critical**: This is the single most misleading document in the repo. A developer reading it would believe the AI Manager has 8 components when it actually has 80+.
- **Scope of Rewrite**:
  - Restructure into "Orchestration Layer" (8 core files) + "Services Inventory" (80+ services)
  - Add service dependency map (see Clarification Report item #10)
  - Document each service's role, inputs, outputs, and dependencies
  - Clarify the relationship between orchestration layer and service layer
- **Canonical intent alignment**: #8 explicitly says AI Manager is expected to grow into many services

---

## P2 — Important Rewrites

### 2. `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md`
- **Current State**: Marked "Draft/Stub" since 2026-04-27. Incomplete chain documentation.
- **Reality**: Manufacturing chain exists (raw → processed → components → blueprints → assembly) but overview doesn't document it.
- **Why Important**: Contributors cannot trace the full manufacturing chain without this doc.
- **Scope of Rewrite**: Complete the overview with service file paths, data flow, and integration points.

### 3. `docs/wiki_reorganization/phase2_alignment/DEVELOPMENT_PHASE_MAPPING.md`
- **Current State**: Maps systems to phases but was created before canonical intent. Contains false blocker references.
- **Reality**: Phase mapping is mostly accurate but some system classifications need updating per canonical intent.
- **Why Important**: Used as a roadmap for development sequencing. False blockers mislead prioritization.
- **Scope of Rewrite**: Update phase mappings to reflect canonical intent resolutions. Remove false blockers from phase dependencies.

### 4. `docs/wiki_reorganization/phase2_alignment/ARCHITECTURE_GAPS_AND_NEXT_STEPS.md`
- **Current State**: Lists gaps including "AI Manager docs outdated" as HIGH impact gap.
- **Reality**: Per canonical intent #8, AI Manager doc staleness is not a gap — it's expected growth.
- **Why Important**: Gap analysis misclassifies documentation issues as architectural gaps.
- **Scope of Rewrite**: Reclassify gaps per canonical intent. Remove false gaps (AI Manager size, template drift). Keep genuine gaps (regression engine, shoreline filter).

---

## P3 — Moderate Updates

### 5. `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md`
- **Current State**: Documents 4-phase exchange evolution but phase transition logic is unclear in code.
- **Reality**: Financial::ExchangeRateService exists but phase triggers may not be implemented.
- **Scope**: Add "Implementation Status" section for each phase. Note which phases are implemented vs planned.

### 6. `docs/architecture/economy/CONTRACTS.md`
- **Current State**: Documents player-first contract priority (24-48h window, 1.5x reward).
- **Reality**: Contract system exists but enforcement flow is unclear.
- **Scope**: Add code paths for player-first enforcement. Note any gaps between design and implementation.

### 7. `docs/architecture/terrasim/OVERVIEW.md`
- **Current State**: Honest about missing regression engine but doesn't cross-reference starsim shoreline issue.
- **Reality**: Regression engine and shoreline filter are related — both address terrain state transitions.
- **Scope**: Add cross-references to starsim docs. Clarify that shoreline filter is a prerequisite for full regression engine.

### 8. `docs/architecture/starsim/OVERVIEW.md`
- **Current State**: Notes Civ4 shoreline flooding as known issue requiring dedicated Regression Filter.
- **Reality**: Issue exists but no implementation path documented.
- **Scope**: Add implementation notes for shoreline filter. Link to terraSim regression engine as dependent system.

### 9. `docs/architecture/units/3d_printed_fabricators.md`
- **Current State**: Documents Mk1→Mk2→Mk3 progression but code enforcement is unclear.
- **Reality**: Fabricator models exist but dependency chain enforcement in code needs verification.
- **Scope**: Add "Code Enforcement" section documenting how Mk dependencies are enforced (or not).

---

## P4 — Low-Priority Improvements

### 10. `docs/architecture/terrain/generation_and_rendering.md`
- **Current State**: Separates terrain generation from biome visualization correctly but integration is undocumented.
- **Scope**: Add integration point documentation.

### 11. `docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md`
- **Current State**: Design principles documented but Earth validation status unclear.
- **Scope**: Add "Validation Status" section noting which biomes have been validated against real data.

### 12. `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md`
- **Current State**: Explicitly states TL-to-MK relationship is an "open question."
- **Scope**: This doc is fine as-is — it's a design intent doc that correctly flags an unresolved decision. No rewrite needed, just note in canonical intent docs that this topic is outside canonical scope.

### 13. `docs/developer/DIGITAL_TWIN_SANDBOX.md`
- **Current State**: Admin feature documentation. Scope unclear.
- **Scope**: Clarify that this is an admin/testing feature, not player-facing gameplay.

---

## Summary

| Priority | Count | Key Documents |
|----------|-------|---------------|
| P1 Critical | 1 | AI Manager architecture (8 vs 80+ services) |
| P2 Important | 3 | Manufacturing overview stub, Phase 2 phase mapping, Phase 2 gaps analysis |
| P3 Moderate | 5 | Economy docs (exchange rates, contracts), terraSim/starsim cross-references, fabricators |
| P4 Low | 4 | Terrain rendering, biome validation, Art Bible, Digital Twin sandbox |

**Total**: 13 documents need rewriting or updating. Only 1 is critical (AI Manager architecture).
