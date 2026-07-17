# Phase 2: Architecture Canonicalization Review

**Created**: 2026-07-16  
**Phase**: 2 (Alignment)  
**Status**: Complete — Ready for human review

---

## What Was Done

Phase 2 analyzed the Phase 1 discovery artifacts against current code architecture to create an authoritative alignment reference. The analysis treated existing documentation as **evidence, not authority**, and preferred current code over old design documents throughout.

---

## Documents Created

All files are in `docs/wiki_reorganization/phase2_alignment/`:

### 1. DEVELOPMENT_PHASE_MAPPING.md
Maps every existing system into 5 development phases (0-4) with:
- Intended phase assignment
- Current implementation status (✅ CONFIRMED / ⚠️ PARTIALLY IMPLEMENTED / ❌ NOT IMPLEMENTED)
- Documentation status (CANONICAL / REFERENCE / OUTDATED)
- Missing pieces and blocking dependencies

**Key finding**: Foundation (Phase 0) is substantially complete. All higher phases have core systems implemented but with integration gaps. **1 critical blocker**: AI Manager architecture documentation describes 8 files while the actual system has 80+.

### 2. BACKLOG_REORGANIZATION_PROPOSAL.md
Reclassifies 54 existing TODO items, issues, and notes into 6 priority categories:
- **FOUNDATION BLOCKERS** (7 items, all P0) — Required before other systems can function
- **CORE GAMEPLAY** (8 items, all P1) — Directly enables gameplay loops
- **INFRASTRUCTURE** (8 items, P1-P3) — Improves architecture but not player-visible
- **EXPANSION FEATURES** (8 items, P2-P4) — Adds future capability
- **EXPERIMENTAL** (6 items, P3-P4) — Interesting but not required
- **DEPRECATED/QUESTIONABLE** (17 items) — Conflicts with current architecture

**Key finding**: 7 P0 foundation blockers must be resolved before any new development. These include template version drift, Habitat.rb active version verification, OrbitalDepot dual namespace, Colony vs Settlement distinction, TL-to-MK relationship, Job system spec compliance, and AI Manager documentation update.

### 3. ARCHITECTURE_GAPS_AND_NEXT_STEPS.md
Identifies gaps across 4 categories:

**A. Systems that exist but need integration:**
- AI Manager (80+ services, unclear orchestration)
- Manufacturing chain (exists but gameplay loop incomplete)
- Economy (core exists but resource flow integration missing)
- TerraSim (simulation exists but regression engine incomplete)
- Rendering pipeline (generation and visualization disconnected)

**B. Systems documented but not implemented:**
- Regression/weathering engine (core SimEarth feature)
- Civ4 shoreline regression filter (critical terrain quality issue)
- Brown dwarf hub manager (implementation status INFERRED)
- Cryosphere simulation service (model exists, no service)

**C. Systems implemented but poorly documented:**
- 10+ AI Manager services with undocumented scope/integration
- Market stabilization integration undocumented
- Transport cost EM physics undocumented

**D. Systems that should be frozen until later phases:**
- Digital Twin sandbox, precursor missions, multi-wormhole events, EM power shields, insurance market, alien life simulation, sci-fi easter eggs

### 4. CORE_GAME_LOOP_STATUS.md
Reconstructs the actual gameplay loop from code evidence:

| Step | System | Status | Blocking Issues |
|------|--------|--------|-----------------|
| 1. System Generation | StarSim | ✅ Implemented | None |
| 2. Planetary Analysis | CelestialBody + Lookup | ✅ Implemented | None |
| 3. Mission Planning | AI Manager + Contracts | ⚠️ Partial | Player-first enforcement unclear |
| 4. Transportation | Craft + Cyclers | ✅ Substantially Implemented | Cycler namespace mismatch |
| 5. Resource Extraction | ISRU + Mining | ✅ Substantially Implemented | ISRU pricing docs may be outdated |
| 6. Manufacturing | Fabricators + Blueprints | ✅ Substantially Implemented | Template version drift, stub overview doc |
| 7. Settlement Construction | Structures + Pressurization | ✅ Substantially Implemented | OrbitalDepot namespace blocker |
| 8. Economic Interaction | Dual Currency + Market | ✅ Substantially Implemented | Exchange rate phase logic unclear |
| 9. Technology Progression | Tech Tree + TL/MK | ⚠️ Partial | **TL-to-MK relationship unresolved** |
| 10. Terraforming | TerraSim + Biomes | ⚠️ Partial | **Regression engine NOT implemented** |
| 11. Interstellar Expansion | Wormholes + AI | ✅ Substantially Implemented | Brown dwarf hub status unclear |
| 12. AI Autonomy | Pattern Learning | ✅ Implemented (docs outdated) | Architecture doc severely outdated |

**Key finding**: ~85% of gameplay loop is functional. **3 critical blockers** prevent the complete loop: TL-to-MK gating, terraforming regression engine, and player-first contract enforcement.

### 5. WIKI_2_STRUCTURE_PROPOSAL.md
Designs the future GitHub Wiki organization with 13 sections:

```
00_Project_Overview     — Game vision, design pillars, guardrails
01_Core_Architecture    — JSON-driven architecture, data conventions
02_Galaxy_and_Celestial_Systems — StarSim, celestial body hierarchy
03_Terraforming_and_Simulation  — TerraSim, sphere models, biomes
04_Settlements_and_Infrastructure   — Settlements, structures, construction
05_Units_and_Craft          — Units, craft, cyclers, fabricators
06_Manufacturing_and_ISRU   — Manufacturing chain, ISRU, blueprints
07_Economy_and_Logistics    — Dual currency, contracts, market, logistics
08_AI_Manager               — AI orchestration (needs major rewrite)
09_Technology_System        — Tech tree, TL/MK (pending resolution)
10_Rendering_and_UI         — Terrain, tilesets, assets, UI
11_Data_Architecture        — JSON formats, schemas, version history
12_Development_Guides       — Setup, deployment, testing, CI/CD
13_Historical_Archive       — Superseded docs, session artifacts, legacy code
```

**Key finding**: Two sections cannot be completed until design decisions are resolved: Technology System (TL-to-MK) and AI Manager overview (80+ services need documentation rewrite).

---

## Major Findings

### 1. Foundation Is Complete — But Has 7 P0 Blockers

All Phase 0 systems exist and are documented as CANONICAL. However, 7 items block meaningful new development:
- Template version drift (v1-v7 across blueprint types)
- Habitat.rb active version verification
- OrbitalDepot dual namespace resolution
- Colony vs Settlement relationship clarification
- TL-to-MK relationship resolution
- Job system code vs spec compliance verification
- AI Manager architecture documentation update

### 2. ~85% of Gameplay Loop Is Functional

A player can generate worlds, analyze planets, deploy craft, extract resources, manufacture goods, build structures, trade economically, and observe AI operations. Three gaps prevent the complete loop:
- **TL-to-MK relationship** — blueprint gating logic unresolved
- **Regression engine** — core SimEarth feature not implemented
- **Player-first contract enforcement** — code implementation unclear

### 3. AI Manager Documentation Is Severely Outdated

The architecture document describes 8 core files; the actual system has 80+ services. This is the single most outdated canonical document in the repository and blocks all AI Manager development.

### 4. Two Major Design Decisions Remain Unresolved

- **Technology Level vs MK Generation** — explicitly an "open question" in Art Bible docs
- **Colony vs Settlement relationship** — both exist with unclear distinction

### 5. Regression Engine Is the Largest Implementation Gap

The core SimEarth-inspired feature (regressing goal-state maps to barren states) is not implemented. The Civ4 shoreline flooding issue also requires a dedicated regression filter. These are HIGH priority gaps.

---

## Recommended Next Steps

### Before Any Migration or New Development

1. **Resolve 7 P0 foundation blockers** (see BACKLOG_REORGANIZATION_PROPOSAL.md)
2. **Resolve TL-to-MK relationship** — design decision needed
3. **Rewrite AI Manager architecture document** — 8 files → 80+ services
4. **Implement regression/weathering engine** — core SimEarth feature
5. **Implement Civ4 shoreline regression filter** — critical terrain quality

### After Blockers Are Resolved

6. Review and approve wiki structure proposal
7. Execute documentation migration (Phase 3)
8. Begin new development on resolved backlog items

---

## Important Reminders

- **Nothing was moved, renamed, deleted, or overwritten.**
- **All existing documents remain in their original locations.**
- **This is an alignment phase only.**
- **No changes should be made until a human reviews these findings.**
- **The proposed wiki structure is a suggestion, not a directive.**

---

## Files Created in Phase 2

```
docs/wiki_reorganization/phase2_alignment/
├── README.md                              ← This file
├── DEVELOPMENT_PHASE_MAPPING.md           ← Systems mapped to 5 phases
├── BACKLOG_REORGANIZATION_PROPOSAL.md     ← 54 items reclassified into 6 categories
├── ARCHITECTURE_GAPS_AND_NEXT_STEPS.md    ← Gaps across 4 categories
├── CORE_GAME_LOOP_STATUS.md               ← 12-step loop reconstructed from code
└── WIKI_2_STRUCTURE_PROPOSAL.md           ← 13-section wiki design
```
