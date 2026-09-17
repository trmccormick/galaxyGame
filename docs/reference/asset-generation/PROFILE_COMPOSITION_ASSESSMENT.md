# Profile Composition Architecture — Assessment & Design

**Date**: 2026-08-26
**Status**: Assessment (not yet implemented)
**Test Subject**: RH-400 Regolith Harvester Rover
**Preceding Tests**: I-beam Mk1 Control (Run 01), I-beam Mk1 Run 02, RH-400 Control (Run 03)

---

## 1. ARCHITECTURE ASSESSMENT — WHAT EXISTS, WHAT IS MISSING

### 1.1 What Already Exists (No Changes Needed)

| Layer | Document/Schema | Status | Role |
|-------|----------------|--------|------|
| **Blueprint** | `regolith_harvester_rover_bp.json` v2.1 | ✅ Complete | Manufacturing specs, physical properties, materials |
| **Operational Data** | `regolith_harvesting_rover_data.json` v2.1 | ✅ Complete | Runtime behavior, deployment, output rates |
| **Visual Definition** | `VEHICLE_HARVESTER_ROVER_RH400.json` | ✅ Complete | Recognition features, tech level, manufacturing style, color profiles, silhouette, visual priority |
| **Visual Profile** | `VISUAL_PROFILE_precision_industrial_v1.md` | ✅ Complete | Locked attributes: materials, finish, markings, silhouette rules, consistency rules |
| **Render Template** | `PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | ✅ Complete | Camera, lighting, background, output format rules |
| **Visual Philosophy** | `VISUAL_PHILOSOPHY.md` | ✅ Complete | 9 foundational principles (tech level progression, modular, industrial, etc.) |
| **Prompt Compiler Contract** | `ASSET_PROMPT_COMPILER_CONTRACT.md` v0.1 | ✅ Complete | Defines the five-layer dependency chain and resolution logic |
| **Asset Generation Architecture** | `ASSET_GENERATION_ARCHITECTURE.md` | ✅ Complete | Full pipeline specification (Blueprint → PromptBuilder → Image Generator) |
| **RH-400 Prompt Template** | `rh400-prompt-template.md` | ✅ Complete | Three-pass output structure, RH-400-specific lessons |
| **Visual Definition Template** | `VISUAL_DEFINITION_TEMPLATE.md` | ✅ Complete | Schema for visual definitions |

### 1.2 What Is Missing (The Gap)

**The PromptBuilder service is NOT implemented.** It exists only as a specification in two documents:

- `ASSET_GENERATION_ARCHITECTURE.md` describes it conceptually (lines 499-578): "class PromptBuilderService" with inputs/outputs
- `ASSET_PROMPT_COMPILER_CONTRACT.md` defines the five-layer dependency chain and resolution logic

**Neither document implements the actual composition mechanism.** They describe WHAT should happen but not HOW. The current workflow bypasses PromptBuilder entirely — a human (or LLM) manually assembles the prompt by reading all source documents and writing prose.

### 1.3 What This Means for Profile Composition

The architecture **already defines the correct layers** in the dependency chain:

```
Layer 1: Blueprint → visual_profile ID, technology_level, manufacturing_style
Layer 2: Visual Profile → locked style attributes
Layer 3: Visual Definition → appearance spec + recognition_features
Layer 4: Operational Data → functional role
Layer 5: Render Template → receives substituted variables
```

**What's missing is the composition layer that sits between Layer 2 (Visual Profile) and Layer 5 (Render Template).** The current architecture treats these as a flat chain. What ChatGPT identified during the RH-400 design conversation — and what Run 03 confirmed is needed — is:

```
Layer 1: Blueprint → visual_profile ID, technology_level, manufacturing_style
Layer 2: Visual Profile → locked style attributes
         ↓
    [MISSING: Profile Composition]
         ↓ resolves independent profile concerns into structured attributes
Layer 3: Visual Definition → appearance spec + recognition_features
Layer 4: Operational Data → functional role
Layer 5: Render Template → receives substituted variables
```

### 1.4 What Should Remain Unchanged

| Component | Reason |
|-----------|--------|
| All canonical data (blueprints, operational data) | Already authoritative; no changes needed |
| Visual Definition schemas | Already structured correctly; contains recognition_features, visual_priority, color_profile |
| Visual Profiles (precision_industrial_v1) | Already defines locked attributes; the Profile Composition layer reads these, doesn't modify them |
| Render Templates | Already defines camera/lighting/background rules; receives composed output, doesn't need to change |
| Prompt Compiler Contract | Already defines dependency chain and resolution logic; the composition layer fits INTO this chain |
| Visual Philosophy | Already defines tech level progression; Profile Composition reads these values |
| All frozen test files | Per user directive — no modifications |

---

## 2. PROFILE COMPOSITION DESIGN

### 2.1 Conceptual Model

```
Canonical Data (Blueprint + Operational Data)
      │
      ▼
Visual Definition (recognition_features, visual_priority, color_profile, etc.)
      │
      ▼
┌─────────────────────────────────────────────────────┐
│              PROFILE COMPOSITION                     │
│                                                      │
│  Resolves these independent profile concerns:        │
│                                                      │
│  1. Global Visual Style (from Visual Profile)        │
│     → structured style attributes                    │
│                                                      │
│  2. Manufacturing Style (from Blueprint + Vis Def)   │
│     → structured manufacturing attributes            │
│                                                      │
│  3. Technology Level (from Blueprint + Vis Def)      │
│     → structured tech level attributes               │
│                                                      │
│  4. Render Type (from Render Template)               │
│     → structured render requirements                 │
│                                                      │
│  5. Asset-Specific Visual Requirements               │
│     → recognition_features + visual_priority          │
│     → color_profile resolution                       │
│     → material_profiles                              │
│                                                      │
│  Output: Structured attributes (not prose)            │
│         ready for PromptBuilder substitution           │
└─────────────────────────────────────────────────────┘
      │
      ▼
PromptBuilder (substitutes structured attributes into Render Template)
      │
      ▼
Structured Generation Prompt (hierarchical, not monolithic)
```

### 2.2 Profile Composition — Structured Attributes

The composition layer outputs **structured attributes**, not prose paragraphs. These are the inputs to PromptBuilder:

```yaml
# Example: RH-400 composed attributes (not a prompt — structured data)

global_style:
  id: grounded_industrial_v1
  source: VISUAL_PROFILE_precision_industrial_v1.md
  resolved_attributes:
    finish: "clean white/light-gray primary paneling over dark gray/black mechanical undercarriage"
    surface_treatment: "precision-machined surfaces, minimal visible construction seams"
    aesthetic: "NASA/ESA-inspired aerospace-industrial"
    markings: "black/yellow hazard striping (moving parts/edges only), unit ID stenciled on hull"

manufacturing_style:
  id: earth_factory_v1
  source: blueprint.manufacturing_style + visual_definition.manufacturing_style
  resolved_attributes:
    method: "precision industrial factory assembly"
    quality: "factory-assembled, not frontier/bootstrap"
    materials: ["high-strength aerospace steel", "aluminum structural members", "abrasion-resistant composite panels", "sealed hydraulic systems", "reinforced rubber tracks"]

technology_level:
  id: tl2_v1
  source: blueprint.technology_level + visual_definition.technology_level
  resolved_attributes:
    level: 2
    characteristics: ["cleaner than early-generation", "fewer visible fasteners", "welded joints", "slight sheen"]
    excluded: ["visible layer lines", "3D-printed rough texture", "improvised appearance"]

render_type:
  id: catalog_render_v2
  source: PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md
  resolved_attributes:
    camera: "top-down orthographic"
    lighting: "soft neutral studio — cool, even, diffused"
    background: "transparent (alpha channel)"
    framing: "75% of canvas"
    output: "PNG, 1024x1024"

asset_specific:
  subject: "RH-400 Regolith Harvester Rover"
  functional_role: "heavy-duty mobile industrial craft designed to skim planetary surfaces and gather regolith for ISRU processing"
  recognition_features:
    primary: ["six-wheel independent suspension chassis", "forward regolith skimming scoop assembly"]
    secondary: ["mid-body cylindrical processing canister", "top-mounted sensor mast with rotating array"]
    tertiary: ["rear-mounted dust exhaust stack", "exposed hydraulic actuator arms on scoop joints"]
  proportions:
    length_m: 6.80
    width_m: 3.30
    height_m: 2.65
    ratio_length_to_width: 2.06
  color_profile:
    industrial_primary: "white/light-gray" (resolved from Visual Profile)
    industrial_secondary: "dark gray/black" (resolved from Visual Profile)
    hazard_warning: "black/yellow" (resolved from Visual Profile)
```

### 2.3 Resolution Order

Profiles are resolved in this order, each building on the previous:

1. **Global Visual Style** — resolved from the Visual Profile referenced by the Blueprint's `visual_profile` field
2. **Manufacturing Style** — resolved from Blueprint's `manufacturing_style` + Visual Definition's `manufacturing_style` (cross-layer validation)
3. **Technology Level** — resolved from Blueprint's `technology_level` + Visual Definition's `technology_level` (cross-layer validation)
4. **Render Type** — resolved from the Render Template being used (not from asset data; this is a pipeline-level choice)
5. **Asset-Specific Requirements** — resolved from Visual Definition's structured fields (recognition_features, color_profile, material_profiles, visual_priority)

### 2.4 Precedence Rules

| Rule | Description |
|------|-------------|
| **Blueprint > Visual Profile** | If Blueprint and Visual Profile conflict on `technology_level` or `manufacturing_style`, the Blueprint wins (it's the authoritative source for this specific asset). The compiler contract already has a warning rule for cross-layer mismatches. |
| **Visual Profile locked attributes > all** | Locked attributes in the Visual Profile cannot be overridden by any other layer. They are truly locked. |
| **Render Template > asset data** | Camera, lighting, background rules come from the Render Template, not from asset data. The template governs rendering behavior only (per its evolution policy). |
| **Visual Definition recognition_features > Visual Profile** | Recognition features are asset-specific and override any generic style guidance in the Visual Profile. |
| **Color profile resolution** | Semantic color descriptions from the Visual Profile are resolved to their semantic role values. If hex values exist in a future Design System, they take precedence over semantic descriptions. |

### 2.5 PromptBuilder Interaction

The PromptBuilder receives structured attributes (not prose) and produces a hierarchical prompt:

```
PromptBuilder Input: Structured attributes from Profile Composition
    │
    ▼
┌─────────────────────────────────────────────────────┐
│              HIERARCHICAL PROMPT GENERATION           │
│                                                      │
│  Section 1: SUBJECT (from asset_specific.subject)     │
│  Section 2: PROPORTIONS (from asset_specific.proportions) │
│  Section 3: STYLE (from global_style.resolved_attributes) │
│  Section 4: MANUFACTURING (from manufacturing_style.resolved_attributes) │
│  Section 5: MATERIALS (from manufacturing_style.materials + asset_specific.color_profile) │
│  Section 6: MARKINGS (from global_style.markings)     │
│  Section 7: RECOGNITION FEATURES (from asset_specific.recognition_features, ordered by priority tier) │
│  Section 8: RENDER REQUIREMENTS (from render_type.resolved_attributes) │
│  Section 9: BACKGROUND (from render_type.background)  │
│  Section 10: OUTPUT (from render_type.output)         │
│                                                      │
│  Key difference from Run 03:                          │
│  - Recognition features are ORDERED by priority tier  │
│    (primary → secondary → tertiary) instead of flat   │
│  - Each section is a self-contained block, not mixed  │
│  - Style/manufacturing come from resolved profiles,   │
│    not inlined prose                                  │
└─────────────────────────────────────────────────────┘
    │
    ▼
Structured Generation Prompt (hierarchical sections)
```

### 2.6 Reference Image Handling

Approved visual references are a **separate input layer** to PromptBuilder, not part of Profile Composition:

```
PromptBuilder Inputs:
├── Structured Attributes (from Profile Composition)
│   ├── global_style
│   ├── manufacturing_style
│   ├── technology_level
│   ├── render_type
│   └── asset_specific
│
├── Visual References (optional, approved only)
│   ├── Catalog Render (provides visual guidance for style/finish)
│   ├── Engineering Blueprint (provides proportion guidance)
│   ├── Multi-view Reference (provides feature visibility guidance)
│   └── Exploded View (proves mechanical coherence)
│
└── Render Template (PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md)
    └── Provides camera/lighting/background/output rules
```

**Important**: Visual references are NOT canonical data. They provide visual guidance but do not override canonical data. If a reference conflicts with the Blueprint, the Blueprint wins.

---

## 3. MINIMAL IMPLEMENTATION/CHANGE PLAN

### 3.1 What Needs to Be Created (New)

| File | Purpose | Status |
|------|---------|--------|
| `docs/reference/asset-generation/PROFILE_COMPOSITION_SPEC.md` | Defines the composition layer: profile types, resolution order, precedence rules, structured attribute schema | **NEW** |
| `docs/reference/asset-generation/profiles/global_style/grounded_industrial_v1.md` | Resolves precision_industrial_v1 into structured style attributes | **NEW** (extends existing Visual Profile) |
| `docs/reference/asset-generation/profiles/manufacturing/earth_factory_v1.md` | Resolves manufacturing style into structured attributes | **NEW** |
| `docs/reference/asset-generation/profiles/technology/tl2_v1.md` | Resolves technology level 2 into structured attributes | **NEW** |

### 3.2 What Needs to Be Modified (Minimal)

| File | Change | Reason |
|------|--------|--------|
| `ASSET_PROMPT_COMPILER_CONTRACT.md` | Add Profile Composition as Layer 2.5 between Visual Profile and Visual Definition | Documents the new architectural layer in the existing contract |
| `VEHICLE_HARVESTER_ROVER_RH400.json` | No change needed | Already contains all required fields (recognition_features, visual_priority, color_profile, etc.) |

### 3.3 What Should Remain Frozen

| Component | Reason |
|-----------|--------|
| All canonical data (blueprints, operational data) | Already authoritative |
| `VISUAL_PROFILE_precision_industrial_v1.md` | Locked attributes are correct; composition layer reads them |
| `PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | Render rules are correct; receives composed output |
| All frozen test files (I-beam Run 01/02, RH-400 Run 03) | Per user directive |
| `rh400_primary_prompt.txt` | Frozen; Run 04 will use Profile Composition instead |
| `rh400_controlled_generation_test_spec.md` | Frozen; defines the test framework |

### 3.4 What Does NOT Need to Be Created

| Item | Why Not Needed |
|------|---------------|
| New Visual Definition schema | Already exists and is correct |
| New Render Template | Already exists and is correct |
| New canonical data fields | The composition layer works with existing fields |
| New complexity categories | Documented as future architectural layer (per user directive) |
| Implementation of PromptBuilder service | This is a specification/design task, not implementation |

---

## 4. RUN 04 EXPERIMENTAL SPECIFICATION

### 4.1 Test Question

> Does profile-composed prompt generation produce better specification-to-render fidelity than monolithic prompt generation for complex vehicle assets?

### 4.2 Control (Existing Run 03)

- **Prompt**: `rh400_primary_prompt.txt` (frozen, monolithic structure)
- **Method**: Human-assembled prompt reading all source documents and writing prose
- **Structure**: Flat feature list with equal weight; proportions as numeric ratio; style/manufacturing as inlined prose
- **Result**: 50% of maximum score; 4 of 6 recognition features dropped

### 4.3 Test (Profile Composition)

- **Prompt**: Generated by Profile Composition layer from the same canonical inputs
- **Method**: Same canonical data → Profile Composition → structured attributes → hierarchical prompt
- **Structure**: 
  - Recognition features ordered by priority tier (primary → secondary → tertiary) instead of flat enumeration
  - Proportions as visual anchor comparison (not numeric ratio) — *this is the one variable change beyond composition*
  - Style/manufacturing from resolved profiles (not inlined prose)
- **Same variables preserved**: Same camera view (top-down orthographic), same background rules, same output format, same subject, same materials

### 4.4 Variables Controlled

| Variable | Control | Test | Why Controlled |
|----------|---------|------|---------------|
| Canonical data | RH-400 bp v2.1 + ops data v2.1 + Visual Def + Visual Profile | Same | Isolate composition method |
| Camera view | Top-down orthographic | Same | Don't conflate camera with composition |
| Background rules | Transparent, no terrain/props | Same | Don't conflate background with composition |
| Output format | PNG, 1024×1024 | Same | Don't conflate format with composition |
| Subject description | Same functional role | Same | Don't change what's being rendered |
| Materials list | Same four materials | Same | Don't change material specification |

### 4.5 Variables Changed (Intentionally)

| Variable | Control | Test | Rationale |
|----------|---------|------|-----------|
| **Feature ordering** | Flat numbered list (1-6, equal weight) | Priority-tier ordered (primary → secondary → tertiary) | Tests whether hierarchical priority improves feature retention |
| **Proportion instruction** | Numeric ratio ("approximately 2.6 times longer than wide") | Visual anchor comparison | Run 03 showed numeric ratios are ignored; visual anchors may be more effective |
| **Style/manufacturing source** | Inlined prose from multiple documents | Resolved from structured profiles | Tests whether profile resolution produces clearer style guidance |

### 4.6 Expected Findings

| Finding | If Observed | Interpretation |
|---------|-------------|---------------|
| Feature retention improves (≥4 of 6 features present) | Profile Composition works | Hierarchical priority + resolved profiles improve specification fidelity |
| Proportion accuracy improves | Visual anchors work better than numeric ratios | Generators respond to visual comparisons more than numbers |
| Both improvements occur | Profile Composition is the missing architectural layer | The architecture, not the constraints, was the bottleneck |
| No improvement | Profile Composition alone is insufficient | May need conversational context building (per catalog render comparison) or multi-view presentation |
| Deterioration | Profile Composition introduces new problems | May need iterative refinement of the composition model |

### 4.7 Evaluation Criteria

Same rubric as Run 03 (Criteria A–N), with additional comparison to Control:

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
| M. Silhouette Strength | Recognizable at small scale? |
| N. Mechanical Plausibility | Mechanically coherent? |

### 4.8 Success Thresholds

| Metric | Pass Condition |
|--------|---------------|
| Recognition feature improvement | ≥3 of 6 features present (vs Control's 1/6) |
| Proportion accuracy | Length-to-width ratio within ±0.3 of specified 2.06:1 |
| Hazard markings present | At least visible on one feature (scoop edges or exhaust stack) |
| No unintended degradation | Criteria A, B, H remain at Control scores or better |
| Cross-model consistency | ChatGPT and Gemini agree within ±1 point on each criterion |

---

## 5. COMPLEXITY STRATEGY — FUTURE ARCHITECTURAL LAYER

The user directive notes that not every asset requires the RH-400 workflow. The existing architecture already contains a complexity concept:

**Existing**: `complexity_levels` field in Visual Definition (L0–L5) and `technology_level` field (1–5).

**What's missing**: A mapping from complexity level to generation strategy (lightweight composition vs hierarchical composition vs reference-driven workflow).

**Recommendation**: Document this as a future architectural layer. Do not implement it now. The Run 04 experiment focuses solely on Profile Composition for the RH-400 test case.

---

## 6. SUMMARY OF FINDINGS

### What Already Exists
The architecture already defines all necessary layers in the dependency chain (Blueprint → Visual Profile → Visual Definition → Operational Data → Render Template). The Visual Definition for RH-400 is complete and correct. The PromptBuilder Contract defines resolution logic.

### What Is Missing
The **composition layer** that sits between Visual Profile and Render Template. This layer resolves independent profile concerns (global style, manufacturing, technology level, render type, asset-specific requirements) into structured attributes — not prose paragraphs — ready for PromptBuilder substitution.

### What the Composition Layer Adds
1. **Hierarchical feature ordering**: Recognition features ordered by priority tier (primary → secondary → tertiary) instead of flat enumeration
2. **Structured profile resolution**: Each profile concern resolved independently into structured attributes
3. **Visual proportion anchors**: Replaces numeric ratios with visual comparisons that generators can actually process
4. **Separation of concerns**: Style, manufacturing, technology level, and render type are independent concepts, not collapsed into monolithic prose

### What Remains Unchanged
All canonical data, Visual Definitions, Visual Profiles, Render Templates, frozen test files, and the PromptBuilder Contract's dependency chain definition. The composition layer fits INTO the existing architecture; it does not replace any existing layer.

---

**Assessment complete. Awaiting review before implementation.**
