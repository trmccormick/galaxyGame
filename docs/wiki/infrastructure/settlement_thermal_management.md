---
title: Settlement Thermal Management
category: Infrastructure
status: OWNER-CONFIRMED DESIGN INTENT / IMPLEMENTATION AUDIT OPEN
last_updated: 2026-11-26
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

Waste heat is not automatically a resource that must be discarded. Where its temperature and availability make it useful, the settlement can route it to another process or structure. Where it cannot be used, it must ultimately be stored temporarily or rejected to the environment.

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

Storage has finite capacity and operating-temperature limits. Practical designs may also have standing losses and limits on charge/discharge rates. The exact storage medium, construction, capacity, and loss model remain open engineering choices.

## Heat Rejection

Not all heat can be recovered or stored. Surplus heat must be rejected through an appropriate path, such as radiators, heat pipes, coolant loops, or suitable environmental sinks. Available rejection capacity and environmental conditions constrain how much heat-producing equipment can operate.

Heat rejection remains necessary even when a settlement has heat recovery and storage. The goal is not to eliminate waste heat but to make useful use of it when practical and safely reject the remainder.

## Gameplay Boundary

The intended gameplay is settlement infrastructure management rather than appliance micromanagement. Meaningful decisions may include:

- locating heat-producing and heat-consuming facilities relative to one another;
- deciding which structures should receive recovered heat;
- installing heat pumps where low-grade heat can be upgraded usefully;
- sizing thermal storage against supply and demand patterns;
- providing sufficient heat-rejection capacity;
- balancing thermal infrastructure costs, power use, maintenance, and reliability.

Ordinary habitat HVAC remains an integrated structure capability, as described in [Life-Support Systems & Waste Recycling](life_support_systems_and_waste_recycling.md). The settlement thermal network can supply useful heat to those structures; this does not require separate player-managed HVAC appliances in every habitat.

## Existing Tracking and Open Audit

Some existing sources and data contain thermal concepts, including waste_heat, waste_heat_kw, heat_generation_kw, thermal_load_max, and radiator-capacity examples. Their presence in isolated configuration, test, or historical design files does not establish a coherent, active thermal simulation or settlement-wide heat network.

Before extending or retaining those mechanics, audit where these fields are loaded, consumed, calculated, transferred, and persisted in current code and data. Determine whether they are active, duplicated, inconsistent, arbitrary placeholders, or remnants of older designs. Redundant or unsupported tracking may need to be consolidated or removed rather than expanded into a second thermal subsystem.

The owner has not yet selected which existing thermal fields or mechanics should remain. Exact heat units, temperature representation, transfer rules, network topology, storage model, heat-pump performance, and radiator/rejection calculations remain OPEN. No implementation change is authorized by this design-intent entry.
