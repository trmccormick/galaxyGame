---
date_created: 2026-07-20
type: DESIGN_SYSTEM_SUMMARY
status: active
purpose: Concise overview of the complete GalaxyGame design system
---

# GalaxyGame Design System — Complete Overview

**Created**: 2026-07-20  
**Purpose**: Single-page reference for the entire design system architecture

---

## The Shift

**Before**: "Design individual assets" → inconsistent, doesn't scale  
**After**: "Design the system that generates assets" → consistent, scales infinitely

---

## Design System Hierarchy (4 Levels)

```
Level 0: VISUAL PHILOSOPHY (Why?)
├─ VISUAL_PHILOSOPHY.md
│  9 principles: Grounded, Functional, Progressive, Modular, Industrial, 
│  Human, Simulation-First, Location-Agnostic, Consistency
│  → Answers "What should this game feel like?"

Level 1: FRAMEWORK (How?)
├─ Icon Bible (2026-07-19-HIGH-DESIGN-GALAXYGAME_ICON_BIBLE.md)
│  Asset hierarchy, color families, shape language, material library,
│  lighting rules, tech level progression (Mk1-Mk5), animation language,
│  damage states, complexity levels (L0-L5), prompt templates
│  → Defines visual language for each asset category

├─ Asset Registry Specification (2026-07-19-HIGH-DESIGN-ASSET_REGISTRY_SPECIFICATION.md)
│  Canonical list of ~250+ planned assets, ID format, categories
│  → Defines WHAT assets exist

Level 2: SPECIFICATIONS (Which session?)
├─ Design Research Index (DESIGN_RESEARCH_INDEX.md)
│  Maps 10 ChatGPT sessions to asset types + priority workflow
│  → Bridges philosophy to implementation

└─ 10 Research Session Files (detailed specs per domain)
   Session 2: Catalog render standards ⭐
   Session 3: Terrain/biome organization ⭐
   Session 6: Manufacturing methods ⭐
   Session 8: Component render specs ⭐
   Session 9: Prompt templates ⭐
   Session 10: Biome compression ⭐

Level 3: REFERENCE (Organization)
├─ UNIFIED_ASSET_CATALOG_ARCHITECTURE.md
│  Location-agnostic naming principle, canonical IDs, implementation rules
│  → How to organize canonically

└─ EXISTING_ASSET_AUDIT.md
   Inventory of ~250+ pre-Icon Bible assets + regeneration priority
   → What exists now vs what needs regeneration
```

---

## Asset Generation Pipeline (7 Steps)

```
1. Define Resource (JSON with canonical ID)
        ↓
2. Reference Specifications (Design Research Index → session files)
        ↓
3. Generate Prompt (parametric template from Icon Bible Section 12)
        ↓
4. Generate Asset (AI image generation using prompt)
        ↓
5. Validate Against Philosophy (9 principles check)
        ↓
6. Store in Asset Library (register with canonical ID)
        ↓
7. Reference in Gameplay (available everywhere, consistent)
```

**Result**: New asset generated in minutes, inherits consistency automatically.

---

## Key Design Principles

| Principle | What It Means |
|-----------|--------------|
| **Grounded** | Looks buildable — NASA/ESA, not Star Trek |
| **Functional** | Every visible part has a reason |
| **Progressive** | Mk1→Mk5 clear at a glance |
| **Modular** | Visibly connectable and expandable |
| **Industrial** | Manufactured, not magical |
| **Human** | Evidence of human engineering |
| **Simulation-First** | Visuals communicate gameplay |
| **Location-Agnostic** | Same asset everywhere (Luna/Mars/Venus) |
| **Consistency** | Unified language beats novelty |

---

## Current Status

### ✅ Complete (Design Foundation)
- [x] VISUAL_PHILOSOPHY.md — 9 foundational pillars
- [x] Icon Bible v2 — comprehensive visual language (9.5/10 per ChatGPT)
- [x] Design Research Index — maps 10 sessions to asset generation
- [x] Design System Architecture — complete hierarchy + pipeline
- [x] Asset Registry Specification — what assets exist
- [x] UNIFIED_ASSET_CATALOG_ARCHITECTURE.md — naming principle
- [x] EXISTING_ASSET_AUDIT.md — ~250+ pre-Icon Bible assets inventoried

### ✅ Complete (Asset Generation Pipeline)
- [x] VISUAL_DEFINITION_TEMPLATE.md — canonical template for appearance (separate from Blueprint/Operational)
- [x] ASSET_GENERATION_ARCHITECTURE.md — 7-stage pipeline specification
- [x] BLUEPRINT_SCHEMA_V2_REVIEW.md — task spec for schema evolution review

### 🔴 Pending (Implementation)
- [ ] Unit sprites regeneration (16 files) — first implementation of design system
- [ ] Corporate logos regeneration (~30 files) — Session 5 + Session 7 specs
- [ ] Terrain Layer 0 tiles (~50+ files) — foundation for surface rendering
- [ ] Biome tiles alignment (14 → ~16 canonical) — Session 10 compression
- [ ] Catalog components regeneration (~200+ files) — Icon Bible hierarchy
- [ ] Tech tree icons — Session 6 tech level progression
- [ ] Blueprint Schema v2 review (Qwen task) — add visualization section to all blueprints

---

## File Locations

All design system documents live in:
```
/agent-tasks/projects/galaxy_game/tasks/backlog/design/
├── VISUAL_PHILOSOPHY.md                    (foundation)
├── 2026-07-19-HIGH-DESIGN-GALAXYGAME_ICON_BIBLE.md     (framework)
├── 2026-07-19-HIGH-DESIGN-ASSET_REGISTRY_SPECIFICATION.md (catalog)
├── DESIGN_RESEARCH_INDEX.md                (specifications)
├── DESIGN_SYSTEM_ARCHITECTURE.md           (overview)
├── EXISTING_ASSET_AUDIT.md                 (inventory)
├── UNIFIED_ASSET_CATALOG_ARCHITECTURE.md   (naming principle)
└── 10 Research Session Analysis Files      (detailed specs)
```

---

## How to Use This System

### For Design Decisions:
1. Read VISUAL_PHILOSOPHY.md (foundation)
2. Reference Icon Bible section (framework)
3. Check UNIFIED_ASSET_CATALOG_ARCHITECTURE.md (naming)

### For Asset Generation:
1. Define resource in JSON (canonical ID)
2. Look up relevant session in Design Research Index
3. Read session file for detailed specifications
4. Use Icon Bible Section 12 prompt template (parametric)
5. Generate asset using specifications
6. Validate against VISUAL_PHILOSOPHY.md principles

### For New Expansions (e.g., new planet):
1. Location affects JSON metadata only
2. No asset regeneration needed
3. Same asset library works everywhere
4. Simulation parameters adjust, visuals stay consistent

---

## The Goal

**Build a system where**:
- Every asset follows documented philosophy
- Every asset derives from specifications
- Every asset generation is reproducible
- Adding 1,000 assets doesn't require 1,000x effort
- All future assets inherit consistency automatically

**That system is now in place.**

---

## References

- VISUAL_PHILOSOPHY.md (foundation)
- Icon Bible v2 (framework)
- Design Research Index (specifications)
- 10 Research session files (details)
- UNIFIED_ASSET_CATALOG_ARCHITECTURE.md (organization)
- Asset Registry Specification (catalog)
- EXISTING_ASSET_AUDIT.md (inventory)
