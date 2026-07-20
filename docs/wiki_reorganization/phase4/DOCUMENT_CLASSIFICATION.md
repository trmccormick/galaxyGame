# Document Classification — Phase 4

**Created**: 2026-07-16  
**Purpose**: Every document in the docs tree classified into one category: Canonical, Supporting, Merge, Split, Archive, Historical, Redirect.

---

## Classification Definitions

| Category | Meaning | Action |
|----------|---------|--------|
| **Canonical** | Authoritative source for a major topic. Should become a wiki canonical page. | Keep as-is; move to canonical wiki location. |
| **Supporting** | Detailed explanation of a sub-topic. Should become a wiki supporting page. | Keep as-is; move to wiki location. |
| **Merge** | Contains valuable content that should be merged into another document. | Merge content; archive source. |
| **Split** | Contains multiple topics that belong in different wiki sections. | Split content; archive source. |
| **Archive** | Historical record, no longer canonical. Valuable but not active reference. | Move to docs/archive/. |
| **Historical** | Development history, research notes, experiments. Keep for context only. | Move to docs/archive/historical/. |
| **Redirect** | Superseded by another document. Content is in a different file now. | Note the redirect target; archive source. |

---

## Root-Level Documents

| Document | Current Location | Wiki Section | Classification | Notes |
|----------|-----------------|--------------|----------------|-------|
| README.md | docs/ | 1. Vision (START_HERE) | **Canonical** | Becomes wiki entry point |
| GLOSSARY_SYSTEM_MECHANICS.md | docs/ | 14. Reference (GLOSSARY) | **Canonical** | Core terminology — move to Glossary |
| GUARDRAILS.md | docs/ | 13. Development (CODING_STANDARDS) | **Supporting** | Developer constraints — merge into Coding Standards |
| MIGRATION_GUIDE.md | docs/ | 13. Development | **Archive** | Migration history — archive for reference |
| PRACTICAL_TESTING_GUIDE.md | docs/ | 13. Development (TESTING) | **Canonical** | Core testing doc — move to Testing |

---

## docs/architecture/ — Root Level

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| overview.md | 13. Development (ARCHITECTURE) | **Canonical** | Becomes Architecture canonical page |
| asteroid_conversion_logic.md | 10. Transportation | **Split** | Asteroid conversion → Transportation; physics → Archive |
| [architecture/adrs/](#adrs-directory) | See ADRs section below | — | Classified separately |

---

## docs/architecture/adrs/ — Architecture Decision Records

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| ADR-001-Bridge-Bus-Topology.md | 13. Development (ARCHITECTURE) | **Supporting** | Design decision record — merge into Architecture |
| GUARDRAILS.md | 13. Development (CODING_STANDARDS) | **Merge** | Merge into docs/GUARDRAILS.md |
| IMPLEMENTATION_SPEC_AND_GOVERNANCE.md | 13. Development | **Archive** | Governance process — archive |
| PROPOSAL_TO_CLAUDE.md | — | **Historical** | AI agent proposal — historical only |

---

## docs/architecture/ai_manager/ — AI Manager Documentation

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| 00_architecture_overview.md | 11. AI Manager (AI_MANAGER_OVERVIEW) | **Canonical** | Core architecture doc |
| 01_probe_system.md | 11. AI Manager | **Supporting** | Probe subsystem — merge into AI Manager overview |
| 02_settlement_planning.md | 11. AI Manager (EXPANSION_LOGIC) | **Supporting** | Settlement planning logic |
| 03_resource_decisions.md | 11. AI Manager | **Merge** | Merge into Economy Subsystem |
| 89→8_EXECUTION_PLAN.md | — | **Historical** | Execution plan — historical |
| 89→8_SURGICAL_MAP.md | — | **Historical** | Surgical map — historical |
| AI_MANAGER_ARCHITECTURE.md | 11. AI Manager (AI_MANAGER_OVERVIEW) | **Canonical** | Core architecture doc — needs update per Phase 3 |
| AI_MANAGER_BLOAT_AUDIT.md | — | **Archive** | Audit report — archive |
| AI_MANAGER_CODE_REVIEW_PROTOCOL.md | 13. Development (AI_WORKFLOW) | **Supporting** | Review protocol — move to Dev |
| AI_MANAGER_COMMAND.md | 11. AI Manager (DECISION_MAKING) | **Supporting** | Command system |
| AI_MANAGER_DAMAGE_INVENTORY.md | 11. AI Manager | **Merge** | Merge into Construction Subsystem |
| AI_MANAGER_DESIGN_FAILURES.md | — | **Historical** | Design failures log — historical |
| AI_MANAGER_ECONOMIC_LOGIC_UPDATE.md | 11. AI Manager (ECONOMY_SUBSYSTEM) | **Supporting** | Economic logic — merge into Economy |
| AI_MANAGER_EVENT_FLOW.md | 11. AI Manager | **Merge** | Merge into Architecture overview |
| AI_MANAGER_HAMMER_INTEGRATION.md | 11. AI Manager | **Archive** | Integration note — archive |
| AI_MANAGER_INTENT.md | 11. AI Manager (AI_MANAGER_OVERVIEW) | **Supporting** | Intent doc — merge into Overview |
| AI_MANAGER_MASTER_PLAN.md | 11. AI Manager | **Merge** | Merge into Architecture overview |
| AI_MANAGER_ORCHESTRATOR_SPEC.md | 11. AI Manager (AI_MANAGER_OVERVIEW) | **Canonical** | Orchestrator spec — core doc |
| AI_MANAGER_PRICING_INTENT.md | 7. Economy (PRICING) | **Redirect** | Content → Pricing canonical page |
| AI_MANAGER_ROLE.md | 11. AI Manager (AI_MANAGER_OVERVIEW) | **Supporting** | Role definition — merge into Overview |
| AI_MANAGER_WAYFINDING.md | 11. AI Manager | **Merge** | Merge into Decision Making |
| AI_MANAGER_WORMHOLE_EXPANSION.md | 3. Universe Generation (ARTIFICIAL_WORMHOLES) | **Redirect** | Content → Artificial Wormholes |
| CLAUDE_5PM_GO.md | — | **Historical** | Agent task — historical |
| CLAUDE_HANDOFF.md | — | **Historical** | Agent handoff — historical |
| CONSORTIUM_VOTING_ENGINE.md | 11. AI Manager (DECISION_MAKING) | **Supporting** | Voting engine — merge into Decision Making |
| FINAL_VALIDATION.md | — | **Historical** | Validation report — historical |
| IMPLEMENTATION_STATUS.md | 13. Development (BACKLOG) | **Archive** | Status doc — archive (ephemeral) |
| INTEGRATION_ASSESSMENT_REPORT.md | — | **Archive** | Assessment report — archive |
| MISSION_COMPLETE.md | — | **Historical** | Mission log — historical |
| NPC_INITIAL_DEPLOYMENT_SEQUENCE.md | 11. AI Manager (EXPANSION_LOGIC) | **Supporting** | Deployment sequence |
| PLAYER_HANDOFF.md | — | **Historical** | Agent handoff — historical |
| RESUPPLY_AND_ESCALATION_ARCHITECTURE.md | 11. AI Manager (CONSTRUCTION_SUBSYSTEM) | **Supporting** | Escalation architecture |
| astrolift_corporation.md | 12. Gameplay (CORPORATIONS) | **Redirect** | Content → Corporations |
| escalation_data_flow.md | 11. AI Manager | **Merge** | Merge into Architecture overview |
| luna_ai_manager_visualization.md | 11. AI Manager | **Archive** | Visualization — archive |

---

## docs/architecture/biology/ — Biology Models

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| README.md | 4. Planetary Simulation (BIOSPHERE) | **Supporting** | Biology overview — merge into Biosphere |
| biology_models.md | 4. Planetary Simulation (BIOSPHERE) | **Canonical** | Core biology model doc |
| biome_model.md | 4. Planetary Simulation (BIOME_SYSTEM) | **Canonical** | Core biome model doc |
| terrasim_service.md | 4. Planetary Simulation (TERRASIM) | **Canonical** | TerraSim service intent |

---

## docs/architecture/core/ — Core Architecture

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| modular_containers.md | 13. Development (ARCHITECTURE) | **Supporting** | Container pattern — merge into Architecture |

---

## docs/architecture/economy/ — Economy Documentation

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| CONTRACTS.md | 7. Economy (CONTRACTS) | **Canonical** | Core contracts doc |
| CURRENCY_AND_EXCHANGE.md | 7. Economy (CURRENCY) | **Canonical** | Currency system |
| FISCAL_POLICY_AND_FEES.md | 7. Economy (ECONOMY_OVERVIEW) | **Supporting** | Fiscal policy — merge into Overview |
| ISRU_PRICING_MODEL.md | 8. Manufacturing (ISRU) | **Redirect** | Content → ISRU canonical page |
| LEDGERS.md | 7. Economy (ECONOMY_OVERVIEW) | **Supporting** | Ledger system — merge into Markets |
| MARKET_OPERATIONS.md | 7. Economy (MARKETS) | **Canonical** | Market operations |
| PLAYER_CONTRACT_SYSTEM.md | 7. Economy (CONTRACTS) | **Merge** | Merge into Contracts canonical |
| PRICE_DISCOVERY_LIFECYCLE.md | 7. Economy (PRICING) | **Canonical** | Price discovery — core pricing doc |
| VIRTUAL_LEDGER_FLOWS.md | 7. Economy (CURRENCY) | **Supporting** | Ledger flows — merge into Currency |
| economic_baseline.md | 7. Economy (ECONOMY_OVERVIEW) | **Supporting** | Baseline economics — merge into Overview |
| financial_system.md | 7. Economy (ECONOMY_OVERVIEW) | **Merge** | Merge into Overview |
| gcc_coupling_status.md | 7. Economy (CURRENCY) | **Archive** | Status doc — archive (ephemeral) |

---

## docs/architecture/manufacturing/ — Manufacturing

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| MANUFACTURING_SYSTEM_OVERVIEW.md | 8. Manufacturing (MANUFACTURING_OVERVIEW) | **Canonical** | Core manufacturing overview |

---

## docs/architecture/settlement/ — Settlement

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| README.md | 9. Settlements (SETTLEMENTS_OVERVIEW) | **Canonical** | Settlement overview |

---

## docs/architecture/simulation/ — Simulation Documentation

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| SIMULATION_SANDBOX.md | 13. Development | **Archive** | Purpose unclear per Phase 3 — archive |
| atmospheric_maintenance_system.md | 4. Planetary Simulation (ATMOSPHERE) | **Supporting** | Atmosphere maintenance |
| biology_system.md | 4. Planetary Simulation (BIOSPHERE) | **Merge** | Merge into Biosphere canonical |
| biology_terraforming_guide.md | 4. Planetary Simulation (TERRAFORMING) | **Supporting** | Terraforming guide |
| biosphere_system.md | 4. Planetary Simulation (BIOSPHERE) | **Canonical** | Core biosphere doc |
| construction_system.md | 8. Manufacturing (CONSTRUCTION) | **Redirect** | Content → Construction |
| equipment_request_system.md | 11. AI Manager | **Archive** | Equipment system — archive |
| geosphere_system.md | 4. Planetary Simulation (GEOSPHERE) | **Canonical** | Core geosphere doc |
| hycean_planet_system.md | 3. Universe Generation | **Supporting** | Hycean planet type — merge into Celestial Bodies |
| hydrosphere_system.md | 4. Planetary Simulation (HYDROSPHERE) | **Canonical** | Core hydrosphere doc |
| location_system.md | 9. Settlements | **Merge** | Merge into Settlements overview |
| organizations_system.md | 12. Gameplay (CORPORATIONS) | **Redirect** | Content → Corporations |
| solar_system.md | 3. Universe Generation(SOL_SYSTEM) | **Canonical** | Sol system simulation |
| terrainforge_layer.md | 4. Planetary Simulation (SIMULATION_PIPELINE) | **Supporting** | Terrain layer — merge into Pipeline |
| visual_layer_stack.md | 13. Development | **Archive** | Visual layers — archive |

---

## docs/architecture/terrasim/ — TerraSim

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| OVERVIEW.md | 4. Planetary Simulation (TERRASIM) | **Canonical** | Core TerraSim overview |

---

## docs/architecture/structures/ — Structures

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| README.md | 9. Settlements (STRUCTURES) | **Canonical** | Structures overview |

---

## docs/architecture/wormhole/ — Wormhole

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| 00_executive_summary.md | 3. Universe Generation (WORMHOLE_HISTORY) | **Supporting** | Wormhole history summary |

---

## docs/architecture/starsim/ — StarSim

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| MISSING_HOOKS.md | 4. Planetary Simulation (STARSIM) | **Supporting** | Missing hooks — merge into Starsim |
| OVERVIEW.md | 4. Planetary Simulation (STARSIM) | **Canonical** | Core StarSim overview |
| PROCEDURAL_INTENT.md | 4. Planetary Simulation (STARSIM) | **Supporting** | Procedural generation intent |
| TECHNICAL_HISTORY.md | — | **Historical** | Technical history — historical |
| celestial_bodies.md | 3. Universe Generation (CELESTIAL_BODIES) | **Canonical** | Celestial bodies reference |
| star_naming_architecture.md | 14. Reference (GLOSSARY) | **Supporting** | Naming conventions — merge into Glossary |

---

## docs/architecture/stations/ — Stations

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| CERES_GATEWAY.md | 10. Transportation (STATIONS) | **Supporting** | Ceres Gateway station |
| CONVERTED_ROCK_STATIONS.md | 10. Transportation (STATIONS) | **Supporting** | Converted rock stations |
| CRAFT_OPERATIONAL_EVOLUTION.md | 10. Transportation (CRAFT) | **Redirect** | Content → Craft canonical |
| SPECIALIZED_WH_STATIONS.md | 10. Transportation (STATIONS) | **Supporting** | Specialized WH stations |
| SYNTHETIC_MEGA_STATIONS.md | 10. Transportation (STATIONS) | **Supporting** | Synthetic mega stations |
| asteroid_relocation_tug.md | 10. Transportation (CARGO) | **Merge** | Merge into Cargo |
| asteroid_relocation_tug_guide.md | 10. Transportation (CARGO) | **Merge** | Merge into Cargo |
| foundry_logic_and_lunar_elevator.md | 8. Manufacturing | **Supporting** | Foundry logic — merge into Manufacturing |
| l1_lagrange_facilities.md | 10. Transportation (DEPOTS) | **Supporting** | L1 Lagrange facilities |
| precursor_mission_bootstrap_architecture.md | 2. Story (IMPLEMENTATION_PHASES) | **Redirect** | Content → Implementation Phases |
| [stations/] | — | — | All classified above |

---

## docs/architecture/terrain/ — Terrain

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| generation_and_rendering.md | 4. Planetary Simulation (SIMULATION_PIPELINE) | **Supporting** | Terrain rendering — merge into Pipeline |

---

## docs/architecture/logistics/ — Logistics

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| STARSIM_GENERATION_RULES.md | 4. Planetary Simulation (STARSIM) | **Redirect** | Content → StarSim canonical |
| SYSTEM_INDUSTRIAL_CHAINS.md | 8. Manufacturing (MANUFACTURING_PIPELINE) | **Supporting** | Industrial chains — merge into Pipeline |
| l1_depot_processing_intent.md | 10. Transportation (DEPOTS) | **Supporting** | L1 depot processing |
| life_support_waste_recycling_architecture.md | 8. Manufacturing (ISRU) | **Supporting** | Waste recycling — merge into ISRU |
| logistics_architecture.md | 10. Transportation (LOGISTICS_NETWORK) | **Canonical** | Core logistics architecture |
| precursor_supply_tether.md | 2. Story (IMPLEMENTATION_PHASES) | **Redirect** | Content → Implementation Phases |
| wormhole_maintenance_job.md | 3. Universe Generation (ARTIFICIAL_WORMHOLES) | **Supporting** | Wormhole maintenance |
| wormhole_system.md | 3. Universe Generation (NATURAL_WORMHOLES) | **Canonical** | Core wormhole system doc |
| [logistics/navigation/] | — | See below | Classified separately |

---

## docs/architecture/logistics/navigation/ — Navigation

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| INNER_SYSTEM_EXCLUSION.md | 10. Transportation (CYCLERS) | **Supporting** | Inner system exclusion rules |
| INTRA_SYSTEM_PORTALS.md | 3. Universe Generation (ARTIFICIAL_WORMHOLES) | **Supporting** | Intra-system portals |
| TRACY_BFS_MAPPING.md | 10. Transportation (LOGISTICS_NETWORK) | **Archive** | BFS mapping — archive |
| WORMHOLE_NETWORK.md | 3. Universe Generation (NATURAL_WORMHOLES) | **Merge** | Merge into Wormhole canonical |

---

## docs/architecture/isru/ — ISRU

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| 3d_printing.md | 8. Manufacturing (CONSTRUCTION) | **Supporting** | 3D printing — merge into Construction |
| README.md | 8. Manufacturing (ISRU) | **Canonical** | ISRU overview |
| cnt_production.md | 8. Manufacturing (RESOURCE_PROCESSING) | **Supporting** | CNT production — merge into Processing |

---

## docs/architecture/concerns/ — Concerns

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| has_units.md | 9. Settlements | **Merge** | Merge into Settlements overview |

---

## docs/architecture/services/ai_manager/ — Service Files

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| ai_manager_economic_loop.md | 11. AI Manager (ECONOMY_SUBSYSTEM) | **Supporting** | Economic loop — merge into Economy Subsystem |
| [other files in services/] | See individual classification above | — | Classified with ai_manager/ docs |

---

## docs/architecture/systems/ — Systems

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| BIOME_TERRAFORMING_DESIGN.md | 4. Planetary Simulation (TERRAFORMING) | **Canonical** | Core biome terraforming design |
| LUNA_ISRU_GAS_PROCESSING_AND_SKIMMER_OPERATIONS.md | 8. Manufacturing (ISRU) | **Supporting** | Luna ISRU — merge into ISRU |
| PORT_CONNECTION_SYSTEM.md | 10. Transportation (DOCKING) | **Supporting** | Port connections — merge into Docking |
| ai_manager_economic_loop.md | 11. AI Manager (ECONOMY_SUBSYSTEM) | **Merge** | Duplicate of services/ai_manager version |
| alpha_centauri_prep.md | 3. Universe Generation (EDEN_SYSTEM) | **Redirect** | Content → Eden System |
| aol-732356.md | — | **Historical** | AOL reference — historical only |
| asteroid_conversion_physics.md | 10. Transportation | **Split** | Physics → Archive; conversion → Transportation |
| em_power_shield_tiers.md | 12. Gameplay | **Supporting** | EM power tiers — merge into Gameplay |
| em_technology_tree.md | 8. Manufacturing (TECHNOLOGY_LEVELS) | **Supporting** | EM tech tree — merge into Tech Levels |
| environmental_volume_intent.md | 9. Settlements (WORLDHOUSES) | **Redirect** | Content → Worldhouses |
| job_system_mechanics_spec.md | 12. Gameplay | **Supporting** | Job system — merge into Gameplay |
| monitor_interface_layers.md | 13. Development | **Archive** | Monitor interfaces — archive |
| orphaned_system_economics.md | 7. Economy | **Merge** | Merge into Economy overview |
| rig_system.md | 10. Transportation (STATIONS) | **Supporting** | Rig system — merge into Stations |
| sphere_creation_optimization.md | 4. Planetary Simulation (SIMULATION_PIPELINE) | **Supporting** | Sphere optimization — merge into Pipeline |
| survey_and_handshake_protocol.md | 3. Universe Generation (NATURAL_WORMHOLES) | **Supporting** | Survey protocol — merge into Wormholes |

---

## docs/architecture/planning/ — Planning

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| COMPLETE_PHASE_STRUCTURE.md | 13. Development (DEVELOPMENT_PHASES) | **Supporting** | Phase structure — merge into Phases |
| DEVELOPMENT_ROADMAP.md | 13. Development (DEVELOPMENT_PHASES) | **Canonical** | Core development roadmap |
| PLANNING_DOCUMENT.md | 13. Development | **Archive** | Planning doc — archive (ephemeral) |
| geological_features_architecture.md | 4. Planetary Simulation (GEO SPHERE) | **Supporting** | Geological features — merge into Geosphere |
| geological_features_design_intent.md | 4. Planetary Simulation (GEO SPHERE) | **Merge** | Merge into Geosphere canonical |

---

## docs/architecture/glossary/ — Glossary

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| system_mechanics.md | 14. Reference (GLOSSARY) | **Canonical** | Core system mechanics glossary |

---

## docs/architecture/intent/ — Design Intent Documents

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| DUAL_ECONOMY_INTENT.md | 7. Economy (CURRENCY) | **Canonical** | Dual economy intent — core doc |
| LOGISTICS_PROVIDER_INTENT.md | 10. Transportation (LOGISTICS_NETWORK) | **Supporting** | Logistics provider intent |
| PLAYER_UI_VISION.md | 12. Gameplay (PLAYER_EXPERIENCE) | **Redirect** | Content → Player Experience |
| SIMEARTH_ADMIN_VISION.md | 13. Development | **Archive** | Admin vision — archive |
| SYSTEM_CLASSIFICATION_INTENT.md | 3. Universe Generation (CELESTIAL_BODIES) | **Supporting** | System classification intent |
| WORMHOLE_NETWORK_INTENT.md | 3. Universe Generation (NATURAL_WORMHOLES) | **Canonical** | Wormhole network intent — core doc |
| base_rig_intent.md | 10. Transportation (STATIONS) | **Supporting** | Base rig intent |
| l1_depot_shell_intent.md | 10. Transportation (DEPOTS) | **Supporting** | L1 depot shell intent |
| operational_data_guardrails.md | 13. Development (CODING_STANDARDS) | **Merge** | Merge into Coding Standards |
| precursor_bootstrap_intent.md | 2. Story (IMPLEMENTATION_PHASES) | **Redirect** | Content → Implementation Phases |
| skimmer_craft_intent.md | 10. Transportation (CRAFT) | **Canonical** | Skimmer craft intent — core doc |
| worldhouse_intent.md | 9. Settlements (WORLDHOUSES) | **Canonical** | Worldhouse intent — core doc |

---

## docs/architecture/operations/ — Operations

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| ADMIN_DASHBOARD_REDESIGN.md | 13. Development | **Archive** | Admin redesign — archive |
| DEVELOPMENT_ROADMAP.md | 13. Development (DEVELOPMENT_PHASES) | **Merge** | Duplicate of planning/ version |
| NPC_INITIAL_DEPLOYMENT_SEQUENCE.md | 11. AI Manager (EXPANSION_LOGIC) | **Merge** | Duplicate of ai_manager/ version |
| component_production_logic.md | 8. Manufacturing (RESOURCE_PROCESSING) | **Supporting** | Component production — merge into Processing |
| isru_operations.md | 8. Manufacturing (ISRU) | **Supporting** | ISRU operations — merge into ISRU |
| precursor_industrial_loop.md | 2. Story (IMPLEMENTATION_PHASES) | **Redirect** | Content → Implementation Phases |
| precursor_mission_bootstrap_architecture.md | 2. Story (IMPLEMENTATION_PHASES) | **Merge** | Duplicate of stations/ version |
| recovery_logic.json | — | **Archive** | JSON data — archive |
| wh-expansion.md | 9. Settlements (EXPANSION) | **Supporting** | Worldhouse expansion |
| work_camp_to_settlement_flow.md | 9. Settlements (EXPANSION) | **Supporting** | Work camp flow — merge into Expansion |

---

## docs/gameplay/ — Gameplay Documentation

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| EASTER_EGGS.md | 12. Gameplay | **Archive** | Easter eggs — archive (fun but not canonical) |
| mechanics.md | 12. Gameplay (GAMEPLAY_OVERVIEW) | **Canonical** | Core gameplay mechanics |
| player_experience_boundaries.md | 12. Gameplay (PLAYER_PROGRESSION) | **Supporting** | Player experience boundaries |
| terraforming.md | 4. Planetary Simulation(TERRAFORMING) | **Redirect** | Content → Terraforming canonical |

---

## docs/reference/ — Reference Documents

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| ARCHITECTURE_ANSWERS_FOR_GROK.md | — | **Historical** | Grok answers — historical only |
| CELESTIAL_BODY_DATA_CONVENTIONS.md | 3. Universe Generation (CELESTIAL_BODIES) | **Supporting** | Celestial body conventions |
| COMPLETED_TASKS_ARCHIVE.md | — | **Archive** | Task archive — archive (ephemeral) |
| DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md | 8. Manufacturing (BLUEPRINTS) | **Canonical** | Blueprint visualization intent |
| DESIGN_INTENT_SEALED_VOLUME_ATMOSPHERE.md | 4. Planetary Simulation (ATMOSPHERE) | **Supporting** | Atmosphere sealed volume intent |
| DIAGNOSTIC_SOL_SEEDING.md | 3. Universe Generation (SOL_SYSTEM) | **Supporting** | Sol seeding diagnostics |
| GAME_DESIGN_INTENT.md | 1. Vision (DESIGN_PHILOSOPHY) | **Canonical** | Core game design intent |
| INVENTORY_AND_STORAGE.md | 8. Manufacturing (MANUFACTURING_OVERVIEW) | **Supporting** | Inventory/storage — merge into Manufacturing |
| MASTER_IMPLEMENTATION_GUIDE.md | 13. Development (DEVELOPMENT_PHASES) | **Supporting** | Implementation guide — merge into Phases |
| README.md | docs/reference/ | **Archive** | Reference README — merge into wiki START_HERE |

---

## docs/developer/ — Developer Documentation

### Root-Level Developer Docs

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| ADMIN_DASHBOARD_REDESIGN.md | 13. Development | **Archive** | Admin redesign — archive |
| ADMIN_MONITORING.md | 13. Development | **Archive** | Admin monitoring — archive |
| ADMIN_SYSTEM.md | 13. Development | **Archive** | Admin system — archive |
| AI_EARTH_MAP_GENERATION.md | 4. Planetary Simulation (SIMULATION_PIPELINE) | **Supporting** | Earth map generation — merge into Pipeline |
| AI_MANAGER_ECONOMIC_ALIGNMENT_REVIEW.md | 11. AI Manager (ECONOMY_SUBSYSTEM) | **Archive** | Review report — archive |
| AI_MANAGER_FUTURE_DEVELOPMENT.md | 13. Development (DEVELOPMENT_PHASES) | **Supporting** | Future dev — merge into Phases |
| AI_MANAGER_PLANNER.md | 11. AI Manager (DECISION_MAKING) | **Supporting** | Planner — merge into Decision Making |
| ALPHA_CENTAURI_GENERATOR.md | 3. Universe Generation(EDEN_SYSTEM) | **Redirect** | Content → Eden System |
| AUTOMATIC_TERRAIN_GENERATOR.md | 4. Planetary Simulation (SIMULATION_PIPELINE) | **Supporting** | Terrain generator — merge into Pipeline |
| BLUEPRINT_COST_SCHEMA_GUIDE.md | 8. Manufacturing (BLUEPRINTS) | **Canonical** | Blueprint cost schema guide |
| COST_SCHEMA_CONSUMPTION_GUIDE.md | 8. Manufacturing (BLUEPRINTS) | **Merge** | Merge into Blueprint Cost Schema Guide |
| CRITICAL_TESTING_FIXES.md | 13. Development (TESTING) | **Archive** | Testing fixes — archive (ephemeral) |
| DATA_DRIVEN_SYSTEMS.md | 13. Development (ARCHITECTURE) | **Canonical** | Data-driven systems architecture |
| DEPLOYMENT.md | 13. Development | **Supporting** | Deployment guide |
| DIGITAL_TWIN_SANDBOX.md | 4. Planetary Simulation (SIMULATION_SANDBOX) | **Archive** | Sandbox doc — archive per Phase 3 |
| ELEVATION_DATA.md | 4. Planetary Simulation (SIMULATION_PIPELINE) | **Supporting** | Elevation data — merge into Pipeline |
| EXTERNAL_REFERENCES.md | 14. Reference | **Supporting** | External references — move to Reference |
| FREECIV_INTEGRATION.md | — | **Historical** | FreeCiv integration — historical |
| GROK_TASK_ALIO_SURFACE_VIEW.md | — | **Historical** | Grok task — historical |
| GROK_TASK_NASA_TERRAIN_HIERARCHY.md | — | **Historical** | Grok task — historical |
| JSON_DATA_GUIDE.md | 13. Development (JSON_STANDARDS) | **Canonical** | JSON data guide |
| LAYERED_RENDERING.md | 4. Planetary Simulation (SIMULATION_PIPELINE) | **Supporting** | Layered rendering — merge into Pipeline |
| LLM_AGENT_TASK_PROTOCOL.md | 13. Development (AI_WORKFLOW) | **Canonical** | Agent task protocol |
| LOCAL_BUBBLE_EXPANSION.md | 3. Universe Generation (LOCAL_BUBBLE) | **Redirect** | Content → Local Bubble |
| MAP_SYSTEM.md | 4. Planetary Simulation (SIMULATION_PIPELINE) | **Supporting** | Map system — merge into Pipeline |
| PROTOPLANET_TERRAIN.md | 4. Planetary Simulation (GEO SPHERE) | **Supporting** | Protoplanet terrain — merge into Geosphere |
| README.md | docs/developer/ | **Archive** | Developer README — merge into wiki START_HERE |
| STAR_SYSTEM_NAMING_STANDARDS.md | 14. Reference (GLOSSARY) | **Supporting** | Naming standards — merge into Glossary |
| SURFACE_VIEW_IMPLEMENTATION_PLAN.md | 13. Development | **Archive** | Implementation plan — archive |
| TERRAFORMABLE_PLANETS.md | 3. Universe Generation (CELESTIAL_BODIES) | **Supporting** | Terraformable planets — merge into Celestial Bodies |
| TERRAFORMING_SIMULATION.md | 4. Planetary Simulation (TERRAFORMING) | **Merge** | Merge into Terraforming canonical |
| TILESET_README.md | 13. Development (JSON_STANDARDS) | **Supporting** | Tileset guide — merge into JSON Standards |
| UI_IMPLEMENTATION.md | 12. Gameplay (PLAYER_EXPERIENCE) | **Redirect** | Content → Player Experience |
| WORMHOLE_SCOUTING_INTEGRATION.md | 3. Universe Generation (NATURAL_WORMHOLES) | **Supporting** | Wormhole scouting — merge into Wormholes |
| ai_testing_framework.md | 13. Development (TESTING) | **Supporting** | Testing framework — merge into Testing |
| architectural_todos.md | — | **Archive** | Todo list — archive (ephemeral) |
| claude_notes.md | — | **Historical** | Claude notes — historical |
| deployment_refinement.md | 13. Development | **Merge** | Merge into Deployment |
| development_notes.md | — | **Historical** | Dev notes — historical |
| freeciv_geographical_patterns.json | — | **Historical** | JSON data — historical |
| orbital_depot_migration.md | 9. Settlements (ORBITAL_SETTLEMENTS) | **Supporting** | Depot migration — merge into Orbital Settlements |
| pending_changes.md | — | **Archive** | Pending changes — archive (ephemeral) |
| planet_ui_development_plan.md | 12. Gameplay | **Merge** | Merge into Player Experience |
| rails_terraforming_prototype.md | — | **Historical** | Prototype — historical |
| refactoring_guide.md | 13. Development (CODING_STANDARDS) | **Supporting** | Refactoring guide — merge into Coding Standards |
| setup.md | 13. Development | **Merge** | Merge into Development Overview |
| sol_data_organization.md | 3. Universe Generation(SOL_SYSTEM) | **Supporting** | Sol data organization |
| spec_stabilization.md | 13. Development (TESTING) | **Supporting** | Spec stabilization — merge into Testing |
| ui_enhancements.md | 12. Gameplay | **Archive** | UI enhancements — archive |

---

## docs/storyline/ — Story Documents

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| 01_story_arc.md | 2. Story (STORY_OVERVIEW) | **Canonical** | Core story arc |
| 01_story_arc.md.bak | — | **Archive** | Backup file — archive |
| 02_crisis_mechanics.md | 2. Story (NARRATIVE_ACTS) | **Supporting** | Crisis mechanics |
| 03_consortium_framework.md | 2. Story (STORY_OVERVIEW) | **Supporting** | Consortium framework |
| 04_terra_gen_consortium.md | 2. Story (STORY_OVERVIEW) | **Merge** | Merge into Story Overview |
| 05_physics_topology.md | 4. Planetary Simulation | **Merge** | Physics topology — merge into Simulation Overview |
| 06_deployment_hierarchy.md | 9. Settlements (SETTLEMENTS_OVERVIEW) | **Redirect** | Content → Settlements Overview |
| 07_procedural_generation.md | 4. Planetary Simulation (STARSIM) | **Supporting** | Procedural generation — merge into StarSim |
| 08_ai_intelligence.md | 11. AI Manager (AI_MANAGER_OVERVIEW) | **Supporting** | AI intelligence — merge into AI Manager |
| 09_economic_systems.md | 7. Economy (ECONOMY_OVERVIEW) | **Supporting** | Economic systems — merge into Economy |
| 10_implementation_phases.md | 13. Development (DEVELOPMENT_PHASES) | **Canonical** | Implementation phases |
| 11_lore_canon.md | 2. Story (HISTORICAL_TIMELINE) | **Canonical** | Lore canon |
| 12_lore_mechanics_summary.md | 14. Reference (GLOSSARY) | **Supporting** | Lore-mechanics summary — merge into Glossary |
| PHASE_ALIGNMENT_SUMMARY_2026-06-18.md | 13. Development (DEVELOPMENT_PHASES) | **Archive** | Phase alignment — archive (ephemeral) |
| README.md | docs/storyline/ | **Merge** | Storyline README — merge into START_HERE |
| ai_manager_tuning.md | 11. AI Manager (DECISION_MAKING) | **Supporting** | AI tuning — merge into Decision Making |
| multi_wormhole_event.md | 3. Universe Generation (NATURAL_WORMHOLES) | **Supporting** | Multi-wormhole event — merge into Wormholes |
| snap_event_and_network_expansion.md | 2. Story (SNAP_EVENT) | **Canonical** | Snap Event core doc |
| system_maturity_conditions.md | 12. Gameplay (PLAYER_PROGRESSION) | **Supporting** | System maturity — merge into Player Progression |

---

## docs/planning/ — Planning Documents

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| AI-MANAGER—LUNA-BEHAVIOR-GOALS.md | 11. AI Manager (EXPANSION_LOGIC) | **Supporting** | Luna behavior goals |
| GALAXY-GAME-PHASE-ALIGNMENT.md | 13. Development (DEVELOPMENT_PHASES) | **Merge** | Merge into Development Phases |
| GALAXY-GAME-PLANNING-GOALS.md | 1. Vision (PROJECT_GOALS) | **Supporting** | Planning goals — merge into Project Goals |
| MISSION_PHASING_AND_TIMELINE.md | 13. Development (DEVELOPMENT_PHASES) | **Merge** | Merge into Development Phases |

---

## docs/testing/ — Testing Documents

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| CI_CD_PIPELINE.md | 13. Development | **Supporting** | CI/CD pipeline — merge into Dev Overview |
| FLAKY_TESTS_ANALYSIS.md | 13. Development (TESTING) | **Archive** | Flaky test analysis — archive (ephemeral) |
| GRINDER_PROTOCOL.md | 13. Development (AI_WORKFLOW) | **Supporting** | Grinder protocol — merge into AI Workflow |
| PRACTICAL_TESTING_GUIDE.md | 13. Development (TESTING) | **Canonical** | Core testing guide |
| TESTING_PHILOSOPHY.md | 13. Development (TESTING) | **Canonical** | Testing philosophy |

---

## docs/api/ — API Documentation

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| README.md | 13. Development (DEVELOPMENT_OVERVIEW) | **Supporting** | API README — merge into Dev Overview |
| materials.md | 8. Manufacturing (RESOURCES) | **Redirect** | Content → Resources canonical |

---

## docs/flavor/ — Flavor Documents

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| sci_fi_easter_eggs.md | 12. Gameplay | **Archive** | Easter eggs — archive (fun but not canonical) |

---

## docs/legacy/ — Legacy Documents

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| PATHS.PAS | — | **Historical** | Pascal source — historical only |

---

## docs/wiki/ — Wiki Reorganization Docs

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| AI-Manager-Logic.md | 11. AI Manager (AI_MANAGER_OVERVIEW) | **Merge** | Merge into AI Manager Overview |
| Atmospheric-Harvesting.md | 4. Planetary Simulation(ATMOSPHERE) | **Supporting** | Atmospheric harvesting |
| Celestial-Systems.md | 3. Universe Generation(UNIVERSE_OVERVIEW) | **Merge** | Merge into Universe Overview |
| Financial-Engine.md | 7. Economy (ECONOMY_OVERVIEW) | **Merge** | Merge into Economy Overview |
| Logistics-and-Hauling.md | 10. Transportation (LOGISTICS_NETWORK) | **Merge** | Merge into Logistics Network |
| Market-and-AI-Bootstrapping.md | 7. Economy (NPC_ECONOMY) | **Merge** | Merge into NPC Economy |
| Player-Roles-and-Alignment.md | 12. Gameplay (PLAYER_EXPERIENCE) | **Canonical** | Player roles — core doc |
| Resource-and-Market-Logistics.md | 7. Economy + 10. Transportation | **Split** | Split: resource → Economy; logistics → Transportation |
| Scenario-Super-Mars.md | 2. Story (NARRATIVE_ACTS) | **Supporting** | Super Mars scenario |
| System-Blueprints.md | 8. Manufacturing (BLUEPRINTS) | **Merge** | Merge into Blueprints canonical |
| System-Commands.md | 11. AI Manager (AI_MANAGER_COMMAND) | **Merge** | Merge into AI Manager Command |
| getting_started.md | 1. Vision (START_HERE) | **Redirect** | Content → START_HERE canonical |

---

## docs/wiki_reorganization/phase3_alignment/ — Phase 3 Deliverables

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| PHASE3_CANONICAL_ALIGNMENT_REPORT.md | 13. Development (ARCHITECTURE) | **Supporting** | Canonical alignment report |
| ARCHITECTURE_DECISION_LOG.md | 13. Development (ARCHITECTURE) | **Canonical** | Architecture decision log |
| DOCUMENTATION_UPDATE_PLAN.md | — | **Archive** | Update plan — archive after completion |
| TRUE_BLOCKERS_ONLY.md | 13. Development (ARCHITECTURE) | **Supporting** | Blocker analysis |
| RESOLVED_CONFLICTS.md | 13. Development (ARCHITECTURE) | **Supporting** | Resolved conflicts |
| OPEN_DESIGN_DECISIONS.md | 13. Development (ARCHITECTURE) | **Supporting** | Open decisions |
| BACKLOG_PRIORITY_ALIGNMENT.md | 13. Development (BACKLOG) | **Canonical** | Backlog alignment |
| README.md | 1. Vision (START_HERE) | **Merge** | Executive summary — merge into START_HERE |

---

## docs/wiki_reorganization/phase4/ — Phase 4 Deliverables

| Document | Wiki Section | Classification | Notes |
|----------|-------------|----------------|-------|
| WIKI_SITE_MAP.md | 1. Vision (START_HERE) | **Canonical** | This site map |
| DOCUMENT_CLASSIFICATION.md | — | **Supporting** | This classification document |
| [remaining phase4 docs] | See individual entries | — | Classified below |

---

## Classification Summary

| Category | Count | Action |
|----------|-------|--------|
| **Canonical** (authoritative) | ~35 | Move to canonical wiki locations |
| **Supporting** (detailed sub-topics) | ~60 | Move to wiki supporting locations |
| **Merge** (content in another doc) | ~25 | Merge into target; archive source |
| **Split** (multiple topics) | ~3 | Split content; archive source |
| **Archive** (ephemeral/historical) | ~30 | Move to docs/archive/ |
| **Historical** (development history) | ~15 | Move to docs/archive/historical/ |
| **Redirect** (content in another doc) | ~20 | Note redirect target; archive source |

**Total documents classified**: ~188

---

## Notes on Classification Decisions

### Why Some Docs Are Archived (Not Moved to Wiki)
- Status reports, execution plans, agent handoffs — ephemeral by nature
- Review/audit reports — valuable as historical record but not active reference
- Backup files (.bak), pending changes lists — no lasting value

### Why Some Docs Are Historical (Not Archived)
- Agent task protocols, Grok/Claude conversations — show development evolution
- Prototype code references — show how systems evolved
- FreeCiv integration research — shows design exploration path

### Canonical Page Selection Criteria
A document becomes a **Canonical** wiki page when:
1. It defines a core game system (not just describes implementation)
2. Multiple other documents reference or depend on it
3. It contains design intent, not just status updates
4. A new contributor needs to understand this topic
