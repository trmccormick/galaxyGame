# GalaxyGame Production Asset Render Template v1.0

Use this template to generate production-ready game assets for GalaxyGame.

This template defines **how an asset is rendered**. It does **not** define the unit's industrial design language. STYLE, MANUFACTURING, and MATERIALS are inherited from the assigned **Visual Profile** (for example, `precision_industrial_v1`). Only the SUBJECT, FUNCTION, and RECOGNITION_FEATURES sections should vary for individual assets.

---

# SUBJECT

Render a single **{{UNIT_NAME}}** for GalaxyGame.

---

# STYLE

Inherit all STYLE characteristics from the assigned Visual Profile.

Do not reinterpret, improve, modernize, or vary the established manufacturing language.

---

# FUNCTION

{{FUNCTIONAL_ROLE}}

---

# MANUFACTURING

Inherit all MANUFACTURING characteristics from the assigned Visual Profile.

---

# MATERIALS

Inherit all MATERIAL definitions from the assigned Visual Profile.

---

# RECOGNITION FEATURES

{{RECOGNITION_FEATURES}}

---

# RENDER REQUIREMENTS

- Single vehicle or object only
- No duplicate objects
- Entire object visible
- Top-down orthographic camera with no perspective distortion
- Vehicle centered within the image
- **The subject should occupy approximately 75% of the canvas. This framing is intended to maximize production asset quality and is not an indication of real-world scale. Relative in-game size is determined by blueprint physical dimensions and the rendering engine, not by production render framing.**
- Soft neutral studio lighting
- Physically accurate materials
- Moderate detail suitable for production game assets
- Strong, immediately recognizable silhouette
- Slight panel seams and realistic industrial wear where appropriate
- Functional hazard markings permitted where appropriate
- No dramatic cinematic effects

---

# BACKGROUND

- Transparent background
- No terrain
- No ground plane
- No baked-in shadows beyond subtle object contact shadow if required
- No sky
- No stars
- No environment
- No buildings
- No props
- No dust effects
- No motion blur
- No text
- No labels
- No borders
- No watermark

---

# SURFACE MAP COMPATIBILITY

- Single static image per unit
- No directional variants
- No alternate facing versions
- Designed for clean extraction into the GalaxyGame surface-map layer
- Engine compatibility confirmed:
  - Top-down square-grid renderer
  - Engine does not rotate sprites
  - Engine contains no facing or directional field for units

---

# OUTPUT

- Transparent PNG
- 1024×1024 pixels
- Object isolated from background
- Production-quality source asset suitable for sprite extraction and future atlas generation

---

# VARIABLE INPUTS

The following fields are supplied by the PromptBuilder for each asset:

**UNIT_NAME**

{{UNIT_NAME}}

**FUNCTION**

{{FUNCTIONAL_ROLE}}

**RECOGNITION_FEATURES**

{{RECOGNITION_FEATURES}}

---

# VISUAL PROFILE CONTRACT

The assigned Visual Profile supplies all fixed visual language for the asset, including but not limited to:

- Industrial design language
- Manufacturing philosophy
- Material appearance
- Surface finish
- Construction quality
- Color palette
- Standardized connectors
- Standardized markings
- Family resemblance
- Overall engineering character

This template must not redefine or reinterpret any Visual Profile content.

Only the following sections are permitted to vary between assets using the same Visual Profile:

- SUBJECT
- FUNCTION
- RECOGNITION_FEATURES

---

# TEMPLATE EVOLUTION POLICY

This template governs **rendering behavior only**.

If an approved production asset exposes shortcomings in lighting, framing, background isolation, transparency, extraction quality, or other rendering parameters, **fix the template, not the asset**. Improvements should be made to this template so all future assets benefit from a more consistent generation pipeline.

This policy applies **only** to render-template behavior. It **does not** authorize changes to any locked attributes defined by the assigned Visual Profile (for example, `precision_industrial_v1`). Industrial design language, manufacturing philosophy, material appearance, silhouette rules, and other Visual Profile characteristics remain canonical and may only be changed through a formal revision of the Visual Profile itself.