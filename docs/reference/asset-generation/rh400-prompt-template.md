# Galaxy Game Asset Generation Prompt Template

**Version:** 1.0  
**Date:** 2026-07-24  
**Purpose:** Parameterized prompt template for generating consistent Galaxy Game assets from blueprint/operational JSON data.

---

## Watch For (From RH-400 Lessons)

1. **Confirm JSON dimensions BEFORE generating anything, not after.** Regenerating art to match data is cheaper than updating data to match unverified art.
2. **Always request a plain white/transparent background explicitly**, since composite sheets default to baking in a ground/environment.

---

## Template Structure

```
[Context] Galaxy Game: industrial space settlement simulation, hard-sci-fi aesthetic, clean utilitarian engineering.
[Asset Name] {{name}} ({{id}})
[Physical Specs] Length: {{length_m}}m | Width: {{width_m}}m | Height: {{height_m}}m | Mass: {{empty_mass_kg}}kg
[Manufacturing Tier] {{tier/aesthetic notes — reuse RH-400 series look: white/dark-grey hull, hazard stripes, exposed tracks/heavy chassis, DMLS matte industrial finish}}
```

---

## Three-Pass Output Structure

### Pass 1 — 3D/Orthographic Render (Transparent Background)

**Purpose:** Feeds surface sprites, animation frames, and damage-state assets.

**Prompt template:**
```
[Context] Galaxy Game: industrial space settlement simulation, hard-sci-fi aesthetic, clean utilitarian engineering.
[Asset Name] {{name}} ({{id}})
[Physical Specs] Length: {{length_m}}m | Width: {{width_m}}m | Height: {{height_m}}m | Mass: {{empty_mass_kg}}kg
[Aesthetic] {{tier/aesthetic notes — RH-400 series: white/dark-grey hull, hazard stripes, exposed tracks/heavy chassis, DMLS matte industrial finish}}

Generate a transparent-background (alpha channel) image of this asset.
Request multiple angles: front elevation, rear elevation, side profile, isometric view.
Each angle must be fully framed with consistent padding — no cropping.
Lighting: cool, even, diffused studio lighting. No baked ground or environment shadows.
Style: hard sci-fi industrial, grounded engineering realism.
```

### Pass 2 — Blueprint/Dimensioned View (White Background)

**Purpose:** Geometrically locked to Pass 1 proportions. Same orthogonal angles with gridlines and dimension callouts.

**Prompt template:**
```
[Context] Galaxy Game: industrial space settlement simulation, hard-sci-fi aesthetic, clean utilitarian engineering.
[Asset Name] {{name}} ({{id}})
[Physical Specs] Length: {{length_m}}m | Width: {{width_m}}m | Height: {{height_m}}m | Mass: {{empty_mass_kg}}kg

Generate a dimensioned blueprint view on a plain white background.
Same orthogonal angles as Pass 1 (front, rear, side, isometric).
Include gridlines, dimension callouts matching the physical specs above.
Style: technical engineering drawing, clean lines, monochrome with accent color for dimensions.
```

### Pass 3 — Catalog/UI Compositing (In-App)

**Purpose:** Assembled in Rails/frontend from Pass 1 hero render + blueprint thumbnail + live sprites into the UI card. NOT requested from the image generator as a single sheet.

**Note:** This pass is handled by the application layer, not the image generation pipeline. The frontend assembles:
- Hero render from Pass 1 (transparent background)
- Blueprint thumbnail from Pass 2
- Live sprite variants from animation/damage states (also from Pass 1 source)

---

## Critical Rules

1. **Sprite/animation/damage-state assets must always come from Pass 1** (transparent background), never cropped from a composite catalog sheet. This is the rule Tasks 1–2 exist to fix retroactively.
2. **Dimensions in the prompt are constraints, not suggestions.** The generated asset must match the physical specs exactly — proportions matter for surface map layer compatibility.
3. **Background must be explicitly transparent or white.** Never accept a composite sheet with baked-in ground/terrain/environment.

---

## Parameter Source

All `{{variables}}` above come directly from the unit's blueprint JSON:
- `name` → `blueprint.name`
- `id` → `blueprint.id`
- `length_m`, `width_m`, `height_m`, `empty_mass_kg` → `blueprint.physical_properties.*`
- `tier/aesthetic` → derived from `blueprint.category` + `blueprint.type`
