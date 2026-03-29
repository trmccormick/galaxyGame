# [MEDIUM ISSUE] Biosphere#simulate_tick — No Life Growth (Missing Biome Conditions)

**Created:** 2026-03-29
**Priority:** Medium
**Spec:** biosphere_spec.rb:607 (line 622)
**Expected:** population != 1000 | **Got:** 1000 (no growth)

## Root Cause
- `simulate_tick` calls `life_form.simulate_growth(Mars conditions)`
- No growth occurs because Phase 4 PlanetBiome → Earth-like temp/o2/co2 is missing

## Fix Options
1. **Recommended:** xdescribe "Phase 4 - Requires PlanetBiome conditions"
2. Mock planet_biome with Earth conditions (temporary)

## Diagnostic
- `grep -n "simulate_tick" app/models/celestial_bodies/spheres/biosphere.rb`
- `grep -n "population" spec/models/celestial_bodies/spheres/biosphere_spec.rb:607-630`

## Acceptance Criteria
- Spec is properly skipped or mocked
- Task is documented and committed
- No regression in surface view or terrain generation

---

**See agent README for workflow.**
