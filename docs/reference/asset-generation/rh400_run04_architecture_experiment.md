---
date_created: 2026-08-26
type: GENERATION_TEST_SPECIFICATION
status: FROZEN (2026-08-26)
subject: regolith_harvester_rover (RH-400) — Run 04 Architecture Experiment
purpose: Compare monolithic prompt generation vs profile-composed prompt generation for complex vehicle assets
test_question: "Does Profile Composition improve specification-to-render fidelity without requiring a larger monolithic prompt?"
frozen: true
frozen_date: 2026-08-26
---

# RH-400 Controlled Generation Test — Run 04 (Architecture Experiment)

## Executive Summary

Run 04 tests whether the **architecture used to construct the prompt** is the actual missing piece identified by the RH-400 Control (Run 03) evaluation. It compares two methods of generating a prompt from the SAME canonical inputs:

- **Control**: Existing Run 03 methodology (monolithic, flat feature list)
- **Test**: Profile Composition layer (hierarchical, independently resolved profiles)

**This is an architecture experiment, not a prompt optimization.** The goal is to isolate whether profile composition improves specification-to-render fidelity. No unrelated improvements should be introduced simultaneously.

---

## 1. CONTROL (Run 03 — Unchanged)

| Field | Value |
|-------|-------|
| **Prompt file** | `rh400_primary_prompt.txt` (frozen, Run 03) |
| **Structure** | Monolithic prompt with flat feature list |
| **Feature ordering** | Flat numbered list (1-6), equal weight |
| **Proportion instruction** | Numeric ratio ("approximately 2.6 times longer than wide") |
| **Style source** | Inlined prose from multiple documents |
| **Result** | 50% of maximum score; 1 of 6 features clearly present |

---

## 2. TEST (Run 04 — Profile Composition)

### Canonical Inputs (Identical to Control)

| Source | File | Status |
|--------|------|--------|
| Blueprint | `data/json-data/blueprints/crafts/ground/regolith_harvesting_rover_bp.json` v2.1 | Unchanged |
| Operational Data | `data/json-data/operational_data/crafts/ground/regolith_harvesting_rover_data.json` v2.1 | Unchanged |
| Visual Definition | `docs/reference/asset-generation/visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json` | Unchanged |
| Visual Profile | `docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md` | Unchanged |
| Render Template | `docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | Unchanged |

### What Changes (Profile Composition)

| Aspect | Control (Run 03) | Test (Run 04) | Rationale |
|--------|-----------------|---------------|-----------|
| **Feature ordering** | Flat numbered list (1-6, equal weight) | Priority-tier ordered (primary → secondary → tertiary) from Visual Definition's `visual_priority` field | Tests whether hierarchical priority improves feature retention |
| **Proportion instruction** | Numeric ratio ("approximately 2.6 times longer than wide") | Visual anchors: "elongated low-slung vehicle, length clearly exceeds width" + canonical dimensions preserved as authoritative data | Run 03 showed numeric ratios are ignored; visual anchors may be more effective |
| **Style/manufacturing source** | Inlined prose from multiple documents | Resolved from structured profiles (global_style, manufacturing_style, technology_level) | Tests whether profile resolution produces clearer style guidance |
| **Prompt structure** | Monolithic text block with mixed concerns | Hierarchical sections: each concern in its own self-contained section | Tests whether separation of concerns improves specification fidelity |

### What Does NOT Change (Controlled Variables)

| Variable | Control | Test | Why Controlled |
|----------|---------|------|---------------|
| Camera view | Top-down orthographic | Same | Don't conflate camera with composition |
| Background rules | Transparent, no terrain/props | Same | Don't conflate background with composition |
| Output format | PNG, 1024×1024 | Same | Don't conflate format with composition |
| Subject description | Same functional role | Same | Don't change what's being rendered |
| Materials list | Same four materials | Same | Don't change material specification |
| Prohibitions | Same prohibition list | Same | Don't add/remove constraints |
| Lighting | Soft neutral studio, cool/even/diffused | Same | Don't change lighting |
| Framing | ~75% of canvas | Same | Don't change framing |

---

## 3. PROFILE COMPOSITION OUTPUT FOR RH-400

### Composed Attributes (Structured — Not Prose)

```yaml
global_style:
  id: grounded_industrial_v1
  source: VISUAL_PROFILE_precision_industrial_v1.md
  resolved_attributes:
    finish: "clean white/light-gray primary paneling over dark gray/black mechanical undercarriage"
    surface_treatment: "precision-machined surfaces, minimal visible construction seams"
    aesthetic: "NASA/ESA-inspired aerospace-industrial"
    markings:
      hazard_striping: "black/yellow on moving parts and edges only"
      unit_id: "stenciled on hull"

manufacturing_style:
  id: earth_factory_v1
  source: blueprint.manufacturing_style + visual_definition.manufacturing_style
  resolved_attributes:
    method: "precision industrial factory assembly"
    quality: "factory-assembled, not frontier/bootstrap"
    materials: ["high-strength aerospace steel", "aluminum structural members", "abrasion-resistant composite panels", "sealed hydraulic systems", "reinforced rubber tracks"]
    excluded: ["frontier/bootstrap/improvised construction", "DMLS or 3D-printed rough surface finish", "visible layer lines", "exposed reinforcement ribs", "regolith-composite or ISRU-derived material appearance"]

technology_level:
  id: tl2_v1
  source: blueprint.technology_level (2) + visual_definition.technology_level (2)
  resolved_attributes:
    level: 2
    characteristics: ["cleaner than early-generation", "fewer visible fasteners", "welded joints", "slight sheen"]
    excluded: ["visible layer lines", "3D-printed rough texture", "improvised appearance"]

render_type:
  id: catalog_render_v2
  source: PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md
  resolved_attributes:
    camera: "top-down orthographic (directly above, no perspective distortion)"
    lighting: "soft neutral studio — cool, even, diffused illumination"
    background: "transparent (alpha channel)"
    framing: "75% of canvas"
    output_format: "PNG, 1024x1024 pixels"

asset_hierarchy:
  source: VEHICLE_HARVESTER_ROVER_RH400.json visual_priority field
  primary: ["regolith skimming scoop assembly", "six-wheel independent suspension chassis"]
  secondary: ["mid-body cylindrical processing canister", "top-mounted sensor mast with rotating array"]
  tertiary: ["rear-mounted dust exhaust stack", "exposed hydraulic actuator arms on scoop joints"]

proportion_anchors:
  canonical_dimensions:
    length_m: 6.80
    width_m: 3.30
    height_m: 2.65
    ratio_length_to_width: 2.06
  visual_anchors:
    - "elongated low-slung vehicle"
    - "length clearly exceeds width"
    - "width remains substantially narrower than overall length"
    - "body height remains low relative to footprint"
```

---

## 4. RUN 04 PRIMARY PROMPT (Generated Through Profile Composition)

See `rh400_run04_profile_composed_prompt.txt` for the actual prompt generated from the composed attributes above.

---

## 5. EVALUATION CRITERIA

Same rubric as Run 03 (Criteria A–N), with direct comparison to Control:

| Criterion | Purpose |
|-----------|---------|
| A. Structural Geometry | Does composition preserve chassis proportions? |
| B. Vehicle Identity | Is RH-400 recognizable as harvester rover? |
| C. Recognition Feature Completeness | How many of 6 features present vs Control's 1/6? |
| D. Proportion Accuracy | Does visual anchor improve ratio accuracy? |
| E. Material Appearance | Does profile resolution improve surface finish? |
| F. Tech Level Consistency | Is Mk2 clearly communicated? |
| G. Hazard Markings | Are hazard striping present (was absent in Control)? |
| H. Absence of Unsupported Context | Background handling |
| I. Blueprint Adherence | All known characteristics present? |
| J. Unwanted Invented Details | No new inventions from composition? |
| K. Asset Isolation/Presentation | Framing, centering, visibility |
| L. Cross-Model Consistency | Agreement between ChatGPT and Gemini |
| M. Silhouette Strength | Recognizable at small scale? |
| N. Mechanical Plausibility | Mechanically coherent? |

### Additional Architectural Question

> Did Profile Composition improve specification-to-render fidelity without requiring a larger monolithic prompt?

This is the **primary Run 04 finding**. The answer determines whether Profile Composition should be incorporated into the general asset-generation architecture.

---

## 6. SUCCESS THRESHOLDS

| Metric | Pass Condition |
|--------|---------------|
| Recognition feature improvement | ≥3 of 6 features present (vs Control's 1/6) |
| Proportion accuracy | Length-to-width ratio within ±0.3 of specified 2.06:1 |
| Hazard markings present | At least visible on one feature (scoop edges or exhaust stack) |
| No unintended degradation | Criteria A, B, H remain at Control scores or better |
| Cross-model consistency | ChatGPT and Gemini agree within ±1 point on each criterion |
| Prompt size not larger | Run 04 prompt ≤ Run 03 prompt in line count |

---

## 7. VISUAL REFERENCES (If Environment Supports)

If the generation environment supports reference images, include:

| Reference | File | Purpose |
|-----------|------|---------|
| Catalog Render | `data/images/catalog/crafts/ground/rh400_regolith_harvesting_rover.png` | Visual guidance for style/finish |
| Engineering Blueprint | From RH-400 reference set | Proportion guidance |

**Rule**: References provide visual guidance but do NOT override canonical data. If a reference conflicts with the Blueprint, the Blueprint wins.

If reference-image support differs between ChatGPT and Gemini, record that as an environmental variable rather than pretending the test is perfectly symmetrical.

---

## 8. COMPARISON WITH I-BEAM RESULTS

The I-beam experiments demonstrated that the basic generation pipeline works for simple components (single object, four recognition features). The RH-400 Control demonstrated that increasing asset complexity exposes weaknesses in the translation from structured visual data to generation instructions.

Run 04 tests whether **the architecture used to construct the prompt** is the actual missing piece — not missing canonical data, not insufficient constraints, but the composition mechanism itself.

---

## 9. FILES UNCHANGED

The following files were **NOT modified** during this specification:
- `rh400_primary_prompt.txt` (Run 03) — FROZEN
- `rh400_controlled_generation_test_spec.md` (Run 03 spec) — FROZEN
- All RH-400 generated images (Run 03) — UNMODIFIED
- All I-beam test files (Run 01, Run 02) — FROZEN
- All canonical RH-400 data (blueprint, operational data, Visual Definition, Visual Profile) — UNCHANGED

---

**Specification complete. Primary prompt file: `rh400_run04_profile_composed_prompt.txt` (separate deliverable).**
