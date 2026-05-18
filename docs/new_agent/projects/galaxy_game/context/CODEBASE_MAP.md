# Codebase Map
**Last Updated**: 2026-05-12
**Maintained By**: Session Strategist (Claude)

> This file exists for local models that may not have RAG access.
> Before searching the whole codebase, check here first.

---

## Top-Level Structure

```
galaxy_game/
├── app/
│   ├── controllers/        ← Rails controllers
│   ├── models/             ← ActiveRecord models
│   │   ├── celestial_bodies/   ← planets, stars, moons
│   │   │   └── spheres/        ← atmosphere, geosphere, hydrosphere, biosphere
│   │   ├── concerns/           ← shared model behaviors
│   │   └── units/              ← unit subclasses
│   └── services/           ← business logic services
│       ├── ai_manager/         ← AI mission planning
│       ├── generators/         ← data generators
│       ├── lookup/             ← data lookup services
│       ├── manufacturing/      ← production services
│       └── terra_sim/          ← terraforming simulation
├── data/
│   └── json-data/          ← all JSON operational data
│       ├── star_systems/       ← sol.json, sol-complete.json
│       ├── generated_star_systems/
│       └── operational_data/
│           └── units/          ← unit JSON configs
├── spec/
│   ├── controllers/
│   ├── factories/          ← FactoryBot factories
│   ├── fixtures/           ← test fixture files
│   ├── integration/        ← integration specs (do not touch)
│   ├── models/
│   │   └── units/          ← unit model specs
│   └── services/
└── docs/
    ├── agent/              ← legacy agent workflow
    └── new_agent/          ← current agent workflow (here)
```

---

## Key Files by Domain

### Units
| File | Purpose |
|---|---|
| `app/models/units/base_unit.rb` | Base class — job_types, supports_job_type?, processing_type |
| `app/models/units/robot.rb` | Primary reference pattern |
| `app/models/units/battery.rb` | Secondary reference pattern |
| `app/models/units/habitat.rb` | population_capacity only |
| `spec/models/units/base_unit_spec.rb` | Unit specs including job_types tests |

### Celestial Bodies & Spheres
| File | Purpose |
|---|---|
| `app/models/celestial_bodies/spheres/geosphere.rb` | stored_volatiles, calculate_volatile_release |
| `app/models/celestial_bodies/spheres/atmosphere.rb` | atmosphere composition |
| `app/models/celestial_bodies/spheres/hydrosphere.rb` | water/liquid tracking |
| `app/models/celestial_bodies/spheres/biosphere.rb` | biome management |

### Services
| File | Purpose |
|---|---|
| `app/services/planet_update_service.rb` | Planet simulation — insolation/albedo calculations |
| `app/services/terra_sim/geosphere_simulation_service.rb` | Geosphere simulation |
| `app/services/terra_sim/biosphere_simulation_service.rb` | balance_biomes, moisture levels |
| `app/services/terra_sim/volatile_phase_transition_service.rb` | Volatile release |
| `app/services/ai_manager/mission_planner_service.rb` | Pattern-specific planetary changes |
| `app/services/manufacturing/component_production_service.rb` | I-beam production, materials |
| `app/services/lookup/material_lookup_service.rb` | JSON material file lookup |
| `app/services/generators/game_data_generator.rb` | JSON data generation |
| `app/services/wormhole_consortium_formation_service.rb` | Consortium creation |
| `app/services/star_sim/system_builder_service.rb` | Loads star system JSON |

### Controllers
| File | Purpose |
|---|---|
| `app/controllers/admin/map_studio_controller.rb` | celestial_bodies_count, target_planets |
| `app/controllers/game_controller.rb` | planet_count |
| `app/controllers/terrestrial_planets_controller.rb` | PATCH update — 422 response |

### Data Files
| Path | Purpose |
|---|---|
| `data/json-data/star_systems/sol.json` | Sol system data — sphere-separated |
| `data/json-data/star_systems/sol-complete.json` | Complete Sol reference |
| `data/json-data/operational_data/units/` | Unit JSON configs |
| `app/data/star_systems/` | Additional star system files (generated) |

### Factories
| File | Key Factories |
|---|---|
| `spec/factories/terrestrial_planets.rb` | insolation: 1361.0 |
| `spec/factories/` | All FactoryBot factories — check here before grepping |

### Constants & Paths
| File | Purpose |
|---|---|
| `app/lib/galaxy_game/paths.rb` (or similar) | GalaxyGame::Paths constants — always use these |

---

## Active Failure Areas (2026-05-12)

Quick reference for the 22 current failures:

| Spec | Location | Root Cause Summary |
|---|---|---|
| `game_spec.rb:66` | `planet_update_service.rb:214` | insolation nil on test planet |
| `wormhole_consortium_service_spec.rb` | factory | member not corporation type |
| `game_data_generator_spec.rb:22` | `spec/fixtures/` | missing sample_template.json |
| `material_lookup_service_spec.rb:251` | service rescue block | logger.error not called |
| `mission_planner_service_spec.rb:80,90,98` | service | missing pattern-specific keys |
| `biosphere_simulation_service_spec.rb:158` | service | moisture not differentiated by climate |
| `component_production_integration_spec.rb` | service | regolith vs depleted_regolith mismatch |
| `map_studio_controller_spec.rb` | controller query | count inflated by leaked records |
| `game_controller_spec.rb:92` | controller query | planet_count inflated |
| `terrestrial_planets_spec.rb:105` | controller | returns 200 instead of 422 |
| Integration specs (7) | various | do not touch until unit layer clean |

---

## Do Not Touch (Integration Specs)

These are quarantined until unit/service layer is clean:
- `spec/integration/terraforming_integration_spec.rb`
- `spec/integration/terraforming_workflow_spec.rb`
- `spec/integration/shell_printing_game_loop_spec.rb`
- `spec/integration/ai_manager/escalation_integration_spec.rb`

---

## Corrupted JSON Files (Known)

These files have parse errors — do not use as reference:
- `app/data/star_systems/alpha_centauri.json`
- `app/data/star_systems/wolf_359.json`
- `app/data/generated_star_systems/djew-716790.json`
- `app/data/generated_star_systems/fr-488530.json`
- `app/data/operational_data/units/production/fabricators/regolith_shell_printer_mk1_data.json`
- `app/data/operational_data/units/production/fabricators/regolith_shell_printer_mk2_data.json`
- `app/data/operational_data/units/production/fabricators/regolith_shell_printer_mk3_data.json`
