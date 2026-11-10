# Skimmers & Mixed Volatiles
> **Code Alignment Status:** `PARTIAL — CONSOLIDATION REVIEW NEEDED`  
> *Last Audited:* 2026-11-10  
> *Audit Summary:* Reusable atmosphere extraction, proportional raw transfer, CO₂ processing, and craft exhaust code exists. The current skimmer path does not yet connect those pieces into a consistent craft-cargo-to-Luna return calculation. A boiloff implementation was not located in the code search; verify tank and transit processing before concluding it is absent.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-10  
**Related**: [atmospheric_harvesting.md](../infrastructure/atmospheric_harvesting.md), [terraforming_options.md](../infrastructure/terraforming_options.md), [isru_fabrication_chain.md](../technical/isru_fabrication_chain.md), Luna operations / TEU material

This page records the intended Venus HLT harvesting and return setup, plus the shared mixed-volatiles inventory concept. It is a statement of intended behavior, not a claim that the current implementation is complete.

---

## Venus HLT Harvesting and Return (DIRECTION)

### 1. Bulk atmospheric intake

The HLT pulls in the **actual atmospheric mixture of the planet**. It does not select only CO₂ and N₂ at the intake. The composition of each captured batch follows the source body's current atmospheric gas composition at the time of extraction.

Use the current gas masses / proportions represented by the source atmosphere. Do not substitute a fixed Venus recipe or invent a separate assumed intake mixture. As harvesting and emissions change the source atmosphere, later intake uses the atmosphere's then-current composition.

The amount captured is bounded by the craft's extraction throughput, time spent harvesting, available source gas, and available craft storage. Track the captured constituents by mass.

### 2. Onboard CO₂ processing

The HLT processes captured CO₂ using its installed processing capability:

`2CO₂ → 2CO + O₂`

- O₂ is liquefied and retained as LOX for the craft's mission fuel requirements.
- CO is dumped/vented; it is not part of the returned cargo.
- This is CO₂ splitting, **not methane production**.
- The HLT must carry sufficient methane for its mission; methane production from Venusian CO₂ is a separate Luna industrial process using lunar-derived hydrogen.

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

---

## Open Questions for Implementation Review

- Which existing extraction/transfer service should be the canonical entry point for bulk craft intake, and how should it write constituent masses into craft cargo?
- How should the existing CO₂ processed-transfer logic be reused or separated from planetary atmosphere transfer so it represents onboard HLT processing and CO venting?
- Where is actual propellant consumption recorded, and how should the existing exhaust calculation use it?
- Which tank/craft/transit tick path should apply cryogenic boiloff, and what data already defines tank-specific loss behavior?
- How should cargo, LOX, and methane inventories be represented and transferred between craft, cycler, and Luna base without double-counting?
- Which focused tests prove constituent mass balance from planetary intake through processing, exhaust, transit losses, and Luna delivery?

Implementation belongs in services and specs. This page records the intended behavior so the HLT loop remains simple: capture the current atmosphere mixture, process CO₂, account for exhaust and boiloff, and calculate the mass actually returned to Luna.
