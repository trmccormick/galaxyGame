# Lore & Mechanics Summary: Post-Planetary Industrialization

## Overarching Theme
The game represents the transition from **Resource Scarcity** to **Post-Planetary Industrialization**. The player manages a logistical monopoly over the solar system's gateways, not just playing a 4X game.

## 1. The Venusian Foundry Arc (The "Lid on a Pressure Cooker")

### Lore
Venus is no longer a "death trap" to be avoided; it is the solar system's primary **Carbon Forge**.

### Concept
Due to high atmospheric pressure and CO₂ abundance, Venus is the only place where **Carbon Nanotubes (CNTs)** can be manufactured at megastructure scale.

### Narrative Logic
The Cycler acts as a "Portable Industrial Brain." It descends into the upper atmosphere, deploys the CNT Fabricator, and "harvests the hell" out of the planet to fuel system expansion.

### Implementation Status
- **CNT Production**: Implemented in `app/services/industry/carbon_synthesis.rb`
- **Venus Operations**: CNT fabricators deployed via cyclers
- **Prerequisites**: Lunar Space Elevator requires CNT delivery (`edit_lunar.py`)

## 2. The Mars "Rule B" Pattern (The "Hollowed Protectorate")

### Lore
Mars is the military and logistical hub, but lacks a natural "Shield."

### Concept
The "Super-Mars" initiative involves **"Rule B" logic**—capturing Phobos, Deimos, or large asteroids and hollowing them out.

### Narrative Logic
Unlike Earth with its magnetosphere, Mars residents live in "Hollowed Moons." The 70% "Slag" from hollowing fuels Fusion Torches keeping stations in orbit, while 30% "Shielded Volume" becomes population safe havens.

### Implementation Status
- **Slag Resource**: Exists in `config/units/production.yml` and geological migration
- **Hollowing Operations**: Part of asteroid tug system
- **Missing**: `processed_slag` resource may be undefined (check for test failures)

## 3. The "Portable Space Station" (The Cycler's Identity)

### Lore
Large, stationary hubs are targets and "sunk costs." The future belongs to the Cyclers.

### Concept
A Cycler isn't just a ship; it's a **"Living Blueprint."**

### Narrative Logic
It carries units (Foundries, Habitats, Power Plants) and "plugs" into hollowed shells prepared by Tugs. This makes civilization "modular"—if a planet becomes unviable, the "Brain" (Cycler) simply unplugs and moves to a new shell.

### Implementation Status
- **Cycler Architecture**: Fully documented in `docs/architecture/ai_manager/CYCLER_SYSTEM_ARCHITECTURE.md`
- **Equipment Transfer**: Detailed in `docs/architecture/ai_manager/EQUIPMENT_TRANSFER_SYSTEM.md`
- **Modular Design**: Implemented via operational data files

## 4. The Alpha Centauri "Wormhole" Hook

### Lore
The Sol system is the "Cradle," but a natural wormhole or advanced FTL path to Alpha Centauri is the "Endgame."

### Concept
The AI Manager may not see a need to leave Sol for centuries, but JSON files for Alpha Centauri exist as a "silent promise" of expansion.

### Narrative Logic
Materials built on Venus (CNTs) and stations built at Mars are the "pre-requisites" for the massive energy required to bridge to the next star system.

### Implementation Status
- **Alpha Centauri Data**: Referenced in ScoutLogic refactor
- **Prerequisites**: CNT and slag production as expansion enablers
- **Future Feature**: Marked as long-term vision in executive summary

## Critical Missing Elements (Potential Test Failure Causes)

### Operational Tax Variables
- **Status**: Partially implemented in `app/services/financial/tax_collection_service.rb`
- **Issue**: Specific GCC tax for hollowing and transport may be missing
- **Impact**: AI Manager can't calculate mission profitability

### The "Slag" Resource
- **Status**: `slag` exists in production config, but `processed_slag` not found
- **Issue**: Primary fuel for Asteroid Propulsion Modules undefined
- **Impact**: Hollowing operations may fail

### Foundry Prerequisites
- **Status**: Lunar Space Elevator requires CNT from Venus/Mars (`edit_lunar.py`)
- **Issue**: If this "Gate" was lost, AI might build elevator too early
- **Impact**: Construction crashes or invalid builds

## Recommendations

1. **Audit Missing Resources**: Add `processed_slag` to resource registry
2. **Verify Tax Variables**: Ensure hollowing/transport taxes are defined
3. **Test Prerequisites**: Validate foundry gates prevent invalid constructions
4. **Document Mechanics**: This summary anchors lore to code implementation

---

*This summary bridges the narrative vision with technical implementation, ensuring the transition from Resource Scarcity to Post-Planetary Industrialization is mechanically sound.*