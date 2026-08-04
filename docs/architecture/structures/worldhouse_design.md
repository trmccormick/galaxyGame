# Worldhouse Design

## Overview

A worldhouse is a **megastructure** that wraps an existing geological feature (valley, canyon, lava tube, or excavated cavity) with pressurized segments to create a habitable environment. It is a structure *over* terrain, not terraforming itself. Worldhouses enable large-scale human habitation on airless or thin-atmosphere bodies by creating contained, breathable environments within pre-existing geological formations.

The closest Earth analogy is a greenhouse: it creates a local microclimate without modifying the planetary conditions outside its walls.

## Key Distinction: Worldhouse vs. Terraforming

### Worldhouse (Local Habitat)
- **Scope**: Single structure built on/over one geological feature
- **What it modifies**: Internal biome conditions only (pressure, temperature, atmosphere composition within sealed segments)
- **What it does NOT modify**: Planetary atmosphere, surface temperature, hydrosphere, or biosphere
- **Analogy**: A greenhouse on Earth

### Terraforming (Planetary Modification)
- **Scope**: Entire celestial body
- **What it modifies**: Atmosphere composition, surface temperature, hydrosphere state across the whole planet/moon
- **What it does NOT modify**: Internal structure of individual habitats or buildings
- **Analogy**: Making Earth-like conditions across an entire planet

## Worldhouse Architecture

### Model Structure

```
Structures::Worldhouse (BaseStructure)
├── geological_feature: BaseFeature (required — Valley/Canyon/LavaTube/ExcavatedCavity)
├── worldhouse_segments: [WorldhouseSegment] (dependent: :destroy)
├── structure_type: 'worldhouse' (stored in operational_data['structure_type'])
├── total_segments: integer
├── enclosed_segments: integer (default: 0)
├── coverage_percent: float (default: 0.0)
│
├── feature_name → geological_feature.name
├── feature_width_m → geological_feature.width_m
├── feature_depth_m → geological_feature.depth_m
├── opening_area_km2 → (length × width) / 1_000_000
├── enclosed_volume_km3 → (length × width × depth) / 1_000_000_000
├── population_capacity → enclosed_volume_km3 × 0.5 × 100 (50% usable, 100 people/km³)
└── construction_complete? → enclosed_segments >= total_segments
```

### WorldhouseSegment Model

```
Structures::WorldhouseSegment
├── worldhouse: Worldhouse (required)
├── segment_index: integer
├── length_m / width_m: dimensions
├── segment_type: string (default: 'residential')
├── status: enum [planned → materials_requested → under_construction → enclosed → operational]
│
├── area_m2 → length × width
├── area_km2 → area_m2 / 1_000_000
├── diameter → sqrt(length² + width²) (for CoveringCalculator compatibility)
├── required_panel_count → area_m2 / 25 (each panel is 5×5m)
├── required_materials → {panel, beam, seal, mount counts}
└── begin_construction! / complete! (workflow methods)
```

### Biome Engineering in Worldhouses

Worldhouse biomes are created **inside** the sealed structure:

1. **Geological feature status progression**: `natural → surveyed → enclosed → pressurized → settlement_established`
2. **Segment construction**: Each segment is built with modular structural panels (5×5m), structural support beams, pressure seals, and mounting hardware
3. **Covering workflow**: `SegmentCoveringService` covers skylights and openings on the geological feature
4. **Pressurization**: Once enclosed, the feature transitions to `pressurized` status — this is local atmospheric processing, NOT planetary atmosphere modification

**ConvertedBase** (a Worldhouse subclass for asteroid cavities) adds:
- `AtmosphericProcessing` concern — processes O2/CO2 and pressure **within** the structure
- `EnergyManagement` concern — manages local power grid
- `HasUnits` concern — life support units
- Composition-based construction material sourcing (carbonaceous/metallic/silicaceous)

### Placement Rules

A worldhouse can only be placed on geological features that pass `worldhouse_suitable?`:

| Requirement | Detail |
|---|---|
| **Feature type** | Valley, Canyon, LavaTube, or ExcavatedCavity |
| **Conversion suitability** | `conversion_suitability['pressurized_valley_section']` or `['worldhouse']` must be 'excellent' or 'good' |
| **No existing worldhouse** | Feature must not already have a worldhouse attached |
| **ConvertedBase only** | Requires a polymorphic `host_body` (Asteroid or SmallMoon) with compatible `composition_type` |

## Interaction with Terraforming

### Indirect Relationships

- Worldhouses can be placed on terraformed terrain — no code prevents this
- Placement validation may reference planetary conditions via the geological feature's `conversion_suitability` data
- The geological feature's status (`enclosed`, `pressurized`) is tracked independently of planetary sphere state

### What Worldhouses Do NOT Affect

| Planetary Sphere | Worldhouse Impact |
|---|---|
| Atmosphere composition | **None** — no writes to `CelestialBodies::Spheres::Atmosphere` |
| Surface temperature | **None** — no writes to planetary thermal models |
| Hydrosphere state | **None** — no writes to `CelestialBodies::Spheres::Hydrosphere` |
| Biodiversity index | **None** — no writes to `CelestialBodies::Spheres::Biosphere` |

Worldhouse atmospheric processing (via `AtmosphericProcessing` concern on ConvertedBase) operates entirely within the sealed structure's local environment. It does not feed back into planetary biosphere calculations.

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  PLANETARY-SCALE (NOT modified by worldhouses)             │
│                                                             │
│  CelestialBody::Atmosphere ────┤                          │
│  CelestialBody::Biosphere      │   (no interaction)       │
│  CelestialBody::Hydrosphere ───┤                          │
└─────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────┐
│  GEOLOGICAL FEATURE (substrate for worldhouse)             │
│                                                             │
│  BaseFeature (Valley/Canyon/LavaTube/ExcavatedCavity)      │
│    ├── feature_type, status (natural→surveyed→enclosed)    │
│    ├── conversion_suitability (placement validation)       │
│    └── structural_stress_factor (for ExcavatedCavity)      │
└─────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────┐
│  WORLDHOUSE STRUCTURE (local habitat creation)             │
│                                                             │
│  Structures::Worldhouse                                      │
│    ├── geological_feature ────→ BaseFeature                │
│    ├── worldhouse_segments ────→ [WorldhouseSegment]       │
│    │     ├── required_materials (panels, beams, seals)     │
│    │     ├── status (planned→materials_requested→...→operational)
│    │     └── Coverable/Enclosable concerns                │
│    ├── enclosed_volume_km3 → population_capacity           │
│    └── construction_complete?                              │
│                                                             │
│  Structures::ConvertedBase < Worldhouse                    │
│    ├── host_body (Asteroid/SmallMoon)                      │
│    ├── AtmosphericProcessing (LOCAL only)                 │
│    ├── EnergyManagement (LOCAL grid)                       │
│    └── HasUnits (life support units)                       │
└─────────────────────────────────────────────────────────────┘
```

## Common Misconceptions

### "Worldhouses terraform planets"
**NO.** Worldhouses create local habitats within existing planetary conditions. They do not modify atmospheric composition, surface temperature, or hydrosphere at the planetary scale. Terraforming is a separate system that operates on the entire celestial body.

### "Worldhouse biomes affect planetary biosphere"
**NO.** Biome engineering inside a worldhouse is isolated from planetary biosphere calculations. The `AtmosphericProcessing` concern processes air locally within the sealed structure — it does not feed back into `CelestialBodies::Spheres::Biosphere`.

### "Worldhouses are just big domes"
**NO.** Worldhouses are segmented megastructures built on geological features. Each segment is independently constructed, covered, and pressurized. The total population capacity scales with enclosed volume (50% usable space × 100 people/km³).

### "Any geological feature can host a worldhouse"
**NO.** Only valleys, canyons, lava tubes, and excavated cavities with suitable `conversion_suitability` ratings ('excellent' or 'good') can support worldhouse construction.
