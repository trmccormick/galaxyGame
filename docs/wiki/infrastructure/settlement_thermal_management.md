---
title: Settlement Thermal Management
category: Infrastructure
status: OWNER-CONFIRMED DESIGN INTENT / IMPLEMENTATION AUDIT OPEN
last_updated: 2026-11-27
---

# Settlement Thermal Management

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-26
> *Audit Summary:* Owner-confirmed direction for thermal management; existing thermal fields and mechanics not yet audited in code.

> **Page role:** Owner-confirmed direction for managing useful heat across a settlement. This is a settlement-level infrastructure concern, not a requirement for every unit to operate its own thermal network. Existing thermal fields and mechanics have not yet been fully audited; this page does not claim an implemented thermal-management system.

## Core Principle

GalaxyGame should account for heat as part of the physical inputs and outputs of its units, while coordinating useful heat at the settlement level.

A unit's operational definition may describe:
- power or other energy consumed;
- useful material and energy outputs;
- waste materials and waste heat;
- heat required to operate or maintain an appropriate temperature;
- capacity, efficiency, and operating limits.

Waste heat is not automatically a resource that must be discarded. Where its temperature and availability make it useful, the settlement can route it directly to a compatible process or structure, store it for later use, or reject it to the environment. A process that accepts recovered heat can reduce the electricity or other energy it would otherwise need to supply that heat itself. This is an avoided energy requirement, not energy creation; the benefit depends on temperature, timing, transfer capacity, and process efficiency.

Heat is energy transfer, not a material inventory like oxygen or water. Thermal storage represents energy retained for later recovery, with finite capacity and losses; it does not create a new material commodity.

This follows the common unit-model principle used for material and energy flows. It does not require a bespoke thermal simulation for every machine, habitat, or appliance.

## Terminology

- **Waste heat:** Thermal energy produced as an unavoidable by-product of a unit's primary operation, with no immediate use in that unit's function.
- **Useful heat:** Thermal energy captured, routed, or retained because it serves a settlement-level thermal requirement.
- **Heat rejection:** The act of dumping thermal energy to the environment (ground, atmosphere, vacuum) when it is no longer useful.
- **Settlement thermal management:** The aggregation and routing of useful heat across a settlement so that surplus from one process can offset demand in another.
- **Thermal network:** A conceptual abstraction for how useful heat moves between structures; GalaxyGame models this through the unit-model interface rather than an explicit pipe or duct graph.

The following fields are legacy / audit targets only. They record what code currently stores and what must still be audited against design intent: `waste_heat`, `waste_heat_kw`, `heat_generation_kw`, `thermal_load_max`, `radiator_capacity_kw`.

## Separation of Responsibilities

| Level | Responsibility |
|---|---|
| **Unit** | Describes heat generated, heat required, relevant operating-temperature limits, and other thermal effects associated with its operation. |
| **Structure** | Has local thermal conditions and heating/cooling requirements appropriate to its occupants, equipment, and purpose. |
| **Settlement** | Coordinates heat recovery, distribution, heat pumps, thermal storage, and rejection of surplus heat across connected facilities and structures. |

A unit does not independently manage the settlement-wide thermal network. Its thermal inputs and outputs contribute to the settlement's overall resource and energy picture.

## Useful Heat Recovery and Distribution

Potential sources include reactors, industrial processors, manufacturing equipment, power systems, and other operating units. Potential consumers include:

- habitats and occupied structures that need to remain warm;
- greenhouses and biological facilities with temperature requirements;
- water and other process systems that can use preheating;
- industrial processes that can accept heat at a suitable temperature.

The settlement should be able to use an available heat source before supplying the same demand through a separate energy-consuming heating process, where the temperatures, location, timing, and infrastructure permit.

Heat transfer is constrained by temperature difference and transfer capacity. A quantity of heat is not universally interchangeable between processes: a low-temperature source may be suitable for space heating but not for a high-temperature industrial process.

## Heat Pumps

A heat-pump-type unit can move heat from a lower-temperature source to a higher-temperature destination by consuming electrical power or another suitable energy input. This can make low-grade heat useful for warming structures or supplying processes that need a higher delivery temperature.

The heat delivered includes both the heat moved from the source and the energy supplied to operate the heat pump. Its performance depends on the temperature lift and operating conditions; it should not be represented as creating heat without an energy cost.

Heat pumps are a possible settlement thermal-infrastructure capability. This page does not establish a finalized blueprint, technology tier, coefficient of performance, or mandatory equipment configuration.

## Thermal Storage

Thermal storage allows heat collected when supply exceeds immediate demand to be retained and used later. It can help balance differences between:

- industrial operating schedules and habitation heating demand;
- day/night or other environmental temperature cycles;
- intermittent power generation and available heat-pump operation;
- heat production and the timing of greenhouse or industrial demand.

Storage has finite capacity and operating-temperature limits. Stored energy bleeds away over time, so storage must account for standing losses as well as the amount that can later be recovered. Recovery is also limited by the unit's usable temperature range and transfer capacity.

A lightweight, reusable **Heat Storage and Recovery Unit** is the intended infrastructure concept. It accepts suitable waste heat, stores a limited amount, and makes recoverable heat available to compatible consumers later. Supporting collection, heat-exchange, transfer, and distribution units may be used where the settlement layout requires them; these functions do not require a detailed pipe-and-duct simulation. Engineered rock mass can serve as a storage medium where suitable, but surrounding rock or a lava tube is not automatically an unlimited thermal battery: it must be coupled to the system through appropriate heat-transfer equipment.

Compatible processes may also consume waste heat directly without storing it first. Storage is useful when supply and demand do not coincide; it is not a required intermediary for every heat transfer.

## Heat Rejection

Not all heat can be recovered or stored. Surplus heat must be rejected through an appropriate path. Radiators are a general option, including for vacuum environments; on worlds with an atmosphere, air-cooled systems may also be practical. Heat pipes, coolant loops, and other transfer equipment may support either recovery or rejection where appropriate. Available rejection capacity and environmental conditions constrain how much heat-producing equipment can operate.

Heat rejection remains necessary even when a settlement has heat recovery and storage. The goal is not to eliminate waste heat but to make useful use of it when practical and safely reject the remainder. The game need not model every cooling method or its detailed control loop.

## Gameplay Boundary

Thermal management is a supporting settlement-infrastructure capability, not a core gameplay loop. The intended level of detail is deliberately lightweight. Meaningful decisions may include:

- providing enough heat-recovery, storage, and rejection capacity for the base;
- prioritizing compatible processes and structures that can use available waste heat;
- deciding whether surplus heat should be used now, stored for later, or rejected;
- installing heat pumps where low-grade heat can be upgraded usefully, recognizing their power cost;
- balancing infrastructure cost, power demand, maintenance, and reliability.

The simulation should account for useful heat availability, finite storage, standing losses, recovery limits, and rejection capacity. It should not track every rock or structure temperature, every valve, or continuous thermal fluctuations. Routine equipment operation is automatic; the Player or AI Manager makes settlement-level infrastructure and priority decisions.

Ordinary habitat HVAC remains an integrated structure capability, as described in [Life-Support Systems & Waste Recycling](life_support_systems_and_waste_recycling.md). The settlement thermal network can supply useful heat to those structures; this does not require separate player-managed HVAC appliances in every habitat.

## Harvested Reference Notes

Summaries drawn from frozen design references; they reflect proposals and author intent, not current owner-confirmed implementation or code state.

### ECLSS thermal loop concept (`docs/design/ECLSS_SYSTEM_ARCHITECTURE.md`)
The reference proposes a dedicated Power & Thermal Loop in which electronics, lighting, and metabolic activity generate excess heat that is carried by thermal coolant through a radiator grid. Undersized or damaged radiators allow internal temperatures to rise ([PROPOSED / PLACEHOLDER]). The document ties the thermal loop to other ECLSS cycles (water, atmosphere, food) and models cascading failures where increased power consumption raises waste-heat production, which stresses radiators and further degrades life-support performance. A game-parameters table in that reference lists `radiator_capacity_kw` and `current_heat_load_kw` as node-state fields ([PROPOSED / PLACEHOLDER]). These numeric constants are design artifacts; they do not establish an active code contract.

### Habitat thermal dissipation contrast (`docs/design/HABITATION_NODE_ARCHITECTURE.md`)
The Habitation Node reference contrasts burial and surface deployment for thermal management: a buried Luna-surface base has low thermal-cycling risk because regolith acts as insulation and heat sinks, whereas open-lattice orbital depots and deep-space cyclers require external radiator wings exposed to direct solar deltas. The table in that document also lists `Sintered Regolith Shield Panels` as a locally manufactured surface panel that insulates against radiation and extreme thermal swings ([PROPOSED / PLACEHOLDER]). These are architectural comparison notes; no transfer formulas or radiator sizing rules are derived from them.

### OPEN gaps vs current owner intent
Both references leave the following explicitly open:

- **Thermal loop integration:** Whether the ECLSS power/thermal cascade should be implemented as a DAG network or via sequential procedural checks (ECLSS_SYSTEM_ARCHITECTURE.md).
- **Radiator sizing and capacity model:** No formula ties `radiator_capacity_kw` to heat_load, environmental context, or panel slots.
- **Buried-vs-surface trade-offs:** The habitation node thermal-dissipation contrast is descriptive only; it does not define concrete gameplay mechanics for regolith-insulation bonuses or surface-radiator penalties.
- **Fire / contamination spreading:** How localized toxic-gas spikes propagate through module ducting remains unresolved (ECLSS_SYSTEM_ARCHITECTURE.md).

These gaps remain OPEN in the current wiki page and its source references. No implementation change is authorized by harvested notes until owner intent is recorded on this page.

## Existing Tracking and Thermal Field Inventory

Some existing sources and data contain thermal concepts, including waste_heat, waste_heat_kw, heat_generation_kw, thermal_load_max, and radiator-capacity examples. The table below conservatively catalogs where each field currently appears. A conservative inventory of known occurrences across the repository is provided below. Their presence in isolated configuration or historical design files does not establish a coherent, active thermal simulation or settlement-wide heat network.

| Field | Example locations (path) | Appears active? (yes/no/unknown) | Notes |
|---|---|---|---|
| `waste_heat_kw` | `galaxy_game/app/data/operational/natural_wormhole_anchor_mk1h_data.json` | no | Config data file only; not loaded by any runtime service. Also appears in `ECLSS_SYSTEM_ARCHITECTURE.md` as a proposed game parameter (`radiator_capacity_kw`, `current_heat_load_kw`). |
| `waste_heat` | `galaxy_game/config/units/storage.yml` (lines 21, 71), `galaxy_game/config/units/production.yml` (line 96) | unknown | Configuration data; runtime consumption not verified. May describe per-unit heat generation in arbitrary units. |
| `heat_generation_kw` | `galaxy_game/tools/transform_component.rb` (line 379) | no | Tool script only (not a Rails service or model). Appears as a static example value (`1.0`). |
| `thermal_load_max` | *(not found in rb/json/yml)* | unknown | Referenced on this wiki page and frozen design docs, but no occurrence found in code or config files searched so far. May exist only as prose intent. |
| `radiator_capacity_kw` / `current_heat_load_kw` | `ECLSS_SYSTEM_ARCHITECTURE.md` (proposed game parameters table) | no | Proposed schema fields in a frozen design reference; not found in active Rails config or data files. |

No runtime service (`galaxy_game/app/services/`) was found loading, computing, or transferring any of these thermal fields. Before extending or retaining those mechanics, audit where these fields are loaded, consumed, calculated, transferred, and persisted in current code and data. Determine whether they are active, duplicated, inconsistent, arbitrary placeholders, or remnants of older designs. Redundant or unsupported tracking may need to be consolidated or removed rather than expanded into a second thermal subsystem.

The owner has not yet selected which existing thermal fields or mechanics should remain. Exact heat units, temperature representation, transfer rules, network topology, storage model, heat-pump performance, and radiator/rejection calculations remain OPEN. No implementation change is authorized by this design-intent entry.
