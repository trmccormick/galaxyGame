# Phase 3 Missing Documentation Report

**Created**: 2026-07-16  
**Purpose**: Identify systems that exist in code but lack documentation, prioritized by development phase relevance.  
**Method**: Cross-reference `app/services/`, `app/models/`, and `app/models/concerns/` against docs/ to find undocumented systems.

---

## Priority System

| Priority | Meaning | Timeline |
|----------|---------|----------|
| **P1 — Critical** | Core gameplay system with zero documentation | Document immediately |
| **P2 — Important** | Implemented system with minimal or no docs | Document within 2-3 sessions |
| **P3 — Moderate** | Partial documentation exists but is incomplete | Update incrementally |
| **P4 — Low** | Niche system, low contributor impact | Document as time permits |

---

## P1 — Critical: Core Systems with No Documentation

### 1. AI Manager Services Inventory (80+ services)
- **Code**: `app/services/ai_manager/` — 80+ service files
- **Docs**: Only 8 core files documented in architecture doc
- **Gap**: 72+ undocumented services including:
  - `colony_manager.rb` — AI decision scope for colony management
  - `system_intelligence_service.rb` — Scope and integration with SystemArchitect
  - `resource_flow_simulator.rb` — Scale of simulation (per-settlement vs per-system)
  - `economic_forecaster_service.rb` — Forecasting horizon and accuracy
  - `task_execution_engine_v2.rb` — v1 vs v2 distinction, migration status
  - `precursor_learning_service.rb` — Scope, timeline, learning methodology
  - `station_cost_benefit_analyzer.rb` — Metrics, thresholds, decision criteria
- **Canonical intent alignment**: #8 (AI Manager expected to grow)
- **Development phase**: Phase 4+ (but needed for Phase 1 AI-driven expansion)

### 2. Settlement Namespace Services
- **Code**: `app/services/settlement/` — settlement-specific services
- **Docs**: No dedicated documentation for settlement service layer
- **Gap**: How settlements interact with AI Manager, economy, and construction
- **Development phase**: Phase 1 (lunar settlement bootstrap)

### 3. Construction Job Progress Tracking
- **Code**: `app/models/construction_job.rb` + related services
- **Docs**: `docs/architecture/systems/job_system_mechanics_spec.md` exists but code alignment unclear
- **Gap**: Surface construction pause/resume capability, job state machine
- **Development phase**: Phase 1 (construction)

---

## P2 — Important: Implemented Systems with Minimal Documentation

### 4. Transport Cost Service
- **Code**: `app/services/logistics/transport_cost_service.rb`
- **Docs**: None found
- **Gap**: EM physics integration for transport costs, distance calculation methodology
- **Canonical intent alignment**: #11 (time and distance have value)
- **Development phase**: Phase 2 (interplanetary logistics)

### 5. Universal Docking Service
- **Code**: `UniversalDockingService` exists
- **Docs**: None found
- **Gap**: Docking protocol, which craft types can dock where
- **Development phase**: Phase 1 (initial habitation)

### 6. Orbital Mechanics Transfer Calculator
- **Code**: `app/services/orbital_mechanics/transfer_calculator.rb`
- **Docs**: None found
- **Gap**: Hohmann transfer, bi-elliptic transfer calculations, fuel cost integration
- **Development phase**: Phase 2 (orbital operations)

### 7. Market Demand Service
- **Code**: `app/services/market/demand_service.rb`
- **Docs**: Partial — economy docs mention market but not demand service specifically
- **Gap**: How demand is calculated, how it affects NPC pricing
- **Development phase**: Phase 1 (economy bootstrap)

### 8. ISRU Evaluator and Optimizer
- **Code**: `isru_evaluator.rb`, `isru_optimizer.rb`
- **Docs**: Partial — ISRU_PRICING_MODEL.md exists but may be outdated
- **Gap**: In-Situ Resource Utilization algorithms, cost-benefit analysis methodology
- **Development phase**: Phase 1 (ISRU foundation)

### 9. Regolith Processing Service
- **Code**: `RegolithProcessingService`
- **Docs**: None found
- **Gap**: Processing pipeline, output materials, energy requirements
- **Development phase**: Phase 1 (regolith processing)

### 10. Component Production Service
- **Code**: `ComponentProductionService`
- **Docs**: Partial — manufacturing overview is stub
- **Gap**: Component recipes, production rates, material requirements
- **Development phase**: Phase 1 (manufacturing foundation)

---

## P3 — Moderate: Partial Documentation Exists

### 11. Craft Models (Harvester, Rover, Ship, Spaceship)
- **Code**: `Craft::BaseCraft` hierarchy
- **Docs**: Some docs reference craft but no dedicated craft documentation
- **Gap**: Full craft type catalog, capabilities, stats
- **Development phase**: Phase 1 (craft deployment)

### 12. Power Systems
- **Code**: PowerStation structure, SolarArray model
- **Docs**: Partial — power generation tech tree integration unclear
- **Gap**: Power generation types, distribution, storage
- **Development phase**: Phase 1 (power systems)

### 13. Storage System
- **Code**: `StorageManager`, `SurfaceStorage`, `MaterialPile`
- **Docs**: None found
- **Gap**: Storage capacity calculations, surface vs orbital storage
- **Development phase**: Phase 1 (storage)

### 14. Base Rig System
- **Code**: `Rigs::BaseRig`
- **Docs**: Partial — rig vs station vs depot distinction needs documentation
- **Gap**: Rig functionality, deployment, resource processing
- **Development phase**: Phase 1 (base establishment)

---

## P4 — Low: Niche Systems

### 15. Cryosphere Simulation
- **Code**: `app/models/celestial_bodies/spheres/cryosphere.rb` (model only)
- **Docs**: No simulation service documentation
- **Gap**: Ice giant and ice moon simulation methodology
- **Development phase**: Phase 3+ (advanced simulation)

### 16. Precursor Mission System
- **Code**: `data/json-data/precursor_mission_setup_methane.json` + architecture docs
- **Docs**: Multiple docs with different scopes
- **Gap**: Unified precursor mission documentation
- **Development phase**: Phase 1 (precursor missions)

### 17. Sub-Brown Dwarf Support
- **Code**: `app/models/sub_brown_dwarf.rb`
- **Docs**: None found
- **Gap**: Purpose, integration with world generation
- **Development phase**: Phase 3+ (world generation expansion)

### 18. Alien Life Form Simulation
- **Code**: `app/models/celestial_bodies/alien_life_form.rb`
- **Docs**: None found
- **Gap**: Scope, simulation methodology, late-game integration
- **Development phase**: Phase 4+ (late-game content)

---

## Summary by Development Phase

| Phase | P1 | P2 | P3 | P4 | Total |
|-------|----|----|----|----|-------|
| Phase 0 (Foundation) | 0 | 0 | 0 | 0 | 0 |
| Phase 1 (Lunar Bootstrap) | 3 | 5 | 4 | 0 | 12 |
| Phase 2 (Orbital Logistics) | 0 | 2 | 0 | 0 | 2 |
| Phase 3+ (Advanced Sim) | 0 | 0 | 0 | 3 | 3 |
| Phase 4+ (Late Game) | 0 | 0 | 0 | 1 | 1 |

**Total missing documentation**: 18 systems
- **Critical (P1)**: 3 — AI Manager services, settlement services, construction job tracking
- **Important (P2)**: 5 — Transport cost, docking, orbital mechanics, market demand, ISRU/regolith/component services
- **Moderate (P3)**: 4 — Craft, power, storage, base rig
- **Low (P4)**: 3 — Cryosphere, precursor missions, sub-brown dwarf, alien life

**Key Finding**: Phase 1 (lunar bootstrap) has the most missing documentation — 12 systems need docs. AI Manager services inventory is the single largest gap (72+ undocumented services).
