---
title: Weathering Engine Regression Filter
status: BACKLOG
priority: HIGH
layer: Meso
created: 2026-03-23
updated: 2026-03-23
author: Documentation Strategist
---

# TASK: Generator Weathering Engine

## Historical Context
Lessons from StarSim archives:
- Previous generators produced 'noisy' maps with excessive randomness and lacked large-scale coherence.
- Incorrect scale: JSON and generator logic sometimes mismatched real planetary scales, leading to unrealistic gameplay.
- Early attempts failed to use 4X-style heuristics, resulting in poor playability and resource distribution.
- Overly global models: Initial Mars settlement JSONs focused on global terraforming and atmospheric skimmers, which proved unmanageable and did not align with new "Quick Win" strategies (local compressors, aerogel panels, gas storage).
- Lack of weathering/erosion: No regression filter or erosion simulation was applied, so barren states were not convincingly derived from lush/goal states.

## Background
Current terrain generation produces output that feels noisy and unnatural compared to balanced 4X maps (e.g., Civ4/FreeCiv). Elevation is sampled independently, and features are overlaid without simulating geological regression or weathering. There is no mechanism to regress a lush/terraformed map to a barren state using real-world erosion patterns.

## Requirements

### 1. Regression Filter Implementation
- Take a 'Goal State' (Terraformed/Lush) map as input.
- Apply NASA-derived erosion/weathering patterns to regress the map to a Barren starting state.
- Output should reflect realistic geological aging and loss of habitability.

### 2. Heuristic-First Generation
- Transition from 'Tectonic-First' to 'Heuristic-First' generation.
- Use FreeCiv/Civ4 map patterns as the training baseline for resource, biome, and terrain distribution.
- Integrate playability and balance heuristics from 4X map design.

### 3. Output Format
- Ensure the generator produces 128x128 HD Sprite output (target spec for downstream rendering).

### 4. Documentation
- Update or create docs/architecture/STAR_SIM_GENERATION.md to document the new 'Weathering' intent and regression approach.
- Describe the shift to heuristic-driven, pattern-trained map generation.

## Acceptance Criteria
- Regression filter demonstrably transforms lush maps into plausible barren states.
- Output matches 128x128 HD Sprite spec.
- Documentation is updated to reflect the new approach.

---

**Simulation Layer:** Meso (Surface)
**Agent Discipline:** 0x — All changes must be auditable, with explicit commit messages and preserved file dates.
**Tag:** weathering, regression, terrain, 4X, meso
