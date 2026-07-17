# Architecture Gaps and Next Steps — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Identify architecture gaps from Phase 1 reconstruction  
**Rule**: Separate CONFIRMED code evidence from INFERRED gaps. Do not resolve design conflicts without marking them.

---

## A. Systems That Exist But Need Integration

### A1: AI Manager — Many Services, Unclear Orchestration

| Gap | Evidence | Impact |
|-----|----------|--------|
| Architecture doc describes 8 core files; actual system has 80+ services | `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` lists 8 files; `app/services/ai_manager/` has 80+ files | **HIGH** — Developers cannot understand the current system from documentation. New service additions have no architectural reference. |
| Service-to-service dependency graph undocumented | 80+ services in `app/services/ai_manager/` with no integration map | **MEDIUM** — Risk of circular dependencies or missing handoff points |
| Task execution engine v1 vs v2 distinction unclear | Both `task_execution_engine.rb` and `task_execution_engine_v2.rb` exist | **LOW** — May indicate migration in progress; unclear which is active |

**Next Step**: Rewrite AI Manager architecture document to reflect actual 80+ service system. Create service dependency map.

### A2: Manufacturing — Chain Exists But Gameplay Loop Incomplete

| Gap | Evidence | Impact |
|-----|----------|--------|
| Raw materials → processed → components → blueprints → assembly chain documented but not fully verified | `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md` marked as "Draft/Stub" (2026-04-27) | **MEDIUM** — Manufacturing overview is incomplete; contributors cannot trace the full chain |
| Template version drift across blueprint types (v1-v7) | `data/json-data/templates/` contains component_blueprint v1.1-v1.4, craft_blueprint v1.1-v1.7, unit_blueprint v1.1-v1.4 | **MEDIUM** — Schema inconsistency creates maintenance burden and potential lookup errors |
| Mk2→Mk3 fabricator dependency chain enforcement unclear | `docs/architecture/units/3d_printed_fabricators.md` describes progression but code enforcement unclear | **LOW** |

**Next Step**: Complete manufacturing overview document. Consolidate template versions. Verify Mk dependency enforcement in code.

### A3: Economy — Core Exists But Resource Flow Integration Missing

| Gap | Evidence | Impact |
|-----|----------|--------|
| GCC/USD exchange rate phase progression logic unclear in code | `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` describes 4 phases; Financial::ExchangeRateService exists but phase transition logic unclear | **MEDIUM** — Economic simulation may not progress correctly through bootstrap → uncoupled phases |
| Market stabilization service integration with NPC pricing unclear | `app/services/market/demand_service.rb` + `npc_price_calculator.rb` exist but integration flow undocumented | **LOW** |
| Player-first contract priority enforcement in code unclear | `docs/architecture/economy/CONTRACTS.md` describes 24-48h window, 1.5x reward; implementation status unclear | **MEDIUM** — Core gameplay pillar (player agency) may not be enforced |

**Next Step**: Verify exchange rate phase logic in code. Document market stabilization integration. Verify player-first contract enforcement.

### A4: TerraSim — Simulation Exists But Regression Engine Incomplete

| Gap | Evidence | Impact |
|-----|----------|--------|
| No explicit regression/weathering engine for lush-to-barren state transitions | `docs/architecture/terrasim/OVERVIEW.md` explicitly states: "No explicit regression filter or lush-to-barren state-shifting method exists yet" | **HIGH** — Core SimEarth-inspired feature incomplete. Weathering rate and state_distribution exist but full regression is missing |
| Civ4 shoreline flooding mitigation not implemented | `docs/architecture/starsim/OVERVIEW.md` and `terrasim/OVERVIEW.md` both flag this as known issue requiring dedicated Regression Filter | **HIGH** — Causes unrealistic water/land boundaries on all generated terrain |
| Earth biosphere validation before terraforming not documented in code | `docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md` design principle: "Validate Model — Ensure biomes respond correctly to temperature/rainfall changes" | **MEDIUM** — Design principle exists but implementation verification unclear |

**Next Step**: Implement regression/weathering engine. Implement Civ4 shoreline regression filter. Verify Earth biosphere simulation correctness.

### A5: Rendering Pipeline — Generation and Visualization Disconnected

| Gap | Evidence | Impact |
|-----|----------|--------|
| Terrain generation produces elevation data but biome visualization not fully connected | `docs/architecture/terrain/generation_and_rendering.md` describes separation of concerns; biome grid exists in `geosphere.terrain_map['biomes']` but rendering integration unclear | **MEDIUM** — Elevation and biome data exist but visual layer may not correctly combine them |
| Tileset pixel size vs grid size relationship not documented for contributors | Grid formula documented but tile pixel size (30x30, 64x64) vs grid size (180x90) confusion risk | **LOW** — Documentation exists but could be clearer |

**Next Step**: Verify terrain-to-biome rendering integration. Clarify tileset documentation for contributors.

---

## B. Systems Documented But Not Implemented

| System | Documentation | Implementation Status | Gap Details |
|--------|--------------|----------------------|-------------|
| **Regression/Weathering Engine** | `docs/architecture/terrasim/OVERVIEW.md` — "No explicit regression filter exists yet" | ❌ NOT IMPLEMENTED | Core SimEarth feature. Weathering_rate and state_distribution exist as partial mechanisms but full lush-to-barren regression is missing. |
| **Civ4 Shoreline Regression Filter** | `docs/architecture/starsim/OVERVIEW.md` — "A dedicated Regression Filter is required" | ❌ NOT IMPLEMENTED | Critical dependency for all biome and DigitalTwin work. Causes shoreline flooding artifact. |
| **Brown Dwarf Hub Manager** | `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` — listed as one of 8 core files | ⚠️ INFERRED | Referenced in architecture doc but implementation status is INFERRED (not CONFIRMED). May exist as partial implementation. |
| **Cryosphere Simulation Service** | `app/models/celestial_bodies/spheres/cryosphere.rb` — model exists | ❌ NO SERVICE | Model file exists but no corresponding simulation service in `app/services/terra_sim/`. Ice giant and ice moon simulation incomplete. |
| **Full Biome Validation (Earth First)** | `docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md` — "Validate Model" design principle | ⚠️ PARTIAL | Biome definitions exist but Earth simulation validation against real data not confirmed. |
| **Exchange Rate Phase Transition Logic** | `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` — 4 phases documented | ⚠️ PARTIAL | Financial::ExchangeRateService exists but phase transition triggers and logic unclear in code. |
| **Player-First Contract Enforcement** | `docs/architecture/economy/CONTRACTS.md` — 24-48h window, 1.5x reward | ⚠️ PARTIAL | Contract posting system exists but player timeout → NPC fallback flow unclear. |

---

## C. Systems Implemented But Poorly Documented

| System | Current Documentation | Gap |
|--------|----------------------|-----|
| **AI Manager (80+ services)** | Documents 8 core files; actual system has 80+ | **CRITICAL** — Most outdated canonical document in the repository. Architecture doc is fundamentally wrong about system size. |
| **Market Stabilization Service** | `app/services/market/demand_service.rb` exists | No documentation for how demand service interacts with NPC pricing and AI Manager economic forecasting |
| **Transport Cost Service** | `app/services/logistics/transport_cost_service.rb` exists | EM physics integration for transport costs undocumented |
| **Station Cost-Benefit Analyzer** | `app/services/ai_manager/station_cost_benefit_analyzer.rb` exists | Metrics, thresholds, and decision criteria undocumented |
| **System Intelligence Service** | `app/services/ai_manager/system_intelligence_service.rb` exists | Scope and integration with SystemArchitect undocumented |
| **Resource Flow Simulator** | `app/services/ai_manager/resource_flow_simulator.rb` exists | Scale of simulation (per-settlement vs per-system) undocumented |
| **Economic Forecaster Service** | `app/services/ai_manager/economic_forecaster_service.rb` exists | Forecasting horizon and accuracy undocumented |
| **Task Execution Engine v2** | `app/services/ai_manager/task_execution_engine_v2.rb` exists | v1 vs v2 distinction, migration status, and active version undocumented |
| **Precursor Learning Service** | `app/services/ai_manager/precursor_learning_service.rb` exists | Scope, timeline, and learning methodology undocumented |
| **Colony Manager (AI-driven)** | `app/services/ai_manager/colony_manager.rb` + `app/models/colony.rb` exist | Colony vs Settlement relationship unclear; AI decision scope undocumented |

---

## D. Systems That Should Be Frozen Until Later Phases

| System | Reason for Freezing | Phase to Resume |
|--------|---------------------|-----------------|
| **Digital Twin Sandbox** | Admin feature, not core gameplay. Integration with TerraSim unclear. Requires regression engine first. | After Phase 3 (post-core simulation stability) |
| **Precursor Mission System (full)** | Multiple docs with different scopes. Lore/mechanic interesting but scope undefined. Not blocking core gameplay. | Phase 4 (interstellar content) |
| **Multi-Wormhole Event System** | Model exists but event flow and player impact unclear. Narrative feature, not core loop. | Phase 4 (interstellar content) |
| **EM Power Shield Tier System** | Physics mechanic documented but implementation status unclear. Interesting but not required for core gameplay. | Phase 3+ (after wormhole infrastructure stable) |
| **Sub-Brown Dwarf Support** | Model exists but purpose unclear. Niche celestial body type. Low priority. | Phase 4 (exotic world content) |
| **Hycean Planet System** | Water-world subtype documented but implementation status unclear. Exploration content, not core loop. | Phase 3 (outer planet expansion) |
| **Insurance Market System** | Eve Online-inspired feature. Services exist but player-facing market unclear. Interesting but not required. | Phase 4 (advanced economy) |
| **Alien Life Form Simulation** | Model exists but scope unclear. Late-game content, not core loop. | Phase 4+ (advanced simulation) |
| **Sci-Fi Easter Eggs** | Non-critical flavor content. Fun to implement but no gameplay impact. | Any phase (low priority) |

---

## Priority Summary

### Must Fix Before New Development (P0)

1. **Rewrite AI Manager architecture document** — 8 files → 80+ services
2. **Implement regression/weathering engine** — Core SimEarth feature
3. **Implement Civ4 shoreline regression filter** — Critical terrain quality issue
4. **Resolve OrbitalDepot dual namespace** — Architecture clarity blocker
5. **Verify Habitat.rb active version** — Runtime correctness

### Should Fix Before Phase 3 (P1)

6. **Complete manufacturing overview document** — Draft/Stub since 2026-04-27
7. **Consolidate template versions** — v1-v7 drift across blueprint types
8. **Verify exchange rate phase logic** — Economic simulation correctness
9. **Document market stabilization integration** — Economy service clarity
10. **Implement Cryosphere simulation service** — Sphere model completeness

### Should Fix Before Phase 4 (P2)

11. **Clarify Colony vs Settlement relationship** — Entity targeting correctness
12. **Resolve TL-to-MK relationship** — Blueprint gating logic
13. **Document task execution engine v1 vs v2** — AI Manager clarity
14. **Verify player-first contract enforcement** — Core gameplay pillar

### Nice to Have (P3+)

15-23: See "Systems That Should Be Frozen" section above.
