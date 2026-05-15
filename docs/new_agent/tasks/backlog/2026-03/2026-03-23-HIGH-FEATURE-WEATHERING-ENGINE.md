# 2026-03-23-HIGH-FEATURE-WEATHERING-ENGINE.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: FEATURE
**Name**: Weathering Engine Terrain Generation

## Context
Current terrain generation is noisy and lacks realistic weathering/erosion. Previous generators failed to use 4X-style heuristics, resulting in poor playability and resource distribution. There is no regression filter to transform lush/terraformed maps into plausible barren states using real-world erosion patterns.

## Problem
Terrain generation lacks realistic weathering and erosion patterns. No regression filter exists to transform maps into plausible barren states. Current generation is noisy and doesn't follow 4X-style heuristics for better playability.

## Files
- Target: Terrain generator code
- Related: data/json-data/maps/, docs/architecture/STAR_SIM_GENERATION.md

## Steps
1. Implement regression filter for weathering/erosion patterns
2. Shift to heuristic-first terrain generation
3. Transform lush/terraformed maps into plausible barren states
4. Update terrain generation documentation
5. Test resource distribution and playability improvements

## Acceptance Criteria
- Terrain generation includes realistic weathering/erosion patterns
- Regression filter transforms maps into plausible barren states
- Improved resource distribution and playability
- Updated documentation reflects new generation approach

## Stop Condition
- Weathering engine implemented and tested
- Terrain generation uses heuristic-first approach
- Documentation updated with new patterns

## Commit
`feat: implement weathering engine for realistic terrain generation`