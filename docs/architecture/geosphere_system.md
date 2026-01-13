# Geosphere System Architecture

## Overview

The geosphere system models planetary solid bodies and their geological processes. Galaxy Game's geosphere is **fully generic and data-driven**, supporting diverse planetary compositions from terrestrial rocky planets to exotic carbon or ice giants.

## Core Components

### Geosphere Model (`CelestialBodies::Spheres::Geosphere`)

The geosphere represents a planet's solid envelope with the following key attributes:

- **crust_composition**: JSON object defining crustal material composition
- **mantle_composition**: JSON object defining mantle material composition
- **core_composition**: JSON object defining core material composition
- **total_crust_mass**: Total mass of crustal materials (kg)
- **total_mantle_mass**: Total mass of mantle materials (kg)
- **total_core_mass**: Total mass of core materials (kg)
- **geological_activity**: Current geological activity level (0-100)
- **tectonic_activity**: Boolean indicating active plate tectonics
- **temperature**: Current geosphere temperature (K)

### Geological Materials (`GeologicalMaterial`)

Each geosphere contains multiple geological materials distributed across layers:

- **name**: Material name (e.g., "Iron", "Silicon", "Water Ice")
- **percentage**: Percentage of layer composition
- **layer**: Layer location ("core", "mantle", "crust")
- **state**: Physical state ("solid", "liquid", "metallic_hydrogen")
- **mass**: Calculated mass of this material

### Generic Material Support

The system supports any geological material through:

1. **Material Lookup Integration**: Uses `Lookup::MaterialLookupService` for material properties
2. **Dynamic Composition**: JSON-based composition allows multiple materials per layer
3. **State-Aware Simulation**: Material states determined by temperature, pressure, and composition

### Example Compositions

```json
// Earth - Terrestrial rocky planet
{
  "crust": {
    "silicon": 50.0,
    "oxygen": 40.0,
    "aluminum": 10.0
  },
  "mantle": {
    "silicon": 30.0,
    "oxygen": 50.0,
    "magnesium": 20.0
  },
  "core": {
    "iron": 80.0,
    "nickel": 20.0
  }
}

// Ice Giant - Uranus/Neptune-like
{
  "crust": {
    "methane_ice": 50.0,
    "ammonia_ice": 50.0
  },
  "mantle": {
    "water_ice": 70.0,
    "methane_ice": 20.0,
    "ammonia_ice": 10.0
  },
  "core": {
    "rock": 60.0,
    "ice": 40.0
  }
}

// Carbon Planet - Diamond-rich world
{
  "crust": {
    "graphite": 40.0,
    "diamond": 60.0
  },
  "mantle": {
    "carbon": 80.0,
    "silicon_carbide": 20.0
  },
  "core": {
    "iron": 70.0,
    "carbon": 30.0
  }
}
```

## Initialization Engine (GeosphereInitializer)

### TerraSim::GeosphereInitializer

The `TerraSim::GeosphereInitializer` service initializes planetary geospheres with appropriate materials and properties based on celestial body type.

#### Core Initialization Process

```ruby
def initialize_geosphere
  geological_activity = determine_geological_activity
  tectonic_activity = determine_tectonic_activity
  
  @geosphere = @celestial_body.build_geosphere(
    geological_activity: geological_activity,
    tectonic_activity: tectonic_activity
  )
  
  initialize_materials
  @geosphere.save!
end
```

#### Key Methods

- **determine_geological_activity**: Calculates geological activity based on planetary mass, temperature, and composition
- **determine_tectonic_activity**: Determines if plate tectonics are active based on geological activity level
- **initialize_materials**: Creates GeologicalMaterial records for core, mantle, and crust layers
- **determine_state**: Determines material physical state based on layer, temperature, and pressure

#### Planetary Type Configurations

The initializer uses configuration-driven material selection:

```ruby
# Terrestrial planets
core_materials: ['Iron', 'Nickel']
mantle_materials: ['Silicon', 'Oxygen', 'Magnesium']
crust_materials: ['Silicon', 'Oxygen', 'Aluminum']

# Ice giants
core_materials: ['Rock', 'Ice']
mantle_materials: ['Water Ice', 'Methane Ice', 'Ammonia Ice']
crust_materials: ['Methane Ice', 'Ammonia Ice']

# Gas giants
core_materials: ['Iron', 'Silicate', 'Hydrogen']
mantle_materials: ['Hydrogen', 'Helium']
crust_materials: ['Hydrogen', 'Helium', 'Methane']
```

#### Material State Determination

Materials change state based on extreme conditions:

- **Metallic Hydrogen**: Hydrogen in core under extreme pressure (>1,000,000 atm)
- **Ice States**: Methane, ammonia, and water exist as ices in cold environments
- **Gas States**: Light materials become gaseous in crustal conditions

## Simulation Engine (GeosphereConcern)

### GeosphereConcern Module

The `GeosphereConcern` provides shared geosphere functionality and simulation capabilities.

#### Core Features

- **Composition Management**: JSON-based material composition storage and manipulation
- **Material State Tracking**: Automatic state updates based on temperature changes
- **Reset Functionality**: Ability to restore geosphere to base initialization values
- **Volatile Extraction**: Temperature-driven release of volatile materials to atmosphere

#### Key Methods

- **reset**: Restores geosphere to initial base values
- **extract_volatiles**: Releases crustal volatiles based on temperature increase
- **update_material_records**: Synchronizes material records after composition changes
- **update_material_states**: Updates material states after temperature changes

#### Integration with Other Systems

The geosphere integrates with:

- **Atmosphere**: Volatile extraction feeds atmospheric composition
- **Biosphere**: Geological activity influences habitability
- **Terraforming**: Material availability affects terraforming processes

## Data Architecture

### Database Schema

```sql
-- Geosphere table
CREATE TABLE geospheres (
  id bigint PRIMARY KEY,
  celestial_body_id bigint REFERENCES celestial_bodies(id),
  crust_composition jsonb,
  mantle_composition jsonb,
  core_composition jsonb,
  total_crust_mass decimal,
  total_mantle_mass decimal,
  total_core_mass decimal,
  geological_activity integer,
  tectonic_activity boolean,
  temperature decimal,
  created_at timestamp,
  updated_at timestamp
);

-- Geological materials table
CREATE TABLE geological_materials (
  id bigint PRIMARY KEY,
  geosphere_id bigint REFERENCES geospheres(id),
  name varchar,
  percentage decimal,
  layer varchar,
  state varchar,
  mass decimal,
  created_at timestamp,
  updated_at timestamp
);
```

### JSON Composition Format

Geosphere compositions use nested JSON structures:

```json
{
  "crust": {
    "silicon": 28.0,
    "oxygen": 46.0,
    "aluminum": 8.0,
    "iron": 6.0
  },
  "mantle": {
    "oxygen": 44.0,
    "silicon": 22.0,
    "magnesium": 23.0,
    "iron": 6.0
  },
  "core": {
    "iron": 85.0,
    "nickel": 5.0,
    "sulfur": 4.0
  }
}
```

## Testing and Validation

### RSpec Test Suite

The geosphere system includes comprehensive testing:

- **Unit Tests**: Individual method testing for GeosphereInitializer
- **Integration Tests**: Full geosphere initialization and simulation
- **Factory Support**: Celestial body factories with proper geosphere associations
- **Material Validation**: Ensures correct material distributions and states

### Test Coverage

Key test scenarios:

- Terrestrial planet geosphere initialization
- Ice giant material composition
- Gas giant extreme pressure states
- Exotic material handling (metallic hydrogen, diamond formation)
- Geological activity calculations
- Tectonic activity determination

## Future Enhancements

### Planned Features

- **Dynamic Geology**: Real-time tectonic plate simulation
- **Volcanic Activity**: Magma generation and eruption modeling
- **Mineral Deposits**: Economically valuable material distribution
- **Impact Cratering**: Surface modification from meteor impacts
- **Tidal Heating**: Orbital mechanics affecting geological activity

### Research Integration

- **Material Science**: Advanced material property modeling
- **Geological Processes**: Erosion, sedimentation, and metamorphism
- **Planetary Evolution**: Long-term geological timescale simulation</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/architecture/geosphere_system.md