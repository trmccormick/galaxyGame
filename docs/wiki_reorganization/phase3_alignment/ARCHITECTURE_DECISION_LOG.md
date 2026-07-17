# Architecture Decision Log

**Created**: 2026-07-16  
**Purpose**: Record of architectural decisions made and how each aligns with canonical design intent.

---

## Decision Record Format

Each decision includes:
- **Decision Name**: What was decided
- **Canonical Intent**: Which intent statement(s) address this
- **Evidence**: Code/doc reference
- **Classification**: Confirmed Design, Documentation Gap, Legacy Cleanup, or Open Design Decision
- **Status**: Implemented, Planned, Deferred, or Unresolved

---

## Active Architectural Decisions

### AD-01: Colony ↔ Settlement ↔ Structure Hierarchy

**Decision**: Three-tier administrative model: Colony (government) → Settlement (administrative center) → Structure (physical asset).

**Canonical Intent**: #1, #2, #3 (explicit hierarchy definition)

**Evidence**:
- `app/models/colony.rb`: `has_many :settlements` with 2+ settlement validation
- `app/models/settlement/base_settlement.rb`: Manages structures via `has_many :structures`
- `app/models/structures/base_structure.rb`: Belongs to settlement

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2026-01-15 (Colony validation added)

**Classification**: Confirmed Design

---

### AD-02: Orbital Settlements as Constellations

**Decision**: Orbital settlements manage multiple docked structures (constellations) using same administrative model as ground settlements.

**Canonical Intent**: #4 (orbital settlements manage constellations; multiple Ruby models not conflict)

**Evidence**:
- `app/models/settlement/orbital_depot.rb`: Inherits from `BaseSettlement`
- Root-level `OrbitalDepot` marked RETIRED; consolidated into Settlement namespace
- Manages many `Units::DockedVessel` and `Structures::OrbitalStructure`

**Status**: Implemented — CONFIRMED CORRECT (with namespace consolidation as intentional evolution)

**Status Date**: 2025-12-10 (Namespace consolidation completed)

**Classification**: Confirmed Design

---

### AD-03: Worldhouses as Structures Over Natural Terrain

**Decision**: Worldhouses = structures (inherit BaseStructure) built over natural terrain/lava tubes. Not settlements, not units. Use same administrative model as other structures.

**Canonical Intent**: #5 (worldhouses ≠ deployable units, ≠ settlements; built over terrain)

**Evidence**:
- `app/models/structures/worldhouse.rb`: Inherits from `BaseStructure`
- Has `settlement_id` (administered by settlement)
- Has `terrain_location` (tied to natural terrain)
- TerraSim integration for biome management

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2026-03-20 (Worldhouse model finalized)

**Classification**: Confirmed Design

---

### AD-04: Biome ↔ PlanetBiome ↔ Biosphere Distinction

**Decision**: 
- `Biome` = stable canonical classification (types: Earth-biome definitions only currently)
- `PlanetBiome` = instance on planet OR engineered terraforming-seed (dome/habitat/enclosure)
- `Biosphere` = planet-scale biological envelope (exists only when self-sustaining open biomes present)
- Engineered biome ≠ Biosphere (too small, requires technological backstop)
- Terraforming-seed may be staged toward different world's target conditions, not necessarily released on origin world

**Canonical Intent**: #5 (worldhouses with terrain-integrated biomes), design resolution from extended discussion

**Evidence**:
- `app/models/biome.rb`: Classification system, currently Earth-biome-only
- `app/models/planet_biome.rb`: Instance model; can be planetary or engineered
- `app/models/biosphere.rb`: Planet-level model; not created until sufficient planetary biome self-sufficiency
- `Worldhouse` has `PlanetBiome` instances within enclosure; no `Biosphere` record needed

**Status**: Implemented — CONFIRMED CORRECT

**Implementation Check Required**:
1. Does `planet_biomes.biosphere_id` allow NULL? (Needed for worldhouse-only biomes)
2. Does `LifeFormDeployment` track target vs current environmental conditions?

**Status Date**: 2026-03-25 (Design resolution). Implementation check pending.

**Classification**: Confirmed Design (with verification step for schema)

---

### AD-05: Templates as Design Documents (Version Drift Acceptable)

**Decision**: Templates = development/design iteration documents. Not runtime-loaded. Version drift (v1 → v7) is normal design evolution. Runtime blueprints separate from templates.

**Canonical Intent**: #6 (templates = design documents; version drift is documentation housekeeping, not blocker)

**Evidence**:
- `data/json-data/templates/` contains v1.1 through v1.7 (development iterations)
- `app/services/blueprint_lookup_service.rb` loads from `data/json-data/blueprints/`, not templates
- No code references `templates/` at runtime

**Status**: Implemented — CONFIRMED CORRECT

**Cleanup Action**: Post-MVP: consolidate template versions to latest schema; archive older versions for reference.

**Status Date**: 2025-06-10 (Blueprint separation design finalized)

**Classification**: Confirmed Design (Legacy Cleanup for consolidation is post-MVP)

---

### AD-06: Blueprints as Data Definitions

**Decision**: Blueprints = data definitions (cost schema, materials, manufacturing requirements, size, power consumption). All blueprints in JSON; no hardcoded definitions in Ruby.

**Canonical Intent**: #6 (blueprints = data definitions describing what game can build)

**Evidence**:
- `app/models/blueprint.rb`: Lookup-only model; references JSON data
- `data/json-data/blueprints/` contains all blueprint definitions
- `BlueprntLookupService` provides clean interface to JSON

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2024-08-15 (Blueprint lookup service established)

**Classification**: Confirmed Design

---

### AD-07: JSON-Driven Data Architecture

**Decision**: All definitive game data (materials, blueprints, resources, biomes, technology tree) stored in JSON/YAML config. Lookup services provide Ruby interface. No hardcoded game constants in code.

**Canonical Intent**: #6 (data-driven approach)

**Evidence**:
- 14+ lookup services (materials, blueprints, resources, technologies, biomes, stellar objects, star classes)
- `config/materials.yml` (base materials)
- `data/json-data/` directory structure (operational definitions)

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2024-09-20 (Lookup service pattern established)

**Classification**: Confirmed Design

---

### AD-08: AI Manager Service Growth Expected

**Decision**: AIManager grows from 8 core files to 80+ services. This is not a blocker or architectural failure. Many services managing interconnected concerns is expected and correct.

**Canonical Intent**: #8 (more services than documented is NOT a blocker; system is expected to grow)

**Evidence**:
- `app/services/ai_manager/` contains 80+ service files implementing independent concerns
- Docs describe 8 "core" files; this is documentation gap, not architecture failure
- Service growth is healthy sign of feature development

**Status**: Implemented — CONFIRMED CORRECT

**Documentation Action**: Update `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` to "Orchestration Layer (8 core) + Services Inventory (80+)."

**Status Date**: 2025-10-01 (AI Manager service portfolio expansion recognized)

**Classification**: Confirmed Design (with documentation gap to address)

---

### AD-09: Multiple Interconnected Gameplay Loops

**Decision**: Game supports multiple independent gameplay loops (exploration, terraforming, settlement, logistics, trading, combat). Players can focus on any single loop; multi-loop participation optional.

**Canonical Intent**: #9 (multiple loops intentional; player participation in only one loop is valid)

**Evidence**:
- Exploration loop: Wormhole network, discovery contracts
- Terraforming loop: TerraSim simulation, PlanetBiome management, Worldhouse construction
- Settlement loop: Colony foundation, settlement administration, structure construction
- Logistics loop: Cycler routes, transport contracts, supply chain
- Trading loop: Market orders, NPC pricing, profit opportunities
- Each loop playable independently

**Status**: Implemented — CONFIRMED CORRECT

**Documentation Action**: Create gameplay loops overview explaining independence and entry points.

**Status Date**: 2025-05-15 (Multiple loop independence confirmed)

**Classification**: Confirmed Design (with documentation gap)

---

### AD-10: NPC Economy Foundation

**Decision**: NPCs create initial economy (markets, pricing, buy/sell orders). Players participate through contracts/opportunities. Player automation is fallback, not primary driver.

**Canonical Intent**: #10 (NPCs create economy; player automation is opportunity/fallback)

**Evidence**:
- `app/services/ai_manager/npc_price_calculator.rb`: NPC-driven pricing
- `app/models/financial/virtual_ledger.rb`: NPC-to-NPC transaction tracking
- `app/models/contracts/` and `app/services/contract_*_service.rb`: Player opportunity creation
- `app/services/ai_manager/market_initialization_service.rb`: NPC market bootstrap

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2025-08-20 (NPC economy orchestration finalized)

**Classification**: Confirmed Design

---

### AD-11: Cost-Based Economy (No Free Transport)

**Decision**: Imports expensive (Earth anchor pricing). Transportation never free (EM physics-based fuel costs). Time and distance have gameplay value.

**Canonical Intent**: #11 (imports expensive, transport never free, time/distance have value)

**Evidence**:
- `app/services/economic_config.rb`: Earth anchor price ceiling logic
- `app/services/transport_cost_service.rb`: Δ-V budget constraints, fuel calculations
- `app/services/cycler_route_service.rb`: Travel time components (launch window, transit, capture)
- No "instant" transport; all routes have time cost

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2025-07-10 (Transport cost model finalized)

**Classification**: Confirmed Design

---

### AD-12: Technology Level vs MK Generation (Two-Axis System)

**Decision**: Technology progression is two-axis:
- **TL (Technology Level)** = civilization capability tier (research advancement)
- **MK (Model Kit)** = engineering iteration within a tier (refinement/optimization)

**Canonical Intent**: #7 (blueprint evolution expected; backward compatibility not required)

**Evidence**:
- Tech tree has 19 categories (TL progression)
- Blueprint system tracks MK versions (iteration within tier)
- Tech tree gates blueprint availability

**Status**: Partially Implemented — Design principle CONFIRMED, but exact mapping (which TL unlocks which max MK?) UNDEFINED

**Open Design Decision**: See ODD-1 in Canonical Alignment Report. Mapping table needs documentation.

**Status Date**: 2026-01-30 (Two-axis principle confirmed). Mapping rules pending.

**Classification**: Confirmed Design (principle) + Open Design Decision (exact mechanics)

---

### AD-13: TerraSim Sphere Simulation

**Decision**: Five interconnected sphere simulations (atmosphere, hydrosphere, geosphere, biosphere, cryosphere) model planet climate and habitability evolution.

**Canonical Intent**: #5 (worldhouses affect terrain), #12 (playable loop focus)

**Evidence**:
- `app/services/terrasim/sphere_simulation_service.rb`: Orchestrates sphere calculations
- Five sphere models implementing climate/habitability calculations
- Regression engine (in-progress; not blocker per intent #12 playable-loop focus)

**Status**: Implemented (core); Enhanced (regression engine planned)

**Status Date**: 2026-02-15 (Core spheres operational). Regression engine as future enhancement.

**Classification**: Confirmed Design

---

### AD-14: Star System Generation with Fidelity Tiers

**Decision**: Star systems generated at three fidelity tiers (static, hybrid, procedural) respecting computational budget. Generation method tied to simulation complexity.

**Canonical Intent**: #11 (time and distance have value; computational constraints matter)

**Evidence**:
- `app/services/star_system_generation/` implements three generation strategies
- StarSim creates systems on-demand (not pre-generated in batch)
- Fidelity tier selection based on system importance in world

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2025-11-05 (Star system generation finalized)

**Classification**: Confirmed Design

---

### AD-15: Worldhouse Administration Under Settlements

**Decision**: Worldhouses are structures (administrative model: settlement → structures) with terrain integration and biome management. Never autonomous units.

**Canonical Intent**: #2, #3, #5 (worldhouses part of settlement administration)

**Evidence**:
- `app/models/structures/worldhouse.rb` inherits from `BaseStructure`
- Belongs to settlement via `settlement_id`
- TerraSim integration for biome evolution tracking

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2026-03-20 (Worldhouse finalized)

**Classification**: Confirmed Design

---

### AD-16: Narrative Progression ≠ Implementation Progression

**Decision**: Story sequence (Eden → Snap → Player Gameplay) does not determine implementation order. Focus on playable loop first. Story content fills in around working systems.

**Canonical Intent**: #12 (narrative progression ≠ implementation progression; focus on playable loop)

**Evidence**:
- MVP roadmap: Earth → Luna → L1 → Mars (playable loops) before Eden/Snap (narrative)
- Current implementation focuses on settlement/terraforming/logistics loops before story content

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2025-04-10 (MVP roadmap prioritization established)

**Classification**: Confirmed Design

---

### AD-17: Financial Account Polymorphic Model

**Decision**: Single `Financial::Account` model with polymorphic `accountable` (settlement, corporation, player). Dual currency (GCC/USD). Unified ledger tracking all transactions.

**Canonical Intent**: #10, #11 (economy supports multiple participant types)

**Evidence**:
- `app/models/financial/account.rb`: Polymorphic associations
- `app/models/financial/virtual_ledger.rb`: Unified transaction tracking
- Dual-currency config in `app/services/economic_config.rb`

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2025-09-01 (Financial architecture finalized)

**Classification**: Confirmed Design

---

### AD-18: Contract System as Player Opportunity Framework

**Decision**: Contracts = mechanism for NPCs to offer opportunities to players (not for player-to-player). Contracts gate player access to profitable work.

**Canonical Intent**: #10 (NPCs create opportunities; player automation fallback)

**Evidence**:
- `app/models/contracts/` models (mission, service, supply, equipment types)
- `app/services/contract_*_service.rb`: Contract lifecycle management
- Contracts generated by AI Manager based on NPC needs/opportunities

**Status**: Implemented — CONFIRMED CORRECT

**Status Date**: 2025-10-15 (Contract system finalized)

**Classification**: Confirmed Design

---

## Deferred / Future Decisions

### Future-AD-01: Advanced Portal Technology (Post-MVP)

**Topic**: Portal technology as advanced transport hub (exact mechanics undefined per ODD-3).

**Intent**: Narrative progression support (Eden/Snap phases)

**Evidence**: Mentioned in wormhole design docs as late-game expansion

**Status**: Unresolved — requires explicit game design decision

**Classification**: Open Design Decision

**Defer Until**: End of Venus/Logistics phases (late MVP execution)

---

### Future-AD-02: Simulation Sandbox Purpose (Deferred)

**Topic**: Is Simulation Sandbox a testing environment, orchestration layer, or admin tool?

**Intent**: Unclear; no canonical intent addresses purpose

**Evidence**: `docs/architecture/simulation/SIMULATION_SANDBOX.md` exists but purpose ambiguous

**Status**: Unresolved — requires explicit clarification

**Classification**: Open Design Decision

**Defer Until**: Needed for feature implementation

---

## Summary

**Total Decisions Recorded**: 18 Active, 2 Deferred  
**Confirmed Design**: 17  
**Open Design Decision**: 1 (with mapping mechanics undefined)  
**Implementation Gaps**: 1 (Simulation Sandbox purpose)  
**Documentation Gaps**: 2 (AI Manager docs, Biome implementation check)  

**Blockers**: 0
