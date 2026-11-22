# Celestial Body & Sphere Data Model

> **Status:** ESTABLISHED IMPLEMENTATION — core CelestialBody/sphere ownership and JSON-driven initial-state loading are present in the Rails 7 application. This page documents the existing model; it is not a proposal to rebuild it.
>
> **Code audit:** `main`, 2026-11-21

## Purpose

This page is the implementation-oriented reference for how GalaxyGame represents a celestial body and its planetary spheres, loads their initial state, and stores material inventories. It complements [Celestial-Body Sphere Models & Environmental Interactions](sphere_models_and_interactions.md), which focuses on TerraSim's environmental processes and the degree of cross-sphere simulation currently implemented.

The planetary model and sphere structure are established parts of GalaxyGame. They have evolved from the original celestial-body model into separate sphere records with their own attributes, material associations, and domain behavior. They may require tuning or correction as the game develops, but the existence of this architecture is not an open design question.

## 1. CelestialBody is the shared body record

`CelestialBodies::CelestialBody` is the shared identity and physical/orbital record. It owns common properties such as identifier, name, body type, mass, radius, density, gravity, surface temperature, orbital relationships, and other body-level properties.

The model defines one-to-one associations to:

- `CelestialBodies::Spheres::Atmosphere`
- `CelestialBodies::Spheres::Hydrosphere`
- `CelestialBodies::Spheres::Geosphere`
- `CelestialBodies::Spheres::Biosphere`

Each sphere belongs to its CelestialBody. The body also has material and location associations used by the wider game.

A sphere is a structured domain record, not simply a JSON section copied into a generic body-properties field. The sphere models own the detailed state appropriate to their domains. The CelestialBody remains the common reference point connecting those records.

The associations are declared as `has_one`; this does not mean every body must have a populated record for every sphere. Actual creation depends on the body-creation path and supplied data. The current model's `after_create` initialization creates a default atmosphere record and spatial location; StarSim's system builder then applies any supplied sphere data. Hydrosphere and geosphere records are created when their corresponding data is supplied. Biosphere data can be supplied explicitly or a biosphere can be created through the builder's surface-life viability path. Do not infer that an absent record means a known zero-valued sphere: absence, unknown state, and not-applicable state are distinct.

## 2. Sphere data ownership

### Atmosphere

The atmosphere record stores atmospheric conditions including pressure, temperature, temperature-related values, dust, pollution, and total atmospheric mass. Individual gas inventories are stored as associated `CelestialBodies::Materials::Gas` records.

The gas records carry the material identity, mass, molar mass, and percentage composition. The atmosphere's composition hash is also retained as a representation of composition, while the gas records provide the mass-based inventory used by the existing gas-management methods.

Important existing methods include:

- `initialize_gases`: creates gas records from composition percentages and `total_atmospheric_mass`;
- `add_gas` / `remove_gas`: modify individual gas masses and update the aggregate atmospheric mass and percentages;
- `calculate_pressure` / `update_pressure_from_mass!`: derive pressure from atmospheric mass, gravity, and body surface area;
- `transfer_material`: transfers atmospheric gas out to another sphere's material collection.

For JSON initialization, `StarSim::SystemBuilderService#create_atmosphere` accepts composition entries represented either as percentage values or nested percentage hashes. It normalizes them, passes the provided pressure, temperature, dust, and `total_atmospheric_mass` into the atmosphere record, and captures the supplied values in `base_values`. `initialize_gases` then calculates each gas's initial mass as its percentage of the supplied total atmospheric mass and resolves material properties through `Lookup::MaterialLookupService`.

The provided total atmospheric mass is therefore an intentional input to initialization; it is not inferred solely from the percentages. Composition percentages describe the relative shares of that total.

Runtime gas additions/removals update the Gas-record masses, aggregate atmospheric mass, and record percentages. The retained composition hash is not visibly synchronized by those ordinary operations. Pressure is derived from mass, gravity, and body surface area, but helper methods currently use differing pressure conversion assumptions. The simplified TerraSim greenhouse and solar-wind-loss behavior, including its bypass of normal percentage recalculation, is documented in [Atmosphere Gas Inventories & Evolution](atmosphere_gas_inventories_and_evolution.md).

### Hydrosphere

The hydrosphere record stores liquid-system state, including composition, state distribution, temperature, pressure, total liquid/water mass, and the `water_bodies` structure. The model exposes generic liquid-body accessors for oceans, lakes, rivers, ice caps, and subsurface reservoirs, with a groundwater compatibility alias.

The model also has associated `Liquid` material records and a general polymorphic material association. Its existing methods include liquid addition/removal and material transfer, as well as state-distribution and water-cycle helpers.

The current database attribute compatibility aliases include:

- `total_liquid_mass` → `total_water_mass`
- `total_hydrosphere_mass` → `total_water_mass`
- `liquid_bodies` → `water_bodies`

The model's generalized liquid naming is broader than water-only terminology. Actual simulation coverage and phase behavior are described separately in the TerraSim implementation snapshot; model flexibility must not be mistaken for complete simulation of every liquid or subsurface environment.

### Geosphere

The geosphere record stores the solid body's geological structure and materials. Its state includes crust, mantle, and core composition and mass, geological and tectonic properties, stored volatiles, and terrain/geological data such as `terrain_map` and plate information.

The geosphere has associated geological-material records and a polymorphic material association. Layer masses are represented separately as `total_crust_mass`, `total_mantle_mass`, and `total_core_mass`. Its domain methods include adding/removing materials by layer, extracting crustal material, transferring material, updating layer composition/percentages, and managing stored volatiles.

StarSim's `create_geosphere` loader normalizes the JSON `stored_volatiles` structure. A simple compound-to-amount entry is treated as crust storage; a compound mapped to a location hash preserves the named reservoir locations. The loader also converts legacy CO₂ reserve fields into named stored-volatile reservoirs. The geosphere model's stored-volatiles data therefore represents material held in geological reservoirs, not an atmospheric gas inventory. The detailed initialization, representation boundaries, current ISRU reads, transfer methods, and unresolved mass-consistency checks are documented in [Geosphere Materials & Stored Volatile Reservoirs](geosphere_materials_and_volatile_reservoirs.md).

The geosphere also supplies the solid-body surface-composition accessor through its crust composition. It is not merely a terrain-map container.

Its `terrain_map` stores the initial terrain/geographic dataset used by map and surface-view workflows, alongside (not instead of) its geological structure and material inventories. StarSim's automatic terrain generator persists the generated dataset to this field. See [Geosphere Terrain Data & Initial Surface State](geosphere_terrain_and_initial_surface_data.md) for the generation hierarchy, the separate Earth layer-import path, the Surface View adapter, and open provenance checks.

### Biosphere

The biosphere record stores ecological and habitability-related state, including biodiversity, habitability ratio, vegetation, biome distribution, and soil-related properties. It relates to biomes through `PlanetBiome`, and to life-form records through `Biology::LifeForm`. It also has a polymorphic material association.

The biosphere model includes operations for introducing/removing biome associations, calculating biodiversity and habitability, resetting to stored base values, and transferring associated material. Explicit JSON biosphere input is filtered to the supported biosphere attributes by the system builder. The distinction between generator output, persisted LifeForm/PlanetBiome records, biomass, and the current atmosphere/soil coupling paths is documented in [Biosphere Ecology & Cross-Sphere Interactions](biosphere_ecology_and_cross_sphere_interactions.md). When explicit biosphere data is absent, the builder may create a default biosphere if the body is considered capable of supporting surface life.

The presence of a biosphere record does not imply that a body has native life or that its ecosystem has been scientifically validated. The record can represent an initial ecological state, a seeded/introduced biosphere, or a state used during terraforming, subject to the actual data supplied.

## 3. Initial-state loading from system JSON

StarSim's `SystemBuilderService` is the primary inspected path for creating celestial bodies from system JSON. It creates the body record first, then creates associated sphere records from the relevant JSON attributes.

The inspected flow is:

1. Create the typed CelestialBody from body-level attributes, excluding association payloads that are handled separately.
2. Create or attach the atmosphere from `atmosphere_attributes` (or the supported atmosphere alias).
3. Create the hydrosphere from `hydrosphere_attributes` (or its supported alias), normalizing composition and state-distribution arrays into hashes where necessary.
4. Create the geosphere from `geosphere_attributes`, preserving and normalizing stored volatile reservoirs.
5. Create body-level material records when a `materials` payload is supplied.
6. Create an explicit biosphere from `biosphere_attributes` / `biosphere`, or create a default biosphere when the body passes the builder's surface-life viability check.
7. Generate automatic terrain when the builder's terrain-generation conditions call for it.

The loader also recognizes an already-existing body and can add missing atmosphere, hydrosphere, or geosphere records when corresponding source data is supplied. The inspected existing-body branch does not show equivalent biosphere backfill in that branch; do not assume every sphere is automatically reconciled on every repeat load.

### Initial values and base values

Some sphere models retain base-state attributes for reset or comparison behavior. Atmosphere initialization explicitly snapshots the initial atmosphere values into `base_values`. Hydrosphere and biosphere expose base-value fields for their own reset methods; geosphere also stores base values, including base volatile data.

These are sphere-specific mechanisms, not a single universal snapshot service. Their exact population and reset coverage depend on the loader and model path. A field or reset method alone is not proof that every initial attribute is captured or restored; verify the relevant code path before relying on it.

## 4. Material inventories and transfers

GalaxyGame uses domain-specific material records and polymorphic material associations to represent inventories associated with a body or sphere. These are persistent records, not merely display summaries.

The principal ownership pattern is:

- Atmosphere: gas records with mass-based composition.
- Hydrosphere: liquid-material records and associated material records, alongside aggregate hydrosphere state. Its aggregate, regional, composition, phase, and liquid-material representations and their relationships are detailed in [Hydrosphere Water Inventories & Cross-Sphere Cycling](hydrosphere_water_inventories_and_cycle.md).
- Geosphere: geological materials associated with crust/mantle/core layers and stored volatile reservoirs.
- Biosphere: associated materials, biome relationships, and life-form records.
- CelestialBody: body-level materials used by broader material-management and game systems.

Sphere models include transfer methods, and the shared `MaterialTransferable` concern provides a common transfer path with special handling for atmosphere and hydrosphere targets. Some sphere classes also define specialized transfer methods. These are existing mechanisms to reuse when tracing a material pathway; they should not be bypassed by creating parallel inventory ledgers.

A transfer between spheres on the same body is an internal redistribution: the source inventory decreases and the destination inventory increases. It does not represent newly created planetary mass. Extraction from a sphere into an external craft, settlement, or depot crosses a body boundary and must be reflected in the source and destination inventories by the relevant operational transfer path. Venting material from an atmosphere to space is an outward loss, not an internal sphere transfer.

The code contains multiple material representations and transfer implementations. Do not assume every path updates every aggregate field identically or that the presence of a transfer method proves all cross-sphere transfers are fully mass-conserving. When documenting a concrete operation, trace its actual caller, source record, destination record, aggregate updates, and transaction boundary.

## 5. Planetary mass and accounting semantics

Sphere records expose aggregate mass values for their domains, and `CelestialBody#calculate_total_mass` currently computes a value by adding:

- the CelestialBody `mass` attribute;
- `atmosphere.total_atmospheric_mass`;
- `hydrosphere.total_hydrosphere_mass`;
- geosphere crust, mantle, and core masses.

That is the exact formula in the inspected method. The intended semantic meaning of the body-level `mass` field relative to the sphere mass totals is not established by that method alone. In particular, system JSON may provide a bulk planetary mass while also providing sphere-level breakdowns. The relationship must be verified against authoritative JSON conventions, mass-validation callers, and the relevant tests before this calculated value is treated as a physically authoritative total. This is a documented semantic question, not a recommendation to replace the existing mass model.

The accounting principle for gameplay remains important: a material deposit or sphere reservoir is an inventory of matter already belonging to its host body. Discovering or lazily materializing a deposit does not create new planetary mass. Moving material between a body's internal reservoirs is redistribution. Moving material off the body changes the body's mass and the destination's inventory. The implementation path must be checked to confirm that each concrete operation updates the intended records and aggregates.

## 6. What is established, and what still merits verification

### Established by the inspected code

- CelestialBody owns separate one-to-one sphere associations.
- Atmosphere, hydrosphere, geosphere, and biosphere have distinct model classes and domain-specific state.
- System JSON is used to initialize sphere records through StarSim's builder.
- Atmospheric gas records are initialized from supplied composition percentages and total atmospheric mass.
- Hydrosphere stores generalized liquid composition/state and liquid-body structures.
- Geosphere stores layered mass/composition and location-specific volatile reservoirs.
- Biosphere stores ecological state and associations to biomes and life forms.
- Sphere and shared material-transfer methods exist and are used as the current inventory-transfer architecture.

### Verification and tuning questions (not missing architecture)

1. Confirm the authoritative semantic contract for body-level `mass` versus the sum of sphere masses, including the use of `calculate_total_mass` and `validate_mass_conservation`.
2. Trace each operational extraction/export/venting caller to establish whether source, destination, and aggregate mass values are all updated consistently.
3. Confirm which base-state fields are populated for each sphere by each supported initialization path and what each reset operation restores.
4. Review legacy and current JSON schema variants so compatibility aliases and normalization behavior remain explicit.
5. Continue tuning and validating the physical calculations and cross-sphere processes documented in [Celestial-Body Sphere Models & Environmental Interactions](sphere_models_and_interactions.md).

These questions concern semantics, call paths, coverage, and calibration around an existing model. They do not imply that the sphere architecture or its basic inventories need to be recreated.

## 7. Source map

Primary implementation inspected for this page:

- `galaxy_game/app/models/celestial_bodies/celestial_body.rb`
- `galaxy_game/app/models/celestial_bodies/spheres/atmosphere.rb`
- `galaxy_game/app/models/celestial_bodies/spheres/hydrosphere.rb`
- `galaxy_game/app/models/celestial_bodies/spheres/geosphere.rb`
- `galaxy_game/app/models/celestial_bodies/spheres/biosphere.rb`
- `galaxy_game/app/models/concerns/atmosphere_concern.rb`
- `galaxy_game/app/models/concerns/hydrosphere_concern.rb`
- `galaxy_game/app/models/concerns/geosphere_concern.rb`
- `galaxy_game/app/models/concerns/biosphere_concern.rb`
- `galaxy_game/app/models/concerns/material_transferable.rb`
- `galaxy_game/app/models/concerns/material_management_concern.rb`
- `galaxy_game/app/services/star_sim/system_builder_service.rb`

Related documentation:

- [Celestial-Body Sphere Models & Environmental Interactions](sphere_models_and_interactions.md)
- [TerraSim — Environmental Simulation, Calibration & Evolution](terrasim.md)
- [StarSim architecture](../design/starsim_and_protection_classes.md)
