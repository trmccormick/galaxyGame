# Structures Architecture

## Overview
**Structures** are the physical assets—natural or artificial—that provide shelter, operational capacity, or special functions to settlements. Structures are not settlements themselves, but are attached to settlements via the `has_many :structures` association. This allows a single settlement to encompass multiple structures, such as a worldhouse, space station, or depot.

## Key Structure Types
- **Worldhouse**: An artificial enclosure built over a natural feature (lava tube, canyon, crater). See [worldhouse_intent.md](../intent/worldhouse_intent.md) and [Structures::Worldhouse](../../../galaxy_game/app/models/structures/worldhouse.rb).
- **Space Station**: An artificial orbital structure, often used for shipyard, repair, or habitation. See [Settlement::SpaceStation](../../../galaxy_game/app/models/settlement/space_station.rb).
- **Orbital Depot**: A logistics/refueling hub, often co-located with stations in orbital settlements.
- **Other Structures**: Domes, surface habitats, planetary umbilical hubs, etc.

## Model Relationships
- All structures inherit from `Structures::BaseStructure`.
- Structures are attached to settlements via `settlement_id`.
- Structures can reference natural features (e.g., `geological_feature_id` for worldhouses).

## Intent and Construction
- **Worldhouse**: Built in-situ, transforms a natural feature into a pressurized, usable volume. Not a unit; must be constructed, not deployed.
- **Space Station**: Constructed in orbit, can host a settlement or be one of several structures in an orbital settlement.
- **Depots/Other**: Built from blueprints, provide specialized functions (storage, refueling, processing).

## Example: Multi-Structure Settlement
- **Settlement:** L1 Gateway (orbital)
  - **Structures:**
    - Structures::SpaceStation (shipyard)
    - Structures::OrbitalDepot (refueling/cargo)
    - Structures::Worldhouse (if attached to a captured asteroid or moon)

## Design Principles
- **Separation of Concerns:** Structures are physical; settlements are administrative.
- **Extensibility:** New structure types can be added as subclasses of `BaseStructure`.
- **Blueprint-Driven:** Artificial structures are constructed from blueprints; natural features are referenced.

## References
- [worldhouse_intent.md](../intent/worldhouse_intent.md)
- [app/models/structures/worldhouse.rb]
- [app/models/settlement/space_station.rb]
- [app/models/settlement/base_settlement.rb]

---
**Last updated:** 2026-03-31
