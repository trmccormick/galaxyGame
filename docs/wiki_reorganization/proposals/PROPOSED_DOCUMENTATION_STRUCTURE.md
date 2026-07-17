# Proposed Documentation Structure — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Proposed reorganization of documentation (NOT yet implemented)  
**Rule**: This is a proposal only. No files have been moved, renamed, or deleted.

---

## Recommended Wiki Organization

### Core Principle
Organize by **conceptual domain** (what the document describes), not by **creation context** (which agent/session created it). Separate **stable reference** from **ephemeral planning**.

---

## Proposed Structure

```
docs/
├── README.md                          ← Current hub (keep, update)
│
├── 01_GAME_FOUNDATION/              ← Design intent, vision, core concepts
│   ├── game_design_intent.md          ← docs/reference/GAME_DESIGN_INTENT.md [CANONICAL]
│   ├── four_layer_vision.md           ← GLOSSARY_SYSTEM_MECHANICS.md §Four-Layer Hybrid Vision [CANONICAL]
│   ├── player_experience_boundaries.md← docs/gameplay/player_experience_boundaries.md [CANONICAL]
│   ├── design_intent_art_bible.md     ← docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md [REFERENCE]
│   └── glossary.md                    ← GLOSSARY_SYSTEM_MECHANICS.md + architecture/glossary/system_mechanics.md [CANONICAL]
│
├── 02_SIMULATION/                   ← World generation, planetary simulation, terraforming
│   ├── star_sim_overview.md           ← docs/architecture/starsim/OVERVIEW.md [CANONICAL]
│   ├── star_sim_fidelity_tiers.md     ← docs/architecture/starsim/PROCEDURAL_INTENT.md [CANONICAL]
│   ├── celestial_body_conventions.md  ← docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md [CANONICAL]
│   ├── celestial_body_hierarchy.md    ← docs/architecture/starsim/celestial_bodies.md [CANONICAL]
│   ├── star_naming.md                 ← docs/architecture/starsim/star_naming_architecture.md [CANONICAL]
│   ├── terra_sim_overview.md          ← docs/architecture/terrasim/OVERVIEW.md [CANONICAL]
│   ├── sphere_models.md               ← Consolidate: biology/biology_models.md, biosphere_system.md, geosphere_system.md, hydrosphere_system.md [CANONICAL]
│   ├── biome_system.md                ← docs/architecture/biology/biome_model.md + planet_biome model [CONFIRMED]
│   ├── terrain_generation.md          ← docs/architecture/terrain/generation_and_rendering.md [CANONICAL]
│   ├── terraforming_guide.md          ← docs/gameplay/terraforming.md + developer/TERRAFORMING_SIMULATION.md [CANONICAL]
│   ├── terraformable_planets.md       ← docs/developer/TERRAFORMABLE_PLANETS.md [CANONICAL]
│   └── geo_tiff_data.md              ← docs/developer/ELEVATION_DATA.md [CANONICAL]
│
├── 03_SETTLEMENTS_AND_STRUCTURES/   ← Settlements, structures, units, craft
│   ├── settlement_architecture.md     ← docs/architecture/settlement/README.md + structures/README.md [CANONICAL]
│   ├── structure_types.md             ← Consolidate all structure docs [CANONICAL]
│   ├── worldhouse_design.md           ← docs/architecture/intent/worldhouse_intent.md [CANONICAL]
│   ├── unit_architecture.md           ← docs/architecture/units/base_unit.md + 3d_printed_fabricators.md [CANONICAL]
│   ├── craft_architecture.md          ← docs/architecture/stations/CRAFT_OPERATIONAL_EVOLUTION.md [CANONICAL]
│   ├── cycler_system.md              ← docs/architecture/services/ai_manager/CYCLER_SYSTEM_ARCHITECTURE.md [CANONICAL]
│   └── asteroid_relocation_tug.md     ← docs/architecture/stations/asteroid_relocation_tug_guide.md [CANONICAL]
│
├── 04_ECONOMY/                      ← Economy, finance, market, logistics
│   ├── economy_overview.md            ← docs/architecture/economy/financial_system.md [CANONICAL]
│   ├── currency_and_exchange.md       ← docs/architecture/economy/CURRENCY_AND_EXCHANGE.md [CANONICAL]
│   ├── contract_system.md             ← docs/architecture/economy/CONTRACTS.md [CANONICAL]
│   ├── market_operations.md           ← docs/architecture/economy/MARKET_OPERATIONS.md [CANONICAL]
│   ├── price_discovery.md             ← docs/architecture/economy/PRICE_DISCOVERY_LIFECYCLE.md [CANONICAL]
│   ├── virtual_ledger.md              ← docs/architecture/economy/VIRTUAL_LEDGER_FLOWS.md [CANONICAL]
│   ├── fiscal_policy.md              ← docs/architecture/economy/FISCAL_POLICY_AND_FEES.md [CANONICAL]
│   ├── isru_pricing.md               ← docs/architecture/economy/ISRU_PRICING_MODEL.md [REFERENCE]
│   ├── logistics_architecture.md     ← docs/architecture/logistics/logistics_architecture.md [CANONICAL]
│   └── dual_economy_intent.md        ← docs/architecture/intent/DUAL_ECONOMY_INTENT.md [CANONICAL]
│
├── 05_MANUFACTURING/                ← Manufacturing, ISRU, blueprints
│   ├── manufacturing_overview.md      ← docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md [REFERENCE]
│   ├── isru_system.md                ← docs/architecture/isru/README.md + 3d_printing.md [CANONICAL]
│   ├── blueprint_schema.md           ← docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md [CANONICAL]
│   ├── json_data_protocol.md         ← docs/developer/JSON_DATA_GUIDE.md [CANONICAL]
│   ├── component_production.md       ← docs/architecture/operations/component_production_logic.md [CANONICAL]
│   └── technology_tree.md            ← Consolidate tech tree docs + TL/MK relationship [CONFIRMED]
│
├── 06_AI_MANAGER/                   ← AI Manager, wormholes, pattern learning
│   ├── ai_manager_architecture.md     ← docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md [CANONICAL - NEEDS UPDATE]
│   ├── ai_manager_services.md         ← Index of all 80+ services [CONFIRMED]
│   ├── wormhole_system.md            ← docs/architecture/wormhole/00_executive_summary.md + logistics/navigation/WORMHOLE_NETWORK.md [CANONICAL]
│   ├── consortium_voting.md          ← docs/architecture/ai_manager/CONSORTIUM_VOTING_ENGINE.md [CANONICAL]
│   ├── hammer_protocol.md            ← docs/architecture/ai_manager/AI_MANAGER_HAMMER_INTEGRATION.md [CANONICAL]
│   ├── pattern_learning.md           ← docs/architecture/services/ai_manager/AI_PATTERN_LEARNING_SYSTEM.md [CANONICAL]
│   ├── expansion_system.md           ← Consolidate expansion docs [CANONICAL]
│   └── mission_planning.md           ← Consolidate mission planning docs [CANONICAL]
│
├── 07_RENDERING/                    ← Rendering, tilesets, assets, UI
│   ├── terrain_rendering.md          ← docs/architecture/terrain/generation_and_rendering.md [CANONICAL]
│   ├── tileset_system.md             ← docs/developer/TILESET_README.md [CANONICAL]
│   ├── asset_pipeline.md             ← Consolidate asset docs [REFERENCE]
│   ├── ui_implementation.md          ← docs/developer/UI_IMPLEMENTATION.md [REFERENCE]
│   └── layered_rendering.md          ← docs/developer/LAYERED_RENDERING.md [REFERENCE]
│
├── 08_DEVELOPMENT/                  ← Dev setup, deployment, testing
│   ├── setup.md                      ← docs/developer/setup.md [CANONICAL]
│   ├── deployment.md                 ← docs/developer/DEPLOYMENT.md [CANONICAL]
│   ├── testing_philosophy.md         ← docs/testing/TESTING_PHILOSOPHY.md [CANONICAL]
│   ├── practical_testing_guide.md    ← docs/testing/PRACTICAL_TESTING_GUIDE.md [CANONICAL]
│   ├── ci_cd_pipeline.md             ← docs/testing/CI_CD_PIPELINE.md [CANONICAL]
│   ├── grinder_protocol.md           ← docs/testing/GRINDER_PROTOCOL.md [CANONICAL]
│   ├── data_driven_systems.md        ← docs/developer/DATA_DRIVEN_SYSTEMS.md [CANONICAL]
│   └── guardrails.md                 ← docs/GUARDRAILS.md [CANONICAL]
│
├── 09_REFERENCE/                    ← Stable design intent, conventions
│   ├── celestial_body_data_conventions.md  ← Already in 02_SIMULATION (move)
│   ├── master_implementation_guide.md  ← docs/reference/MASTER_IMPLEMENTATION_GUIDE.md [REFERENCE]
│   └── architecture_answers_for_grok.md ← docs/reference/ARCHITECTURE_ANSWERS_FOR_GROK.md [REFERENCE]
│
├── 10_PLAYER_WIKI/                  ← Player-facing documentation
│   ├── getting_started.md            ← docs/wiki/getting_started.md [CANONICAL]
│   ├── celestial_systems.md          ← docs/wiki/Celestial-Systems.md [CANONICAL]
│   ├── financial_engine.md           ← docs/wiki/Financial-Engine.md [CANONICAL]
│   ├── logistics_and_hauling.md      ← docs/wiki/Logistics-and-Hauling.md [CANONICAL]
│   ├── terraforming_guide.md         ← docs/gameplay/terraforming.md [CANONICAL]
│   └── ai_manager_logic.md           ← docs/wiki/AI-Manager-Logic.md [REFERENCE]
│
├── 11_NARRATIVE/                    ← Storyline, lore, flavor
│   ├── story_arc.md                  ← docs/storyline/01_story_arc.md [REFERENCE]
│   ├── crisis_mechanics.md           ← docs/storyline/02_crisis_mechanics.md [CANONICAL]
│   ├── consortium_framework.md       ← docs/storyline/03_consortium_framework.md [CANONICAL]
│   └── lore_canon.md                 ← docs/storyline/11_lore_canon.md [REFERENCE]
│
├── 12_ARCHIVE/                      ← Historical documents, legacy code
│   ├── agent_docs/                   ← docs/agent/archive/ [DEPRECATED]
│   ├── legacy_code/                  ← docs/legacy/PATHS.PAS [DEPRECATED]
│   └── session_artifacts/            ← Chat logs, handoff notes, task files [HISTORICAL]
│
├── 13_PLANNING/                     ← Active planning (change-prone)
│   ├── phase_alignment.md            ← docs/planning/GALAXY-GAME-PHASE-ALIGNMENT.md [REFERENCE]
│   ├── development_roadmap.md        ← Consolidate all roadmap docs [REFERENCE]
│   └── current_status.md             ← CURRENT_STATUS.md [CANONICAL]
│
└── wiki_reorganization/             ← This staging area (temporary)
    ├── README.md
    ├── inventory/
    │   ├── DOCUMENT_INVENTORY.md
    │   └── DOCUMENT_AUTHORITY_MAP.md
    ├── analysis/
    │   ├── CONFLICT_REPORT.md
    │   ├── CORE_CONCEPT_MAP.md
    │   ├── TERMINOLOGY_MAP.md
    │   └── ARCHITECTURE_RECONSTRUCTION.md
    └── proposals/
        └── PROPOSED_DOCUMENTATION_STRUCTURE.md
```

---

## Document Migration Plan

### Documents That Belong in Proposed Structure (CANONICAL)

These documents should be **moved** to the proposed structure when the reorganization is approved:

| Current Location | Proposed Location | Reason |
|-----------------|-------------------|--------|
| `docs/reference/GAME_DESIGN_INTENT.md` | `01_GAME_FOUNDATION/game_design_intent.md` | Core design philosophy |
| `docs/GLOSSARY_SYSTEM_MECHANICS.md` | `01_GAME_FOUNDATION/glossary.md` | Core mechanics reference |
| `docs/gameplay/player_experience_boundaries.md` | `01_GAME_FOUNDATION/player_experience_boundaries.md` | Design constraint |
| `docs/architecture/starsim/OVERVIEW.md` | `02_SIMULATION/star_sim_overview.md` | World generation core |
| `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md` | `02_SIMULATION/celestial_body_conventions.md` | Data conventions |
| `docs/architecture/terrasim/OVERVIEW.md` | `02_SIMULATION/terra_sim_overview.md` | Simulation core |
| `docs/architecture/terrain/generation_and_rendering.md` | `02_SIMULATION/terrain_generation.md` | Terrain architecture |
| `docs/architecture/settlement/README.md` | `03_SETTLEMENTS_AND_STRUCTURES/settlement_architecture.md` | Settlement core |
| `docs/architecture/structures/README.md` | `03_SETTLEMENTS_AND_STRUCTURES/settlement_architecture.md` | Structure core |
| `docs/architecture/units/base_unit.md` | `03_SETTLEMENTS_AND_STRUCTURES/unit_architecture.md` | Unit architecture |
| `docs/architecture/economy/financial_system.md` | `04_ECONOMY/economy_overview.md` | Economy core |
| `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` | `04_ECONOMY/currency_and_exchange.md` | Currency system |
| `docs/architecture/economy/CONTRACTS.md` | `04_ECONOMY/contract_system.md` | Contract system |
| `docs/architecture/logistics/logistics_architecture.md` | `04_ECONOMY/logistics_architecture.md` | Logistics core |
| `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md` | `05_MANUFACTURING/manufacturing_overview.md` | Manufacturing core |
| `docs/architecture/isru/README.md` | `05_MANUFACTURING/isru_system.md` | ISRU system |
| `docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md` | `05_MANUFACTURING/blueprint_schema.md` | Blueprint reference |
| `docs/developer/JSON_DATA_GUIDE.md` | `05_MANUFACTURING/json_data_protocol.md` | JSON protocol |
| `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` | `06_AI_MANAGER/ai_manager_architecture.md` | AI Manager core (needs update) |
| `docs/architecture/wormhole/00_executive_summary.md` | `06_AI_MANAGER/wormhole_system.md` | Wormhole system |
| `docs/architecture/terrain/generation_and_rendering.md` | `07_RENDERING/terrain_rendering.md` | Rendering core |
| `docs/developer/TILESET_README.md` | `07_RENDERING/tileset_system.md` | Tileset reference |
| `docs/developer/setup.md` | `08_DEVELOPMENT/setup.md` | Dev setup |
| `docs/developer/DEPLOYMENT.md` | `08_DEVELOPMENT/deployment.md` | Deployment guide |
| `docs/testing/PRACTICAL_TESTING_GUIDE.md` | `08_DEVELOPMENT/practical_testing_guide.md` | Testing reference |
| `docs/GUARDRAILS.md` | `08_DEVELOPMENT/guardrails.md` | Development constraints |
| `docs/wiki/getting_started.md` | `10_PLAYER_WIKI/getting_started.md` | Player guide |
| `docs/gameplay/terraforming.md` | `10_PLAYER_WIKI/terraforming_guide.md` | Player guide |

### Documents That Should Be Consolidated

These documents should be **merged** into single reference documents:

| Documents to Merge | Proposed Single Document |
|-------------------|-------------------------|
| `docs/architecture/biology/biology_models.md`, `biosphere_system.md`, `geosphere_system.md`, `hydrosphere_system.md` | `02_SIMULATION/sphere_models.md` |
| `docs/architecture/economy/LEDGERS.md`, `VIRTUAL_LEDGER_FLOWS.md`, `FISCAL_POLICY_AND_FEES.md` | `04_ECONOMY/fiscal_policy.md` |
| `docs/architecture/ai_manager/AI_MANAGER_ORCHESTRATOR_SPEC.md`, `AI_MANAGER_ROLE.md`, `AI_MANAGER_INTENT.md` | `06_AI_MANAGER/ai_manager_architecture.md` (update) |
| `docs/architecture/stations/CERES_GATEWAY.md`, `SPECIALIZED_WH_STATIONS.md`, `SYNTHETIC_MEGA_STATIONS.md`, `l1_lagrange_facilities.md` | `03_SETTLEMENTS_AND_STRUCTURES/station_types.md` |
| `docs/architecture/patterns/planetary_patterns/lunar_isru_flow.md`, `lunar_isru_flow_2.md` | `05_MANUFACTURING/isru_system.md` (update) |
| `docs/storyline/01_story_arc.md` through `12_lore_mechanics_summary.md` | `11_NARRATIVE/story_arc.md` + `11_NARRATIVE/lore_canon.md` |

### Documents That Should Be Archived

These documents are **historical** and should be moved to `13_ARCHIVE/`:

| Document | Reason |
|----------|--------|
| `docs/agent/chat-logs/*` | Ephemeral session logs |
| `docs/agent/tasks/*` | Completed task files |
| `docs/agent/archive/*` | Already archived |
| `docs/legacy/PATHS.PAS` | Legacy code |
| `docs/architecture/adrs/PROPOSAL_TO_CLAUDE.md` | Completed proposal |
| `docs/developer/architectural_todos.md` | Session-specific todos |
| `docs/developer/claude_notes.md` | Session notes |
| `docs/developer/development_notes.md` | Session notes |
| `docs/developer/pending_changes.md` | Superseded by CURRENT_STATUS.md |
| `docs/developer/GROK_TASK_ALIO_SURFACE_VIEW.md` | Completed task |
| `docs/developer/GROK_TASK_NASA_TERRAIN_HIERARCHY.md` | Completed task |
| `docs/developer/CRITICAL_TESTING_FIXES.md` | Completed session |
| `docs/storyline/PHASE_ALIGNMENT_SUMMARY_2026-06-18.md` | Superseded by current planning |
| All `.old`, `.new`, `.bak`, `.backup` files in codebase | Code hygiene |

### Documents That Should Remain Where They Are

These documents are **stable enough** to remain in their current locations:

| Document | Current Location | Reason |
|----------|-----------------|--------|
| `docs/README.md` | `docs/README.md` | Documentation hub — update links after reorganization |
| `docs/architecture/glossary/system_mechanics.md` | `docs/architecture/glossary/` | Already in architecture folder, maps to proposed glossary |
| `data/json-data/` (all) | `data/json-data/` | Data files, not documentation |
| `galaxy_game/config/` (all) | `galaxy_game/config/` | Configuration files, not documentation |
| `docs/flavor/sci_fi_easter_eggs.md` | `docs/flavor/` | Non-critical content, low priority |

---

## Documents That Need Creation

The following documents do **not currently exist** and should be created as part of the reorganization:

| Document | Purpose | Based On |
|----------|---------|----------|
| `02_SIMULATION/sphere_models.md` | Consolidated sphere documentation | biology/biology_models.md, biosphere_system.md, geosphere_system.md, hydrosphere_system.md |
| `03_SETTLEMENTS_AND_STRUCTURES/station_types.md` | All station type documentation | stations/ directory |
| `04_ECONOMY/fiscal_policy.md` | Consolidated fiscal/economic policy | economy/LEDGERS.md, VIRTUAL_LEDGER_FLOWS.md, FISCAL_POLICY_AND_FEES.md |
| `05_MANUFACTURING/technology_tree.md` | Technology tree + TL/MK relationship | tech_tree/*.json + DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md |
| `06_AI_MANAGER/ai_manager_services.md` | Index of all 80+ AI Manager services | app/services/ai_manager/ directory scan |
| `07_RENDERING/asset_pipeline.md` | Asset pipeline documentation | app/assets/, generate_sprites.py, chromakey docs |
| `11_NARRative/story_arc.md` | Consolidated story arc | storyline/01_story_arc.md + related files |

---

## Documents Requiring Human Review Before Migration

| Document | Issue | Decision Needed |
|----------|-------|-----------------|
| `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` | Documents 8 core files; actual system has 80+ services | Update before migration or create new overview |
| `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` | Contains open question (TL vs MK) | Resolve design decision before archiving |
| `docs/architecture/biology/biome_model.md` | Dual biome model conflict | Clarify Biome vs PlanetBiome relationship |
| `app/models/orbital_depot.rb` vs `app/models/settlement/orbital_depot.rb` | Dual namespace conflict | Resolve before documenting |
| `docs/architecture/simulation/SIMULATION_SANDBOX.md` | Purpose unclear | Clarify purpose before placing in structure |
| `data/json-data/missions/` vs `data/json-data/missions_v2/` | Parallel mission data directories | Clarify relationship before organizing |

---

## Implementation Notes

### This Is a Proposal Only

- **No files have been moved, renamed, or deleted.**
- **All existing documents remain in their current locations.**
- **This proposal should be reviewed by a human before any changes are made.**

### Recommended Implementation Order

1. **Phase 0**: Resolve conflicts requiring human review (see above)
2. **Phase 1**: Create new directory structure under `docs/`
3. **Phase 2**: Move CANONICAL documents to proposed locations
4. **Phase 3**: Consolidate documents that should be merged
5. **Phase 4**: Archive HISTORICAL/DEPRECATED documents
6. **Phase 5**: Create missing documents
7. **Phase 6**: Update `docs/README.md` with new navigation
8. **Phase 7**: Update all internal cross-references

### Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Broken cross-references during migration | HIGH | Update all internal links in Phase 6 |
| Loss of historical context | MEDIUM | Archive, don't delete, historical documents |
| Incomplete consolidation | MEDIUM | Review each merge decision with human |
| Player wiki disruption | LOW | Player wiki is separate from architecture docs |
| Agent tooling disruption | MEDIUM | Update agent references after migration |
