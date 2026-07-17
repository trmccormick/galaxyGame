# Architecture Reconstruction — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Reconstruct the current architecture from existing evidence  
**Legend**: [CONFIRMED] = Supported by code/docs | [INFERRED] = Strongly suggested | [UNKNOWN] = Needs review

---

## Simulation Hierarchy

### Top-Level Structure

```
Galaxy (app/models/galaxy.rb)
├── SolarSystem (app/models/solar_system.rb)
│   ├── Star (CelestialBody::Star)
│   │   └── HabitableZoneCalculator [CONFIRMED]
│   ├── CelestialBody hierarchy
│   │   ├── Planets
│   │   │   ├── Rocky planets (CelestialBody::Planets::Rocky::* )
│   │   │   ├── Ocean planets (CelestialBody::Planets::Ocean::* )
│   │   │   └── Gaseous planets (CelestialBody::Planets::Gaseous::* )
│   │   ├── Moons
│   │   │   ├── LargeMoon, IceMoon, SmallMoon
│   │   │   └── Satellite hierarchy
│   │   ├── MinorBodies
│   │   │   ├── Asteroid, Comet, KuiperBeltObject, Protoplanet
│   │   │   └── AsteroidBeltGenerator [CONFIRMED]
│   │   └── DwarfPlanet, GasGiant, IceGiant, BrownDwarf
│   │       └── BrownDwarfHubManager [INFERRED - referenced in AI Manager docs]
│   └── Wormholes (app/models/wormhole.rb)
│       └── WormholeCoordinator [CONFIRMED]
└── Galaxy (container for multiple SolarSystems)
```

### Sphere Model (per CelestialBody)

```
CelestialBody
└── Spheres (CelestialBody::Spheres::*)
    ├── Atmosphere
    │   └── atmosphere_simulation_service.rb [CONFIRMED]
    ├── Hydrosphere
    │   └── hydrosphere_simulation_service.rb [CONFIRMED]
    ├── Geosphere
    │   └── geosphere_simulation_service.rb [CONFIRMED]
    ├── Biosphere
    │   └── biosphere_simulation_service.rb [CONFIRMED]
    └── Cryosphere
        └── (model exists, service unclear) [UNKNOWN]
```

**Note**: Spheres are namespaced under CelestialBody but operate as **independent simulation domains**. Each has its own:
- Model (`CelestialBody::Spheres::*`)
- Generator service (`app/services/star_sim/*_generator_service.rb`)
- Simulation service (`app/services/terra_sim/*_simulation_service.rb`)
- Interface services (e.g., `atmosphere_hydrosphere_interface_service.rb`)

---

## Data Flow Architecture

### World Generation Flow (StarSim)

```
[CONFIRMED] Star System JSON data (data/json-data/star_systems/)
    ↓
[CONFIRMED] StarSim::SystemBuilderService / SystemGeneratorService
    ↓
[CONFIRMED] Fidelity Tier Selection:
    ├── Tier 1: Static JSON (known systems like Sol)
    ├── Tier 2: Hybrid (static + procedural gap-filling, Local Bubble)
    └── Tier 3: Fully procedural (exotic systems beyond Local Bubble)
    ↓
[CONFIRMED] StarGenerator → PlanetBuilder → MoonGenerator → MinorBody generators
    ↓
[CONFIRMED] Sphere generation (atmosphere, hydrosphere, geosphere, biosphere)
    ↓
[CONFIRMED] Terrain generation (MultiBodyTerrainGenerator)
    ├── NASA GeoTIFF (ground truth for Sol bodies with real data)
    └── AI Manager procedural generation (for bodies without NASA data)
    ↓
[CONFIRMED] Resource deposit placement (procedural on survey)
    ↓
[CONFIRMED] Data stored in:
    ├── data/json-data/star_systems/*.json (system-level data)
    └── data/geotiff/processed/*.asc.gz (elevation data)
```

### Terraforming Flow (TerraSim)

```
[CONFIRMED] StarSim-generated terrain map (heightmap/elevation grid)
    ↓
[CONFIRMED] TerraSim::Simulator
    ├── AtmosphereSimulationService [CONFIRMED]
    ├── HydrosphereSimulationService [CONFIRMED]
    ├── GeosphereSimulationService [CONFIRMED]
    ├── BiosphereSimulationService [CONFIRMED]
    └── VolatilePhaseTransitionService [CONFIRMED]
    ↓
[CONFIRMED] Weathering/Regression logic (NOT fully implemented)
    ├── weathering_rate in Geosphere/Biosphere interfaces [CONFIRMED]
    └── state_distribution in HydrosphereSimulationService [CONFIRMED]
    ↓
[INFERRED] PlanetUpdateService applies seasonal/long-term changes [INFERRED]
    (ice ages, extreme weather)
    ↓
[CONFIRMED] Biome validation via BiomeValidator [CONFIRMED]
```

### Manufacturing Flow

```
[CONFIRMED] Raw materials (config/raw_materials/*.yml)
    ↓
[CONFIRMED] Processed materials (data/json-data/resources/materials/)
    ↓
[CONFIRMED] Components (data/json-data/blueprints/components/)
    ↓
[CONFIRMED] Blueprints (data/json-data/blueprints/ + data/json-data/templates/)
    ├── Template schemas (v1, v1.1, v1.2, etc.) [CONFIRMED]
    └── Instance blueprints [CONFIRMED]
    ↓
[CONFIRMED] Manufacturing::ProductionService
    ├── ComponentProductionService [CONFIRMED]
    ├── MaterialProcessingService [CONFIRMED]
    ├── RegolithProcessingService [CONFIRMED]
    └── ShellPrintingService [CONFIRMED]
    ↓
[CONFIRMED] Units::BaseUnit subclasses (Robot, Habitat, Extractor, Fabricator, etc.)
    ↓
[CONFIRMED] Craft::BaseCraft subclasses (Harvester, Rover, Ship, Spaceship)
```

### AI Manager Flow

```
[CONFIRMED] AIManager (master orchestrator) [CONFIRMED]
    ├── AIManager::ServiceOrchestrator [CONFIRMED]
    └── AIManager::SystemOrchestrator [CONFIRMED]
    ↓
[CONFIRMED] Core subsystems:
    ├── Expansion (ExpansionService, ExpansionDecisionService) [CONFIRMED]
    ├── Logistics (LogisticsCoordinator, ContractService) [CONFIRMED]
    ├── Economy (EconomicForecasterService, FinancialService) [CONFIRMED]
    ├── Pattern Learning (PatternLoader, PatternValidator) [CONFIRMED]
    ├── Mission Planning (LlmPlannerService, MissionScorer) [CONFIRMED]
    ├── Wormhole Management (WormholeCoordinator, WormholeManager) [CONFIRMED]
    └── Settlement (SettlementManager, SettlementPlanGenerator) [CONFIRMED]
    ↓
[CONFIRMED] Governance:
    ├── ConsortiumVotingEngine (66% quorum) [CONFIRMED]
    └── HammerProtocol (EM reset/snap control) [CONFIRMED]
    ↓
[CONFIRMED] Output:
    ├── Missions → AIManager::MissionPlannerService [CONFIRMED]
    ├── Contracts → PlayerContractService [CONFIRMED]
    └── Resource allocation → ResourceAllocator [CONFIRMED]
```

---

## Major Systems

### 1. Celestial Body System

**Status**: [CONFIRMED] — Fully implemented and documented

```
CelestialBody (abstract base)
├── Star
├── Planet (abstract)
│   ├── RockyPlanet
│   ├── OceanPlanet
│   └── GaseousPlanet
├── Moon (abstract)
│   ├── LargeMoon
│   ├── IceMoon
│   └── SmallMoon
├── Satellite
├── MinorBody (abstract)
│   ├── Asteroid
│   ├── Comet
│   ├── KuiperBeltObject
│   └── Protoplanet
├── DwarfPlanet
├── GasGiant
├── IceGiant
└── BrownDwarf
```

**Key attributes per body**:
- Diameter, gravity, temperature range [CONFIRMED]
- Spheres (atmosphere, hydrosphere, geosphere, biosphere) [CONFIRMED]
- Features (craters, lava tubes, skylights, canyons, valleys, caves) [CONFIRMED]
- Resource deposits (procedural on survey) [CONFIRMED]
- Terrain map (elevation grid) [CONFIRMED]
- Stored volatiles (chemical classification, not physical state) [CONFIRMED]

### 2. Settlement System

**Status**: [CONFIRMED] — Implemented with dual namespace ambiguity

```
Settlement::BaseSettlement (administrative container)
├── Structures::BaseStructure (physical assets, has_many :structures)
│   ├── Worldhouse (lava tube enclosure)
│   ├── CraterDome
│   ├── HabitationFacility
│   ├── Hangar
│   ├── ManufacturingFacility
│   ├── OrbitalStructure
│   ├── PowerStation
│   ├── SolarArray
│   ├── Skylight
│   ├── StorageFacility
│   ├── AccessPoint
│   └── ConvertedBase
├── Units::BaseUnit (deployable entities, has_many :units)
│   ├── Robot, Habitat, Extractor, Fabricator, Processor
│   ├── Battery, Computer, LifeSupport, Propulsion, Storage
│   └── PlanetaryUmbilicalHub
└── Settlement types:
    ├── OrbitalDepot (dual namespace: app/models/orbital_depot.rb AND app/models/settlement/orbital_depot.rb) [CONFLICT]
    ├── OrbitalSettlement
    └── SpaceStation
```

### 3. Economy System

**Status**: [CONFIRMED] — Core infrastructure implemented; specific pricing models may be outdated

```
Financial System:
├── Financial::Account (polymorphic, per-currency) [CONFIRMED]
├── Financial::Currency (GCC, USD) [CONFIRMED]
├── Financial::ExchangeRate [CONFIRMED]
├── Financial::LedgerEntry / LedgerManager [CONFIRMED]
└── Financial::Bond / BondRepayment [CONFIRMED]

Market System:
├── Market::Marketplace [CONFIRMED]
├── Market::NPCPriceCalculator [CONFIRMED]
├── Market::Order [CONFIRMED]
├── Market::PriceHistory [CONFIRMED]
└── Market::SupplyChain / Trade [CONFIRMED]

Logistics System:
├── Logistics::ContractService [CONFIRMED]
├── Logistics::ManifestGenerator [CONFIRMED]
├── Logistics::RouteCostCalculator [CONFIRMED]
└── Logistics::ShippingCalculator [CONFIRMED]

Organization System:
├── Organizations::BaseOrganization [CONFIRMED]
├── Organizations::Corporation [CONFIRMED]
├── Organizations::DevelopmentCorporation (NPC) [CONFIRMED]
├── Organizations::InsuranceCorporation [CONFIRMED]
└── Organizations::TaxAuthority [CONFIRMED]

Currency Exchange:
├── Phase 1: Hard peg (1 GCC = 1 USD) [CONFIRMED in docs]
├── Phase 2: Soft peg (±10%) [CONFIRMED in docs]
├── Phase 3: Managed float [CONFIRMED in docs]
└── Phase 4: Uncoupled [CONFIRMED in docs]
```

### 4. AI Manager System

**Status**: [INFERRED] — Code exists (80+ services) but documented architecture (8 core files) is outdated

```
AIManager (master orchestrator)
├── ServiceOrchestrator [CONFIRMED]
├── SystemOrchestrator [CONFIRMED]
├── StateAnalyzer [CONFIRMED]
├── StrategicEvaluator [CONFIRMED]
├── StrategySelector [CONFIRMED]
├── PriorityArbitrator / PriorityHeuristic [CONFIRMED]
├── PatternLoader / PatternValidator [CONFIRMED]
├── MissionPlannerService [CONFIRMED]
├── MissionScorer [CONFIRMED]
├── LlmPlannerService [CONFIRMED]
├── TaskExecutionEngine / TaskExecutionEngineV2 [CONFIRMED]
├── EconomicForecasterService [CONFIRMED]
├── FinancialService [CONFIRMED]
├── LogisticsCoordinator [CONFIRMED]
├── SettlementManager [CONFIRMED]
├── TerraformingManager [CONFIRMED]
├── WormholeCoordinator (BFS wayfinding) [CONFIRMED]
├── WormholeManager [CONFIRMED]
├── WormholePlacementService [CONFIRMED]
├── WormholeScoutingService [CONFIRMED]
├── ExpansionService / ExpansionDecisionService [CONFIRMED]
├── ConsortiumManager [CONFIRMED]
├── HammerProtocol [CONFIRMED]
├── EMHarvestingService [CONFIRMED]
├── SystemArchitect [CONFIRMED]
├── SystemIntelligenceService [CONFIRMED]
├── SystemDiscoveryService [CONFIRMED]
├── NetworkOptimizer [CONFIRMED]
├── ResourceAllocator / ResourceAcquisitionService [CONFIRMED]
├── ResourceFlowSimulator [CONFIRMED]
├── ResourceFulfillmentService [CONFIRMED]
├── ResourcePlanner [CONFIRMED]
├── ResourcePositioningService [CONFIRMED]
├── ProductionManager [CONFIRMED]
├── IsruEvaluator / IsruOptimizer [CONFIRMED]
├── ScoutLogic [CONFIRMED]
├── ProbeDeploymentService [CONFIRMED]
├── SurfaceSuitabilityAnalyzer [CONFIRMED]
├── PlanetaryMapGenerator [CONFIRMED]
├── EarthMapGenerator [CONFIRMED]
├── StationConstructionStrategy [CONFIRMED]
├── StationPlacementService [CONFIRMED]
├── StationCostBenefitAnalyzer [CONFIRMED]
├── ConstructionService [CONFIRMED]
├── ContractCreationService [CONFIRMED]
├── ProcurementService [CONFIRMED]
├── MarketStabilizationService [CONFIRMED]
├── TransitFeeService [CONFIRMED]
├── UniversalDockingService [CONFIRMED]
├── SkimmerCyclerHandshakeService [CONFIRMED]
├── ColonyManager [CONFIRMED]
├── EmergencyMissionService [CONFIRMED]
├── EscalationService [CONFIRMED]
├── PerformanceTracker [CONFIRMED]
├── SimEvaluator [CONFIRMED]
├── DecisionTree [CONFIRMED]
├── CorporateRoles [CONFIRMED]
├── DepotsAdapter [CONFIRMED]
├── ManifestParser [CONFIRMED]
├── PrecursorCapabilityService [CONFIRMED]
├── PrecursorLearningService [CONFIRMED]
├── MultiWormholeEventHandler [CONFIRMED]
└── TestScenarioExtractor [CONFIRMED]
```

### 5. Rendering System

**Status**: [CONFIRMED] — Implementation exists; documentation partially outdated

```
Rendering Pipeline:
├── Generation Layer (pure elevation data)
│   └── Terrain::MultiBodyTerrainGenerator [CONFIRMED]
├── Rendering Layer (visualization)
│   ├── app/javascript/system_renderer.js [CONFIRMED]
│   ├── app/javascript/planet_detail.js [CONFIRMED]
│   ├── app/javascript/game_interface.js [CONFIRMED]
│   └── app/javascript/ui_manager.js [CONFIRMED]
├── Tileset System
│   ├── Tileset::AlioTilesetService [CONFIRMED]
│   ├── Tileset::FreeCivTilesetService [CONFIRMED]
│   └── data/galaxy_game_tileset.json [CONFIRMED]
├── Asset Pipeline
│   ├── app/assets/images/settlement_sprites.png [CONFIRMED]
│   ├── app/assets/data/settlement_tileset.json [CONFIRMED]
│   └── app/assets/data/galaxy_regional_atlas.json [CONFIRMED]
└── Data Storage
    └── geosphere.terrain_map (elevation grid 0.0-1.0) [CONFIRMED]
```

### 6. Technology Tree System

**Status**: [CONFIRMED] — 19 categories defined in JSON; relationship to TL/MK is OPEN QUESTION

```
Technology Tree (data/json-data/tech_tree/):
├── biotechnology.json [CONFIRMED]
├── computing_ai.json [CONFIRMED]
├── construction_manufacturing.json [CONFIRMED]
├── diplomatic_trade.json [CONFIRMED]
├── exploration_science.json [CONFIRMED]
├── life_support.json [CONFIRMED]
├── materials_science.json [CONFIRMED]
├── mining_resource_processing.json [CONFIRMED]
├── particle_physics.json [CONFIRMED]
├── planetary_engineering.json [CONFIRMED]
├── power_generation.json [CONFIRMED]
├── propulsion_systems_v1.json [CONFIRMED]
├── research_system.json [CONFIRMED]
├── robotics.json [CONFIRMED]
├── sensor_instrumentation.json [CONFIRMED]
├── social_governance.json [CONFIRMED]
├── space_construction.json [CONFIRMED]
├── technology_tree_master_v1.json [CONFIRMED]
└── xenoarchaeology.json [CONFIRMED]

Technology Level (TL 1-4+): [INFERRED - documented but not clearly implemented]
├── TL1: Early settlement (regolith_3d_printing)
├── TL2: Intermediate (advanced_regolith_3d_printing)
├── TL3: Advanced (autonomous_regolith_3d_printing)
└── TL4+: [INFERRED - not documented]

MK Designation (per-blueprint): [CONFIRMED]
├── Mk1: Entry-level, day-one deployment
├── Mk2: Improved throughput, requires Mk1 as component
└── Mk3: Autonomous, advanced composites
```

---

## Ownership Boundaries

### Clear Boundaries (CONFIRMED)

| System | Owner | Boundary |
|--------|-------|----------|
| World Generation | StarSim services | Generates celestial bodies, terrain, resource deposits |
| Planetary Simulation | TerraSim services | Simulates sphere evolution, terraforming effects |
| AI Decision-Making | AIManager services | Makes all autonomous decisions, plans missions |
| Economy | Financial/Market/Logistics services | Manages pricing, trade, contracts, currency exchange |
| Manufacturing | Manufacturing services + Blueprint model | Produces units, craft, components from blueprints |
| Settlement Management | Settlement models + AIManager::SettlementManager | Administers structures, units, life support |
| Wormhole Network | AIManager::WormholeCoordinator + Wormhole model | Manages interstellar graph, BFS wayfinding |
| Rendering | JavaScript services + Tileset services | Visualizes terrain, settlements, UI |
| Data Storage | JSON files + PostgreSQL schema | Blueprints, operational data, star system data |

### Unclear Boundaries (INFERRED/UNKNOWN)

| Boundary | Issue | Confidence |
|----------|-------|------------|
| StarSim ↔ TerraSim interface | How does generated terrain flow into simulation? | MEDIUM |
| AI Manager ↔ Economy | Does AI Manager set prices or just respond to them? | LOW |
| Settlement ↔ Structure ownership | Who creates/destroys structures? | MEDIUM |
| Blueprint model ↔ JSON templates | How do runtime blueprints relate to template schemas? | LOW |
| Colony model ↔ Settlement model | Are they the same concept with different names? | LOW |
| OrbitalDepot dual namespace | Root vs settlement namespace — which is authoritative? | LOW |

---

## Current Implementation Patterns

### Pattern 1: JSON-Driven Architecture [CONFIRMED]

**Evidence**: `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md` states "JSON describes what is estimated to exist. The game engine determines state and emergent interactions."

**Implementation**:
- Blueprints define structure/capabilities (JSON)
- Operational data defines runtime state (JSON)
- Models read JSON at startup/runtime via lookup services
- Service logic never hardcodes physical state assumptions

### Pattern 2: Namespace-Hierarchical Models [CONFIRMED]

**Evidence**: All model files follow Rails namespace conventions.

**Implementation**:
- `CelestialBody::Spheres::Atmosphere` — nested under celestial body
- `Structures::BaseStructure` → `Structures::Worldhouse` — structure hierarchy
- `Units::BaseUnit` → `Units::Robot` — unit hierarchy
- `Financial::Account` — financial system models
- `Market::*` — market system models

### Pattern 3: Service-Oriented Architecture [CONFIRMED]

**Evidence**: 100+ service files in `app/services/`, organized by domain.

**Implementation**:
- Single-responsibility services (e.g., `AtmosphereGeneratorService`)
- Manager services for coordination (e.g., `AIManager::Manager`)
- Engine services for core loops (e.g., `TaskExecutionEngine`)
- Lookup services for data access (14 services in `app/services/lookup/`)

### Pattern 4: Fidelity Tiers [CONFIRMED]

**Evidence**: `docs/architecture/starsim/OVERVIEW.md` describes three tiers.

**Implementation**:
- Tier 1: Static JSON for known systems (Sol)
- Tier 2: Hybrid static + procedural for Local Bubble
- Tier 3: Fully procedural for exotic systems

### Pattern 5: Player-First Priority [CONFIRMED]

**Evidence**: `docs/architecture/economy/CONTRACTS.md` describes player-first contract posting.

**Implementation**:
- AI Manager posts contracts to market first
- 24-48 hour player acceptance window
- Timeout fallback to NPC queue
- Player rewards at 1.5x vs NPC execution value

### Pattern 6: Dual Currency with Phased Exchange [CONFIRMED in docs, INFERRED in code]

**Evidence**: `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` describes 4 phases. Code has `Financial::Currency`, `Financial::ExchangeRate`, `Financial::ExchangeRateService`.

**Implementation**:
- GCC (space-side) and USD (Earth-side)
- Bootstrap phase: 1:1 hard peg
- Evolves through soft peg → managed float → uncoupled
- Exchange rate affects EAP (Earth Anchor Price) calculations

---

## Architecture Gaps (UNKNOWN — Needs Review)

| Gap | Description | Where to Investigate |
|-----|-------------|---------------------|
| StarSim ↔ TerraSim handoff | How terrain data flows from generation to simulation | `app/services/star_sim/` → `app/services/terra_sim/` interface |
| Colony vs Settlement | Whether these are the same concept or distinct | `app/models/colony.rb` vs `app/models/settlement/base_settlement.rb` |
| Digital Twin purpose | Referenced in docs and service but unclear integration | `app/services/digital_twin_service.rb`, `docs/developer/DIGITAL_TWIN_SANDBOX.md` |
| Precursor mission scope | Appears in multiple docs with different scopes | `data/json-data/precursor_mission_setup_methane.json`, `docs/architecture/stations/precursor_mission_bootstrap_architecture.md` |
| EM (Energy-Matter) physics | Referenced but definition unclear | `app/services/em_harvesting_service.rb`, `docs/architecture/systems/em_power_shield_tiers.md` |
| Simulation Sandbox purpose | Moved from root, purpose unclear | `docs/architecture/simulation/SIMULATION_SANDBOX.md` |
| TL-to-MK relationship | Explicitly open question in Art Bible docs | `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` |
| Quest vs Mission | "Quest" appears in mission data but unclear if distinct | `data/json-data/missions/quests/` directory |
| Resource vs Material | Used interchangeably in some places | `data/json-data/resources/materials/`, `app/models/material_request.rb` |
| Biome model duality | `Biome` vs `PlanetBiome` — relationship unclear | `app/models/biome.rb` vs `app/models/planet_biome.rb` |

---

## Architecture Summary

Galaxy Game is a **Rails 7.0 application** with:
- **~100 model files** defining celestial bodies, settlements, structures, units, craft, financial systems, market systems, logistics, and organizations
- **~100 service files** implementing world generation (StarSim), planetary simulation (TerraSim), AI decision-making, economy, manufacturing, logistics, rendering, and lookup
- **70+ JSON template files** defining blueprints, operational data, and technology trees
- **30+ star system JSON files** including Sol-complete data
- **19 technology categories** in the tech tree
- **Dual-currency economy** (GCC/USD) with phased exchange evolution
- **Three-tier world generation** (static → hybrid → procedural)
- **JSON-driven architecture** where data defines structure and code determines state

The architecture is **largely confirmed by code** but has several areas requiring human review: namespace ambiguities, dual-model patterns, and unresolved design decisions (particularly the Technology Level vs MK Generation relationship).
