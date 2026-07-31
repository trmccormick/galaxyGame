---
date_created: 2026-07-19
type: DESIGN_REFERENCE
status: active
purpose: Map ChatGPT research sessions to asset generation specifications
hierarchy_level: 2 (sits below VISUAL_PHILOSOPHY.md, above Icon Bible)
---

# Design Research Index — Asset Generation Guidance

**Foundation**: [VISUAL_PHILOSOPHY.md](VISUAL_PHILOSOPHY.md) (the "why")

This document is the bridge between philosophy and implementation. It maps the 10 ChatGPT research sessions to **specific asset generation work**.

When creating assets:
1. Read VISUAL_PHILOSOPHY.md (foundation)
2. Reference this index for session mappings
3. Read detailed research session file for specifications
4. Use Icon Bible for framework
5. Generate following research specifications

---

## Research Session → Asset Generation Mapping

### Session 1: Architectural Patterns
**File**: `2026-07-15-ANALYSIS-chatgpt-design-extraction.md`
**Applies To**: Overall project architecture, not asset generation
**Key Outputs**:
- Multi-view simulation lens (Monitor/Surface/TerrainForge abstraction)
- Zoom hierarchy (persistent objects across levels)
- Top-down simulation construction
- Tile engine as implementation detail

**Asset Impact**: Objects must work at multiple abstraction levels (e.g., HRV-400 harvester exists in Monitor as "count", Surface as "tile icon", TerrainForge as "individual sprite")

---

### Session 2: Catalog Architecture & Render Standards ⭐
**File**: `2026-07-15-ANALYSIS-SESSION2-asset-design-catalog.md`
**Applies To**: ALL component catalog renders
**Key Specifications**:
- **Catalog Render Standard**: White background, two views (front isometric + rear isometric), no text/annotations
- **Three Image Types**: (1) Catalog Render (product photography), (2) Engineering Drawing (callouts/dimensions), (3) Blueprint (section cuts/exploded diagrams)
- **Visual Recognition Rule**: Players should identify components purely from visual cues after 20 hours
- **Consistency Goal**: All 400+ assets feel like one manufacturer's product line

**Generation Guidance**:
```
When generating catalog renders:
1. Use white background
2. Show exactly two isometric views (front + rear)
3. No text, no dimensions, no arrows on the render itself
4. Consistent lighting/perspective/scale across all assets
5. Follow material specifications from Material Library
```

**Blocking Task**: Generate catalog render standards document before batch asset generation

---

### Session 3: Asset Organization & Terrain Classification ⭐
**File**: `2026-07-15-ANALYSIS-SESSION3-asset-organization.md`
**Applies To**: Terrain/biome/surface layer rendering
**Key Specifications**:
- **Asset Organization by Purpose** (NOT by biome):
  - `assets/terrain/` (geological base + features)
  - `assets/biosphere/` (living layers)
  - `assets/resources/` (item sprites)
  - `assets/units/` (unit sprites)
  - etc.
- **Three-Tier Terrain Classification**:
  - Layer 0: Geological Base (opaque: regolith, dust, basalt, rock, ice, volcanic)
  - Layer 1: Geological Features (transparent overlays: crater, rilles, boulders, lava flows, crevasses)
  - Layer 2: Biosphere (living: forest, grassland, jungle, swamp, savanna, tundra)
- **Canonical Biome Compression**: 30+ entries → ~16 canonical tiles

**Generation Guidance**:
```
Organize all terrain assets by Layer 0, 1, 2.
Generate in priority order:
1. Geological Base tiles (Layer 0)
2. Geological Features overlays (Layer 1)
3. Biosphere tiles (Layer 2)

Use canonical biome list (Session 10) for consistent naming.
```

**Blocking Task**: Compress/canonicalize biome list before terrain generation

---

### Session 4: Vehicle Variant Architecture
**File**: `2026-07-15-ANALYSIS-SESSION4-vehicle-variants.md`
**Applies To**: Vehicle/spacecraft asset generation
**Key Specifications**:
- **Variant Pattern**: Same base hull, different equipment packages (e.g., skimmer vs. tanker)
- **Orientation Constraint**: All variants use same camera angle as base render
- **File Structure**: Separate JSON per variant (not unified file with sub-variants)
- **Equipment-Driven Differentiation**: Visual differences come from mission-specific equipment, not geometry

**Generation Guidance**:
```
For each vehicle family:
1. Generate base render (locked orientation)
2. Create variant renders (same orientation, different equipment)
3. Store as separate JSON files per variant
4. Highlight equipment differences visually
```

---

### Session 5: Visual Identity & Corporate Branding ⭐
**File**: `2026-07-15-ANALYSIS-SESSION5-visual-identity.md`
**Applies To**: Faction logos, corporate branding, mission patches, splash screens
**Key Specifications**:
- **Three Pillars of Visual Identity**: Futuristic but grounded, realistic, strategy-focused
- **Grounded Sci-Fi Aesthetic**: NASA/ESA aesthetic, not Star Trek fantasy
- **Three Faction Logos**: Terraformers (leaf + planet), Wormhole Engineers (ripple + grid), Isolationists (dark planet + shield)
- **Mission Patches**: NASA-style badges, readable at small sizes, circular/hexagonal format
- **Game Art Concepts**: Wormhole stabilization scene (splash screen), satellite approaching wormhole near gas giant

**Generation Guidance**:
```
All visual branding must follow grounded sci-fi aesthetic:
- Realistic, plausible technology (think aerospace, not fantasy)
- Minimalist iconography for logos
- NASA-style design language for mission patches
- High-resolution splash screens communicating scale + danger
```

**Blocking Task**: Create visual identity guidelines document before corporate branding generation

---

### Session 6: Manufacturing Methods & Tech Level Progression ⭐
**File**: `2026-07-15-ANALYSIS-SESSION6-blueprint-manufacturing.md`
**Applies To**: ALL component design, tech level variants
**Key Specifications**:
- **Six Manufacturing Methods** (each with distinct visual language):
  1. Precision Factory (aerospace-grade, clean, refined)
  2. Additive Construction (layer lines, modular)
  3. Cast Construction (rough, organic flow patterns)
  4. Modular Assembly (visible fasteners, bolted)
  5. Heavy Industrial (crude, oversized, simple)
  6. Bootstrap/Frontier (improvised, thick members, visible structure)
- **Tech Levels 1-4+**: Each has specific visual language
  - TL1: Bootstrap manufacturing (thick, exposed, layered)
  - TL2: Mature industrial (cleaner, fewer visible fasteners)
  - TL3: Advanced engineering (integrated systems, polished)
  - TL4+: Automated/AI manufacturing (seamless, exotic materials)
- **Blueprint Schema Extension**: Visualization section with `catalog_style`, `technology_level`, `manufacturing_style`, `component_class`, `visual_characteristics`

**Generation Guidance**:
```
For each component/tech level variant:
1. Reference manufacturing method visual language
2. Apply appropriate tech level characteristics
3. Store in blueprint `visualization` section (not just image)
4. Only 3 fields change during tech progression (version, tech_level, manufacturing_style)
```

**Blocking Task**: Formalize manufacturing methods visual language before component generation

---

### Session 7: Corporate Ecosystem
**File**: `2026-07-15-ANALYSIS-SESSION7-corporate-branding.md`
**Applies To**: Corporation logos, themed assets
**Key Specifications**:
- **10 Corporations** across three categories:
  - Development (LDC, MDC, VDC, TDC, SDC)
  - Logistics (AstroLift, Vector Hauling, Zenith Orbital, WTC)
  - Infrastructure (Wormhole Station)
- **Each Corporation Has Unique Visual Identity**:
  - LDC: Lunar industrial (Earth visible in sky, blue-white lighting)
  - MDC: Mars frontier (red-orange landscape, terraforming)
  - VDC: Elegant atmospheric (golden clouds, aerostat habitats)
  - TDC: Cryogenic hydrocarbon (orange/cyan lighting, methane seas)
  - SDC: System-wide authority (Saturn massive, multiple moons, interplanetary scale)

**Generation Guidance**:
```
When generating corporate branding:
1. Reference corporation-specific visual characteristics
2. Use planetary context (Earth in sky for LDC, Saturn for SDC, etc.)
3. Apply appropriate color palette (blue-white for LDC, orange/cyan for TDC)
4. Create minimalist logos that work at small sizes
```

---

### Session 8: Component Render Specifications ⭐
**File**: `2026-07-15-ANALYSIS-SESSION8-lunar-infrastructure.md`
**Applies To**: Component detail renders, lunar infrastructure
**Key Specifications**:
- **Three-Angle Pattern**: Perspective view + Side profile + Functional detail view
- **Functional Design Language**: Every visible element serves purpose (thick walls = pressure, clamps = assembly, ribs = reinforcement)
- **Material Specification Pattern**: (1) Primary exterior, (2) Functional hardware, (3) Structural reinforcement
- **Pressurized Components**: Matte industrial composite exterior + metallic seal hardware + reinforced ribs
- **Foundation/Ground Components**: Rough regolith composite + abrasive texture + metal reinforcement at load points
- **Detail Views Demonstrate Function**: Pressurized components show interior connection rings; foundation blocks show underside anchoring

**Generation Guidance**:
```
For each component render:
1. Show three angles (perspective + side profile + functional detail)
2. Choose detail view based on primary function
3. Apply appropriate material specification pattern
4. Ensure all visible structure justified by function
5. Use multi-angle image format (all three in single render)
```

**Blocking Task**: Create component render prompt templates before batch generation

---

### Session 9: Prompt Template & Parametric Generation ⭐
**File**: `2026-07-15-ANALYSIS-SESSION9-component-catalog.md`
**Applies To**: AI generation automation
**Key Specifications**:
- **Base Prompt Template** (parametric, 5 variables):
```
Industrial component render of a [ITEM_NAME], made from [MATERIAL_DESCRIPTION].

Show multiple angles of the same object in a single image:
- perspective view
- side view
- end cross-section view

The object is rugged and utilitarian, built using [CONSTRUCTION_METHOD].

Material appearance:
- [TEXTURE_DETAILS]
- [COLOR_VARIATION]

Lighting:
- neutral studio lighting
- soft shadows
- dark or transparent background

Style:
- realistic, industrial, not futuristic or sleek
- no text, no labels, no UI
```
- **Five Template Variables** map to blueprint JSON fields
- **Material→Quality→Structural Behavior Pipeline**: Core design flow
- **Systems Pass Over Schema Compliance**: Gameplay completeness > template compliance

**Generation Guidance**:
```
When generating assets via AI:
1. Use base prompt template (above)
2. Fill 5 variables from blueprint JSON
3. Verify output quality metrics set (pressure rating, tensile strength, etc.)
4. Test material→quality→structural behavior pipeline
5. Automate via PromptBuilder service (if available)
```

**Implementation**: Build PromptBuilder Rails service to parametrize template

---

### Session 10: Biome Layer Architecture & Canonical Compression ⭐
**File**: `2026-07-15-ANALYSIS-SESSION10-biome-tilesheet.md`
**Applies To**: Biome/terrain tile generation
**Key Specifications**:
- **Two-Layer Rendering Model**:
  - Layer 0: Terrain/geology (elevation-based colors currently, tiles needed)
  - Layer 1: Biome/vegetation (flat hex colors currently, tiles needed)
- **Current State**: Flat hex colors only, no biome tiles
- **Canonical Biome Compression**: 30+ entries → ~16 canonical tiles
- **Canonical Mapping**:
  ```
  Ice Group: arctic/polar_ice/snow/glacier → smooth_ice_sheet_white, pack_ice, smooth_ice, glacier_texture
  Forest Group: boreal/temperate/tropical → forest.png, tropical_jungle.png
  Wet Group: wetlands/marsh/bog → swamp.png
  Grass Group: grassland/steppe → grasslands.png, plains.png
  Mountain Group: alpine/montane/highlands → mountains_snow_covered.png, mountains.png, rocky_plains.png
  ```
- **Design Decision Open**: Desert/tundra belong to Layer 0 or Layer 1?

**Generation Guidance**:
```
Priority order for biome tile generation:
1. Finalize canonical mapping (16 tiles, resolve Layer 0/1 ambiguity for desert/tundra)
2. Generate terrain family tiles (Layer 0)
3. Generate biome overlay tiles (Layer 1)
4. Replace flat hex colors with actual tile renders
5. Test zoom transitions (zoomed out = color map, zoomed in = tiles)
```

**Blocking Task**: Decide desert/tundra layer assignment before generation

---

## Cross-Session Themes

### Theme: Consistency Through Constraints
**Sessions**: 2, 5, 6, 9
**Principle**: Define standards upfront (lighting, angle, material, manufacturing method), then apply them uniformly across all assets. Constraints prevent stylistic drift.

### Theme: Parametric Generation
**Sessions**: 6, 8, 9
**Principle**: Every asset has a prompt template with 5-10 variables that map to blueprint data. Automate generation through PromptBuilder rather than hand-crafting each prompt.

### Theme: Functional Design Language
**Sessions**: 3, 4, 6, 8
**Principle**: Assets communicate function visually (pressure rating shown by wall thickness, manufacturing method shown by surface finish, etc.). No decorative elements.

### Theme: Layered Composition Over Asset Duplication
**Sessions**: 3, 6, 10
**Principle**: Build complex visuals by layering simple assets (Layer 0 + Layer 1 + Layer 2 = varied appearance) rather than creating separate assets per variation.

---

## Asset Generation Workflow

**Suggested execution order** (using research specifications as guidance):

1. **Session 5**: Create Visual Identity Guidelines (color palettes, grounded sci-fi aesthetic)
2. **Session 2**: Formalize Catalog Render Standard (white bg, two views, consistency rules)
3. **Session 6**: Document Manufacturing Methods Visual Language (6 methods × 4 tech levels = 24 distinct looks)
4. **Session 10**: Resolve biome canonical mapping (16 tiles, Layer 0/1 assignments)
5. **Session 3**: Generate Terrain Layer 0 tiles (geological base)
6. **Session 8**: Create Component Render Specification (3-angle pattern, functional detail views)
7. **Session 9**: Build PromptBuilder service (parametric prompt generation)
8. **Session 9 + 8**: Batch generate components using templates
9. **Session 10 + 3**: Generate biome overlays (Layer 1)
10. **Session 7**: Create corporate branding assets (faction logos, corporate themes)

---

## Reference: Full Research Session List

| Session | File | Focus | Priority |
|---------|------|-------|----------|
| 1 | `2026-07-15-ANALYSIS-chatgpt-design-extraction.md` | Architecture | Reference |
| 2 | `2026-07-15-ANALYSIS-SESSION2-asset-design-catalog.md` | Catalog renders | 🔴 HIGH |
| 3 | `2026-07-15-ANALYSIS-SESSION3-asset-organization.md` | Terrain/biome | 🔴 HIGH |
| 4 | `2026-07-15-ANALYSIS-SESSION4-vehicle-variants.md` | Vehicle design | 🟡 MEDIUM |
| 5 | `2026-07-15-ANALYSIS-SESSION5-visual-identity.md` | Branding | 🟡 MEDIUM |
| 6 | `2026-07-15-ANALYSIS-SESSION6-blueprint-manufacturing.md` | Manufacturing methods | 🔴 HIGH |
| 7 | `2026-07-15-ANALYSIS-SESSION7-corporate-branding.md` | Corporations | 🟡 MEDIUM |
| 8 | `2026-07-15-ANALYSIS-SESSION8-lunar-infrastructure.md` | Component renders | 🔴 HIGH |
| 9 | `2026-07-15-ANALYSIS-SESSION9-component-catalog.md` | Prompt templates | 🔴 HIGH |
| 10 | `2026-07-15-ANALYSIS-SESSION10-biome-tilesheet.md` | Biome compression | 🔴 HIGH |

---

## How to Use This Index

**When creating a new asset generation task**:
1. Identify asset type (component, biome, vehicle, branding, etc.)
2. Find corresponding session(s) in this index
3. Read detailed specification from referenced session file
4. Reference both the Icon Bible AND this index in your task prompt
5. Use specifications as acceptance criteria

**Example**:
- **Task**: Generate lunar habitat component
- **Sessions to consult**: Session 6 (manufacturing methods), Session 8 (component render specs), Session 9 (prompt template)
- **Key specs**: Use "Precision Factory" visual language for Mk3 tech level, show 3 angles (perspective + side + interior connection detail), apply material pattern (composite exterior + metallic hardware), use parametric prompt template with bootstrap values

---

## Status

- ✅ Index created and mapped
- ⏳ Visual Identity Guidelines (from Session 5): Not yet formalized as standalone document
- ⏳ Manufacturing Methods Visual Language (from Session 6): Not yet detailed as standalone document
- ⏳ Component Render Specification (from Session 8): Not yet as standalone prompt guide
- ⏳ PromptBuilder Service (from Session 9): Not yet implemented
- 🔴 Biome Canonical Mapping (from Session 10): Decision needed (desert/tundra Layer 0 or 1?)

---

## Notes

This index serves as a **bridge document** between research (10 ChatGPT sessions) and execution (asset generation tasks). When the Icon Bible describes "visual complexity levels," this index provides specific specs from Sessions 2, 8, 9 on HOW to generate those levels. When Icon Bible mentions "manufacturing origin variation," this index points to Session 6's detailed manufacturing method visual language.

Use this index + Icon Bible together: Icon Bible = philosophy, this index = specifications, research sessions = detailed details.
