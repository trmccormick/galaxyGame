# app/services/construction/skylight_service.rb
class Manufacturing::Construction::SkylightService < Manufacturing::Construction::CoveringService
  protected
  
  def default_panel_type
    "basic_transparent_crater_tube_cover_array"
  end
      
      def find_settlement
        lava_tube = get_lava_tube
        @settlement || lava_tube&.settlement || get_settlement_from_location
      end
      
      def job_type_name
        'skylight_cover'
      end
      
      def complexity_factor
        case @panel_type
        when "basic_transparent_crater_tube_cover_array"
          1.0
        when "solar_cover_panel"
          1.5
        when "thermal_insulation_cover_panel"
          1.3
        when "structural_cover_panel"
          1.2
        else
          1.0
        end
      end
      
      def calculate_panel_specific_materials(panel_type)
        width, length = Manufacturing::Construction::CoveringCalculator.get_skylight_dimensions(@coverable)
        panel_count = Manufacturing::Construction::CoveringCalculator.calculate_panel_count(width, length)
        
        case panel_type
        when "basic_transparent_crater_tube_cover_array", "transparent_cover_panel"
          {
            "silicate_glass" => panel_count * 25,
            "aluminum_frame" => panel_count * 5,
            "ceramic_composite" => panel_count * 2
          }
        when "solar_cover_panel"
          {
            "advanced_solar_cells" => panel_count * 10,
            "graphene_layers" => panel_count * 3,
            "silicate_glass" => panel_count * 20,
            "aluminum_frame" => panel_count * 5
          }
        when "thermal_insulation_cover_panel"
          {
            "aerogel_layers" => panel_count * 15,
            "thermal_resistant_coating" => panel_count * 5,
            "aluminum_frame" => panel_count * 5
          }
        when "structural_cover_panel"
          {
            "reinforced_steel" => panel_count * 30,
            "carbon_nanotubes" => panel_count * 2,
            "radiation_shielding" => panel_count * 10
          }
        else
          {
            "processed_materials" => panel_count * 20,
            "structural_components" => panel_count * 10
          }
        end
      end
      
      def determine_completion_status(panel_type)
        case panel_type
        when "basic_transparent_crater_tube_cover_array"
          "primary_cover"
        when "structural_cover_panel"
          @coverable.status == "primary_cover" ? "full_cover" : "secondary_cover"
        when "solar_cover_panel"
          "solar_cover"
        when "thermal_insulation_cover_panel"
          "insulated_cover"
        else
          "covered"
        end
      end
      
      def start_maintenance_systems(status)
        case status
        when "primary_cover"
          MaintenanceMonitorService.start_repair_drones(@coverable, @panel_type) if defined?(MaintenanceMonitorService)
        when "full_cover", "solar_cover", "insulated_cover"
          MaintenanceMonitorService.start_advanced_maintenance(@coverable, @panel_type) if defined?(MaintenanceMonitorService)
        end
      end
      
      private
      
      def get_lava_tube
        if @coverable.respond_to?(:lava_tube)
          @coverable.lava_tube
        elsif @coverable.respond_to?(:lavatube)
          @coverable.lavatube
        else
          nil
        end
      end
      
      def get_settlement_from_location
        lava_tube = get_lava_tube
        return nil unless lava_tube&.location
        Settlement::BaseSettlement.find_by(location: lava_tube.location)
      end
    end

