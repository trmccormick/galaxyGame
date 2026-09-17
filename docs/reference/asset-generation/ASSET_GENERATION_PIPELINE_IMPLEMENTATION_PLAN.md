# Asset Generation Pipeline — Implementation Plan

**Date**: 2026-08-27
**Purpose**: Implementation plan for turning validated asset-generation findings into reusable GalaxyGame infrastructure.
**Scope**: Data-driven, extensible pipeline applicable to all asset types (not RH-400-specific).
**Status**: Planning only — no code, no file modifications, no new prompts.

---

## 1. EXISTING COMPONENTS AUDIT

### 1.1 What Already Exists in the Codebase

| Component | Status | Location | Notes |
|-----------|--------|----------|-------|
| **Blueprint Schema** (`unit_blueprint.json`) | ✅ EXISTING (specification) | `data/json-data/schemas/blueprint/` | Schema exists; RH-400 blueprint instance exists at `data/json-data/blueprints/crafts/ground/regolith_harvester_rover_bp.json` v2.1 |
| **Blueprint Schema** (`component_blueprint.json`) | ✅ EXISTING (specification) | `data/json-data/schemas/blueprint/` | Schema defined in ASSET_PROMPT_COMPILER_CONTRACT.md; no instances exist yet |
| **Operational Data Schema** | ✅ EXISTING (specification) | `data/json-data/schemas/operational_data/` | Schema exists; RH-400 operational data instance exists at `data/json-data/operational_data/crafts/ground/regolith_harvesting_rover_data.json` v2.1 |
| **Visual Definition Template** | ✅ EXISTING (specification) | `docs/reference/asset-generation/VISUAL_DEFINITION_TEMPLATE.md` | Schema/template defined; no instances exist yet |
| **Visual Profile** (`precision_industrial_v1`) | ✅ EXISTING (instance) | `docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md` v1.1 | One instance exists; reusable profile with locked attributes |
| **Render Template** | ✅ EXISTING (instance) | `docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | One instance exists; defines camera/lighting/background/output rules |
| **RH-400 Visual Definition** | ✅ EXISTING (instance) | `docs/reference/asset-generation/visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json` | First real Visual Definition instance for a complex vehicle |
| **Profile Composition Spec** | ✅ EXISTING (specification) | `docs/reference/asset-generation/PROFILE_COMPOSITION_SPEC.md` | Specification only; no implementation |
| **Asset Prompt Compiler Contract** | ✅ EXISTING (specification) | `docs/reference/asset-generation/ASSET_PROMPT_COMPILER_CONTRACT.md` v0.1 | Full five-layer dependency chain + validation rules specified; no implementation |
| **Asset Generation Architecture** | ✅ EXISTING (specification) | `docs/reference/asset-generation/ASSET_GENERATION_ARCHITECTURE.md` | Pipeline architecture with PromptBuilder, Image Generator, QA, Asset Registry defined; no implementation |
| **RH-400 frozen prompts** | ✅ EXISTING (artifacts) | `docs/reference/asset-generation/rh400_run0{3-6}_profile_composed_prompt.txt` | Four frozen prompts from validated experiments |
| **I-beam frozen prompts** | ✅ EXISTING (artifacts) | `docs/reference/asset-generation/ibeam_mk1_prompt_primary.txt`, `ibeam_mk1_prompt_quadrant.txt` | Two frozen prompts from I-beam experiments |
| **Validation Report** | ✅ EXISTING (analysis) | `docs/reference/asset-generation/ASSET_GENERATION_PIPELINE_VALIDATION.md` | Classification of architecture vs practice vs experimental guidance |

### 1.2 What Is Specification-Only (No Implementation)

| Component | Status | Location | Notes |
|-----------|--------|----------|-------|
| **PromptBuilder** | ❌ SPECIFICATION ONLY | `ASSET_GENERATION_ARCHITECTURE.md` | Architecture doc describes what it does; no class/service exists |
| **Blueprint Validator** | ❌ SPECIFICATION ONLY | `ASSET_GENERATION_ARCHITECTURE.md`, `ASSET_PROMPT_COMPILER_CONTRACT.md` | Validation rules defined; no validator code exists |
| **Profile Composition Engine** | ❌ SPECIFICATION ONLY | `PROFILE_COMPOSITION_SPEC.md` | Profile types, resolution order, precedence rules all specified; no engine exists |
| **Targeted Refinement Mechanism** | ❌ NOT IMPLEMENTED | Experiment artifacts only | Hex colors, geometric constraints tested manually; no mechanism exists |
| **Safeguard Layer** | ❌ NOT IMPLEMENTED | Experiment artifacts only | Three safeguards tested manually on RH-006; no mechanism exists |
| **Asset Registry** | ❌ SPECIFICATION ONLY | `ASSET_GENERATION_ARCHITECTURE.md` | Schema defined (canonical ID, render types, versions, QA status); no registry exists |
| **Automated Pre-Filter** | ❌ SPECIFICATION ONLY | `ASSET_GENERATION_ARCHITECTURE.md` | Checklist items defined; no pre-filter code exists |
| **Generator Abstraction Layer** | ❌ NOT IMPLEMENTED | Architecture doc mentions "model-agnostic" conceptually | No abstraction layer exists; generation is manual via ChatGPT/Gemini interfaces |
| **Render Family System** | ❌ NOT IMPLEMENTED | Conceptual framework only | Render types defined in architecture doc; no family management exists |

### 1.3 What Is Missing Entirely

| Component | Status | Notes |
|-----------|--------|-------|
| **Profile Resolution Engine** | ❌ MISSING | Reads Visual Profile markdown, extracts locked attributes, resolves profile types — does not exist |
| **Composition Refinery** | ❌ MISSING | Takes composed attributes + targeted refinements + safeguards → structured output for PromptBuilder — does not exist |
| **Prompt Compiler/Builder** | ❌ MISSING | Walks five-layer chain, validates, substitutes variables, produces final prompt — does not exist |
| **Generator Adapter Interface** | ❌ MISSING | Common generation interface abstracting ChatGPT/Gemini differences — does not exist |
| **QA Automation Layer** | ❌ MISSING | Automated pre-filter + A–N rubric scoring — does not exist |
| **Asset Registry Storage** | ❌ MISSING | Persistent registry for canonical assets, render types, versions, QA status — does not exist |
| **Render Family Manager** | ❌ MISSING | Manages multiple render types per asset with shared canonical inputs — does not exist |

---

## 2. ARCHITECTURE TO IMPLEMENT

### 2.1 Pipeline Architecture (Reconciled)

The validated generation flow from the experiment series maps to these implementation layers:

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 0: CANONICAL DATA INPUTS                             │
│                                                             │
│  Blueprint (unit_blueprint.json or component_blueprint.json)│
│  Operational Data (operational_data JSON)                   │
│  Visual Definition (visual_definition JSON)                 │
│  Visual Profile (VISUAL_PROFILE_*.md — markdown, not JSON)  │
│  Render Template (PRODUCTION_ASSET_RENDER_TEMPLATE_*.md)    │
│                                                             │
│  STATUS: All exist as specification + some instances        │
│  IMPLEMENTATION: Schema validation only; no code needed     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: PROFILE RESOLUTION                                │
│                                                             │
│  Reads Visual Profile markdown → extracts locked attributes │
│  Resolves profile types (global_visual_style,              │
│  manufacturing_style, technology_level, render_type)        │
│  Cross-validates Blueprint vs Visual Definition fields      │
│                                                             │
│  STATUS: Specification exists (PROFILE_COMPOSITION_SPEC.md) │
│  IMPLEMENTATION: New service class                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 2: COMPOSITION REFINERY                              │
│                                                             │
│  Takes composed attributes + targeted refinements +         │
│  safeguards → structured output for PromptBuilder           │
│                                                             │
│  Targeted Refinements (configurable, not hard-coded):       │
│    - Hex color ranges (EXPERIMENTAL — configurable)         │
│    - Geometric constraints (EXPERIMENTAL — configurable)    │
│    - Negative/positive constraint pairs                     │
│                                                             │
│  Safeguards (configurable, not hard-coded):                 │
│    - Camera precedence rules                                │
│    - Autonomous/crewless protection                         │
│    - Recognition feature tier elevation                     │
│                                                             │
│  STATUS: Specification exists; safeguards tested on RH-006  │
│  IMPLEMENTATION: New service class + configuration layer    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 3: PROMPT COMPILER/BUILDER                           │
│                                                             │
│  Walks five-layer dependency chain                          │
│  Validates required fields, resolves IDs                    │
│  Substitutes structured data into Render Template           │
│  Produces final renderer-neutral prompt (FROZEN)            │
│  Adds provenance header                                     │
│                                                             │
│  STATUS: Contract exists (ASSET_PROMPT_COMPILER_CONTRACT.md)│
│  IMPLEMENTATION: New service class                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 4: ASSET GENERATION                                  │
│                                                             │
│  Common generation interface (generator-agnostic)           │
│  Generator adapters (ChatGPT, Gemini, future generators)    │
│  Adapter-specific configuration (only where evidence        │
│  justifies per-generator behavior)                          │
│                                                             │
│  STATUS: Manual generation via ChatGPT/Gemini interfaces    │
│  IMPLEMENTATION: New interface + adapter pattern            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 5: ASSET QA                                          │
│                                                             │
│  Automated pre-filter (background transparency,             │
│  feature completeness, proportion accuracy)                 │
│  A–N rubric scoring (human-automated hybrid)                │
│  Canonical geometry comparison                              │
│  Recognition feature verification                           │
│  Unwanted detail detection                                  │
│                                                             │
│  STATUS: Specification exists; manual evaluation used       │
│         in all six runs                                     │
│  IMPLEMENTATION: New service class + rubric engine          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 6: ASSET REGISTRY                                    │
│                                                             │
│  Persistent storage of canonical assets                     │
│  Canonical ID, render types, blueprint version,             │
│  prompt version, QA status, obsolete references             │
│                                                             │
│  STATUS: Specification exists (ASSET_GENERATION_ARCHITECTURE)│
│         no implementation                                   │
│  IMPLEMENTATION: New registry service + storage backend     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 7: RENDER FAMILY MANAGER                             │
│                                                             │
│  Manages multiple render types per asset                    │
│  Each render type shares canonical inputs                   │
│  Differs only in render_type profile configuration          │
│                                                             │
│  STATUS: Conceptual framework only                          │
│         (catalog, engineering, exploded view, sprites,      │
│         animation frames, damage states, icon/thumbnail)    │
│  IMPLEMENTATION: FUTURE — define render_type configs first  │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 8: GAME INTEGRATION                                  │
│                                                             │
│  Consumes approved assets from Asset Registry               │
│  References by canonical ID (not filename)                  │
│  All complexity levels available                            │
│  Animation profiles applied at runtime                      │
│  Damage states layered on top                               │
│                                                             │
│  STATUS: Architectural intent only                          │
│         implementation depends on game engine decisions     │
│  IMPLEMENTATION: FUTURE — after layers 0-6 are stable       │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Component-by-Component Implementation Status

| Layer | Component | Classification | What to Implement |
|-------|-----------|---------------|-------------------|
| 0 | Canonical Data Inputs | EXISTING (specification + instances) | Schema validation only; no code changes needed |
| 1 | Profile Resolution Engine | IMPLEMENT | New service: reads Visual Profile markdown, extracts locked attributes, resolves profile types, cross-validates Blueprint vs Visual Definition |
| 2a | Composition Refinery | IMPLEMENT | New service: takes composed attributes + targeted refinements + safeguards → structured output for PromptBuilder |
| 2b | Targeted Refinements Mechanism | EXPERIMENTAL (configurable) | Configuration layer, not hard-coded values; hex ranges, geometric constraints as optional parameters |
| 2c | Safeguard Layer | EXPERIMENTAL (configurable) | Configuration layer, not hard-coded rules; camera precedence, autonomous protection, feature tier elevation as optional modules |
| 3 | Prompt Compiler/Builder | IMPLEMENT | New service: walks five-layer chain, validates, substitutes variables, produces FROZEN prompt with provenance header |
| 4 | Generator Abstraction Interface | IMPLEMENT | Common generation interface; generator adapters (ChatGPT, Gemini) behind interface; per-generator config only where evidence justifies |
| 5 | Asset QA | IMPLEMENT | Automated pre-filter + A–N rubric engine; human-automated hybrid scoring |
| 6 | Asset Registry | IMPLEMENT | Persistent storage; canonical ID, render types, versions, QA status |
| 7 | Render Family Manager | FUTURE (optional) | Define render_type configs first; family management after layers 0-6 are stable |
| 8 | Game Integration | FUTURE (optional) | Depends on game engine decisions; not part of this implementation plan |

---

## 3. DATA BOUNDARIES

### 3.1 What Belongs Where — No Duplication

| Data Type | Canonical Source | Why Here | Other Layers Access Via |
|-----------|-----------------|----------|------------------------|
| **Geometry/dimensions** (length, width, height, mass) | Blueprint operational data | Authoritative source of truth | Profile Resolution reads for proportion_anchors; Prompt Compiler substitutes into prompt |
| **Functional role** | Operational Data | Runtime behavior specification | Prompt Compiler substitutes into SUBJECT section |
| **Recognition features + visual_priority** | Visual Definition | Asset-specific appearance spec | Profile Composition maps to hierarchy tiers; Prompt Compiler substitutes into tiered sections |
| **Locked style attributes** (materials, finish, aesthetic) | Visual Profile (markdown) | Reusable across assets in same family | Profile Resolution extracts; Profile Composition resolves into structured attributes |
| **Manufacturing style** | Blueprint + Visual Definition (cross-layer) | Both must agree | Cross-layer validation in Profile Resolution; warning on mismatch |
| **Technology level** | Blueprint + Visual Definition (cross-layer) | Both must agree | Cross-layer validation in Profile Resolution; warning on mismatch |
| **Camera/lighting/background/output rules** | Render Template | Pipeline-level choice, not asset data | Profile Composition resolves into render_type profile; Prompt Compiler substitutes into RENDER REQUIREMENTS section |
| **Hex color ranges** | Targeted Refinements (configurable) | EXPERIMENTAL — not canonical data | Optional parameter to Composition Refinery; NOT stored in Blueprint/Visual Definition |
| **Safeguard rules** | Safeguard Layer (configurable) | EXPERIMENTAL — not canonical data | Optional module in Composition Refinery; NOT stored in Blueprint/Visual Definition |
| **Proportion visual anchors** | Profile Composition output | Derived from canonical dimensions + generation instructions | Generated by Profile Resolution from canonical dimensions; used by Prompt Compiler |

### 3.2 What Does NOT Belong Where

| Data Type | Should NOT Be In | Should Be In | Reason |
|-----------|-----------------|--------------|--------|
| Hex color ranges | Blueprint, Visual Definition, Visual Profile | Composition Refinery config | EXPERIMENTAL guidance — not validated across assets; hard-coding would make it architecture prematurely |
| Safeguard rules | Blueprint, Visual Definition, Visual Profile | Composition Refinery config | EXPERIMENTAL guidance — tested on one asset family only; per-asset configuration required |
| Generator-specific behavior | Any canonical data layer | Generator adapter config | Generator behavior is runtime, not design-time; must be isolated from canonical data |
| Reference image colors | Blueprint, Visual Definition, Visual Profile | QA comparison reference only | Reference images are visual references, NOT canonical geometry (validated in Section 7 of validation report) |
| Render family outputs | Canonical data layers | Asset Registry + Render Family Manager | Render families derive from canonical inputs; they are outputs, not inputs |

### 3.3 Data Flow Summary

```
Blueprint (geometry, dimensions, manufacturing_style, technology_level, visual_profile ID)
    ↓ reads
Visual Profile (locked attributes: materials, finish, aesthetic, markings)
    ↓ resolves
Profile Resolution Engine → structured profile attributes
    ↓
Visual Definition (recognition_features + visual_priority, material_profiles)
    ↓
Composition Refinery (applies optional targeted refinements + safeguards)
    ↓ structured output
Prompt Compiler (walks chain, validates, substitutes into Render Template)
    ↓ FROZEN prompt
Generator Adapter → image generation
    ↓ asset output
Asset QA (automated pre-filter + A-N rubric)
    ↓ approved/feedback
Asset Registry (canonical ID, render types, versions, QA status)
```

---

## 4. EXPERIMENTAL vs PRODUCTION BEHAVIOR

### 4.1 Classification of Each Experimental Finding

| Finding | Classification | Implementation Approach |
|---------|---------------|------------------------|
| **Hex color ranges** for critical zones | EXPERIMENTAL GUIDANCE | Configuration parameter, NOT hard-coded. Optional refinement module. Per-asset configuration required. Monitor generator adherence before generalizing. |
| **Negative + positive geometric constraints** | EXPERIMENTAL GUIDANCE | Configuration parameter, NOT hard-coded. Optional refinement module. Validated for cylindrical geometry only; test on other shapes before generalizing. |
| **Safeguard layer** (camera precedence, autonomous protection, feature tier elevation) | EXPERIMENTAL GUIDANCE | Optional modules in Composition Refinery. Three tested safeguards available as configuration options. Test on additional asset types before enabling by default. |
| **Prompt size ≤120 lines** for complex vehicles | VALIDATED PRACTICE | Soft limit with warning. Not a hard constraint — complexity may require more. Use as guidance metric, not enforcement rule. |
| **Generator-specific behavior** (ChatGPT structural vs Gemini associative) | ASSET-SPECIFIC KNOWLEDGE | Isolate in generator adapter layer. Do NOT propagate into canonical data or prompt compilation. Per-generator config only where evidence justifies. |
| **Transparency as post-processing** | ESTABLISHED LIMITATION | Document as known limitation in QA checklist. Do not implement transparency generation in pipeline. Treat as post-processing requirement. |

### 4.2 Configuration Design Principle

All experimental findings must be implemented as **configuration**, not hard-coded values:

```yaml
# Example configuration structure (NOT implementation — design direction only)
targeted_refinements:
  enabled: false  # opt-in, not default
  hex_color_ranges:
    enabled: false  # per-zone configuration required
    zones: []  # defined per-asset
  geometric_constraints:
    enabled: false  # per-shape testing required
    constraints: []  # defined per-asset

safeguards:
  camera_precedence:
    enabled: false  # test on additional asset types first
  autonomous_protection:
    enabled: false  # vehicle-specific only
  feature_tier_elevation:
    enabled: false  # per-feature testing required

prompt_size:
  soft_limit_lines: 120
  warning_threshold: 100  # warn at 100, hard stop at 120 (configurable)
```

---

## 5. REFERENCE IMAGE ARCHITECTURE

### 5.1 Reference Image Role in Pipeline

Reference images serve three roles but must never silently override canonical geometry:

| Role | How to Supply | Where Stored | Access Boundary |
|------|--------------|--------------|-----------------|
| **Visual reference** (aesthetic, surface finish, detail level) | Optional parameter to generation interface | Asset Registry (linked by canonical ID) | Generator adapter reads for visual context; NOT substituted into prompt text |
| **QA comparison standard** | Linked from Asset Registry entry | Asset Registry (linked by canonical ID) | QA layer compares generated output against reference; does not modify prompt |
| **Composition/style reference** (camera, lighting, presentation conventions) | Optional parameter to Render Template configuration | Render Family Manager (per-render-type config) | Used to inform render_type profile settings; NOT substituted into prompt text |

### 5.2 Anti-Override Safeguards

Reference images must never silently override canonical data. Implementation safeguards:

1. **Prompt compilation layer**: Reference images are NEVER read by the Prompt Compiler. The compiler only reads canonical data layers (Blueprint, Operational Data, Visual Definition, Visual Profile, Render Template). This is a hard boundary.

2. **Generator adapter layer**: If reference images are supplied to the generator (as visual context), they are passed as separate parameters — NOT merged into prompt text. The adapter documents whether reference images were used in the generation metadata.

3. **QA layer**: Reference images are comparison standards, not authority sources. QA compares generated output against canonical data first, then against reference images second. If a discrepancy exists between reference image and canonical data, canonical data wins.

4. **Asset Registry**: Reference images are stored as linked assets (not embedded in canonical data). Each registry entry has a `reference_images` field listing associated visual references with their role (aesthetic, composition, QA comparison).

### 5.3 When Reference Images Are Appropriate vs Inappropriate

| Scenario | Appropriate? | How to Handle |
|----------|-------------|---------------|
| Communicating desired aesthetic to generator | ✅ Yes | Pass as separate visual context parameter to generator adapter; NOT into prompt text |
| Establishing visual quality target for QA | ✅ Yes | Store in Asset Registry as comparison standard; QA compares against it |
| Informing render family composition conventions | ✅ Yes | Use to inform render_type profile settings in Render Family Manager |
| Overriding Blueprint dimensions | ❌ No | Canonical data always wins; document discrepancy in QA feedback |
| Adding features not in Visual Definition | ❌ No | Prompt must match canonical sources; reference images cannot add features |
| Replacing hex color ranges with "match this color" | ⚠️ Context-dependent | Hex ranges are more reliable; reference colors can supplement but not replace |

---

## 6. RENDER FAMILIES — EXTENSIBLE MODEL

### 6.1 Render Family Architecture (Conceptual)

One canonical asset → multiple render types, each serving a different purpose:

| Render Type | Purpose | Camera/View | Detail Level | Relation to Canonical Data |
|-------------|---------|-------------|--------------|---------------------------|
| **catalog_render** | Asset family sheet, encyclopedia entry | Multi-view (front/rear/side) | Highest detail | All canonical features present |
| **engineering_blueprint** | Technical reference, manufacturing spec | Orthographic with dimensions | Line-art precision | Dimensions from Blueprint operational data |
| **exploded_view** | Assembly/maintenance visualization | Isometric exploded | Component-level detail | All components from Blueprint |
| **surface_sprite** | Texture/material reference | Flat/orthographic | Surface finish only | Material profiles from Visual Profile |
| **animation_frames** | Status lights, movement, operation | Dynamic views | Frame-by-frame consistency | Operational data drives animation behavior |
| **damage_states** | Progressive damage visualization | Same camera as base render | Consistent with base render | Blueprint defines damage thresholds |
| **icon_thumbnail** | UI inventory display | Optimized for 32-64px | Silhouette only | Silhouette rules from Visual Profile |

### 6.2 How Render Families Relate to Canonical Asset

All render types in a family derive from the same canonical inputs:
- **Blueprint** provides geometry, dimensions, and component list
- **Operational Data** provides functional behavior (power, output, speed)
- **Visual Definition** provides appearance spec and recognition features
- **Visual Profile** provides locked style attributes
- **Render Template** provides camera/lighting/background rules for each render type

The difference between render types is the **render_type profile configuration**, not the canonical data. Each render type uses the same Blueprint + Operational Data + Visual Definition + Visual Profile but applies different render_type profile settings (camera, lighting, background, output format).

### 6.3 Implementation Phasing for Render Families

| Phase | What to Do | Status |
|-------|-----------|--------|
| **Phase 1** (FUTURE) | Define `render_type` profile configurations for each render type | NOT STARTED — conceptual framework only |
| **Phase 2** (FUTURE) | Test Profile Composition + render_type profiles produce consistent family members | NOT STARTED — requires Phase 1 complete |
| **Phase 3** (FUTURE) | Implement Render Family Manager in Asset Registry | NOT STARTED — depends on Phase 1-2 validation |

**Do not implement render families until layers 0-6 are stable.** The catalog render demonstrates one asset can support multiple coordinated render types. Future work should define render_type profile configurations first, then test consistency before implementing management infrastructure.

---

## 7. PROMPT COMPILATION — STRUCTURED DATA TO FINAL PROMPT

### 7.1 Compilation Process

The Prompt Compiler walks the five-layer dependency chain and produces a FROZEN prompt:

```
Input (canonical data layers):
  Blueprint → operational_data_id, visual_profile_id, manufacturing_style, technology_level
  Operational Data → functional_role, dimensions, mass
  Visual Definition → recognition_features (with visual_priority), material_profiles
  Visual Profile → locked attributes (materials, finish, aesthetic, markings)
  Render Template → camera/lighting/background/output rules

Profile Resolution:
  Reads Visual Profile markdown → extracts locked attributes
  Resolves profile types (global_visual_style, manufacturing_style, technology_level, render_type)
  Cross-validates Blueprint vs Visual Definition fields

Composition Refinery:
  Takes composed attributes + optional targeted refinements + optional safeguards
  Outputs structured attributes (not prose) for PromptBuilder

Prompt Compiler:
  Walks five-layer chain
  Validates required fields, resolves IDs
  Substitutes structured data into Render Template variables
  Orders recognition features by priority tier (primary → secondary → tertiary)
  Produces FROZEN prompt with provenance header

Output:
  Final renderer-neutral prompt (FROZEN upon preparation)
  Provenance header (canonical IDs, versions, timestamp)
```

### 7.2 Prompt Structure (Template-Driven)

The Render Template defines the prompt structure. Variables are substituted by the Prompt Compiler from structured data:

```
SUBJECT:
  {{FUNCTIONAL_ROLE}} (from Operational Data)

CAMERA:
  {{camera_rules}} (from Render Template, via render_type profile)

PROPORTIONS:
  {{visual_anchors}} (derived from canonical dimensions in Operational Data)

STYLE:
  {{global_visual_style}} (resolved from Visual Profile)

MANUFACTURING:
  {{manufacturing_style}} (resolved from Blueprint + Visual Definition cross-validation)

TECHNOLOGY LEVEL:
  {{technology_level}} (resolved from Blueprint + Visual Definition cross-validation)

DESIGN CONSTRAINTS:
  {{safeguard_config.autonomous_protection}} (optional, EXPERIMENTAL)

MARKINGS:
  {{markings}} (from Visual Profile locked attributes)

RECOGNITION FEATURES:
  PRIMARY:
    {{primary_features}} (from Visual Definition visual_priority = primary)
  SECONDARY:
    {{secondary_features}} (from Visual Definition visual_priority = secondary)
  TERTIARY:
    {{tertiary_features}} (from Visual Definition visual_priority = tertiary)

RENDER REQUIREMENTS:
  {{render_requirements}} (from Render Template)

BACKGROUND:
  {{background_rules}} (from Render Template)

OUTPUT:
  {{output_format}} (from Render Template)
```

### 7.3 Provenance Header

Every compiled prompt includes a provenance header:

```
# Generated Prompt — Provenance Header
# Asset ID: <canonical_id>
# Blueprint Version: <version>
# Operational Data Version: <version>
# Visual Definition Version: <version>
# Visual Profile: <profile_id>
# Render Template: <template_id>
# Composition Method: <method> (e.g., profile_composition_v1)
# Targeted Refinements: <list of enabled refinements or "none">
# Safeguards: <list of enabled safeguards or "none">
# Generated At: <ISO timestamp>
# Prompt Version: <auto-incremented version>
# Status: FROZEN
```

---

## 8. GENERATOR ABSTRACTION

### 8.1 Common Generation Interface

All generators must be accessed through a common interface:

```ruby
# Conceptual interface (NOT implementation)
class AssetGenerator
  # Generate asset from compiled prompt
  # Returns: { image_path:, metadata:, generator_name:, generation_time_ms: }
  def generate(prompt:, render_type:, options = {})
    raise NotImplementedError
  end

  # Evaluate generated asset against A-N rubric
  # Returns: { scores: { a: N, b: N, ... }, feedback: String }
  def evaluate(image_path:, canonical_data:)
    raise NotImplementedError
  end
end
```

### 8.2 Generator Adapters

Each generator gets its own adapter behind the common interface:

| Adapter | Status | Configuration Scope |
|---------|--------|-------------------|
| **ChatGPTAdapter** | IMPLEMENT (adapter) | Common interface + ChatGPT-specific parameters (model version, temperature if applicable) |
| **GeminiAdapter** | IMPLEMENT (adapter) | Common interface + Gemini-specific parameters; per-generator config ONLY where evidence justifies (e.g., hex color interpretation differences) |
| **Future adapters** | FUTURE | Same pattern — common interface, adapter-specific config only where evidence justifies |

### 8.3 Generator-Specific Configuration Rules

Generator-specific configuration is ALLOWED but RESTRICTED:

1. **Allowed**: Model version selection, temperature/settings tuning, API parameter mapping
2. **Allowed**: Per-generator hex color calibration (if future evidence shows persistent divergence)
3. **Not Allowed**: Different prompt structures per generator (must remain renderer-neutral)
4. **Not Allowed**: Different canonical data per generator (canonical data is universal)
5. **Not Allowed**: Different safeguard rules per generator (safeguards are renderer-neutral)

### 8.4 Dual-Generator Evaluation Protocol

Every complex asset generation MUST evaluate both ChatGPT and Gemini:

1. Generate with ChatGPT adapter → capture image + metadata
2. Generate with Gemini adapter → capture image + metadata
3. Run automated pre-filter on both outputs
4. Score both against A-N rubric (human-automated hybrid)
5. Compare cross-generator divergence → record as data, not failure
6. Store both results in Asset Registry

---

## 9. QA — AUTOMATED vs HUMAN BOUNDARIES

### 9.1 Automated Pre-Filter (Automated)

| Check | How to Automate | Status |
|-------|----------------|--------|
| **Background transparency** | Image metadata check (PNG alpha channel presence); pixel sampling for transparent regions | IMPLEMENT — automated |
| **Resolution compliance** | Image dimension check against Render Template requirements | IMPLEMENT — automated |
| **Feature completeness** | Object detection / feature recognition on generated image vs Visual Definition feature list | EXPERIMENTAL — requires ML model; start with manual checklist |
| **Proportion accuracy** | Bounding box analysis of generated image vs canonical dimensions | EXPERIMENTAL — requires pixel-to-meter calibration; start with manual comparison |
| **Color family validation** | Sample dominant colors from generated image vs hex color ranges (if configured) | IMPLEMENT — automated color sampling + range check |

### 9.2 Human QA Review (Human-Automated Hybrid)

| Check | Automated Component | Human Component | Status |
|-------|-------------------|-----------------|--------|
| **Visual fidelity** (A–N rubric scoring) | Pre-filter pass/fail; color sampling results | A-N rubric scoring against canonical data | IMPLEMENT — rubric engine + human scoring interface |
| **Canonical geometry compliance** | Automated pre-filter results | Human comparison of generated image vs Blueprint dimensions | IMPLEMENT — human review with automated reference data |
| **Recognition feature verification** | Feature detection (if ML model available) | Human verification of all recognition_features present | IMPLEMENT — human checklist + optional ML assistance |
| **Unwanted invented details** | None (requires semantic understanding) | Human identification of non-canonical elements | IMPLEMENT — human review with canonical data reference |
| **Silhouette strength** | None (requires aesthetic judgment) | Human assessment at thumbnail scale | IMPLEMENT — human review |
| **Mechanical plausibility** | None (requires domain expertise) | Human assessment against engineering principles | IMPLEMENT — human review |

### 9.3 QA Output Format

QA results stored in Asset Registry:

```json
{
  "asset_id": "rh400_regolith_harvester_rover",
  "qa_results": {
    "automated_prefilter": {
      "background_transparency": "pass",
      "resolution_compliance": "pass",
      "color_family_validation": "pass"
    },
    "human_scoring": {
      "rubric_scores": {
        "a_structural_geometry": 8,
        "b_vehicle_identity": 9,
        ...
      },
      "total_score": 62,
      "max_score": 70,
      "feedback": "All six recognition features present; minor color divergence on hazard yellow"
    },
    "cross_generator_comparison": {
      "chatgpt_score": 62,
      "gemini_score": 55,
      "gap_points": 7,
      "divergence_notes": "ChatGPT followed all hex ranges; Gemini partially followed hazard yellow range"
    },
    "qa_status": "approved",
    "reviewer": "human_reviewer_id",
    "reviewed_at": "2026-08-27T12:00:00Z"
  }
}
```

---

## 10. IMPLEMENTATION PHASES

### Phase 1: Foundation (Layers 0-3) — Core Pipeline

**Goal**: Enable deterministic prompt compilation from canonical data to FROZEN prompt.

| Component | Classification | Priority | Notes |
|-----------|---------------|----------|-------|
| Schema validation for all canonical data layers | EXISTING (specification) | HIGH | Validate against existing schemas; no code changes needed if schemas are correct |
| Profile Resolution Engine | IMPLEMENT | HIGH | Read Visual Profile markdown, extract locked attributes, resolve profile types, cross-validate Blueprint vs Visual Definition |
| Composition Refinery (base) | IMPLEMENT | HIGH | Takes composed attributes → structured output for PromptBuilder. Targeted refinements and safeguards as optional modules (disabled by default) |
| Prompt Compiler/Builder | IMPLEMENT | HIGH | Walks five-layer chain, validates, substitutes variables, produces FROZEN prompt with provenance header |

**Deliverable**: A service that takes canonical data inputs → produces a FROZEN prompt. No generation, no QA, no registry — just compilation.

### Phase 2: Generation + QA (Layers 4-5) — Complete Pipeline

**Goal**: Enable end-to-end asset generation with evaluation.

| Component | Classification | Priority | Notes |
|-----------|---------------|----------|-------|
| Generator Abstraction Interface | IMPLEMENT | HIGH | Common interface for all generators; ChatGPT and Gemini adapters |
| ChatGPTAdapter | IMPLEMENT | HIGH | Adapter for ChatGPT image generation |
| GeminiAdapter | IMPLEMENT | HIGH | Adapter for Gemini image generation; per-generator config only where evidence justifies |
| Automated Pre-Filter | IMPLEMENT | MEDIUM | Background transparency, resolution compliance, color family validation |
| A-N Rubric Engine | IMPLEMENT | MEDIUM | Human-automated hybrid scoring; rubric engine + human scoring interface |
| Cross-Generator Comparison | IMPLEMENT | MEDIUM | Automated comparison of ChatGPT vs Gemini scores and divergence notes |

**Deliverable**: End-to-end pipeline: canonical data → FROZEN prompt → generation (ChatGPT + Gemini) → QA evaluation.

### Phase 3: Registry + Render Families (Layers 6-7) — Asset Management

**Goal**: Enable asset tracking, version management, and render family support.

| Component | Classification | Priority | Notes |
|-----------|---------------|----------|-------|
| Asset Registry Storage | IMPLEMENT | MEDIUM | Persistent storage for canonical assets, render types, versions, QA status |
| Render Type Profile Configurations | FUTURE (optional) | LOW | Define render_type configs for each render type (catalog, engineering, exploded view, sprites, etc.) |
| Render Family Manager | FUTURE (optional) | LOW | Manages multiple render types per asset; depends on Phase 3 render_type configs being defined first |

**Deliverable**: Asset tracking and management infrastructure. Render families remain conceptual until render_type configs are defined.

### Phase 4: Game Integration (Layer 8) — Production Use

**Goal**: Integrate approved assets into the game pipeline.

| Component | Classification | Priority | Notes |
|-----------|---------------|----------|-------|
| Game Integration Layer | FUTURE (optional) | LOW | Depends on game engine decisions; not part of this implementation plan |

**Deliverable**: Production-ready asset integration. Out of scope for this implementation plan.

---

## 11. CLASSIFICATION SUMMARY

### Every Proposed Component — Classified

| Component | Classification | Phase | Notes |
|-----------|---------------|-------|-------|
| Canonical data schemas | EXISTING | — | No changes needed |
| Profile Resolution Engine | IMPLEMENT | Phase 1 | New service class |
| Composition Refinery (base) | IMPLEMENT | Phase 1 | New service class |
| Targeted Refinements (hex colors, geometric constraints) | EXPERIMENTAL (configurable) | Phase 1 | Optional modules, disabled by default |
| Safeguard Layer (camera precedence, autonomous protection, feature tier elevation) | EXPERIMENTAL (configurable) | Phase 1 | Optional modules, disabled by default |
| Prompt Compiler/Builder | IMPLEMENT | Phase 1 | New service class |
| Generator Abstraction Interface | IMPLEMENT | Phase 2 | Common interface |
| ChatGPTAdapter | IMPLEMENT | Phase 2 | Adapter behind common interface |
| GeminiAdapter | IMPLEMENT | Phase 2 | Adapter behind common interface; per-generator config only where evidence justifies |
| Automated Pre-Filter | IMPLEMENT | Phase 2 | New service class |
| A-N Rubric Engine | IMPLEMENT | Phase 2 | Human-automated hybrid scoring |
| Cross-Generator Comparison | IMPLEMENT | Phase 2 | Automated comparison tool |
| Asset Registry Storage | IMPLEMENT | Phase 3 | Persistent storage service |
| Render Type Profile Configurations | FUTURE (optional) | Phase 3 | Define configs before implementing manager |
| Render Family Manager | FUTURE (optional) | Phase 3 | Depends on render_type configs being defined first |
| Game Integration Layer | FUTURE (optional) | Phase 4 | Depends on game engine decisions |

---

## 12. CRITICAL DESIGN PRINCIPLES

### Data-Driven, Not RH-400-Specific

RH-400 and I-beam are **validation cases**, not templates. Every proposed component must be:

1. **Generic enough** to apply to any asset type (equipment, components, aerial vehicles, naval vessels, space craft)
2. **Configurable enough** to handle asset-specific requirements without hard-coding
3. **Testable enough** to validate on additional assets before generalizing

### Experimental Findings → Configuration, Not Architecture

All experimental findings (hex colors, safeguards, geometric constraints, prompt size limits) must be implemented as **configuration**, not hard-coded values. This allows:

- Per-asset configuration without code changes
- Opt-in testing without affecting other assets
- Easy rollback if an experimental finding doesn't generalize
- Clear distinction between validated architecture and experimental guidance

### Generator-Specific Behavior Isolated

Generator-specific behavior (ChatGPT structural processing vs Gemini associative processing) must be **isolated in the adapter layer**. It must never propagate into:

- Canonical data layers
- Prompt compilation
- Profile resolution
- Composition/refinement/safeguard layers

Per-generator configuration is allowed ONLY where future evidence justifies it.

### Reference Images Never Override Canonical Data

Reference images serve three roles (visual reference, QA comparison standard, composition/style reference) but must NEVER silently override canonical geometry. The Prompt Compiler reads canonical data only — reference images are never merged into prompt text.

---

*Implementation plan created: 2026-08-27*
*Based on six controlled experiments across two assets (I-beam Mk1, RH-400 Regolith Harvester Rover).*
*Planning only — no code, no file modifications, no new prompts.*
