# app/models/celestial_bodies/spheres/atmosphere.rb
module CelestialBodies
  module Spheres
    class Atmosphere < ApplicationRecord
      include AtmosphereConcern
      include MaterialTransferable
      
      # Associations
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :materials, as: :materializable, dependent: :destroy
      has_many :gases, class_name: 'CelestialBodies::Materials::Gas', dependent: :destroy
      
      # Stored attributes
      store_accessor :temperature_data, :effective_temperature, 
                                       :greenhouse_temperature, 
                                       :polar_temperature, 
                                       :tropical_temperature
      
      store :composition, accessors: [:gas_ratios]
      store :dust, accessors: [:concentration, :particle_size]

      # Validations
      validates :pressure, :temperature, presence: true
      validates :pressure, numericality: { greater_than_or_equal_to: 0 }
      validates :temperature, numericality: true
      validates :total_atmospheric_mass, numericality: { greater_than_or_equal_to: 0 }

      # Callbacks
      after_create :initialize_gases

      # The reset method is now provided by AtmosphereConcern for DRYness and consistency.

      #---------------------------------------------------------------------------
      # Temperature Management Methods
      #---------------------------------------------------------------------------
      def set_effective_temp(temp)
        self.effective_temperature = temp
        save!
      end
      
      def set_greenhouse_temp(temp)
        self.greenhouse_temperature = temp
        self.temperature = temp
        save!
      end
      
      def set_polar_temp(temp)
        self.polar_temperature = temp
        save!
      end
      
      def set_tropic_temp(temp)
        self.tropical_temperature = temp
        save!
      end
      
      def effective_temp
        effective_temperature || temperature
      end
      
      def greenhouse_temp
        greenhouse_temperature || temperature
      end
      
      def polar_temp
        polar_temperature || (temperature - 40)
      end
      
      def tropic_temp
        tropical_temperature || (temperature + 10)
      end
      
      #---------------------------------------------------------------------------
      # Mass Management Methods
      #---------------------------------------------------------------------------
      def recalculate_mass!
        update_total_atmospheric_mass
      end

      #---------------------------------------------------------------------------
      # Atmospheric Physical Properties
      #---------------------------------------------------------------------------
      def density
        return 0.0 if pressure.to_f <= 0 || temperature.to_f <= 0
        
        pressure_pa = pressure.to_f * 100000.0 # Convert bars to Pascals
        r_specific = calculate_gas_constant
        
        pressure_pa / (r_specific * temperature.to_f)
      end
      
      def calculate_gas_constant
        if gases.any?
          total_mass = gases.sum(:mass)
          return GameConstants::EARTH_ATMOSPHERE[:average_gas_constant] if total_mass <= 0
          
          material_service = Lookup::MaterialLookupService.new
          weighted_sum = gases.sum do |gas|
            next 0 if gas.mass.to_f <= 0
            
            mass_fraction = gas.mass.to_f / total_mass
            # Always use chemical formula for lookup
            material_data = material_service.find_material(gas.name)
            
            if material_data && material_data['properties'] && material_data['properties']['specific_gas_constant']
              gas_constant = material_data['properties']['specific_gas_constant']
            elsif material_data && material_data['properties'] && material_data['properties']['molar_mass']
              molar_mass = material_data['properties']['molar_mass'].to_f / 1000.0
              gas_constant = GameConstants::IDEAL_GAS_CONSTANT / molar_mass
            elsif gas.molar_mass.to_f > 0
              gas_constant = GameConstants::IDEAL_GAS_CONSTANT / (gas.molar_mass.to_f / 1000.0)
            else
              gas_constant = GameConstants::EARTH_ATMOSPHERE[:average_gas_constant]
            end
            
            mass_fraction * gas_constant
          end
          
          return weighted_sum
        end
        
        GameConstants::EARTH_ATMOSPHERE[:average_gas_constant]
      end
      
      def calculate_average_molar_mass
        if gases.any?
          total_mass = gases.sum(:mass)
          return estimate_molar_mass(composition || {}) if total_mass <= 0
          
          material_service = Lookup::MaterialLookupService.new
          
          weighted_sum = gases.sum do |gas|
            next 0 if gas.mass.to_f <= 0
            
            mass_fraction = gas.mass.to_f / total_mass
            
            if gas.molar_mass.to_f > 0
              molar_mass = gas.molar_mass.to_f / 1000.0 # Convert to kg/mol
            else
              # Always use chemical formula for lookup
              material_data = material_service.find_material(gas.name)
              if material_data && material_data['properties'] && material_data['properties']['molar_mass']
                molar_mass = material_data['properties']['molar_mass'].to_f / 1000.0
              else
                molar_mass = 0.029 # Default for Earth air
              end
            end
            
            mass_fraction * molar_mass
          end
          
          return weighted_sum
        end
        
        # Always fall back to composition-based calculation
        estimate_molar_mass(composition || {})
      end
      
      def scale_height
        # Scale height H = R*T/(M*g)
        gravity = celestial_body.respond_to?(:gravity) ? celestial_body.gravity : 9.8 # m/s²
        molar_mass = calculate_average_molar_mass
        r_universal = GameConstants::IDEAL_GAS_CONSTANT

        return nil if temperature.nil? || molar_mass.nil? || gravity.nil? || molar_mass == 0.0 || gravity == 0.0

        (r_universal * temperature.to_f) / (molar_mass * gravity) / 1000.0
      end

      # ✅ ADD: Override for planetary atmospheres (they don't have containers)
      def get_celestial_atmosphere_data
        # For planetary atmospheres, they ARE the celestial atmosphere data
        {
          temperature: temperature || 273.15,
          pressure: pressure || 0.0,
          composition: composition || {}
        }
      end

      # ✅ ADD: Planetary atmospheres are never "sealed" (they're natural)
      def sealed?
        false # Planetary atmospheres are never artificially sealed
      end      
      
      def habitable?
        # Planetary atmospheres don't need to be "sealed" - they're natural
        return false if pressure < 60.0   # Minimum pressure for human survival (kPa)  
        return false if o2_percentage < 16.0
        return false if co2_percentage > 0.5
        return false if temperature < 273.15 || temperature > 313.15  # 0°C to 40°C
        true
      end

      private

      def default_temperature
        celestial_body.surface_temperature
      end

      # Add a callback that runs after gas changes
      after_save :update_celestial_body_material_tracking, if: :total_atmospheric_mass_changed?
      
      # Only update material tracking for celestial body atmospheres
      def update_celestial_body_material_tracking
        return unless celestial_body.present?
        
        # Trigger material validation at celestial body level
        if celestial_body.respond_to?(:validate_mass_conservation)
          celestial_body.validate_mass_conservation
        end
      end
    end
  end
end

