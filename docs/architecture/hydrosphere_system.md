# Hydrosphere System Architecture

## Overview

The hydrosphere system models planetary liquid bodies and their dynamic behavior. Unlike traditional hardcoded water-only systems, Galaxy Game's hydrosphere is **fully generic and data-driven**, supporting any liquid material based on planetary conditions and composition.

## Core Components

### Hydrosphere Model (`CelestialBodies::Spheres::Hydrosphere`)

The hydrosphere represents a planet's liquid envelope with the following key attributes:

- **total_liquid_mass**: Total mass of all liquids (kg)
- **liquid_bodies**: Distribution across oceans, lakes, rivers, ice caps, groundwater
- **composition**: JSON object defining liquid materials and their properties
- **state_distribution**: Current phase distribution (liquid/solid/vapor percentages)
- **temperature**: Current hydrosphere temperature (K)
- **pressure**: Current hydrosphere pressure (atm)

### Generic Liquid Support

The system supports any liquid material through:

1. **Material Lookup Integration**: Uses `Lookup::MaterialLookupService` for material properties
2. **Dynamic Composition**: JSON-based composition allows multiple liquid types per hydrosphere
3. **Phase-Aware Simulation**: Freezing/boiling points determined by material properties

### Example Compositions

```json
// Earth - Water-based
{
  "water": {
    "percentage": 100.0,
    "state": "liquid"
  }
}

// Titan - Methane/Ethane mixture
{
  "methane and ethane": {
    "percentage": 100.0,
    "state": "liquid"
  }
}

// Mixed composition (future expansion)
{
  "water": {"percentage": 70.0, "state": "liquid"},
  "ammonia": {"percentage": 30.0, "state": "liquid"}
}
```

## Terrain Analysis Integration

### TerrainDecompositionService

The `TerrainAnalysis::TerrainDecompositionService` decomposes mixed terrain data from Civ4/FreeCiv maps into separate dynamic layers, enabling realistic terraforming with independent geological, hydrological, and biological systems.

#### Key Features

- **Layer Separation**: Divides terrain into geological (rocky, mountains), hydrological (ocean, coast), and biological (grasslands, forest) layers
- **Elevation Generation**: Creates realistic elevation maps from terrain types using predefined ranges
- **Water Volume Calculation**: Calculates initial water volume based on hydrological terrain distribution
- **Dynamic Integration**: Applies `HydrosphereVolumeService` for volume-based water distribution

#### Decomposition Process

```ruby
service = TerrainAnalysis::TerrainDecompositionService.new(terrain_data)
result = service.decompose

# Returns:
{
  'width' => 10,
  'height' => 10,
  'elevation' => [[0.1, 0.2, ...], ...],  # 2D elevation map
  'water_volume' => 0.3,                   # 30% water coverage
  'layers' => {
    'geological' => [...],                 # Rocky, mountains, etc.
    'hydrological' => [...],               # Ocean, coast, swamp
    'biological' => [...]                  # Grasslands, forest, etc.
  },
  'grid' => [...],                         # Dynamic water distribution
  'sea_level' => 0.4,                      # Calculated sea level
  'water_coverage' => 0.3                  # Actual water coverage
}
```

### HydrosphereVolumeService

The `TerrainAnalysis::HydrosphereVolumeService` provides volume-based water distribution for terraforming simulations, replacing static tile assignments with dynamic elevation-based calculations.

#### Core Functionality

- **Sea Level Calculation**: Determines water level based on total volume and elevation distribution
- **Dynamic Distribution**: Updates terrain grid to reflect current water volume and sea level
- **Terraforming Support**: Allows adding/removing water volume (e.g., from KBO impacts)
- **Elevation-Based Rendering**: Enables realistic Mars terraforming with rising water levels

#### Volume-Based Water Distribution

```ruby
service = TerrainAnalysis::HydrosphereVolumeService.new(terrain_map)

# Calculate sea level for current water volume
sea_level = service.calculate_sea_level(0.5)  # 50% water coverage

# Update terrain with dynamic water distribution
updated_map = service.update_water_bodies

# Add water from KBO impact
terraformed_map = service.add_water_volume(0.2)  # +20% water
```

#### Water Volume Management

- **add_water_volume(volume_increase)**: Increases water volume and recalculates distribution
- **remove_water_volume(volume_decrease)**: Decreases water volume and recalculates distribution
- **Automatic Capping**: Water volume constrained between 0.0 and 1.0
- **Elevation Integration**: Sea level rises/falls based on elevation map and water volume

## Simulation Engine (HydrosphereConcern)

````

### HydrosphereSimulationService

The `TerraSim::HydrosphereSimulationService` provides comprehensive hydrosphere dynamics simulation:

#### Core Simulation Loop

```ruby
def simulate
  return unless valid_spheres?
  return if @simulating  # Prevent recursive calls
  
  @simulating = true
  begin
    calculate_region_temperatures
    handle_evaporation
    handle_precipitation
    calculate_state_distributions
    @hydrosphere.recalculate_state_distribution
    update_hydrosphere_volume
    handle_ice_melting
  ensure
    @simulating = false
  end
end
```

#### Key Methods

- **calculate_region_temperatures**: Computes temperatures for oceans, lakes, rivers, and ice based on surface temperature
- **handle_evaporation**: Transfers liquid to atmospheric vapor, supporting both numeric volumes and hash-based liquid bodies
- **handle_precipitation**: Condenses atmospheric vapor back to liquid bodies
- **calculate_state_distributions**: Updates solid/liquid/vapor phase percentages based on temperature and pressure
- **handle_ice_melting**: Simulates polar ice cap melting when temperatures exceed freezing point
- **update_hydrosphere_volume**: Maintains total liquid volume consistency

#### Robust Data Handling

The service handles multiple data formats for backward compatibility:

- **Numeric Volumes**: Direct numeric values for simple cases
- **Hash Volumes**: `{'volume' => 1.0e15}` for complex liquid body structures
- **Nil-Safe Operations**: Graceful handling of missing or invalid data

#### Integration with Atmosphere

- **Material Exchange**: Uses `MaterialLookupService` for proper material identification
- **Gas Management**: Adds/removes water vapor from atmosphere during evaporation/precipitation
- **Dust Reduction**: Precipitation reduces atmospheric dust concentrations

### Water Cycle Simulation

The hydrosphere concern provides realistic water cycle simulation:

- **Evaporation**: Liquid → Vapor (temperature and surface area dependent)
- **Precipitation**: Vapor → Liquid (temperature dependent)
- **Phase Transitions**: Dynamic solid/liquid/vapor distribution

### Generic Material Handling

```ruby
def primary_liquid
  # Returns the dominant liquid material from composition
  # e.g., "methane and ethane" for Titan, "water" for Earth
end

def calculate_evaporation_rate
  # Uses primary_liquid properties for evaporation calculations
  # No longer hardcoded to H2O
end
```

### Phase Change Calculations

Phase distributions are calculated using material-specific properties:

- **Freezing Point**: Retrieved from material lookup service
- **Boiling Point**: Retrieved from material lookup service
- **Temperature Ranges**: Dynamic based on liquid material properties

## Database Schema

```sql
CREATE TABLE hydrospheres (
  id BIGSERIAL PRIMARY KEY,
  celestial_body_id BIGINT NOT NULL,
  temperature FLOAT DEFAULT 0.0,
  pressure FLOAT DEFAULT 0.0,
  water_bodies JSONB DEFAULT '{}',  -- Generic liquid distribution
  composition JSONB DEFAULT '{}',   -- Liquid material composition
  state_distribution JSONB DEFAULT '{"liquid": 0.0, "solid": 0.0, "vapor": 0.0}',
  total_water_mass FLOAT DEFAULT 0.0,  -- Aliased to total_liquid_mass
  pollution INTEGER DEFAULT 0,
  environment_type VARCHAR DEFAULT 'planetary',
  sealed_status BOOLEAN DEFAULT FALSE,
  water_changes JSONB DEFAULT '{}',
  dynamic_pressure FLOAT,
  base_values JSONB DEFAULT '{}' NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

## Integration Points

### Atmosphere Interaction

Hydrospheres exchange materials with atmospheres:

- **Evaporation**: Liquids vaporize and enter atmosphere
- **Precipitation**: Atmospheric vapors condense into liquids
- **Material Transfer**: Generic material exchange between spheres

### Material Transferable Concern

Implements standardized material transfer protocols:

```ruby
def transfer_material(material_name, amount, target_sphere)
  # Generic material transfer between hydrosphere and other spheres
end
```

### Celestial Body Integration

Hydrospheres are tightly coupled with celestial bodies:

- **Surface Temperature**: Drives phase changes and evaporation rates
- **Atmospheric Pressure**: Affects boiling points and precipitation
- **Surface Area**: Determines evaporation surface area

## Testing Strategy

### Unit Tests

- **Model Validations**: Ensures data integrity
- **Generic Attributes**: Tests both water_bodies and liquid_bodies accessors
- **Material Independence**: Tests work with any liquid composition

### Integration Tests

- **Simulation Cycles**: End-to-end water cycle testing
- **Material Transfers**: Cross-sphere material movement
- **Phase Transitions**: Temperature-driven state changes

### Factory Support

```ruby
FactoryBot.define do
  factory :hydrosphere do
    total_liquid_mass { 0.0 }
    liquid_bodies { { oceans: 0.0, lakes: 0.0, rivers: 0.0 } }
    composition { { 'H2O' => 100.0 } }
    # ... other attributes
  end
end
```

## Future Enhancements

### Multi-Liquid Systems

Support for hydrospheres with multiple liquid phases:

- **Immiscible Liquids**: Oil/water separations
- **Solution Chemistry**: Dissolved materials and concentrations
- **Phase Diagrams**: Complex multi-component phase behavior

### Advanced Thermodynamics

- **Heat Transfer**: Energy exchange with atmosphere/geosphere
- **Convection Currents**: Ocean current modeling
- **Tidal Effects**: Lunar gravitational influences

### Exotic Liquids

Support for non-traditional liquids:

- **Cryogenic Liquids**: Liquid nitrogen, oxygen
- **High-Pressure Liquids**: Supercritical fluids
- **Exotic Compounds**: Complex organic mixtures

## Migration Notes

The hydrosphere system maintains backward compatibility through aliasing:

- `total_water_mass` ↔ `total_liquid_mass`
- `water_bodies` ↔ `liquid_bodies`

Existing code continues to work while new code can use generic naming.