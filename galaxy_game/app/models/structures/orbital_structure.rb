# app/models/structures/orbital_structure.rb
module Structures
  class OrbitalStructure < BaseStructure
    # ============================================
    # INCLUDES (Matched to BaseCraft)
    # ============================================
    include Structures::Shell
    include HasUnits               # Essential for housing units
    # Removed: include Housing
    include EnergyManagement
    include AtmosphericProcessing
    include Docking
    include SpinGravity   # ← add this line

    # Override BaseStructure settlement association — orbital structures
    # belong to OrbitalSettlement, not BaseSettlement
    belongs_to :settlement, class_name: 'Settlement::OrbitalSettlement', optional: true

    # ============================================
    # PHYSICAL PRESENCE
    # ============================================
    has_one :celestial_location, as: :locationable, class_name: 'Location::CelestialLocation', dependent: :destroy
    has_one :atmosphere, foreign_key: :structure_id, dependent: :destroy

    # ============================================
    # DATA & METHODS
    # ============================================
    # materials/mass are still blueprint-level (the shell), 
    # but population is now unit-level.
    delegate :materials, to: :blueprint
    delegate :celestial_body, to: :celestial_location, allow_nil: true

    after_create :initialize_atmosphere_if_needed

    def total_storage_capacity
      base_units.where(unit_type: 'storage').sum { |u| u.operational_data.dig('storage', 'capacity').to_f }
    end

    # Replaced habitat_capacity with explicit logic
    def habitat_capacity
      base_units.sum do |unit|
        capacity_data = unit.operational_data&.dig('capacity')
        if capacity_data.is_a?(Hash)
          capacity_data['passenger_capacity'] || capacity_data['capacity'] || 0
        else
          capacity_data&.to_i || 0
        end
      end
    end

    # Methods copied from BaseCraft for atmosphere logic
    def needs_atmosphere?
      return true if operational_data&.dig('operational_flags', 'human_rated') == true
      if operational_data&.dig('recommended_units').is_a?(Array)
        life_support_unit_ids = ['starship_habitat_unit', 'waste_management_unit',
          'co2_oxygen_production_unit', 'water_recycling_unit', 'life_support_unit', 'habitat']
        operational_data['recommended_units'].each do |unit|
          unit_id = unit['id'].to_s.downcase
          return true if life_support_unit_ids.any? { |ls| unit_id.include?(ls) }
        end
      end
      if persisted? && base_units.any?
        life_support_unit_types = ['habitat', 'starship_habitat', 'life_support',
          'co2_oxygen_production', 'waste_management', 'water_recycling']
        return true if base_units.any? do |unit|
          life_support_unit_types.any? { |ls| unit.unit_type.to_s.downcase.include?(ls) }
        end
      end
      false
    end

    def get_construction_atmosphere_data
      if docked_at&.respond_to?(:atmosphere) && docked_at.atmosphere
        factory_atm = docked_at.atmosphere
        { temperature: factory_atm.temperature, pressure: factory_atm.pressure,
          composition: factory_atm.composition || default_atmosphere_composition,
          source: 'factory_inheritance' }
      elsif celestial_location&.respond_to?(:atmosphere)
        celestial_atm = celestial_location.atmosphere
        { temperature: celestial_atm.temperature || 293.15,
          pressure: celestial_atm.pressure || 101.325,
          composition: celestial_atm.composition || default_atmosphere_composition,
          source: 'planetary_inheritance' }
      else
        { temperature: 293.15, pressure: 101.325,
          composition: default_atmosphere_composition,
          source: 'default_factory' }
      end
    end

    def default_atmosphere_composition
      { "N2" => 78.0, "O2" => 21.0, "Ar" => 0.9, "CO2" => 0.04 }
    end

    def total_mass
      (blueprint&.dig('physical_properties', 'empty_mass') || 0) + 
      inventory.total_weight + 
      (atmosphere&.total_atmospheric_mass || 0)
    end

    private

    def blueprint
      @blueprint ||= Lookup::BlueprintLookupService.find(self.identifier)
    end

    def initialize_atmosphere_if_needed
      # needs_atmosphere? (from BaseCraft) checks if any 
      # life-support or habitat units are installed.
      return if atmosphere.present? || !needs_atmosphere?
      
      inherited_atmosphere = get_construction_atmosphere_data
      create_atmosphere!(
        environment_type: 'artificial',
        temperature: inherited_atmosphere[:temperature],
        pressure: inherited_atmosphere[:pressure],
        composition: inherited_atmosphere[:composition],
        sealing_status: true
      )
    end
  end
end