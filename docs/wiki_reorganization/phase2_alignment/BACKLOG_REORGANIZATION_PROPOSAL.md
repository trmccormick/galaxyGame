# Backlog Reorganization Proposal — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Reclassify existing TODO items, issues, notes, and planning documents by priority category  
**Rule**: Do not simply sort by date. Analyze each item's relationship to current code architecture.

---

## Methodology

Each backlog item was evaluated against:
1. **Current code existence** — Does the system exist in code?
2. **Documentation authority** — Is it CANONICAL, REFERENCE, or HISTORICAL?
3. **Dependency analysis** — What must exist before this can work?
4. **Gameplay relevance** — Does it directly enable gameplay loops?
5. **Architecture alignment** — Does it conflict with current architecture?

---

## FOUNDATION BLOCKERS

Required before other systems can function. These are not "TODO" items — they are prerequisites for all development.

| Task | Current Location | Related Systems | Dependency | Recommended Priority | Reason |
|------|-----------------|-----------------|------------|---------------------|--------|
| Resolve template version drift (v1-v7 across blueprint types) | data/json-data/templates/ | Blueprint system, Manufacturing | None | **P0** | Template inconsistency breaks lookup service reliability. All blueprints must converge on a single canonical schema version. |
| Verify Habitat.rb active version (.new variant) | app/models/units/habitat.rb.new | Phase 1 habitation | Foundation models | **P0** | Unclear which habitat implementation is active. Could cause runtime errors if legacy code is loaded. |
| Resolve OrbitalDepot dual namespace | app/models/orbital_depot.rb + app/models/settlement/orbital_depot.rb | Phase 2, Phase 3 | Foundation models | **P0** | Two models with same name in different namespaces creates ambiguity for all downstream systems. |
| Clarify Colony vs Settlement relationship | app/models/colony.rb + app/models/settlement/base_settlement.rb | Phase 1, Phase 4 | Foundation models | **P0** | Both represent settlement concepts. Without clear distinction, AI Manager and economy services cannot correctly target entities. |
| Resolve TL-to-MK relationship | docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md | Tech tree, Manufacturing | Foundation (tech tree) | **P0** | Explicitly documented as "open question." Blueprint gating logic depends on this decision. |
| Verify Job system code matches authoritative spec | docs/architecture/systems/job_system_mechanics_spec.md | Phase 1 jobs | Foundation models | **P0** | Spec is marked "source of truth." If code contradicts, code is wrong per the spec itself. |
| Implement Cryosphere simulation service | app/models/celestial_bodies/spheres/cryosphere.rb (model exists) | Phase 0, Phase 3 | Sphere model | **P1** | Model exists but no simulation service. Ice giant and ice moon simulation incomplete without it. |

---

## CORE GAMEPLAY

Directly enables gameplay loops. These are the systems players interact with most.

| Task | Current Location | Related Systems | Dependency | Recommended Priority | Reason |
|------|-----------------|-----------------|------------|---------------------|--------|
| Complete terraforming simulation pipeline | docs/architecture/terrasim/OVERVIEW.md, app/services/terra_sim/ | TerraSim, Biome system | Foundation (spheres) | **P1** | Core gameplay pillar. Simulation exists but regression/weathering engine incomplete per architecture doc. |
| Implement Civ4 shoreline regression filter | docs/architecture/starsim/OVERVIEW.md | StarSim, Rendering | World generation | **P1** | Known issue: "Civ4 Shoreline Flooding" causes unrealistic water/land boundaries. Critical for terrain quality. |
| Complete player contract system (all 4 types) | docs/architecture/economy/CONTRACTS.md | Economy, AI Manager | Foundation (economy) | **P1** | Courier, manufacturing, exploration, station expansion contracts documented but implementation status unclear. |
| Verify market stabilization integration | app/services/market/demand_service.rb + npc_price_calculator.rb | Economy, Phase 2 | Foundation (economy) | **P1** | NPC price calculation exists but integration with market conditions and AI Manager unclear. |
| Complete biome system validation (Earth first) | docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md | TerraSim, Biome model | Foundation (spheres) | **P1** | Design principle: "Validate Earth simulation before terraforming barren worlds." Implementation status unclear. |
| Implement player-first contract priority enforcement | docs/architecture/economy/CONTRACTS.md | Economy, AI Manager | Foundation (economy) | **P1** | 24-48 hour player window, 1.5x reward multiplier documented but enforcement in code unclear. |
| Complete construction job progress tracking | app/models/construction_job.rb + Job System Mechanics Spec | Phase 1 construction | Foundation models | **P1** | Surface construction requires pause/resume capability. Implementation status vs spec unclear. |
| Implement biosphere scoring system | docs/wiki_reorganization/inventory/ (Phase 1 notes reference) | TerraSim, Biosphere | Sphere simulation | **P2** | Scoring pseudocode designed in Phase 1 but implementation status unclear. |

---

## INFRASTRUCTURE

Improves architecture but not directly player-visible. Important for maintainability and correctness.

| Task | Current Location | Related Systems | Dependency | Recommended Priority | Reason |
|------|-----------------|-----------------|------------|---------------------|--------|
| Update AI Manager architecture documentation (8 → 80+ services) | docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md | Phase 4, all AI systems | None | **P1** | Documentation describes 8 files; actual system has 80+. This is the single most outdated canonical document. |
| Clean up legacy model files (.old, .new, .bak, .backup) | app/models/ (multiple locations) | All models | None | **P1** | Code hygiene issue creating confusion about which files are authoritative. |
| Consolidate blueprint schema versions | data/json-data/templates/ | Manufacturing, Blueprint system | Foundation | **P2** | 70+ template files with version drift (v1-v7). Needs consolidation to reduce maintenance burden. |
| Resolve cycler model location mismatch | app/models/cycler.rb vs docs/architecture/services/ai_manager/CYCLER_SYSTEM_ARCHITECTURE.md | Phase 2, AI Manager | Foundation models | **P2** | Model in root namespace but documented as AI Manager subsystem. Namespace convention needs enforcement. |
| Implement exchange rate phase progression logic | docs/architecture/economy/CURRENCY_AND_EXCHANGE.md + Financial::ExchangeRateService | Economy | Foundation (economy) | **P2** | 4-phase exchange evolution documented but phase transition logic unclear in code. |
| Verify seed file deduplication | galaxy_game/db/seeds.rb vs "seeds copy.rb" vs "seeds copy 2.rb" | Database | None | **P2** | Multiple seed files suggest abandoned iterations. Only one should be authoritative. |
| Implement automated link checking for docs | docs/ (all) | Documentation | None | **P3** | Prevents broken cross-references during future reorganization. |
| Establish documentation contribution guide | docs/ (all) | All docs | None | **P3** | Standardizes how new documentation is created and reviewed. |

---

## EXPANSION FEATURES

Adds future capability. Interesting but not required for core gameplay.

| Task | Current Location | Related Systems | Dependency | Recommended Priority | Reason |
|------|-----------------|-----------------|------------|---------------------|--------|
| Brown dwarf hub manager implementation verification | docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md (listed as core file) | Phase 3, AI Manager | Wormhole network | **P2** | Listed as "core" in architecture doc but implementation status is INFERRED. Verify code existence and functionality. |
| Digital Twin sandbox integration | docs/developer/DIGITAL_TWIN_SANDBOX.md + app/services/digital_twin_service.rb | Simulation, Admin | TerraSim | **P3** | Referenced in docs and code but integration unclear. Interesting admin feature but not core gameplay. |
| Precursor mission system (full implementation) | data/json-data/precursor_mission_setup_methane.json + docs/architecture/stations/precursor_mission_bootstrap_architecture.md | Phase 1, AI Manager | Foundation | **P3** | Multiple docs with different scopes. Interesting lore/mechanic but scope unclear. |
| Multi-wormhole event system (full implementation) | app/models/story_events/multi_wormhole_event.rb + docs/architecture/services/ai_manager/ | Phase 3, AI Manager | Wormhole network | **P3** | Model exists but event flow and player impact unclear. Interesting narrative feature. |
| EM power shield tier system | docs/architecture/systems/em_power_shield_tiers.md | Phase 3, Physics | Foundation | **P3** | Design documented but implementation status unclear. Interesting physics mechanic. |
| Sub-brown dwarf support | app/models/sub_brown_dwarf.rb | Phase 3, World Generation | StarSim | **P3** | Model exists but purpose and integration unclear. Niche celestial body type. |
| Hycean planet system (full implementation) | docs/architecture/simulation/hycean_planet_system.md | Phase 3, TerraSim | Sphere simulation | **P3** | Water-world subtype documented but implementation status unclear. Interesting world type for exploration. |
| Sci-fi easter eggs | docs/flavor/sci_fi_easter_eggs.md | Flavor | None | **P4** | Non-critical content. Fun to implement but not required for any gameplay loop. |

---

## EXPERIMENTAL

Interesting but not required. May be valuable later but should not block core development.

| Task | Current Location | Related Systems | Dependency | Recommended Priority | Reason |
|------|-----------------|-----------------|------------|---------------------|--------|
| Simulation Sandbox purpose clarification | docs/architecture/simulation/SIMULATION_SANDBOX.md | All simulation | None | **P3** | Document moved from root, purpose unclear. May be testing environment or orchestration layer. |
| Quest vs Mission distinction | data/json-data/missions/quests/ | AI Manager, Economy | Foundation | **P3** | "Quest" appears in mission data directory but unclear if distinct from missions. |
| Resource vs Material distinction | data/json-data/resources/materials/ + app/models/material_request.rb | Manufacturing, Economy | Foundation | **P3** | Used interchangeably in some places. Clarify before adding new resource types. |
| Technology Level visual tier system (TL 1-4+) | docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md | Tech tree, Rendering | TL-to-MK resolution | **P4** | Art Bible describes TL tiers but implementation status unclear. Visual design decision pending. |
| Alien life form simulation | app/models/celestial_bodies/alien_life_form.rb | TerraSim, Biosphere | Sphere simulation | **P4** | Model exists but scope and integration unclear. Interesting for late-game content. |
| Insurance market system | docs/architecture/economy/CONTRACTS.md + app/services/insurance/ | Economy | Foundation (economy) | **P4** | Insurance services exist but player-facing insurance market unclear. Interesting Eve Online-inspired feature. |

---

## DEPRECATED / QUESTIONABLE

Conflicts with current architecture or clearly superseded by newer decisions.

| Task | Current Location | Related Systems | Dependency | Recommended Priority | Reason |
|------|-----------------|-----------------|------------|---------------------|--------|
| PATHS.PAS (legacy Pascal code) | docs/legacy/PATHS.PAS | None | None | **DELETE** | Personal legacy code from unknown era. No connection to current Ruby/Rails architecture. |
| All .old, .new, .bak, .backup model files | app/models/ (multiple) | All models | None | **ARCHIVE** | Legacy variants superseded by current implementations. Archive to git history, remove from working tree. |
| docs/agent/archive/ content | docs/agent/archive/ | Agent system | None | **ARCHIVE** | Already archived but not moved to wiki_reorganization/13_ARCHIVE/. Consolidate with other historical content. |
| docs/agent/chat-logs/* | docs/agent/chat-logs/ | Agent system | None | **ARCHIVE** | Ephemeral session logs. No lasting architectural value. |
| docs/developer/pending_changes.md | docs/developer/pending_changes.md | Planning | None | **DELETE** | Superseded by CURRENT_STATUS.md. Pending changes are tracked in active status documents. |
| docs/developer/architectural_todos.md | docs/developer/architectural_todos.md | Planning | None | **ARCHIVE** | Session-specific todos from past work. Superseded by current phase mapping. |
| docs/developer/claude_notes.md | docs/developer/claude_notes.md | AI Manager | None | **ARCHIVE** | Session notes from specific Claude interaction. No lasting value. |
| docs/developer/development_notes.md | docs/developer/development_notes.md | Planning | None | **ARCHIVE** | Session notes. Superseded by CURRENT_STATUS.md and phase mapping. |
| docs/storyline/PHASE_ALIGNMENT_SUMMARY_2026-06-18.md | docs/storyline/ | Planning | None | **ARCHIVE** | Date-specific summary superseded by current planning documents. |
| GPT41_VACATION_BATCH.md | docs/agent/GPT41_VACATION_BATCH.md | Agent system | None | **ARCHIVE** | Specific batch processing notes from past session. No lasting value. |
| lunar_isru_flow.md (superseded by v2) | docs/architecture/patterns/planetary_patterns/lunar_isru_flow.md | Phase 1, ISRU | lunar_isru_flow_2.md | **ARCHIVE** | Superseded by lunar_isru_flow_2.md. Keep only if historical comparison needed. |
| AI_MANAGER_CONSTRUCTION_ECONOMICS.md.old.md | docs/architecture/services/ai_manager/ | AI Manager | None | **DELETE** | Obvious backup file. No value in repository. |
| AI_PRIORITY_SYSTEM.md.old.md | docs/architecture/services/ai_manager/ | AI Manager | None | **DELETE** | Obvious backup file. No value in repository. |
| ai_manager_expansion_and_wormhole_network.md.old.md | docs/architecture/services/ai_manager/ | AI Manager | None | **DELETE** | Obvious backup file. No value in repository. |
| PLAYER_EMERGENCY_MISSION.md.old | docs/architecture/services/ai_manager/ | AI Manager | None | **DELETE** | Obvious backup file. No value in repository. |
| material_lookup_service.rb.old | app/services/material_lookup_service.rb.old | Lookup services | None | **ARCHIVE** | Legacy service file. May have historical value but not active code. |
| base_craft.rb.new2, .new3 | app/models/craft/ | Craft system | base_craft.rb | **ARCHIVE** | Iteration variants superseded by current version. |
| unit.rb.old | app/models/units/unit.rb.old | Unit system | Units::BaseUnit | **ARCHIVE** | Superseded by Units::BaseUnit architecture. |

---

## Summary Statistics

| Category | Count | P0 | P1 | P2 | P3 | P4 |
|----------|-------|----|----|----|----|----|
| FOUNDATION BLOCKERS | 7 | 7 | 0 | 0 | 0 | 0 |
| CORE GAMEPLAY | 8 | 0 | 8 | 0 | 0 | 0 |
| INFRASTRUCTURE | 8 | 1 | 2 | 3 | 2 | 0 |
| EXPANSION FEATURES | 8 | 0 | 0 | 1 | 5 | 2 |
| EXPERIMENTAL | 6 | 0 | 0 | 1 | 3 | 2 |
| DEPRECATED/QUESTIONABLE | 17 | 0 | 0 | 0 | 0 | 17 (archive/delete) |
| **Total** | **54** | **8** | **10** | **5** | **10** | **23** |

---

## Critical Path Items (Must Address Before Any New Development)

1. **P0-1**: Resolve template version drift — breaks blueprint reliability
2. **P0-2**: Verify Habitat.rb active version — runtime correctness
3. **P0-3**: Resolve OrbitalDepot dual namespace — architecture clarity
4. **P0-4**: Clarify Colony vs Settlement — entity targeting correctness
5. **P0-5**: Resolve TL-to-MK relationship — blueprint gating logic
6. **P0-6**: Verify Job system code matches spec — authoritative spec compliance
7. **P1-1**: Update AI Manager architecture documentation — most outdated canonical doc

These 7 items block all meaningful new development because they affect core model correctness, blueprint reliability, and architectural clarity.
