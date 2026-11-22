# Hydrosphere Water Inventories & Cross-Sphere Cycling

> **Status:** EXISTING MODEL AND WATER-CYCLE PATHS IMPLEMENTED; current behavior is simplified and contains distinct inventory representations  
> **Last audited:** 2026-11-21  
> **Code inspected:** StarSim hydrosphere generation and system construction; Hydrosphere model and concern; TerraSim hydrosphere simulation; terrain hydrosphere-volume service

## Purpose and boundaries

This page records the existing Hydrosphere model, its initial-state paths, the surface-water representation, and its exchanges with Atmosphere. The Hydrosphere is an established sphere in GalaxyGame. The work here is documentation and code-path verification, not a proposal to replace it or introduce another water inventory.

The Hydrosphere models liquid-envelope composition and distribution, including surface water bodies and ice-related state. Its generic-liquid design is broader than water, although the currently inspected TerraSim cycle is substantially H2O/surface-water oriented.

The main representations are related but not interchangeable:

- `total_water_mass` is the persisted aggregate scalar, exposed through the aliases `total_liquid_mass` and `total_hydrosphere_mass`.
- `water_bodies` (legacy alias `liquid_bodies`) stores the spatial/region categories such as oceans, lakes, rivers, ice caps, and subsurface.
- `composition` identifies the liquid material mixture.
- `state_distribution` stores solid/liquid/vapor state percentages in the inspected model and simulation paths.
- `liquid_materials` stores named material amounts associated with the Hydrosphere.
- Polymorphic `materials` are a separate associated-material representation.

See [Celestial Body & Sphere Data Model](celestial_body_and_sphere_data_model.md), [Celestial-Body Sphere Models & Environmental Interactions](sphere_models_and_interactions.md), and [Geosphere Materials & Stored Volatile Reservoirs](geosphere_materials_and_volatile_reservoirs.md).

## 1. Initial-state inputs and creation

### JSON-driven creation

`StarSim::SystemBuilderService#create_hydrosphere` builds the Hydrosphere directly from the supplied body JSON. It normalizes array-form composition entries into a compound → percentage hash and normalizes array-form state-distribution entries into a state → percentage hash before saving the association.

The loader preserves the supplied hydrosphere attributes; it does not itself create a set of liquid-material records from the composition percentages. The inspected method also contains a default H2O composition branch for missing composition data. Existing body JSON remains the authoritative source when explicit hydrosphere state is supplied.

### Procedural generation

`StarSim::HydrosphereGeneratorService#generate` is used by `StarSim::ProceduralGenerator` for procedurally generated planets. It:

1. Estimates an initial water mass as a fraction of body mass (the current helper uses 0.1% of body mass per Earth mass, capped at 10%).
2. Reads atmospheric H2O percentage and total atmospheric mass when present, estimates atmospheric water mass, and adds that to the estimated hydrosphere mass.
3. Generates surface water-body data based on temperature, pressure, radius, and the resulting mass.
4. Supplies a default H2O/dissolved-salts composition and a phase-state distribution.
5. Returns the generated hydrosphere hash for the procedural body data.

This is a separate procedural seeding path, not the JSON loader's behavior. The generated liquid-body volumes and the aggregate mass are distinct fields and must not be assumed to be numerically interchangeable.

**Verification item:** the procedural generator's aggregate hydrosphere estimate adds atmospheric H2O mass to the estimated initial water mass, while the Atmosphere sphere separately initializes that same atmospheric water from the atmospheric inventory. Verify the intended meaning of the generated hydrosphere mass and whether atmospheric vapor is intentionally included in the hydrosphere aggregate. Do not change the existing data contract based on this observation alone.

## 2. Hydrosphere data model

The model is `CelestialBodies::Spheres::Hydrosphere`. Its table stores `total_water_mass`, JSONB `water_bodies`, `composition`, `state_distribution`, and `base_values`, along with temperature and pressure. Compatibility aliases retain the older `total_liquid_mass` and `liquid_bodies` naming.

The Hydrosphere also has:

- `liquid_materials`: associated `CelestialBodies::Materials::Liquid` records;
- `materials`: polymorphic `CelestialBodies::Material` records through `MaterialTransferable`.

The model exposes generic-liquid methods such as `add_liquid` and `remove_liquid`, and a specialized `transfer_material`. These methods do not all update the same representations:

- `add_liquid` creates/updates a `liquid_materials` record, distributes the added amount across oceans/lakes/rivers using a fixed 70/20/10 split, increments the aggregate `total_liquid_mass`, and saves.
- `remove_liquid` reduces/destroys the named `liquid_materials` record and decrements the aggregate scalar. The inspected method does not reduce the corresponding regional `water_bodies` entries.
- `transfer_material` selects either a polymorphic `materials` record or a `liquid_materials` record, reduces that selected source record, and creates/updates a polymorphic target `materials` record. It does not demonstrate a matching update to the Hydrosphere aggregate scalar or regional `water_bodies` when the selected source is a `liquid_materials` record.

`update_hydrosphere_volume` sums the numeric volumes for oceans, lakes, rivers, and ice caps and writes that sum into `total_liquid_mass` (the `total_water_mass` database column). The regional values are named and handled as volumes, while the aggregate field is named and validated as mass. This method therefore deserves a unit-contract review before its result is treated as a physical mass in body-level mass accounting.

## 3. Regional water-body representation

The `water_bodies` JSONB hash supports region categories including:

- `oceans`
- `lakes`
- `rivers`
- `ice_caps`
- `subsurface` (with legacy `groundwater` accessor alias)

Entries may be numeric values or hashes containing a `volume` and additional metadata. The TerraSim hydrosphere simulation reads both numeric and hash-style values for oceans, lakes, and rivers. The model's water-coverage method also reads ice caps and groundwater/subsurface values.

The `ice` accessor reads `ice_caps`, including either a numeric value or a hash with `volume`. Its setter writes an ice-cap entry into the regional hash. The model has a helper to calculate aggregate regional volume and a separate helper for water coverage using body surface area.

The regional representation is not itself a discovered deposit or a Geosphere reservoir. Subsurface Hydrosphere water is distinct from water held in geosphere stored-volatiles; cross-sphere movement requires an explicit operation.

## 4. Atmosphere–Hydrosphere cycle

`TerraSim::Simulator#update_spheres` invokes `TerraSim::HydrosphereSimulationService` when a body has a Hydrosphere. The service currently requires both a Hydrosphere and an Atmosphere.

The inspected cycle:

1. Calculates regional water temperatures from body surface temperature and regional volume.
2. Calculates evaporation for oceans, lakes, and rivers and reduces those regional volumes.
3. Adds the evaporated amount to the Atmosphere as H2O gas.
4. Calculates precipitation from atmospheric H2O vapor and atmospheric temperature.
5. Removes precipitated H2O from the Atmosphere and distributes it into oceans, lakes, and rivers using a 70/20/10 split.
6. Reduces atmospheric dust in proportion to precipitation.
7. Adjusts the stored solid/liquid/vapor state percentages using a simplified temperature threshold.
8. Recalculates the aggregate Hydrosphere volume.
9. Applies a separate ice-melting routine when surface temperature is above approximately 273 K.

This is an existing cross-sphere exchange path: evaporation moves H2O from Hydrosphere to Atmosphere, and precipitation moves H2O back. These are internal transfers within the same celestial body, not additions or losses of planetary mass.

### Current simplifications and code-level caveats

- The service accepts `time_delta`, but the inspected cycle does not use it to scale the rates.
- The evaporation and precipitation rates are simplified coefficients rather than a calibrated climate/hydrology model.
- The phase-state routine changes fixed increments based on a 273 K threshold; the local pressure value is read but does not affect that decision.
- The ice-melting method reduces the `ice_caps` volume and adds a small H2O amount to the Atmosphere, but the inspected method does not add the remaining meltwater to ocean/lake/river volumes.
- The service's final `update_hydrosphere_volume` calls the model helper that sums regional volumes and writes the result to the aggregate field described above. That is a volume-to-mass naming/unit concern, not proof of a correctly converted mass total.
- The service mutates nested regional data in memory; persistence behavior depends on the surrounding model/save lifecycle. The inspected service does not explicitly save the Hydrosphere after each regional mutation in the shown cycle.

A further, distinct TerraSim::AtmosphereHydrosphereInterfaceService is invoked by PlanetUpdateService#process_sphere_interfaces. It computes a humidity estimate and stores it in Atmosphere temperature data. Its CO2/O2 exchange only logs calculated amounts; the actual gas-transfer calls are commented out. It also searches for an Atmosphere gas named Water, whereas the active TerraSim water cycle adds H2O; Gas names are normalized to chemical formulas, so the humidity vapor lookup may not find the H2O record. This interface service is not called by TerraSim::Simulator#update_spheres.
The model concern also contains a separate `hydrosphere_cycle_tick` path that calls its own evaporation and precipitation methods. The Hydrosphere model's `after_update` callback invokes that cycle unless `simulation_running` is set. This is distinct from the explicit TerraSim simulation service path and should be considered when tracing update-triggered behavior; do not assume the two implementations are identical or that only one can run.

## 5. Generic liquid support versus current simulation scope

The model and data structures are intended to support different liquid compositions, with material properties available through `Lookup::MaterialLookupService`. The `liquid_type` accessor selects the most abundant composition entry. The concern's phase helpers look up freezing and boiling temperatures for the primary liquid.

However, the inspected TerraSim simulation service explicitly looks for atmospheric `H2O`, adds/removes H2O gas, and uses water-oriented regional categories and ice melting. The generic model interface therefore should not be documented as proof that the active TerraSim cycle fully simulates methane, ammonia, or arbitrary multi-liquid hydrospheres.

## 6. Terrain water coverage is a separate representation

`TerrainAnalysis::HydrosphereVolumeService` operates on a terrain-map hash. Its `water_volume` value is a normalized 0–1 coverage-like fraction used with elevation data to derive sea level and rewrite terrain grid classifications. Its add/remove methods clamp that normalized value and return an updated terrain map.

This service does not update `Hydrosphere.total_water_mass`, `water_bodies`, or liquid-material records. It is a terrain-distribution/rendering operation, not the authoritative physical water inventory or a mass-transfer mechanism.

The legacy architecture document describes the older intended relationship between terrain decomposition and water coverage. The current code inspected here establishes the terrain-map behavior described above; do not equate normalized terrain `water_volume` with kilograms or cubic metres stored by the Hydrosphere.

## 7. Mass-accounting interpretation

- Hydrosphere regional volumes, aggregate scalar, composition percentages, phase percentages, and liquid-material records are different representations of related state; they must not be summed together as independent mass.
- Evaporation and precipitation are internal Atmosphere–Hydrosphere transfers. The body's combined mass should remain unchanged by the exchange itself.
- Melting is an internal phase/location change; it should not create or destroy planetary mass.
- Moving water from the Hydrosphere into a settlement, vehicle, or depot crosses the body's boundary and must reduce the source inventory while increasing the destination inventory.
- Importing water from another body increases the receiving body's inventory and decreases the source body's inventory.
- Terrain-map coverage changes alone do not constitute physical water addition or removal.

## 8. Open verification items

1. Establish the unit contract for `water_bodies[*].volume`, `total_water_mass`, and `liquid_materials.amount`. In particular, verify the use of `update_hydrosphere_volume` before relying on the aggregate scalar as kilograms.
2. Determine whether the procedural generator should include atmospheric H2O in the generated hydrosphere aggregate or keep atmospheric and hydrosphere inventories strictly separate.
3. Trace all callers of `add_liquid`, `remove_liquid`, `transfer_material`, and `setup_liquid_materials`; identify which representation is authoritative for each operation and whether associated records remain synchronized.
4. Confirm whether the Hydrosphere `after_update` callback's concern cycle and the explicit TerraSim cycle can both be triggered during normal updates, and document the intended owner of simulation ticks.
5. Verify persistence of nested `water_bodies` mutations in the TerraSim cycle, including ice melting and phase updates.
6. Verify the intended treatment of meltwater: the current ice-melting method removes ice-cap volume but does not visibly add the liquid portion to regional surface-water volumes.
7. Trace the relationship between Geosphere stored H2O reservoirs, any extraction/release operations, and Hydrosphere `add_liquid`; do not infer a cross-sphere transfer from shared substance identity alone.
8. Clarify whether non-H2O hydrospheres are expected to use the current TerraSim cycle or require separate material-aware exchange paths.

These are focused data-contract and call-path checks for the existing Hydrosphere implementation. They are not a request to create another water model.

## 9. Primary code inspected

- `galaxy_game/app/services/star_sim/system_builder_service.rb` — `create_hydrosphere`
- `galaxy_game/app/services/star_sim/hydrosphere_generator_service.rb`
- `galaxy_game/app/services/star_sim/procedural_generator.rb`
- `galaxy_game/app/models/celestial_bodies/spheres/hydrosphere.rb`
- `galaxy_game/app/models/concerns/hydrosphere_concern.rb`
- `galaxy_game/app/services/terra_sim/hydrosphere_simulation_service.rb`
- `galaxy_game/app/services/terra_sim/simulator.rb`
- `galaxy_game/app/services/terrain_analysis/hydrosphere_volume_service.rb`

Historical harvest sources consulted but not modified:

- `docs/architecture/simulation/hydrosphere_system.md`
- `docs/agent/tasks/completed/hydrosphere_concern_spec_fix.md`
