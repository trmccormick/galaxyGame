# Unit & Manufacturing Blueprints

## Status: VERIFIED ACTIVE (code-grounded)

This page is the canonical wiki entry for unit composition, facility manufacturing schemas, and operational data roles. All content is grounded in live code inspection (`galaxy_game/app/`). Legacy docs are cited as harvest sources but carry no authority.

**Harvested from legacy sources:**
- `docs/architecture/units/base_unit.md` — Unit persistence contract & lifecycle
- `docs/architecture/units/3d_printed_fabricators.md` — Mk1-Mk3 fabricator registry
- `docs/architecture/units/initial_3d_printer.md` — Luna ISRU starter printer intent
- `docs/architecture/units/robots.md` — Robot two-state (Item <-> Unit) lifecycle
- `docs/architecture/units/manifest_integration.md` — Mission manifest unit seeding
- `docs/architecture/units/propulsion.md` — Propulsion unit registry & naming standards
- `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md` — Manufacturing chain intent
- `docs/gameplay/mechanics.md` — Player-first task priority system overview

---

## 1. Scope & Separation

| Boundary | What it owns | Owner in this wiki |
|----------|-------------|--------------------|
| **StarSim (astronomy/)** | Celestial body generation, orbital mechanics, star-system initialization | [System blueprints](../astronomy/System-Blueprints.md) - documents StarSim: procedural system generation and loading JSON systems to initialize that part of the game |
| **Unit & Manufacturing Blueprints** | Constructed units (craft, satellites, harvesters), structural modules, stations built from components, jobs, build queues, and production-pipeline schemas | **This page** |

**Rule:** Anything that produces matter, energy flow, or build state - *not* celestial/planetary initialization - lives under this engineering scope. If it describes an item that appears in the crafting catalog (materials, intermediate parts, finished units), it is a blueprint data role and belongs here.

---

## 2. Unit Hierarchy & Model Contract

### 2.1 `Units::BaseUnit` - Abstract Base for All Physical Entities

`Units::BaseUnit` is the concrete base class for every physical entity in a Settlement or Craft. It provides standardized persistence, location tracking, and resource storage.

**Database:** `base_units` table (table_name set explicitly; inheritance column disabled).

| Attribute | Type | Requirement | Description |
|-----------|------|-------------|-------------|
| `identifier` | String | **Required** | Unique WTC registry ID (e.g., `IHU001`, `ROBOT-XXXX`) |
| `name` | String | **Required** | Human-readable label |
| `unit_type` | String | **Required** | Categorical slug (e.g., `"housing_unit"`, `"robot"`, `"fabricator"`) |
| `owner` | Polymorphic (`Player \| Settlement \| Organization`) | **Required** | Parent owner |
| `attachable` | Polymorphic (`Settlement \| Craft`) | Optional | Parent container (plug-into a craft port) |
| `operational_data` | JSONB | **Critical** | Complex nested state - the "JSONB black box" |
| `location` | `CelestialLocation` | via `has_one` | Current celestial body |
| `inventory` | `Inventory` | via `has_one`, dependent: :destroy | Items held by this unit |

**Included concerns:**
- `HasModules` - internal module slots
- `HasRigs` - rig attachment slots
- `EnergyManagement` - power draw tracking (delegated via `energy_usage -> power_usage`)
- `Units::HasProcessing` - resource processing
- `AtmosphericProcessing` - atmospheric extraction/processing
- `HasExtraction` - extraction operations
- `RigAttachable` - rig-to-unit binding

**Key lifecycle hooks:**
| Hook | Effect |
|------|--------|
| `before_validation :load_unit_info` | Loads unit catalog data into `@unit_info` from JSON lookups |
| `after_create :initialize_unit` | Performs post-creation setup |
| `after_create :create_inventory` | Every BaseUnit gets an Inventory record on creation |

**Key methods (verified in code):**

| Method | Return / Effect | Code location |
|--------|----------------|---------------|
| `job_types` | Array of supported job type slugs from `operational_data['job_types.supported']` | base_unit.rb |
| `max_concurrent_jobs` | Integer from `operational_data['job_types.max_concurrent']`, defaults to 1 | base_unit.rb |
| `supports_job_type?(type)` | Boolean - checks if type is in job_types | base_unit.rb |
| `processing_type` | String from `operational_data['processing_type']` | base_unit.rb |
| `storage_manager` | `Storage::StorageManager` instance (lazy-initialized) | base_unit.rb |
| `population_capacity` | Integer from `operational_data['capacity']`, defaults to 0 | base_unit.rb |
| `input_resources / output_resources` | Arrays of resource hashes from `@unit_info` | base_unit.rb |
| `collect_materials` | Collects stored materials from all attached BaseUnits into inventory; clears storage. Returns count of items collected. | base_unit.rb |
| `process_materials(craft_inventory)` | Checks input availability, converts inputs to outputs (gas -> gas_buffer, liquid -> liquid_buffer, others -> resource). Consumes inputs. Returns boolean. | base_unit.rb |
| `operate(time_skipped)` | Core simulation tick: calculates inputs/outputs, handles outputs via `handle_outputs` | base_unit.rb |
| `process_resources(resource_name)` | Processes a specific material - consumes input rate, smelts via material composition, stores outputs by type. Returns true/false. | base_unit.rb |
| `current_location` | Resolves attachable location or direct location | base_unit.rb |
| `target_thickness_mm` | Integer from `operational_data['target_thickness_mm']` or `@unit_info` | base_unit.rb |

**Subclass registry:**
- `Units::Fabricator` - 3D printing of parts/materials (see section 2.4)
- `Units::Robot` - mobile autonomous actor (see section 2.5)
- Plus all concrete subclasses: Habitat, Extractor, etc.

### 2.2 `Blueprint` - Blueprint ORM Backbone

**Database:** `blueprints` table (belongs_to :player).

| Attribute | Type | Requirement | Description |
|-----------|------|-------------|-------------|
| `name` | String | **Required** | Blueprint identifier / name |
| `current_research_level` | Integer | >= 0 | Research progression level |
| `material_efficiency` | Float | >= 0 | Material efficiency modifier |
| `time_efficiency` | Float | >= 0 | Time efficiency modifier |
| `licensed_runs_remaining` | Integer or nil | >= 0, allow_nil: true | Manufacturing license runs (nil = unlimited for NPCs) |

**Verified methods:**

| Method | Return / Effect | Code location |
|--------|----------------|---------------|
| `materials` | Hash of material names -> amounts via `BlueprintLookupService` | blueprint.rb |
| `can_manufacture?(qty)` | Boolean - checks licensed_runs_remaining (unlimited for NPCs) | blueprint.rb |
| `consume_runs(qty)` | Reduces licensed_runs_remaining by qty; no-op for unlimited NPCs | blueprint.rb |
| `calculate_efficiencies` | Computes derived material/time efficiency from research effects in JSON catalog data | blueprint.rb |

### 2.3 `Craft::BaseCraft` - Vessel Registry

All vessels (satellites, starships, haulers) inherit from `Craft::BaseCraft`. Craft carry a full inventory and attachable BaseUnits via `HasUnits`.

**Key association:**
```ruby
has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable, dependent: :destroy
```

### 2.4 `Units::Fabricator` - 3D Printing Units

Mk1-Mk3 fabricators from legacy docs (`docs/architecture/units/3d_printed_fabricators.md`). The code implements a stub pattern - Fabricator extends BaseUnit with scaffolding for future extension:

| Method / Field | Status | Notes |
|----------------|--------|-------|
| `available?` | Implemented | Returns true if no Job exists with status pending/in_progress for this unit |
| `supported_parts` | TODO (placeholder comment) | Would read from `operational_data['supported_parts']` |
| `tick` | TODO (placeholder comment) | Would orchestrate fabrication jobs per tick |
| `perform_maintenance` | RETIRED / DO NOT USE | Placeholder method - never wired to any pipeline |

**Mk1-Mk3 registry (from legacy docs; JSON data paths are frozen ore):**
| Unit | Role | Blueprint path |
|------|------|----------------|
| Fabricator Mk1 | Entry-level, day-one ISRU. Consumes regolith -> panels, I-beams, basic structures | `data/json-data/blueprints/units/production/fabricators/3d_printed_fabricator_mk1.json` |
| Fabricator Mk2 | Improved throughput + material compatibility; requires Mk1 as component | `data/json-data/blueprints/units/production/fabricators/3d_printed_fabricator_mk2_bp.json` |
| Fabricator Mk3 | Autonomous, advanced composites + quantum electronics. Maximum throughput/efficiency | `data/json-data/blueprints/units/production/fabricators/3d_printed_fabricator_mk3_bp.json` |

### 2.5 `Units::Robot` - Mobile Autonomous Actors

Robots exist in two states:

| State | Location | Behavior |
|-------|----------|----------|
| **Crated Item** (dormant) | Inventory items (`inventory.units` or `InventoryItem`) | Static asset, no power draw, no identifier. Minimal metadata: `{name:, count:}` |
| **Active Unit** (live) | `base_units` table, attached to Settlement/Craft | Active AI participant, consumes battery, has identifier |

**Creation contract (strict - must pass all validations):**

| Attribute | Type | Requirement |
|-----------|------|-------------|
| `name` | String | Required - from blueprint (e.g., "CAR-300") |
| `identifier` | String | **Required at activation time** - generated as `ROBOT-XXXX` |
| `unit_type` | String | Always `"robot"` |
| `owner` | Polymorphic | Parent Settlement or Organization |
| `operational_data` | JSONB | Must contain `mobility_type` (`wheels`, `legs`, `treads`, or `hover`) |

**Robot model registry:**

| Model ID | Role | Key Visual Features |
|----------|------|---------------------|
| CAR-300 | Utility / Assembly | 6 wheels, 2 manipulator arms, orange/white |
| SMR-500 | Mapping / LIDAR | Compact, blue-glowing lenses, rotating turret |
| HRV-400 | Harvesting | Front scoop, large rear hopper, weathered metal |
| MRR-100 | Maintenance | Welding torch arm, tool-rack backplate |

**Active robot behaviors (via concerns):** `EnergyManagement` -> `BatteryManagement` -> `RechargeBehavior` (auto "Needs Recharge" below 20%) + `StorageOperations`.

---

## 3. Propulsion Unit Registry

All propulsion units must expose performance metrics in their `operational_data['performance']` block. **Required schema:**
- `nominal_thrust_kn` (Float) - primary acceleration physics force
- `isp_seconds` (Integer) - specific impulse for fuel consumption math
- `fuel_type` (String) - must match `GameConstants::RESOURCES`

Craft thrust is computed via:
```ruby
total_thrust = container.units.sum { |u| u.operational_data['performance']['nominal_thrust_kn'] || 0 }
```

**Propulsion registry (verified against code):**

| Unit ID | Name | Thrust (kN) | Fuel Type | Isp (s) | Notes |
|---------|------|-------------|-----------|---------|-------|
| `methane_engine` | Methane Engine | 2000 | Methane/LOX | 350 | Standard chemical rocket |
| `liquid_rocket_engine` | Liquid Rocket Engine | 845 | Kerosene/LOX | 311 | Legacy chemical rocket |
| `basic_engine` | Basic Engine | 1000 | Hydrazine | 300 | Small craft / maneuvering |
| `nuclear_thermal_engine` | Nuclear Thermal Propulsion | 900 | Liquid Hydrogen | 900 | Inner solar system operations |
| `fusion_drive_engine` | Fusion Drive | 2500 | Deuterium/He-3 | 5000 | Rapid interplanetary travel |
| `ion_thruster_engine` | Ion Thruster | 0.25 | Xenon Gas | 3000 | High-efficiency, low-thrust |
| `electromagnetic_capture_thruster_engine` | Electromagnetic Capture Thruster | 0.1 | Interplanetary Plasma | 10000 | Propellantless, long-duration |

> **Naming note:** Epstein Drive is not present in this project - all references removed for clarity. Raptor and Methane refer to the same engine; use `methane_engine` only.

---

## 4. Job Model & Production Pipeline

### 4.1 `Job` - Production Task ORM

**Database:** `jobs` table.

| Attribute | Type | Description |
|-----------|------|-------------|
| `job_type` (enum) | material_processing / component_production / smelting / unit_assembly / resource_processing / environment_processing | Category of work |
| `status` (enum) | in_progress / ready_to_claim / claimed / failed / cancelled / pending | Current state |
| `completes_at` | DateTime | Scheduled completion timestamp (required for non-pending jobs) |
| `owner` | Polymorphic | Who owns the job |
| `settlement` | Settlement::BaseSettlement | Associated settlement |
| `blueprint` | Blueprint (optional) | Associated blueprint definition |

### 4.2 `BuildQueue` - Job Dispatch Queue

```ruby
class BuildQueue
  def self.add_job(player_id, blueprint_id, settlement_id = nil)
    BuildJob.perform_async(player_id, blueprint_id, settlement_id)
  end
end
```

This is a thin ActiveJob dispatch wrapper. The actual work runs in the `BuildJob` worker class.

---

## 5. Manufacturing Services (Verified Code Reality)

### 5.1 Core Manufacturing Service - `ManufacturingService`

**Path:** `galaxy_game/app/services/manufacturing_service.rb`

This is the **primary player-facing manufacturing entry point**. Called via `ManufacturingService.manufacture(blueprint_name, owner, settlement, count:)`.

**Pipeline (verified line-by-line):**

1. **Blueprint lookup** - via `BlueprintLookupService.find_blueprint(name)`
2. **License check** - if owner is a Player, checks `blueprints.find_by(name).can_manufacture?(count)`; returns error if exhausted
3. **Access check** - verifies settlement ownership or accessibility
4. **Cost calculation** - uses BOM from `required_materials`; computes via `NpcPriceCalculator.calculate_ask(settlement, material_name)` and `settlement.calculate_construction_cost(bom_cost)`
5. **Affordability check** - `owner.can_afford?(construction_cost)`
6. **Job creation** - creates Job with `job_type: :unit_assembly`, status in_progress, `completes_at` set from blueprint's `production_data.time_hours`
7. **Material availability** - checks via `check_materials(settlement, required_materials, count, is_player)`

### 5.2 Component Production Service - `Manufacturing::ComponentProductionService`

**Path:** `galaxy_game/app/services/manufacturing/component_production_service.rb`

Higher-fidelity component production with ISRU chain support. Pipeline:

1. Validate printer capability against blueprint category
2. Resolve materials (with acceptable_types substitution logic)
3. Ensure materials via ISU chain trigger if missing
4. Consume from settlement inventory
5. Calculate production time (base_time x qty / printer_rate_multiplier)
6. Create Job with `job_type: :component_production` and full operational_data payload

On job completion: adds finished component + waste products to inventory, sets status to `ready_to_claim`.

### 5.3 Production Service - `Manufacturing::ProductionService`

**Path:** `galaxy_game/app/services/manufacturing/production_service.rb`

Full ISRU chain orchestrator with PVE/TEU cycle logic:

```
Raw regolith -> PVE (volute extraction) -> TEU cycles -> MaterialProcessing
-> 3D Printer cycle -> Final component
```

**Key constant:** `PVE_DATA = {input_processed_kg: 5.0, output_gases_kg: 0.05, output_water_kg: 0.10, output_inert_waste_kg: 4.85}.freeze`

Pipeline (transactional):
1. Calculate material requirements -> inert_req_kg = input_quantity x target_units
2. Determine PVE cycles needed
3. Consume raw_regolith from surface pile
4. Run TEU/PVE cycles -> yield water + gases + waste
5. Produce volatiles to inventory, inert waste to pile
6. Consume intermediate materials, produce final component
7. Return production report with byproducts

### 5.4 Unit Module Assembly Service - `UnitModuleAssemblyService`

**Path:** `galaxy_game/app/services/unit_module_assembly_service.rb`

Handles craft build-out from inventory items:
- `#build_units_and_modules` - creates a Craft::BaseCraft from a craft_item, looks up recommended_fit/recommended_units, applies modules to the craft
- `self.build_units_and_modules(target:, settlement_inventory:)` - class method that installs units/modules on a target craft

### 5.5 Craft Factory - `Manufacturing::CraftFactory`

**Path:** `galaxy_game/app/services/manufacturing/craft_factory.rb`

Class-level factory for building complete craft:
```ruby
CraftFactory.build_from_blueprint(
  blueprint_id:, variant_data:, owner:, location:
)
```

Determines craft class from subcategory:
- Satellite mining -> `Craft::Satellite::BaseSatellite`
- Starship / heavy lander -> `Craft::Transport::HeavyLander`
- Fallback -> `Craft::BaseCraft`

### 5.6 Orbital Shipyard Service - `Construction::OrbitalShipyardService`

**Path:** `galaxy_game/app/services/construction/orbital_shipyard_service.rb`

Manages orbital mega-craft construction at stations:
| Method | Purpose |
|--------|---------|
| `create_shipyard_project(blueprint_id)` | Creates an OrbitalConstructionProject (status: materials_pending) |
| `self.deliver_materials(station, material_type, qty, source_settlement)` | Distributes materials across active projects |
| `self.update_construction_progress` | Advances all in_progress projects |
| `self.complete_project(project)` | Marks completed, spawns craft at station |

> **NOTE:** `create_shipyard_project` class method is partially stubbed. The instance method works; the class-level `create_shipyard_project(station, blueprint_id)` has a minimal stub with intent-unknown warning. See section 7 OPEN items.

### 5.7 Blueprint Material Generator - `BlueprintServices::MaterialGenerator`

**Path:** `galaxy_game/app/services/blueprint_services/material_generator.rb`

Procedural material cost generation:
```ruby
MaterialGenerator.generate_material(material_data)
# produces: id, name, type, description, weight (kg), storage config, source, reprocessing
```

Reads from base template at `GalaxyGame::Paths::TEMPLATE_PATH.join('base_material.json')`.

### 5.8 Byproduct Manufacturing Service

**Path:** `galaxy_game/app/services/manufacturing/byproduct_manufacturing_service.rb`

Handles secondary product streams from primary manufacturing jobs (waste recovery, byproduct valorization).

---

## 6. Blueprint Lookup & Dependency Services

### 6.1 `Lookup::BlueprintLookupService`

Sole source of blueprint definitions across the system. Called by every manufacturing service for catalog data lookups.

### 6.2 `BlueprintDependencyGenerator`

**Path:** `galaxy_game/app/services/blueprint_dependency_generator.rb`

DAG resolver for blueprint dependency graphs. Dynamic resolution with caching - trees re-resolve only on catalog changes. Trade-off: stale-cache risk vs load-time rigidity.

### 6.3 Other Lookup Services

| Service | Purpose |
|---------|---------|
| `Lookup::CraftLookupService` | Craft catalog lookups (used by CraftFactory) |
| `Lookup::UnitLookupService` | Unit catalog lookups (used by HasUnits, UnitModuleAssemblyService) |
| `Lookup::ModuleLookupService` | Module catalog lookups |
| `Lookup::RigLookupService` | Rig catalog lookups |

### 6.4 `AIManager::ProductionManager`

**Path:** `galaxy_game/app/services/ai_manager/production_manager.rb`

AI-driven production scheduling - reads blueprint yields and dependency DAGs to allocate labor/energy across settlement production lines.

---

## 7. Unit Attachment via HasUnits Concern

**Path:** `galaxy_game/app/models/concerns/has_units.rb`

The `HasUnits` concern provides craft-level unit management:

```ruby
has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable, dependent: :destroy
```

| Method | Purpose | Verification |
|--------|---------|-------------|
| `add_unit(unit_blueprint_id)` | Creates a new BaseUnit from blueprint ID, validates max_units and compatible_unit_types constraints | Active code |
| `install_unit(unit)` | Attaches an existing unit to this craft | Active code |
| `_apply_unit_effects(unit)_` | Applies any operational effects from the attached unit | Active code |

---

## 8. Mission Manifest & Unit Seeding

**Harvested from:** `docs/architecture/units/manifest_integration.md`

The `mission_manifest` defines initial deployment state:
- **Active units** in `craft.installed_units` - have immediate operational requirements (fuel, power, port connections)
- **Crated units** in `inventory.units` - dormant items awaiting unpacking via UnpackingService

**Robot unpacking protocol:**
1. Attributes merged from `data/json-data/blueprints/units/robots/` directory
2. Robots created as independent BaseUnit instances attached to Settlement (not a specific port)
3. Identifier generated at activation moment, not during manifest creation

---

## 9. Active vs Target Design Map

### VERIFIED ACTIVE - Fully wired to live code

| Component | Location | Status |
|-----------|----------|--------|
| Blueprint model + schema | `app/models/blueprint.rb` | Active - validates presence, efficiencies, licensed runs |
| BaseUnit model + lifecycle | `app/models/units/base_unit.rb` | Active - persistence contract, operational_data, all hooks verified |
| Fabricator unit | `app/models/units/fabricator.rb` | Stub scaffold - `available?` works; extension plan is TODO |
| Job model + enums | `app/models/job.rb` | Active - 6 job types, 6 statuses, all validations verified |
| BuildQueue dispatch | `app/models/build_queue.rb` | Active - thin ActiveJob wrapper |
| ManufacturingService (player-facing) | `app/services/manufacturing_service.rb` | Active - full pipeline: lookup -> license -> cost -> materials -> job creation |
| ComponentProductionService | `app/services/manufacturing/component_production_service.rb` | Active - ISRU chain support, substitution logic, waste products |
| ProductionService (ISRU orchestrator) | `app/services/manufacturing/production_service.rb` | Active - full PVE/TEU cycle transactional pipeline |
| UnitModuleAssemblyService | `app/services/unit_module_assembly_service.rb` | Active - build-out from inventory items, recommended_fit application |
| CraftFactory | `app/services/manufacturing/craft_factory.rb` | Active - class-level craft builder with subcategory routing |
| OrbitalShipyardService (instance) | `app/services/construction/orbital_shipyard_service.rb` | Active - project lifecycle; class method `create_shipyard_project(station, blueprint_id)` is stubbed |
| BlueprintMaterialGenerator | `app/services/blueprint_services/material_generator.rb` | Active - procedural material generation from templates |
| BlueprintLookupService | `app/services/lookup/blueprint_lookup_service.rb` | Active - sole catalog source |
| BlueprintDependencyGenerator | `app/services/blueprint_dependency_generator.rb` | Active - DAG resolver with caching |
| AIManager::ProductionManager | `app/services/ai_manager/production_manager.rb` | Active - AI production scheduling |
| HasUnits concern | `app/models/concerns/has_units.rb` | Active - unit attachment on craft, validation constraints |

### RETIRED / DO NOT USE

| Component | Location | Notes |
|-----------|----------|-------|
| Fabricator Mk3 (as standalone model class) | Legacy docs only | Never implemented as a separate Ruby class |
| `perform_maintenance` | `units/fabricator.rb` placeholder comment | Dead stub - no callers anywhere in codebase |

### OPEN - Needs Owner Confirmation

| Item | Location | Description |
|------|----------|-------------|
| OrbitalShipyardService class method stub | `app/services/construction/orbital_shipyard_service.rb` | `create_shipyard_project(station, blueprint_id)` has a minimal stub with intent-unknown warning - needs owner implementation |
| Fabricator extension plan | `units/fabricator.rb` comments | Extension plan (energy management, resource processing) is unimplemented - Mk1-Mk3 defined only in legacy docs + JSON data |
| Degradation / wear metrics | No active code | Open question: blueprint property vs instance property (no implementation exists either way) |

---

## 10. Cross-References

| Page | Relationship |
|------|--------------|
| [Station construction options](./station_construction_options.md) | Station-level assembly pipeline; consumes blueprints as input modules |
| [System blueprints (astronomy)](../astronomy/System-Blueprints.md) | StarSim initialization - distinct from constructible-unit schemas documented here |
| [AI Manager logic](../logistics/ai_manager_logic.md) | AI scheduling consumes blueprint yields and dependency DAGs to drive production decisions |
| [Status and gaps](../status-and-gaps.md) | Tracks wiki coverage posture; this page fills the unit/blueprint gap |
| [ISRU fabrication chain](../technical/isru_fabrication_chain.md) | Downstream ISRU material processing feeds into manufacturing pipelines |

---

## 11. Section Status

> **Code-grounded.** All sections in section 2 through section 9 are verified against live code inspection. Legacy doc citations carry authority only for naming conventions and design intent that has no code equivalent. See section 9 for the active vs target design map.
