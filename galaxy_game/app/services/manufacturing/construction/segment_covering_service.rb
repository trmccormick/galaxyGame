# app/services/construction/segment_covering_service.rb
class Manufacturing::Construction::SegmentCoveringService < Manufacturing::Construction::CoveringService
  
  protected
  
      def default_panel_type
        "modular_structural_panel"
      end
      
      def find_settlement
        @coverable.worldhouse&.settlement
      end
      
      def job_type_name
        'structure_upgrade'
      end
    
    def complexity_factor
      # Worldhouse segments are more complex due to scale
      base = 1.5
      
      # Additional complexity for very large segments
      if @coverable.respond_to?(:area_km2) && @coverable.area_km2 > 1000
        base * 1.2
      else
        base
      end
    end
    
    def calculate_panel_specific_materials(panel_type)
      width = @coverable.respond_to?(:width_m) ? @coverable.width_m : 1000
      length = @coverable.respond_to?(:length_m) ? @coverable.length_m : 1000
      panel_count = Manufacturing::Construction::CoveringCalculator.calculate_panel_count(width, length)
      
      case panel_type
      when "modular_structural_panel"
        {
          "transparent_aluminum" => (panel_count * 50).round,
          "structural_steel" => (panel_count * 30).round,
          "sealant" => (panel_count * 2).round,
          "support_cables" => calculate_cable_needs
        }
      when "solar_panel_array"
        {
          "advanced_solar_cells" => (panel_count * 15).round,
          "power_conduits" => (panel_count * 5).round,
          "transparent_aluminum" => (panel_count * 40).round,
          "structural_steel" => (panel_count * 25).round
        }
      else
        super
      end
    end
    
    def determine_completion_status(panel_type)
      'enclosed'
    end
    
    def calculate_equipment_requirements
      printer_requirements = Manufacturing::Construction::CoveringCalculator.calculate_printer_requirements(@coverable)
      
      # Worldhouse segments need more equipment
      base_printers = printer_requirements[:printer_count]
      scaled_printers = [base_printers, 10].max # Minimum 10 printers for worldhouse
      
      [
        { equipment_type: "3d_printer", quantity: scaled_printers },
        { equipment_type: "construction_drone", quantity: 20 },
        { equipment_type: "assembly_robot", quantity: 10 },
        { equipment_type: "materials_transport", quantity: 5 },
        { equipment_type: "heavy_lifter", quantity: 2 }
      ]
    end
    
    public
    
    def schedule_construction
      result = super
      
      # For massive segments, create construction phases
      if @coverable.respond_to?(:area_km2) && @coverable.area_km2 > 1000
        create_construction_phases(result[:construction_job]) if result[:success]
      end
      
      result
    end
    
    private
    
    def calculate_cable_needs
      width = @coverable.respond_to?(:width_m) ? @coverable.width_m : 1000
      length = @coverable.respond_to?(:length_m) ? @coverable.length_m : 1000
      perimeter = 2 * (width + length)
      (perimeter * 100).round # 100kg per meter
    end
    
    def create_construction_phases(construction_job)
      # Create sub-phases for UI/gameplay tracking
      phases = [
        { name: 'Framework Installation', progress: 0, duration_percent: 30 },
        { name: 'Panel Installation - Quarter 1', progress: 0, duration_percent: 15 },
        { name: 'Panel Installation - Quarter 2', progress: 0, duration_percent: 15 },
        { name: 'Panel Installation - Quarter 3', progress: 0, duration_percent: 15 },
        { name: 'Panel Installation - Quarter 4', progress: 0, duration_percent: 15 },
        { name: 'Sealing and Pressurization', progress: 0, duration_percent: 10 }
      ]
      
      construction_job.update(
        target_values: construction_job.target_values.merge(
          construction_phases: phases,
          current_phase_index: 0
        )
      )
    end
end