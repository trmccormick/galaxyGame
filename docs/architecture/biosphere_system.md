# Biosphere System Architecture

## Overview

The biosphere system models planetary biological ecosystems and their dynamic interactions with other planetary spheres. Galaxy Game's biosphere is **fully generic and data-driven**, supporting diverse planetary biomes from terrestrial Earth-like worlds to exotic alien ecosystems.

## Core Components

### Biosphere Model (`CelestialBodies::Spheres::Biosphere`)

The biosphere represents a planet's biological envelope with the following key attributes:

- **biodiversity**: Current species diversity index (0-100)
- **biome_complexity**: Overall ecosystem complexity (0-100)
- **life_forms**: Collection of life form species on the planet
- **planet_biomes**: Distribution of biomes across the planetary surface
- **atmosphere_id**: Reference to the planet's atmospheric composition
- **hydrosphere_id**: Reference to the planet's water/liquid systems
- **geosphere_id**: Reference to the planet's geological systems

### PlanetBiome Model (`CelestialBodies::PlanetBiome`)

Individual biomes represent localized ecological zones:

- **biome_id**: Reference to biome type definition
- **area_percentage**: Percentage of planetary surface covered (stored in properties JSONB)
- **vegetation_cover**: Percentage of biome covered by vegetation (0-1)
- **moisture_level**: Soil moisture content (0-1)
- **latitude**: Biome latitude position (-90 to 90)
- **optimal_temperature**: Ideal temperature for this biome (K)
- **biodiversity**: Local species diversity

### LifeForm Model (`CelestialBodies::LifeForm`)

Biological species inhabiting the biosphere:

- **population**: Current population count
- **oxygen_production_rate**: O2 production per individual per day
- **co2_consumption_rate**: CO2 consumption per individual per day
- **methane_production_rate**: CH4 production per individual per day
- **nitrogen_fixation_rate**: N2 fixation rate
- **soil_improvement_rate**: Soil fertility improvement rate

## Simulation Engine (BiosphereSimulationService)

### TerraSim::BiosphereSimulationService

The `TerraSim::BiosphereSimulationService` provides comprehensive biosphere dynamics simulation, coordinating biological, atmospheric, and geological interactions.

#### Core Simulation Loop

```ruby
def simulate(time_skipped = 1)
  return unless valid_spheres?
  
  # Phase 1: Life form atmospheric effects
  influence_atmosphere(time_skipped)
  
  # Phase 2: Biome interactions
  simulate_biome_interactions
  
  # Phase 3: Global climate balancing
  balance_biomes
  
  # Phase 4: Biodiversity updates
  update_biodiversity
end
```

#### Key Methods

- **influence_atmosphere**: Calculates and applies life form gas exchange effects
- **simulate_biome_interactions**: Models vegetation growth, moisture dynamics, and inter-biome effects
- **balance_biomes**: Redistributes biome areas based on climate suitability
- **update_biodiversity**: Recalculates global biodiversity based on biome health

### Atmospheric Integration

The biosphere tightly integrates with atmospheric systems:

#### Gas Exchange Calculations

```ruby
def calculate_life_form_atmospheric_effects
  total_population = @biosphere.life_forms.sum(:population)
  
  effects = {
    total_population: total_population,
    species_count: @biosphere.life_forms.count,
    oxygen_production: 0.0,
    co2_consumption: 0.0,
    methane_production: 0.0
  }
  
  @biosphere.life_forms.each do |life_form|
    scale_factor = life_form.population.to_f / total_population
    
    effects[:oxygen_production] += life_form.oxygen_production_rate * scale_factor
    effects[:co2_consumption] += life_form.co2_consumption_rate * scale_factor
    effects[:methane_production] += life_form.methane_production_rate * scale_factor
  end
  
  effects
end
```

#### Time-Scaled Effects

Atmospheric influence scales with simulation time:

```ruby
def influence_atmosphere(time_skipped = 1)
  effects = calculate_life_form_atmospheric_effects
  
  # Scale effects by time and vegetation
  vegetation_factor = calculate_vegetation_factor
  time_factor = time_skipped.to_f
  
  o2_change = effects[:oxygen_production] * vegetation_factor * time_factor
  co2_change = -effects[:co2_consumption] * vegetation_factor * time_factor
  ch4_change = effects[:methane_production] * vegetation_factor * time_factor
  
  # Apply changes to atmosphere
  apply_atmospheric_changes(o2_change, co2_change, ch4_change)
end
```

### Biome Dynamics

#### Plant Growth Simulation

```ruby
def simulate_plant_growth(biome)
  light_availability = calculate_light_availability(biome)
  temperature_suitability = calculate_temperature_suitability(biome)
  moisture_availability = biome.moisture_level
  
  growth_rate = light_availability * temperature_suitability * moisture_availability
  new_cover = [biome.vegetation_cover + growth_rate, 1.0].min
  
  biome.update(vegetation_cover: new_cover)
end
```

#### Climate Suitability

Temperature suitability uses configurable ranges:

```ruby
def calculate_temperature_suitability(biome)
  current_temp = @biosphere.tropical_temperature
  optimal_temp = biome.optimal_temperature
  
  range = determine_temperature_range(biome)
  distance = (current_temp - optimal_temp).abs
  
  if distance <= range
    1.0
  else
    [0.0, 1.0 - (distance - range) / range].max
  end
end
```

### Global Balancing

#### Biome Area Redistribution

```ruby
def balance_biomes
  total_area = @biosphere.planet_biomes.sum(&:area_percentage)
  
  if total_area > 101.0 || total_area < 99.0
    scaling_factor = 100.0 / total_area
    @biosphere.planet_biomes.each do |biome|
      normalized_area = biome.area_percentage * scaling_factor
      biome.update(area_percentage: normalized_area)
    end
  end
  
  adjust_global_temperatures
end
```

#### Temperature Optimization

```ruby
def adjust_global_temperatures
  biome_optima = @biosphere.planet_biomes.map(&:optimal_temperature)
  target_temp = biome_optima.sum / biome_optima.size
  
  current_tropical = @biosphere.tropical_temperature
  current_polar = @biosphere.polar_temperature
  
  # Adjust temperatures toward biome optima
  new_tropical = adjust_temperature(current_tropical, target_temp)
  new_polar = adjust_temperature(current_polar, target_temp)
  
  @biosphere.update(
    tropical_temperature: new_tropical,
    polar_temperature: new_polar
  )
end
```

## Data Architecture

### Database Schema

```sql
-- Biosphere table
CREATE TABLE biospheres (
  id BIGSERIAL PRIMARY KEY,
  celestial_body_id BIGINT NOT NULL,
  biodiversity INTEGER DEFAULT 0,
  biome_complexity INTEGER DEFAULT 0,
  tropical_temperature FLOAT,
  polar_temperature FLOAT,
  base_values JSONB DEFAULT '{}' NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Planet biomes table
CREATE TABLE planet_biomes (
  id BIGSERIAL PRIMARY KEY,
  biosphere_id BIGINT REFERENCES biospheres(id),
  biome_id BIGINT REFERENCES biomes(id),
  properties JSONB DEFAULT '{}' NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Life forms table
CREATE TABLE life_forms (
  id BIGSERIAL PRIMARY KEY,
  biosphere_id BIGINT REFERENCES biospheres(id),
  population BIGINT DEFAULT 0,
  oxygen_production_rate FLOAT DEFAULT 0.0,
  co2_consumption_rate FLOAT DEFAULT 0.0,
  methane_production_rate FLOAT DEFAULT 0.0,
  nitrogen_fixation_rate FLOAT DEFAULT 0.0,
  soil_improvement_rate FLOAT DEFAULT 0.0,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

### JSON Properties Format

PlanetBiome uses JSONB properties for flexible attributes:

```json
{
  "area_percentage": 25.0,
  "vegetation_cover": 0.8,
  "moisture_level": 0.6,
  "latitude": 45.0,
  "optimal_temperature": 295.0,
  "biodiversity": 75
}
```

## Material Integration

### Lookup Service Integration

The biosphere integrates with material systems for realistic gas exchange:

```ruby
def apply_atmospheric_changes(o2_change, co2_change, ch4_change)
  atmosphere = @celestial_body.atmosphere
  
  # Use material lookup for proper gas identification
  lookup_service = Lookup::MaterialLookupService.new
  
  if o2_change > 0
    atmosphere.add_gas('O2', o2_change)
  end
  
  if co2_change != 0
    gas_name = lookup_service.get_material_property(
      lookup_service.find_material('CO2'), 'chemical_formula'
    )
    if co2_change > 0
      atmosphere.add_gas(gas_name, co2_change.abs)
    else
      atmosphere.remove_gas(gas_name, co2_change.abs)
    end
  end
end
```

### Property Access Methods

```ruby
def get_material_property(material, property_name)
  return nil unless material
  
  # Check top-level properties
  return material[property_name] if material.key?(property_name)
  
  # Check nested properties
  if material['properties']&.key?(property_name)
    return material['properties'][property_name]
  end
  
  # Special handling for molar_mass
  if property_name == 'molar_mass' && material['properties']&.key?('molar_mass_g_mol')
    return material['properties']['molar_mass_g_mol']
  end
  
  nil
end
```

## Testing and Validation

### RSpec Test Suite

The biosphere system includes comprehensive testing:

- **Unit Tests**: Individual method testing for BiosphereSimulationService
- **Integration Tests**: Full biosphere simulation cycles
- **Factory Support**: Celestial body factories with proper biosphere associations
- **Material Validation**: Ensures correct gas exchange and property access

### Test Coverage

Key test scenarios:

- Life form atmospheric effects scaling with population
- Biome vegetation growth based on environmental factors
- Global temperature balancing across biomes
- Time-scaled atmospheric gas exchange
- Material property lookup for gas identification
- Store accessor compatibility for biome properties

### Example Test

```ruby
describe '#influence_atmosphere simulates gas exchange with the atmosphere' do
  it 'scales effects by time' do
    # Create life forms
    create(:life_form, biosphere: biosphere, population: 1_000_000,
           oxygen_production_rate: 0.1, co2_consumption_rate: 0.05)
    
    # Run for 1 day
    service.influence_atmosphere(1)
    o2_mass_1 = atmosphere.gases.find_by(name: 'O2')&.mass.to_f
    
    # Reset and run for 10 days
    atmosphere.reset
    service.influence_atmosphere(10)
    o2_mass_10 = atmosphere.gases.find_by(name: 'O2')&.mass.to_f
    
    # Verify scaling
    expect(o2_mass_10).to be > o2_mass_1
  end
end
```

## Integration Points

### Multi-Sphere Interactions

The biosphere coordinates with all planetary spheres:

- **Atmosphere**: Gas exchange, climate effects, precipitation
- **Hydrosphere**: Water availability, moisture levels, evaporation
- **Geosphere**: Geological activity, mineral availability, soil composition

### Terraforming Integration

Biosphere simulation supports terraforming operations:

- **Life Form Introduction**: Adding species to modify atmospheric composition
- **Biome Modification**: Changing biome properties through terraforming
- **Climate Engineering**: Temperature and moisture manipulation

### Economic Integration

Biosphere state affects economic calculations:

- **Resource Availability**: Biodiversity affects harvestable resources
- **Habitability**: Biome complexity influences settlement viability
- **Terraforming Costs**: Current biosphere state affects terraforming expenses

## Future Enhancements

### Advanced Features

- **Species Evolution**: Dynamic species adaptation to environmental changes
- **Ecosystem Networks**: Complex food web and predator-prey relationships
- **Climate Feedback Loops**: Advanced climate-biosphere interactions
- **Alien Biochemistry**: Support for non-carbon-based life forms
- **Microbial Ecology**: Detailed microbial community modeling

### Research Integration

- **Ecological Modeling**: Advanced population dynamics and succession
- **Climate Science**: Integration with real climate models
- **Astrobiology**: Exotic life form support and detection</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/architecture/biosphere_system.md