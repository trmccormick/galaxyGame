# Inventory System Architecture

## Overview

The inventory system is the **single source of truth** for all physical items in
the game. Every material, gas, component, food item, or manufactured good is
represented as an `Item` model tracked by an `Inventory`. This applies universally
to settlements, crafts, players, and organizations.

**Core principle: If it exists physically in the game world, it's in an inventory.**

---

## Item Model

All physical goods are `Item` records with a `material_type` enum:

```ruby
# Item material types
enum material_type: {
  solid: 0,
  liquid: 1,
  biological: 2,
  electronic: 3,
  gas: 4,
  ...
}
```

**Querying examples:**
```ruby
# All gas in a settlement
settlement.inventory.items.where(material_type: :gas)

# Specific gas
settlement.inventory.items.find_by(name: 'O2', material_type: :gas)

# All items on a craft
craft.inventory.items

# Player's personal inventory
player.inventory.items
```

---

## Units — Capacity Only

Units (e.g. `inflatable_gas_storage`, `warehouse_module`, `cryogenic_tank`) exist
solely to define **storage capacity**. They do NOT store item quantities.

**What units do:**
- Add to `settlement.inventory.capacity_remaining`
- Constrain what types of items can be stored (e.g. gas units add gas capacity,
  cryogenic units add liquid capacity)

**What units do NOT do:**
- Track item quantities
- Have their own item ledger
- Need to be queried to find out how much of something exists

**Correct pattern:**
```ruby
# RIGHT — query inventory for quantities
settlement.inventory.items.where(material_type: :gas)

# WRONG — never do this
settlement.structures.where(structure_name: 'depot_tank').first
  .operational_data['gas_storage']['O2']
```

---

## Storage Types by Context

Different unit types are appropriate for different locations and material types:

| Unit | Material Types | Context |
|------|---------------|---------|
| `inflatable_gas_storage` | gases | Surface, pressurized, needs pressure rating |
| `open_surface_storage` | solids (ibeams, regolith, printed parts) | Luna/Mars surface, cheap, stackable outside |
| `warehouse_module` | general goods | Pressurized settlements |
| `cryogenic_tank` | liquids, volatiles | Temperature-controlled environments |
| `lava_tube_atmosphere` | gases (vented) | Sealed lava tube, builds atmosphere |

**Surface storage note:** On Luna and Mars, non-volatile solids (ibeams, 3D printed
components, raw regolith) can be stored on the open surface. This is cheap and
effectively unlimited for solids. Gases and biologicals always need enclosed units.

---

## Transfer Validation

When a player or AI attempts to transfer items to a settlement or craft:

1. Check `destination.inventory.capacity_remaining`
2. If insufficient → reject transfer with "Storage capacity reached"
3. Player must build more storage units, sell existing stock, or find another destination

```ruby
# Capacity check pattern
if destination.inventory.capacity_remaining < transfer_quantity
  raise "Storage capacity reached, cannot accept transfer"
end
```

---

## Gas Disposition Options

When a settlement accumulates excess gases, the AI manager and player have
several options:

### 1. Store
Keep in `inflatable_gas_storage` units. Costs capacity. Default behavior.

### 2. Vent to Lava Tube Atmosphere
If the settlement is inside a sealed lava tube, gases can be vented to build
up the tube's atmosphere. This is tracked via the `Atmosphere` model on the
lava tube location.

```ruby
# Venting to lava tube — adds to atmosphere, not lost
lava_tube.atmosphere.add_gas(gas_name, quantity)
settlement.inventory.items.find_by(name: gas_name).decrement!(:amount, quantity)
```

- Net positive action — builds toward a breathable lava tube environment
- `AtmosphereSimulationService` tracks pressure buildup over time
- Contributes to terraforming progress

### 3. Vent to Space
Instant capacity relief. Gas is permanently lost. Should be logged so the
player can see the cost of this decision.

```ruby
# Venting to space — gas is lost
Rails.logger.info "[GasVent] #{quantity}kg #{gas_name} vented to space from #{settlement.name}"
settlement.inventory.items.find_by(name: gas_name).decrement!(:amount, quantity)
```

- Last resort option
- AI manager should warn before doing this
- Should never happen automatically without player acknowledgment

### 4. Transfer to Craft
Sell or transfer to departing ships. Generates revenue or fulfills contracts.

### 5. Feed Life Support
Use directly for pressurization via `StructurePressurizationService`.

---

## AI Manager Capacity Logic

The AI manager monitors inventory fill rates and triggers actions:

```ruby
# Capacity pressure signal — same logic for ALL item types
fill_ratio = settlement.inventory.items.sum(:amount) / settlement.inventory.total_capacity

if fill_ratio > 0.80
  # Evaluate disposition options based on item type and context
  case
  when lava_tube_present? && gas_items_present?
    queue_job(:vent_to_lava_tube)
  when traders_available?
    lower_sell_price(gas_items)  # Free storage via sales
  when fill_ratio > 0.95
    queue_build_job(:inflatable_gas_storage)  # Build more capacity
  end
end
```

**Key point:** The same fill ratio check works for gases, metals, food, water,
or any other item type. No special-casing per material.

---

## Byproduct Manufacturing

When manufacturing processes produce byproducts (e.g. mining Si produces O2),
byproducts go directly into the settlement inventory:

```ruby
# Correct pattern — ByproductManufacturingService
inventory.items.find_or_create_by(name: gas_name, material_type: :gas) do |item|
  item.amount = 0
  item.owner = settlement.owner
end.increment!(:amount, byproduct_mass)
```

Never write byproducts to structure `operational_data`.

---

## Integration with TerraSim

Gases vented to a lava tube atmosphere feed directly into `AtmosphereSimulationService`:
- Pressure builds over time as more gas is added
- Composition shifts based on what gases are vented
- Temperature and habitability are recalculated by TerraSim
- When atmosphere reaches breathable thresholds, new settlement expansion options unlock

This creates a long-term terraforming loop entirely driven by inventory decisions.

---

## Common Mistakes to Avoid

These patterns are **WRONG** and should never appear in new code:

```ruby
# WRONG — depot_tank doesn't exist as a structure type
settlement.structures.where(structure_name: 'depot_tank')

# WRONG — gas quantities don't live in operational_data
tank.operational_data['gas_storage']['O2']

# WRONG — units don't have their own item ledger
unit.stored_gases

# WRONG — there is no nil owner, everything has an owner
settlement.where(owner: nil)
```

---

## Summary

| Concept | Where it lives |
|---------|---------------|
| Item quantities | `settlement.inventory.items` |
| Storage capacity | Unit models attached to settlement |
| Gas in lava tube | `lava_tube.atmosphere` (via TerraSim) |
| Capacity triggers | AI Manager monitoring fill ratios |
| Transfer validation | `inventory.capacity_remaining` check |
| Byproducts | Written directly to inventory |
