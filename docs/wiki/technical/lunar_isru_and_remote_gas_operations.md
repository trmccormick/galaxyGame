# Lunar ISRU and Remote Gas Operations

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
- Remote atmospheric harvesting and delivery, including Venus-derived gas supplies.
- Fuel production, storage, consumption, and transport loops.
- Crew survival and continuity during delays, equipment failures, and shortages.
- Revenue and available cash sufficient to pay for purchases; the AI Manager must not assume unlimited funds.

The Rake-driven Luna operation is a reference baseline for validating outcomes. It is not the AI Manager's permanent operating script. The AI Manager must ultimately plan and manage the operation independently, including under changed conditions.

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

The fuel-loop rationale is specifically to combine this water-derived H₂ with CO₂ available to Luna, enabling local methane production for HLT engine propellant. This lunar production path is distinct from the Titan mission's proposed simple onboard gas separator, which would recover methane/ethane from Titan's atmosphere; the Titan craft would carry additional O₂ because the separator does not supply the matching oxidizer. The early simulation must validate and tune the lunar chain—including water extraction and processing, hydrogen availability, CO₂ supply and conditioning, methane synthesis, oxygen/oxidizer handling, storage, transfer, consumption, and losses—so that the resulting production rate and inventories can sustain the intended craft operations. This is a target for simulation validation, not a claim that the current equipment chain already closes the loop at adequate rates. The PSR path is part of the initial Luna strategy, with deployment expected after humans occupy the initial base; it should not be treated as an already validated production system.

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

The current operational benchmark specifically includes Venus atmospheric gas harvesting and its integration with Luna's fuel and supply loops. Craft fuel requirements, payload configuration, turnaround, and return logistics must follow the current craft designs and mission requirements—not the older mission profile's simplified fuel-exchange assumptions.

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
