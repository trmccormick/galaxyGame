# 2026-04-03-MEDIUM-ARCHITECTURE-GEOSPHERE INITIALIZER PROCEDURAL ARCHITECTURE

**Agent:** GPT-4.1 (0.25x)
**Priority:** MEDIUM
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Task: GeosphereInitializer Procedural Architecture
## Context
This file contains the architecture section from the original geosphere_initializer_architecture_backlog.md, preserved for future proced...

---

## Original Content

# Task: GeosphereInitializer Procedural Architecture
## Context
This file contains the architecture section from the original geosphere_initializer_architecture_backlog.md, preserved for future procedural implementation work.

## Requirements for Procedural Path
- Derive geosphere properties (geological_activity, tectonic_activity, crust_composition, regolith_depth, regolith_particle_size, weathering_rate) from physical parameters (mass, density, age, orbital zone, etc.).
- Resolution order: JSON-specified > computed > nil.
- Add `data_confidence` enum to geospheres (observed, modeled, generated) when procedural path is built.
- Do NOT call `GeosphereInitializer` from `SystemBuilderService` for seeded systems.
- Do NOT randomize with rand(); use physics-based derivation.

## Files to Modify (when ready)
- `app/services/terra_sim/geosphere_initializer.rb` (full refactor)
- `app/services/star_sim/planetary_seed_generator.rb` (wire to initializer)
- `db/migrate/` (add data_confidence enum)
- `app/data/solar_systems/sol-complete.json` (add regolith_attributes for Luna, Mars, Mercury)

## Reference
See task file and docs/architecture for full context and rationale.

