class Resource::Acquisition
  def initialize(settlement)
    @settlement = settlement
    @inventory = settlement.inventory
    @location = settlement.location
  end
  
  # Main method for acquiring resources
  def acquire_resource(resource_name, amount, priority = :medium)
    Rails.logger.info "[Resource] Attempting to acquire #{amount} of #{resource_name} (Priority: #{priority})"
    
    # Check if we already have it
    available = @inventory.available(resource_name)
    if available >= amount
      Rails.logger.info "[Resource] Already have sufficient #{resource_name} in inventory (#{available})"
      return { success: true, method: :inventory, amount: amount }
    end
    
    # Try different acquisition methods in order of preference
    result = try_local_harvesting(resource_name, amount) ||
             try_local_processing(resource_name, amount) ||
             try_earth_import(resource_name, amount, priority) ||
             try_contracted_harvesting(resource_name, amount)
    
    # If all methods failed, return failure
    unless result
      Rails.logger.warn "[Resource] Failed to acquire #{resource_name} - no viable method found"
      return { success: false, method: nil, amount: 0 }
    end
    
    result
  end
  
  # Check if resource can be harvested locally on the Moon
  def can_harvest_locally?(resource_name)
    # Limited resources available on the Moon
    lunar_resources = [
      'Lunar Regolith',
      'Lunar Ice',
      'Helium-3',
      'Silicon',
      'Iron',
      'Aluminum',
      'Titanium',
      'Calcium',
      'Magnesium'
    ]
    
    lunar_resources.include?(resource_name) && has_suitable_harvester?(resource_name)
  end
  
  # Check if resource can be processed from lunar materials
  def can_process_locally?(resource_name)
    case resource_name
    when 'Oxygen'
      # Can extract oxygen from lunar regolith
      @inventory.available('Lunar Regolith') >= 10 && has_regolith_processor?
    when 'Water'
      # Can extract water from lunar ice
      @inventory.available('Lunar Ice') >= 1.2 && has_ice_processor?
    when 'Aluminum', 'Iron', 'Titanium'
      # Can extract metals from regolith
      @inventory.available('Lunar Regolith') >= 20 && has_metal_processor?
    when 'Silicon'
      # Can extract silicon from regolith for solar panels
      @inventory.available('Lunar Regolith') >= 15 && has_silicon_processor?
    when 'Steel'
      # Can make steel if we have iron and carbon
      @inventory.available('Iron') >= 0.95 && 
      @inventory.available('Carbon') >= 0.05 && 
      has_metal_processor?
    else
      false
    end
  end
  
  # Check if resource should be imported from Earth
  def should_import_from_earth?(resource_name)
    # Complex manufactured goods, electronics, specialized equipment
    earth_imports = [
      'Electronics',
      'Computer Components',
      'Medical Supplies',
      'Scientific Equipment',
      'Specialized Tools',
      'Seeds',
      'Batteries',
      'Machinery Parts',
      'Carbon Fiber',
      'Plastics',
      'Glass',
      'Food'
    ]
    
    # Check if it's in our Earth imports list
    earth_imports.include?(resource_name)
  end
  
  # Check if resource can be harvested via contracted services (like SpaceX)
  def can_contract_harvesting?(resource_name)
    # Resources that would be harvested from other celestial bodies
    contracted_resources = {
      'Methane' => 'Titan',
      'Nitrogen' => 'Titan',
      'Ammonia' => 'Titan',
      'Hydrogen' => 'Gas Giants',
      'Carbon Dioxide' => 'Mars',
      'Precious Metals' => 'Asteroids'
    }
    
    # Check if this is a resource we would contract for
    contracted_resources.key?(resource_name) && 
    @settlement.credits >= estimate_contract_cost(resource_name, 1)
  end
  
  private
  
  def try_local_harvesting(resource_name, amount)
    return nil unless can_harvest_locally?(resource_name)
    
    # Get harvester type needed
    harvester_type = determine_lunar_harvester_type(resource_name)
    
    # Check if we have that harvester
    available_harvesters = @settlement.units
                                      .where(unit_type: harvester_type)
                                      .where(status: 'idle')
    
    return nil if available_harvesters.empty?
    
    # Simulate harvesting time (longer for rarer materials)
    hours_needed = calculate_lunar_harvesting_time(resource_name, amount)
    
    # Create a resource job
    job = ResourceJob.create!(
      job_type: 'harvesting',
      resource_type: resource_name,
      target_amount: amount,
      settlement: @settlement,
      location: @location,
      status: 'scheduled',
      estimated_completion: Time.current + hours_needed.hours,
      job_data: {
        harvester_type: harvester_type,
        estimated_hours: hours_needed,
        location_name: 'Lunar Surface'
      }
    )
    
    # Assign harvester
    harvester = available_harvesters.first
    harvester.update(
      status: 'working',
      current_job_id: job.id,
      current_job_type: 'ResourceJob'
    )
    
    # Update job
    job.update(
      status: 'in_progress',
      assigned_units: [harvester.id]
    )
    
    Rails.logger.info "[Resource] Started lunar harvesting of #{amount} of #{resource_name}, ETA: #{hours_needed} hours"
    
    { success: true, method: :local_harvesting, amount: amount, job: job, eta: hours_needed.hours }
  end
  
  def try_local_processing(resource_name, amount)
    return nil unless can_process_locally?(resource_name)
    
    # Determine what processor to use
    processor_type = determine_processor_type(resource_name)
    
    # Find an available processor
    processor = @settlement.units
                          .where(unit_type: processor_type)
                          .where(status: 'idle')
                          .first
                          
    return nil unless processor
    
    # Determine source materials needed
    source_materials = determine_source_materials(resource_name)
    
    # Check if we have source materials
    source_materials.each do |source, needed_amount|
      available = @inventory.available(source)
      return nil if available < needed_amount * amount
    end
    
    # Calculate processing time
    hours_needed = calculate_processing_time(resource_name, amount)
    
    # Create job
    job = ResourceJob.create!(
      job_type: 'processing',
      resource_type: resource_name,
      target_amount: amount,
      settlement: @settlement,
      status: 'scheduled',
      estimated_completion: Time.current + hours_needed.hours,
      job_data: {
        processor_type: processor_type,
        source_materials: source_materials
      }
    )
    
    # Consume source materials
    source_materials.each do |source, source_amount|
      source_to_consume = source_amount * (amount / 10.0) # Adjust for output amount
      @inventory.items.find_by(name: source)&.update(
        amount: @inventory.available(source) - source_to_consume
      )
    end
    
    # Assign processor
    processor.update(
      status: 'working',
      current_job_id: job.id,
      current_job_type: 'ResourceJob'
    )
    
    # Update job
    job.update(
      status: 'in_progress',
      assigned_units: [processor.id]
    )
    
    Rails.logger.info "[Resource] Started processing #{amount} of #{resource_name}, ETA: #{hours_needed} hours"
    
    { success: true, method: :processing, amount: amount, job: job, eta: hours_needed.hours }
  end
  
  def try_earth_import(resource_name, amount, priority)
    return nil unless should_import_from_earth?(resource_name)
    
    Rails.logger.info "[Resource] Importing #{amount} of #{resource_name} from Earth (Priority: #{priority})"
    
    # Simulate import time based on priority
    delivery_time = case priority
                   when :critical
                     6.hours
                   when :high
                     12.hours
                   when :medium
                     24.hours
                   else
                     48.hours
                   end
    
    # Create a simulated import job
    job = ResourceJob.create!(
      job_type: 'earth_import',
      resource_type: resource_name,
      target_amount: amount,
      settlement: @settlement,
      status: 'in_progress',
      estimated_completion: Time.current + delivery_time,
      job_data: {
        priority: priority
      }
    )
    
    Rails.logger.info "[Resource] Simulated import order placed for #{amount} #{resource_name}, ETA: #{delivery_time / 1.hour} hours"
    
    { success: true, method: :earth_import, amount: amount, job: job, eta: delivery_time }
  end
  
  def try_contracted_harvesting(resource_name, amount)
    return nil unless can_contract_harvesting?(resource_name)
    
    # Resources that would be harvested from other celestial bodies
    contracted_resources = {
      'Methane' => 'Titan',
      'Nitrogen' => 'Titan',
      'Ammonia' => 'Titan',
      'Hydrogen' => 'Gas Giants',
      'Carbon Dioxide' => 'Mars',
      'Precious Metals' => 'Asteroids'
    }
    
    # Determine the celestial body and contract cost
    celestial_body = contracted_resources[resource_name]
    contract_cost = estimate_contract_cost(resource_name, amount)
    
    return nil unless celestial_body && contract_cost
    
    # Check if we can afford the contract
    if @settlement.credits < contract_cost
      Rails.logger.warn "[Resource] Insufficient credits to contract harvesting: #{contract_cost} needed"
      return nil
    end
    
    # Deduct credits for the contract
    @settlement.update(credits: @settlement.credits - contract_cost)
    
    # Simulate delivery time (longer for outer planets)
    delivery_time = case celestial_body
                   when 'Titan'
                     72.hours
                   when 'Mars'
                     48.hours
                   when 'Gas Giants'
                     96.hours
                   when 'Asteroids'
                     120.hours
                   else
                     24.hours
                   end
    
    # Create a simulated contract job
    job = ResourceJob.create!(
      job_type: 'contracted_harvesting',
      resource_type: resource_name,
      target_amount: amount,
      settlement: @settlement,
      status: 'in_progress',
      estimated_completion: Time.current + delivery_time,
      job_data: {
        celestial_body: celestial_body,
        contract_cost: contract_cost,
        delivery_time: delivery_time
      }
    )
    
    Rails.logger.info "[Resource] Contracted harvesting of #{amount} #{resource_name} from #{celestial_body}, ETA: #{delivery_time / 1.hour} hours"
    
    { success: true, method: :contracted_harvesting, amount: amount, job: job, eta: delivery_time }
  end
  
  def simulate_market_acquisition(resource_name, amount, priority)
    # Simulate market behavior for testing
    Rails.logger.info "[Resource] Simulating market acquisition of #{amount} #{resource_name}"
    
    # Set price based on material type
    material_data = Lookup::MaterialLookupService.new.find_material(resource_name)
    category = material_data&.dig('category') || 'raw_material'
    
    base_price = case category
                when 'ore', 'mineral', 'gas'
                  50
                when 'metal', 'alloy'
                  100
                when 'chemical_compound'
                  150
                when 'component'
                  250
                else
                  75
                end
    
    # Calculate total cost
    total_cost = base_price * amount
    
    # Check if settlement has enough credits
    if @settlement.credits < total_cost
      Rails.logger.warn "[Resource] Insufficient credits for market purchase: #{total_cost} needed"
      return nil
    end
    
    # Deduct credits
    @settlement.update(credits: @settlement.credits - total_cost)
    
    # Simulate delivery time based on priority
    delivery_time = case priority
                   when :critical
                     6.hours
                   when :high
                     12.hours
                   when :medium
                     24.hours
                   else
                     48.hours
                   end
    
    # Create a simulated delivery job
    job = ResourceJob.create!(
      job_type: 'market_delivery',
      resource_type: resource_name,
      target_amount: amount,
      settlement: @settlement,
      status: 'in_progress',
      estimated_completion: Time.current + delivery_time,
      job_data: {
        price_per_unit: base_price,
        total_cost: total_cost,
        delivery_time: delivery_time
      }
    )
    
    Rails.logger.info "[Resource] Simulated market order placed for #{amount} #{resource_name}, ETA: #{delivery_time / 1.hour} hours"
    
    { success: true, method: :market, amount: amount, job: job, eta: delivery_time }
  end
  
  # Helper methods
  
  def has_suitable_harvester?(resource_name)
    harvester_type = determine_harvester_type(resource_name)
    @settlement.units.where(unit_type: harvester_type).exists?
  end
  
  def determine_harvester_type(resource_name)
    material_data = Lookup::MaterialLookupService.new.find_material(resource_name)
    
    category = material_data&.dig('category') || ''
    
    case category
    when 'gas', 'atmosphere'
      'atmospheric_gas_harvester'
    when 'ore', 'mineral'
      'automated_planetary_mining_harvester'
    when 'liquid'
      'liquid_extraction_harvester'
    when 'ice'
      'ice_harvester'
    else
      'automated_planetary_mining_harvester' # Default
    end
  end
  
  def determine_lunar_harvester_type(resource_name)
    # Simplified harvester determination for lunar resources
    case resource_name
    when 'Lunar Regolith'
      'lunar_regolith_harvester'
    when 'Lunar Ice'
      'lunar_ice_harvester'
    when 'Helium-3'
      'helium3_extractor'
    else
      'lunar_regolith_harvester' # Default for Moon
    end
  end
  
  def determine_processor_type(resource_name)
    material_data = Lookup::MaterialLookupService.new.find_material(resource_name)
    category = material_data&.dig('category') || ''
    
    case category
    when 'metal', 'alloy'
      'metal_smelter'
    when 'chemical_compound'
      'chemical_processor'
    when 'component'
      'component_fabricator'
    else
      'generic_processor'
    end
  end
  
  def has_regolith_processor?
    @settlement.units.where(unit_type: 'regolith_processor').exists?
  end
  
  def has_ice_processor?
    @settlement.units.where(unit_type: 'ice_processor').exists?
  end
  
  def has_metal_processor?
    @settlement.units.where(unit_type: 'metal_processor').exists?
  end
  
  def determine_source_materials(resource_name)
    # Simplified source material determination
    case resource_name
    when 'Oxygen'
      { 'Lunar Regolith' => 10 }
    when 'Water'
      { 'Lunar Ice' => 1.2 }
    when 'Aluminum', 'Iron', 'Titanium'
      { 'Lunar Regolith' => 20 }
    when 'Silicon'
      { 'Lunar Regolith' => 15 }
    when 'Steel'
      { 'Iron' => 0.95, 'Carbon' => 0.05 }
    else
      {}
    end
  end
  
  def estimate_contract_cost(resource_name, amount)
    # Simplified cost estimation for contracts
    base_cost = case resource_name
               when 'Methane', 'Nitrogen', 'Ammonia'
                 1000
               when 'Hydrogen'
                 500
               when 'Carbon Dioxide'
                 200
               when 'Precious Metals'
                 5000
               else
                 100
               end
    
    base_cost * amount
  end
  
  def calculate_lunar_harvesting_time(resource_name, amount)
    # Basic formula: larger amounts take longer
    harvester_type = determine_lunar_harvester_type(resource_name)
    
    # Base rate in kg per hour
    base_rate = case harvester_type
                when 'lunar_regolith_harvester'
                  30.0
                when 'lunar_ice_harvester'
                  20.0
                when 'helium3_extractor'
                  10.0
                else
                  15.0
                end
    
    # Calculate hours needed
    (amount / base_rate).ceil
  end
  
  def calculate_processing_time(resource_name, amount)
    # Base processing time in hours
    material_data = Lookup::MaterialLookupService.new.find_material(resource_name)
    complexity = material_data&.dig('processing_complexity') || 1.0
    
    # More complex materials take longer
    base_time = 2.0 * complexity
    
    # Scale with amount, but with diminishing returns
    (base_time * Math.sqrt(amount / 10.0)).ceil
  end
  
  def calculate_manufacturing_time(resource_name, amount)
    # Similar to processing but possibly longer
    material_data = Lookup::MaterialLookupService.new.find_material(resource_name)
    complexity = material_data&.dig('manufacturing_complexity') || 1.5
    
    # Manufacturing is generally more complex
    base_time = 3.0 * complexity
    
    # Scale with amount, but with diminishing returns
    (base_time * Math.sqrt(amount / 5.0)).ceil
  end
end