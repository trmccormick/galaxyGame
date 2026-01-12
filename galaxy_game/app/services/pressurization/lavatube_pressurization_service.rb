# app/services/lavatube_pressurization_service.rb
module Pressurization
  class LavatubePressurizationService < BasePressurizationService
    def initialize(lava_tube, available_gases = {}, options = {})
      @lava_tube = lava_tube
      volume = calculate_volume
      
      super(volume, available_gases, options)
      
      # Add lavatube-specific properties
      @sections = options[:sections] || []
      @current_section = options[:current_section]
    end
    
    # Calculate the volume of the lava tube (cylindrical approximation)
    def calculate_volume
      # Use radius = diameter/2
      radius = @lava_tube.diameter / 2.0  # in meters
      length = @lava_tube.length # in meters
      Math::PI * radius**2 * length
    end
    
    # Calculate volume of a specific section
    def calculate_section_volume(start_position, end_position)
      section_length = (end_position - start_position).abs
      radius = @lava_tube.diameter / 2.0
      Math::PI * radius**2 * section_length
    end
    
    # Pressurize a specific section
    def pressurize_section(start_position:, end_position:)
      return unless sealing_verified?(start_position, end_position)
      
      # Find the section
      section = @lava_tube.sections.find { |s| s.start_position == start_position && s.end_position == end_position }
      return { success: false, error: "Section not found" } unless section
      
      # Check if O2 integrity test has passed
      unless section.operational_data&.dig('o2_test_verified')
        return { success: false, error: "Oxygen integrity test must pass before full pressurization" }
      end
      
      # Calculate section volume
      section_volume = calculate_section_volume(start_position, end_position)
      
      # Store current volume
      original_volume = @volume
      
      # Set volume to section volume temporarily
      @volume = section_volume
      
      # Pressurize the section
      result = pressurize
      
      # Restore original volume
      @volume = original_volume
      
      result
    end

    # Perform oxygen integrity test for a section
    def perform_oxygen_integrity_test(section_id)
      # Find the lava tube section
      section = @lava_tube.sections.find { |s| s.id == section_id }
      return { success: false, error: "Section not found" } unless section

      # Calculate section volume
      section_volume = calculate_section_volume(section.start_position, section.end_position)

      # Get oxygen from LDC settlement inventory (Local Production)
      ldc_settlement = Settlement::BaseSettlement.find_by(name: "Moon Subsurface Base") # Assuming LDC owns it
      return { success: false, error: "LDC settlement not found" } unless ldc_settlement

      oxygen_available = ldc_settlement.inventory.items.find_by(name: "oxygen")&.amount || 0
      available_gases = { oxygen: oxygen_available }

      # Create temporary service for O2-only test
      test_service = self.class.new(@lava_tube, available_gases, {
        target_pressure: 21278, # 0.21 atm in Pa
        gas_mix: { 'oxygen' => 1.0 },
        sections: @sections,
        current_section: section
      })

      # Set volume to section volume
      test_service.instance_variable_set(:@volume, section_volume)

      # Perform the test pressurization
      result = test_service.pressurize

      # If test passes, mark section as O2 verified
      if result[:success]
        section.update!(operational_data: section.operational_data.merge(o2_test_verified: true))
      end

      result
    end
    
    private
    
    def sealing_verified?(start_pos, end_pos)
      # Check if section boundaries have airlocks or seals
      start_seal = @lava_tube.access_points.find_by(position: start_pos)
      end_seal = @lava_tube.access_points.find_by(position: end_pos)
      
      return false unless start_seal && end_seal
      
      # Check if the seals are functional/intact
      start_seal_functional = start_seal.access_type == 'sealed'
      end_seal_functional = end_seal.access_type == 'sealed'
      
      # Final check
      start_seal_functional && end_seal_functional
    end
  end
end
