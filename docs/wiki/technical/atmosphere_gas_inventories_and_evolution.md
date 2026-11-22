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

Several distinct paths touch atmospheric gas:

- `Atmosphere#transfer_material` removes a named gas from the planetary Atmosphere and creates a generic polymorphic `Material` record on the target sphere inside a transaction. It does not create a target `Gas` record, so this is a generic material transfer, not a direct Atmosphere-to-Atmosphere gas transfer.
- `MaterialTransferable` and `CelestialBodies::Material` contain other sphere-transfer behavior, including special handling when the target is an Atmosphere. Those methods should be traced at their call sites; they are not interchangeable with `Atmosphere#transfer_material`.
- `TerraSim::AtmosphericTransferService` implements body-to-body raw, selective, and processed transfer modes. Raw transfer extracts source gases proportionally using current gas percentages, bounded by capacity and source-specific extraction limits (Titan 5%, Venus unlimited by that percentage rule, other bodies 20%). It removes the extracted mass from the source and adds the delivered fraction to the target Atmosphere. Default delivery efficiency is 98%; the undelivered remainder is not returned to the source or assigned to another inventory in this method.
- Selective transfer applies per-gas limits and the same default efficiency. Processed transfer is a separate CO₂/N₂ pathway with its own extraction caps and product handling.

The transfer service is under TerraSim, and the code includes source-specific rules that do not match the uncapped/5%/20% figures in every design document. Treat actual runtime code and the exact selected transfer mode as authoritative when describing current behavior. Do not infer that the atmospheric escape/recovery design page's suggested recovery or technology behavior is already implemented.

Hydrosphere evaporation/precipitation and Biosphere gas exchange also add or remove atmospheric H₂O, O₂, CO₂, and other constituents through their own services. Their actual behavior and limitations are documented in [Hydrosphere Water Inventories & Cross-Sphere Cycling](hydrosphere_water_inventories_and_cycle.md) and [Biosphere Ecology & Cross-Sphere Interactions](biosphere_ecology_and_cross_sphere_interactions.md). Geosphere volatile release has separate paths; stored volatile reservoir accounting is documented in [Geosphere Materials & Stored Volatile Reservoirs](geosphere_materials_and_volatile_reservoirs.md).

## Execution paths and duplicate-update caution

There are two concrete orchestration paths in the application:
- `TerraSim::Simulator#update_spheres` invokes Atmosphere, Geosphere, Hydrosphere, and Biosphere services in sequence, then invokes the Biosphere–Geosphere interface when both spheres exist.
- `Game#process_planets` iterates bodies and calls `PlanetUpdateService#run`; its detailed and progressive step paths also invoke the sphere services in sequence and then process sphere interfaces.

Separately, `CelestialBodies::CelestialBody` has a `before_save :run_terra_sim` callback when `simulation_relevant_changes?` is true. That callback calls `TerraSim::Simulator#calc_current`. The Atmosphere concern also defines a private `trigger_simulation` helper, but the inspected search did not establish a production caller for it.

These are real, distinct entry points, but their complete runtime overlap and cadence depend on callers and conditions. In particular, do not assume `PlanetUpdateService` and the CelestialBody callback always run together, or that a body update always causes a full sphere tick. The current code has no single demonstrated global cadence contract.

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
7. Trace all generic and specialized transfer call sites, including how the 2% raw-transfer difference is treated, before claiming full mass conservation.

## Related wiki pages

- [Sphere Models & Environmental Interactions](sphere_models_and_interactions.md)
- [Celestial Body & Sphere Data Model](celestial_body_and_sphere_data_model.md)
- [Atmospheric Harvesting](../infrastructure/atmospheric_harvesting.md)
- [Atmospheric Escape, Retention & Recovery](../infrastructure/atmospheric_escape_and_recovery.md)
- [Skimmers & Mixed Volatiles](../logistics/skimmer_and_mixed_volatiles.md)
- [Hydrosphere Water Inventories & Cross-Sphere Cycling](hydrosphere_water_inventories_and_cycle.md)
- [Biosphere Ecology & Cross-Sphere Interactions](biosphere_ecology_and_cross_sphere_interactions.md)
- [Geosphere Materials & Stored Volatile Reservoirs](geosphere_materials_and_volatile_reservoirs.md)
