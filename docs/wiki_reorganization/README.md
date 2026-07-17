# Galaxy Game Documentation Archaeology — Phase 1 Discovery

**Date**: 2026-07-16  
**Phase**: 1 (Discovery/Analysis)  
**Status**: Complete — Ready for human review

---

## What Was Analyzed

This analysis performed a comprehensive archaeological scan of the Galaxy Game repository, examining:

### Directories Scanned
- `docs/` and all 14 subdirectories (~657+ agent files cataloged at directory level)
- `data/` including `json-data/` (70+ templates, 40+ mission profiles, 30+ star systems)
- `galaxy_game/app/models/` (~100 model files across 20+ namespaces)
- `galaxy_game/app/services/` (~100 service files across 15+ domains)
- `galaxy_game/app/javascript/` (8 JS files for rendering/UI)
- `galaxy_game/app/assets/` (sprites, tilesets, atlases)
- `galaxy_game/config/` (YAML configs for economy, units, raw materials)
- `galaxy_game/db/` (schema.rb, seeds, migrations)

### Total Documents Cataloged: **368+** individual files across all categories

---

## What Was Created

All output is in `/docs/wiki_reorganization/`:

### Inventory Layer (`inventory/`)
| File | Description |
|------|-------------|
| `DOCUMENT_INVENTORY.md` | Complete catalog of 368+ documents with path, purpose, category, and date |
| `DOCUMENT_AUTHORITY_MAP.md` | Authority classification (CANONICAL/REFERENCE/HISTORICAL/DEPRECATED/UNKNOWN) for every document |

### Analysis Layer (`analysis/`)
| File | Description |
|------|-------------|
| `CONFLICT_REPORT.md` | 15 identified conflicts with sources, differences, confidence levels, and human decision requirements |
| `CORE_CONCEPT_MAP.md` | 20+ simulation entities and systems mapped to their current code owners |
| `TERMINOLOGY_MAP.md` | 22 terminology inconsistencies with recommendations |
| `ARCHITECTURE_RECONSTRUCTION.md` | Reconstructed architecture from evidence, separated into CONFIRMED/INFERRED/UNKNOWN |

### Proposal Layer (`proposals/`)
| File | Description |
|------|-------------|
| `PROPOSED_DOCUMENTATION_STRUCTURE.md` | Proposed 13-folder wiki organization with migration plan |

### Root
| File | Description |
|------|-------------|
| `README.md` | This file — overview and navigation |

---

## Major Findings

### 1. The Codebase Is Substantially Larger Than Its Documentation Suggests

The AI Manager architecture document describes "8 core files" but the actual implementation has **80+ services**. This pattern of under-documented growth appears across multiple subsystems (economy, manufacturing, settlement).

### 2. JSON-Driven Architecture Is Well-Established

The principle "JSON describes what is estimated to exist. The game engine determines state and emergent interactions" is consistently enforced across:
- Celestial body data conventions
- Blueprint/operational data separation
- Template-based schema evolution (v1 → v1.7)
- Runtime lookup service pattern

### 3. Five Conflicts Require Human Decision

| Priority | Conflict | Impact |
|----------|----------|--------|
| **HIGH** | Technology Level vs MK Generation relationship | Affects data model and visual asset generation |
| **MEDIUM** | Settlement vs Structure relationship ambiguity | Affects model organization |
| **MEDIUM** | Dual Biome Model (Biome vs PlanetBiome) | Affects simulation architecture |
| **MEDIUM** | Orbital Depot dual namespace | Affects code clarity |
| **LOW** | Simulation Sandbox purpose | Affects documentation placement |

### 4. Terminology Is Mostly Consistent With 22 Identified Inconsistencies

The most significant inconsistency is the Technology Level / Tech Tier / MK Generation triad, which represents an unresolved design decision rather than a pure naming issue.

### 5. Architecture Can Be Reconstructed From Evidence

The current architecture is largely **CONFIRMED** by code and documentation:
- Three-layer simulation (StarSim → TerraSim → rendering)
- JSON-driven data model with template evolution
- Service-oriented architecture (100+ services)
- Dual-currency economy with phased exchange
- Player-first contract system
- Namespace-hierarchical models

Several areas remain **INFERRED** or **UNKNOWN** and need review.

### 6. Documentation Is Organized By Creation Context, Not Conceptual Domain

The current `docs/` structure reflects which agent/session created each document rather than what the documents describe. This creates:
- Duplicate coverage (e.g., AI Manager documented in 4+ separate directories)
- Scattered related content (e.g., economy docs in economy/, intent/, operations/, wiki/)
- Hard-to-find references (e.g., terraforming docs in gameplay/, developer/, architecture/)

### 7. Historical Documents Are Preserved But Not Clearly Labeled

Many HISTORICAL documents (chat logs, session notes, completed task files) are mixed with CANONICAL documents without clear visual distinction. The `docs/agent/archive/` directory exists but not all historical content has been moved there.

---

## Known Uncertainties

### Areas Where Evidence Is Insufficient

| Area | Issue | Confidence |
|------|-------|------------|
| Simulation Sandbox purpose | Document moved from root, sparse content | LOW |
| Colony vs Settlement relationship | Both exist with unclear distinction | LOW |
| Digital Twin integration | Service exists but integration unclear | LOW |
| Precursor mission scope | Multiple docs with different scopes | LOW |
| EM (Energy-Matter) physics definition | Referenced but not defined | LOW |
| Quest vs Mission distinction | "Quest" appears in data directory | LOW |
| TL-to-MK relationship | Explicitly open question in Art Bible | MEDIUM |
| Biome model duality | Biome vs PlanetBiome relationship unclear | LOW |

### Areas Where Code and Docs Diverge

| Area | Documentation Says | Code Shows |
|------|-------------------|------------|
| AI Manager size | 8 core files | 80+ services |
| OrbitalDepot location | Single model | Two namespaces (root + settlement) |
| Ship location | Within craft namespace | Also exists at root level |
| Cycler location | AI Manager subsystem | Root namespace model |
| ISRU pricing | Documented in ISRU_PRICING_MODEL.md | Needs verification against current services |

---

## Recommended Next Steps

### Immediate (Before Any Migration)

1. **Resolve the 5 conflicts requiring human decision** (see Conflict Report)
   - Technology Level vs MK Generation: Design decision needed
   - Biome model duality: Clarify if both should coexist
   - Orbital Depot dual namespace: Consolidate or document distinction
   - Settlement vs Structure: Clarify boundary
   - Simulation Sandbox: Define purpose

2. **Resolve the 6 additional uncertainties** listed above

3. **Review the Terminology Map** and approve/reject recommendations

### Phase 2 (Implementation — Not Yet Started)

4. **Create proposed directory structure** under `docs/` (13 folders)
5. **Move CANONICAL documents** to proposed locations
6. **Consolidate scattered documents** into unified references
7. **Archive HISTORICAL/DEPRECATED documents** to `13_ARCHIVE/`
8. **Create missing documents** identified in this analysis
9. **Update docs/README.md** with new navigation
10. **Update all internal cross-references**

### Phase 3 (Maintenance — Not Yet Started)

11. **Establish documentation conventions** based on terminology recommendations
12. **Create documentation contribution guide** for future work
13. **Set up automated link checking** to prevent broken references
14. **Establish document lifecycle policy** (CANONICAL → REFERENCE → HISTORICAL → DEPRECATED)

---

## Files Created in This Phase

```
docs/wiki_reorganization/
├── README.md                              ← This file
├── inventory/
│   ├── DOCUMENT_INVENTORY.md              ← 368+ document catalog
│   └── DOCUMENT_AUTHORITY_MAP.md          ← Authority classification
├── analysis/
│   ├── CONFLICT_REPORT.md                 ← 15 conflicts identified
│   ├── CORE_CONCEPT_MAP.md                ← 20+ concepts mapped
│   ├── TERMINOLOGY_MAP.md                 ← 22 inconsistencies found
│   └── ARCHITECTURE_RECONSTRUCTION.md     ← Architecture reconstructed
└── proposals/
    └── PROPOSED_DOCUMENTATION_STRUCTURE.md ← Proposed reorganization
```

---

## Important Reminders

- **Nothing was deleted, moved, renamed, or overwritten.**
- **All existing documents remain in their original locations.**
- **This is a discovery phase only.**
- **No changes should be made until a human reviews these findings.**
- **The proposed structure is a suggestion, not a directive.**

---

## Quick Reference: Authority Distribution

| Authority Level | Count | Percentage |
|----------------|-------|------------|
| CANONICAL | ~180 | 49% |
| REFERENCE | ~120 | 33% |
| HISTORICAL | ~50 | 14% |
| DEPRECATED | ~2 | <1% |
| UNKNOWN | ~16 | 4% |

**Total documents analyzed**: ~368

---

## Contact / Review Process

This analysis was generated as part of Phase 1 (Discovery) of the Galaxy Game Documentation Archaeology project. All findings should be reviewed by a human before any changes are made to the documentation system.

**Key decisions requiring human input**: See CONFLICT_REPORT.md Section "Conflicts Requiring Human Review" (5 items).
