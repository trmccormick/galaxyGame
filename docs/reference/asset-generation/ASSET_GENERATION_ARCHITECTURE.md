---
date_created: 2026-07-20
type: ARCHITECTURE_SPECIFICATION
status: active
purpose: Roadmap for automated asset generation pipeline
---

# Asset Generation Architecture — Pipeline Specification

**Purpose**: Complete architecture for the automated asset generation pipeline. Bridges blueprints to game-ready assets through a structured, version-independent workflow.

**Position in System**: Sits between Blueprint/Operational Data and Image Generation. Defines HOW information flows from design to art.

---

## The Missing Link

ChatGPT identified: "You're missing one document that sits between the blueprints and the image generator."

This is it.

---

## Complete Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    INPUT LAYER                              │
│                                                             │
│  Blueprint (manufacturing)                                  │
│  Operational Data (runtime behavior)                        │
│  Visual Definition (appearance)                             │
│  Material Library (surface treatments)                      │
│  Icon Bible (visual language rules)                         │
│  Visual Philosophy (9 principles)                           │
│  Design Research Index (session specifications)             │
│  Shared Components Registry (reusable visual primitives)    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              BLUEPRINT VALIDATOR                            │
│                                                             │
│  Validates:                                                 │
│  - All required fields present                              │
│  - Asset ID follows canonical format                        │
│  - Material profiles reference valid entries                │
│  - Technology level is 1-5                                  │
│  - Manufacturing style matches Icon Bible                   │
│  - Recognition features are descriptive (not prompts)       │
│  - Shared components exist in Asset Registry                │
│  - Design constraints are project-compliant                 │
│                                                             │
│  Output: Validated blueprint set (ready for enrichment)     │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│             BLUEPRINT ENRICHMENT                            │
│                                                             │
│  Enriches with:                                             │
│  - Default values from Icon Bible (color families, shapes)  │
│  - Material Library entries (surface finish defaults)       │
│  - Animation profiles by category                           │
│  - Render profiles by asset family                          │
│  - Complexity level defaults                                │
│  - Manufacturing style defaults                             │
│                                                             │
│  Output: Enriched blueprint set (complete visual spec)      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                PROMPT BUILDER                               │
│                                                             │
│  Converts four canonical sources into structured prompts:   │
│                                                             │
│  Inputs:                                                    │
│  - Blueprint (validated + enriched)           [manufacturing spec] │
│  - Operational Data                         [runtime behavior] │
│  - Visual Definition                        [appearance spec] │
│  - Design System                            [Icon Bible + Material Library + Philosophy] │
│                                                             │
│  Outputs (one per render profile):                          │
│  - Inventory Prompt (L0-L1, silhouette only)               │
│  - Catalog Prompt (white bg, two isometric views)          │
│  - Blueprint Prompt (section cuts, exploded diagrams)      │
│  - Engineering Prompt (callouts, dimensions, materials)    │
│  - Sprite Prompt (all complexity levels L0-L5)             │
│                                                             │
│  Each prompt uses:                                            │
│  - Subject from asset_id                                    │
│  - Category from component_class                            │
│  - Material from material_profiles                          │
│  - Color from color_profile                                 │
│  - Shape from Icon Bible shape language                     │
│  - Tech level from technology_level                         │
│  - Manufacturing from manufacturing_style                   │
│  - Lighting from Icon Bible Section 3                       │
│  - Background from render profile                           │
│  - Animation from animation_profile + speed                 │
│  - Complexity from complexity_levels                        │
│  - Output size from complexity level                        │
│  - Style reference from Visual Philosophy                   │
│  - Acceptance criteria from Icon Bible                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              PROMPT ARCHIVE                                 │
│                                                             │
│  Stores:                                                    │
│  - Generated prompts with version stamps                    │
│  - Prompt template versions used                            │
│  - Blueprint version that generated the prompt              │
│  - Timestamp and generator ID                               │
│                                                             │
│  Enables:                                                   │
│  - Reproducibility (regenerate same asset)                  │
│  - Audit trail (which prompt produced which asset)          │
│  - Template evolution (upgrade prompts without losing       │
│    ability to regenerate old assets)                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              IMAGE GENERATOR                                │
│                                                             │
│  Receives:                                                  │
│  - Structured prompt (from Prompt Builder)                  │
│  - Image generation model (current or future)               │
│                                                             │
│  Produces:                                                  │
│  - Asset images at specified complexity levels              │
│  - Multiple render types per asset                          │
│  - Animation keyframes                                      │
│  - Sprite sheets                                            │
│                                                             │
│  Model-agnostic:                                            │
│  - Current: ChatGPT image generation                        │
│  - Future: Any image model                                  │
│  - Prompt format unchanged when model changes               │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│           AUTOMATED PRE-FILTER              │  (new)        │
│                                                             │
│  Runs before human review:                                  │
│  - Background transparency check                            │
│  - Sprite pivot alignment                                   │
│  - Tile edge continuity                                     │
│  - Resolution/compliance                                    │
│  - Color family validation                                  │
│                                                             │
│  Output: Pre-filtered assets (passed → Human QA)            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              HUMAN QA REVIEW                                │
│                                                             │
│  Validates against:                                         │
│  - Visual Philosophy (9 principles)                         │
│  - Icon Bible acceptance criteria                           │
│  - Category-specific animation rules                        │
│  - Damage state progression                                 │
│  - Complexity level consistency                             │
│  - Manufacturing style accuracy                             │
│  - Color family correctness                                 │
│  - Shape language compliance                                │
│  - Tech level progression                                   │
│  - Location-agnostic naming                                 │
│                                                             │
│  Output: Approved or rejected with specific feedback        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              ASSET REGISTRY                                 │
│                                                             │
│  Registers:                                                 │
│  - Canonical asset ID                                       │
│  - All generated render types                               │
│  - Complexity level variants (L0-L5)                        │
│  - Animation keyframes                                      │
│  - Sprite sheets                                            │
│  - Blueprint version that generated it                      │
│  - Prompt template version used                             │
│  - QA approval status                                       │
│  - Obsolete asset references (for regeneration)             │
│                                                             │
│  Enables:                                                   │
│  - Canonical lookup by ID                                   │
│  - Version tracking                                         │
│  - Regeneration when art style evolves                      │
│  - Archival of obsolete assets                              │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  GAME                                     │
│                                                             │
│  Consumes:                                                  │
│  - Approved assets from Asset Registry                      │
│  - References by canonical ID (not filename)                │
│  - All complexity levels available                          │
│  - Animation profiles applied at runtime                    │
│  - Damage states layered on top                             │
│                                                             │
│  Result: Consistent, scalable, location-agnostic assets     │
└─────────────────────────────────────────────────────────────┘
```

---

## Design Principle: Location Independence

Assets are **location-agnostic**. The same asset library is used across all planets (Luna, Mars, Venus, etc.).

Planetary appearance is achieved through:
- Terrain layer composition (surface tiles)
- Environmental effects (atmosphere, weather)
- Lighting and color grading
- Simulation parameters (gravity, temperature, pressure)

**Not through duplicate asset libraries.** A `UNIT_INFLATABLE_HAB_MK3` on Luna is the same visual asset as one on Mars — only the terrain beneath it and the atmospheric lighting differ.

This principle is enforced by:
- Asset IDs that contain no location prefix
- Visual Definitions that specify appearance, not environment
- Prompt templates that exclude planetary context from subject description

---

## Asset Classes

Assets fall into two classes with different rendering requirements. The distinction affects
which render profiles are generated, which prompt templates are used, and which QA criteria apply.

### Inspection Assets
Purpose: Human-readable reference documentation.

| Render Type | Background | Detail Level | Use Case |
|-------------|-----------|--------------|----------|
| inventory_icon | Opaque (solid) | L0-L1 silhouette | UI slots, menus |
| catalog_render | White | Two isometric views | Encyclopedia, reference |
| engineering_render | White/light | Callouts + dimensions | Technical documentation |
| blueprint | White | Section cuts, internal routing | Design review |
| exploded_view | White | Disassembled components | Assembly instructions |

### Gameplay Assets
Purpose: Runtime rendering in the game world.

| Render Type | Background | Detail Level | Use Case |
|-------------|-----------|--------------|----------|
| sprite_sheet | Transparent | L0-L5 complexity | Surface tiles, inventory |
| animation_keyframes | Transparent | Per-frame detail | In-world animation |
| damage_states | Transparent | Progressive degradation | Combat/decay visuals |
| construction_states | Transparent | Progressive assembly | Building sequence |

### Cross-Class Rules
- Both classes share the same Visual Definition (appearance spec)
- Both classes use the same canonical asset ID
- Inspection assets validate against documentation standards
- Gameplay assets validate against runtime suitability (pivot, transparency, tile alignment)

---

## Component Details

### 1. Blueprint Validator

**Purpose**: Ensure all input documents are well-formed before processing.

**Validation Rules**:
| Rule | Description | Error Level |
|------|-------------|-------------|
| `asset_id_format` | Must match `[CATEGORY]_[TYPE]_[NAME]_[VARIANT]` | ERROR |
| `required_fields_present` | All REQUIRED fields present | ERROR |
| `material_profiles_valid` | Each profile references valid Material Library entry | ERROR |
| `technology_level_range` | Must be 1-5 | ERROR |
| `manufacturing_style_valid` | Must match one of 6 manufacturing methods | ERROR |
| `recognition_features_descriptive` | Features are descriptive, not prompts | WARNING |
| `shared_components_exist` | Each shared component exists in Asset Registry | WARNING |
| `design_constraints_compliant` | Constraints are project-compliant | WARNING |
| `color_profile_valid` | Colors match Icon Bible color families | WARNING |
| `animation_profile_valid` | Animation matches category rules | WARNING |

**Output**: Validated blueprint set (hash of all input documents)

### 2. Blueprint Enrichment

**Purpose**: Fill in defaults from Icon Bible and Material Library so the Prompt Builder has complete information.

**Enrichment Rules**:
| Field | Default Source | Example |
|-------|---------------|---------|
| `color_profile` | Icon Bible color families (by category) | Silver for metals, blue for gases |
| `animation_profile` | Icon Bible animation language (by category) | Pulse for gases, blink for electronics |
| `render_profiles` | Icon Bible complexity levels | L0-L5 for all assets |
| `camera_profiles` | Session 2 catalog standards | front_isometric + rear_isometric |
| `surface_finish` | Material Library defaults | Matte for inflatable polymer |
| `complexity_levels` | Icon Bible Section 11 | All levels unless specified |

**Output**: Enriched blueprint set (complete visual specification)

### 3. Prompt Builder

**Purpose**: Convert enriched blueprints into structured prompts for image generation.

**Prompt Structure** (from Icon Bible Section 12):
```
Subject: [asset_id]
Category: [component_class]
Material: [material_profiles joined]
Color Family: [color_profile.primary]
Shape Language: [Icon Bible shape for category]
Tech Level: [technology_level]
Manufacturing Origin: [manufacturing_style]
Lighting: 45° top-left, key light strong, rim light subtle, fill light 30%
Background: [render profile specific]
Animation: [animation_profile]
Animation Speed: [category-specific cycle time]
Complexity Level: [complexity_levels joined]
Output Size: [pixels based on complexity level]
Style Reference: [Visual Philosophy mood]
Acceptance: Must match Icon Bible rules exactly. No deviations.
```

**Prompt Templates** (one per render profile):
| Render Profile | Prompt Template | Output Size |
|---------------|-----------------|-------------|
| inventory_icon | Silhouette only, no detail | 24px or 32px |
| catalog_render | White bg, two isometric views, no text | 256px |
| engineering_render | Callouts, dimensions, materials | 512px |
| blueprint | Section cuts, exploded diagrams | 512px |
| sprite_sheet | All complexity levels in one sheet | 1024x1024 |

**Template Versioning**:
- Templates evolve independently of blueprints
- Each prompt includes template version reference
- Old prompts can be regenerated with new templates
- Prompt archive tracks which template produced each asset

### 4. Prompt Archive

**Purpose**: Track every generated prompt for reproducibility and audit trail.

**Archive Entry**:
```json
{
  "prompt_id": "PROMPT_20260720_001",
  "blueprint_version": "14",
  "operational_data_version": "3",
  "visual_definition_revision": "5",
  "template_version": "3",
  "generated_at": "2026-07-20T12:00:00Z",
  "generator_id": "prompt_builder_v2.0",
  "prompt_text": "...",
  "output_asset_ids": ["UNIT_INFLATABLE_HAB_MK3_catalog_render"],
  "status": "completed"
}
```

### 5. Image Generator

**Purpose**: Generate images from structured prompts. Model-agnostic.

**Inputs**:
- Structured prompt (from Prompt Builder)
- Image generation model (current or future)

**Outputs**:
- Asset images at specified complexity levels
- Multiple render types per asset
- Animation keyframes
- Sprite sheets

**Model Independence**:
- Prompt format is stable regardless of image model
- When switching models, only the generator layer changes
- Blueprints, Visual Definitions, and Prompts remain unchanged

### 6. Human QA Review

**Purpose**: Human review of assets that passed automated pre-filtering.

**Automated Pre-Filter** (runs before human review):
| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Background transparency | Pixel analysis | No opaque pixels outside asset bounds |
| Sprite pivot alignment | Bounding box analysis | Pivot at expected position |
| Tile edge continuity | Edge comparison | Adjacent tiles connect visually |
| Resolution compliance | Dimension check | Matches spec dimensions |
| Color family validation | Histogram analysis | Colors within Icon Bible families |

**Human Review Checklist**:
| Check | Why Automated Can't Do It |
|-------|--------------------------|
| Grounded in reality | Requires domain knowledge (NASA/ESA reference) |
| Functional clarity | Requires understanding of engineering intent |
| Gameplay suitability | Requires playtesting intuition |
| Baked terrain quality | Requires visual judgment of tile seams |
| Sprite pivot correctness | Requires understanding of in-world behavior |
| Manufacturing style accuracy | Requires comparison to real hardware |
| Tech level progression | Requires comparative analysis across Mk1-Mk5 |

**Output**: Approved / Rejected with specific human-readable feedback

### 7. Asset Registry

**Purpose**: Canonical registry of all approved assets. Single source of truth.

**Registry Entry**:
```json
{
  "asset_id": "UNIT_INFLATABLE_HAB_MK3",
  "asset_family": "unit",
  "component_class": "habitat",
  "technology_level": 3,
  "manufacturing_style": "precision_factory",
  "status": "approved",
  "generated_at": "2026-07-20T12:00:00Z",
  "blueprint_version": "14",
  "visual_definition_version": "5",
  "prompt_template_version": "3",
  "qa_reviewer": "qwen",
  "qa_timestamp": "2026-07-20T13:00:00Z",
  "assets": {
    "inventory_icon": "/assets/UNIT_INFLATABLE_HAB_MK3/icon_32.png",
    "catalog_render": "/assets/UNIT_INFLATABLE_HAB_MK3/catalog_256.png",
    "engineering_render": "/assets/UNIT_INFLATABLE_HAB_MK3/engineering_512.png",
    "blueprint": "/assets/UNIT_INFLATABLE_HAB_MK3/blueprint_512.png",
    "exploded_view": "/assets/UNIT_INFLATABLE_HAB_MK3/exploded_512.png",
    "sprite_sheet": "/assets/UNIT_INFLATABLE_HAB_MK3/sprite_sheet_1024.png",
    "animation_keyframes": ["/assets/UNIT_INFLATABLE_HAB_MK3/kf_01.png", ...]
  },
  "complexity_levels": [0, 1, 2, 3, 4],
  "shared_components": ["COMP_STANDARD_AIRLOCK", "COMP_POWER_PORT"],
  "animation_profile": "glow",
  "obsolete_assets": [],
  "regeneration_eligible": true
}
```

**Regeneration**: When art style evolves:
1. Update Visual Definition or Prompt Template version
2. Mark assets as `regeneration_eligible`
3. Re-run pipeline for eligible assets
4. Old assets archived, new assets approved
5. Game references updated by canonical ID (no filename changes)

---

## Version Independence

Each layer has independent versioning:

```
Blueprint v14 ──────────────────┐
                                │
Operational Data v3 ────────────┼──→ Prompt Builder v2.0
                                │
Visual Definition v5 ───────────┤
                                │
Material Library v4 ────────────┤
                                │
Icon Bible v2 ──────────────────┤
                                │
Visual Philosophy (stable) ─────┘
                                ↓
                        Prompt Template v3
                                ↓
                        Image Generator v?
                                ↓
                        Asset Registry v?
```

**Key Principle**: When art style evolves, only the Visual Definition and Prompt Template layers change. Blueprint and Operational Data remain untouched.

---

## Error Handling

| Error Type | Action | Recovery |
|-----------|--------|----------|
| Validation error | Reject blueprint, return specific errors | Fix blueprint, re-validate |
| Enrichment failure | Use fallback defaults from Icon Bible | Manual override if needed |
| Prompt generation failure | Log error, retry with simplified prompt | Manual prompt creation |
| Image generation failure | Retry (up to 3x), then flag for manual review | Human-in-the-loop |
| QA rejection | Return specific feedback per check | Fix and regenerate |
| Registry conflict | Alert, prevent duplicate asset IDs | Resolve naming conflict |

---

## Implementation Notes

### PromptBuilder Service (Rails)
```ruby
class PromptBuilderService
  def self.build(blueprint, visual_definition, render_profile)
    # 1. Validate inputs
    validator = BlueprintValidator.new(blueprint, visual_definition)
    raise ValidationError unless validator.valid?
    
    # 2. Enrich with defaults
    enriched = BlueprintEnrichmentService.enrich(validator.blueprint)
    
    # 3. Build prompt from template
    prompt = PromptTemplateService.render(render_profile, enriched)
    
    # 4. Archive prompt
    archive = PromptArchive.create(prompt, enriched)
    
    # 5. Return structured prompt
    {
      text: prompt.text,
      version: prompt.template_version,
      archive_id: archive.id,
      blueprint_version: enriched.blueprint_version
    }
  end
end
```

### Asset Registry Service (Rails)
```ruby
class AssetRegistryService
  def self.register(asset_id, assets_hash, qa_status)
    entry = {
      asset_id: asset_id,
      status: qa_status,
      assets: assets_hash,
      generated_at: Time.current,
      obsolete_assets: []
    }
    
    # Prevent duplicate registration
    raise DuplicateAssetError if exists?(asset_id)
    
    # Archive any previous version of this asset
    archive_previous_versions(asset_id)
    
    entry
  end
  
  def self.regenerate(asset_id, new_visual_definition_version)
    # Mark for regeneration
    mark_eligible_for_regeneration(asset_id)
    
    # Return all render types that need regeneration
    get_render_types_for_regeneration(asset_id)
  end
end
```

---

## Notes

This architecture is **model-agnostic** and **version-independent**. It enables:
- Automated generation of 300+ consistent assets
- Independent evolution of art style without touching simulation data
- Full audit trail from blueprint to game asset
- Regeneration when art style or image models change
- Canonical lookup by ID (not filename)

The pipeline is the bridge between "design philosophy" and "game-ready assets." Every asset flows through it, ensuring consistency at scale.

---

## Current Status

### ✅ Validated Through Production
- [x] Architecture validated through first asset generation (catalog renders)
- [x] Initial catalog renders produced and reviewed
- [x] PromptBuilder philosophy refined based on production experience
- [x] First surface sprites generated (preliminary)
- [x] Human QA process established (transparent backgrounds, pivots, tile seams)

### ✅ Architecture Complete
- [x] Four-source input model (Blueprint + Operational Data + Visual Definition + Design System)
- [x] Asset class distinction (Inspection vs Gameplay) documented
- [x] Provenance tracking in Prompt Archive and Asset Registry
- [x] Location-agnostic principle codified
- [x] Shared components recognized as first-class concept
- [x] Human QA stage with automated pre-filtering defined

### 🔄 In Progress
- [ ] Blueprint schema refinement (visualization section addition)
- [ ] Visual Definition refinement (field completeness, defaults)
- [ ] Prompt template automation (PromptBuilder service implementation)
- [ ] First terrain/biome tile generation using compressed biome spec

### 🔴 Pending
- [ ] Unit sprites regeneration (16 files) — first full design system implementation
- [ ] Corporate logos regeneration (~30 files) — Session 5 + Session 7 specs
- [ ] Terrain Layer 0 tiles (~50+ files) — foundation for surface rendering
- [ ] Biome tiles alignment (14 → ~16 canonical) — Session 10 compression
- [ ] Catalog components regeneration (~200+ files) — Icon Bible hierarchy
