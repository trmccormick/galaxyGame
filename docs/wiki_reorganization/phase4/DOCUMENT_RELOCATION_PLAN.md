# Document Relocation Plan — Phase 4

**Created**: 2026-07-16  
**Purpose**: Every document's current location → canonical wiki location → recommended action.

---

## Relocation Method

| Action | Meaning |
|--------|---------|
| **Move to wiki** | Document becomes a canonical or supporting wiki page at its new location |
| **Merge then archive** | Content merged into target document; source archived |
| **Split and redistribute** | Content split across multiple wiki locations; source archived |
| **Archive as-is** | Document moved to docs/archive/ without modification |
| **Archive to historical/** | Document moved to docs/archive/historical/ for development context |

---

## 1. Vision Section Relocations

### START_HERE (Entry Point)

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/README.md | Merge content into | START_HERE |
| docs/wiki/getting_started.md | Redirect to | START_HERE |
| docs/storyline/README.md | Merge content into | START_HERE |
| docs/developer/README.md | Merge content into | START_HERE |
| docs/reference/README.md | Merge content into | START_HERE |

### VISION_AND_PURPOSE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/reference/GAME_DESIGN_INTENT.md | Move to | VISION_AND_PURPOSE |
| docs/planning/GALAXY-GAME-PLANNING-GOALS.md | Merge into | PROJECT_GOALS |

### DESIGN_PHILOSOPHY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/reference/GAME_DESIGN_INTENT.md | Move to | DESIGN_PHILOSOPHY |
| docs/architecture/intent/ (all intent docs) | Merge key content into | DESIGN_PHILOSOPHY |

### CORE_PRINCIPLES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/GUARDRAILS.md | Move to | CORE_PRINCIPLES |
| docs/architecture/adrs/GUARDRAILS.md | Merge into | CORE_PRINCIPLES |
| docs/architecture/intent/operational_data_guardrails.md | Merge into | CORE_PRINCIPLES |

### PLAYER_EXPERIENCE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/gameplay/player_experience_boundaries.md | Move to | PLAYER_EXPERIENCE |
| docs/wiki/Player-Roles-and-Alignment.md | Move to | PLAYER_EXPERIENCE |
| docs/architecture/intent/PLAYER_UI_VISION.md | Merge into | PLAYER_EXPERIENCE |
| docs/developer/UI_IMPLEMENTATION.md | Merge into | PLAYER_EXPERIENCE |
| docs/developer/planet_ui_development_plan.md | Merge into | PLAYER_EXPERIENCE |

### PROJECT_GOALS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/planning/GALAXY-GAME-PLANNING-GOALS.md | Move to | PROJECT_GOALS |
| docs/wiki_reorganization/phase3_alignment/README.md | Merge into | START_HERE (exec summary) |

---

## 2. Story Section Relocations

### STORY_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/storyline/01_story_arc.md | Move to | STORY_OVERVIEW |
| docs/storyline/03_consortium_framework.md | Merge into | STORY_OVERVIEW |
| docs/storyline/04_terra_gen_consortium.md | Merge into | STORY_OVERVIEW |
| docs/architecture/intent/precursor_bootstrap_intent.md | Merge into | STORY_OVERVIEW |

### NARRATIVE_ACTS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/storyline/02_crisis_mechanics.md | Move to | NARRATIVE_ACTS |
| docs/wiki/Scenario-Super-Mars.md | Merge into | NARRATIVE_ACTS |

### IMPLEMENTATION_PHASES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/storyline/10_implementation_phases.md | Move to | IMPLEMENTATION_PHASES |
| docs/architecture/planning/DEVELOPMENT_ROADMAP.md | Merge into | IMPLEMENTATION_PHASES |
| docs/planning/AI-MANAGER—LUNA-BEHAVIOR-GOALS.md | Merge into | IMPLEMENTATION_PHASES |
| docs/planning/MISSION_PHASING_AND_TIMELINE.md | Merge into | IMPLEMENTATION_PHASES |
| docs/planning/GALAXY-GAME-PHASE-ALIGNMENT.md | Merge into | IMPLEMENTATION_PHASES |
| docs/storyline/06_deployment_hierarchy.md | Merge into | IMPLEMENTATION_PHASES |
| docs/architecture/intent/precursor_bootstrap_intent.md | Merge into | IMPLEMENTATION_PHASES |
| docs/architecture/operations/precursor_industrial_loop.md | Merge into | IMPLEMENTATION_PHASES |
| docs/architecture/stations/precursor_mission_bootstrap_architecture.md | Merge into | IMPLEMENTATION_PHASES |

### HISTORICAL_TIMELINE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/storyline/11_lore_canon.md | Move to | HISTORICAL_TIMELINE |
| docs/storyline/12_lore_mechanics_summary.md | Merge into | HISTORICAL_TIMELINE |

### SNAP_EVENT

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/storyline/snap_event_and_network_expansion.md | Move to | SNAP_EVENT |

### WORMHOLE_HISTORY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/wormhole/00_executive_summary.md | Merge into | WORMHOLE_HISTORY |
| docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md | Move to | WORMHOLE_HISTORY |
| docs/wiki/Celestial-Systems.md | Merge into | WORMHOLE_HISTORY |

---

## 3. Universe Generation Section Relocations

### UNIVERSE_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/starsim/celestial_bodies.md | Move to | UNIVERSE_OVERVIEW |
| docs/wiki/Celestial-Systems.md | Merge into | UNIVERSE_OVERVIEW |

### SOL_SYSTEM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/starsim/solar_system.md | Move to | SOL_SYSTEM |
| docs/developer/DIAGNOSTIC_SOL_SEEDING.md | Merge into | SOL_SYSTEM |
| docs/developer/sol_data_organization.md | Merge into | SOL_SYSTEM |
| docs/developer/TERRAFORMABLE_PLANETS.md | Merge into | SOL_SYSTEM |

### EDEN_SYSTEM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/developer/ALPHA_CENTAURI_GENERATOR.md | Move to | EDEN_SYSTEM |
| docs/architecture/intent/precursor_bootstrap_intent.md | Merge into | EDEN_SYSTEM |
| docs/architecture/systems/alpha_centauri_prep.md | Merge into | EDEN_SYSTEM |

### LOCAL_BUBBLE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/developer/LOCAL_BUBBLE_EXPANSION.md | Move to | LOCAL_BUBBLE |

### STARS (Reference)

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/starsim/star_naming_architecture.md | Merge into | STARS |
| docs/architecture/intent/SYSTEM_CLASSIFICATION_INTENT.md | Merge into | STARS |

### CELESTIAL_BODIES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/starsim/celestial_bodies.md | Move to | CELESTIAL_BODIES |
| docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md | Merge into | CELESTIAL_BODIES |
| docs/developer/TERRAFORMABLE_PLANETS.md | Merge into | CELESTIAL_BODIES |
| docs/architecture/intent/SYSTEM_CLASSIFICATION_INTENT.md | Merge into | CELESTIAL_BODIES |

### NATURAL_WORMHOLES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/wormhole/WORMHOLE_SYSTEM.md | Move to | NATURAL_WORMHOLES |
| docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md | Merge into | NATURAL_WORMHOLES |
| docs/architecture/logistics/navigation/WORMHOLE_NETWORK.md | Merge into | NATURAL_WORMHOLES |
| docs/storyline/multi_wormhole_event.md | Merge into | NATURAL_WORMHOLES |
| docs/architecture/systems/survey_and_handshake_protocol.md | Merge into | NATURAL_WORMHOLES |

### ARTIFICIAL_WORMHOLES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/logistics/navigation/INTRA_SYSTEM_PORTALS.md | Move to | ARTIFICIAL_WORMHOLES |
| docs/architecture/intent/precursor_bootstrap_intent.md | Merge into | ARTIFICIAL_WORMHOLES |

---

## 4. Planetary Simulation Section Relocations

### SIMULATION_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/simulation/SIMULATION_SANDBOX.md | Archive (purpose unclear per Phase 3) |
| docs/storyline/05_physics_topology.md | Merge into | SIMULATION_OVERVIEW |

### STARSIM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/starsim/OVERVIEW.md | Move to | STARSIM |
| docs/architecture/starsim/PROCEDURAL_INTENT.md | Merge into | STARSIM |
| docs/architecture/starsim/MISSING_HOOKS.md | Merge into | STARSIM |
| docs/architecture/starsim/TECHNICAL_HISTORY.md | Archive to historical/ |
| docs/storyline/07_procedural_generation.md | Merge into | STARSIM |

### TERRASIM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/biology/terrasim_service.md | Move to | TERRASIM |
| docs/architecture/terrasim/OVERVIEW.md | Merge into | TERRASIM |

### GEOSPHERE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/simulation/geosphere_system.md | Move to | GEOSPHERE |
| docs/architecture/planning/geological_features_architecture.md | Merge into | GEOSPHERE |
| docs/architecture/planning/geological_features_design_intent.md | Merge into | GEOSPHERE |

### ATMOSPHERE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/simulation/atmospheric_maintenance_system.md | Move to | ATMOSPHERE |
| docs/reference/DESIGN_INTENT_SEALED_VOLUME_ATMOSPHERE.md | Merge into | ATMOSPHERE |

### HYDROSPHERE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/simulation/hydrosphere_system.md | Move to | HYDROSPHERE |

### BIOSPHERE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/biology/biology_models.md | Move to | BIOSPHERE |
| docs/architecture/simulation/biosphere_system.md | Merge into | BIOSPHERE |
| docs/architecture/simulation/biology_system.md | Merge into | BIOSPHERE |

### BIOME_SYSTEM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/biology/biome_model.md | Move to | BIOME_SYSTEM |
| docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md | Merge into | BIOME_SYSTEM |

### TERRAFORMING

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/gameplay/terraforming.md | Move to | TERRAFORMING |
| docs/architecture/simulation/biology_terraforming_guide.md | Merge into | TERRAFORMING |
| docs/developer/TERRAFORMING_SIMULATION.md | Merge into | TERRAFORMING |
| docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md | Merge into | TERRAFORMING |

### SIMULATION_PIPELINE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/terrain/generation_and_rendering.md | Merge into | SIMULATION_PIPELINE |
| docs/architecture/simulation/terrainforge_layer.md | Merge into | SIMULATION_PIPELINE |
| docs/architecture/simulation/visual_layer_stack.md | Archive (visual layers) |
| docs/architecture/systems/sphere_creation_optimization.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/AI_EARTH_MAP_GENERATION.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/AUTOMATIC_TERRAIN_GENERATOR.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/ELEVATION_DATA.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/LAYERED_RENDERING.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/MAP_SYSTEM.md | Merge into | SIMULATION_PIPELINE |

---

## 5. Game World Model Section Relocations

### WORLD_MODEL_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/settlement/README.md | Move to | WORLD_MODEL_OVERVIEW |
| docs/architecture/structures/README.md | Merge into | WORLD_MODEL_OVERVIEW |
| docs/storyline/06_deployment_hierarchy.md | Merge into | WORLD_MODEL_OVERVIEW |
| docs/architecture/concerns/has_units.md | Merge into | WORLD_MODEL_OVERVIEW |

### GALAXY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | GALAXY |

### SOLAR_SYSTEM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/starsim/solar_system.md | Move to | SOLAR_SYSTEM |
| docs/developer/DIAGNOSTIC_SOL_SEEDING.md | Merge into | SOLAR_SYSTEM |
| docs/developer/sol_data_organization.md | Merge into | SOLAR_SYSTEM |

### STAR

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | STAR |

### CELESTIAL_BODY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/starsim/celestial_bodies.md | Move to | CELESTIAL_BODY |
| docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md | Merge into | CELESTIAL_BODY |

### PLANET_ENVIRONMENT

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | PLANET_ENVIRONMENT |

### SETTLEMENT

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/settlement/README.md | Move to | SETTLEMENT |

### STRUCTURE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/structures/README.md | Move to | STRUCTURE |

### UNIT

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | UNIT |

---

## 6. Simulation Engine Section Relocations

### SIMULATION_ENGINE_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/simulation/SIMULATION_SANDBOX.md | Archive (purpose unclear per Phase 3) |
| docs/storyline/05_physics_topology.md | Merge into | SIMULATION_ENGINE_OVERVIEW |

### STAR_SIM_PIPELINE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/starsim/OVERVIEW.md | Move to | STAR_SIM_PIPELINE |
| docs/architecture/starsim/PROCEDURAL_INTENT.md | Merge into | STAR_SIM_PIPELINE |
| docs/architecture/starsim/MISSING_HOOKS.md | Merge into | STAR_SIM_PIPELINE |

### TERRA_SIM_PIPELINE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/biology/terrasim_service.md | Move to | TERRA_SIM_PIPELINE |
| docs/architecture/terrasim/OVERVIEW.md | Merge into | TERRA_SIM_PIPELINE |

### SIMULATION_DATA_OWNERSHIP

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | SIMULATION_DATA_OWNERSHIP |

### SIMULATION_INTEGRATION

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/simulation/terrainforge_layer.md | Merge into | SIMULATION_INTEGRATION |
| docs/architecture/systems/sphere_creation_optimization.md | Merge into | SIMULATION_INTEGRATION |

### SIMULATION_PIPELINE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/terrain/generation_and_rendering.md | Merge into | SIMULATION_PIPELINE |
| docs/architecture/simulation/visual_layer_stack.md | Archive (visual layers) |
| docs/developer/AI_EARTH_MAP_GENERATION.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/AUTOMATIC_TERRAIN_GENERATOR.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/ELEVATION_DATA.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/LAYERED_RENDERING.md | Merge into | SIMULATION_PIPELINE |
| docs/developer/MAP_SYSTEM.md | Merge into | SIMULATION_PIPELINE |

---

## 7. Economy Section Relocations

### ECONOMY_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/economy/economic_baseline.md | Move to | ECONOMY_OVERVIEW |
| docs/architecture/economy/financial_system.md | Merge into | ECONOMY_OVERVIEW |
| docs/architecture/economy/FISCAL_POLICY_AND_FEES.md | Merge into | ECONOMY_OVERVIEW |
| docs/wiki/Financial-Engine.md | Merge into | ECONOMY_OVERVIEW |
| docs/storyline/09_economic_systems.md | Merge into | ECONOMY_OVERVIEW |
| docs/architecture/systems/orphaned_system_economics.md | Merge into | ECONOMY_OVERVIEW |

### CURRENCY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/economy/CURRENCY_AND_EXCHANGE.md | Move to | CURRENCY |
| docs/architecture/intent/DUAL_ECONOMY_INTENT.md | Merge into | CURRENCY |
| docs/architecture/economy/VIRTUAL_LEDGER_FLOWS.md | Merge into | CURRENCY |

### MARKETS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/economy/MARKET_OPERATIONS.md | Move to | MARKETS |
| docs/architecture/economy/LEDGERS.md | Merge into | MARKETS |
| docs/wiki/Market-and-AI-Bootstrapping.md | Merge into | MARKETS |

### TRADING

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/economy/ (trading content) | Create new page | TRADING |

### NPC_ECONOMY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/wiki/Market-and-AI-Bootstrapping.md | Move to | NPC_ECONOMY |

### PLAYER_ECONOMY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | PLAYER_ECONOMY |

### CONTRACTS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/economy/CONTRACTS.md | Move to | CONTRACTS |
| docs/architecture/economy/PLAYER_CONTRACT_SYSTEM.md | Merge into | CONTRACTS |

### SUPPLY_AND_DEMAND

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | SUPPLY_AND_DEMAND |

### IMPORT_EXPORT

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | IMPORT_EXPORT |

### PRICING

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/economy/PRICE_DISCOVERY_LIFECYCLE.md | Move to | PRICING |
| docs/architecture/ai_manager/AI_MANAGER_PRICING_INTENT.md | Merge into | PRICING |
| docs/architecture/economy/ISRU_PRICING_MODEL.md | Merge into | PRICING |

### ECONOMIC_PHILOSOPHY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | ECONOMIC_PHILOSOPHY |

---

## 8. Manufacturing Section Relocations

### MANUFACTURING_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md | Move to | MANUFACTURING_OVERVIEW |
| docs/reference/INVENTORY_AND_STORAGE.md | Merge into | MANUFACTURING_OVERVIEW |

### RESOURCES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | RESOURCES |
| docs/api/materials.md | Merge into | RESOURCES |

### ISRU

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/isru/README.md | Move to | ISRU |
| docs/architecture/isru/3d_printing.md | Merge into | ISRU |
| docs/architecture/isru/cnt_production.md | Merge into | ISRU |
| docs/architecture/systems/LUNA_ISRU_GAS_PROCESSING_AND_SKIMMER_OPERATIONS.md | Merge into | ISRU |
| docs/architecture/operations/isru_operations.md | Merge into | ISRU |
| docs/architecture/systems/life_support_waste_recycling_architecture.md | Merge into | ISRU |

### BLUEPRINTS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md | Move to | BLUEPRINTS |
| docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md | Merge into | BLUEPRINTS |
| docs/developer/COST_SCHEMA_CONSUMPTION_GUIDE.md | Merge into | BLUEPRINTS |
| docs/wiki/System-Blueprints.md | Merge into | BLUEPRINTS |

### CONSTRUCTION

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/simulation/construction_system.md | Move to | CONSTRUCTION |
| docs/architecture/isru/3d_printing.md | Merge into | CONSTRUCTION |
| docs/architecture/systems/job_system_mechanics_spec.md | Merge into | CONSTRUCTION |

### TECHNOLOGY_LEVELS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | TECHNOLOGY_LEVELS |
| docs/architecture/systems/em_technology_tree.md | Merge into | TECHNOLOGY_LEVELS |

### MK_GENERATIONS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | MK_GENERATIONS |

### FACTORIES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | FACTORIES |

### RESOURCE_PROCESSING

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/operations/component_production_logic.md | Move to | RESOURCE_PROCESSING |
| docs/architecture/isru/cnt_production.md | Merge into | RESOURCE_PROCESSING |

### MANUFACTURING_PIPELINE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | MANUFACTURING_PIPELINE |
| docs/architecture/logistics/SYSTEM_INDUSTRIAL_CHAINS.md | Merge into | MANUFACTURING_PIPELINE |

---

## 9. Settlements Section Relocations

### SETTLEMENTS_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/settlement/README.md | Move to | SETTLEMENTS_OVERVIEW |
| docs/storyline/06_deployment_hierarchy.md | Merge into | SETTLEMENTS_OVERVIEW |
| docs/architecture/concerns/has_units.md | Merge into | SETTLEMENTS_OVERVIEW |

### COLONIES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | COLONIES |

### SETTLEMENTS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | SETTLEMENTS |

### STRUCTURES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/structures/README.md | Move to | STRUCTURES |

### WORLDHOUSES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/intent/worldhouse_intent.md | Move to | WORLDHOUSES |
| docs/architecture/systems/environmental_volume_intent.md | Merge into | WORLDHOUSES |

### ORBITAL_SETTLEMENTS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | ORBITAL_SETTLEMENTS |
| docs/developer/orbital_depot_migration.md | Merge into | ORBITAL_SETTLEMENTS |

### POPULATION

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | POPULATION |

### INFRASTRUCTURE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | INFRASTRUCTURE |

### EXPANSION

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/operations/wh-expansion.md | Move to | EXPANSION |
| docs/architecture/operations/work_camp_to_settlement_flow.md | Merge into | EXPANSION |

---

## 10. Transportation Section Relocations

### TRANSPORTATION_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | TRANSPORTATION_OVERVIEW |

### CRAFT

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/intent/skimmer_craft_intent.md | Move to | CRAFT |
| docs/architecture/stations/CRAFT_OPERATIONAL_EVOLUTION.md | Merge into | CRAFT |

### STATIONS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/stations/CERES_GATEWAY.md | Move to | STATIONS |
| docs/architecture/stations/CONVERTED_ROCK_STATIONS.md | Merge into | STATIONS |
| docs/architecture/stations/SPECIALIZED_WH_STATIONS.md | Merge into | STATIONS |
| docs/architecture/stations/SYNTHETIC_MEGA_STATIONS.md | Merge into | STATIONS |
| docs/architecture/intent/base_rig_intent.md | Merge into | STATIONS |
| docs/architecture/systems/rig_system.md | Merge into | STATIONS |

### DEPOTS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/intent/l1_depot_shell_intent.md | Move to | DEPOTS |
| docs/architecture/stations/l1_lagrange_facilities.md | Merge into | DEPOTS |
| docs/architecture/logistics/l1_depot_processing_intent.md | Merge into | DEPOTS |

### SHIPYARDS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | SHIPYARDS |

### CYCLERS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | CYCLERS |
| docs/architecture/logistics/navigation/INNER_SYSTEM_EXCLUSION.md | Merge into | CYCLERS |

### CARGO

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/stations/asteroid_relocation_tug.md | Move to | CARGO |
| docs/architecture/stations/asteroid_relocation_tug_guide.md | Merge into | CARGO |

### DOCKING

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/systems/PORT_CONNECTION_SYSTEM.md | Move to | DOCKING |

### LOGISTICS_NETWORK

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/logistics/logistics_architecture.md | Move to | LOGISTICS_NETWORK |
| docs/wiki/Logistics-and-Hauling.md | Merge into | LOGISTICS_NETWORK |
| docs/architecture/intent/LOGISTICS_PROVIDER_INTENT.md | Merge into | LOGISTICS_NETWORK |

---

## 11. AI Manager Section Relocations

### AI_MANAGER_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/ai_manager/00_architecture_overview.md | Move to | AI_MANAGER_OVERVIEW |
| docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md | Merge into | AI_MANAGER_OVERVIEW |
| docs/architecture/ai_manager/AI_MANAGER_ORCHESTRATOR_SPEC.md | Merge into | AI_MANAGER_OVERVIEW |
| docs/architecture/ai_manager/AI_MANAGER_INTENT.md | Merge into | AI_MANAGER_OVERVIEW |
| docs/architecture/ai_manager/AI_MANAGER_ROLE.md | Merge into | AI_MANAGER_OVERVIEW |
| docs/architecture/ai_manager/AI_MANAGER_MASTER_PLAN.md | Merge into | AI_MANAGER_OVERVIEW |
| docs/architecture/ai_manager/AI_MANAGER_EVENT_FLOW.md | Merge into | AI_MANAGER_OVERVIEW |
| docs/architecture/ai_manager/escalation_data_flow.md | Merge into | AI_MANAGER_OVERVIEW |
| docs/wiki/AI-Manager-Logic.md | Merge into | AI_MANAGER_OVERVIEW |

### MISSION_VALIDATION

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/ai_manager/AI_MANAGER_COMMAND.md | Move to | MISSION_VALIDATION |
| docs/storyline/ai_manager_tuning.md | Merge into | MISSION_VALIDATION |

### PATTERN_LEARNING

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | PATTERN_LEARNING |

### EXPANSION_LOGIC

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/ai_manager/02_settlement_planning.md | Move to | EXPANSION_LOGIC |
| docs/architecture/ai_manager/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md | Merge into | EXPANSION_LOGIC |
| docs/architecture/operations/work_camp_to_settlement_flow.md | Merge into | EXPANSION_LOGIC |

### ECONOMY_SUBSYSTEM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/ai_manager/AI_MANAGER_ECONOMIC_LOGIC_UPDATE.md | Move to | ECONOMY_SUBSYSTEM |
| docs/architecture/services/ai_manager_economic_loop.md | Merge into | ECONOMY_SUBSYSTEM |

### CONSTRUCTION_SUBSYSTEM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/ai_manager/AI_MANAGER_DAMAGE_INVENTORY.md | Move to | CONSTRUCTION_SUBSYSTEM |
| docs/architecture/ai_manager/RESUPPLY_AND_ESCALATION_ARCHITECTURE.md | Merge into | CONSTRUCTION_SUBSYSTEM |

### LOGISTICS_SUBSYSTEM

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | LOGISTICS_SUBSYSTEM |

### DECISION_MAKING

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/ai_manager/AI_MANAGER_WAYFINDING.md | Move to | DECISION_MAKING |
| docs/architecture/ai_manager/CONSORTIUM_VOTING_ENGINE.md | Merge into | DECISION_MAKING |
| docs/storyline/ai_manager_tuning.md | Merge into | DECISION_MAKING |

### SIMULATION_INTEGRATION

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | SIMULATION_INTEGRATION |

### SERVICE_PORTFOLIO

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page — inventory of 80+ services) | Create | SERVICE_PORTFOLIO |

---

## 12. Gameplay Section Relocations

### GAMEPLAY_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/gameplay/mechanics.md | Move to | GAMEPLAY_OVERVIEW |

### PLANETARY_GAMEPLAY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | PLANETARY_GAMEPLAY |

### ORBITAL_GAMEPLAY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | ORBITAL_GAMEPLAY |

### INDUSTRY_GAMEPLAY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | INDUSTRY_GAMEPLAY |

### MINING_GAMEPLAY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | MINING_GAMEPLAY |

### TRADING_GAMEPLAY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | TRADING_GAMEPLAY |

### TERRAFORMING_GAMEPLAY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/gameplay/terraforming.md | Merge into | TERRAFORMING_GAMEPLAY |

### EXPLORATION_GAMEPLAY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | EXPLORATION_GAMEPLAY |

### CORPORATIONS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/ai_manager/astrolift_corporation.md | Move to | CORPORATIONS |
| docs/architecture/simulation/organizations_system.md | Merge into | CORPORATIONS |

### PLAYER_PROGRESSION

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/gameplay/player_experience_boundaries.md | Merge into | PLAYER_PROGRESSION |
| docs/storyline/system_maturity_conditions.md | Merge into | PLAYER_PROGRESSION |

---

## 13. Development Section Relocations

### DEVELOPMENT_OVERVIEW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/overview.md | Move to | DEVELOPMENT_OVERVIEW |
| docs/developer/setup.md | Merge into | DEVELOPMENT_OVERVIEW |
| docs/api/README.md | Merge into | DEVELOPMENT_OVERVIEW |

### ARCHITECTURE

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/overview.md | Move to | ARCHITECTURE |
| docs/developer/DATA_DRIVEN_SYSTEMS.md | Merge into | ARCHITECTURE |
| docs/architecture/core/modular_containers.md | Merge into | ARCHITECTURE |
| docs/wiki_reorganization/phase3_alignment/PHASE3_CANONICAL_ALIGNMENT_REPORT.md | Merge into | ARCHITECTURE |
| docs/wiki_reorganization/phase3_alignment/ARCHITECTURE_DECISION_LOG.md | Move to | ARCHITECTURE |
| docs/wiki_reorganization/phase3_alignment/TRUE_BLOCKERS_ONLY.md | Merge into | ARCHITECTURE |
| docs/wiki_reorganization/phase3_alignment/RESOLVED_CONFLICTS.md | Merge into | ARCHITECTURE |
| docs/wiki_reorganization/phase3_alignment/OPEN_DESIGN_DECISIONS.md | Merge into | ARCHITECTURE |

### CODING_STANDARDS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/GUARDRAILS.md | Move to | CODING_STANDARDS |
| docs/developer/refactoring_guide.md | Merge into | CODING_STANDARDS |
| docs/architecture/adrs/GUARDRAILS.md | Merge into | CODING_STANDARDS |
| docs/architecture/intent/operational_data_guardrails.md | Merge into | CODING_STANDARDS |

### JSON_STANDARDS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/developer/JSON_DATA_GUIDE.md | Move to | JSON_STANDARDS |
| docs/developer/TILESET_README.md | Merge into | JSON_STANDARDS |

### NAMING_CONVENTIONS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/developer/STAR_SYSTEM_NAMING_STANDARDS.md | Move to | NAMING_CONVENTIONS |

### BLUEPRINT_STANDARDS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md | Move to | BLUEPRINT_STANDARDS |
| docs/developer/COST_SCHEMA_CONSUMPTION_GUIDE.md | Merge into | BLUEPRINT_STANDARDS |

### DEVELOPMENT_PHASES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/architecture/planning/DEVELOPMENT_ROADMAP.md | Move to | DEVELOPMENT_PHASES |
| docs/storyline/10_implementation_phases.md | Merge into | DEVELOPMENT_PHASES |
| docs/planning/AI-MANAGER—LUNA-BEHAVIOR-GOALS.md | Merge into | DEVELOPMENT_PHASES |
| docs/planning/MISSION_PHASING_AND_TIMELINE.md | Merge into | DEVELOPMENT_PHASES |
| docs/planning/GALAXY-GAME-PHASE-ALIGNMENT.md | Merge into | DEVELOPMENT_PHASES |
| docs/developer/AI_MANAGER_FUTURE_DEVELOPMENT.md | Merge into | DEVELOPMENT_PHASES |

### BACKLOG

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/wiki_reorganization/phase3_alignment/BACKLOG_PRIORITY_ALIGNMENT.md | Move to | BACKLOG |

### TESTING

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/testing/PRACTICAL_TESTING_GUIDE.md | Move to | TESTING |
| docs/testing/TESTING_PHILOSOPHY.md | Merge into | TESTING |
| docs/testing/CI_CD_PIPELINE.md | Merge into | TESTING |
| docs/testing/FLAKY_TESTS_ANALYSIS.md | Archive (ephemeral) |
| docs/developer/ai_testing_framework.md | Merge into | TESTING |
| docs/developer/spec_stabilization.md | Merge into | TESTING |
| docs/developer/CRITICAL_TESTING_FIXES.md | Archive (ephemeral) |

### AI_WORKFLOW

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/developer/LLM_AGENT_TASK_PROTOCOL.md | Move to | AI_WORKFLOW |
| docs/testing/GRINDER_PROTOCOL.md | Merge into | AI_WORKFLOW |
| docs/architecture/ai_manager/AI_MANAGER_CODE_REVIEW_PROTOCOL.md | Merge into | AI_WORKFLOW |

---

## 14. Reference Section Relocations

### GLOSSARY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/GLOSSARY_SYSTEM_MECHANICS.md | Move to | GLOSSARY |
| docs/architecture/glossary/system_mechanics.md | Merge into | GLOSSARY |
| docs/storyline/12_lore_mechanics_summary.md | Merge into | GLOSSARY |

### TERMINOLOGY

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | TERMINOLOGY |

### GAME_CONSTANTS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | GAME_CONSTANTS |

### RESOURCE_LIST

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | RESOURCE_LIST |

### CELESTIAL_BODY_INDEX

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md | Merge into | CELESTIAL_BODY_INDEX |

### BLUEPRINT_INDEX

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | BLUEPRINT_INDEX |

### JSON_SCHEMAS

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | JSON_SCHEMAS |

### CROSS_REFERENCES

| Source | Action | Target Wiki Page |
|--------|--------|-----------------|
| (create new page) | Create | CROSS_REFERENCES |

---

## Archive Plan Summary

Documents to move to **docs/archive/**:

| Category | Count | Examples |
|----------|-------|---------|
| Ephemeral status reports | ~10 | IMPLEMENTATION_STATUS.md, MISSION_COMPLETE.md, PHASE_ALIGNMENT_SUMMARY |
| Agent task files | ~8 | CLAUDE_5PM_GO.md, CLAUDE_HANDOFF.md, PLAYER_HANDOFF.md |
| Audit/review reports | ~5 | AI_MANAGER_BLOAT_AUDIT.md, INTEGRATION_ASSESSMENT_REPORT.md |
| UI enhancement notes | ~3 | ui_enhancements.md, ui_enhancements.md |
| Pending changes lists | ~2 | pending_changes.md, architectural_todos.md |
| Backup files | ~2 | *.bak files |

Documents to move to **docs/archive/historical/**:

| Category | Count | Examples |
|----------|-------|---------|
| Agent conversations | ~5 | Grok/Claude task files, chat logs |
| Prototype references | ~3 | rails_terraforming_prototype.md, FreeCiv integration |
| Development history | ~5 | TECHNICAL_HISTORY.md, claude_notes.md, freeciv_geographical_patterns.json |
| Legacy code | ~1 | PATHS.PAS |

---

## New Pages to Create (Not Relocated)

These wiki pages should be created from scratch (not relocated from existing docs):

1. ECONOMY_OVERVIEW (synthesis of economy docs)
2. PLAYER_ECONOMY (new content)
3. SUPPLY_AND_DEMAND (new content)
4. IMPORT_EXPORT (new content)
5. ECONOMIC_PHILOSOPHY (new content)
6. RESOURCES (synthesis of resource docs)
7. TECHNOLOGY_LEVELS (synthesis of tech docs)
8. MK_GENERATIONS (new content)
9. FACTORIES (new content)
10. MANUFACTURING_PIPELINE (synthesis of pipeline docs)
11. COLONIES (new content)
12. SETTLEMENTS (new content)
13. ORBITAL_SETTLEMENTS (synthesis of orbital docs)
14. POPULATION (new content)
15. INFRASTRUCTURE (new content)
16. TRANSPORTATION_OVERVIEW (new content)
17. SHIPYARDS (new content)
18. CYCLERS (new content)
19. LOGISTICS_SUBSYSTEM (new content)
20. SIMULATION_INTEGRATION (new content)
21. SERVICE_PORTFOLIO (inventory of 80+ services)
22. PLANETARY_GAMEPLAY (new content)
23. ORBITAL_GAMEPLAY (new content)
24. INDUSTRY_GAMEPLAY (new content)
25. MINING_GAMEPLAY (new content)
26. TRADING_GAMEPLAY (new content)
27. EXPLORATION_GAMEPLAY (new content)
28. TERMINOLOGY (new content)
29. GAME_CONSTANTS (new content)
30. RESOURCE_LIST (new content)
31. BLUEPRINT_INDEX (new content)
32. JSON_SCHEMAS (new content)
33. CROSS_REFERENCES (new content)
