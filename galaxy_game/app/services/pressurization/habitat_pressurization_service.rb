module Pressurization
  class HabitatPressurizationService < BasePressurizationService
    def initialize(habitat, available_gases = {}, options = {})
      @habitat = habitat
      volume = calculate_habitat_volume
      
      super(volume, available_gases, options)
    end
    
    # Calculate habitat volume based on its dimensions
    def calculate_habitat_volume
      case @habitat
      when Structures::CraterDome
        # πr²h/2 (hemisphere) - using diameter/2 for radius
        Math::PI * ((@habitat.diameter / 2.0) ** 2) * @habitat.depth / 2.0
      when Structures::Dome
        # For future-proofing when domes become structures
        Math::PI * ((@habitat.diameter / 2.0) ** 2) * @habitat.height / 2.0
      when Structures::HabitationModule
        # Length × Width × Height
        @habitat.length * @habitat.width * @habitat.height
      when CelestialBodies::Features::LavaTube
        # πr²l (cylinder) - using width/2 as radius
        Math::PI * ((@habitat.width_m / 2.0) ** 2) * @habitat.length_m
      when Craft::BaseCraft
        # Use craft's interior volume if defined, otherwise calculate from dimensions
        @habitat.respond_to?(:interior_volume) ? @habitat.interior_volume : calculate_craft_volume
      else
        # Default calculation or raise error
        raise ArgumentError, "Unsupported habitat type: #{@habitat.class}"
      end
    end
    
    # Calculate estimated craft volume from dimensions if interior_volume not available
    def calculate_craft_volume
      return @habitat.operational_data['specifications']['interior_volume'] if @habitat.operational_data&.dig('specifications', 'interior_volume')
      
      # Basic calculation if we have dimensions
      if @habitat.operational_data&.dig('specifications', 'length') && 
         @habitat.operational_data&.dig('specifications', 'width') && 
         @habitat.operational_data&.dig('specifications', 'height')
        
        length = @habitat.operational_data['specifications']['length']
        width = @habitat.operational_data['specifications']['width']
        height = @habitat.operational_data['specifications']['height']
        
        # Apply a utilization factor (not all space is usable)
        length * width * height * 0.7
      else
        # Fallback for unknown craft types
        50.0 # Default 50 cubic meters
      end
    end
    
    # Check if the habitat is properly sealed
    def verify_sealing
      case @habitat
      when Settlement::CraterDome
        @habitat.respond_to?(:integrity) && @habitat.integrity >= 95
      when Structures::Dome
        @habitat.integrity >= 95
      when Structures::HabitationModule
        @habitat.respond_to?(:airlocks) && 
        @habitat.airlocks.all?(&:functional?) && 
        @habitat.integrity >= 90
      when CelestialBodies::Features::LavaTube
        @habitat.respond_to?(:sealed) && 
        @habitat.sealed && 
        @habitat.integrity >= 85
      when Craft::BaseCraft
        # Check for hull integrity or similar property
        hull_integrity = @habitat.operational_data&.dig('specifications', 'hull_integrity') || 
                         @habitat.respond_to?(:hull_integrity) && @habitat.hull_integrity
        
        hull_integrity && hull_integrity >= 95
      else
        false
      end
    end
    
    # Override pressurize to check sealing first
    def pressurize
      unless verify_sealing
        return {
          achieved_pressure: 0,
          used_gases: {},
          success: false,
          error: "Habitat is not properly sealed"
        }
      end
      
      result = super
      
      # If successful, update the habitat's atmosphere status if it has that property
      if result[:success] && @habitat.respond_to?(:atmosphere_status)
        @habitat.atmosphere_status = {
          pressure: result[:achieved_pressure],
          breathable: result[:human_breathable],
          last_checked: Time.current
        }
        @habitat.save
      end
      
      result
    end
  end
end