# Biome & Terraforming System Design

## Overview

This document describes the biome system architecture and the Ascension Island-inspired terraforming model used in Galaxy Game. The system is designed for realistic, science-grounded planetary simulation rather than "game-y" instant effects.

## Design Principles

1. **No Magic** - Life survives only if environmental conditions support it
2. **Slow Changes** - Terraforming takes years/decades of game time
3. **Domes First** - Protected environments bootstrap biome establishment
4. **Pioneer Species** - Simple life modifies conditions for complex life
5. **Import Life** - Every species is delivered via player contracts, not spawned
6. **Failure Possible** - Wrong conditions = die-off, restart required

## Priority: Earth First

Before implementing terraforming for barren worlds, the system must correctly simulate Earth's existing biosphere:

1. **Earth Simulation** - TerraSim manages existing biomes based on climate
2. **Validate Model** - Ensure biomes respond correctly to temperature/rainfall changes
3. **Then Mars** - Requires atmospheric adjustments before any biome work
4. **Then Others** - Venus, Titan, etc. have unique challenges

---

## Biome Definitions

### Canonical Biome Types (FreeCiv-aligned)

Biomes are defined by **climate conditions** (temperature + rainfall), not terrain features.

| Biome | Temperature (K) | Rainfall (mm/yr) | Climate Driver |
|-------|-----------------|------------------|----------------|
| `arctic` | 200-250 | 50-150 | Cold + dry |
| `tundra` | 250-280 | 100-300 | Cold |
| `boreal` | 265-290 | 300-800 | Cold + wet |
| `forest` | 278-295 | 750-1500 | Temperate + wet |
| `grasslands` | 283-300 | 250-750 | Temperate + seasonal |
| `plains` | 280-305 | 300-600 | Temperate + dry |
| `desert` | 260-320 | 0-250 | Arid (any temp) |
| `jungle` | 293-308 | 2000-4000 | Hot + wet |
| `swamp` | 288-303 | 1000-2000 | Warm + waterlogged |
| `ocean` | 273-300 | N/A | Marine |
| `deep_sea` | 273-277 | N/A | Marine (deep) |

### Key Clarifications

- **Desert** = Low rainfall. Can be hot (Sahara) or cold (Gobi, Antarctic dry valleys)
- **Mountains/Hills** = Terrain features (elevation), NOT biomes. A mountain can have arctic biome at peak, forest at base
- **Biomes seed TerraSim** - Initial temp/rainfall values come from biome classification

### NASA Name Mapping

NASA terrain generator uses detailed names that map to canonical types:

| NASA Name | Canonical Biome |
|-----------|-----------------|
| `tropical_grassland` | `grasslands` |
| `tropical_seasonal_forest` | `jungle` |
| `tropical_rainforest` | `jungle` |
| `temperate_forest` | `forest` |
| `temperate_grassland` | `plains` |
| `boreal_forest` | `boreal` |
| `polar_desert` | `arctic` |
| `tundra` | `tundra` |

---

## Data Architecture

### Storage Layers

| Location | Purpose | Content |
|----------|---------|---------|
| `geosphere.terrain_map['elevation']` | Topography | 2D grid of elevation values |
| `geosphere.terrain_map['biomes']` | Spatial biomes | 2D grid of biome types per cell |
| `biomes` table | Master definitions | Biome records with temp/rainfall ranges |
| `planet_biomes` join | Aggregate stats | Links biosphere → biomes with area % |
| `biosphere.biome_distribution` | Summary | Hash of biome percentages |

### Data Flow

```
NASA/Civ4 Import
      ↓
terrain_map['biomes'][y][x] = 'forest'
      ↓
Aggregate to planet_biomes (area percentages)
      ↓
TerraSim reads conditions, evolves percentages
      ↓
Biomes reclassify if climate shifts enough
```

---

## TerraSim Biosphere Integration

### For Earth (Existing Biosphere)

Earth already has a functioning biosphere. TerraSim's role:

1. **Read Initial State** - Biomes from NASA/Civ4 data
2. **Monitor Climate** - Track temperature and rainfall per region
3. **Evolve Distribution** - If climate changes, biome boundaries shift
4. **Atmospheric Feedback** - Forests absorb CO2, release O2

### Biome Evolution Rules

```ruby
# Biomes shift based on climate suitability
def reclassify_biome(cell, current_temp, current_rainfall)
  current_biome = cell.biome
  
  # Check if current biome is still viable
  if biome_viable?(current_biome, current_temp, current_rainfall)
    return current_biome  # No change
  end
  
  # Find best matching biome for new conditions
  find_best_biome(current_temp, current_rainfall)
end
```

---

## Terraforming Model (Ascension Island)

### Historical Reference

Ascension Island (1843-present): British Navy transformed barren volcanic rock into self-sustaining cloud forest by:
1. Planting pioneer species that modified local conditions
2. Each generation enabled the next, more complex species
3. Trees captured moisture from clouds, creating rainfall
4. Process took 150+ years

### Game Implementation

#### Phase 1: Survey & Planning

```
AI Manager analyzes:
├── Current conditions (atmosphere, temp, water)
├── Target biome (from Civ4/FreeCiv "future state" map)
└── Gap analysis: What infrastructure/conditions needed?
```

#### Phase 2: Protected Bootstrap (Domes)

```
AI Manager places biodome:
├── Artificial life support (heating, pressure, water)
├── Pioneer organisms (engineered bacteria, algae)
├── Creates SUPPLY CONTRACTS for materials
└── Players deliver: organisms, equipment, resources
```

#### Phase 3: Environment Modification

```
Inside dome, pioneers work:
├── Bacteria process regolith → soil
├── Algae produce O2, consume CO2
├── Moisture accumulates
└── LOCAL microclimate improves
```

#### Phase 4: Condition Monitoring

```
TerraSim evaluates each tick:
├── Can surface outside dome support life yet?
├── Has atmosphere improved enough?
├── Is temperature/pressure within range?
└── Track progress toward "dome removal" threshold
```

#### Phase 5: Gradual Expansion

```
When conditions allow:
├── Dome boundaries expand OR
├── New adjacent domes placed OR
├── Dome removed, biome exposed to surface
└── Success: biome spreads naturally
```

### Viability Factors

For a biome to survive outside a dome:

| Factor | Weight | Description |
|--------|--------|-------------|
| Temperature | 30% | Within survivable range |
| Rainfall | 25% | Adequate water availability |
| Atmosphere | 20% | O2/CO2 balance, pressure, no toxics |
| Soil | 15% | Nutrients, processed regolith |
| Radiation | 10% | Protection from solar/cosmic |

### Biome Lifecycle States

```
SEEDED → STRUGGLING → ESTABLISHING → THRIVING → STABLE
              ↓            ↓             ↓
           DYING → COLLAPSED → BARREN
```

---

## Mars Terraforming Example

Mars requires atmospheric work before biome establishment:

### Pre-Biome Requirements

1. **Atmosphere thickening** - Import gases, release frozen CO2
2. **Magnetic shielding** - Orbital or surface-based radiation protection
3. **Water liberation** - Melt polar ice, import comets
4. **Temperature increase** - Greenhouse effect from thicker atmosphere

### Sequence

```
Year 0-50:    Atmospheric processing (no biomes possible)
Year 50-100:  First biodomes with extremophile bacteria
Year 100-200: Dome networks, soil processing
Year 200-300: First surface-exposed lichens/mosses
Year 300+:    Gradual biome expansion as conditions improve
```

### Target State (from Civ4 Mars Map)

Civ4/FreeCiv Mars maps show the "goal state" - what Mars could look like after successful terraforming. AI Manager uses this to:
- Plan dome placement at target biome locations
- Prioritize regions with favorable conditions (Hellas Basin = low elevation)
- Estimate timeline and resource requirements

---

## Implementation Status

### Completed
- [x] Biome model with temperature/humidity ranges
- [x] NASA terrain generator produces biome grid
- [x] FreeCiv import maps terrain to biomes
- [x] BiosphereSimulationService basic structure

### Needed for Earth Simulation
- [ ] Seed `biomes` table with canonical types
- [ ] Normalize NASA biome names to FreeCiv canonical
- [ ] Connect terrain_map['biomes'] to planet_biomes records
- [ ] Update monitor.js getBiomeColor() for all biome types
- [ ] Validate TerraSim biome evolution logic

### Future (Terraforming)
- [ ] Biodome structure/entity
- [ ] Pioneer species (extremophile life forms)
- [ ] Dome microclimate simulation
- [ ] Surface viability calculation
- [ ] AI Manager dome placement planning
- [ ] Supply contracts for biome materials

---

## References

- [Ascension Island Terraforming](https://en.wikipedia.org/wiki/Ascension_Island#Flora) - Historical model
- [SimEarth Manual](https://archive.org/details/SimEarthManual) - Game inspiration (but more realistic)
- [FreeCiv Terrain Types](https://freeciv.org/wiki/Terrain) - Canonical biome naming
- [docs/developer/FREECIV_INTEGRATION.md](../developer/FREECIV_INTEGRATION.md) - Map import details
