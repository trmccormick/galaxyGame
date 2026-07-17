# Wiki 2 Structure Proposal — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Design future GitHub Wiki organization around architecture and gameplay, not file history  
**Rule**: This is a proposal only. No files have been moved, renamed, or deleted.

---

## Design Principles

1. **Organize by conceptual domain** — what the document describes, not who created it
2. **Separate stable reference from ephemeral planning** — architecture docs stay; session notes archive
3. **Player-facing and developer-facing paths are distinct** — wiki has parallel entry points
4. **Cross-references use canonical names** — no duplicate pages for the same concept
5. **Historical content preserved but separated** — archive folder for superseded documents

---

## Proposed Wiki Structure

```
Galaxy Game Wiki/
│
├── 00_Project_Overview/
│   ├── game_design_intent.md          ← Core design pillars (scientific accuracy, strategic resources, exploration, long-term planning)
│   ├── four_layer_vision.md           ← Macro/Meso/Micro/Economic layer architecture
│   ├── player_experience_boundaries.md← What players can/cannot do
│   ├── guardrails.md                  ← Operational boundaries for all development
│   └── getting_started.md             ← Player and developer entry points
│
├── 01_Core_Architecture/
│   ├── architecture_overview.md       ← System hierarchy, data flow, ownership boundaries
│   ├── json_driven_architecture.md    ← Blueprint vs operational data, template system
│   ├── data_conventions.md            ← Celestial body data conventions, naming standards
│   ├── namespace_rules.md             ← Model/service namespace conventions
│   └── technology_tree.md             ← 19 categories, TL-to-MK relationship (pending resolution)
│
├── 02_Galaxy_and_Celestial_Systems/
│   ├── star_sim_overview.md           ← Weathering engine, fidelity tiers, dynamic population
│   ├── celestial_body_hierarchy.md    ← Star → Planet/Moon/MinorBody hierarchy
│   ├── star_systems.md                ← Sol data, procedural generation for other systems
│   ├── planetary_types.md             ← Rocky, ocean, gaseous, ice giant, brown dwarf
│   └── minor_bodies.md                ← Asteroids, comets, KBOs, protoplanets
│
├── 03_Terraforming_and_Simulation/
│   ├── terra_sim_overview.md          ← Regression/weathering, sphere simulation
│   ├── sphere_models.md               ← Atmosphere, hydrosphere, geosphere, biosphere, cryosphere
│   ├── biome_system.md                ← 11 canonical biome types, temperature/rainfall ranges
│   ├── terrain_generation.md          ← NASA GeoTIFF ground truth, FreeCiv training data
│   ├── terraforming_guide.md          ← Multi-stage planetary modification
│   └── biosphere_scoring.md           ← Biosphere development stages and scoring
│
├── 04_Settlements_and_Infrastructure/
│   ├── settlement_architecture.md     ← Administrative container concept
│   ├── structure_types.md             ← Worldhouse, crater dome, hangar, manufacturing facility, etc.
│   ├── worldhouse_design.md           ← Lava tube enclosure design intent
│   ├── orbital_infrastructure.md      ← Space stations, depots, L1 facilities
│   └── construction_system.md         ← ConstructionJob, pressurization, dome services
│
├── 05_Units_and_Craft/
│   ├── unit_architecture.md           ← Units::BaseUnit hierarchy, operational data
│   ├── fabricators.md                 ← Mk1-Mk3 3D-printed fabricators
│   ├── craft_types.md                 ← Harvester, rover, ship, spaceship, satellite
│   ├── cycler_system.md              ← Mobile space stations, interplanetary transport
│   └── asteroid_relocation_tug.md     ← Asteroid hollowing and relocation
│
├── 06_Manufacturing_and_ISRU/
│   ├── manufacturing_overview.md      ← Raw → processed → components → blueprints → assembly
│   ├── isru_system.md                 ← In-Situ Resource Utilization, regolith processing
│   ├── blueprint_schema.md            ← Blueprint cost schema v1.1, template system
│   ├── json_data_protocol.md          ← JSON naming conventions, required fields, validation
│   └── component_production.md        ← Component production logic and integration
│
├── 07_Economy_and_Logistics/
│   ├── economy_overview.md            ← Dual-currency model, three-currency architecture
│   ├── currency_and_exchange.md       ← GCC/USD peg phases (bootstrap → uncoupled)
│   ├── contract_system.md             ← Courier, manufacturing, exploration, station expansion
│   ├── market_operations.md           ← NPC pricing, demand service, trade execution
│   ├── logistics_architecture.md      ← Interplanetary trade, manifest generation, routing
│   └── consortium_voting.md           ← 66% quorum, EM-aware ROI voting
│
├── 08_AI_Manager/
│   ├── ai_manager_overview.md         ← Current 80+ service architecture (needs rewrite)
│   ├── core_services.md               ← Orchestrator, state analyzer, strategic evaluator
│   ├── expansion_system.md            ← Scouting, system evaluation, placement
│   ├── wormhole_management.md         ← BFS wayfinding, coordinator, manager, scouting
│   ├── pattern_learning.md            ← Pattern loader, validator, target mapper
│   ├── mission_planning.md            ← LLM planner, mission scorer, profile analyzer
│   ├── governance.md                  ← Consortium voting, Hammer Protocol
│   └── economic_logic.md              ← Economic forecaster, financial service, market stabilization
│
├── 09_Technology_System/
│   ├── tech_tree_categories.md        ← All 19 technology categories
│   ├── technology_levels.md           ← TL 1-4+ framework (pending TL-to-MK resolution)
│   ├── mk_designations.md             ← Mk1/Mk2/Mk3 engineering iterations
│   └── tech_gating.md                 ← How technology gates blueprint availability
│
├── 10_Rendering_and_UI/
│   ├── terrain_rendering.md           ← Generation → rendering → data storage pipeline
│   ├── tileset_system.md              ← Trident, BigTrident, Engels tilesets
│   ├── asset_pipeline.md              ← Spritesheets, atlases, chromakey process
│   ├── ui_implementation.md           ← Game interface, admin panel, planet detail
│   └── layered_rendering.md           ← Macro/Meso/Micro visual layers
│
├── 11_Data_Architecture/
│   ├── star_system_data.md            ← Sol JSON structure, other system formats
│   ├── blueprint_data.md              ← Blueprint JSON format and examples
│   ├── operational_data.md            ← Runtime data format and examples
│   ├── resource_definitions.md        ← Raw materials, processed materials, components
│   └── schema_versions.md             ← Template version history (v1-v7 across types)
│
├── 12_Development_Guides/
│   ├── setup.md                       ← Development environment setup
│   ├── deployment.md                  ← Production deployment
│   ├── testing_philosophy.md          ← Testing approach and conventions
│   ├── practical_testing_guide.md     ← RSpec best practices
│   ├── ci_cd_pipeline.md              ← CI/CD automation
│   ├── grinder_protocol.md            ← Automated testing protocol
│   ├── refactoring_guide.md           ← Refactoring conventions
│   └── environment_boundaries.md      ← Docker/Git operational boundaries
│
└── 13_Historical_Archive/
    ├── agent_docs/                    ← Agent instructions (legacy, being migrated)
    ├── session_artifacts/             ← Chat logs, handoff notes, task files
    ├── legacy_code/                   ← PATHS.PAS and other legacy artifacts
    ├── superseded_architecture/       ← Outdated architecture docs (pre-80-service AI Manager)
    └── phase_plans/                   ← Completed phase plans (Phase 1, Phase 4 test docs)
```

---

## Section Descriptions

### 00_Project_Overview
**Audience**: Everyone (players, developers, contributors)  
**Content**: High-level game vision, design pillars, operational constraints. This is the "front door" to the wiki.  
**Key Documents**: Game design intent establishes the four pillars (scientific accuracy, strategic resources, exploration, long-term planning). Guardrails establish non-negotiable operational boundaries.

### 01_Core_Architecture
**Audience**: Developers, architects  
**Content**: The foundational architecture principles that govern all system design. JSON-driven architecture is the single most important concept here.  
**Key Documents**: Data conventions document (CELESTIAL_BODY_DATA_CONVENTIONS.md) is authoritative for how data flows between JSON and code.

### 02_Galaxy_and_Celestial_Systems
**Audience**: Developers working on world generation, players interested in the game world  
**Content**: How star systems and celestial bodies are generated, classified, and represented. StarSim architecture is the primary reference.  
**Key Documents**: StarSim OVERVIEW.md describes fidelity tiers (static → hybrid → procedural). Celestial body data conventions define JSON structure.

### 03_Terraforming_and_Simulation
**Audience**: Developers working on simulation, players interested in terraforming  
**Content**: How planetary simulation works across all sphere domains. TerraSim architecture and biome system are the primary references.  
**Key Documents**: TerraSim OVERVIEW.md describes regression/weathering (noted as incomplete). Biome definitions document has canonical temperature/rainfall ranges.

### 04_Settlements_and_Infrastructure
**Audience**: Developers working on construction, players interested in building  
**Content**: Settlement architecture (administrative container), structure types (physical assets), and construction systems.  
**Key Documents**: Structures README.md defines the settlement-structure relationship. Worldhouse intent document is authoritative for that specific structure type.

### 05_Units_and_Craft
**Audience**: Developers working on units/craft, players interested in equipment  
**Content**: Unit hierarchy (BaseUnit → Robot/Habitat/Extractor/etc.), craft types, cycler system, and fabrication progression.  
**Key Documents**: BaseUnit architecture intent document is authoritative for unit model design. 3D-printed fabricators doc covers Mk1-Mk3 progression.

### 06_Manufacturing_and_ISRU
**Audience**: Developers working on manufacturing, players interested in production  
**Content**: Full manufacturing chain from raw materials through blueprints to assembled units/craft. ISRU system enables distributed fabrication.  
**Key Documents**: Blueprint cost schema guide is authoritative for blueprint data format. JSON data guide covers naming conventions and validation.

### 07_Economy_and_Logistics
**Audience**: Developers working on economy, players interested in trading  
**Content**: Dual-currency model (GCC/USD), contract system, market operations, logistics, and consortium governance.  
**Key Documents**: Currency and exchange document describes the 4-phase evolution. Contract system document covers all 4 contract types with economic models.

### 08_AI_Manager
**Audience**: Developers working on AI systems, strategists coordinating agent work  
**Content**: The most complex section — AI Manager has grown to 80+ services. This section needs a major rewrite to reflect current architecture.  
**Key Documents**: Current AI Manager architecture document (8 files) is severely outdated and must be rewritten. Wormhole coordination and consortium voting are the best-documented subsystems.

### 09_Technology_System
**Audience**: Developers working on tech progression, players interested in advancement  
**Content**: Technology tree categories, technology levels, MK designations, and gating logic.  
**Key Documents**: Tech tree JSON files (19 categories) are the authoritative data source. TL-to-MK relationship is an OPEN QUESTION that must be resolved before this section can be complete.

### 10_Rendering_and_UI
**Audience**: Developers working on rendering/UI, artists contributing assets  
**Content**: Terrain generation pipeline, tileset system, asset pipeline, and UI implementation.  
**Key Documents**: Terrain generation and rendering document is authoritative for the NASA GeoTIFF → FreeCiv training data hierarchy. Tileset README covers available tilesets.

### 11_Data_Architecture
**Audience**: Developers working with game data, contributors adding blueprints/resources  
**Content**: Data file formats, JSON schemas, version history, and conventions for all data files.  
**Key Documents**: Celestial body data conventions is the most comprehensive data document. Template files (70+) serve as living schema documentation.

### 12_Development_Guides
**Audience**: Developers contributing to the project  
**Content**: Setup, deployment, testing, CI/CD, and development conventions.  
**Key Documents**: Practical testing guide is marked as ⭐ (high priority). Guardrails document establishes operational boundaries.

### 13_Historical_Archive
**Audience**: Anyone needing historical context  
**Content**: Superseded documents, session artifacts, legacy code, and completed phase plans. Separated from active documentation to prevent confusion.  
**Key Documents**: All HISTORICAL and DEPRECATED documents from Phase 1 analysis belong here.

---

## Migration Notes

### What Belongs in Each Section (From Phase 1 Analysis)

| Wiki Section | Source Documents (CANONICAL) |
|-------------|------------------------------|
| 00_Project_Overview | GAME_DESIGN_INTENT.md, GLOSSARY_SYSTEM_MECHANICS.md, player_experience_boundaries.md, GUARDRAILS.md |
| 01_Core_Architecture | CELESTIAL_BODY_DATA_CONVENTIONS.md, JSON_DATA_GUIDE.md, DATA_DRIVEN_SYSTEMS.md, namespace rules from AI Manager docs |
| 02_Galaxy_and_Celestial_Systems | starsim/OVERVIEW.md, starsim/celestial_bodies.md, starsim/star_naming_architecture.md, sol_data_organization.md |
| 03_Terraforming_and_Simulation | terrasim/OVERVIEW.md, biology/biome_model.md, systems/BIOME_TERRAFORMING_DESIGN.md, TERRAFORMING_SIMULATION.md |
| 04_Settlements_and_Infrastructure | structures/README.md, settlement/README.md, intent/worldhouse_intent.md, operations/component_production_logic.md |
| 05_Units_and_Craft | units/base_unit.md, units/3d_printed_fabricators.md, stations/CRAFT_OPERATIONAL_EVOLUTION.md, CYCLER_SYSTEM_ARCHITECTURE.md |
| 06_Manufacturing_and_ISRU | isru/README.md, manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md, BLUEPRINT_COST_SCHEMA_GUIDE.md, JSON_DATA_GUIDE.md |
| 07_Economy_and_Logistics | economy/CURRENCY_AND_EXCHANGE.md, economy/CONTRACTS.md, economy/financial_system.md, logistics/logistics_architecture.md |
| 08_AI_Manager | ai_manager/AI_MANAGER_ARCHITECTURE.md (needs rewrite), wormhole docs, pattern learning docs, consortium voting doc |
| 09_Technology_System | tech_tree/*.json files, DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md (pending TL-MK resolution) |
| 10_Rendering_and_UI | terrain/generation_and_rendering.md, TILESET_README.md, LAYERED_RENDERING.md, UI_IMPLEMENTATION.md |
| 11_Data_Architecture | All data/json-data/ documentation, schema files, sol.json structure docs |
| 12_Development_Guides | setup.md, DEPLOYMENT.md, PRACTICAL_TESTING_GUIDE.md, CI_CD_PIPELINE.md, GUARDRAILS.md |
| 13_Historical_Archive | All HISTORICAL/DEPRECATED documents from Phase 1 analysis |

### Documents That Need Creation Before Migration

| Document | Based On | Notes |
|----------|---------|-------|
| `08_AI_Manager/ai_manager_overview.md` | Current AI Manager architecture doc + code scan | **Must be rewritten** — current doc describes 8 files, actual system has 80+ |
| `09_Technology_System/technology_levels.md` | DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md | **Cannot complete** until TL-to-MK relationship is resolved |
| `03_Terraforming_and_Simulation/biosphere_scoring.md` | Phase 1 notes (biosphere scoring pseudocode) | Created during biosphere development modeling |
| `11_Data_Architecture/schema_versions.md` | Template version history across all blueprint types | Requires scanning all template files for version timeline |

---

## Wiki Navigation Design

### Primary Entry Points

```
┌─────────────────────────────────────────────────────┐
│                    Galaxy Game Wiki                   │
│                                                       │
│  🎮 For Players                                       │
│  ├── Getting Started                                 │
│  ├── Game World (02_Galaxy_and_Celestial_Systems)   │
│  ├── Settlements & Structures (04)                   │
│  ├── Units & Craft (05)                              │
│  ├── Economy & Trading (07)                          │
│  └── Terraforming Guide (03)                         │
│                                                       │
│  💻 For Developers                                    │
│  ├── Architecture Overview (01)                      │
│  ├── Core Architecture (01)                          │
│  ├── Development Guides (12)                         │
│  ├── Data Architecture (11)                          │
│  └── AI Manager (08)                                │
│                                                       │
│  🔬 Deep Dive                                         │
│  ├── StarSim & World Generation (02)                 │
│  ├── TerraSim & Simulation (03)                      │
│  ├── Manufacturing & ISRU (06)                       │
│  ├── Technology System (09)                          │
│  └── Rendering & UI (10)                             │
│                                                       │
│  📜 Historical Archive (13)                           │
└─────────────────────────────────────────────────────┘
```

### Cross-Reference Strategy

- Each document links to its **canonical source** in the wiki structure
- No duplicate pages — if a concept appears in multiple sections, use cross-references
- External links to code files use relative paths from repository root
- Historical documents link to their superseding canonical documents

---

## Implementation Notes

### This Is a Proposal Only

- **No files have been moved, renamed, or deleted.**
- **All existing documentation remains in its current location.**
- **This proposal should be reviewed by a human before any changes are made.**

### Recommended Migration Order

1. Create wiki structure (13 sections)
2. Migrate CANONICAL documents to appropriate sections
3. Create missing documents (ai_manager_overview, technology_levels pending resolution)
4. Move HISTORICAL/DEPRECATED documents to archive
5. Update cross-references throughout
6. Set up wiki navigation sidebar

### Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Broken cross-references during migration | HIGH | Update all internal links in Phase 2 of migration |
| Loss of historical context | MEDIUM | Archive, don't delete, historical documents |
| TL-to-MK blocking technology section | HIGH | Mark as "pending resolution" until design decision is made |
| AI Manager section overwhelming | MEDIUM | Use sub-pages for each subsystem (expansion, wormhole, pattern learning, etc.) |
