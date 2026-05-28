# app/services/manufacturing/shell_printing_service.rb
module Manufacturing
  class ShellPrintingService
    attr_reader :settlement

    def initialize(settlement)
      @settlement = settlement
      @blueprint_lookup = Lookup::BlueprintLookupService.new
    end

    def enclose_inflatable(inflatable_tank, printer_unit)
      # 1. Validate tank is ready for enclosure
      validate_tank_ready(inflatable_tank)
      
      # 2. Validate printer can do shell printing
      validate_printer_capability(printer_unit)
      
      # 3. Calculate target shell thickness based on atmosphere
      target_thickness = calculate_target_thickness(inflatable_tank)
      
      # 4. Calculate material requirements from tank blueprint
      materials_needed = calculate_shell_materials(inflatable_tank, target_thickness)
      
      # 5. Ensure materials available
      ensure_materials_available(materials_needed)
      
      # 6. Consume materials from inventory
      consume_materials(materials_needed)
      
      # 7. Calculate production time based on thickness and unit size
      production_time = calculate_production_time(inflatable_tank, printer_unit, target_thickness)
      
      # 8. Create shell printing job
      create_shell_printing_job(inflatable_tank, printer_unit, production_time, materials_needed, target_thickness)
    end

    # Alias for backward compatibility with tests
    def print_shell(inflatable_tank, printer_unit)
      enclose_inflatable(inflatable_tank, printer_unit)
    end

    def complete_job(job)
      # 1. Mark tank as enclosed
      job.inflatable_tank.update!(
        operational_data: job.inflatable_tank.operational_data.merge(
          'enclosed' => true,
          'shell_printed_at' => Time.current.iso8601,
          'shell_materials' => job.materials_consumed
        )
      )
      
      # 2. Mark job as completed
      job.update!(status: :completed, completed_at: Time.current)
      
      # 3. Check for next pending job for this printer and promote it to scheduled
      promote_next_pending_job(job.printer_unit_id)
      
      job
    end

    def promote_next_pending_job(printer_unit_id)
      # Note: The game loop is responsible for checking unit capacity and moving 
      # pending jobs to in_progress. This method is kept for reference but jobs
      # are now all created as pending and managed by the game loop.
      # Jobs queue up as pending, game loop assigns to in_progress when capacity available.
    end

    private

    def validate_tank_ready(tank)
      raise "Tank must be deployed" unless tank.operational_data['deployed']
      raise "Tank already has shell" if tank.operational_data['enclosed']
      raise "Tank not operational" unless tank.operational_data['operational']
    end

    def validate_printer_capability(printer_unit)
      raise "Printer must be operational" unless printer_unit.operational?
      
      capabilities = printer_unit.operational_data.dig('processing_capabilities', 'geosphere_processing', 'types') || []
      raise "Printer cannot process regolith for shell printing" unless capabilities.include?('regolith')
    end

    def calculate_shell_materials(inflatable_tank, target_thickness = nil)
      # Check if tank has shell requirements in operational_data first
      if inflatable_tank.operational_data['shell_requirements']
        shell_requirements = inflatable_tank.operational_data['shell_requirements']
      else
        # Fallback to blueprint lookup
        tank_blueprint = @blueprint_lookup.find_blueprint(inflatable_tank.unit_type)
        raise "Tank blueprint not found" unless tank_blueprint
        
        shell_requirements = tank_blueprint['shell_requirements']
        raise "No shell requirements defined for #{inflatable_tank.unit_type}" unless shell_requirements
      end
      
      materials = {}
      
      shell_requirements['material_requirements'].each do |req|
        material_name = req['material']
        needed_amount = req['quantity'] || req['amount']  # Support both 'quantity' and 'amount' keys
        
        # Skip if quantity is not specified or invalid
        next unless needed_amount && needed_amount.is_a?(Numeric) && needed_amount > 0
        
        # For regolith-based materials, use intelligent fallback chain
        if material_name.downcase.include?('regolith')
          item = find_regolith_material(needed_amount)
          material_to_use = item[:name] if item
        else
          item = @settlement.inventory.items.find_by(name: material_name)
          material_to_use = material_name
        end
        
        if item && item[:amount] >= needed_amount
          composition = item[:composition] || {}
          
          materials[material_to_use] = {
            amount: needed_amount,
            composition: composition
          }
        else
          materials[material_to_use || material_name] = {
            amount: needed_amount,
            composition: {},
            missing: true
          }
        end
      end
      
      materials
    end

    def ensure_materials_available(materials_needed)
      materials_needed.each do |material_name, data|
        if data[:missing]
          raise "Insufficient materials: need #{data[:amount]}kg of #{material_name}"
        end
        
        item = @settlement.inventory.items.find_by(name: material_name)
        
        unless item && item.amount >= data[:amount]
          raise "Insufficient materials: need #{data[:amount]}kg of #{material_name}"
        end
      end
      
      # Clean up the :missing flag
      materials_needed.each do |_, data|
        data.delete(:missing)
      end
    end

    def consume_materials(materials_needed)
      materials_needed.each do |material_name, data|
        @settlement.inventory.remove_item(
          material_name,
          data[:amount],
          @settlement.owner
        )
      end
    end

    def calculate_production_time(inflatable_tank, printer_unit, target_thickness = nil)
      target_thickness ||= calculate_target_thickness(inflatable_tank)
      
      # Get tank physical dimensions for volume calculation
      unit_volume = calculate_unit_volume(inflatable_tank)
      
      # Production time calculation:
      # Base: 10 hours per 100mm thickness
      # Volume factor: larger units take proportionally longer
      # Printer efficiency: applied as multiplier
      
      # Thickness contribution: 10 hours per 100mm (e.g., 150mm = 15 hours, 80mm = 8 hours)
      thickness_hours = (target_thickness / 100.0) * 10.0
      
      # Volume contribution: base unit = 25 m³ takes base time
      # Scale by volume (larger inflatable = more surface area to print)
      volume_multiplier = unit_volume / 25.0
      
      base_time = thickness_hours * volume_multiplier
      
      # Apply printer efficiency multiplier if available
      multiplier = printer_unit.operational_data.dig('component_production', 'production_rate_multiplier') || 1.0
      
      base_time / multiplier
    end

    def calculate_unit_volume(inflatable_tank)
      # Try to get volume from operational data
      operational_volume = inflatable_tank.operational_data&.dig('volume_m3')
      return operational_volume.to_f if operational_volume.present?
      
      # Try to calculate from physical properties
      if inflatable_tank.operational_data['physical_properties']
        props = inflatable_tank.operational_data['physical_properties']
        width = props['width_m'].to_f
        height = props['height_m'].to_f
        length = props['length_m'].to_f
        return width * height * length if width > 0 && height > 0 && length > 0
      end
      
      # Default fallback
      25.0  # Default inflatable tank volume
    end

    def find_regolith_material(needed_amount)
      # Preference order: depleted > processed > raw
      # Reason: depleted regolith has already had volatiles removed by PVE/TEU
      
      regolith_types = ['depleted_regolith', 'processed_regolith', 'raw_regolith']
      
      regolith_types.each do |regolith_type|
        item = @settlement.inventory.items.find_by(name: regolith_type)
        
        if item && item.amount >= needed_amount
          composition = item.metadata&.dig('composition') || 
                        item.material_properties&.dig('composition') || 
                        {}
          return { name: item.name, amount: item.amount, composition: composition }
        end
      end
      
      # Fallback: accept any regolith type even if not enough (service will handle error)
      regolith_types.each do |regolith_type|
        item = @settlement.inventory.items.find_by(name: regolith_type)
        
        if item
          composition = item.metadata&.dig('composition') || 
                        item.material_properties&.dig('composition') || 
                        {}
          return { name: item.name, amount: item.amount, composition: composition }
        end
      end
      
      # No regolith found
      nil
    end

    def create_shell_printing_job(inflatable_tank, printer_unit, production_time, materials_consumed, target_thickness = nil)
      target_thickness ||= calculate_target_thickness(inflatable_tank)
      
      # All new jobs start as pending - game loop will check capacity and move to in_progress
      ConstructionJob.create!(
        settlement: @settlement,
        jobable: inflatable_tank,
        inflatable_id: inflatable_tank&.id,
        status: :pending,
        job_type: :shell_printing,
        target_thickness_mm: target_thickness,
        target_values: {
          'printer_unit_id' => printer_unit&.id,
          'inflatable_tank_id' => inflatable_tank&.id,
          'production_time_hours' => production_time,
          'materials_consumed' => materials_consumed,
          'unit_volume_m3' => calculate_unit_volume(inflatable_tank)
        }
      )
    end

    def calculate_target_thickness(inflatable_tank)
      # Get celestial body from settlement location
      celestial_body = @settlement.location&.celestial_body
      
      # Default thickness if no celestial body
      return 120.0 unless celestial_body
      
      # Get atmosphere pressure
      atmosphere = celestial_body.respond_to?(:atmosphere) ? celestial_body.atmosphere : nil
      pressure = atmosphere&.pressure.to_f || 0.0
      
      # Calculate thickness based on atmospheric pressure
      # Airless worlds (pressure = 0) need thicker shells to protect from radiation
      # Mars-like (pressure ~0.6 kPa) needs less protection
      # Earth-like (pressure ~101 kPa) needs minimal shell since atmosphere provides protection
      
      case pressure
      when 0
        # Airless world - thicker shell needed for radiation protection
        150.0
      when 0.0..1.0
        # Very thin atmosphere (Mars-like) - substantial shell needed
        140.0
      when 1.0..10.0
        # Thin atmosphere - moderate shell thickness
        130.0
      when 10.0..50.0
        # Medium atmosphere - reduced shell thickness
        110.0
      else
        # Earth-like or thicker atmosphere - minimal shell thickness
        80.0
      end
    end

    def format_materials_for_storage(materials_consumed)
      materials_consumed.transform_values do |data|
        {
          'amount' => data[:amount],
          'composition' => data[:composition]
        }
      end
    end
  end
end