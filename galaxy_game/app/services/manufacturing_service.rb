class ManufacturingService
  def self.manufacture(blueprint_name, owner, settlement, count: 1)
    blueprint_service = Lookup::BlueprintLookupService.new
    blueprint_data = blueprint_service.find_blueprint(blueprint_name)
    
    return { success: false, error: "Blueprint not found" } unless blueprint_data
    
    # Check blueprint licensing for players
    if owner.is_a?(Player)
      blueprint_record = owner.blueprints.find_by(name: blueprint_name)
      unless blueprint_record&.can_manufacture?(count)
        return { success: false, error: "Blueprint license exhausted or not owned" }
      end
    end
    
    # Validate owner has access to settlement
    unless settlement.owner == owner || settlement.accessible_by?(owner)
      return { success: false, error: "No access to settlement" }
    end
    
    # Calculate construction cost using settlement's percentage
    purchase_cost = blueprint_data.dig('cost_data', 'purchase_cost', 'amount')
    construction_cost = settlement.calculate_construction_cost(purchase_cost)
    
    # Check if owner can afford the construction cost
    if construction_cost > 0 && !owner.can_afford?(construction_cost)
      return { 
        success: false, 
        error: "Insufficient funds (#{construction_cost} GCC required for construction)" 
      }
    end
    
    # Create the manufacturing job
    job = UnitAssemblyJob.create!(
      unit_type: blueprint_name,
      owner: owner,
      base_settlement: settlement,
      count: count,
      status: 'pending',
      specifications: blueprint_data
    )
    
    # Check material availability
    required_materials = get_required_materials(blueprint_data)
    material_check_result = check_materials(settlement, required_materials, count, owner.is_a?(Player))
    
    if !material_check_result[:success]
      if owner.is_a?(Player)
        # Players must have all materials available
        job.destroy
        return { success: false, error: material_check_result[:message] }
      else
        # AI can create material requests
        create_material_requests(job, required_materials, count)
        job.update(status: 'materials_pending')
      end
    else
      # All materials available, start assembly
      # Change 'materials_ready' to 'in_progress' since that's a valid status
      job.update(status: 'in_progress')
      
      # Set start date and estimated completion
      manufacturing_time = blueprint_data.dig('production_data', 'manufacturing_time_hours') || 24
      job.update(
        start_date: Time.current,
        estimated_completion: Time.current + manufacturing_time.hours
      )
      
      # Consume materials
      consume_materials(settlement, required_materials, count)
    end
    
    # Charge construction cost
    if owner.respond_to?(:charge)
      # If the owner has a charge method (like through FinancialManagement concern)
      owner.charge(construction_cost, "Construction cost for #{blueprint_name}")
    elsif owner.respond_to?(:withdraw)
      # If the owner has a withdraw method (like through an Account)
      owner.withdraw(construction_cost, "Construction cost for #{blueprint_name}")
    elsif owner.respond_to?(:debit)
      # Alternative method name for withdrawing
      owner.debit(construction_cost, "Construction cost for #{blueprint_name}")
    else
      # Look at the owner's account directly
      account = owner.account
      if account
        account.withdraw(construction_cost, "Construction cost for #{blueprint_name}")
      else
        raise "Cannot charge construction cost - no suitable payment method found"
      end
    end
    
    # Return success result
    {
      success: true,
      message: "Manufacturing job started. Construction cost: #{construction_cost} GCC",
      job: job
    }
  end
  
  def self.complete_manufacturing_job(job)
    # Consume licensed runs for player-owned blueprints
    if job.owner.is_a?(Player)
      blueprint_record = job.owner.blueprints.find_by(name: job.unit_type)
      blueprint_record&.consume_runs(job.count)
    end
    
    # Mark job as completed
    job.update(status: 'completed', completed_at: Time.current)
    
    # Add completed items to settlement inventory
    add_completed_items(job.base_settlement, job.unit_type, job.count)
  end
  
  def self.add_completed_items(settlement, item_name, count)
    # Find or create inventory item
    item = settlement.inventory.items.find_or_create_by(name: item_name)
    item.update(amount: item.amount + count)
  end
  
  def self.get_required_materials(blueprint_data)
    # Check both possible locations for required materials
    blueprint_data.dig('production_data', 'required_materials') || 
    blueprint_data['required_materials'] || 
    {}
  end

  def self.check_materials(settlement, required_materials, count, is_player)
    missing_materials = []
    
    if required_materials.is_a?(Hash)
      required_materials.each do |material_name, requirements|
        amount_needed = requirements['amount'] * count
        inventory_item = settlement.inventory.items.find_by(name: material_name)
        
        if !inventory_item || inventory_item.amount < amount_needed
          missing_materials << "#{material_name} (need: #{amount_needed}, have: #{inventory_item&.amount || 0})"
        end
      end
    elsif required_materials.is_a?(Array)
      required_materials.each do |material|
        amount_needed = material['quantity'] * count
        inventory_item = settlement.inventory.items.find_by(name: material['name'])
        
        if !inventory_item || inventory_item.amount < amount_needed
          missing_materials << "#{material['name']} (need: #{amount_needed}, have: #{inventory_item&.amount || 0})"
        end
      end
    end
    
    if missing_materials.any?
      {
        success: false,
        message: "Missing required materials: #{missing_materials.join(', ')}"
      }
    else
      { success: true }
    end
  end

  def self.consume_materials(settlement, required_materials, count)
    if required_materials.is_a?(Hash)
      required_materials.each do |material_name, requirements|
        amount_needed = requirements['amount'] * count
        inventory_item = settlement.inventory.items.find_by(name: material_name)
        inventory_item.update!(amount: inventory_item.amount - amount_needed)
      end
    elsif required_materials.is_a?(Array)
      required_materials.each do |material|
        amount_needed = material['quantity'] * count
        inventory_item = settlement.inventory.items.find_by(name: material['name'])
        inventory_item.update!(amount: inventory_item.amount - amount_needed)
      end
    end
  end

  def self.create_material_requests(job, required_materials, count)
    if required_materials.is_a?(Hash)
      required_materials.each do |material_name, requirements|
        job.material_requests.create!(
          material_name: material_name,
          quantity_requested: requirements['amount'] * count,
          status: 'pending'
        )
      end
    elsif required_materials.is_a?(Array)
      required_materials.each do |material|
        job.material_requests.create!(
          material_name: material['name'],
          quantity_requested: material['quantity'] * count,
          status: 'pending'
        )
      end
    end
  end
end