# Geosphere Materials & Stored Volatile Reservoirs

> **Status:** CORE GEOSPHERE STATE MODEL IMPLEMENTED; operational extraction/transfer paths are mixed and require targeted verification  
> **Last audited:** 2026-11-21  
> **Code inspection:** `main` — Geosphere, GeosphereConcern, MaterialTransferable, StarSim initialization, ISRU evaluation, and material-processing service

## Purpose and boundaries

This page documents the existing Geosphere material and volatile state, how StarSim initializes it, and how current operations read or modify it. The Geosphere model and its JSON-driven initial state are established architecture. This is a code audit and documentation reference, not a proposal to replace the sphere model or introduce another resource ledger.

The Geosphere owns the solid body's crust, mantle, and core state. Its data includes:

- layer composition percentages and aggregate layer masses;
- material records associated with the Geosphere;
- geological-material records;
- volatile compounds stored in named geological reservoirs;
- geological/tectonic properties and terrain-related state.

These representations have related but distinct purposes. Do not assume that a composition percentage, a material record, a stored-volatile amount, a mapped resource marker, and a discovered mineable deposit are interchangeable records.

See [Celestial Body & Sphere Data Model](celestial_body_and_sphere_data_model.md) for the overall model and [Geosphere Terrain Data & Initial Surface State](geosphere_terrain_and_initial_surface_data.md) for terrain generation and persistence.

## 1. Initial state from system JSON

StarSim's `SystemBuilderService#create_geosphere` takes the body's `geosphere_attributes` and builds the Geosphere record from those attributes.

The loader performs normalization for `stored_volatiles`:

- A compound mapped to a location hash is retained as compound → location → amount.
- A simple compound → amount entry is normalized to a `crust` location.
- Legacy `co2_reserves` fields are converted into CO2 entries for `polar_caps`, `regolith`, and `clathrates`, where values are present.
- The normalized hash is assigned to `geosphere.stored_volatiles` before the Geosphere is saved.

The model's layer composition and layer-mass fields are initialized from the supplied JSON attributes. `GeosphereConcern` has an `after_save` callback that creates/updates polymorphic `Material` records when layer composition or layer mass changes. For each layer, it derives a material amount from percentage × layer mass. It handles flat composition entries and nested `volatiles`, `oxides`, and `minerals` categories.

This callback is a materialized representation of the layer composition; it does not mean the composition hash, material records, and geological-material records are three separate physical stores whose masses should be added together.

## 2. Layer composition, mass, and material records

The Geosphere model exposes `total_crust_mass`, `total_mantle_mass`, and `total_core_mass`, with corresponding composition hashes. Its `calculate_total_mass` method sets `total_geosphere_mass` to the sum of the three layer masses.

`GeosphereConcern#update_material_records` derives polymorphic `Material` records from each layer's composition. Each record is associated with the Geosphere, carries a layer, and uses the `geosphere` location. The derived amount is:

`material amount = (composition percentage / 100) × layer mass`

The concern also contains operations to add/remove materials by layer and recalculate composition percentages. `add_material` validates the material through `Lookup::MaterialLookupService`, rejects materials classified as gases at room temperature, increases the selected layer mass, updates/creates its material record, and recalculates layer composition. `remove_material` decreases a material record and the selected layer mass, then recalculates percentages.

The Geosphere model additionally declares a `geological_materials` association to `CelestialBodies::Materials::GeologicalMaterial`. That model stores `mass`, `percentage`, `layer`, and physical `state`. It is distinct from the polymorphic `Material` association, whose operations use `amount`. Do not collapse these into one model in documentation or assume every operation keeps both representations synchronized.

## 3. Stored volatiles: reservoir inventory, not atmospheric inventory

`geosphere.stored_volatiles` records volatile compounds held within the solid body. The compound key identifies the substance; nested location keys identify its reservoir/storage context. The field is not the body's atmospheric gas inventory, which belongs to the Atmosphere sphere.

The code supports location names such as:

- `regolith` and `crust`;
- `polar_caps` and `surface_ice`;
- `subsurface`;
- `clathrates` and `hydrates`.

The set of names is not an exhaustive enforced enum in the inspected methods. Preserve source JSON's actual location names and avoid silently renaming legacy values.

The Geosphere model provides:

- `update_volatile_store(compound, location, amount)` to set an amount for a compound/location pair;
- `total_stored_volatile(compound)` to sum the location values for a compound;
- `calculate_volatile_release(temperature)` to calculate location-dependent release rates, decrement the stored-volatile hash, save the Geosphere, and return a compound → released-amount hash.

The last method is a reservoir-depletion calculation. In the inspected implementation it does **not** itself transfer the returned amount into the body's Atmosphere. A caller must be traced before describing it as a completed cross-sphere transfer.

A separate `GeosphereConcern#extract_volatiles` method reads `crust_composition['volatiles']`, calculates release based on temperature increase, calls `atmosphere.add_gas`, updates the composition percentage, and creates/updates a polymorphic material record. This is a different data path from `stored_volatiles`; do not assume it consumes the location-based reservoir hash.

## 4. Resource assessment and ISRU reads

`AIManager::ISRUEvaluator` reads three live inputs for a settlement's celestial body:

- raw regolith stock from settlement surface storage;
- `geosphere.stored_volatiles`;
- atmospheric gas percentages from the body's Atmosphere.

It uses the stored-volatile hash to estimate world-dependent processing fractions. The evaluator distinguishes an absent compound from a compound present in the survey data, and it can fall back to a conservative default volatile fraction when no survey data exists. This is an operational capability/readiness estimate, not a spatial deposit survey and not proof that a specific mineable deposit has been discovered.

The evaluator's production-rate calculation is driven by unit JSON inputs/outputs and processing efficiencies. It estimates possible output rates; it does not itself remove material from the Geosphere or add produced material to settlement inventory.

## 5. Material-processing path and current limitations

`Manufacturing::MaterialProcessingService#complete_job` removes the declared input from settlement inventory and processes output definitions from unit operational data.

For zero-amount/world-driven outputs, the inspected implementation reads `geosphere.stored_volatiles`, totals the stored-volatile quantities, and normalizes each compound's share of that total. It then uses those shares to estimate outputs such as H2O, mixed volatiles, or depleted regolith.

Important distinctions from the inspected implementation:

- This path reads the reservoir hash to derive percentages but does not decrement the corresponding `stored_volatiles` quantities.
- It does not select a specific reservoir location such as a particular PSR deposit or regolith zone.
- The code comment describes the input as raw regolith, but the world-driven output fraction is calculated from the relative composition of all stored volatile compounds; this is not the same as a surveyed yield for the specific regolith batch.
- The method adds estimated outputs to settlement inventory. The inspected method does not demonstrate a matching reduction in Geosphere layer mass/material records or stored-volatile mass.

Consequently, document this as an existing operational processing path with a read/estimate/output implementation—not as a fully verified physical extraction transaction against the Geosphere inventory.

## 6. Transfer methods and representation boundaries

The current code contains more than one material-transfer/removal implementation:

- `Geosphere#transfer_material` operates on `geological_materials` using the record's `mass` and layer, reduces that layer's aggregate mass, and creates/updates a target sphere's polymorphic `Material` record using `amount`.
- `MaterialTransferable#transfer_material` operates on polymorphic `Material` records using `amount` and dispatches to Atmosphere, Hydrosphere, or another target sphere.
- `GeosphereConcern#remove_material` operates on polymorphic `Material` records and reduces the selected aggregate layer mass.
- `Geosphere#extract_material` calculates a maximum from the crust composition percentage and total crust mass, then reduces `total_crust_mass` and recalculates percentages. The inspected method does not reduce a matching material record's `amount` before returning.

These are concrete methods in the existing implementation, but the inspected code does not establish one unified, consistently invoked transfer path for all resource operations. In particular, `MaterialTransferable#transfer_material` does not update Geosphere layer aggregates or composition when used as the source operation. Callers and transaction boundaries must be traced before relying on any one method as the universal mass-conserving operation.

## 7. Mass-accounting interpretation

The intended physical accounting rule remains:

- Composition percentages and material records describe the same layer inventory in different forms; do not add them together.
- Stored volatile reservoirs represent matter already belonging to the body, not extra mass on top of the body's geological inventory.
- A survey or lazy creation of a deposit representation reveals or localizes existing material; it must not create additional planetary mass.
- Moving material between internal Geosphere reservoirs is redistribution within the body.
- Moving material from the Geosphere into a settlement, vehicle, or orbital depot transfers mass across the body's boundary and must be reflected in source and destination inventories.
- Releasing a volatile into the body's atmosphere moves matter from Geosphere to Atmosphere; venting it beyond the body's boundary is a separate mass-loss event.

These are the accounting semantics the implementation and operational workflows should satisfy. They are not a claim that every current service path has been verified to update every affected record.

## 8. Open implementation verification

1. Trace callers of `calculate_volatile_release` and establish where its returned compound amounts are transferred, if anywhere.
2. Trace callers of `extract_volatiles` and verify whether the composition hash, polymorphic material amount, aggregate crust mass, and atmospheric gas mass remain consistent.
3. Identify the intended authoritative use of `GeologicalMaterial.mass` versus polymorphic `Material.amount`; map which current operations write each representation.
4. Trace callers of `Geosphere#extract_material` and determine whether callers separately update the corresponding material record and persist the Geosphere.
5. Trace the actual ISRU job lifecycle from input stock through output claim. Determine where physical reservoir depletion should occur and whether it is currently represented by a different, already-existing operation.
6. Verify whether `stored_volatiles` values are aggregate reservoir estimates, survey-derived accessible quantities, or both in each source dataset. Keep that distinction explicit in the data contract.
7. Verify mass updates and transaction boundaries for cross-sphere and off-body transfers before describing a path as mass-conserving.

These are targeted consistency and caller-tracing questions around the existing sphere and material architecture. They do not call for another inventory model or a replacement Geosphere.

## 9. Primary code inspected

- `galaxy_game/app/services/star_sim/system_builder_service.rb` — `create_geosphere`
- `galaxy_game/app/models/celestial_bodies/spheres/geosphere.rb`
- `galaxy_game/app/models/concerns/geosphere_concern.rb`
- `galaxy_game/app/models/concerns/material_transferable.rb`
- `galaxy_game/app/models/celestial_bodies/materials/geological_material.rb`
- `galaxy_game/app/services/ai_manager/isru_evaluator.rb`
- `galaxy_game/app/services/manufacturing/material_processing_service.rb`

Related legacy reference: `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md` was consulted as a historical source for storage-location terminology. It is not treated as the current wiki authority and was not modified.
