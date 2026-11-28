# Lunar ISRU and Remote Gas Operations

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-26
> *Audit Summary:* Design intent confirmed for lunar ISRU workflows; not all described operational connections verified in code.

> **Status:** Consolidated design intent with historical-source reconciliation. This page harvests operational details from older Luna ISRU and base-establishment references. It does not claim that every described workflow is implemented.
>
> **Scope:** Surface volatile extraction, gas buffering and separation, infrastructure routing, remote atmospheric-gas deliveries, and the operational decisions needed to sustain the Luna base.
>
> **Related:** [ISRU Fabrication Chain](isru_fabrication_chain.md), [Atmospheric Harvesting](../infrastructure/atmospheric_harvesting.md), [Precursor Mission Deployment](precursor_mission_deployment.md), [AI Manager](../services/ai_manager.md), [AI Manager Economic Loops](../logistics/ai_manager_economic_loops.md), [EAP and AI Manager Escalation](../logistics/eap_and_ai_manager_escalation.md).

---

## 1. Operational Context

Luna is the first complete operational benchmark for the settlement simulation and AI Manager. The objective is not just to deploy equipment or demonstrate isolated ISRU output. The operation must coordinate:

- Surface construction, power, life support, storage, maintenance, and production.
- Earth-side procurement and resupply, including shipment timing and available USD.
- Remote atmospheric harvesting and delivery (Venus/Titan-derived gas) as a **later scored option** for the initial test profile; early CH₄/N₂ prefer Earth imports (see Initial test profile below and [Skimmers & mixed volatiles](../logistics/skimmer_and_mixed_volatiles.md)).
- Fuel production, storage, consumption, and transport loops.
- Crew survival and continuity during delays, equipment failures, and shortages.
- Revenue and available cash sufficient to pay for purchases; the AI Manager must not assume unlimited funds.

The Rake-driven Luna operation is a reference baseline for validating outcomes. It is not the AI Manager's permanent operating script. The AI Manager must ultimately plan and manage the operation independently, including under changed conditions.


### Earth–Luna infrastructure objective and operating model

**OWNER-CONFIRMED STRATEGIC REQUIREMENT — 2026-11-23**

The initial Earth–Luna buildout is a connected industrial, logistics, and spacecraft-construction system. It is not a standalone lunar settlement exercise, and lunar self-sufficiency is not the final objective. The required strategic progression is:

1. **Luna industrial base:** establish and continually expand the settlement's ability to harvest resources, process feedstocks, fabricate materials and components, maintain equipment, support its crew, and produce useful propellant. Earth imports remain necessary where local capability is not yet available or economical.
2. **Earth–Moon L1 Depot:** build the first depot using Luna-produced materials and propellant together with high-technology equipment and components imported from Earth. It supports lunar and onward logistics.
3. **Near-LEO Depot:** build the distinct Earth-side depot second. It supports refueling, cargo transfer/offload, and reducing the cost of launching onward cargo and propellant from Earth's surface.
4. **Orbital shipyards:** establish shipbuilding and spacecraft-support capacity after the two depot capabilities are in place.
5. **Mars expansion:** proceed to the next major expansion objective after this Earth–Luna industrial and orbital infrastructure has been established.

This order is a locked strategic dependency, not a fixed sequence of every individual task. Luna harvesting, fabrication, construction, maintenance, Venus harvesting, transport, resupply, and fuel production are expected to overlap whenever their actual dependencies, available assets, and resource constraints permit. The AI Manager must maintain existing operations while building the throughput and infrastructure needed for the next objective. It must not wait for an entire broad mission to finish before scheduling unrelated productive work.

The AI Manager's normal operating loop belongs in gameplay. Simulation-time checks and event/condition evaluations identify when time-dependent work becomes due; the AI Manager evaluates the world and determines what work should happen; Sidekiq executes eligible asynchronous tasks concurrently; results and changed game state return to the AI Manager for continued evaluation. A launch-window check or elapsed production interval, for example, need not itself become a background job. Sidekiq is for delegated work, not a replacement for simulation-time processing or AI decision-making.

Rake scripts and integration tests are development/validation instruments. They can establish test conditions, exercise services, and record benchmark outcomes, but they are not the in-game operating mechanism and must not hardcode the strategic progression as the AI Manager's only execution recipe. The AI Manager should learn and compose available capabilities to pursue these fixed objectives under changing conditions.

The L1 and near-LEO depots are separate required milestones with distinct roles; references that combine them, reverse their order, or place shipyards before the second depot are stale relative to this owner-confirmed progression. The exact build plans, task combinations, concurrency, costs, yields, and schedules remain matters for simulation and operational evaluation.

### Initial crew-supported settlement and robotic lava-tube development

**OWNER-CONFIRMED INITIAL DEPLOYMENT INTENT — 2026-11-26**

The initial Luna deployment is planned to establish enough occupied surface capability to support an ISS-scale crew, using multiple inflatable habitation modules and the necessary surface equipment. This is a bootstrap settlement package, not a requirement to finish and pressurize the entire lava tube before people arrive.

The crew is one possible way to support the planned initial permanently shadowed region (PSR) water-ice mining activity. Under this operating plan, the crew establishes and supports the mining operation at the lunar site; PSR mining can alternatively be pursued by robotic means once infrastructure permits — crew vs robotic for PSR mining remains OPEN.

In parallel, robotic construction continues work on the lava-tube Worldhouse: sealing and progressively developing the larger protected geological volume while the crew occupies the initial habitat modules and conducts the planned surface operations. The inflatable modules and their life-support capability provide the initial occupied settlement; the developing lava tube is the larger environmental structure. These are related but distinct deployment and completion milestones.

The crew's initial occupancy therefore does not depend on completion of the whole Worldhouse. Conversely, the existence of an occupied habitat does not mean the tube has been fully sealed, brought to its target pressure, or composition-conditioned. Robotic construction/sealing and PSR mining proceed as parallel workstreams, subject to their actual logistical and safety dependencies; PSR mining is not a prerequisite for initial occupancy.

### Luna buildout as a multi-profile experiment

Luna is a required strategic infrastructure objective and the first integrated settlement benchmark, but its initial design, supply chain, and buildout profile are not fixed. Multiple in-game profiles should pursue the same Luna outcome using different viable combinations of Earth imports, local ISRU, remote harvesting, spacecraft, manufacturing locations, and investment timing. Those profiles are experimental approaches—not competing definitions of the strategic objective and not a closed list of what the AI Manager may do.

The owner's preferred long-term pathway is a Luna-first industrial and fuel economy that reduces dependence on lifting fuel and other mass from Earth. It is a strategic preference and a hypothesis to evaluate, not a result already established by simulation. Earth-supported and hybrid profiles remain valid comparisons. An Earth-supported profile may import any requirement Luna cannot yet produce, including N₂, and omit the Venus harvester. Its cost must include recurring Earth launch and delivery requirements, not just the initial base construction.

Other candidate in-game approaches include using Mk1 HLT and imports to establish Luna before remote harvesting; investing in an Earth-orbital shipyard and building a dedicated harvesting craft before heading to Luna; or investigating a more capable HLT before remote operations. The Mk2 HLT is only a proposed design direction at this point—there is no established Mk2 specification, capability set, or cost estimate. Titan was an early harvesting option, but the initial Mk1 harvester could not support the long-duration mission and cryogenic retention requirements. This is a limitation of that early craft/configuration, not a permanent exclusion of Titan from later strategies.

### Initial test profile — Earth-supported volatiles (DIRECTION — owner, 2026-11-27)

- **Strategic objective unchanged:** build Luna industrial capacity to establish and supply the depots (Earth–Moon L1, then near-LEO) and support onward expansion. How volatiles and storage are supplied is scored from available options and missions/tasks.
- **Early CH₄ and N₂:** Earth imports (e.g. cargo landers delivering tank loads into the lava-tube internal tank farm; later bulk via tanker-class craft when that option exists).
- **Early LOX:** Luna local ISRU preferred.
- **Local methane generators:** optional secondary — e.g. nighttime emergency power; products (CO₂, water) may feed greenhouse/storage; limited daytime methane make may support a thin loop but does **not** replace Earth CH₄ for the initial profile.
- **Venus HLT Mk1 / Titan harvesters:** deferred for the initial profile. HLT Mk2+ (updated units/equipment) may restore a viable Venus→Luna skimmer loop later; AI Manager may score that when infrastructure and missions allow.
- **PSR water-ice mining:** not required on the early critical path solely to feed methane synthesis if CH₄ is imported. Retain as a later option for local water/H₂/fuel independence. Crew vs robotic division remains OPEN.
- **Tank farms (options, not a mandated layout):**
  - Lava-tube **internal** tank farm expands as lander (and later tanker) N₂/CH₄ are moved inside.
  - **Surface** tank farm accepts tanker offload; holds LOX for refueling and typically methane as well.
  - Storage hardware options include multi-purpose cryogenic tanks (Mk1–Mk3; Mk1 suited to Earth-built shipping and internal farm; higher marks for longer-haul/lower boil-off), inflatable cryo tanks with 3D-printed regolith shells, inflatable pressure tanks with shells, and inflatable gas storage buffers. Exact mix is chosen by plan/mission scoring, not fixed by this page.

### Alternate / later profile — Venus–Luna resource sequence (owner-confirmed direction)

When testing the preferred Venus-supported pathway, preserve these dependencies without turning the whole operation into an unnecessarily serial script:

1. Establish dependable initial RTG power and communications.
2. Prepare landing pads and tank-farm/storage infrastructure while early lunar ISRU proceeds; these workstreams can overlap where their actual dependencies permit.
3. Begin regolith processing early. It accumulates O₂ for habitat reserves and begins I-beam production. I-beams support elevated solar-panel mounting arrays so panels are raised off the lunar surface. The Solar Expansion Rig is a separate HLT-mounted component; do not conflate it with the I-beam-supported elevated arrays.
4. Scout and prepare the lava-tube site before the Venus harvester arrives. Habitat placement may begin before the Venus return, but completion of the intended pressurized habitat requires an adequate N₂ supply.
5. Return the Venus harvester with its actual captured atmospheric mixture. Separate N₂ for habitat pressurization and retain CO₂ for further processing and industrial use. Venus harvesting is not a targeted N₂/CO₂ intake; the returned composition follows the source atmosphere at the time of collection.
6. Complete habitat pressurization and establish the first human crew. Begin PSR water-ice mining with that first crew, after the Venus return and habitat pressurization.
7. Use hydrogen recovered from PSR-derived water together with Venus-derived CO₂ as feedstocks for lunar methane production. Regolith/PVE and other suitable local processes supply O₂/LOX as supported by their actual equipment and yields.

The exact task graph, concurrency, quantities, production rates, and operational timing must be determined and validated through the simulation. The sequence above records dependencies and intended timing; it is not a mandate to serialize independent work into rigid phases.

The reusable Venus harvester is an operating asset: it returns to Luna for unloading, inspection, repair, and turnaround before repeating its mission. Its onboard CO₂ processing produces most of its own LOX; methane replenishment and repairs remain requirements. The economics must include the initial craft and deployment investment, mission methane, actual LOX balance, maintenance/repair parts, turnaround time, useful delivered gas mass, and Earth imports avoided over repeated missions.

Luna's intended downstream role is larger than supplying its own settlement. Local methane and LOX production can support the harvester fleet and provide fuel to the L1 Depot first, then the near-LEO Depot, reducing the propellant that must be launched from Earth's surface for onward transport. The L1 and LEO depots are fixed strategic objectives in that order; the profile experiments compare ways to establish and supply them, not whether to build them.


## 2. Surface ISRU: Extraction, Buffering, and Separation

The older lunar ISRU references describe a useful functional chain:

1. Harvest surface regolith and deliver it to suitable extraction equipment.
2. Extract mixed volatile streams and retain the solid byproducts for downstream use.
3. Route captured gas into intermediate buffer storage.
4. Feed buffered gas to separation and any compatible liquefaction or conditioning equipment.
5. Route separated products to appropriate storage and consumers.
6. Reuse depleted or processed regolith as construction/fabrication feedstock where the material is suitable.

The current [ISRU Fabrication Chain](isru_fabrication_chain.md) establishes the broader design intent that TEU and PVE are modular building blocks, not one mandatory hard-coded sequence. It also records an unresolved discrepancy between the TEU/PVE design descriptions, unit operational data, blueprint descriptions, and service/optimizer ordering. This page does not resolve that discrepancy.

### Buffer storage

An intermediate gas buffer decouples extraction timing from downstream separation and storage. This can help manage variable production, equipment duty cycles, and downstream capacity. The older lunar flow proposes an inflatable pressure tank for mixed-gas buffering and cryogenic tanks for separated products.

The exact tank types, pressure limits, capacities, thermal behavior, transfer rates, and control rules remain subject to the relevant unit and structure definitions. Do not treat the older reference's example tank inventory or assumed gas composition as a current blueprint specification.

### Solid byproduct reuse

The older lunar flow identifies depleted or oxide-rich regolith as a potential feedstock for printed shells, beams, panels, construction fill, and other structural products. This is consistent with the current ISRU design direction that depleted regolith is a useful material stream rather than automatically waste. Actual acceptance depends on composition, processing, and the target fabrication blueprint.

### PSR water-ice mining for lunar hydrogen supply (DIRECTION)

The initial Luna buildout was pivoted toward **permanently shadowed region (PSR) water-ice mining** after the early Titan atmospheric-harvesting plan proved unsuitable for the HLT Mk1. Mk1's cryogenic boiloff over the long Titan-to-inner-System mission made that return route impractical with the initial craft. Rather than make early Luna operations depend on that mission, the near-term plan is to establish a local PSR ice-mining path to supply Luna's **H₂ needs**.

This water-ice resource path is distinct from the TEU/PVE regolith-processing chain described above; it is not another name for that chain and should not be forced into its unresolved processing order. The intended resource is PSR water ice, with hydrogen recovered for Luna's industrial and fuel requirements. The detailed mining equipment, water handling and separation steps, production rates, storage, transport from PSR sites, and exact integration with the lunar fuel loop remain OPEN pending reconciliation with current unit data and blueprints.

The fuel-loop rationale is specifically to combine this water-derived H₂ with CO₂ available to Luna, enabling local methane production for HLT engine propellant. This lunar production path is distinct from the Titan mission's proposed simple onboard gas separator, which would recover methane/ethane from Titan's atmosphere; the Titan craft would carry additional O₂ because the separator does not supply the matching oxidizer. When CH₄ is Earth-imported for the initial test profile, PSR water-ice mining is not on the early critical path solely to feed methane synthesis; it remains a later option for local water/H₂/fuel independence and possible methane synthesis from local components. This should be evaluated through simulation rather than treated as an established production requirement.

## 3. Planetary Umbilical Hub: Routing Concept

An older Luna architecture describes the Planetary Umbilical Hub as a shared surface connection point for power, gas, and data. Surface units register their ports with the hub, and the hub routes transfers rather than requiring every unit to connect directly to every other unit.

This is a useful architectural pattern to retain as design intent:

- The landed craft, surface power sources, harvesters, extraction units, separators, storage, and fabrication equipment need compatible connections.
- Power, gas/material transfer, and data/control are distinct routed services, even where they share a physical umbilical or hub.
- The network should support adding or replacing units without redesigning every direct connection.
- Existing gas-transfer mechanisms should be reused where suitable rather than creating a parallel transfer system.

**Implementation status is not established by the frozen reference.** Its 2026-07-01 implementation note says a legacy port adapter and `connect_units` action existed, while `register_to_bus` and hub routing logic did not. That is a dated historical snapshot, not a current code audit. Verify current port, transfer, and task-execution code before describing bus registration as implemented or assigning a new task.

Open details include hub topology, port compatibility, routing arbitration, transfer-rate constraints, failure isolation, and how power/data routing relates to gas-transfer connections.

## 4. Remote Atmospheric-Gas Operations

Atmospheric harvesting craft collect the atmosphere they actually intake. They do not selectively scoop a target gas from the planetary atmosphere. The delivered stream therefore reflects the source atmosphere's current composition and may change as the planetary atmosphere changes.

For Luna operations, this means:

- Treat returned atmospheric material as a mixed-gas feedstock until it has been processed.
- Separate and store useful constituents locally according to actual composition, equipment capability, demand, and available storage.
- Track source, delivered quantity, composition, losses, and processing outputs so the AI Manager can forecast usable supply rather than treating all delivered mass as one finished product.
- Do not assume a skimmer can produce a gas that its equipment and source atmosphere cannot provide.
- Do not assume atmospheric harvesting is a substitute for the surface ISRU chain; the two supply paths provide different feedstocks and capabilities.

The current operational benchmark includes Venus atmospheric gas harvesting and its integration with Luna's fuel and supply loops as a design concept; for the initial test profile, Venus harvesting is deferred and full integration is a later scored option. Craft fuel requirements, payload configuration, turnaround, and return logistics must follow the current craft designs and mission requirements—not the older mission profile's simplified fuel-exchange assumptions.

### Docking, unloading, and turnaround

The older skimmer reference usefully identifies docking as an operational interface between a visiting craft and the settlement's gas-processing/storage network. A complete turnaround needs to account for:

- Craft arrival and safe docking/connection.
- Transfer of delivered material into available receiving capacity.
- Recording the actual delivered mixture and quantity.
- Processing and storage capacity at the receiving site.
- Craft inspection, repair, refueling, and readiness for its next launch opportunity.
- Departure timing and any cargo that cannot be offloaded before departure.

The exact transfer order and departure policy must be taken from the current craft and mission design. The old proposal's specific Titan/Venus pairings, fuel barter assumptions, and “empty all raw tanks before departure” rule are not adopted here.

## 5. AI Manager Operational Decisions

The AI Manager must manage the combined operation rather than optimize each machine or mission independently. Relevant decisions include:

- **Production planning:** choose viable extraction and processing configurations from surveyed resource availability, equipment capability, power, and maintenance state.
- **Buffer management:** compare expected production and delivery against available intermediate and product storage.
- **Processing priorities:** choose which gas streams to process and retain based on current composition, demand, equipment, and storage constraints.
- **Resupply:** forecast shortages early enough to account for procurement, launch windows, transit, and delivery delays.
- **Fuel continuity:** ensure craft and surface operations have the required propellants before committing to missions or transfers.
- **Financial constraints:** compare purchases and operating costs with actual USD income and cash on hand. A shortage cannot be solved by issuing an unaffordable purchase.
- **Survival priorities:** protect life support, critical maintenance, and continuity before discretionary expansion.
- **Recovery:** respond to equipment failure, delayed deliveries, reduced harvesting, and competing demands without relying on a fixed scripted sequence.

These decisions are part of the Luna Rake benchmark and the subsequent AI Manager evaluation. Candidate decisions and observed outcomes should become evidence for training and assessment; they must not be confused with proof that the AI Manager already performs them autonomously.

## 6. Luna-to-Orbit Dependency

The established Sol bootstrap begins with the Luna foothold and then builds the Earth–Moon L1 depot. Luna's industrial output and Earth-imported high-tech components support the L1 build. The next planned logistics node is a separate near-LEO depot, followed by the larger station and shipyard infrastructure as their dependencies are satisfied.

The older Luna base profile contains a more prescriptive sequence in which an L1 shipyard follows immediately after the L1 depot and HLT craft are used for particular construction and skimmer roles. That sequence is not adopted as a current requirement. The active bootstrap ordering and current craft roles take precedence.

## 7. Historical Claims Not Adopted as Current Requirements

The following items appear in the frozen references but are not carried forward as settled design:

| Historical claim | Current treatment |
|---|---|
| TEU must always precede PVE, or PVE must always precede TEU | Unresolved. Current wiki explicitly records conflicting design, blueprint, operational-data, and service-order descriptions. |
| All lunar extraction occurs by day and gas separation only by night | Historical operating proposal. Not established as a universal schedule or current runtime rule. |
| Natural lunar cold provides a specified separation/liquefaction advantage | Plausible design consideration, but exact equipment behavior and thermal model remain open. |
| Six-month harvesting estimates and listed mass outputs | Not adopted. The old estimate contains assumptions and figures that have not been validated against current unit data and mass balance. |
| Titan gas delivery is the required early CH₄ source, with a fixed Titan/ Venus skimmer fuel barter | Superseded by current craft, mission, and fuel-loop decisions; do not use as a planning rule. |
| Luna's Sabatier loop and imported CO₂/H₂ necessarily eliminate CH₄ imports on a fixed progression | Not established by this harvest. Requires current chemistry, equipment, feedstock, and economic validation. |
| L1 shipyard immediately follows the L1 depot, with LEO depot as a later optional note | Does not represent the current locked bootstrap ordering. |
| GCC market transactions and standing contracts are the required initial Luna funding model | Not a substitute for the current Rake benchmark's explicit USD income, cash, expense, and purchasing constraints. GCC market design is documented separately and must not be conflated with this benchmark. |
| `register_to_bus` was implemented | The frozen source's dated note says it was not implemented at that time. Current implementation must be inspected before making any claim. |

## 8. Open Questions

- What is the current authoritative TEU/PVE processing order and how do the unit data, blueprints, optimizer, and production services reconcile?
- Which existing gas-transfer services and port abstractions should the hub use?
- What are the actual capacities, rates, pressures, and thermal requirements for buffers, separators, and product storage?
- Which operating constraints depend on local illumination, temperature, or power availability, and how are they represented in simulation?
- What are the current mission-specific gas payloads, onboard processing capabilities, fuel requirements, and turnaround rules for each atmospheric-harvesting craft?
- Which gases are needed by Luna's life-support, industrial, and fuel systems, and what local processing paths are actually supported?
- How should the AI Manager value delayed supply, inventory buffers, maintenance, and emergency procurement under the USD constraint?

---

**Source reconciliation:** Harvested from the frozen references `docs/architecture/systems/LUNA_ISRU_GAS_PROCESSING_AND_SKIMMER_OPERATIONS.md`, `docs/architecture/patterns/planetary_patterns/lunar_isru_flow.md`, `docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md`, and `docs/architecture/operations/precursor_industrial_loop.md`. These historical files were not modified. Contradictions and unverified proposals are identified above rather than silently promoted into current requirements.
