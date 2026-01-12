module Pressurization
  class UnitPressurizationService < BasePressurizationService
    def initialize(habitat_unit, available_gases = {}, options = {})
      @habitat_unit = habitat_unit
      volume = calculate_habitat_volume
      
      super(volume, available_gases, options)
    end
    
    # Calculate habitat volume based on the unit type
    def calculate_habitat_volume
      # Get volume from unit's operational data
      if @habitat_unit.operational_data&.dig('physical_properties', 'volume_m3')
        return @habitat_unit.operational_data['physical_properties']['volume_m3']
      end
      
      # Calculate from dimensions if available
      if @habitat_unit.operational_data&.dig('physical_properties', 'length_m') &&
         @habitat_unit.operational_data&.dig('physical_properties', 'width_m') &&
         @habitat_unit.operational_data&.dig('physical_properties', 'height_m')
         
        length = @habitat_unit.operational_data['physical_properties']['length_m']
        width = @habitat_unit.operational_data['physical_properties']['width_m']
        height = @habitat_unit.operational_data['physical_properties']['height_m']
        
        return length * width * height * 0.8 # 80% of total volume is habitable
      end
      
      # Default fallback based on unit type
      case @habitat_unit.unit_type
      when 'starship_habitat_unit'
        700.0 # As per the blueprint
      when 'habitat_unit'
        500.0 # Standard habitat unit
      when 'emergency_shelter'
        100.0 # Small emergency shelter
      else
        200.0 # Generic fallback
      end
    end
    
    # Check if the habitat unit can maintain pressure
    def verify_sealing
      # For habitat units, integrity is the key factor
      integrity = @habitat_unit.operational_data&.dig('integrity') || 
                  @habitat_unit.operational_data&.dig('specifications', 'integrity') || 0
                  
      return false if integrity < 85
      
      # Check that the unit is properly installed
      return false unless @habitat_unit.attachable.present?
      
      # Check that the unit has power (if it needs it)
      if @habitat_unit.operational_data&.dig('operational_properties', 'power_draw_kw')
        power_draw = @habitat_unit.operational_data['operational_properties']['power_draw_kw']
        return false if power_draw > 0 && !@habitat_unit.has_power?
      end
      
      true
    end
    
    # Override pressurize to update the habitat unit status
    def pressurize
      unless verify_sealing
        return {
          achieved_pressure: 0,
          used_gases: {},
          success: false,
          error: "Habitat unit is not properly sealed or installed"
        }
      end
      
      result = super
      
      # Update habitat unit status if successful
      if result[:success]
        # Initialize operational data if needed
        @habitat_unit.operational_data ||= {}
        @habitat_unit.operational_data['atmosphere'] = {
          'pressure' => result[:achieved_pressure],
          'breathable' => result[:human_breathable],
          'composition' => result[:used_gases].transform_keys(&:to_s),
          'last_updated' => Time.current.to_i
        }
        
        # Save the unit
        @habitat_unit.save
        
        # Log the successful pressurization
        Rails.logger.info("Habitat unit #{@habitat_unit.id} (#{@habitat_unit.name}) successfully pressurized to #{result[:achieved_pressure]} Pa")
      else
        Rails.logger.warn("Failed to pressurize habitat unit #{@habitat_unit.id} (#{@habitat_unit.name}): #{result[:error]}")
      end
      
      result
    end
    
    # Calculate the maximum number of people that can be supported
    def max_occupancy
      return 0 unless result[:human_breathable]
      
      # Get the designed capacity
      designed_capacity = @habitat_unit.operational_data&.dig('operational_properties', 'crew_capacity') || 
                          @habitat_unit.operational_data&.dig('capacity') || 0
      
      # Adjust based on pressure - lower pressure means fewer people
      pressure_ratio = [result[:achieved_pressure] / GameConstants::EARTH_PRESSURE, 1.0].min
      
      # Calculate adjusted capacity
      (designed_capacity * pressure_ratio).floor
    end
  end
end