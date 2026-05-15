# TASK: Fix Biosphere Guard in Terrain Generation
**Status**: BACKLOG  
**Priority**: CRITICAL  
**Type**: feature  
**Created**: 2026-02-15

---

## Problem Statement
Airless bodies (Luna, Mercury, bare Mars) are assigned Earth-like biomes due to missing biosphere check in `generate_hybrid_biomes`. This causes wasted computation and incorrect terrain data.

## Goals
- Add biosphere presence guard to `generate_hybrid_biomes`
- Prevent biome generation for airless bodies
- Ensure correct biomes for Earth and biosphere worlds

## Acceptance Criteria
- [ ] Airless bodies return `nil` for biomes
- [ ] Earth and biosphere worlds generate biomes
- [ ] No performance regression

## Implementation Notes
- Add `return nil unless celestial_body.biosphere.present?` at start of `generate_hybrid_biomes`
- Test with Luna/Mercury and Earth

## Diagnostic/Debugging
- Confirm no biomes for airless bodies
- Verify correct biomes for Earth

## Related Files/Paths
- app/services/automatic_terrain_generator.rb (generate_hybrid_biomes)

## References
- Archive task (2026-02-15)

---

