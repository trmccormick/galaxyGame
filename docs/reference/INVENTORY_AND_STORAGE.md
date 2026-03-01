# Inventory and Storage System

## Overview
- All items (resources, equipment, etc.) are stored in an `Inventory` associated with a `Craft`, `Settlement`, or `Location`.
- Inventory capacity is determined by the sum of all *attached storage units* (units with a valid storage capacity).
- Storage units are special `Units::BaseUnit` records, attached via the `attachable` association to the craft/location, and must have `operational_data['storage']['capacity']` set.

## Storage Units
- Storage units provide **protected, limited capacity** for inventory.
- To be recognized for capacity:
  - The storage unit must be attached to the craft/location via `attachable`.
  - Its `operational_data` must include a nested `'storage' => { 'capacity' => ... }`.
- Example:
  ```ruby
  storage_unit = Units::BaseUnit.create!(
    attachable: craft,
    owner: craft.owner,
    unit_type: 'storage_unit',
    operational_data: { 'storage' => { 'capacity' => 1000, 'type' => 'general', 'current_level' => 0 } }
  )
  ```
- After attaching, reload the craft and its associations to ensure the storage unit is recognized.

## Surface Storage
- Surface storage provides **unlimited, unprotected storage** for bulk materials at a settlement or location.
- Items stored on the surface may degrade over time due to planetary conditions (e.g., corrosion, temperature extremes).
- All items, whether in protected storage or on the surface, are tracked in the inventory system and associated with a location or craft.
- Use surface storage for materials like mined ore, regolith, or waste that do not require protection.

## Capacity Checks
- `inventoryable_capacity` (in `Inventory`) sums `unit.operational_data['storage']['capacity']` for all `base_units` attached to the craft/location.
- For specialized storage (e.g., gas, liquid), the system looks for a storage unit with a compatible type.
- If surface storage is available, `available_capacity` returns `Float::INFINITY`.

## Summary
- Storage units are not containers; they are capacity providers.
- All inventory is centralized and associated with a location/craft.
- Capacity checks always sum the attached units’ storage capacities.
- Correct association and data structure are critical for the system to recognize available capacity.
- Surface storage is for unlimited, unprotected, degradable piles.
- All inventory is centralized and associated with a location/craft.
- Storage units provide protected, limited capacity; surface storage is for overflow and bulk.
