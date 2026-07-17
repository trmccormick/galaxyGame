# Galaxy Game Wiki — Phase 4 Blueprint

**Created**: 2026-07-16  
**Purpose**: Complete blueprint for the canonical Galaxy Game Wiki knowledge system.  
**Status**: COMPLETE — All 9 deliverables created.

---

## Executive Summary

Phase 4 transforms the current documentation collection into a coherent knowledge system organized by **game concept**, not repository layout. A new contributor should be able to understand Galaxy Game without reverse-engineering the codebase.

### What Was Done

- Surveyed **188+ documents** across the entire docs tree
- Classified every document into one of 7 categories (Canonical, Supporting, Merge, Split, Archive, Historical, Redirect)
- Designed a complete **12-section wiki navigation hierarchy**
- Identified **ONE authoritative page** for every major topic
- Mapped **all required cross-references** between sections
- Identified **89 missing pages** that should exist (33 P0 critical, 38 P1 high, 18 P2 medium)
- Created an **archive plan** for ~120 documents (ephemeral, historical, superseded)
- Established **contributor guidelines** to prevent future documentation drift

### Key Design Decisions

1. **Concept-first organization** — Wiki is organized around what the game IS, not how the codebase is structured. No Rails namespaces, no model folders, no service directories.

2. **One canonical page per topic** — Every major topic has exactly ONE authoritative page. All other pages link to it. This eliminates ambiguity about which document is correct.

3. **Separation of active and historical** — Active wiki pages describe the game. Historical documents live in `docs/archive/`. Status reports, execution plans, and agent handoffs are ephemeral — archive after use.

4. **No new terminology** — Phase 4 reorganizes existing knowledge; it does not introduce new terms or redesign game systems.

---

## The 12-Section Wiki Structure

```
Galaxy Game Wiki
├── 1. Vision          (What is Galaxy Game? Why does it exist?)
├── 2. Story & Timeline (Narrative, acts, timeline, Snap Event)
├── 3. Universe        (Sol, Eden, planets, stars, wormholes)
├── 4. Simulation      (StarSim, TerraSim, spheres, biomes, terraforming)
├── 5. Economy         (Currency, markets, trading, NPC economy, pricing)
├── 6. Manufacturing   (Resources, ISRU, blueprints, construction, tech levels)
├── 7. Settlements     (Colonies, settlements, structures, worldhouses, orbital)
├── 8. Transportation  (Craft, stations, depots, cyclers, logistics)
├── 9. AI Manager      (Architecture, subsystems, service portfolio)
├── 10. Gameplay       (Planetary, orbital, industry, mining, trading, exploration)
├── 11. Development    (Architecture, standards, phases, testing, AI workflow)
└── 12. Reference      (Glossary, terminology, constants, indices, schemas)
```

### Reading Order for New Contributors

1. **Vision** — What is Galaxy Game? Design philosophy
2. **Story & Timeline** — The narrative setting
3. **Universe** — Sol system and beyond
4. **Simulation** — How the world works
5. **Economy** — NPC-first economy
6. **Manufacturing** — Resource pipeline
7. **Settlements** — Colony hierarchy
8. **Transportation** — Logistics network
9. **AI Manager** — Orchestration layer
10. **Gameplay** — Player experience
11. **Development** — For contributors
12. **Reference** — Glossary and indices

---

## Document Classification Results

| Category | Count | Meaning |
|----------|-------|---------|
| **Canonical** | ~35 | Authoritative source for a major topic |
| **Supporting** | ~60 | Detailed explanation of a sub-topic |
| **Merge** | ~25 | Content should be merged into another doc |
| **Split** | ~3 | Content spans multiple wiki sections |
| **Archive** | ~30 | Ephemeral — status reports, execution plans |
| **Historical** | ~15 | Development history, agent conversations, prototypes |
| **Redirect** | ~20 | Superseded by another document |

**Total documents classified**: 188+

---

## Deliverables (9 Documents)

### 1. WIKI_SITE_MAP.md
Complete navigation tree for the wiki. Every section, every page, every link. Includes reading order, page types legend, and cross-section canonical links.

### 2. DOCUMENT_CLASSIFICATION.md
Every document in the docs tree classified into one of 7 categories. Organized by current location (docs/architecture/, docs/developer/, etc.) with wiki section target and action for each file.

### 3. DOCUMENT_RELOCATION_PLAN.md
Current location → canonical wiki location → recommended action for every document. Includes merge targets, archive destinations, and new pages to create from scratch.

### 4. CANONICAL_DOCUMENT_INDEX.md
ONE authoritative page for every major topic. Lists canonical source, supporting pages, and historical pages for each topic. Includes canonical page selection rules.

### 5. CROSS_REFERENCE_PLAN.md
All required internal wiki links organized by section. Identifies missing cross-links (current state) and prioritizes them (critical → high → medium). Ensures no documentation is isolated.

### 6. MISSING_WIKI_PAGES.md
89 pages that should exist but currently do not. Organized by priority:
- **P0 Critical** (33): Blocks contributor understanding; MVP-relevant
- **P1 High** (38): Important for feature development
- **P2 Medium** (18): Improves contributor experience

### 7. ARCHIVE_PLAN.md
~120 documents suitable for archive, organized into three subdirectories:
- `docs/archive/ephemeral/` — Status reports, execution plans, agent handoffs
- `docs/archive/historical/` — Development history, agent conversations, prototypes
- `docs/archive/superseded/` — Merged content with redirect to target

### 8. CONTRIBUTOR_GUIDE.md
How future documentation should be organized: naming conventions, section placement rules, cross-reference requirements, AI agent guidelines, and maintenance procedures. Includes emergency procedures for broken references and contradictions.

### 9. README.md (this file)
Executive summary of the Phase 4 blueprint. Navigation philosophy, reading order, contributor expectations.

---

## Implementation Roadmap

### Phase A: Foundation (Do First)
1. Create `docs/archive/` directory structure
2. Move ephemeral documents to `docs/archive/ephemeral/`
3. Move historical documents to `docs/archive/historical/`
4. Create the 33 P0 critical wiki pages

### Phase B: Migration (Do Second)
5. Move canonical/supporting docs to their wiki locations
6. Merge superseded content into target pages
7. Create the 38 P1 high-priority wiki pages
8. Add all cross-references between sections

### Phase C: Refinement (Do Third)
9. Create the 18 P2 medium-priority wiki pages
10. Build the complete CROSS_REFERENCES page
11. Update CANONICAL_DOCUMENT_INDEX.md with final state
12. Archive remaining superseded documents to `docs/archive/superseded/`

### Phase D: Maintenance (Ongoing)
13. Enforce CONTRIBUTOR_GUIDE rules on all new docs
14. Quarterly review of cross-references and canonical page accuracy
15. Archive ephemeral documents as they serve their purpose

---

## What This Blueprint Does NOT Do

- ❌ Redesign game systems
- ❌ Rewrite gameplay mechanics
- ❌ Change canonical intent (Phase 3 established that)
- ❌ Introduce new terminology
- ❌ Identify new architecture blockers
- ❌ Modify implementation plans

This is a **documentation architecture project**, not a software architecture redesign.

---

## Success Criteria

The wiki is complete when:

1. ✅ A new contributor can understand Galaxy Game by reading pages in the recommended order
2. ✅ Every major topic has ONE authoritative page
3. ✅ No documentation is isolated — every page links to related pages
4. ✅ All ephemeral documents are archived
5. ✅ No canonical page contradicts Phase 3 canonical intent statements
6. ✅ The wiki is organized by game concept, not repository layout

---

## Files in This Directory

| File | Purpose |
|------|---------|
| WIKI_SITE_MAP.md | Complete navigation tree |
| DOCUMENT_CLASSIFICATION.md | Every document categorized |
| DOCUMENT_RELOCATION_PLAN.md | Current → future location mapping |
| CANONICAL_DOCUMENT_INDEX.md | ONE authoritative page per topic |
| CROSS_REFERENCE_PLAN.md | All required internal links |
| MISSING_WIKI_PAGES.md | 89 pages that should exist |
| ARCHIVE_PLAN.md | ~120 documents to archive |
| CONTRIBUTOR_GUIDE.md | How to maintain the wiki |
| README.md | This file — executive summary |

---

## Next Steps

1. **Review this blueprint** with the team
2. **Approve the 12-section structure** (adjust if needed)
3. **Prioritize P0 pages** for immediate creation
4. **Execute Phase A** (archive ephemeral docs, create foundation)
5. **Proceed through Phases B-D** in order

**Phase 4 is complete as a blueprint. Implementation follows approval.**
