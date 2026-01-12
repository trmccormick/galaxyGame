class Manufacturing::UnitDeployment
  def self.deploy(unit_name, location, options = {})
    # Find the unit blueprint
    blueprint = UnitBlueprint.find_by(name: unit_name)
    return false unless blueprint
    
    # Create the unit
    unit = Unit.create!(
      name: options[:custom_name] || unit_name,
      unit_type: blueprint.unit_type,
      location: location,
      status: 'deployed',
      operational_data: blueprint.default_operational_data.merge(options[:operational_data] || {})
    )
    
    # Set up connections and other unit-specific configurations
    configure_unit(unit, blueprint, options)
    
    unit
  end
  
  def self.deploy_from_inventory(inventory_item, target_location, options = {})
    # Verify this is a deployable item
    return false unless can_deploy?(inventory_item)
    
    # Remove item from inventory first
    inventory = inventory_item.inventory
    return false unless inventory.remove_item(inventory_item.name, 1)
    
    # Get the unit type from the inventory item
    unit_type = extract_unit_type(inventory_item)
    
    # Look up operational data
    unit_lookup = Lookup::UnitLookupService.new
    operational_data = unit_lookup.find_unit(unit_type)
    return false unless operational_data
    
    # Create the active unit
    unit = Units::BaseUnit.create!(
      name: options[:custom_name] || operational_data['name'],
      unit_type: unit_type,
      location: target_location,
      status: 'deployed',
      operational_data: operational_data,
      owner: inventory.inventoryable
    )
    
    # Configure the unit based on operational data
    configure_unit(unit, operational_data, options)
    
    unit
  end
  
  def self.configure_unit(unit, blueprint_or_operational_data, options)
    operational_data = blueprint_or_operational_data.is_a?(UnitBlueprint) ? blueprint_or_operational_data.default_operational_data : blueprint_or_operational_data
    
    # Set up ports based on blueprint
    operational_data['ports']&.each do |port_config|
      unit.ports.create!(
        name: port_config['name'],
        port_type: port_config['type'],
        status: 'disconnected'
      )
    end
    
    # Set up any resource containers
    if operational_data['storage']
      operational_data['storage']['containers']&.each do |container_config|
        unit.storage_containers.create!(
          name: container_config['name'],
          resource_type: container_config['resource_type'],
          capacity: container_config['capacity']
        )
      end
    end
    
    # Initialize any specialized functionality
    case unit.unit_type
    when 'power_generator'
      initialize_power_generator(unit, operational_data)
    when 'cryogenic_storage'
      initialize_cryo_storage(unit, operational_data)
    when 'volatile_processor'
      initialize_volatile_processor(unit, operational_data)
    end
  end
  
  def self.can_deploy?(inventory_item)
    # Check if this is an unassembled unit item
    inventory_item.item_type == "unassembled_unit" ||
    inventory_item.name.start_with?("Unassembled ") ||
    inventory_item.respond_to?(:deployment_data)
  end
  
  def self.extract_unit_type(inventory_item)
    # Try different ways to get the unit type
    if inventory_item.respond_to?(:deployment_data) && inventory_item.deployment_data
      return inventory_item.deployment_data['unit_type']
    end
    
    # Extract from name "Unassembled Raptor Engine" → "raptor_engine"
    if inventory_item.name.start_with?("Unassembled ")
      base_name = inventory_item.name.sub("Unassembled ", "")
      return base_name.downcase.gsub(' ', '_')
    end
    
    # Fallback to item name
    inventory_item.name.downcase.gsub(' ', '_')
  end
  
  # Specialized initialization methods use operational_data instead of blueprint
  def self.initialize_power_generator(unit, operational_data)
    unit.update!(
      power_output: operational_data.dig('power_generation', 'output_kw'),
      fuel_type: operational_data.dig('power_generation', 'fuel_type')
    )
  end
  
  def self.initialize_cryo_storage(unit, operational_data)
    unit.update!(
      storage_capacity: operational_data.dig('storage', 'capacity'),
      operating_temperature: operational_data.dig('storage', 'temperature_k')
    )
  end
  
  def self.initialize_volatile_processor(unit, operational_data)
    unit.update!(
      processing_rate: operational_data.dig('processing', 'rate_per_hour'),
      supported_materials: operational_data.dig('processing', 'supported_materials')
    )
  end
end