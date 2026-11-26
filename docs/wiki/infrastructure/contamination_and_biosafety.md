# Contamination & Biosafety

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Updated:* 2026-11-26  
> *Page role:* Consolidates biological-contamination risk, biosafety practices, containment engineering, and their relationship to planetary protection. This page records design intent and source distinctions; it does not claim that the governance framework, risk calculations, or operational controls are implemented.

## Purpose and Scope

GalaxyGame needs to represent the possibility that biological material can be carried between environments, introduced accidentally or deliberately, and affect a destination's existing or potential biosphere. Absolute sterility cannot be guaranteed. The design therefore manages uncertainty and reduces risk rather than promising zero contamination.

This page covers the engineering and biological side of that problem:

- screening biological material, equipment, payloads, and relevant cargo before deployment or transfer;

**Related wiki pages:** [Planetary Protection & Environmental Governance](./planetary_protection_environmental_governance.md) defines the broader policy framework; [Terraforming Seeds](../technical/biology/terraforming_seeds.md) covers biological deployment concepts; [Biosphere Simulation](../technical/biology/biosphere_simulation.md) covers biosphere behavior and proposed simulation architecture.

- containment during transport, incubation, research, and habitat operation;
- monitoring and assessment after contact with a destination environment;
- reducing, recording, and communicating residual contamination risk;
- connecting biological facilities and operations to the wider planetary-protection policy.

The broader policy hierarchy, planetary protection classes, environmental restrictions, and proposed regulatory enforcement remain on [Planetary Protection & Environmental Governance](./planetary_protection_environmental_governance.md). This page should not duplicate that policy specification.

## Established Principles

### Sterility Is Not Provable

A survey or sterilization process can increase confidence and reduce risk, but cannot prove that a world, sample, payload, or piece of equipment is completely sterile. Absence of detected life is not evidence that no life exists.

Risk assessments must therefore retain uncertainty. Detection confidence and residual risk are related but are not interchangeable: a high-confidence survey can reduce estimated risk without making it zero.

### Contamination Risk Is Persistent but Reducible

Biological contamination risk is a persistent factor. Better screening, containment, sterilization, handling, and monitoring can reduce it, but no protocol tier should be represented as eliminating it.

The historical Seed direction describes residual contamination risk as a factor in Digital Twin confidence and project evaluation. Exact formulas, weights, and cost impacts remain unverified proposals and must not be treated as implemented mechanics.

### Prevention, Containment, and Assessment Are Separate Controls

A robust operation considers three different questions:

1. **Before contact:** What biological material may be present, and what screening or preparation is appropriate?
2. **During contact or transfer:** How is material contained, handled, monitored, and prevented from escaping unintentionally?
3. **After contact:** What changed, what evidence was observed, and what residual risk remains?

Passing one control does not automatically satisfy the others. For example, screening a payload does not establish that its transport container, handling equipment, or destination environment is sterile.

## Contamination Pathways and Operational Context

Potential pathways identified across the existing design material include:

- landers, drills, excavation equipment, and other surface-contact machinery;
- imported biological payloads, samples, and materials;
- organisms incubated or adapted in a Seed, Bio-Nursery, or Worldhouse;
- cargo or volatile streams transported from environments with biological uncertainty;
- equipment and craft that operate across multiple celestial bodies or settlements.

This is a design checklist, not a finalized exhaustive taxonomy. The precise contamination state attached to each object, shipment, mission, or destination remains **OPEN**.

Contamination of a destination environment, contamination of a cargo shipment, and contamination contained within a sealed facility are different situations. They should not be collapsed into one global status or treated as automatically equivalent.

## Biosafety Engineering and Operating Practices

The following are candidate control categories retained from the existing design material. Their presence here records intended engineering concerns, not proof that a complete operational system or blueprint exists.

| Control area | Intended role | Status |
|---|---|---|
| Pre-deployment screening | Assess biological material and equipment before deployment or contact. | Design intent |
| Sterilization and surface treatment | Reduce viable biological material on equipment and payload surfaces. | Candidate methods; exact procedures open |
| Sealed barriers and isolation | Limit unintended exchange between contained biological environments and their surroundings. | Design intent |
| Filtration and controlled handling | Reduce movement of biological material through air, fluids, or handling paths where applicable. | Candidate methods; applicability open |
| Monitoring and sampling | Detect possible introduction, escape, or ecological effects after contact. | Design intent |
| Post-contact assessment | Update the risk picture using observed evidence and uncertainty. | Design intent |
| Operational resources | Account for the cost, time, power, consumables, and maintenance needed to operate controls. | Quantification open |

Historical source material mentions thermal treatment, radiation treatment, sealed barriers, HEPA filtration, and sterilization budgets. These are candidate examples, not universal requirements for every mission or facility. The correct method depends on the organism, material, equipment, destination, and mission purpose; no universal procedure or cost schedule is established here.

## Seeds, Bio-Nurseries, and Worldhouses

Biological facilities can serve different purposes while sharing structural, power, environmental-control, and life-support technologies.

### Terraforming-Seed Programs

A terraforming seed is a planned biological use or program, not a structure class. It may support incubation, adaptation, research, and preparation of organisms for a possible later introduction into the open biosphere. The historical staged Seed lifecycle is a candidate design, not a mandatory progression. Initial simple-life use on Mars is an established planning direction and does not require completion of every historical stage.

A seed program may use one structure or several facilities. It may be hosted within a Worldhouse, including one that also supports human habitation and other uses. Containment and biosafety are relevant both before release and during any period in which organisms are being grown or adapted. A release decision must consider destination protection and residual uncertainty; exact release criteria remain **OPEN**.

### Worldhouses

A Worldhouse is a physical, engineered, sealed environmental structure built around or within a suitable geological feature. Its atmosphere is selected for its intended operating environment; a human-breathable atmosphere is not mandatory. **ESTABLISHED INTENT — 2026-11-26:** A Worldhouse can host a terraforming-seed program and can be mixed use, but mixed use depends on compatibility with its selected atmospheric profile and operating conditions.

A human-rated Worldhouse may combine habitation, research, biological incubation, contained ecosystem development, and seed-program activities. A non-human-rated Worldhouse may combine compatible industrial, biological, experimental, or other purposes, or remain dedicated to one purpose. Different functions may require distinct internal zones, environmental conditions, containment boundaries, or dedicated systems. The exact zoning and engineering model remain **OPEN**.

A Worldhouse does not automatically alter the planetary atmosphere or open planetary biosphere merely because it contains life or hosts a seed program. Biological activity inside a sealed structure remains local unless a designed and authorized connection or release pathway makes it affect the external environment. The transition from contained activity to external release or planetary interaction requires its own decision and risk assessment.

### Bio-Nurseries and Shared Infrastructure

Bio-Nursery describes a biological incubation/adaptation capability. It may be a standalone facility or hosted within a larger suitable structure, including a mixed-use Worldhouse; it is not necessarily a separate structure class. Exact facility taxonomy, equipment packages, zoning, and construction boundaries remain **OPEN**.

Shared construction technology does not make every structure biologically equivalent. The actual uses, internal organization, contained organisms, operating conditions, and release pathways determine a facility's biosafety needs.

## Planetary Protection and Governance Relationship

Planetary protection is broader than facility biosafety. It considers the status and uncertainty of the destination world, the consequences of introducing material, resource extraction, cargo movement, and governance restrictions.

The existing Planetary Protection & Environmental Governance specification proposes:

- protection classes based on astrobiological and environmental context;
- precaution for unsurveyed environments, including ice-shell oceans;
- pre-deployment screening and sterilization requirements;
- monitoring of biological introduction during operations;
- post-contact contamination assessment;
- quarantine handling for certain raw volatile shipments from higher-risk environments;
- operational spending to reduce contamination risk.

These are **target design intent**, not verified runtime behavior. In particular, the proposed cycler-hub quarantine loop for raw volatile shipments must not be presented as an existing logistics feature.

### Two Classification Concepts Need Reconciliation

The source material uses Class-0 through Class-4 terminology both for planetary-protection categories and for historical Seed/biosafety protocol tiers. These appear to describe different things:

- a **planetary protection class** describes the protection/governance context of a world or environment;
- a **biosafety protocol tier** would describe the level of controls applied to an operation, facility, payload, or shipment.

They must not be assumed to be the same classification merely because the labels overlap. A distinct naming scheme or an explicit mapping is **OPEN**.

## Digital Twin and AI Manager Considerations

The historical Terraforming Seed direction includes residual contamination risk and uncertainty among the factors considered in Digital Twin projections. The AI Manager may need to compare biological projects, Worldhouse projects, and non-biological terraforming interventions using comparable cost, timeline, benefit, and risk information.

For contamination-related evaluation, the durable requirements are:

- preserve uncertainty rather than reporting sterility as certain;
- distinguish evidence and detection confidence from residual risk;
- account for the risk associated with the proposed biological material and its destination;
- distinguish contained biological development from intended external release;
- avoid treating a higher protocol tier as zero risk;
- do not invent numerical costs, risk weights, thresholds, or ranking formulas.

The exact data model, risk calculation, evidence history, AI Manager decision rules, and market-cost integration remain **OPEN**.

## Open Questions

1. What biological status and provenance must be tracked for organisms, samples, equipment, cargo, and destinations?
2. How should contamination risk be represented separately for a world, a facility, a payload, a shipment, and a mission?
3. What screening and handling controls apply to different mission types and biological materials?
4. Which methods are appropriate for sterilizing equipment, and which materials or organisms may be damaged by those methods?
5. What containment and monitoring capabilities are required for Seeds, Bio-Nurseries, and Worldhouses?
6. What evidence and authorization are required before organisms can be intentionally released from a contained facility?
7. How should post-contact observations update destination risk and the history of a biological introduction?
8. How should the planetary-protection class system relate to any operational biosafety tier system without reusing ambiguous labels?
9. What quarantine rules, if any, should apply to raw volatile shipments and other cargo moving between worlds?
10. What risk and cost information should the Digital Twin expose to the AI Manager, and how should uncertainty affect comparisons?

## Harvest Sources and Authority

This page harvests relevant intent from the frozen, non-authoritative material:

- `docs/architecture/biology/TERRAFORMING_SEED_AND_LIFE_DIRECTION.md` — permanent residual uncertainty, risk reduction, Seed/Worldhouse distinctions, and Digital Twin risk considerations.
- `docs/architecture/intent/worldhouse_intent.md` and `docs/architecture/structures/worldhouse_design.md` — Worldhouse as a sealed/local environmental structure and the boundary between internal habitat conditions and planetary-scale effects.
- `docs/wiki/technical/biology/terraforming_seeds.md` — current wiki direction for Seed use, candidate lifecycle, and unresolved contamination-cost material.
- `docs/wiki/infrastructure/planetary_protection_environmental_governance.md` — broader protection classes, proposed contamination framework, and governance hooks.

The active wiki and owner-confirmed direction take precedence over frozen documents. No frozen source has been edited. No code, blueprint, simulation behavior, or runtime policy is changed by this page.
