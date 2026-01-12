class Resource::Transfer
  # Transfer resources between units
  def self.transfer(source_unit, target_unit, resource_type, amount, options = {})
    # Find source container
    source_container = find_resource_container(source_unit, resource_type)
    return false unless source_container && source_container.amount >= amount
    
    # Find target container
    target_container = find_resource_container(target_unit, resource_type)
    return false unless target_container && target_container.can_accept?(amount)
    
    # Transfer the resource
    source_container.remove(amount)
    target_container.add(amount)
    
    # Log the transfer
    log_transfer(source_unit, target_unit, resource_type, amount, options)
    
    true
  end
  
  def self.continuous_transfer(source_unit, target_unit, resource_type, rate, options = {})
    # Validate umbilical link for craft-to-settlement transfers
    if source_unit.is_a?(Craft::BaseCraft) && target_unit.is_a?(Settlement::BaseSettlement)
      unless umbilical_link_active?(source_unit, target_unit)
        raise ArgumentError, "Cannot establish continuous transfer: no active umbilical link between craft and settlement"
      end
    end
    
    # Create a continuous transfer record
    transfer = ContinuousResourceTransfer.create!(
      source_unit: source_unit,
      target_unit: target_unit,
      resource_type: resource_type,
      rate: rate,
      rate_unit: options[:rate_unit] || 'kg/hour',
      active: true
    )
    
    # Schedule the transfer processing
    ResourceTransferWorker.perform_async(transfer.id)
    
    transfer
  end
  
  # Establish umbilical link between craft and hub
  def self.establish_umbilical_link(craft, hub)
    # Generate shared connection ID
    connection_id = SecureRandom.uuid
    
    # Update craft's operational data
    craft_operational = craft.operational_data || {}
    craft_operational['umbilical_connection'] = {
      'connection_id' => connection_id,
      'hub_id' => hub.id,
      'hub_type' => hub.class.name,
      'established_at' => Time.current,
      'status' => 'active'
    }
    craft.update!(operational_data: craft_operational)
    
    # Update hub's operational data
    hub_operational = hub.operational_data || {}
    hub_operational['umbilical_connections'] ||= {}
    hub_operational['umbilical_connections'][craft.id.to_s] = {
      'connection_id' => connection_id,
      'craft_id' => craft.id,
      'craft_type' => craft.class.name,
      'established_at' => Time.current,
      'status' => 'active'
    }
    hub.update!(operational_data: hub_operational)
    
    connection_id
  end
  
  # Migrate unit from craft to ground settlement rack
  def self.migrate_unit_to_ground(unit, robot, target_storage)
    # Validate robot type (CAR-300)
    unless robot.is_a?(Units::Robot) && robot.mobility_type == 'wheels'
      raise ArgumentError, "Only CAR-300 wheeled robots can perform tank migration"
    end
    
    # Validate unit type (MP-CST)
    unless unit.unit_type == 'mp-cst' || unit.name.include?('Multi-Purpose Cryogenic Storage Tank')
      raise ArgumentError, "Only MP-CST units can be migrated to ground storage"
    end
    
    # Check if robot has sufficient power
    unless robot.has_sufficient_power?
      raise ArgumentError, "Robot does not have sufficient power for migration task"
    end
    
    ActiveRecord::Base.transaction do
      # Update unit location from craft to settlement
      settlement = target_storage.settlement || target_storage
      unit.update!(
        location_id: settlement.id,
        location_type: settlement.class.name,
        attachable: target_storage, # Attach to the storage structure
        operational_data: unit.operational_data.merge(
          'migrated_at' => Time.current,
          'migrated_by_robot' => robot.id,
          'previous_location' => {
            'id' => unit.location_id,
            'type' => unit.location_type
          }
        )
      )
      
      # Log the migration
      MigrationLog.create!(
        unit: unit,
        robot: robot,
        source_location_id: unit.location_id_was,
        source_location_type: unit.location_type_was,
        target_location_id: settlement.id,
        target_location_type: settlement.class.name,
        migration_type: 'tank_to_ground',
        performed_at: Time.current
      )
      
      # Consume robot power
      robot.consume_power(5.0) # 5 kWh for migration task
    end
    
    true
  end
  
  # Check if umbilical link is active between craft and settlement
  def self.umbilical_link_active?(craft, settlement)
    return false unless craft.is_a?(Craft::BaseCraft)
    
    craft_connection = craft.operational_data&.dig('umbilical_connection')
    return false unless craft_connection && craft_connection['status'] == 'active'
    
    # Find the hub connected to this settlement
    hub = settlement.structures.where(type: 'PlanetaryUmbilicalHub').first
    return false unless hub
    
    hub_connections = hub.operational_data&.dig('umbilical_connections') || {}
    hub_connection = hub_connections[craft.id.to_s]
    
    return false unless hub_connection && hub_connection['status'] == 'active'
    
    # Verify connection IDs match
    craft_connection['connection_id'] == hub_connection['connection_id']
  end
  
  private
  
  def self.find_resource_container(unit, resource_type)
    unit.storage_containers.find_by(resource_type: resource_type)
  end
  
  # Get all visible inventory for a settlement (including connected craft)
  def self.settlement_visible_inventory(settlement)
    visible_inventory = {}
    
    # Add settlement's own inventory
    settlement.storage_containers.each do |container|
      visible_inventory[container.resource_type] ||= 0
      visible_inventory[container.resource_type] += container.amount
    end
    
    # Add inventory from umbilically connected craft
    connected_craft = get_umbilically_connected_craft(settlement)
    connected_craft.each do |craft|
      craft_mp_cst_units = craft.base_units.where(unit_type: 'mp-cst')
      craft_mp_cst_units.each do |unit|
        unit.storage_containers.each do |container|
          visible_inventory[container.resource_type] ||= 0
          visible_inventory[container.resource_type] += container.amount
        end
      end
    end
    
    visible_inventory
  end
  
  # Get craft connected to settlement via umbilical
  def self.get_umbilically_connected_craft(settlement)
    hub = settlement.structures.where(type: 'Structures::PlanetaryUmbilicalHub').first
    return [] unless hub
    
    hub.connected_craft
  end
end
