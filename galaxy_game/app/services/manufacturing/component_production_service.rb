# app/services/manufacturing/component_production_service.rb
module Manufacturing
  class ComponentProductionService
    attr_reader :settlement, :material_processing_service

    def initialize(settlement)
      @settlement = settlement
      @material_processing_service = Manufacturing::MaterialProcessingService.new(settlement)
      @blueprint_lookup = Lookup::BlueprintLookupService.new
    end

    def produce_component(component_blueprint_id, quantity, printer_unit)
      blueprint = load_blueprint(component_blueprint_id)
      
      # 1. Validate printer can produce this category
      validate_printer_capability(printer_unit, blueprint)
      
      # 2. Find and reserve materials (with substitution logic)
      materials_to_consume = resolve_materials(blueprint, quantity)
      
      # 3. If materials missing, trigger ISRU chain
      ensure_materials_available(materials_to_consume)
      
      # 4. Consume materials from inventory
      consume_materials(materials_to_consume)
      
      # 5. Calculate production time with printer efficiency
      production_time = calculate_production_time(blueprint, quantity, printer_unit)
      
      # 6. Create production job
      create_production_job(blueprint, quantity, printer_unit, production_time, materials_to_consume)
    end

    def complete_job(job)
      blueprint = load_blueprint(job.component_blueprint_id)
      
      # Add finished component to inventory with composition metadata
      add_component_to_inventory(job, blueprint)
      
      # Add waste products to inventory
      add_waste_products(job, blueprint)
      
      # Mark job as complete
      job.complete!
      
      job
    end

    private

    def load_blueprint(blueprint_id)
      blueprint = @blueprint_lookup.find_blueprint(blueprint_id)
      raise "Blueprint not found: #{blueprint_id}" unless blueprint
      blueprint
    end

    def validate_printer_capability(printer_unit, blueprint)
      return unless printer_unit.operational_data['component_production']
      
      capabilities = printer_unit.operational_data['component_production']['categories'] || []
      component_category = blueprint['category']
      
      unless capabilities.include?(component_category)
        raise "Printer #{printer_unit.name} cannot produce #{component_category} components"
      end
    end

    def resolve_materials(blueprint, quantity)
      materials = {}
      
      blueprint['blueprint_data']['material_requirements'].each do |req|
        material_found = find_available_material(req, quantity)
        
        if material_found
          materials[material_found[:name]] = {
            amount: material_found[:amount],
            composition: material_found[:composition]
          }
        else
          # Mark as missing but don't raise yet
          needed_amount = req['quantity'] * quantity
          materials[req['material']] = {
            amount: needed_amount,
            composition: {},
            missing: true
          }
        end
      end
      
      materials
    end

    def find_available_material(requirement, quantity)
      needed_amount = requirement['quantity'] * quantity
      material_name = requirement['material']
      
      # Check if we have acceptable materials defined (future feature)
      acceptable_materials = [material_name]
      
      acceptable_materials.each do |mat_name|
        item = @settlement.inventory.items.find_by(name: mat_name)
        
        if item && item.amount >= needed_amount
          # Try to get composition from metadata first, then material_properties
          composition = item.metadata&.dig('composition') || 
                        item.material_properties&.dig('composition') || 
                        {}
          
          return {
            name: mat_name,
            amount: needed_amount,
            composition: composition
          }
        end
      end
      
      nil
    end

    def ensure_materials_available(materials_to_consume)
      # Check if all materials are available
      materials_to_consume.each do |material_name, data|
        if data[:missing]
          raise "Insufficient materials: need #{data[:amount]}kg of #{material_name}"
        end
        
        item = @settlement.inventory.items.find_by(name: material_name)
        
        unless item && item.amount >= data[:amount]
          raise "Insufficient materials: need #{data[:amount]}kg of #{material_name}"
        end
      end
      
      # Clean up the :missing flag
      materials_to_consume.each do |_, data|
        data.delete(:missing)
      end
    end

    def consume_materials(materials_to_consume)
      materials_to_consume.each do |material_name, data|
        @settlement.inventory.remove_item(
          material_name,
          data[:amount],
          @settlement.owner
        )
      end
    end

    def calculate_production_time(blueprint, quantity, printer_unit)
      base_time = blueprint['blueprint_data']['construction_time_hours']
      total_time = base_time * quantity
      
      # Apply printer efficiency multiplier if available
      if printer_unit.operational_data['component_production']
        multiplier = printer_unit.operational_data['component_production']['production_rate_multiplier'] || 1.0
        total_time = total_time / multiplier
      end
      
      total_time
    end

    def create_production_job(blueprint, quantity, printer_unit, production_time, materials_consumed)
      ComponentProductionJob.create!(
        settlement: @settlement,
        printer_unit: printer_unit,
        component_blueprint_id: blueprint['id'],
        component_name: blueprint['name'],
        quantity: quantity,
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

    def add_component_to_inventory(job, blueprint)
      composition_data = job.materials_consumed.map do |material_name, data|
        {
          'material' => material_name,
          'amount' => data['amount'],
          'composition' => data['composition']
        }
      end
      
      metadata = {
        'source_materials' => composition_data,
        'manufactured_at' => @settlement.name,
        'manufactured_date' => Time.current.iso8601,
        'blueprint_id' => blueprint['id']
      }
      
      @settlement.inventory.add_item(
        blueprint['name'],
        job.quantity,
        @settlement.owner,
        metadata
      )
    end

    def add_waste_products(job, blueprint)
      waste_products = blueprint['blueprint_data']['waste_products'] || []
      
      waste_products.each do |waste|
        @settlement.inventory.add_item(
          waste['material'],
          waste['quantity'] * job.quantity,
          @settlement.owner,
          { 'recyclable' => waste['recyclable'] }
        )
      end
    end
  end
end