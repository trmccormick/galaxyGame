## Cycler System Architecture

Cyclers are large mobile space stations that serve as AI Manager's primary deployment platforms.

### Design Philosophy:
- **Base Platform:** Generic cycler blueprint (base_cycler_bp.json)
- **Mission Fits:** Operational data files define specific configurations
- **Reconfigurable:** Units installed/removed between missions
- **Transferable Equipment:** Mission units transfer to permanent infrastructure
- **Reusable Platform:** Same cycler reused for multiple missions

### Cycler Capabilities:
- Acts as mobile base during construction (months to years)
- Provides temporary processing/manufacturing capability
- Houses crew during deployment
- Serves as construction platform
- Doubles as kinetic hammer for controlled Snaps

### Unit Categories:

**Permanent Equipment (Never Transfers):**
- Habitat modules (crew quarters)
- Life support systems
- Navigation systems
- Propulsion systems (ion drives)
- Core power generation

**Mission-Specific Equipment (Transfers to Infrastructure):**
- Atmospheric processors → Venus Station
- ISRU processors → Luna Base
- CNT fabricators → Venus Station
- Gas separators → Depot
- Solar arrays → Station/Depot
- Refining equipment → Ceres Base

**Reusable Equipment (Returns to Sol):**
- Construction drones
- Survey equipment
- Temporary storage modules
- Assembly cranes

### Operational Configurations:

**Venus Harvester Configuration:**
- Atmospheric processors (transfer to station)
- CNT fabricators (transfer to station)
- Gas separators (transfer to depot)
- Skimmer deployment bays (return to Sol)
- **Production Loop:** Atmospheric processors → CNT fabricators (CO₂ → Carbon Nanotubes, 50 kg/hour per fabricator)

**Luna Support Configuration:**
- ISRU processors (transfer to base)
- Regolith processors (transfer to base)
- Fabrication units (transfer to base)
- Construction drones (return to Sol)
- **Prerequisite for Lunar Space Elevator:** Requires CNT delivery from Venus/Mars foundry

**Mars Constructor Configuration:**
- Mining drones (deploy to Ceres)
- Refining equipment (transfer to Ceres)
- Hollowing equipment (transfer to Phobos/Deimos)
- Assembly systems (return to Sol)

**Kinetic Hammer Configuration:**
- All mission equipment removed/transferred
- Maximum cargo capacity
- Loaded with: extracted resources + retracted satellites
- Total mass: 18M+ kg

---

## AI Manager Pattern Recognition

The AI Manager now recognizes specialized mission patterns for optimized deployment:

### Interplanetary Foundry Pattern
- **Detection:** Profiles including atmospheric harvesting + CNT fabricator units
- **Classification:** Tagged as `interplanetary_foundry`
- **Priority:** HIGH PRIORITY when Lunar Elevator project is active
- **Purpose:** Identifies Venus/Mars missions capable of producing CNTs for lunar infrastructure
- **[Detailed Implementation](foundry_logic_and_lunar_elevator.md)**: Complete technical specification

### Pattern Training Integration
- Mission profiles analyzed for equipment combinations
- Foundry patterns prioritized for lunar elevator dependency fulfillment
- Dynamic weighting based on active project requirements
```

---

## ✅ Action Items for Implementation

### 1. Create Base Cycler Blueprint
```
File: base_cycler_bp.json
├─ Generic platform (no mission-specific equipment)
├─ Maximum mounting points
├─ Compatible with all unit types
└─ Foundation for all operational configurations
```

### 2. Create Operational Data Files
```
cycler_venus_harvester_data.json
cycler_lunar_support_data.json
cycler_mars_constructor_data.json
cycler_titan_harvester_data.json
cycler_kinetic_hammer_data.json
```

### 3. Define Transfer Mechanics
```
Document in operational data:
├─ Which units transfer where
├─ Transfer timing (after what milestone)
├─ What stays on cycler
├─ What returns to Sol
└─ Transfer process (docking, moving, installation)
```

### 4. Update Plan Document
```
Add sections:
├─ Cycler System Architecture
├─ Unit Transferability Rules
├─ Mission Lifecycle (Fit → Deploy → Transfer → Return → Refit)
└─ Examples for each pattern