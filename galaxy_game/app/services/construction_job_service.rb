class ConstructionJobService
  # Create a new construction job
  def self.create_job(jobable, job_type, options = {})
    # Create the job record
    job = ConstructionJob.create!(
      jobable: jobable,
      job_type: job_type,
      status: 'scheduled',
      settlement: jobable.try(:settlement) || options[:settlement],
      blueprint_id: options[:blueprint_id],
      target_values: options[:target_values] || {}
    )
    
    # Handle different job types
    case job_type
    when 'crater_dome_construction'
      setup_dome_construction(job)
    when 'skylight_cover'
      setup_skylight_construction(job)
    when 'access_point_conversion'
      setup_access_point_construction(job)
    when 'pressurization'
      setup_pressurization(job)
    end
    
    job
  end
  
  # Process all pending jobs (called by a scheduled task)
  def self.process_jobs
    # Process material requests
    process_material_requests
    
    # Process equipment requests
    process_equipment_requests
    
    # Start jobs that have resources ready
    start_ready_jobs
    
    # Update progress on in-progress jobs
    update_job_progress
    
    # Complete jobs that are finished
    complete_finished_jobs
  end
  
  # Material request management
  def self.process_material_requests
    MaterialRequest.pending_requests.each do |request|
      # Try to fulfill from inventory
      fulfill_material_request(request)
    end
  end
  
  # Equipment request management
  def self.process_equipment_requests
    EquipmentRequest.pending_requests.each do |request|
      # Try to fulfill from available equipment
      fulfill_equipment_request(request)
    end
  end
  
  # Starting jobs when ready
  def self.start_ready_jobs
    ConstructionJob.where(status: 'materials_pending').each do |job|
      next unless resources_ready?(job)
      
      # Start the construction
      start_construction(job)
    end
  end
  
  # Update progress on running jobs
  def self.update_job_progress
    ConstructionJob.in_progress.each do |job|
      update_construction_progress(job)
    end
  end
  
  # Complete jobs that are finished
  def self.complete_finished_jobs
    ConstructionJob.in_progress.each do |job|
      next unless construction_complete?(job)
      
      finalize_construction(job)
    end
  end
  
  # Specific methods for different job types
  
  # Setup methods for different construction types
  def self.setup_dome_construction(job)
    # Get the dome from the job
    dome = job.jobable
    
    # Calculate materials
    materials = calculate_dome_materials(dome)
    
    # Create material requests
    create_material_requests(job, materials)
    
    # Create equipment requests
    create_equipment_requests_for_dome(job, dome)
    
    # Update job status
    job.update(status: 'materials_pending')
  end
  
  def self.setup_skylight_construction(job)
    skylight = job.jobable
    panel_type = job.target_values['panel_type']
    
    # Calculate materials for the skylight cover
    materials = calculate_skylight_materials(skylight, panel_type)
    
    # Create material requests
    create_material_requests(job, materials)
    
    # Create equipment requests (e.g., 3D printers)
    create_equipment_requests_for_skylight(job, skylight)
    
    # Update job status
    job.update(status: 'materials_pending')
  end
  
  # Helper methods
  
  def self.resources_ready?(job)
    job.material_requests.all? { |req| req.status == 'fulfilled' } &&
    job.equipment_requests.all? { |req| req.status == 'fulfilled' }
  end
  
  def self.start_construction(job)
    # Reserve all materials and equipment
    reserve_materials(job)
    reserve_equipment(job)
    
    # Calculate estimated completion time
    completion_time = calculate_completion_time(job)
    
    # Update job
    job.update(
      status: 'in_progress',
      start_date: Time.current,
      estimated_completion: Time.current + completion_time
    )
    
    # Update the jobable object status
    update_jobable_status(job, 'under_construction')
  end
  
  def self.update_construction_progress(job)
    return unless job.in_progress?
    
    # Calculate progress based on time
    elapsed = Time.current - job.started_at
    total_duration = job.estimated_completion - job.started_at
    
    # Avoid division by zero
    return if total_duration <= 0
    
    progress = (elapsed / total_duration * 100).round
    progress = [progress, 99].min # Cap at 99% until formally completed
    
    # Update job progress
    job.update(progress: progress)
    
    # Update the jobable with progress information
    update_jobable_progress(job, progress)
  end
  
  def self.construction_complete?(job)
    return false unless job.in_progress?
    return true if job.estimated_completion <= Time.current
    
    # Could also check for manual completion or other conditions
    false
  end
  
  def self.finalize_construction(job)
    # Complete the construction based on job type
    case job.job_type
    when 'crater_dome_construction'
      complete_dome_construction(job)
    when 'skylight_cover'
      complete_skylight_construction(job)
    when 'access_point_conversion'
      complete_access_point_construction(job)
    when 'pressurization'
      complete_pressurization(job)
    end
    
    # Update job status
    job.update(
      status: 'completed',
      completed_at: Time.current,
      progress: 100
    )
    
    # Release any equipment
    release_equipment(job)
  end
  
  # Implementation for specific job types
  
  def self.complete_dome_construction(job)
    dome = job.jobable
    
    # Set owner from stored values
    if job.target_values['owner_id'] && job.target_values['owner_type']
      owner_id = job.target_values['owner_id']
      owner_type = job.target_values['owner_type']
      owner = owner_type.constantize.find(owner_id) rescue nil
      dome.owner = owner if owner
    end
    
    # Update dome status
    dome.update(
      status: "#{job.target_values['layer_type'] || 'primary'}_layer_complete",
      completion_date: Time.current
    )
    
    # Associate with settlement if not already
    if dome.respond_to?(:settlement) && !dome.settlement && dome.location
      settlement = Settlement::BaseSettlement.find_by(location: dome.location)
      dome.update(settlement: settlement) if settlement
    end
  end
  
  def self.complete_skylight_construction(job)
    skylight = job.jobable
    panel_type = job.target_values['panel_type']
    
    # Update skylight status based on panel type
    if panel_type == 'basic_transparent_crater_tube_cover_array'
      skylight.update(status: 'primary_cover')
    elsif panel_type == 'structural_cover_panel'
      skylight.update(status: 'full_cover')
    else
      skylight.update(status: 'complete')
    end
    
    # Start maintenance systems if needed
    start_maintenance_for_skylight(skylight, panel_type)
  end
  
  # Helper methods for material management
  
  def self.create_material_requests(job, materials)
    materials.each do |material_name, quantity|
      job.material_requests.create!(
        material_name: material_name,
        quantity_requested: quantity,
        status: 'pending',
        priority: determine_priority(material_name)
      )
    end
  end
  
  def self.fulfill_material_request(request)
    # Check if material is available in inventory
    settlement = request.requestable.settlement
    return false unless settlement&.inventory
    
    # Find the material in inventory
    material = settlement.inventory.items.find_by(name: request.material_name)
    return false unless material
    
    # Check if we have enough
    if material.amount >= request.quantity_requested
      # Mark as fulfilled (but don't withdraw yet)
      request.update(
        status: 'fulfilled',
        fulfilled_at: Time.current
      )
      return true
    elsif material.amount > 0
      # Mark as partially fulfilled
      request.update(
        status: 'partially_fulfilled',
        quantity_fulfilled: material.amount
      )
    end
    
    false
  end
  
  def self.reserve_materials(job)
    # Actually withdraw materials from inventory
    settlement = job.settlement
    return false unless settlement&.inventory
    
    job.material_requests.fulfilled.each do |request|
      material = settlement.inventory.items.find_by(name: request.material_name)
      next unless material
      
      # Withdraw the requested amount
      material.update(amount: material.amount - request.quantity_requested)
    end
  end
  
  # And similar methods for equipment management...
  
  private
  
  def self.calculate_dome_materials(dome)
    # Calculate based on dome dimensions
    {
      "Steel" => dome.diameter * 2,
      "Glass" => dome.diameter * dome.depth * 0.1,
      "Planetary Regolith" => dome.diameter * dome.depth * 0.5
    }
  end
  
  def self.calculate_skylight_materials(skylight, panel_type)
    # Use existing calculator - pass nil for blueprint since we're calculating from dimensions
    Manufacturing::Construction::CoveringCalculator.calculate_materials(skylight, nil)
  end
  
  def self.create_equipment_requests_for_dome(job, dome)
    # TODO: Implement equipment request creation for dome construction
    # For now, no equipment requests needed
  end
  
  def self.create_equipment_requests_for_skylight(job, skylight)
    # TODO: Implement equipment request creation for skylight construction
    # For now, no equipment requests needed
  end
  
  def self.reserve_materials(job)
    # TODO: Implement material reservation logic
    # For now, assume materials are available since we're auto-fulfilling
  end
  
  def self.reserve_equipment(job)
    # TODO: Implement equipment reservation logic
    # For now, assume equipment is available since we're auto-fulfilling
  end
  
  def self.calculate_completion_time(job)
    case job.job_type
    when 'crater_dome_construction'
      # Base time plus factors for size
      dome = job.jobable
      base_time = 24.hours
      size_factor = (dome.diameter * dome.depth) / 5000.0
      base_time * [size_factor, 1.0].max
    when 'skylight_cover'
      # Base time plus factors for skylight size
      skylight = job.jobable
      base_time = 8.hours
      size_factor = (skylight.diameter_m ** 2) / 100.0
      base_time * [size_factor, 1.0].max
    else
      # Default time for other job types
      24.hours
    end
  end
  
  def self.update_jobable_status(job, status)
    jobable = job.jobable
    jobable.update(status: status) if jobable.respond_to?(:status=)
  end
  
  def self.update_jobable_progress(job, progress)
    jobable = job.jobable
    jobable.update(progress: progress) if jobable.respond_to?(:progress=)
  end
  
  def self.start_maintenance_for_skylight(skylight, panel_type)
    # Implementation for starting maintenance systems
  end
  
  def self.release_equipment(job)
    # Find all equipment reserved for this job
    Equipment.where(
      reserved_for_id: job.id,
      reserved_for_type: job.class.name
    ).update_all(
      status: 'available',
      reserved_for_id: nil,
      reserved_for_type: nil
    )
  end
  
  def self.determine_priority(material_name)
    # Same priority determination as before
    if ['Oxygen', 'Water', 'Food'].include?(material_name)
      'critical'
    elsif ['Steel', 'Glass', 'Aluminum'].include?(material_name)
      'high'
    elsif ['Planetary Regolith', 'Lunar Regolith', 'Iron Ore'].include?(material_name)
      'normal'
    else
      'low'
    end
  end
end