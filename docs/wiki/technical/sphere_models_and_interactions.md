# Celestial-Body Sphere Models & Environmental Interactions

> **Status:** PARTIALLY IMPLEMENTED — established model structure with TerraSim interactions requiring continued evaluation  
> **Last Audited:** 2026-11-14  
> **Code baseline:** `main` at `d4297134f4477d7fc9021a69f140d81c64d2b026`

## Purpose

This page describes how GalaxyGame organizes detailed planetary and environmental data and how TerraSim is responsible for modeling interactions among those systems.

The central `CelestialBody` is the common identity and physical/orbital reference for a world. Detailed environmental data belongs in the associated sphere models rather than being accumulated in the central body's general-purpose properties.

Sphere models describe the state and properties of their respective systems. TerraSim models the processes, exchanges, and evolution that connect those systems. These are related responsibilities, but they are not interchangeable.

See [TerraSim — Environmental Simulation, Calibration & Evolution](../terrasim.md) for the overall simulation purpose, reference-world calibration, and scope.

## 1. CelestialBody and sphere ownership

The current `CelestialBodies::CelestialBody` model defines optional one-to-one associations to:

- `CelestialBodies::Spheres::Atmosphere`
- `CelestialBodies::Spheres::Hydrosphere`
- `CelestialBodies::Spheres::Geosphere`
- `CelestialBodies::Spheres::Biosphere`

Each sphere belongs to its CelestialBody. A world can therefore carry detailed data in separate, appropriately scoped records. The central body retains shared identity and physical/orbital characteristics.

Do not assume every celestial body must have every sphere. Presence, absence, unknown state, and not-applicable state are different concepts and should not be collapsed into the same interpretation.

## 2. Sphere responsibilities

The following describes the current model organization, not a claim that every physical process is already simulated at scientific fidelity.

### Atmosphere

Stores atmospheric conditions such as pressure and temperature, temperature-related data, dust properties, and associated gas records. Gas composition and mass are represented through associated material records.

TerraSim processes can use atmospheric composition, pressure, temperature, stellar input, and atmospheric retention/loss when evaluating climate and exchanges with other systems.

### Hydrosphere

Stores liquid and frozen material inventories and distributions, composition, state distribution, temperature, pressure, and base-state data. The model includes generalized liquid naming and body fields such as oceans, lakes, rivers, ice caps, and subsurface material.

The model's data organization is broader than an Earth ocean model. However, the currently inspected simulation service remains substantially water- and surface-condition-oriented; see the implementation snapshot below.

### Geosphere

Stores geological composition and material inventories across crust, mantle, and core, geological and tectonic properties, volatile storage, and terrain-related data such as `terrain_map`.

The geosphere is not merely a terrain image. It represents the body's solid interior and geological materials as well as surface/geological state.

### Biosphere

Stores biological and ecological state, including biome relationships, life forms, biodiversity, and habitability-related values. Biomes are associated with a body through the biosphere's regional biome relationships.

Biosphere behavior depends on environmental conditions and can in turn affect atmospheric composition, soil, and other environmental state. Detailed ecosystem behavior and terraforming-specific gates should not be treated as universal requirements for every celestial body.

## 3. TerraSim and cross-sphere interactions

TerraSim is responsible for calculating how environmental systems interact and evolve. Examples include:

| Interaction | Example processes |
|---|---|
| Atmosphere ↔ Hydrosphere | Evaporation, condensation, precipitation, vapor exchange, and energy exchange |
| Geosphere ↔ Atmosphere | Volcanic gas release, weathering, atmospheric interaction, and volatile exchange |
| Geosphere ↔ Hydrosphere | Erosion, water-rock interaction, dissolution, and heat exchange |
| Biosphere ↔ Atmosphere | Photosynthesis, respiration, and biological gas exchange |
| Biosphere ↔ Geosphere | Soil formation, nutrient cycling, and biological weathering |
| Energy input ↔ multiple spheres | Stellar heating, internal heat, albedo, and coupled temperature response |

The list is illustrative, not a claim that every interaction is fully implemented.

Interaction rules must account for the body's physical nature and active configuration. They should not assume that every world is Earth-like or that all spheres participate in every process.

## 4. Different worlds, different interaction requirements

The sphere architecture is intended to represent a range of celestial-body compositions and configurations. TerraSim's processes must be appropriate to the body being modeled.

For example, an icy moon may have:
- a rocky interior that supplies internal heat;
- a thick surface ice shell;
- a liquid subsurface ocean;
- exchange between the interior, ocean, ice shell, and possibly a tenuous atmosphere;
- tidal heating and cryovolcanic activity.

This does not mean the initial terraforming-focused work must implement comprehensive ice-moon simulation. It means the model architecture should not force every world into terrestrial-planet assumptions, and TerraSim's interaction rules may need adjustment when those worlds become an active simulation use case.

The existing model fields and code include some ice-related concepts, such as subsurface hydrosphere data, ice-related geosphere behavior, and cryovolcanism paths. Their physical completeness and coupling are not established by their presence alone.

Do not introduce a separate Cryosphere model or another simulation engine solely by assumption. First determine whether the existing sphere data can represent the required state and which TerraSim processes are actually missing. Whether a distinct cryosphere data model is ever warranted remains OPEN.

## 5. Evidence and status conventions

Keep three categories separate throughout the TerraSim wiki:

1. **Implemented:** Behavior directly confirmed in current source code, with tests noted separately. Describe actual inputs, outputs, dependencies, simplifications, fallbacks, and stubs. A test that mocks a service proves orchestration or interface behavior, not physical accuracy.
2. **Established design intent:** Required behavior and architectural responsibilities that the project intends to support, whether or not the current code fully implements them.
3. **Future / aspirational:** Possible extensions, research directions, or capabilities not yet established as requirements. Keep these explicitly open and do not turn them into implementation commitments without approval.

Also distinguish **implemented** from **validated**. Existing calculations may run and have test coverage while still requiring parameter tuning, calibration, or scientific validation. Do not describe a capability as validated merely because a service, model field, or spec exists.

When documenting any TerraSim feature, identify its category and evidence. If implementation status is uncertain, say so rather than inferring it from names, model fields, old design documents, or test doubles.

## 6. Current implementation snapshot

This is a focused source inspection, not a complete scientific validation or test-suite result. It records observable code structure so that future tuning starts from what exists. The following entries describe **implemented behavior**, not a claim of scientific validation. The broader natural-world, historical-calibration, and generalization goals are **established design intent**; specialized ice-moon process coverage remains a **future evaluation area**, not an immediate implementation commitment.

### Orchestration

`TerraSim::Simulator#calc_current` updates a basic stellar-equilibrium temperature and gravity, then invokes available sphere services in a fixed sequence:

1. Atmosphere
2. Geosphere
3. Hydrosphere
4. Biosphere
5. Biosphere–Geosphere interface, when both spheres exist
6. Exotic-world simulation when the body reports exotic properties

The current calls do not pass a shared elapsed-time value through this orchestration. The ordering and coupling should be evaluated as TerraSim's time model and process dependencies are refined.

### Existing process coverage and limitations

- **Atmosphere:** Updates pressure from atmospheric mass, estimates greenhouse-adjusted temperature from selected gas masses, and applies a simplified stellar-distance/magnetosphere-based atmospheric-loss calculation. This is a starting implementation, not a validated climate or atmospheric-escape model.
- **Hydrosphere:** Contains basic regional temperature, evaporation, precipitation, phase-distribution, and ice-melting routines. The inspected service requires both a hydrosphere and an atmosphere, uses simplified coefficients and a 273 K phase threshold, and primarily processes surface water bodies and ice caps. The model's broader composition and subsurface fields are not evidence of complete generalized-liquid or subsurface-ocean simulation.
- **Geosphere:** Includes weathering-rate calculation using atmospheric and hydrosphere properties, regolith and erosion updates, tectonic behavior, volatile phase-transition hooks, and geological-event paths. Some exotic-world routines, including portions of cryovolcanism and other specialized processes, are explicitly stubs or placeholders.
- **Geosphere initialization:** `TerraSim::GeosphereInitializer` selects material configurations for terrestrial planets, carbon planets, ice giants, and gas giants. Unrecognized body classes fall back to a terrestrial-style composition, and geological-activity defaults include random values. The current initializer therefore does not establish a dedicated icy-moon composition simply because the body is a moon; this is a concrete area to review when that body type becomes a simulation target.
- **Biosphere:** Includes biome, vegetation, life-form, population, food-web, and atmospheric-effect routines. The inspected service also contains fallback atmospheric changes when no life forms are present; these simplified defaults require review before being relied upon for natural-world projections.
- **Tests:** TerraSim orchestration and individual sphere services have RSpec coverage. The inspected simulator spec mocks the individual sphere services, so its orchestration tests do not validate the physical accuracy of coupled planetary evolution.

The existence of services, fields, or specs must not be mistaken for a complete, scientifically calibrated model. Conversely, simplified or incomplete routines do not mean the overall architecture needs to be replaced.

## 7. Future evaluation questions

When the relevant simulation work is prioritized, evaluate:

1. Which sphere states are required, optional, unknown, or not applicable for each modeled body?
2. Are exchanges mass- and energy-consistent across sphere boundaries?
3. Are the process equations appropriate to the body's composition, gravity, pressure, temperature, stellar input, and internal heat?
4. Does the simulation propagate elapsed time consistently and preserve a coherent update order?
5. Can the same engine represent natural evolution, historical forcing, external events, and intentional interventions distinctly?
6. Which gaps are missing processes, inaccurate parameters, data-quality limitations, or uncertainty in planetary science?
7. Which body-specific behaviors can be expressed as configuration or process selection, and which genuinely require new model structure?
8. What is the authoritative meaning and unit of hydrosphere `state_distribution` (surface coverage, phase fraction, or another measure), and how should it represent vapor versus gas?
9. How should geosphere initialization handle moons and other body classes that do not match the current terrestrial/carbon/ice-giant/gas-giant cases?

These are evaluation questions, not immediate implementation tasks.

## 8. Scope boundary

The initial TerraSim development and gameplay emphasis has been planetary terraforming. The sphere models and their broader physical data are not limited to that use case.

Natural-world simulation and reasonable forward projection are foundational TerraSim goals. Historical calibration against Earth, Mars, and Venus helps tune the shared models. More specialized non-terraforming worlds, including ice moons, can be addressed when their simulation requirements are prioritized.

Preserve the existing modular sphere architecture, audit before redesigning, and extend the physical interactions deliberately rather than building replacement systems prematurely.
