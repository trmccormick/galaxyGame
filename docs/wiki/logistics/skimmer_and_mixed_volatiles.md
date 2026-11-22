# Skimmers & Mixed Volatiles

> **Code Alignment Status:** `PARTIALLY IMPLEMENTED`  
> *Last Audited:* 2026-11-22  
> *Audit Summary:* Reusable atmosphere extraction, proportional raw transfer, CO₂ processing, and craft exhaust code exists. The current skimmer path does not yet connect those pieces into a consistent craft-cargo-to-Luna return calculation. A boiloff implementation was not located in the code search; verify tank and transit processing before concluding it is absent.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-22  
**Related**: [atmospheric_harvesting.md](../infrastructure/atmospheric_harvesting.md), [atmospheric_escape_and_recovery.md](../infrastructure/atmospheric_escape_and_recovery.md) (natural loss, retention, and optional recovery as resource paths), [terraforming_options.md](../infrastructure/terraforming_options.md), [isru_fabrication_chain.md](../technical/isru_fabrication_chain.md), Luna operations / TEU material

This page records the intended Venus HLT harvesting and return setup, plus the shared mixed-volatiles inventory concept. It is a statement of intended behavior, not a claim that the current implementation is complete.

---

## Venus HLT Harvesting and Return (DIRECTION)

### 1. Bulk atmospheric intake

The HLT pulls in the **actual atmospheric mixture of the planet**. It does not select only CO₂ and N₂ at the intake. The composition of each captured batch follows the source body's current atmospheric gas composition at the time of extraction.

Use the current gas masses / proportions represented by the source atmosphere. Do not substitute a fixed Venus recipe or invent a separate assumed intake mixture. As harvesting and emissions change the source atmosphere, later intake uses the atmosphere's then-current composition.

This includes trace constituents, not only the dominant CO₂ and N₂. The Mk1 skimmer captures the mixture; it does not selectively separate or purify individual gases from its cargo. Trace species may have useful industrial, chemical, or specialty-material applications, but recovering them requires suitable downstream separation equipment. Do not assume a trace gas is unavailable simply because it is a small fraction, but do not assume every trace constituent is present in the game model or worth extracting. Actual species and masses come from the current source-atmosphere inventory.

The amount captured is bounded by the craft's extraction throughput, time spent harvesting, available source gas, and available craft storage. Track the captured constituents by mass.


### Venus industrial geography (DIRECTION)

Venus's industrial role is determined by its location and planetary makeup, not by access to the planetary surface. Routine surface access and surface-based industry are not assumed to be practical. The intended pattern is to develop facilities in suitable atmospheric layers (including cloud cities / high-altitude platforms) and in orbit. Imported asteroids are brought into the Venusian industrial system for conversion into useful materials. The initial two stations are only the starting foothold, not a cap on the eventual network: additional cloud-city and orbital facilities can expand as industrial capacity and logistics grow. Exact counts, locations, asteroid sources, and conversion chains remain OPEN. See [Terraforming Options](../infrastructure/terraforming_options.md).


### 2. Onboard CO₂ processing (Mk1)

**HLT is a class of ships designed to be fitted and configured for different operational roles.** The initial Venus atmospheric harvesters are Earth-produced HLT Mk1 ships fitted/configured for that role; “harvester” is the assigned role and fit, not a separate ship class. HLT marks are successive versions within the HLT ship class. The exact Mk1 vehicle is an early-game example, not a permanent requirement for Venus harvesting. The HLT class is also expected to continue serving cargo-transport needs: later marks (Mk5 or beyond, as the fleet develops) are expected to move cargo from Earth to Luna and L1. A later HLT mark may or may not be used for Venus harvesting, and its equipment and configuration must be determined by the role for which it is fitted. The continuity is the HLT ship class, whose ships can be fitted for different roles—not a single fixed airframe, mark, or universal configuration. These adapted craft are not onboard gas-separation plants. They capture bulk atmospheric mixture without selectively filtering, fractionating, or purifying the individual gases in their cargo. Their limited onboard CO₂ processing is a separate fuel-support function: it produces the LOX required for the skimmer's own mission. The mixed cargo is delivered for downstream processing at Luna. More capable gas-separation and recovery equipment is a likely addition to future craft purpose-built in space; do not assume it is fitted to the current Mk1 fleet or that it will necessarily appear in a particular Mk tier.

The HLT Mk1 craft configured for Venus harvesting processes captured CO₂ using its installed limited fuel-support capability:

`2CO₂ → 2CO + O₂`

- O₂ is liquefied and retained as LOX for the craft's mission fuel requirements.
- **During harvesting at Venus, CO handling is a configurable policy (DIRECTION, owner, 2026-11-18).** The Venus-harvesting HLT Mk1 configuration data sets `gas_handling_policy` to store O₂ and N₂, store CO if its value is positive, and process CO₂. With no CO storage fitted, the CO byproduct is vented back into the Venus atmosphere. This slightly modifies the source atmosphere composition over time (mass-ledger effect).
- If the craft has **no dedicated CO tank**, further CO₂ processing during the return leg to Luna pushes the CO byproduct into the mixed-volatiles inventory item (a tank only provides capacity).
- This is CO₂ splitting for the craft's **LOX/fuel requirement**, **not CNT manufacture** and **not methane production**. Venus HLT skimmers perform this processing onboard during atmospheric harvesting and continue processing during the return leg, producing the LOX needed for their own mission. The corresponding CO is a process coproduct of the skimmer's own fuel production, distinct from CO captured in the raw atmospheric mixture. Across repeated skimmer missions this can become a substantial CO stream; its recoverable quantity depends on actual onboard CO₂ processing, storage/venting configuration, and mission throughput, not a fixed assumed rate. CNT/structural-carbon production is a separate industrial CO₂-processing route using dedicated industrial equipment; it is not Venus-exclusive. Venus is expected to be a major atmospheric-gas and materials industrial powerhouse: its atmospheric composition provides CO₂ and N₂ feedstocks and supports O₂ and CO processing/recovery, while strong solar-energy availability supports substantial industry. CNT/solid-carbon manufacture is one important part of that broader industrial base, alongside O₂ production and handling, N₂ separation and supply, and CO₂ harvesting, processing, storage, and export. It can also be established elsewhere wherever suitable carbon feedstock and industrial capability are available, including Luna using imported CO₂; see [Terraforming Options](../infrastructure/terraforming_options.md).
- The HLT Mk1 craft must carry sufficient methane for its mission; methane production from Venusian CO₂ is a separate Luna industrial process using lunar-derived hydrogen.

Tanks track capacity only. Actual gas identity, masses, and composition live in the inventory system (already established). The Mk1 craft's cargo tanks hold mixed atmospheric material; they are not evidence of onboard selective gas separation.

<<<<<<< HEAD
- **Optional CO capacity (OPEN, owner, 2026-11-18):** a Mk1 Venus craft may fit an optional storage item to hold CO for the return leg, filled during operations or on the return leg. It could be an adjusted multi-purpose cryogenic tank or a new design. Per the current Venus-harvesting HLT Mk1 configuration data, the recommended fit's four storage ports are all used by Mk2 multi-purpose cryogenic tanks, so a CO item would replace one of them or need another port.
=======
**Cryogenic boil-off (DIRECTION):** Mk1 methane and LOX storage tanks that declare `requires_cooling: true` suppress boil-off only while connected to active power and cooling. Without power, standard cryogenic boil-off applies and mass is lost over time. Exact daily loss rates and the presence of a live boil-off implementation remain OPEN (current code search did not locate one).

- **Optional CO capacity (OPEN, owner, 2026-11-18):** a Mk1 Venus craft may fit an optional storage item to hold CO for the return leg, filled during operations or on the return leg. It could be an adjusted multi-purpose cryogenic tank or a new design. Per the current Venus harvester data, the recommended fit's four storage ports are all used by Mk2 multi-purpose cryogenic tanks, so a CO item would replace one of them or need another port.
>>>>>>> a18be93a (wiki: clarify cryogenic boil-off depends on active cooling for Mk1 tanks)
- **Code alignment (verified against galaxyGame `8fd62da`, 2026-11-18):** the CO₂ split and the return of CO to the source atmosphere match `TerraSim::AtmosphericTransferService` (`remove_gas` on CO₂, then `add_gas('CO', …)` on the source). The `gas_handling_policy` block in the harvester data is not read by any Ruby code, and its `vent` list is currently empty (OPEN). Per-tank gas logic in `Units::Storage` is stubbed; capacity is checked through `Inventory`.

Goal arrival state at Luna for a successful Mk1 run: full LOX tank + mixed gas cargo (composition tracked in inventory). Selling the mix against standing buy orders and buying return methane is a valid commercial loop; pure inventory transfer remains allowed.

The quantity processed is determined by available captured CO₂, processing throughput, energy, and the LOX required for the mission. Do not assume all captured CO₂ is processed.

### 3. Exhaust returned to the source atmosphere

Propellant consumed by the craft produces exhaust gases. Those emissions are added back to the atmosphere of the body where the craft is operating. The gas species and masses follow the propellant actually consumed and its exhaust chemistry.

The code already has propellant-specific exhaust composition and an atmosphere-emission method on `Craft::Harvester`. Its current consumption estimate is a rough proxy based on extraction rate; review should determine how to use actual fuel consumption rather than duplicate the exhaust mechanism.

### 4. Calculate the return manifest

The return quantity is a mass balance, not a fixed delivery percentage or assumed daily output.

For each constituent, calculate what remains aboard after:
- bulk intake using the source atmosphere's current composition;
- CO₂ consumed by onboard splitting;
- CO vented from the craft;
- propellant consumed during outbound travel, harvesting, and return;
- cryogenic boiloff during storage and transit;
- any other explicitly modeled handling or transfer losses; and
- craft tank, cargo, and payload capacity limits.

The return manifest is the actual remaining mass of each stored gas at Luna arrival. LOX retained for the craft's mission fuel cycle is tracked separately from raw mixed atmospheric cargo. The craft's methane requirement is also tracked separately; it is provisioned for the whole mission and is not manufactured onboard.

Boiloff should be calculated from the applicable stored substance, tank/cooling configuration, and elapsed time. Do not apply an arbitrary universal loss percentage if the code has a tank-specific model. If no applicable runtime calculation exists, identify that as a missing integration point rather than inventing a rate.

### 5. Luna delivery and turnaround

On arrival, transfer returned gases and retained propellant into Luna/base inventory or compatible storage, subject to storage compatibility and capacity. Transfers between the craft and base are inventory movements, not forced market sales and repurchases.

**Unloading useful cargo is not an atmospheric transfer.** Returned atmospheric constituents belong in craft/base inventories and storage, then in the downstream mixed-volatiles / gas-separation pipeline where compatible. Do not routinely add delivered cargo to Luna's planetary atmosphere. Existing raw/processed transfer code that writes to a target body's atmosphere may be an early test or prototype path; its provenance and actual callers must be checked rather than treating that behavior as accepted cargo-delivery design.

This does not imply a perfectly sealed vehicle or zero emissions. Account for ordinary operational losses and emissions wherever they apply: seal and connection leaks, cryogenic boiloff, pressure management, and venting associated with launch, landing, docking, servicing, or other operations. Model these as losses/emissions from the relevant tank or inventory at the relevant time, with the receiving environment determined by where the operation occurs. They reduce the mass available for delivery; they are not a deliberate bulk dump of useful cargo into Luna's atmosphere. Venting CO from onboard CO₂ processing and propellant exhaust are separate, expected emissions and must not be confused with cargo unloading.

These emissions are **real additions to the atmosphere** at the location and time they are released. Repeated leaks, boiloff, processing vents, propellant exhaust, and launch/landing/docking/pressure-management releases can cumulatively change atmospheric gas masses and composition over long periods. This is distinct from deliberately unloading useful cargo into the atmosphere. The atmosphere model should account for both additions and losses through the same environmental simulation, not a separate artificial pollution mechanic. Apply emissions to the local atmospheric environment or volume where they occur; do not assume they are instantly and uniformly mixed across an entire moon or planet unless that is how the current atmosphere model represents it. Where supported by the existing simulation, account for mixing/dispersion, replenishment, and atmospheric escape over time.

The craft can unload, transfer fuel, be inspected and serviced, and prepare for its next launch window. A full LOX tank that remains available for the next mission does not need to be sold and repurchased; only an actual shortfall needs replenishing.

### 6. AI Manager responsibility

The AI Manager calculates the expected and actual Luna return manifest from current atmospheric composition, extraction amount and duration, installed processing throughput, mission fuel consumption, exhaust, storage capacity, elapsed transit time, and applicable boiloff/transfer losses.

It compares the resulting inventory with Luna's habitat, life-support, industrial, reserve, and next-mission needs. If returned nitrogen or other gases are insufficient, it can select another harvesting run, Earth imports, or another available supply route. These are alternatives; the required outcome is adequate supply, not a fixed mission script.

---

## Existing Code — Partial Building Blocks

The codebase already contains several relevant pieces that should be inspected and consolidated before new services are introduced:

- `TerraSim::AtmosphericTransferService` has a raw mode that transfers gases proportionally and a processed mode that splits CO₂ into CO and O₂.
- `AIManager::AtmosphericExtractionService#execute_extraction` validates the skimmer and source, then calls `TerraSim::AtmosphericTransferService` in raw mode with `source_body` and `target_body`. The default target is Luna. This removes proportional gas mass from the planetary source Atmosphere and adds the delivered mass directly to Luna's planetary Atmosphere. It does not populate the skimmer's atmosphere, `raw_cargo`, or its inventory.
- `AIManager::SkimmerCyclerHandshakeService#execute_atmospheric_extraction` calls that extraction method, then calls `dock_and_transfer_to_cycler` if the skimmer is already docked to a Cycler. That offload method reads gas records from `skimmer.atmosphere`, writes proportional masses into `cycler.definition_data['cargo']`, and removes the same masses from the skimmer Atmosphere. These are different inventories from the source and Luna Atmospheres modified by the preceding extraction call. The two steps are therefore not connected by the inspected code.
- The handshake's separate harvester cargo path, `process_cargo_harvester`, expects `skimmer.raw_cargo` and deducts fuel-refill mass from it. Repository search did not find a `raw_cargo` model attribute/accessor implementation; its existence and persistence need runtime/schema verification. The extraction/offload path writes Cycler `definition_data['cargo']`, not `skimmer.raw_cargo`.
- The specs confirm this separation rather than an end-to-end mission: the extraction spec expects the source body to be Luna and a target body to be another CelestialBody, while docking specs independently seed gas records into the skimmer's own Atmosphere before testing cargo transfer. They do not prove that extraction populates the inventory later offloaded.
- `Resource::AtmosphericHarvester#harvest_gases` is a separate gas-specific helper. It removes a named gas from the source Atmosphere and calls `harvester_unit.store_material`, then `use_resources_for_harvesting`. No production call site for the namespaced `Resource::AtmosphericHarvester` was found. In addition, `Craft::Harvester#harvest_gas` instantiates unqualified `AtmosphericHarvester`, but the inspected class is defined as `Resource::AtmosphericHarvester`; no top-level alias was found. The expected `store_material` and `use_resources_for_harvesting` methods were not found on `Craft::Harvester` in the inspected model. Treat this as an unverified/likely disconnected helper path, not a proven working craft-storage implementation.
- `Craft::Harvester#harvest_atmosphere` exposes `gas_name` and `dust_amount`, and passes `dust_amount` as the gas extraction amount when `gas_name` is present. There is no separate gas amount argument in that method signature. This is another integration/API mismatch to resolve before treating its gas-specific route as operational.
- `Craft::Harvester#apply_exhaust_to_atmosphere!` does add exhaust products to the source body's Atmosphere when the craft is operational. Its propellant consumption remains an estimate derived from extraction rate, not measured tank consumption.
- The skimmer extraction service always selects raw mode. The processed mode in `TerraSim::AtmosphericTransferService` is not selected by this service and is not evidence of the onboard CO₂-to-LOX process described in the operational design.
- A runtime boiloff calculation was not located in this audit. Tank, cryogenic storage, and craft tick/transit paths still need dedicated tracing before treating boiloff as definitively absent.

These are existing building blocks, not proof that the end-to-end HLT mission loop is implemented or validated.

---

## Existing Craft Inventory and Storage Paths — Code Audit

The existing data model provides a plausible place to hold a mixed-volatiles batch, but the storage/capacity paths are not yet consistent enough to treat as a working skimmer cargo implementation.

### Craft inventory and composition metadata

- `Craft::BaseCraft` has one polymorphic `Inventory` and exposes its `Item` records through `has_many :items, through: :inventory`. `Craft::Harvester` inherits this.
- `Inventory#add_item(name, amount, owner, metadata)` creates or updates an `Item` record and accepts metadata. The default owner is the inventoryable's owner (or the inventoryable itself).
- `Item.metadata` is already used elsewhere for material composition/provenance. Manufacturing code reads `metadata['composition']`, and specs exercise composition-bearing Items. A `mixed_volatiles` Item with constituent chemical formulas and their kg masses therefore fits an existing data shape; this is a candidate representation, not proof that the skimmer's cargo capacity and tanks are integrated.
- The craft inventory is distinct from the craft's planetary-style `Atmosphere` association and from a plain `raw_cargo` hash. The current skimmer extraction/offload code does not bridge those representations.

### Attached storage-unit behavior and mismatches

- `Craft::BaseCraft` has attached `Units::BaseUnit` records. Each BaseUnit has its own Inventory, and storage capacity/type/current level are described in its `operational_data['storage']`.
- `Units::BaseUnit#store_resource` is a concrete unit-level storage path: it checks material/storage compatibility and available capacity, writes an Item to the unit's own Inventory, then updates `resources['stored']` and `storage['current_level']`. `remove_resource` has a corresponding unit-level removal path.
- `Inventory#add_item` does not use that unit-level method. For gas/liquid/fuel it finds a compatible attached unit and checks its available capacity, but then calls `store_in_inventory` on the inventory's own Item collection. The separate `store_in_specialized_unit` helper—which would update unit operational storage and create a craft-inventory Item—is not called by `add_item` in the inspected implementation. Consequently the Item record and the selected tank's current-level/resource records can diverge.
- The general-storage check is also inconsistent: `Inventory#available_general_storage` selects units where `unit.storage_type == 'general'`, but `Units::BaseUnit#storage_type` returns `operational_data['subcategory']`, while storage compatibility reads `operational_data['storage']['type']`. A unit configured only with `storage.type = 'general'` may therefore be ignored by the general-capacity check. `Inventory#inventoryable_capacity` separately sums attached units' `storage.capacity`, but that does not repair the preceding `can_store?` gate.
- `Craft::Harvester#can_store?` currently returns true whenever the craft has an Inventory; its comment explicitly leaves actual craft-size/storage-module capacity checking as TODO. Its regolith extraction path therefore does not establish usable physical cargo capacity.
- Unit-level storage and craft-level inventory are separate records. `Units::BaseUnit#collect_materials` copies entries from `resources['stored']` into the craft Inventory and resets the stored hash/current level; the inspected method does not remove the source unit Inventory Items. Do not assume this collection path is a mass-safe move without reconciling both records.

### Existing ISRU producers do not yet share the intended batch representation

The two inspected lunar production paths also disagree about what a mixed-volatiles output is:

- `Manufacturing::MaterialProcessingService#complete_job` handles a declared `mixed_volatiles` output by iterating the Geosphere's stored-volatile composition and adding each non-H2O compound as its own Inventory Item (for example, separate CO2/N2 Items). It does not create one `mixed_volatiles` Item with constituent masses in metadata. H2O is handled by a separate output branch, so it is not part of that mixed output. The service derives fractions from stored_volatiles but does not decrement the Geosphere reservoir in this method; see [Geosphere Materials & Stored Volatile Reservoirs](../technical/geosphere_materials_and_volatile_reservoirs.md).
- `LunaOperationsSimulationService` has a separate TEU estimate: it calculates a scalar mixed-volatiles output and records it under the display name `Mixed Volatiles`. Its `apply_production` helper calls `amount.to_i`, so fractional kg outputs are truncated before being added to Inventory. At the documented 0.05 kg per TEU cycle, a single-cycle output becomes zero. This path does not attach constituent composition metadata.
- The two outputs are not interchangeable: one creates individual chemical Items without a single batch record; the other creates a scalar display-name Item with no composition and integer-truncated quantity. Neither inspected path demonstrates the intended canonical `mixed_volatiles` batch whose metadata holds each constituent's mass.
- The code search did not establish a production gas-separator job path that consumes this canonical batch and produces separated constituent Items. The historical/status note describing a 500 kg `mixed_volatiles` gas-separator input is not, by itself, proof of a live end-to-end code path.

This reinforces the intended direction already recorded above: the skimmer, TEU, and PVE should converge on one mass-primary mixed-volatiles Item representation, with composition metadata consistent with its total amount. The current TEU paths are evidence of implementation divergence, not alternative approved representations.

---

### PVE / TEU unit-buffer extraction is not a constituent inventory

The unit-level processing concern contains a second extraction path, separate from `Manufacturing::MaterialProcessingService` and `LunaOperationsSimulationService`:

- `Units::HasProcessing#process_resources` requires `operational_data['processing_capabilities']['thermal_extraction']`, obtains the regolith input rate from the unit lookup data, consumes that amount through the unit's Inventory, then reads `celestial_body.geosphere.crust_composition['volatiles']`. It estimates each volatile from the crust percentage and configured efficiency.
- Gas and liquid products are sent to `store_in_buffer('gas_buffer', volatile, amount)` or `store_in_buffer('water_buffer', volatile, amount)`. The method called `store_in_buffer` accepts the resource name and amount, but only increments the selected buffer's aggregate `current_level`; it does not store the resource name, constituent amount, or a composition map. The buffer therefore cannot later identify which gases make up its aggregate mass.
- `thermal_extract_volatiles` is a separate TEU-specific method. It reads the unit lookup's `processing_capabilities.processes` entry named `volatile_extraction`, consumes regolith, calculates yields from the same `crust_composition['volatiles']`, and writes gases/liquids to `gas_storage` / `liquid_storage` buffers. It has the same limitation: `store_in_buffer` only increments an aggregate level and discards constituent identity.
- Neither method visibly decrements the source Geosphere volatile composition or its material inventory, and neither transfers its outputs into a planetary Atmosphere. The consumed regolith is removed from the unit's own Inventory; the volatile yield is an estimate from composition percentages rather than a demonstrated extraction from a finite, depleted volatile reservoir.
- `process_geosphere!` dispatches to these methods, but repository search found no production caller of `process_geosphere!`, `process_resources`, or `thermal_extract_volatiles`; direct visible calls were definitions/spec coverage. Treat these as callable model methods, not proof of an automatically operating PVE/TEU simulation loop.
- `Units::BaseUnit#process_materials` is another generic route: it checks craft-inventory inputs, routes gas/liquid outputs to buffers and other outputs to `store_resource`, then consumes inputs. Its buffer writes use the same aggregate-only method. The generic `operate` path instead calculates outputs and sends them through `handle_outputs` / `store_resource`; it does not establish a gas-separator-specific separation algorithm.

The unit buffer is consequently a capacity/level counter, not a constituent-resolved material store. It cannot serve as the intermediate mixed-volatiles batch described in the direction above without an existing downstream representation being connected and reconciled.

### Gas-separator processing path not found in active code

- Repository search found gas-separator identifiers in deployment/planning references and test doubles, but did not find an active gas-separator model, service, processing branch, or production call path that consumes mixed volatiles and emits separated gas Items.
- The inspected `Manufacturing::MaterialProcessingService#complete_job` zero-amount output dispatch handles only `H2O`, `mixed_volatiles`, and `depleted_regolith`. It has no corresponding output branches for separator products such as `CO2`, `N2`, `O2`, or `CH4`.
- A historical `CURRENT_STATUS.md` entry describes a gas-separator JSON definition with a 500 kg mixed-volatiles input and world-driven outputs. That is a historical/status statement, not evidence of an active operational-data file or executable processing path. Attempts to fetch the expected operational-data file locations did not resolve; the exact current lookup-data location remains unverified.
- The existing `Units::BaseUnit#process_materials` and `operate` methods are generic resource-handling methods, not evidence of cryogenic fractional distillation. The inspected code contains no separator-specific constituent split, composition-based output calculation, or matching consumption of a mixed-volatiles batch.

**Audit conclusion:** PVE/TEU extraction, constituent-preserving storage, and downstream gas separation are not connected as a validated chain. The existing unit buffer stores only aggregate levels; the manufacturing job path creates separate Items or a scalar label in other paths; and no active separator implementation was located. Keep the existing Craft/Settlement Inventory + Item metadata as the documented candidate batch representation, and reconcile the current unit buffers and job execution paths rather than introducing another inventory abstraction.

---

### Docking cargo transfer is not an established solution

- `AIManager::UniversalDockingService#transfer_payload` calls `transfer_cargo`, but repository search found no production caller of `UniversalDockingService`.
- `transfer_cargo` returns unless both inventories exist and `to.can_process_volatiles?` is true. No definition of `can_process_volatiles?` was found in the inspected repository; the method appears only in this guard.
- If it proceeds, it removes each source Item and then adds an Item of the same name/amount to the destination, but it does not pass the source metadata. A batch's constituent composition and provenance would therefore be lost. It also does not check the destination `add_item` result or wrap the remove/add sequence in a transaction, so failed destination storage could lose the source item.
- The existing `universal_docking_spec` tests docking compatibility only. Its payload-handover section explicitly contains no cargo, equipment, or personnel transfer tests. It does not validate this method.
- The current skimmer handshake's Cycler offload is separate again: it reads skimmer Atmosphere Gas records and writes to Cycler `definition_data['cargo']`, not to the Cycler's Inventory/Items.

**Audit conclusion:** Craft Inventory + Item metadata is the closest existing foundation for the intended mass-primary mixed-volatiles batch. Attached storage units provide capacity/type concepts, and BaseUnit has a unit-level store/remove implementation. But the Inventory, BaseUnit, Harvester, and docking-transfer methods are not yet one coherent, tested cargo lifecycle. Reuse should begin by reconciling these existing paths and their accounting, not by introducing another cargo ledger or inventory abstraction.

---

## Capacity vs Inventory (ESTABLISHED DIRECTION)

| Concern | Owner | Role |
|---------|--------|------|
| Tank / storage unit | `Units::BaseUnit` (craft `has_many`) | Capacity, storage mode, temperature/pressure compatibility, and cooling/maintenance |
| Contents | Craft/base inventory and `Item` records | Actual stored substances, masses, and source/composition metadata |

Tanks answer: “Can this mass and storage mode fit?”  
Inventory answers: “What substance, how much, and where did it come from?”

Do not make a tank's capacity fields the source of truth for cargo composition.

---

## Mixed Volatiles Tracking (DIRECTION)

### Shared downstream intake

- TEU already produces a lumped `mixed_volatiles` inventory item from lunar regolith thermal extraction.
- The gas separator blueprint consumes `mixed_volatiles` and yields individual compounds.
- Venus HLT cargo should feed the compatible Luna inventory/separation path, while preserving the actual constituent masses in the captured batch.

### Composition and mass

- **Mass is primary.** Planetary gas records store mass; percentages are derived from the current gas inventory.
- Preserve each captured batch's constituent masses. Do not replace its actual composition with a generic Venus mixture.
- Keep source/batch identity where needed so materially different mixtures are not blindly merged.
- Any `Item.metadata['composition']` representation should remain consistent with the item's total mass; it is a possible implementation shape, not a second source of truth.
- **Initial batch composition (DIRECTION, owner, 2026-11-18):** a captured `mixed_volatiles` item starts from the source atmosphere's current proportions, with some variation. The amount of variation is OPEN. The mass removed from the source atmosphere must equal the mass the batch holds.
- **One item for every producer (DIRECTION, owner, 2026-11-18):** the skimmer, the TEU and the PVE can all produce mixed volatiles. A single `mixed_volatiles` inventory item records each gas's amount in its loaded metadata, so anything that needs to store them uses the same item. A tank is only a capacity check.
- **Onboard processing needs finer tracking (DIRECTION, owner, 2026-11-18):** products are tracked as their own inventory, for example O₂ filling the LOX tank. On Titan, methane could be extracted from the captured gases instead of being produced. Details OPEN.
- **Composition mirrors the atmosphere gas record (DIRECTION, owner, 2026-11-18):** the `mixed_volatiles` item's metadata lists each gas by chemical formula with its mass in kg, the same way an atmosphere's gas records do. Percentages are derived from those masses and are not a second source of truth. `amount` is the total mass, and merging two batches adds each gas's mass. Whether `molar_mass` is also stored on the item is OPEN.
- **Intake and venting (DIRECTION, owner, 2026-11-18):** the skimmer removes gas in the same proportions as the source atmosphere's current composition until its capacity is full, using a generic raw gas transfer that is not tied to TerraSim (any added variation, above, is OPEN). Anything vented is added back to the source atmosphere with `add_gas`.
- **Code alignment (verified against galaxyGame `89f9941`, 2026-11-18):** `TerraSim::AtmosphericTransferService#perform_raw_transfer` already extracts each gas in proportion to its `percentage`, up to a capacity and a per-body extraction limit, and removes it with `remove_gas`. It delivers 98% to a target body's atmosphere, and the other 2% is not returned to any atmosphere. TerraSim is the terraforming simulation and is not the right home for a generic gas-transfer operation (owner, 2026-11-18); where the generic transfer lives is OPEN. Candidate homes, not a decision: next to `add_gas` and `remove_gas` in `AtmosphereConcern` (a method that removes gas proportionally up to a given mass and returns the per-gas masses), or `Resource::AtmosphericHarvester#harvest_gases`, which removes a single named gas and stores it in the harvester. Writing the extracted masses into the craft's Mixed Volatiles item is not implemented (OPEN).

---

## Open Questions for Implementation Review

- Which existing extraction/transfer service should be the canonical entry point for bulk craft intake, and how should it write constituent masses into craft cargo?
- How should the existing CO₂ processed-transfer logic be reused or separated from planetary atmosphere transfer so it represents onboard HLT processing and CO venting?
- Where is actual propellant consumption recorded, and how should the existing exhaust calculation use it?
- Which tank/craft/transit tick path should apply cryogenic boiloff, and what data already defines tank-specific loss behavior?
- How should cargo, LOX, and methane inventories be represented and transferred between craft, cycler, and Luna base without double-counting?
- Which focused tests prove constituent mass balance from planetary intake through processing, exhaust, transit losses, and Luna delivery?

Implementation belongs in services and specs. This page records the intended behavior so the HLT loop remains simple: capture the current atmosphere mixture, process CO₂, account for exhaust and boiloff, and calculate the mass actually returned to Luna.
