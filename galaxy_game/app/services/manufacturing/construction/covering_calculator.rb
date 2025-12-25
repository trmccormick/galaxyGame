module Manufacturing
  module Construction
    class CoveringCalculator
      # Constants for material calculations
      IBEAM_SPACING = 5.0 # meters between I-beams
      PANEL_SIZE = 5.0 # standard panel size in meters (5x5)
      REGOLITH_PER_IBEAM = 75.0 # kg of regolith needed per I-beam
      SILICATE_PER_PANEL = 25.0 # kg of processed silicate for transparent panels
      
      # Class method to calculate materials based on skylight size and blueprint
      def self.calculate_materials(skylight, blueprint)
        # Get dimensions - handle both circular and rectangular skylights
        width, length = get_skylight_dimensions(skylight)
        area = width * length
        
        # Calculate number of components needed
        ibeam_count = calculate_ibeam_count(width, length)
        panel_count = calculate_panel_count(width, length)
        fastener_count = ibeam_count * 4 # 4 fasteners per I-beam connection
        
        # Calculate raw materials needed from local resources
        local_regolith_needed = calculate_regolith_needed(ibeam_count, panel_count)
        metal_extract_needed = calculate_metal_extract_needed(ibeam_count)
        silicate_extract_needed = calculate_silicate_extract_needed(panel_count)
        
        # Final materials hash - combines blueprint base materials with calculated needs
        materials = {
          "processed_regolith" => local_regolith_needed,
          "metal_extract" => metal_extract_needed,
          "silicate_extract" => silicate_extract_needed,
          "3d_printed_ibeams" => ibeam_count,
          "transparent_panels" => panel_count,
          "fasteners" => fastener_count,
          "sealant" => calculate_sealant(width, length)
        }
        
        # Add any additional materials from the blueprint
        if blueprint&.materials
          blueprint.materials.each do |material, amount|
            # Scale blueprint materials based on area ratio
            scaling_factor = area / 100.0 # Assuming blueprint is based on 100 sq meter reference
            scaled_amount = (amount.to_f * scaling_factor).to_i
            
            if materials.key?(material)
              materials[material] += scaled_amount
            else
              materials[material] = scaled_amount
            end
          end
        end
        
        materials
      end
      
      # Get skylight dimensions - handle different skylight types
      def self.get_skylight_dimensions(skylight)
        if skylight.respond_to?(:width_m) && skylight.respond_to?(:length_m) && skylight.width_m.present? && skylight.length_m.present?
          # Rectangular skylight
          [skylight.width_m, skylight.length_m]
        elsif skylight.respond_to?(:diameter_m) && skylight.diameter_m.present?
          # Circular skylight - approximate as square for material calculations
          diameter = skylight.diameter_m
          side_length = diameter * 0.8 # Use 80% of diameter as effective square side
          [side_length, side_length]
        else
          # Default fallback
          [10.0, 10.0]
        end
      end
      
      # Calculate how much regolith must be processed for the entire structure
      def self.calculate_regolith_needed(ibeam_count, panel_count)
        # Total regolith needed for both I-beams and panels
        (ibeam_count * REGOLITH_PER_IBEAM) + (panel_count * SILICATE_PER_PANEL)
      end
      
      # Calculate amount of metals needed from regolith processing
      def self.calculate_metal_extract_needed(ibeam_count)
        # Assuming 40% of I-beam mass is metal (iron, aluminum, etc)
        ibeam_count * REGOLITH_PER_IBEAM * 0.4
      end
      
      # Calculate amount of silicates needed for transparent panels
      def self.calculate_silicate_extract_needed(panel_count)
        panel_count * SILICATE_PER_PANEL
      end
      
      # Calculate number of I-beams needed based on dimensions
      def self.calculate_ibeam_count(width, length)
        # Determine grid of I-beams needed (add 1 to each dimension for edge beams)
        width_beams = (width / IBEAM_SPACING).ceil + 1
        length_beams = (length / IBEAM_SPACING).ceil + 1
        
        # Total beams = all horizontal + all vertical beams
        width_beams * length_beams
      end
      
      # Calculate number of panels needed - FIXED to be more flexible
      def self.calculate_panel_count(width, length)
        # Calculate basic panel count
        width_panels = (width / PANEL_SIZE).ceil
        length_panels = (length / PANEL_SIZE).ceil
        base_panels = width_panels * length_panels
        
        # Add 5% additional panels for overlaps, cuts, and wastage
        total_panels = (base_panels * 1.05).ceil
        
        # Ensure minimum panel count for structural integrity
        [total_panels, 4].max
      end
      
      # Calculate amount of sealant needed
      def self.calculate_sealant(width, length)
        # Sealant needed for panel edges and joins
        perimeter = 2 * (width + length)
        panel_count = calculate_panel_count(width, length)
        interior_joins = panel_count * 4 # 4 edges per panel
        
        # Convert to kilograms of sealant (0.2 kg per meter)
        (perimeter + interior_joins) * 0.2
      end
      
      # Calculate construction time estimate (in hours)
      def self.estimate_construction_time(skylight)
        width, length = get_skylight_dimensions(skylight)
        
        # Base time plus additional time per square meter
        base_hours = 24 # One day base time
        area = width * length
        area_factor = area / 10.0 # Hours per 10 sq meters
        
        # Panel complexity factor
        panel_count = calculate_panel_count(width, length)
        complexity_factor = 1 + (panel_count / 100.0) # More panels = more complexity
        
        ((base_hours + area_factor) * complexity_factor).ceil
      end
      
      # Calculate required 3D printer capacity
      def self.calculate_printer_requirements(skylight)
        width, length = get_skylight_dimensions(skylight)
        ibeam_count = calculate_ibeam_count(width, length)
        
        # Assuming 2 hours per I-beam as per JSON file
        total_print_hours = ibeam_count * 2
        
        # Number of printers needed to complete in a reasonable time (7 days)
        target_completion_days = 7
        hours_available = 24 * target_completion_days
        printers_needed = (total_print_hours.to_f / hours_available).ceil
        
        # Ensure minimum of 1 printer
        printers_needed = [printers_needed, 1].max
        
        {
          printer_count: printers_needed,
          print_hours: total_print_hours,
          power_required: printers_needed * 50, # 50kW per printer
          estimated_days: (total_print_hours.to_f / (printers_needed * 24)).ceil
        }
      end
    end
  end
end