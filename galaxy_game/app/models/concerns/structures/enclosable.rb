# app/models/concerns/structures/enclosable.rb
module Structures
  module Enclosable
    extend ActiveSupport::Concern
    
    # Required methods - must be implemented by including class
    def width_m
      raise NotImplementedError, "#{self.class} must implement #width_m"
    end
    
    def length_m
      raise NotImplementedError, "#{self.class} must implement #length_m"
    end
    
    # Optional: for circular openings/structures
    def diameter_m
      nil
    end
    
    # ============================================================================
    # AREA CALCULATIONS
    # ============================================================================
    
    # Calculate enclosure area in square meters
    # @return [Float] area in m²
    def area_m2
      if diameter_m.present?
        # Circular area: π × r²
        Math::PI * (diameter_m / 2.0) ** 2
      else
        # Rectangular area: width × length
        width_m * length_m
      end
    end
    
    # Convert area to square kilometers
    # @return [Float] area in km²
    def area_km2
      area_m2 / 1_000_000.0
    end
    
    # ============================================================================
    # MATERIAL CALCULATIONS (Blueprint-Driven)
    # ============================================================================
    
    # Calculate materials needed for enclosure
    # @param panel_type [String] type of panel to use
    # @return [Hash] materials with quantities
    def calculate_enclosure_materials(panel_type: 'structural_cover_panel')
      area = area_m2
      panel_blueprint = load_panel_blueprint(panel_type)
      
      return {} unless panel_blueprint
      
      base_materials = {
        '3d_printed_ibeams' => calculate_ibeam_needs(area)
      }
      
      # Extract materials from blueprint
      panel_materials = extract_panel_materials(panel_blueprint, area)
      
      base_materials.merge(panel_materials).merge(
        'sealant' => calculate_sealant_needs(area)
      )
    end
    
    # ============================================================================
    # SHELL COMPOSITION TRACKING
    # ============================================================================
    
    # Update shell composition in operational_data
    # @param panel_type [String] type of panel
    # @param count [Integer] number of panels
    # @param area_m2 [Float] total area covered
    def update_shell_composition(panel_type, count, area_m2)
      self.operational_data ||= {}
      self.operational_data['shell_composition'] ||= {}
      
      self.operational_data['shell_composition'][panel_type] = {
        'count' => count,
        'total_area_m2' => area_m2,
        'installed_date' => Time.current.to_s,
        'health_percentage' => 100.0,
        'failed_count' => 0
      }
      
      save!
    end
    
    # Get shell composition data
    # @return [Hash] composition data
    def shell_composition
      operational_data&.dig('shell_composition') || {}
    end
    
    # ============================================================================
    # POWER GENERATION
    # ============================================================================
    
    # Calculate total power generation from solar panels
    # @return [Float] power in kW
    def total_power_generation
      shell_composition.sum do |panel_type, data|
        blueprint = load_panel_blueprint(panel_type)
        next 0 unless blueprint
        
        power_per_panel = parse_power(blueprint.dig('properties', 'energy_output'))
        next 0 unless power_per_panel > 0
        
        # Account for failures and degradation
        operational_panels = data['count'] - data['failed_count']
        health_factor = data['health_percentage'] / 100.0
        
        power_per_panel * operational_panels * health_factor
      end
    end
    
    # Calculate power generation capacity for a panel type
    # @param panel_type [String] type of panel
    # @return [Float] power capacity in kW
    def power_generation_capacity(panel_type)
      panel_blueprint = load_panel_blueprint(panel_type)
      return 0 unless panel_blueprint
      
      power_per_panel = parse_power(panel_blueprint.dig('properties', 'energy_output'))
      return 0 unless power_per_panel > 0
      
      panels_needed = (area_m2 / 25.0).ceil # 5m × 5m panels
      power_per_panel * panels_needed
    end
    
    # ============================================================================
    # DEGRADATION & MAINTENANCE
    # ============================================================================
    
    # Simulate panel degradation over time
    # @param time_elapsed_days [Integer] days elapsed
    def simulate_panel_degradation(time_elapsed_days)
      shell_composition.each do |panel_type, data|
        blueprint = load_panel_blueprint(panel_type)
        next unless blueprint
        
        # Get failure rate from blueprint
        degradation_rate = blueprint.dig('durability', 'degradation_rate') || 0.001
        
        # Calculate new health
        health_loss = degradation_rate * time_elapsed_days
        data['health_percentage'] = [data['health_percentage'] - health_loss, 0].max
        
        # Random catastrophic failures
        failure_chance = (time_elapsed_days / 365.0) * 0.001 # 0.1% per year
        if rand < failure_chance * data['count']
          failures = rand(1..3) # 1-3 panels fail
          data['failed_count'] = [data['failed_count'] + failures, data['count']].min
        end
      end
      
      save!
    end
    
    # Repair failed panels
    # @param panel_type [String] type of panel to repair
    # @param count_to_repair [Integer] number to repair
    # @return [Hash] result with repaired count and materials needed
    def repair_panels(panel_type, count_to_repair)
      composition = shell_composition[panel_type]
      return { success: false, message: "Panel type not found" } unless composition
      
      repaired = [count_to_repair, composition['failed_count']].min
      composition['failed_count'] -= repaired
      
      # Calculate materials for repair
      blueprint = load_panel_blueprint(panel_type)
      materials_needed = calculate_repair_materials(blueprint, repaired)
      
      save!
      
      {
        success: true,
        repaired_count: repaired,
        materials_needed: materials_needed
      }
    end
    
    # Replace degraded panels
    # @param panel_type [String] type of panel to replace
    # @param percentage [Float] percentage of panels to replace
    # @return [Hash] result with replaced count and materials needed
    def replace_degraded_panels(panel_type, percentage: 10)
      composition = shell_composition[panel_type]
      return { success: false, message: "Panel type not found" } unless composition
      
      panels_to_replace = (composition['count'] * (percentage / 100.0)).ceil
      
      # Calculate materials
      blueprint = load_panel_blueprint(panel_type)
      materials_needed = calculate_panel_materials(blueprint, panels_to_replace)
      
      # Replace panels - set health to 100% for replaced panels
      composition['health_percentage'] = 100.0
      
      save!
      
      {
        success: true,
        replaced_count: panels_to_replace,
        materials_needed: materials_needed
      }
    end
    
    # ============================================================================
    # STATUS REPORTING
    # ============================================================================
    
    # Get comprehensive shell status report
    # @return [Hash] status information
    def shell_status_report
      composition = shell_composition
      
      return { total_panels: 0, message: "No shell composition data" } if composition.empty?
      
      {
        total_panels: composition.sum { |_, data| data['count'] },
        total_failed: composition.sum { |_, data| data['failed_count'] },
        average_health: composition.sum { |_, data| data['health_percentage'] } / composition.size,
        power_generation: total_power_generation,
        needs_maintenance: composition.any? { |_, data| data['health_percentage'] < 80 },
        composition_breakdown: composition.transform_values do |data|
          {
            count: data['count'],
            operational: data['count'] - data['failed_count'],
            health: "#{data['health_percentage'].round(1)}%",
            status: status_for_health(data['health_percentage'])
          }
        end
      }
    end
    
    # ============================================================================
    # PANEL PROPERTIES (Blueprint-Driven)
    # ============================================================================
    
    # Get light transmission percentage from blueprint
    # @param panel_type [String] type of panel
    # @return [String, Float] transmission value
    def light_transmission(panel_type)
      panel_blueprint = load_panel_blueprint(panel_type)
      panel_blueprint&.dig('properties', 'light_transmission') || 0
    end
    
    # Get thermal rating from blueprint
    # @param panel_type [String] type of panel
    # @return [String, Float] thermal rating
    def thermal_rating(panel_type)
      panel_blueprint = load_panel_blueprint(panel_type)
      panel_blueprint&.dig('properties', 'thermal_insulation') || 0
    end
    
    private
    
    # ============================================================================
    # HELPER METHODS
    # ============================================================================
    
    # Load panel blueprint from database or file
    # @param panel_type [String] panel identifier
    # @return [Hash, nil] blueprint data
    def load_panel_blueprint(panel_type)
      # Try database first
      blueprint = Blueprint.find_by(unit_id: panel_type)
      return blueprint.data if blueprint&.data
      
      # Fallback to JSON file
      load_blueprint_from_file(panel_type)
    end
    
    # Load blueprint from JSON file
    # @param panel_type [String] panel identifier
    # @return [Hash, nil] blueprint data
    def load_blueprint_from_file(panel_type)
      file_path = Rails.root.join('app', 'data', 'blueprints', "#{panel_type}_bp.json")
      return nil unless File.exist?(file_path)
      
      JSON.parse(File.read(file_path))
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse blueprint for #{panel_type}: #{e.message}"
      nil
    end
    
    # Extract materials from blueprint for given area
    # @param blueprint [Hash] panel blueprint
    # @param total_area [Float] total area in m²
    # @return [Hash] materials with quantities
    def extract_panel_materials(blueprint, total_area)
      panels_needed = (total_area / 25.0).ceil # 5m × 5m panels
      materials = {}
      
      blueprint['materials']&.each do |material, config|
        qty_per_panel = parse_quantity(config['quantity_needed'])
        materials[material] = qty_per_panel * panels_needed
      end
      
      materials[blueprint['unit_id']] = panels_needed
      materials
    end
    
    # Calculate I-beam needs
    # @param area [Float] area in m²
    # @return [Float] number of I-beams needed
    def calculate_ibeam_needs(area)
      # Approximately 1 I-beam per 25 m² (one per panel)
      (area / 25.0).ceil
    end
    
    # Calculate sealant needs
    # @param area [Float] area in m²
    # @return [Float] kg of sealant needed
    def calculate_sealant_needs(area)
      # Approximately 0.32 kg per m² of seam
      area * 0.32
    end
    
    # Calculate materials for panel repairs
    # @param blueprint [Hash] panel blueprint
    # @param count [Integer] number of panels
    # @return [Hash] materials needed
    def calculate_repair_materials(blueprint, count)
      materials = {}
      
      # Repairs typically need 50% of original materials
      blueprint['materials']&.each do |material, config|
        qty_per_panel = parse_quantity(config['quantity_needed'])
        materials[material] = (qty_per_panel * count * 0.5).ceil
      end
      
      materials
    end
    
    # Calculate materials for panel installation
    # @param blueprint [Hash] panel blueprint
    # @param count [Integer] number of panels
    # @return [Hash] materials needed
    def calculate_panel_materials(blueprint, count)
      materials = {}
      
      blueprint['materials']&.each do |material, config|
        qty_per_panel = parse_quantity(config['quantity_needed'])
        materials[material] = qty_per_panel * count
      end
      
      materials[blueprint['unit_id']] = count
      materials
    end
    
    # Parse quantity string from blueprint
    # @param qty_string [String] e.g., "35 kg per panel"
    # @return [Float] numeric quantity
    def parse_quantity(qty_string)
      qty_string.to_s.scan(/\d+/).first.to_f
    end
    
    # Parse power string from blueprint
    # @param power_string [String] e.g., "10 kW per panel"
    # @return [Float] numeric power value
    def parse_power(power_string)
      return 0 if power_string.nil?
      power_string.to_s.scan(/\d+/).first.to_f
    end
    
    # Get status description for health percentage
    # @param health [Float] health percentage
    # @return [String] status description
    def status_for_health(health)
      case health
      when 90..100 then 'excellent'
      when 70..89 then 'good'
      when 50..69 then 'fair'
      when 30..49 then 'poor'
      else 'critical'
      end
    end
  end
end