# 3D Printing in ISRU

## Overview
3D printing is the backbone of early lunar and planetary ISRU, enabling rapid construction of infrastructure using local regolith and additive manufacturing techniques. This document will detail:
- The canonical 3D-printed fabricator chain (Mk1–Mk3)
- Material qualification and feedstock requirements
- Upgrade paths and dependencies
- Operational data and blueprint compliance

## Sections to Complete
- [ ] Canonical 3D-printed fabricator chain summary
- [ ] Regolith feedstock qualification and additives
- [ ] Fabricator upgrade logic and dependencies
- [ ] Operational data requirements and validation
- [ ] Example manufacturing chains

---

## Canonical 3D-Printed Fabricator Chain (Mk1–Mk3)

The 3D-printed fabricator chain is the backbone of early ISRU. Each generation is strictly canonical, with blueprints and operational data:
- **Mk1:** Entry-level, uses qualified regolith feedstock. [Blueprint](../../data/json-data/blueprints/units/production/fabricators/3d_printed_fabricator_mk1.json), [Operational Data](../../data/json-data/operational_data/units/production/fabricators/3d_printed_fabricator_mk1_data.json)
- **Mk2:** Requires Mk1 as a component, adds advanced_composites, high_performance_electronics, drive_systems. [Blueprint](../../data/json-data/blueprints/units/production/fabricators/3d_printed_fabricator_mk2_bp.json), [Operational Data](../../data/json-data/operational_data/units/production/fabricators/3d_printed_fabricator_mk2_data.json)
- **Mk3:** Requires Mk2, upgrades to smart_composites, quantum_electronics. [Blueprint](../../data/json-data/blueprints/units/production/fabricators/3d_printed_fabricator_mk3_bp.json), [Operational Data](../../data/json-data/operational_data/units/production/fabricators/3d_printed_fabricator_mk3_data.json)

---

## Regolith Feedstock Qualification
- Regolith must be analyzed for composition (SiO₂, FeO, etc.) before use.
- Additives may be required for printability and strength (see ISRU Primer, initial_3d_printer.md).
- Only qualified feedstock is accepted by canonical blueprints.

---

## Fabricator Upgrade Logic & Dependencies
- Each upgrade requires the previous generation as a component.
- Material chains are strictly canonical and validated (see audit).
- Upgrades unlock higher throughput, new materials, and automation.

---

## Operational Data Requirements & Validation
- Every fabricator must have a matching operational data file.
- Operational data defines power, throughput, storage, and safety systems.
- See BaseUnit and audit notes for compliance logic.

---

## Example Manufacturing Chain
1. Harvest regolith → 2. Qualify feedstock → 3. Mk1 fabricator prints panels/ibeams → 4. Mk2/Mk3 upgrades enable advanced construction.

---

## Precursor Mission: First 3D-Printed Structure

In all precursor missions, the first 3D-printed structure is the support array for the solar panels (solar farm). Power and comms infrastructure are established first, followed by regolith harvesting and then the deployment of the I-beam printing unit to fabricate the solar array support. This sequence is canonical for all worlds, regardless of equipment name updates.

---

## Solar Expansion Rig: Temporary Power Solution

After landing, robots mount the Solar Expansion Rig to the HLT/lander. This rig enables rapid deployment of additional solar panels, providing a temporary boost to the power grid before the permanent 3D-printed solar farm support is constructed. The Solar Expansion Rig is not 3D-printed; it is a modular, early-deployed unit for initial power scaling.

---

*Sections completed per April 2026 canonicalization and audit.*
