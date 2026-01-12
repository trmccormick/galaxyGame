class Manufacturing::EquipmentRequest
  # Create equipment requests for a construction job
  def self.create_equipment_requests(requestable, equipment_list)
    requests = []
    
    equipment_list.each do |equipment_data|
      priority = equipment_data[:priority] || 'normal'
      
      request = requestable.equipment_requests.create!(
        equipment_type: equipment_data[:equipment_type],
        quantity_requested: equipment_data[:quantity] || equipment_data[:quantity_requested],
        priority: priority,
        status: 'pending'
      )
      requests << request
    end
    
    requests
  end
  
  # Check if all equipment requests are fulfilled
  def self.all_equipment_fulfilled?(requestable)
    return false unless requestable
    return true if requestable.equipment_requests.empty?
    
    requestable.equipment_requests.all? { |req| req.status == 'fulfilled' }
  end
  
  # Attempt to fulfill equipment requests from service provider's inventory
  def self.fulfill_from_provider(construction_job)
    return false unless construction_job
    
    # Get service provider info
    provider_type = construction_job.target_values['service_provider_type']
    provider_id = construction_job.target_values['service_provider_id']
    
    return false unless provider_type && provider_id
    
    # Get the provider
    begin
      provider = provider_type.constantize.find(provider_id)
    rescue => e
      Rails.logger.error("Could not find service provider: #{e.message}")
      return false
    end
    
    # Get the provider's inventory
    provider_inventory = provider.inventory
    return false unless provider_inventory
    
    # Get the settlement where construction is happening
    settlement = construction_job.settlement
    return false unless settlement
    
    # Try to fulfill each equipment request
    all_fulfilled = true
    
    construction_job.equipment_requests.each do |request|
      next if request.status == 'fulfilled'
      
      # Check if provider has this equipment in inventory
      equipment_item = provider_inventory.items.find_by(name: request.equipment_type)
      
      if equipment_item && equipment_item.quantity >= request.quantity_requested
        # Provider has the equipment - transfer it to the construction site
        
        # Create or update equipment at settlement
        settlement_item = settlement.inventory.items.find_or_create_by(name: request.equipment_type)
        settlement_item.update(
          quantity: settlement_item.quantity + request.quantity_requested
        )
        
        # Remove from provider's inventory
        equipment_item.update(
          quantity: equipment_item.quantity - request.quantity_requested
        )
        
        # Mark request as fulfilled
        request.update(
          status: 'fulfilled',
          quantity_fulfilled: request.quantity_requested,
          fulfilled_at: Time.current
        )
      else
        # Provider doesn't have this equipment
        all_fulfilled = false
        
        # Optionally trigger a purchase order for the equipment
        if provider.is_a?(Organizations::BaseOrganization) && 
           provider.organization_type == 'corporation'
          
          # Companies could automatically try to buy equipment they're missing
          # This would integrate with your market system
        end
      end
    end
    
    all_fulfilled
  end
  
  # Check local settlement for equipment availability
  def self.check_local_availability(construction_job)
    return false unless construction_job
    
    settlement = construction_job.settlement
    return false unless settlement
    
    settlement_inventory = settlement.inventory
    return false unless settlement_inventory
    
    # Check each equipment request against local inventory
    construction_job.equipment_requests.each do |request|
      next if request.status == 'fulfilled'
      
      item = settlement_inventory.items.find_by(name: request.equipment_type)
      
      if item && item.quantity >= request.quantity_requested
        # Settlement has this equipment
        request.update(
          status: 'fulfilled',
          quantity_fulfilled: request.quantity_requested,
          fulfilled_at: Time.current
        )
      end
    end
    
    # Return true if all requests are now fulfilled
    all_equipment_fulfilled?(construction_job)
  end
  
  # Return equipment to owner after job completion
  def self.return_equipment_after_completion(construction_job)
    return false unless construction_job
    return false unless construction_job.status == 'completed'
    
    provider_type = construction_job.target_values['service_provider_type']
    provider_id = construction_job.target_values['service_provider_id']
    
    return false unless provider_type && provider_id
    
    begin
      provider = provider_type.constantize.find(provider_id)
    rescue => e
      Rails.logger.error("Could not find service provider: #{e.message}")
      return false
    end
    
    settlement = construction_job.settlement
    return false unless settlement
    
    # Return each fulfilled equipment request
    construction_job.equipment_requests.fulfilled.each do |request|
      # Get equipment from settlement
      item = settlement.inventory.items.find_by(name: request.equipment_type)
      
      next unless item && item.quantity >= request.quantity_fulfilled
      
      # Return to provider
      provider_item = provider.inventory.items.find_or_create_by(name: request.equipment_type)
      provider_item.update(
        quantity: provider_item.quantity + request.quantity_fulfilled
      )
      
      # Remove from settlement
      item.update(
        quantity: item.quantity - request.quantity_fulfilled
      )
      
      # Mark request as completed
      request.update(status: 'completed')
    end
    
    true
  end
end