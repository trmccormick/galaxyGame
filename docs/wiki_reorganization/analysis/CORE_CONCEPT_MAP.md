# Core Concept Map — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Identify major game concepts and their current owners  
**Rule**: Document what exists; do not propose changes yet

---

## Simulation Entities

### Universe / Galaxy

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/galaxy.rb`, `docs/architecture/starsim/OVERVIEW.md`, `docs/architecture/starsim/celestial_bodies.md` |
| **Files that reference it** | `app/services/star_sim/system_builder_service.rb`, `app/services/star_sim/system_generator_service.rb`, `data/json-data/star_systems/*.json` |
| **Current understanding** | The highest-level container. A Galaxy contains multiple SolarSystem instances. Each solar system has its own JSON data file (sol.json, alpha_centauri.json, etc.). StarSim handles procedural generation for systems beyond known data. |
| **Likely owner** | `StarSim::SystemBuilderService` / `StarSim::SystemGeneratorService` |

### Solar System

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/solar_system.rb`, `data/json-data/star_systems/sol/`, `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md` |
| **Files that reference it** | `app/services/star_sim/` (all services), `app/services/planet/`, `app/services/terra_sim/` |
| **Current understanding** | A collection of celestial bodies orbiting a star. Sol system has precomputed JSON data; other systems use procedural generation. Each body has a hierarchical type (star, planet, moon, minor body). |
| **Likely owner** | `SolarSystem` model + `StarSim::SystemBuilderService` |

### Celestial Body

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/celestial_bodies/celestial_body.rb`, `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md`, `docs/architecture/starsim/celestial_bodies.md` |
| **Files that reference it** | 50+ model files under `app/models/celestial_bodies/`, all StarSim services, TerraSim services |
| **Current understanding** | Base class for all physical bodies in space. Hierarchical: Star → Planet/Moon/MinorBody → subtypes (rocky, ocean, gaseous, ice_giant, gas_giant, brown_dwarf, dwarf_planet). Each body has spheres (atmosphere, hydrosphere, geosphere, biosphere) and features (craters, lava tubes, skylights, etc.). |
| **Likely owner** | `CelestialBody` model + `StarSim::PlanetBuilder` / `StarSim::StarGenerator` |

### Star

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/celestial_bodies/star.rb`, `docs/architecture/starsim/star_naming_architecture.md` |
| **Files that reference it** | `app/services/star_sim/star_generator.rb`, `data/json-data/star_systems/*.json` |
| **Current understanding** | The central body of a solar system. Has spectral type, luminosity, habitable zone. Star naming follows documented architecture. |
| **Likely owner** | `StarGenerator` service + `StarSim::HabitableZoneCalculator` |

### Planetary Body (Planet)

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/celestial_bodies/planets/planet.rb`, `docs/architecture/simulation/hycean_planet_system.md` |
| **Files that reference it** | `app/services/star_sim/planet_builder.rb`, `app/services/star_sim/planet_type_classifier.rb`, `app/services/terra_sim/` |
| **Current understanding** | Planets are classified by type: rocky, ocean, gaseous, ice giant. Each has a composition estimated by `PlanetCompositionEstimator`. Rocky planets can be terraformed; ocean planets have hydrosphere simulation; hycean planets are a special water-world subtype. |
| **Likely owner** | `PlanetBuilder` + `PlanetTypeClassifier` + `PlanetCompositionEstimator` |

### Moon / Satellite

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/celestial_bodies/moons/`, `app/models/celestial_bodies/satellites/` |
| **Files that reference it** | `app/services/star_sim/moon_generator.rb`, `data/json-data/star_systems/sol/` |
| **Current understanding** | Two parallel hierarchies: Moons (large_moon, ice_moon, small_moon) and Satellites. MoonGenerator handles procedural moon creation. Major Sol moons have specific data files. |
| **Likely owner** | `MoonGenerator` service |

### Minor Body (Asteroid, Comet, KBO, Protoplanet)

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/celestial_bodies/minor_bodies/`, `docs/architecture/systems/asteroid_conversion_physics.md` |
| **Files that reference it** | `app/services/star_sim/asteroid_belt_generator.rb`, `app/services/star_sim/oort_cloud_generator.rb` |
| **Current understanding** | Asteroids, comets, Kuiper Belt Objects, and protoplanets. Protoplanets are classified for large asteroids (Vesta, Psyche). Asteroids can be hollowed for station conversion (asteroid_relocation_tug concept). |
| **Likely owner** | `AsteroidBeltGenerator` + `OortCloudGenerator` |

### Settlement

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/settlement/base_settlement.rb`, `docs/architecture/settlement/README.md`, `docs/architecture/structures/README.md` |
| **Files that reference it** | `app/services/settlements/cost_analyzer.rb`, `app/services/ai_manager/settlement_manager.rb`, `app/services/ai_manager/settlement_plan_generator.rb` |
| **Current understanding** | Administrative container for structures and units. Settlements can be surface-based or orbital. Types include: OrbitalDepot, OrbitalSettlement, SpaceStation. Settlements have life support, docking, and module requirements. |
| **Likely owner** | `Settlement::BaseSettlement` model + `AIManager::SettlementManager` |

### Structure

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/structures/base_structure.rb`, `docs/architecture/structures/README.md` |
| **Files that reference it** | 15+ structure model files, `app/services/construction/`, `app/services/pressurization/` |
| **Current understanding** | Physical assets attached to settlements. Types: Worldhouse (lava tube enclosure), CraterDome, HabitationFacility, Hangar, ManufacturingFacility, OrbitalStructure, PowerStation, SolarArray, Skylight, StorageFacility, AccessPoint, ConvertedBase, SegmentComponent. All inherit from BaseStructure. |
| **Likely owner** | `Structures::BaseStructure` + `Construction::*` services |

### Component / Module

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/modules/base_module.rb`, `data/json-data/templates/module_blueprint_v1.2.json`, `docs/architecture/core/modular_containers.md` |
| **Files that reference it** | `app/services/manufacturing/assembly_service.rb`, `app/services/lookup/module_lookup_service.rb` |
| **Current understanding** | Modules are building blocks for structures and settlements. They have blueprints (module_blueprint_v1.2.json) and operational data. Components appear to be smaller sub-elements within modules/blueprints. The distinction between "component" and "module" is not clearly documented. |
| **Likely owner** | `Modules::BaseModule` + `Manufacturing::AssemblyService` |

### Unit

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/units/base_unit.rb`, `docs/architecture/units/base_unit.md`, `docs/architecture/glossary/system_mechanics.md` |
| **Files that reference it** | 14+ unit model files, `app/services/manufacturing/unit_deployment.rb`, `app/services/lookup/unit_lookup_service.rb` |
| **Current understanding** | Deployable, mobile, or portable assets tracked by `unit_id`. Types: Robot, Habitat, Extractor, Fabricator, Processor, Battery, Computer, LifeSupport, Propulsion, Storage, PlanetaryUmbilicalHub. All inherit from Units::BaseUnit which provides inventory, operational_data, and location tracking. |
| **Likely owner** | `Units::BaseUnit` + `Manufacturing::UnitDeployment` |

### Craft / Ship

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/models/craft/base_craft.rb`, `docs/architecture/stations/CRAFT_OPERATIONAL_EVOLUTION.md` |
| **Files that reference it** | `app/services/lookup/craft_lookup_service.rb`, `data/json-data/blueprints/crafts/` |
| **Current understanding** | Mobile vehicles: Harvester, Rover, Ship, Spaceship, Satellite subtypes, Transport subtypes. Craft have variant management (VariantManager), operational data, and blueprints. Cyclers are described as "evolution from simple transport vehicles to portable space stations." |
| **Likely owner** | `Craft::BaseCraft` + `Craft::VariantManager` |

---

## Systems

### World Generation (StarSim)

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/starsim/OVERVIEW.md`, `app/services/star_sim/` (25+ services) |
| **Files that reference it** | All star_sim services, `data/json-data/star_systems/*.json`, `data/geotiff/processed/*.asc.gz` |
| **Current understanding** | Three-tier system: Tier 1 (static JSON for known systems like Sol), Tier 2 (hybrid — static + procedural gap-filling for Local Bubble), Tier 3 (fully procedural for exotic systems). Weathering engine regresses goal-state maps to barren states. Dynamic population spawns transient objects. Fidelity tiers govern data source selection. |
| **Likely owner** | `StarSim::SystemBuilderService` + `StarSim::ProceduralGenerator` |

### Terraforming (TerraSim)

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/terrasim/OVERVIEW.md`, `app/services/terra_sim/` (13 services), `docs/gameplay/terraforming.md` |
| **Files that reference it** | All terra_sim services, `app/models/terraforming_project.rb`, `docs/developer/TERRAFORMING_SIMULATION.md` |
| **Current understanding** | Simulates planetary surface and climate evolution. Takes StarSim-generated heightmaps and applies regression/weathering logic. Key services: atmosphere simulation, biosphere simulation, geosphere simulation, hydrosphere simulation, volatile phase transitions, biome validation. Known issue: Civ4 shoreline flooding requires regression filter. |
| **Likely owner** | `TerraSim::Simulator` + individual sphere simulation services |

### Economy

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/economy/` (13 files), `app/models/financial/`, `app/models/market/`, `app/services/financial/`, `app/services/market/` |
| **Files that reference it** | All financial and market models/services, `docs/reference/GAME_DESIGN_INTENT.md` |
| **Current understanding** | Dual-currency system (GCC/USD) with phased exchange evolution. Polymorphic account model. Virtual ledger for NPC-to-NPC trading. Market system with NPC price calculation, demand service, trade execution. Player contract system with courier, manufacturing, exploration, and station expansion contracts. AI Manager provides player-first mission priority. |
| **Likely owner** | `Financial::Account` + `Market::Marketplace` + `AIManager::EconomicForecasterService` |

### Manufacturing

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md`, `docs/architecture/isru/README.md`, `app/services/manufacturing/` (17 services) |
| **Files that reference it** | All manufacturing services, `data/json-data/blueprints/`, `data/json-data/templates/`, `app/models/blueprint.rb` |
| **Current understanding** | Chain: Raw Materials → Processed Materials → Components → Blueprints → Assembly → Units/Craft. ISRU (In-Situ Resource Utilization) enables distributed fabrication. 3D-printed fabricators Mk1-Mk3 are foundational. Regolith processing, component production, material processing, shell printing, byproduct manufacturing. Blueprint cost schema v1.1 is the current standard. |
| **Likely owner** | `Manufacturing::Service` + `Manufacturing::ProductionService` + `Manufacturing::AssemblyService` |

### AI / AI Manager

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md`, `app/services/ai_manager/` (80+ services) |
| **Files that reference it** | All ai_manager services, `docs/architecture/services/ai_manager/` (20+ docs), `data/learned_patterns.json` |
| **Current understanding** | Central orchestration for all AI-driven expansion and logistics. Core concepts: 89→8 architecture (documented as 8 core files but actually 80+ services), consortium voting (66% quorum), Hammer Protocol (EM reset/snap control), BFS wayfinding via wormhole network, pattern learning from successful deployments, strategic evaluation, mission planning/scoring. AI Manager learns from player and NPC actions to improve future decisions. |
| **Likely owner** | `AIManager` (master orchestrator) + `AIManager::ServiceOrchestrator` + `AIManager::SystemOrchestrator` |

### Rendering / Terrain Visualization

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/terrain/generation_and_rendering.md`, `app/javascript/`, `app/assets/`, `data/tilesets/` |
| **Files that reference it** | All JS rendering files, tileset services, terrain analysis services, `data/galaxy_game_tileset.json` |
| **Current understanding** | Three-layer architecture: Generation (pure elevation data) → Rendering (visualization based on elevation/body properties) → Data Storage (geosphere.terrain_map). NASA GeoTIFF = ground truth for Sol bodies. FreeCiv/Civ4 = training data only. Grid sizing is diameter-based with 2:1 aspect ratio. Tile pixel size independent of grid size. Multiple tileset options (Trident 30x30, Trident modified 64x64, BigTrident 60x60, Engels 45x45). |
| **Likely owner** | `Terrain::MultiBodyTerrainGenerator` + `Tileset::AlioTilesetService` / `Tileset::FreeCivTilesetService` |

### Asset Pipeline

| Aspect | Details |
|--------|---------|
| **Where defined** | `app/assets/`, `data/tilesets/`, `docs/developer/TILESET_README.md` |
| **Files that reference it** | Asset manifest, settlement sprites/atlas, tileset images, `generate_sprites.py`, `chromakey_spritesheet.py` |
| **Current understanding** | Rails asset pipeline with custom sprite generation. Settlement spritesheets generated via Python chromakey process. Tilesets include original Trident, FreeCiv alien, and community-contributed variants. Galaxy regional atlas JSON defines color/texture mappings. |
| **Likely owner** | `app/assets/` + Python sprite generation scripts |

### Technology Progression

| Aspect | Details |
|--------|---------|
| **Where defined** | `data/json-data/tech_tree/` (19 categories), `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` |
| **Files that reference it** | All tech tree JSON files, blueprint required_technology fields, `app/services/economics/cost_validator.rb` |
| **Current understanding** | 19 technology categories: biotechnology, computing_ai, construction_manufacturing, diplomatic_trade, exploration_science, life_support, materials_science, mining_resource_processing, particle_physics, planetary_engineering, power_generation, propulsion_systems_v1, research_system, robotics, sensor_instrumentation, social_governance, space_construction, xenoarchaeology. Technology Level (Tier 1-4+) is a settlement-wide capability metric. MK generation (Mk1-Mk3) is per-blueprint engineering iteration. Relationship between Tech Level and MK is an **open question**. |
| **Likely owner** | `data/json-data/tech_tree/` + blueprint `required_technology` fields |

### Logistics

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/logistics/logistics_architecture.md`, `app/services/logistics/` (14 services) |
| **Files that reference it** | All logistics services, `app/models/logistics/`, `docs/wiki/Logistics-and-Hauling.md` |
| **Current understanding** | Interplanetary trade and transportation. Contract fulfillment, manifest generation, route cost calculation, shipping calculator, transport cost service, shortage detection. ISRU capability management for local resource utilization. Player contracts for transport between locations. |
| **Likely owner** | `Logistics::ContractService` + `Logistics::ManifestGenerator` + `Logistics::RouteCostCalculator` |

### Wormhole Network

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/wormhole/00_executive_summary.md`, `docs/architecture/logistics/navigation/WORMHOLE_NETWORK.md`, `app/models/wormhole.rb` |
| **Files that reference it** | All wormhole services, AI Manager expansion services, `docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md` |
| **Current understanding** | Interstellar graph of wormhole connections. BFS wayfinding for optimal paths. Consortium voting (66% quorum) governs expansion decisions. EM (energy-matter) physics affects path costs. Natural discovery events trigger SystemArchitect for infrastructure deployment. Gravitational anchor detection (≥10^16 kg). Multi-wormhole events enable network expansion. Hammer Protocol manages controlled snap/reset events. |
| **Likely owner** | `AIManager::WormholeCoordinator` + `AIManager::WormholeManager` + `AIManager::ExpansionService` |

### Construction

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/operations/component_production_logic.md`, `app/services/construction/` (6 services) |
| **Files that reference it** | All construction services, pressurization services, structure models |
| **Current understanding** | Dome service, covering calculator, skylight calculator, orbital shipyard service, construction manager, logistics service. Pressurization system with 6 specialized services (base, craft, habitat, lavatube, structure, unit). Lava tube sealing service for worldhouse construction. |
| **Likely owner** | `Construction::ConstructionManager` + `Pressurization::*` services |

---

## Cross-Cutting Concepts

### JSON-Driven Architecture

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md`, `docs/developer/JSON_DATA_GUIDE.md`, `data/json-data/templates/` (70+ templates) |
| **Files that reference it** | All JSON data files, Blueprint model, all lookup services |
| **Current understanding** | "JSON describes what is estimated to exist. The game engine determines state and emergent interactions." Blueprints define structure; operational data defines runtime state. Templates provide base schemas (craft_blueprint_v1.7.json, unit_blueprint_v1.4.json, etc.). Versioned templates indicate ongoing evolution. |
| **Likely owner** | `Blueprint` model + `Lookup::*Service` classes |

### Pattern Learning

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/services/ai_manager/AI_PATTERN_LEARNING_SYSTEM.md`, `data/learned_patterns.json`, `data/json-data/ai_patterns.json` |
| **Files that reference it** | AI Manager pattern services, mission profiles, `app/services/ai_manager/pattern_loader.rb` |
| **Current understanding** | AI Manager learns from successful deployments and applies patterns to new systems. Pattern loading, validation, and target mapping are separate services. Learned patterns stored in JSON files. Used for mission planning, resource allocation, and settlement strategies. |
| **Likely owner** | `AIManager::PatternLoader` + `AIManager::PatternValidator` |

### Dual Economy

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/architecture/intent/DUAL_ECONOMY_INTENT.md`, `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` |
| **Files that reference it** | Financial models, market services, AI Manager economic services |
| **Current understanding** | Two currencies: GCC (space-side) and USD (Earth-side). Bootstrap phase: 1:1 peg. Evolves through soft peg → managed float → uncoupled. Virtual ledger allows NPC-to-NPC trading without GCC movement. Player contracts pay 1.5x vs NPC execution. |
| **Likely owner** | `Financial::Currency` + `Financial::ExchangeRateService` |

### Four-Layer Hybrid Vision

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/GLOSSARY_SYSTEM_MECHANICS.md` |
| **Files that reference it** | All simulation and rendering documentation |
| **Current understanding** | Macro layer (planetary, 100-year tactical + 500-1000+ year strategic), Meso layer (surface view, Civ-style), Micro layer (TerrainForge, SimCity-style industrial), Economic layer (player-driven market). Each layer operates at different scales and timeframes. |
| **Likely owner** | Cross-cutting architectural principle |

### Player Experience Boundaries

| Aspect | Details |
|--------|---------|
| **Where defined** | `docs/gameplay/player_experience_boundaries.md`, `docs/reference/GAME_DESIGN_INTENT.md` |
| **Files that reference it** | All player-facing documentation, contract systems, UI implementation docs |
| **Current understanding** | Four design pillars: Scientific accuracy (NASA data), Strategic resource management (finite resources, extraction costs), Exploration and discovery (unique planets), Long-term planning (time matters, dependencies enforced). Player role: primary mission priority over NPC. Admin control for manual mission design teaching AI patterns. |
| **Likely owner** | `Player` model + `AIManager::ContractCreationService` |

---

## Concepts Needing Further Investigation

| Concept | Reason | Where to Look |
|---------|--------|---------------|
| Digital Twin | Referenced in docs but unclear how it integrates | `app/services/digital_twin_service.rb`, `docs/developer/DIGITAL_TWIN_SANDBOX.md` |
| Precursor Mission | Appears in multiple docs with different scopes | `docs/architecture/stations/precursor_mission_bootstrap_architecture.md`, `data/json-data/precursor_mission_setup_methane.json` |
| EM (Energy-Matter) Physics | Referenced in AI Manager but definition unclear | `docs/architecture/systems/em_power_shield_tiers.md`, `app/services/em_harvesting_service.rb` |
| Orbital Mechanics | Separate service namespace but limited files | `app/services/orbital_mechanics/transfer_calculator.rb` |
| Story Events | Single model file, unclear scope | `app/models/story_events/multi_wormhole_event.rb` |
| Claims System | Namespace exists but unclear purpose | `app/models/claims/` directory |
| Location System | Multiple references, unclear architecture | `app/models/location_record.rb`, `app/services/location_service.rb`, `app/services/location_selector.rb` |
