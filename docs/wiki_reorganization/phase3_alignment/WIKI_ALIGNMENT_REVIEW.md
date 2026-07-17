# Phase 3 Wiki Organization Review

**Created**: 2026-07-16  
**Purpose**: Evaluate the proposed wiki structure (from WIKI_2_STRUCTURE_PROPOSAL.md) against the needs of new contributors, AI agents, documentation maintenance, implementation phases, and gameplay understanding.  
**Method**: Each wiki section is evaluated for necessity, clarity, and potential improvements.

---

## Proposed Structure Evaluation

### 00_Project_Overview/ ✅ STRONG
- **game_design_intent.md** — Essential entry point for all contributors
- **four_layer_vision.md** — Helps understand the macro architecture
- **player_experience_boundaries.md** — Critical for scope management
- **guardrails.md** — Operational boundaries needed by all developers
- **getting_started.md** — New contributor onboarding

**Verdict**: Keep as-is. This is the canonical entry point.

---

### 01_Core_Architecture/ ✅ STRONG
- **architecture_overview.md** — System hierarchy and data flow
- **json_driven_architecture.md** — Core architectural pattern (blueprints vs operational data)
- **data_conventions.md** — Naming standards, celestial body conventions
- **namespace_rules.md** — Model/service namespace conventions
- **technology_tree.md** — 19 categories + TL-to-MK relationship

**Verdict**: Keep as-is. The JSON-driven architecture section is critical given the project's design philosophy.

**Suggestion**: Add `architecture_overview.md` should include the Colony → Settlement → Structure hierarchy diagram (from Clarification Report item #11).

---

### 02_Galaxy_and_Celestial_Systems/ ✅ STRONG
- **star_sim_overview.md** — Weathering engine, fidelity tiers
- **celestial_body_hierarchy.md** — Star → Planet/Moon/MinorBody hierarchy
- **star_systems.md** — Sol data, procedural generation
- **planetary_types.md** — Rocky, ocean, gaseous, ice giant, brown dwarf
- **minor_bodies.md** — Asteroids, comets, KBOs

**Verdict**: Keep as-is. Well-organized by domain.

---

### 03_Terraforming_and_Simulation/ ✅ STRONG
- **terra_sim_overview.md** — Regression/weathering, sphere simulation
- **sphere_models.md** — Atmosphere, hydrosphere, geosphere, biosphere, cryosphere
- **biome_system.md** — 11 canonical biome types
- **terrain_generation.md** — NASA GeoTIFF, FreeCiv training data
- **terraforming_guide.md** — Multi-stage planetary modification
- **biosphere_scoring.md** — Development stages and scoring

**Verdict**: Keep as-is. Comprehensive coverage of the SimEarth-inspired simulation layer.

---

### 04_Settlements_and_Infrastructure/ ⚠️ NEEDS CLARIFICATION
- **settlement_architecture.md** — Administrative container concept
- **structure_types.md** — Worldhouse, crater dome, hangar, etc.
- **worldhouse_design.md** — Lava tube enclosure design intent
- **orbital_infrastructure.md** — Space stations, depots, L1 facilities
- **construction_system.md** — ConstructionJob, pressurization, dome services

**Verdict**: Good structure but needs explicit Colony → Settlement → Structure hierarchy documentation. Per canonical intent #1-3:
- Colony = governance entity (2+ settlements)
- Settlement = administrative population center
- Structure = physical asset owned by settlement

**Suggestion**: Add `governance_hierarchy.md` to this section showing Colony → Settlement → Structure relationships with code references.

---

### 05_Units_and_Craft/ ✅ STRONG
- **unit_architecture.md** — Units::BaseUnit hierarchy
- **fabricators.md** — Mk1-Mk3 3D-printed fabricators
- **craft_types.md** — Harvester, rover, ship, spaceship, satellite
- **cycler_system.md** — Mobile space stations
- **asteroid_relocation_tug.md** — Asteroid hollowing

**Verdict**: Keep as-is. Well-organized by entity type.

---

### 06_Manufacturing_and_ISRU/ ✅ STRONG
- **manufacturing_overview.md** — Raw → processed → components → blueprints → assembly
- **isru_system.md** — In-Situ Resource Utilization
- **blueprint_schema.md** — Blueprint cost schema v1.1, template system
- **json_data_protocol.md** — JSON naming conventions, required fields
- **component_production.md** — Component production logic

**Verdict**: Keep as-is. The blueprint schema section should note that multiple schema versions exist (per canonical intent #6).

---

### 07_Economy_and_Logistics/ ✅ STRONG
- **economy_overview.md** — Dual-currency model, three-currency architecture
- **currency_and_exchange.md** — GCC/USD peg phases
- **contract_system.md** — Courier, manufacturing, exploration, station expansion
- **market_operations.md** — NPC pricing, demand service, trade execution
- **logistics_architecture.md** — Interplanetary trade, manifest generation, routing
- **consortium_voting.md** — 66% quorum, EM-aware ROI voting

**Verdict**: Keep as-is. Comprehensive coverage of the economy layer.

---

### Remaining Sections (08-13)

The wiki structure proposal continues with sections 08-13 covering:
- 08_AI_and_Automation/ — AI Manager services, task execution, pattern learning
- 09_Starsim_and_World_Generation/ — Star generation, fidelity tiers
- 10_Rendering_and_Visuals/ — Tilesets, sprites, terrain rendering
- 11_Developer_Guide/ — Setup, testing conventions, agent workflows
- 12_Reference/ — Glossary, API docs, data schemas
- archive/ — Superseded documents

**Verdict**: All sections are necessary and well-organized.

---

## Overall Assessment

### Strengths
1. **Conceptual organization** — Organized by domain, not file history or author
2. **Parallel entry points** — Player-facing (00-05) and developer-facing (06-12) paths are distinct
3. **Comprehensive coverage** — All major systems have dedicated sections
4. **Archive separation** — Historical content preserved but separated

### Weaknesses
1. **Missing governance hierarchy** — Colony → Settlement → Structure needs explicit documentation (canonical intents #1-3)
2. **No cross-reference index** — New contributors need a "where to start" guide for their role (player vs developer vs AI agent)
3. **Section 08 naming** — "AI and Automation" is vague; consider "AI_Manager_and_Automation/" for consistency with code namespace

### Recommendations

1. **Add governance hierarchy doc** to section 04
2. **Add a `START_HERE.md`** in the wiki root with role-based entry points:
   - New player → 00_Project_Overview
   - New developer → 01_Core_Architecture + 11_Developer_Guide
   - AI agent → 01_Core_Architecture + 06_Manufacturing_and_ISRU
   - TerraSim contributor → 03_Terraforming_and_Simulation
3. **Rename section 08** to `08_AI_Manager/` for namespace consistency
4. **Add canonical intent statements** as a reference doc in section 12_Reference

---

## Final Wiki Structure (Recommended)

```
Galaxy Game Wiki/
│
├── START_HERE.md                    ← NEW: Role-based entry points
│
├── 00_Project_Overview/
│   ├── game_design_intent.md
│   ├── four_layer_vision.md
│   ├── player_experience_boundaries.md
│   ├── guardrails.md
│   └── getting_started.md
│
├── 01_Core_Architecture/
│   ├── architecture_overview.md     ← ADD: governance hierarchy diagram
│   ├── json_driven_architecture.md
│   ├── data_conventions.md
│   ├── namespace_rules.md
│   └── technology_tree.md
│
├── 02_Galaxy_and_Celestial_Systems/
│   ├── star_sim_overview.md
│   ├── celestial_body_hierarchy.md
│   ├── star_systems.md
│   ├── planetary_types.md
│   └── minor_bodies.md
│
├── 03_Terraforming_and_Simulation/
│   ├── terra_sim_overview.md
│   ├── sphere_models.md
│   ├── biome_system.md
│   ├── terrain_generation.md
│   ├── terraforming_guide.md
│   └── biosphere_scoring.md
│
├── 04_Settlements_and_Infrastructure/
│   ├── settlement_architecture.md
│   ├── governance_hierarchy.md      ← NEW: Colony → Settlement → Structure
│   ├── structure_types.md
│   ├── worldhouse_design.md
│   ├── orbital_infrastructure.md
│   └── construction_system.md
│
├── 05_Units_and_Craft/
│   ├── unit_architecture.md
│   ├── fabricators.md
│   ├── craft_types.md
│   ├── cycler_system.md
│   └── asteroid_relocation_tug.md
│
├── 06_Manufacturing_and_ISRU/
│   ├── manufacturing_overview.md
│   ├── isru_system.md
│   ├── blueprint_schema.md
│   ├── json_data_protocol.md
│   └── component_production.md
│
├── 07_Economy_and_Logistics/
│   ├── economy_overview.md
│   ├── currency_and_exchange.md
│   ├── contract_system.md
│   ├── market_operations.md
│   ├── logistics_architecture.md
│   └── consortium_voting.md
│
├── 08_AI_Manager/                   ← RENAMED from "AI_and_Automation"
│   ├── ai_manager_overview.md       ← Lists 80+ services + 8 core orchestration files
│   ├── orchestration_layer.md       ← 8 core files
│   ├── services_inventory.md        ← All 80+ services with roles
│   └── service_dependency_map.md    ← NEW: Mermaid diagram
│
├── 09_Starsim_and_World_Generation/
│   ├── star_generation.md
│   ├── fidelity_tiers.md
│   └── procedural_systems.md
│
├── 10_Rendering_and_Visuals/
│   ├── tileset_reference.md
│   ├── sprite_generation.md
│   └── terrain_rendering.md
│
├── 11_Developer_Guide/
│   ├── setup.md
│   ├── testing_conventions.md
│   ├── agent_workflows.md
│   └── contribution_guide.md        ← NEW
│
├── 12_Reference/
│   ├── glossary.md
│   ├── api_docs.md
│   ├── data_schemas.md
│   └── canonical_intent_statements.md  ← NEW: The 12 canonical statements
│
└── archive/
    └── [superseded documents]
```

**Changes from original proposal**: 4 additions (START_HERE, governance_hierarchy, canonical_intent_statements, contribution_guide), 1 rename (AI_and_Automation → AI_Manager)
