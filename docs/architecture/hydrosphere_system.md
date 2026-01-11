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

## Simulation Engine (HydrosphereConcern)

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