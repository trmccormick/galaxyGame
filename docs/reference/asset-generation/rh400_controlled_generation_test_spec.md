---
date_created: 2026-08-25
type: GENERATION_TEST_SPECIFICATION
status: FROZEN (2026-08-25)
subject: regolith_harvester_rover (RH-400)
purpose: Controlled generation test — compare ChatGPT vs Gemini output for a higher-complexity vehicle asset against data-driven specification
test_question: "Can the same structured specification produce recognizably equivalent representations across ChatGPT and Gemini when asset complexity increases substantially?"
frozen: true
frozen_date: 2026-08-25
---

# Controlled Generation Test Specification — RH-400 Regolith Harvester Rover

## Executive Summary

This document produces a controlled generation specification for `regolith_harvester_rover` (RH-400) to test whether the prompt-generation methodology validated by the Mk1 I-beam Run 01/Run 02 tests continues to work when asset complexity increases substantially. The RH-400 is intentionally a higher-complexity test: it contains more geometry, mechanical systems, materials, proportions, and functional details than the single-object I-beam.

**This is a test of methodology scalability, not an opportunity to redesign the RH-400.** No canonical data will be modified. Existing generated imagery is treated as visual reference only unless explicitly established by a canonical document.

---

## 1. SOURCE FILES EXAMINED

### Authoritative Blueprint Data (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 1 | `regolith_harvester_rover_bp.json` | `data/json-data/blueprints/crafts/ground/` | **AUTHORITATIVE** — v2.1, base_craft_v1.6 |

### Operational Data (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 2 | `regolith_harvesting_rover_data.json` | `data/json-data/operational_data/crafts/ground/` | **AUTHORITATIVE** — v2.1, craft_operational_data_v1.7 |

### Visual Definition (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 3 | `VEHICLE_HARVESTER_ROVER_RH400.json` | `docs/reference/asset-generation/visual_definitions/` | **AUTHORITATIVE** — pilot unit, active status |

### Visual Profile (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 4 | `VISUAL_PROFILE_precision_industrial_v1.md` | `docs/reference/asset-generation/` | **AUTHORITATIVE** — RH-400 is the canonical reference for this profile |

### Design Philosophy (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 5 | `VISUAL_PHILOSOPHY.md` | `docs/reference/asset-generation/` | **AUTHORITATIVE** — 9 foundational principles |

### Render Template (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 6 | `PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | `docs/reference/asset-generation/` | **AUTHORITATIVE** — governs rendering behavior only |

### Prompt Template (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 7 | `rh400-prompt-template.md` | `docs/reference/asset-generation/` | **AUTHORITATIVE** — three-pass output structure, RH-400-specific lessons |

### Visual Definition Template (on disk)
| # | File | Path | Status |
|---|------|------|--------|
| 8 | `VISUAL_DEFINITION_TEMPLATE.md` | `docs/reference/asset-generation/` | **AUTHORITATIVE** — template structure for visual definitions |

### Existing Visual References (NOT canonical geometry)
| # | File | Path | Notes |
|---|------|------|-------|
| 9 | `regolith_harvesting_rover.png` | `data/images/catalog/crafts/ground/` | **Visual reference only** — prior catalog render. Silhouette, proportions, and material language are locked per VISUAL_PROFILE_precision_industrial_v1.md but the image itself is NOT canonical geometry. |

---

## 2. CANONICAL RH-400 DATA — BLUEPRINT FACTS ONLY

### Source: `regolith_harvester_rover_bp.json` (v2.1) + `regolith_harvesting_rover_data.json` (v2.1)

| Field | Value | Prompt Relevance |
|-------|-------|-----------------|
| **id** | `regolith_harvester_rover` | Asset identifier |
| **name** | "RH-400 Regolith Harvester Rover" | Asset name |
| **description** | "A heavy-duty mobile industrial craft designed to skim planetary surfaces and gather regolith for ISRU processing." | Functional role |
| **category** | `harvester` | Component class |
| **type** | `craft` / `vehicle` | Scale class |
| **length_m** | 6.80 | Physical dimension — proportion constraint |
| **width_m** | 3.30 | Physical dimension — proportion constraint |
| **height_m** | 2.65 | Physical dimension — proportion constraint |
| **empty_mass_kg** | 22,800 | Mass impression (heavy industrial) |
| **volume_m3** | 59.5 | Volume constraint |
| **drag_coefficient** | 0.9 | Aerodynamic property — NOT visible in static asset render |
| **crew_capacity** | 0 | Autonomous vehicle — no cockpit, no human-scale features |
| **maintenance_time_hours** | 6 | Indicates modular repairability (design philosophy) |
| **repair_cost_gcc** | 1,500 | Game data — NOT visible in render |
| **materials_needed_for_repair** | steel 450kg, electronics 100kg | Indicates steel/electronics material presence |
| **blueprint materials** | aluminum 4,200kg, electronics 850kg, steel 9,500kg | Material composition — steel is dominant (67% by mass) |
| **assembly_time** | 12,000 (hours) | Manufacturing complexity indicator |
| **research_required** | "Surface Harvesting Technology" | Tech level context |
| **autonomous** | true | No human operator features needed |
| **human_rated** | false | Confirms no cockpit/egress systems |
| **power_consumption_kw** | 25.0 | Power system presence (indicates electrical infrastructure) |
| **maintenance_interval_hours** | 250 | Indicates robust, low-maintenance design |
| **efficiency** | 1.0 | Game data — NOT visible in render |
| **output_resources** | regolith 1,500 kg/hr, rare_minerals 75 kg/hr | Functional role (harvesting) |
| **waste_heat_kw** | 8.0 | Thermal management presence (indicates heat dissipation features) |
| **deployment_locations** | lunar_surface, mars_surface, asteroid_surface | Location-agnostic by design |

### Visual Definition Facts (from `VEHICLE_HARVESTER_ROVER_RH400.json`)

| Field | Value | Prompt Relevance |
|-------|-------|-----------------|
| **asset_id** | `VEHICLE_HARVESTER_ROVER_RH400` | Canonical ID |
| **recognition_features** | 6 structured features (see below) | Must be visually present |
| **technology_level** | 2 (Mk2) | Tech level = "cleaner, welded, slight sheen" per VISUAL_PHILOSOPHY.md |
| **manufacturing_style** | `heavy_industrial` | Design System canonical value: "crude, oversized, simple geometry" |
| **silhouette** | "low-profile rectangular chassis with forward scoop protrusion and rear exhaust stack; six visible drive wheels create distinctive segmented undercarriage outline" | Silhouette rules per VISUAL_PROFILE_precision_industrial_v1.md |
| **visual_priority.primary** | regolith skimming scoop assembly, six-wheel suspension chassis | Must be dominant in render |
| **visual_priority.secondary** | mid-body processing canister, sensor mast with rotating array | Must be clearly visible |
| **visual_priority.tertiary** | hydraulic actuator joints, exhaust stack fins | Should be present but not dominant |
| **visual_identity.feel** | heavy, industrial, rugged, modular, repairable | Overall impression |
| **surface_finish** | matte | Surface treatment |
| **material_profiles** | cast_steel, anodized_aluminum, oxidized_copper, 3d_printed_regolith | Material palette |
| **animation_profile** | `vehicles_status_lights` | Not relevant for static production render |
| **design_constraints.must_be_recognizable_at_32px** | true | Silhouette must be strong |
| **physical_specs_reference** | length 6.80m, width 3.30m, height 2.65m, empty_mass 22,800kg, volume 59.5m³ | Proportion constraints |

### Recognition Features (from Visual Definition — structured array)

1. Six-wheel independent suspension chassis
2. Forward regolith skimming scoop assembly
3. Mid-body cylindrical processing canister
4. Rear-mounted dust exhaust stack
5. Top-mounted sensor mast with rotating array
6. Exposed hydraulic actuator arms on scoop joints

### Visual Profile Locked Attributes (from `VISUAL_PROFILE_precision_industrial_v1.md`)

| Attribute | Value |
|-----------|-------|
| **Typical Manufacturing Method** | Precision industrial factories (descriptive, not prescriptive) |
| **Materials** | high-strength aerospace steel, aluminum structural members, abrasion-resistant composite panels, sealed hydraulic systems, reinforced rubber tracks |
| **Finish** | clean white/light-gray primary paneling over dark gray/black mechanical undercarriage, precision-machined surfaces, minimal visible construction seams — NASA/ESA-inspired aerospace-industrial aesthetic |
| **Markings** | black/yellow hazard striping used functionally (moving parts, edges only), unit ID stenciled on the hull |
| **Overall impression** | purpose-built, factory-assembled, clean industrial |

### Explicitly Excluded from This Profile

- Frontier / bootstrap / improvised-construction language
- DMLS or 3D-printed rough surface finish, visible layer lines, exposed reinforcement ribs
- Regolith-composite or ISRU-derived material appearance

---

## 3. DERIVED VISUAL REQUIREMENTS

### From Blueprint + Visual Definition + Visual Profile

| Requirement | Derivation Source |
|------------|------------------|
| **Low-profile rectangular chassis** | Silhouette description from Visual Definition |
| **Forward scoop protrusion** | Recognition feature #2 + silhouette description |
| **Rear exhaust stack** | Recognition feature #4 + waste_heat_kw = 8.0 (thermal management) |
| **Six visible drive wheels** | Recognition feature #1 + silhouette description |
| **Mid-body cylindrical canister** | Recognition feature #3 + volume_m3 = 59.5 (processing capacity) |
| **Top-mounted sensor mast with rotating array** | Recognition feature #5 |
| **Exposed hydraulic actuator arms on scoop joints** | Recognition feature #6 |
| **White/light-gray primary paneling over dark gray/black undercarriage** | VISUAL_PROFILE_precision_industrial_v1.md finish specification |
| **Precision-machined surfaces, minimal visible seams** | VISUAL_PROFILE_precision_industrial_v1.md finish specification |
| **Black/yellow hazard striping on moving parts and edges** | VISUAL_PROFILE_precision_industrial_v1.md markings specification |
| **Unit ID stenciled on hull** | VISUAL_PROFILE_precision_industrial_v1.md markings specification |
| **Tech level Mk2: cleaner, fewer visible fasteners, welded joints, slight sheen** | VISUAL_PHILOSOPHY.md tech level progression + Visual Definition technology_level = 2 |
| **Heavy industrial feel (crude, oversized, simple geometry)** | Visual Definition manufacturing_style = heavy_industrial |
| **Modular, repairable appearance** | visual_identity.feel + maintenance_time_hours = 6 (modular repair) |
| **Steel-dominant material composition (67% by mass)** | Blueprint materials: steel 9,500kg / total 13,700kg ≈ 67% |
| **No cockpit, no human-scale features** | crew_capacity = 0 + autonomous = true + human_rated = false |

### Derived Color Requirements (from Visual Profile)

The VISUAL_PROFILE_precision_industrial_v1.md specifies:
- **Primary paneling**: "clean white/light-gray"
- **Mechanical undercarriage**: "dark gray/black"
- **Hazard striping**: "black/yellow"
- **Unit ID**: stenciled (color not specified)

**Note**: The Visual Profile uses semantic color descriptions, NOT hex values. This is a known limitation identified in Run 01 — the prompt should note this as an area where cross-generator divergence is expected.

---

## 4. GENERATION / PRESENTATION REQUIREMENTS

### From PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 + rh400-prompt-template.md

| Requirement | Source |
|------------|--------|
| Single vehicle only, fully visible, no cropping | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| Top-down orthographic camera with no perspective distortion | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| Vehicle centered within canvas, ~75% of frame | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| Soft neutral studio lighting — cool, even, diffused | rh400-prompt-template.md + PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| Physically accurate materials | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| Strong, immediately recognizable silhouette | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| Slight panel seams and realistic industrial wear where appropriate | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| Functional hazard markings permitted where appropriate | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| No dramatic cinematic effects | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| Transparent background (alpha channel) | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 |
| No terrain, ground plane, baked shadows, sky, stars, environment, props, dust, motion blur | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 prohibition list |
| No text, labels, borders, watermark | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 prohibition list |
| Transparent PNG, 1024×1024 pixels | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 output specification |

---

## 5. UNKNOWN OR UNDERSPECIFIED INFORMATION

### Intentionally Not Specified (Valid Gaps)

| Element | Why Unknown |
|---------|------------|
| **Exact scoop geometry** (depth, width, angle of attack) | Blueprint description is functional ("skim planetary surfaces") not geometric. Visual Definition lists it as a recognition feature but provides no dimensions. |
| **Canister diameter/length** | Blueprint volume_m3 = 59.5 is total vehicle volume, not canister-specific. No canister-specific dimensions exist in any source. |
| **Wheel diameter/tread pattern** | Recognition feature #1 specifies "six-wheel independent suspension" but no wheel dimensions or tread details. |
| **Sensor mast height/diameter** | Recognition feature #5 specifies presence but no dimensions. |
| **Hydraulic actuator count/size** | Recognition feature #6 specifies presence but no quantitative data. |
| **Exhaust stack diameter/height/fins** | Recognition feature #4 specifies presence but no dimensions. |
| **Exact color hex values** | Visual Profile uses semantic descriptions only ("white/light-gray", "dark gray/black"). Run 01 established that semantic colors produce variable results across generators. This is a known limitation, not a prompt defect. |
| **Hazard stripe width/pitch** | Visual Profile specifies "black/yellow hazard striping" but no quantitative dimensions. |
| **Unit ID text content** | Visual Profile says "unit ID stenciled on the hull" but does not specify what the ID reads (e.g., "RH-400", "RHR-001", etc.). |
| **Panel seam locations** | No panel layout data exists in any source document. |
| **Surface wear distribution** | PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0 says "realistic industrial wear where appropriate" but does not specify where wear should appear. |

### Derived Assumptions (Documented, Not Promoted to Canonical)

| Assumption | Basis | Confidence |
|-----------|-------|-----------|
| **Mk2 tech level = cleaner than Mk1** | VISUAL_PHILOSOPHY.md: Mk2 = "cleaner, fewer visible fasteners, welded joints" | High — explicit definition |
| **Heavy industrial = oversized components** | Visual Definition manufacturing_style = heavy_industrial + Design System definition | Medium — inferred from Design System canonical value |
| **No cockpit/human features** | crew_capacity = 0 + autonomous = true + human_rated = false | High — explicit data |
| **Steel-dominant appearance** | Blueprint materials: steel 9,500kg (67% of total) | Medium — material composition doesn't guarantee visual dominance (paint/coatings may obscure) |

---

## 6. EVALUATION CRITERIA

### Adapted from I-beam Rubric with Vehicle-Specific Additions

The I-beam rubric (Criteria A–L) is sufficient for object identity and geometry but insufficient for vehicle-specific evaluation. The following additions are proposed:

| Criterion | Description | Scoring |
|-----------|-------------|---------|
| **A. Structural/Overall Geometry** | Chassis proportions, silhouette correctness, component placement accuracy | 1–5 |
| **B. Vehicle Identity** | RH-400 recognizable as a harvester rover (not generic truck, not excavator, not rover without scoop) | 1–5 |
| **C. Recognition Feature Completeness** | All 6 recognition features present and correctly positioned | 1–5 |
| **D. Proportion Accuracy** | Length:width:height ratio ≈ 6.80:3.30:2.65 (≈ 2.57:1.25:1) — vehicle appears low-profile, not tall/narrow | 1–5 |
| **E. Material Appearance** | White/light-gray paneling over dark undercarriage; precision-machined surfaces; no regolith/3D-printed appearance | 1–5 |
| **F. Tech Level Consistency** | Mk2 characteristics present (cleaner, welded joints, slight sheen); no Mk1 (layer lines) or Mk3+ (polished/seamless) features | 1–5 |
| **G. Hazard Markings** | Black/yellow hazard striping present on moving parts/edges; not over-applied or absent | 1–5 |
| **H. Absence of Unsupported Context** | No terrain, ground plane, sky, stars, environment, props, dust, motion blur | 1–5 |
| **I. Blueprint Adherence** | All known blueprint characteristics present and accurate (no contradictions) | 1–5 |
| **J. Unwanted Invented Details** | No invented geometry, text, labels, logos, or contradictory features beyond background artifacts | 1–5 |
| **K. Asset Isolation/Presentation** | Vehicle fully visible, centered, ~75% frame, clean edges | 1–5 |
| **L. Cross-Model Consistency** | Agreement between ChatGPT and Gemini on key criteria | 1–5 |

### Additional Vehicle-Specific Criteria (Proposed)

| Criterion | Description | Scoring |
|-----------|-------------|---------|
| **M. Silhouette Strength** | Strong, primary silhouette recognizable at small scale; functional components dominate outline | 1–5 |
| **N. Mechanical Plausibility** | Hydraulic arms, suspension, wheels, and scoop appear mechanically coherent (not impossible geometry) | 1–5 |

---

## 7. EXPECTED FAILURE/DIVERGENCE POINTS

### Based on Run 01/Run 02 Findings

| Risk Area | Likelihood | Basis |
|-----------|------------|-------|
| **Color divergence** (primary paneling, undercarriage, hazard markings) | HIGH | Run 01 established semantic colors produce variable results. RH-400 has THREE color zones (white/light-gray, dark gray/black, yellow) — more complexity = more divergence potential. |
| **Proportion distortion** (length:width:height ratio) | MODERATE | Image generators struggle with specific aspect ratios without explicit constraints. 6.80:3.30:2.65 is a non-standard ratio that may be compressed or stretched. |
| **Recognition feature omission** (especially tertiary features) | MODERATE | Six recognition features is more than the I-beam's four. Generators may omit or merge features under complexity pressure. |
| **Background transparency failure** | HIGH | Run 02 confirmed prompt-level format mandates cannot override environment serialization. Both generators will likely fail true transparency. |
| **Over-detailing** (invented panels, ports, text) | MODERATE | Higher complexity may trigger generator tendency to add "interesting" details not in the source data. |
| **Tech level confusion** (Mk1 vs Mk2 vs Mk3) | LOW-MODERATE | The VISUAL_PROFILE_precision_industrial_v1.md specifies precision-machined surfaces, which could be interpreted as Mk3-level if the generator over-cleans the appearance. |
| **Scale ambiguity** (vehicle vs model/toy) | MODERATE | Without ground reference or human-scale elements, the vehicle may appear as a miniature rather than full-size industrial equipment. |

---

## 8. FROZEN STATUS

This specification is FROZEN as of 2026-08-25. Do not modify after the initial ChatGPT vs Gemini generation run. If results diverge, record where they diverge — do not rewrite the specification to make generators agree. The experiment is intended to reveal weaknesses in the specification-to-generator pipeline at higher complexity.

---

**Specification complete. Primary prompt file: `rh400_mk1_primary_prompt.txt` (separate deliverable).**
