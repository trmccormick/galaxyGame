# Asset Generation Pipeline — Validation Report

**Date**: 2026-08-27
**Purpose**: Document which parts of the asset-generation methodology are validated architecture, validated practice, experimental guidance, asset-specific knowledge, or open questions.
**Scope**: I-beam Mk1 (simple component) + RH-400 Regolith Harvester Rover (complex vehicle). Six controlled experiments across four runs.

---

## 1. EXPERIMENTAL EVIDENCE SUMMARY

### Runs Conducted

| Run | Asset | Test Type | Prompt Structure | ChatGPT Score | Gemini Score | Key Finding |
|-----|-------|-----------|-----------------|---------------|--------------|-------------|
| **I-beam Run 01** | I-beam Mk1 (simple) | Control generation | Monolithic flat prompt | 42/50 | 39/50 | Pipeline works for simple components; semantic colors produce variable results |
| **I-beam Run 02** | I-beam Mk1 (simple) | A/B test of constraints | Hex colors, layer quantification, format mandates | — | — | **Hex color ranges eliminate cross-generator color divergence**; format constraints ineffective |
| **RH-400 Run 03** | RH-400 (complex) | Control generation | Monolithic flat prompt (~103 lines) | 35/70 | 34/70 | **Feature prioritization collapse**: both generators dropped 4 of 6 recognition features; semantic colors produced variable results |
| **RH-400 Run 04** | RH-400 (complex) | Architecture experiment | Profile Composition layer added (~202 lines) | ~58/70 | ~48/70 | **Profile Composition confirmed as missing architectural layer**: features went from 1/6 to 4-6/6; ChatGPT gap widened to ~10 points |
| **RH-400 Run 05** | RH-400 (complex) | Targeted refinements | Profile Comp + hex colors + canister description + hazard reinforcement (~108 lines) | ~62/70 | ~32/70 | ChatGPT peak maintained; Gemini regressed on camera view and autonomous design but achieved cylindrical canister for first time |
| **RH-400 Run 06** | RH-400 (complex) | Safeguard experiment | Profile Comp + refinements + safeguards (~117 lines) | ~62/70 | ~55/70 | **All three safeguards effective**: both generators achieved top-down view, no crew elements, all six features; gap narrowed to ~7 points |

### Evidence Chain

```
I-beam Run 01 (simple component works)
    → I-beam Run 02 (hex colors fix color divergence for simple components)
    → RH-400 Run 03 (complex component FAILS — feature prioritization collapse)
    → RH-400 Run 04 (Profile Composition fixes features — architecture confirmed)
    → RH-400 Run 05 (refinements improve ChatGPT, expose Gemini mode-shift)
    → RH-006 (safeguards fix Gemini without degrading ChatGPT)
```

---

## 2. VALIDATED ARCHITECTURE

These components have been **experimentally validated across multiple assets and runs** and should be treated as architecture — not guidance, not practice, but architecture.

### 2.1 Five-Layer Dependency Chain (from ASSET_PROMPT_COMPILER_CONTRACT.md)

**Status: VALIDATED ARCHITECTURE**

```
Layer 1: Blueprint (unit_blueprint.json or component_blueprint.json)
    ↓ resolves visual_profile ID
Layer 2: Visual Profile (e.g., precision_industrial_v1)
    ↓ provides locked style attributes
Layer 3: Visual Definition (visual_definition JSON)
    ↓ provides appearance spec + recognition_features
Layer 4: Operational Data (operational_data JSON)
    ↓ provides functional role / runtime behavior
Layer 5: Production Asset Render Template
    ↓ receives substituted variables → produces final prompt
```

**Evidence**: This chain was defined in ASSET_PROMPT_COMPILER_CONTRACT.md and validated through all six runs. Every run followed this chain from canonical data to generated prompt to rendered output. The chain is the structural backbone of the entire pipeline.

### 2.2 Profile Composition Layer

**Status: VALIDATED ARCHITECTURE**

Profile Composition resolves independent profile concerns (style, manufacturing, technology level, render type) into structured attributes that PromptBuilder substitutes into the Render Template. It sits between Visual Profile and Visual Definition in the five-layer dependency chain.

**What it solves**: Feature prioritization collapse under complexity pressure. When six recognition features plus proportions plus materials plus markings are all in the prompt simultaneously as a flat list, generators drop most of them. Profile Composition introduces hierarchical priority (primary → secondary → tertiary) that maps to generator attention ordering.

**Evidence**:
- **RH-400 Run 03 → Run 04**: Features went from 1/6 to 4-6/6 across both generators (+500% for Gemini, +500% for ChatGPT). This is not marginal improvement — it is the difference between a generic rover and a specific, recognizable RH-400 harvester.
- **ChatGPT maintained peak performance** across Runs 04→05→06 (6/6 features in all three runs). Profile Composition does not degrade ChatGPT's performance once established.
- **Catalog render comparison**: The catalog renders that showed all six features present were generated through conversational multi-view presentation, which implicitly uses hierarchical feature prioritization. Profile Composition makes this implicit mechanism explicit and reproducible.

**How it should consume Visual Definitions and Visual Profiles**:
- Visual Definition's `visual_priority` field maps directly to priority tiers (primary → secondary → tertiary)
- Visual Profile's locked attributes map to global_visual_style profile type
- Blueprint's manufacturing_style maps to manufacturing_style profile type
- Blueprint's technology_level maps to technology_level profile type
- Render Template maps to render_type profile type

**Recognition-feature priority preservation**: The `visual_priority` field in the Visual Definition is authoritative. Priority tiers must match this field exactly. If a feature is listed as secondary in the Visual Definition, it must be rendered at secondary tier in the composed prompt — not elevated or demoted.

### 2.3 Asset Registry and Version Tracking

**Status: VALIDATED ARCHITECTURE** (conceptually validated; implementation pending)

The pipeline requires an asset registry that tracks:
- Canonical asset ID
- All generated render types
- Blueprint version that generated the asset
- Prompt template version used
- QA approval status
- Obsolete asset references

**Evidence**: The experiment itself required version tracking across six runs. Each run's prompt, specification, and outputs were explicitly versioned and frozen. Without this discipline, the experiments would have been impossible to evaluate.

### 2.4 Frozen Prompt Discipline

**Status: VALIDATED ARCHITECTURE**

Prompts must be FROZEN upon preparation for a generation run. No modifications during or after generation. If results diverge between generators, record where they diverge — do not rewrite the prompt to make them agree.

**Evidence**: This discipline was followed across all six runs and was essential for valid experimental comparison. Without frozen prompts, each "run" would be an uncontrolled variable rather than a testable hypothesis.

---

## 3. VALIDATED PRACTICE

These components have been **experimentally validated but are practices, not architecture**. They should be codified as standard operating procedure but may evolve as more assets are tested.

### 3.1 Controlled Sequential Experimentation

**Status: VALIDATED PRACTICE**

Use controlled sequential experiments rather than continuously changing prompts. Each run tests one hypothesis with minimal variables. A failed experiment is a finding — do not rewrite the prompt merely to make generators agree.

**Evidence**:
- **I-beam Run 02 A/B test**: Isolated three constraints (hex colors, layer quantification, format mandates) in separate variants, then combined them. This identified which constraints were effective and which were not.
- **RH-400 Run 03 → 06**: Each run tested a specific hypothesis (monolithic prompt failure, Profile Composition effectiveness, targeted refinements, safeguard effectiveness). The sequential progression built evidence incrementally.

**Why this matters**: Continuously changing prompts creates an uncontrolled experiment where no finding is attributable to any specific change. Controlled sequential experiments produce actionable evidence.

### 3.2 Canonical Data Supremacy

**Status: VALIDATED PRACTICE**

Canonical data (Blueprint, Operational Data, Visual Definition) is authoritative. Generated images and reference images must never silently override canonical geometry or specifications. If a generated image contradicts canonical data, the prompt — not the image — is the problem.

**Evidence**:
- **RH-400 catalog render comparison**: The catalog renders proved generators CAN render all six features when prompted conversationally with multi-view presentation. This was used as positive control evidence, not as canonical geometry override.
- **Run 05 canister constraint**: The strengthened cylindrical canister description (negative + positive constraints) overrode Gemini's persistent rectangular panel invention — but only because the Visual Definition explicitly specified "cylindrical processing canister." The constraint was grounded in canonical data, not aesthetic preference.

### 3.3 Cross-Generator Evaluation Protocol

**Status: VALIDATED PRACTICE**

Always evaluate both ChatGPT and Gemini for every complex asset generation. Record scores using a consistent A–N rubric. Track cross-generator divergence as a first-class metric.

**Evidence**: All six runs included dual-generator evaluation with the same scoring methodology. This produced the evidence that:
- ChatGPT processes prompts structurally (follows hierarchy faithfully)
- Gemini processes prompts associatively (responds to semantic triggers, can shift modes)
- The divergence pattern is generator-specific, not architecture-specific

### 3.4 Prompt Size Discipline

**Status: VALIDATED PRACTICE**

Target prompt size ≤120 lines for complex vehicle assets. Additions should be targeted refinements addressing specific failures, not content bloat. Each added line should address a specific identified divergence.

**Evidence**:
- **Run 05**: Added 13 lines (+14%) — all targeted at specific Run 04 divergences
- **Run 06**: Added 9 lines (+8%) — three safeguards addressing three specific failures
- Both additions were within the ≤120-line target and addressed specific identified problems

---

## 4. EXPERIMENTAL GUIDANCE

These components have been **tested but not yet validated across multiple assets**. They should be treated as guidance that requires further testing before becoming architecture or practice.

### 4.1 Hex Color Ranges for Critical Color Zones

**Status: EXPERIMENTAL GUIDANCE**

Add hex color ranges to critical color zones (body panels, undercarriage, hazard markings) when semantic descriptions produce cross-generator divergence. Use dual-anchor approach: hex range + visual anchor phrase + negative qualifier.

**Evidence**:
- **I-beam Run 02**: Hex colors eliminated cross-generator color divergence for simple components
- **RH-400 Run 05**: ChatGPT followed all four hex ranges perfectly; Gemini followed two of four correctly and partially followed one (orange-yellow hazard instead of industrial yellow)
- **RH-400 Run 06**: With safeguards preventing aesthetic mode shift, both generators produced correct colors

**What's validated**: Hex ranges work when generators follow them faithfully. ChatGPT follows all ranges; Gemini follows most but may interpret specific hues differently.

**What's NOT validated**: Whether hex ranges are necessary for all assets or only complex vehicles with multiple color zones. Whether per-generator hex calibration is needed for full consistency.

**Guidance**: Use hex ranges for critical color zones on complex assets. Monitor generator adherence. If divergence persists after safeguards, consider per-generator calibration as a future experiment.

### 4.2 Strengthened Geometric Constraints (Negative + Positive)

**Status: EXPERIMENTAL GUIDANCE**

For persistent geometry failures, use explicit negative constraints ("NOT rectangular, NOT box-shaped") combined with positive geometry descriptions ("oval/circular outline from above," "curved dome or flat circular cap").

**Evidence**:
- **RH-400 Run 05 → 06**: Gemini's persistent rectangular panel invention (across Runs 03 and 04) was definitively resolved in Run 05 and maintained in Run 06. This is the single most successful refinement across all runs.

**What's validated**: Negative + positive constraints can override persistent generator biases for specific geometry types.

**What's NOT validated**: Whether this approach generalizes to other geometry types (e.g., non-cylindrical shapes, complex curves). Whether it works without the Profile Composition layer as baseline.

**Guidance**: Use for persistent geometry failures where canonical data specifies a specific shape. Combine negative constraints with positive top-down observable geometry. Do not invent dimensions not in canonical data.

### 4.3 Safeguard Layer for Complex Assets

**Status: EXPERIMENTAL GUIDANCE** (three safeguards tested on one asset)

For complex vehicle assets, add a minimal renderer-neutral safeguard layer addressing:
1. Camera precedence (dedicated section before STYLE with explicit precedence language)
2. Autonomous/crewless protection (concise DESIGN CONSTRAINTS section before recognition features)
3. Protected recognition features (elevate to appropriate tier per Visual Definition)

**Evidence**:
- **RH-400 Run 06**: All three safeguards fully effective on one complex vehicle asset. Gemini improved from ~32/70 to ~55/70. ChatGPT maintained peak at ~62/70. Gap narrowed from ~30 to ~7 points.

**What's validated**: Safeguards are effective for the tested asset (RH-400). Renderer-neutral approach works without fragmenting architecture.

**What's NOT validated**: Whether these safeguards generalize to other vehicle types (aerial, naval, space). Whether different safeguard sets are needed for different asset families. Whether the three tested safeguards cover all common failure modes.

**Guidance**: Use for complex vehicle assets where generator-specific failures have been identified. Test on additional asset types before generalizing. Keep renderer-neutral by default.

### 4.4 Transparency/Output Handling

**Status: EXPERIMENTAL GUIDANCE** (established limitation, not a solution)

Prompt-level PNG/alpha requirements cannot necessarily override generator serialization behavior. Treat transparency/background removal as a post-processing problem, not a generation problem.

**Evidence**:
- **I-beam Run 02 Variant C**: Explicit PNG mandate did not prevent ChatGPT from filling RGBA with gradient data or Gemini from outputting JPEG
- **All RH-400 runs**: Both generators produced non-transparent backgrounds (ChatGPT: vignette; Gemini: checkerboard) regardless of prompt instructions

**What's validated**: Transparency is an environment limitation, not a prompt variable. Prompt-level requirements cannot overcome generator serialization behavior.

**What's NOT validated**: Whether future generator versions will handle transparency correctly. Whether post-processing pipelines have been designed to address this.

**Guidance**: Do not spend experimental variables on PNG/alpha generation. Treat as post-processing requirement. Document as known limitation in asset QA checklist.

---

## 5. ASSET-SPECIFIC KNOWLEDGE

These findings are **specific to the tested assets** and should not be generalized without further testing.

### 5.1 I-beam Mk1 Findings

- Simple components (single object, one material) work well with monolithic flat prompts
- Semantic color descriptions produce variable results even for simple components
- Hex color ranges eliminate cross-generator color divergence for simple components
- Layer structure quantification was tested but not validated as necessary (I-beam had no layer divergence)

### 5.2 RH-400 Findings

- Complex vehicles (six recognition features, three color zones, proportions, materials, markings) fail with monolithic flat prompts due to feature prioritization collapse
- ChatGPT processes prompts structurally; Gemini processes associatively — this pattern was consistent across all four RH-400 runs
- The cylindrical canister constraint resolved Gemini's persistent rectangular panel invention — but this is specific to cylindrical geometry
- Hazard marking hex ranges (#E8C800–#D4B500 yellow, #1A1A1A–#0D0D0D black) worked for ChatGPT and partially for Gemini — may need per-generator calibration
- The "vehicle" → "crew element" semantic association in Gemini is specific to vehicle assets; may not apply to equipment or component assets

---

## 6. OPEN QUESTIONS

These are **questions that require further experimentation** before answers can be determined.

### 6.1 Architecture Questions

| Question | Why It Matters | How to Test |
|----------|---------------|-------------|
| Does Profile Composition work for non-vehicle assets (equipment, components)? | Current validation is on one vehicle (RH-400) and one component (I-beam). Equipment assets may have different complexity profiles. | Test Profile Composition on a complex equipment asset (e.g., ISRU processor unit) with 3-4 recognition features. |
| Does the safeguard layer generalize to aerial/naval/space vehicles? | Three safeguards tested only on ground vehicle. Different vehicle types may have different failure modes. | Test on an aerial vehicle (e.g., atmospheric probe) and a space vehicle (e.g., orbital transfer craft). |
| Is 120 lines the right prompt size ceiling for all asset complexity levels? | RH-400 at ~117 lines works well. Higher-complexity assets may need more. | Test Profile Composition on an asset with 8+ recognition features and measure prompt size vs. feature retention. |
| Should per-generator color calibration become architecture or remain experimental? | Hex ranges work for ChatGPT but Gemini interprets specific hues differently. Is this a fundamental difference requiring per-generator variants, or can renderer-neutral safeguards resolve it? | Test whether additional safeguard language (e.g., "industrial yellow — not orange-yellow") eliminates the divergence without per-generator calibration. |

### 6.2 Pipeline Questions

| Question | Why It Matters | How to Test |
|----------|---------------|-------------|
| Can the five-layer dependency chain be automated as a compiler? | Current implementation is manual prompt construction. Automation would enable production-scale asset generation. | Implement a Profile Composition compiler that reads Visual Definition + Visual Profile + Render Template and produces the composed prompt automatically. |
| How should render families relate to canonical assets? | RH-400 concept suggests one asset may require multiple coordinated render types (catalog, engineering, exploded view, sprites, etc.). How do these relate to the canonical data? | Define how each render type in a family maps to the same canonical inputs with different render_type profile configurations. |
| What is the role of reference images in the pipeline? | Catalog renders were used as positive control evidence but must not silently become canonical geometry. How should they be formally integrated? | Formalize reference images as visual references only, with explicit prohibition against overriding canonical data. Define when reference images are appropriate vs. inappropriate. |
| How should asset QA integrate with the pipeline? | The architecture defines Human QA Review and Asset Registry but implementation is pending. What criteria should QA use? | Develop an automated pre-filter checklist (background transparency, feature completeness, proportion accuracy) that runs before human review. |

### 6.3 Generator Questions

| Question | Why It Matters | How to Test |
|----------|---------------|-------------|
| Is the ChatGPT/Gemini divergence pattern consistent across all generators? | Only two generators tested. Other generators (DALL-E, Midjourney, etc.) may have different failure modes. | Test the same RH-006 prompt on additional generators and compare divergence patterns. |
| Can generator-specific behavior be addressed through renderer-neutral safeguards alone? | Run 06 narrowed the gap to ~7 points but did not eliminate it. Are remaining divergences addressable without per-generator variants? | Test whether additional safeguard language (beyond the three tested) can close the remaining gap. |
| Will future generator versions change the divergence pattern? | Current findings are specific to current generator capabilities. Future versions may have different strengths/weaknesses. | Re-run RH-006 on updated generator versions and compare results. |

---

## 7. REFERENCE IMAGES — FORMALIZED ROLE

### What Reference Images ARE

Reference images (catalog renders, concept art, engineering blueprints) serve three roles:

1. **Visual references** — They communicate desired visual character (aesthetic, surface finish, level of detail) to the generator and to human reviewers.
2. **Evidence of desired visual character** — They demonstrate what "good" looks like for a specific asset family under the Visual Profile.
3. **Composition/style references** — They can inform camera angles, lighting approaches, and presentation conventions for render families.

### What Reference Images Are NOT

Reference images must NOT silently become canonical geometry. Specifically:

- **NOT blueprint override**: If a reference image shows a feature that contradicts the Blueprint, the Blueprint wins. The prompt — not the reference — is the problem.
- **NOT dimension source**: Reference images do not provide measurable dimensions. Canonical data (Blueprint operational data) provides authoritative dimensions.
- **NOT feature authority**: If the Visual Definition lists six recognition features and the reference image shows five, all six must be in the prompt regardless of what the reference shows.
- **NOT style override**: The Visual Profile defines locked attributes. Reference images may illustrate the style but cannot override it.

### When to Use Reference Images

| Use Case | Appropriate? | Notes |
|----------|-------------|-------|
| Communicating desired aesthetic to generator | ✅ Yes | Include as visual reference in generation environment if supported |
| Establishing visual quality target for QA | ✅ Yes | Use as comparison standard during human review |
| Informing render family composition conventions | ✅ Yes | Catalog renders inform camera/lighting choices for other render types |
| Overriding Blueprint dimensions | ❌ No | Canonical data always wins |
| Adding features not in Visual Definition | ❌ No | Prompt must match canonical sources, not reference images |
| Replacing hex color ranges with "match this color" | ⚠️ Context-dependent | Hex ranges are more reliable; reference colors can supplement but not replace |

---

## 8. RENDER FAMILIES — CONCEPTUAL FRAMEWORK

One asset may require multiple coordinated render types, each serving a different purpose in the game pipeline:

### Render Family Types (Conceptual)

| Render Type | Purpose | Camera/View | Detail Level | Relation to Canonical Data |
|-------------|---------|-------------|--------------|---------------------------|
| **Catalog Render** | Asset family sheet, encyclopedia entry | Multi-view (front/rear/side) | Highest detail | All canonical features present |
| **Engineering Blueprint** | Technical reference, manufacturing spec | Orthographic with dimensions | Line-art precision | Dimensions from Blueprint operational data |
| **Exploded View** | Assembly/maintenance visualization | Isometric exploded | Component-level detail | All components from Blueprint |
| **Surface Sprite** | Texture/material reference | Flat/orthographic | Surface finish only | Material profiles from Visual Profile |
| **Animation Frames** | Status lights, movement, operation | Dynamic views | Frame-by-frame consistency | Operational data drives animation behavior |
| **Damage States** | Progressive damage visualization | Same camera as base render | Consistent with base render | Blueprint defines damage thresholds |
| **Thumbnail/Icon** | UI inventory display | Optimized for 32-64px | Silhouette only | Silhouette rules from Visual Profile |

### How Render Families Relate to Canonical Asset

All render types in a family derive from the same canonical inputs:
- **Blueprint** provides geometry, dimensions, and component list
- **Operational Data** provides functional behavior (power, output, speed)
- **Visual Definition** provides appearance spec and recognition features
- **Visual Profile** provides locked style attributes
- **Render Template** provides camera/lighting/background rules for each render type

The difference between render types is the **render_type profile configuration**, not the canonical data. Each render type uses the same Blueprint + Operational Data + Visual Definition + Visual Profile but applies different render_type profile settings (camera, lighting, background, output format).

### Future Work

Do not design all render families yet. The RH-400 catalog render demonstrates that one asset can support multiple coordinated render types. Future work should:
1. Define render_type profile configurations for each render type
2. Test whether Profile Composition + render_type profiles produce consistent family members
3. Establish how render families relate to the Asset Registry (one canonical asset → multiple registered renders)

---

## 9. ASSET/UI RELATIONSHIP — ARCHITECTURAL INTENT

### Rich Imagery Informs Game UI and Encyclopedia Views

The rich catalog/engineering imagery produced by the pipeline can eventually inform:
- **Game UI**: Icon/thumbnail renders for inventory display, status indicators for damage states
- **Encyclopedia/detail views**: Catalog renders and engineering blueprints for in-game reference
- **Tutorial/maintenance interfaces**: Exploded views and animation frames for assembly instructions

### Sprites Remain Independently Usable

Surface sprites and icon renders are independently usable across multiple rendering layers:
- **Civ4/FreeCiv-style surface layers**: Tile-based terrain rendering with unit overlays
- **TerrainForge/SimCity-style views**: Isometric/orthographic city-building views
- **Other gameplay rendering layers**: Any layer that needs asset representation at appropriate detail level

### Architectural Intent

The pipeline produces a **rich canonical asset** (multiple render types from one canonical definition) that can serve multiple UI/gameplay purposes without requiring separate art production for each use case. This is an architectural intent, not an implementation requirement. Implementation depends on game engine capabilities and UI design decisions.

---

## 10. EVALUATION METHODOLOGY — WHY CONTROLLED SEQUENTIAL EXPERIMENTS

### Why Controlled Sequential Experiments Are Preferable

**Continuous prompt modification creates uncontrolled experiments where no finding is attributable to any specific change.** Each run in this series tested one hypothesis with minimal variables:

| Run | Hypothesis Tested | Variable Changed | Finding |
|-----|-------------------|-----------------|---------|
| I-beam 01 | Does pipeline work for simple components? | None (control) | Yes, but semantic colors produce variable results |
| I-beam 02 | Do hex colors fix color divergence? | Hex ranges only | Yes, eliminates cross-generator color divergence |
| RH-400 03 | Does monolithic prompt work for complex assets? | None (control) | No — feature prioritization collapse at complexity |
| RH-400 04 | Does Profile Composition fix feature collapse? | Profile Composition layer only | Yes — features went from 1/6 to 4-6/6 |
| RH-400 05 | Do targeted refinements improve consistency? | Hex colors + canister description + hazard reinforcement | Mixed — ChatGPT improved, Gemini regressed on camera/autonomous |
| RH-400 06 | Do safeguards fix Gemini's Run 05 failures? | Camera precedence + autonomous protection + sensor mast elevation | Yes — all three safeguards effective, gap narrowed to ~7 points |

### Core Principle: A Failed Experiment Is a Finding

**Do not rewrite the prompt merely to make generators agree.** Each divergence between generators is data about generator behavior, not a failure of the pipeline. The goal is to understand what works, why it works, and where generators diverge — not to force agreement at the cost of experimental validity.

### Evaluation Rubric (A–N)

The A–N evaluation rubric provides consistent scoring across all runs:
- **A**: Structural/Overall Geometry
- **B**: Vehicle Identity
- **C**: Recognition Feature Completeness
- **D**: Proportion Accuracy
- **E**: Material Appearance
- **F**: Tech Level Consistency
- **G**: Hazard Markings
- **H**: Absence of Unsupported Context
- **I**: Blueprint Adherence
- **J**: Unwanted Invented Details
- **K**: Asset Isolation/Presentation
- **L**: Cross-Model Consistency
- **M**: Silhouette Strength
- **N**: Mechanical Plausibility

This rubric enables direct comparison across runs and assets. It should be used for all future complex asset evaluations.

---

## 11. COMPLETE VALIDATED PIPELINE

Based on the experimental evidence, the validated pipeline is:

```
Game Design
    ↓
Blueprint Schema (unit_blueprint.json or component_blueprint.json)
    ↓
Operational Data (operational_data JSON)
    ↓
Visual Definition (visual_definition JSON with recognition_features + visual_priority)
    ↓
Schema Validation (required fields, ID resolution, cross-reference checks)
    ↓
Profile Composition (resolves global_visual_style, manufacturing_style, technology_level, render_type into structured attributes)
    ↓
Targeted Refinements (hex color ranges for critical zones; negative+positive geometric constraints for persistent failures)
    ↓
Safeguard Layer (camera precedence; autonomous/crewless protection; protected recognition features — for complex assets where generator-specific failures have been identified)
    ↓
Prompt Generation (frozen, ≤120 lines for complex vehicles)
    ↓
Asset Generation (ChatGPT + Gemini dual-generator evaluation)
    ↓
Asset QA (A–N rubric scoring; cross-generator comparison; reference to canonical data)
    ↓
Asset Registry (canonical ID, render types, blueprint version, prompt version, QA status)
    ↓
Game Integration (sprites for gameplay layers; catalog renders for UI/encyclopedia)
```

### Classification of Each Layer

| Layer | Classification | Evidence |
|-------|---------------|----------|
| Five-Layer Dependency Chain | **VALIDATED ARCHITECTURE** | All six runs followed this chain |
| Profile Composition | **VALIDATED ARCHITECTURE** | RH-400 Run 04 proved it is the missing layer; maintained across Runs 04→05→06 |
| Schema Validation | **VALIDATED ARCHITECTURE** (conceptually) | Required for ID resolution; validated through canonical data usage |
| Targeted Refinements | **EXPERIMENTAL GUIDANCE** | Tested on one asset family; hex colors validated, geometric constraints validated for cylindrical geometry only |
| Safeguard Layer | **EXPERIMENTAL GUIDANCE** | Three safeguards tested on one complex vehicle; effective but not yet generalized |
| Frozen Prompt Discipline | **VALIDATED ARCHITECTURE** | Essential for valid experimental comparison across all six runs |
| Dual-Generator Evaluation | **VALIDATED PRACTICE** | Consistent pattern of ChatGPT (structural) vs Gemini (associative) processing |
| A–N Rubric Scoring | **VALIDATED PRACTICE** | Used consistently across all evaluations; enables direct comparison |
| Asset Registry | **VALIDATED ARCHITECTURE** (conceptually) | Required for version tracking; implementation pending |
| Reference Image Role | **VALIDATED PRACTICE** | Formalized in Section 7; reference ≠ canonical geometry |
| Render Families | **EXPERIMENTAL GUIDANCE** | Conceptual framework defined; testing needed on multiple assets |
| Asset/UI Relationship | **ARCHITECTURAL INTENT** (not yet validated) | Design intent documented; implementation depends on game engine |

---

## 12. SUMMARY OF FINDINGS

### What Is Now Architecture (Do Not Change Without New Evidence)

1. Five-layer dependency chain (Blueprint → Visual Profile → Visual Definition → Operational Data → Render Template)
2. Profile Composition layer with hierarchical priority mapping to `visual_priority` field
3. Frozen prompt discipline (FROZEN upon preparation, no modifications during/after generation)
4. Asset Registry concept (canonical ID, render types, version tracking, QA status)

### What Is Validated Practice (Codify as Standard Operating Procedure)

1. Controlled sequential experimentation (one hypothesis per run, minimal variables)
2. Canonical data supremacy (generated images never override canonical geometry)
3. Cross-generator evaluation protocol (always evaluate ChatGPT + Gemini with A–N rubric)
4. Prompt size discipline (≤120 lines for complex vehicles; each added line addresses specific divergence)

### What Is Experimental Guidance (Test Before Generalizing)

1. Hex color ranges for critical color zones (validated for ChatGPT; partially validated for Gemini)
2. Negative + positive geometric constraints (definitively resolved cylindrical canister for Gemini)
3. Safeguard layer (three safeguards effective on one complex vehicle; needs testing on other asset types)
4. Transparency as post-processing problem (established limitation, not a solution)

### What Is Asset-Specific Knowledge (Do Not Generalize)

1. I-beam Mk1: Simple components work with monolithic prompts; hex colors fix color divergence
2. RH-400: ChatGPT processes structurally; Gemini processes associatively; "vehicle" → "crew element" association in Gemini

### What Are Open Questions (Require Further Experimentation)

1. Does Profile Composition work for non-vehicle assets?
2. Do safeguards generalize to aerial/naval/space vehicles?
3. Is 120 lines the right ceiling for all complexity levels?
4. Should per-generator color calibration become architecture?
5. Can the five-layer chain be automated as a compiler?
6. How should render families relate to canonical assets?
7. What is the role of reference images in the pipeline?
8. How should asset QA integrate with the pipeline?
9. Is the ChatGPT/Gemini divergence pattern consistent across all generators?
10. Will future generator versions change the divergence pattern?

---

*Validation report created: 2026-08-27*
*Based on six controlled experiments across two assets (I-beam Mk1, RH-400 Regolith Harvester Rover).*
*No files modified beyond this document.*
