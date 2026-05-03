# CNT Production in ISRU

## Overview
Carbon Nanotube (CNT) production is a critical advanced ISRU capability, enabling high-performance composites and next-generation infrastructure. This document will detail:
- The canonical CNT fabricator chain (Mk1–Mk3)
- Atmospheric and catalyst feedstock requirements
- Upgrade paths and dependencies
- Operational data and blueprint compliance

## Canonical CNT Fabricator Chain (Mk1–Mk3)

The CNT fabricator chain enables advanced ISRU for high-performance composites and infrastructure. Each generation is strictly canonical, with blueprints and operational data:
- **Mk1:** Converts CO₂ and catalyst to CNTs. [Blueprint](../../data/json-data/blueprints/units/production/fabricators/cnt_fabricator_mk1_bp.json), [Operational Data](../../data/json-data/operational_data/units/production/fabricators/cnt_fabricator_unit_mk1_data.json)
- **Mk2:** Requires Mk1 as a component, adds advanced_composites, high_performance_electronics, drive_systems. [Blueprint](../../data/json-data/blueprints/units/production/fabricators/cnt_fabricator_mk2_bp.json), [Operational Data](../../data/json-data/operational_data/units/production/fabricators/cnt_fabricator_unit_mk2_data.json)
- **Mk3:** Requires Mk2, upgrades to smart_composites, quantum_electronics. [Blueprint](../../data/json-data/blueprints/units/production/fabricators/cnt_fabricator_mk3_bp.json), [Operational Data](../../data/json-data/operational_data/units/production/fabricators/cnt_fabricator_unit_mk3_data.json)

## CO₂ and Catalyst Sourcing & Processing
- CO₂ is harvested from the local atmosphere or delivered as a precursor resource.
- Catalyst is a required input for CNT synthesis (see operational data).
- Input resources and process parameters are strictly defined in blueprints and operational data.

## Fabricator Upgrade Logic & Dependencies
- Each upgrade requires the previous generation as a component.
- Material chains are strictly canonical and validated (see audit).
- Upgrades unlock higher throughput, new materials, and automation.

## Operational Data Requirements & Validation
- Every CNT fabricator must have a matching operational data file.
- Operational data defines power, throughput, storage, and safety systems.
- See BaseUnit and audit notes for compliance logic.

## Example CNT-Based Manufacturing Chain
1. Harvest CO₂ + catalyst → 2. Mk1 fabricator produces CNTs → 3. Mk2/Mk3 upgrades enable advanced composites and infrastructure.

---
*Sections completed per April 2026 canonicalization and audit.*
