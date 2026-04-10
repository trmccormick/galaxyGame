# app/models/structures/converted_base.rb
module Structures
  class ConvertedBase < Worldhouse
    # ============================================
    # ASSOCIATIONS & REUSE
    # ============================================
    
    # Polymorphic link allows anchoring to an Asteroid or a SmallMoon.
    # The 'celestial_body_id' and 'celestial_body_type' are the keys here.
    belongs_to :host_body, polymorphic: true, foreign_key: 'celestial_body_id'

    # REUSE: Physical concerns matched to BaseCraft logic
    # Ensures this stationary base behaves like a ship regarding life and power.
    include HasUnits               
    # include Housing                # Calculates population capacity from installed units
    include AtmosphericProcessing  # Simulates O2/CO2 and Pressure within the cavity
    include EnergyManagement       # Manages the local grid (Solar/Nuclear/Battery)

    # ============================================
    # SOURCING LOGIC (The "Market vs. Build" Core)
    # ============================================
    
    def construction_materials
      # Leverages the composition_type of the host body (Asteroid or SmallMoon).
      # This dictates the local economy and material "Loss Rates".
      case host_body.composition_type
      when :carbonaceous
        { local: [:carbon, :silicates], multiplier: 1.2 } 
      when :metallic
        { local: [:iron, :nickel, :rare_earths], multiplier: 2.5 } 
      when :silicaceous
        { local: [:silica, :oxygen], multiplier: 1.5 } 
      else
        # Default regolith-based construction
        { local: [:regolith], multiplier: 1.0 }
      end
    end

    # ============================================
    # PHYSICAL PROPERTIES & STRESS
    # ============================================

    def shielding_rating
      # Natural shielding based on the host body's mass and type.
      # Metallic hosts provide superior radiation protection via density.
      return 0 unless host_body.respond_to?(:estimated_mineral_value) && host_body.estimated_mineral_value.present?
      
      # Matches the scaling defined in the original AsteroidBase logic
      host_body.estimated_mineral_value / 1_000_000 
    end

    def rotation_stress_factor
      # Dynamic check against the host body's physics.
      # High rotation speed (short period) increases structural maintenance costs.
      return 1.0 unless host_body.respond_to?(:typical_rotation_period)
      
      period_hours = host_body.typical_rotation_period * 24.0
      case period_hours
      when 0..2  then 2.5 # Critical centrifugal stress
      when 2..8  then 1.2 # Elevated stress
      else 1.0            # Stable/Optimal
      end
    end

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

    # ============================================
    # ENVIRONMENTAL SYNC
    # ============================================

    def local_resource_tags
      # Used by the generator/AI to identify what can be built on-site.
      host_body.respond_to?(:resource_tags) ? host_body.resource_tags : []
    end

    def needs_atmosphere?
      # Inherited from BaseCraft logic: Checks if human-rated or has life support.
      super
    end
  end
end