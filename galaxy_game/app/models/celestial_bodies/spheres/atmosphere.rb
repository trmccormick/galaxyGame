# This is for planetary/natural atmospheres
module CelestialBodies
  module Spheres
    class Atmosphere < ApplicationRecord
      include AtmosphereConcern
      include MaterialTransferable
      
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :materials, as: :materializable, dependent: :destroy
      has_many :gases, class_name: 'Gas', dependent: :destroy
      
      # store :composition, accessors: [:gas_ratios]
      store :dust, accessors: [:concentration, :particle_size]

      validates :pressure, :temperature, presence: true
      validates :pressure, numericality: { greater_than_or_equal_to: 0 }
      validates :temperature, numericality: true
      validates :total_atmospheric_mass, numericality: { greater_than_or_equal_to: 0 }

      after_create :initialize_gases

      # This is the key method that converts composition to actual Gas records
      def initialize_gases
        return unless composition.present?
        
        # Delete existing gases to avoid duplicates
        gases.destroy_all
        
        # Calculate the total atmospheric mass
        total_mass = total_atmospheric_mass || 0
        
        # Create gases
        composition.each do |name, percentage|
          # Skip if percentage is zero
          next if percentage.to_f <= 0
          
          # Get molar mass using lookup service
          lookup_service = Lookup::MaterialLookupService.new
          material_data = lookup_service.find_material(name)
          molar_mass = material_data&.dig('properties', 'molar_mass') || 29.0 # Default molar mass
          
          # Calculate mass based on percentage
          mass = (percentage.to_f / 100) * total_mass
          
          # Create the gas record with molar_mass included
          gas = gases.create!(
            name: name,
            percentage: percentage.to_f,
            mass: mass,
            molar_mass: molar_mass  # Add this line - this was missing!
          )
          
          # Create Material record (handled by Gas model after_create)
          # This ensures each Gas has a corresponding Material
        end
        
        # Return true if gases were created
        gases.any?
      end

      def transfer_material(material_name, amount, target_sphere)
        gas = gases.find_by(name: material_name)

        Rails.logger.warn "[Atmosphere] Transfer failed: #{material_name} has insufficient mass (#{gas&.mass || 0})" if gas.nil? || gas.mass < amount
        
        return false unless gas && gas.mass >= amount

        Material.transaction do
          remove_gas(material_name, amount)
          
          target_sphere.materials.create!(
            name: material_name,
            amount: amount
          )
        end
      end

      def decrease_dust(amount)
        return unless dust.present?
        self.dust['concentration'] = [dust['concentration'].to_f - amount, 0.0].max
        save!
      end

      def formatted_pressure
        GameFormatters::AtmosphericData.format_pressure(pressure)
      end

      def formatted_mass
        GameFormatters::AtmosphericData.format_mass(total_atmospheric_mass)
      end

      private

      def default_temperature
        celestial_body.surface_temperature
      end     
    end
  end
end

