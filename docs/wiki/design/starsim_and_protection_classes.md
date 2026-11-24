# StarSim, Unit Simulation Boundaries & Protection Classes
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-01  
> *Audit Summary:* Design intent specification. Code implementation pending or unverified as of audit baseline.

**Role:** Canonical wiki entry for StarSim system generation, unit-simulation boundaries, CelestialBody contracts, and code-reality notes. For stellar radiation environment and Planetary Protection Class physics detail, see [Stellar Radiation & Protection Classes](../astronomy/starsim_and_protection_classes.md).

This page is the canonical wiki entry for StarSim system generation, unit-level simulation execution boundaries, and planetary protection class frameworks. The architecture and design intent are described below. Code implementation coverage is detailed in the relevant sections.

**Harvested from legacy sources:**
- `docs/architecture/starsim/OVERVIEW.md` — StarSim architecture overview, weathering engine intent, fidelity tiers
- `docs/architecture/starsim/PROCEDURAL_INTENT.md` — Civ4/NASA terrain fusion strategy
- `docs/architecture/starsim/MISSING_HOOKS.md` — Architectural gaps (erosion state, radiolytic decay, velocity vectors)
- `docs/architecture/starsim/celestial_bodies.md` — BaseFeature static data system priority
- `docs/architecture/starsim/star_naming_architecture.md` — Star naming ID-primary design
- `docs/architecture/starsim/TECHNICAL_HISTORY.md` — Math formulas, JSON structures, historical failures
- `docs/wiki/infrastructure/planetary_protection_environmental_governance.md` — Protection class hierarchy (TARGET DESIGN INTENT)
- `docs/gameplay/mechanics.md` — Player-first task priority system overview

---

## 1. Simulation Scale Hierarchy

Galaxy Game operates across two distinct simulation scales with a hard boundary between them:

### Macro-Simulation (StarSim) — System-Level Procedural Generation

| Component | Scope | Code Location | Status |
|-----------|-------|---------------|--------|
| **SystemGeneratorService** | Creates solar systems procedurally or from predefined JSON | `app/services/star_sim/system_generator_service.rb` | Active |
| **ProceduralGenerator** | Seed generation with biosphere complexity options, accretion mode support | `app/services/star_sim/procedural_generator.rb` | Active |
| **SystemBuilderService** | Constructs ActiveRecord objects from predefined JSON (Sol system templates) | `app/services/star_sim/system_builder_service.rb` | Active |
| **AccretionSimulationService** | Accretion-based body generation using dust disk model | `app/services/star_sim/accretion_simulation_service.rb` | Active |

### Micro-Simulation (Units & Settlements) — Tick-Level Entity Execution

| Component | Scope | Code Location | Status |
|-----------|-------|---------------|--------|
| **CelestialBody model** | Per-body properties, physics calculations (gravity, density, escape velocity, temperature) | `app/models/celestial_bodies/celestial_body.rb` | Active |
| **Units::BaseUnit subclasses** | Settlement infrastructure, craft units, robots — tick-driven operational behavior | `app/models/units/base_unit.rb` | Active |
| **Job model** | Production tasks with status transitions (in_progress → ready_to_claim → claimed) | `app/models/job.rb` | Active |
| **ManufacturingService** | Player-facing unit assembly pipeline | `app/services/manufacturing_service.rb` | Active |

### The Boundary Between Generation and Simulation

StarSim generates the initial cosmic canvas and system-generation data, including stars, planets, orbital elements, and initial body properties. Its generated seed/output is the baseline for a system; downstream simulation must not rewrite that original generation record.

TerraSim is responsible for calculating environmental conditions and their evolution over time, including modeled atmospheric composition, temperature, climate, hydrology, and other environmental processes. The live/persisted planetary state may therefore evolve under TerraSim; it must not be confused with the immutable historical StarSim generation seed.

Unit-level simulation operates within the generated and evolving world via tick-driven entities. Units read relevant celestial/environmental properties for their operations, but do not directly rewrite the StarSim seed or independently take ownership of planetary environmental evolution. The exact service/model interfaces between StarSim, TerraSim, and other systems require code-level validation.

### Ongoing celestial motion and spatial-position updates — ESTABLISHED INTENT (owner, 2026-11-24)

StarSim must eventually do more than generate a system's initial arrangement. Stars, planets, moons, and other orbiting celestial objects move as simulation time advances; their positions must not remain fixed at their generation-time values.

- **Generation remains the baseline:** StarSim's original generated seed/output records the initial system configuration and orbital data. Runtime movement must not rewrite that historical generation record.
- **Runtime position advancement:** StarSim is responsible for calculating updated celestial positions from the elapsed **game-clock time** and the system's orbital/dynamical data. This includes stellar motion in multiple-star systems as well as planetary and other satellite/orbital motion around their appropriate parent bodies.
- **Background processing:** The intended direction is a background job/process that performs these updates when simulation processing capacity is available, including idle time. Position calculation must not depend on a page load, API poll, or browser animation. The exact job framework, scheduling cadence, batching, and update frequency remain implementation decisions.
- **Game-time intervals:** Each update must account for the actual game-time interval since the last successfully applied position update. It must use the authoritative game clock, not treat wall-clock elapsed time as the simulation timeline. Delayed work and deliberate pre-Snap time advancement must not leave positions permanently stale or cause an interval to be applied twice.
- **Authoritative spatial state:** Calculated positions update each object's active `Location::SpatialLocation` coordinates (X/Y/Z) in the appropriate spatial context/reference frame. The original generation seed remains historical input; `SpatialLocation` represents the evolving current position.
- **System-specific reference frames:** The active coordinate frame and origin must be explicit for each system. A primary-star origin is appropriate where defined; a barycenter or other origin is appropriate for systems whose architecture requires it. Consumers must not assume every system is heliocentric or that every multi-star system uses the same origin convention.
- **Hierarchical systems:** Position calculations must respect the system's actual stellar and orbital hierarchy. For example, a multiple-star system cannot be modeled accurately by treating every star as independently stationary while only moving its planets. The available orbital data may be incomplete, so missing elements must remain unresolved rather than being replaced with invented positions or dynamics.

The API should expose the latest authoritative spatial positions and their coordinate-frame/context metadata. Space views and other consumers render those positions; JavaScript may interpolate visually between updates, but it must not become a competing orbital simulator or source of authoritative coordinates.

**Implementation status:** This is future design intent, not a claim that StarSim currently advances celestial positions. Current generation establishes initial objects and orbital data; ongoing position calculation/update behavior remains to be implemented and validated. The required fidelity and numerical integration approach remain OPEN.

---

### Generated-world plausibility, survey calibration, and ongoing spawning

**DESIGN DIRECTION:** A generated system should make reasonable physical and astronomical sense when it is created. If its initial state is implausible enough that the world does not make sense, the generator or the generated data may need adjustment before the system is used. This is a plausibility threshold, not a requirement that every generated value be complete, precise, or mutually consistent.

Early generator output and systems produced by early test runs remain useful starting data. Imperfect values do not automatically make a generated system bad, and the project does not need to correct every discrepancy up front while the generator is still being tuned. Preserve the original generation output as historical source data; do not silently rewrite it to make later observations agree.

**SURVEY GAMEPLAY DIRECTION:** Survey missions are part of how a system becomes better characterized during exploration and buildout. Survey work may flag values or relationships as inconsistent, gather additional observations, and recalibrate affected estimates toward more realistic values when the evidence supports doing so. A survey is not guaranteed to resolve every discrepancy: measurements may remain uncertain or conflicting. The exact confidence model, data records, and recalibration implementation remain open for design and code review.

**REMAINING WORK — initial-property calculation and survey-data integration (OPEN):** Inspect the StarSim generation and system-loading paths to identify which planetary properties can be calculated or materially improved from already available stellar, orbital, and body inputs. Where practical, calculate or refresh those derivable values when a system is loaded/initialized rather than requiring a player survey to establish facts the model can already determine. Do not silently rewrite the original generated JSON/seed; retain it as the historical source and keep any accepted calculated/refined values in the appropriate active body/system state with their source and calculation provenance.

Survey missions must be able to add observations that improve properties StarSim cannot determine reliably from the initial inputs alone. The AI Manager may coordinate survey priorities and evaluate returned evidence, or a dedicated supporting service may perform calibration and reconciliation. That ownership and the actual runtime pipeline are **not yet established** and require inspection of existing survey, mission, model, lookup/loading, and AI Manager code. The completed capability must preserve the observations and their provenance/uncertainty separately from the currently accepted body properties, then update the active system maps and relevant celestial-body properties when evidence justifies a change. Conflicting or inconclusive observations must remain visible as uncertain rather than being forced into a single unquestioned value.

This work is a refinement capability, not a gate on using early generated systems. A system with plausible but incomplete or test-generated values can enter play and be explored; do not require exhaustive scientific correction before system selection, landing-page display, or ordinary progression.

Keep these concepts distinct:
- the original generated seed/output, retained as the historical generation baseline;
- the evolving modeled world state, which may be refined as evidence and simulation advance;
- surveyed observations and the level of confidence or consistency associated with them.

The game should not treat every mismatch in early generated data as a defect that must be repaired before play. It should support an initially plausible world whose details can be improved through surveys as the system is explored.

**SURVEY-DRIVEN DISCOVERY AND POPULATION DIRECTION:** The initial system-generation output and map are not an exhaustive census of every object that may exist in a system. During gameplay, surveys can discover additional celestial objects that were not represented in the initial data and cause those objects to be spawned/instantiated in the active system and map. Their absence from the initial JSON or map is not, by itself, a data defect or evidence that the system is invalid. These discoveries become part of the evolving world; they do not require reconstructing or retroactively completing the original generated file. The exact runtime service ownership and lifecycle implementation remain OPEN as described above.

---

## 2. StarSim Code Reality (Verified Active)

### 2.1 Generation Entry Points

`SystemGeneratorService#generate!` branches on whether the solar system identifier exists in `Lookup::StarSystemLookupService`:

| Path | Condition | Behavior |
|------|-----------|----------|
| **Path A — Predefined System** | `system_exists?` returns true for this identifier | Delegates to `SystemBuilderService.new(name: @solar_system.identifier).build!`. Reads JSON from `SYSTEMS_PATH` and constructs ActiveRecord objects directly. |
| **Path B — Random Procedural** | Identifier NOT found in lookup service | Runs `ProceduralGenerator.generate_system_seed`, writes seed to `GENERATED_STAR_SYSTEMS_PATH` as `generated_{identifier}_{timestamp}.json`, updates solar system name/identifier, then calls `fallback_build`. |
| **Path C — Prize Target System** | Special generation mode | Ensures first 3 wormhole shift events produce a system containing at least one prize template planet (`TPL-A01` or `TPL-A05`) from `alien_world_templates_v1.1.json`. |
| **Path D — Accretion Mode** | `use_accretion: true` | `AccretionSimulationService` per star using dust disk model (inner 0.1 AU, outer 40 AU, band width 0.5 AU). Asteroids not produced by accretion mode. |

## StarSim Scope: System Generation and Additional Space Objects

**ESTABLISHED / CURRENT CODE:** StarSim procedurally generates stars and planetary systems. The current generation path includes several celestial-body categories; the active seed format and generation behavior are documented in [System Blueprints & Procedural Generation Spec](../astronomy/system_blueprints.md).

**DIRECTION:** StarSim may also be responsible for generating or populating additional objects in space that are not part of the major star-system generation pass. Examples include asteroids, comets, Kuiper Belt objects, Oort Cloud objects, and other small bodies. Preserve the distinction between initial system generation and any additional population process rather than assuming they must be one operation.

**OPEN:** The exact boundary between StarSim and a possible separate Spawning System is not settled. Nor is it settled whether additional object population is a one-time initial-generation operation or includes ongoing spawning, replenishment, migration, and lifecycle management. Do not treat those responsibilities as implemented or finalized merely because related object models or partial generation code exist.

### Resource generation ownership — OPEN

It is possible that StarSim should generate initial resource locations or distributions as part of world generation. Candidate examples include geological deposits on planets and moons, lunar permanently shadowed region (PSR) ice, and resources associated with asteroids or other small bodies. This is a design possibility requiring further planning, not a locked StarSim responsibility.

Keep the following concerns separate:
- initial generation of resource distributions and plausible deposit locations;
- survey-triggered discovery or placement of deposits not represented as confirmed data;
- total resource quantities, geological plausibility, and accessibility;
- extraction, depletion, replenishment, and economic use after generation.

Existing design material has assigned survey-triggered deposit placement to AI Manager. That is prior design direction and must be reconciled with the possible StarSim role; it does not settle the ownership question. Which system owns each concern—and whether responsibilities are shared across StarSim, TerraSim, AI Manager, or a separate resource/spawning service—remains OPEN.

---

### 2.2 ProceduralGenerator Configuration

Active parameters (verified via constructor):

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `force_complex_biosphere` | false | Forces complex biosphere detection for test/scenario worlds |
| `use_accretion` | false | Enable accretion-based body generation |
| `generate_biospheres` | true | Toggle biosphere generation |
| `biosphere_complexity` | :auto | One of: `:auto`, `:none`, `:primitive`, `:complex` |
| `seed_era` | :present_day | One of: `:present_day`, `:early_solar_system`, `:terraformed` |

**Constant:** `TERRAFORMABLE_CHANCE = 0.4` (40% chance for terraformable planets)

### 2.3 CelestialBody Model Contract

| Attribute | Type | Requirement | Description |
|-----------|------|-------------|-------------|
| `identifier` | String | **Required, unique** | Solar System identifier |
| `size` | Float | **Required** | Body size parameter |
| `gravity` | Float | ≥ 0, nullable | Surface gravity |
| `density` | Float | ≥ 0, nullable | Density (auto-calculated from mass/volume if not set) |
| `radius` | Float | ≥ 0, nullable | Radius in METERS |
| `orbital_period` | Float | ≥ 0, nullable | Orbital period |
| `mass` | String (numeric) | nullable, format-validated | Mass with scientific notation support |
| `known_pressure` | Float | ≥ 0, nullable | Atmospheric pressure at surface |
| `status` | enum | active(0) / mined_out(1) | Mining status |

**JSONB stores via store_accessor:**
- `properties`: `has_magnetosphere`, `preservation_mode`, `aliases`
- `orbital_elements`: `semi_major_axis`, `eccentricity`, `inclination`, `mean_anomaly`

**Spheres (one-to-one associations):** Atmosphere, Biosphere, Geosphere, Hydrosphere — all in `CelestialBodies::Spheres::` namespace.

The sphere models provide the data organization for a celestial body's detailed environmental and physical systems; they do not require every body type to have identical Earth-like properties or simulation behavior. The architecture is intended to accommodate different kinds of bodies and can be adjusted or extended as needed.

TerraSim models how these systems interact and evolve. Its purpose is broader than terraforming: natural-state simulation, historical calibration, environmental events, forward projection, and intentional modification are all within its intended role. The initial gameplay emphasis on terraforming does not make terraforming a prerequisite for simulation. See [TerraSim — Environmental Simulation, Calibration & Evolution](../technical/terrasim.md) for the canonical intent. Detailed sphere data ownership and interaction boundaries are documented in [Celestial-Body Sphere Models & Environmental Interactions](../technical/sphere_models_and_interactions.md).

Different body types may require different processes and sphere interactions. Ice-moon processes, for example, may involve an ice shell, subsurface ocean, rocky interior, tidal heating, and cryovolcanism. These are future modeling considerations to evaluate when relevant; they do not require immediate expansion or a separate simulation engine.

### 2.4 Star Naming Architecture (Active Code)

Verified from `star_naming_architecture.md` + CelestialBody code:
- **ID-primary design** — each star has a unique immutable ID
- **Alias support** — historical/cultural names map to primary ID
- **Scoped uniqueness by solar system** — duplicates allowed across systems but not within one
- **"Sol" special case** — permitted in multiple galaxies

### 2.5 Celestial Body Type Hierarchy

Active STI models under `CelestialBodies::`:

| Top-Level Type | Subclasses |
|----------------|------------|
| **star.rb** | Star records |
| **planet.rb** → | `planets/rocky/*` — CarbonPlanet, LavaWorld, RockyPlanet, SuperEarth, TerrestrialPlanet |
| **gas_giant.rb** | `planets/gaseous/GasGiant`, GaseousPlanet, HotJupiter, IceGiant |
| **ice_giant.rb** | Alias for ice giant classification |
| **moon.rb** | `satellites/Moon`, LargeMoon, SmallMoon, IceMoon |
| **brown_dwarf.rb** | Brown dwarf classification |
| **dwarf_planet.rb** | Dwarf planet classification |

Minor bodies under `CelestialBodies::MinorBodies::`:
- `asteroid.rb` — `comet.rb` — `kuiper_belt_object.rb` — `protoplanet.rb` — `dwarf_planet.rb`

Ocean planets: `HyceanPlanet`, `OceanPlanet`, `WaterWorld` (under `planets/ocean/`)

### 2.6 Geosphere Features System

Active STI models under `CelestialBodies::Features::`:
- `base_feature.rb` — Base with static_data JSONB column + lookup service fallback
- `canyon.rb` — `cave.rb` — `crater.rb` — `excavated_cavity.rb` — `lava_tube.rb` — `skylight.rb` — `valley.rb`
- `adapted_feature.rb` — Extended feature with static data priority (database → lookup service)

**Feature static_data priority:** Database column → `Lookup::PlanetaryGeologicalFeatureLookupService` fallback.

---

## 3. Biosphere Model & Life Detection (Active Code)

### 3.1 `CelestialBodies::Spheres::Biosphere` Model

| Attribute | Type | Requirement | Purpose |
|-----------|------|-------------|---------|
| `biodiversity_index` | Float | ≥ 0, ≤ 1 | Biodiversity measurement |
| `habitable_ratio` | Float | ≥ 0, ≤ 1 | Habitability ratio (auto-calculated if not set) |
| `biome_distribution` | Hash (serialized) | — | Biome area distribution |

**JSONB stores via store_accessor:**
- `base_values`: `base_temperature_tropical`, `base_temperature_polar`, `base_biodiversity_index`, `base_habitable_ratio`, `base_biome_distribution`

**Associations:**
- `belongs_to :celestial_body`
- `has_many :life_forms, class_name: 'Biology::LifeForm'` — active biological entities on this body
- `has_many :planet_biomes` — biome classification records
- `has_many :materials` — materials stored in the biosphere

**Simulation control:** `simulation_running` flag (attr_accessor). Updates run simulation via `after_update`.

### 3.2 Biosphere Detection Mechanism (Active Code)

The `ProceduralGenerator#initialize` accepts:
```ruby
biosphere_complexity: :auto   # or :none, :primitive, :complex
force_complex_biosphere: false
```

When `generate_system_seed` runs, the biosphere complexity parameter drives whether a biosphere sphere is generated and what biodiversity/habitability values it receives. The `BiosphereGeneratorService` produces these values procedurally.

### 3.3 ⚠️ CRITICAL GAP — Protection Classes Are NOT Code

**There is NO code implementing protection class classification on CelestialBody.** Specifically:
- **NO** `protection_class` column or attribute on CelestialBody or any sphere model
- **NO** `has_complex_life` or `has_microbial_life` boolean attributes
- **NO** classification logic mapping biosphere state → protection class
- **NO** runtime enforcement of extraction limits based on protection class

Protection Class hierarchy exists entirely as TARGET DESIGN INTENT in `docs/wiki/infrastructure/planetary_protection_environmental_governance.md`. See section 5 below.

---

## 4. Missing Hooks & Architectural Gaps (from MISSING_HOOKS.md)

| Missing Hook | Impact | Current State |
|--------------|--------|---------------|
| **Erosion State** — No persistent attribute for 'Erosion State' on CelestialBody or Geosphere models | Weathering engine intent from OVERVIEW.md cannot be implemented | Only a method for updating erosion rate in geosphere.rb (not full state) |
| **Radiolytic Decay** — No attribute or logic for radiolytic resource loss on any model | Resource degradation over time impossible | Not started |
| **Velocity Vectors for Interstellar Visitors** — No model/attribute for storing/updating velocity vectors | KBO/comet visitor simulation impossible | Not started |
| **KBO-to-Mars Logic** — No hook in system_builder_service.rb | Kuiper Belt Object transfer or impact logic blocked | Not started |
| **Terraforming Impact on Terrain** — No direct service/model hook for applying terraforming effects to terrain | Terraforming cannot modify surface models | Not started |
| **Dynamic Population** — No dynamic spawning/lifespan logic for transient objects in Rails models | Handled only in procedural generation, not persisted | Partially implemented |

---

## 5. Planetary Protection Classes (TARGET DESIGN INTENT ONLY)

> **⚠️ STATUS: TARGET DESIGN INTENT — NOT IMPLEMENTED IN CODE**
>
> The following classification hierarchy and enforcement rules exist exclusively as design documentation in `docs/wiki/infrastructure/planetary_protection_environmental_governance.md`. No code currently implements protection class assignment, life detection triggers, or extraction cap enforcement.

### 5.1 Classification Hierarchy

| Class | Trigger Criteria (Design Intent) | Governance | Extraction & Settlement Rules |
|-------|-----------------------------------|------------|-------------------------------|
| **Class-0** — Sanctuary World | `entity.has_complex_life == true` (detected multicellular flora/fauna) | SDC Orbital Interdiction | 100% extraction freeze; total settlement ban; science-only exclusion zone |
| **Class-1** — Regulated World | `entity.has_microbial_life == true` or `entity.subsurface_ocean == true` (extremophiles, prebiotic organics, ice-shell oceans) | Regional Authorities (e.g., Titan Development Commission) | Settlement permitted; regulated/capped extraction (e.g., Titan 5% volatile cap); bio-harvesting & hybridization unlocked |
| **Class-2** — Resource-Rich Industrial Zone | `entity.is_abiotic == true` + high commodity yield | Standard market rules | Standard extraction with environmental impact assessments |
| **Class-3** — Post-Terraforming Transition | Actively being terraformed but not yet self-sustaining | Limited extraction for operations only | No commercial exploitation permitted |
| **Class-4** — Fully Industrialized / Abiotic | Completed terraforming OR heavily modified/sterile environments, airless rocky bodies, metallic asteroids, inorganic atmospheres | Local Mining Guilds / Open Free Market | No planetary protection restrictions; bounded by physics only |

### 5.2 Sol System Governance (Design Intent)

| Body | Class | Governance Detail |
|------|-------|-------------------|
| **Titan** | Class-1 Prebiotic Hydrocarbon Reservoir | 5% total volatile extraction cap ±0.1% pressure tolerance; managed as closed-loop reservoir |
| **Venus** | Dynamic AI Manager policy toggle (Option A: Terraforming Reserve / Option B: Industrialized) | Policy evaluated by AutonomousConstructionManager; early terraforming abandoned when superior extra-solar targets found |

### 5.3 BCI (Bio-Contamination Incursion) Framework (Design Intent)

Three-phase contamination management:
1. **Pre-Deployment Screening** — Sterilization requirements, quarantine protocols
2. **Deployment Monitoring** — Sterilization budgets for thermal sweeps, radiation baths, sealed bio-barriers
3. **Post-Contact Assessment** — Raw volatile shipments from high-risk Class-1 must transit through quarantine nodes on cycler hubs before market clearance

> This framework references `NpcPriceCalculator` and `AutonomousConstructionManager` as intended downstream hooks but no code currently implements these integrations.

---

## 6. Fusion Torch Drive Naming Standard (IP Compliance)

### 6.1 Legacy Reference — PURGED

The term "Epstein Drive" has been removed from all active documentation to prevent IP/copyright friction. Legacy references that remain in frozen ore files (e.g., `docs/architecture/units/propulsion.md`, `docs/gameplay/EASTER_EGGS.md`, `data/json-data/missions/`) carry no operational authority.

### 6.2 Active Code Baseline: `methane_engine`

| Unit ID | Name | Thrust (kN) | Fuel Type | Isp (s) | Notes |
|---------|------|-------------|-----------|---------|-------|
| `methane_engine` | Methane Engine | 2000 | Methane/LOX | 350 | **Active code baseline** — standard chemical rocket for main reaction propulsion |

### 6.3 Fusion Torch Drive (Fusion Torch Drive / fusion_torch_engine)

| Unit ID | Name | Thrust (kN) | Fuel Type | Isp (s) | Status |
|---------|------|-------------|-----------|---------|--------|
| `fusion_drive_engine` | Fusion Drive | 2500 | Deuterium/He-3 | 5000 | **🟡 TARGET DESIGN INTENT — Unimplemented in Code** |

> **Note:** No code exists for `fusion_torch_engine`. The only fusion-class engine reference in the codebase is `fusion_drive_engine`, which appears as a data value but has no dedicated Ruby model, service, or active instantiation path. Use **Fusion Torch Drive** (`fusion_torch_engine`) exclusively in all future documentation to avoid IP concerns.

---

## 7. Active vs Target Design Map

### VERIFIED ACTIVE — Fully wired to live code

| Component | Location | Status |
|-----------|----------|--------|
| SystemGeneratorService entry point | `app/services/star_sim/system_generator_service.rb` | ✅ 4 generation paths verified (predefined, procedural, prize target, accretion) |
| ProceduralGenerator with biosphere complexity | `app/services/star_sim/procedural_generator.rb` | ✅ Constructor params all verified; biosphere_complexity = :auto/:none/:primitive/:complex |
| SystemBuilderService JSON → AR | `app/services/star_sim/system_builder_service.rb` | ✅ 15+ methods verified including determine_model_class, create_* record helpers |
| CelestialBody model + physics | `app/models/celestial_bodies/celestial_body.rb` | ✅ All validations, store_accessors, physics calculations (gravity, density, escape velocity, temperature) |
| Biosphere model + life tracking | `app/models/celestial_bodies/spheres/biosphere.rb` | ✅ biodiversity_index, habitable_ratio, biome_distribution; has_many :life_forms (Biology::LifeForm) |
| CelestialBody type hierarchy | `app/models/celestial_bodies/` + subdirs | ✅ Rocky, GasGiant, IceGiant, Moon, Star, BrownDwarf, DwarfPlanet, minor bodies, ocean planets |
| Geosphere features system | `app/models/celestial_bodies/features/` | ✅ 8 feature types with static_data priority (DB → lookup service) |
| Star naming architecture | Verified against code + docs | ✅ ID-primary, aliases scoped by solar_system_id, Sol allowed globally |

### 🔴 RETIRED / DO NOT USE

| Item | Location | Notes |
|------|----------|-------|
| Epstein Drive (naming convention) | Legacy docs only (`docs/architecture/units/propulsion.md`, `docs/gameplay/EASTER_EGGS.md`) | **PURGED** — replaced with Fusion Torch Drive in all new docs; legacy files carry no operational authority |

### 🟡 OPEN — Needs Owner Confirmation

| Item | Location | Description |
|------|----------|-------------|
| Protection Class classification logic | No active code | Code for `protection_class` attribute on CelestialBody, life detection triggers (`has_complex_life`, `has_microbial_life`), and extraction cap enforcement does not exist. Entirely TARGET DESIGN INTENT in planetary_protection_environmental_governance.md |
| Fusion Torch Drive (fusion_torch_engine) | No active code | Only data value exists as `fusion_drive_engine`. No dedicated model/service/instantiation path. Marked as target design intent — unimplemented |
| Erosion State persistence | No CelestialBody/Geosphere attribute | MISSING_HOOKS.md item #1 — critical for weathering engine; no implementation started |
| Radiolytic Decay persistence | No model/attribute | MISSING_HOOKS.md item #2 — no implementation started |
| KBO-to-Mars transfer logic | system_builder_service.rb | MISSING_HOOKS.md item #4 — no hook exists |
| Terraforming terrain impact service | Not started | MISSING_HOOKS.md item #5 — blocks surface model modification |

---

## 8. Cross-References

| Page | Relationship |
|------|--------------|
| [Starsim & Protection Classes](../astronomy/starsim_and_protection_classes.md) | Astrophysics / PPC physics expansion for StarSim-generated systems and planetary protection class frameworks |
| [System blueprints (astronomy)](../astronomy/system_blueprints.md) | Master spec for procedural system generation; this page covers StarSim + protection classes |
| [Unit & manufacturing blueprints](../engineering/unit_and_manufacturing_blueprints.md) | Unit tick-level execution — the micro-simulation that operates within the StarSim-generated canvas |
| [Scenario: Super-Mars](../astronomy/scenario_super_mars.md) | Stress-test scenario exercising moonless colonization, asteroid interception, orbital staging |
| [Planetary Protection & Environmental Governance](../infrastructure/planetary_protection_environmental_governance.md) | Complete protection class hierarchy (TARGET DESIGN INTENT — no runtime enforcement exists) |
| [Status and gaps](../status-and-gaps.md) | Tracks wiki coverage posture; this page fills the StarSim/protection gap |

---

## 9. Section Status

> **Code-grounded.** Sections 1–4 are verified against live code inspection of `galaxy_game/app/`. Section 5 documents TARGET DESIGN INTENT (protection classes) with clear separation from code reality. Section 6 enforces IP-compliant naming standards per governance directive. See section 7 for the complete active vs target design map.
