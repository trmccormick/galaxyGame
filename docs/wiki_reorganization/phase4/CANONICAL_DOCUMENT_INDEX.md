# Canonical Document Index — Phase 4

**Created**: 2026-07-16  
**Purpose**: ONE authoritative page for every major topic in Galaxy Game. All other pages on the same topic link here.

---

## How to Use This Index

Each entry has:
- **Topic** — The game concept
- **Canonical Page** — The ONE authoritative wiki page
- **Supporting Pages** — Detailed sub-topics that link to the canonical page
- **Historical** — Old/obsolete pages on this topic (for reference only)

---

## 1. Vision

### What is Galaxy Game?
- **Canonical**: START_HERE
- **Supporting**: docs/README.md, docs/wiki/getting_started.md, docs/storyline/README.md, docs/developer/README.md, docs/reference/README.md
- **Historical**: (none)

### Design Philosophy
- **Canonical**: DESIGN_PHILOSOPHY (synthesized from GAME_DESIGN_INTENT.md + intent documents)
- **Supporting**: docs/reference/GAME_DESIGN_INTENT.md, docs/architecture/intent/* (all intent docs)
- **Historical**: docs/architecture/intent/operational_data_guardrails.md

### Core Principles
- **Canonical**: CORE_PRINCIPLES (synthesized from GUARDRAILS.md + operational guardrails)
- **Supporting**: docs/GUARDRAILS.md, docs/architecture/adrs/GUARDRAILS.md
- **Historical**: (none)

### Player Experience
- **Canonical**: PLAYER_EXPERIENCE (synthesized from player_experience_boundaries.md + Player-Roles-and-Alignment.md)
- **Supporting**: docs/gameplay/player_experience_boundaries.md, docs/wiki/Player-Roles-and-Alignment.md, docs/architecture/intent/PLAYER_UI_VISION.md
- **Historical**: docs/developer/UI_IMPLEMENTATION.md, docs/developer/planet_ui_development_plan.md

### Project Goals
- **Canonical**: PROJECT_GOALS (synthesized from GALAXY-GAME-PLANNING-GOALS.md)
- **Supporting**: docs/planning/GALAXY-GAME-PLANNING-GOALS.md
- **Historical**: (none)

---

## 2. Story

### Story Overview
- **Canonical**: STORY_OVERVIEW (synthesized from 01_story_arc.md + 03_consortium_framework.md + 04_terra_gen_consortium.md)
- **Supporting**: docs/storyline/01_story_arc.md, docs/storyline/03_consortium_framework.md, docs/storyline/04_terra_gen_consortium.md
- **Historical**: docs/storyline/01_story_arc.md.bak

### Narrative Acts
- **Canonical**: NARRATIVE_ACTS (synthesized from 02_crisis_mechanics.md + Scenario-Super-Mars.md)
- **Supporting**: docs/storyline/02_crisis_mechanics.md, docs/wiki/Scenario-Super-Mars.md
- **Historical**: (none)

### Implementation Phases
- **Canonical**: IMPLEMENTATION_PHASES (synthesized from 10_implementation_phases.md + DEVELOPMENT_ROADMAP.md + mission phasing docs)
- **Supporting**: docs/storyline/10_implementation_phases.md, docs/architecture/planning/DEVELOPMENT_ROADMAP.md, docs/planning/AI-MANAGER—LUNA-BEHAVIOR-GOALS.md, docs/planning/MISSION_PHASING_AND_TIMELINE.md
- **Historical**: docs/storyline/PHASE_ALIGNMENT_SUMMARY_2026-06-18.md

### Historical Timeline
- **Canonical**: HISTORICAL_TIMELINE (synthesized from 11_lore_canon.md + 12_lore_mechanics_summary.md)
- **Supporting**: docs/storyline/11_lore_canon.md, docs/storyline/12_lore_mechanics_summary.md
- **Historical**: (none)

### Snap Event
- **Canonical**: SNAP_EVENT
- **Supporting**: docs/storyline/snap_event_and_network_expansion.md
- **Historical**: (none)

### Wormhole History
- **Canonical**: WORMHOLE_HISTORY (synthesized from wormhole_system.md + WORMHOLE_NETWORK_INTENT.md + 00_executive_summary.md)
- **Supporting**: docs/architecture/wormhole/00_executive_summary.md, docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md
- **Historical**: docs/storyline/multi_wormhole_event.md

---

## 3. Universe Generation
### Universe Overview
- **Canonical**: UNIVERSE_OVERVIEW (synthesized from celestial_bodies.md + Celestial-Systems.md)
- **Supporting**: docs/architecture/starsim/celestial_bodies.md, docs/wiki/Celestial-Systems.md
- **Historical**: (none)

### Sol System
- **Canonical**: SOL_SYSTEM (synthesized from solar_system.md + DIAGNOSTIC_SOL_SEEDING.md + sol_data_organization.md)
- **Supporting**: docs/architecture/starsim/solar_system.md, docs/developer/DIAGNOSTIC_SOL_SEEDING.md, docs/developer/sol_data_organization.md
- **Historical**: (none)

### Eden System
- **Canonical**: EDEN_SYSTEM
- **Supporting**: docs/developer/ALPHA_CENTAURI_GENERATOR.md, docs/architecture/systems/alpha_centauri_prep.md
- **Historical**: (none)

### Local Bubble
- **Canonical**: LOCAL_BUBBLE
- **Supporting**: docs/developer/LOCAL_BUBBLE_EXPANSION.md
- **Historical**: (none)

### Stars
- **Canonical**: STARS
- **Supporting**: docs/architecture/starsim/star_naming_architecture.md, docs/architecture/intent/SYSTEM_CLASSIFICATION_INTENT.md
- **Historical**: (none)

### Celestial Bodies
- **Canonical**: CELESTIAL_BODIES (synthesized from celestial_bodies.md + CELESTIAL_BODY_DATA_CONVENTIONS.md + TERRAFORMABLE_PLANETS.md)
- **Supporting**: docs/architecture/starsim/celestial_bodies.md, docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md, docs/developer/TERRAFORMABLE_PLANETS.md
- **Historical**: (none)

### Natural Wormholes
- **Canonical**: NATURAL_WORMHOLES (synthesized from wormhole_system.md + WORMHOLE_NETWORK_INTENT.md + multi_wormhole_event.md)
- **Supporting**: docs/architecture/wormhole/WORMHOLE_SYSTEM.md, docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md, docs/storyline/multi_wormhole_event.md
- **Historical**: docs/architecture/logistics/navigation/WORMHOLE_NETWORK.md

### Artificial Wormholes
- **Canonical**: ARTIFICIAL_WORMHOLES
- **Supporting**: docs/architecture/logistics/navigation/INTRA_SYSTEM_PORTALS.md
- **Historical**: (none)

---

## 4. Planetary Simulation
### Simulation Overview
- **Canonical**: SIMULATION_OVERVIEW
- **Supporting**: docs/storyline/05_physics_topology.md
- **Historical**: docs/architecture/simulation/SIMULATION_SANDBOX.md (archived — purpose unclear per Phase 3)

### StarSim
- **Canonical**: STARSIM (synthesized from OVERVIEW.md + PROCEDURAL_INTENT.md + MISSING_HOOKS.md)
- **Supporting**: docs/architecture/starsim/OVERVIEW.md, docs/architecture/starsim/PROCEDURAL_INTENT.md, docs/architecture/starsim/MISSING_HOOKS.md
- **Historical**: docs/architecture/starsim/TECHNICAL_HISTORY.md

### TerraSim
- **Canonical**: TERRASIM (synthesized from terrasim_service.md + OVERVIEW.md)
- **Supporting**: docs/architecture/biology/terrasim_service.md, docs/architecture/terrasim/OVERVIEW.md
- **Historical**: (none)

### Geosphere
- **Canonical**: GEOSPHERE (synthesized from geosphere_system.md + geological_features_architecture.md)
- **Supporting**: docs/architecture/simulation/geosphere_system.md, docs/architecture/planning/geological_features_architecture.md
- **Historical**: docs/architecture/planning/geological_features_design_intent.md

### Atmosphere
- **Canonical**: ATMOSPHERE (synthesized from atmospheric_maintenance_system.md + DESIGN_INTENT_SEALED_VOLUME_ATMOSPHERE.md)
- **Supporting**: docs/architecture/simulation/atmospheric_maintenance_system.md, docs/reference/DESIGN_INTENT_SEALED_VOLUME_ATMOSPHERE.md
- **Historical**: (none)

### Hydrosphere
- **Canonical**: HYDROSPHERE
- **Supporting**: docs/architecture/simulation/hydrosphere_system.md
- **Historical**: (none)

### Biosphere
- **Canonical**: BIOSPHERE (synthesized from biology_models.md + biosphere_system.md + biology_system.md)
- **Supporting**: docs/architecture/biology/biology_models.md, docs/architecture/simulation/biosphere_system.md, docs/architecture/simulation/biology_system.md
- **Historical**: (none)

### Biome System
- **Canonical**: BIOME_SYSTEM (synthesized from biome_model.md + BIOME_TERRAFORMING_DESIGN.md)
- **Supporting**: docs/architecture/biology/biome_model.md, docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md
- **Historical**: (none)

### Terraforming
- **Canonical**: TERRAFORMING (synthesized from terraforming.md + biology_terraforming_guide.md + TERRAFORMING_SIMULATION.md)
- **Supporting**: docs/gameplay/terraforming.md, docs/architecture/simulation/biology_terraforming_guide.md, docs/developer/TERRAFORMING_SIMULATION.md
- **Historical**: (none)

### Simulation Pipeline
- **Canonical**: SIMULATION_PIPELINE (synthesized from terrain generation + visual layers + sphere optimization)
- **Supporting**: docs/architecture/terrain/generation_and_rendering.md, docs/architecture/simulation/terrainforge_layer.md, docs/architecture/systems/sphere_creation_optimization.md
- **Historical**: docs/architecture/simulation/visual_layer_stack.md (archived)

---

## 5. Game World Model

### World Model Overview
- **Canonical**: WORLD_MODEL_OVERVIEW
- **Supporting**: docs/architecture/settlement/README.md, docs/architecture/structures/README.md
- **Historical**: docs/storyline/06_deployment_hierarchy.md, docs/architecture/concerns/has_units.md

### Galaxy
- **Canonical**: GALAXY
- **Supporting**: (create new)
- **Historical**: (none)

### Solar System
- **Canonical**: SOLAR_SYSTEM (synthesized from solar_system.md + DIAGNOSTIC_SOL_SEEDING.md)
- **Supporting**: docs/architecture/starsim/solar_system.md, docs/developer/DIAGNOSTIC_SOL_SEEDING.md
- **Historical**: (none)

### Star
- **Canonical**: STAR
- **Supporting**: docs/architecture/starsim/star_naming_architecture.md
- **Historical**: (none)

### Celestial Body
- **Canonical**: CELESTIAL_BODY (synthesized from celestial_bodies.md + CELESTIAL_BODY_DATA_CONVENTIONS.md)
- **Supporting**: docs/architecture/starsim/celestial_bodies.md, docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md
- **Historical**: (none)

### Planet Environment
- **Canonical**: PLANET_ENVIRONMENT
- **Supporting**: docs/architecture/simulation/geosphere_system.md, docs/architecture/biology/biology_models.md
- **Historical**: (none)

### Settlement
- **Canonical**: SETTLEMENT
- **Supporting**: docs/architecture/settlement/README.md
- **Historical**: (none)

### Structure
- **Canonical**: STRUCTURE
- **Supporting**: docs/architecture/structures/README.md
- **Historical**: (none)

### Unit
- **Canonical**: UNIT
- **Supporting**: (create new)
- **Historical**: (none)

---

## 6. Simulation Engine

### Simulation Engine Overview
- **Canonical**: SIMULATION_ENGINE_OVERVIEW
- **Supporting**: docs/architecture/simulation/SIMULATION_SANDBOX.md, docs/storyline/05_physics_topology.md
- **Historical**: (none)

### StarSim Pipeline
- **Canonical**: STAR_SIM_PIPELINE
- **Supporting**: docs/architecture/starsim/OVERVIEW.md, docs/architecture/starsim/PROCEDURAL_INTENT.md
- **Historical**: docs/architecture/starsim/TECHNICAL_HISTORY.md

### TerraSim Pipeline
- **Canonical**: TERRA_SIM_PIPELINE
- **Supporting**: docs/architecture/biology/terrasim_service.md, docs/architecture/terrasim/OVERVIEW.md
- **Historical**: (none)

### Simulation Data Ownership
- **Canonical**: SIMULATION_DATA_OWNERSHIP
- **Supporting**: docs/architecture/starsim/MISSING_HOOKS.md, docs/architecture/simulation/geosphere_system.md
- **Historical**: (none)

### Simulation Integration
- **Canonical**: SIMULATION_INTEGRATION
- **Supporting**: docs/architecture/simulation/terrainforge_layer.md, docs/architecture/systems/sphere_creation_optimization.md
- **Historical**: docs/architecture/simulation/visual_layer_stack.md (archived)

### Simulation Pipeline
- **Canonical**: SIMULATION_PIPELINE (synthesized from terrain generation + visual layers + sphere optimization)
- **Supporting**: docs/architecture/terrain/generation_and_rendering.md, docs/architecture/simulation/terrainforge_layer.md, docs/architecture/systems/sphere_creation_optimization.md
- **Historical**: docs/architecture/simulation/visual_layer_stack.md (archived)

---

## 7. Economy

### Economy Overview
- **Canonical**: ECONOMY_OVERVIEW (synthesized from economic_baseline.md + financial_system.md + FISCAL_POLICY_AND_FEES.md)
- **Supporting**: docs/architecture/economy/economic_baseline.md, docs/architecture/economy/financial_system.md, docs/architecture/economy/FISCAL_POLICY_AND_FEES.md
- **Historical**: docs/wiki/Financial-Engine.md, docs/storyline/09_economic_systems.md

### Currency
- **Canonical**: CURRENCY (synthesized from CURRENCY_AND_EXCHANGE.md + DUAL_ECONOMY_INTENT.md)
- **Supporting**: docs/architecture/economy/CURRENCY_AND_EXCHANGE.md, docs/architecture/intent/DUAL_ECONOMY_INTENT.md
- **Historical**: docs/architecture/economy/VIRTUAL_LEDGER_FLOWS.md

### Markets
- **Canonical**: MARKETS (synthesized from MARKET_OPERATIONS.md + LEDGERS.md)
- **Supporting**: docs/architecture/economy/MARKET_OPERATIONS.md, docs/architecture/economy/LEDGERS.md
- **Historical**: docs/wiki/Market-and-AI-Bootstrapping.md

### NPC Economy
- **Canonical**: NPC_ECONOMY
- **Supporting**: docs/wiki/Market-and-AI-Bootstrapping.md
- **Historical**: (none)

### Contracts
- **Canonical**: CONTRACTS (synthesized from CONTRACTS.md + PLAYER_CONTRACT_SYSTEM.md)
- **Supporting**: docs/architecture/economy/CONTRACTS.md, docs/architecture/economy/PLAYER_CONTRACT_SYSTEM.md
- **Historical**: (none)

### Pricing
- **Canonical**: PRICING (synthesized from PRICE_DISCOVERY_LIFECYCLE.md + AI_MANAGER_PRICING_INTENT.md)
- **Supporting**: docs/architecture/economy/PRICE_DISCOVERY_LIFECYCLE.md, docs/architecture/ai_manager/AI_MANAGER_PRICING_INTENT.md
- **Historical**: docs/architecture/economy/ISRU_PRICING_MODEL.md

---

## 8. Manufacturing

### Manufacturing Overview
- **Canonical**: MANUFACTURING_OVERVIEW
- **Supporting**: docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md
- **Historical**: (none)

### Resources
- **Canonical**: RESOURCES
- **Supporting**: docs/api/materials.md
- **Historical**: (none)

### ISRU
- **Canonical**: ISRU (synthesized from isru/README.md + 3d_printing.md + cnt_production.md)
- **Supporting**: docs/architecture/isru/README.md, docs/architecture/isru/3d_printing.md, docs/architecture/isru/cnt_production.md
- **Historical**: docs/architecture/systems/LUNA_ISRU_GAS_PROCESSING_AND_SKIMMER_OPERATIONS.md

### Blueprints
- **Canonical**: BLUEPRINTS (synthesized from DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md + BLUEPRINT_COST_SCHEMA_GUIDE.md)
- **Supporting**: docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md, docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md
- **Historical**: docs/developer/COST_SCHEMA_CONSUMPTION_GUIDE.md

### Construction
- **Canonical**: CONSTRUCTION
- **Supporting**: docs/architecture/simulation/construction_system.md
- **Historical**: (none)

### Technology Levels
- **Canonical**: TECHNOLOGY_LEVELS
- **Supporting**: docs/architecture/systems/em_technology_tree.md
- **Historical**: (none)

---

## 9. Settlements

### Settlements Overview
- **Canonical**: SETTLEMENTS_OVERVIEW
- **Supporting**: docs/architecture/settlement/README.md
- **Historical**: docs/storyline/06_deployment_hierarchy.md, docs/architecture/concerns/has_units.md

### Colonies
- **Canonical**: COLONIES
- **Supporting**: (create new)
- **Historical**: (none)

### Settlements
- **Canonical**: SETTLEMENTS
- **Supporting**: (create new)
- **Historical**: (none)

### Structures
- **Canonical**: STRUCTURES
- **Supporting**: docs/architecture/structures/README.md
- **Historical**: (none)

### Worldhouses
- **Canonical**: WORLDHOUSES
- **Supporting**: docs/architecture/intent/worldhouse_intent.md, docs/architecture/systems/environmental_volume_intent.md
- **Historical**: (none)

### Orbital Settlements
- **Canonical**: ORBITAL_SETTLEMENTS
- **Supporting**: docs/developer/orbital_depot_migration.md
- **Historical**: (none)

---

## 10. Transportation

### Transportation Overview
- **Canonical**: TRANSPORTATION_OVERVIEW
- **Supporting**: (create new)
- **Historical**: (none)

### Craft
- **Canonical**: CRAFT
- **Supporting**: docs/architecture/intent/skimmer_craft_intent.md, docs/architecture/stations/CRAFT_OPERATIONAL_EVOLUTION.md
- **Historical**: (none)

### Stations
- **Canonical**: STATIONS
- **Supporting**: docs/architecture/stations/CERES_GATEWAY.md, docs/architecture/stations/CONVERTED_ROCK_STATIONS.md, docs/architecture/stations/SPECIALIZED_WH_STATIONS.md
- **Historical**: docs/architecture/intent/base_rig_intent.md

### Depots
- **Canonical**: DEPOTS
- **Supporting**: docs/architecture/intent/l1_depot_shell_intent.md, docs/architecture/stations/l1_lagrange_facilities.md
- **Historical**: (none)

### Cyclers
- **Canonical**: CYCLERS
- **Supporting**: docs/architecture/logistics/navigation/INNER_SYSTEM_EXCLUSION.md
- **Historical**: (none)

### Logistics Network
- **Canonical**: LOGISTICS_NETWORK
- **Supporting**: docs/architecture/logistics/logistics_architecture.md, docs/wiki/Logistics-and-Hauling.md
- **Historical**: docs/architecture/intent/LOGISTICS_PROVIDER_INTENT.md

---

## 11. AI Manager

### AI Manager Overview
- **Canonical**: AI_MANAGER_OVERVIEW (synthesized from 00_architecture_overview.md + AI_MANAGER_ARCHITECTURE.md + AI_MANAGER_ORCHESTRATOR_SPEC.md)
- **Supporting**: docs/architecture/ai_manager/00_architecture_overview.md, docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md, docs/architecture/ai_manager/AI_MANAGER_ORCHESTRATOR_SPEC.md
- **Historical**: docs/architecture/ai_manager/AI_MANAGER_BLOAT_AUDIT.md, docs/architecture/ai_manager/IMPLEMENTATION_STATUS.md

### Mission Validation
- **Canonical**: MISSION_VALIDATION
- **Supporting**: docs/architecture/ai_manager/AI_MANAGER_COMMAND.md
- **Historical**: (none)

### Expansion Logic
- **Canonical**: EXPANSION_LOGIC
- **Supporting**: docs/architecture/ai_manager/02_settlement_planning.md, docs/architecture/ai_manager/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md
- **Historical**: (none)

### Service Portfolio
- **Canonical**: SERVICE_PORTFOLIO (inventory of 80+ services — create new)
- **Supporting**: (create new)
- **Historical**: (none)

---

## 12. Gameplay

### Gameplay Overview
- **Canonical**: GAMEPLAY_OVERVIEW
- **Supporting**: docs/gameplay/mechanics.md
- **Historical**: docs/gameplay/EASTER_EGGS.md (archived)

### Player Progression
- **Canonical**: PLAYER_PROGRESSION
- **Supporting**: docs/gameplay/player_experience_boundaries.md, docs/storyline/system_maturity_conditions.md
- **Historical**: (none)

---

## 13. Development

### Development Overview
- **Canonical**: DEVELOPMENT_OVERVIEW
- **Supporting**: docs/architecture/overview.md, docs/developer/setup.md
- **Historical**: docs/api/README.md

### Architecture
- **Canonical**: ARCHITECTURE (synthesized from overview.md + DATA_DRIVEN_SYSTEMS.md)
- **Supporting**: docs/architecture/overview.md, docs/developer/DATA_DRIVEN_SYSTEMS.md
- **Historical**: docs/wiki_reorganization/phase3_alignment/PHASE3_CANONICAL_ALIGNMENT_REPORT.md

### Architecture Decision Log
- **Canonical**: ARCHITECTURE_DECISION_LOG
- **Supporting**: docs/wiki_reorganization/phase3_alignment/ARCHITECTURE_DECISION_LOG.md
- **Historical**: docs/architecture/adrs/* (ADR format preserved)

### Development Phases
- **Canonical**: DEVELOPMENT_PHASES (synthesized from DEVELOPMENT_ROADMAP.md + 10_implementation_phases.md)
- **Supporting**: docs/architecture/planning/DEVELOPMENT_ROADMAP.md, docs/storyline/10_implementation_phases.md
- **Historical**: docs/planning/GALAXY-GAME-PHASE-ALIGNMENT.md

### Testing
- **Canonical**: TESTING (synthesized from PRACTICAL_TESTING_GUIDE.md + TESTING_PHILOSOPHY.md)
- **Supporting**: docs/testing/PRACTICAL_TESTING_GUIDE.md, docs/testing/TESTING_PHILOSOPHY.md
- **Historical**: docs/testing/FLAKY_TESTS_ANALYSIS.md, docs/developer/CRITICAL_TESTING_FIXES.md

### Backlog
- **Canonical**: BACKLOG
- **Supporting**: docs/wiki_reorganization/phase3_alignment/BACKLOG_PRIORITY_ALIGNMENT.md
- **Historical**: (none)

---

## 14. Reference

### Glossary
- **Canonical**: GLOSSARY (synthesized from GLOSSARY_SYSTEM_MECHANICS.md + system_mechanics.md)
- **Supporting**: docs/GLOSSARY_SYSTEM_MECHANICS.md, docs/architecture/glossary/system_mechanics.md
- **Historical**: docs/storyline/12_lore_mechanics_summary.md

### Cross References
- **Canonical**: CROSS_REFERENCES (create new — maps all canonical pages to each other)
- **Supporting**: (create new)
- **Historical**: (none)

---

## Canonical Page Selection Rules

When multiple documents cover the same topic, select the canonical page based on:

1. **Design intent over implementation details** — Documents that explain WHY a system exists, not just HOW it's built
2. **Stability over ephemerality** — Documents that define lasting concepts, not status reports or execution plans
3. **Completeness over partial coverage** — The most comprehensive document on the topic
4. **Canonical intent alignment** — Documents that match Phase 3 canonical design intent statements

### Canonical Page Selection Summary

| Topic | Canonical Source | Why |
|-------|-----------------|-----|
| What is Galaxy Game? | START_HERE (new) | Entry point, synthesized from all READMEs |
| Design Philosophy | GAME_DESIGN_INTENT.md | Core game design intent document |
| Architecture | overview.md + DATA_DRIVEN_SYSTEMS.md | Most comprehensive architecture docs |
| AI Manager | 00_architecture_overview.md + AI_MANAGER_ARCHITECTURE.md | Core architecture docs |
| Economy | economic_baseline.md + MARKET_OPERATIONS.md | Foundation economics docs |
| Manufacturing | MANUFACTURING_SYSTEM_OVERVIEW.md | Only manufacturing overview doc |
| Settlements | settlement/README.md | Settlement hierarchy overview |
| Simulation | STARSIM/OVERVIEW.md + TERRASIM/OVERVIEW.md | Core simulation docs |
| Blueprints | DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md | Blueprint design intent |
| Terraforming | terraforming.md + biology_terraforming_guide.md | Core terraforming docs |
| Biome System | biome_model.md | Core biome model doc |
| Wormholes | WORMHOLE_NETWORK_INTENT.md | Wormhole network intent |
| Worldhouses | worldhouse_intent.md | Worldhouse design intent |
| Skimmer Craft | skimmer_craft_intent.md | Skimmer craft intent |
| Dual Economy | DUAL_ECONOMY_INTENT.md | Dual economy intent |
| Testing | PRACTICAL_TESTING_GUIDE.md + TESTING_PHILOSOPHY.md | Core testing docs |
| Agent Protocol | LLM_AGENT_TASK_PROTOCOL.md | Agent workflow standard |
| Glossary | GLOSSARY_SYSTEM_MECHANICS.md | Core terminology doc |
| Development Phases | DEVELOPMENT_ROADMAP.md + 10_implementation_phases.md | Phase planning docs |
| Story | 01_story_arc.md | Core story arc |
| Snap Event | snap_event_and_network_expansion.md | Snap Event core doc |
| Lore | 11_lore_canon.md | Lore canon |
