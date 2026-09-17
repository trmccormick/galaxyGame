# I-Beam Mk1 Generation Evaluation Rubric

**Test**: ChatGPT vs Gemini — controlled generation comparison
**Subject**: 3D-Printed I-Beam Mk1 (structural component)
**Source**: `data/json-data/blueprints/components/structural/3d_printed_ibeam_mk1_bp.json` (v1.3) + v1.4 migration
**Status**: FROZEN — use for both ChatGPT and Gemini outputs

---

## Evaluation Question

> Can the same structured specification produce recognizably equivalent representations across different image-generation systems?

This is NOT a "which image looks prettier" test. The question is whether two independent generators, given identical specifications derived from the same blueprint data, produce outputs that are visually coherent and stylistically compatible.

---

## Rubric

Each criterion scored on a 5-point scale:
- **5** — Fully meets requirement
- **4** — Mostly meets requirement with minor deviation
- **3** — Partially meets requirement with noticeable deviation
- **2** — Significantly deviates from requirement
- **1** — Fails to meet requirement

### A. Structural / Overall Geometry

| Score | Criteria |
|-------|----------|
| 5 | I-beam silhouette is immediately recognizable; flanges and web plate are clearly visible in correct proportion |
| 4 | I-beam silhouette recognizable but proportions slightly off (e.g., flanges too narrow/wide) |
| 3 | I-shape present but ambiguous — could be confused with other structural profiles |
| 2 | Structural form is unclear or distorted |
| 1 | Object does not resemble an I-beam at all |

**Blueprint basis**: `name` = "3D-Printed I-Beam" + `category` = structural → standard I-beam cross-section with flanged top/bottom edges and connecting web plate.

### B. I-Beam Identity

| Score | Criteria |
|-------|----------|
| 5 | I-shaped cross-section is unmistakable from any viewing angle shown |
| 4 | I-shape visible but could be misidentified at small scale |
| 3 | Some I-beam characteristics present but not dominant |
| 2 | I-beam identity is weak or ambiguous |
| 1 | No recognizable I-beam characteristics |

**Blueprint basis**: Name explicitly identifies the object as an I-beam — a standard structural shape.

### C. Material Appearance

| Score | Criteria |
|-------|----------|
| 5 | Surface clearly reads as sintered regolith composite — granular, matte, dark gray-brown, rough/porous |
| 4 | Material reads as regolith-like but surface quality is slightly too smooth or too uniform |
| 3 | Material has some regolith characteristics but also reads as other materials (concrete, stone, etc.) |
| 2 | Material appearance is ambiguous — could be metal, plastic, wood, or many other materials |
| 1 | Material appearance contradicts sintered regolith (e.g., polished, glossy, metallic sheen) |

**Blueprint basis**: `description` = "molten lunar regolith... heat sintering and melting" + `material` = regolith → granular matte surface, not polished metal or smooth plastic.

### D. Additive / Sintered Manufacturing Cues

| Score | Criteria |
|-------|----------|
| 5 | Manufacturing process is clearly communicated — visible layer lines, sintering texture, no binder appearance |
| 4 | Manufacturing cues present but subtle — layer lines visible upon close inspection |
| 3 | Some manufacturing evidence but not dominant — could be cast or machined |
| 2 | Manufacturing process is ambiguous |
| 1 | No manufacturing cues — appears as a generic object with no production history |

**Blueprint basis**: `description` = "No external binder required, relying on heat sintering and melting of regolith" + `required_technology` = regolith_3d_printing → additive construction with visible layer lines.

### E. Layer Structure

| Score | Criteria |
|-------|----------|
| 5 | Prominent horizontal layer lines running the full length — clearly first-generation Mk1 print quality |
| 4 | Layer lines visible but not prominent enough for "first-generation" characterization |
| 3 | Some layer structure present but inconsistent or too subtle |
| 2 | Layer lines barely visible or absent |
| 1 | No layer structure — surface appears uniform or machined |

**Blueprint basis**: VISUAL_PHILOSOPHY.md Mk1 = "visible layer lines" + `material_efficiency` = 0.92 (8% waste → early-stage tolerances).

### F. Surface Consistency

| Score | Criteria |
|-------|----------|
| 5 | Surface texture is consistent across all visible faces — uniform granular matte throughout |
| 4 | Surface mostly consistent with minor variations in texture density |
| 3 | Surface has noticeable inconsistencies — some areas too smooth, others too rough |
| 2 | Surface texture varies significantly between faces in ways not explained by lighting |
| 1 | Surface is chaotic or inconsistent to the point of appearing broken |

**Blueprint basis**: Single material (regolith) + single process (heat sintering) → uniform surface treatment expected.

### G. Absence of Unsupported Environmental / Context Elements

| Score | Criteria |
|-------|----------|
| 5 | Completely isolated — no ground plane, terrain, sky, stars, environment, props, or contextual elements |
| 4 | Mostly isolated with minor environmental artifacts (e.g., subtle contact shadow is acceptable) |
| 3 | Some unwanted context elements present but not dominant |
| 2 | Significant environmental context that distracts from the object |
| 1 | Object is embedded in a scene — cannot be extracted as a production asset |

**Blueprint basis**: PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 prohibition list: "No ground plane, no terrain, no sky, no stars, no environment, no props."

### H. Adherence to Known Blueprint Characteristics

| Score | Criteria |
|-------|----------|
| 5 | All known blueprint characteristics are present and accurate (I-shape, regolith appearance, layer lines, heavy/infrastructure impression) |
| 4 | Most blueprint characteristics present; one minor characteristic missing or slightly off |
| 3 | Several blueprint characteristics present but some are missing or contradicted |
| 2 | Few blueprint characteristics are accurately represented |
| 1 | Output contradicts multiple known blueprint characteristics |

**Blueprint basis**: All facts from §2 of the generation test specification.

### I. Unwanted Invented Details

| Score | Criteria |
|-------|----------|
| 5 | No invented details — all visible features are consistent with or derivable from the blueprint |
| 4 | Minor invented details that do not contradict the blueprint (e.g., extra bolts, minor surface variations) |
| 3 | Several invented details present but none fundamentally contradictory |
| 2 | Significant invented details that contradict the blueprint (e.g., white paneling, hazard striping, precision-machined surfaces) |
| 1 | Output contains major invented features that contradict the blueprint's manufacturing process |

**Blueprint basis**: The Mk1 blueprint specifies NO external binder, NO white paneling, NO hazard striping, NO precision machining. Any such features are inventions not supported by the data.

### J. Asset Isolation / Presentation

| Score | Criteria |
|-------|----------|
| 5 | Object is fully visible, centered, ~75% of frame, clean isolation suitable for production use |
| 4 | Object is well-presented but framing is slightly off (too small or too large) |
| 3 | Object is visible but presentation has issues (cropping, poor centering, excessive padding) |
| 2 | Presentation significantly detracts from the object |
| 1 | Object is not usable as a production asset (cropped, obscured, or poorly framed) |

**Blueprint basis**: PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0: "Object centered within the canvas, occupying approximately 75% of the frame."

### K. Repeatability (within same generator)

| Score | Criteria |
|-------|----------|
| 5 | Two generations from the same generator produce highly consistent results |
| 4 | Two generations are similar with minor variations |
| 3 | Two generations show noticeable differences in key characteristics |
| 2 | Two generations are significantly different |
| 1 | Two generations are essentially different objects |

**Test method**: Run the prompt twice from the same generator. Compare outputs for consistency of I-shape, material appearance, layer lines, and framing.

### L. Cross-Model Consistency (ChatGPT vs Gemini)

| Score | Criteria |
|-------|----------|
| 5 | ChatGPT and Gemini produce visually equivalent results — same silhouette, material appearance, and manufacturing cues |
| 4 | Results are similar with minor differences in texture detail or color interpretation |
| 3 | Results share core characteristics but differ noticeably in one or more areas |
| 2 | Results have significant divergences in key visual characteristics |
| 1 | Results are fundamentally different objects |

**Test method**: Compare ChatGPT output against Gemini output using criteria A-J. Score based on the number and severity of divergences.

---

## Scoring Summary Template

| Criterion | ChatGPT Score | Gemini Score | Divergence Noted? |
|-----------|--------------|-------------|-------------------|
| A. Structural/Overall Geometry | | | |
| B. I-Beam Identity | | | |
| C. Material Appearance | | | |
| D. Additive/Sintered Manufacturing Cues | | | |
| E. Layer Structure | | | |
| F. Surface Consistency | | | |
| G. Absence of Unsupported Context | | | |
| H. Adherence to Blueprint Characteristics | | | |
| I. Unwanted Invented Details | | | |
| J. Asset Isolation/Presentation | | | |
| K. Repeatability (within generator) | | | |
| L. Cross-Model Consistency | | | |

**Total ChatGPT Score**: ___ / 50 (excluding K, which is intra-generator)
**Total Gemini Score**: ___ / 50 (excluding K, which is intra-generator)
**Cross-Model Consistency Score**: ___ / 5

---

## Divergence Recording Protocol

If ChatGPT and Gemini diverge on any criterion:

1. **Record the divergence** — describe exactly what each generator produced differently
2. **Identify the source** — is the divergence in the prompt (ambiguous wording), the blueprint (missing data), or the generator (interpretation difference)?
3. **Do NOT rewrite the prompt to make them agree** — the divergence IS the finding
4. **Classify the divergence**:
   - **Specification gap**: The prompt doesn't specify enough → note for future spec refinement
   - **Blueprint gap**: The blueprint doesn't provide enough data → note as blueprint enhancement opportunity
   - **Generator interpretation**: Both outputs are valid interpretations of ambiguous input → acceptable finding

---

## FROZEN STATUS

This rubric is FROZEN as of 2026-08-25. Do not modify criteria or scoring after the initial generation run. If the rubric reveals gaps in the specification, record them for future refinement — do not retroactively change the rubric to match the results.
