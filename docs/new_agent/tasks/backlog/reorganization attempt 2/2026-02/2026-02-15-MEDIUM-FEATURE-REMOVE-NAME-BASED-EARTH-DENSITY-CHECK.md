# TASK: Remove Name-Based Earth Check in Biome Density
**Status**: BACKLOG  
**Priority**: MEDIUM  
**Type**: feature  
**Created**: 2026-02-15

---

## Problem Statement
`calculate_biome_density` method uses a hardcoded name check for 'earth', which is a logic smell. Earth should get full biome density through biosphere and environmental conditions, not by name override.

## Goals
- Remove name-based logic from biome density calculation
- Ensure Earth gets correct density through environmental factors
- Maintain proper calculation for all planets

## Acceptance Criteria
- [ ] No name-based logic in biome density calculation
- [ ] Earth maintains high biome density through environmental factors
- [ ] Other planets get density based on actual conditions

## Implementation Notes
- Remove `return 1.0 if body.name.downcase == 'earth'` from `calculate_biome_density`
- Test with Earth and other planets

## Diagnostic/Debugging
- Verify density for Earth and other planets

## Related Files/Paths
- app/services/automatic_terrain_generator.rb (calculate_biome_density)

## References
- Archive (2026-02-15)

---

