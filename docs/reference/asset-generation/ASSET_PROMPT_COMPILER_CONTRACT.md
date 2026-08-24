# Asset Prompt Compiler Contract

**Status**: Draft v0.1
**Priority**: MEDIUM
**Type**: Architecture Specification
**Created**: 2026-08-23
**Last Updated**: 2026-08-24
**Owner**: Asset Pipeline Design

---

## Context

This contract defines the **Asset Prompt Compiler** — a deterministic pipeline component that walks a fixed dependency chain of canonical files (Blueprint → Operational Data → Visual Definition → Visual Profile → Production Asset Render Template), validates required fields, resolves ID references, and produces a structured image-generation prompt with a provenance header.

### Key Fact: No `component_blueprint.json` Instances Exist Yet

An audit of the codebase confirms that **no `component_blueprint.json` instance files exist anywhere in the repository**. The directory `data/json-data/blueprints/components/` contains only material-level blueprints (e.g., `polymer_matrix_bp.json`, `carbon_nanotubes_bp.json`) under subdirectories like `materials/` and `electronics/`. Structural components — including the I-beam Mk1–Mk4 production assets that already exist on disk at `data/images/catalog/components/structural/3d_printed_ibeam_mk{1-4}.png` — have no corresponding blueprint instance.

**This contract establishes the pattern for the first `component_blueprint.json` instance.** The I-beam Mk1 is used as the concrete worked example throughout the Required Fields and Dependency Resolution sections because it has real, approved production assets on disk but no blueprint yet.

### Related Architecture Docs (authoritative sources)

| Doc | Location | Role in This Contract |
|---|---|---|
| `VISUAL_DEFINITION_TEMPLATE.md` | `docs/reference/asset-generation/VISUAL_DEFINITION_TEMPLATE.md` | Defines required/optional fields for the Visual Definition layer |
| `ASSET_GENERATION_ARCHITECTURE.md` | `docs/reference/asset-generation/ASSET_GENERATION_ARCHITECTURE.md` | Defines the broader pipeline; this contract is a component of it |
| `PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | `docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | Defines the render template into which compiled data is substituted |
| `VISUAL_PROFILE_precision_industrial_v1.md` | `docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md` | Example Visual Profile; defines locked attributes inherited by all assets under this profile |
| `DECISIONS.md` | `docs/new_agent/rules/DECISIONS.md` | Locked architectural decisions (not restated here) |
| `GUARDRAILS.md` | Consolidated at `agent-tasks/rules/GUARDRAILS.md` | Operational guardrails (not restated here) |

> **One-owning-doc rule**: This contract does not duplicate content from the docs above. It references them by name and path. If any referenced doc cannot be located, this is a stop condition — do not proceed to implementation without confirming the schemas match reality.

---

## The Dependency Chain

Every asset compiled by this system follows a **fixed five-layer dependency chain**:

```
Layer 1: Blueprint (unit_blueprint.json or component_blueprint.json)
    ↓ resolves visual_profile ID
Layer 2: Visual Profile (e.g., precision_industrial_v1)
    ↓ provides locked style attributes
Layer 3: Visual Definition (visual_definition JSON)
    ↓ provides appearance spec + recognition_features
Layer 4: Operational Data (operational_data JSON)
    ↓ provides functional role / runtime behavior
Layer 5: Production Asset Render Template (PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md)
    ↓ receives substituted variables → produces final prompt
```

### How Resolution Works

The compiler **never needs file paths passed explicitly**. It resolves references by ID:

1. A Blueprint or Visual Definition contains a field like `"visual_profile": "precision_industrial_v1"`.
2. The compiler searches the known Visual Profile directory for a file whose ID matches `precision_industrial_v1` (e.g., `VISUAL_PROFILE_precision_industrial_v1.md`).
3. Similarly, it resolves blueprint IDs to their JSON files, operational data IDs to their JSON files, etc.
4. If any ID cannot be resolved to an existing file, the compiler raises a **hard error** (see Error Behavior).

---

## Worked Example: I-beam Mk1

The I-beam Mk1 is used throughout this contract as a concrete example because:

- Production assets exist on disk: `data/images/catalog/components/structural/3d_printed_ibeam_mk{1-4}.png`
- No `component_blueprint.json` instance exists yet — this contract defines the pattern for the first one
- The I-beam Mk1–Mk4 are structural components with a clear dependency chain

### Expected File Layout (for the first component_blueprint.json)

```
data/json-data/blueprints/components/structural/ibeam_mk1_bp.json    ← Blueprint (new)
data/json-data/visual_definitions/components/structural/ibeam_mk1_vd.json  ← Visual Definition (new)
data/json-data/operational_data/components/structural/ibeam_mk1_ops.json  ← Operational Data (new)
docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md  ← Visual Profile (existing)
docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md  ← Render Template (existing)
```

### I-beam Mk1: Dependency Chain Walkthrough

**Layer 1 — Blueprint** (`ibeam_mk1_bp.json`):
```json
{
  "id": "ibeam_mk1",
  "asset_family": "component",
  "component_class": "structural",
  "visual_profile": "precision_industrial_v1",
  "technology_level": 1,
  "manufacturing_style": "additive_construction",
  "name": "I-Beam Mk1",
  "description": "Primary structural support member for early-stage construction"
}
```

**Layer 2 — Visual Profile** (resolved from `"precision_industrial_v1"`):
- File: `VISUAL_PROFILE_precision_industrial_v1.md`
- Provides locked attributes: clean white/light-gray paneling, dark gray undercarriage, black/yellow hazard striping, precision-machined surfaces, NASA/ESA-inspired aerospace-industrial aesthetic

**Layer 3 — Visual Definition** (`ibeam_mk1_vd.json`):
```json
{
  "visual_definition": {
    "asset_id": "COMP_STRUCTURAL_IBEEP_MK1",
    "asset_family": "component",
    "component_class": "structural",
    "recognition_features": [
      "I-shaped cross-section profile",
      "flanged top and bottom edges",
      "web plate connecting flanges",
      "bolted connection holes at regular intervals"
    ],
    "material_profiles": [
      "3d_printed_regolith",
      "cast_steel"
    ],
    "technology_level": 1,
    "manufacturing_style": "additive_construction"
  }
}
```

**Layer 4 — Operational Data** (`ibeam_mk1_ops.json`):
```json
{
  "operational_data": {
    "asset_id": "ibeam_mk1",
    "functional_role": "Primary structural support member for early-stage construction. Provides load-bearing capacity for habitation modules and equipment racks.",
    "load_capacity_kg": 500,
    "durability_rating": "Mk1_frontier_grade"
  }
}
```

**Layer 5 — Render Template** (existing):
- File: `PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md`
- Variables to substitute: `{{UNIT_NAME}}`, `{{FUNCTIONAL_ROLE}}`, `{{RECOGNITION_FEATURES}}`

### Compiled Prompt Output (I-beam Mk1)

```
Render a single I-Beam Mk1 for GalaxyGame.

STYLE: Inherit all STYLE characteristics from precision_industrial_v1.
Do not reinterpret, improve, modernize, or vary the established manufacturing language.

FUNCTION: Primary structural support member for early-stage construction. Provides load-bearing capacity for habitation modules and equipment racks.

MANUFACTURING: Inherit all MANUFACTURING characteristics from precision_industrial_v1.

MATERIALS: Inherit all MATERIAL definitions from precision_industrial_v1.
Additional material profiles: 3d_printed_regolith, cast_steel

RECOGNITION FEATURES:
- I-shaped cross-section profile
- flanged top and bottom edges
- web plate connecting flanges
- bolted connection holes at regular intervals

RENDER REQUIREMENTS:
- Single vehicle or object only
- No duplicate objects
- Entire object visible
- Top-down orthographic camera with no perspective distortion
- Vehicle centered within the image
- The subject should occupy approximately 75% of the canvas.
- Soft neutral studio lighting
- Physically accurate materials
- Moderate detail suitable for production game assets
- Strong, immediately recognizable silhouette
- Slight panel seams and realistic industrial wear where appropriate
- Functional hazard markings permitted where appropriate
- No dramatic cinematic effects

BACKGROUND: Transparent background (no terrain, no ground plane, no sky, no stars, no environment)

OUTPUT: Transparent PNG, 1024x1024 pixels, object isolated from background
```

---

## Required Fields

The fields below are **required** per layer. These are verified against the actual `VISUAL_DEFINITION_TEMPLATE.md` schema (confirmed at `docs/reference/asset-generation/VISUAL_DEFINITION_TEMPLATE.md`).

### Layer 1: Blueprint (`unit_blueprint.json` or `component_blueprint.json`)

| Field | Type | Required? | Notes |
|---|---|---|---|
| `id` | string | **Yes** | Canonical asset identifier; must be unique within its directory |
| `asset_family` | string | **Yes** | Must be one of: `resource`, `component`, `assembly`, `equipment`, `unit`, `structure`, `vehicle`, `organization` |
| `component_class` | string | **Yes** (for components/units/structures/vehicles) | Maps to Icon Bible categories; e.g., `structural`, `mechanical`, `electronics` |
| `visual_profile` | string | **Yes** | ID referencing a Visual Profile; must resolve to an existing file |
| `technology_level` | integer | **Yes** | Must be 1–5 |
| `manufacturing_style` | string | **Yes** | Must be one of: `precision_factory`, `additive_construction`, `cast_construction`, `modular_assembly`, `heavy_industrial`, `bootstrap_frontier` |

### Layer 2: Visual Profile (`.md` file)

Visual Profiles are markdown documents, not JSON. The compiler reads them as text and extracts locked attributes. No required JSON fields — the contract validates that the referenced file **exists** and is a valid Visual Profile document (contains `Profile ID` and `Locked attributes` sections).

### Layer 3: Visual Definition (`visual_definition.json`)

Verified against `VISUAL_DEFINITION_TEMPLATE.md` (confirmed at `docs/reference/asset-generation/VISUAL_DEFINITION_TEMPLATE.md`).

| Field | Type | Required? | Notes |
|---|---|---|---|
| `asset_id` | string | **Yes** | Canonical ID in Icon Bible format: `[CATEGORY]_[TYPE]_[NAME]_[VARIANT]` |
| `asset_family` | string | **Yes** | Same valid values as Blueprint layer |
| `component_class` | string | **Yes** (for components/units/structures/vehicles) | Same valid values as Blueprint layer |
| `recognition_features` | array of strings | **Yes** | Minimum 4 items triggers a WARNING (not a hard failure); see Validation Rules |
| `material_profiles` | array of strings | **Yes** | Each string must map to a valid Material Library entry |
| `technology_level` | integer | **Yes** | Must be 1–5; should match Blueprint layer's value |
| `manufacturing_style` | string | **Yes** | Same valid values as Blueprint layer; should match Blueprint layer's value |

### Layer 4: Operational Data (`operational_data.json`)

| Field | Type | Required? | Notes |
|---|---|---|---|
| `asset_id` | string | **Yes** | Must match the Blueprint's `id` field |
| `functional_role` | string | **Yes** | Non-empty description of the asset's function; used for `{{FUNCTIONAL_ROLE}}` substitution |

### Layer 5: Render Template (`.md` file)

The Render Template is a markdown document with placeholder variables. The compiler validates that it exists and contains the expected placeholders (`{{UNIT_NAME}}`, `{{FUNCTIONAL_ROLE}}`, `{{RECOGNITION_FEATURES}}`). No required JSON fields.

---

## Validation Rules

### Hard Errors (block compilation)

| Rule | Condition | Action |
|---|---|---|
| **Reference Resolution** | Any referenced ID cannot be resolved to an existing file | Hard error; report broken reference + "did you mean: X?" suggestion if close-match filename exists in same directory |
| **Missing Required Field** | Any required field (per layer above) is absent or empty | Hard error; name the field and which file it was expected in |
| **Invalid Enum Value** | `asset_family`, `component_class`, `technology_level`, or `manufacturing_style` has an invalid value | Hard error; list valid values |
| **Cross-Layer Mismatch** | `visual_profile` ID in Blueprint does not match `visual_profile` in Visual Definition (if both present) | Hard error; report conflicting IDs |
| **ID Consistency** | `asset_id` in Visual Definition does not match `id` in Blueprint | Warning (not hard error); compilation proceeds but flag for human review |

### Warnings (do not block compilation)

| Rule | Condition | Action |
|---|---|---|
| **Sparse Recognition Features** | `recognition_features` has fewer than 4 items | Warning with explicit count; compilation proceeds. In Assist Mode, the compiler may generate candidate features (see Suggestion Mode) |
| **ID Consistency** | `asset_id` in Visual Definition does not match `id` in Blueprint | Warning; compilation proceeds but flag for human review |
| **Cross-Layer Tech Level Mismatch** | `technology_level` differs between Blueprint and Visual Definition | Warning; compilation proceeds but flag for human review |

---

## Compile Mode (v1 — Deterministic)

### Allowed Transformations

The compiler in Compile Mode may:

1. **Read** canonical files from the dependency chain
2. **Resolve** ID references into file paths by searching known directories
3. **Substitute** placeholders (`{{UNIT_NAME}}`, `{{FUNCTIONAL_ROLE}}`, `{{RECOGNITION_FEATURES}}`) into the Render Template
4. **Validate** required fields are present and values are valid
5. **Generate** the output prompt file plus a provenance/metadata header
6. **Report** warnings for soft gaps (e.g., sparse `recognition_features`) without blocking compilation

### Forbidden Transformations

The compiler in Compile Mode may **NOT**:

1. **Invent, embellish, or infer** asset characteristics not present in the source data
2. **Modify** Visual Profiles, Render Templates, Blueprints, or Visual Definitions
3. **Auto-correct** a broken reference — report it as an error with a suggestion, but do not guess and proceed
4. **Proceed silently** on any hard error — compilation must stop

---

## Suggestion Mode (Assist Mode — Separate from Compile Mode)

A distinct, explicitly separate mode that may derive candidate values for sparse fields.

### Rules for Assist Mode

1. **Separate output**: Suggestions are clearly labeled as `SUGGESTION:` and never mixed with validated facts
2. **Source-bound**: Suggestions are derived ONLY from the blueprint's own stated capabilities/components — never from external knowledge or inference
3. **No writes**: Assist Mode NEVER writes to canonical files. A human must review and manually apply any accepted suggestion
4. **Explicit opt-in**: Assist Mode is only activated by an explicit flag/parameter; it is NOT the default behavior
5. **Never mistaken for fact**: The output format ensures a suggestion can never be confused with a validated field value

### Example Assist Mode Output (I-beam Mk1, sparse recognition_features)

```
=== ASSIST MODE SUGGESTIONS ===

Field: recognition_features (current count: 2, recommended minimum: 4)

Source data: ibeam_mk1_bp.json
- component_class: structural
- technology_level: 1
- manufacturing_style: additive_construction

SUGGESTION: "I-shaped cross-section profile" — derived from component_class=structural + asset_family=component
SUGGESTION: "flanged top and bottom edges" — standard structural I-beam geometry
SUGGESTION: "web plate connecting flanges" — required for load-bearing function
SUGGESTION: "bolted connection holes at regular intervals" — consistent with additive_construction manufacturing style

Note: These are CANDIDATE suggestions only. A human must review and manually apply any accepted suggestion to the Visual Definition file.
```

---

## Output Format

### Generated Prompt File

The compiled prompt is saved to a file (not printed only). The output path follows this convention:

```
data/json-data/prompts/[asset_family]/[component_class]/[asset_id]_prompt.md
```

Example for I-beam Mk1:
```
data/json-data/prompts/component/structural/ibeam_mk1_prompt.md
```

### Provenance Header

Every generated prompt file begins with a YAML frontmatter provenance header:

```yaml
---
provenance:
  asset_id: "ibeam_mk1"
  prompt_type: "production_render"
  generated_from:
    blueprint:
      file: "data/json-data/blueprints/components/structural/ibeam_mk1_bp.json"
      id: "ibeam_mk1"
    visual_profile:
      file: "docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md"
      id: "precision_industrial_v1"
    visual_definition:
      file: "data/json-data/visual_definitions/components/structural/ibeam_mk1_vd.json"
      id: "COMP_STRUCTURAL_IBEEP_MK1"
    operational_data:
      file: "data/json-data/operational_data/components/structural/ibeam_mk1_ops.json"
      id: "ibeam_mk1"
    render_template:
      file: "docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md"
      version: "1.0"
  generated_by: "<compiler_identifier>"
  generated_date: "YYYY-MM-DD"
---
```

### Version Tracking (v2 — Planned, NOT v1)

The following is documented here for v2 implementation reference. **v1 does NOT implement version tracking.**

**Intended future field in provenance header:**
```yaml
source_versions:
  blueprint: "v1.0"
  visual_profile: "v1.1"
  visual_definition: "v1.0"
  render_template: "v1.0"
```

Blueprints already have `metadata.version` / `template_compliance` fields. Visual Profiles, Visual Definitions, and Render Templates currently do not. v2 will add version fields to all layers and include them in the provenance header.

### Regeneration Rules (v2 — Planned, NOT v1)

Regeneration (re-running the compiler on existing assets to produce updated prompts when source data changes) depends on version tracking. This is noted as future scope only. v1 does not implement regeneration logic.

---

## Error/Warning Behavior

All errors and warnings must be **human-readable and actionable**, not just stack traces.

### Error Format

```
ERROR [COMPILER-001]: Reference resolution failed
  Asset: ibeam_mk1
  Broken reference: visual_profile = "precision_industrial_v2"
  Searched in: docs/reference/asset-generation/VISUAL_PROFILE_*.md
  Did you mean: precision_industrial_v1 (found at VISUAL_PROFILE_precision_industrial_v1.md)?
```

### Warning Format

```
WARNING [COMPILER-003]: Sparse recognition_features
  Asset: ibeam_mk1
  File: data/json-data/visual_definitions/components/structural/ibeam_mk1_vd.json
  Current count: 2 (minimum recommended: 4)
  Compilation proceeds but consider adding more features for consistent recognition.
```

### Error Codes

| Code | Condition | Severity |
|---|---|---|
| `COMPILER-001` | Reference resolution failed | Hard error |
| `COMPILER-002` | Missing required field | Hard error |
| `COMPILER-003` | Sparse recognition_features (< 4 items) | Warning |
| `COMPILER-004` | Invalid enum value | Hard error |
| `COMPILER-005` | Cross-layer mismatch (visual_profile ID) | Hard error |
| `COMPILER-006` | ID inconsistency between layers | Warning |
| `COMPILER-007` | Technology level mismatch between layers | Warning |

---

## Stop Conditions

The compiler MUST halt and report to the user (not silently proceed) if:

1. **Canonical doc missing**: Any of the referenced canonical docs (`VISUAL_DEFINITION_TEMPLATE.md`, `ASSET_GENERATION_ARCHITECTURE.md`, `PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md`) cannot be located at their expected paths
2. **Schema mismatch**: The actual current schema for Visual Definitions/Profiles materially disagrees with what's described in this contract — report the discrepancy, do not silently reconcile by picking one

---

## Directory Conventions

The compiler assumes these directory conventions for resolution:

| Layer | Directory Pattern | Example |
|---|---|---|
| Blueprint | `data/json-data/blueprints/[asset_family]/[component_class]/` | `data/json-data/blueprints/components/structural/ibeam_mk1_bp.json` |
| Visual Profile | `docs/reference/asset-generation/VISUAL_PROFILE_<id>.md` | `docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md` |
| Visual Definition | `data/json-data/visual_definitions/[asset_family]/[component_class]/` | `data/json-data/visual_definitions/components/structural/ibeam_mk1_vd.json` |
| Operational Data | `data/json-data/operational_data/[asset_family]/[component_class]/` | `data/json-data/operational_data/components/structural/ibeam_mk1_ops.json` |
| Render Template | `docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | (single file) |

---

## Scope Boundaries

### In Scope (this contract)

- Defining the dependency chain structure and resolution rules
- Specifying required fields per layer (verified against actual schemas)
- Defining validation rules, error codes, and warning thresholds
- Specifying Compile Mode vs. Assist Mode behavior
- Defining output format including provenance header
- Documenting v2 planned features (version tracking, regeneration)

### Out of Scope (this contract)

- Implementation code (Ruby/Python) — that is the next task
- Actual JSON data files — those are created by separate tasks
- Sprite generation logic — handled by existing scripts (`generate_sprites.py`, `generate_unit_sprites.py`)
- Image model integration — the prompt output is model-agnostic; how it reaches an image generator is outside scope

---

## Acceptance Criteria

- [x] This contract exists as a standalone file at `docs/reference/asset-generation/ASSET_PROMPT_COMPILER_CONTRACT.md`
- [x] All sections from the task spec are present, with `[FILL IN]` sections resolved against actual current schema files (not guessed)
- [x] Compile Mode (v1, deterministic, never modifies source) is explicitly separated from Assist Mode (suggestion-only, human-approval-required)
- [x] Version tracking and regeneration rules are explicitly marked as v2/future scope, not v1 requirements
- [x] Content does not duplicate content already owned by another canonical doc — references links instead of restating
- [x] The I-beam Mk1 is used as a concrete worked example in Required Fields and Dependency Resolution sections
- [x] The contract explicitly notes that no `component_blueprint.json` instances exist yet — this establishes the pattern for the first one

---

## Dependencies

**Blocked by**: none
**Blocks**: the v1 Asset Compiler build task (not yet filed) — that task should implement against this contract, not the other way around
**Related tasks**: none filed yet — see `[[asset-pipeline]]` for full design history

---

## Completion Report

*Filled in by the implementing agent after completion*

- Contract written: 2026-08-24
- Schema verification: VISUAL_DEFINITION_TEMPLATE.md, ASSET_GENERATION_ARCHITECTURE.md, PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md, VISUAL_PROFILE_precision_industrial_v1.md all confirmed at expected paths
- I-beam Mk1 worked example: validated against existing production assets on disk
- component_blueprint.json gap: confirmed no instances exist; contract establishes the pattern

## Handoff Summary

*Filled in at end of session*
