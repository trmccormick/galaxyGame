---
title: Settlement Infrastructure
category: Infrastructure
status: LIVE (design intent + code-verified note + open items)
last_updated: 2026-10-29
---

# Settlement Infrastructure

> **How to read this page.** *Design Intent* is the agreed design. *Verified against code* records what the codebase does today (checked at commit `c5f0d9e`, 2026-10-29); where the two differ, the code section is current behavior and the intent stands until the owner changes it. *OPEN* lists items with no source in the docs or the code; they are not decisions.

---

## Design Intent

A **Settlement** is the core administrative, economic, and population unit in Galaxy Game. It manages population, economy, contracts, and jurisdiction, and can encompass multiple physical structures, both natural and artificial. Settlements can exist on planetary surfaces, within natural features (lava tubes, craters), or in orbit (e.g., the L1 Gateway).

### Key Principles

| Principle | Intent |
|-----------|--------|
| Separation of concerns | Settlements are administrative entities, not structures. They contain, or are hosted within, one or more structures. |
| Structures as assets | Structures (natural or artificial) are physical assets that provide shelter, storage, or operational capacity to a settlement. |
| Blueprint-driven expansion | Artificial structures are built from blueprints and added to a settlement as it grows. |
| Natural features | A settlement can be hosted in a natural feature (lava tube, crater) or an artificial structure (worldhouse, station, depot). |

### Natural vs. Artificial Structures

- **Natural:** lava tubes, craters, canyons (worldhouse pattern).
- **Artificial:** space stations, depots, worldhouses.
- Both attach to a settlement through its structures.

### Orbital Settlements

An orbital settlement (e.g., the L1 Gateway) is **one settlement containing several peer structures**, for example a shipyard/repair structure and a cargo/refueling structure. It is not a single station object.

Related design: [Station Construction Options](../engineering/station_construction_options.md) (how stations are built), [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md) (in-situ production), [Atmospheric Harvesting](Atmospheric-Harvesting.md).

---

## Verified against code (commit `c5f0d9e`, 2026-10-29)

| Topic | What the code does |
|-------|--------------------|
| Settlement types | `settlement_type` enum: `base`, `outpost`, `settlement`, `city`, `station`. |
| How the type is set | On every change to `current_population` the type is reassigned from population: **0–9 → base, 10–99 → outpost, 100–999 → settlement, 1000+ → city**. A `population_requirements` method defines the same minimums (base ≥ 1, outpost ≥ 10, settlement ≥ 100, city ≥ 1000) but is not registered as a validation in the settlement model files. This rule never assigns `station`. |
| What a settlement has | Owner (optional), colony (optional), accounts, inventory, missions, marketplace, location, docked crafts, base units, orbital construction projects, jobs, construction jobs, and `structures` (all `Structures::BaseStructure`, linked by `settlement_id`). |
| Orbital settlement | `Settlement::OrbitalSettlement` exists and is active. It shares the settlements table; its location comes from its first structure, and its population capacity and storage are summed over its structures. |
| `SpaceStation`, `OrbitalDepot` | Both `Settlement::` classes are marked **RETIRED 2026-04-10** in code ("kept for git history only. Do not use this class."). Replacement: `Settlement::OrbitalSettlement` with `Structures::OrbitalStructure`. |
| Structure types | Under `Structures::BaseStructure`: `CraterDome`, `HabitationFacility`, `Hangar`, `ManufacturingFacility`, `OrbitalStructure`, `PowerStation`, `SolarArray`, `StorageFacility`, `Worldhouse` (`ConvertedBase` extends `Worldhouse`). There is no `Structures::SpaceStation` or `Structures::OrbitalDepot`. |

**Effect on the intent above:** an orbital settlement's peer structures are `OrbitalStructure` instances. The earlier intent text named a space-station structure and a depot structure for the L1 Gateway; those names are superseded by the retirement above.

---

## OPEN — needs owner confirmation

No source for these was found in the documentation or the code. They are not part of the design until confirmed.

| Item | Note |
|------|------|
| Life-support requirements per tier | Nothing defines what must be online for each tier. Code only validates per-person food, water, and energy rates. |
| Structure-count ranges per tier | Values such as 1–2 / 3–5 / 6–10+ structures were proposed in an earlier draft of this page with no source. The code tiers by **population**, not structure count. |
| Stage-gate rule ("each tier needs the prior life-support loop online") | No source found; nothing in the code enforces it. |
| Per-tier descriptions | Earlier wording ("minimal life support", "integrated ISRU loops", etc.) has no source. |
| Per-tier construction costs and durations | Not defined anywhere found. |
| Role of the `station` type | Population-based reassignment never produces `station` and would overwrite it on the next population change. Is `station` meant to be exempt? |
