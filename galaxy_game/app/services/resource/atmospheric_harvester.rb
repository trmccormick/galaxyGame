class Resource::AtmosphericHarvester
    def initialize(celestial_body, harvester_unit)
      @celestial_body = celestial_body
      @harvester_unit = harvester_unit
      @atmosphere = celestial_body.atmosphere
    end
  
    # Harvest gases from the atmosphere
    def harvest_gases(gas_name, amount)
      # Check if the gas can be harvested from the atmosphere
      if can_harvest?(gas_name, amount)
        # Use the add_gas and remove_gas methods from the concern to transfer gas
        transfer_gas(gas_name, amount)
        # Optional: Apply some cost to the harvester or update its resources
        update_harvester_resources
      else
        raise "Insufficient gas in the atmosphere for harvesting"
      end
    end
  
    # Harvest dust particles from the atmosphere
    def harvest_dust(amount)
      # Check if dust is present and sufficient for harvesting
      if can_harvest_dust?(amount)
        @atmosphere.decrease_dust(amount)
        # Store harvested dust in harvester (could add to unit storage)
        update_harvester_storage(amount, "dust")
      else
        raise "Insufficient dust in the atmosphere for harvesting"
      end
    end
  
    private
  
    # Check if gas is available and sufficient for harvesting
    def can_harvest?(gas_name, amount)
      gas = @atmosphere.gases.find_by(name: gas_name)
      gas && gas.mass >= amount
    end
  
    # Transfer gas from the atmosphere to the harvester unit
    def transfer_gas(gas_name, amount)
      # Use the `remove_gas` method from the concern to remove gas from atmosphere
      @atmosphere.remove_gas(gas_name, amount)
      
      # Optionally, add gas to the harvester's storage
      # Assuming the harvester unit has some kind of `storage` method
      @harvester_unit.store_material(gas_name, amount)
      
      # Log or trigger events related to the harvest (optional)
      log_harvest_event(gas_name, amount)
    end
  
    # Check if sufficient dust is present for harvesting
    def can_harvest_dust?(amount)
      dust_concentration = @atmosphere.dust['concentration'].to_f
      dust_concentration >= amount
    end
  
    # Store harvested materials (gas or dust) into the harvester's storage
    def update_harvester_storage(amount, material_type)
      # Assuming the harvester unit has a method to store materials
      @harvester_unit.store_material(material_type, amount)
    end
  
    # Optional: Apply cost to harvester unit or update internal resources
    def update_harvester_resources
      @harvester_unit.use_resources_for_harvesting
    end
  
    # Log the harvest event (can be expanded for logging or triggers)
    def log_harvest_event(gas_name, amount)
      # Custom logging or event tracking
      Rails.logger.info("Harvested #{amount} of #{gas_name} from #{@celestial_body.name}")
    end
  end
  
  def complete_contracted_harvesting_job(job)
    # Add harvested resources to inventory
    settlement = job.settlement
    resource_name = job.resource_type
    amount = job.target_amount
    source_location = job.job_data['source_location']
    
    # If this is an atmospheric harvesting job from a place like Titan,
    # we should use the AtmosphericHarvesterService
    if source_location == 'Titan' && ['Methane', 'Nitrogen', 'Ammonia'].include?(resource_name)
      # Get the celestial body
      titan = CelestialBody.find_by(name: 'Titan')
      
      if titan
        # Create a virtual harvester unit to represent the contracted service
        harvester = OpenStruct.new(
          id: "contracted_#{job.id}",
          name: job.job_data['harvester_type'],
          store_material: ->(material, qty) { 
            # Instead of storing in the harvester, we'll add directly to settlement
            item = settlement.inventory.items.find_or_initialize_by(name: material)
            item.amount ||= 0
            item.amount += qty
            item.save!
          },
          use_resources_for_harvesting: -> { true }
        )
        
        # Use the atmospheric harvester service
        begin
          harvester_service = AtmosphericHarvesterService.new(titan, harvester)
          
          # Determine which gas to harvest based on resource name
          gas_name = case resource_name
                    when 'Methane'
                      'methane'
                    when 'Nitrogen'
                      'nitrogen'
                    when 'Ammonia'
                      'ammonia'
                    else
                      resource_name.downcase
                    end
            
          # Harvest the gas
          harvester_service.harvest_gases(gas_name, amount)
          
          Rails.logger.info "[Resource] Atmospheric harvesting completed on Titan: Added #{amount} of #{resource_name} to inventory"
        rescue => e
          # If harvesting fails, still add the resources (simulating the contractor handling issues)
          Rails.logger.warn "[Resource] Atmospheric harvesting error: #{e.message}, but contractor delivered anyway"
          
          # Add to inventory directly
          item = settlement.inventory.items.find_or_initialize_by(name: resource_name)
          item.amount ||= 0
          item.amount += amount
          item.save!
        end
      else
        # If Titan doesn't exist in our database, just add the resources directly
        item = settlement.inventory.items.find_or_initialize_by(name: resource_name)
        item.amount ||= 0
        item.amount += amount
        item.save!
      end
    else
      # For other resources, just add directly
      item = settlement.inventory.items.find_or_initialize_by(name: resource_name)
      item.amount ||= 0
      item.amount += amount
      item.save!
    end
    
    # Mark job as complete
    job.update(
      status: 'completed', 
      completion_date: Time.current,
      job_data: job.job_data.merge('arrival_status' => 'delivered')
    )
    
    Rails.logger.info "[Resource] Contracted harvesting shipment arrived: Added #{amount} of #{resource_name} from #{source_location} to inventory"
    
    # Check for material requests that can be fulfilled
    check_material_requests(settlement, resource_name)
    
    # Trigger event for arrival
    trigger_contracted_shipment_arrived_event(settlement, job)
  end
