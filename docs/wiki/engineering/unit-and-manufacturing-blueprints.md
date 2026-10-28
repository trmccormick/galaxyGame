# Unit and Manufacturing Blueprints Specification

## STATUS: DESIGN INTENT ONLY

This page is the canonical wiki entry for unit composition, facility manufacturing schemas, and operational data roles. It defines target design intent and is **not** fully wired to live code execution.

---

## 1. Scope & Separation

| Boundary | What it owns | Owner in this wiki |
|----------|-------------|--------------------|
| **StarSim (astronomy/)** | Celestial body generation, orbital mechanics, star-system initialization | [System blueprints](../astronomy/System-Blueprints.md) — "documents StarSim: procedural system generation and loading JSON systems to initialize that part of the game" |
| **Unit & Manufacturing Blueprints** | Constructed units (craft, satellites, harvesters), structural modules, stations built from components, and production-pipeline schemas | **This page** |

**Rule:** Anything that produces matter, energy flow, or build state — *not* celestial/planetary initialization — lives under this engineering scope. If it describes an item that appears in the crafting catalog (materials, intermediate parts, finished units), it is a blueprint data role and belongs here.

---

## 2. Data Role & Schemas

### 2.1 Blueprint JSON Schema Intent

Every craftable or constructible entity is described by a JSON-backed `Blueprint` model (`galaxy_game/app/models/blueprint.rb`). The schema carries three conceptual zones:

| Zone | Payload example fields | Purpose |
|------|----------------------|---------|
| **Input Materials** | `materials`, `component_requirements`, `isr_chain` | What raw / intermediate resources are consumed per build or per tick. |
| **Production Metadata** | `build_time`, `energy_draw`, `licensed_runs`, `assembly_steps` | Tick-level cost and throughput for scheduling and queue management. |
| **Output Yield** | `output_type`, `yield_quantity`, `degraded_output` | What enters the catalog or storage bay once the job completes (or degrades in progress). |

A blueprint may reference other blueprints as dependencies (`parent_blueprint_id`, `dependency_graph`) to form static trees that the AI builder resolves before dispatching work orders.

### 2.2 Operational Data Roles

| Service / model | Role in the pipeline |
|----------------|--------------------|
| `galaxy_game/app/models/blueprint.rb` | ORM backbone — stores schema, validates constraints. |
| `galaxy_game/app/services/blueprint_services/material_generator.rb` | Populates the `materials` zone at runtime (procedural cost adjustment). |
| `galaxy_game/app/services/manufacturing/assembly_service.rb` | Consumes blueprints to drive build queues and tick logic. |
| `galaxy_game/app/services/manufacturing/component_production_service.rb` | Intermediate-part production; bridges material input → component output. |
| `galaxy_game/app/services/manufacturing/craft_factory.rb` | Higher-level factory that composes multi-module craft units from base blueprints. |
| `galaxy_game/app/services/construction/orbital_shipyard_service.rb` | Station-level assembly — scales the same schema to mega-station construction. |
| `galaxy_game/app/services/unit_module_assembly_service.rb` | Unit-level module composition for multi-part craft. |

---

## 3. Open Options & Trade-offs

### 3.1 Modular vs Fixed Hull Templates

| Option | Pros | Cons |
|--------|------|------|
| **Modular hull templates** (component-based) | Reuse across craft classes; composition-driven catalog entries. | Runtime graph resolution overhead; harder to guarantee balanced stats. |
| **Fixed hull templates** (pre-built JSON per craft) | Balanced, debuggable, fast load-time lookup via `BlueprintLookupService`. | Duplication across similar units; template drift as mechanics evolve. |

**Current lean:** A hybrid — fixed top-level templates in catalog JSON with modular sub-component overrides for specialized variants.

### 3.2 Degradation / Wear Metrics

| Option | Mechanism | Cost to system |
|--------|-----------|---------------|
| **Static degradation** (flat %) | Blueprint carries a `degradation_rate` applied at job start. | Minimal CPU, easy to tune. |
| **Tick-driven wear** | Wear accumulates per simulation tick based on operational stress factors. | Adds storage writes; requires AI reassignment logic. |

**Open question:** Should degradation be a *blueprint property* (static) or an *instance property* (tick-driven)? Blueprint-level keeps schemas simple; instance-level enables dynamic economy shifts (scarcity, repair services).

### 3.3 Static vs Dynamic Manufacturing Trees

| Option | Description |
|--------|-------------|
| **Static tree** | Blueprint `dependencies` resolve at load time into a fixed DAG. Fast but brittle to catalog changes. |
| **Dynamic resolution** | AI Manager resolves dependencies at runtime via `BlueprintDependencyGenerator`. Flexible; adds latency per build dispatch. |

**Current state:** Dynamic with caching — trees are re-resolved only when catalog data changes, then served from the cached graph. Trade-off: stale-cache risk vs load-time rigidity.

---

## 4. Architecture Pointers

The following code paths contain the deepest current implementation detail. Use them for wire-verification before tying a design decision to production behavior.

### Models & ORM
| Path | Content |
|------|---------|
| `galaxy_game/app/models/blueprint.rb` | Blueprint ActiveRecord model and constraints. |
| `galaxy_game/app/models/build_queue.rb` | Scheduled build-job state machine. |
| `galaxy_game/app/models/concerns/has_construction_costs.rb` | Shared cost-calculus mixin used by blueprints on structures. |

### Services & Pipelines
| Path | Content |
|------|---------|
| `galaxy_game/app/services/blueprint_services/material_generator.rb` | Procedural material cost generation. |
| `galaxy_game/app/services/blueprint_dependency_generator.rb` | DAG resolver for blueprint dependency graphs. |
| `galaxy_game/app/services/lookup/blueprint_lookup_service.rb` | Catalog lookup and legacy-port adapter. |
| `galaxy_game/app/services/manufacturing/production_service.rb` | Core tick-loop production driver. |
| `galaxy_game/app/services/manufacturing/cost_calculator.rb` | Per-job cost computation (materials + energy). |
| `galaxy_game/app/services/unit_module_assembly_service.rb` | Multi-module unit composition logic. |
| `galaxy_game/app/services/construction/orbital_shipyard_service.rb` | Orbital mega-station construction service. |

### AI Manager Integration
| Path | Content |
|------|---------|
| `galaxy_game/app/services/ai_manager/builder.rb` | AI-driven build dispatching from blueprints. |
| `galaxy_game/app/services/ai_manager/production_manager.rb` | Production-line scheduling; reads blueprint yields to allocate labor/energy. |

### Data Fixtures / Catalogs
| Path | Content |
|------|---------|
| `galaxy_game/json-build-scripts/` | JSON generation/migration tooling for catalog blueprints. |
| `galaxy_game/app/services/catalog_service.rb` | Live catalog loader at runtime. |
| `galaxy_game/config/initializers/game_data_paths.rb` | Paths that feed the lookup service and define fixture load order. |

---

## 5. Cross-References

| Page | Relationship |
|------|-------------|
| [Station construction options](./station_construction_options.md) | Station-level assembly pipeline; consumes blueprints as input modules. |
| [System blueprints (astronomy)](../astronomy/System-Blueprints.md) | StarSim initialization — distinct from constructible-unit schemas documented here. |
| [AI Manager logic](../logistics/AI-Manager-Logic.md) | AI scheduling consumes blueprint yields and dependency DAGs to drive production decisions. |
| [Status and gaps](../status-and-gaps.md) | Tracks wiki coverage posture; this page fills the unit/blueprint gap. |

---

## 6. Section status

> **DESIGN INTENT ONLY** — Schema zones, trade-off tables, and service pointers represent target architecture. Verify against live code in `galaxy_game/app/services/` before treating any detail as implemented behavior.
