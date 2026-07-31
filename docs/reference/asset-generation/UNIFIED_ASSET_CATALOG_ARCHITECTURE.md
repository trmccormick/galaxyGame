---
date_created: 2026-07-19
date_modified: 2026-07-19
type: DESIGN GUIDE
status: REFERENCE
phase: Phase 2 - Asset Architecture
---

# Unified Asset Catalog — Location-Agnostic Design Principle

## Summary

GalaxyGame uses a **unified asset catalog** where every visual asset (icon, sprite, 3D model, blueprint) is named and organized by **resource type**, not by its location of origin.

**Core Rule**: Nothing is location-specific unless inherently unique to that celestial body.

---

## Design Philosophy

### ❌ What NOT to Do

```
Lunar Regolith
Martian Regolith
Venusian Sulfur
Europa Ice
Mars Solar Panel
Lunar Solar Panel
Venus Atmospheric Processor
```

Problems with location-specific naming:
1. **Duplication**: Same resource appears multiple times with different names
2. **Scaling nightmare**: Add new planet (Proxima Centauri colony) → regenerate all assets with new location prefix
3. **System complexity**: Resource lookups become ambiguous ("which Oxygen are we using?")
4. **Player confusion**: Players don't learn unified visual language (each location looks "different")
5. **Asset maintenance hell**: Update Regolith icon → regenerate 10+ planet-specific versions

### ✅ What TO Do

```
Regolith
Basalt
Granite
Water Ice
Sulfur Ice
Oxygen (O₂)
Nitrogen (N₂)
Hydrogen Fuel
Solar Panel Mk1
Solar Panel Mk2
Atmospheric Processor
```

Benefits of canonical naming:
1. **Single source of truth**: Each resource exists once in the system
2. **Scales infinitely**: Add Mars, Venus, Titan, then Proxima Centauri — same asset library works everywhere
3. **Clear asset management**: One Regolith icon, used by all planets where regolith exists
4. **Player learns icons**: Blue hexagon = metal, brown hexagon = mineral, circle = gas (consistent across all locations)
5. **Future-proof**: Expands to other star systems without rework

---

## How Location Differences Work

### Location Effects Flow

**Game Data Layer** (JSON resources):
```json
{
  "resource_id": "regolith",
  "canonical_name": "Regolith",
  "locations": {
    "luna": {"abundance": "abundant", "extraction_difficulty": 0.5},
    "mars": {"abundance": "abundant", "extraction_difficulty": 0.6},
    "mercury": {"abundance": "common", "extraction_difficulty": 0.8},
    "venus": {"abundance": "rare", "extraction_difficulty": 1.2}
  }
}
```

**Asset Layer** (single icon used everywhere):
```
icon_mineral_regolith_256.png
  ↓
Used on Luna (abundant, easy extraction)
Used on Mars (abundant, moderate extraction)
Used on Mercury (common, harder extraction)
Used on Venus (rare, very hard extraction)
```

**Simulation Layer** (performance varies by planet):
```
Solar Panel Mk1 icon (same asset everywhere)
  ↓
On Luna: 140 W/m² output (low solar constant, no atmosphere loss)
On Mars: 590 W/m² output (moderate solar constant, dust effects)
On Venus: 10 W/m² output (cloud absorption, high heat stress)
```

The **same icon** represents the same resource, but location affects:
- Availability (where it's found)
- Difficulty (extraction cost)
- Performance (equipment output/efficiency)
- Formation (what processes create it)

**NOT** the asset itself.

---

## Resource Categories (Canonical List)

### Atmospheric Gases
All named by chemical formula or common name, not location:
- Oxygen (O₂)
- Nitrogen (N₂)
- Carbon Dioxide (CO₂)
- Hydrogen (H₂)
- Methane (CH₄)
- Ammonia (NH₃)
- Argon (Ar)
- Neon (Ne)
- Helium (He) — not "Helium-3" as primary asset; isotope variants are simulation parameters

### Liquids
- Water
- Heavy Water (D₂O)
- Brine
- Sulfuric Acid
- Liquid Hydrogen
- Liquid Methane
- (Location determines WHERE they're found, not their appearance)

### Ices
- Water Ice
- Carbon Dioxide Ice
- Methane Ice
- Nitrogen Ice
- Ammonia Ice

### Metals & Elements
- Iron (Fe)
- Aluminum (Al)
- Titanium (Ti)
- Silicon (Si)
- Carbon (C)
- Copper (Cu)
- Lithium (Li)
- Nickel (Ni)
- Chromium (Cr)
- Magnesium (Mg)
- (All generic; location determines availability)

### Minerals & Ore
- Regolith (generic planetary dust)
- Basalt
- Granite
- Quartz
- Ilmenite
- Olivine
- Feldspar
- Hematite
- Magnetite
- (All generic; location determines where found)

### Manufactured Materials
- Polymer
- Plastic
- Kevlar
- Carbon Fiber
- Composite Panel
- Glass
- Ceramic
- Steel
- Aluminum Alloy
- (Same materials work everywhere; performance may vary)

### Electronics
- Circuit Board
- Processor
- Memory
- Sensor
- Battery
- Capacitor
- Diode
- (Universal components; location affects availability/cost)

### Biological Resources
- Algae
- Seeds
- Crops
- Biomass
- (Appear where conditions allow; same icon everywhere)

### Fuels
- Hydrogen Fuel
- Methane Fuel
- Hydrazine
- RP-1
- LOX (Liquid Oxygen)
- Nuclear Fuel
- (Generic fuels; location determines production methods)

### Waste
- Scrap Metal
- Plastic Scrap
- Toxic Waste
- Nuclear Waste
- Slag
- (Same waste types everywhere; disposal/recycling methods vary)

### Unit Types
- Extractor (mining rig)
- Habitat (living quarters)
- Fabricator (manufacturing)
- Computer (data center)
- Battery (energy storage)
- Propulsion System
- Storage Depot
- Robot
(No "Lunar Extractor" vs "Martian Extractor" — same unit type, different deployment conditions)

### Craft Types
- Rover (wheeled vehicle)
- Harvester (extraction vehicle)
- Ship (small spacecraft)
- Spaceship (large spacecraft)
- Satellite (orbital platform)
(Same craft types everywhere; performance varies by location simulation)

### Structures
- Surface Base
- Orbital Station
- Power Plant
- Lab
- Inflatable Hub
- Greenhouse
- Mining Operation
- Processing Facility
- Storage Facility
(Generic structure types; location affects layout, power needs, resource availability)

---

## Implementation Rules

### Canonical Resource IDs
All assets should be referenced by canonical ID:
```
oxygen          (O₂)
nitrogen        (N₂)
regolith        (generic planetary dust)
water_ice       (frozen water)
iron            (element)
carbon_fiber    (manufactured material)
extractor       (unit type)
solar_panel_mk1 (technology tier 1)
```

NOT:
```
lunar_regolith      ❌
mars_iron           ❌
venus_sulfur        ❌
moon_base_unit      ❌
```

### Asset File Naming
```
icon_[category]_[name]_[size].png
  ✅ icon_mineral_regolith_256.png
  ✅ icon_gas_oxygen_32.png
  ✅ icon_unit_extractor_64.png
  ✅ icon_craft_rover_256.png
  
  ❌ icon_lunar_regolith_256.png
  ❌ icon_mars_iron_256.png
  ❌ icon_moon_habitat_256.png
```

### JSON Resource Definition
```json
{
  "id": "regolith",
  "canonical_name": "Regolith",
  "type": "mineral",
  "aliases": ["lunar soil", "martian dust", "asteroid regolith"],
  "icon": "icon_mineral_regolith_256.svg",
  "color_theme": "gray-brown",
  "locations": {
    "luna": {
      "prevalence": "abundant",
      "extraction_difficulty_base": 0.5,
      "special_properties": null
    },
    "mars": {
      "prevalence": "abundant",
      "extraction_difficulty_base": 0.6,
      "special_properties": "dust_storms"
    },
    "mercury": {
      "prevalence": "common",
      "extraction_difficulty_base": 0.8,
      "special_properties": "thermal_extremes"
    },
    "venus": {
      "prevalence": "rare",
      "extraction_difficulty_base": 1.2,
      "special_properties": "extreme_pressure"
    }
  },
  "simulation_effects": {
    "thermal_conductivity": 0.8,
    "radiation_shielding": 1.0,
    "dust_abrasion": 0.6
  }
}
```

Note:
- **Single** "regolith" resource entry
- Location prevalence is metadata, not a separate asset
- Simulation effects document how it behaves, not how it looks

---

## Exception: Inherently Unique Resources

**Only create separate assets if the resource is FUNDAMENTALLY UNIQUE to one location.**

Examples that CAN be location-specific:
- `helium3_luna` — Helium-3 is effectively Luna-only (isotope variant)
- `methane_titan_lakes` — Methane seas are Titan-specific (environmental feature)
- `europan_subsurface_water` — May need special icon if visually distinct from generic water ice

But even then, consider:
- Could it be generic + simulation notes? ("Water Ice — unique subsurface origin on Europa")
- Or is it genuinely different enough to warrant separate visual treatment?

**Rule**: Burden of proof is HIGH. Default to generic naming unless there's a strong visual/conceptual reason.

---

## Future System: Asset Registry Service

**Phase 2 planned feature** (2026-Q3):
```ruby
# Asset lookup — canonical only, location-agnostic
@asset = AssetRegistry.find("regolith")
@asset.icon_for_size(256)  # Returns same icon everywhere

# Location affects sourcing/availability, not asset
@regolith_on_luna = CelestialBody.luna.resources.find("regolith")
@regolith_on_luna.abundance  # "abundant"
@regolith_on_luna.difficulty  # 0.5
@regolith_on_luna.icon  # Same as regolith_on_mars.icon (same asset)
```

Benefits:
- No duplicate assets in database
- Scaling to new planets = just add location metadata, reuse existing icons
- Prevents accidental duplication ("oh, I need to generate Mars versions too")
- Clear separation: asset ≠ location behavior

---

## Migration Path (If Old System Had Location-Specific Assets)

**Before** (hypothetical past state):
```
lunar_regolith_icon.png
martian_regolith_icon.png
venusian_sulfur_icon.png
```

**After** (unified system):
```
icon_mineral_regolith_256.png    (used everywhere)
icon_element_sulfur_256.png      (used everywhere)
```

Process:
1. Audit all existing assets
2. Identify duplicates (same visual concept, different names)
3. Merge to canonical version (usually pick best quality or average if different)
4. Update JSON: all location references point to same canonical ID
5. Verify UI/code doesn't break (should be seamless if IDs were canonical internally)

---

## Advantages Summary

| Aspect | Location-Specific (❌) | Unified/Canonical (✅) |
|--------|----------------------|----------------------|
| **Asset count for 10 resources on 5 planets** | 50 assets | 10 assets |
| **Scaling to new planets** | Regenerate all assets | Add JSON metadata only |
| **Player learning curve** | Relearn icons per planet | One visual language |
| **File management** | Complex folder structure | Simple flat catalog |
| **Maintenance cost** | High (update all versions) | Low (update once) |
| **Visual consistency** | Requires manual enforcement | Automatic (same icon) |
| **Asset regeneration** | Months (hundreds of variants) | Days (single design system) |
| **Code complexity** | Lookup by location × resource | Lookup by resource only |

---

## References

- Icon Bible (2026-07-19-HIGH-DESIGN-GALAXY_GAME_ICON_BIBLE.md)
- Phase 2 Asset Registry planning
- ChatGPT design session (2026-07-19) — original source of this principle
- Professional precedent: Factorio, Dyson Sphere Program, Satisfactory, Oxygen Not Included (all use canonical asset libraries)

---

## Questions & Decision Tree

**Q: Should we make a Lunar-specific variant of the Extractor?**
- A: No. Same Extractor unit everywhere. Lunar conditions (lower gravity, dust) affect performance through simulation, not asset changes.

**Q: What about Helium-3, which is Luna-specific?**
- A: Keep as generic "Helium" (He) in main catalog. If Helium-3 is mechanically important, track as isotope variant in simulation metadata, not asset name.

**Q: Should Venus have different resource icons because of extreme conditions?**
- A: No. Same icons. Venus conditions (pressure, temperature, sulfuric clouds) affect extraction difficulty/resource availability in simulation, not visual appearance.

**Q: Can we have location-specific building skins?**
- A: Yes, if visually distinct (e.g., Inflatable Habitat vs Lava Tube Habitat as fundamentally different architecture). But base asset (icon) is still generic "habitat_module" with variant names for specific designs.

**Q: What happens when we expand to Proxima Centauri?**
- A: Add new location JSON entries. Icon library stays the same. Simulation parameters adapt to new planet's conditions. Zero asset regeneration needed.

