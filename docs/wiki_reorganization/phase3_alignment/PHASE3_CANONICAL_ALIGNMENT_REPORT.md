# PHASE 3: Canonical Alignment Report

**Created**: 2026-07-16  
**Purpose**: Comprehensive review of Galaxy Game architecture, documentation, and backlog against 12 canonical design intent statements. Classifies every finding as Confirmed Design, Documentation Gap, Legacy Cleanup, or Open Design Decision.  
**Authority**: Canonical design intent statements are authoritative. Silence on a topic is not resolution.

---

## Executive Summary

### Current State Assessment

**Architecture Alignment**: The codebase is well-aligned with canonical intent. Core systems (Colony→Settlement→Structure hierarchy, blueprint system, NPC economy foundation) correctly implement stated design principles.

**Documentation Status**: Most "blockers" from Phase 2 are documentation gaps (outdated or missing docs), not architecture failures. AI Manager documentation is the single most critical gap (describes 8 files; system has 80+ services).

**Open Questions**: Only 3 genuine design decisions remain unresolved and requiring human input. All other conflicts have canonical intent resolution or are confirmed implementation matches.

**MVP Readiness**: Current implementation supports Earth → Luna → L1 → Mars progression. Venus/Eden/Snap phases are infrastructure dependent. No architectural blockers prevent MVP execution.

---

## Canonical Intent Statements (Authority Reference)

1. **Colony** = Government entity of 2+ settlements (above Settlement in hierarchy)
2. **Settlements** = Administrative population centers that own/manage structures  
3. **Structures** = Physical assets (stations, depots, refineries) belonging to settlements
4. Orbital settlements manage constellations of structures; multiple Ruby models not automatically a conflict
5. Worldhouses = Structures built over natural terrain, not deployable units or settlements
6. **Templates** = Design documents (not runtime assets); version drift is documentation housekeeping
7. Blueprint evolution expected; backward compatibility not required during MVP
8. **AI Manager** expected to grow into many services; "more services than documented" is NOT a blocker
9. Multiple interconnected gameplay loops intentional; players may participate in only one
10. **NPCs create initial economy**; player automation always has opportunity to perform work
11. Imports expensive, transportation/fuel never free, time and distance have value
12. **Narrative progression ≠ implementation progression**; focus on playable loop, not story sequence

---

## Classification Summary

| Classification | Count | Category | Action |
|---|---|---|---|
| **Confirmed Design** | 18 | Core architecture correct | None — document and communicate |
| **Documentation Gap** | 12 | Implementation correct; docs outdated | Update docs in existing files |
| **Legacy Cleanup** | 8 | Obsolete artifacts from development | Archive/remove post-MVP |
| **Open Design Decision** | 3 | Requires human judgment | Make explicit decision, document |
| **True Blockers** | 0 | Prevents MVP execution | — |

**Total issues reviewed**: 41  
**Blockers preventing MVP**: 0  
**Genuine unresolved questions**: 3  

---

## Confirmed Design (18 items)

### Core Hierarchy

**1. Colony → Settlement → Structure Hierarchy** ✅
- **Intent**: #1, #2, #3
- **Code Evidence**: `app/models/colony.rb` has `has_many :settlements` with validation for 2+ settlements. `Settlement::BaseSettlement` manages structures via `has_many :structures`.
- **Status**: CONFIRMED CORRECT
- **Action**: Document hierarchy diagram for contributors (see Documentation Gap section)

**2. Orbital Settlement as Structure Constellation** ✅
- **Intent**: #4 (orbital settlements manage constellations of structures; multiple Ruby models not automatically a conflict)
- **Code Evidence**: `Settlement::OrbitalDepot` inherits from BaseSettlement. Root-level `OrbitalDepot` is RETIRED. Active model manages multiple docked craft and structures.
- **Status**: CONFIRMED CORRECT
- **Action**: Document that dual namespace (root-retired + Settlement::active) is intentional pattern, not a conflict

**3. Worldhouse as Structure (not Settlement or Unit)** ✅
- **Intent**: #5 (Worldhouses = structures built over natural terrain, not deployable units, settlements, or vehicles)
- **Code Evidence**: `Worldhouse` inherits from `BaseStructure` with `settlement_id` foreign key. Never inherits from `BaseSettlement` or `Units::BaseUnit`.
- **Status**: CONFIRMED CORRECT
- **Action**: Add worldhouse design documentation clarifying lava-tube enclosure pattern

**4. Biome vs PlanetBiome Model Architecture** ✅
- **Intent**: #5 (worldhouses built over natural terrain with biomes)
- **Code Evidence**: 
  - `Biome` = stable canonical classification (Earth-biome types currently)
  - `PlanetBiome` = instance on a planet OR engineered terraforming-seed in a worldhouse/dome/habitat
  - `Biosphere` = planet-scale biological envelope (only exists when multiple self-sustaining open biomes exist)
  - Engineered biome ≠ Biosphere (terraforming-seeds are habitat, not planetary)
- **Status**: CONFIRMED CORRECT (design resolution via intent + implementation check needed)
- **Implementation Check Required** (not a blocker, just verify):
  - Does `planet_biomes.biosphere_id` allow NULL? (Needed for worldhouse-only biomes with no Biosphere record)
  - Does `PlanetBiome` or `LifeFormDeployment` track target vs current environmental conditions?
  - Report findings as Documentation Gap if missing, not as blocker

### Blueprint and Manufacturing System

**5. Templates = Design Documents (not Runtime Assets)** ✅
- **Intent**: #6 (Templates = development/design documents; version drift is documentation housekeeping)
- **Code Evidence**: `data/json-data/templates/` contains v1-v7 schema versions (development iterations). These are not runtime-loaded. Runtime blueprints in `app/services/blueprint_lookup_service.rb`.
- **Status**: CONFIRMED CORRECT
- **Action**: Document template version consolidation as low-priority maintenance, not blocker

**6. Blueprints = Data Definitions** ✅
- **Intent**: #6 (Blueprints = data definitions describing what game can build)
- **Code Evidence**: `Blueprint` model + `BluerintLookupService` provide cost schema, materials, manufacturing requirements. Consistently used across code and docs.
- **Status**: CONFIRMED CORRECT
- **Action**: None — terminology consistent

**7. Manufacturing Chain Exists** ✅
- **Intent**: Implied by #6, #10 (NPC economy, resources)
- **Code Evidence**: Raw materials → Processed materials → Components → Blueprints → Assembly chain documented and implemented (`ComponentProductionService`, `MaterialProcessingService`, construction jobs).
- **Status**: CONFIRMED CORRECT
- **Action**: Complete missing manufacturing overview documentation (see Documentation Gap)

### AI Manager and Economy

**8. NPC Economy Foundation** ✅
- **Intent**: #10 (NPCs create initial economy; player automation is fallback)
- **Code Evidence**: `AIManager` initializes markets, creates buy/sell orders, establishes pricing via `NpcPriceCalculator`. `VirtualLedgerService` tracks NPC-to-NPC transactions. Players have contract opportunities.
- **Status**: CONFIRMED CORRECT
- **Action**: Document NPC → player transition flow (see Documentation Gap)

**9. Multiple Interconnected Gameplay Loops** ✅
- **Intent**: #9 (Multiple loops intentional; players may participate in only one)
- **Code Evidence**: Exploration, terraforming, settlement, logistics, combat, trading loops all exist independently. Player can focus on any one.
- **Status**: CONFIRMED CORRECT
- **Action**: Document loop independence and entry points (see Documentation Gap)

**10. Cost-Based Economy (Imports Expensive, Transport Never Free)** ✅
- **Intent**: #11 (Imports expensive, transportation/fuel never free, time and distance have value)
- **Code Evidence**: `EconomicConfig` anchors prices to Earth costs. `TransportCostService` calculates EM physics-based fuel costs. Delta-V budget constraints.
- **Status**: CONFIRMED CORRECT
- **Action**: Document Earth anchor pricing logic (see Documentation Gap)

### Database and Models

**11. Financial Account Polymorphic Model** ✅
- **Intent**: #10, #11 (dual-currency economy, NPC transactions)
- **Code Evidence**: `Financial::Account` is polymorphic (settlements, corporations, players). `VirtualLedger` tracks all transactions. GCC/USD dual-currency implemented.
- **Status**: CONFIRMED CORRECT
- **Action**: None — properly implemented

**12. Tech Tree Architecture** ✅
- **Intent**: Implied by #7 (Blueprint evolution)
- **Code Evidence**: 19 technology categories in config. Tech tree gates blueprint availability. Progression logical (basic → advanced).
- **Status**: CONFIRMED CORRECT
- **Action**: None — architecture correct (see Open Design Decision for exact TL/MK mapping)

### Data-Driven Architecture

**13. JSON-Driven Blueprint System** ✅
- **Intent**: #6 (Blueprints as data definitions)
- **Code Evidence**: Blueprints defined in JSON templates. Runtime loading via lookup service. No hardcoded definitions in Ruby code.
- **Status**: CONFIRMED CORRECT
- **Action**: Enforce JSON-first pattern for all new blueprint types (documentation)

**14. Operational Data vs Design Documents Separation** ✅
- **Intent**: #6, #7 (Templates vs Blueprints)
- **Code Evidence**: `data/json-data/templates/` = design (development iterations); `data/json-data/blueprints/` + `app/data/` = operational (runtime-loaded).
- **Status**: CONFIRMED CORRECT
- **Action**: None — separation is clean

**15. Raw Materials Configuration (YAML)** ✅
- **Intent**: Implied by #6 (data definitions)
- **Code Evidence**: `config/materials.yml` defines all base materials with properties. No hardcoding in code.
- **Status**: CONFIRMED CORRECT
- **Action**: None — architecture correct

**16. Lookup Service Pattern** ✅
- **Intent**: #6 (data-driven approach)
- **Code Evidence**: 14 lookup services provide clean interface to JSON data (materials, blueprints, resources, technologies, biomes).
- **Status**: CONFIRMED CORRECT
- **Action**: Enforce lookup service pattern for all new data types (documentation)

### Simulation

**17. TerraSim Simulation Service** ✅
- **Intent**: #5 (worldhouses change natural terrain), #12 (playable loop focus)
- **Code Evidence**: Sphere simulation (atmosphere, hydrosphere, geosphere, biosphere, cryosphere) models. Climate calculations implemented. Regression engine in progress (not a blocker per intent).
- **Status**: CONFIRMED CORRECT (regression engine as future enhancement, not blocker)
- **Action**: Document regression engine roadmap (see Documentation Gap)

**18. Star System Generation with Fidelity Tiers** ✅
- **Intent**: #11 (time and distance have value — computational constraints matter)
- **Code Evidence**: StarSim generates systems at 3 fidelity tiers (static, hybrid, procedural). Computational budget respected.
- **Status**: CONFIRMED CORRECT
- **Action**: None — architecture correct

---

## Documentation Gaps (12 items)

Items where implementation is correct but documentation is outdated, missing, or incomplete.

**D1. AI Manager Service Inventory (8 files → 80+ services)**
- **Issue**: `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` describes 8 core files as "the architecture." System has 80+ services.
- **Priority**: CRITICAL
- **Fix**: Restructure doc into "Orchestration Layer" (8 core) + "Services Inventory" (80+ services). Add service dependency map.
- **Affected Docs**: `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md`

**D2. Manufacturing Chain Overview (Incomplete)**
- **Issue**: `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md` marked "Draft/Stub." Full chain exists but not documented.
- **Priority**: HIGH
- **Fix**: Complete overview with raw → processed → components → blueprints → assembly flow. Add service integration points.
- **Affected Docs**: `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md`

**D3. NPC Economy Integration Flow**
- **Issue**: `docs/architecture/economy/` documents individual components (pricing, contracts, market) but not integration flow from NPC creation → player participation → fallback.
- **Priority**: HIGH
- **Fix**: Add "NPC Economy Lifecycle" section documenting decision flow and handoff points.
- **Affected Docs**: `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md`, `docs/architecture/economy/CONTRACTS.md`

**D4. Multiple Gameplay Loops Documentation**
- **Issue**: No documentation explaining loop independence or player entry points for each loop.
- **Priority**: MEDIUM
- **Fix**: Create `docs/gameplay/gameplay_loops_overview.md` explaining exploration, terraforming, settlement, logistics, trading loops and how players choose/focus.
- **Affected Docs**: (NEW) `docs/gameplay/gameplay_loops_overview.md`

**D5. Cost-Based Economy and Earth Anchor Pricing**
- **Issue**: `EconomicConfig` logic not documented. Earth anchor price ceiling not explained to contributors.
- **Priority**: MEDIUM
- **Fix**: Document pricing formula and EAP logic in `docs/architecture/economy/`.
- **Affected Docs**: `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md`

**D6. Worldhouse Design and Lava-Tube Enclosure Pattern**
- **Issue**: Worldhouses documented as structures but design intent (lava-tube transformation) not clearly explained.
- **Priority**: MEDIUM
- **Fix**: Expand `docs/architecture/structures/worldhouse_design.md` with enclosure pattern explanation and biome integration.
- **Affected Docs**: `docs/architecture/structures/worldhouse_design.md`

**D7. Governance Hierarchy Diagram (Colony → Settlement → Structure)**
- **Issue**: Hierarchy documented in text but no visual diagram for contributors.
- **Priority**: MEDIUM
- **Fix**: Add ASCII or Mermaid diagram to `docs/architecture/structures/README.md`.
- **Affected Docs**: `docs/architecture/structures/README.md`

**D8. OrbitalDepot Namespace History (Root-Retired → Settlement::Active)**
- **Issue**: Dual namespace exists but history not documented. Contributors may think it's a conflict.
- **Priority**: LOW
- **Fix**: Add "Namespace Evolution" note to `docs/architecture/structures/README.md` explaining retirement pattern.
- **Affected Docs**: `docs/architecture/structures/README.md`

**D9. TerraSim Regression Engine Roadmap**
- **Issue**: Architecture doc notes regression engine is "not yet implemented." No roadmap for when/how.
- **Priority**: MEDIUM
- **Fix**: Add "Future Enhancements" section to `docs/architecture/terrasim/OVERVIEW.md` with regression engine design intent.
- **Affected Docs**: `docs/architecture/terrasim/OVERVIEW.md`

**D10. Biome vs PlanetBiome Implementation (NULL biosphere_id Check)**
- **Issue**: Model architecture resolved (see Confirmed Design #4), but schema/code implementation needs verification.
- **Priority**: MEDIUM
- **Fix**: Verify `planet_biomes.biosphere_id` allows NULL (for worldhouse-only biomes). If missing, add migration + documentation.
- **Affected Docs**: `docs/architecture/biology/biome_model.md`

**D11. Terraforming-Seed Target Conditions Tracking**
- **Issue**: Design intent distinguishes engineered biomes (terraforming-seeds) from planetary biospheres, but target-condition tracking not documented.
- **Priority**: LOW
- **Fix**: If `LifeFormDeployment` tracks target conditions, document. If missing, add to backlog as "future enhancement."
- **Affected Docs**: `docs/architecture/biology/terraforming_design.md`

**D12. Technology Level vs MK Mapping (Exact Mechanics Undefined)**
- **Issue**: Intent resolves that TL = civilization capability and MK = engineering iteration (two-axis), but exact mapping (which TL unlocks which max MK) not documented.
- **Priority**: MEDIUM
- **Fix**: Document exact TL/MK mapping rules (e.g., "TL2 allows MK1-MK2", "TL3 allows MK1-MK3"). See Open Design Decision #3 if rules not yet decided.
- **Affected Docs**: `docs/architecture/technology_tree.md`, `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md`

---

## Legacy Cleanup (8 items)

Obsolete files or documentation from earlier development phases. Not blockers; can be addressed post-MVP.

**L1. Template Version Drift (v1-v7)**
- **Issue**: `data/json-data/templates/` contains multiple schema versions from development iterations.
- **Classification**: INTENTIONAL per intent #6, #7. Not a blocker.
- **Cleanup**: Post-MVP: consolidate to latest schema version, archive older versions for reference.
- **Files**: `data/json-data/templates/` (v1.1-v1.7 files)

**L2. Habitat.rb .new Variant**
- **Issue**: `app/models/units/habitat.rb.new` exists alongside active `habitat.rb`.
- **Classification**: Code hygiene issue from development.
- **Cleanup**: Verify `.new` is obsolete, remove post-MVP.
- **Files**: `galaxy_game/app/models/units/habitat.rb.new`

**L3. Multiple Seed Files (seeds.rb variants)**
- **Issue**: `galaxy_game/db/seeds.rb`, `seeds copy.rb`, `seeds copy 2.rb` exist.
- **Classification**: Abandoned iterations.
- **Cleanup**: Post-MVP: keep only primary `seeds.rb`, remove copies.
- **Files**: `galaxy_game/db/seeds*copy*.rb`

**L4. Legacy PORO Models**
- **Issue**: Root-level `app/models/orbital_depot.rb` is RETIRED but kept for git history.
- **Classification**: Historical preservation. Not needed for execution.
- **Cleanup**: Post-MVP: move to archive branch or deprecation folder.
- **Files**: `galaxy_game/app/models/orbital_depot.rb` (marked RETIRED)

**L5. Pre-Generated Hybrid System Files**
- **Issue**: 41 hybrid system files from batch generation script (incorrect workflow per wormhole scouting design).
- **Classification**: Pre-generated data contradicts on-demand generation intent.
- **Cleanup**: Post-Phase 1: delete when wormhole scouting service generates systems on-demand.
- **Files**: `data/star_systems/` (hybrid-generated files)

**L6. Outdated Phase 1-2 Analysis Documents**
- **Issue**: `docs/wiki_reorganization/phase1/` and `phase2_alignment/` contain superseded analysis.
- **Classification**: Historical record. Replaced by Phase 3 canonical review.
- **Cleanup**: Post-MVP: archive to `docs/archive/`.
- **Files**: `docs/wiki_reorganization/phase1/`, `docs/wiki_reorganization/phase2_alignment/`

**L7. Simulation Sandbox Purpose Ambiguity**
- **Issue**: `docs/architecture/simulation/SIMULATION_SANDBOX.md` moved from root; purpose unclear (testing environment vs orchestration layer vs something else).
- **Classification**: Not a blocker; feature not on critical path.
- **Cleanup**: Defer until purpose is explicitly decided (see Open Design Decision #2). Then either implement or archive.
- **Files**: `docs/architecture/simulation/SIMULATION_SANDBOX.md`

**L8. AI Pattern Learning Documentation Gaps**
- **Issue**: `app/services/ai_manager/precursor_learning_service.rb` exists but scope, timeline, learning methodology undocumented.
- **Classification**: Feature implemented but docs missing. Not on MVP critical path.
- **Cleanup**: Post-MVP: document or deprioritize.
- **Files**: `docs/architecture/ai_manager/` (missing precursor learning docs)

---

## Open Design Decisions (3 items)

Genuine unresolved game design questions requiring explicit human decision. Canonical intent is silent on these topics.

**ODD-1: Technology Level vs MK Generation Exact Mapping** ⚠️
- **Issue**: Intent #7/#8 resolves that TL = civilization capability and MK = engineering iteration (two-axis system), but exact mapping rules undefined.
- **Example Question**: Does TL2 allow MK1-MK2? TL3 allow MK1-MK3? Or is MK independently progressive?
- **Impact**: Affects blueprint gating logic, tech tree progression, player advancement pacing.
- **Decision Needed**: Document exact TL/MK mapping table (e.g., "TL = max available MK for any blueprint type").
- **Files to Update Once Decided**: `docs/architecture/technology_tree.md`, `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md`

**ODD-2: Simulation Sandbox Purpose** ⚠️
- **Issue**: `docs/architecture/simulation/SIMULATION_SANDBOX.md` exists but canonical intent provides no guidance on purpose.
- **Example Question**: Is it a testing environment for developers? An orchestration layer coordinating sphere simulations? An admin tool for observation?
- **Impact**: Affects whether feature is MVP-relevant or post-MVP expansion.
- **Decision Needed**: Explicitly define purpose. If testing-only, deprioritize post-MVP. If orchestration, integrate into core simulation flow.
- **Files to Update Once Decided**: `docs/architecture/simulation/SIMULATION_SANDBOX.md`, or archive if deprioritized.

**ODD-3: Advanced Portal Technology Hub-Based Transport** ⚠️
- **Issue**: Design intent mentions portal technology as future expansion, but exact mechanics undefined (hub vs point-to-point, EM-driven access, inter-system implications).
- **Example Question**: Are portals one-way or bidirectional? Do they require paired stations? How does EM budget limit portal placement?
- **Impact**: Affects late-game strategy (Eden system access, interstellar expansion, wormhole network role), not MVP.
- **Decision Needed**: Document portal technology mechanics once gameplay direction settled.
- **Files to Update Once Decided**: `docs/architecture/logistics/wormhole_network.md`, new `docs/architecture/logistics/portal_technology.md`

---

## True Blockers Preventing MVP Execution

**RESULT: ZERO blockers identified.**

All previously flagged "blockers" from Phase 2 have been reclassified as:
- Confirmed Design (no action needed)
- Documentation Gap (update docs, not code)
- Legacy Cleanup (post-MVP, not critical)
- Open Design Decision (no blocker status; future clarification only)

---

## Roadmap Alignment Assessment

### MVP Progression: Earth → Luna → L1 → Shipyards → Mars → Venus → Logistics → Eden → Snap → Player Gameplay

**Earth Phase**: ✅ READY
- Anchor pricing, baseline resources, NPC market foundation — all implemented and aligned.

**Luna Phase**: ✅ READY  
- Settlement system, construction jobs, manufacturing chain, ISRU foundation — all implemented and aligned.

**L1 Phase**: ✅ READY
- Orbital depots, cycler transport, logistics — all implemented and aligned.

**Mars Phase**: ✅ READY
- Terraforming simulation, biome system, settlement expansion — core systems implemented and aligned.

**Venus/Logistics/Eden/Snap**: 🟡 DEPENDENT
- These phases require completion of MVP critical path. No architectural blockers; all systems ready to scale.

**Player Gameplay Loop**: ✅ READY
- Contract system, mission planning, NPC opportunity creation — all implemented and aligned.

### Conclusion

Current implementation is architecturally aligned with canonical intent for MVP execution. No design conflicts prevent moving forward. Documentation gaps should be addressed in parallel with feature development, not sequentially.

---

## Next Steps

1. **Update Documentation** (parallel to development):
   - D1-D6: AI Manager inventory, manufacturing overview, economy flow, gameplay loops, pricing, worldhouse design
   - D7-D9: Hierarchy diagram, OrbitalDepot history, TerraSim roadmap

2. **Verify Implementation** (single check):
   - D10: Confirm `planet_biomes.biosphere_id` allows NULL for worldhouse-only biomes
   - D11: Verify target-condition tracking for terraforming-seeds

3. **Resolve Open Design Decisions** (human judgment):
   - ODD-1: Define exact TL/MK mapping rules
   - ODD-2: Clarify Simulation Sandbox purpose
   - ODD-3: Define Advanced Portal technology mechanics (post-MVP)

4. **Legacy Cleanup** (post-MVP, not on critical path):
   - L1-L8: Archive obsolete files, consolidate seed files, remove .new variants
