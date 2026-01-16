# Terraformable Planets (Data-Driven)

Intent: During Local Bubble expansion via artificial wormholes, complete known systems with reasonable, data-driven terraformable planets using templates — no system-specific code beyond SOL.

## Principles
- Templates: Use `data/json-data/templates/alien_world_templates_v1.1.json` (fallback to v1.0) for terraformable terrestrial worlds.
- No name literals: Generators must not reference specific systems/bodies by name; operate purely on seed fields and identifiers.
- Read-only seeds: Canonical seeds under `data/json-data/star_systems/` are never overwritten.

## Generator Behavior
- Generic hybrid method: `StarSim::ProceduralGenerator.generate_hybrid_system_from_seed_generic(seed_path)`
  - Preserves all seed bodies and tags them `from_seed=true`.
  - Per star, if no terrestrial planets are present, adds at least one.
  - Prefers terraformable templates when available; sets orbits near the star ecosphere and recalculates temperature.
  - Falls back to procedural generation when templates are unavailable.

## Commands
- Expand all systems (inside container):
```bash
ruby ./scripts/local_bubble_expand.rb --dir app/data/star_systems
```
- Expand one system (inside container):
```bash
ruby ./scripts/generate_hybrid_system.rb --seed app/data/star_systems/alpha_centauri.json
```

## Acceptance Criteria
- Hybrid outputs include preserved seed bodies plus at least one terraformable terrestrial planet per star when templates exist.
- No system-specific assumptions in generator code paths; seeds drive behavior.
- RSpec template integrity spec passes or is skipped only when templates are intentionally empty.

## Testing Notes
- See [galaxy_game/spec/data/alien_world_templates_integrity_spec.rb](../../galaxy_game/spec/data/alien_world_templates_integrity_spec.rb).
- If templates are incomplete, keep the integrity spec `skip` gates to avoid false failures; once A01→A25 are in place, enable full checks.

## References
- Templates: [data/json-data/templates/alien_world_templates_v1.1.json](../data/json-data/templates/alien_world_templates_v1.1.json) (fallback v1.0)
- Runners: [galaxy_game/scripts/local_bubble_expand.rb](../galaxy_game/scripts/local_bubble_expand.rb), [galaxy_game/scripts/generate_hybrid_system.rb](../galaxy_game/scripts/generate_hybrid_system.rb)
- Guardrails: [docs/developer/DATA_DRIVEN_SYSTEMS.md](DATA_DRIVEN_SYSTEMS.md)
- Playbook: [docs/developer/GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md)
