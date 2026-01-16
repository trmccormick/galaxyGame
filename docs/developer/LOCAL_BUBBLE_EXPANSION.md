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

## References
- Generator: `StarSim::ProceduralGenerator.generate_hybrid_system_from_seed_generic(seed_path)`
- Runners: [galaxy_game/scripts/local_bubble_expand.rb](../scripts/local_bubble_expand.rb), [galaxy_game/scripts/generate_hybrid_system.rb](../scripts/generate_hybrid_system.rb)
- Guardrails: [docs/developer/DATA_DRIVEN_SYSTEMS.md](DATA_DRIVEN_SYSTEMS.md)
- Terraformable: [docs/developer/TERRAFORMABLE_PLANETS.md](TERRAFORMABLE_PLANETS.md)
- Playbook: [docs/developer/GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md)
