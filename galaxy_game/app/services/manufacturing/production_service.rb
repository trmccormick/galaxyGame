# app/services/manufacturing/production_service.rb

module Manufacturing
  class ProductionService
    # Constant data used internally (should be loaded from unit data/DB in final app)
    # Replicated here for clarity.
    PVE_DATA = { 
        input_processed_kg: 5.0, 
        output_gases_kg: 0.05, 
        output_water_kg: 0.10, 
        output_inert_waste_kg: 4.85
    }.freeze

    def initialize(settlement)
      @settlement = settlement
      @inventory = settlement.inventory
      @surface_storage = @inventory.surface_storage || 
                         raise("Surface Storage not initialized for settlement.")
    end

    ##
    # Core method to run the entire ISRU chain for a final component.
    # This method orchestrates the consumption/production of all intermediate materials.
    #
    def manufacture_component(blueprint_data, target_units)
      ActiveRecord::Base.transaction do
        # 1. Calculate the final material requirements for the blueprint.
        inert_req_kg = blueprint_data[:input_quantity_kg] * target_units
        
        # 2. Determine upstream unit cycles needed (PVE -> TEU cycles).
        pve_cycles = calculate_pve_cycles(inert_req_kg)
        
        # 3. Calculate total material requirements for validation
        materials_needed = calculate_material_requirements(pve_cycles, blueprint_data, target_units)
        
        # 4. Validate materials available (transactional - check before consume)
        validate_materials_available(materials_needed)
        
        # 5. Consume Raw Regolith from Surface Pile (Logistics step)
        consume_from_pile("raw_regolith", blueprint_data[:input_quantity_kg] * target_units)
        
        # 6. Run TEU/PVE cycles (Calls Manufacturing::MaterialProcessing internally)
        yield_data = run_pve_cycles(pve_cycles, blueprint_data)
        
        # 7. Produce Volatiles to Base Inventory (Logistics step)
        produce_to_inventory("water", yield_data[:total_water])
        produce_to_inventory("gases", yield_data[:total_gas])
        
        # 8. Produce Inert Waste to Surface Pile (Logistics step)
        produce_to_pile("depleted_regolith", yield_data[:total_inert_waste])
        
        # 9. Consume Inert Waste & Produce Final Component (3D Printer cycle)
        job = create_production_job(blueprint_data, target_units, materials_needed, yield_data)
        
        # raw_regolith already consumed via consume_from_pile above — remove to avoid double-debit
        materials_needed.delete('raw_regolith')
        
        consume_materials(materials_needed)
        produce_final_component(job, blueprint_data, target_units, yield_data)
        
        # 10. Return comprehensive production report
        {
          pve_cycles: pve_cycles,
          total_water: yield_data[:total_water],
          total_gas: yield_data[:total_gas],
          total_inert_waste: yield_data[:total_inert_waste],
          component_produced: blueprint_data[:id],
          component_amount: target_units,
          job_id: job.id,
          materials_consumed: materials_needed,
          byproducts: yield_data[:byproducts] || []
        }
      end
    rescue => e
      Rails.logger.error("Production failed: #{e.message}")
      raise
    end

    ##
    # Helper method to run one cycle of a specific unit (TEU/PVE).
    # Returns yield data with all output materials.
    #
    def run_unit_cycle(unit_type, input_material)
      case unit_type
      when :pve, :teu
        # Calculate yield based on PVE_DATA ratios
        input_kg = input_material[:quantity] || PVE_DATA[:input_processed_kg]
        
        {
          input_kg: input_kg,
          output_gases_kg: (input_kg / PVE_DATA[:input_processed_kg]) * PVE_DATA[:output_gases_kg],
          output_water_kg: (input_kg / PVE_DATA[:input_processed_kg]) * PVE_DATA[:output_water_kg],
          output_inert_waste_kg: (input_kg / PVE_DATA[:input_processed_kg]) * PVE_DATA[:output_inert_waste_kg],
          unit_type: unit_type,
          composition: input_material[:composition] || {}
        }
      else
        raise "Unknown unit type: #{unit_type}"
      end
    end
    
    # Run multiple PVE cycles and aggregate results
    def run_pve_cycles(cycles, blueprint_data)
      total_water = 0.0
      total_gas = 0.0
      total_inert_waste = 0.0
      byproducts = []
      
      cycles.times do |cycle|
        # Simulate input material for this cycle
        input_material = {
          quantity: PVE_DATA[:input_processed_kg],
          composition: blueprint_data[:composition] || {}
        }
        
        # Run the unit cycle
        yield_data = run_unit_cycle(:pve, input_material)
        
        # Aggregate results
        total_water += yield_data[:output_water_kg]
        total_gas += yield_data[:output_gases_kg]
        total_inert_waste += yield_data[:output_inert_waste_kg]
        
        # Track byproducts for this cycle
        byproducts << {
          cycle: cycle + 1,
          water_kg: yield_data[:output_water_kg],
          gases_kg: yield_data[:output_gases_kg],
          inert_waste_kg: yield_data[:output_inert_waste_kg]
        }
      end
      
      {
        total_water: total_water,
        total_gas: total_gas,
        total_inert_waste: total_inert_waste,
        byproducts: byproducts
      }
    end
    
    # Calculate PVE cycles needed for required inert waste
    def calculate_pve_cycles(inert_req_kg)
      (inert_req_kg / PVE_DATA[:output_inert_waste_kg]).ceil
    end
    
    # Calculate total material requirements including upstream materials
    def calculate_material_requirements(pve_cycles, blueprint_data, target_units)
      materials = {}
      
      # Raw regolith needed for PVE cycles
      materials["raw_regolith"] = {
        amount: pve_cycles * PVE_DATA[:input_processed_kg],
        composition: blueprint_data[:composition] || {}
      }
      
      # Add any additional materials from blueprint (e.g., binding agents)
      if blueprint_data[:additional_materials]
        blueprint_data[:additional_materials].each do |mat_data|
          materials[mat_data[:name]] = {
            amount: mat_data[:quantity] * blueprint_data[:input_quantity_kg] * target_units,
            composition: mat_data[:composition] || {}
          }
        end
      end
      
      materials
    end
    
    # Validate that all required materials are available in inventory
    def validate_materials_available(materials_needed)
      missing = {}
      
      materials_needed.each do |material_name, material_data|
        available = get_available_amount(material_name)
        if available < material_data[:amount]
          missing[material_name] = {
            needed: material_data[:amount],
            available: available,
            deficit: material_data[:amount] - available
          }
        end
      end
      
      if missing.any?
        raise "Insufficient materials: #{missing.map { |k, v| "#{k} (need #{v[:needed]}, have #{v[:available]})" }.join(', ')}"
      end
    end
    
    # Get available amount of a material in inventory
    def get_available_amount(material_name)
      item_amount = @inventory.items.where(name: material_name).sum(:amount)
      pile_amount = @surface_storage.material_piles
                      .where(material_type: material_name)
                      .sum(:amount)
      item_amount + pile_amount
    end
    
    # Consume materials from inventory atomically
    def consume_materials(materials_needed)
      materials_needed.each do |material_name, material_data|
        remaining_to_use = material_data[:amount]
        
        # Check if material exists as a pile on surface storage first
        matching_piles = @surface_storage.material_piles.where(material_type: material_name).order(:created_at)
        
        if matching_piles.any?
          # Consume from piles
          matching_piles.each do |pile|
            if pile.amount <= remaining_to_use
              remaining_to_use -= pile.amount
              pile.destroy
            else
              pile.amount -= remaining_to_use
              pile.save!
              remaining_to_use = 0
            end
            
            break if remaining_to_use <= 0
          end
        else
          # Fall back to inventory items
          matching_items = @inventory.items.where(name: material_name).order(:created_at)
          
          matching_items.each do |item|
            if item.amount <= remaining_to_use
              remaining_to_use -= item.amount
              item.destroy
            else
              item.remove_quantity(remaining_to_use)
              remaining_to_use = 0
            end
            
            break if remaining_to_use <= 0
          end
        end
        
        if remaining_to_use > 0
          raise "Failed to consume all of #{material_name}: still need #{remaining_to_use}"
        end
      end
    end
    
    # Consume from surface pile (logistics helper)
    def consume_from_pile(pile_name, quantity)
      pile = @surface_storage.material_piles.where(material_type: pile_name).first
      if pile.nil? || pile.amount < quantity
        raise "Insufficient material in pile #{pile_name}: need #{quantity}, have #{pile&.amount || 0}"
      end
      
      pile.amount -= quantity
      pile.save!
    end
    
    # Produce to surface pile (logistics helper)
    def produce_to_pile(pile_name, quantity)
      pile = @surface_storage.material_piles.where(material_type: pile_name).first
      
      if pile.nil?
        # Create new pile if it doesn't exist
        pile = @surface_storage.material_piles.create!(
          material_type: pile_name,
          amount: quantity,
          quality_factor: 1.0
        )
      else
        pile.amount += quantity
        pile.save!
      end
    end
    
    # Produce to settlement inventory
    def produce_to_inventory(item_name, quantity)
      @inventory.add_item(item_name, quantity, @settlement.owner, {
        'production_source' => 'PVE_cycle',
        'production_date' => Time.current
      })
    end
    
    # Create a production job record for tracking
    def create_production_job(blueprint_data, target_units, materials_needed, yield_data)
      Job.create!(
        job_type: :component_production,
        settlement: @settlement,
        owner: @settlement.owner,
        status: 'in_progress',
        completes_at: Time.current + (blueprint_data[:production_time_hours] || 2.0) * target_units.hours,
        operational_data: {
          'component_blueprint_id' => blueprint_data[:id],
          'component_name' => blueprint_data[:name],
          'output_quantity' => target_units,
          'production_time_hours' => (blueprint_data[:production_time_hours] || 2.0) * target_units,
          'materials_consumed' => materials_needed.map { |k, v| [k, { amount: v[:amount], composition: v[:composition] }] }.to_h,
          'pve_cycles' => yield_data[:total_water].to_i, # Approximate cycle count
          'byproducts' => yield_data[:byproducts] || []
        }
      )
    end
    
    # Produce final component and add to inventory
    def produce_final_component(job, blueprint_data, target_units, yield_data)
      # Look up real item properties via ItemLookupService (same pattern as Inventory#determine_storage_method)
      lookup = Lookup::ItemLookupService.new.find_item(blueprint_data[:name] || 'Component')
      storage_method = lookup&.dig('storage', 'method') || 'bulk_storage'
      
      # Create the final component item
      component = Item.create!(
        name: blueprint_data[:name] || "Component",
        amount: target_units,
        material_type: :component,
        storage_method: storage_method,
        owner: @settlement.owner,
        inventory: @inventory,
        metadata: {
          'blueprint_name' => blueprint_data[:id],
          'item_type' => blueprint_data[:category] || 'component',
          'production_date' => Time.current,
          'source_materials' => yield_data[:byproducts] || [],
          'job_id' => job.id
        }
      )
      
      # Update job status to ready for claim
      job.update!(status: 'ready_to_claim')
      
      component
    end
    
    # STUB: Private helpers for pile management (consume_from_pile, produce_to_pile)
    # These are now implemented as public methods above for testability
  end
end