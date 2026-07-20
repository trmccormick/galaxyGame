# Archive Plan — Phase 4

**Created**: 2026-07-16  
**Purpose**: Documents suitable for archive in docs/archive/. These remain valuable historical references but are no longer considered canonical. Do not delete.

---

## Archive Structure

```
docs/archive/
├── README.md                    (archive index)
├── ephemeral/                   (status reports, execution plans, agent handoffs)
├── historical/                  (development history, agent conversations, prototypes)
└── superseded/                  (superseded canonical docs — content merged elsewhere)
```

---

## Category 1: Ephemeral Documents

These documents are status reports, execution plans, or task-specific notes. They have served their purpose and should be archived. Their content is either already merged into canonical pages or is no longer relevant.

### Status Reports (No Lasting Value)

| Document | Current Location | Archive To | Reason |
|----------|-----------------|------------|--------|
| IMPLEMENTATION_STATUS.md | ai_manager/ | ephemeral/ | Implementation status — ephemeral by nature |
| MISSION_COMPLETE.md | ai_manager/ | ephemeral/ | Mission completion log — ephemeral |
| FINAL_VALIDATION.md | ai_manager/ | ephemeral/ | Validation report — ephemeral |
| INTEGRATION_ASSESSMENT_REPORT.md | ai_manager/ | ephemeral/ | Assessment report — ephemeral |
| PHASE_ALIGNMENT_SUMMARY_2026-06-18.md | storyline/ | ephemeral/ | Phase alignment snapshot — ephemeral |
| AI_MANAGER_ECONOMIC_ALIGNMENT_REVIEW.md | developer/ | ephemeral/ | Review report — ephemeral |
| gcc_coupling_status.md | economy/ | ephemeral/ | Status doc — ephemeral |
| pending_changes.md | developer/ | ephemeral/ | Pending changes list — ephemeral |
| architectural_todos.md | developer/ | ephemeral/ | Todo list — ephemeral |
| FLAKY_TESTS_ANALYSIS.md | testing/ | ephemeral/ | Test analysis — ephemeral |
| CRITICAL_TESTING_FIXES.md | developer/ | ephemeral/ | Testing fixes — ephemeral |
| PLANNING_DOCUMENT.md | architecture/planning/ | ephemeral/ | Planning doc — ephemeral |

### Execution Plans (Served Their Purpose)

| Document | Current Location | Archive To | Reason |
|----------|-----------------|------------|--------|
| 89→8_EXECUTION_PLAN.md | ai_manager/ | ephemeral/ | Execution plan — served its purpose |
| 89→8_SURGICAL_MAP.md | ai_manager/ | ephemeral/ | Surgical map — served its purpose |
| SURFACE_VIEW_IMPLEMENTATION_PLAN.md | developer/ | ephemeral/ | Implementation plan — served its purpose |
| COMPLETE_PHASE_STRUCTURE.md | architecture/planning/ | superseded/ | Phase structure — merged into DEVELOPMENT_PHASES |

### Agent Handoffs (Historical Communication)

| Document | Current Location | Archive To | Reason |
|----------|-----------------|------------|--------|
| CLAUDE_5PM_GO.md | ai_manager/ | ephemeral/ | Agent task — historical communication |
| CLAUDE_HANDOFF.md | ai_manager/ | ephemeral/ | Agent handoff — historical communication |
| PLAYER_HANDOFF.md | ai_manager/ | ephemeral/ | Agent handoff — historical communication |
| PROPOSAL_TO_CLAUDE.md | architecture/adrs/ | ephemeral/ | Agent proposal — historical communication |

### Audit Reports (Historical Reference)

| Document | Current Location | Archive To | Reason |
|----------|-----------------|------------|--------|
| AI_MANAGER_BLOAT_AUDIT.md | ai_manager/ | historical/ | Audit report — shows system growth |
| AI_MANAGER_DESIGN_FAILURES.md | ai_manager/ | historical/ | Design failures — valuable learning |

---

## Category 2: Historical Documents

These documents show development evolution, agent interactions, or prototype exploration. They are valuable for understanding how the project evolved but are not active references.

### Agent Conversations and Tasks

| Document | Current Location | Archive To | Reason |
|----------|-----------------|------------|--------|
| GROK_TASK_ALIO_SURFACE_VIEW.md | developer/ | historical/ | Grok task — shows AI agent evolution |
| GROK_TASK_NASA_TERRAIN_HIERARCHY.md | developer/ | historical/ | Grok task — shows AI agent evolution |
| claude_notes.md | developer/ | historical/ | Claude notes — development history |
| LLM_AGENT_TASK_PROTOCOL_IMPLEMENTATION_HISTORY.md | archive/ | historical/ | Protocol history — development evolution |
| SESSION_STRATEGIST.md.bak | archive/ | historical/ | Backup file — development history |

### Prototype References

| Document | Current Location | Archive To | Reason |
|----------|-----------------|------------|--------|
| rails_terraforming_prototype.md | developer/ | historical/ | Prototype — shows how terraforming evolved |
| FREECIV_INTEGRATION.md | developer/ | historical/ | FreeCiv integration — design exploration |
| freeciv_geographical_patterns.json | developer/ | historical/ | JSON data — design exploration artifact |
| PATHS.PAS | legacy/ | historical/ | Pascal source — shows codebase evolution |

### Development History

| Document | Current Location | Archive To | Reason |
|----------|-----------------|------------|--------|
| TECHNICAL_HISTORY.md | starsim/ | historical/ | Technical history — development evolution |
| ARCHITECTURE_ANSWERS_FOR_GROK.md | reference/ | historical/ | Grok answers — AI agent interaction history |
| aol-732356.md | systems/ | historical/ | AOL reference — no lasting value |

### Guardrails Evolution (Historical Versions)

| Document | Current Location | Archive To | Reason |
|----------|-----------------|------------|--------|
| GUARDRAILS.md.old | archive/ | historical/ | Old guardrails version — evolution history |
| GUARDRAILS.md.old2 | archive/ | historical/ | Old guardrails version — evolution history |
| GUARDRAILS.md.old3.md | archive/ | historical/ | Old guardrails version — evolution history |
| GUARDRAILS.md.old4.md | archive/ | historical/ | Old guardrails version — evolution history |

---

## Category 3: Superseded Documents

These documents have been merged into other canonical pages. The source files should be archived with a note pointing to the merged content.

### Merged Into Architecture

| Document | Merged Into | Archive To |
|----------|------------|------------|
| modular_containers.md (core/) | ARCHITECTURE | superseded/ |
| DATA_DRIVEN_SYSTEMS.md (developer/) | ARCHITECTURE | superseded/ |
| overview.md (architecture/) | DEVELOPMENT_OVERVIEW + ARCHITECTURE | superseded/ |

### Merged Into AI Manager

| Document | Merged Into | Archive To |
|----------|------------|------------|
| 01_probe_system.md | AI_MANAGER_OVERVIEW | superseded/ |
| 03_resource_decisions.md | ECONOMY_SUBSYSTEM | superseded/ |
| AI_MANAGER_COMMAND.md | MISSION_VALIDATION | superseded/ |
| AI_MANAGER_DAMAGE_INVENTORY.md | CONSTRUCTION_SUBSYSTEM | superseded/ |
| AI_MANAGER_ECONOMIC_LOGIC_UPDATE.md | ECONOMY_SUBSYSTEM | superseded/ |
| AI_MANAGER_EVENT_FLOW.md | AI_MANAGER_OVERVIEW | superseded/ |
| AI_MANAGER_INTENT.md | AI_MANAGER_OVERVIEW | superseded/ |
| AI_MANAGER_MASTER_PLAN.md | AI_MANAGER_OVERVIEW | superseded/ |
| AI_MANAGER_ORCHESTRATOR_SPEC.md | AI_MANAGER_OVERVIEW | superseded/ |
| AI_MANAGER_ROLE.md | AI_MANAGER_OVERVIEW | superseded/ |
| AI_MANAGER_WAYFINDING.md | DECISION_MAKING | superseded/ |
| CONSORTIUM_VOTING_ENGINE.md | DECISION_MAKING | superseded/ |
| NPC_INITIAL_DEPLOYMENT_SEQUENCE.md (ai_manager/) | EXPANSION_LOGIC | superseded/ |
| RESUPPLY_AND_ESCALATION_ARCHITECTURE.md | CONSTRUCTION_SUBSYSTEM | superseded/ |
| astrolift_corporation.md | CORPORATIONS | superseded/ |
| escalation_data_flow.md | AI_MANAGER_OVERVIEW | superseded/ |
| luna_ai_manager_visualization.md | (archive) | ephemeral/ |
| ai_manager_economic_loop.md (services/) | ECONOMY_SUBSYSTEM | superseded/ |

### Merged Into Economy

| Document | Merged Into | Archive To |
|----------|------------|------------|
| FISCAL_POLICY_AND_FEES.md | ECONOMY_OVERVIEW | superseded/ |
| LEDGERS.md | MARKETS | superseded/ |
| PLAYER_CONTRACT_SYSTEM.md | CONTRACTS | superseded/ |
| VIRTUAL_LEDGER_FLOWS.md | CURRENCY | superseded/ |
| economic_baseline.md | ECONOMY_OVERVIEW | superseded/ |
| financial_system.md | ECONOMY_OVERVIEW | superseded/ |

### Merged Into Simulation

| Document | Merged Into | Archive To |
|----------|------------|------------|
| biology_system.md | BIOSPHERE | superseded/ |
| terrainforge_layer.md | SIMULATION_PIPELINE | superseded/ |
| visual_layer_stack.md | (archive) | ephemeral/ |
| sphere_creation_optimization.md | SIMULATION_PIPELINE | superseded/ |

### Merged Into Manufacturing

| Document | Merged Into | Archive To |
|----------|------------|------------|
| component_production_logic.md | RESOURCE_PROCESSING | superseded/ |
| isru_operations.md (operations/) | ISRU | superseded/ |
| cnt_production.md | ISRU + RESOURCE_PROCESSING | superseded/ |
| 3d_printing.md | CONSTRUCTION + ISRU | superseded/ |

### Merged Into Settlements

| Document | Merged Into | Archive To |
|----------|------------|------------|
| has_units.md | SETTLEMENTS_OVERVIEW | superseded/ |
| work_camp_to_settlement_flow.md | EXPANSION | superseded/ |
| wh-expansion.md | EXPANSION | superseded/ |

### Merged Into Transportation

| Document | Merged Into | Archive To |
|----------|------------|------------|
| asteroid_relocation_tug.md | CARGO | superseded/ |
| asteroid_relocation_tug_guide.md | CARGO | superseded/ |
| foundry_logic_and_lunar_elevator.md | MANUFACTURING | superseded/ |
| l1_lagrange_facilities.md | DEPOTS | superseded/ |
| precursor_mission_bootstrap_architecture.md (stations/) | IMPLEMENTATION_PHASES | superseded/ |
| life_support_waste_recycling_architecture.md | ISRU | superseded/ |

### Merged Into Story

| Document | Merged Into | Archive To |
|----------|------------|------------|
| 03_consortium_framework.md | STORY_OVERVIEW | superseded/ |
| 04_terra_gen_consortium.md | STORY_OVERVIEW | superseded/ |
| 06_deployment_hierarchy.md | SETTLEMENTS_OVERVIEW + IMPLEMENTATION_PHASES | superseded/ |
| 07_procedural_generation.md | STARSIM | superseded/ |
| 08_ai_intelligence.md | AI_MANAGER_OVERVIEW | superseded/ |
| 09_economic_systems.md | ECONOMY_OVERVIEW | superseded/ |
| ai_manager_tuning.md | MISSION_VALIDATION + DECISION_MAKING | superseded/ |

### Merged Into Development

| Document | Merged Into | Archive To |
|----------|------------|------------|
| setup.md | DEVELOPMENT_OVERVIEW | superseded/ |
| refactoring_guide.md | CODING_STANDARDS | superseded/ |
| deployment_refinement.md | DEPLOYMENT | superseded/ |
| spec_stabilization.md | TESTING | superseded/ |
| ai_testing_framework.md | TESTING | superseded/ |
| CI_CD_PIPELINE.md | TESTING | superseded/ |
| LLM_AGENT_TASK_PROTOCOL.md | AI_WORKFLOW | superseded/ |
| GRINDER_PROTOCOL.md | AI_WORKFLOW | superseded/ |
| AI_MANAGER_CODE_REVIEW_PROTOCOL.md | AI_WORKFLOW | superseded/ |

### Merged Into Reference/Glossary

| Document | Merged Into | Archive To |
|----------|------------|------------|
| star_naming_architecture.md | GLOSSARY + NAMING_CONVENTIONS | superseded/ |
| STAR_SYSTEM_NAMING_STANDARDS.md | GLOSSARY + NAMING_CONVENTIONS | superseded/ |
| 12_lore_mechanics_summary.md | GLOSSARY | superseded/ |
| system_mechanics.md (glossary/) | GLOSSARY | superseded/ |

### Merged Into Universe

| Document | Merged Into | Archive To |
|----------|------------|------------|
| solar_system.md | SOL_SYSTEM | superseded/ |
| celestial_bodies.md | CELESTIAL_BODIES + UNIVERSE_OVERVIEW | superseded/ |
| star_naming_architecture.md | STARS + GLOSSARY | superseded/ |
| SYSTEM_CLASSIFICATION_INTENT.md | STARS + CELESTIAL_BODIES | superseded/ |
| DIAGNOSTIC_SOL_SEEDING.md | SOL_SYSTEM | superseded/ |
| sol_data_organization.md | SOL_SYSTEM | superseded/ |
| TERRAFORMABLE_PLANETS.md | CELESTIAL_BODIES + SOL_SYSTEM | superseded/ |
| ALPHA_CENTAURI_GENERATOR.md | EDEN_SYSTEM | superseded/ |
| alpha_centauri_prep.md | EDEN_SYSTEM | superseded/ |
| LOCAL_BUBBLE_EXPANSION.md | LOCAL_BUBBLE | superseded/ |

### Merged Into Gameplay

| Document | Merged Into | Archive To |
|----------|------------|------------|
| mechanics.md | GAMEPLAY_OVERVIEW | superseded/ |
| player_experience_boundaries.md | PLAYER_EXPERIENCE + PLAYER_PROGRESSION | superseded/ |
| system_maturity_conditions.md | PLAYER_PROGRESSION | superseded/ |
| em_power_shield_tiers.md | (Gameplay section) | superseded/ |
| job_system_mechanics_spec.md | CONSTRUCTION + INDUSTRY_GAMEPLAY | superseded/ |

### Merged Into Other Sections

| Document | Merged Into | Archive To |
|----------|------------|------------|
| BIOME_TERRAFORMING_DESIGN.md | BIOME_SYSTEM + TERRAFORMING | superseded/ |
| worldhouse_intent.md | WORLDHOUSES | superseded/ |
| environmental_volume_intent.md | WORLDHOUSES | superseded/ |
| skimmer_craft_intent.md | CRAFT | superseded/ |
| base_rig_intent.md | STATIONS | superseded/ |
| l1_depot_shell_intent.md | DEPOTS | superseded/ |
| DUAL_ECONOMY_INTENT.md | CURRENCY + ECONOMY_OVERVIEW | superseded/ |
| LOGISTICS_PROVIDER_INTENT.md | LOGISTICS_NETWORK | superseded/ |
| WORMHOLE_NETWORK_INTENT.md | NATURAL_WORMHOLES + WORMHOLE_HISTORY | superseded/ |
| precursor_bootstrap_intent.md | STORY_OVERVIEW + IMPLEMENTATION_PHASES + EDEN_SYSTEM | superseded/ |
| operational_data_guardrails.md | CORE_PRINCIPLES + CODING_STANDARDS | superseded/ |
| PLAYER_UI_VISION.md | PLAYER_EXPERIENCE | superseded/ |
| SIMEARTH_ADMIN_VISION.md | (archive) | ephemeral/ |
| CERES_GATEWAY.md | STATIONS | superseded/ |
| CONVERTED_ROCK_STATIONS.md | STATIONS | superseded/ |
| SPECIALIZED_WH_STATIONS.md | STATIONS | superseded/ |
| SYNTHETIC_MEGA_STATIONS.md | STATIONS | superseded/ |
| CRAFT_OPERATIONAL_EVOLUTION.md | CRAFT | superseded/ |
| PORT_CONNECTION_SYSTEM.md | DOCKING | superseded/ |
| rig_system.md | STATIONS | superseded/ |
| survey_and_handshake_protocol.md | NATURAL_WORMHOLES | superseded/ |
| asteroid_conversion_physics.md | (archive) | historical/ |
| monitor_interface_layers.md | (archive) | ephemeral/ |
| recovery_logic.json | (archive) | ephemeral/ |
| ORGANIZATIONS_SYSTEM.md | CORPORATIONS | superseded/ |
| location_system.md | SETTLEMENTS_OVERVIEW | superseded/ |
| hycean_planet_system.md | CELESTIAL_BODIES | superseded/ |
| GEOLOGICAL_FEATURES_ARCHITECTURE.md | GEOSPHERE | superseded/ |
| GEOLOGICAL_FEATURES_DESIGN_INTENT.md | GEOSPHERE | superseded/ |
| STARSIM_GENERATION_RULES.md | STARSIM | superseded/ |
| SYSTEM_INDUSTRIAL_CHAINS.md | MANUFACTURING_PIPELINE | superseded/ |
| l1_depot_processing_intent.md | DEPOTS | superseded/ |
| wormhole_maintenance_job.md | ARTIFICIAL_WORMHOLES | superseded/ |
| INNER_SYSTEM_EXCLUSION.md | CYCLERS | superseded/ |
| INTRA_SYSTEM_PORTALS.md | ARTIFICIAL_WORMHOLES | superseded/ |
| TRACY_BFS_MAPPING.md | (archive) | ephemeral/ |
| WORMHOLE_NETWORK.md (navigation/) | NATURAL_WORMHOLES | superseded/ |
| 00_executive_summary.md | WORMHOLE_HISTORY | superseded/ |
| AI_MANAGER_PRICING_INTENT.md | PRICING | superseded/ |
| ISRU_PRICING_MODEL.md | PRICING + ISRU | superseded/ |
| COST_SCHEMA_CONSUMPTION_GUIDE.md | BLUEPRINTS + BLUEPRINT_STANDARDS | superseded/ |
| BLUEPRINT_COST_SCHEMA_GUIDE.md | BLUEPRINTS + BLUEPRINT_STANDARDS | superseded/ |
| TERRAFORMING_SIMULATION.md | TERRAFORMING | superseded/ |
| terraforming.md (gameplay/) | TERRAFORMING + TERRAFORMING_GAMEPLAY | superseded/ |
| EASTER_EGGS.md | (archive) | ephemeral/ |
| sci_fi_easter_eggs.md | (archive) | ephemeral/ |
| ADMIN_DASHBOARD_REDESIGN.md | (archive) | ephemeral/ |
| ADMIN_MONITORING.md | (archive) | ephemeral/ |
| ADMIN_SYSTEM.md | (archive) | ephemeral/ |
| ui_enhancements.md | (archive) | ephemeral/ |
| orbital_depot_migration.md | ORBITAL_SETTLEMENTS | superseded/ |
| AI_MANAGER_FUTURE_DEVELOPMENT.md | DEVELOPMENT_PHASES | superseded/ |
| GALAXY-GAME-PHASE-ALIGNMENT.md | DEVELOPMENT_PHASES | superseded/ |
| MISSION_PHASING_AND_TIMELINE.md | DEVELOPMENT_PHASES | superseded/ |
| AI-MANAGER—LUNA-BEHAVIOR-GOALS.md | IMPLEMENTATION_PHASES + EXPANSION_LOGIC | superseded/ |
| GALAXY-GAME-PLANNING-GOALS.md | PROJECT_GOALS | superseded/ |
| 05_physics_topology.md | SIMULATION_OVERVIEW | superseded/ |
| MATERIALS.md (api/) | RESOURCES | superseded/ |
| README.md (api/) | DEVELOPMENT_OVERVIEW | superseded/ |
| README.md (storyline/) | START_HERE | superseded/ |
| README.md (developer/) | START_HERE | superseded/ |
| README.md (reference/) | START_HERE | superseded/ |
| README.md (wiki/) | START_HERE | superseded/ |
| getting_started.md (wiki/) | START_HERE | superseded/ |
| Player-Roles-and-Alignment.md (wiki/) | PLAYER_EXPERIENCE | superseded/ |
| Celestial-Systems.md (wiki/) | UNIVERSE_OVERVIEW + CELESTIAL_BODIES | superseded/ |
| Financial-Engine.md (wiki/) | ECONOMY_OVERVIEW | superseded/ |
| Logistics-and-Hauling.md (wiki/) | LOGISTICS_NETWORK | superseded/ |
| Market-and-AI-Bootstrapping.md (wiki/) | NPC_ECONOMY + MARKETS | superseded/ |
| Resource-and-Market-Logistics.md (wiki/) | ECONOMY_OVERVIEW + LOGISTICS_NETWORK | superseded/ |
| Scenario-Super-Mars.md (wiki/) | NARRATIVE_ACTS | superseded/ |
| System-Blueprints.md (wiki/) | BLUEPRINTS | superseded/ |
| System-Commands.md (wiki/) | MISSION_VALIDATION | superseded/ |
| AI-Manager-Logic.md (wiki/) | AI_MANAGER_OVERVIEW | superseded/ |
| Atmospheric-Harvesting.md (wiki/) | ATMOSPHERE | superseded/ |
| PHASE3_CANONICAL_ALIGNMENT_REPORT.md | ARCHITECTURE | superseded/ |
| RESOLVED_CONFLICTS.md | ARCHITECTURE | superseded/ |
| OPEN_DESIGN_DECISIONS.md | ARCHITECTURE | superseded/ |
| TRUE_BLOCKERS_ONLY.md | ARCHITECTURE | superseded/ |
| BACKLOG_PRIORITY_ALIGNMENT.md | BACKLOG | superseded/ |
| DOCUMENTATION_UPDATE_PLAN.md | (archive after completion) | ephemeral/ |
| 01_story_arc.md.bak | (archive) | ephemeral/ |

---

## Archive Summary

| Category | Count | Destination |
|----------|-------|-------------|
| **Ephemeral** (status reports, execution plans, agent handoffs) | ~25 | docs/archive/ephemeral/ |
| **Historical** (development history, prototypes, agent conversations) | ~15 | docs/archive/historical/ |
| **Superseded** (merged into canonical pages) | ~80 | docs/archive/superseded/ |

**Total documents to archive**: ~120

---

## Archive Process

### Step 1: Create Archive Structure
```bash
mkdir -p docs/archive/{ephemeral,historical,superseded}
```

### Step 2: Move Documents
Move each document to its appropriate archive subdirectory.

### Step 3: Add Archive Index
Create `docs/archive/README.md` with:
- Purpose of the archive
- Three subdirectories explained
- Link back to canonical wiki pages where content was merged
- Note that documents are preserved for historical reference only

### Step 4: Update Source Locations
For each superseded document, add a redirect comment at the top:
```markdown
<!-- ARCHIVED: This document has been merged into [Target Wiki Page](../../wiki/path). -->
<!-- Original location: docs/... -->
<!-- Archived: 2026-07-16 (Phase 4) -->
```

### Step 5: Verify No Broken Links
After archiving, verify no canonical pages reference archived documents directly. All references should point to the merged target page instead.

---

## What NOT to Archive

These documents should remain in their current locations:

1. **Canonical wiki sources** — Documents that will become wiki pages (moved to phase4/ structure)
2. **Supporting wiki sources** — Documents that feed into wiki pages (moved to phase4/ structure)
3. **Phase 3 deliverables** — Moved to phase4/ as part of canonical wiki construction
4. **docs/GUARDRAILS.md** — Active developer constraints
5. **docs/PRACTICAL_TESTING_GUIDE.md** — Active testing reference
6. **docs/GLOSSARY_SYSTEM_MECHANICS.md** — Active terminology reference
7. **docs/MIGRATION_GUIDE.md** — May be needed for future migrations

---

## Post-Archive State

After archiving, the docs tree will have:

- **docs/** — Active wiki structure (14 sections)
- **docs/archive/** — Historical reference material
- **docs/wiki_reorganization/phase4/** — This blueprint (can be archived after implementation)

The active docs tree will be clean, organized by game concept, and free of ephemeral status reports and agent task files.
