---

# 2026-03-23-HIGH-FEATURE-WEATHERING-ENGINE.md

**Status:** BACKLOG
**Priority:** HIGH
**Type:** feature (terrain generation)
**Layer:** MESO (Surface)
**Created:** 2026-03-23
**Last Updated:** 2026-04-17

---

## Agent Assignment
**Assigned To:** Implementation Agent (0x, auditable)
**Why This Agent:** Requires auditable, testable code and doc changes
**Supervision Level:** Standard

---

## Context
Current terrain generation is noisy and lacks realistic weathering/erosion. Previous generators failed to use 4X-style heuristics, resulting in poor playability and resource distribution. There is no regression filter to transform lush/terraformed maps into plausible barren states using real-world erosion patterns. This task implements a regression filter, shifts to heuristic-first generation, and updates documentation.

---

## Target Files
- Terrain generator code (location as appropriate)
- data/json-data/maps/ (input/output)
- docs/architecture/STAR_SIM_GENERATION.md

---

## Acceptance Criteria
- Regression filter demonstrably transforms lush maps into plausible barren states
- Output matches 128x128 HD Sprite spec
- Documentation is updated to reflect the new approach

---

## Subtasks
1. Implement regression filter: take lush/terraformed map as input, apply NASA-derived erosion/weathering patterns, output barren state
2. Shift generator to heuristic-first approach using FreeCiv/Civ4 map patterns for resource, biome, and terrain distribution
3. Ensure generator produces 128x128 HD Sprite output
4. Update or create docs/architecture/STAR_SIM_GENERATION.md to document weathering intent and heuristic-driven generation

---

## Commit Instructions
```
git add [generator code] docs/architecture/STAR_SIM_GENERATION.md
git commit -m "feat: implement weathering regression filter and heuristic-first terrain generation"
```
