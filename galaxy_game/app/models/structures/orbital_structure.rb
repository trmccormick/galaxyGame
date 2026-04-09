# app/models/structures/orbital_structure.rb
module Structures
  class OrbitalStructure < BaseStructure
    # ============================================
    # INCLUDES (Matched to BaseCraft)
    # ============================================
    include Structures::Shell
    include HasUnits               # Essential for housing units
    include Housing                # Handles the population/crew math
    include EnergyManagement
    include AtmosphericProcessing
    include Docking
  include SpinGravity   # ← add this line

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

    # This overrides the 'random number' and uses your Housing concern logic
    def habitat_capacity
      # Housing concern provides the methods to sum capacity from 'habitat' units
      current_housing_capacity 
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