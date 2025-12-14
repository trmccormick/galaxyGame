module Construction
  class DomeService
    def initialize(entity, crater_dome, service_provider = nil, panel_type = nil)
      @entity = entity
      @crater_dome = crater_dome
      @service_provider = service_provider || entity
      @panel_type = panel_type || "basic_transparent_crater_tube_cover_array"
      @settlement = get_current_settlement
    end

    def schedule_construction
      # Verify we have a valid settlement
      return { success: false, message: "No valid settlement found at location" } unless @settlement

      # 1. Calculate required materials using the unified system
      required_materials = Construction::DomeCalculator.calculate_materials(@crater_dome, @panel_type)

      # 2. Create a construction job
      construction_job = ConstructionJob.create!(
        jobable: @crater_dome,
        job_type: 'crater_dome_construction',
        status: 'materials_pending',
        settlement: @settlement,
        target_values: { 
          panel_type: @panel_type,
          materials_needed: required_materials,
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
        construction_job.update(
          target_values: construction_job.target_values.merge(
            required_materials: required_materials
          )
        )
        []  # No material requests created for settlement
      end
      
      # 4. Handle equipment similarly
      equipment_list = calculate_equipment_requirements
      
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
        payment_result = process_contractor_payment(construction_job)
        return payment_result unless payment_result[:success]
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
        return false unless construction_job.materials_gathered?
        return false unless construction_job.equipment_gathered?
      end
      
      # Update job status
      construction_job.update(status: 'in_progress')
      
      # Calculate estimated time
      estimated_time = calculate_construction_time
      
      # Assign builders
      ConstructionManager.assign_builders(@crater_dome, estimated_time)
      
      # Update dome status
      @crater_dome.update(
        status: "under_construction", 
        estimated_completion: Time.now + estimated_time.hours
      )
      
      true
    end

    def track_progress(construction_job)
      return false unless construction_job.status == 'in_progress'
      
      if ConstructionManager.complete?(@crater_dome)
        complete_construction(construction_job)
        return true
      end
      
      false
    end

    def complete_construction(construction_job)
      # Update job status
      construction_job.update(
        status: 'completed',
        completion_date: Time.now
      )
      
      # Get layer_type from target_values (defaults to 'primary' for backwards compatibility)
      layer_type = construction_job.target_values['layer_type'] || 'primary'
      
      # Update dome status based on layer type
      new_status = determine_completion_status(layer_type)
      
      @crater_dome.update(
        status: new_status
      )
      
      # Release equipment
      Construction::EquipmentManager.release_equipment(construction_job)
      
      true
    end

    private

    def is_player_construction?(construction_job)
      entity_type = construction_job.target_values['owner_type']
      entity_id = construction_job.target_values['owner_id']
      provider_type = construction_job.target_values['service_provider_type']
      provider_id = construction_job.target_values['service_provider_id']
      
      entity_type == provider_type && entity_id == provider_id
    end

    def process_contractor_payment(construction_job)
      # Calculate cost
      construction_cost = Construction::DomeCalculator.calculate_construction_cost(@crater_dome, @panel_type)
      
      # Process transaction
      begin
        TransactionService.process_transaction(
          buyer: @settlement,
          seller: @service_provider,
          amount: construction_cost
        )
        
        # Record transaction info
        construction_job.update(
          target_values: construction_job.target_values.merge({
            payment_amount: construction_cost,
            payment_status: 'paid',
            materials_status: 'provided_by_contractor',
            equipment_status: 'provided_by_contractor'
          })
        )
        
        { success: true }
      rescue StandardError => e
        # Handle payment failure
        construction_job.update(
          target_values: construction_job.target_values.merge({
            payment_status: 'failed',
            payment_error: e.message
          })
        )
        
        { 
          success: false, 
          message: "Payment failed: #{e.message}",
          construction_job: construction_job
        }
      end
    end

    def calculate_equipment_requirements
      [
        { equipment_type: "excavator", quantity: 2 },
        { equipment_type: "construction_vehicle", quantity: 5 },
        { equipment_type: "3d_printer", quantity: 3 }
      ]
    end

    def calculate_construction_time
      Construction::DomeCalculator.estimate_construction_time(@crater_dome, @panel_type)
    end

    def determine_completion_status(layer_type)
      case layer_type
      when 'primary'
        'primary_layer_complete'
      when 'secondary' 
        'secondary_layer_complete'
      when 'both'
        'fully_operational'
      else
        'operational'
      end
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
end