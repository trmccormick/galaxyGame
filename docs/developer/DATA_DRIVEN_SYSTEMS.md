# Data-Driven Star Systems Guardrails

Principle: Only `SOL` may be hard-coded in the codebase. All other systems must be expressed via data files and referenced by identifiers.

## Rules
- No system-specific names or constants in services/generators (e.g., Alpha Centauri A/B, Proxima b).
- Mission profiles and events target systems via identifiers or data references, not by name literals.
- Generators/readers should operate generically across any seed file under `data/json-data/star_systems/`.
- Hybrid generation preserves seed ground truth and fills only missing data procedurally.

## Implementation Guidance
- Use seed metadata to mark immutable bodies (e.g., `metadata.locked=true` or per-body `locked=true`). Avoid name checks.
- Parameterize orbits and capabilities via seed data fields; never assume fixed orbits for specific stars.
- Procedural generation methods should accept data-driven hints (habitable zone, ecosphere radii, body tags) from seed files.

## Mission Profiles
- Reference systems and bodies by `identifier`.
- Natural wormhole locations and story arc specifics live in mission event data (JSON/YAML), not in service code.

## Assignable Tasks
- Refactor `StarSim::ProceduralGenerator.generate_hybrid_system_from_seed` to:
  - Lock bodies based on `locked` flags in seed, not names.
  - Select stars/bodies via identifiers present in seed metadata.
  - Remove any system-specific assumptions.
- Add validation that warns when code paths rely on name literals.

## Acceptance Criteria
- No system-specific literals remain outside of `SOL` references.
- Hybrid generation works for any seed file; canonical data remains untouched.
- Mission profiles run using identifiers and event data only.

## References
- Playbook: [docs/developer/GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md)
- Validator: [galaxy_game/json-build-scripts/star_system_validator.rb](../json-build-scripts/star_system_validator.rb)
- Hybrid runner: [galaxy_game/scripts/generate_hybrid_system.rb](../scripts/generate_hybrid_system.rb)