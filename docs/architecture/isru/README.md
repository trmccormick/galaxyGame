# ISRU Primer: In-Situ Resource Utilization for Luna Settlement

## Overview
In-situ resource utilization (ISRU) is the foundation of day-one lunar settlement. The precursor robotic mission delivers and deploys the first 3D-printed fabricator (Mk1), which enables all early construction—including panels and I-beams—by harvesting and processing local regolith. Regolith composition varies by location and crustal geology, requiring careful qualification and, in some cases, additives to meet manufacturing requirements.

## Key ISRU Principles
- **Harvest First:** Local resource harvesting is prioritized for all construction and manufacturing (see: GUARDRAILS.md, "Harvest First").
- **Regolith Variability:** Regolith composition (SiO₂, FeO, etc.) must be checked before use. Additives or pre-processing may be required to meet 3D printer feedstock specs.
- **ISRU Priorities:** Oxygen, water, and metals are ranked and documented per engine requirements (see: GUARDRAILS.md, Resource Allocation Engine Integration).
- **Surface Storage:** Non-volatile solids (ibeams, regolith, printed parts) can be stored on the lunar surface (see: INVENTORY_AND_STORAGE.md).

## Day-One Manufacturing Chain
1. **Robotic Deployment:** Precursor mission lands and deploys the Mk1 3D-printed fabricator.
2. **Regolith Harvesting:** Surface regolith is collected from the Luna site.
3. **Feedstock Qualification:** Regolith is analyzed for composition; additives are blended if needed.
4. **3D Printing:** Qualified regolith is used in the Mk1 fabricator to produce structural panels and ibeams.
5. **Fabricator Upgrades:** As infrastructure grows, Mk2 and Mk3 fabricators are constructed for higher throughput and advanced materials.
6. **Panel/I-Beam Assembly:** Printed components are assembled into habitat and infrastructure.

## Precursor Mission Sequence: Power, Comms, and First 3D-Printed Structure

In all precursor missions (Luna or other worlds), the initial deployment sequence is:
1. Land and deploy robots for surface operations.
2. Establish comms and power infrastructure (solar rig, panels, RTG, power management).
3. Deploy regolith harvesting and extraction units.
4. **First 3D-printed structure:** Use the I-beam printing unit to fabricate the solar array/farm support structure, enabling full solar farm buildout.

This sequence ensures that power and comms are online before any major construction, and that the first use of 3D printing is always for the solar array/farm support, as originally intended. Equipment names may evolve, but this intent is canonical for all precursor missions.

## Solar Expansion Rig: Early Power Bridge

Immediately after landing, robots mount the Solar Expansion Rig to the HLT (lander). This rig allows additional solar panels to be deployed and connected, temporarily expanding available power for initial ISRU, robotics, and infrastructure setup. The Solar Expansion Rig is distinct from the permanent solar farm: it is a modular, temporary solution bridging the gap between RTG-only power and full solar array construction.

## References
- [docs/GUARDRAILS.md](../../GUARDRAILS.md)
- [docs/mission_profiles/orbital_settlement_strategies.md](../../mission_profiles/orbital_settlement_strategies.md)
- [docs/reference/INVENTORY_AND_STORAGE.md](../../reference/INVENTORY_AND_STORAGE.md)

## See Also

- [3D-Printed Fabricators (Mk1–Mk3)](../units/3d_printed_fabricators.md) _(canonical unit chain documentation)_
- [Regolith Shell Printers (Mk1–Mk3)](../units/regolith_shell_printers.md) _(parallel unit chain for advanced shell construction)_

## Regolith Shell Printers: Parallel Construction Chain

The Regolith Shell Printer series (Mk1–Mk3) operates alongside the 3D-printed fabricators to enable advanced shell and habitat construction. These units specialize in printing large regolith-based shells and protective structures, leveraging local materials and upgraded processing capabilities as infrastructure matures. For technical details and operational data, see the canonical [Regolith Shell Printers (Mk1–Mk3)](../units/regolith_shell_printers.md) documentation.

## CNT Fabricators: Advanced ISRU Chain

The Carbon Nanotube (CNT) Fabricator series (Mk1–Mk3) enables advanced ISRU by converting atmospheric CO₂ and catalyst feedstock into carbon nanotubes for high-performance composites and infrastructure. Each generation upgrades throughput, automation, and material compatibility, strictly using canonical materials:
- Mk1: advanced_composites, high_performance_electronics, precision_extruders
- Mk2: adds drive_systems, increased quantities, requires Mk1 as a component
- Mk3: upgrades to smart_composites, quantum_electronics, requires Mk2 as a component

Blueprints and operational data for all CNT fabricators are canonical and strictly validated. See: [CNT Fabricator Blueprints](../../data/json-data/blueprints/units/production/fabricators/)

## Canonicalization and Data Integrity

- Only canonical blueprints/items from the correct folders are valid for ISRU chains. Duplicates or misplaced files (e.g., non-canonical planetary_volatiles_extractor) are removed and must not be referenced.
- All active units (fabricators, extractors, printers) must have matching operational data files, strictly enforced for ISRU compliance.
- Recent audit: All mk1–mk3 3D-printed fabricators, regolith shell printers, and CNT fabricators have been reviewed and updated for canonical material chains and operational data alignment. All required_materials are resolvable and canonical.

## Reference Updates

- [CNT Fabricator Blueprints](../../data/json-data/blueprints/units/production/fabricators/)
- [3D-Printed Fabricators (Mk1–Mk3)](../units/3d_printed_fabricators.md)
- [Regolith Shell Printers (Mk1–Mk3)](../units/regolith_shell_printers.md) (if/when available)

---
