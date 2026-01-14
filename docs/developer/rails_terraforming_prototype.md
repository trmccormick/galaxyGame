# Rails Terraforming Simulation Prototype

This document outlines an early Rails-based prototype for a terraforming simulation game, adapted from a ChatGPT conversation. It serves as a developer tutorial for building basic planetary models, atmospheric calculations, and turn-based gameplay mechanics. The prototype demonstrates model design, Java-to-Ruby adaptations, and iterative development principles.

## Overview
The prototype creates a SimEarth-inspired game where players terraform and settle planets (Mars, Venus, random/dwarf planets) using "paraterraforming shells" or "worldhouse shells." It tracks resources (gases, ores, money), population, and habitable conditions.

Key features:
- Planetary settlement and building decisions
- Resource management (gases, ores, credits)
- Population tracking per planet
- Atmospheric calculations adapted from a Java Mars Terraforming Calculator

## Rails Application Structure

### Models

#### Planet Model
```ruby
class Planet < ApplicationRecord
  has_one :atmosphere
  has_many :terraformings
  has_many :settlements

  # Attributes: name, type (terrestrial, dwarf, etc.), mass, radius, gravity
  # Methods for settlement and resource checks
end
```

#### Atmosphere Model
```ruby
class Atmosphere < ApplicationRecord
  belongs_to :planet

  # Attributes: co2_level, n2_level, ch4_level, temperature, pressure, albedo, insolation
  # Adapted from Java calculator: regolith CO2, greenhouse effects, habitable ratios
end
```

#### Terraforming Model
```ruby
class Terraforming < ApplicationRecord
  belongs_to :planet

  # Attributes: action_type (e.g., 'add_co2', 'build_shell'), cost, progress
  # Methods for applying changes to atmosphere/population
end
```

#### Settlement Model
```ruby
class Settlement < ApplicationRecord
  belongs_to :planet

  # Attributes: population, resources (hash/jsonb), buildings (array)
  # Methods for growth, resource consumption
end
```

### Controllers

#### SimulationController
Handles turn-based gameplay:
```ruby
class SimulationController < ApplicationController
  def show
    @planet = Planet.find(params[:id])
    @atmosphere = @planet.atmosphere
  end

  def terraform
    # Apply terraforming action, update atmosphere
    terraforming = Terraforming.new(params[:terraforming])
    if terraforming.save
      update_atmosphere(terraforming)
      redirect_to simulation_path(@planet)
    end
  end

  private

  def update_atmosphere(terraforming)
    # Adapted Java calculations for CO2, temperature, etc.
    # Example: regolith outgassing based on Td (temperature increment)
  end
end
```

### Views
- `app/views/simulations/show.html.erb`: Display planet status, atmosphere data, available actions
- Forms for selecting terraforming actions and tracking resources/population

## Adapted Java Calculations (TerraSim1_1)

The prototype adapts the Java Mars Terraforming Calculator's formulas for habitable conditions:

### Key Variables
- `pole`: Polar CO2 reservoir
- `regolith`: Regolith CO2 capacity
- `Pr`: Regolith CO2 inventory
- `totCO2`: Total CO2 inventory
- `Td`: Temperature increment for regolith outgassing
- `S, a`: Insolation and albedo
- `PCO2, PN2, PCH4`: Partial pressures
- `Tb, Ts, Tp, Tt`: Temperatures (effective, surface, polar, tropical)
- `iceLat, habRatio`: Habitable parameters

### Ruby Implementation Example
```ruby
class AtmosphereCalculator
  def self.calculate_habitable_conditions(atmosphere)
    # Adapted from Java init and calculation methods
    td = calculate_td(atmosphere.temperature)
    pr = calculate_pr(atmosphere.co2_level, td)
    ice_lat = calculate_ice_latitude(atmosphere.temperature, atmosphere.albedo)
    hab_ratio = calculate_habitable_ratio(ice_lat)
    
    { td: td, pr: pr, ice_lat: ice_lat, hab_ratio: hab_ratio }
  end

  private

  def self.calculate_td(temperature)
    # Java: Td = ... (temperature-dependent outgassing)
    100.0 * Math.exp(-temperature / 50.0)  # Simplified adaptation
  end

  # Additional methods for regolith, pressures, etc.
end
```

## Development Tutorial

### Step 1: Set Up Rails App
1. `rails new terraforming_sim`
2. Generate models: `rails g model Planet name:string type:string mass:decimal radius:decimal`
3. Add associations and validations.

### Step 2: Adapt Calculations
1. Port Java variables to Ruby constants/methods.
2. Test with sample data (e.g., Mars baseline: CO2=95.32%, pressure=0.006 bar).

### Step 3: Add Gameplay
1. Create turn-based controller actions.
2. Implement resource checks and population growth.
3. Add UI for player decisions.

### Step 4: Iterate
- Add random planet generation.
- Integrate economic costs.
- Expand to multi-planet simulations.

## Relation to Galaxy Game
This prototype illustrates early design for the game's terraforming systems. The full game uses similar models (`CelestialBody`, biosphere simulations) but with integrated AI, markets, and multiplayer features. Use this as a starting point for understanding model-driven simulations and Java adaptation techniques.

## Resources
- Original Java TerraSim1_1 source (adapted in ChatGPT log)
- Rails guides for model associations and validations
- Game's `docs/architecture/biosphere_system.md` for advanced integrations</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/rails_terraforming_prototype.md