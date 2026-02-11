# Local Bubble Expansion

Goal: Expand into known systems using artificial wormholes with data-driven seeds. Many systems are incomplete; use the generator to fill missing data reasonably without hard-coding specifics.

## Principles
- Canonical seeds live under `data/json-data/star_systems/`. Do not overwrite.
- Generation is data-driven; SOL is the only exception for hard-coded logic.
- Hybrid outputs are written to `GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH` with timestamps.

## Commands
- Expand all systems:
```bash
ruby ./scripts/local_bubble_expand.rb --dir app/data/star_systems
```
- Expand one system:
```bash
ruby ./scripts/generate_hybrid_system.rb --seed app/data/star_systems/alpha_centauri.json
```

## Behavior (Generic Hybrid)
- Preserves all bodies from the seed and tags them `from_seed=true`.
- Fills per-star gaps by adding at least one terrestrial planet near the ecosphere radius with reasonable orbital parameters.
- Prefers terraformable templates when available; falls back to procedural generation.
- Uses star fields (`r_ecosphere`, `identifier`, `name`) if present; no name-based checks.

## Acceptance Criteria
- No system-specific code paths outside SOL.
- Seeds remain untouched; generated outputs contain preserved seed bodies plus procedurally filled data.
- Mission profiles reference systems by identifiers and operate on generated outputs.

## StarSim Status and Future Enhancements

### Current State
StarSim is a modular service layer for star system generation, comprising:
- **ProceduralGenerator**: Main hybrid generator for filling incomplete seeds (e.g., Alpha Centauri). Supports both procedural and physics-based accretion modes. Default is procedural for compatibility.
- **AccretionSimulationService**: Complete physics-inspired accretion disk simulation (StarGen-influenced). Generates protoplanets via dust accretion with gravity stability checks. Includes Hill sphere overlaps to ensure orbital stability. Added rand_orbit for density-weighted orbital selection, threshold checks for mass limits, and apply_gravity_stability for preventing overlapping orbits.
- **PlanetBuilder**: Builds planet data from protoplanet seeds, now with build_data method for JSON-compatible output and fixed classify method for correct class names.
- **Supporting Services**: Orbital calculators, atmosphere/hydrosphere/geosphere generators, moon generators, etc. Many are stubs or incomplete.
- **Integration**: ProceduralGenerator integrates accretion as an optional mode (`use_accretion: true`). Accretion generates planet data hashes compatible with the JSON schema. Added DustBand class for dust disk simulation.

### Strengths
- Dual-mode generation: Procedural for fast hybrid completion, accretion for physics-based realism.
- Data-driven design preserves seeds and avoids hard-coding.
- Generated systems (e.g., in `data/json-data/generated_star_systems/`) are usable for gameplay.
- Gravity stability ensures realistic orbital architectures.
- Recent enhancements: Accretion mode fully integrated, gravity influence added, all procedural generator specs pass (34/34).

### Weaknesses and Suggestions
- **Realism Gaps**: Accretion lacks migration, ejections, and advanced multi-body dynamics (e.g., resonances).
- **Incomplete Physics**: Dust bands are simplified; no gas dynamics or planetesimal interactions.
- **Performance**: Accretion is more compute-intensive than procedural; use selectively.
- **Integration**: Accretion mode is new; test thoroughly for edge cases.
- **Feature Parity**: Accretion planets lack atmosphere/hydrosphere/biosphere generation (critical for hybrid use).
- **Easter Eggs**: Consider adding procedural moons/gas giants for specific systems (e.g., Pandora-like moon for gas giants).

**Recent Enhancements (2026-02-07)**:
1. **Gravity Influence**: Added Hill sphere stability checks in AccretionSimulationService. Post-accretion, removes bodies with overlapping spheres.
2. **Hybrid Integration**: ProceduralGenerator now supports `use_accretion` flag. When enabled, uses accretion for planet formation instead of procedural.
3. **Complete Methods**: Implemented `rand_orbit` (density-weighted), `threshold` (mass check), `apply_gravity_stability`.
4. **Data Compatibility**: Accretion returns JSON-compatible planet hashes with orbits, atmospheres, etc.
5. **Validation**: All 34 ProceduralGenerator specs pass; accretion mode tested.

## Hybrid Generation Enhancement Proposals

### Accretion-Based Gap Filling
**Considered For**: Local bubble expansion of partial systems  
**Rationale**: Physics-based orbital placement more realistic than random procedural for completing known systems.

**Current Gap-Filling Logic** (Procedural):
```ruby
# Check planet count per star
existing_count = count_existing_planets(star)
to_add = [minimum_target - existing_count, 0].max

# Add planets near ecosphere
to_add.times do |i|
  distance = ecosphere * rand(0.8..1.3)  # Random placement
  planet = generate_complete_planet(star, distance)  # Full features
end
```

**Proposed Accretion Gap-Filling**:
```ruby
# Run accretion simulation for this star
dust_disk = create_dust_disk(star)
accretion = AccretionSimulationService.new(star, dust_disk)
candidates = accretion.run.select do |planet|
  !conflicts_with_existing_seed?(planet, existing_planets)
end

# Enhance basic accretion planets with full features
candidates.each do |basic_planet|
  enhanced = enhance_accretion_planet(basic_planet)  # Add atmosphere, biosphere, etc.
  system["celestial_bodies"]["terrestrial_planets"] << enhanced
end
```

**Benefits**:
- Realistic orbital spacing based on physics
- Proper mass-distance relationships  
- Natural formation patterns (rocky inner, gas outer)
- Stability-checked orbits

**Blockers**:
- Accretion planets currently lack atmosphere/hydrosphere/biosphere
- Need `enhance_accretion_planet()` method
- Must handle orbital conflicts with seed planets
- Performance impact on bulk generation

**Recommendation**: Implement accretion enhancement features first, then integrate as optional hybrid mode.

## JSON Import Compatibility Issues

### Celestial Body Aliases Support
**Status**: ✅ FIXED - Aliases moved to properties field  
**Issue**: Adding `aliases` field to JSON star system data broke import compatibility.

**Solution Implemented**:
- Moved `aliases` from top-level JSON field into `properties` JSONB field
- `SystemBuilderService` now properly imports aliases via properties merging
- Maintains backward compatibility for name resolution

**Current Structure**:
```json
{
  "name": "Eden II",
  "properties": {
    "aliases": ["Topaz", "Eden II"]
  }
}
```

**Impact**: Aliases now persist through system import/regeneration, enabling reliable name resolution for renamed celestial bodies.

## Accretion-Based Hybrid Generation (Proposed)

### Concept
For local bubble expansion of partial systems, use StarGen accretion physics to fill orbital gaps instead of random procedural placement.

**Current Hybrid Logic**:
```ruby
# For each star, count existing planets
existing_count = count_terrestrial_planets_for_star(star)
to_add = [target_min - existing_count, 0].max

# Add planets near ecosphere with procedural generation
to_add.times do
  semi_major = ecosphere * rand(0.8..1.3)
  planet = generate_procedural_terrestrial(...) # Complete planet
end
```

**Proposed Accretion Hybrid Logic**:
```ruby
# Use accretion to generate realistic orbital architecture
dust_disk = create_dust_disk(star_mass)
accretion = AccretionSimulationService.new(star, dust_disk)
candidate_planets = accretion.run

# Filter to fill gaps, enhance with procedural details
candidate_planets.each do |basic_planet|
  next if orbital_slot_occupied?(basic_planet.orbit)
  enhanced_planet = enhance_accretion_planet(basic_planet) # Add atmosphere, biosphere, etc.
  add_to_system(enhanced_planet)
end
```

### Benefits
- ✅ **Realistic Orbital Spacing**: Physics-based planet placement vs random
- ✅ **Proper Mass Distribution**: Accretion naturally creates inner rocky + outer gas giant patterns  
- ✅ **Stability Checks**: Hill sphere calculations prevent overlapping orbits
- ✅ **Distance-Based Properties**: Planet characteristics tied to formation distance

### Implementation Challenges
- 🔴 **Feature Gap**: Accretion planets lack atmosphere/hydrosphere/biosphere generation
- 🔴 **Integration Required**: Need `enhance_accretion_planet()` method to add missing features
- 🔴 **Orbital Conflicts**: Must check for conflicts with existing seed planets
- 🔴 **Performance**: Accretion simulation is slower than procedural

### StarGen Reference Implementation Analysis

**Complete StarGen Features** (Reference: https://github.com/vico93/stargen):
- **Atmosphere Generation**: Gas composition, pressure, molecular weights, breathability assessment (breathable/unbreathable/poisonous)
- **Temperature Modeling**: Surface temperature, greenhouse effects, temperature ranges (high/low), seasonal variations
- **Hydrosphere**: Water coverage, ice coverage, cloud coverage with dynamic calculations based on temperature and pressure
- **Climate Physics**: Gas retention limits, gas lifetimes, inspired partial pressure calculations
- **Surface Properties**: Albedo calculations, surface coverage fractions (rock/water/ice/cloud)
- **Environmental Assessment**: Habitability scoring, biosphere potential, geological activity

**Current Accretion Implementation Gaps**:
- **PlanetBuilder**: Only generates basic physical properties (mass, radius, density, orbit) - missing all environmental features
- **Missing Services**: No accretion equivalents for AtmosphereGeneratorService, HydrosphereGeneratorService, Biosphere generation
- **Data Structure**: Accretion planets lack JSON fields for atmosphere_attributes, hydrosphere_attributes, biosphere_attributes, geosphere_attributes
- **Environmental Physics**: No greenhouse effect calculations, gas retention modeling, temperature range calculations, albedo dynamics

**Required Enhancement Phases**:

#### Phase 1A: Environmental Physics Foundation
- Implement accretion temperature calculations (effective temp, greenhouse rise, surface temp)
- Add gas retention physics (molecular weight limits, smallest MW retained)
- Create albedo calculation system based on surface composition

#### Phase 1B: Atmosphere Generation for Accretion
- Build AccretionAtmosphereService with gas composition algorithms
- Implement pressure calculations and breathability assessment
- Add atmospheric escape velocity and retention modeling

#### Phase 1C: Surface Coverage Systems
- Implement hydrosphere calculations (water/ice/cloud fractions)
- Add dynamic surface coverage based on temperature and pressure
- Create geological activity and tectonic modeling

#### Phase 1D: Biosphere Integration
- Add biosphere generation for accretion planets (biodiversity, habitability, biome distribution)
- Implement habitability scoring based on environmental conditions
- Create species count estimation algorithms

#### Phase 2: Enhanced PlanetBuilder
- Extend PlanetBuilder.build_data to include all environmental attributes
- Integrate with accretion-specific generators (AccretionAtmosphereService, etc.)
- Add moon generation for accretion-formed planets

#### Phase 3: Hybrid Integration Testing
- Implement enhance_accretion_planet() method for feature parity
- Test orbital conflict resolution with existing seed planets
- Validate performance impact and optimization opportunities

### Recommended Implementation Path

1. **Phase 1**: Create accretion hybrid mode for orbital mechanics only
   - Use accretion for realistic spacing around existing seed planets
   - Still use procedural generation for planet details

2. **Phase 2**: Full accretion enhancement  
   - Implement `enhance_accretion_planet()` to add atmospheres, biospheres, moons
   - Integrate with existing generator services

3. **Phase 3**: Selective accretion
   - Allow per-star accretion mode based on system completeness
   - Fallback to procedural for performance-critical scenarios

**Status**: Considered but not implemented - accretion method needs feature parity first.

**Recommended Enhancements**:
1. **Advanced Physics**: Add migration, ejections, and resonance calculations.
2. **Gas Giants**: Extend accretion for gas/ice giants with different formation mechanisms.
3. **Performance Optimization**: Cache dust bands or precompute for common star types.
4. **Easter Eggs**: Use accretion for specific systems (e.g., Pandora-like moons) while keeping procedural default.

These changes would improve realism without breaking existing functionality, as generation is infrequent.

## References
- Generator: `StarSim::ProceduralGenerator.generate_hybrid_system_from_seed_generic(seed_path)`
- Runners: [galaxy_game/scripts/local_bubble_expand.rb](../scripts/local_bubble_expand.rb), [galaxy_game/scripts/generate_hybrid_system.rb](../scripts/generate_hybrid_system.rb)
- Guardrails: [docs/developer/DATA_DRIVEN_SYSTEMS.md](DATA_DRIVEN_SYSTEMS.md)
- Terraformable: [docs/developer/TERRAFORMABLE_PLANETS.md](TERRAFORMABLE_PLANETS.md)
- Playbook: [docs/developer/GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md)
