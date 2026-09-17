---
date_created: 2026-08-26
type: PROFILE_COMPOSITION_SPEC
status: active
purpose: Defines the Profile Composition layer — resolves independent profile concerns into structured attributes for PromptBuilder
---

# Profile Composition Specification

**Purpose**: Resolves independent profile concerns (style, manufacturing, technology level, render type) into structured attributes that PromptBuilder substitutes into the Render Template.

**Position in Pipeline**: Sits between Visual Profile (Layer 2) and Visual Definition (Layer 3) in the five-layer dependency chain defined by `ASSET_PROMPT_COMPILER_CONTRACT.md`.

---

## 1. PROFILE TYPES

Each profile type resolves one independent concern. Profiles are **independent concepts** — they do not collapse into a single "asset style."

### 1.1 Global Visual Style Profile

Resolves the Visual Profile's locked attributes into structured style data.

```json
{
  "profile_type": "global_visual_style",
  "profile_id": "grounded_industrial_v1",
  "source_file": "VISUAL_PROFILE_precision_industrial_v1.md",
  "resolved_attributes": {
    "finish": "clean white/light-gray primary paneling over dark gray/black mechanical undercarriage",
    "surface_treatment": "precision-machined surfaces, minimal visible construction seams",
    "aesthetic": "NASA/ESA-inspired aerospace-industrial",
    "markings": {
      "hazard_striping": "black/yellow on moving parts and edges only",
      "unit_id": "stenciled on hull"
    },
    "silhouette_rules": [
      "strong primary silhouette recognizable at 64x64 pixels",
      "functional components dominate the outline",
      "decorative geometry must never obscure recognition"
    ],
    "consistency_rules": [
      "maintain consistent proportions across related vehicles",
      "reuse standardized connectors",
      "reuse standardized access hatches",
      "reuse standardized warning markings",
      "reuse standardized lighting fixtures",
      "reuse standardized sensor packages where appropriate"
    ]
  }
}
```

### 1.2 Manufacturing Style Profile

Resolves manufacturing style into structured attributes from Blueprint + Visual Definition.

```json
{
  "profile_type": "manufacturing_style",
  "profile_id": "earth_factory_v1",
  "source_blueprint_field": "manufacturing_style",
  "source_visual_def_field": "manufacturing_style",
  "resolved_attributes": {
    "method": "precision industrial factory assembly",
    "quality": "factory-assembled, not frontier/bootstrap",
    "materials": [
      "high-strength aerospace steel",
      "aluminum structural members",
      "abrasion-resistant composite panels",
      "sealed hydraulic systems",
      "reinforced rubber tracks"
    ],
    "excluded": [
      "frontier/bootstrap/improvised construction",
      "DMLS or 3D-printed rough surface finish",
      "visible layer lines",
      "exposed reinforcement ribs",
      "regolith-composite or ISRU-derived material appearance"
    ]
  }
}
```

### 1.3 Technology Level Profile

Resolves technology level into structured attributes from Blueprint + Visual Definition + Visual Philosophy.

```json
{
  "profile_type": "technology_level",
  "profile_id": "tl2_v1",
  "source_blueprint_field": "technology_level",
  "source_visual_def_field": "technology_level",
  "resolved_attributes": {
    "level": 2,
    "characteristics": [
      "cleaner than early-generation equipment",
      "fewer visible fasteners",
      "welded joints",
      "slight sheen consistent with factory-assembled aerospace equipment"
    ],
    "excluded": [
      "visible layer lines",
      "3D-printed rough texture",
      "improvised or bootstrap appearance"
    ]
  }
}
```

### 1.4 Render Type Profile

Resolves the Render Template's camera/lighting/background/output rules into structured render requirements.

```json
{
  "profile_type": "render_type",
  "profile_id": "catalog_render_v2",
  "source_file": "PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md",
  "resolved_attributes": {
    "camera": "top-down orthographic (directly above, no perspective distortion)",
    "lighting": "soft neutral studio — cool, even, diffused illumination",
    "background": "transparent (alpha channel)",
    "framing": "75% of canvas",
    "output_format": "PNG, 1024x1024 pixels",
    "prohibitions": [
      "no ground plane",
      "no terrain",
      "no baked shadows beyond subtle contact shadow",
      "no sky",
      "no stars",
      "no environment",
      "no props",
      "no dust effects",
      "no motion blur",
      "no text",
      "no labels",
      "no annotations",
      "no logos",
      "no borders",
      "no watermark"
    ]
  }
}
```

---

## 2. ASSET-SPECIFIC VISUAL HIERARCHY

The composition layer also organizes recognition features into a priority hierarchy from the Visual Definition's `visual_priority` field.

```json
{
  "profile_type": "asset_visual_hierarchy",
  "source_visual_def": "VEHICLE_HARVESTER_ROVER_RH400.json",
  "hierarchy": {
    "primary": [
      "regolith skimming scoop assembly",
      "six-wheel independent suspension chassis"
    ],
    "secondary": [
      "mid-body cylindrical processing canister",
      "top-mounted sensor mast with rotating array"
    ],
    "tertiary": [
      "rear-mounted dust exhaust stack",
      "exposed hydraulic actuator arms on scoop joints"
    ]
  }
}
```

---

## 3. PROPORTION ANCHORS

Numeric proportions are preserved as authoritative data but supplemented with visual anchors for generation instructions.

```json
{
  "profile_type": "proportion_anchors",
  "canonical_dimensions": {
    "length_m": 6.80,
    "width_m": 3.30,
    "height_m": 2.65,
    "ratio_length_to_width": 2.06
  },
  "visual_anchors": [
    "elongated low-slung vehicle",
    "length clearly exceeds width",
    "width remains substantially narrower than overall length",
    "body height remains low relative to footprint"
  ]
}
```

**Rule**: Canonical dimensions are authoritative. Visual anchors are additional generation instructions, NOT replacements for canonical data.

---

## 4. RESOLUTION ORDER

Profiles are resolved in this order:

1. **Global Visual Style** — from the Visual Profile referenced by Blueprint's `visual_profile` field
2. **Manufacturing Style** — from Blueprint's `manufacturing_style` + Visual Definition's `manufacturing_style` (cross-layer validation)
3. **Technology Level** — from Blueprint's `technology_level` + Visual Definition's `technology_level` (cross-layer validation)
4. **Render Type** — from the Render Template being used (pipeline-level choice, not asset data)
5. **Asset-Specific Visual Hierarchy** — from Visual Definition's `visual_priority` field

---

## 5. PRECEDENCE RULES

| Rule | Description |
|------|-------------|
| Blueprint > Visual Profile | If Blueprint and Visual Profile conflict on `technology_level` or `manufacturing_style`, the Blueprint wins |
| Visual Profile locked attributes > all | Locked attributes in the Visual Profile cannot be overridden by any other layer |
| Render Template > asset data | Camera, lighting, background rules come from the Render Template, not from asset data |
| Visual Definition recognition_features > Visual Profile | Recognition features are asset-specific and override generic style guidance in the Visual Profile |

---

## 6. OUTPUT TO PROMPTBUILDER

The composition layer outputs structured attributes (not prose) to PromptBuilder:

```json
{
  "composed_attributes": {
    "global_style": <resolved from profile 1>,
    "manufacturing_style": <resolved from profile 2>,
    "technology_level": <resolved from profile 3>,
    "render_type": <resolved from profile 4>,
    "asset_hierarchy": <resolved from profile 5>,
    "proportion_anchors": <resolved from proportion anchors>
  }
}
```

PromptBuilder receives these structured attributes and substitutes them into the Render Template, producing a hierarchical prompt where:

- Recognition features are ordered by priority tier (primary → secondary → tertiary)
- Each section is self-contained (not mixed prose)
- Style/manufacturing come from resolved profiles (not inlined prose)
- Proportions include both canonical dimensions and visual anchors

---

## 7. REFERENCE IMAGE HANDLING

Approved visual references are a separate input layer to PromptBuilder:

```json
{
  "visual_references": {
    "catalog_render": "data/images/catalog/crafts/ground/rh400_regolith_harvesting_rover.png",
    "engineering_blueprint": "available from RH-400 reference set",
    "multi_view_reference": "available from RH-400 reference set"
  }
}
```

**Rule**: Visual references provide visual guidance but do NOT override canonical data. If a reference conflicts with the Blueprint, the Blueprint wins.
