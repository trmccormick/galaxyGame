# Asset Generation Pipeline — Development-Time Tooling

## Overview

This directory contains the **development-time asset generation pipeline** — a suite of Ruby tooling that walks the five-layer dependency chain to produce renderer-neutral prompts for AI image generation.

**This is NOT game runtime code.** It is an authoring workflow tool used during development to generate consistent visual assets for the game.

## Architecture

### Five-Layer Dependency Chain

```
1. Blueprint (JSON)          → Canonical asset definition
2. Visual Profile (MD)       → Locked aesthetic attributes
3. Visual Definition (JSON)  → Recognition features & specs
4. Operational Data (JSON)   → Functional role & flags
5. Render Template (MD)      → Camera/lighting/background/output rules
```

### Pipeline Stages

```
┌─────────────────────┐
│ ProfileResolution   │ Layer 1: Resolve visual profile from locked attributes
│ Engine              │ + cross-validate with blueprint/visual definition
└──────────┬──────────┘
           │ profile_attributes
           ▼
┌─────────────────────┐
│ CompositionRefinery │ Layer 2: Compose prompt sections from all layers
│                     │ + apply targeted refinements & safeguards
└──────────┬──────────┘
           │ composed_sections
           ▼
┌─────────────────────┐
│ PromptCompiler      │ Layer 3: Substitute sections into render template
│                     │ + produce FROZEN prompt with provenance header
└──────────┬──────────┘
           │
           ▼
    Generated Prompt
   (with provenance)
```

## Usage

### Basic Compilation

```ruby
require_relative 'prompt_compiler'

result = AssetGeneration::PromptCompiler.compile(
  asset_id: "regolith_harvester_rover",
  blueprint_path: Pathname.new("data/json-data/blueprints/crafts/ground/regolith_harvesting_rover_bp.json"),
  operational_data_path: Pathname.new("data/json-data/operational_data/crafts/ground/regolith_harvesting_rover_data.json"),
  visual_definition_path: Pathname.new("docs/reference/asset-generation/visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json"),
  render_template_path: Pathname.new("docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md")
)

puts result[:prompt_text]
puts "Provenance: #{result[:provenance]}"
```

### With Refinements & Safeguards

```ruby
result = AssetGeneration::PromptCompiler.compile(
  asset_id: "regolith_harvester_rover",
  blueprint_path: Pathname.new("data/json-data/blueprints/crafts/ground/regolith_harvesting_rover_bp.json"),
  operational_data_path: Pathname.new("data/json-data/operational_data/crafts/ground/regolith_harvesting_rover_data.json"),
  visual_definition_path: Pathname.new("docs/reference/asset-generation/visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json"),
  render_template_path: Pathname.new("docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md"),
  targeted_refinements_config: {
    enabled: true,
    hex_color_ranges: [
      { zone: "body_panels", range: "#E8E6E1 to #D4D0C8" }
    ]
  },
  safeguards_config: {
    enabled: true,
    camera_precedence: true,
    autonomous_protection: true
  }
)
```

### Running Tests

```bash
cd tools/asset_generation
bundle exec rspec spec/
```

## Source Files

### Input (Canonical Data)

| Layer | Format | Location Pattern |
|-------|--------|-----------------|
| Blueprint | JSON | `data/json-data/blueprints/crafts/{ground|air|space}/{name}_bp.json` |
| Visual Profile | Markdown | `docs/reference/asset-generation/VISUAL_PROFILE_{name}.md` |
| Visual Definition | JSON | `docs/reference/asset-generation/visual_definitions/{ASSET}_{name}.json` |
| Operational Data | JSON | `data/json-data/operational_data/crafts/{ground|air|space}/{name}_data.json` |
| Render Template | Markdown | `docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` |

### Tooling (This Directory)

| File | Purpose |
|------|---------|
| `profile_resolution_engine.rb` | Layer 1: Resolve visual profile from locked attributes |
| `composition_refinery.rb` | Layer 2: Compose prompt sections from all layers |
| `prompt_compiler.rb` | Layer 3: Produce FROZEN prompt with provenance header |

### Tests

| File | Purpose |
|------|---------|
| `spec/profile_resolution_engine_spec.rb` | Layer 1 tests |
| `spec/composition_refinery_spec.rb` | Layer 2 tests |
| `spec/prompt_compiler_spec.rb` | Layer 3 integration tests |

## Output Format

The compiler produces a Hash with:

```ruby
{
  prompt_text: "String — FROZEN prompt with provenance header",
  provenance: {
    asset_id: "regolith_harvester_rover",
    blueprint_version: "2.1",
    visual_profile: "precision_industrial_v1",
    visual_definition_asset_id: "VEHICLE_HARVESTER_ROVER_RH400",
    render_template: "PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0",
    composition_method: "profile_composition_v1",
    targeted_refinements: "enabled",
    safeguards: "none",
    generated_at: "2026-01-15T10:30:00Z",
    prompt_version: 1,
    status: "FROZEN"
  },
  validation_errors: [],      # Empty if compilation succeeded
  validation_warnings: []     # Non-empty if warnings were generated
}
```

## Design Principles

1. **Development-time only** — Never loaded at game runtime
2. **Direct file reads** — No CatalogService, no Rails dependencies
3. **Deterministic** — Same inputs always produce same outputs
4. **FROZEN prompts** — Generated prompts are immutable once produced
5. **Provenance tracking** — Every prompt includes full metadata trail
6. **Renderer-neutral** — Output works with any AI image generator

## Runtime Boundary

| Component | Location | Runtime? |
|-----------|----------|----------|
| Asset Generation Pipeline | `tools/asset_generation/` | NO — Development tooling |
| Game Data Lookups | `galaxy_game/app/services/lookups/` | YES — Game runtime |
| Game Services | `galaxy_game/app/services/` | YES — Game runtime |

**Documentation is NOT mounted into Docker.** The pipeline reads docs/ directly from the host filesystem.

## Visual Profile Reference

Current locked profiles:

- `precision_industrial_v1` — NASA/ESA aerospace-industrial aesthetic
- `tl2_v1` — Technology Level 2 characteristics
- `earth_factory_v1` — Earth-based factory manufacturing
