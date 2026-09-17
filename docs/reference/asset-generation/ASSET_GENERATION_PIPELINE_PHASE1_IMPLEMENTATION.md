# Asset Generation Pipeline — Phase 1 Implementation Plan

**Date**: 2026-08-27
**Scope**: Profile Resolution Engine, Composition Refinery, Prompt Compiler/Builder
**Principle**: Data-driven and extensible. RH-400 and I-beam are validation cases, not templates.
**Constraint**: Use existing `CatalogService` as the sole data-loading boundary. No duplication of blueprint/operational-data file loading logic.

---

## 1. ARCHITECTURAL OVERVIEW

```
┌─────────────────────────────────────────────────────────────┐
│  CATALOG SERVICE (existing)                                 │
│  Loads blueprints, operational data from JSON files         │
│  Provides find_entry(), entries_for()                       │
└──────────────────────┬──────────────────────────────────────┘
                       │ (provides raw canonical data)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: PROFILE RESOLUTION ENGINE                         │
│                                                             │
│  Input: CatalogService entry for Visual Profile             │
│  Output: Structured profile attributes                      │
│                                                             │
│  Responsibilities:                                          │
│  - Parse Visual Profile markdown → extract locked attrs     │
│  - Resolve profile types (global_visual_style,              │
│    manufacturing_style, technology_level, render_type)      │
│  - Cross-validate Blueprint vs Visual Definition fields     │
│  - Return structured attributes (not prose)                 │
└──────────────────────┬──────────────────────────────────────┘
                       │ (structured profile attributes)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 2: COMPOSITION REFINERY                              │
│                                                             │
│  Input: Structured profile attributes + Visual Definition   │
│        + optional targeted refinements + optional safeguards│
│  Output: Composed prompt sections (structured, not prose)   │
│                                                             │
│  Responsibilities:                                          │
│  - Organize recognition features by priority tier           │
│  - Apply optional targeted refinements (configurable)       │
│  - Apply optional safeguards (configurable)                 │
│  - Produce ordered prompt sections                          │
│  - Never invent values for unknown/unpopulated fields       │
└──────────────────────┬──────────────────────────────────────┘
                       │ (composed prompt sections)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 3: PROMPT COMPILER / BUILDER                         │
│                                                             │
│  Input: Composed prompt sections + Render Template          │
│  Output: FROZEN renderer-neutral prompt with provenance     │
│                                                             │
│  Responsibilities:                                          │
│  - Walk five-layer dependency chain (via CatalogService)    │
│  - Validate required fields, resolve IDs                    │
│  - Substitute composed sections into Render Template        │
│  - Produce FROZEN prompt with provenance header             │
│  - Never treat reference images as authoritative geometry   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. DATA BOUNDARIES — WHAT BELONGS WHERE

### Canonical Data (Immutable, loaded via CatalogService)

| Layer | Source | What It Provides |
|-------|--------|-----------------|
| Blueprint | `CatalogService.find_entry(id)` → blueprint entry | `id`, `asset_family`, `component_class`, `visual_profile` ID, `technology_level`, `manufacturing_style`, physical specs |
| Operational Data | `CatalogService.find_operational_data_by_name(blueprint_filename)` | `functional_role`, dimensions, mass, deployment info |
| Visual Definition | File in `docs/reference/asset-generation/visual_definitions/` | `recognition_features`, `visual_priority`, `material_profiles`, `color_profile`, `design_constraints` |
| Visual Profile | File in `docs/reference/asset-generation/` (markdown) | Locked attributes: materials, finish, aesthetic, markings |
| Render Template | File in `docs/reference/asset-generation/` (markdown) | Camera/lighting/background/output rules |

### Generation Composition (Configurable, built by pipeline)

| Layer | What It Does | Configuration Boundary |
|-------|-------------|----------------------|
| Profile Resolution | Reads Visual Profile markdown → structured attributes | No config needed — deterministic parsing |
| Feature Priority | Orders recognition features by `visual_priority` tier | Uses Visual Definition's `visual_priority` field (canonical) |
| Targeted Refinements | Optional hex color ranges, geometric constraints | **EXPERIMENTAL** — configurable, disabled by default |
| Safeguards | Optional camera precedence, autonomous protection, feature tier elevation | **EXPERIMENTAL** — configurable, disabled by default |
| Prompt Compilation | Walks chain, validates, substitutes, produces FROZEN prompt | Deterministic — no config needed |

### Critical Rule: No Duplication of Data Loading

**CatalogService is the sole data-loading boundary.** The Profile Resolution Engine and Prompt Compiler MUST use CatalogService to load canonical data. They must NOT read blueprint/operational-data JSON files directly.

---

## 3. COMPONENT SPECIFICATIONS

### 3.1 Profile Resolution Engine

**File**: `galaxy_game/app/services/asset_generation/profile_resolution_engine.rb`

**Responsibilities**:
1. Accept a Visual Profile ID (e.g., `"precision_industrial_v1"`)
2. Load the Visual Profile markdown file via CatalogService or direct path resolution
3. Parse locked attributes from markdown (materials, finish, aesthetic, markings)
4. Resolve four profile types:
   - `global_visual_style` — from Visual Profile locked attributes
   - `manufacturing_style` — cross-validate Blueprint + Visual Definition
   - `technology_level` — cross-validate Blueprint + Visual Definition
   - `render_type` — from Render Template being used
5. Cross-validate Blueprint vs Visual Definition fields (warn on mismatch)
6. Return structured attributes (Hash, not prose)

**Input**:
```ruby
{
  visual_profile_id: "precision_industrial_v1",
  blueprint_data: { "technology_level": 2, "manufacturing_style": "heavy_industrial" },
  visual_definition_data: { "technology_level": 2, "manufacturing_style": "heavy_industrial" },
  render_template_path: "/path/to/render_template.md"
}
```

**Output**:
```ruby
{
  global_visual_style: {
    profile_id: "precision_industrial_v1",
    materials: ["high-strength aerospace steel", "aluminum structural members", ...],
    finish: "clean white/light-gray primary paneling over dark gray/black mechanical undercarriage...",
    aesthetic: "NASA/ESA-inspired aerospace-industrial"
  },
  manufacturing_style: {
    profile_id: "earth_factory_v1",
    method: "precision industrial factory assembly",
    quality: "factory-assembled, not frontier/bootstrap",
    materials: [...],
    excluded: ["frontier/bootstrap/improvised construction", ...]
  },
  technology_level: {
    profile_id: "tl2_v1",
    level: 2,
    characteristics: ["cleaner than early-generation equipment", ...],
    excluded: ["visible layer lines", "3D-printed rough texture", ...]
  },
  render_type: {
    profile_id: "catalog_render_v2",
    camera: "top-down orthographic",
    lighting: "soft neutral studio — cool, even, diffused",
    background: "transparent (alpha channel)",
    framing: "75% of canvas",
    output_format: "PNG, 1024x1024 pixels"
  }
}
```

**Key Design Decisions**:
- Visual Profile parsing extracts locked attributes from markdown bullet points and prose sections
- Cross-validation warns (does not block) on Blueprint vs Visual Definition mismatches
- Returns Hash — never prose. Prose is the Prompt Compiler's job.

### 3.2 Composition Refinery

**File**: `galaxy_game/app/services/asset_generation/composition_refinery.rb`

**Responsibilities**:
1. Accept structured profile attributes + Visual Definition data
2. Organize recognition features by priority tier (primary → secondary → tertiary) from Visual Definition's `visual_priority` field
3. Apply optional targeted refinements (hex color ranges, geometric constraints) — **disabled by default**
4. Apply optional safeguards (camera precedence, autonomous protection, feature tier elevation) — **disabled by default**
5. Produce ordered prompt sections (structured Hash, not prose)
6. Never invent values for unknown/unpopulated fields

**Input**:
```ruby
{
  profile_attributes: <output from ProfileResolutionEngine>,
  visual_definition: { "recognition_features": [...], "visual_priority": {...}, ... },
  targeted_refinements: { enabled: false, hex_color_ranges: [], geometric_constraints: [] },
  safeguards: { enabled: false, camera_precedence: false, autonomous_protection: false, feature_tier_elevation: false }
}
```

**Output**:
```ruby
{
  sections: {
    subject: "RH-400 Regolith Harvester Rover — functional role description",
    proportions: { visual_anchors: ["elongated low-slung vehicle", ...], canonical_dimensions: {...} },
    style: <from global_visual_style>,
    manufacturing: <from manufacturing_style>,
    technology_level: <from technology_level>,
    design_constraints: ["Fully autonomous industrial machine — NO cockpit, NO crew elements"],
    markings: { hazard_striping: {...}, unit_id: "stenciled on hull" },
    recognition_features: {
      primary: ["regolith skimming scoop assembly", "six-wheel independent suspension chassis"],
      secondary: ["mid-body processing canister", "sensor mast with rotating array"],
      tertiary: ["rear-mounted dust exhaust stack", "exposed hydraulic actuator arms"]
    },
    render_requirements: <from render_type>,
    background: <from render_type>,
    output: <from render_type>
  },
  provenance: { ... }
}
```

**Key Design Decisions**:
- Recognition features are ALWAYS ordered by `visual_priority` tier from Visual Definition — this is canonical, not configurable
- Targeted refinements and safeguards are OPTIONAL modules, disabled by default
- If a field is missing from canonical data, it is omitted from output (never invented)
- Reference images are never merged into prompt sections

### 3.3 Prompt Compiler / Builder

**File**: `galaxy_game/app/services/asset_generation/prompt_compiler.rb`

**Responsibilities**:
1. Accept composed prompt sections from Composition Refinery + Render Template path
2. Walk five-layer dependency chain (via CatalogService)
3. Validate required fields per layer
4. Substitute composed sections into Render Template variables
5. Produce FROZEN renderer-neutral prompt with provenance header
6. Never treat reference images as authoritative geometry

**Input**:
```ruby
{
  asset_id: "regolith_harvester_rover",
  render_template_path: "/path/to/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md",
  composed_sections: <output from CompositionRefinery>,
  targeted_refinements_config: { enabled: false, ... },
  safeguards_config: { enabled: false, ... }
}
```

**Output**:
```ruby
{
  prompt_text: "# Generated Prompt — Provenance Header\n# Asset ID: ...\n...\n\n[Prompt body]",
  provenance: {
    asset_id: "regolith_harvester_rover",
    blueprint_version: "2.1",
    visual_profile: "precision_industrial_v1",
    render_template: "PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md",
    composition_method: "profile_composition_v1",
    targeted_refinements: "none",
    safeguards: "none",
    generated_at: "2026-08-27T12:00:00Z",
    prompt_version: 1,
    status: "FROZEN"
  },
  validation_errors: [],
  validation_warnings: []
}
```

**Key Design Decisions**:
- Prompt structure follows the hierarchy from RH-006 experiments (CAMERA before STYLE, DESIGN CONSTRAINTS before recognition features)
- Provenance header is YAML frontmatter at the top of the prompt
- Validation errors block compilation; warnings do not
- Reference images are never read by the compiler — they are separate metadata

---

## 4. FILE LAYOUT

```
galaxy_game/app/services/asset_generation/
├── profile_resolution_engine.rb    # Layer 1: Profile Resolution
├── composition_refinery.rb          # Layer 2: Composition Refinery
└── prompt_compiler.rb               # Layer 3: Prompt Compiler/Builder

galaxy_game/spec/services/asset_generation/
├── profile_resolution_engine_spec.rb
├── composition_refinery_spec.rb
└── prompt_compiler_spec.rb
```

---

## 5. CONFIGURATION BOUNDARIES

### What Is Configurable (EXPERIMENTAL — opt-in)

| Feature | Default | How to Enable |
|---------|---------|--------------|
| Hex color ranges | Disabled | Pass `targeted_refinements: { enabled: true, hex_color_ranges: [...] }` |
| Geometric constraints | Disabled | Pass `targeted_refinements: { enabled: true, geometric_constraints: [...] }` |
| Camera precedence safeguard | Disabled | Pass `safeguards: { enabled: true, camera_precedence: true }` |
| Autonomous protection safeguard | Disabled | Pass `safeguards: { enabled: true, autonomous_protection: true }` |
| Feature tier elevation safeguard | Disabled | Pass `safeguards: { enabled: true, feature_tier_elevation: true }` |

### What Is NOT Configurable (Canonical — always applied)

| Feature | Source | Why |
|---------|--------|-----|
| Recognition feature priority ordering | Visual Definition `visual_priority` field | Canonical data, not experimental |
| Profile type resolution order | PROFILE_COMPOSITION_SPEC.md precedence rules | Architecture, not guidance |
| Cross-layer validation warnings | Blueprint vs Visual Definition mismatch | Data integrity check |
| Unknown field handling | Omit from output (never invent) | Prevents hallucination |
| Reference image separation | Compiler reads canonical data only | Anti-override safeguard |

---

## 6. TEST STRATEGY

### Test Fixtures (Validation Cases, Not Special Cases)

| Fixture | Source | Purpose |
|---------|--------|---------|
| RH-400 canonical data | `VEHICLE_HARVESTER_ROVER_RH400.json`, blueprint v2.1, operational data v2.1, Visual Profile, Render Template | Validate full pipeline on complex vehicle |
| I-beam Mk1 canonical data | Blueprint schema (component), Visual Profile, Render Template | Validate pipeline on simple component |

### Test Categories

| Category | What It Verifies | Test Method |
|----------|-----------------|-------------|
| Profile resolution | Locked attributes extracted correctly from markdown | Parse Visual Profile → compare structured output |
| Priority ordering | Recognition features ordered by `visual_priority` tier | Check primary/secondary/tertiary lists match Visual Definition |
| Composition precedence | Style/manufacturing come from resolved profiles, not inlined prose | Verify composed sections use profile data |
| Refinement application | Hex colors/constraints applied when enabled, omitted when disabled | Toggle refinements → verify output changes |
| Safeguard application | Camera/autonomous/tier safeguards applied when enabled, omitted when disabled | Toggle safeguards → verify output changes |
| Canonical data precedence | Blueprint wins over Visual Profile on conflicts | Set conflicting values → verify Blueprint wins |
| Unknown field handling | Missing fields omitted (never invented) | Remove fields from canonical data → verify omission |
| Deterministic compilation | Same inputs → same output every time | Run twice → compare outputs |
| CatalogService integration | Pipeline uses CatalogService, not direct file reads | Mock CatalogService → verify no direct file access |
| No duplication of data loading | Profile Resolution and Prompt Compiler use CatalogService | Code review + test with mocked CatalogService |

### RH-400 Structure Comparison

Compile the existing RH-400 case through the pipeline and compare the resulting prompt structure against the frozen Run 06 prompt architecture. Do NOT require byte-for-byte equality — the compiler produces structured output that follows the same hierarchy (CAMERA before STYLE, DESIGN CONSTRAINTS before recognition features, tiered features). Compare:
- Section ordering matches Run 06 architecture
- Recognition features appear in correct priority tiers
- Profile attributes are resolved from Visual Profile (not inlined)
- Provenance header is present and complete

---

## 7. IMPLEMENTATION ORDER

1. **Profile Resolution Engine** — simplest component, reads markdown, extracts attributes
2. **Composition Refinery** — depends on Profile Resolution Engine output
3. **Prompt Compiler/Builder** — depends on Composition Refinery output
4. **Tests** — test each component individually, then integration tests for full pipeline

---

## 8. DEVIATIONS FROM IMPLEMENTATION PLAN (If Any)

None anticipated. This plan refines the implementation plan with specific file layouts, method signatures, and configuration boundaries based on actual data structures observed in the codebase.

---

*Plan created: 2026-08-27*
*No code written. No files modified.*
