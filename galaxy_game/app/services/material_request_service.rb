class MaterialRequestService
  def self.create_material_requests(construction_job)
    blueprint = construction_job.blueprint
    return [] unless blueprint
    
    # Create a material request for each required material
    material_requests = []
    blueprint.materials.each do |material_name, quantity|
      material_requests << construction_job.material_requests.create!(
        material_name: material_name,
        quantity_requested: quantity,
        status: 'pending'
      )
    end
    
    material_requests
  end
  
  def self.fulfill_request(material_request)
    # Check if inventory has enough of the requested material
    available = Inventory.check(material_request.material_name)
    
    if available >= material_request.quantity_requested
      # Withdraw the materials from inventory
      Inventory.withdraw(material_request.material_name, material_request.quantity_requested)
      
      # Mark request as fulfilled
      material_request.update(
        status: 'fulfilled',
        fulfilled_at: Time.current,
        quantity_fulfilled: material_request.quantity_requested
      )
      
      # Check if all material requests for the job are fulfilled
      construction_job = material_request.construction_job
      all_fulfilled = construction_job.material_requests.all? { |req| req.status == 'fulfilled' }
      
      # If all are fulfilled, we can start construction
      ConstructionJobManager.start_construction(construction_job) if all_fulfilled
      
      return true
    end
    
    # Not enough materials available
    material_request.update(
      status: 'partially_fulfilled',
      quantity_fulfilled: available
    )
    
    false
  end
  
  def self.cancel_request(material_request)
    # Return any fulfilled materials to inventory
    if material_request.quantity_fulfilled > 0
      Inventory.deposit(material_request.material_name, material_request.quantity_fulfilled)
    end
    
    # Mark request as canceled
    material_request.update(
      status: 'canceled'
    )
    
    true
  end

  # New method for pressurization requests
  def self.create_pressurization_requests(enclosed_environment, target_pressure = GameConstants::STANDARD_PRESSURE_KPA)
    # Calculate needed gases for pressurization
    needed_gases = calculate_pressurization_materials(enclosed_environment, target_pressure)
    return [] if needed_gases.empty?
    
    # Create a job to track all the requests
    pressurization_job = EnvironmentJob.create!(
      jobable: enclosed_environment,
      job_type: 'pressurization',
      status: 'materials_pending',
      target_values: { pressure: target_pressure }
    )
    
    # Create a material request for each required gas
    material_requests = []
    needed_gases.each do |gas_name, quantity|
      material_requests << pressurization_job.material_requests.create!(
        material_name: gas_name,
        quantity_requested: quantity,
        status: 'pending',
        priority: 'high' # Atmosphere is high priority
      )
    end
    
    material_requests
  end
  
  # Calculate materials needed for pressurization
  def self.calculate_pressurization_materials(enclosed_environment, target_pressure)
    # Use the PressurizationService to calculate needed gases
    # But don't actually pressurize yet - just get the requirements
    service = PressurizationService.new(enclosed_environment)
    service.calculate_required_gases(target_pressure)
  end
  
  # Helper method to check if a request is for pressurization
  def self.pressurization_request?(material_request)
    material_request.requestable_type == 'EnvironmentJob' && 
    material_request.requestable.job_type == 'pressurization'
  end
  
  # When a pressurization request is fulfilled
  def self.fulfill_pressurization_request(material_request)
    # Similar to regular fulfill_request, but with pressurization handling
    available = Inventory.check(material_request.material_name)
    
    if available >= material_request.quantity_requested
      # Withdraw the materials from inventory
      Inventory.withdraw(material_request.material_name, material_request.quantity_requested)
      
      # Mark request as fulfilled
      material_request.update(
        status: 'fulfilled',
        fulfilled_at: Time.current,
        quantity_fulfilled: material_request.quantity_requested
      )
      
      # Check if all material requests for the job are fulfilled
      pressurization_job = material_request.requestable
      all_fulfilled = pressurization_job.material_requests.all? { |req| req.status == 'fulfilled' }
      
      # If all are fulfilled, we can start pressurization
      if all_fulfilled
        EnvironmentManager.start_pressurization(pressurization_job)
      end
      
      return true
    end
    
    # Not enough materials available
    material_request.update(
      status: 'partially_fulfilled',
      quantity_fulfilled: available
    )
    
    false
  end

  # New method to create requests from a simple hash
  def self.create_material_requests_from_hash(requestable, materials_hash)
    material_requests = []
    
    materials_hash.each do |material_name, quantity|
      material_requests << requestable.material_requests.create!(
        material_name: material_name,
        quantity_requested: quantity,
        status: 'pending',
        priority: determine_priority(material_name)
      )
    end
    
    material_requests
  end
  
  # Helper to determine priority based on material type
  def self.determine_priority(material_name)
    # Critical materials get high priority
    if ['Oxygen', 'Water', 'Food'].include?(material_name)
      'critical'
    # Structural materials get medium-high priority
    elsif ['Steel', 'Glass', 'Aluminum'].include?(material_name)
      'high'
    # Raw materials get medium priority
    elsif ['Planetary Regolith', 'Lunar Regolith', 'Iron Ore'].include?(material_name)
      'medium'
    # Everything else gets low priority
    else
      'low'
    end
  end

  # Keep your existing methods...

  # Add methods from MaterialRequestSystem that you want to preserve
  def self.check_and_request(requestable, required_materials)
    missing_materials = find_missing_materials(requestable, required_materials)
  
    if missing_materials.any?
      create_material_requests_from_hash(requestable, missing_materials)
      return false # Materials are still being gathered
    end
  
    true # All materials are available
  end

  def self.find_missing_materials(requestable, required_materials)
    # Get the settlement from the requestable
    settlement = requestable.respond_to?(:settlement) ? 
                 requestable.settlement : 
                 requestable.respond_to?(:infer_settlement) ? 
                 requestable.infer_settlement : nil
    
    return {} unless settlement&.inventory
                 
    missing = {}
    inventory = settlement.inventory
  
    required_materials.each do |material_name, quantity|
      # Check if the material exists in the inventory
      item = inventory.items.find_by(name: material_name)
      available = item ? item.amount : 0
      
      if available < quantity
        missing[material_name] = quantity - available
      end
    end
  
    missing
  end
  
  # Add a method to optionally trigger resource gathering
  def self.trigger_resource_gathering(settlement, material_name, quantity)
    # This could integrate with your mining, processing, or market systems
    # For now, just log the request
    Rails.logger.info("Resource gathering triggered for #{quantity} of #{material_name} at #{settlement.name}")
    
    # If you have these systems, uncomment and adapt as needed:
    # if defined?(MiningOperation) && MiningOperation.can_extract?(material_name)
    #   MiningOperation.start_extraction(settlement, material_name, quantity)
    # elsif defined?(Refinery) && Refinery.can_process?(material_name)
    #   Refinery.start_processing(settlement, material_name, quantity)
    # elsif defined?(ImportSystem)
    #   ImportSystem.order_import(settlement, material_name, quantity)
    # end
  end
  
  # Add integration with MaterialProcessingService if needed
  def self.process_material_for_request(material_request)
    return false unless material_request.status == 'pending'
    
    # Find a suitable processor unit
    settlement = material_request.settlement
    processor = settlement.units.find_by(unit_type: 'material_processor', status: 'operational')
    
    return false unless processor
    
    # Find raw materials that could be processed
    raw_materials = find_processable_materials(settlement, material_request.material_name)
    
    return false if raw_materials.empty?
    
    # Process the materials
    raw_material = raw_materials.first
    processing_service = MaterialProcessingService.new(processor, raw_material)
    results = processing_service.process_material
    
    # Check if we got what we needed
    if results[:solids].key?(material_request.material_name)
      produced_amount = results[:solids][material_request.material_name]
      
      # If we produced some, update the request
      if produced_amount > 0
        current_fulfilled = material_request.quantity_fulfilled || 0
        new_fulfilled = [current_fulfilled + produced_amount, material_request.quantity_requested].min
        
        material_request.update(
          quantity_fulfilled: new_fulfilled,
          status: new_fulfilled >= material_request.quantity_requested ? 'fulfilled' : 'partially_fulfilled'
        )
        
        return true
      end
    end
    
    false
  end
  
  private
  
  def self.find_processable_materials(settlement, target_material)
    # This would be implementation-specific
    # For now, just return an empty array
    []
  end

  def self.create_material_request(settlement, material_name, quantity)
    # TODO: Prevent duplicate open requests for the same material/settlement
    request = MaterialRequest.create!(
      settlement: settlement,
      material_name: material_name,
      quantity: quantity,
      status: :pending
    )
    PlayerNotifier.notify_material_request(request)
    request
  end

  def self.escalate_unfulfilled_requests
    MaterialRequest.pending.find_each do |request|
      if request.critical? && request.expired_or_urgent?
        AIManager::Manager.fulfill_material_request(request)
        request.update!(status: :fulfilled_by_npc)
      end
    end
  end

  def self.fulfill_by_player(request, player)
    # TODO: Implement logic to transfer material from player to settlement
    # TODO: Reward player for fulfillment
    request.update!(status: :fulfilled_by_player)
  end
end