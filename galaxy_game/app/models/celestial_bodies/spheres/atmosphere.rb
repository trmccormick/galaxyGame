# app/models/celestial_bodies/spheres/atmosphere.rb
module CelestialBodies
  module Spheres
    class Atmosphere < ApplicationRecord
      include AtmosphereConcern
      include MaterialTransferable
      
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :materials, as: :materializable, dependent: :destroy
      has_many :gases, class_name: 'CelestialBodies::Materials::Gas', dependent: :destroy
      
      # Use the new temperature_data field for temperature measurements
      store_accessor :temperature_data, :effective_temperature, 
                                       :greenhouse_temperature, 
                                       :polar_temperature, 
                                       :tropical_temperature
      
      # Existing code for composition and dust
      store :composition, accessors: [:gas_ratios]
      store :dust, accessors: [:concentration, :particle_size]

      validates :pressure, :temperature, presence: true
      validates :pressure, numericality: { greater_than_or_equal_to: 0 }
      validates :temperature, numericality: true
      validates :total_atmospheric_mass, numericality: { greater_than_or_equal_to: 0 }

      after_create :initialize_gases

      # Temperature-related methods - RESTORED FROM OLD3
      def set_effective_temp(temp)
        self.effective_temperature = temp
        save!
      end
      
      def set_greenhouse_temp(temp)
        self.greenhouse_temperature = temp
        # Also update the main temperature since greenhouse effect determines actual temperature
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
      
      # Temperature getters with reasonable defaults - RESTORED FROM OLD3
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
      
      # Gas percentage lookup method that checks multiple sources in order:
      # 1. First checks the actual Gas records in the database
      # 2. Then falls back to the composition hash
      # 3. Then checks gas_ratios from the store accessor
      # 4. Returns 0.0 if not found anywhere
      def gas_percentage(formula_or_name)
        # First try by name (most common case)
        gas = gases.find_by(name: formula_or_name)
        return gas.percentage if gas
        
        # Fallback to composition hash
        if composition.present?
          return composition[formula_or_name].to_f if composition[formula_or_name]
        end
        
        # Check in gas_ratios if it exists
        return gas_ratios[formula_or_name].to_f if gas_ratios.present? && gas_ratios[formula_or_name]
        
        # Default if not found anywhere
        0.0
      end

      # Convenience methods for common gases
      def o2_percentage
        gas_percentage('O2')
      end

      def co2_percentage
        gas_percentage('CO2')
      end

      def ch4_percentage
        gas_percentage('CH4')
      end

      # Add this public method to call the private one
      def recalculate_mass!
        update_total_atmospheric_mass
      end

      private

      def default_temperature
        celestial_body.surface_temperature
      end
    end
  end
end

