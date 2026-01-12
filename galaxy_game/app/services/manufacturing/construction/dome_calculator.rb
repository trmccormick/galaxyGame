module Manufacturing
  module Construction
  class DomeCalculator
    # Use the same panel types as skylights
    AVAILABLE_PANEL_TYPES = [
      "basic_transparent_crater_tube_cover_array",  # Default for domes
      "solar_cover_panel",
      "thermal_insulation_cover_panel",
      "structural_cover_panel"
    ].freeze

    def self.calculate_materials(crater_dome, panel_type = nil)
      panel_type ||= "basic_transparent_crater_tube_cover_array"
      
      # Calculate dome surface area (hemisphere)
      radius = crater_dome.diameter / 2.0
      dome_surface_area = 2 * Math::PI * radius**2  # Surface area of hemisphere
      
      # Convert dome surface to equivalent rectangular skylight for calculations
      equivalent_width = Math.sqrt(dome_surface_area)
      equivalent_length = equivalent_width
      
      # Create a mock skylight object for the calculator
      mock_skylight = OpenStruct.new(
        width: equivalent_width,
        length: equivalent_length,
        name: "#{crater_dome.name} (as skylight)"
      )
      
      # Use the existing skylight calculator!
      base_materials = Construction::SkylightCalculator.calculate_materials(mock_skylight, nil)
      
      # Add dome-specific adjustments
      dome_specific_adjustments = calculate_dome_adjustments(crater_dome, base_materials)
      
      # Merge and return
      base_materials.merge(dome_specific_adjustments) { |key, base_val, adjustment| base_val + adjustment }
    end
    
    def self.calculate_dome_adjustments(crater_dome, base_materials)
      # Domes need extra structural support due to curvature
      curvature_factor = 1.2  # 20% more materials for dome shape
      depth_factor = 1 + (crater_dome.depth / 100.0)  # Deeper craters need more support
      
      {
        "structural_supports" => (base_materials["3d_printed_ibeams"] * 0.3).to_i,  # Extra supports
        "dome_anchors" => calculate_anchor_points(crater_dome),
        "pressure_seals" => calculate_pressure_sealing(crater_dome)
      }
    end
    
    def self.calculate_anchor_points(crater_dome)
      # Anchor points around the crater rim
      circumference = Math::PI * crater_dome.diameter
      anchor_spacing = 10.0  # Every 10 meters
      (circumference / anchor_spacing).ceil
    end
    
    def self.calculate_pressure_sealing(crater_dome)
      # Extra sealing for the crater rim interface
      circumference = Math::PI * crater_dome.diameter
      (circumference * 2).to_i  # 2kg sealant per meter of rim
    end
    
    def self.calculate_construction_cost(crater_dome, panel_type = nil)
      materials = calculate_materials(crater_dome, panel_type)
      
      # Use similar costing logic as skylights
      base_cost = materials.sum { |material, amount| 
        case material
        when "processed_regolith" then amount * 1.0
        when "metal_extract" then amount * 5.0
        when "silicate_extract" then amount * 3.0
        when "3d_printed_ibeams" then amount * 50.0
        when "transparent_panels" then amount * 100.0
        when "structural_supports" then amount * 75.0
        when "dome_anchors" then amount * 25.0
        when "pressure_seals" then amount * 10.0
        else amount * 2.0  # Default cost
        end
      }
      
      # Add complexity factor for dome shape
      complexity_multiplier = 1.3  # Domes are 30% more complex than flat skylights
      (base_cost * complexity_multiplier).to_i
    end
    
    def self.estimate_construction_time(crater_dome, panel_type = nil)
      # Create equivalent skylight for time calculation
      radius = crater_dome.diameter / 2.0
      dome_surface_area = 2 * Math::PI * radius**2
      equivalent_side = Math.sqrt(dome_surface_area)
      
      mock_skylight = OpenStruct.new(
        width: equivalent_side,
        length: equivalent_side
      )
      
      # Get base time from skylight calculator
      base_time = Construction::SkylightCalculator.estimate_construction_time(mock_skylight)
      
      # Add dome-specific time factors
      curvature_complexity = 1.4  # Domes take 40% longer due to curved construction
      depth_factor = 1 + (crater_dome.depth / 200.0)  # Deeper = more complex
      
      (base_time * curvature_complexity * depth_factor).ceil
    end
  end
end
end