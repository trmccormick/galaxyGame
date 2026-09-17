---
date_created: 2026-08-25
type: GENERATION_TEST_SPECIFICATION
status: FROZEN (2026-08-25)
subject: 3d_printed_ibeam_mk1
purpose: Controlled generation test — compare ChatGPT vs Gemini output against data-driven specification
test_question: "Can the same existing data-driven specification produce visually coherent and stylistically compatible results in both generators?"
frozen: true
frozen_date: 2026-08-25
---

# Controlled Generation Test Specification — 3D-Printed I-Beam Mk1

## Executive Summary

This document produces a controlled generation specification for `3d_printed_ibeam_mk1` to test whether existing component blueprint data can be converted into reproducible visual-generation prompts that produce coherent results across **ChatGPT image generation** and **Gemini image generation**.

The Mk1–Mk5 blueprints are authoritative regardless of git version-control status. The `data/` directory is intentionally gitignored because JSON blueprints and generated system data are treated as rebuildable data, not source code.

## Deliverables

| # | File | Purpose | Status |
|---|------|---------|--------|
| 1 | `ibeam_mk1_generation_test_spec.md` (this file) | Full test specification with blueprint analysis, derived requirements, unknowns, and prompts | **FROZEN** |
| 2 | `ibeam_mk1_prompt_primary.txt` | Canonical renderer-neutral primary production render prompt | **FROZEN** |
| 3 | `ibeam_mk1_prompt_quadrant.txt` | Optional four-quadrant engineering reference prompt | **FROZEN** |
| 4 | `ibeam_mk1_generation_evaluation.md` | Objective comparison rubric for ChatGPT vs Gemini outputs | **FROZEN** |

## Next Step

Run the actual **ChatGPT vs. Gemini controlled generation run** using the frozen prompts above. Evaluate outputs against the rubric in `ibeam_mk1_generation_evaluation.md`. Record divergences — do not rewrite the specification to make generators agree.

---

## 1. SOURCE FILES EXAMINED

### Authoritative Blueprint Data (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 1 | `3d_printed_ibeam_mk1_bp.json` | `data/json-data/blueprints/components/structural/` | **AUTHORITATIVE** — Mk1 v1.3 |
| 2 | `3d_printed_ibeam_mk1_bp_v1.4.json` | `data/json-data/blueprints/components/structural/` | **AUTHORITATIVE** — Mk1 v1.4 migration (adds quality metrics) |
| 3 | `3d_printed_ibeam_mk2_bp.json` | `data/json-data/blueprints/components/structural/` | Authoritative — Mk2 reference |
| 4 | `3d_printed_ibeam_mk3_bp.json` | `data/json-data/blueprints/components/structural/` | Authoritative — Mk3 reference |
| 5 | `3d_printed_ibeam_mk4_bp.json` | `data/json-data/blueprints/components/structural/` | Authoritative — Mk4 reference (first with populated dimensions) |
| 6 | `3d_printed_ibeam_mk5_bp.json` | `data/json-data/blueprints/components/structural/` | Authoritative — Mk5 reference |

### Architecture & Pipeline Documents
| # | File | Path | Relevance |
|---|------|------|-----------|
| 7 | ASSET_GENERATION_ARCHITECTURE.md | `docs/reference/asset-generation/ASSET_GENERATION_ARCHITECTURE.md` | Pipeline architecture, PromptBuilder contract |
| 8 | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md | `docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | Render template (camera, background, output format) |
| 9 | VISUAL_PROFILE_precision_industrial_v1.md | `docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md` | Visual profile — see §3.2 for conflict analysis |
| 10 | ASSET_PROMPT_COMPILER_CONTRACT.md | `docs/reference/asset-generation/ASSET_PROMPT_COMPILER_CONTRACT.md` | Dependency chain, validation rules |
| 11 | VISUAL_DEFINITION_TEMPLATE.md | `docs/reference/asset-generation/VISUAL_DEFINITION_TEMPLATE.md` | Visual Definition schema |
| 12 | VISUAL_PHILOSOPHY.md | `docs/reference/asset-generation/VISUAL_PHILOSOPHY.md` | 9 foundational principles (tech level progression) |
| 13 | DESIGN_RESEARCH_INDEX.md | `docs/reference/asset-generation/DESIGN_RESEARCH_INDEX.md` | Session mappings (Sessions 2, 6, 8, 9 relevant) |

### Prompt Templates & Experimental Prompts
| # | File | Path | Relevance |
|---|------|------|-----------|
| 14 | ibeam-prompt.md | `docs/reference/asset-generation/ibeam-prompt.md` | Existing ibeam four-quadrant engineering reference format |
| 15 | panel-prompt.md | `docs/reference/asset-generation/panel-prompt.md` | Similar four-quadrant format (regolith panel) — structural precedent |
| 16 | rh400-prompt-template.md | `docs/reference/asset-generation/rh400-prompt-template.md` | Three-pass output structure, critical rules |

### Existing Visual References (NOT canonical geometry)
| # | File | Path | Notes |
|---|------|------|-------|
| 17 | 3d_printed_ibeam_mk1.png | `data/images/catalog/components/structural/` | **Visual reference only** — prior generation result |
| 18 | 3d_printed_ibeam_mk2.png | `data/images/catalog/components/structural/` | Visual reference only |
| 19 | 3d_printed_ibeam_mk3.png | `data/images/catalog/components/structural/` | Visual reference only |
| 20 | 3d_printed_ibeam_mk4.png | `data/images/catalog/components/structural/` | Visual reference only |

> **Important**: Previous Gemini/ChatGPT renders are visual references/concepts. They are NOT canonical geometry. The blueprints define the canonical data; images are experimental outputs to be evaluated against that data.

---

## 2. CANONICAL MK1 DATA — BLUEPRINT FACTS ONLY

### Source: `3d_printed_ibeam_mk1_bp.json` (v1.3) + `3d_printed_ibeam_mk1_bp_v1.4.json` (v1.4)

#### A. IDENTIFIER & CLASSIFICATION
| Field | Value | Confidence |
|-------|-------|-----------|
| `id` | `3d_printed_ibeam_mk1` | Blueprint fact |
| `name` | 3D-Printed I-Beam Mk1 | Blueprint fact |
| `category` | structural | Blueprint fact |
| `subcategory` | framework | Blueprint fact |
| `template_compliance` | component_blueprint_v1.4 (v1.4 file) / component_blueprint (v1.3 file) | Blueprint fact |

#### B. DESCRIPTION & MANUFACTURING PROCESS
| Field | Value | Confidence |
|-------|-------|-----------|
| `description` | "Basic structural beams printed using molten lunar regolith (waste regolith preferred). No external binder required, relying on heat sintering and melting of regolith." | Blueprint fact |
| **Key process** | Heat sintering + melting of regolith — NO external binder | Blueprint fact |
| **Technology required** | `regolith_3d_printing` | Blueprint fact |

#### C. MATERIAL REQUIREMENTS
| Field | Value | Confidence |
|-------|-------|-----------|
| Primary material | regolith, 75 kg | Blueprint fact |
| Preferred type | depleted_regolith (preference_bonus: 0.03) | v1.4 only |
| Acceptable types | raw_regolith, processed_regolith, depleted_regolith | Blueprint fact |
| Composition constraint — SiO2 | >= 40% (v1.3) / min: 0.40 (v1.4) | Blueprint fact |
| Composition constraint — FeO | <= 15% (v1.3) / max: 0.15 (v1.4) | Blueprint fact |
| Origin body | any | Blueprint fact |
| Quality modifiers (v1.4) | raw_regolith: 0.95, processed_regolith: 1.05, depleted_regolith: 1.0 | v1.4 only |

#### D. OUTPUT SPECIFICATIONS
| Field | Value | Confidence |
|-------|-------|-----------|
| `weight_kg` | 69 | Blueprint fact |
| `volume_m3` | 0 (v1.3) / not populated | **UNPOPULATED** — see §5 |
| `material_efficiency` | 0.92 | Blueprint fact |
| Quality — structural_integrity | 0.85 | v1.4 only |
| Quality — precision | 0.90 | v1.4 only |
| Quality — durability | 0.80 | v1.4 only |

#### E. PRODUCTION PARAMETERS
| Field | Value | Confidence |
|-------|-------|-----------|
| `production_time_hours` | 2 | Blueprint fact |
| `required_tools` | 3d_printer | Blueprint fact |
| `required_skills` | 3d_printing_operation, structural_engineering | Blueprint fact |
| `printer_compatibility` | categories: ["structural"], material_types: ["regolith"] | Blueprint fact |

#### F. WASTE PRODUCTS
| Material | Percentage | Confidence |
|----------|-----------|-----------|
| manufacturing_dust | 5% | Blueprint fact |
| offgas_volatiles | 3% | Blueprint fact |

#### G. PHYSICAL PROPERTIES (Mk1)
| Field | Value | Confidence |
|-------|-------|-----------|
| `mass_kg` | 69 | Blueprint fact |
| `volume_m3` | **0 (UNPOPULATED)** | **DATA GAP** — see §5 |
| `dimensions.length_m` | **0 (UNPOPULATED)** | **DATA GAP** — see §5 |
| `dimensions.width_m` | **0 (UNPOPULATED)** | **DATA GAP** — see §5 |
| `dimensions.height_m` | **0 (UNPOPULATED)** | **DATA GAP** — see §5 |
| `durability_rating` | "" (empty string) | **DATA GAP** — see §5 |
| `environmental_resistance` | "" (empty string) | **DATA GAP** — see §5 |

#### H. MK1-MK5 PROGRESSION CONTEXT (for visual progression reference)
| Mk | Regolith (kg) | Aluminum Alloy (kg) | Binding Agent (kg) | Carbon/Nano Additive (kg) | Weight (kg) | Dimensions (L×W×H m) | Durability | Tech Indicators |
|----|---------------|--------------------|--------------------|--------------------------|-------------|---------------------|------------|----------------|
| **Mk1** | 75 | 0 | 0 | 0 | 69 | 0×0×0 (unpopulated) | basic (v1.4 quality: 0.80) | regolith_3d_printing |
| **Mk2** | 70 | 7 | 2 | 0 | 77 | 0×0×0 (unpopulated) | (empty) | +regolith_3d_printing |
| **Mk3** | 75 | 15 | 5 | 3 (carbon_fiber) | 98 | 0×0×0 (unpopulated) | (empty) | +regolith_3d_printing |
| **Mk4** | 65 | 15 | 5 | 3 (CNT powder) | 100 | 5.0×0.3×0.3 | ultra_high | +cnt_processing |
| **Mk5** | 60 | 15 | 5 | 2 (nano_additives) + 2 (CNT powder/fiber) | 101 | 5.0×0.3×0.3 | maximum | +advanced_regolith_processing, nano_materials |

> **Key observation**: Mk4 and Mk5 are the first Mks with populated physical dimensions (5.0m × 0.3m × 0.3m). Mk1-Mk3 dimensions are unpopulated in their blueprints. This is a data gap in the blueprints, not an ambiguity about design intent — later Mks clarify the intended scale.

---

## 3. DERIVED VISUAL REQUIREMENTS

### A. From Blueprint Facts (directly supported)

| Requirement | Source | Derivation |
|------------|--------|-----------|
| **Form: I-beam cross-section** | `name` = "3D-Printed I-Beam" + `category` = structural | The name explicitly identifies the object as an I-beam — a standard structural shape with flanged top/bottom edges and connecting web plate |
| **Material appearance: regolith composite** | `description` = "molten lunar regolith... heat sintering and melting" + `material` = regolith | The manufacturing process (heat sintering of regolith) produces a granular, matte surface — not polished metal or smooth plastic |
| **No binder appearance** | `description` = "No external binder required" | Pure regolith sintering means the material should look like sintered planetary regolith — rough, porous, unbound grain structure |
| **Mk1 technology level: early/rough** | Mk1 is first in progression; VISUAL_PHILOSOPHY.md Mk1 = "Improvised, thick members, visible layer lines, oversized components" | First-generation additive construction should show prominent manufacturing artifacts |
| **Weight/mass context: 69 kg** | `weight_kg` = 69, `mass_kg` = 69 | The object has substantial mass — it is heavy infrastructure material, not lightweight aerospace hardware |
| **Material efficiency: 0.92** | `material_efficiency` = 0.92 | 8% material loss (waste) — consistent with early-stage additive manufacturing tolerances |

### B. From Architecture Documents (render template requirements)

| Requirement | Source | Derivation |
|------------|--------|-----------|
| **Camera: isometric perspective** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 + ibeam-prompt.md | Single object render for production use |
| **Framing: ~75% canvas, centered** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 | Standard production asset framing |
| **Lighting: soft neutral studio, cool/even/diffused** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 + ibeam-prompt.md | Highlights surface texture without harsh shadows |
| **Background: transparent (alpha channel)** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 | Required for sprite/animation pipeline |
| **No text/labels/logos/borders** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 prohibition list | Clean production asset |
| **Output: high-res PNG** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 | Production game asset format |

### C. From Visual Philosophy (tech level progression)

| Requirement | Source | Derivation |
|------------|--------|-----------|
| **Mk1 = rough, visible layer lines** | VISUAL_PHILOSOPHY.md Mk1 description | First-generation additive construction shows manufacturing process prominently |
| **Mk1 = thick members, oversized components** | VISUAL_PHILOSOPHY.md Mk1 description | Early tech level has conservative engineering margins |
| **Industrial, not aerospace** | `category` = structural + no binder process | Infrastructure-grade material, not precision-machined hardware |

---

## 4. VISUAL PROFILE CONFLICT ANALYSIS

### The precision_industrial_v1 Conflict

The ASSET_PROMPT_COMPILER_CONTRACT.md assigns ibeam Mk1 to `precision_industrial_v1`. However, this profile explicitly **excludes** the ibeam's actual manufacturing appearance:

| precision_industrial_v1 Requires | I-beam Actually Shows | Match? |
|---------------------------------|----------------------|--------|
| Clean white/light-gray paneling | Dark gray-brown granular matte | ❌ NO |
| Precision-machined surfaces | Rough, porous, prominent layer lines | ❌ NO |
| Minimal visible construction seams | Very prominent layer lines (Mk1) | ❌ NO |
| NASA/ESA aerospace-industrial aesthetic | Infrastructure-grade regolith sintering | ❌ NO |
| Black/yellow hazard striping | None specified in blueprint | ❌ NO |

**Resolution**: The ibeam blueprints have **no `visual_profile` field**. The visual profile is handled at the Visual Definition layer, not in the blueprint. The ibeam's actual manufacturing process (heat-sintered regolith with no binder) produces a fundamentally different appearance than precision_industrial_v1 describes. A separate visual profile for "additive_construction / regolith_composite" would be needed before production use — but this is a **separate architecture question**, not a blocker for the generation test.

For this test, the visual requirements are derived from:
1. The blueprint's explicit description of the manufacturing process (heat sintering, no binder)
2. The Visual Philosophy's Mk1 tech level characteristics
3. The render template's camera/background/lighting requirements

---

## 5. UNKNOWN / UNSPECIFIED — INTENTIONALLY LEFT OPEN

The following values are **genuinely unspecified** in the blueprints and architecture documents. They are NOT filled with guesses:

| Unknown | Why Unspecified | Impact on Test |
|---------|----------------|---------------|
| **Physical dimensions (Mk1)** | Mk1-Mk3 blueprints have `dimensions` all set to 0 — unpopulated data field. Only Mk4+ have dimensions (5.0×0.3×0.3m). | The generator will infer scale from context. This is a test variable — different generators may produce different aspect ratios. Acceptable for comparison purposes. |
| **Exact flange width / web thickness ratios** | Not specified in any blueprint or architecture document. | The I-beam silhouette will be inferred by the generator. As long as the I-shape is recognizable, this is acceptable. |
| **Layer line pitch / frequency** | Not quantified anywhere. VISUAL_PHILOSOPHY.md says "visible layer lines" for Mk1 but gives no quantitative spec. | The generator will interpret "prominent layer lines" differently. This is a test variable. |
| **Surface roughness Ra value** | Not quantified. Blueprint describes process (heat sintering) not surface metrology. | Acceptable — the visual effect ("rough, porous") is specified qualitatively. |
| **Exact color values (hex/RGB)** | Architecture explicitly prohibits literal hex values; uses semantic roles only. | The generator will produce its own color interpretation of "dark gray-brown granular matte." Acceptable for comparison. |
| **Connection hole spacing / bolt pattern** | Not specified in blueprint. Mk1 has no `variants` array. | Not relevant to the primary production render test. Would matter for engineering reference variant. |
| **Durability rating (Mk1)** | Empty string in v1.3; v1.4 has quality.durability: 0.80 but this is a simulation metric, not a visual spec. | Not directly relevant to visual generation. |
| **Environmental resistance** | Empty string in blueprint. | Not relevant to visual generation. |
| **Manufacturing origin (Earth vs Luna)** | Blueprint says `origin_body: "any"` — location-agnostic by design. Renders show lunar appearance but blueprint does not restrict. | The prompt should NOT specify a planetary context, consistent with the location-agnostic principle. |

---

## 6. CHATGPT IMAGE GENERATION PROMPT

### Primary Test — Production Render (Single Object, Transparent Background)

```
Generate a single structural I-beam component for GalaxyGame, a hard-sci-fi industrial space settlement simulation game.

SUBJECT:
A Mk1 3D-printed regolith structural I-beam — the primary load-bearing support member for early-stage construction. Standard I-shaped cross-section with wide flanged top and bottom edges connected by a vertical web plate. The beam is long and rectangular in profile, with the characteristic I-beam silhouette recognizable from any angle.

MANUFACTURING APPEARANCE (Mk1 — Heat-Sintered Regolith, No Binder):
- Surface: Dark gray-brown granular matte finish, clearly showing the rough porous texture of heat-sintered regolith composite
- Layer lines: Prominent, deep horizontal layer lines running the full length of the beam — this is a first-generation Mk1 print, so the additive manufacturing process should be very visible
- Edges: Slightly irregular at the flange edges, consistent with early-stage 3D printing tolerances and 8% material loss (waste)
- Overall impression: Heavy, functional, field-fabricated infrastructure material — not precision-machined aerospace hardware. The object weighs 69 kg and is built from sintered planetary regolith with no external binder.

RECOGNITION FEATURES (must be visible):
- I-shaped cross-section profile (flanged top and bottom edges with connecting web plate)
- Prominent horizontal layer lines across all surfaces
- Dark granular matte surface texture consistent with sintered regolith
- Slightly irregular flange edges (early manufacturing tolerance)

RENDER REQUIREMENTS:
- Single object only, fully visible, no cropping
- Isometric perspective view (approximately 30-degree angle showing top and side faces)
- Object centered within the canvas, occupying approximately 75% of the frame
- Soft neutral studio lighting — cool, even, diffused illumination that highlights the granular surface texture without harsh shadows or specular highlights
- Physically accurate materials — the regolith composite should look like sintered planetary regolith, not metal or plastic

BACKGROUND:
- Completely transparent background (alpha channel)
- No ground plane, no terrain, no shadows beyond a subtle contact shadow beneath the object
- No sky, no stars, no environment, no props
- No text, no labels, no annotations, no logos, no borders, no watermark

OUTPUT:
- Transparent PNG
- High resolution suitable for production game assets
- Moderate detail level appropriate for Mk1 technology (rough, visible layer lines)
```

---

## 7. GEMINI IMAGE GENERATION PROMPT

### Primary Test — Production Render (Same Object, Same Requirements)

```
Generate a single structural I-beam component for GalaxyGame, a hard-sci-fi industrial space settlement simulation game.

SUBJECT:
A Mk1 3D-printed regolith structural I-beam — the primary load-bearing support member for early-stage construction. Standard I-shaped cross-section with wide flanged top and bottom edges connected by a vertical web plate. The beam is long and rectangular in profile, with the characteristic I-beam silhouette recognizable from any angle.

MANUFACTURING APPEARANCE (Mk1 — Heat-Sintered Regolith, No Binder):
- Surface: Dark gray-brown granular matte finish, clearly showing the rough porous texture of heat-sintered regolith composite
- Layer lines: Prominent, deep horizontal layer lines running the full length of the beam — this is a first-generation Mk1 print, so the additive manufacturing process should be very visible
- Edges: Slightly irregular at the flange edges, consistent with early-stage 3D printing tolerances and 8% material loss (waste)
- Overall impression: Heavy, functional, field-fabricated infrastructure material — not precision-machined aerospace hardware. The object weighs 69 kg and is built from sintered planetary regolith with no external binder.

RECOGNITION FEATURES (must be visible):
- I-shaped cross-section profile (flanged top and bottom edges with connecting web plate)
- Prominent horizontal layer lines across all surfaces
- Dark granular matte surface texture consistent with sintered regolith
- Slightly irregular flange edges (early manufacturing tolerance)

RENDER REQUIREMENTS:
- Single object only, fully visible, no cropping
- Isometric perspective view (approximately 30-degree angle showing top and side faces)
- Object centered within the canvas, occupying approximately 75% of the frame
- Soft neutral studio lighting — cool, even, diffused illumination that highlights the granular surface texture without harsh shadows or specular highlights
- Physically accurate materials — the regolith composite should look like sintered planetary regolith, not metal or plastic

BACKGROUND:
- Completely transparent background (alpha channel)
- No ground plane, no terrain, no shadows beyond a subtle contact shadow beneath the object
- No sky, no stars, no environment, no props
- No text, no labels, no annotations, no logos, no borders, no watermark

OUTPUT:
- Transparent PNG
- High resolution suitable for production game assets
- Moderate detail level appropriate for Mk1 technology (rough, visible layer lines)
```

---

## 8. OPTIONAL SECOND TEST — Four-Quadrant Engineering Reference

### Justification

The existing `ibeam-prompt.md` documents a four-quadrant engineering reference format used in prior ibeam generation sessions. The panel-prompt.md confirms this is an established pattern for structural components. This format serves documentation purposes, not sprite/asset pipeline purposes. It should be treated as a secondary test only.

### Four-Quadrant Prompt (ChatGPT + Gemini — Identical)

```
Generate a professional technical catalog sheet showing a Mk1 3D-printed regolith structural I-beam for GalaxyGame.

COMPOSITION:
Present as a strict, symmetrical 2x2 grid layout against a seamless neutral light-gray studio background. The sheet is organized as two distinct vertical columns divided by thin dark gray lines. Text-free. No annotations. No labels. No logos.

TOP-LEFT PANEL — Orthographic end view (flange face):
A dead-on orthographic view of the I-beam's flange face, showing the wide top/bottom flanges and connecting web plate in cross-section. The object is fully centered within the panel with consistent padding.

BOTTOM-LEFT PANEL — Side profile view:
A straight side orthographic profile of the full beam length, showing the rectangular web and protruding flanges in true side elevation. Fully centered with consistent padding.

TOP-RIGHT PANEL — Isometric perspective view:
A clean three-quarter isometric view of the full-length I-beam, showing its complete geometry without cropping. The perspective reveals the I-shaped cross-section and full beam length. Fully centered.

BOTTOM-RIGHT PANEL — Opposite end view:
A dead-on orthographic view of the opposite flange face (mirrored from top-left), showing the same I-beam cross-section from the other end. Fully centered.

MATERIAL APPEARANCE (Mk1 heat-sintered regolith):
- Dark gray-brown granular matte surface
- Prominent horizontal layer lines running the full length (first-generation additive construction)
- Rough, porous texture consistent with heat-sintered regolith composite (no external binder)
- Slightly irregular flange edges (early manufacturing tolerance)
- Cool, even, diffused lighting designed to highlight the raw material texture

STYLE:
High-resolution industrial product photography. Extreme detail. Consistent padding around the object in every panel. The entire sheet should read as a professional engineering reference document.
```

---

## 9. SOURCE PROVENANCE FOR EACH PROMPT SECTION

| Prompt Section | Source | Confidence | Derivation Type |
|---------------|--------|-----------|----------------|
| **Subject: I-beam form** | `3d_printed_ibeam_mk1_bp.json` name field + category = structural | **High** — blueprint fact | Blueprint fact |
| **Mk1 heat-sintered regolith (no binder)** | `3d_printed_ibeam_mk1_bp.json` description field | **High** — blueprint fact | Blueprint fact |
| **Dark gray-brown granular matte surface** | ibeam-prompt.md + visual inspection of mk1.png | **High** — confirmed by existing asset | Derived from visual reference |
| **Prominent layer lines (Mk1)** | VISUAL_PHILOSOPHY.md Mk1 ("visible layer lines") + ibeam-prompt.md | **High** — consistent across sources | Derived from philosophy |
| **Heavy, infrastructure-grade impression** | `weight_kg` = 69 + category = structural | **Medium** — inferred from mass + classification | Derived requirement |
| **Slightly irregular edges (early tolerance)** | `material_efficiency` = 0.92 (8% waste) + Mk1 tech level | **Medium** — derived from efficiency metric | Derived requirement |
| **Isometric perspective** | ibeam-prompt.md + rh400-prompt-template.md Pass 1 | **Medium** — ibeam-prompt specifies it, but PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 says "top-down orthographic" | Assumption (conflict between sources) |
| **Transparent background** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 | **High** — explicit in render template | Blueprint fact (architecture doc) |
| **75% canvas framing** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 | **High** — explicit in render template | Blueprint fact (architecture doc) |
| **Soft neutral studio lighting** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 + ibeam-prompt.md | **High** — consistent across templates | Blueprint fact (architecture doc) |
| **No text/labels/logos** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 prohibition list | **High** — explicit in multiple sources | Blueprint fact (architecture doc) |
| **I-beam recognition features** | `3d_printed_ibeam_mk1_bp.json` name + description + visual inspection of mk1-mk4 renders | **High** — confirmed by actual blueprint file | Blueprint fact + visual reference |
| **Four-quadrant format** | ibeam-prompt.md (full 2×2 grid layout) + panel-prompt.md | **High** — explicitly documented | Blueprint fact (prompt template) |
| **Light-gray background for quad sheet** | ibeam-prompt.md | **High** — explicit in ibeam-prompt.md | Blueprint fact (prompt template) |

---

## 10. DIFFERENCES BETWEEN PROPOSED PRODUCTION RENDER AND HISTORICAL EXPERIMENTAL RENDERS

| Aspect | Historical Experimental Renders (mk1-mk4) | Proposed Production Render | Difference |
|--------|------------------------------------------|---------------------------|------------|
| **Background** | White opaque | Transparent (alpha channel) | **Significant** — production template requires transparent; historical renders used white |
| **Composition** | Multi-view collage (isometric + side + end view in one image) | Single isometric view only | **Significant** — production template specifies single object; historical used composite layout |
| **Framing** | Object fills entire canvas as part of multi-view sheet | 75% canvas, centered, isolated | **Moderate** — different framing intent |
| **Format purpose** | Documentation/reference sheet | Sprite/animation source asset | **Significant** — different end use |
| **Lighting** | Cool, even, diffused (matches) | Soft neutral studio lighting (matches) | Consistent |
| **No text/labels** | Yes (matches) | Required (matches) | Consistent |
| **Material appearance** | Dark gray-brown DMLS regolith (matches) | Same specification (matches) | Consistent |
| **Layer line prominence** | Very prominent Mk1 (matches) | Prominent Mk1 (matches) | Consistent |
| **Camera angle** | Isometric + orthographic views | Single isometric perspective | **Moderate** — historical used multiple angles; production uses single view |

### Key Takeaway

The historical ibeam renders are **engineering reference sheets** (multi-view, white background, documentation purpose). The proposed production render is a **single-object sprite source** (transparent background, isolated, production pipeline purpose). These serve different purposes in the asset pipeline. The four-quadrant optional test preserves the historical format for comparison.

---

## 11. RISKS / AMBIGUITIES

### HIGH RISK

| Risk | Description | Impact |
|------|-------------|--------|
| **Mk1-Mk3 physical dimensions unpopulated** | Blueprint has `dimensions` all set to 0 for Mk1-Mk3. Only Mk4+ have dimensions (5.0×0.3×0.3m). Generators will infer scale from context, which may produce inconsistent aspect ratios between ChatGPT and Gemini. | The test should flag if the resulting I-beam proportions look unreasonable (e.g., extremely thin or excessively thick relative to length). This is a known data gap in the blueprints, not a prompt error. |
| **Visual profile conflict unresolved** | The ibeam's actual appearance (heat-sintered regolith) conflicts with `precision_industrial_v1` which explicitly excludes DMLS/3D-printed rough surfaces. The blueprints have no `visual_profile` field — this is handled at the Visual Definition layer. | If the ibeam is meant to be used under precision_industrial_v1 in production, the existing renders are wrong. This is a separate architecture question from the generation test. |
| **Camera angle conflict** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 says "top-down orthographic" but ibeam-prompt.md and existing renders use isometric perspective. The prompt uses isometric to match historical precedent. | Generators may orient the beam differently. This should be noted in the comparison. |

### MEDIUM RISK

| Risk | Description | Impact |
|------|-------------|--------|
| **Layer line interpretation** | "Prominent, deep horizontal layer lines" is qualitative. ChatGPT and Gemini may interpret "prominent" differently — one may show very coarse layers, the other subtle ones. | Acceptable as a test variable — the comparison will reveal how each generator interprets qualitative texture descriptors. |
| **Color interpretation** | "Dark gray-brown granular matte" has no hex values (by architecture design). Generators will produce their own color interpretation. | Acceptable for comparison — consistency between generators matters more than absolute color accuracy. |

### LOW RISK

| Risk | Description | Impact |
|------|-------------|--------|
| **Mk3 roughness regression in historical renders** | Mk3 appears visually rougher than Mk2 in existing renders, contradicting expected progression (Mk1→Mk4 = increasing refinement). | Not relevant to Mk1 test. Should be flagged as a separate data quality issue. |
| **primary_structural_spine.png confusion** | A cylindrical truss structure exists in the same directory — visually distinct from I-beam but could cause confusion about what's an ibeam reference. | Minimal — it's clearly a different object. |

---

## TEST EXECUTION NOTES

### What to Compare After Generation

1. **Visual coherence between generators**: Do ChatGPT and Gemini produce I-beams that look like they belong to the same product family?
2. **Material fidelity**: Does the heat-sintered regolith appearance translate correctly in both generators?
3. **Silhouette consistency**: Is the I-shaped cross-section recognizable in both outputs?
4. **Tech level accuracy**: Does Mk1 read as "first-generation, rough, visible layer lines" in both outputs?
5. **Background transparency**: Does each generator respect the transparent background requirement?
6. **Framing**: Does each generator center the object at approximately 75% canvas?
7. **Proportion inference**: Given unpopulated dimensions, do the resulting aspect ratios look reasonable and consistent between generators?

### If Results Are Incoherent

**Do NOT modify the canonical blueprint to accommodate the image.** Instead, identify which portion of the specification failed:

- Did the generator misinterpret "heat-sintered regolith" as something else? → Material description needs clarification
- Did the I-beam silhouette not read clearly? → Recognition features need strengthening
- Did the tech level look wrong (too refined or too rough)? → Mk1 characteristics need more specificity
- Did backgrounds fail to become transparent? → Background requirement needs stronger emphasis
- Did proportions look unreasonable? → This is a blueprint data gap (unpopulated dimensions), not a prompt error

### Test Question

> "Can the same existing data-driven specification produce visually coherent and stylistically compatible results in both generators?"

The answer will depend on whether the specification — built from actual blueprint facts, architecture document requirements, and Visual Philosophy principles — is sufficient to guide two different image models toward the same visual outcome. If the answer is no, the gap is in the specification (or its interpretation), not in the generators.

---

## APPENDIX A: Blueprint Data Gap Summary

| Field | Mk1 Value | Status |
|-------|-----------|--------|
| `dimensions.length_m` | 0 (unpopulated) | **DATA GAP** — only Mk4+ have dimensions |
| `dimensions.width_m` | 0 (unpopulated) | **DATA GAP** |
| `dimensions.height_m` | 0 (unpopulated) | **DATA GAP** |
| `volume_m3` | 0 (unpopulated) | **DATA GAP** |
| `durability_rating` | "" (empty string) | **DATA GAP** — v1.4 has quality.durability: 0.80 but this is simulation metric |
| `environmental_resistance` | "" (empty string) | **DATA GAP** |

> These gaps exist in the blueprints themselves, not in this specification. They are noted here so the generation test can flag unreasonable proportions without blaming the prompt.

---

## APPENDIX B: Visual Profile Conflict — Detailed Analysis

| Property | precision_industrial_v1 Requires | I-beam Blueprint Actually Specifies | Match? |
|----------|----------------------------------|------------------------------------|--------|
| Primary color | Clean white/light-gray paneling | Dark gray-brown (from visual reference) | ❌ NO |
| Surface finish | Precision-machined, minimal seams | Rough, porous, prominent layer lines | ❌ NO |
| Manufacturing | Precision factory (aerospace-grade) | Heat-sintered regolith, no binder | ❌ NO |
| Hazard markings | Black/yellow functional striping | Not specified in blueprint | ❌ NO |
| Overall impression | Clean industrial, factory-assembled | Heavy, field-fabricated, rough | ❌ NO |

**Conclusion**: The ibeam's actual manufacturing process (heat-sintered regolith with no binder) produces a fundamentally different appearance than precision_industrial_v1 describes. The blueprints have no `visual_profile` field — this is handled at the Visual Definition layer. A separate visual profile for "additive_construction / regolith_composite" would be needed before production use. This is a **separate architecture question**, not a blocker for the generation test.

---

## APPENDIX C: Mk1-Mk5 Blueprint File Inventory

```
data/json-data/blueprints/components/structural/
├── 3d_printed_ibeam_mk1_bp.json          (v1.3, 2026-04-27) ← AUTHORITATIVE
├── 3d_printed_ibeam_mk1_bp_v1.4.json     (v1.4, 2026-04-27) ← v1.4 MIGRATION (adds quality metrics)
├── 3d_printed_ibeam_mk2_bp.json          (v1.3, 2026-04-27) ← AUTHORITATIVE
├── 3d_printed_ibeam_mk3_bp.json          (v1.3, 2026-04-27) ← AUTHORITATIVE
├── 3d_printed_ibeam_mk4_bp.json          (v1.4, 2026-05-04) ← AUTHORITATIVE
└── 3d_printed_ibeam_mk5_bp.json          (v1.4, 2026-05-04) ← AUTHORITATIVE
```

All files are on disk and authoritative regardless of git version-control status. The `data/` directory is intentionally gitignored because JSON blueprints and generated system data are treated as rebuildable data.
