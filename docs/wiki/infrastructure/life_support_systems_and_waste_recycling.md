# Life-Support Systems & Waste Recycling

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Updated:* 2026-11-22  
> *Last Audited:* 2026-11-22
> *Audit Summary:* Page role and design intent confirmed by owner; operational connections between units, cargo, and blueprints remain to be verified in code.

## Established Intent — Unit-Based Simulation (2026-11-22)

GalaxyGame models most equipment through a common operational definition rather than simulating each machine's internal engineering. A unit is primarily described by:

- **Inputs:** resources and materials consumed.
- **Power:** energy required for operation.
- **Outputs:** useful products and byproducts.
- **Capacity and efficiency:** how much it can process and how effectively.
- **Maintenance:** labor, replacement parts, and associated costs.
- **Storage:** input, output, or process inventory where applicable.

This common model supports life support, waste processing, agriculture, chemical processing, and manufacturing without requiring a bespoke simulation subsystem for every real-world component. The meaningful simulation emerges from resource dependencies, unit capacity, power availability, maintenance, and how units are combined.

Do not create a separate unit or detailed mechanic for every appliance, pump, filter, valve, or control component. Model a component separately only when it creates a meaningful operational constraint, resource flow, cost, maintenance burden, or gameplay decision.

## Existing Life-Support and Waste-Processing Unit Designs

The following units are represented in the early blueprint examples reviewed for this page. The list documents existing design work; it is not intended as an exhaustive catalog or a claim that every operational connection has been runtime-verified.

### Waste and water processing

| Unit | Designed role |
|---|---|
| **Waste Management Unit** | Receives and sorts settlement liquid and solid waste, routing useful streams to downstream processing and producing residual inert waste. |
| **Water Recycling Unit** | Processes wastewater into reclaimed water and nutrient solution; its brine byproduct returns to the waste stream. |
| **Biomass Recycler** | Converts suitable organic waste into usable biomass. |
| **Biogas Digester** | Processes biomass and organic waste into biogas and digestate, with wastewater as a byproduct. |

### Atmosphere and biomass production

| Unit | Designed role |
|---|---|
| **Algae Bioreactor** | Uses carbon dioxide and water to produce algae biomass and oxygen; sludge is a byproduct. |
| **CO₂/Oxygen Production Unit** | Blueprint-defined CO₂ processing equipment with oxygen and water outputs. Detailed chemistry and operating balances should be checked against its operational data before quantitative tuning. |

### Food production and habitat support

| Unit | Designed role |
|---|---|
| **Inflatable Greenhouse** | Provides hydroponic and soil-based growing capacity. Organic waste from greenhouse operations can be routed into the settlement's waste-processing and recycling network. |
| **Cycler Habitat Module Mk1** | Crew-capable habitat module with integrated life-support capability; its operational details are referenced through habitat operational data. |
| **Radiation Shielding Module Mk1** | Provides additional radiation protection where required, including around high-output reactors and fusion drives. This is supporting habitat infrastructure rather than a waste-processing unit. |

These units already cover substantial parts of settlement life support: waste intake and sorting, water recovery, organic-waste processing, biogas production, biomass cultivation, oxygen production, and food growing. New equipment should not be added merely because a real-world ECLSS inventory contains another named component. First identify a genuinely missing capability or useful resource flow.

## How the Resource Flows Work Together

The settlement life-support network is formed by combining units and routing their inputs, outputs, and byproducts. Examples represented in the blueprint designs include:

- Waste Management routes suitable liquid waste toward water recycling and organic material toward biological or waste-processing paths.
- Water Recycling returns reclaimed water and nutrient solution to useful settlement inventories; brine returns to waste processing.
- Biomass Recycling and anaerobic digestion provide different ways to recover value from organic waste. Digestion also produces biogas and digestate for downstream use.
- Algae cultivation uses water and CO₂ while supplying oxygen and biomass.
- Greenhouse operations provide food-growing capacity and return organic waste to the settlement's recycling network.

The precise routing, storage, and operating rates are defined by the relevant unit and operational data. Do not assume that every illustrative connection above is already wired or validated in runtime code solely because the blueprints describe the intended flow.

## Habitat Environmental Controls

**Established Intent — Integrated HVAC (2026-11-22)**

Ordinary habitats are assumed to have integrated HVAC and environmental controls for heating, cooling, and humidity control. These are part of the habitat's baseline capability and do not need to be represented as separate dehumidifier or humidifier blueprints.

Excess moisture collected by habitat HVAC is treated as clean condensate and returned directly to the clean-water system. It does not require a separate graywater treatment path in the simplified habitat model.

GalaxyGame does not need to track habitat humidity as a separate simulation variable or model the internal operation of HVAC appliances. Habitat environmental control is represented at the level needed for crew survival, power demand, maintenance, and overall resource balances. Humidity remains relevant to planetary/environmental simulation where it has meaningful effects on climate, clouds, precipitation, or hydrology; that is a different simulation scale.

Habitat heating can also benefit from settlement-level recovery and distribution of useful waste heat. Unit-level thermal outputs and local structure heating requirements feed that wider infrastructure; the settlement coordinates heat pumps, storage, distribution, and rejection. See [Settlement Thermal Management](settlement_thermal_management.md).

## Facility Growth and Settlement Scaling

Life-support capacity grows by adding units, not by introducing a new bespoke simulation layer:

- **Initial base:** Provide enough existing units to handle the settlement's essential waste, water, atmosphere, and food-support needs. The initial arrangement may be compact and distributed among available structures.
- **Growing settlement:** Add existing units as population, waste generation, water demand, and production requirements increase.
- **Larger settlement:** Build dedicated life-support or waste-processing facilities and install the appropriate existing units within them.

A facility is the structure and operational arrangement that houses the equipment. The units provide the processing capabilities. The player or AI Manager manages capacity, power, maintenance, and resource routing; routine internal appliance operation does not become a separate micromanagement task.

## Atmospheric Life Support and Gas-Balance Management

**Established design intent — general life-support capability (2026-11-26)**

Atmospheric management is a general life-support function, not a Worldhouse-specific feature. Any life-support installation must maintain the atmosphere required by the environment and its occupants or biological processes. This applies at different scales, including crewed spacecraft, orbital stations, submarines, surface habitats, settlement facilities, greenhouses, biological incubation spaces, and enclosed ecosystems. The target atmosphere and required capabilities depend on the installation's purpose; not every installation needs the same equipment or degree of recycling.

The system must account for the combined gas sources and sinks operating in its environment, including:

- Human and animal respiration, which consumes oxygen and produces carbon dioxide.
- Photosynthesis, which consumes carbon dioxide and produces oxygen when light and biological activity support it.
- Plant respiration, microbial activity, soil processes, decomposition, and other biological exchanges, which can consume or release gases in different proportions.
- Industrial processing, gas generation, scrubbers, chemical reactions, and other equipment that consume, produce, capture, or transform gases.
- Leakage, venting, external intake, material interactions, and other exchanges with the surrounding environment.

The presence of plants or other photosynthetic organisms does not guarantee a stable breathable atmosphere. Biological and chemical activity can shift oxygen and carbon-dioxide levels in unexpected directions; the system must respond to the actual net balance rather than assume a fixed biological contribution.

### Required functional capabilities

A life-support system's functional scope may include:

- Monitoring atmospheric composition, pressure, and relevant environmental conditions.
- Circulating atmosphere through treatment and processing equipment.
- Removing excess carbon dioxide and other contaminants.
- Supplying or generating oxygen and other required gases.
- Adding or removing controlled gases as their concentrations move away from target ranges. For example, excess oxygen may need to be captured or removed, while carbon dioxide may need to be replenished when photosynthesis or other processes reduce it below its target.
- Recovering useful gases and routing them to compatible consumers, processing, storage, or controlled exhaust.
- Maintaining gas inventories and reserve capacity where the installation requires storage.
- Coordinating gas additions and removals with total pressure and the desired atmospheric mixture.
- Providing appropriate backup or emergency capabilities when normal equipment is unavailable.

These are functional responsibilities, not a requirement for a separate machine for every operation. Capabilities may be combined in equipment units or distributed among connected units. Storage, regeneration, consumables, venting, and resupply strategies can differ substantially between a short-duration spacecraft, a submarine, a long-duration station, and a large biological enclosure.

### Real-world engineering precedents

These systems illustrate different operating strategies and should be treated as references, not as a checklist of machinery to reproduce:

| Precedent | Useful design lesson |
|---|---|
| **International Space Station (ISS)** | Oxygen generation, carbon-dioxide removal and reduction, water recovery, contaminant control, and monitoring are distinct but coordinated functions. The system is not perfectly closed and still relies on external supplies. |
| **Crewed spacecraft** | Limited mass, volume, power, and mission duration drive compact systems, stored gas supplies, regenerable or replaceable scrubbers, and carefully chosen venting or resupply strategies. |
| **Submarines** | Long-duration occupied environments require continuous atmosphere monitoring, oxygen supply, CO₂ removal, contaminant control, and emergency fallback provisions. |
| **Biosphere 2** | Large ecosystems have complex biological and chemical gas exchanges. Soil microbes and material interactions can upset atmospheric balances; vegetation alone does not guarantee stable oxygen and CO₂ levels. |

### Atmospheric composition as inventory and unit resource flows

**Established design intent — simplified resource model (2026-11-26)**

The composition of the atmosphere held by a craft, habitat, station, structure, or other enclosed environment is represented through its gas inventory. Track the quantities of the relevant gases as inventory items associated with that environment. Atmospheric changes occur through ordinary resource transactions against that inventory; do not create a separate detailed atmospheric-chemistry simulation merely to account for routine consumption and production.

Equipment and biological processes use the same unit-based operational model as other GalaxyGame systems:

- **Inputs:** inventory resources consumed or processed.
- **Outputs:** inventory resources produced, including useful coproducts.
- **Power:** energy required to operate.
- **Capacity and efficiency:** processing or exchange rate and effectiveness.
- **Maintenance:** labor, replacement parts, and operating costs.

Examples:

| Activity or unit | Input | Output / inventory effect |
|---|---|---|
| Crew respiration | O₂ | CO₂ |
| Greenhouse photosynthesis | CO₂, water, light/energy as represented by its operating model | O₂, biomass |
| CO₂ processor | CO₂, power | O₂ and CO (for a MOXIE-like process) |
| CO₂ scrubber | CO₂ from the environment's gas inventory | Captured CO₂ routed to storage, processing, or another defined destination |
| Oxygen generator | Water, power | O₂ and any other process coproducts defined for that unit |

These examples describe resource-flow patterns, not mandatory blueprints or fixed chemistry for every unit. Use each unit's defined inputs, outputs, power, capacity, and efficiency. Where a process transfers a gas from an environment into a storage inventory, that transfer must be represented consistently so the same gas is not counted in both places.

The atmosphere is therefore not a special, disconnected resource pool: it is the gas inventory associated with the craft or structure. Equipment and biological activity change that inventory through their input/output flows. The resulting gas quantities can be checked against the environment's required composition and operating limits. Pressure or habitability consequences should be derived at the level needed for gameplay, without simulating every molecular interaction or internal control mechanism.

### GalaxyGame gameplay abstraction

GalaxyGame should represent the meaningful system-level consequences without simulating every valve, filter element, chemical reaction, or control loop. The gameplay model should focus on:

- Required atmospheric targets and acceptable operating ranges.
- Net gas production and consumption from occupants, biological systems, and installed equipment.
- Processing and replenishment capacity, including power and maintenance requirements.
- Gas inventory, useful byproducts, storage limits, and resupply or external-feedstock dependencies where relevant.
- Whether the system can respond quickly enough to changing demand, biological activity, equipment failure, or leakage.
- Environmental status and consequences when the system cannot maintain required conditions.

The player or AI Manager should make meaningful decisions about capacity, equipment selection, power, maintenance, resource routing, reserves, and system reliability. Routine internal operation of individual appliances should normally be handled by the simulation. Different installations can use different simplified equipment configurations while sharing these underlying life-support principles.

## Simulation Boundary

The intended level of detail is a simplified but connected engineering and resource simulation. Track the consequences that matter to settlement operation: resource inputs and outputs, power, capacity, efficiency, maintenance, and useful byproducts. Do not simulate every internal component or environmental-control variable when its effects can be represented by the habitat or unit's overall operating balance.

This page records design intent. Blueprint definitions and operational data should be inspected, and runtime behavior verified, before treating any individual unit or resource connection as fully implemented.
