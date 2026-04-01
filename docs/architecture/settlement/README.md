# Settlement Architecture

## Overview
A **Settlement** is the core administrative, economic, and population unit in the Galaxy Game simulation. Settlements can exist on planetary surfaces, within natural features (like lava tubes or craters), or in orbit (e.g., L1 Gateway). The settlement is responsible for managing population, economy, contracts, and jurisdiction, and can encompass multiple physical structures—both natural and artificial.

## Key Principles
- **Separation of Concerns:** Settlements are not structures. They are administrative entities that can contain or be hosted within one or more structures.
- **Structures as Assets:** Structures (natural or artificial) are physical assets that provide shelter, storage, or operational capacity to a settlement.
- **Blueprint-Driven Expansion:** Artificial structures are constructed from blueprints and can be added to a settlement as it grows.
- **Natural Features:** Settlements can be hosted in natural features (lava tubes, craters) or artificial structures (worldhouses, space stations, depots).

## Model Relationships
- `BaseSettlement` (app/models/settlement/base_settlement.rb)
  - `has_many :structures` (Structures::BaseStructure)
  - `has_many :base_units` (Units::BaseUnit)
  - `has_one :location` (Location::CelestialLocation)
  - `belongs_to :colony`
  - `enum settlement_type: { base, outpost, settlement, city, station }`
- **Structures**
  - Each structure (natural or artificial) is a subclass of `Structures::BaseStructure`.
  - Examples: `Structures::Worldhouse`, `Structures::SpaceStation`, `Structures::OrbitalDepot`.

## Orbital Settlements
- **Orbital settlements** (e.g., L1 Gateway) are modeled as a single settlement instance containing multiple peer structures (e.g., a shipyard station and a depot).
- The `Settlement::SpaceStation` model is deprecated for multi-structure settlements; use `Settlement::OrbitalSettlement` (planned) with `has_many :structures`.

## Natural vs. Artificial Structures
- **Natural:** Lava tubes, craters, canyons (see Worldhouse pattern)
- **Artificial:** Space stations, depots, worldhouses
- Both can be attached to a settlement via the `structures` association.

## Example: L1 Gateway
- **Settlement:** L1 Gateway (Settlement::OrbitalSettlement)
  - **Structures:**
    - Structures::SpaceStation (shipyard/repair)
    - Structures::OrbitalDepot (cargo/refueling)

## References
- [settlement_patterns.md](../patterns/settlement_patterns.md)
- [worldhouse_intent.md](../intent/worldhouse_intent.md)
- [app/models/settlement/base_settlement.rb]
- [app/models/structures/worldhouse.rb]
- [app/models/settlement/space_station.rb]

---
**Last updated:** 2026-03-31
