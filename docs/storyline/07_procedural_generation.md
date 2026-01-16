# Procedural Generation: System Creation and Loading

## Core Generation Methods

### Standard Procedural Generation
- `generate_system_seed`: Creates new systems with randomized parameters
- Uses stellar mass distributions, orbital mechanics, and atmospheric modeling
- Generates terrestrial planets, gas giants, ice giants, and asteroid belts

### Hybrid Generation
- `generate_hybrid_system_from_seed`: Loads ground truth data and fills procedural gaps
- Preserves immutable astronomical data (stars, known exoplanets)
- Generates missing orbital slots with consistent physics

## EM Yield Variable

- **Definition**: EM Yield represents the Exotic Matter extraction potential of natural wormholes, measured in EM units per hour
- **Calculation**: Based on wormhole size, stability, and residual EM signatures from historical activity
- **Range**: 10-1000 EM/hour depending on wormhole characteristics and system EM background
- **AI Integration**: Used by AI Manager to prioritize harvesting sites and calculate network fuel requirements
- **Act 2 Urbanization**: This variable enables the transition to permanent wormhole networks by quantifying EM resources for artificial station construction

## Vetted System Loading

### load_vetted_system(file_id)
- **Purpose**: Force-loads pre-vetted systems for narrative events (e.g., System A)
- **Implementation**: Specifically loads `aol-732356.json` when System A event triggers
- **Prize Status Guarantee**: Automatically maps `magnetic_moment: 0.82` and `tei_score: 0.88` to celestial bodies
- **Identifier Sanitization**: Enforces [System]-[Letter] formatting (e.g., PLANET-1 → AOL-732356-b) for all loaded systems, even legacy test data
- **Metadata**: Marks system with `naming_status: "scientific_catalog"` and `vetted_for_system_a: true`

### sanitize_identifiers!(system_data)
- **Purpose**: Enforces consistent [System]-[Letter] identifier formatting across all celestial bodies
- **Implementation**: Iterates through terrestrial_planets, gas_giants, ice_giants, dwarf_planets, and asteroids arrays
- **Transformation**: Replaces legacy identifiers (e.g., "PLANET-1") with proper [System]-[Letter] format (e.g., "AOL-732356-b") for planets, and [System]-AST-[Index] for asteroids (e.g., "AOL-732356-AST-35")
- **Minor Bodies Convention**: Asteroids and comets follow [System]-AST-[Index] convention to prevent UI clutter during high-density belt scans
- **Name Field Sync**: Updates asteroid name fields to match identifiers for redundancy elimination in technical logs
- **Integration**: Called automatically by load_vetted_system and load_generated_system methods
- **AI Compatibility**: Ensures AI mission logging and UI display use consistent alphanumeric identifiers

### Narrative Override
- Bypasses standard procedural generation for story-critical systems
- Ensures consistent "Prize World" characteristics across playthroughs
- Maintains scientific catalog identifiers until settlement phase

## System Loading Pipeline

1. **File Resolution**: Locate JSON in `generated_star_systems/` directory
2. **Data Validation**: Verify required astronomical parameters
3. **Metadata Injection**: Add naming status and vetting flags
4. **Prize Mapping**: Apply terraformability scores for AI recognition

---

*Procedural generation provides infinite variety while narrative overrides ensure story consistency.*