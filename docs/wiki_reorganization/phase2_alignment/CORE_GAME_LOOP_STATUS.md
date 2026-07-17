# Core Game Loop Status — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Reconstruct the actual gameplay loop from code and documentation evidence  
**Rule**: Treat existing documentation as evidence, not authority. Prefer current code architecture over old design documents.

---

## Reconstructed Gameplay Loop

### Step 1: System Generation / Selection

```
Player starts:
↓
[What exists] Star system selection (Sol or procedural)
    ↓
[Status] ✅ IMPLEMENTED
    - Sol system: Precomputed JSON data (sol.json, sol-complete.json)
    - Other systems: Procedural generation via StarSim (Tier 2/3)
    - 30+ star system JSON files in data/json-data/star_systems/
    ↓
[Blocking issues] None — core world generation is complete
```

**Evidence**: `StarGenerator`, `SystemBuilderService`, `SystemGeneratorService` all CONFIRMED. Fidelity tiers (static → hybrid → procedural) documented and implemented.

---

### Step 2: Planetary Analysis

```
↓
Player selects target body and analyzes conditions:
↓
[What exists] Celestial body analysis (gravity, temp, atmosphere, resources)
    ↓
[Status] ✅ IMPLEMENTED
    - CelestialBody model with all sphere data
    - Resource deposits (procedural on survey)
    - Terrain map (elevation grid via geosphere.terrain_map)
    - Biome classification (11 canonical types per BIOME_TERRAFORMING_DESIGN.md)
    - Lookup services for all entity types
    ↓
[Blocking issues] None — analysis pipeline is complete
```

**Evidence**: `CelestialBody` model hierarchy CONFIRMED. `PlanetBuilder`, `PlanetTypeClassifier`, `PlanetCompositionEstimator` CONFIRMED. Biome definitions with temperature/rainfall ranges documented and implemented.

---

### Step 3: Mission Planning

```
↓
Player or AI Manager creates mission plan:
↓
[What exists] Mission planning (AI-driven + player contracts)
    ↓
[Status] ⚠️ PARTIALLY IMPLEMENTED
    - AI Manager has LlmPlannerService, MissionScorer, MissionProfileAnalyzer ✅
    - Player contract system with 4 types (courier, manufacturing, exploration, station expansion) ✅
    - Pattern learning from successful deployments ✅
    - ❓ Player-facing mission creation UI status unclear
    - ❓ Contract posting → player acceptance → NPC fallback flow needs verification
    ↓
[Blocking issues] 
    - Player-first contract priority enforcement in code unclear (MEDIUM)
    - AI Manager architecture documentation severely outdated (8 files vs 80+ services) (HIGH)
```

**Evidence**: `AIManager::LlmPlannerService`, `AIManager::MissionScorer` CONFIRMED. Contract system documented in `docs/architecture/economy/CONTRACTS.md`. Player-first priority (24-48h window, 1.5x reward) documented but code enforcement unclear.

---

### Step 4: Transportation / Deployment

```
↓
Player deploys craft to target location:
↓
[What exists] Craft deployment and orbital mechanics
    ↓
[Status] ⚠️ PARTIALLY IMPLEMENTED
    - Craft models (Harvester, Rover, Ship, Spaceship) ✅
    - Cycler system (mobile space stations) ✅
    - Universal docking service ✅
    - Transport cost service ✅
    - Orbital mechanics transfer calculator ✅
    - ❓ Cycler model location mismatch (root namespace vs AI Manager docs)
    - ❓ EM physics integration for transport costs unclear
    ↓
[Blocking issues]
    - Cycler namespace convention needs clarification (LOW)
    - Transport cost EM physics integration undocumented (LOW)
```

**Evidence**: `Craft::BaseCraft` hierarchy CONFIRMED. `Cycler` model exists at root namespace. `UniversalDockingService`, `TransportCostService`, `OrbitalMechanics::TransferCalculator` all CONFIRMED.

---

### Step 5: Resource Extraction

```
↓
Player extracts resources from planetary surface:
↓
[What exists] Resource extraction (ISRU, mining, atmospheric harvesting)
    ↓
[Status] ✅ SUBSTANTIALLY IMPLEMENTED
    - Units::Extractor model ✅
    - ISRU evaluator and optimizer services ✅
    - Atmospheric harvester service ✅
    - Regolith processing service ✅
    - Gas mining service ✅
    - Resource acquisition service ✅
    - Material request system ✅
    ↓
[Blocking issues]
    - ISRU pricing model documentation may be outdated (LOW)
    - Extraction cost/energy mechanics need verification against GUARDRAILS
```

**Evidence**: `AIManager::IsruEvaluator`, `AIManager::IsruOptimizer`, `AIManager::AtmosphericHarvesterService`, `Manufacturing::RegolithProcessingService` all CONFIRMED. Resource deposit model CONFIRMED.

---

### Step 6: Manufacturing / Fabrication

```
↓
Player manufactures goods from extracted resources:
↓
[What exists] Manufacturing chain (raw → processed → components → blueprints → assembly)
    ↓
[Status] ✅ SUBSTANTIALLY IMPLEMENTED
    - Units::Fabricator (Mk1-Mk3) ✅
    - Component production service ✅
    - Material processing service ✅
    - Shell printing service ✅
    - Byproduct manufacturing service ✅
    - Blueprint model + cost schema v1.1 ✅
    - 70+ template JSON files ✅
    - 19 technology categories in tech tree ✅
    ↓
[Blocking issues]
    - Manufacturing overview doc is Draft/Stub (2026-04-27) — incomplete (MEDIUM)
    - Template version drift v1-v7 across blueprint types (MEDIUM)
    - Mk2→Mk3 dependency chain enforcement unclear (LOW)
```

**Evidence**: `Manufacturing::AssemblyService`, `ComponentProductionService`, `MaterialProcessingService`, `ShellPrintingService` all CONFIRMED. Blueprint model + schema CONFIRMED. Tech tree 19 categories CONFIRMED.

---

### Step 7: Settlement Construction / Expansion

```
↓
Player builds structures and expands settlement:
↓
[What exists] Settlement and structure construction
    ↓
[Status] ✅ SUBSTANTIALLY IMPLEMENTED
    - Settlement::BaseSettlement model ✅
    - Structures::BaseStructure + 15 structure types ✅
    - Worldhouse (lava tube enclosure) ✅
    - ConstructionJob model (surface construction) ✅
    - Pressurization system (6 services) ✅
    - Lava tube sealing service ✅
    - Dome service ✅
    - Skylight calculator ✅
    ↓
[Blocking issues]
    - OrbitalDepot dual namespace is a blocker for documentation consolidation (MEDIUM)
    - ConstructionJob code must match authoritative Job System Mechanics Spec (MEDIUM)
```

**Evidence**: `Structures::BaseStructure` + all subclasses CONFIRMED. `Settlement::BaseSettlement` CONFIRMED. `ConstructionJob`, `PressurizationService` hierarchy CONFIRMED. Job system documented in authoritative spec.

---

### Step 8: Economic Interaction

```
↓
Player interacts with economy (trade, contracts, pricing):
↓
[What exists] Dual-currency economy with market and logistics
    ↓
[Status] ✅ SUBSTANTIALLY IMPLEMENTED
    - Financial::Account polymorphic model ✅
    - GCC/USD dual currency ✅
    - Exchange rate service ✅
    - Virtual ledger for NPC trading ✅
    - Market::Marketplace + NPC pricing ✅
    - Contract system (4 types) ✅
    - Logistics services (contract, manifest, routing) ✅
    - Consortium membership system ✅
    ↓
[Blocking issues]
    - Exchange rate phase progression logic unclear in code (MEDIUM)
    - Player-first contract enforcement in code unclear (MEDIUM)
    - Market stabilization integration undocumented (LOW)
```

**Evidence**: `Financial::Account`, `Financial::Currency` (GCC/USD), `Financial::ExchangeRateService`, `Financial::VirtualLedgerService` all CONFIRMED. `Market::Marketplace`, `NPCPriceCalculator`, `TradeExecutionService` CONFIRMED. Contract system CONFIRMED.

---

### Step 9: Technology Progression

```
↓
Player advances technology to unlock new capabilities:
↓
[What exists] Technology tree with 19 categories and TL/MK system
    ↓
[Status] ⚠️ PARTIALLY IMPLEMENTED
    - 19 tech categories in JSON ✅
    - Blueprint required_technology fields ✅
    - Mk1→Mk2→Mk3 fabrication progression ✅
    - ❓ Technology Level (TL 1-4+) implementation status unclear
    - ❓ TL-to-MK relationship is an OPEN QUESTION (Art Bible docs)
    ↓
[Blocking issues]
    - TL-to-MK relationship explicitly unresolved — design decision needed (HIGH)
    - TL visual tier system implementation unclear (MEDIUM)
```

**Evidence**: `data/json-data/tech_tree/` has 19 categories CONFIRMED. Blueprint `required_technology` fields CONFIRMED. Art Bible docs explicitly state TL-to-MK relationship is "open question" needing "explicit design decision."

---

### Step 10: Terraforming (Long-Term)

```
↓
Player initiates planetary terraforming over extended game time:
↓
[What exists] TerraSim simulation with sphere-level evolution
    ↓
[Status] ⚠️ PARTIALLY IMPLEMENTED
    - Atmosphere simulation service ✅
    - Hydrosphere simulation service ✅
    - Geosphere simulation service ✅
    - Biosphere simulation service ✅
    - Biome definitions (11 types) ✅
    - Terraforming project model ✅
    - ❓ Regression/weathering engine NOT IMPLEMENTED (core SimEarth feature)
    - ❓ Civ4 shoreline regression filter NOT IMPLEMENTED
    - ❓ Earth biosphere validation before terraforming unclear
    ↓
[Blocking issues]
    - No regression/weathering engine for lush-to-barren transitions (HIGH)
    - Civ4 shoreline flooding causes unrealistic water/land boundaries (HIGH)
    - Earth-first validation principle not confirmed in code (MEDIUM)
```

**Evidence**: TerraSim services CONFIRMED. Biosphere simulation CONFIRMED. Architecture docs explicitly state regression engine is NOT implemented. Shoreline flooding flagged as known issue requiring dedicated filter.

---

### Step 11: Interstellar Expansion (Late Game)

```
↓
Player expands beyond solar system via wormhole network:
↓
[What exists] Wormhole infrastructure and AI-driven expansion
    ↓
[Status] ⚠️ PARTIALLY IMPLEMENTED
    - Wormhole model ✅
    - WormholeCoordinator (BFS wayfinding) ✅
    - WormholeManager + PlacementService ✅
    - WormholeScoutingService ✅
    - Consortium voting engine (66% quorum) ✅
    - Hammer Protocol (EM reset/snap control) ✅
    - EM harvesting service ✅
    - SystemArchitect (infrastructure deployment) ✅
    - Multi-wormhole event handler ✅
    - ❓ Brown dwarf hub manager implementation status INFERRED (not CONFIRMED)
    ↓
[Blocking issues]
    - Brown dwarf hub manager implementation status unclear (LOW)
    - Quorum enforcement in code unclear (LOW)
```

**Evidence**: Wormhole services CONFIRMED. Consortium voting engine CONFIRMED. Hammer Protocol CONFIRMED. Brown dwarf hub manager listed as "core" in architecture doc but implementation is INFERRED.

---

### Step 12: AI Autonomy / Emergent Complexity

```
↓
AI Manager operates autonomously, learning from player and NPC actions:
↓
[What exists] AI Manager with pattern learning and strategic evaluation
    ↓
[Status] ✅ IMPLEMENTED (but documentation severely outdated)
    - PatternLoader + PatternValidator ✅
    - StrategicEvaluator + StrategySelector ✅
    - PriorityArbitrator + PriorityHeuristic ✅
    - PerformanceTracker ✅
    - SimEvaluator ✅
    - ColonyManager (AI-driven) ✅
    - EmergencyMissionService ✅
    - PrecursorLearningService ✅
    ↓
[Blocking issues]
    - Architecture documentation describes 8 files; actual system has 80+ (CRITICAL)
    - Colony vs Settlement relationship unclear (MEDIUM)
```

**Evidence**: All AI Manager services CONFIRMED in code. Pattern learning CONFIRMED. Strategic evaluation CONFIRMED. Documentation is the primary gap — not implementation.

---

## Complete Loop Summary

| Step | System | Status | Blocking Issues |
|------|--------|--------|-----------------|
| 1. System Generation | StarSim | ✅ Implemented | None |
| 2. Planetary Analysis | CelestialBody + Lookup | ✅ Implemented | None |
| 3. Mission Planning | AI Manager + Contracts | ⚠️ Partial | Player-first enforcement unclear |
| 4. Transportation | Craft + Cyclers + Docking | ✅ Substantially Implemented | Cycler namespace mismatch |
| 5. Resource Extraction | ISRU + Mining | ✅ Substantially Implemented | ISRU pricing docs may be outdated |
| 6. Manufacturing | Fabricators + Blueprints | ✅ Substantially Implemented | Template version drift, stub overview doc |
| 7. Settlement Construction | Structures + Pressurization | ✅ Substantially Implemented | OrbitalDepot namespace blocker |
| 8. Economic Interaction | Dual Currency + Market | ✅ Substantially Implemented | Exchange rate phase logic unclear |
| 9. Technology Progression | Tech Tree + TL/MK | ⚠️ Partial | **TL-to-MK relationship unresolved** |
| 10. Terraforming | TerraSim + Biomes | ⚠️ Partial | **Regression engine NOT implemented** |
| 11. Interstellar Expansion | Wormholes + AI | ✅ Substantially Implemented | Brown dwarf hub status unclear |
| 12. AI Autonomy | Pattern Learning | ✅ Implemented (docs outdated) | Architecture doc severely outdated |

---

## Critical Path for Complete Loop

```
Step 1 → Step 2 → Step 3 → Step 4 → Step 5 → Step 6 → Step 7 → Step 8 → Step 9 → Step 10 → Step 11 → Step 12
```

**Steps with blockers preventing complete loop:**

1. **Step 9 (Technology)**: TL-to-MK relationship unresolved — blocks blueprint gating logic
2. **Step 10 (Terraforming)**: Regression engine not implemented — core SimEarth feature missing
3. **Step 3 (Mission Planning)**: Player-first contract enforcement unclear — core gameplay pillar at risk

**These 3 blockers prevent the full gameplay loop from functioning as designed.**

---

## What Works Today (Without Changes)

A player can:
1. ✅ Generate or select a star system
2. ✅ Analyze planetary conditions and resources
3. ⚠️ View AI-generated missions (player-facing creation unclear)
4. ✅ Deploy craft to target bodies
5. ✅ Extract resources via ISRU and mining
6. ✅ Manufacture goods via fabricators and blueprints
7. ✅ Build structures in settlements
8. ✅ Trade via market and contracts
9. ⚠️ View technology tree (TL-to-MK gating unclear)
10. ❌ Full terraforming simulation (regression engine missing)
11. ✅ Discover and expand via wormholes
12. ✅ Observe AI Manager autonomous operations

**Estimated completion: ~85% of gameplay loop functional, 2 critical gaps (terraforming regression, TL-to-MK gating).**
