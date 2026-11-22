# Atmosphere Gas Inventories & Evolution

> **Status:** source-verified implementation snapshot — Rails 7 application, `main`, 2026-11-22. This page documents the existing planetary Atmosphere model and its active code paths; it does not propose a replacement architecture.

## Scope and model boundary

The planetary atmosphere is `CelestialBodies::Spheres::Atmosphere`, associated one-to-one with a `CelestialBody`. It is distinct from the top-level `Atmosphere` model used for enclosed/artificial environments associated with a celestial body, craft, or structure. Do not conflate their gas associations or assume that a planetary atmosphere is sealed.

The planetary record stores pressure, temperature, total atmospheric mass, composition, temperature data, dust, and pollution. It has:
- a `gases` association to `CelestialBodies::Materials::Gas`, the per-species mass inventory;
- a polymorphic `materials` association, used by generic material-transfer paths;
- temperature accessors for effective, greenhouse, polar, and tropical values.

`CelestialBodies::Materials::Gas` stores the chemical formula as `name`, plus `mass`, `molar_mass`, `percentage`, and optional `ppm`. Its validation and normalization callbacks resolve material properties and normalize names to chemical formulas.

## Initial state and gas inventory creation

The inspected JSON path is `StarSim::SystemBuilderService#create_atmosphere`:
1. Read the supplied composition hash. A nested entry is reduced to its `percentage`; scalar percentages are retained.
2. Pass composition, pressure, temperature, dust, and `total_atmospheric_mass` to the body-built Atmosphere record.
3. Preserve those supplied values in `base_values`.
4. Save the atmosphere, then call `initialize_gases`.

`initialize_gases` calculates each gas mass as `percentage / 100 × total_atmospheric_mass`, resolves its chemical formula and molar mass through `Lookup::MaterialLookupService`, creates Gas records, and recalculates percentages from the resulting records.

The supplied total atmospheric mass is therefore the mass basis for JSON initialization; percentages alone do not determine an absolute inventory. The Gas records are the mass-bearing representation used by the current gas-management methods. The Atmosphere `composition` hash is also retained, but the inspected `add_gas` and `remove_gas` methods recalculate Gas-record percentages without synchronizing that hash. Treat it as an initialization/parallel composition representation unless a specific consumer is shown to refresh it.

The concern's default-value fallback has a separate `calculate_total_mass` path that iterates composition entries as though each value contains a `percentage` key and combines that with molar mass. This is not the same calculation as JSON initialization from a supplied total mass, and it is not a physically complete mass derivation from percentages. The inspected JSON builder supplies `total_atmospheric_mass` directly; the fallback path and its expected composition shape require further verification before relying on it.

## Additions, removals, and aggregate mass

`AtmosphereConcern#add_gas(formula, amount_kg)`:
- validates a nonblank known gas and positive amount;
- resolves the canonical chemical formula;
- creates or increments the matching Gas record;
- updates total atmospheric mass from the sum of Gas-record masses;
- recalculates each gas percentage and ppm.

`remove_gas(formula, amount_kg = nil)`:
- resolves the formula and requires an existing Gas record;
- removes the requested mass (or the entire record when no amount is supplied);
- rejects negative or over-inventory removal;
- destroys near-empty records or saves the reduced mass;
- recalculates aggregate mass and percentages.

The aggregate `total_atmospheric_mass` is thus recomputed from the Gas records by these methods. `recalculate_gas_percentages` uses the stored aggregate and updates each record's percentage and ppm. If there are no gas records or the aggregate is zero, it returns without assigning replacement percentages.

The Atmosphere model's `after_save` tracking callback calls the CelestialBody mass-conservation validation hook when total atmospheric mass changes. This callback is not itself the gas inventory update mechanism.

## Pressure and other derived properties

`calculate_pressure` derives pressure from total atmospheric mass, surface gravity, and spherical surface area:

`pressure = (total_atmospheric_mass × gravity) / (4π × radius²)`

The result is converted from pascals to atmospheres by dividing by 101325. `update_pressure_from_mass!` persists that result. The code comments describe pressure in atmospheres in the default-value path.

The model also derives gas-mixture properties from Gas records:
- average gas constant, weighted by gas mass fractions and material properties;
- average molar mass, weighted by gas mass fractions;
- density from pressure, temperature, and the calculated gas constant;
- scale height from temperature, mean molar mass, and gravity.

There are unit conventions that need careful review before treating every helper as mutually consistent: the pressure calculation explicitly returns atmospheres, while the density helper multiplies pressure by 100000 (a bar-to-pascal-style conversion), and `calculate_atmospheric_mass_for_volume` converts an input pressure from kPa by multiplying by 1000. The code paths do not establish one globally enforced pressure unit contract.

The model's `habitable?` method is a simple threshold check on pressure, O₂, CO₂, and temperature. It is a gameplay screening helper, not a complete human-life-support or toxicology model.

## TerraSim atmospheric update

`TerraSim::Simulator#update_spheres` calls `AtmosphereSimulationService#simulate` when the body has an Atmosphere. The inspected service sequence is:
1. Recalculate pressure from atmospheric mass.
2. Calculate a simplified greenhouse temperature from albedo, stellar input, and selected gas masses.
3. Persist effective, greenhouse, polar, and tropical temperature values and update the body's surface temperature.
4. Apply simplified solar-wind-related atmospheric loss to each gas.
5. Decrease atmospheric dust by a fixed amount.

The greenhouse calculation uses CO₂, CH₄, and a calculated water-vapor-pressure term. Although N₂O is listed in `GREENHOUSE_GASES` and gas data is gathered for it, the temperature expression does not use its mass. The water-vapor term is calculated from a fixed relative-humidity assumption rather than directly using the stored H₂O gas mass. The temperature loop repeats 100 times but has no convergence test; the resulting temperature is clamped before persistence.

Atmospheric loss is a simplified heuristic:
- a magnetosphere returns a near-zero loss factor;
- otherwise, stellar distance sets an inverse-square solar-wind factor, with a fallback if distance is missing;
- fixed species multipliers adjust the loss fraction by gas name;
- each Gas record's mass is reduced with `update_columns`, then `total_atmospheric_mass` is directly reset to the sum of remaining gas masses.

This path does not call `remove_gas`. It therefore does not run the normal percentage/ppm recalculation after loss. It also deliberately bypasses the Atmosphere save callbacks. Pressure is left for a later simulation update to recalculate. The `days` argument accepted by `simulate(days = 1)` is not used to scale pressure, greenhouse, loss, or dust operations in the inspected implementation.

This is evidence of an existing atmospheric-loss mechanism, but it is not a validated atmospheric escape model. It is materially simpler than the species/mechanism-specific intent recorded in [Atmospheric Escape, Retention & Recovery](../infrastructure/atmospheric_escape_and_recovery.md). In particular, the current code uses a single stellar-distance/magnetosphere factor and a small set of fixed species multipliers; it does not implement the full range of escape mechanisms or a distinct upper-atmosphere recovery path described as future options in that design page.

## Cross-sphere and body-to-body transfer paths

Several distinct mechanisms touch atmospheric gas. They do not share one transfer implementation.

### Same-body Hydrosphere exchange

TerraSim::HydrosphereSimulationService performs the active H2O cycle: evaporation reduces ocean/lake/river regional values and calls Atmosphere#add_gas('H2O', amount); precipitation calls remove_gas('H2O', amount) and distributes the returned amount into those regions 70/20/10. Its ice-melting path also adds some H2O to Atmosphere, but the remaining meltwater is not visibly added to surface-water regions. See [Hydrosphere Water Inventories & Cross-Sphere Cycling](hydrosphere_water_inventories_and_cycle.md).

A separate TerraSim::AtmosphereHydrosphereInterfaceService is called by PlanetUpdateService#process_sphere_interfaces, after its sphere updates. It calculates a humidity value and stores it in Atmosphere.temperature_data. Its gas-exchange method only calculates/logs prospective CO2 and O2 transfers; the actual Hydrosphere absorb/release calls are comments, so it does not currently transfer those gases. It looks up atmospheric vapor by the name Water, while the active Hydrosphere service uses H2O; because Gas names are normalized to chemical formulas, this lookup can miss the active vapor record. The interface service is not called by TerraSim::Simulator#update_spheres.

The Hydrosphere model concern has another evaporation/precipitation implementation, invoked by its after_update callback. It changes the Hydrosphere aggregate scalar and Atmosphere gas inventory, but is distinct from the TerraSim regional-volume cycle. See the Hydrosphere page for callback and representation caveats.

### Same-body Biosphere exchange

Two separate Biosphere paths modify Atmosphere:
- BiosphereConcern#respond_to_atmospheric_changes estimates CO2 absorption and O2 production from gas percentages and biodiversity, converts the percentage changes to mass, then calls remove_gas('CO2') and add_gas('O2').
- BiosphereSimulationService#influence_atmosphere derives O2/CO2/CH4 changes from populated LifeForm contributions (or fallback rates), computes target masses for O2, CO2, CH4, N2, and Ar from the current total atmospheric mass, then applies gas-record mass deltas with add_gas/remove_gas.

The service collects N2-fixation and soil-improvement contributions but does not apply them in this atmospheric update. Its gas conversion is a simplified percentage-to-mass adjustment, not a complete chemical/elemental balance. The Biosphere model's after_update callback also runs its concern simulation unless simulation_running is set, so callback-driven exchange is distinct from the explicit TerraSim service. See [Biosphere Ecology & Cross-Sphere Interactions](biosphere_ecology_and_cross_sphere_interactions.md).

### Same-body Geosphere volatile release and processing

GeosphereConcern#extract_volatiles reads crust_composition['volatiles'], calculates a temperature-dependent release, calls Atmosphere#add_gas, reduces the corresponding crust-composition percentage, and updates a polymorphic Material record. It does not visibly reduce total_crust_mass, so the release is not demonstrated as a fully mass-balanced layer-to-atmosphere transfer.

Call-site tracing did not find a production caller of GeosphereConcern#extract_volatiles; the inspected direct callers were specs. The production HasProcessing#thermal_extract_volatiles path is separate: it reads the same crust volatile percentages, consumes settlement/unit regolith, and stores estimated volatile outputs in unit buffers. It does not call GeosphereConcern#extract_volatiles, decrement the Geosphere volatile composition, or add the outputs to the planetary Atmosphere. Do not treat the two methods as one connected extraction pipeline. See [Geosphere Materials & Stored Volatile Reservoirs](geosphere_materials_and_volatile_reservoirs.md).

### Generic sphere transfer methods

- Atmosphere#transfer_material removes a named gas and creates a generic polymorphic Material record on the target sphere. It does not create a target Gas record, so it is not a direct Atmosphere-to-Atmosphere transfer.
- MaterialTransferable#transfer_material decrements a source polymorphic Material record and dispatches to target.add_gas for an Atmosphere, target.add_liquid for a Hydrosphere, or a target Material record for other spheres. This is the generic path that explicitly recognizes an Atmosphere target.
- Geosphere#transfer_material uses geological_materials.mass and creates/updates a target polymorphic Material record. It does not special-case an Atmosphere target to create a Gas record. The source representation and target inventory type therefore matter when choosing a transfer method.

These methods are not interchangeable. A method that creates a generic Material row on an Atmosphere does not automatically populate the Atmosphere Gas association used by pressure, composition, and gas-management methods. A repository-wide call-site search found no production invocations of the sphere-level transfer_material methods; the visible direct calls were in specs. The body-to-body AtmosphericTransferService has separate production callers, but that does not establish that the generic sphere-transfer APIs are part of the normal runtime material flow.

### Body-to-body atmospheric transfer

TerraSim::AtmosphericTransferService has production call sites in TerraformingProject#process_atm_transfer and the Venus-Mars pipeline Rake task. It supports three modes:

- **Raw:** extracts a capacity-limited amount proportionally across source gas percentages. The source cap is 5% for Titan, unlimited by percentage for Venus, and 20% for other bodies. It removes the extracted mass and adds 98% by default to the target; the difference is not returned or assigned.
- **Selective:** applies the same source-specific caps per gas and delivers the requested gases at the configured/default 98% efficiency.
- **Processed:** extracts CO2 and N2, each capped at 0.5% of its source-gas mass per call. It applies a simplified CO2 -> CO + 1/2 O2 mass ratio (16/44 O2 and 28/44 CO) at default 95% processing efficiency, returns CO to the source, and delivers O2 and N2 to the target at default 98% transport efficiency. Conversion and transport remainders are not assigned to a modeled byproduct/loss inventory in this service.

After transfer, the service recalculates source and target pressures from their atmospheric masses. These are inter-body transfers, not same-body sphere exchanges. The active code and actual selected mode take precedence over older design-page limits or descriptions.

AtmosphericTransferService also contains a separate perform_transfer helper with a hardcoded 98% delivery factor; the inspected primary mode dispatcher uses the three methods above. Do not assume this helper is the path used by every caller.

## Mass-accounting interpretation

- Gas-record masses are the per-species Atmosphere inventory used by normal gas-management and transfer services.
- Same-body evaporation/precipitation and Biosphere gas exchange are intended as internal body exchanges, but their counterpart sphere representations and callbacks must also be updated for strict conservation.
- Geosphere volatile release currently reduces composition percentage and a polymorphic Material amount but does not visibly reduce aggregate crust mass.
- Generic Material transfer and Gas-record transfer are different operations. A target Atmosphere needs a Gas record for its atmospheric pressure/composition calculations.
- Body-to-body transfer removes mass from the source and adds delivered mass to the target; conversion/transport differences are unassigned in the inspected service.

## Sphere interfaces, orchestration, and game-loop entry points

The repository contains multiple sphere-update implementations. Their presence in code does not mean all are invoked by the same game tick.

### Root PlanetUpdateService path

The root `PlanetUpdateService#run` (not the namespaced `TerraSim::PlanetUpdateService`) processes Atmosphere, Geosphere, Hydrosphere, and Biosphere in sequence. Its detailed and progressive steps then call `process_sphere_interfaces`, which runs:
- `TerraSim::AtmosphereHydrosphereInterfaceService` when both spheres exist;
- `TerraSim::BiosphereGeosphereInterfaceService` when both spheres exist.

The model-level `Game#process_planets` method calls this root service. The separate `GameService#process_planets` method also calls it.

However, `GameService#advance_by_days(days, update_planets: false)` does not call `process_planets`, and the `update_planets` argument is not read in the inspected method. The job `GameSimulationJob#perform` instantiates `Game` and calls `advance_by_days`; it does not directly call the root `PlanetUpdateService`. The source tree defines `class Game` in both `app/models/game.rb` and `app/services/game_service.rb`, so the exact method implementation resolved by the job's constant/load path must be verified in the running Rails application rather than inferred from either file alone.

### CelestialBody callback / TerraSim path

`CelestialBodies::CelestialBody` has a conditional `before_save :run_terra_sim` callback. When atmosphere, hydrosphere, or geosphere is changed (or body mass/albedo changes), it calls `TerraSim::Simulator#calc_current`. That simulator processes Atmosphere, Geosphere, Hydrosphere, and Biosphere, then runs only the Biosphere–Geosphere interface. It does not run the Atmosphere–Hydrosphere interface.

`GameSimulationJob` also contains an optional 10% chance per job run to choose one idle body and call `TerraSim::Simulator#calc_current(1)`. This is an explicit occasional idle-body update, not evidence that all bodies receive a TerraSim tick every game day.

### Other update services and unresolved integration

- `TerraSim::PlanetUpdateService#update` is a third, distinct service. It expects both Atmosphere and Hydrosphere, calls older-style `update_gases`, `update_pressure`, `update_volumes`, evaporation/precipitation, and a terraforming-cycle path. Repository search found no production caller of this namespaced service.
- `GameSimulation` is another class that explicitly iterates celestial bodies and calls `TerraSim::Simulator`; repository search did not establish a production caller.
- `TerraformingConcern#process_terraforming_cycle` is called only by the namespaced `TerraSim::PlanetUpdateService` in the inspected search. The concern's `has_many :terraforming_projects` association is commented out in the concern itself, and the concern was not found included by the CelestialBody model. Therefore the atmospheric-transfer project cycle is not demonstrated as connected to the active `GameSimulationJob` path. The separate Rake pipeline and direct project cycle are distinct execution routes.

The exact production cadence and overlap remain unresolved until the Rails constant/load behavior, job orchestration, and actual game-loop entry points are verified together. Do not treat a method definition or an optional update branch as proof of a regular planetary simulation tick.

The Atmosphere service's own gas-loss updates bypass normal callbacks and percentage recalculation, while ordinary gas additions/removals use the concern methods. This distinction matters when following a simulation tick into later consumers of percentage values.

## Mass-accounting interpretation

- Gas-record masses are the current per-species atmospheric inventory used by `add_gas`, `remove_gas`, pressure updates, and transfer services.
- `total_atmospheric_mass` is intended to equal the sum of Gas-record masses; normal add/remove methods explicitly recompute it, and atmospheric loss directly assigns the sum after reducing records.
- Percentages and ppm are derived fields on Gas records, not additional material mass.
- The composition hash is a retained parallel representation and is not visibly synchronized by ordinary add/remove operations.
- Pressure and temperatures are derived environmental properties, not additional mass inventories.
- Atmospheric escape removes mass from the body atmosphere. A transfer to another body should add the delivered mass to the destination atmosphere; any efficiency loss is external/unassigned in the inspected transfer path.
- Internal exchanges with Hydrosphere/Biosphere are material transfers between environmental records, but the individual service paths must be checked for whether they update all associated aggregate representations.

## Open verification points

1. Establish and enforce one pressure unit contract across model fields, lookups, UI, and services.
2. Verify the composition-hash shape expected by the default `calculate_total_mass` fallback and whether that path is reachable in normal body creation.
3. Determine which consumers read the Atmosphere composition hash versus Gas records after runtime changes.
4. Decide whether atmospheric-loss updates should refresh percentage/ppm immediately or whether consumers intentionally tolerate stale values until the next inventory operation.
5. Trace all production callers of `PlanetUpdateService`, `TerraSim::Simulator`, and `AtmosphereConcern#trigger_simulation` to establish the actual cadence and avoid accidental double ticks.
6. Validate the current heuristic loss rates against the separate design intent for Earth, Venus, and Mars; the current code does not model all known mechanisms or provide upper-atmosphere recovery.
7. Establish production callers for the generic and specialized sphere transfer_material methods; repository search found definitions and spec calls but no production invocation. Separately trace how the 2% raw-transfer difference and processed-transfer remainders are represented before claiming full mass conservation.

## Related wiki pages

- [Sphere Models & Environmental Interactions](sphere_models_and_interactions.md)
- [Celestial Body & Sphere Data Model](celestial_body_and_sphere_data_model.md)
- [Atmospheric Harvesting](../infrastructure/atmospheric_harvesting.md)
- [Atmospheric Escape, Retention & Recovery](../infrastructure/atmospheric_escape_and_recovery.md)
- [Skimmers & Mixed Volatiles](../logistics/skimmer_and_mixed_volatiles.md)
- [Hydrosphere Water Inventories & Cross-Sphere Cycling](hydrosphere_water_inventories_and_cycle.md)
- [Biosphere Ecology & Cross-Sphere Interactions](biosphere_ecology_and_cross_sphere_interactions.md)
- [Geosphere Materials & Stored Volatile Reservoirs](geosphere_materials_and_volatile_reservoirs.md)
