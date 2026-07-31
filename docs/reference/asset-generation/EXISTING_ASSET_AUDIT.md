---
date_created: 2026-07-20
type: ASSET_AUDIT
status: active
purpose: Inventory all existing ChatGPT-generated assets and map to Icon Bible categories
---

# Existing Asset Audit — What Was Generated Before the Design System

**Date**: 2026-07-20
**Purpose**: Catalog all existing ChatGPT-generated assets, identify inconsistencies with new Icon Bible, plan regeneration under design system

---

## Inventory Summary

| Location | Category | Subfolders | Files (approx) | Status vs Icon Bible |
|----------|----------|------------|----------------|---------------------|
| `data/images/catalog/` | Components/Crafts/Infrastructure/Items/Materials/Modules/Rigs | 10 top-level + nested | ~200+ | ❌ Pre-Icon Bible, inconsistent |
| `data/images/logos/` | Corporate branding | 15 corporations | ~30 files | ⚠️ Needs Icon Bible alignment |
| `data/images/icons/tech/` | Tech tree icons | tech subfolder | ? | ⚠️ Needs review |
| `data/images/terrain/` | Terrain families | dust/frozen/regolith/temperate/tropical/volcanic | ~50+ | ❌ Pre-Icon Bible, inconsistent |
| `data/images/terrain_tiles/` | Terrain tiles (duplicate?) | dust/frozen/regolith/temperate/volcanic | ~50+ | ⚠️ Redundant with terrain/ |
| `data/images/biomes/` | Biome tiles | 14 biome PNGs | 14 files | ❌ Pre-Icon Bible, inconsistent |
| `data/images/biosphere/` | Biosphere layers | desert/forest/marsh/tundra | ~20+ | ⚠️ Needs review |
| `data/images/hydrosphere/` | Water features | ice/lava/ocean | ? | ⚠️ Empty folders? |
| `data/images/materials/raw/` | Material samples | raw subfolder | ? | ⚠️ Needs review |
| `data/images/crystal/` | Crystal/mineral assets | ? | ? | ⚠️ Needs review |
| `data/images/desert/` | Desert-specific assets | ? | ? | ❌ VIOLATES location-agnostic principle |
| `data/images/wetlands/` | Wetland-specific assets | ? | ? | ⚠️ Needs review |
| `data/images/artificial/` | Artificial/synthetic assets | ? | ? | ⚠️ Needs review |
| `galaxy_game/app/assets/images/unit_sprites/` | Unit sprites (in-game) | 16 PNGs | 16 files | ❌ FLAGGED: misaligned, placeholder |
| `galaxy_game/app/assets/images/settlement_*` | Settlement sprites | atlas + multiple variants | ~8 files | ⚠️ Needs review |

---

## Detailed Inventory by Category

### 1. Catalog Assets (`data/images/catalog/`) — ~200+ files

**Structure**:
```
catalog/
├── components/          (structural, mechanical, electronics, production, specialized)
├── crafts/              (atmospheric, ground, space)
├── infrastructure/      (empty)
├── items/               (components/, consumables/)
├── materials/           (processed/)
├── modules/             (computer, control, defense, em_storage, energy, harvester, etc.)
├── ports/               (empty)
├── rigs/                (computer, defense, energy, infrastructure, life_support, power, production, propulsion, science, storage, utility, wormhole_anchor)
├── structures/          (habitation, landing_infrastructure, life_support, manufacturing, mega_structures, power_generation, resource_extraction, resource_processing, science_research, space_stations, storage, transportation)
└── units/               (communication, computers, construction, control, electronics, em_processing, energy, fuel, gravitational_control, habitats, housing, industrial, infrastructure, life_support, mechanical, power, power_generation, production, propulsion, resource, sensors, specialized, storage, vehicles)
```

**Issues vs Icon Bible**:
- ❌ **No canonical naming**: Files likely named by ChatGPT session, not by `[CATEGORY]_[TYPE]_[NAME]` format
- ❌ **Inconsistent styling**: Generated across multiple sessions without unified design constraints
- ❌ **Redundant categories**: `modules/`, `rigs/`, `units/` overlap significantly with Icon Bible's Equipment/Structures/Vehicles hierarchy
- ❌ **No tech level variants**: No evidence of Mk1-Mk5 progression in naming or visual treatment
- ❌ **No manufacturing origin indicators**: No way to distinguish Earth vs Luna vs Orbital variants

**Icon Bible Mapping**:
| Catalog Folder | Icon Bible Category | Notes |
|---------------|-------------------|-------|
| components/ | Manufactured Items (Components) | Needs canonical naming |
| crafts/ | Vehicles | Needs tech level variants |
| infrastructure/ | Structures | Empty — needs generation |
| items/components/ | Manufactured Items (Materials) | Overlaps with materials/processed/ |
| items/consumables/ | Manufactured Items (Items) | New category in Icon Bible? |
| materials/processed/ | Manufactured Items (Materials) | Needs material library alignment |
| modules/ | Equipment + Structures | Ambiguous — overlaps both categories |
| rigs/ | Equipment + Structures | Overlaps with modules/ |
| structures/* | Structures | Needs canonical naming |
| units/* | Units + Vehicles + Equipment | Massive overlap — needs consolidation |

### 2. Corporate Logos (`data/images/logos/`) — ~30 files

**Files**:
- AstroLift (Alt).png, AstroLift.png
- LDC (Alt).png, LDC.png
- MDC (Alt).png, MDC.png
- SDC.png
- TDC.png
- TTC.png
- VDC (Alt v2).png, VDC (Alt v3).png, VDC (Alt).png, VDC.png
- Vector Hauling (Alt).png, Vector Hauling.png
- Wormhole Station (Alt).png, Wormhole Station.png
- Wormhole Transit Consortium (Alt).png, Wormhole Transit Consortium (Astroid Station Variant).png, Wormhole Transit Consortium.png
- Zenith Orbital (Alt).png, Zenith Orbital.png

**Issues vs Icon Bible**:
- ⚠️ **Multiple variants per corporation**: "Alt" versions suggest inconsistent generations
- ⚠️ **No corporate branding standards**: Session 7 identified 10 corporations across 3 categories — need formal branding guidelines
- ⚠️ **Missing corporations**: WTC (Wormhole Transit Consortium) exists but Wormhole Station logo may be separate entity
- ⚠️ **No visual identity alignment**: Session 5 established "grounded sci-fi" aesthetic — need to verify these match

**Icon Bible Mapping**:
| Icon Bible Section | Relevance |
|-------------------|-----------|
| Organizations category | These are the Organization assets |
| Visual Identity (Session 5) | Three pillars: grounded, realistic, strategy-focused |
| Corporate Branding (Session 7) | 10 corporations across 3 categories |

### 3. Terrain Assets (`data/images/terrain/`) — ~50+ files

**Folders**: dust/frozen/regolith/temperate/tropical/volcanic

**Issues vs Icon Bible**:
- ❌ **Pre-Icon Bible generation**: No unified color families, shape language, or material standards
- ❌ **Layer 0/Layer 1 ambiguity**: Session 3 established 3-tier classification (geological base/features/biosphere) — need to verify which assets belong where
- ⚠️ **Redundant with terrain_tiles/**: Same categories in both folders

**Icon Bible Mapping**:
| Icon Bible Section | Relevance |
|-------------------|-----------|
| Layer 0 (Terrain/Geology) | geological base tiles |
| Layer 1 (Biome overlays) | transparent overlay tiles |
| Color Families | gray for minerals, cyan for water, etc. |
| Material Library | regolith composite, frozen ice, volcanic basalt |

### 4. Biome Tiles (`data/images/biomes/`) — 14 files

**Files**: agricultural_fields.png, cold_desert.png, forest.png, grasslands.png, hot_desert.png, jungle.png, ocean.png, plains.png, polar_desert.png, savanna.png, swamp.png, tropical_jungle.png, tundra.png

**Issues vs Icon Bible**:
- ❌ **Pre-Icon Bible generation**: No unified design language
- ⚠️ **Session 10 canonical compression**: 30+ entries compressed to ~16 tiles — these 14 are close but may not match the canonical list exactly
- ⚠️ **Layer assignment ambiguity**: Session 10 left desert/tundra as Layer 0 or Layer 1 unresolved

**Icon Bible Mapping**:
| Icon Bible Section | Relevance |
|-------------------|-----------|
| Canonical Biome Compression (Session 10) | 30+ → ~16 tiles |
| Layer Assignment | desert/tundra: Layer 0 or Layer 1? |
| Color Families | green for vegetation, brown for arid, etc. |

### 5. Biosphere Assets (`data/images/biosphere/`) — ~20+ files

**Folders**: desert/forest/marsh/tundra

**Issues vs Icon Bible**:
- ⚠️ **Needs review**: Purpose unclear (Layer 1 overlays? Or separate from biomes/?)
- ⚠️ **Overlap with biomes/**: Both contain vegetation/ecological assets

### 6. Hydrosphere Assets (`data/images/hydrosphere/`) — Empty folders

**Folders**: ice/lava/ocean (all empty)

**Status**: Not yet generated

### 7. Unit Sprites (`galaxy_game/app/assets/images/unit_sprites/`) — 16 files

**Files**: sprite_00.png through sprite_15.png

**Issues vs Icon Bible**:
- ❌ **FLAGGED**: Visual inspection revealed misalignment (sprite_00 OK, sprite_15 severely degraded)
- ❌ **Pre-Icon Bible**: Generated without design system constraints
- ⚠️ **Placeholder status**: Already documented in NEEDS_REVIEW.md

**Icon Bible Mapping**:
| Icon Bible Section | Relevance |
|-------------------|-----------|
| Equipment category | Extractor, Fabricator, Life Support, Battery Module |
| Structures category | Habitat, Storage Depot |
| Vehicles category | Rover, Harvester, Ship, Spaceship, Satellite |
| Animation Language | Category-specific animation rules |
| Damage States | Physical degradation progression |
| Visual Complexity Levels | L4 (256px in-game rendering) |

### 8. Settlement Assets (`galaxy_game/app/assets/images/settlement_*`) — ~8 files

**Files**: settlement_atlas.json, settlement_sprites.png, settlement_sprites_DEBUG.png, settlement_sprites_final.jpg, settlement_sprites_final.png, settlement_terrain.png, source_preview.jpg, GalaxyGame*.png (logo variants)

**Issues vs Icon Bible**:
- ⚠️ **Needs review**: Purpose unclear — are these structure sprites? UI assets? Concept art?
- ⚠️ **Multiple variants**: DEBUG/FINAL/ALTERNATE versions suggest inconsistent generation

### 9. Crystal Assets (`data/images/crystal/`) — ?

**Status**: Folder exists but contents unknown

### 10. Desert/Wetlands/Artificial/Materials Raw (`data/images/desert/`, `wetlands/`, `artificial/`, `materials/raw/`) — Empty or minimal

**Status**: Mostly empty folders — not yet populated

---

## Critical Findings

### Problem 1: Massive Inconsistency
~200+ assets generated across multiple ChatGPT sessions WITHOUT unified design constraints. This is exactly the "style drift" problem the Icon Bible was designed to prevent.

### Problem 2: No Canonical Naming
Existing files are named by ChatGPT session conventions, not by `[CATEGORY]_[TYPE]_[NAME]` format from the Icon Bible.

### Problem 3: Category Overlap
`modules/`, `rigs/`, `units/` in catalog overlap significantly. Icon Bible's clean hierarchy (Equipment vs Structures vs Vehicles) doesn't map cleanly to existing folder structure.

### Problem 4: No Tech Level Variants
No evidence of Mk1-Mk5 progression in any existing assets.

### Problem 5: Location-Specific Assets Exist
`desert/` folder suggests location-specific generation — VIOLATES the core location-agnostic principle.

---

## Regeneration Priority (Under New Design System)

### 🔴 HIGH PRIORITY (Foundation First)
1. **Unit sprites** (16 files) — Already flagged, needs regeneration under Icon Bible
2. **Corporate logos** (~30 files) — Session 7 identified 10 corporations; need formal branding standards
3. **Terrain Layer 0 tiles** (~50+ existing, needs regeneration) — Foundation for all surface rendering

### 🟡 MEDIUM PRIORITY (Core Gameplay)
4. **Biome tiles** (14 existing, needs canonical alignment) — Session 10 compression to ~16 tiles
5. **Catalog components** (~200+ existing, needs complete regeneration) — Apply Icon Bible hierarchy
6. **Tech tree icons** (`icons/tech/`) — Session 6 tech level progression

### 🟢 LOW PRIORITY (Supporting Assets)
7. **Biosphere overlays** (~20+ existing, needs review)
8. **Hydrosphere tiles** (empty folders — generate fresh under design system)
9. **Crystal/mineral assets** (unknown contents — audit first)
10. **Settlement assets** (~8 files — audit purpose first)

---

## Migration Strategy

### Phase 1: Audit & Categorize (Current)
- ✅ This document created
- Map all existing assets to Icon Bible categories
- Identify which can be reused vs which need regeneration

### Phase 2: Regenerate Foundation Assets
- Unit sprites (16 files) — first implementation of design system
- Corporate logos (30 files) — using Session 5 + Session 7 specs
- Terrain Layer 0 tiles (~50+ files) — using Session 3 + Session 10 specs

### Phase 3: Regenerate Core Assets
- Catalog components (~200+ files) — using Icon Bible hierarchy + parametric prompts
- Biome tiles (14 → ~16 canonical) — using Session 10 compression
- Tech tree icons — using Session 6 tech level progression

### Phase 4: Clean Up & Archive
- Archive pre-Icon Bible assets (keep as reference, not in game)
- Remove redundant folders (terrain/ vs terrain_tiles/)
- Establish ongoing asset generation workflow under design system

---

## Next Steps

1. **Audit specific subfolders** that are empty or unknown (crystal/, hydrosphere/, desert/, wetlands/, artificial/, materials/raw/)
2. **Sample a few existing assets visually** to confirm inconsistency with Icon Bible standards
3. **Prioritize which assets to regenerate first** based on gameplay impact
4. **Create regeneration tasks** for each priority tier

---

## Notes

This audit reveals the scope of what was generated BEFORE the design system existed. The Icon Bible wasn't just "nice to have" — it's essential infrastructure that prevents ~200+ assets from being inconsistent, unmaintainable, and impossible to scale.

The regeneration work is ongoing and will be tracked as a separate task series under the design system framework.
