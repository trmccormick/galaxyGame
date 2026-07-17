# Document Authority Map — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Classify each document's likely authority level  
**Rule**: No irreversible assumptions; human review required for UNKNOWN classifications

---

## Classification Key

| Level | Meaning |
|-------|---------|
| **CANONICAL** | Appears to represent current design decisions; actively referenced by code or other docs |
| **REFERENCE** | Useful supporting information; may be partially outdated but still valuable |
| **HISTORICAL** | Earlier design exploration; preserved for context but superseded |
| **DEPRECATED** | Clearly replaced by newer decisions; should not be followed |
| **UNKNOWN** | Requires human review to determine authority level |

---

## Root-Level Documents

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `README.md` | CANONICAL | Active project overview with current dev status, tech stack, quick start |
| `CURRENT_STATUS.md` | CANONICAL | Active development tracker (Phase 3: Integration & Restoration) |
| `personal_notes.txt` | HISTORICAL | Personal notes, no active references |
| `phase1_mars_blueprint_architecture.md` | HISTORICAL | Phase 1 specific; superseded by later architecture docs |
| `phase4_tests.txt` | HISTORICAL | Phase 4 test documentation; phase likely completed or abandoned |
| `resume_rspec_grinding.md` | REFERENCE | RSpec recovery strategy may still be relevant |
| `BIOME_RENDERING_TEST.md` | REFERENCE | Test documentation, may reference current systems |
| `CHROMAKEY_README.md` | HISTORICAL | Sprite extraction process; tooling-specific |
| `CHROMAKEY_PHASE3_README.md` | HISTORICAL | Phase 3 specific; likely superseded |
| `OVERNIGHT_GEOTIFF_README.md` | REFERENCE | GeoTIFF automation may still be in use |
| `TEST_COVERAGE_BIOSPHERE_GENERATION.md` | REFERENCE | Test coverage documentation, may be current |

---

## docs/README.md — Documentation Hub

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/README.md` | CANONICAL | Main navigation hub; actively maintained with current status links |
| `docs/GLOSSARY_SYSTEM_MECHANICS.md` | CANONICAL | Core mechanics glossary with active system definitions (cyclers, ISRU, four-layer vision) |
| `docs/GUARDRAILS.md` | CANONICAL | Active development constraints; referenced by AI Manager docs |
| `docs/MIGRATION_GUIDE.md` | REFERENCE | Migration guidance; may need verification against current state |
| `docs/PRACTICAL_TESTING_GUIDE.md` | CANONICAL | RSpec best practices; marked as ⭐ in navigation |

---

## docs/agent/ — Agent Instructions (657 files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/agent/README.md` | REFERENCE | Agent system overview; being migrated per docs/README.md |
| `docs/agent/AGENT_ROUTING.md` | UNKNOWN | Agent routing logic; needs review |
| `docs/agent/DOCUMENTATION_STRATEGIST.md` | UNKNOWN | Role definition; needs review |
| `docs/agent/IMPLEMENTATION_AGENT_README.md` | REFERENCE | Implementation instructions; may still be in use |
| `docs/agent/SESSION_STRATEGIST.md` | UNKNOWN | Session workflow; needs review |
| `docs/agent/TASK_TEMPLATE.md` | REFERENCE | Task template; actively referenced by agent_guides.md |
| `docs/agent/WORKFLOW_README.md` | REFERENCE | Workflow documentation; may still be relevant |
| `docs/agent/CURRENT_STATUS.md` | CANONICAL | Active agent work tracker |
| `docs/agent/BACKLOG_AUDIT_SESSION_SUMMARY.md` | HISTORICAL | Audit results from completed session |
| `docs/agent/BACKLOG_AUDIT_VERIFICATION_STRATEGY.md` | REFERENCE | Verification strategy may still be applicable |
| `docs/agent/LUNA_MVP_BLOCKER_CHECKLIST.md` | REFERENCE | Luna MVP blockers; may still be relevant to current work |
| `docs/agent/TEST_ENVIRONMENT_SETUP.md` | REFERENCE | Test environment config; may need verification |
| `docs/agent/GPT41_VACATION_BATCH.md` | HISTORICAL | Specific batch processing notes |
| `docs/agent/README_ADDITIONS.md` | HISTORICAL | Additions log from past session |
| `docs/agent/chat-logs/` | HISTORICAL | Chat session logs; ephemeral by nature |
| `docs/agent/planning/` | REFERENCE | Agent planning documents; may contain current plans |
| `docs/agent/reference/` | REFERENCE | Agent reference materials |
| `docs/agent/rules/` | UNKNOWN | Agent behavior rules; needs review |
| `docs/agent/tasks/` | HISTORICAL | Task files from completed sessions |
| `docs/agent/archive/` | DEPRECATED | Archived agent documents |

---

## docs/api/ — API Documentation

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/api/README.md` | REFERENCE | Admin endpoints reference; may need verification against current controllers |
| `docs/api/materials.md` | REFERENCE | Materials API; may need verification against current models |

---

## docs/architecture/overview.md

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/overview.md` | CANONICAL | Master architecture overview; describes current system components (StarSim, TerraSim, AI Manager, economy) |

---

## docs/architecture/adrs/ — Architecture Decision Records

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/adrs/ADR-001-Bridge-Bus-Topology.md` | CANONICAL | Formal ADR; represents a design decision |
| `docs/architecture/adrs/GUARDRAILS.md` | CANONICAL | ADR guardrails; actively referenced |
| `docs/architecture/adrs/IMPLEMENTATION_SPEC_AND_GOVERNANCE.md` | CANONICAL | Implementation governance; active reference |
| `docs/architecture/adrs/PROPOSAL_TO_CLAUDE.md` | HISTORICAL | Proposal document; likely completed or superseded |

---

## docs/architecture/ai_manager/ — AI Manager Architecture (30+ files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` | CANONICAL | Core AI Manager architecture; describes 8 core files and orchestration flow |
| `docs/architecture/ai_manager/00_architecture_overview.md` | CANONICAL | AI Manager architecture overview |
| `docs/architecture/ai_manager/01_probe_system.md` | REFERENCE | Probe system design; may need verification against code |
| `docs/architecture/ai_manager/02_settlement_planning.md` | REFERENCE | Settlement planning logic |
| `docs/architecture/ai_manager/03_resource_decisions.md` | REFERENCE | Resource decision logic |
| `docs/architecture/ai_manager/89→8_EXECUTION_PLAN.md` | UNKNOWN | Execution plan; needs review for current relevance |
| `docs/architecture/ai_manager/89→8_SURGICAL_MAP.md` | UNKNOWN | Surgical map; needs review |
| `docs/architecture/ai_manager/AI_MANAGER_BLOAT_AUDIT.md` | REFERENCE | Bloat audit; may inform refactoring decisions |
| `docs/architecture/ai_manager/AI_MANAGER_CODE_REVIEW_PROTOCOL.md` | CANONICAL | Code review protocol; active process document |
| `docs/architecture/ai_manager/AI_MANAGER_COMMAND.md` | REFERENCE | Command reference; may need verification |
| `docs/architecture/ai_manager/AI_MANAGER_DAMAGE_INVENTORY.md` | UNKNOWN | Damage inventory system; needs review |
| `docs/architecture/ai_manager/AI_MANAGER_DESIGN_FAILURES.md` | REFERENCE | Design failures; valuable learning document |
| `docs/architecture/ai_manager/AI_MANAGER_ECONOMIC_LOGIC_UPDATE.md` | REFERENCE | Economic logic update; may be partially superseded |
| `docs/architecture/ai_manager/AI_MANAGER_EVENT_FLOW.md` | CANONICAL | Event flow documentation; describes active system behavior |
| `docs/architecture/ai_manager/AI_MANAGER_HAMMER_INTEGRATION.md` | CANONICAL | Hammer Protocol integration; actively referenced in code |
| `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` | CANONICAL | AI Manager intent document; design intent |
| `docs/architecture/ai_manager/AI_MANAGER_MASTER_PLAN.md` | REFERENCE | Master plan; may contain outdated elements |
| `docs/architecture/ai_manager/AI_MANAGER_ORCHESTRATOR_SPEC.md` | CANONICAL | Orchestrator specification; active reference |
| `docs/architecture/ai_manager/AI_MANAGER_PRICING_INTENT.md` | REFERENCE | Pricing intent; needs verification against current economy docs |
| `docs/architecture/ai_manager/AI_MANAGER_ROLE.md` | CANONICAL | AI Manager role definition; active reference |
| `docs/architecture/ai_manager/AI_MANAGER_WAYFINDING.md` | CANONICAL | Wayfinding logic; actively referenced in wormhole_coordinator.rb |
| `docs/architecture/ai_manager/AI_MANAGER_WORMHOLE_EXPANSION.md` | CANONICAL | Wormhole expansion; active system |
| `docs/architecture/ai_manager/CLAUDE_5PM_GO.md` | HISTORICAL | Claude handoff notes from specific session |
| `docs/architecture/ai_manager/CLAUDE_HANDOFF.md` | HISTORICAL | Claude handoff document; session-specific |
| `docs/architecture/ai_manager/CONSORTIUM_VOTING_ENGINE.md` | CANONICAL | Consortium voting engine; active system (66% quorum) |
| `docs/architecture/ai_manager/FINAL_VALIDATION.md` | REFERENCE | Validation criteria; may need verification |
| `docs/architecture/ai_manager/IMPLEMENTATION_STATUS.md` | REFERENCE | Status tracker; changes frequently |
| `docs/architecture/ai_manager/INTEGRATION_ASSESSMENT_REPORT.md` | REFERENCE | Integration assessment; may be partially outdated |
| `docs/architecture/ai_manager/MISSION_COMPLETE.md` | HISTORICAL | Mission completion from completed work |
| `docs/architecture/ai_manager/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md` | REFERENCE | NPC deployment sequence; may still be relevant |
| `docs/architecture/ai_manager/PLAYER_HANDOFF.md` | REFERENCE | Player handoff procedures |
| `docs/architecture/ai_manager/RESUPPLY_AND_ESCALATION_ARCHITECTURE.md` | CANONICAL | Resupply and escalation architecture; active system |
| `docs/architecture/ai_manager/astrolift_corporation.md` | UNKNOWN | Astrolift Corporation design; needs review |
| `docs/architecture/ai_manager/escalation_data_flow.md` | REFERENCE | Escalation data flow; may be current |
| `docs/architecture/ai_manager/luna_ai_manager_visualization.md` | REFERENCE | Luna AI Manager visualization |

---

## docs/architecture/biology/ — Biology & Biome Systems

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/biology/README.md` | CANONICAL | Biology system overview; active reference |
| `docs/architecture/biology/biology_models.md` | CANONICAL | Biology model definitions; maps to code models |
| `docs/architecture/biology/biome_model.md` | CANONICAL | Biome model architecture; maps to Biome/Biome models |
| `docs/architecture/biology/terrasim_service.md` | REFERENCE | TerraSim biology service; needs verification against current services |

---

## docs/architecture/concerns/ & docs/architecture/core/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/concerns/has_units.md` | CANONICAL | Has units concern; maps to `app/models/concerns/has_units.rb` |
| `docs/architecture/core/modular_containers.md` | UNKNOWN | Modular containers design; needs review |

---

## docs/architecture/economy/ — Economic Engine (13 files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/economy/CONTRACTS.md` | CANONICAL | Player contract system; maps to active models and services |
| `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` | CANONICAL | GCC/USD peg phases; maps to Financial::Currency model |
| `docs/architecture/economy/FISCAL_POLICY_AND_FEES.md` | CANONICAL | Fiscal policy with specific fee values (0.5%, 0.3%, 3.37%) |
| `docs/architecture/economy/ISRU_PRICING_MODEL.md` | REFERENCE | ISRU pricing; needs verification against current economy services |
| `docs/architecture/economy/LEDGERS.md` | CANONICAL | Ledger system; maps to Financial::LedgerEntry/LedgerManager |
| `docs/architecture/economy/MARKET_OPERATIONS.md` | REFERENCE | Market operations; needs verification |
| `docs/architecture/economy/PLAYER_CONTRACT_SYSTEM.md` | CANONICAL | Player contract system design; active reference |
| `docs/architecture/economy/PRICE_DISCOVERY_LIFECYCLE.md` | CANONICAL | Price discovery lifecycle; active economic mechanism |
| `docs/architecture/economy/VIRTUAL_LEDGER_FLOWS.md` | CANONICAL | Virtual ledger flows; maps to NPC trading system |
| `docs/architecture/economy/economic_baseline.md` | REFERENCE | Economic baseline; may need verification |
| `docs/architecture/economy/financial_system.md` | CANONICAL | Financial system architecture; maps to Financial::Account model |
| `docs/architecture/economy/gcc_coupling_status.md` | REFERENCE | GCC coupling status tracker; changes frequently |

---

## docs/architecture/glossary/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/glossary/system_mechanics.md` | CANONICAL | Core mechanics glossary; maps to active model behavior |

---

## docs/architecture/intent/ — Design Intent Documents (12 files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/intent/DUAL_ECONOMY_INTENT.md` | CANONICAL | Dual economy design intent; active system |
| `docs/architecture/intent/LOGISTICS_PROVIDER_INTENT.md` | REFERENCE | Logistics provider intent; needs verification |
| `docs/architecture/intent/PLAYER_UI_VISION.md` | REFERENCE | Player UI vision; may be partially outdated |
| `docs/architecture/intent/SIMEARTH_ADMIN_VISION.md` | CANONICAL | SimEarth admin vision; core design philosophy |
| `docs/architecture/intent/SYSTEM_CLASSIFICATION_INTENT.md` | CANONICAL | System classification; active in StarSim |
| `docs/architecture/intent/WORMHOLE_NETWORK_INTENT.md` | CANONICAL | Wormhole network design intent; active system |
| `docs/architecture/intent/base_rig_intent.md` | REFERENCE | Base rig intent; needs verification against Rigs::BaseRig model |
| `docs/architecture/intent/l1_depot_shell_intent.md` | REFERENCE | L1 depot shell intent; needs verification |
| `docs/architecture/intent/operational_data_guardrails.md` | CANONICAL | Operational data guardrails; active constraint |
| `docs/architecture/intent/precursor_bootstrap_intent.md` | CANONICAL | Precursor bootstrap design; active AI Manager system |
| `docs/architecture/intent/skimmer_craft_intent.md` | REFERENCE | Skimmer craft intent; needs verification against craft models |
| `docs/architecture/intent/worldhouse_intent.md` | CANONICAL | Worldhouse design intent; maps to Structures::Worldhouse model |

---

## docs/architecture/isru/ — In-Situ Resource Utilization

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/isru/3d_printing.md` | CANONICAL | 3D printing ISRU design; maps to fabricator units |
| `docs/architecture/isru/README.md` | CANONICAL | ISRU system overview; active reference |
| `docs/architecture/isru/cnt_production.md` | REFERENCE | CNT production; needs verification against current manufacturing |

---

## docs/architecture/logic/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/logic/modular_refinery_integration.md` | UNKNOWN | Modular refinery integration; needs review |
| `docs/architecture/logic/shipyard_generational_progression.md` | REFERENCE | Shipyard progression; may map to orbital_shipyard_service.rb |
| `docs/architecture/logic/universal_unit_interface.md` | CANONICAL | Universal unit interface; maps to active unit patterns |

---

## docs/architecture/logistics/ — Logistics Architecture

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/logistics/STARSIM_GENERATION_RULES.md` | REFERENCE | Starsim generation rules; needs verification against star_sim services |
| `docs/architecture/logistics/SYSTEM_INDUSTRIAL_CHAINS.md` | CANONICAL | System industrial chains; active economic concept |
| `docs/architecture/logistics/l1_depot_processing_intent.md` | REFERENCE | L1 depot processing intent; needs verification |
| `docs/architecture/logistics/life_support_waste_recycling_architecture.md` | UNKNOWN | Life support waste recycling; needs review |
| `docs/architecture/logistics/logistics_architecture.md` | CANONICAL | Logistics architecture overview; active reference |
| `docs/architecture/logistics/precursor_supply_tether.md` | REFERENCE | Precursor supply tether; may be partially outdated |
| `docs/architecture/logistics/wormhole_maintenance_job.md` | CANONICAL | Wormhole maintenance job; active AI Manager system |
| `docs/architecture/logistics/wormhole_system.md` | CANONICAL | Wormhole system design; maps to Wormhole model and services |
| `docs/architecture/logistics/navigation/INNER_SYSTEM_EXCLUSION.md` | UNKNOWN | Inner system exclusion rules; needs review |
| `docs/architecture/logistics/navigation/INTRA_SYSTEM_PORTALS.md` | REFERENCE | Intra-system portal logic; may be partially outdated |
| `docs/architecture/logistics/navigation/TRACY_BFS_MAPPING.md` | REFERENCE | Tracy BFS mapping; maps to wormhole_coordinator.rb BFS logic |
| `docs/architecture/logistics/navigation/WORMHOLE_NETWORK.md` | CANONICAL | Wormhole network documentation; active reference |

---

## docs/architecture/lookup/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/lookup/unit_lookup_service.md` | CANONICAL | Unit lookup service; maps to Lookup::UnitLookupService |

---

## docs/architecture/manufacturing/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md` | REFERENCE | Manufacturing overview (marked as Draft/Stub 2026-04-27); incomplete |

---

## docs/architecture/operations/ — Operations & Construction

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/operations/ADMIN_DASHBOARD_REDESIGN.md` | REFERENCE | Admin dashboard redesign; may be partially implemented |
| `docs/architecture/operations/DEVELOPMENT_ROADMAP.md` | REFERENCE | Development roadmap; changes frequently |
| `docs/architecture/operations/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md` | REFERENCE | NPC deployment sequence; may still be relevant |
| `docs/architecture/operations/component_production_logic.md` | CANONICAL | Component production logic; maps to manufacturing services |
| `docs/architecture/operations/isru_operations.md` | CANONICAL | ISRU operations guide; active reference |
| `docs/architecture/operations/precursor_industrial_loop.md` | REFERENCE | Precursor industrial loop; may be partially outdated |
| `docs/architecture/operations/precursor_mission_bootstrap_architecture.md` | REFERENCE | Precursor mission bootstrap; needs verification |
| `docs/architecture/operations/recovery_logic.json` | REFERENCE | Recovery logic config; data file, may change |
| `docs/architecture/operations/wh-expansion.md` | CANONICAL | Wormhole expansion operations; active system |
| `docs/architecture/operations/work_camp_to_settlement_flow.md` | REFERENCE | Work camp flow; needs verification against current settlement services |

---

## docs/architecture/patterns/ — Design Patterns

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/patterns/settlement_patterns.md` | CANONICAL | Settlement patterns; active reference |
| `docs/architecture/patterns/planetary_patterns/INTERPLANETARY_BASE_TIMELINE_COST_ANALYSIS.md` | REFERENCE | Cost analysis; may be partially outdated |
| `docs/architecture/patterns/planetary_patterns/lunar_isru_flow.md` | REFERENCE | Lunar ISRU flow; needs verification |
| `docs/architecture/patterns/planetary_patterns/lunar_isru_flow_2.md` | REFERENCE | Lunar ISRU flow v2; supersedes lunar_isru_flow.md |
| `docs/architecture/patterns/planetary_patterns/lunar_landing_pads_and_storage.md` | REFERENCE | Luna landing pads; needs verification |
| `docs/architecture/patterns/planetary_patterns/saturn_jupiter_pattern_comparison.md` | HISTORICAL | Pattern comparison from specific analysis session |
| `docs/architecture/patterns/planetary_patterns/three_tier_infrastructure.md` | CANONICAL | Three-tier infrastructure; active design pattern |

---

## docs/architecture/planning/ — Planning Documents

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/planning/COMPLETE_PHASE_STRUCTURE.md` | REFERENCE | Phase structure; may be partially outdated |
| `docs/architecture/planning/DEVELOPMENT_ROADMAP.md` | REFERENCE | Development roadmap; changes frequently |
| `docs/architecture/planning/PLANNING_DOCUMENT.md` | REFERENCE | Planning document; may be partially outdated |
| `docs/architecture/planning/geological_features_architecture.md` | CANONICAL | Geological features architecture; maps to CelestialBody::Features models |
| `docs/architecture/planning/geological_features_design_intent.md` | CANONICAL | Geological features design intent; active reference |

---

## docs/architecture/services/ai_manager/ — AI Manager Service Docs (30+ files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/services/ai_manager/AI_LEARNING_SYSTEM.md` | CANONICAL | AI learning system; active in AI Manager |
| `docs/architecture/services/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md` | REFERENCE | Construction economics; needs verification |
| `docs/architecture/services/ai_manager/AI_MANAGER_CYCLER_CONFIGURATION_LOGIC.md` | CANONICAL | Cycler configuration; maps to Cycler model |
| `docs/architecture/services/ai_manager/AI_PATTERN_LEARNING_SYSTEM.md` | CANONICAL | AI pattern learning; active system |
| `docs/architecture/services/ai_manager/AI_PRIORITY_SYSTEM.md` | CANONICAL | AI priority system; maps to AIManager::AiPrioritySystem |
| `docs/architecture/services/ai_manager/CYCLER_MISSION_TIMELINES.md` | REFERENCE | Cycler timelines; needs verification |
| `docs/architecture/services/ai_manager/CYCLER_SYSTEM_ARCHITECTURE.md` | CANONICAL | Cycler system architecture; active reference |
| `docs/architecture/services/ai_manager/EQUIPMENT_TRANSFER_SYSTEM.md` | CANONICAL | Equipment transfer; active system |
| `docs/architecture/services/ai_manager/PATTERN_LEARNING.md` | CANONICAL | Pattern learning; active AI Manager mechanism |
| `docs/architecture/services/ai_manager/PLAYER_EMERGENCY_MISSION.md` | REFERENCE | Emergency mission design; needs verification |
| `docs/architecture/services/ai_manager/TERRAFORMING_PATTERNS.md` | CANONICAL | Terraforming patterns; active system |
| `docs/architecture/services/ai_manager/ai_manager_expansion_and_wormhole_network.md` | CANONICAL | Expansion and wormhole network; active reference |
| `docs/architecture/services/ai_manager/emergency_requisition.md` | REFERENCE | Emergency requisition; needs verification |
| `docs/architecture/services/ai_manager/escalation_service.md` | CANONICAL | Escalation service; maps to EscalationService |
| `docs/architecture/services/ai_manager/governance_and_chaos.md` | UNKNOWN | Governance and chaos theory; needs review |
| `docs/architecture/services/ai_manager/learning_integration.md` | REFERENCE | Learning integration; may be partially outdated |
| `docs/architecture/services/ai_manager/mission_scorer.md` | CANONICAL | Mission scorer; maps to MissionScorer service |
| `docs/architecture/services/ai_manager/planner.md` | CANONICAL | Planner service; maps to LlmPlannerService |
| `docs/architecture/services/ai_manager/priority_mapping.md` | REFERENCE | Priority mapping; needs verification |
| `docs/architecture/services/ai_manager/settlement_plan_example.txt` | REFERENCE | Settlement plan example; illustrative |
| `docs/architecture/services/ai_manager/sol_validation_protocol.md` | CANONICAL | Sol validation protocol; active reference |
| `docs/architecture/services/ai_manager/strategy_selector.md` | CANONICAL | Strategy selector; maps to StrategySelector service |

---

## docs/architecture/settlement/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/settlement/README.md` | CANONICAL | Settlement system overview; active reference |

---

## docs/architecture/simulation/ — Simulation Systems (17 files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/simulation/SIMULATION_SANDBOX.md` | CANONICAL | Simulation sandbox; active reference |
| `docs/architecture/simulation/atmospheric_maintenance_system.md` | CANONICAL | Atmospheric maintenance; maps to atmosphere simulation services |
| `docs/architecture/simulation/biology_system.md` | CANONICAL | Biology simulation; maps to biology models |
| `docs/architecture/simulation/biology_terraforming_guide.md` | REFERENCE | Biology terraforming guide; needs verification |
| `docs/architecture/simulation/biosphere_system.md` | CANONICAL | Biosphere simulation; maps to CelestialBody::Spheres::Biosphere |
| `docs/architecture/simulation/construction_system.md` | REFERENCE | Construction simulation; needs verification |
| `docs/architecture/simulation/equipment_request_system.md` | REFERENCE | Equipment request system; needs verification |
| `docs/architecture/simulation/geosphere_system.md` | CANONICAL | Geosphere simulation; maps to CelestialBody::Spheres::Geosphere |
| `docs/architecture/simulation/hycean_planet_system.md` | CANONICAL | Hycean planet simulation; active world type |
| `docs/architecture/simulation/hydrosphere_system.md` | CANONICAL | Hydrosphere simulation; maps to CelestialBody::Spheres::Hydrosphere |
| `docs/architecture/simulation/location_system.md` | REFERENCE | Location system; needs verification |
| `docs/architecture/simulation/organizations_system.md` | REFERENCE | Organizations system; needs verification against org models |
| `docs/architecture/simulation/solar_system.md` | CANONICAL | Solar system simulation; maps to SolarSystem model |
| `docs/architecture/simulation/terrainforge_layer.md` | REFERENCE | TerrainForge layer; may be partially outdated |
| `docs/architecture/simulation/visual_layer_stack.md` | REFERENCE | Visual layer stack; needs verification against rendering code |

---

## docs/architecture/starsim/ — Star System Simulation

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/starsim/MISSING_HOOKS.md` | REFERENCE | Missing hooks; identifies gaps in current implementation |
| `docs/architecture/starsim/OVERVIEW.md` | CANONICAL | StarSim overview (weathering engine, fidelity tiers, dynamic population); active reference |
| `docs/architecture/starsim/PROCEDURAL_INTENT.md` | CANONICAL | Procedural generation intent; active in StarSim services |
| `docs/architecture/starsim/TECHNICAL_HISTORY.md` | REFERENCE | Technical history; may contain outdated implementation details |
| `docs/architecture/starsim/celestial_bodies.md` | CANONICAL | Celestial bodies in StarSim; maps to celestial body models |
| `docs/architecture/starsim/star_naming_architecture.md` | CANONICAL | Star naming architecture; active reference |

---

## docs/architecture/stations/ — Station Architecture

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/stations/CERES_GATEWAY.md` | REFERENCE | Ceres Gateway design; needs verification |
| `docs/architecture/stations/CONVERTED_ROCK_STATIONS.md` | REFERENCE | Converted rock stations; needs verification |
| `docs/architecture/stations/CRAFT_OPERATIONAL_EVOLUTION.md` | CANONICAL | Craft operational evolution; active system concept |
| `docs/architecture/stations/SPECIALIZED_WH_STATIONS.md` | REFERENCE | Specialized wormhole stations; needs verification |
| `docs/architecture/stations/SYNTHETIC_MEGA_STATIONS.md` | REFERENCE | Synthetic mega stations; needs verification |
| `docs/architecture/stations/asteroid_relocation_tug.md` | CANONICAL | Asteroid relocation tug; maps to craft models |
| `docs/architecture/stations/asteroid_relocation_tug_guide.md` | CANONICAL | Asteroid tug guide; active reference |
| `docs/architecture/stations/foundry_logic_and_lunar_elevator.md` | CANONICAL | Foundry logic and lunar elevator; active system concept |
| `docs/architecture/stations/l1_lagrange_facilities.md` | REFERENCE | L1 Lagrange facilities; needs verification |
| `docs/architecture/stations/precursor_mission_bootstrap_architecture.md` | REFERENCE | Precursor mission bootstrap; may be partially outdated |

---

## docs/architecture/structures/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/structures/README.md` | CANONICAL | Structures architecture overview (2026-03-31); maps to structure models |

---

## docs/architecture/systems/ — Systems Design (16 files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md` | CANONICAL | Biome terraforming design; active reference |
| `docs/architecture/systems/LUNA_ISRU_GAS_PROCESSING_AND_SKIMMER_OPERATIONS.md` | REFERENCE | Luna ISRU gas processing; needs verification |
| `docs/architecture/systems/PORT_CONNECTION_SYSTEM.md` | REFERENCE | Port connection system; needs verification |
| `docs/architecture/systems/ai_manager_economic_loop.md` | CANONICAL | AI Manager economic loop; active system |
| `docs/architecture/systems/alpha_centauri_prep.md` | REFERENCE | Alpha Centauri prep; may be partially outdated |
| `docs/architecture/systems/aol-732356.md` | UNKNOWN | AOL-732356 design document; needs review |
| `docs/architecture/systems/asteroid_conversion_physics.md` | CANONICAL | Asteroid conversion physics; active system concept |
| `docs/architecture/systems/em_power_shield_tiers.md` | REFERENCE | EM power shield tiers; needs verification |
| `docs/architecture/systems/em_technology_tree.md` | REFERENCE | EM technology tree; needs verification |
| `docs/architecture/systems/environmental_volume_intent.md` | CANONICAL | Environmental volume intent; active design concept |
| `docs/architecture/systems/job_system_mechanics_spec.md` | CANONICAL | Job system mechanics spec; active reference |
| `docs/architecture/systems/monitor_interface_layers.md` | REFERENCE | Monitor interface layers; needs verification against rendering code |
| `docs/architecture/systems/orphaned_system_economics.md` | REFERENCE | Orphaned system economics; may be partially outdated |
| `docs/architecture/systems/rig_system.md` | CANONICAL | Rig system design; maps to Rigs::BaseRig model |
| `docs/architecture/systems/sphere_creation_optimization.md` | REFERENCE | Sphere creation optimization; needs verification |
| `docs/architecture/systems/survey_and_handshake_protocol.md` | CANONICAL | Survey and handshake protocol; active AI Manager system |

---

## docs/architecture/terrain/ — Terrain Generation & Rendering

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/terrain/generation_and_rendering.md` | CANONICAL | Terrain generation architecture (2026-07-03); maps to terrain services and GeoTIFF data |

---

## docs/architecture/terrasim/ — TerraSim Architecture

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/terrasim/OVERVIEW.md` | CANONICAL | TerraSim overview (regression/weathering, radiolytic degradation); active reference |

---

## docs/architecture/units/ — Unit Architecture

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/units/3d_printed_fabricators.md` | CANONICAL | 3D-printed fabricators (Mk1-Mk3); maps to fabricator units and blueprints |
| `docs/architecture/units/base_unit.md` | CANONICAL | BaseUnit architecture intent; maps to Units::BaseUnit model |
| `docs/architecture/units/initial_3d_printer.md` | REFERENCE | Initial 3D printer design; needs verification |
| `docs/architecture/units/manifest_integration.md` | REFERENCE | Manifest integration; needs verification |
| `docs/architecture/units/propulsion.md` | CANONICAL | Propulsion system design; maps to Units::Propulsion model |
| `docs/architecture/units/robots.md` | CANONICAL | Robot unit design; maps to Units::Robot model |

---

## docs/architecture/wormhole/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/architecture/wormhole/00_executive_summary.md` | CANONICAL | Wormhole system executive summary; active reference |

---

## docs/developer/ — Development Documentation (~50 files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/developer/README.md` | REFERENCE | Developer docs hub; may need updates |
| `docs/developer/ADMIN_DASHBOARD_REDESIGN.md` | REFERENCE | Admin dashboard redesign; may be partially implemented |
| `docs/developer/ADMIN_MONITORING.md` | REFERENCE | Admin monitoring; needs verification |
| `docs/developer/ADMIN_SYSTEM.md` | REFERENCE | Admin system; needs verification |
| `docs/developer/AI_EARTH_MAP_GENERATION.md` | CANONICAL | AI Earth map generation; maps to EarthMapGenerator service |
| `docs/developer/AI_MANAGER_ECONOMIC_ALIGNMENT_REVIEW.md` | REFERENCE | Economic alignment review; may be partially outdated |
| `docs/developer/AI_MANAGER_FUTURE_DEVELOPMENT.md` | REFERENCE | Future development; by nature forward-looking and speculative |
| `docs/developer/AI_MANAGER_PLANNER.md` | CANONICAL | AI Manager planner; maps to LlmPlannerService |
| `docs/developer/ALPHA_CENTAURI_GENERATOR.md` | CANONICAL | Alpha Centauri generator; maps to star system generation |
| `docs/developer/AUTOMATIC_TERRAIN_GENERATOR.md` | CANONICAL | Automatic terrain generator; maps to AutomaticTerrainGenerator service |
| `docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md` | CANONICAL | Blueprint cost schema guide; active reference for manufacturing |
| `docs/developer/COST_SCHEMA_CONSUMPTION_GUIDE.md` | REFERENCE | Cost schema consumption; needs verification |
| `docs/developer/CRITICAL_TESTING_FIXES.md` | HISTORICAL | Testing fixes from completed session |
| `docs/developer/DATA_DRIVEN_SYSTEMS.md` | CANONICAL | Data-driven systems patterns; active architecture principle |
| `docs/developer/DEPLOYMENT.md` | CANONICAL | Production deployment guide; active reference |
| `docs/developer/DIGITAL_TWIN_SANDBOX.md` | REFERENCE | Digital twin sandbox; needs verification against DigitalTwinService |
| `docs/developer/ELEVATION_DATA.md` | CANONICAL | Elevation data documentation; maps to GeoTIFF data |
| `docs/developer/EXTERNAL_REFERENCES.md` | REFERENCE | External references; may change |
| `docs/developer/FREECIV_INTEGRATION.md` | CANONICAL | FreeCiv integration; active in terrain generation |
| `docs/developer/GROK_TASK_ALIO_SURFACE_VIEW.md` | HISTORICAL | Grok task from completed session |
| `docs/developer/GROK_TASK_NASA_TERRAIN_HIERARCHY.md` | HISTORICAL | Grok task from completed session |
| `docs/developer/JSON_DATA_GUIDE.md` | CANONICAL | JSON data protocol; active reference for blueprints and operational data |
| `docs/developer/LAYERED_RENDERING.md` | REFERENCE | Layered rendering; needs verification against JS rendering code |
| `docs/developer/LLM_AGENT_TASK_PROTOCOL.md` | REFERENCE | LLM agent task protocol; may be partially outdated |
| `docs/developer/LOCAL_BUBBLE_EXPANSION.md` | CANONICAL | Local Bubble expansion; active world generation concept |
| `docs/developer/MAP_SYSTEM.md` | CANONICAL | Map system documentation; maps to map services |
| `docs/developer/PROTOPLANET_TERRAIN.md` | CANONICAL | Protoplanet terrain design; maps to protoplanet models |
| `docs/developer/STAR_SYSTEM_NAMING_STANDARDS.md` | CANONICAL | Star system naming standards; active reference |
| `docs/developer/SURFACE_VIEW_IMPLEMENTATION_PLAN.md` | REFERENCE | Surface view implementation plan; may be partially implemented |
| `docs/developer/TERRAFORMABLE_PLANETS.md` | CANONICAL | Terraformable planets criteria; active simulation concept |
| `docs/developer/TERRAFORMING_SIMULATION.md` | CANONICAL | Terraforming simulation guide; active reference |
| `docs/developer/TILESET_README.md` | CANONICAL | Tileset documentation; maps to tileset assets and services |
| `docs/developer/UI_IMPLEMENTATION.md` | REFERENCE | UI implementation; may be partially outdated |
| `docs/developer/WORMHOLE_SCOUTING_INTEGRATION.md` | CANONICAL | Wormhole scouting integration; active AI Manager system |
| `docs/developer/ai_testing_framework.md` | CANONICAL | AI testing framework; active reference |
| `docs/developer/architectural_todos.md` | HISTORICAL | Architectural todos from past session |
| `docs/developer/claude_notes.md` | HISTORICAL | Claude development notes from session |
| `docs/developer/deployment_refinement.md` | REFERENCE | Deployment refinement; may be partially outdated |
| `docs/developer/development_notes.md` | HISTORICAL | Development notes from session |
| `docs/developer/freeciv_geographical_patterns.json` | REFERENCE | FreeCiv patterns data; may be partially outdated |
| `docs/developer/orbital_depot_migration.md` | REFERENCE | Orbital depot migration; needs verification against current models |
| `docs/developer/pending_changes.md` | HISTORICAL | Pending changes tracker; likely superseded by CURRENT_STATUS.md |
| `docs/developer/planet_ui_development_plan.md` | REFERENCE | Planet UI development plan; may be partially implemented |
| `docs/developer/rails_terraforming_prototype.md` | HISTORICAL | Rails terraforming prototype; may be superseded by current services |
| `docs/developer/refactoring_guide.md` | REFERENCE | Refactoring guide; may contain outdated examples |
| `docs/developer/setup.md` | CANONICAL | Development environment setup; active reference |
| `docs/developer/sol_data_organization.md` | CANONICAL | Sol data organization; maps to star_systems/sol/ JSON files |
| `docs/developer/spec_stabilization.md` | REFERENCE | Spec stabilization strategy; may be partially outdated |
| `docs/developer/ui_enhancements.md` | REFERENCE | UI enhancement plans; may be partially implemented |

---

## docs/flavor/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/flavor/sci_fi_easter_eggs.md` | HISTORICAL | Easter eggs documentation; non-critical content |

---

## docs/gameplay/ — Player-Facing Documentation

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/gameplay/EASTER_EGGS.md` | HISTORICAL | Easter eggs; non-critical content |
| `docs/gameplay/mechanics.md` | CANONICAL | Core gameplay mechanics; player-facing reference |
| `docs/gameplay/player_experience_boundaries.md` | CANONICAL | Player experience boundaries; active design constraint |
| `docs/gameplay/terraforming.md` | CANONICAL | Terraforming guide for players; active reference |

---

## docs/legacy/

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/legacy/PATHS.PAS` | DEPRECATED | Legacy Pascal code; personal artifact |

---

## docs/mission_profiles/ — Mission Templates

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/mission_profiles/00_complete_profile_library.md` | REFERENCE | Mission profile library; may be partially outdated |
| `docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md` | CANONICAL | Luna base establishment profile; active mission pattern |
| `docs/mission_profiles/orbital_settlement_strategies.md` | REFERENCE | Orbital settlement strategies; needs verification |

---

## docs/planning/ — Planning Documents

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/planning/AI-MANAGER—LUNA-BEHAVIOR-GOALS.md` | REFERENCE | Luna behavior goals; may be partially outdated |
| `docs/planning/GALAXY-GAME-PHASE-ALIGNMENT.md` | REFERENCE | Phase alignment; changes with each phase transition |
| `docs/planning/GALAXY-GAME-PLANNING-GOALS.md` | REFERENCE | Planning goals; forward-looking, may change |
| `docs/planning/MISSION_PHASING_AND_TIMELINE.md` | REFERENCE | Mission phasing; changes with development |

---

## docs/reference/ — Stable Design Intent Documents

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/reference/ARCHITECTURE_ANSWERS_FOR_GROK.md` | REFERENCE | Architecture answers for Grok; may be partially outdated |
| `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md` | CANONICAL | Celestial body data conventions (2026-05-01); active JSON-driven architecture reference |
| `docs/reference/COMPLETED_TASKS_ARCHIVE.md` | HISTORICAL | Completed tasks archive; historical record |
| `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` | REFERENCE | Art bible intent; needs verification against current assets |
| `docs/reference/DESIGN_INTENT_SEALED_VOLUME_ATMOSPHERE.md` | CANONICAL | Sealed volume/atmosphere design intent; active simulation concept |
| `docs/reference/DIAGNOSTIC_SOL_SEEDING.md` | REFERENCE | Diagnostic Sol seeding; needs verification |
| `docs/reference/GAME_DESIGN_INTENT.md` | CANONICAL | Game design intent (4 pillars); core design philosophy document |
| `docs/reference/INVENTORY_AND_STORAGE.md` | CANONICAL | Inventory and storage system; maps to Inventory model |
| `docs/reference/MASTER_IMPLEMENTATION_GUIDE.md` | REFERENCE | Map Studio fixes; implementation-specific, may be partially implemented |
| `docs/reference/README.md` | REFERENCE | Reference docs hub; may need updates |

---

## docs/storyline/ — Narrative & Lore (18 files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/storyline/01_story_arc.md` | REFERENCE | Primary story arc; narrative document, may evolve |
| `docs/storyline/02_crisis_mechanics.md` | CANONICAL | Crisis mechanics design; maps to active simulation systems |
| `docs/storyline/03_consortium_framework.md` | CANONICAL | Consortium framework; maps to ConsortiumMembership model |
| `docs/storyline/04_terra_gen_consortium.md` | REFERENCE | Terra Gen consortium lore; narrative document |
| `docs/storyline/05_physics_topology.md` | REFERENCE | Physics topology lore; narrative document |
| `docs/storyline/06_deployment_hierarchy.md` | REFERENCE | Deployment hierarchy lore; narrative document |
| `docs/storyline/07_procedural_generation.md` | REFERENCE | Procedural generation lore; narrative document |
| `docs/storyline/08_ai_intelligence.md` | REFERENCE | AI intelligence lore; narrative document |
| `docs/storyline/09_economic_systems.md` | CANONICAL | Economic systems lore; maps to active economy models |
| `docs/storyline/10_implementation_phases.md` | HISTORICAL | Implementation phases lore; may be partially outdated |
| `docs/storyline/11_lore_canon.md` | REFERENCE | Lore canon; narrative document |
| `docs/storyline/12_lore_mechanics_summary.md` | REFERENCE | Lore-mechanics summary; narrative document |
| `docs/storyline/PHASE_ALIGNMENT_SUMMARY_2026-06-18.md` | HISTORICAL | Phase alignment from specific date; superseded by current planning docs |
| `docs/storyline/README.md` | REFERENCE | Storyline docs hub |
| `docs/storyline/ai_manager_tuning.md` | REFERENCE | AI Manager tuning lore; narrative document |
| `docs/storyline/multi_wormhole_event.md` | CANONICAL | Multi-wormhole event lore; maps to StoryEvents::MultiWormholeEvent model |
| `docs/storyline/snap_event_and_network_expansion.md` | REFERENCE | Snap event lore; may be partially outdated |
| `docs/storyline/system_maturity_conditions.md` | REFERENCE | System maturity conditions; needs verification against current simulation |

---

## docs/testing/ — Testing Documentation

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/testing/CI_CD_PIPELINE.md` | CANONICAL | CI/CD pipeline documentation; active reference |
| `docs/testing/FLAKY_TESTS_ANALYSIS.md` | REFERENCE | Flaky tests analysis; changes with test runs |
| `docs/testing/GRINDER_PROTOCOL.md` | CANONICAL | Grinder protocol (automated testing); active reference |
| `docs/testing/PRACTICAL_TESTING_GUIDE.md` | CANONICAL | Practical testing guide; marked as ⭐ in navigation |
| `docs/testing/TESTING_PHILOSOPHY.md` | CANONICAL | Testing philosophy; stable reference |

---

## docs/wiki/ — Player Wiki (12 files)

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `docs/wiki/AI-Manager-Logic.md` | REFERENCE | AI Manager logic for players; needs verification against current AI Manager |
| `docs/wiki/Atmospheric-Harvesting.md` | CANONICAL | Atmospheric harvesting guide; maps to atmospheric services |
| `docs/wiki/Celestial-Systems.md` | CANONICAL | Celestial systems overview; maps to celestial body models |
| `docs/wiki/Financial-Engine.md` | CANONICAL | Financial engine for players; maps to financial models |
| `docs/wiki/Logistics-and-Hauling.md` | CANONICAL | Logistics and hauling guide; maps to logistics services |
| `docs/wiki/Market-and-AI-Bootstrapping.md` | REFERENCE | Market and AI bootstrapping; needs verification |
| `docs/wiki/Player-Roles-and-Alignment.md` | REFERENCE | Player roles; may need verification against current game mechanics |
| `docs/wiki/Resource-and-Market-Logistics.md` | CANONICAL | Resource and market logistics; maps to economy models |
| `docs/wiki/Scenario-Super-Mars.md` | CANONICAL | Super Mars scenario; maps to SuperMarsSettlementService |
| `docs/wiki/System-Blueprints.md` | REFERENCE | System blueprints; needs verification against current blueprint schema |
| `docs/wiki/System-Commands.md` | REFERENCE | System commands; needs verification against current admin endpoints |
| `docs/wiki/getting_started.md` | CANONICAL | Player getting started guide; active reference |

---

## data/ — Data Assets

| Path | Authority | Rationale |
|------|-----------|-----------|
| `data/galaxy_game_tileset.json` | CANONICAL | Active tileset configuration |
| `data/learned_patterns.json` | REFERENCE | AI learned patterns; changes with AI Manager operation |
| `data/schemas/component_blueprint_v1.1.json` | CANONICAL | Component blueprint schema; active reference |
| `data/json-data/blueprints/*/` | CANONICAL | Active blueprints; referenced by Blueprint model and manufacturing services |
| `data/json-data/resources/*/` | CANONICAL | Active resource definitions |
| `data/json-data/missions/*/` | REFERENCE | Mission profiles; may be partially outdated |
| `data/json-data/missions_v2/*/` | REFERENCE | Mission v2 profiles; supersedes missions/ in some cases |
| `data/json-data/star_systems/sol/` | CANONICAL | Sol system data; active reference |
| `data/json-data/star_systems/*.json` | CANONICAL | Star system data; active reference for 30+ systems |
| `data/json-data/operational_data/*/` | CANONICAL | Operational data; referenced by models at runtime |
| `data/json-data/templates/` | CANONICAL | Base template JSON files (70+); active schema references |
| `data/json-data/tech_tree/` | CANONICAL | Technology tree definitions; active reference |
| `data/tilesets/` | REFERENCE | Tileset assets; may need updates for current rendering |
| `data/geotiff/processed/*.asc.gz` | CANONICAL | NASA GeoTIFF elevation data; ground truth for terrain |
| `data/Civ4_Maps/` | REFERENCE | Civ4 training data; not direct terrain source per GUARDRAILS.md |

---

## galaxy_game/config/ — Rails Configuration

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `galaxy_game/config/application.rb` | CANONICAL | Rails application config; active |
| `galaxy_game/config/database.yml` | CANONICAL | Database configuration; active |
| `galaxy_game/config/economic_parameters.yml` | CANONICAL | Economic parameters; active reference for economy services |
| `galaxy_game/config/names.yml` | CANONICAL | Name generation config; active reference |
| `galaxy_game/config/routes.rb` | CANONICAL | Rails routes; active |
| `galaxy_game/config/schedule.rb` | CANONICAL | Scheduled jobs; active reference |
| `galaxy_game/config/sidekiq.yml` | CANONICAL | Sidekiq configuration; active |
| `galaxy_game/config/sidekiq_scheduler.yml` | CANONICAL | Sidekiq scheduler; active |
| `galaxy_game/config/raw_materials/*.yml` | CANONICAL | Raw materials config; active reference for manufacturing |
| `galaxy_game/config/units/*.yml` | CANONICAL | Unit definitions; active reference |

---

## galaxy_game/db/ — Database Schema

| File Path | Authority | Rationale |
|-----------|-----------|-----------|
| `galaxy_game/db/schema.rb` | CANONICAL | Database schema; authoritative source of truth for data model |
| `galaxy_game/db/seeds.rb` | REFERENCE | Seed data; may need updates |
| `galaxy_game/db/seeds copy.rb` | HISTORICAL | Alternative seeds; superseded by seeds.rb |
| `galaxy_game/db/seeds copy 2.rb` | HISTORICAL | Alternative seeds v2; superseded by seeds.rb |
| `galaxy_game/db/units.rb` | REFERENCE | Units seed data; may need updates |
| `galaxy_game/db/luna_craters.rb` | REFERENCE | Luna craters seed; may need updates |
| `galaxy_game/db/migrate/` | CANONICAL | Database migrations; historical record of schema evolution |

---

## galaxy_game/app/models/ — Data Models

**All model files are classified as CANONICAL** because they represent the actual code that defines the data layer. However, some have caveats:

| File Path | Authority | Caveat |
|-----------|-----------|--------|
| `app/models/units/unit.rb.old` | HISTORICAL | Legacy unit model; superseded by Units::BaseUnit |
| `app/models/units/habitat.rb.new` | CANONICAL | New habitat implementation; verify against current code |
| `app/models/craft/base_craft.rb.new` through `.new3` | HISTORICAL | Multiple iterations of base craft; only latest is active |
| `app/models/celestial_bodies/spheres.rb` | REFERENCE | Module file for spheres namespace; needs verification |
| `app/models/structures.rb` | REFERENCE | Module file for structures namespace; needs verification |
| `app/models/locations.rb` | REFERENCE | Module file for locations namespace; directory may not exist |
| `app/models/scheduled_import.rb.backup` | HISTORICAL | Backup file; superseded by scheduled_import.rb |

---

## galaxy_game/app/services/ — Rails Services

**All service files are classified as CANONICAL** because they represent active code. However:

| Category | Count | Authority Notes |
|----------|-------|----------------|
| AI Manager services | ~80 | All CANONICAL; maps to active AI orchestration |
| StarSim services | ~25 | All CANONICAL; maps to active world generation |
| TerraSim services | ~13 | All CANONICAL; maps to active simulation |
| Manufacturing services | ~17 | All CANONICAL; maps to active production chain |
| Economic/Financial services | ~15 | All CANONICAL; maps to active economy |
| Lookup services | ~14 | All CANONICAL; maps to active lookup patterns |
| Construction services | ~6 | All CANONICAL; maps to active construction |
| Pressurization services | ~6 | All CANONICAL; maps to active pressurization |
| Logistics services | ~14 | All CANONICAL; maps to active logistics |
| Other services | ~20 | All CANONICAL; verify against current usage |

**Note**: `app/services/material_lookup_service.rb.old` is classified as HISTORICAL.

---

## Summary Statistics by Authority Level

| Authority Level | Approximate Count | Percentage |
|----------------|------------------|------------|
| CANONICAL | ~180 | 49% |
| REFERENCE | ~120 | 33% |
| HISTORICAL | ~50 | 14% |
| DEPRECATED | ~2 | <1% |
| UNKNOWN | ~16 | 4% |
| **Total** | **~368** | **100%** |

---

## Documents Requiring Human Review (UNKNOWN Classification)

These documents need a human reviewer to determine their authority level:

1. `docs/agent/AGENT_ROUTING.md` — Agent routing logic
2. `docs/agent/DOCUMENTATION_STRATEGIST.md` — Role definition
3. `docs/agent/SESSION_STRATEGIST.md` — Session workflow
4. `docs/agent/rules/` (directory) — Agent behavior rules
5. `docs/architecture/core/modular_containers.md` — Modular containers design
6. `docs/architecture/services/ai_manager/governance_and_chaos.md` — Governance theory
7. `docs/architecture/services/ai_manager/aol-732356.md` — Design document
8. `docs/architecture/logistics/navigation/INNER_SYSTEM_EXCLUSION.md` — Exclusion rules
9. `docs/architecture/logistics/life_support_waste_recycling_architecture.md` — Waste recycling
10. `docs/architecture/stations/CERES_GATEWAY.md` — Station design
11. `docs/architecture/stations/SPECIALIZED_WH_STATIONS.md` — Station design
12. `docs/architecture/stations/SYNTHETIC_MEGA_STATIONS.md` — Station design
13. `docs/architecture/ai_manager/89→8_EXECUTION_PLAN.md` — Execution plan
14. `docs/architecture/ai_manager/89→8_SURGICAL_MAP.md` — Surgical map
15. `docs/architecture/ai_manager/astrolift_corporation.md` — Corporation design
16. `docs/architecture/ai_manager/AI_MANAGER_DAMAGE_INVENTORY.md` — Damage inventory

---

## Notes on Classification Methodology

1. **CANONICAL** documents are those that:
   - Map directly to active code (models, services, config files)
   - Are actively referenced by other CANONICAL documents
   - Describe systems currently in use (StarSim, TerraSim, AI Manager, economy)
   - Contain specific technical details (fee percentages, quorum thresholds, grid formulas)

2. **REFERENCE** documents are those that:
   - May be partially outdated but still contain valuable information
   - Describe systems that may have evolved
   - Are status trackers or change-prone documents
   - Map to code that exists but may have diverged from the documentation

3. **HISTORICAL** documents are those that:
   - Come from completed sessions or phases
   - Contain chat logs, handoff notes, or task-specific content
   - Are explicitly from past work (e.g., "Phase 1", "Phase 4")
   - Include backup files (.bak, .backup, .old)

4. **DEPRECATED** documents are those that:
   - Are clearly superseded by newer versions
   - Are in the legacy/ directory
   - Are backup copies of active files

5. **UNKNOWN** documents require human review because:
   - They lack clear indicators of current relevance
   - They describe systems not obviously mapped to code
   - They may be in-progress designs
   - Their relationship to the current codebase is unclear
