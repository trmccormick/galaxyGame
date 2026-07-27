# AI Manager Architecture

> **Last Updated**: 2026-07-26
> **Total Services**: 121 (93 ai_manager + 31 manufacturing + 1 terraforming import — 7 noise files excluded)
> **Related Services**: 31 manufacturing services + 1 imported terraforming service
> **Service Inventory**: [Full inventory with descriptions](../../new_agent/projects/galaxy_game/services/ai_manager_service_inventory.md)
> **Contributor Guide**: [Adding a new AI Manager service](../../new_agent/projects/galaxy_game/contributors/adding-ai-manager-service.md)

## Overview

The AI Manager is the largest subsystem in galaxy_game, containing **121 Ruby files** across multiple directories: `app/services/ai_manager/` (93 files), `app/services/manufacturing/` (31 files including subdirectories), and `app/services/import/terrain_terraforming_service.rb` (1 file). It is responsible for autonomous decision-making across the game world: settlement management, mission planning, expansion, terraforming, wormhole infrastructure, market stabilization, and resource logistics.

This document provides the architectural overview. For a complete service-by-service inventory with responsibilities, key methods, and MVP phase classification, see [AI Manager Service Inventory](../../new_agent/projects/galaxy_game/services/ai_manager_service_inventory.md).

## Architecture Files vs Reality

⚠️ **This document previously referenced 8 "core files" that no longer exist in the codebase.** The architecture has evolved significantly. The current reality:

| Old Reference (Stale) | Current Status |
|---|---|
| `wormhole_coordinator.rb` | ❌ Does not exist. Functionality lives in `WormholeManager`, `NetworkOptimizer`, `MultiWormholeEventHandler` |
| `consortium_voting_engine.rb` | ❌ Does not exist. Functionality lives in `ConsortiumManager` |
| `hammer_protocol_service.rb` | ❌ Does not exist. Protocol logic lives in `HammerProtocol` class |
| `brown_dwarf_hub_manager.rb` | ❌ Does not exist. No equivalent service |
| `em_harvesting_service.rb` | ❌ Does not exist. EM harvesting integrated into `WormholeManager.harvest_em_bloom` |
| `expansion_assessment.rb` | ❌ Does not exist. Functionality lives in `ExpansionService`, `SystemDiscoveryService`, `ProbeDeploymentService` |
| **8 core files** | ✅ **93 actual files** (see [service inventory](../../new_agent/projects/galaxy_game/services/ai_manager_service_inventory.md)) |

## Core Services (MVP-relevant)

The following services form the MVP-relevant core of the AI Manager:

### Decision Orchestration

| Service | Responsibility |
|---|---|
| **OperationalManager** | Main decision loop for settlements; orchestrates all other AI services |
| **SettlementManager** | Settlement strategy selection and resource coordination |
| **ColonyManager** | NPC colony management + player colony auto-management |

### Mission & Expansion

| Service | Responsibility |
|---|---|
| **MissionPlannerService** | Mission simulation, timeline, cost calculation, sourcing strategy |
| **ExpansionService** | Multi-phase expansion with probe deployment and wormhole coordination |
| **ExpansionDecisionService** | Expansion decision logic |

### Economy & Market

| Service | Responsibility |
|---|---|
| **EconomicForecasterService** | Resource demand forecasting and scenario comparison |
| **MarketStabilizationService** | NPC buyer/producer/importer of last resort for market liquidity |
| **FinancialService** | Financial calculations for settlements |
| **ConsortiumManager** | Wormhole network health, orphaned system handling |

### Construction & Production

| Service | Responsibility |
|---|---|
| **ConstructionService** | Facility building with resource validation |
| **ProductionManager** | Resource management for construction plans |
| **ProcurementService** | Local production vs market purchase decisions |
| **ResourceAcquisitionService** | Low-level resource ordering (local vs external) |
| **ResourceFulfillmentService** | Supply need fulfillment via MaterialRequestService |

### Terraforming

| Service | Responsibility |
|---|---|
| **TerraformingManager** | Planetary terraforming phase determination and gas calculations |
| **AtmosphericExtractionService** | Skimmer-based atmospheric extraction with raw transfer mode |
| **AtmosphericHarvesterService** | Harvester-specific atmospheric processing |

### Escalation & Emergency Response

| Service | Responsibility |
|---|---|
| **EscalationService** | Resource shortage handling, expired order escalation |
| **EmergencyMissionService** | Emergency mission creation and execution |

## Subsystem Organization

Despite the flat file structure, services cluster into these conceptual subdomains:

```
AI Manager (89 files)
├── Core Decision-Making (7 services)
│   ├── OperationalManager — Main decision loop
│   ├── SettlementManager — Strategy selection
│   └── ColonyManager — Colony management
├── Mission & Expansion (3 services)
│   ├── MissionPlannerService — Mission simulation
│   ├── ExpansionService — Multi-phase expansion
│   └── ExpansionDecisionService — Decision logic
├── Economy & Market (4 services)
│   ├── EconomicForecasterService — Demand forecasting
│   ├── MarketStabilizationService — Market liquidity
│   ├── FinancialService — Financial calculations
│   └── ConsortiumManager — Network health
├── Construction & Production (5 services)
│   ├── ConstructionService — Facility building
│   ├── ProductionManager — Resource management
│   ├── ProcurementService — Procurement decisions
│   ├── ResourceAcquisitionService — Resource ordering
│   └── ResourceFulfillmentService — Supply fulfillment
├── Terraforming Pipeline (3 services)
│   ├── TerraformingManager — Phase determination
│   ├── AtmosphericExtractionService — Skimmer extraction
│   └── AtmosphericHarvesterService — Harvester processing
├── Wormhole Infrastructure (6 services)
│   ├── WormholeManager — Mass monitoring, shift discharge
│   ├── WormholePlacementService — Lagrange point placement
│   ├── WormholeScoutingService — Scouting evaluation
│   ├── TransitFeeService — Fee collection
│   ├── UniversalDockingService — Docking protocol
│   └── SkimmerCyclerHandshakeService — Cargo transfer
├── Probe & Exploration (3 services)
│   ├── ProbeDeploymentService — Scout deployment
│   ├── SystemDiscoveryService — System discovery
│   └── SystemIntelligenceService — Status reporting
├── Pattern Learning & Knowledge (7 services)
│   ├── PrecursorCapabilityService — Capability assessment
│   ├── PrecursorLearningService — Pattern application
│   ├── WorldKnowledgeService — ISRU catalog
│   ├── PatternValidationService / PatternValidator — Validation
│   ├── PatternLoader — Pattern loading
│   └── PatternTargetMapper — Target mapping
├── Decision Support & Analytics (6 services)
│   ├── PriorityArbitrator — Priority resolution
│   ├── PerformanceTracker — Performance tracking
│   ├── ISREvaluator / ISROptimizer — ISRU analysis
│   ├── LogisticsCoordinator — Logistics coordination
│   ├── NetworkOptimizer — Network optimization
│   └── MultiWormholeEventHandler — Event handling
├── Map Generation (3 services)
│   ├── PlanetaryMapGenerator — Map generation
│   ├── EarthMapGenerator — Earth-specific maps
│   └── ResourcePositioningService — Resource placement
├── Bootstrap & Planning (3 services)
│   ├── BootstrapResourceAllocator — Bootstrap requirements
│   ├── LLMPlannerService — LLM planning
│   └── EMMissionCoordinatorService — EM coordination
└── Supporting Utilities (16 files)
    ├── ai_priority_system.rb, builder.rb, construction.rb
    ├── corporate_roles.rb, decision_tree.rb, errors.rb
    ├── hammer_protocol.rb, priority_heuristic.rb
    ├── scout_logic.rb, resource_planner.rb
    ├── settlement_plan_generator.rb, sim_evaluator.rb
    ├── system_architect.rb
    ├── task_execution_engine.rb / v2
    └── test_scenario_extractor.rb, depot_adapter.rb, manifest_parser.rb
```

## Service Dependency Graph

```
OperationalManager (main decision loop)
├── AiPrioritySystem (priority weighting)
├── WorldKnowledgeService (ISRU knowledge)
├── PerformanceTracker (adaptation recommendations)
├── MarketStabilizationService (market health)
├── EscalationService (resource shortages)
├── ExpansionService (expansion decisions)
├── FinancialService (financial checks)
└── EmergencyMissionService (emergency response)

ExpansionService
├── ProbeDeploymentService (intelligence gathering)
├── BootstrapResourceAllocator (resource requirements)
├── WormholeCoordinator (network coordination)
└── SettlementPlanGenerator (plan generation)

MissionPlannerService
├── PrecursorCapabilityService (local resource availability)
├── PatternTargetMapper (target location resolution)
├── EconomicForecasterService (cost analysis)
└── MaterialLookupService (material pricing)

TerraformingManager
├── PatternLoader (terraforming patterns)
├── AtmosphericExtractionService (gas calculations)
└── ResourcePositioningService (resource placement)

WormholeManager
├── StationPlacementService (AWS placement)
├── TransitFeeService (fee collection)
└── ConsortiumManager (network health)

SkimmerCyclerHandshakeService
├── AtmosphericExtractionService (extraction execution)
└── UniversalDockingService (docking protocol)

ProductionManager
├── ResourceAcquisitionService (resource ordering)
├── ConstructionService (facility building)
└── ProcurementService (procurement decisions)

ResourceFulfillmentService
└── MaterialRequestService (market procurement)
```

## Entry Point: `ai_manager.rb`

The file `app/services/ai_manager.rb` acts as a **require-bundler** for core services. It loads ~35 files that are needed by the main decision loop. Services not loaded here are loaded on-demand via direct `require_relative`.

```ruby
# app/services/ai_manager.rb (excerpt)
module AIManager
  require_relative 'ai_manager/errors'
  require_relative 'ai_manager/operational_manager'
  require_relative 'ai_manager/terraforming_manager'
  require_relative 'ai_manager/mission_planner_service'
  # ... ~35 more requires
end
```

## Integration with Related Domains

AI Manager services interact with several adjacent namespaces:

| Domain | Namespace | Services | Relationship |
|---|---|---|---|
| Manufacturing | `app/services/manufacturing/` | 14 services | AI Manager triggers production; manufacturing executes ISRU |
| Construction | `app/services/manufacturing/construction/` | 9 services | AI Manager plans; construction builds |
| Terraforming (imported) | `app/services/import/` | 1 service | Imported terraforming logic |

## Operational Constraints (from GUARDRAILS.md §5: Operational Boundaries)

- **Autonomous Overrides:** The AI Manager may ignore Alpha Centauri in favor of local Milky Way wormholes if the `SimEvaluator` predicts a higher ROI or faster stability rating.
- **Verification:** All autonomous construction phases must be logged via the `PerformanceTracker` to ensure they meet the 85% success rate requirement.

## Namespace Preservation Rules

- **Namespace Preservation:** Models must reside in directories matching their Ruby namespace (e.g., `Location::SpatialLocation` belongs in `app/models/location/`).
- **Nesting Mandate:** Do not flatten directory structures during recovery. If a class is namespaced in `ApplicationRecord`, the spec must reflect that namespace (e.g., use `Location::SpatialLocation.new`, not `SpatialLocation.new`).

## Service Namespace Integrity

- All service classes (AIManager, Ceres, Mars, etc.) must use nested module definitions:
  ```ruby
  module AIManager
    module Testing
      class PerformanceMonitor
        # ...
      end
    end
  end
  ```
- Do **not** use `module AIManager::Testing` for service classes. Zeitwerk may not resolve the parent module if not already loaded, causing `NameError`.
- Ensure there is no file named `app/services/ai_manager/testing.rb` that conflicts with the `app/services/ai_manager/testing/` directory. If a namespace file is needed, it should only define the module and not contain logic or requires.
- All specs for namespaced services must require `rails_helper` and never use `require_relative` for app/services code.
- After any namespace or structure change, run `bin/rails zeitwerk:check` and the relevant RSpec suite.

## Manager/Service Placement Rule [2026-01-15]

- All 'Manager' and 'Service' classes must reside in `app/services/` and never in `app/models/` unless they are backed by a database table (i.e., inherit from `ApplicationRecord`).
- This ensures Zeitwerk autoloading and logical separation of concerns.

## Sol Training Data (from GUARDRAILS.md §9: Sol as AI Training Data)

**Core Design Philosophy:** The Sol system serves as the primary training dataset for AI Manager autonomous decision-making in new system development. All patterns, economic dynamics, and infrastructure decisions learned from Sol must be applied to maintain consistent expansion quality and player-first economics.

### Training Data Structure
- **Mission Profiles:** JSON mission files (`l1_tug_construction_profile_v1.json`, cycler logistics manifests) provide pattern recognition templates for procurement, sequencing, and quality assurance workflows.
- **Economic Patterns:** Player-first with NPC fallback dynamics, market-based pricing, and infrastructure rental systems establish baseline ROI expectations and participation incentives.
- **Infrastructure Templates:** Orbital shipyards, cycler platforms, and development corporation foundations serve as architectural blueprints for new system deployment.

### AI Manager Learning Objectives
- **Pattern Matching:** Analyze Sol mission success rates, economic participation levels, and infrastructure ROI to identify optimal deployment strategies for new systems.
- **Adaptive Decision-Making:** When building new systems, AI Manager must evaluate local conditions against Sol-trained patterns, adapting cycler logistics, market dynamics, and construction sequencing accordingly.
- **Player Integration:** Maintain player-first economics by creating competitive opportunities in new systems, using Sol data to predict participation levels and adjust NPC fallback timing.

### Implementation Requirements
- **JSON Mission Refinement:** All Sol mission files must be structured for AI pattern recognition, including success criteria, ROI estimates, and adaptive parameters.
- **Economic Continuity:** New systems must replicate Sol's market dynamics, ensuring players can profit from infrastructure contributions and logistics operations.
- **Autonomous Expansion:** AI Manager uses Sol training data to make independent decisions about wormhole stability, resource prioritization, and development sequencing without requiring human intervention.

### Validation Metrics
- **Pattern Accuracy:** AI Manager decisions in new systems must achieve 85% success rate compared to Sol baseline performance.
- **Economic Alignment:** Player participation rates and GCC earnings in new systems should match or exceed Sol system averages.
- **Infrastructure Quality:** New system deployments must meet Sol-established standards for stability, resource availability, and expansion potential.

## Resource Allocation Engine Integration (from GUARDRAILS.md §Resource Allocation)

- All bootstrap settlement logic must use AIManager::ResourceAllocator to calculate initial supply packages (energy, water, food, construction).
- ISRU priorities (oxygen, water, metals) must be ranked and documented per engine requirements.
- ResourceAllocator interacts with ColonyManager's trade logic for supply and extraction planning.
- All integration must be validated by spec and documented in the workflow.

## Adding New Services

See [Adding an AI Manager Service](../../new_agent/projects/galaxy_game/contributors/adding-ai-manager-service.md) for:
- Naming conventions
- Module inclusions
- Wiring up services (require-bundler vs direct require)
- Test placement conventions
- Documentation requirements
- Common pitfalls

---

*This architecture is the foundation for all AI Manager logic, expansion, and governance. All code and documentation must align with this orchestration.*

## Operational Constraints (from GUARDRAILS.md §5: Operational Boundaries)
- **Autonomous Overrides:** The AI Manager may ignore Alpha Centauri in favor of local Milky Way wormholes if the `SimEvaluator` predicts a higher ROI or faster stability rating.
- **Verification:** All autonomous construction phases must be logged via the `PerformanceTracker` to ensure they meet the 85% success rate requirement.

## Namespace Preservation Rules
- **Namespace Preservation:** Models must reside in directories matching their Ruby namespace (e.g., `Location::SpatialLocation` belongs in `app/models/location/`).
- **Nesting Mandate:** Do not flatten directory structures during recovery. If a class is namespaced in `ApplicationRecord`, the spec must reflect that namespace (e.g., use `Location::SpatialLocation.new`, not `SpatialLocation.new`).

## Service Namespace Integrity
- All service classes (AIManager, Ceres, Mars, etc.) must use nested module definitions:
  ```ruby
  module AIManager
    module Testing
      class PerformanceMonitor
        # ...
      end
    end
  end
  ```
- Do **not** use `module AIManager::Testing` for service classes. Zeitwerk may not resolve the parent module if not already loaded, causing `NameError`.
- Ensure there is no file named `app/services/ai_manager/testing.rb` that conflicts with the `app/services/ai_manager/testing/` directory. If a namespace file is needed, it should only define the module and not contain logic or requires.
- All specs for namespaced services must require `rails_helper` and never use `require_relative` for app/services code.
- After any namespace or structure change, run `bin/rails zeitwerk:check` and the relevant RSpec suite.

## Manager/Service Placement Rule [2026-01-15]
- All 'Manager' and 'Service' classes must reside in `app/services/` and never in `app/models/` unless they are backed by a database table (i.e., inherit from `ApplicationRecord`).
- This ensures Zeitwerk autoloading and logical separation of concerns.

## Sol Training Data (from GUARDRAILS.md §9: Sol as AI Training Data)
**Core Design Philosophy:** The Sol system serves as the primary training dataset for AI Manager autonomous decision-making in new system development. All patterns, economic dynamics, and infrastructure decisions learned from Sol must be applied to maintain consistent expansion quality and player-first economics.

### Training Data Structure
- **Mission Profiles:** JSON mission files (`l1_tug_construction_profile_v1.json`, cycler logistics manifests) provide pattern recognition templates for procurement, sequencing, and quality assurance workflows.
- **Economic Patterns:** Player-first with NPC fallback dynamics, market-based pricing, and infrastructure rental systems establish baseline ROI expectations and participation incentives.
- **Infrastructure Templates:** Orbital shipyards, cycler platforms, and development corporation foundations serve as architectural blueprints for new system deployment.

### AI Manager Learning Objectives
- **Pattern Matching:** Analyze Sol mission success rates, economic participation levels, and infrastructure ROI to identify optimal deployment strategies for new systems.
- **Adaptive Decision-Making:** When building new systems, AI Manager must evaluate local conditions against Sol-trained patterns, adapting cycler logistics, market dynamics, and construction sequencing accordingly.
- **Player Integration:** Maintain player-first economics by creating competitive opportunities in new systems, using Sol data to predict participation levels and adjust NPC fallback timing.

### Implementation Requirements
- **JSON Mission Refinement:** All Sol mission files must be structured for AI pattern recognition, including success criteria, ROI estimates, and adaptive parameters.
- **Economic Continuity:** New systems must replicate Sol's market dynamics, ensuring players can profit from infrastructure contributions and logistics operations.
- **Autonomous Expansion:** AI Manager uses Sol training data to make independent decisions about wormhole stability, resource prioritization, and development sequencing without requiring human intervention.

### Validation Metrics
- **Pattern Accuracy:** AI Manager decisions in new systems must achieve 85% success rate compared to Sol baseline performance.
- **Economic Alignment:** Player participation rates and GCC earnings in new systems should match or exceed Sol system averages.
- **Infrastructure Quality:** New system deployments must meet Sol-established standards for stability, resource availability, and expansion potential.

## Resource Allocation Engine Integration (from GUARDRAILS.md §Resource Allocation)
- All bootstrap settlement logic must use AIManager::ResourceAllocator to calculate initial supply packages (energy, water, food, construction).
- ISRU priorities (oxygen, water, metals) must be ranked and documented per engine requirements.
- ResourceAllocator interacts with ColonyManager's trade logic for supply and extraction planning.
- All integration must be validated by spec and documented in the workflow.

*This architecture is the foundation for all AI Manager logic, expansion, and governance. All code and documentation must align with this orchestration.*
