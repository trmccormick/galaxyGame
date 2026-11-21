# Skimmers & Mixed Volatiles

> **Code Alignment Status:** `PARTIALLY IMPLEMENTED`  
> *Last Audited:* 2026-11-21  
> *Audit Summary:* Reusable atmosphere extraction, proportional raw transfer, CO₂ processing, and craft exhaust code exists. The current skimmer path does not yet connect those pieces into a consistent craft-cargo-to-Luna return calculation. A boiloff implementation was not located in the code search; verify tank and transit processing before concluding it is absent.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-21  
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

**The initial Venus harvesters are Earth-produced HLT Mk1 craft configured for atmospheric harvesting, not a separate harvester ship class.** “Harvester” describes the craft's role/configuration; HLT Mk1 is the specific early-game craft type/variant being adapted. This is not a commitment to use that exact Mk1 vehicle indefinitely. HLT is also the established cargo-transport craft family: later marks (Mk5 or beyond, as the fleet develops) are expected to continue serving Earth-to-Luna and Earth-to-L1 cargo routes. A later HLT mark may not be the vehicle used for Venus atmospheric harvesting, and its equipment/configuration must not be assumed to match this Mk1 example. The continuity is the HLT family and its cargo-transport role, not a fixed Mk1 airframe or a universal harvester configuration. These adapted craft are not onboard gas-separation plants. They capture bulk atmospheric mixture without selectively filtering, fractionating, or purifying the individual gases in their cargo. Their limited onboard CO₂ processing is a separate fuel-support function: it produces the LOX required for the skimmer's own mission. The mixed cargo is delivered for downstream processing at Luna. More capable gas-separation and recovery equipment is a likely addition to future craft purpose-built in space; do not assume it is fitted to the current Mk1 fleet or that it will necessarily appear in a particular Mk tier.

The HLT Mk1 craft configured for Venus harvesting processes captured CO₂ using its installed limited fuel-support capability:

`2CO₂ → 2CO + O₂`

- O₂ is liquefied and retained as LOX for the craft's mission fuel requirements.
- **During harvesting at Venus, CO handling is a configurable policy (DIRECTION, owner, 2026-11-18).** The Venus-harvesting HLT Mk1 configuration data sets `gas_handling_policy` to store O₂ and N₂, store CO if its value is positive, and process CO₂. With no CO storage fitted, the CO byproduct is vented back into the Venus atmosphere. This slightly modifies the source atmosphere composition over time (mass-ledger effect).
- If the craft has **no dedicated CO tank**, further CO₂ processing during the return leg to Luna pushes the CO byproduct into the mixed-volatiles inventory item (a tank only provides capacity).
- This is CO₂ splitting for the craft's **LOX/fuel requirement**, **not CNT manufacture** and **not methane production**. Venus HLT skimmers perform this processing onboard during atmospheric harvesting and continue processing during the return leg, producing the LOX needed for their own mission. The corresponding CO is a process coproduct of the skimmer's own fuel production, distinct from CO captured in the raw atmospheric mixture. Across repeated skimmer missions this can become a substantial CO stream; its recoverable quantity depends on actual onboard CO₂ processing, storage/venting configuration, and mission throughput, not a fixed assumed rate. CNT/structural-carbon production is a separate industrial CO₂-processing route using dedicated industrial equipment; it is not Venus-exclusive. Venus is expected to be a major atmospheric-gas and materials industrial powerhouse: its atmospheric composition provides CO₂ and N₂ feedstocks and supports O₂ and CO processing/recovery, while strong solar-energy availability supports substantial industry. CNT/solid-carbon manufacture is one important part of that broader industrial base, alongside O₂ production and handling, N₂ separation and supply, and CO₂ harvesting, processing, storage, and export. It can also be established elsewhere wherever suitable carbon feedstock and industrial capability are available, including Luna using imported CO₂; see [Terraforming Options](../infrastructure/terraforming_options.md).
- The HLT Mk1 craft must carry sufficient methane for its mission; methane production from Venusian CO₂ is a separate Luna industrial process using lunar-derived hydrogen.

Tanks track capacity only. Actual gas identity, masses, and composition live in the inventory system (already established). The Mk1 craft's cargo tanks hold mixed atmospheric material; they are not evidence of onboard selective gas separation.

- **Optional CO capacity (OPEN, owner, 2026-11-18):** a Mk1 Venus craft may fit an optional storage item to hold CO for the return leg, filled during operations or on the return leg. It could be an adjusted multi-purpose cryogenic tank or a new design. Per the current Venus-harvesting HLT Mk1 configuration data, the recommended fit's four storage ports are all used by Mk2 multi-purpose cryogenic tanks, so a CO item would replace one of them or need another port.
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
- `AIManager::AtmosphericExtractionService` invokes raw transfer for skimmers, but currently resolves Luna as the target body. The transfer service therefore adds gases to Luna's planetary atmosphere rather than clearly recording them as craft cargo.
- `Resource::AtmosphericHarvester` and `Craft::Harvester#harvest_atmosphere` already provide gas-specific extraction and storage through the harvester. Review whether this can support or be generalized for bulk proportional intake.
- `Craft::Harvester#apply_exhaust_to_atmosphere!` already adds propellant exhaust products to the source body's atmosphere. Its current propellant-consumption estimate is approximate.
- `AIManager::SkimmerCyclerHandshakeService` expects `raw_cargo` for one cargo-processing path, while `AtmosphericExtractionService#dock_and_transfer_to_cycler` reads gases from the craft's atmosphere. These paths need reconciliation.
- The processed mode in `TerraSim::AtmosphericTransferService` is not currently selected by the skimmer extraction service. It has its own hard-coded CO₂/N₂ behavior and source/target atmosphere effects; verify whether any of it should be reused for HLT onboard processing.
- A runtime boiloff calculation was not located in the initial code search. Search tank, cryogenic storage, and craft tick/transit processing before treating it as definitively absent.

These are existing building blocks, not proof that the end-to-end HLT mission loop is implemented or validated.

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
