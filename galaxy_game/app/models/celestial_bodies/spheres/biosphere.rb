# app/models/celestial_bodies/spheres/biosphere.rb
module CelestialBodies
  module Spheres
    class Biosphere < ApplicationRecord
      include MaterialTransferable
      include BiosphereConcern
      
      # All temperatures in this model are stored and returned in Kelvin

      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :materials, as: :materializable, dependent: :destroy
      has_many :planet_biomes, class_name: 'CelestialBodies::PlanetBiome', dependent: :destroy
      has_many :biomes, through: :planet_biomes, class_name: 'Biome' # Explicit class_name for top-level Biome
      
      # Update association to use new Biology namespace
      has_many :life_forms, class_name: 'Biology::LifeForm', dependent: :destroy
      
      # Simulation control flag
      attr_accessor :simulation_running
      
      # JSONB field accessors - explicitly define as hash
      serialize :biome_distribution, Hash
      
      # Fix the store_accessor issue by using the correct syntax
      store :base_values, coder: JSON # First define the store
      # Then define accessors for the specific fields
      store_accessor :base_values, :base_temperature_tropical, :base_temperature_polar,
                     :base_biodiversity_index, :base_habitable_ratio, :base_biome_distribution
      
      # Add validations for temperature fields
      validate :validate_temperature_data
      validates :biodiversity_index, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
      validates :habitable_ratio, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
      
      after_initialize :set_defaults
      after_update :run_simulation, unless: :simulation_running

      # Reset biosphere to base values
      def reset
        return false unless base_values.present?
        
        # First reset atmosphere temperature if it exists
        reset_atmosphere_temperature
        
        # Then reset own attributes
        update(
          biodiversity_index: base_biodiversity_index || 0.0,
          habitable_ratio: base_habitable_ratio || 0.0,
          biome_distribution: base_biome_distribution || {}
        )
      end

      # Add a biome to the biosphere
      def introduce_biome(biome)
        return if biomes.include?(biome)

        # Create association
        planet_biomes.create!(biome: biome)
        
        # Update biome distribution - ensure it's a hash
        distribution = self.biome_distribution.is_a?(Hash) ? self.biome_distribution : {}
        distribution[biome.name] = { 'area_percentage' => 10.0 } # Default 10% coverage
        self.biome_distribution = distribution
        save!
      end
      
      # Remove a biome from the biosphere
      def remove_biome(biome)
        return unless biomes.include?(biome)
        
        # Remove association
        planet_biomes.find_by(biome: biome)&.destroy
        
        # Update biome distribution - ensure it's a hash
        distribution = self.biome_distribution.is_a?(Hash) ? self.biome_distribution : {}
        distribution.delete(biome.name)
        self.biome_distribution = distribution
        save!
      end

      # Calculate biodiversity based on biomes present
      def calculate_biodiversity_index
        return 0 if biomes.empty?
        
        # Simple biodiversity calculation based on biome counts
        biome_count = biomes.count
        max_possible_biomes = 10  # Theoretical maximum number of biomes
        
        # Biodiversity is a function of biome variety relative to maximum
        self.biodiversity_index = [biome_count.to_f / max_possible_biomes, 1.0].min
        save!
        
        biodiversity_index
      end
      
      # Calculate habitability ratio based on atmosphere and temperature
      def calculate_habitability
        atmo = celestial_body&.atmosphere
        return 0.0 unless atmo && atmo.gases.exists?
        
        # Check for earth-like conditions
        o2_level = atmo.gases.find_by(name: 'O2')&.percentage.to_f
        pressure = atmo.pressure.to_f
        temp = celestial_body.surface_temperature.to_f
        
        # Simple habitability formula
        temp_factor = temperature_habitability(temp)
        pressure_factor = pressure_habitability(pressure)
        o2_factor = oxygen_habitability(o2_level)
        
        # Weighted calculation
        self.habitable_ratio = (temp_factor * 0.4) + (pressure_factor * 0.3) + (o2_factor * 0.3)
        save!
        
        habitable_ratio
      end
      
      # Transfer material to another sphere
      def transfer_material(material_name, amount, target_sphere)
        material = materials.find_by(name: material_name)
        return false unless material && material.amount >= amount
      
        # Use the correct Material class for transaction
        begin
          CelestialBodies::Material.transaction do
            # Reduce source material amount
            material.update!(amount: material.amount - amount)
            
            # Find or create target material with proper attributes
            target_material = target_sphere.materials.find_or_initialize_by(name: material_name)
            
            # Important: Assign these values explicitly
            target_material.celestial_body = target_sphere.celestial_body
            target_material.materializable = target_sphere
            
            # Initialize or increment amount
            target_material.amount ||= 0
            target_material.amount += amount
            
            # Save the target material - this may raise an error if saving fails
            target_material.save!
          end
          true
        rescue StandardError => e
          # Log ALL errors, not just RecordInvalid
          Rails.logger.error "Error transferring material: #{e.message}"
          false
        end
      end
      
      # Discover life based on biodiversity index
      def discover_life
        return [] if biodiversity_index < 0.1
        
        # Probability of finding life increases with biodiversity
        discovery_chance = biodiversity_index * 0.5
        return [] if rand > discovery_chance
        
        # Create a new life form using the Biology namespace
        life_form = Biology::LifeForm.create!(
          biosphere: self,
          name: "Unknown Organism",
          complexity: :microbial,
          domain: :aquatic,
          population: rand(1000..1000000),
          properties: {
            description: "Newly discovered microbial organism",
            biochemistry: "Carbon-based",
            ecological_role: "Producer"
          }
        )
        
        [life_form]
      end
      
      # Add methods for ecological simulation with life forms
      
      # Calculate total biomass of all life forms
      def total_biomass
        life_forms.sum(&:total_biomass)
      end
      
      # Calculate biodiversity including life forms
      def expanded_biodiversity_index
        base_biodiversity = biodiversity_index || 0.0
        
        # ✅ More generous calculation to ensure it exceeds base
        life_form_count = life_forms.count
        
        if life_form_count > 0
          # Each life form adds 5% minimum
          life_form_bonus = life_form_count * 0.05
          
          # Complexity bonuses
          complexity_bonus = life_forms.sum do |life_form|
            case life_form.complexity&.downcase
            when 'simple' then 0.02
            when 'complex' then 0.05
            when 'intelligent' then 0.1
            else 0.01
            end
          end
          
          result = base_biodiversity + life_form_bonus + complexity_bonus
          [result, 1.0].min
        else
          base_biodiversity
        end
      end
      
      # Run life form simulation cycle
      def simulate_life_cycle
        return if life_forms.empty?
        
        # First calculate environment factors
        environment_factors = {
          temperature: temperature_habitability(celestial_body.surface_temperature.to_f),
          atmosphere: oxygen_habitability(celestial_body.atmosphere&.gases&.find_by(name: 'O2')&.percentage.to_f || 0),
          water: celestial_body.hydrosphere.present? ? celestial_body.hydrosphere.water_coverage : 0.0
        }
        
        # For each life form, simulate growth
        life_forms.find_each do |life_form|
          # Natural life forms adapt to environment
          if life_form.is_a?(Biology::LifeForm)
            life_form.adapt_to_environment(environment_factors)
          end
          
          # All life forms go through growth cycle
          life_form.simulate_growth(
            temperature: environment_factors[:temperature] * 300, # Convert to Kelvin-ish
            o2_percentage: environment_factors[:atmosphere] * 100, # Convert to percentage
            co2_percentage: 100 - (environment_factors[:atmosphere] * 100) # Assume rest is CO2
          )
        end
        
        # Check for new life emergence
        if rand < biodiversity_index * 0.05 # 5% chance per biodiversity point
          # Create a new life form that's derived from existing ones
          parent = life_forms.order('RANDOM()').first
          
          # Create an offspring with slightly different properties
          Biology::LifeForm.create!(
            biosphere: self,
            name: "#{parent.name} Variant",
            complexity: parent.complexity,
            domain: parent.domain,
            population: (parent.population * 0.1).to_i,
            properties: parent.properties.merge({
              'derived_from' => parent.name,
              'mutation_factor' => rand(0.1..0.3)
            })
          )
        end
      end
      
      # Add to Biosphere model
      def update_soil_health(new_health)
        self.soil_health = new_health
        save!
      end
      
      # CORRECTED: Simplified temperature getters for Biosphere
      # These now directly call the atmosphere's store_accessor generated methods.
      def tropical_temperature
        # Returns temperature in Kelvin
        celestial_body.atmosphere&.tropical_temperature || 300.0  # Default 300K
      end
      
      def polar_temperature
        # Returns temperature in Kelvin  
        celestial_body.atmosphere&.polar_temperature || 250.0  # Default 250K 
      end
      
      # Temperature setter methods (these are fine as they explicitly update atmosphere)
      def set_tropical_temperature(value)
        atmo = celestial_body&.atmosphere
        if atmo
          # Use the store_accessor setter directly on the atmosphere object
          atmo.tropical_temperature = value
          atmo.save! # Save the atmosphere to persist the change
        end
      end
      
      def set_polar_temperature(value)
        atmo = celestial_body&.atmosphere
        if atmo
          # Use the store_accessor setter directly on the atmosphere object
          atmo.polar_temperature = value
          atmo.save! # Save the atmosphere to persist the change
        end
      end
      
      # Update the biome-related methods to use the delegated temperature values
      def recalculate_biome_distribution
        # Use tropical_temperature and polar_temperature methods
        # instead of directly accessing temperature_tropical and temperature_polar
      end
      
      # Add vegetation_cover method
      def vegetation_cover
        attributes['vegetation_cover'] || 0.0
      end

      # CORRECTED: Removed the call to initialize_atmosphere_temperature
      def validate_temperature_data
        # This validation method can remain, but it should not initialize atmosphere data.
        # The atmosphere model itself should handle its own initialization.
        return unless celestial_body.present?
        return unless celestial_body.atmosphere.present?
        
        # No action needed here for temperature initialization.
        # If you want to ensure temperatures exist, you could add a validation
        # that checks for their presence, but not initialize them.
      end       
      
      # Add this method to your Biosphere class
      def update_vegetation_cover(value)
        update!(vegetation_cover: value)
      end
      
      private
      
      # Temperature habitability factor (0-1)
      def temperature_habitability(temp)
        return 0 if temp < 240 || temp > 320
        
        # Optimal temperature is 288-295K
        if temp.between?(288, 295)
          1.0  # Ideal temperature
        elsif temp.between?(270, 310)
          0.8  # Good temperature
        elsif temp.between?(250, 320)
          0.4  # Marginal temperature
        else
          0.1  # Poor temperature
        end
      end
      
      # Pressure habitability factor (0-1)
      def pressure_habitability(pressure)
        return 0 if pressure < 0.3 || pressure > 3.0
        
        # Optimal pressure is 0.7-1.3 atm
        if pressure.between?(0.7, 1.3)
          1.0  # Ideal pressure
        elsif pressure.between?(0.5, 2.0)
          0.7  # Good pressure
        else
          0.3  # Marginal pressure
        end
      end
      
      # Oxygen habitability factor (0-1)
      def oxygen_habitability(o2_level)
        return 0 if o2_level < 5 || o2_level > 35
        
        # Optimal oxygen is 15-25%
        if o2_level.between?(15, 25)
          1.0  # Ideal oxygen
        elsif o2_level.between?(10, 30)
          0.7  # Good oxygen
        else
          0.3  # Marginal oxygen
        end
      end
      
      # Update the set_defaults method to ALWAYS set 300.0 - not just when nil
      def set_defaults
        # Don't set temperature values directly anymore
        # Only initialize non-temperature attributes
        self.biome_distribution ||= {}
        self.biodiversity_index ||= 0.0
        self.habitable_ratio ||= 0.0
        
        # Log for debugging
        Rails.logger.debug "set_defaults called for biosphere"
      end
      
      def run_simulation
        # Prevent recursive updates
        self.simulation_running = true
        
        # Call ecological_cycle_tick from the concern
        ecological_cycle_tick if respond_to?(:ecological_cycle_tick)
        
        # Basic simulation steps
        calculate_biodiversity_index
        calculate_habitability
        
        self.simulation_running = false
      end

      def reset_atmosphere_temperature
        atmo = celestial_body&.atmosphere
        return unless atmo && atmo.respond_to?(:base_values)
        
        # Reset atmosphere temperature data from its base values
        base_temp_data = atmo.base_values['base_temperature_data']
        if base_temp_data.present?
          current_temp_data = atmo.temperature_data || {}
          
          # Update specific temperature fields
          current_temp_data['tropical_temperature'] = base_temp_data['tropical_temperature'] if base_temp_data['tropical_temperature']
          current_temp_data['polar_temperature'] = base_temp_data['polar_temperature'] if base_temp_data['polar_temperature']
          
          atmo.update(temperature_data: current_temp_data)
        end
      end
    end
  end
end