module CelestialBodies
  module Spheres
    class Biosphere < ApplicationRecord
      include MaterialTransferable
      include BiosphereConcern
      
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :materials, as: :materializable, dependent: :destroy
      has_many :planet_biomes, dependent: :destroy
      has_many :biomes, through: :planet_biomes
      has_many :alien_life_forms, class_name: 'CelestialBodies::AlienLifeForm', dependent: :destroy
      
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
        
        # Create a new alien life form
        life_form = CelestialBodies::AlienLifeForm.create!(
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
      
      # Add to Biosphere model
      def update_soil_health(new_health)
        self.soil_health = new_health
        save!
      end
      
      # Update the tropical_temperature method to use temperature_data directly 
      def tropical_temperature
        if celestial_body&.atmosphere
          # Use temperature_data directly instead of tropic_temp
          temp_data = celestial_body.atmosphere.temperature_data
          return temp_data['tropical_temperature'] if temp_data && temp_data['tropical_temperature'].present?
        end
        300.0  # Default value
      end
      
      def polar_temperature
        atmo = celestial_body&.atmosphere
        if atmo && atmo.respond_to?(:temperature_data) && 
           atmo.temperature_data && atmo.temperature_data['polar_temperature'].present?
          atmo.temperature_data['polar_temperature']
        else
          # Default value instead of trying to call a non-existent method
          250.0
        end
      end
      
      # Temperature setter methods
      def set_tropical_temperature(value)
        atmo = celestial_body&.atmosphere
        if atmo && atmo.respond_to?(:temperature_data)
          temp_data = atmo.temperature_data || {}
          temp_data['tropical_temperature'] = value
          atmo.update(temperature_data: temp_data)
        elsif respond_to?(:temperature_tropical=) # For backward compatibility
          self.temperature_tropical = value
        end
      end
      
      def set_polar_temperature(value)
        atmo = celestial_body&.atmosphere
        if atmo && atmo.respond_to?(:temperature_data)
          temp_data = atmo.temperature_data || {}
          temp_data['polar_temperature'] = value
          atmo.update(temperature_data: temp_data)
        elsif respond_to?(:temperature_polar=) # For backward compatibility
          self.temperature_polar = value
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

      def validate_temperature_data
        # Guard clause to prevent calling methods on nil
        return unless celestial_body.present?
        return unless celestial_body.atmosphere.present?
        
        temp_data = celestial_body.atmosphere.temperature_data || {}
        if temp_data['tropical_temperature'].blank? || temp_data['polar_temperature'].blank?
          # Initialize temperatures if missing
          initialize_atmosphere_temperature
        end
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
        
        # If we need to initialize the atmosphere's temperature values,
        # we should do that through the Atmosphere model
        initialize_atmosphere_temperature if should_initialize_atmosphere?
        
        # Log for debugging
        Rails.logger.debug "set_defaults called for biosphere"
      end

      # Helper method to initialize atmosphere temperature if needed
      def initialize_atmosphere_temperature
        return unless celestial_body&.atmosphere
        
        atmo = celestial_body.atmosphere
        temp_data = atmo.temperature_data || {}
        
        # Only set if not already set
        if !temp_data['tropical_temperature'].present?
          temp_data['tropical_temperature'] = 300.0
        end
        
        if !temp_data['polar_temperature'].present?
          temp_data['polar_temperature'] = 250.0
        end
        
        atmo.update(temperature_data: temp_data)
      end

      # Determine if we should initialize atmosphere
      def should_initialize_atmosphere?
        # Only initialize if we have a celestial body and atmosphere
        # AND we're creating a new record (not loading from DB)
        celestial_body.present? && 
        celestial_body.atmosphere.present? && 
        new_record?
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