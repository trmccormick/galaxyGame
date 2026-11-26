---
title: Worldhouse Engineering
category: Infrastructure
status: DESIGN INTENT
last_updated: 2026-11-26
---

# Worldhouse Engineering

> **Status: DESIGN INTENT.** This page consolidates Worldhouse structure, enclosure, incremental construction, and atmospheric-development intent. It is not a code-verification report. Historical engineering details are retained only where they remain compatible with current owner-confirmed direction; unresolved specifications are identified below.

## Existing Code Alignment (Repository Inspection)

> **Code inspection, 2026-11-26 — PARTIAL IMPLEMENTATION.** The repository already contains Worldhouse and geological-feature models and related construction/pressurization services. This section records the inspected code shape; it does not imply that every intended Worldhouse workflow is complete or validated end to end.

- `Structures::Worldhouse` inherits from `Structures::BaseStructure`, links to a `CelestialBodies::Features::BaseFeature`, and has many `Structures::WorldhouseSegment` records. It stores segment totals, enclosed-segment count, and coverage percentage, and recalculates overall enclosure progress from enclosed segments.
- `Structures::WorldhouseSegment` has its own construction status (`planned`, `materials_requested`, `under_construction`, `enclosed`, `operational`), construction jobs, and segment components. The covering service schedules jobs against individual coverable segments. This is existing segment-level progress tracking for the Worldhouse enclosure.
- `Structures::BaseStructure` is the shared model for individual structures. It supports settlement membership, a parent `container_structure` and contained structures, and a structure-associated atmosphere. This is the existing model foundation for treating internal facilities as individual structures rather than making them part of one monolithic Worldhouse building.
- Geological features are modeled separately under `CelestialBodies::Features`. The inspected feature models include lava tubes, valleys, and canyons; the Worldhouse links to the natural feature rather than replacing the feature model.
- Construction code includes `Manufacturing::Construction::SegmentCoveringService` and the shared covering workflow. A lava-tube-specific pressurization service also exists, and the construction documentation describes a broader pressurization service that calculates gas requirements and consumes available gases.

**Important implementation boundaries and inconsistencies found during this inspection:**

- The current `BaseFeature#worldhouse_suitable?` and `convert_to_worldhouse!` path is limited to valleys and canyons, while `Structures::Worldhouse#feature_must_be_suitable` lists valleys, canyons, lava tubes, and excavated cavities. The lava-tube model exposes a `can_pressurize?` check, but the inspected generic conversion path does not currently include it. This means the model's declared suitability and the conversion entry point are not aligned.
- The Worldhouse segment status and aggregate enclosure coverage are represented separately from the individual internal structures. The inspected code establishes a structure model and containment association, but this inspection does not establish that every internal structure's construction progress is fully integrated with Worldhouse environmental readiness or that all intended structures are currently placeable inside a Worldhouse.
- The feature status helpers distinguish `enclosed` and `pressurized`, and `pressurize!` requires an enclosed feature. The lava-tube service contains section-level seal checks and gas-based pressurization logic. However, code inspection alone does not demonstrate that the complete real-time resource-limited atmospheric establishment workflow is fully integrated, nor does it validate the older fixed crew-arrival sequence in frozen documentation.

Relevant inspected files include `galaxy_game/app/models/structures/worldhouse.rb`, `worldhouse_segment.rb`, `base_structure.rb`, `galaxy_game/app/models/celestial_bodies/features/base_feature.rb`, `lava_tube.rb`, `valley.rb`, `canyon.rb`, `galaxy_game/app/services/manufacturing/construction/covering_service.rb`, `segment_covering_service.rb`, and `galaxy_game/app/services/pressurization/lavatube_pressurization_service.rb`.

**Additional pressurization and containment findings — 2026-11-26:**

- `Pressurization::BasePressurizationService` exists as a shared ideal-gas calculation service. It calculates target gas masses from volume, target pressure, temperature, and a selected gas mix; estimates achievable pressure from the limiting available gas; deducts the calculated usage from its in-memory available-gas hash; and reports whether the result passes its current human-breathability checks.
- `Pressurization::StructurePressurizationService` is a separate structure-oriented path. It can source gas quantities from settlement inventory items when no gas hash is supplied, reads/writes a structure's `operational_data['gas_storage']`, and checks sealing integrity, life-support units, and airlocks before pressurization. This establishes an existing gas-inventory connection, but not a complete Worldhouse-scale atmosphere program.
- The structure-oriented service currently calculates pressure from oxygen and nitrogen only, while the shared base service's default atmospheric mix also includes argon. Its reported `used_gases` and stored atmosphere composition also warrant review against the actual combined gas store. The inspected path reads settlement inventory to build an available-gas hash, but does not itself show a corresponding settlement-inventory deduction. These are concrete implementation/tuning review points, not reasons to change the Worldhouse design intent.
- The existing structure pressurization path defaults to a 100 m³ volume when it cannot derive a recognized structure volume, and its sealing gate requires an integrity value and a life-support unit. Those assumptions may be suitable for some human-rated structures but should not automatically define non-human-rated Worldhouse environments or large geological volumes.
- `Structures::CraterDome` provides a more explicit example of nested structures: it can add/remove contained structures and update their atmosphere records from the dome atmosphere while preserving each nested structure's sealing flag. This is useful existing precedent for environmental inheritance, but it is dome-specific code and does not prove that the same workflow is already integrated for Worldhouses.

**Development interpretation:** Treat the suitability mismatch and the pressurization details above as candidates for ordinary implementation refinement while the game is still being developed. The current code is a foundation, not a frozen contract. A mismatch should be classified as a likely tuning/integration item where the intended behavior is already clear; reserve a design conflict for cases where the intended behavior itself is genuinely ambiguous. No proposed code correction is approved by this documentation entry.


## Purpose and Core Definition

A **Worldhouse** is an engineered, sealed environmental structure built around or within a suitable natural geological feature. Where suitable geology exists, adapting and enclosing that natural volume is the preferred approach over constructing an entirely artificial pressure vessel. The geological host can provide shelter and part of the physical boundary, reducing the amount of structure that must be built; suitability, structural condition, geometry, and engineering demands determine whether a particular feature is practical. This preference applies across worlds, not only to lunar lava tubes. A Worldhouse establishes a local environmental boundary without inherently changing the surrounding planet or moon.

A Worldhouse is defined by its enclosure and environmental-control capability, not by a mandatory breathable atmosphere, a particular biome, or one exclusive use. Its target atmospheric profile is selected according to the work it is intended to support. Enclosure, habitation, and atmospheric establishment are distinct capabilities: sealing a volume does not mean the gases needed to pressurize or condition it are available.

The Worldhouse is the enclosed site or environmental volume, not one giant building. The intent is to enclose a suitable geological area and construct ordinary settlement and operational structures within it. These may include habitation buildings, laboratories, factories, warehouses, greenhouses, utility buildings, and other facilities. The Worldhouse supplies the broader environmental boundary; the buildings inside it provide their own functions. Individual buildings do not all need to be independent pressure vessels or sealed habitats. Building-level environmental controls or containment are added where a particular use requires them.

A sealed lava tube is one Worldhouse configuration. Sealing the openings and controlling access to a natural underground void can establish a Worldhouse without constructing a roof over the entire landscape. An enclosed valley is another configuration, but requires a much larger engineered boundary around an open geological feature.

A Worldhouse is not itself planetary terraforming. Conditions inside the enclosure remain local unless a deliberate external connection or release operation is separately undertaken.

## Worldhouse Forms

### Sealed Lava Tube

A lava tube provides a naturally sheltered geological volume. Its skylights, entrances, access points, and other openings can be sealed or converted into controlled access points. Structural reinforcement and covering work establish the environmental boundary. The same general preference for using suitable natural geological volumes applies to other worlds and to other forms such as caverns, craters, valleys, and canyons.

Lava tubes are particularly relevant to initial settlement locations because a habitation module can be placed inside the tube while the larger Worldhouse is still being developed. The module provides its own life support and an initially occupied space; it does not imply that the entire tube is sealed, pressurized, or conditioned to a human-rated atmosphere.

**ESTABLISHED INTENT — 2026-11-26:** In the Luna initial-settlement pattern, the crew can occupy the initial habitation setup while robotic construction and sealing of the larger lava-tube environment continue. Occupancy of the starter module and completion of the Worldhouse are separate milestones. This is a deployment pattern, not a requirement that every Worldhouse be crewed during construction.

### Enclosed Valley or Canyon

A valley or canyon Worldhouse creates a much larger environmental boundary around an open landscape. Its perimeter, structural supports, roof or covering system, access points, and seals must collectively contain the intended internal environment. Once the area is enclosed, ordinary buildings and settlement infrastructure can be constructed within the protected volume; the entire enclosed landscape is not itself one building.

A valley does not become pressurized merely because its enclosure has been constructed. At closure, its internal atmosphere begins from the conditions present in the enclosed volume, subject to the construction and sealing process. On Mars, that may mean starting with the thin local atmosphere. Raising pressure above the natural Martian level and tuning the composition are separate operations that may take substantial additional time and resources.

The same separation between enclosure construction and atmospheric development applies to other Worldhouse forms, although the starting atmospheric conditions differ by location.

## Design Layers

Keep these concepts distinct when describing or planning a Worldhouse:

| Layer | Meaning |
|---|---|
| **Geological host** | The natural feature being enclosed or adapted: lava tube, valley, canyon, crater, or another suitable cavity. |
| **Structure and enclosure** | The engineered supports, panels, barriers, seals, controlled openings, and related construction. |
| **Environmental boundary** | The local volume whose pressure, temperature, and gas composition can be managed. |
| **Atmospheric profile** | The selected operating conditions for the intended use; human-breathable conditions are optional, not inherent. |
| **Internal structures and uses** | Ordinary buildings and facilities placed within the enclosure, supporting habitation, industrial work, research, biological incubation, contained ecosystem development, or compatible combinations. |
| **External coupling** | Any deliberate exchange with, or release into, the surrounding planetary environment. This is separate from ordinary internal operation. |

A terraforming-seed program is a possible biological use of suitable infrastructure, not a competing structure type. A Bio-Nursery is an incubation/adaptation capability that may be hosted within a Worldhouse or provided separately. See [Terraforming Seeds](../technical/biology/terraforming_seeds.md) and [Contamination & Biosafety](./contamination_and_biosafety.md).

## Construction and Enclosure

The frozen construction material describes a generic in-situ structural approach based on locally manufactured supports and panels. Its reusable design direction is:

- Survey and characterize the geological feature, including openings and access requirements.
- Plan the enclosure and any segments or structural subdivisions needed for the feature.
- Manufacture or provide load-bearing supports. The Luna concept uses regolith-derived, 3D-printed I-beams.
- Manufacture and install suitable panels or other covering elements.
- Seal joints, interfaces, skylights, entrances, and other openings; provide controlled access where required.
- Inspect and validate the enclosure before treating the larger volume as ready for atmospheric conditioning.

The source material describes structural, transparent, solar-integrated, and ruggedized/armored panel concepts. These are candidate panel functions, not a finalized universal panel catalogue. The appropriate materials and panel arrangement depend on the geological host, structural loads, radiation and thermal requirements, and intended operating environment.

A candidate construction sequence is **support/bracing → panel installation → sealing → enclosure validation**. It is a useful organizing model, not a claim that every Worldhouse follows one identical sequence or that every construction step must finish across the entire site before any local occupation can begin.

Construction may be carried out incrementally. Inflatable habitats or other independently life-supported modules are a practical early habitation step on worlds where establishing a large enclosed volume and supplying its atmosphere would take longer. Occupants can live in these starter habitats while robotic equipment continues structural work, sealing, and expansion around or near them. Once the larger area is enclosed and its environment is established to the required operating conditions, ordinary buildings and facilities can be built and operated inside it. Those structures are not presumed to be individually pressurized shells; their internal environmental systems depend on their purpose and on the conditions maintained by the Worldhouse. The exact boundaries between occupied space and active construction areas must be designed for the actual deployment. This is a general deployment option, not a Luna-only rule or a requirement that every Worldhouse be built around an occupied starter habitat.

## Starting Environment During Construction and Seal Testing

Construction begins under the **initial local planetary environmental conditions** at the site. The starting environment is not presumed to be vacuum, and it is not presumed to be habitable. The geological feature and exposed work area have the atmosphere and environmental conditions naturally present there; construction methods, equipment, materials, and work procedures must account for those conditions.

When the enclosure is sealed, it retains the atmosphere present within the enclosed volume at that point, subject to gas exchanges and leakage that occur during construction and sealing. Sealing establishes the environmental boundary; it does not itself pressurize the volume or supply a different gas mixture.

Where the planet or moon has an atmosphere, that local atmosphere can also provide gas for post-sealing pressure and seal-integrity testing. For example, after a Martian valley is sealed, operators can capture, compress, and pump additional Martian atmospheric gas into the enclosure to raise its pressure for testing. The test does not require importing a human-breathable mixture: the purpose at this stage is to test the enclosure under a suitable pressure condition. Gas availability, capture/compression equipment, test pressure, and the suitability of the local gas for the test remain engineering and operational considerations.

A location with effectively no atmosphere, such as a lunar lava tube, has no useful ambient planetary gas source for this purpose; test gas must instead be supplied from stored, produced, or imported inventory. The same general principle applies to other construction and facilities: account for the local environment during construction, and use local atmospheric gas as a potential test resource where it is available and suitable.

Seal testing is distinct from final atmospheric establishment. After integrity testing and acceptance, the enclosure can proceed to the separate atmospheric-conditioning program for its intended operating profile.

## Atmospheric Establishment Is a Separate Program

Construction and sealing create the environmental boundary. They do not, by themselves, establish the final pressure or gas composition.

After the relevant volume is sufficiently enclosed and its integrity is accepted, atmospheric establishment and conditioning can proceed as a separate, potentially lengthy operating program. Depending on the target profile, this may involve:

1. Assessing the gas and pressure conditions present when the volume is enclosed.
2. Acquiring or producing the required gases.
3. Transferring gases into or out of the enclosed volume.
4. Raising or otherwise adjusting pressure toward the selected operating conditions.
5. Adjusting gas composition and other environmental variables toward the target profile.
6. Monitoring stability and making further corrections as the environment is operated.

For a large Martian valley, increasing pressure above the natural Martian atmosphere is not an immediate consequence of sealing. Atmospheric mass acquisition, compression or processing, transfer, and subsequent composition tuning are additional work beyond construction. Tuning the atmosphere to a target profile may take longer still.

For a lunar lava tube, the starting external environment is effectively vacuum rather than a useful ambient atmosphere. The environmental starting point and available gas sources therefore differ from the Martian valley example. A local habitation module can nevertheless provide an occupied, independently life-supported space while the larger tube remains under robotic development.

No universal pressure target, gas recipe, pressurization rate, conditioning duration, or seal-test duration is established by this page. Do not carry historical example values forward as game-wide requirements.

## Atmospheric Profiles and Uses

The atmosphere is selected for the intended operating environment. Illustrative profile families retained from historical design material include:

- **Industrial or robotic:** Conditions selected for manufacturing and equipment operation; a human-breathable oxygen mix is not automatically required.
- **Biological or pre-terraforming:** Conditions selected for particular organisms, incubation, research, or contained ecosystem work.
- **Human-rated:** Conditions that support human occupancy and its associated life-support and safety requirements.

These are purpose categories, not finalized recipes. Exact compositions, pressure ranges, thermal and humidity requirements, and transition procedures remain open.

A Worldhouse may be dedicated to one purpose or support mixed use. Its overall enclosed environment may take substantial time to bring to human-rated conditions, especially when the enclosed geological area is large and the required atmospheric gases and processing capacity are not yet available. The structures inside it therefore do not all have to share the same human-rating status. A settlement may contain human-rated habitation or work buildings alongside non-human-rated industrial, robotic, experimental, or biological facilities while the wider Worldhouse is still being developed.

The individual structures inside the Worldhouse remain separate physical assets represented by the existing structure model; they are not collapsed into one Worldhouse-wide construction record. Construction and development progress is tracked for each individual structure separately from the enclosure's own construction, sealing, atmospheric conditioning, and readiness. Consequently, a Worldhouse can remain under construction or not yet be human-rated while particular internal structures are already complete and operational, others are still being built, and others remain planned. The Worldhouse's overall environmental state and each structure's own development state are related but distinct.

A structure's rating is determined by the environment and safeguards required for its intended occupants and operations, not automatically by the rating of the Worldhouse as a whole. A non-human-rated facility may operate in a non-human-rated portion of the enclosure, or may require its own local containment or environmental boundary if its processes are incompatible with surrounding occupied areas. Conversely, a human-rated building can provide a safe occupied environment before the entire Worldhouse reaches human-rated conditions. The exact division between shared ambient conditions, local building systems, and separated zones depends on the facility and its hazards.

Different activities may require separate internal zones, access controls, containment boundaries, environmental conditions, or dedicated systems. Do not assume all functions can share one undivided volume. Equally, do not assume every function requires a completely independent life-support plant; the actual engineering boundary remains to be determined.

## Local Environment, Biosafety, and Planetary Interaction

A Worldhouse creates a local controlled environment. Its internal atmosphere and biological processes do not automatically change the external planetary atmosphere, hydrosphere, or open biosphere.

Contained organisms may be researched, incubated, adapted, or used in a seed program without implying that they have been released to the surrounding world. Deliberate release, unsealing, or another form of external coupling is a separate operation requiring its own environmental and biosafety assessment. It is not an automatic final stage of every Worldhouse.

See [Contamination & Biosafety](./contamination_and_biosafety.md) for containment and residual-risk principles, and [Planetary Protection & Environmental Governance](./planetary_protection_environmental_governance.md) for the broader protection framework.

## Relationship to Other Infrastructure

- **Habitation modules:** Can provide an independently life-supported occupied space inside a larger lava-tube Worldhouse during incremental construction.
- **Life support:** Supports occupied modules and any human-rated zones; it should not be assumed that the entire Worldhouse shares the module's atmosphere. See [Life-Support Systems & Waste Recycling](./life_support_systems_and_waste_recycling.md).
- **ISRU and fabrication:** Local materials can support structural manufacturing and expansion. See [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md).
- **Terraforming-seed programs and Bio-Nurseries:** Optional biological uses hosted in suitable structures; they do not define the Worldhouse structure itself.
- **Planetary terraforming:** A separate, larger-scale activity. A Worldhouse may support experiments or contained biological work, but is not itself a planetary-atmosphere modification.

## Open Engineering Questions

The following details are not settled by the current wiki intent:

- Geological suitability criteria and the supported range of host-feature geometries.
- Structural load cases, anchoring, bracing layout, material properties, and safety margins.
- Panel construction, transparency, shielding, solar integration, joints, and replacement methods.
- How skylights, entrances, access points, airlocks, hangars, and service connections are treated in each form.
- Construction segmentation, robotic equipment requirements, inspection methods, and acceptance criteria.
- What constitutes sufficient enclosure integrity for atmospheric establishment; historical references to a complete seal are not yet a universal accepted rule.
- Pressure-management trajectories, gas sourcing, compression and processing capacity, composition tuning, and stabilization time.
- Environmental zoning and the extent to which power, thermal management, atmospheric processing, and life support can be shared.
- How construction, occupancy, and biological containment boundaries are represented together.
- Maintenance, leakage, repair, and long-term operating requirements.

## Historical Source Conflicts and Reconciliation

The frozen documents contain different generations of Worldhouse framing. They remain unchanged; this page records how their claims are treated in the current wiki.

| Frozen source | Historical framing or claim | Current treatment |
|---|---|---|
| `docs/architecture/intent/worldhouse_intent.md` | Worldhouse as a pressure-sealed, atmosphere-neutral vessel; atmosphere selected after sealing. | Consistent with current structure/profile distinction. Its suggestion that the volume is then simply filled is not a duration or operational specification. |
| `docs/architecture/systems/environmental_volume_intent.md` | Separate structural and atmospheric-content layers; illustrative industrial, biological, and human profiles; complete sealing before gas injection. | Useful conceptual source. Exact profiles and a universal 100% sealing gate remain unconfirmed. |
| `docs/architecture/structures/worldhouse_design.md` | Worldhouse primarily described as a segmented, pressurized, breathable habitat, with fixed segment fields, panel dimensions, population formula, and a pressurized status transition. | Historical human-habitat framing conflicts with current atmospheric optionality. Its numeric and schema-like details are not adopted as current requirements. |
| `docs/architecture/simulation/construction_system.md` | Lunar sequence seals and pressurizes the whole tube before crew arrival; Mars example gives a staged 40 kPa-to-human-atmosphere path. | Conflicts with the current Luna pattern of occupied, independently life-supported modules while robotic Worldhouse construction continues. The Mars pressure values and durations are historical examples, not established targets. |
| `docs/architecture/simulation/atmospheric_maintenance_system.md` and `docs/gameplay/PLANETARY_TERRAFORMING_SOP.md` | Worldhouses treated as staged planetary-terraforming test facilities, with later unsealing and ecosystem release. | Not adopted as a mandatory Worldhouse lifecycle. Internal containment remains distinct from any deliberate external release or planetary interaction. |

## Related Wiki Pages

- [Settlement Infrastructure](./settlement_infrastructure.md)
- [Surface Habitat Options](./surface_habitat_options.md)
- [Life-Support Systems & Waste Recycling](./life_support_systems_and_waste_recycling.md)
- [Contamination & Biosafety](./contamination_and_biosafety.md)
- [Planetary Protection & Environmental Governance](./planetary_protection_environmental_governance.md)
- [Terraforming Seeds](../technical/biology/terraforming_seeds.md)
- [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md)
