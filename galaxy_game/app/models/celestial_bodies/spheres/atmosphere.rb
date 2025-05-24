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
          return 0.029 if total_mass <= 0 # Earth default
          
          material_service = Lookup::MaterialLookupService.new
          
          weighted_sum = gases.sum do |gas|
            next 0 if gas.mass.to_f <= 0
            
            mass_fraction = gas.mass.to_f / total_mass
            
            if gas.molar_mass.to_f > 0
              molar_mass = gas.molar_mass.to_f / 1000.0 # Convert to kg/mol
            else
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
        
        0.029 # kg/mol for Earth's air
      end
      
      def scale_height
        # Scale height H = R*T/(M*g)
        gravity = celestial_body.respond_to?(:gravity) ? celestial_body.gravity : 9.8 # m/s²
        molar_mass = calculate_average_molar_mass
        r_universal = GameConstants::IDEAL_GAS_CONSTANT
        
        (r_universal * temperature.to_f) / (molar_mass * gravity) / 1000.0
      end
      
      private

      def default_temperature
        celestial_body.surface_temperature
      end
    end
  end
end

