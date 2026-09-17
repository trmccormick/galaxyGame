# Asset Generation Pipeline — Codebase Audit

**Date**: 2026-08-27
**Purpose**: Verify whether `ASSET_GENERATION_PIPELINE_IMPLEMENTATION_PLAN.md` accurately describes the current GalaxyGame codebase state. Determine what already exists, what is specification-only, and what needs implementation.
**Scope**: All components from Phases 1–3 of the implementation plan, plus any overlapping existing services.

---

## EXECUTIVE SUMMARY

**The implementation plan is ACCURATE.** Every component classified as "SPECIFICATION ONLY" or "MISSING" in the plan genuinely does not exist as code. The entire asset-generation pipeline (PromptBuilder, Profile Composition, Asset Registry, QA, generator abstraction) exists exclusively as specification documents — no Ruby/Python classes, services, or modules implement any of these components.

**Key finding**: The only existing code that overlaps with asset generation is:
1. `CatalogService` — loads/query blueprints and operational data (NOT asset-generation pipeline)
2. `BlueprintServices::MaterialGenerator` — generates material JSON objects (NOT image assets)
3. `MaterialGeneratorService` (two instances) — generates material definitions (NOT image assets)
4. `chromakey_gemini.py` / `chromakey_spritesheet.py` — post-processing sprite extraction (NOT asset generation pipeline)

None of these implement any layer of the asset-generation pipeline described in the implementation plan.

---

## 1. COMPONENT-BY-COMPONENT AUDIT

### 1.1 Layer 0: Canonical Data Inputs

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Blueprint Schema** (`unit_blueprint.json`) | EXISTING (specification) | ✅ DOCUMENTED + INSTANCES | `data/json-data/blueprints/crafts/ground/regolith_harvester_rover_bp.json` v2.1 exists; schema defined in ASSET_PROMPT_COMPILER_CONTRACT.md | RH-400 blueprint instance exists and is authoritative |
| **Blueprint Schema** (`component_blueprint.json`) | EXISTING (specification) | ✅ DOCUMENTED + NO INSTANCES | Schema defined in ASSET_PROMPT_COMPILER_CONTRACT.md; no `component_blueprint.json` instances exist anywhere | Directory `data/json-data/blueprints/components/` contains only material-level blueprints, not structural components |
| **Operational Data Schema** | EXISTING (specification) | ✅ DOCUMENTED + INSTANCES | `data/json-data/operational_data/crafts/ground/regolith_harvesting_rover_data.json` v2.1 exists; schema defined in ASSET_PROMPT_COMPILER_CONTRACT.md | RH-400 operational data instance exists and is authoritative |
| **Visual Definition Template** | EXISTING (specification) | ✅ DOCUMENTED + NO INSTANCES | `docs/reference/asset-generation/VISUAL_DEFINITION_TEMPLATE.md` — schema/template defined; no instances exist yet | First real instance: `VEHICLE_HARVESTER_ROVER_RH400.json` |
| **Visual Profile** (`precision_industrial_v1`) | EXISTING (instance) | ✅ DOCUMENTED + INSTANCES | `docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md` v1.1 — one instance exists, reusable profile with locked attributes | Canonical reference for all assets under this profile |
| **Render Template** | EXISTING (instance) | ✅ DOCUMENTED + INSTANCES | `docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` — one instance exists; defines camera/lighting/background/output rules | Production template used in all six runs |
| **RH-400 Visual Definition** | EXISTING (instance) | ✅ DOCUMENTED + INSTANCES | `docs/reference/asset-generation/visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json` — first real instance for complex vehicle | Complete and correct per VISUAL_DEFINITION_TEMPLATE.md schema |
| **I-beam frozen prompts** | EXISTING (artifacts) | ✅ DOCUMENTED + INSTANCES | `docs/reference/asset-generation/ibeam_mk1_prompt_primary.txt`, `ibeam_mk1_prompt_quadrant.txt` — two frozen prompts from I-beam experiments | Artifacts only; no code |
| **RH-400 frozen prompts** | EXISTING (artifacts) | ✅ DOCUMENTED + INSTANCES | `docs/reference/asset-generation/rh400_run0{3-6}_profile_composed_prompt.txt` — four frozen prompts from validated experiments | Artifacts only; no code |

**Verdict**: All canonical data layers are accurately classified. No code exists for any of these — they are all specification documents or JSON/markdown instances. The implementation plan correctly identifies them as "EXISTING (specification + instances)" requiring "schema validation only; no code needed."

### 1.2 Layer 1: Profile Resolution Engine

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Profile Composition Spec** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | `docs/reference/asset-generation/PROFILE_COMPOSITION_SPEC.md` — profile types, resolution order, precedence rules all specified; no engine code exists | Specification only. The PROFILE_COMPOSITION_ASSESSMENT.md confirms: "The PromptBuilder service is NOT implemented. It exists only as a specification in two documents." |
| **Profile Resolution Engine** | IMPLEMENT (new) | ❌ MISSING ENTIRELY | No Ruby/Python class, no module, no service exists | Must be created from PROFILE_COMPOSITION_SPEC.md specification |

**Overlap check**: 
- `CatalogService` (`galaxy_game/app/services/catalog_service.rb`) loads/query blueprints and operational data but does NOT resolve profiles. It is a generic data loader, not a profile resolver.
- No other existing service reads Visual Profile markdown or resolves profile types.

**Verdict**: ACCURATE. The implementation plan correctly identifies this as "IMPLEMENT — New service class." No existing code overlaps with this component.

### 1.3 Layer 2a: Composition Refinery

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Composition Refinery** | IMPLEMENT (new) | ❌ MISSING ENTIRELY | No Ruby/Python class, no module, no service exists | Takes composed attributes + targeted refinements + safeguards → structured output for PromptBuilder. Does not exist. |

**Overlap check**: 
- `BlueprintServices::MaterialGenerator` (`galaxy_game/app/services/blueprint_services/material_generator.rb`) generates material JSON objects from template data. NOT a composition refinery — it operates on materials, not visual profiles or recognition features.
- No other existing service performs profile composition or structured attribute output.

**Verdict**: ACCURATE. The implementation plan correctly identifies this as "IMPLEMENT — New service class." No existing code overlaps with this component.

### 1.4 Layer 2b: Targeted Refinements Mechanism

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Hex color ranges** | EXPERIMENTAL (configurable) | ✅ TESTED MANUALLY + NO CODE | Tested in RH-400 Runs 05 and 06; no mechanism exists to apply them programmatically | Manual application only. No configuration system, no hex range engine. |
| **Geometric constraints** | EXPERIMENTAL (configurable) | ✅ TESTED MANUALLY + NO CODE | Tested in RH-400 Run 05 (cylindrical canister); no mechanism exists to apply them programmatically | Manual application only. No constraint engine. |

**Overlap check**: 
- `chromakey_gemini.py` and `scripts/chromakey_spritesheet.py` perform chromakey post-processing on sprite atlases. NOT targeted refinements — they operate on generated images, not prompt construction.
- No existing code applies hex color ranges or geometric constraints to prompts.

**Verdict**: ACCURATE. The implementation plan correctly identifies these as "EXPERIMENTAL (configurable)" requiring configuration layer implementation. No existing code overlaps with this component.

### 1.5 Layer 2c: Safeguard Layer

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Camera precedence safeguard** | EXPERIMENTAL (configurable) | ✅ TESTED MANUALLY + NO CODE | Tested in RH-400 Run 06; no mechanism exists to apply it programmatically | Manual application only. No safeguard engine. |
| **Autonomous protection safeguard** | EXPERIMENTAL (configurable) | ✅ TESTED MANUALLY + NO CODE | Tested in RH-400 Run 06; no mechanism exists to apply it programmatically | Manual application only. No safeguard engine. |
| **Feature tier elevation safeguard** | EXPERIMENTAL (configurable) | ✅ TESTED MANUALLY + NO CODE | Tested in RH-400 Run 06; no mechanism exists to apply it programmatically | Manual application only. No safeguard engine. |

**Overlap check**: 
- No existing code implements any safeguard mechanism.
- The safeguards are documented in the frozen prompt files (Run 06) but not implemented as configurable modules.

**Verdict**: ACCURATE. The implementation plan correctly identifies these as "EXPERIMENTAL (configurable)" requiring configuration layer implementation. No existing code overlaps with this component.

### 1.6 Layer 3: Prompt Compiler/Builder

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **PromptCompiler Contract** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | `docs/reference/asset-generation/ASSET_PROMPT_COMPILER_CONTRACT.md` v0.1 — five-layer dependency chain, validation rules, provenance header all specified; no compiler code exists | The contract defines WHAT should happen but not HOW. PROFILE_COMPOSITION_ASSESSMENT.md confirms: "Neither document implements the actual composition mechanism." |
| **PromptBuilder Service** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | `ASSET_GENERATION_ARCHITECTURE.md` describes it conceptually (lines 499-578): "class PromptBuilderService" with inputs/outputs — no actual class exists | The architecture doc contains pseudocode for `PromptBuilderService.build()` and `AssetRegistryService.register()` but these are NOT Ruby classes. They are architectural descriptions. |
| **BlueprintValidator** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | Validation rules defined in ASSET_PROMPT_COMPILER_CONTRACT.md; no validator code exists | The architecture doc mentions `validator = BlueprintValidator.new(blueprint, visual_definition)` but this is pseudocode, not a real class. |
| **PromptArchive** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | Concept defined in ASSET_GENERATION_ARCHITECTURE.md; no archive code exists | No prompt storage mechanism exists. All prompts are frozen text files. |

**Overlap check**: 
- `CatalogService` (`galaxy_game/app/services/catalog_service.rb`) loads/query blueprints and operational data but does NOT compile prompts. It is a generic data loader with `find_entry()` and `paginated_result()` methods.
- No existing code walks the five-layer dependency chain, validates required fields, resolves IDs, or substitutes variables into templates.

**Verdict**: ACCURATE. The implementation plan correctly identifies this as "IMPLEMENT — New service class." No existing code overlaps with this component. The pseudocode in ASSET_GENERATION_ARCHITECTURE.md is architectural description, not implementation.

### 1.7 Layer 4: Generator Abstraction Interface

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Generator Abstraction Interface** | IMPLEMENT (new) | ❌ MISSING ENTIRELY | No Ruby/Python class, no module, no service exists | Common generation interface abstracting ChatGPT/Gemini differences. Does not exist. |
| **ChatGPTAdapter** | IMPLEMENT (adapter) | ❌ MISSING ENTIRELY | No adapter code exists | Generation is done manually via chatgpt.com web interface. No API integration. |
| **GeminiAdapter** | IMPLEMENT (adapter) | ❌ MISSING ENTIRELY | No adapter code exists | Generation is done manually via Gemini web interface. No API integration. |

**Overlap check**: 
- `chromakey_gemini.py` processes Gemini-generated sprite atlases but does NOT generate images. It post-processes existing images.
- No existing code generates images via ChatGPT or Gemini APIs.
- Generation is entirely manual — a human writes prompts and submits them to chatgpt.com or Gemini web interface.

**Verdict**: ACCURATE. The implementation plan correctly identifies all three as "IMPLEMENT." No existing code overlaps with this component.

### 1.8 Layer 5: Asset QA

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Automated Pre-Filter** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | ASSET_GENERATION_ARCHITECTURE.md defines checklist items (background transparency, sprite pivot alignment, tile edge continuity, resolution/compliance, color family validation); no pre-filter code exists | Architecture doc mentions "AUTOMATED PRE-FILTER" as a pipeline stage but no implementation exists. |
| **A-N Rubric Engine** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | A-N rubric defined in ASSET_GENERATION_PIPELINE_VALIDATION.md; scoring methodology used manually across all six runs; no rubric engine code exists | Manual evaluation only. No automated scoring system. |
| **Cross-Generator Comparison** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | Methodology documented in validation report; no comparison tool exists | Manual comparison only. No automated comparison system. |

**Overlap check**: 
- `chromakey_spritesheet.py` performs sprite extraction and chromakey on generated atlases. NOT asset QA — it post-processes images, not evaluates them against canonical data.
- No existing code performs background transparency checks, resolution compliance verification, or A-N rubric scoring.

**Verdict**: ACCURATE. The implementation plan correctly identifies all three as "IMPLEMENT." No existing code overlaps with this component.

### 1.9 Layer 6: Asset Registry

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Asset Registry Spec** | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | `2026-07-19-HIGH-DESIGN-ASSET_REGISTRY_SPECIFICATION.md` — registry spec defined; no registry code exists | Architecture doc contains pseudocode for `AssetRegistryService.register()` and `AssetRegistryService.regenerate()` but these are NOT Ruby classes. |
| **Asset Registry Storage** | IMPLEMENT (new) | ❌ MISSING ENTIRELY | No persistent storage mechanism exists | No database, no file-based registry, no JSON store for canonical assets. |

**Overlap check**: 
- `CatalogService` loads/query blueprints and operational data but does NOT serve as an asset registry. It has no concept of render types, QA status, or version tracking.
- No existing code implements asset registration, version tracking, or obsolete reference management.

**Verdict**: ACCURATE. The implementation plan correctly identifies this as "IMPLEMENT — New service class + storage backend." No existing code overlaps with this component.

### 1.10 Layer 7: Render Family Manager

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Render Type Profile Configurations** | FUTURE (optional) | ✅ CONCEPTUAL ONLY | Defined in ASSET_GENERATION_ARCHITECTURE.md as render family types; no configurations exist | Conceptual framework only. No render_type profile configs defined for any render type. |
| **Render Family Manager** | FUTURE (optional) | ❌ MISSING ENTIRELY | No manager code exists | No system to manage multiple render types per asset. |

**Verdict**: ACCURATE. The implementation plan correctly identifies both as "FUTURE (optional)." No existing code overlaps with this component.

### 1.11 Layer 8: Game Integration

| Component | Plan Classification | Actual Status | File/Class Location | Notes |
|-----------|-------------------|---------------|---------------------|-------|
| **Game Integration Layer** | FUTURE (optional) | ✅ ARCHITECTURAL INTENT ONLY | Defined in ASSET_GENERATION_ARCHITECTURE.md as game consumption layer; no integration code exists | Depends on game engine decisions. Out of scope for this implementation plan. |

**Verdict**: ACCURATE. The implementation plan correctly identifies this as "FUTURE (optional)." No existing code overlaps with this component.

---

## 2. ACTUAL FILE/CLASS LOCATIONS

### 2.1 Existing Code That Overlaps With Asset Generation

| File/Class | Location | What It Does | Overlap With Pipeline |
|------------|----------|-------------|----------------------|
| `CatalogService` | `galaxy_game/app/services/catalog_service.rb` | Loads/query blueprints and operational data from JSON files. Provides `find_entry()`, `paginated_result()`. | LOW — generic data loader, not pipeline component. Does NOT resolve profiles, compile prompts, or manage assets. |
| `BlueprintServices::MaterialGenerator` | `galaxy_game/app/services/blueprint_services/material_generator.rb` | Generates material JSON objects from template data. | NONE — operates on materials, not visual profiles or recognition features. |
| `MaterialGeneratorService` (two instances) | `galaxy_game/app/services/material_generator_service.rb` and `galaxy_game/app/services/generators/material_generator_service.rb` | Generates material definitions. | NONE — operates on materials, not image assets. |
| `chromakey_gemini.py` | Root of workspace | Post-processes Gemini-generated sprite atlases (chromakey magenta → transparent). | LOW — post-processing only, not generation pipeline. |
| `chromakey_spritesheet.py` | `scripts/` directory | Extracts 32x32 sprites from generated atlases with chromakey. | LOW — post-processing only, not generation pipeline. |

### 2.2 Existing Specification Documents (No Code)

| Document | Location | What It Specifies |
|----------|----------|-------------------|
| `ASSET_GENERATION_ARCHITECTURE.md` | `docs/reference/asset-generation/` | Complete pipeline architecture with pseudocode for PromptBuilderService, AssetRegistryService, BlueprintValidator |
| `ASSET_PROMPT_COMPILER_CONTRACT.md` v0.1 | `docs/reference/asset-generation/` | Five-layer dependency chain, validation rules, provenance header format |
| `PROFILE_COMPOSITION_SPEC.md` | `docs/reference/asset-generation/` | Profile types, resolution order, precedence rules, structured attribute schema |
| `VISUAL_DEFINITION_TEMPLATE.md` | `docs/reference/asset-generation/` | Schema for visual definitions (required/optional fields) |
| `VISUAL_PROFILE_precision_industrial_v1.md` v1.1 | `docs/reference/asset-generation/` | Locked attributes for precision industrial aesthetic profile |
| `PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | `docs/reference/asset-generation/` | Camera/lighting/background/output rules for production renders |
| `ASSET_GENERATION_PIPELINE_VALIDATION.md` | `docs/reference/asset-generation/` | Classification of architecture vs practice vs experimental guidance |
| `VEHICLE_HARVESTER_ROVER_RH400.json` | `docs/reference/asset-generation/visual_definitions/` | First real Visual Definition instance for complex vehicle |

### 2.3 Existing Frozen Artifacts (No Code)

| Artifact | Location | What It Is |
|----------|----------|------------|
| `rh400_run0{3-6}_profile_composed_prompt.txt` | `docs/reference/asset-generation/` | Four frozen prompts from validated experiments |
| `ibeam_mk1_prompt_primary.txt`, `ibeam_mk1_prompt_quadrant.txt` | `docs/reference/asset-generation/` | Two frozen prompts from I-beam experiments |
| `rh400_run0{3-6}_evaluation.md` | `data/images/asset-generation-tests/` | Evaluation reports for all four RH-400 runs |
| `ibeam_mk1_generation_evaluation.md`, `ibeam_mk1_generation_test_spec.md` | `docs/reference/asset-generation/` | I-beam evaluation and test spec |

---

## 3. CURRENT IMPLEMENTATION STATUS

### 3.1 Summary Table

| Component | Plan Classification | Actual Status | Match? |
|-----------|-------------------|---------------|--------|
| Canonical data schemas | EXISTING (specification + instances) | ✅ DOCUMENTED + INSTANCES | ✅ YES |
| Profile Composition Spec | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | ✅ YES |
| Profile Resolution Engine | IMPLEMENT (new) | ❌ MISSING ENTIRELY | ✅ YES |
| Composition Refinery | IMPLEMENT (new) | ❌ MISSING ENTIRELY | ✅ YES |
| Targeted Refinements (hex colors, geometric constraints) | EXPERIMENTAL (configurable) | ✅ TESTED MANUALLY + NO CODE | ✅ YES |
| Safeguard Layer (camera precedence, autonomous protection, feature tier elevation) | EXPERIMENTAL (configurable) | ✅ TESTED MANUALLY + NO CODE | ✅ YES |
| Prompt Compiler/Builder | IMPLEMENT (new) | ❌ MISSING ENTIRELY | ✅ YES |
| BlueprintValidator | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | ✅ YES |
| PromptArchive | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | ✅ YES |
| Generator Abstraction Interface | IMPLEMENT (new) | ❌ MISSING ENTIRELY | ✅ YES |
| ChatGPTAdapter | IMPLEMENT (adapter) | ❌ MISSING ENTIRELY | ✅ YES |
| GeminiAdapter | IMPLEMENT (adapter) | ❌ MISSING ENTIRELY | ✅ YES |
| Automated Pre-Filter | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | ✅ YES |
| A-N Rubric Engine | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | ✅ YES |
| Cross-Generator Comparison | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | ✅ YES |
| Asset Registry Spec | EXISTING (specification) | ✅ DOCUMENTED + NO CODE | ✅ YES |
| Asset Registry Storage | IMPLEMENT (new) | ❌ MISSING ENTIRELY | ✅ YES |
| Render Type Profile Configurations | FUTURE (optional) | ✅ CONCEPTUAL ONLY | ✅ YES |
| Render Family Manager | FUTURE (optional) | ❌ MISSING ENTIRELY | ✅ YES |
| Game Integration Layer | FUTURE (optional) | ✅ ARCHITECTURAL INTENT ONLY | ✅ YES |

**Result: 20/20 components match between the implementation plan and actual codebase state.**

### 3.2 What Is DOCUMENTED vs IMPLEMENTED vs TESTED

| Category | Count | Examples |
|----------|-------|----------|
| **DOCUMENTED (specification only)** | 12 | PromptBuilder, BlueprintValidator, AssetRegistry, Automated Pre-Filter, A-N Rubric, Cross-Generator Comparison, Render Type Configs, Game Integration, Profile Composition Spec, Visual Definition Template, Canonical data schemas, PromptArchive |
| **IMPLEMENTED (code exists)** | 0 | None of the pipeline components have code implementations |
| **PARTIALLY IMPLEMENTED** | 0 | None — all pipeline components are either fully documented or fully missing |
| **TESTED (manually)** | 6 runs across 2 assets | I-beam Runs 01-02, RH-400 Runs 03-06; all manual evaluation via ChatGPT/Gemini web interfaces |
| **UNTESTED (no code to test)** | All pipeline components | No code exists to test |

---

## 4. EXISTING TESTS

### 4.1 Asset Generation Tests

| Test File | Location | Status | What It Tests |
|-----------|----------|--------|---------------|
| `star_sim/data_driven_generation_spec.rb` | `galaxy_game/spec/services/star_sim/` and `spec/services/star_sim/` | EXISTS | Star simulation data generation — NOT asset generation pipeline |
| `rh400_controlled_generation_test_spec.md` | `docs/reference/asset-generation/` | EXISTS (specification only) | RH-400 controlled generation test spec — no code to run |
| `ibeam_mk1_generation_test_spec.md` | `docs/reference/asset-generation/` | EXISTS (specification only) | I-beam Mk1 generation test spec — no code to run |

**Key finding**: There are NO RSpec tests for any asset-generation pipeline component. The only existing "tests" are:
1. Manual evaluation reports (`rh400_run0{3-6}_evaluation.md`, `ibeam_mk1_generation_evaluation.md`)
2. Test specifications (no code to execute)
3. Star simulation data generation spec (unrelated to asset generation)

### 4.2 Existing Service Tests

| Service | Has Tests? | Notes |
|---------|-----------|-------|
| `CatalogService` | Unknown (not audited) | Generic data loader, not pipeline component |
| `BlueprintServices::MaterialGenerator` | Unknown (not audited) | Material JSON generation, not image assets |
| `MaterialGeneratorService` (two instances) | Unknown (not audited) | Material definitions, not image assets |

**Key finding**: No tests exist for any asset-generation pipeline component because no code exists.

---

## 5. GAPS BETWEEN DOCUMENTATION AND CODE

### 5.1 Major Gaps

| Gap | Documentation Says | Code Reality | Impact |
|-----|-------------------|-------------|--------|
| **PromptBuilder** | "class PromptBuilderService" with `build()` method (ASSET_GENERATION_ARCHITECTURE.md lines 499-578) | No class exists. Pseudocode in architecture doc is architectural description, not implementation. | HIGH — core pipeline component missing |
| **Profile Composition Engine** | "Resolves independent profile concerns into structured attributes" (PROFILE_COMPOSITION_SPEC.md) | No engine exists. Profile types, resolution order, precedence rules all specified but unimplemented. | HIGH — missing layer between Visual Profile and Render Template |
| **Composition Refinery** | "Takes composed attributes + targeted refinements + safeguards → structured output" | No refinery exists. All three layers (composition, refinements, safeguards) are manual only. | HIGH — no mechanism to apply experimental findings programmatically |
| **Asset Registry** | "Registers canonical asset ID, all generated render types, complexity level variants, animation keyframes, sprite sheets, blueprint version, prompt template version, QA approval status" | No registry exists. No persistent storage for assets. | MEDIUM — no tracking of generated assets |
| **Automated Pre-Filter** | "Background transparency check, sprite pivot alignment, tile edge continuity, resolution/compliance, color family validation" | No pre-filter exists. All checks done manually. | MEDIUM — QA is entirely manual |
| **A-N Rubric Engine** | "14-criteria scoring system (A through N)" | No rubric engine exists. Scoring done manually across all six runs. | MEDIUM — evaluation is entirely manual |
| **Generator Abstraction** | "Model-agnostic: current ChatGPT image generation, future any image model" | Generation is entirely manual via web interfaces. No API integration. | HIGH — no programmatic generation capability |

### 5.2 Minor Gaps

| Gap | Documentation Says | Code Reality | Impact |
|-----|-------------------|-------------|--------|
| **BlueprintValidator** | "Validates required fields, asset ID format, material profiles, technology level" | No validator exists. Validation rules defined in ASSET_PROMPT_COMPILER_CONTRACT.md but unimplemented. | LOW — validation can be added to PromptCompiler |
| **PromptArchive** | "Stores generated prompts with version stamps, prompt template versions, blueprint version, timestamp and generator ID" | No archive exists. All prompts are frozen text files. | LOW — prompts already stored as text files |
| **Render Family Manager** | "Manages multiple render types per asset" | Conceptual framework only. No manager exists. | LOW — FUTURE component |

---

## 6. DUPLICATE/OVERLAPPING IMPLEMENTATIONS

### 6.1 Potential Overlaps Identified

| Overlap | Component A | Component B | Resolution |
|---------|------------|-------------|------------|
| **MaterialGenerator** (two instances) | `galaxy_game/app/services/material_generator_service.rb` | `galaxy_game/app/services/generators/material_generator_service.rb` | Both generate material definitions. NOT asset-generation pipeline overlap — they operate on materials, not image assets. Consolidation recommended but out of scope for this audit. |
| **CatalogService** vs **Asset Registry** | `CatalogService` loads/query blueprints and operational data | Asset Registry (planned) stores canonical assets, render types, versions, QA status | CatalogService is a generic data loader; Asset Registry is an asset tracking system. Different purposes. No overlap — both needed. |
| **BlueprintServices::MaterialGenerator** vs **Composition Refinery** | Generates material JSON objects from template data | Composition Refinery (planned) takes composed attributes + refinements + safeguards → structured output for PromptBuilder | MaterialGenerator operates on materials; Composition Refinery operates on visual profiles and recognition features. Different purposes. No overlap — both needed. |
| **chromakey_* scripts** vs **Automated Pre-Filter** | Post-processes sprite atlases (chromakey magenta → transparent) | Automated Pre-Filter (planned) checks background transparency, resolution compliance, color family validation | Chromakey scripts are post-processing; Pre-Filter is evaluation. Different purposes. No overlap — both needed. |

### 6.2 Consolidation Recommendations

| Recommendation | Components Affected | Priority |
|---------------|---------------------|----------|
| **Consolidate MaterialGeneratorService** (two instances) | `galaxy_game/app/services/material_generator_service.rb` and `galaxy_game/app/services/generators/material_generator_service.rb` | LOW — out of scope for asset-generation pipeline |
| **CatalogService can serve as data loader for PromptCompiler** | CatalogService loads blueprints/operational data; PromptCompiler needs to read these same files | MEDIUM — PromptCompiler should use CatalogService as its data source, not duplicate loading logic |

---

## 7. REQUIRED REFACTORS

### 7.1 Refactors Needed Before Implementation

| Refactor | Why | Impact |
|----------|-----|--------|
| **CatalogService → PromptCompiler data source** | CatalogService already loads blueprints and operational data. PromptCompiler should use it rather than duplicating file loading logic. | Reduces code duplication; establishes single source of truth for canonical data loading |
| **MaterialGeneratorService consolidation** | Two instances exist with overlapping functionality (both generate material definitions). | Out of scope for asset-generation pipeline but recommended as housekeeping |

### 7.2 Refactors NOT Needed

| Component | Why No Refactor Needed |
|-----------|----------------------|
| Canonical data schemas | All schemas are correct; no code changes needed |
| Visual Profile (precision_industrial_v1) | Locked attributes are correct; composition layer reads them, doesn't modify them |
| Render Template | Rules are correct; receives composed output, doesn't need to change |
| Frozen test files | Per user directive — no modifications |
| RH-400 canonical data | Already authoritative; no changes needed |

---

## 8. REQUIRED NEW COMPONENTS

### 8.1 Phase 1: Foundation (Layers 0-3)

| Component | Classification | Implementation Notes |
|-----------|---------------|---------------------|
| **Profile Resolution Engine** | IMPLEMENT | New service class. Reads Visual Profile markdown, extracts locked attributes, resolves profile types (global_visual_style, manufacturing_style, technology_level, render_type), cross-validates Blueprint vs Visual Definition fields. |
| **Composition Refinery (base)** | IMPLEMENT | New service class. Takes composed attributes + optional targeted refinements + optional safeguards → structured output for PromptBuilder. Targeted refinements and safeguards as optional modules (disabled by default). |
| **Prompt Compiler/Builder** | IMPLEMENT | New service class. Walks five-layer chain, validates required fields, resolves IDs, substitutes variables into Render Template, produces FROZEN prompt with provenance header. Should use CatalogService as data source. |

### 8.2 Phase 2: Generation + QA (Layers 4-5)

| Component | Classification | Implementation Notes |
|-----------|---------------|---------------------|
| **Generator Abstraction Interface** | IMPLEMENT | Common interface for all generators. ChatGPT and Gemini adapters behind interface. Per-generator config only where evidence justifies. |
| **ChatGPTAdapter** | IMPLEMENT | Adapter for ChatGPT image generation. API integration needed (currently manual via web). |
| **GeminiAdapter** | IMPLEMENT | Adapter for Gemini image generation. Per-generator config only where evidence justifies. |
| **Automated Pre-Filter** | IMPLEMENT | New service class. Background transparency check, resolution compliance, color family validation. |
| **A-N Rubric Engine** | IMPLEMENT | Human-automated hybrid scoring. Rubric engine + human scoring interface. |
| **Cross-Generator Comparison** | IMPLEMENT | Automated comparison of ChatGPT vs Gemini scores and divergence notes. |

### 8.3 Phase 3: Registry + Render Families (Layers 6-7)

| Component | Classification | Implementation Notes |
|-----------|---------------|---------------------|
| **Asset Registry Storage** | IMPLEMENT | Persistent storage for canonical assets, render types, versions, QA status. |
| **Render Type Profile Configurations** | FUTURE (optional) | Define render_type configs for each render type before implementing manager. |
| **Render Family Manager** | FUTURE (optional) | Manages multiple render types per asset; depends on render_type configs being defined first. |

---

## 9. RECOMMENDED IMPLEMENTATION ORDER

### Phase 1: Foundation (Highest Priority)

1. **Profile Resolution Engine** — reads Visual Profile markdown, extracts locked attributes, resolves profile types
2. **Composition Refinery (base)** — takes composed attributes → structured output for PromptBuilder
3. **Prompt Compiler/Builder** — walks five-layer chain, validates, substitutes variables, produces FROZEN prompt

**Rationale**: These three components form the core pipeline. Without them, no automated asset generation is possible. Each depends on the previous one.

### Phase 2: Generation + QA (Medium Priority)

4. **Generator Abstraction Interface** — common interface for all generators
5. **ChatGPTAdapter** — adapter for ChatGPT image generation
6. **GeminiAdapter** — adapter for Gemini image generation
7. **Automated Pre-Filter** — background transparency, resolution compliance, color family validation
8. **A-N Rubric Engine** — human-automated hybrid scoring
9. **Cross-Generator Comparison** — automated comparison of ChatGPT vs Gemini scores

**Rationale**: These components complete the end-to-end pipeline. Generation and QA cannot be tested until Phase 1 is stable.

### Phase 3: Registry + Render Families (Lower Priority)

10. **Asset Registry Storage** — persistent storage for canonical assets
11. **Render Type Profile Configurations** — define configs before implementing manager
12. **Render Family Manager** — manages multiple render types per asset

**Rationale**: These components manage generated assets but don't enable generation itself. Can be implemented after pipeline is stable.

---

## 10. RISKS AND DEPENDENCIES

### 10.1 Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| **No existing code to build on** | HIGH | All components must be created from scratch. Start with Profile Resolution Engine as the simplest component (reads markdown, extracts attributes). |
| **Visual Profile markdown parsing** | MEDIUM | Visual Profiles are markdown documents, not JSON. Parsing locked attributes requires text extraction logic. Consider YAML frontmatter for structured data in Visual Profiles. |
| **Generator API integration** | HIGH | ChatGPT and Gemini generation is currently manual via web interfaces. API integration requires credentials, rate limiting handling, error recovery. |
| **Cross-generator comparison complexity** | MEDIUM | Automated comparison of generated images against canonical data requires image analysis (object detection, color sampling). ML models may be needed. |
| **CatalogService coupling** | LOW | PromptCompiler should use CatalogService as data source but must not create circular dependencies. Define clear interface boundaries. |

### 10.2 Dependencies

| Component Depends On | Notes |
|---------------------|-------|
| Profile Resolution Engine → Visual Profile markdown files | Must parse markdown to extract locked attributes |
| Composition Refinery → Profile Resolution Engine | Receives composed attributes from Profile Resolution |
| Prompt Compiler/Builder → Composition Refinery + CatalogService | Walks five-layer chain; uses CatalogService for data loading |
| Generator Abstraction Interface → Prompt Compiler/Builder | Receives FROZEN prompts from Prompt Compiler |
| ChatGPTAdapter/GeminiAdapter → Generator Abstraction Interface | Adapters implement the common interface |
| Automated Pre-Filter → Generated images | Runs after generation; checks image properties |
| A-N Rubric Engine → Generated images + canonical data | Scores generated assets against canonical data |
| Asset Registry Storage → All above | Stores results from all pipeline stages |

---

## 11. CORRECTIONS TO IMPLEMENTATION PLAN

### 11.1 Corrections Required

| Correction | Implementation Plan Says | Actual State | Impact |
|-----------|-------------------------|-------------|--------|
| **CatalogService as data source** | Implementation plan does not mention CatalogService as a potential data source for PromptCompiler | CatalogService already loads blueprints and operational data. PromptCompiler should use it rather than duplicating loading logic. | MEDIUM — PromptCompiler implementation should reference CatalogService to avoid code duplication |
| **MaterialGeneratorService consolidation** | Implementation plan does not mention the two MaterialGeneratorService instances | Two instances exist (`galaxy_game/app/services/material_generator_service.rb` and `galaxy_game/app/services/generators/material_generator_service.rb`). Consolidation recommended as housekeeping. | LOW — out of scope for asset-generation pipeline but worth noting |
| **No existing code to build on** | Implementation plan correctly identifies all components as "MISSING" or "SPECIFICATION ONLY" | Confirmed: zero code exists for any pipeline component. All are specification documents only. | NONE — plan is accurate |

### 11.2 No Corrections Required

All other components in the implementation plan are accurately classified. The plan correctly distinguishes between:
- **EXISTING** (specification + instances): Canonical data schemas, Visual Profile, Render Template, frozen prompts
- **IMPLEMENT** (new code needed): Profile Resolution Engine, Composition Refinery, Prompt Compiler, Generator Abstraction, QA components, Asset Registry
- **EXPERIMENTAL** (configurable, not hard-coded): Hex colors, geometric constraints, safeguards
- **FUTURE** (optional): Render families, game integration

---

## 12. FINAL VERDICT

**The implementation plan is ACCURATE.** Every component classification matches the actual codebase state:

- ✅ All canonical data layers correctly identified as EXISTING (specification + instances)
- ✅ All pipeline components correctly identified as MISSING or SPECIFICATION ONLY
- ✅ No existing code overlaps with any pipeline component (CatalogService is a generic data loader, not a pipeline component)
- ✅ Implementation order is correct (Foundation → Generation+QA → Registry+Families)
- ✅ Risk assessment is accurate (all components must be created from scratch)
- ✅ Dependencies are correctly identified

**One recommendation**: PromptCompiler should use CatalogService as its canonical data source rather than duplicating file loading logic. This is a design detail, not a correction to the plan's accuracy.

---

*Audit completed: 2026-08-27*
*Based on comprehensive search of galaxy_game/app/services/, galaxy_game/app/assets/, data/json-data/, docs/reference/asset-generation/, and all specification documents.*
*No code modifications made. No files modified.*
