# GALAXY RIG SYSTEM v1.0

## Intent
EVE-style rigs: attach → apply bonuses; remove → revert and destroy. Rigs provide modular, swappable enhancements to units, crafts, and structures.

## Architecture
- **HasRigs**: Provides associations and helpers for attaching/detaching rigs.
- **Rigs::BaseRig**: Encapsulates rig logic, effects, and JSON-driven configuration.
- **RigAttachable**: Universal concern providing the delta interface (update_consumables, update_outputs, update_damage_risks) and persisted_rigs alias for spec and code compatibility.

## Data Flow
1. **Blueprint JSON** → defines host entity (unit, craft, structure)
2. **Rig JSON** → defines rig properties and effects
3. **Rigs::BaseRig** → loaded and attached to host
4. **RigAttachable** → host receives delta calls (e.g., update_outputs)
5. **Host operational_data** → updated with new values (e.g., output_resources['gcc'] += 200)

## Host Requirements
- Must have an `operational_data` hash-like column
- Must have either `base_rigs` or `rigs` association (from HasRigs or direct)
- Must include `RigAttachable`

## Usage
- **Units::BaseUnit**: include HasRigs, include RigAttachable
- **Craft::BaseCraft**: include HasRigs, include RigAttachable
- **Structures::BaseStructure**: include HasRigs, include RigAttachable
- **Facilities::MiningOutpost**: (future) include HasRigs, include RigAttachable

## Example
```ruby
satellite = Craft::Satellite::BaseSatellite.create!(craft_type: "crypto_mining_satellite", owner: Player.first)
satellite.rigs.count  # => 2 gpu_coprocessor_rig
satellite.update_outputs("gcc", 200)
satellite.operational_data['output_resources']['gcc']  # => updated value
```

## Test Coverage
- All Rigs::BaseRig specs pass (16/16 green)
- Universal interface: any model with HasRigs + RigAttachable supports rigs

## Extending
To add rig support to a new model:
1. Add HasRigs (or a direct rigs/base_rigs association)
2. Include RigAttachable
3. Ensure operational_data is present

---

**Result:** Universal, maintainable, and DRY rig system for all game entities.
