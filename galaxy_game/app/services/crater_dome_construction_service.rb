# app/services/crater_dome_construction_service.rb
class CraterDomeConstructionService
  def initialize(entity, crater_dome, service_provider = nil, layer_type = 'primary')
    @entity = entity  # Player, Organizations::BaseOrganization, etc.
    @crater_dome = crater_dome
    @service_provider = service_provider || entity  # Default to self-construction
    @layer_type = layer_type
    @settlement = get_current_settlement
  end

  def construct
    # Verify we have a valid settlement
    return { success: false, message: "No valid settlement found at location" } unless @settlement

    # 1. Calculate required materials
    required_materials = calculate_layer_materials(@layer_type)

    # 2. Create a construction job
    construction_job = ConstructionJob.create!(
      jobable: @crater_dome,
      job_type: 'crater_dome_construction',  # Make sure this line is actually running
      status: 'materials_pending',
      settlement: @settlement,
      target_values: { 
        layer_type: @layer_type,
        owner_id: @entity.id,
        owner_type: @entity.class.name,
        service_provider_id: @service_provider.id,
        service_provider_type: @service_provider.class.name
      }
    )
    
    # 3. Handle materials differently based on who's doing the construction
    material_requests = if @entity == @service_provider
      # Player is doing their own construction - create material requests from settlement
      MaterialRequestService.create_material_requests_from_hash(
        construction_job,
        required_materials
      )
    else
      # Construction is contracted out - company handles materials (no settlement requests)
      # Instead, just record what materials are needed for reference
      construction_job.update(
        target_values: construction_job.target_values.merge(
          required_materials: required_materials
        )
      )
      []  # No material requests created for settlement
    end
    
    # 4. Handle equipment similarly
    equipment_list = [
      { equipment_type: "excavator", quantity: 2 },
      { equipment_type: "construction_vehicle", quantity: 5 },
      { equipment_type: "3d_printer", quantity: 3 }
    ]
    
    equipment_requests = if @entity == @service_provider
      # Player doing own construction - create equipment requests
      EquipmentRequestService.create_equipment_requests(
        construction_job,
        equipment_list
      )
    else
      # Contracted construction - company handles equipment (no requests)
      construction_job.update(
        target_values: construction_job.target_values.merge(
          required_equipment: equipment_list
        )
      )
      []  # No equipment requests created
    end
    
    # 5. For contracted construction, process payment immediately
    if @entity != @service_provider
      # Calculate cost
      construction_cost = calculate_construction_cost(@crater_dome, @layer_type)
      
      # Process transaction
      begin
        TransactionService.process_transaction(
          buyer: @settlement,  # Settlement pays, not necessarily the entity
          seller: @service_provider,
          amount: construction_cost
        )
        
        # Record transaction info
        construction_job.update(
          target_values: construction_job.target_values.merge({
            payment_amount: construction_cost,
            payment_status: 'paid',
            # For contracted jobs, materials/equipment are considered fulfilled
            materials_status: 'provided_by_contractor',
            equipment_status: 'provided_by_contractor'
          }),
          status: 'ready_to_start'  # Skip materials/equipment pending states
        )
      rescue StandardError => e
        # Handle payment failure
        construction_job.update(
          target_values: construction_job.target_values.merge({
            payment_status: 'failed',
            payment_error: e.message
          })
        )
        
        return { 
          success: false, 
          message: "Payment failed: #{e.message}",
          construction_job: construction_job
        }
      end
    end
    
    { 
      success: true, 
      message: "Construction job created", 
      construction_job: construction_job,
      material_requests: material_requests,
      equipment_requests: equipment_requests
    }
  end

  def start_construction(construction_job)
    # For player construction, verify materials and equipment
    # For contracted construction, these checks are bypassed
    
    if is_player_construction?(construction_job)
      return false unless materials_gathered?(construction_job)
      return false unless equipment_gathered?(construction_job)
    end
    
    # Update job status
    construction_job.update(status: 'in_progress')
    
    # Calculate estimated time
    estimated_time = calculate_construction_time(construction_job.jobable)
    
    # Update dome status
    construction_job.jobable.update(
      status: "under_construction", 
      estimated_completion: Time.now + estimated_time
    )
    
    true
  end

  def complete_construction(construction_job)
    return "Construction job not in progress" unless construction_job.status == 'in_progress'
    
    # Get the crater dome from the construction job
    dome = construction_job.jobable
    
    # Update job status
    construction_job.update(
      status: 'completed',
      completion_date: Time.now
    )
    
    # Get layer_type from target_values
    layer_type = construction_job.target_values['layer_type'] || @layer_type
    
    # Update dome status based on layer type
    new_status = case layer_type
                 when 'primary'
                   'primary_layer_complete'
                 when 'secondary' 
                   'secondary_layer_complete'
                 when 'both'
                   'fully_operational'
                 else
                   'operational'
                 end
    
    dome.update(
      status: new_status,
      completion_date: Time.now
    )
    
    "Construction complete: #{dome.name} is now #{new_status}"
  end

  private

  def is_player_construction?(construction_job)
    entity_type = construction_job.target_values['owner_type']
    entity_id = construction_job.target_values['owner_id']
    provider_type = construction_job.target_values['service_provider_type']
    provider_id = construction_job.target_values['service_provider_id']
    
    entity_type == provider_type && entity_id == provider_id
  end

  def calculate_layer_materials(layer_type)
    # Get dome dimensions
    diameter = @crater_dome.diameter
    depth = @crater_dome.depth
    
    # Calculate surface area
    surface_area = Math::PI * (diameter/2)**2
    
    # Calculate material needs based on size
    {
      "Steel" => (surface_area * 0.05).ceil,
      "Glass" => (surface_area * 0.02).ceil,
      "Planetary Regolith" => (surface_area * depth * 0.01).ceil
    }
  end
  
  def materials_gathered?(construction_job)
    return true if construction_job.target_values['materials_status'] == 'provided_by_contractor'
    construction_job.material_requests.all? { |req| req.status == 'fulfilled' }
  end

  def equipment_gathered?(construction_job)
    return true if construction_job.target_values['equipment_status'] == 'provided_by_contractor'
    construction_job.equipment_requests.all? { |req| req.status == 'fulfilled' }
  end

  def calculate_construction_cost(crater_dome, layer_type)
    # Base cost calculation
    base_cost = 10000
    diameter = crater_dome.diameter.to_f
    depth = crater_dome.depth.to_f
    
    # Size factor calculation
    size_factor = (Math::PI * (diameter/2)**2 * depth) / 1000
    
    # Complexity factor based on layer type
    complexity_factor = case layer_type
                        when 'primary' then 1.0
                        when 'secondary' then 1.2
                        when 'both' then 2.0
                        else 1.0
                        end
    
    (base_cost + (size_factor * complexity_factor)).round(2)
  end

  def calculate_construction_time(crater_dome)
    # Time calculation
    base_time = 24 # 24 hours minimum
    diameter = crater_dome.diameter.to_f
    depth = crater_dome.depth.to_f
    
    # Size factor
    size_factor = (Math::PI * (diameter/2)**2) / 10
    
    # Difficulty factor
    difficulty = 1 + (depth / 100)
    
    # Calculate total hours
    total_hours = base_time + (size_factor * difficulty)
    total_hours.hours
  end

  def get_current_settlement
    if @crater_dome.settlement
      @crater_dome.settlement
    elsif @crater_dome.location
      Settlement::BaseSettlement.find_by(location: @crater_dome.location)
    else
      nil
    end
  end
end
