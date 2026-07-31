---
date_created: 2026-07-20
type: VISUAL_DEFINITION_TEMPLATE
status: active
purpose: Canonical template for how objects look (separate from blueprint/operational)
---

# Visual Definition Template — How Objects Look

**Purpose**: Canonical template for visual asset generation. Separate from Blueprint (how to make) and Operational Data (how it behaves).

**Position in Architecture**:
```
Blueprint (manufacturing) + Operational Data (runtime behavior) + Visual Definition (appearance)
        ↓
    Prompt Builder
        ↓
    Asset Generation
```

---

## Template Structure

```json
{
  "visual_definition": {
    "asset_id": "",
    "asset_family": "",
    "component_class": "",
    "recognition_features": [],
    "material_profiles": [],
    "technology_level": 1,
    "manufacturing_style": "",
    "silhouette": "",
    "visual_priority": {
      "primary": [],
      "secondary": [],
      "tertiary": []
    },
    "surface_finish": "",
    "color_profile": {},
    "animation_profile": "",
    "render_profiles": [],
    "camera_profiles": [],
    "complexity_levels": [],
    "shared_components": [],
    "design_constraints": {},
    "prompt_template_refs": {}
  }
}
```

---

## Field Definitions

### asset_id (string, REQUIRED)
Canonical ID for this visual asset. Follows Icon Bible format: `[CATEGORY]_[TYPE]_[NAME]_[VARIANT]`

**Examples**:
- `COMP_PRESSURE_BULKHEAD`
- `UNIT_INFLATABLE_HAB_MK3`
- `VEHICLE_ROVER_LUNAR_MK2`
- `STRUCT_POWER_SOLAR_MK1`

### asset_family (string, REQUIRED)
Which object class this belongs to. Determines which documents are relevant.

**Valid values**: `resource`, `component`, `assembly`, `equipment`, `unit`, `structure`, `vehicle`, `organization`

### component_class (string, REQUIRED for components/units/structures/vehicles)
What type of thing this is within its family. Maps to Icon Bible categories.

**Examples**:
- Component: `structural`, `mechanical`, `electronics`, `production`, `specialized`
- Unit: `extractor`, `habitat`, `fabricator`, `computer`, `battery`, `propulsion`, `storage`, `robot`
- Structure: `power_generation`, `habitation`, `manufacturing`, `resource_extraction`, `science_research`
- Vehicle: `rover`, `harvester`, `ship`, `spaceship`, `satellite`

### recognition_features (array of strings, REQUIRED)
What must be visually present for the asset to be recognizable. These are **descriptive facts**, not prompts.

**Examples**:
```json
"recognition_features": [
  "pill-shaped pressure vessel",
  "forward EVA airlock",
  "rear utility manifold",
  "corridor docking port",
  "inflatable reinforcement ribs"
]
```

**Rules**:
- Each feature is a visual element that must appear in ALL renders
- Describes WHAT is visible, not HOW to render it
- Maps directly to Icon Bible shape language (circle→gas, hex→metal, etc.)
- Enables consistent recognition across all complexity levels

### material_profiles (array of strings, REQUIRED)
Which entries from the Material Library apply. Each string maps to a Material Bible entry.

**Examples**:
```json
"material_profiles": [
  "inflatable_polymer",
  "kevlar_fabric",
  "carbon_nanotube_composite"
]
```

**Material Library entries** (from Icon Bible Section 3):
- Metals: `brushed_aluminum`, `cast_steel`, `polished_titanium`, `anodized_aluminum`, `oxidized_copper`
- Manufactured: `3d_printed_regolith`, `woven_carbon_fiber`, `extruded_plastic`, `inflatable_polymer`, `cast_concrete`
- Advanced: `nanofabricated_composite`, `automated_fusion_welded`
- Natural: `raw_silicon`, `ceramic`, `organic_compounds`
- Electronic: `silicon_wafer`, `copper_trace_patterns`, `led_surface`

### technology_level (integer, REQUIRED)
Tech level (1-5). Maps to Icon Bible Section 4 progression.

**Valid values**: 1, 2, 3, 4, 5

**Visual characteristics per level**:
- Mk1: Simple, painted, bolted, matte finish
- Mk2: Cleaner, welded, slight sheen
- Mk3: Integrated systems, polished, nearly seamless
- Mk4: Futuristic, optimized, iridescent
- Mk5: Otherworldly, elegant, impossible to see how it works

### manufacturing_style (string, REQUIRED)
Which of the 6 manufacturing methods applies. Maps to Icon Bible Section 5 + Session 6 specs.

**Valid values**: `precision_factory`, `additive_construction`, `cast_construction`, `modular_assembly`, `heavy_industrial`, `bootstrap_frontier`

**Visual characteristics per method**:
- Precision Factory: Clean, refined, aerospace-grade, smooth surfaces
- Additive Construction: Layer lines visible, modular appearance
- Cast Construction: Rough, organic flow patterns
- Modular Assembly: Visible fasteners, bolted joints
- Heavy Industrial: Crude, oversized, simple geometry
- Bootstrap Frontier: Improvised, thick members, exposed structure

### silhouette (string, OPTIONAL)
Brief description of the overall shape. Helps generators maintain consistent form across variants.

**Examples**:
- "pill-shaped pressure vessel"
- "boxy rectangular with rounded corners"
- "cylindrical with forward protrusion"
- "triangular wedge profile"

### visual_priority (object, OPTIONAL)
What elements should be emphasized in renders. Helps generators know what details to focus on.

```json
"visual_priority": {
  "primary": ["airlock", "utility manifold"],
  "secondary": ["pressure ribs", "inspection ports"],
  "tertiary": ["fasteners"]
}
```

**Rules**:
- Primary: Must be clearly visible in ALL renders
- Secondary: Visible in detailed renders (L3+)
- Tertiary: Visible only in high-detail renders (L4-L5)

### surface_finish (string, OPTIONAL)
Overall surface treatment. Maps to Material Library + Icon Bible Section 3.

**Valid values**: `brushed`, `polished`, `matte`, `glossy`, `rough`, `satin`, `textured`

### color_profile (object, OPTIONAL)
Color scheme for this asset. Maps to Icon Bible Section 3 color families.

```json
"color_profile": {
  "primary": "#C0C0C0",
  "secondary": "#808080",
  "accent": "#FFD700",
  "background": "transparent"
}
```

**Color families** (from Icon Bible):
- Blue: atmosphere/gas
- Cyan: water/liquid
- Gray: stone/minerals
- Silver: metals/elements
- Orange: fuel/energy
- Yellow: electricity/power
- Green: biology/organic
- Purple: rare/advanced
- Red: waste/hazard
- Brown: manufactured/organic
- Black: carbon/tech
- White: electronics/tech

### animation_profile (string, OPTIONAL)
Which animation category applies. Maps to Icon Bible Section 9.

**Valid values**: `none`, `pulse`, `ripple`, `rotation`, `flicker`, `blink`, `breathe`, `particles`, `glow`, `assembly`

**Animation rules** (from Icon Bible):
- Gases: pulse, 2-3s cycle
- Liquids: ripple, 1-2s cycle
- Solids/minerals: rotation, 4-5s cycle
- Energy/electricity: flicker, 0.3-0.5s cycle
- Electronics: blink, 0.8-1.2s cycle
- Biological: breathe/sway, 2-4s cycle
- Waste/hazard: particles, 1-2s cycle
- Vehicles: status lights, 0.5-1s cycle
- Structures: glow, 1-2s cycle
- Manufacturing: assembly, 2-3s cycle

### render_profiles (array of strings, REQUIRED)
Which render types are needed for this asset. Maps to Icon Bible Section 11 + Session 2 specs.

**Valid values**: `inventory_icon`, `catalog_render`, `engineering_render`, `blueprint`, `exploded_view`, `sprite_sheet`, `animation_reference`

**Render specifications** (from Session 2):
- **inventory_icon**: L0-L1, silhouette only, no text
- **catalog_render**: White background, two isometric views, no annotations
- **engineering_render**: Callouts, dimensions, materials, part numbers
- **blueprint**: Section cuts, exploded diagrams, internal routing
- **exploded_view**: Disassembled components with connection lines
- **sprite_sheet**: All complexity levels (L0-L5) in single sheet
- **animation_reference**: Keyframes for animation generation

### camera_profiles (array of strings, OPTIONAL)
Which camera angles are required. Maps to Session 8 three-angle pattern + Session 2 catalog standards.

**Valid values**: `front_isometric`, `rear_isometric`, `side_profile`, `top_down`, `cross_section`, `detail_view`

**Standard patterns**:
- **Catalog render**: front_isometric + rear_isometric (Session 2)
- **Component detail**: perspective + side_profile + functional_detail (Session 8)
- **Blueprint**: cross_section + exploded_view (Session 6)

### complexity_levels (array of integers, OPTIONAL)
Which complexity levels (L0-L5) are needed. Maps to Icon Bible Section 11.

**Valid values**: 0, 1, 2, 3, 4, 5

**Default**: All levels unless specified otherwise.

### shared_components (array of strings, OPTIONAL)
Canonical asset IDs for components this shares with other assets. Enables consistency across the catalog.

**Examples**:
```json
"shared_components": [
  "COMP_STANDARD_AIRLOCK",
  "COMP_POWER_PORT",
  "COMP_DATA_PORT"
]
```

**Rules**:
- Each entry is a canonical asset ID from the Asset Registry
- All assets sharing a component use the SAME visual asset
- Enables massive consistency gain across the catalog
- Reduces total asset count (no duplicate components)

### design_constraints (object, OPTIONAL)
Project-wide rules that apply to this asset. Maps to Icon Bible acceptance criteria.

```json
"design_constraints": {
  "must_be_recognizable_at_32px": true,
  "must_share_family_appearance": true,
  "must_support_manufacturing_variants": true,
  "must_follow_location_agnostic_naming": true,
  "must_have_animation_profile": false
}
```

**Valid constraints**:
- `must_be_recognizable_at_32px`: Asset must work at L1 (inventory slot size)
- `must_share_family_appearance`: Must visually belong to its family (e.g., all rovers look like same manufacturer)
- `must_support_manufacturing_variants`: Must have visual variants for different manufacturing methods
- `must_follow_location_agnostic_naming`: Asset ID must not include location prefix
- `must_have_animation_profile`: Asset must have an animation (not static)

### prompt_template_refs (object, OPTIONAL)
References to prompt templates for each render type. NOT the prompts themselves — just references.

```json
"prompt_template_refs": {
  "catalog_render": "template_catalog_render_v3",
  "engineering_render": "template_engineering_draw_v2",
  "blueprint": "template_blueprint_v1"
}
```

**Rules**:
- Values are template names, not prompt text
- Template versions tracked separately (PromptBuilder manages)
- Enables prompt evolution without changing blueprints

---

## Object Class Requirements

Different object classes need different documents. This table shows which documents each class owns:

| Object Class | Blueprint | Operational Data | Visual Definition |
|-------------|-----------|-----------------|-------------------|
| **Resource** | Resource Definition | N/A | ✅ Required |
| **Component** | ✅ Required | N/A | ✅ Required |
| **Assembly** | ✅ Required | N/A | ✅ Required |
| **Equipment** | ✅ Required | N/A | ✅ Required |
| **Unit** | ✅ Required | ✅ Required | ✅ Required |
| **Structure** | ✅ Required | ✅ Required | ✅ Required |
| **Vehicle** | ✅ Required | ✅ Required | ✅ Required |
| **Organization** | N/A | N/A | ✅ Required |

### Key Distinctions

**Components/Assemblies**: Blueprint + Visual Definition only. No operational data. They're catalog items, not active game objects.

**Units/Structures/Vehicles**: Blueprint + Operational Data + Visual Definition. These are active game objects with runtime behavior.

**Resources**: Resource Definition + Visual Definition. No blueprint (resources aren't manufactured).

**Organizations**: Visual Definition only. Logos, faction symbols, corporate branding.

---

## Versioning Strategy

```json
"metadata": {
  "schema_version": "2.0",
  "blueprint_version": "14",
  "operational_version": "3",
  "visualization_version": "5"
}
```

**Independent versioning**:
- `schema_version`: Which schema format this file uses (e.g., "2.0")
- `blueprint_version`: Manufacturing spec version (independent of visualization)
- `operational_version`: Runtime behavior version (independent of visualization)
- `visualization_version`: Visual definition version (independent of blueprint/operational)

**Why independent**: Art style evolves faster than simulation. If you change your art pipeline, you don't need to touch the manufacturing or operational data.

---

## Example: Inflatable Habitat

```json
{
  "visual_definition": {
    "asset_id": "UNIT_INFLATABLE_HAB_MK3",
    "asset_family": "unit",
    "component_class": "habitat",
    "recognition_features": [
      "pill-shaped inflatable pressure vessel",
      "forward EVA airlock",
      "rear utility manifold",
      "corridor connection port",
      "inflatable reinforcement ribs"
    ],
    "material_profiles": [
      "inflatable_polymer",
      "kevlar_fabric"
    ],
    "technology_level": 3,
    "manufacturing_style": "precision_factory",
    "silhouette": "pill-shaped pressure vessel with forward protrusion",
    "visual_priority": {
      "primary": ["airlock", "utility manifold"],
      "secondary": ["pressure ribs", "inspection ports"],
      "tertiary": ["fasteners"]
    },
    "surface_finish": "matte",
    "color_profile": {
      "primary": "#F5F5DC",
      "secondary": "#C0C0C0",
      "accent": "#4169E1",
      "background": "transparent"
    },
    "animation_profile": "glow",
    "render_profiles": [
      "inventory_icon",
      "catalog_render",
      "engineering_render",
      "blueprint",
      "exploded_view"
    ],
    "camera_profiles": [
      "front_isometric",
      "rear_isometric",
      "side_profile",
      "detail_view"
    ],
    "complexity_levels": [0, 1, 2, 3, 4],
    "shared_components": [
      "COMP_STANDARD_AIRLOCK",
      "COMP_POWER_PORT",
      "COMP_DATA_PORT"
    ],
    "design_constraints": {
      "must_be_recognizable_at_32px": true,
      "must_share_family_appearance": true,
      "must_support_manufacturing_variants": true,
      "must_follow_location_agnostic_naming": true,
      "must_have_animation_profile": true
    },
    "prompt_template_refs": {
      "catalog_render": "template_catalog_render_v3",
      "engineering_render": "template_engineering_draw_v2",
      "blueprint": "template_blueprint_v1"
    }
  }
}
```

---

## Example: Pressure Bulkhead (Component)

```json
{
  "visual_definition": {
    "asset_id": "COMP_PRESSURE_BULKHEAD",
    "asset_family": "component",
    "component_class": "structural",
    "recognition_features": [
      "cylindrical pressure vessel",
      "flanged connection ends",
      "weld seam visible along length",
      "inspection port on side"
    ],
    "material_profiles": [
      "cast_steel",
      "brushed_aluminum"
    ],
    "technology_level": 2,
    "manufacturing_style": "modular_assembly",
    "silhouette": "cylindrical with flanged ends",
    "visual_priority": {
      "primary": ["flanges", "weld seam"],
      "secondary": ["inspection port"],
      "tertiary": ["fasteners"]
    },
    "surface_finish": "rough",
    "color_profile": {
      "primary": "#808080",
      "secondary": "#A9A9A9",
      "accent": "#696969",
      "background": "transparent"
    },
    "animation_profile": "none",
    "render_profiles": [
      "inventory_icon",
      "catalog_render",
      "engineering_render",
      "blueprint"
    ],
    "camera_profiles": [
      "front_isometric",
      "side_profile",
      "cross_section"
    ],
    "complexity_levels": [0, 1, 2, 3],
    "shared_components": [],
    "design_constraints": {
      "must_be_recognizable_at_32px": true,
      "must_share_family_appearance": true,
      "must_support_manufacturing_variants": true,
      "must_follow_location_agnostic_naming": true,
      "must_have_animation_profile": false
    },
    "prompt_template_refs": {
      "catalog_render": "template_catalog_render_v3",
      "engineering_render": "template_engineering_draw_v2"
    }
  }
}
```

---

## Notes

This template is the **bridge between simulation and art**. It contains:
- Descriptive facts (not prompts) that define what an asset looks like
- References to Material Library, Icon Bible, and Prompt Templates
- Version-independent fields that evolve separately from blueprint/operational data
- Shared component references for catalog-wide consistency

**What it does NOT contain**:
- Manufacturing specs (that's the Blueprint)
- Runtime behavior (that's Operational Data)
- Actual prompt text (that's PromptBuilder's job)
- Simulation parameters (that's the simulation layer)

This keeps concerns properly separated while providing all information needed for consistent asset generation.
