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
- **Easter Eggs**: Consider adding procedural moons/gas giants for specific systems (e.g., Pandora-like moon for gas giants).

**Recent Enhancements (2026-02-07)**:
1. **Gravity Influence**: Added Hill sphere stability checks in AccretionSimulationService. Post-accretion, removes bodies with overlapping spheres.
2. **Hybrid Integration**: ProceduralGenerator now supports `use_accretion` flag. When enabled, uses accretion for planet formation instead of procedural.
3. **Complete Methods**: Implemented `rand_orbit` (density-weighted), `threshold` (mass check), `apply_gravity_stability`.
4. **Data Compatibility**: Accretion returns JSON-compatible planet hashes with orbits, atmospheres, etc.
5. **Validation**: All 34 ProceduralGenerator specs pass; accretion mode tested.

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
