# ==============================================================================
# STRATEGY: Enhance BiosphereSimulationService for Terraforming
# ==============================================================================
# This shows how to add terraforming features to your EXISTING simulation
# without breaking what you have
# ==============================================================================

# ------------------------------------------------------------------------------
# STEP 1: Pass time_skipped through the simulation chain
# ------------------------------------------------------------------------------

# In TerraSim::Simulator
module TerraSim
  class Simulator
    # MODIFY: Pass days_elapsed to sphere simulations
    def update_spheres(days_elapsed = 1)
      # Simulate atmosphere if present
      if @celestial_body.respond_to?(:atmosphere) && @celestial_body.atmosphere.present?
        AtmosphereSimulationService.new(@celestial_body).simulate(days_elapsed)
      end
      
      # ... other spheres ...
      
      # Simulate biosphere if present - NOW WITH TIME
      if @celestial_body.respond_to?(:biosphere) && @celestial_body.biosphere.present?
        BiosphereSimulationService.new(@celestial_body).simulate(days_elapsed)
      end
      
      # ... rest of your code ...
    end
    
    # MODIFY: Accept days_elapsed parameter
    def calc_current(days_elapsed = 1)
      if stars.empty?
        @celestial_body.update(surface_temperature: 3)
        update_gravity
        update_spheres(days_elapsed)
        return
      end

      update_temperature
      update_gravity
      update_spheres(days_elapsed)
    end
  end
end

# In Game class
class Game
  def advance_by_days(days)
    # ... your existing code ...
    
    # When you simulate planets, pass the days
    CelestialBodies::CelestialBody.find_each do |body|
      simulator = TerraSim::Simulator.new(body)
      simulator.calc_current(days) # Pass the days!
    end
  end
end

# ------------------------------------------------------------------------------
# STEP 2: Enhance BiosphereSimulationService to USE time_skipped
# ------------------------------------------------------------------------------

module TerraSim
  class BiosphereSimulationService
    def initialize(celestial_body, config = {})
      @celestial_body = celestial_body
      @biosphere = celestial_body.biosphere
      @simulation_in_progress = false
      @config = GameConstants::BIOSPHERE_SIMULATION.dup
      configure_for_planet
      @config.merge!(config)
    end
    
    # MODIFY: Actually use the time_skipped parameter
    def simulate(time_skipped = 1)
      return if @simulation_in_progress
      @simulation_in_progress = true
      return unless @biosphere
      
      # Store time for use in other methods
      @time_skipped = time_skipped
      
      calculate_biosphere_conditions
      simulate_ecosystem_interactions
      track_species_population
      manage_food_web
      balance_biomes 
      
      # MODIFIED: Scale atmospheric influence by time
      influence_atmosphere(time_skipped)

      @simulation_in_progress = false
    end
    
    # MODIFY: Accept and use time_skipped parameter
    def influence_atmosphere(time_skipped = 1)
      return unless @biosphere && @celestial_body.atmosphere
      
      atmosphere = @celestial_body.atmosphere
      
      if atmosphere.total_atmospheric_mass <= 0
        atmosphere.update(total_atmospheric_mass: 100.0)
      end
      
      # NEW: Calculate gas changes from actual life forms
      life_form_effects = calculate_life_form_atmospheric_effects
      
      # If we have life forms with effects, use those
      if life_form_effects[:total_population] > 0
        o2_change = life_form_effects[:o2_production] * time_skipped
        co2_change = life_form_effects[:co2_consumption] * time_skipped
        methane_change = life_form_effects[:ch4_production] * time_skipped
      else
        # Fall back to your existing hardcoded values (scaled by time)
        o2_change = 0.01 * time_skipped
        co2_change = -0.01 * time_skipped
        methane_change = 0.001 * time_skipped
      end
      
      # Your existing vegetation scaling code
      has_vegetation = false
      total_biomes = 0
      
      begin
        if @biosphere.respond_to?(:planet_biomes) && @biosphere.planet_biomes.any?
          total_biomes = @biosphere.planet_biomes.count
          has_vegetation = true
        end
      rescue => e
        puts "WARNING: Error accessing biome data: #{e.message}"
      end
      
      if has_vegetation
        vegetation_factor = (total_biomes / 5.0).clamp(0.1, 2.0)
        o2_change *= vegetation_factor
        co2_change *= vegetation_factor
      end
      
      # Rest of your existing atmosphere update code...
      initial_o2 = atmosphere.o2_percentage
      initial_co2 = atmosphere.co2_percentage
      initial_ch4 = atmosphere.ch4_percentage
      
      new_o2 = [initial_o2 + o2_change, 0.0].max
      new_co2 = [initial_co2 + co2_change, 0.0].max
      new_ch4 = [initial_ch4 + methane_change, 0.0].max
      
      puts "Atmosphere gas changes (#{time_skipped} days):"
      puts "  O2: #{initial_o2} → #{new_o2} (change: #{o2_change.round(4)})"
      puts "  CO2: #{initial_co2} → #{new_co2} (change: #{co2_change.round(4)})"
      puts "  CH4: #{initial_ch4} → #{new_ch4} (change: #{methane_change.round(4)})"
      
      total_mass = atmosphere.total_atmospheric_mass
      
      o2_mass = (new_o2 * total_mass) / 100.0
      co2_mass = (new_co2 * total_mass) / 100.0
      ch4_mass = (new_ch4 * total_mass) / 100.0
      
      atmosphere.gases.where(name: ['O2', 'CO2', 'CH4']).destroy_all
      
      atmosphere.add_gas('O2', o2_mass) if o2_mass > 0
      atmosphere.add_gas('CO2', co2_mass) if co2_mass > 0
      atmosphere.add_gas('CH4', ch4_mass) if ch4_mass > 0
      
      atmosphere.reload

      true
    end
    
    # NEW: Calculate atmospheric effects from actual life forms
    def calculate_life_form_atmospheric_effects
      effects = {
        o2_production: 0.0,
        co2_consumption: 0.0,
        ch4_production: 0.0,
        total_population: 0
      }
      
      return effects unless @biosphere.respond_to?(:life_forms)
      
      @biosphere.life_forms.each do |life_form|
        next unless life_form.population && life_form.population > 0
        
        # Scale by population (normalize to billions)
        pop_scale = life_form.population / 1_000_000_000.0
        
        # Get rates from properties (new fields we'll add)
        o2_rate = life_form.properties['oxygen_production_rate'].to_f
        co2_rate = life_form.properties['co2_consumption_rate'].to_f
        ch4_rate = life_form.properties['methane_production_rate'].to_f
        
        effects[:o2_production] += o2_rate * pop_scale
        effects[:co2_consumption] += co2_rate * pop_scale
        effects[:ch4_production] += ch4_rate * pop_scale
        effects[:total_population] += life_form.population
      end
      
      effects
    end
    
    # MODIFY: Scale population changes by time
    def track_species_population
      puts "Tracking species population in #{@biosphere}"

      @biosphere.life_forms.each do |life_form|
        biome = @biosphere.biomes.find_by(name: life_form.properties['preferred_biome'])
        next unless biome

        # Your existing logic...
        carrying_capacity = biome.area_percentage * life_form.properties['size_modifier'].to_f
        birth_rate = life_form.properties['reproduction_rate'].to_f * life_form.properties['health_modifier'].to_f
        death_rate = life_form.properties['mortality_rate'].to_f * (2.0 - life_form.properties['health_modifier'].to_f).clamp(0.1, 2.0)

        # MODIFIED: Scale by time_skipped
        population_change = (birth_rate - death_rate) * life_form.population * 0.01 * @time_skipped

        new_population = (life_form.population + population_change).floor
        life_form.update(population: [new_population, 0].max)
        puts "  #{life_form.name} population: #{life_form.population} in #{biome.name}, Change: #{population_change.round(2)}"
      end
    end
    
    # Your other existing methods stay the same...
    # simulate_ecosystem_interactions, manage_food_web, balance_biomes, etc.
  end
end

# ------------------------------------------------------------------------------
# STEP 3: Add terraforming-specific properties to life forms
# ------------------------------------------------------------------------------

# In a migration:
# class AddTerraformingPropertiesToLifeForms < ActiveRecord::Migration[7.0]
#   def change
#     # No schema changes needed! We use the existing JSONB 'properties' column
#   end
# end

# In your life form models - ADD these to the existing store_accessor:
module Biology
  class BaseLifeForm < ApplicationRecord
    # Your existing store_accessor line:
    store_accessor :properties, 
      :diet, :prey_for, :description, :biochemistry, :ecological_role,
      :reproduction_mode, :lifespan, :resistance_traits,
      # ADD these new ones for terraforming:
      :oxygen_production_rate,      # kg/day per billion organisms
      :co2_consumption_rate,         # kg/day per billion organisms
      :methane_production_rate,      # kg/day per billion organisms
      :nitrogen_fixation_rate,       # kg/day per billion organisms
      :soil_improvement_rate,        # points/day per billion organisms
      # ADD these for your existing simulation:
      :preferred_biome,              # string
      :size_modifier,                # float
      :reproduction_rate,            # float
      :mortality_rate,               # float
      :health_modifier,              # float
      :consumption_rate,             # float
      :mass,                         # kg
      :foraging_efficiency,          # float
      :hunting_efficiency            # float
    
    # Your existing methods stay...
    
    # NEW: Get this life form's atmospheric contribution
    def atmospheric_contribution
      return {} unless population && population > 0
      
      pop_scale = population / 1_000_000_000.0
      
      {
        o2: properties['oxygen_production_rate'].to_f * pop_scale,
        co2: properties['co2_consumption_rate'].to_f * pop_scale,
        ch4: properties['methane_production_rate'].to_f * pop_scale,
        n2: properties['nitrogen_fixation_rate'].to_f * pop_scale
      }
    end
  end
end

# ------------------------------------------------------------------------------
# STEP 4: Create a library of deployable organisms
# ------------------------------------------------------------------------------

module Biology
  class TerraformingLibrary
    # These are factory methods that create life forms with terraforming properties
    
    def self.create_cyanobacteria(biosphere)
      Biology::LifeForm.create!(
        biosphere: biosphere,
        name: 'Cyanobacteria',
        complexity: :microbial,
        domain: :aquatic,
        population: 1_000_000_000, # 1 billion starting population
        
        # Terraforming properties (per day, per billion organisms)
        oxygen_production_rate: 0.1,        # 0.1 kg O2 per day
        co2_consumption_rate: 0.15,         # consumes 0.15 kg CO2 per day
        
        # Simulation properties
        preferred_biome: 'Ocean',
        size_modifier: 0.000001,
        reproduction_rate: 1.5,
        mortality_rate: 1.0,
        health_modifier: 1.0,
        
        # Survival tolerances
        description: 'Oxygen-producing photosynthetic bacteria, very hardy'
      )
    end
    
    def self.create_nitrogen_fixer(biosphere)
      Biology::LifeForm.create!(
        biosphere: biosphere,
        name: 'Nitrogen-Fixing Bacteria',
        complexity: :microbial,
        domain: :terrestrial,
        population: 500_000_000,
        
        # Terraforming properties
        nitrogen_fixation_rate: 0.08,
        soil_improvement_rate: 0.02,
        
        # Simulation properties
        preferred_biome: 'Grassland',
        size_modifier: 0.000001,
        reproduction_rate: 1.3,
        mortality_rate: 1.0,
        health_modifier: 1.0,
        
        description: 'Converts atmospheric nitrogen to usable form, improves soil'
      )
    end
    
    def self.create_methane_producer(biosphere)
      Biology::LifeForm.create!(
        biosphere: biosphere,
        name: 'Methanogenic Archaea',
        complexity: :microbial,
        domain: :subterranean,
        population: 2_000_000_000,
        
        # Terraforming properties
        methane_production_rate: 0.05,      # Creates greenhouse gas
        co2_consumption_rate: 0.03,
        
        # Simulation properties
        preferred_biome: 'Wetland',
        size_modifier: 0.000001,
        reproduction_rate: 1.4,
        mortality_rate: 0.9,
        health_modifier: 1.0,
        
        description: 'Produces methane for greenhouse warming'
      )
    end
    
    def self.create_hardy_lichen(biosphere)
      Biology::LifeForm.create!(
        biosphere: biosphere,
        name: 'Extremophile Lichen',
        complexity: :simple,
        domain: :terrestrial,
        population: 100_000_000,
        
        # Terraforming properties
        oxygen_production_rate: 0.05,
        co2_consumption_rate: 0.06,
        soil_improvement_rate: 0.015,
        
        # Simulation properties
        preferred_biome: 'Tundra',
        size_modifier: 0.0001,
        reproduction_rate: 1.1,
        mortality_rate: 0.8,
        health_modifier: 1.0,
        
        description: 'Hardy organism that can colonize bare rock'
      )
    end
    
    # NEW: Create an engineered super-organism
    def self.create_engineered_terraformer(biosphere, template_name: 'super_algae')
      case template_name
      when 'super_algae'
        Biology::HybridLifeForm.create!(
          biosphere: biosphere,
          name: 'Engineered Super-Algae',
          complexity: :simple,
          domain: :aquatic,
          population: 50_000_000,
          
          # Boosted terraforming properties
          oxygen_production_rate: 0.5,      # 5x normal
          co2_consumption_rate: 0.7,
          
          # Engineered traits
          engineered_traits: ['rapid_photosynthesis', 'high_yield'],
          creator_species: 'Human',
          
          # Simulation properties
          preferred_biome: 'Ocean',
          size_modifier: 0.00001,
          reproduction_rate: 1.6,
          mortality_rate: 1.2,              # Less stable
          health_modifier: 1.0,
          
          description: 'Genetically engineered for rapid oxygen production'
        )
      end
    end
  end
end

# ------------------------------------------------------------------------------
# STEP 5: Add convenience methods to Biosphere model
# ------------------------------------------------------------------------------

module CelestialBodies
  module Spheres
    class Biosphere < ApplicationRecord
      # ... all your existing code stays ...
      
      # NEW: Deploy a terraforming organism
      def deploy_terraforming_organism(organism_type)
        case organism_type
        when :cyanobacteria
          Biology::TerraformingLibrary.create_cyanobacteria(self)
        when :nitrogen_fixer
          Biology::TerraformingLibrary.create_nitrogen_fixer(self)
        when :methane_producer
          Biology::TerraformingLibrary.create_methane_producer(self)
        when :hardy_lichen
          Biology::TerraformingLibrary.create_hardy_lichen(self)
        when :super_algae
          Biology::TerraformingLibrary.create_engineered_terraformer(self)
        end
      end
      
      # NEW: Get current terraforming rates
      def current_terraforming_rates
        rates = {
          o2_production: 0.0,
          co2_consumption: 0.0,
          ch4_production: 0.0,
          n2_fixation: 0.0
        }
        
        life_forms.each do |lf|
          contribution = lf.atmospheric_contribution
          rates[:o2_production] += contribution[:o2]
          rates[:co2_consumption] += contribution[:co2]
          rates[:ch4_production] += contribution[:ch4]
          rates[:n2_fixation] += contribution[:n2]
        end
        
        rates
      end
      
      # NEW: Summary for UI/AI
      def terraforming_summary
        rates = current_terraforming_rates
        
        {
          active_species: life_forms.count,
          total_biomass: life_forms.sum(:population),
          o2_production_kg_per_day: rates[:o2_production].round(4),
          co2_consumption_kg_per_day: rates[:co2_consumption].round(4),
          estimated_days_to_breathable: estimate_days_to_breathable_atmosphere
        }
      end
      
      private
      
      def estimate_days_to_breathable_atmosphere
        return Float::INFINITY unless celestial_body.atmosphere
        
        current_o2 = celestial_body.atmosphere.o2_percentage
        target_o2 = 15.0 # Minimum breathable
        
        return 0 if current_o2 >= target_o2
        
        o2_needed = target_o2 - current_o2
        daily_rate = current_terraforming_rates[:o2_production]
        
        return Float::INFINITY if daily_rate <= 0
        
        (o2_needed / daily_rate).ceil
      end
    end
  end
end

# ------------------------------------------------------------------------------
# USAGE EXAMPLES
# ------------------------------------------------------------------------------

# Example 1: Deploy organisms for terraforming
# planet = CelestialBodies::Planet.find(1)
# biosphere = planet.biosphere
# 
# # Deploy oxygen producers
# biosphere.deploy_terraforming_organism(:cyanobacteria)
# 
# # Deploy soil builders
# biosphere.deploy_terraforming_organism(:nitrogen_fixer)
# 
# # Check what's happening
# summary = biosphere.terraforming_summary
# puts "O2 production: #{summary[:o2_production_kg_per_day]} kg/day"
# puts "Days to breathable: #{summary[:estimated_days_to_breathable]}"

# Example 2: Let the simulation run
# # In your game loop, when time advances:
# game.advance_by_days(100)
# 
# # The BiosphereSimulationService will:
# # 1. Calculate life form populations (existing code)
# # 2. Apply their terraforming effects to atmosphere (new code)
# # 3. Scale everything by time_skipped

# Example 3: Create a hybrid organism
# cyano = biosphere.life_forms.find_by(name: 'Cyanobacteria')
# lichen = biosphere.life_forms.find_by(name: 'Extremophile Lichen')
# 
# hybrid = Biology::HybridLifeForm.create_from_parents(
#   cyano,
#   lichen,
#   name: "Cold-Tolerant Oxygen Producer",
#   creator_species: "Human Terraformers"
# )
# 
# hybrid.update(biosphere: biosphere, population: 10_000_000)