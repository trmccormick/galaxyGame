# app/models/celestial_bodies/materials/gas.rb
module CelestialBodies
  module Materials
    # The issue is that when we inherit from ::Gas, we're inheriting its association
    # which expects the top-level Atmosphere class
    class Gas < ApplicationRecord
      # Define our own association instead of inheriting from ::Gas
      self.table_name = 'gases'
      
      # Use foreign_key to explicitly specify the column name
      belongs_to :atmosphere, 
                 class_name: 'CelestialBodies::Spheres::Atmosphere',
                 foreign_key: 'atmosphere_id'
      
      # Copy the needed validations and methods
      validates :name, presence: true
      validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
      validates :ppm, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :mass, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :molar_mass, numericality: { greater_than_or_equal_to: 0 }, presence: true
      
      before_validation :set_molar_mass_from_material
      
      # Calculate moles of gas based on the material's amount and molar mass
      def moles(amount)
        return 0 unless amount && molar_mass
        (amount / molar_mass).to_f
      end
      
      private
      
      def set_molar_mass_from_material
        if molar_mass.blank? || molar_mass == 0
          material = Lookup::MaterialLookupService.new.find_material(name)
          # Try both locations for molar_mass to be flexible
          self.molar_mass = material['molar_mass'] || material.dig('properties', 'molar_mass') if material
        end
      end

      # Determine the state of the gas based on the temperature and pressure
      def state(temperature, pressure)
        return 'unknown' unless material
        material.state_at(temperature, pressure)
      end
    end
  end
end