module Pressurization
  class CraftPressurizationService < BasePressurizationService
    def initialize(craft, available_gases = {}, options = {})
      @craft = craft
      volume = calculate_craft_volume
      
      super(volume, available_gases, options)
    end
    
    # Calculate the habitable volume of the craft
    def calculate_craft_volume
      # First check if the craft has interior volume in operational_data
      if @craft.operational_data&.dig('specifications', 'interior_volume')
        return @craft.operational_data['specifications']['interior_volume']
      end
      
      # Second, check if we have dimensions in operational_data
      if @craft.operational_data&.dig('specifications', 'length') && 
         @craft.operational_data&.dig('specifications', 'width') && 
         @craft.operational_data&.dig('specifications', 'height')
         
        length = @craft.operational_data['specifications']['length']
        width = @craft.operational_data['specifications']['width']
        height = @craft.operational_data['specifications']['height']
        
        # Apply a utilization factor (not all space is habitable)
        return length * width * height * 0.7
      end
      
      # Third, calculate based on habitat units
      habitable_volume = @craft.base_units
                               .where("unit_type LIKE ?", "%habitat%")
                               .sum do |unit|
        # Get volume from unit's operational data
        unit.operational_data&.dig('physical_properties', 'volume_m3') || 0
      end
      
      # Return calculated volume or default
      habitable_volume > 0 ? habitable_volume : default_volume_for_craft_type
    end
    
    # Provide sensible defaults based on craft type
    def default_volume_for_craft_type
      case @craft.craft_type&.downcase
      when 'spacecraft', 'spaceship'
        200.0 # 200 cubic meters
      when 'rover'
        15.0  # 15 cubic meters
      when 'harvester'
        35.0  # 35 cubic meters
      else
        50.0  # Default fallback
      end
    end
    
    # Check if the craft is properly sealed and can hold pressure
    def verify_sealing
      # Check for hull integrity
      hull_integrity = @craft.operational_data&.dig('specifications', 'hull_integrity') || 0
      return false if hull_integrity < 90
      
      # Check that all hatches/airlocks are closed
      airlocks_sealed = @craft.base_units
                              .where(unit_type: 'airlock')
                              .all? { |unit| unit.operational_data&.dig('status') == 'sealed' }
      return false unless airlocks_sealed
      
      # Check for minimum life support units
      has_life_support = @craft.base_units
                                .where(unit_type: 'life_support')
                                .any?
      return false unless has_life_support
      
      # Check for oxygen generation or storage
      has_oxygen = @craft.base_units
                         .any? { |unit| unit.unit_type.include?('oxygen') || unit.unit_type == 'lox_tank' }
      return false unless has_oxygen
      
      true
    end
    
    # Override pressurize to include craft-specific behavior
    def pressurize
      unless verify_sealing
        return {
          achieved_pressure: 0,
          used_gases: {},
          success: false,
          error: "Craft is not properly sealed for pressurization"
        }
      end
      
      result = super
      
      # Update craft's atmosphere status if successful
      if result[:success]
        # Store pressure results in operational data
        @craft.operational_data ||= {}
        @craft.operational_data['systems'] ||= {}
        @craft.operational_data['systems']['life_support'] ||= {}
        @craft.operational_data['systems']['life_support']['atmosphere'] = {
          pressure: result[:achieved_pressure],
          breathable: result[:human_breathable],
          composition: result[:used_gases].transform_keys(&:to_s),
          last_updated: Time.current.to_i
        }
        
        # Save the craft with the updated operational data
        @craft.save
        
        # Log the successful pressurization
        Rails.logger.info("Craft #{@craft.id} (#{@craft.name}) successfully pressurized to #{result[:achieved_pressure]} Pa")
      else
        Rails.logger.warn("Failed to pressurize craft #{@craft.id} (#{@craft.name}): #{result[:error]}")
      end
      
      result
    end
    
    # Calculate gas consumption rate for life support
    def calculate_daily_gas_consumption
      # Get crew count
      crew_count = @craft.current_population || 0
      return {} if crew_count == 0
      
      # Calculate daily oxygen consumption (kg per person per day)
      oxygen_per_person_day = GameConstants::HUMAN_LIFE_SUPPORT['oxygen_consumption_kg_per_day'] || 0.84
      
      # Calculate nitrogen loss due to leakage (0.1% per day is typical)
      nitrogen_leakage = (@volume * 0.001) * 1.165 # kg of N2, assuming density of 1.165 kg/m³
      
      # Calculate CO2 production (kg per person per day)
      co2_per_person_day = GameConstants::HUMAN_LIFE_SUPPORT['co2_production_kg_per_day'] || 1.0
      
      # Return daily consumption rates
      {
        oxygen: crew_count * oxygen_per_person_day,
        nitrogen: nitrogen_leakage,
        co2_scrubbing: crew_count * co2_per_person_day
      }
    end
  end
end