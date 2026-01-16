# Alpha Centauri Star System Validator & Generator (Scaffold)

Purpose: Validate the existing Alpha Centauri star system JSON and, if needed, generate a separate derived file without overwriting known data.

## Important: Source of Truth Exists
- Known canonical file: [data/json-data/star_systems/alpha_centauri.json](data/json-data/star_systems/alpha_centauri.json)
- Do not overwrite or replace this file. Use the validator to confirm compliance and optionally produce a new derived JSON under a different path.

## Validator: Check Anchor Law & Basic Schema
```bash
# Inside web container (cwd: /home/galaxy_game) — validate canonical star system JSON
ruby ./json-build-scripts/star_system_validator.rb \
  --input app/data/star_systems/alpha_centauri.json \
  --anchor-min-mass 1e16
```

- Reports:
  - Anchor Law compliance (any body or star mass ≥ minimum threshold)
  - Basic field presence (galaxy block, stars list, celestial_bodies)
  - Optional notes on wormhole/system metadata

## Optional: Generator (Derived File Only)
If you need a separate, opinionated system doc for prototyping, generate to a new path (do not overwrite `star_systems/alpha_centauri.json`).

```bash
# Inside web container (cwd: /home/galaxy_game) — generate a derived system JSON (prototype-only)
ruby ./json-build-scripts/alpha_centauri_generator.rb \
  --output app/data/systems/alpha_centauri_prototype.json
```

- Defaults: `system_name=Alpha Centauri`, `identifier=ALC-2026`, `star_type=G2V`, `anchor_law.min_mass_kg=1e16`
- Keep prototype files separate from canonical `star_systems` data.

## Hybrid Generation (Fill Missing Data from Canonical Seed)
Use the StarSim procedural generator to fill in missing bodies while preserving ground truth.

```bash
# Inside web container (cwd: /home/galaxy_game)
ruby ./scripts/generate_hybrid_alpha_centauri.rb \
  --seed app/data/star_systems/alpha_centauri.json
```

- Output path: under `GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH` (timestamped `hybrid_[identifier]_[ts].json`).
- Behavior: Preserves stars and Proxima Centauri b as immutable; fills specific orbits for Alpha Centauri A/B; marks new bodies `unclaimed_procedural`.
- Caution: Canonical seed is read-only; hybrid outputs go to the generated systems path.

## Assignment Template (Atomic)
- Steps:
  - Run validator against the canonical file.
  - If prototyping, generate derived JSON to a new path; back up prior prototype to `tmp/pre_revert_backup/`.
  - Update related system docs where needed (AOL / GUARDRAILS references).
  - Atomic commit (code + docs).
- Acceptance:
  - Validator runs and reports compliance status.
  - Prototype JSON (if generated) is present and well-formed; canonical file untouched.

## References
- [docs/GUARDRAILS.md](../GUARDRAILS.md)
- [docs/systems/aol-732356.md](../systems/aol-732356.md)
- Playbook: [docs/developer/GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md)
