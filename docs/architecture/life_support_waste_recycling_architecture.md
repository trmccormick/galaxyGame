# Life Support & Waste Recycling Ecosystem
## Architecture Reference

**Settlement Simulation Project — Version 1.0 — March 2026**

*Defines canonical material taxonomy, unit roles, closed-loop resource flow, settlement tier progression, and the Tier 1 Unit → Tier 3 Structure greenhouse upgrade path.*

*Inspired by NASA ECLSS and the ESA MELiSSA (Micro-Ecological Life Support System Alternative) project — the most detailed real-world closed-loop life support research programme, running since 1989.*

---

## 1. Purpose & Scope

This document is the authoritative reference for the life support and waste recycling subsystem. It consolidates design intent that was previously fragmented across multiple concept-testing files and agent-generated stubs, and establishes the canonical definitions that all unit blueprints, operational data files, and Ruby models must conform to.

Covers:
- Canonical material taxonomy — the definitive list of material IDs and what they represent
- Unit roles and the processing each unit is responsible for
- The full closed-loop resource flow across all units
- Settlement tier progression — which units are active at each growth stage
- The Inflatable Greenhouse (Unit) → Greenhouse Structure progression
- The Greenhouse Structure unit slot configuration
- The biogas processing split — digester vs generator engine
- File cleanup and template compliance actions required

---

## 2. Design Principles

**Nothing is waste.** Every output from one unit is an input to another. Organic waste, sludge, CO2, digestate, and wastewater are all intermediate materials with a defined downstream consumer.

**Settlement growth drives unit activation.** A Tier 1 outpost cannot afford a biogas digester. A Tier 3 settlement cannot function without one. Units are unlocked by population pressure, not arbitrary tech trees.

**Structures contain units — units do not contain structures.** The Inflatable Greenhouse is a standalone deployable unit. The Greenhouse Structure is a `BaseStructure` that accepts composting, algae, and recycling units installed inside it. `BaseUnit` processes resources; `BaseStructure` coordinates the units that do.

---

## 3. Canonical Material Taxonomy

The following table defines every material ID used across this subsystem. These IDs are the only valid identifiers in blueprint and operational data files.

> **DECISION:** `biomass` means cultivated biological material produced by the Algae Bioreactor. It is not synonymous with `organic_waste`. This resolves the ambiguity present in the legacy `biomass_recycler` and `biogas_generator` files.

> **DECISION:** `digestate` is the correct term for post-digestion slurry output from the Biogas Digester. It feeds back into the Composting Unit or directly to the Greenhouse Structure as a nutrient amendment. It is distinct from `compost`, which is the finished, stabilised output of the Composting Unit.

| Material ID | Category | Produced By | Consumed By | Notes |
|---|---|---|---|---|
| `organic_waste` | Waste | Humans, Greenhouse | Composting Unit, Biogas Digester | Food scraps, crop residue, biodegradable solids |
| `liquid_waste` | Waste | Humans | Waste Management Unit | Urine, greywater, blackwater |
| `solid_waste` | Waste | Humans, Industry | Waste Management Unit | Non-organic solids, packaging |
| `sludge` | Intermediate | Waste Management Unit, Algae Bioreactor | Composting Unit | Biological slurry; sewage biosolids |
| `digestate` | Intermediate | Biogas Digester | Composting Unit, Greenhouse Structure | Nutrient-rich post-digestion slurry |
| `compost` | Output | Composting Unit | Greenhouse Structure, Inflatable Greenhouse | Stabilised organic soil amendment |
| `biomass` | Intermediate | Algae Bioreactor | Biogas Digester, Biomass Recycler | Cultivated biological material — algae / crop waste |
| `biogas` | Energy | Biogas Digester | Biogas Generator Engine | Combustible gas — CH4 / CO2 mix |
| `fertilizer` | Output | Biomass Recycler, Biogas Digester | Greenhouse Structure, Inflatable Greenhouse | Concentrated nutrients for hydroponics |
| `biofuel` | Energy | Biomass Recycler | Vehicles, Backup Power | Liquid fuel; complements biogas in energy mix |
| `wastewater` | Waste | Composting Unit, Biogas Digester | Water Recycling Unit | Process water outputs from organic processing |
| `reclaimed_water` | Output | Waste Management Unit, Water Recycling Unit | Greenhouse, Algae Bioreactor, Habitat | Potable-grade recycled water |
| `nutrient_solution` | Intermediate | Water Recycling Unit (enriched) | Greenhouse Structure | Mineral-enriched water for hydroponic systems |
| `oxygen` | Output | Greenhouse Structure, Algae Bioreactor | Habitat Life Support | O2 for crew atmosphere |
| `co2` | Waste/Input | Habitats, Biogas Generator Engine | Algae Bioreactor, Greenhouse Structure | CO2 scrubbed from habitats feeds photosynthesis |
| `food` | Output | Greenhouse Structure, Inflatable Greenhouse | Humans | Crop yield — caloric output |
| `heat` | Byproduct | Biogas Generator Engine, Composting | Habitat Heating, HVAC | Waste heat recovery improves overall efficiency |

---

## 4. Closed-Loop Resource Flow

The following describes the full closed loop at Tier 3 maturity. Tier 1 and Tier 2 settlements operate subsets of this loop — see Section 6 for tier-by-tier detail.

### 4.1 Waste Intake

Human activity and greenhouse operations produce the settlement's waste streams. The Waste Management Unit is the primary intake point for liquid and solid waste, sorting and pre-processing before downstream units receive specific streams.

```
Humans & Greenhouse
  → liquid_waste + solid_waste + organic_waste
  → Waste Management Unit
  → sludge + organic_waste + reclaimed_water
```

### 4.2 Organic Processing

Organic waste and sludge enter the Composting Unit. The thermophilic process (55–65°C) sanitises biosolids and produces stable compost. Digestate from the Biogas Digester also feeds back here, ensuring nothing from the digestion chain is discarded.

```
organic_waste + sludge + digestate
  → Composting Unit
  → compost + co2 + water_vapor
  → Greenhouse Structure
```

### 4.3 Algae Cultivation Loop

The Algae Bioreactor is the engine of the biomass loop. It consumes CO2 scrubbed from habitats and water, producing biomass (cultivated algae), oxygen for life support, and a sludge byproduct that re-enters the composting stream. This is the primary O2 buffer for the settlement between Tier 2 and Tier 3.

```
co2 + water + energy
  → Algae Bioreactor
  → biomass + oxygen + sludge

oxygen → Habitat Life Support
sludge → Composting Unit
biomass → Biogas Digester + Biomass Recycler
```

### 4.4 Biogas Processing Chain

Biomass and organic waste enter the Biogas Digester (anaerobic digestion). This is a two-unit chain: the Digester produces biogas and digestate; the Biogas Generator Engine combusts biogas with oxygen to produce electricity returned to the power grid, with CO2 and heat as byproducts. CO2 feeds back to the Algae Bioreactor, completing the carbon loop. Heat is recovered for habitat heating.

```
biomass + organic_waste
  → Biogas Digester
  → biogas + digestate
  → Biogas Generator Engine
  → electricity + co2 + heat

digestate → Composting Unit
co2       → Algae Bioreactor
heat      → Habitat HVAC
electricity → Power Grid
```

### 4.5 Biomass Recycling

In parallel with the biogas chain, the Biomass Recycler processes biomass into fertilizer and biofuel. Fertilizer feeds the greenhouse directly. Biofuel supplements the energy system — relevant for vehicles and backup power where the biogas generator is not appropriate.

```
biomass + energy
  → Biomass Recycler
  → fertilizer + biofuel

fertilizer → Greenhouse Structure
biofuel    → Vehicles / Backup Power
```

### 4.6 Water Recovery

Wastewater from multiple sources — composting (water_vapor condensed), biogas digestion, and habitat greywater — feeds the Water Recycling Unit. Output is reclaimed water suitable for the greenhouse and algae bioreactor, and a nutrient-enriched stream for hydroponic systems.

```
wastewater (multiple sources)
  → Water Recycling Unit
  → reclaimed_water + nutrient_solution

reclaimed_water    → Greenhouse + Algae Bioreactor
nutrient_solution  → Greenhouse Structure (hydroponics)
```

### 4.7 Greenhouse Production

At Tier 3 the Greenhouse Structure is the primary food and oxygen production facility. It consumes compost, fertilizer, nutrient solution, water, and CO2, producing food, oxygen, and organic waste that re-enters the loop. At Tier 1 and 2 the Inflatable Greenhouse unit fulfils this role at smaller scale.

```
compost + fertilizer + water + co2
  → Greenhouse Structure
  → food + oxygen + organic_waste

food         → Humans
oxygen       → Life Support
organic_waste → Waste intake loop
```

---

## 5. Biogas Processing — Unit Split

The legacy files contained a naming collision: `biogas_generator` was used to mean both the anaerobic digestion unit (waste → gas) and the combustion unit (gas → electricity). These are now two distinct units with distinct IDs, blueprints, and operational data files.

| Unit ID | Old Name | Process | Key I/O |
|---|---|---|---|
| `biogas_digester` | `biogas_unit` / `biogas_generator` (processing variant) | Anaerobic digestion (biological) | IN: `biomass + organic_waste + wastewater` / OUT: `biogas + digestate + waste_water` |
| `biogas_generator_engine` | `biogas_generator` (energy variant) | Combustion / CHP (mechanical/electrical) | IN: `biogas + oxygen` / OUT: `electricity + co2 + heat` (emergency mode: 65 kW output) |

> **ACTION:** Rename `biogas_unit_data.json` → `biogas_digester_operational_data.json`. Create `biogas_digester_blueprint.json`. The existing `biogas_generator_data.json` (v1.4 with power generation modes) becomes `biogas_generator_engine_operational_data.json`.

---

## 6. Settlement Tier Progression

Units from earlier tiers remain active — each tier adds to the previous.

| Settlement Tier | Active Units | Greenhouse Type | Loop Completeness |
|---|---|---|---|
| **Tier 1** — Outpost (1–10 crew) | `waste_management_unit`, `water_recycling_unit`, `inflatable_greenhouse` | Inflatable Greenhouse (Unit) — standalone deployable | Partial — food + O2 produced. Waste processed but not fully looped. No biogas, no algae cultivation. |
| **Tier 2** — Base (10–50 crew) | + `composting_unit`, `algae_bioreactor`, `biogas_digester`, `biomass_recycler` | Inflatable Greenhouse (Unit) — multiple in parallel | Most loops closed. Biogas energy offset begins. Algae provides O2 buffer + biomass. |
| **Tier 3** — Settlement (50–200 crew) | + `biogas_generator_engine`, `GreenhouseStructure` — all Tier 1+2 units scaled | `Structures::GreenhouseStructure` — units installed inside structure | Full closed loop. Biogas → electricity returned to grid. Heat recovery active. Digestate feeds back to composting. |
| **Tier 4** — City (200+ crew) | Multiple `GreenhouseStructure`s, redundant processing trains, specialised crop structures | Multiple `GreenhouseStructure`s by crop type / function | Industrial scale. Export surplus food/O2. Full terraforming integration possible. |

---

## 7. Greenhouse Progression

### 7.1 Tier 1 — Inflatable Greenhouse (Unit)

The Inflatable Greenhouse is a `Units::BaseUnit`. It is portable, requires no structure, and can be deployed anywhere with power and water connections. It directly defines `input_resources` and `output_resources` in its operational data — `BaseUnit` handles the processing loop. It does not have unit slots; it is a single self-contained processing unit.

The shell printer was designed specifically for this use case. Once a shell printer is operational and depleted regolith is available, a regolith shell can be printed around the inflatable unit providing significantly improved radiation shielding, thermal stability, and microimpact protection. The shell is not required for operation but is the natural and intended upgrade path within the Tier 1 outpost stage — deploy the inflatable first, harden it with a printed shell once the printer is running.

**Deployment progression within Tier 1:**
1. Deploy inflatable greenhouse — operational immediately, basic protection only
2. Shell printer prints regolith shell around the unit using depleted regolith
3. Shelled inflatable — same `BaseUnit`, hardened environment, improved growing conditions

The unit remains a `BaseUnit` throughout — the shell is a physical upgrade to its environment, not a reclassification. The `deployment_data` block in the blueprint reflects this: `requires_shell: false` (operational without one), with shell printing noted as the recommended hardening path.

- **Type:** `Units::BaseUnit` (declarative — no Ruby model file)
- **Blueprint:** `inflatable_greenhouse_blueprint.json` (needs v1.3 upgrade — set `requires_shell: false`, note shell printing as upgrade path)
- **Operational data:** `inflatable_greenhouse_operational_data.json` (needs v1.3 upgrade — outputs should include `organic_waste`)
- **Status:** `inflatable_greenhouse.rb` model exists — delete after v1.3 files confirmed
- `greenhouse.rb` also present — old-style model, delete alongside

### 7.2 Tier 3 — Greenhouse Structure (`Structures::GreenhouseStructure`)

At Tier 3 the settlement constructs permanent greenhouse structures. These inherit from `Structures::BaseStructure`, giving them the full `HasUnits`, `HasModules`, `HasRigs`, `EnergyManagement`, and atmosphere concerns. The structure does not process resources directly — its installed units do. The structure coordinates, monitors, and provides the physical environment.

- **Type:** `Structures::GreenhouseStructure < Structures::BaseStructure`
- **New model file required:** `app/models/structures/greenhouse_structure.rb`
- **Overrides:** `needs_atmosphere? → true`, `atmosphere_type → 'controlled_growing'`
- **Operational data** defines `unit_slots` and `recommended_units` for `build_recommended_units` callback
- **Has own atmosphere:** higher CO2 tolerance, elevated humidity 60–80%, temperature 18–28°C
- **Contained structures:** can hold nested cold storage or seed vault structures via `container_structure`

### 7.3 Greenhouse Structure — Unit Slots

Slot counts are the baseline for a standard structure; larger structures (defined in operational data) may have more.

| Unit Slot | Unit ID | Count (Base) | Purpose |
|---|---|---|---|
| `composting` | `composting_unit` | 1–2 | `organic_waste + sludge → compost` |
| `water_recycling` | `water_recycling_unit` | 1 | `wastewater → reclaimed_water / nutrient_solution` |
| `algae_cultivation` | `algae_bioreactor` | 1–4 | `co2 + water → biomass + oxygen` |
| `biomass_processing` | `biomass_recycler` | 1 | `biomass → fertilizer + biofuel` |
| `digestion` | `biogas_digester` | 0–1 | `biomass + organic_waste → biogas + digestate` (Tier 3+) |
| `climate_control` | *(module)* | 1 | temperature / humidity / CO2 regulation |
| `lighting` | *(module)* | 2–8 | supplemental grow lighting |

> **NOTE:** The Greenhouse Structure's atmosphere is maintained by its installed Algae Bioreactor units — they consume the structure's internal CO2 and produce O2 directly into the enclosed atmosphere. This is why `algae_cultivation` slots scale with structure size.

---

## 8. Algae Bioreactor

The Algae Bioreactor is the most architecturally significant unit in the ecosystem. It is the bridge between the waste stream and the food/oxygen production chain, and it defines what `biomass` means in the material taxonomy.

**Current state:** `algae_bio_reactor.rb` is an old-style model with hardcoded values (`@capacity = 1000`, `@energy_consumption = 50`, `@water_consumption = 200`, `@food_output = 100`, `@biomass_output = 150`, `@oxygen_output = 200`). These values are reasonable starting points for the operational data but are currently untestable and not connected to `BaseUnit`'s resource processing.

The sludge byproduct (10% of biomass output from the legacy model) is correct and should be preserved in the operational data as a byproduct entry.

**Actions:**
- Delete `app/models/algae_bio_reactor.rb`
- Create `algae_bioreactor_blueprint.json` (v1.3)
- Create `algae_bioreactor_operational_data.json` (v1.3)
- Inputs: `co2`, `water`, `energy` — Outputs: `biomass`, `oxygen` — Byproducts: `sludge` (10% of biomass output)
- `processing_capabilities.atmospheric_processing`: enabled `true`, types: `[co2_scrubbing, oxygen_generation]`

---

## 9. Unit Registry & Actions Required

Complete in order — units that feed into `GreenhouseStructure` should be finalised before the structure's operational data is written.

> **PRIORITY ORDER:** composting_unit (in progress) → algae_bioreactor → water_recycling_unit → biogas_digester (rename + align) → biomass_recycler → biogas_generator_engine → waste_management_unit → inflatable_greenhouse → GreenhouseStructure model + operational data

| Unit ID | Type | Tier | Template Status | Action Required |
|---|---|---|---|---|
| `waste_management_unit` | Facility | 1+ | v1.2 — upgrade needed | Bring to v1.3; add `operational_status`, `operational_modes` blocks |
| `composting_unit` | Facility | 1+ | **v1.3 — NEW** | Delete 3 legacy `.rb` models; delete spec; add to data directory |
| `algae_bioreactor` | Facility | 1+ | No data file | Delete `algae_bio_reactor.rb`; create blueprint + operational data |
| `biogas_digester` | Facility | 2+ | Rename needed | Rename `biogas_unit_data.json`; align inputs/outputs to taxonomy |
| `biogas_generator_engine` | Generator | 2+ | v1.4 partial | Rename from `biogas_generator_data`; confirm `resource_management` block |
| `biomass_recycler` | Facility | 2+ | v1.2 stub | Bring to v1.3; delete `biomass_recycler.rb` and spec |
| `water_recycling_unit` | Facility | 1+ | v1.2 — missing inputs | Add `input_resources` block; bring to v1.3 |
| `inflatable_greenhouse` | Unit | 1 | v1.2 partial | Bring to v1.3; confirm as standalone unit not structure |

---

## 10. Files to Delete

Delete once replacement JSON files are confirmed complete and in the correct data directory.

| File | Reason | Prerequisite Before Deleting |
|---|---|---|
| `app/models/units/composting_unit.rb` | Superseded by JSON data | `composting_unit_blueprint.json` + `operational_data.json` in place |
| `app/models/units/composting_unit_new.rb` | Incomplete agent merge | Same as above |
| `app/models/units/composting.rb` | Pre-BaseUnit legacy | Same as above |
| `spec/models/composting_unit_spec.rb` | Tests deleted model | composting_unit files confirmed |
| `spec/models/biomass_recycler_spec.rb` | Broken — tests `BaseUnit` not `BiomassRecycler` | biomass_recycler v1.3 files confirmed |
| `app/models/units/biomass_recycler.rb` | Superseded by JSON data | biomass_recycler v1.3 operational data confirmed |
| `app/models/algae_bio_reactor.rb` | Superseded by JSON data | algae_bioreactor blueprint + operational data confirmed |
| `app/models/units/greenhouse.rb` | Pre-BaseUnit legacy | inflatable_greenhouse v1.3 operational data confirmed |

---

*This document supersedes all fragmented concept-testing notes for the life support / waste recycling subsystem.*
*Update this document when material IDs, unit roles, or settlement tier definitions change.*
