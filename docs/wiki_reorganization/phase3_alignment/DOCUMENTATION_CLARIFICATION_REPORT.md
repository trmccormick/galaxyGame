# Phase 3 Documentation Clarification Report

**Created**: 2026-07-16  
**Purpose**: List docs needing terminology cleanup, cross-references, or diagrams to align with canonical intent and current architecture.  
**Priority**: Low — these are housekeeping tasks, not blockers.

---

## A. Terminology Cleanup (High Priority)

### 1. `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md`
- **Issue**: Title says "8 Core" but system has 80+ services. Readers assume 8 files total.
- **Canonical intent #8**: AI Manager expected to grow into many services.
- **Fix**: Rename to "AI Manager Architecture (Core Services)" and add a "Services Inventory" section listing all 80+ services with their roles. Clarify that the 8 core files are the orchestration layer, not the complete system.

### 2. `docs/wiki_reorganization/phase2_alignment/BACKLOG_REORGANIZATION_PROPOSAL.md`
- **Issue**: Lists 7 P0 blockers that canonical intent resolves as false blockers.
- **Canonical intents #1, #4, #6, #8**: Resolve Colony/Settlement, OrbitalDepot, template drift, AI Manager docs.
- **Fix**: This document is superseded by `BLOCKER_REVIEW_CANONICAL_ALIGNMENT.md`. Mark as superseded in its header.

### 3. `docs/wiki/Celestial-Systems.md` (wiki page)
- **Issue**: May describe settlements differently than code (Phase 1 conflict report flagged this).
- **Canonical intents #1, #2**: Colony = governance entity of 2+ settlements; Settlements = administrative population centers.
- **Fix**: Verify wiki page matches canonical hierarchy. Update if it conflates Colony and Settlement.

### 4. `docs/architecture/structures/README.md`
- **Issue**: Describes settlement-structure relationship correctly but doesn't mention OrbitalDepot's dual namespace history (retired root-level class).
- **Canonical intent #4**: Multiple Ruby models not automatically a conflict.
- **Fix**: Add a "Namespace History" note explaining the OrbitalDepot evolution from root PORO → Settlement::OrbitalSettlement.

---

## B. Cross-Reference Cleanup (Medium Priority)

### 5. `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md`
- **Issue**: Marked as "Draft/Stub" (2026-04-27). References template versions but doesn't address version drift.
- **Canonical intent #6**: Templates are design documents; version drift is documentation housekeeping.
- **Fix**: Complete the overview. Add a "Template Versions" section noting that multiple schema versions exist and are intentional design iterations, not errors.

### 6. `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md`
- **Issue**: Documents 4-phase exchange evolution but phase transition logic is unclear in code.
- **Canonical intent #10**: NPCs create initial economy; player automation has opportunity.
- **Fix**: Add a "Phase Transition Implementation" section documenting where (or if) the phase transition logic exists in code. If it doesn't exist, note as "planned but not implemented."

### 7. `docs/architecture/economy/CONTRACTS.md`
- **Issue**: Documents player-first contract priority (24-48h window, 1.5x reward) but code enforcement is unclear.
- **Canonical intent #10**: Player automation always has opportunity to perform work.
- **Fix**: Add a "Code Implementation" section with specific file paths and method names that enforce player-first priority. If not implemented, note as "design documented, implementation pending."

### 8. `docs/architecture/terrasim/OVERVIEW.md`
- **Issue**: Notes missing regression engine but doesn't cross-reference the Civ4 shoreline flooding issue in starsim docs.
- **Canonical intent #5**: Worldhouses built over natural terrain (implies terrain stability matters).
- **Fix**: Add cross-reference to `docs/architecture/starsim/OVERVIEW.md` shoreline flooding section. Link regression engine to shoreline filter as a dependency.

### 9. `docs/architecture/terrain/generation_and_rendering.md`
- **Issue**: Separates terrain generation from biome visualization but doesn't document the integration point.
- **Canonical intent #5**: Worldhouses built over natural terrain.
- **Fix**: Add an "Integration Points" section showing how terrain elevation → biome classification → visual rendering flows through the pipeline.

---

## C. Diagrams Needed (Low Priority)

### 10. AI Manager Service Dependency Map
- **Why**: 80+ services with no integration map. Risk of circular dependencies or missing handoff points.
- **What**: Mermaid diagram showing service-to-service dependencies and the 8 core orchestration files.
- **Location**: Should go in `docs/architecture/ai_manager/` as a new file.

### 11. Colony → Settlement → Structure Hierarchy
- **Why**: Phase 2 flagged this as P0 (now resolved by canonical intent), but no visual diagram exists for contributors.
- **What**: Mermaid class diagram showing Colony has_many Settlements, Settlements have_many Structures/Units.
- **Location**: `docs/wiki/04_Settlements_and_Infrastructure/settlement_architecture.md`

### 12. Template Version Matrix
- **Why**: 70+ template files with v1-v7 drift across blueprint types. Contributors need to know which version is canonical.
- **What**: Table or matrix showing each blueprint type and its current schema version.
- **Location**: `docs/wiki/06_Manufacturing_and_ISRU/blueprint_schema.md`

### 13. Core Game Loop Flow
- **Why**: Phase 2 reconstructed a 12-step loop but it exists only in the phase2_alignment folder (not canonical wiki location).
- **What**: Mermaid flow diagram of the complete gameplay loop from system selection through settlement management.
- **Location**: `docs/wiki/00_Project_Overview/` or `docs/wiki/01_Core_Architecture/`

---

## Summary

| Priority | Count | Type | Examples |
|----------|-------|------|---------|
| High | 4 | Terminology cleanup | AI Manager doc title, Phase 2 backlog superseded, wiki settlement description, OrbitalDepot namespace history |
| Medium | 4 | Cross-reference gaps | Manufacturing overview stub, economy phase transitions, contract enforcement code paths, terraSim-starsim cross-links |
| Low | 5 | Diagrams needed | AI Manager dependency map, Colony hierarchy, template version matrix, game loop flow |

**Total items**: 13 (4 high + 4 medium + 5 low)
