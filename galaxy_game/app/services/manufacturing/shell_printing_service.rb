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
      
      # 3. Calculate material requirements from tank blueprint
      materials_needed = calculate_shell_materials(inflatable_tank)
      
      # 4. Ensure materials available
      ensure_materials_available(materials_needed)
      
      # 5. Consume materials from inventory
      consume_materials(materials_needed)
      
      # 6. Calculate production time
      production_time = calculate_production_time(inflatable_tank, printer_unit)
      
      # 7. Create shell printing job
      create_shell_printing_job(inflatable_tank, printer_unit, production_time, materials_needed)
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
      
      # 2. Update job status
      job.complete!
      
      job
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

    def calculate_shell_materials(inflatable_tank)
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
        
        item = @settlement.inventory.items.find_by(name: material_name)
        
        if item && item.amount >= needed_amount
          composition = item.metadata&.dig('composition') || 
                        item.material_properties&.dig('composition') || 
                        {}
          
          materials[material_name] = {
            amount: needed_amount,
            composition: composition
          }
        else
          materials[material_name] = {
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

    def calculate_production_time(inflatable_tank, printer_unit)
      # Check if tank has shell requirements in operational_data first
      if inflatable_tank.operational_data['shell_requirements']
        shell_requirements = inflatable_tank.operational_data['shell_requirements']
      else
        # Fallback to blueprint lookup
        tank_blueprint = @blueprint_lookup.find_blueprint(inflatable_tank.unit_type)
        shell_requirements = tank_blueprint['shell_requirements']
      end
      
      base_time = shell_requirements['printing_time_hours'] || 10.0
      
      # Apply printer efficiency multiplier if available
      multiplier = printer_unit.operational_data.dig('component_production', 'production_rate_multiplier') || 1.0
      
      base_time / multiplier
    end

    def create_shell_printing_job(inflatable_tank, printer_unit, production_time, materials_consumed)
      ShellPrintingJob.create!(
        settlement: @settlement,
        printer_unit: printer_unit,
        inflatable_tank: inflatable_tank,
        production_time_hours: production_time,
        status: 'pending',
        materials_consumed: format_materials_for_storage(materials_consumed)
      )
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