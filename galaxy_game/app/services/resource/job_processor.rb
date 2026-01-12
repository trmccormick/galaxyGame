class Resource::JobProcessor
  def self.process_jobs
    # Process jobs that are ready to complete
    complete_ready_jobs
    
    # Check for new resource jobs that can be started
    start_pending_jobs
    
    # Check for arrivals from Earth or contracted services
    check_for_arrivals
  end
  
  def self.complete_ready_jobs
    # Find jobs that should be complete based on estimated time
    ready_jobs = ResourceJob.where(status: 'in_progress')
                            .where('estimated_completion <= ?', Time.current)
    
    ready_jobs.each do |job|
      complete_job(job)
    end
  end
  
  def self.start_pending_jobs
    # Find scheduled jobs that are ready to start
    pending_jobs = ResourceJob.where(status: 'scheduled')
    
    pending_jobs.each do |job|
      # Check if the job can be started (units assigned, etc.)
      start_job(job) if can_start_job?(job)
    end
  end
  
  def self.check_for_arrivals
    # Check for any arrivals from Earth or contracted services
    # These jobs are already in progress but might arrive early or late
    
    # Earth imports
    earth_imports = ResourceJob.where(job_type: 'earth_import', status: 'in_progress')
    earth_imports.each do |job|
      # Check if it's time for the shipment to arrive
      if job.estimated_completion <= Time.current
        complete_job(job)
      elsif rand < 0.01 # 1% chance per check of early arrival
        # Shipment arrived early!
        Rails.logger.info "[Resource] Earth shipment arrived early: #{job.resource_type}"
        complete_job(job)
      elsif rand < 0.02 && job.estimated_completion <= Time.current + 5.days # 2% chance of delay
        # Shipment delayed
        new_eta = job.estimated_completion + rand(1..7).days
        job.update(
          estimated_completion: new_eta,
          job_data: job.job_data.merge(
            'delay_reason' => ['Weather on Earth', 'Launch scheduling issues', 'Technical problems', 'Customs delay'].sample,
            'original_eta' => job.estimated_completion
          )
        )
        Rails.logger.info "[Resource] Earth shipment delayed: #{job.resource_type}, new ETA: #{new_eta.strftime('%Y-%m-%d')}"
      end
    end
    
    # Contracted harvesting
    contract_jobs = ResourceJob.where(job_type: 'contracted_harvesting', status: 'in_progress')
    contract_jobs.each do |job|
      # Check if it's time for the harvested materials to arrive
      if job.estimated_completion <= Time.current
        complete_job(job)
      elsif rand < 0.005 # 0.5% chance per check of early arrival
        # Harvesting completed ahead of schedule!
        Rails.logger.info "[Resource] Contracted harvesting completed early: #{job.resource_type} from #{job.job_data['source_location']}"
        complete_job(job)
      elsif rand < 0.03 && job.estimated_completion <= Time.current + 10.days # 3% chance of delay
        # Harvesting delayed
        new_eta = job.estimated_completion + rand(5..30).days
        job.update(
          estimated_completion: new_eta,
          job_data: job.job_data.merge(
            'delay_reason' => ['Harvester malfunction', 'Solar storm', 'Orbital complications', 'Equipment failure'].sample,
            'original_eta' => job.estimated_completion
          )
        )
        Rails.logger.info "[Resource] Contracted harvesting delayed: #{job.resource_type}, new ETA: #{new_eta.strftime('%Y-%m-%d')}"
      end
    end
  end
  
  def self.complete_job(job)
    # Process completion based on job type
    case job.job_type
    when 'harvesting'
      complete_harvesting_job(job)
    when 'processing'
      complete_processing_job(job)
    when 'earth_import'
      complete_earth_import_job(job)
    when 'contracted_harvesting'
      complete_contracted_harvesting_job(job)
    end
  end
  
  def self.complete_harvesting_job(job)
    # Add harvested resources to inventory
    settlement = job.settlement
    resource_name = job.resource_type
    amount = job.target_amount
    
    # Find or create inventory item
    item = settlement.inventory.items.find_or_initialize_by(name: resource_name)
    item.amount ||= 0
    item.amount += amount
    item.save!
    
    # Release harvester
    release_units(job)
    
    # Mark job as complete
    job.update(status: 'completed', completion_date: Time.current)
    
    Rails.logger.info "[Resource] Harvesting job completed: Added #{amount} of #{resource_name} to inventory"
    
    # Check for material requests that can be fulfilled
    check_material_requests(settlement, resource_name)
  end
  
  def self.complete_processing_job(job)
    # Add processed resources to inventory
    settlement = job.settlement
    resource_name = job.resource_type
    amount = job.target_amount
    
    # Find or create inventory item
    item = settlement.inventory.items.find_or_initialize_by(name: resource_name)
    item.amount ||= 0
    item.amount += amount
    item.save!
    
    # Release processor
    release_units(job)
    
    # Mark job as complete
    job.update(status: 'completed', completion_date: Time.current)
    
    Rails.logger.info "[Resource] Processing job completed: Added #{amount} of #{resource_name} to inventory"
    
    # Check for material requests that can be fulfilled
    check_material_requests(settlement, resource_name)
  end
  
  def self.complete_earth_import_job(job)
    # Add imported resources to inventory
    settlement = job.settlement
    resource_name = job.resource_type
    amount = job.target_amount
    
    # Find or create inventory item
    item = settlement.inventory.items.find_or_initialize_by(name: resource_name)
    item.amount ||= 0
    item.amount += amount
    item.save!
    
    # Mark job as complete
    job.update(
      status: 'completed', 
      completion_date: Time.current,
      job_data: job.job_data.merge('arrival_status' => 'delivered')
    )
    
    Rails.logger.info "[Resource] Earth import arrived: Added #{amount} of #{resource_name} to inventory"
    
    # Check for material requests that can be fulfilled
    check_material_requests(settlement, resource_name)
    
    # Trigger event for arrival (could be used for notifications, etc.)
    trigger_shipment_arrived_event(settlement, job)
  end
  
  def self.complete_contracted_harvesting_job(job)
    # Add harvested resources to inventory
    settlement = job.settlement
    resource_name = job.resource_type
    amount = job.target_amount
    
    # Find or create inventory item
    item = settlement.inventory.items.find_or_initialize_by(name: resource_name)
    item.amount ||= 0
    item.amount += amount
    item.save!
    
    # Release harvester units
    release_units(job)
    
    # Mark job as complete
    job.update(status: 'completed', completion_date: Time.current)
    
    Rails.logger.info "[Resource] Contracted harvesting job completed: Added #{amount} of #{resource_name} to inventory"
    
    # Check for material requests that can be fulfilled
    check_material_requests(settlement, resource_name)
  end
  
  def self.start_job(job)
    # Start the job based on type
    case job.job_type
    when 'harvesting', 'processing', 'manufacturing'
      # These jobs are started when units are assigned
      job.update(status: 'in_progress', started_at: Time.current)
    when 'market_delivery'
      # Market deliveries are already in progress when created
      # Nothing to do here
    end
  end
  
  def self.can_start_job?(job)
    # Check if job can be started
    case job.job_type
    when 'harvesting', 'processing', 'manufacturing'
      # Check if units are assigned
      !job.assigned_units.empty?
    when 'market_delivery'
      # Market deliveries are always ready
      true
    else
      false
    end
  end
  
  def self.release_units(job)
    # Get unit IDs from job
    unit_ids = job.assigned_units
    
    # Release each unit
    unit_ids.each do |unit_id|
      unit = Units::BaseUnit.find_by(id: unit_id)
      next unless unit
      
      unit.update(
        status: 'idle',
        current_job_id: nil,
        current_job_type: nil
      )
    end
  end
  
  def self.check_material_requests(settlement, resource_name)
    # Find pending requests for this material
    pending_requests = MaterialRequest.pending_requests
                                      .where(material_name: resource_name)
                                      .where(requestable_type: ['ConstructionJob', 'UnitAssemblyJob'])
                                      .where(requestable_id: settlement.construction_jobs.pluck(:id) + 
                                                             settlement.unit_assembly_jobs.pluck(:id))
    
    pending_requests.each do |request|
      # Check if we now have enough
      available = settlement.inventory.available(resource_name)
      
      if available >= request.quantity_requested
        # Mark as fulfilled
        request.update(
          status: 'fulfilled',
          fulfilled_at: Time.current
        )
        
        Rails.logger.info "[Resource] Material request for #{request.quantity_requested} #{resource_name} fulfilled"
      elsif available > 0
        # Mark as partially fulfilled
        request.update(
          status: 'partially_fulfilled',
          quantity_fulfilled: available
        )
      end
    end
  end
end