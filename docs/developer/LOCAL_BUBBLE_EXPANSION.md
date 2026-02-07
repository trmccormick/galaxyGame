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
- **ProceduralGenerator**: Main hybrid generator for filling incomplete seeds (e.g., Alpha Centauri). Works well for quick, data-driven completion but lacks physics-based realism.
- **AccretionSimulationService**: Physics-inspired accretion disk simulation (StarGen-influenced). Generates protoplanets via dust accretion but incomplete—missing inter-body gravity, stability checks, and integration with ProceduralGenerator.
- **Supporting Services**: Orbital calculators, atmosphere/hydrosphere/geosphere generators, moon generators, etc. Many are stubs or incomplete.
- **Integration**: ProceduralGenerator is used in scripts for local bubble expansion. Accretion and others are not wired in, leading to disconnected components.

### Strengths
- Procedural approach ensures fast, reproducible generation.
- Data-driven design preserves seeds and avoids hard-coding.
- Generated systems (e.g., in `data/json-data/generated_star_systems/`) are usable for gameplay.

### Weaknesses and Suggestions
- **Realism Gaps**: No gravitational interactions between bodies (e.g., orbital stability, resonances). Accretion service treats planets independently.
- **Incomplete Physics**: Accretion lacks migration, ejections, and multi-body dynamics. Methods like `rand_orbit` are placeholders.
- **Integration Issues**: Accretion not used in main pipeline; StarGen files exist but aren't combined.
- **Performance**: Systems generated on-demand; pre-generation mitigates this.

**Recommended Enhancements**:
1. **Gravity Influence**: Add Hill sphere checks in AccretionSimulationService to ensure stable orbits. Post-generation, run a stability pass to remove unstable bodies.
2. **Hybrid Accretion + Procedural**: For full systems, use accretion for planet formation, then procedural for atmospheres/moons.
3. **Complete Stubs**: Define missing methods (e.g., `rand_orbit` based on disk density, `threshold` for planet mass).
4. **Integration Path**: Extend ProceduralGenerator to optionally use accretion for terrestrial planets, falling back to templates.
5. **Validation**: Add checks for realistic architectures (e.g., no planets crossing orbits).

These changes would improve realism without breaking existing functionality, as generation is infrequent.

## References
- Generator: `StarSim::ProceduralGenerator.generate_hybrid_system_from_seed_generic(seed_path)`
- Runners: [galaxy_game/scripts/local_bubble_expand.rb](../scripts/local_bubble_expand.rb), [galaxy_game/scripts/generate_hybrid_system.rb](../scripts/generate_hybrid_system.rb)
- Guardrails: [docs/developer/DATA_DRIVEN_SYSTEMS.md](DATA_DRIVEN_SYSTEMS.md)
- Terraformable: [docs/developer/TERRAFORMABLE_PLANETS.md](TERRAFORMABLE_PLANETS.md)
- Playbook: [docs/developer/GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md)
