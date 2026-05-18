# 2026-03-23-HIGH-FEATURE-WEATHERING-ENGINE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority feature for weathering engine terrain generation
**Supervision Level**: 🔴 Watched carefully

## Context
Current terrain generation is noisy and lacks realistic weathering/erosion. Previous generators failed to use 4X-style heuristics, resulting in poor playability and resource distribution. Need regression filter to transform lush/terraformed maps into plausible barren states using real-world erosion patterns.

## Problem Statement
Terrain generation lacks realistic weathering/erosion. No regression filter to transform lush maps into barren states. Generator doesn't use heuristic-first approach with 4X-style patterns.

**Expected**: Regression filter transforms lush maps into plausible barren states. Generator uses heuristic-first approach. Output matches 128x128 HD Sprite spec. Documentation updated.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `docs/architecture/STAR_SIM_GENERATION.md` | Architecture docs | Update to document weathering intent and heuristic-driven generation |

### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/services/terrain/weathering_engine.rb` | Weathering service | Implement regression filter for erosion/weathering patterns |

## Implementation Steps
1. **Implement regression filter**: Create service that takes lush/terraformed map as input, applies NASA-derived erosion/weathering patterns, outputs barren state
2. **Shift to heuristic-first generation**: Update generator to use FreeCiv/Civ4 map patterns for resource, biome, and terrain distribution
3. **Ensure HD output**: Verify generator produces 128x128 HD Sprite output
4. **Update documentation**: Modify STAR_SIM_GENERATION.md to document weathering intent and heuristic-driven generation

## Acceptance Criteria
- [ ] Regression filter demonstrably transforms lush maps into plausible barren states
- [ ] Output matches 128x128 HD Sprite spec
- [ ] Documentation updated to reflect new approach

## Stop Conditions
- Breaking existing terrain generation functionality
- Changes beyond weathering engine and documentation

## Commit Instructions
```bash
git add app/services/terrain/weathering_engine.rb
git add docs/architecture/STAR_SIM_GENERATION.md
git commit -m "feat: implement weathering regression filter and heuristic-first terrain generation"
```