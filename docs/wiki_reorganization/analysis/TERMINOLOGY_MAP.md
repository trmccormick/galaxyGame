# Terminology Map — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Identify naming inconsistencies across documentation and code  
**Rule**: Recommend preferred terminology; do not rename anything

---

## Terminology Inconsistencies

### 1. Structure vs Building

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Structure" | `docs/architecture/structures/README.md`, `app/models/structures/`, `Structures::BaseStructure` | **PREFERRED** — canonical model namespace |
| "Building" | Not found in current docs or code | No usage detected |

**Recommendation**: Use "Structure" consistently. No conflict exists — "building" is not used.

---

### 2. Component vs Module

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Component" | `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md`, `data/json-data/blueprints/components/`, `Manufacturing::ComponentProductionService` | Smaller sub-elements in manufacturing chain |
| "Module" | `app/models/modules/base_module.rb`, `data/json-data/templates/module_blueprint_v1.2.json`, `Modules::BaseModule` | Building blocks for structures and settlements |

**Conflict**: The distinction between "component" and "module" is not clearly documented. Both appear to be building blocks, but at different scales:
- **Component**: Smaller, used in manufacturing chain (raw → processed → component → blueprint → assembly)
- **Module**: Larger, used for structure/settlement construction

**Recommendation**: 
- Keep "Component" for manufacturing sub-elements
- Keep "Module" for structure/settlement building blocks
- Add explicit documentation of the scale difference

---

### 3. Blueprint vs Asset

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Blueprint" | `app/models/blueprint.rb`, `data/json-data/blueprints/`, `data/json-data/templates/*_blueprint*.json` | **PREFERRED** — data definition (JSON) |
| "Asset" | `app/assets/`, sprite files, tileset files | Visual resource (PNG, JSON atlas) |

**Status**: No conflict. The distinction is clear in practice:
- Blueprint = data/schema (JSON)
- Asset = visual resource (image/sprite)

---

### 4. Terrain vs Biome

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Terrain" | `docs/architecture/terrain/`, `app/services/terrain/`, `geosphere.terrain_map` | Elevation data and rendering |
| "Biome" | `app/models/biome.rb`, `app/models/planet_biome.rb`, `docs/architecture/biology/biome_model.md` | Ecological classification |

**Conflict**: The relationship between terrain (elevation) and biome (ecology) is not explicitly documented. Terrain is the physical layer; biome is the ecological overlay. They are generated separately but visually combined in rendering.

**Recommendation**: 
- "Terrain" = elevation/topography data
- "Biome" = ecological classification (vegetation, climate zone)
- Add explicit documentation of their relationship in the rendering pipeline

---

### 5. Technology Level vs Tech Tier vs MK Generation

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Technology Level" | `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` | Settlement-wide capability metric (Tier 1-4+) |
| "Tech Tier" | `docs/new_agent/projects/galaxy_game/handoffs/session_handoff_2026-06-16_CLAUDE_REVIEW_IMAGE_ASSETS_AND_AI_MANAGER_AUDIT.md` | Informal reference to technology level |
| "MK Generation" / "Mk1-Mk3" | `docs/architecture/units/3d_printed_fabricators.md`, `data/json-data/blueprints/units/production/fabricators/` | Per-blueprint engineering iteration |

**Conflict**: This is the most significant terminology inconsistency. Three related but distinct concepts:
- **Technology Level (TL)**: Settlement-wide visual/capability tier (1-4+)
- **Tech Tier**: Informal synonym for Technology Level
- **MK Generation**: Per-blueprint engineering evolution (Mk1 → Mk2 → Mk3)

The Art Bible document explicitly states the relationship between TL and MK is an **open question**.

**Recommendation**: 
- Standardize on "Technology Level" (TL) for settlement-wide capability
- Use "Tech Tier" only as informal shorthand
- Keep "MK Generation" or "MK Designation" for per-blueprint engineering iteration
- **RESOLVE**: The TL-to-MK relationship is a design decision, not a terminology issue

---

### 6. Manufacturing Level vs Mk Version

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Mk1/Mk2/Mk3" | `docs/architecture/units/3d_printed_fabricators.md`, blueprint filenames | Engineering generation designation |
| "Manufacturing Level" | Not explicitly found as a term | Would be the systematic name for what MK represents |

**Recommendation**: Use "MK Designation" consistently. It represents engineering iteration, not a separate "manufacturing level" concept.

---

### 7. Sphere vs Layer

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Sphere" | `app/models/celestial_bodies/spheres/`, `CelestialBody::Spheres::*` | Atmospheric, hydrosphere, geosphere, biosphere, cryosphere |
| "Layer" | `docs/architecture/simulation/terrainforge_layer.md`, `docs/architecture/simulation/visual_layer_stack.md` | Rendering/construction layers |

**Conflict**: "Sphere" and "Layer" are used in different contexts but could be confused:
- **Sphere**: Physical planetary system (atmosphere, hydrosphere, geosphere, biosphere)
- **Layer**: Rendering or construction abstraction (TerrainForge layer, visual layer stack)

**Recommendation**: Keep the distinction. Spheres are physical; layers are abstract/visual.

---

### 8. StarSim vs Starsim

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "StarSim" | `docs/architecture/starsim/OVERVIEW.md`, `app/services/star_sim/` | **PREFERRED** — camelCase branding |
| "starsim" | `docs/architecture/logistics/STARSIM_GENERATION_RULES.md` (in directory path) | Lowercase in file paths (Linux convention) |

**Recommendation**: Use "StarSim" in all documentation. File paths will naturally be lowercase on Linux.

---

### 9. TerraSim vs Terrasim

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "TerraSim" | `docs/architecture/terrasim/OVERVIEW.md`, `app/services/terra_sim/` | **PREFERRED** — camelCase branding |
| "terrasim" | Directory paths, some doc references | Lowercase in file paths |

**Recommendation**: Use "TerraSim" in all documentation. File paths will naturally be lowercase on Linux.

---

### 10. Settlement vs Colony

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Settlement" | `app/models/settlement/`, `docs/architecture/settlement/` | **PREFERRED** — current canonical term |
| "Colony" | `app/models/colony.rb`, `app/models/player_colony.rb`, `app/services/ai_manager/colony_manager.rb` | Legacy or player-specific term |

**Conflict**: Both terms exist. "Settlement" is the current canonical term in the architecture docs. "Colony" appears in:
- `Colony` model (may be legacy)
- `PlayerColony` model (player-owned settlement)
- `AIManager::ColonyManager` service (AI-managed settlement)

**Recommendation**: 
- Use "Settlement" for the general concept
- Use "Colony" only when referring to player-owned settlements (`PlayerColony`)
- Consider renaming `AIManager::ColonyManager` to `AIManager::SettlementManager` (which also exists)

---

### 11. Craft vs Ship vs Vessel

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Craft" | `app/models/craft/`, `docs/architecture/stations/CRAFT_OPERATIONAL_EVOLUTION.md` | **PREFERRED** — canonical namespace |
| "Ship" | `app/models/craft/ship.rb`, `app/models/ship.rb` (root) | Ship exists in both craft namespace and root |
| "Vessel" | Not found as a model term | Appears in player-facing documentation ("player-owned vessels") |

**Conflict**: `Ship` exists in two places:
- `app/models/craft/ship.rb` — within the craft namespace
- `app/models/ship.rb` — at root level (possibly legacy)

**Recommendation**: 
- Use "Craft" as the umbrella term
- Keep `Craft::Ship` for ship-type craft
- Investigate whether `app/models/ship.rb` is legacy

---

### 12. Unit vs Module (in context of physical entities)

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Unit" | `app/models/units/base_unit.rb`, `Units::*` | Deployable, mobile, or portable physical entity |
| "Module" | `app/models/modules/base_module.rb`, `Modules::BaseModule` | Building block for structures/settlements |

**Conflict**: Both are physical entities but at different scales:
- **Unit**: Smaller, deployable (robots, habitats, extractors)
- **Module**: Larger, structural building blocks

**Recommendation**: The distinction is clear in practice. Add explicit documentation of the scale difference.

---

### 13. Blueprint vs Template

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Blueprint" | `data/json-data/blueprints/`, `app/models/blueprint.rb` | Instance-specific definitions for game entities |
| "Template" | `data/json-data/templates/` (70+ files) | Base schema definitions (v1, v1.1, v1.2, etc.) |

**Status**: Clear distinction in practice:
- **Template**: Base schema (e.g., `craft_blueprint_v1.7.json`)
- **Blueprint**: Instance-specific data derived from templates

---

### 14. Terrain Map vs Heightmap vs Elevation Map

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Terrain map" | `geosphere.terrain_map`, `docs/architecture/terrain/generation_and_rendering.md` | **PREFERRED** — canonical term |
| "Heightmap" | `docs/architecture/terrasim/OVERVIEW.md` | Synonymous but less precise |
| "Elevation map" | `docs/developer/ELEVATION_DATA.md` | Describes the data content |

**Recommendation**: Use "Terrain map" for the game object. Use "elevation data" or "heightmap" when describing the raw data within it.

---

### 15. Wormhole vs Gate vs Portal

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Wormhole" | `app/models/wormhole.rb`, `docs/architecture/wormhole/` | **PREFERRED** — canonical term |
| "Gate" | `docs/architecture/stations/CERES_GATEWAY.md` ("Ceres Gateway") | Used for station naming, not the phenomenon |
| "Portal" | `docs/architecture/logistics/navigation/INTRA_SYSTEM_PORTALS.md` | Intra-system travel mechanism |

**Conflict**: Three terms for related but distinct concepts:
- **Wormhole**: Interstellar connection between star systems
- **Gate**: Station naming convention (e.g., "Ceres Gateway")
- **Portal**: Intra-system travel mechanism (inner system exclusion, BFS mapping)

**Recommendation**: Keep all three terms with their distinct meanings. Add a glossary entry clarifying the difference.

---

### 16. ISRU vs In-Situ Manufacturing

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "ISRU" (In-Situ Resource Utilization) | `docs/architecture/isru/README.md`, `app/services/ai_manager/isru_evaluator.rb` | **PREFERRED** — established acronym |
| "In-Situ Manufacturing" | Not explicitly found | Would be a subset of ISRU |

**Recommendation**: Use "ISRU" consistently. It encompasses all in-situ resource activities including manufacturing.

---

### 17. Service vs Manager vs Engine

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Service" | `app/services/` (100+ files) | **PREFERRED** — Rails convention |
| "Manager" | `app/services/ai_manager/manager.rb`, `AIManager::Manager` | Higher-level orchestrator |
| "Engine" | `app/services/ai_manager/task_execution_engine.rb`, `task_execution_engine_v2.rb` | Core execution logic |

**Conflict**: Three patterns for service-like classes:
- **Service**: Single-responsibility operation (e.g., `AtmosphereGeneratorService`)
- **Manager**: Coordinates multiple services (e.g., `AIManager::Manager`)
- **Engine**: Core execution loop (e.g., `TaskExecutionEngine`)

**Recommendation**: The distinction is reasonable but should be documented. Add naming convention guide:
- Use "Service" for single-responsibility operations
- Use "Manager" for coordination/orchestration
- Use "Engine" for core execution loops

---

### 18. Simulation vs Sandbox

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Simulation" | `app/services/star_sim/`, `app/services/terra_sim/` | **PREFERRED** — canonical term |
| "Sandbox" | `docs/architecture/simulation/SIMULATION_SANDBOX.md`, `docs/developer/DIGITAL_TWIN_SANDBOX.md` | Unclear if testing environment or higher-level concept |

**Conflict**: "Sandbox" appears in two contexts:
- Simulation Sandbox (moved from root)
- Digital Twin Sandbox

The purpose of "Sandbox" is unclear. It may be a testing environment, an orchestration layer, or a player-facing concept.

**Recommendation**: Clarify the purpose of "Sandbox" before standardizing. It may need to be renamed or split into distinct concepts.

---

### 19. Mission vs Contract vs Quest

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Mission" | `app/models/mission.rb`, `data/json-data/missions/` | **PREFERRED** — canonical term for AI-driven assignments |
| "Contract" | `app/models/mission_contract.rb`, `app/models/player_contract.rb`, `docs/architecture/economy/CONTRACTS.md` | Player-facing task assignment |
| "Quest" | `data/json-data/missions/quests/` | Appears in mission data but unclear if distinct from missions |

**Conflict**: Three terms for task assignments:
- **Mission**: AI-driven, automated execution
- **Contract**: Player-facing, player-executed
- **Quest**: Appears in mission data directory but unclear if distinct

**Recommendation**: 
- Keep "Mission" for AI-driven assignments
- Keep "Contract" for player-facing assignments
- Investigate whether "Quest" is a distinct concept or legacy naming

---

### 20. Deposit vs Resource vs Material

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Resource deposit" | `app/models/resource_deposit.rb` | Physical concentration of resources on a body |
| "Material" | `app/models/material_request.rb`, `data/json-data/resources/` | Substance type (regolith, iron, water, etc.) |
| "Resource" | `data/json-data/resources/materials/` | Overlaps with "material" — unclear distinction |

**Conflict**: "Resource" and "Material" appear to be used interchangeably in some places:
- `data/json-data/resources/materials/` — directory named "materials" inside "resources"
- `app/models/material_request.rb` vs potential "resource request" concept

**Recommendation**: 
- **Resource deposit**: Physical concentration on a celestial body
- **Material**: Substance type (the "what")
- **Resource**: Use only in context of "resource deposit" or "stored resources"
- Avoid using "resource" and "material" as synonyms

---

### 21. Rig vs Station vs Depot

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Rig" | `app/models/rigs/base_rig.rb`, `docs/architecture/systems/rig_system.md` | Extraction/processing installation |
| "Station" | `app/models/settlement/space_station.rb`, `docs/architecture/stations/` | Orbital infrastructure |
| "Depot" | `app/models/settlement/orbital_depot.rb`, `docs/architecture/intent/l1_depot_shell_intent.md` | Logistics/refueling hub |

**Conflict**: Three types of infrastructure with overlapping functions:
- **Rig**: Surface extraction/processing (mining, ISRU)
- **Station**: Orbital habitation/operations
- **Depot**: Logistics/refueling/storage

**Recommendation**: The distinction is clear in practice. Add explicit documentation of each type's purpose and where they can be built.

---

### 22. Generation vs Fabrication vs Production

| Term Used | Where Found | Notes |
|-----------|-------------|-------|
| "Generation" | `StarSim::ProceduralGenerator`, `NameGeneratorService` | Creating something from nothing (procedural) |
| "Fabrication" | `Units::Fabricator`, 3D-printed fabricators | Manufacturing via additive processes |
| "Production" | `Manufacturing::ProductionService`, `ComponentProductionService` | General manufacturing term |

**Conflict**: Three overlapping manufacturing terms:
- **Generation**: Procedural creation (no physical input)
- **Fabrication**: Additive manufacturing (3D printing, regolith-based)
- **Production**: General term encompassing all manufacturing

**Recommendation**: 
- Use "Production" as the umbrella term for all manufacturing
- Use "Fabrication" specifically for 3D-printed/additive processes
- Use "Generation" only for procedural/non-physical creation

---

## Recommended Terminology Standard

| Concept | Preferred Term | Alternatives to Avoid |
|---------|---------------|----------------------|
| Physical game entity (deployable) | **Unit** | Module, Component (for smaller items) |
| Structure building block | **Module** | Component (for manufacturing sub-elements) |
| Data definition (JSON) | **Blueprint** | Asset, Template (use "template" only for base schemas) |
| Visual resource | **Asset** | Blueprint (never use interchangeably) |
| Planetary system layer | **Sphere** | Layer (use "layer" only for rendering/construction) |
| Interstellar connection | **Wormhole** | Gate, Portal (different concepts) |
| In-situ resource activity | **ISRU** | In-Situ Manufacturing (subset of ISRU) |
| Settlement-wide capability | **Technology Level** | Tech Tier, MK Generation (distinct concept) |
| Per-blueprint engineering iteration | **MK Designation** | Manufacturing Level, Tech Level |
| AI-driven task assignment | **Mission** | Contract, Quest |
| Player-facing task assignment | **Contract** | Mission, Quest |
| Surface extraction installation | **Rig** | Station, Depot |
| Orbital infrastructure | **Station** | Rig, Depot |
| Logistics hub | **Depot** | Station, Rig |
| Physical concentration of resources | **Resource deposit** | Material deposit, Resource site |
| Substance type | **Material** | Resource (use "resource" only in context of deposits or stored amounts) |

---

## Terminology Decisions Needed from Human Review

| # | Decision | Impact | Priority |
|---|----------|--------|----------|
| 1 | Technology Level vs MK relationship | Data model design, visual asset generation | HIGH |
| 2 | Colony vs Settlement naming | Model renaming if needed | MEDIUM |
| 3 | Quest vs Mission distinction | Data model if distinct | LOW |
| 4 | Resource vs Material distinction | Data model if distinct | MEDIUM |
| 5 | Sandbox purpose clarification | Architecture documentation | LOW |
| 6 | Ship dual namespace resolution | Code cleanup | MEDIUM |
