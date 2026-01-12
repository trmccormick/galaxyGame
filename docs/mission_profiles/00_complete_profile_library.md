# Complete Mission Profile Library

## Overview

Mission profiles are **reusable deployment techniques** learned from Sol's colonization history. Each profile represents a proven pattern for specific system characteristics that the AI can apply to any compatible discovered star system. The system is completely data-driven and system-agnostic - no hardcoded assumptions about specific systems exist (except Sol as the origin point).

## Complete Profile Catalog

### Luna Pattern
**Based on**: Earth's Moon
**Mission Profile**: `luna_deployment_mission.json`
**Trigger Conditions**: Large moon with accessible resources, stable orbit, proximity to habitable planet
**Key Features**: Surface ISRU operations, orbital depot network, resource extraction infrastructure
**Cycler Configuration**: `luna_support_configuration`
**Example Target Systems**: Any system with large rocky moons (similar to Luna, Europa, Ganymede)
**Special Notes**: Focuses on surface operations and orbital infrastructure development

### Mars Pattern
**Based on**: Mars system (planet + Phobos/Deimos)
**Mission Profile**: `mars_deployment_mission.json`
**Trigger Conditions**: Terrestrial planet with thin atmosphere + 2+ small moons + asteroid belt
**Key Features**: Asteroid capture and conversion, orbital depot network, atmospheric skimming
**Cycler Configuration**: `mars_constructor_configuration`
**Example Target Systems**: Rocky planets with moon systems and nearby asteroid belts
**Special Notes**: Integrates asteroid relocation tugs for moon/asteroid capture and positioning

### Venus Pattern (REFACTORED)
**Based on**: Venus (refactored for asteroid stations)
**Mission Profile**: `venus_deployment_mission.json`
**Trigger Conditions**: Dense atmosphere with no surface access, high pressure/temperature
**Key Features**: Asteroid station deployment, orbital infrastructure, atmospheric processing
**Cycler Configuration**: `venus_harvester_configuration`
**Example Target Systems**: High-pressure atmosphere worlds requiring orbital-only operations
**Special Notes**: **REFACTORED** - No longer focuses on surface/cloud cities. Now emphasizes asteroid relocation for orbital station networks due to Venus's extreme surface conditions.

### Jupiter Pattern
**Based on**: Jupiter system
**Mission Profile**: `jupiter_orbital_hub_profile_v1.json`
**Trigger Conditions**: Massive gas giant with intense radiation belts, multiple large moons
**Key Features**: Radiation-hardened infrastructure, helium-3 harvesting, moon-based depots
**Cycler Configuration**: `jupiter_deep_space_configuration`
**Example Target Systems**: Large gas giants with radiation concerns and moon systems
**Special Notes**: Three-tier separation: orbital station (construction), orbital depot (processing), moon network (storage)

### Saturn Pattern
**Based on**: Saturn system
**Mission Profile**: `saturn_orbital_hub_profile_v1.json`
**Trigger Conditions**: Ringed gas giant with extensive ring system and moon network
**Key Features**: Ring mining operations, moon-based infrastructure, hydrocarbon processing
**Cycler Configuration**: `saturn_operations_configuration`
**Example Target Systems**: Gas giants with prominent ring systems
**Special Notes**: Leverages ring resources for construction materials and fuel

### Titan Pattern
**Based on**: Titan (Saturn's moon)
**Mission Profile**: `titan_deployment_mission.json`
**Trigger Conditions**: Hydrocarbon-rich moon with thick atmosphere, cryovolcanic activity
**Key Features**: Fuel production hub, chemical manufacturing, surface base operations
**Cycler Configuration**: `titan_harvester_configuration`
**Example Target Systems**: Hydrocarbon-rich moons in gas giant systems
**Special Notes**: Primary fuel production and chemical synthesis center for outer system operations

### Neptune Pattern
**Based on**: Neptune system
**Mission Profile**: `neptune_orbital_hub_profile_v1.json`
**Trigger Conditions**: Distant ice giant with cryovolcanic moons, extreme distance from star
**Key Features**: Deep space research hub, nitrogen processing, autonomous operations
**Cycler Configuration**: `neptune_deep_space_configuration`
**Example Target Systems**: Distant ice giants requiring long-duration missions
**Special Notes**: Focuses on research and extreme environment operations

### Generic Pattern
**Based on**: Fallback pattern for unmatched systems
**Mission Profile**: `generic_settlement_mission.json`
**Trigger Conditions**: Any system not matching the above patterns
**Key Features**: Basic orbital infrastructure, resource assessment, minimal operations
**Cycler Configuration**: `standard_cycler_configuration`
**Example Target Systems**: Unique or exotic system configurations
**Special Notes**: Provides baseline colonization capability for novel system types

## Pattern Selection Logic

### How ScoutLogic Detects Patterns

The AI analyzes system characteristics using a decision tree:

```
System Analysis
├── Primary Body Classification
│   ├── Large Moon + Resources → Luna Pattern
│   ├── Terrestrial + Thin Atmosphere + Moons + Belt → Mars Pattern
│   ├── Dense Atmosphere + No Surface Access → Venus Pattern
│   ├── Massive Gas Giant + Radiation → Jupiter Pattern
│   ├── Ringed Gas Giant → Saturn Pattern
│   ├── Hydrocarbon Moon → Titan Pattern
│   ├── Distant Ice Giant → Neptune Pattern
│   └── No Match → Generic Pattern
└── Secondary Characteristics
    ├── Resource Availability
    ├── Orbital Mechanics
    ├── Radiation Environment
    └── Accessibility Factors
```

### Priority Order

When multiple patterns could apply, the system uses this priority hierarchy:

1. **Specific Moon Patterns** (Luna, Titan) - Most precise matches
2. **Gas Giant Patterns** (Jupiter, Saturn, Neptune) - Based on planet characteristics
3. **Terrestrial Patterns** (Mars, Venus) - Based on atmosphere and accessibility
4. **Generic Pattern** - Always available as fallback

## Cycler Configurations Table

| Pattern | Cycler Configuration | Specialized Craft | Primary Function |
|---------|---------------------|-------------------|------------------|
| Luna | `luna_support_configuration` | Surface ISRU equipment | Resource extraction |
| Mars | `mars_constructor_configuration` | Asteroid relocation tug | Orbital construction |
| Venus | `venus_harvester_configuration` | Atmospheric skimmers + tug | Orbital processing |
| Jupiter | `jupiter_deep_space_configuration` | Radiation-hardened systems | Gas giant operations |
| Saturn | `saturn_operations_configuration` | Ring mining equipment | Ring resource extraction |
| Titan | `titan_harvester_configuration` | Hydrocarbon processors | Fuel production |
| Neptune | `neptune_deep_space_configuration` | Autonomous systems | Deep space research |
| Generic | `standard_cycler_configuration` | Basic equipment | General operations |

## Mission Profile File Locations

### Core Pattern Files
- **Luna Pattern**: `app/data/missions/tasks/lunar-precursor-ai/lunar-precursor-ai_profile_v1.json`
- **Mars Pattern**: `app/data/missions/mars_settlement/mars_orbital_establishment_profile_v1.json`
- **Venus Pattern**: `app/data/missions/venus_settlement/profiles/venus_asteroid_relocation_network_profile_v1.json`
- **Jupiter Pattern**: `app/data/missions/jupiter-orbital-hub/jupiter_orbital_hub_profile_v1.json`
- **Saturn Pattern**: `app/data/missions/titan-resource-hub/titan_resource_hub_profile_v1.json`
- **Titan Pattern**: `app/data/missions/titan-resource-hub/titan_resource_hub_profile_v1.json`
- **Neptune Pattern**: `app/data/missions/neptune-orbital-hub/neptune_orbital_hub_profile_v1.json`
- **Generic Pattern**: Fallback logic in SettlementPlanGenerator

### Supporting Mission Files
- **Celestial Object Relocation**: `app/data/missions/tasks/celestial_object_relocation_mission/celestial_object_relocation_profile_v1.json`
- **Wormhole Expansion**: `app/data/missions/wormhole_expansion/wormhole_expansion_profile_v1.json`
- **Venus Harvester**: `app/data/missions/tasks/venus_harvester_mission/venus_harvest_01_profile_v1.json`
- **Titan Harvester**: `app/data/missions/tasks/titan_harvester_mission/titan_harvest_01_profile_v1.json`

## Code Examples

### Pattern Detection in SettlementPlanGenerator

```ruby
def select_mission_profile(analysis)
  case analysis[:primary_characteristic]
  when :large_moon_with_resources
    "luna_deployment_mission.json"
  when :small_moons_with_belt
    "mars_deployment_mission.json"
  when :atmospheric_planet_no_surface_access
    "venus_deployment_mission.json"
  when :gas_giant_with_moons
    "titan_deployment_mission.json"
  when :icy_moon_system
    "neptune_orbital_hub_profile_v1.json"
  else
    "generic_settlement_mission.json"
  end
end
```

### Cycler Configuration Selection

```ruby
def select_cycler_config(analysis)
  case analysis[:primary_characteristic]
  when :large_moon_with_resources
    "luna_support_configuration"
  when :small_moons_with_belt
    "mars_constructor_configuration"
  when :atmospheric_planet_no_surface_access
    "venus_harvester_configuration"
  when :gas_giant_with_moons
    "titan_harvester_configuration"
  when :icy_moon_system
    "neptune_deep_space_configuration"
  else
    "standard_cycler_configuration"
  end
end
```

### Pattern Matching Flowchart

```
System Characteristics Detected
        │
        ▼
Pattern Matching Engine
        │
        ├─ Large moon? ──────────────▶ Luna Pattern
        │
        ├─ Terrestrial + moons + belt? ──▶ Mars Pattern
        │
        ├─ Dense atmosphere + no surface? ──▶ Venus Pattern
        │
        ├─ Massive gas giant + radiation? ──▶ Jupiter Pattern
        │
        ├─ Ringed gas giant? ─────────▶ Saturn Pattern
        │
        ├─ Hydrocarbon moon? ────────▶ Titan Pattern
        │
        ├─ Distant ice giant? ───────▶ Neptune Pattern
        │
        └─ No match ─────────────────▶ Generic Pattern
```

## Integration with Wormhole Expansion

### Pattern Application to New Systems

When a wormhole is discovered and probed:

1. **System Analysis**: Probes gather celestial data
2. **Characteristic Extraction**: AI analyzes planets, moons, resources, orbital mechanics
3. **Pattern Matching**: System characteristics matched against Sol patterns
4. **Profile Selection**: Appropriate mission profile selected
5. **Plan Generation**: SettlementPlanGenerator creates customized colonization strategy
6. **Resource Allocation**: Specialized craft (tugs, cyclers) assigned based on pattern
7. **Mission Execution**: Coordinated deployment through wormhole

### System-Agnostic Design

The pattern library ensures that colonization strategies are:
- **Data-driven**: Based on physical characteristics, not system names
- **Scalable**: Same patterns work across different stellar classifications
- **Adaptable**: AI can refine patterns based on mission outcomes
- **Comprehensive**: Covers all major planetary system configurations

---

*This library represents the complete set of colonization patterns proven in the Sol system, ready for application to any discovered star system via wormhole expansion.*