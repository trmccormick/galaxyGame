# app/services/manufacturing/construction/covering_service.rb
class Manufacturing::Construction::CoveringService
  attr_reader :coverable, :panel_type, :settlement, :blueprint

  def initialize(coverable, panel_type = nil, settlement = nil)
    @coverable = coverable
    @panel_type = panel_type || default_panel_type
    @settlement = settlement || find_settlement
      @blueprint = find_blueprint(@panel_type)
    end
    
    # Calculate all required materials
    def calculate_materials
      base_materials = Manufacturing::Construction::CoveringCalculator.calculate_materials(@coverable, @blueprint)
      panel_specific_materials = calculate_panel_specific_materials(@panel_type)
      
      # Merge materials, summing quantities for duplicate keys
      base_materials.merge(panel_specific_materials) do |key, base_val, panel_val|
        base_val + panel_val
      end
    end
    
    # Schedule construction job
    def schedule_construction
      return { success: false, message: "Already covered" } if @coverable.covered?
      return { success: false, message: "No settlement" } unless @settlement
      return { success: false, message: "No blueprint found for #{@panel_type}" } unless @blueprint
      
      materials_needed = calculate_materials
      
      # Create construction job
      construction_job = ConstructionJob.create!(
        jobable: @coverable,
        job_type: job_type_name,
        status: 'materials_pending',
        settlement: @settlement,
        blueprint: @blueprint,
        target_values: {
          panel_type: @panel_type,
          materials_needed: materials_needed,
          construction_phase: determine_construction_phase
        }
      )
      
      # Create material requests
      material_requests = Manufacturing::MaterialRequest.create_material_requests_from_hash(
        construction_job,
        materials_needed
      )
      
      # Create equipment requests
      equipment_requirements = calculate_equipment_requirements
      equipment_requests = Manufacturing::EquipmentRequest.create_equipment_requests(
        construction_job,
        equipment_requirements
      )
      
      # Update coverable status
      update_coverable_status('materials_requested', panel_type: @panel_type)
      
      # Set panel_type on the coverable object
      @coverable.panel_type = @panel_type
      
      {
        success: true,
        message: "Construction scheduled for #{@panel_type}",
        construction_job: construction_job,
        materials: materials_needed,
        estimated_time: calculate_construction_time,
        material_requests: material_requests,
        equipment_requests: equipment_requests
      }
    rescue => e
      { success: false, message: "Error scheduling construction: #{e.message}" }
    end
    
    # Start construction when materials are ready
    def start_construction(construction_job)
      return false unless construction_job.materials_gathered?
      return false unless construction_job.equipment_gathered?
      
      construction_job.update(status: 'in_progress')
      
      estimated_time = calculate_construction_time
      Manufacturing::Construction::ConstructionManager.assign_builders(@coverable, estimated_time)
      
      update_coverable_status(
        'under_construction',
        estimated_completion: Time.now + estimated_time.hours,
        notes: "Installing #{@panel_type}"
      )
      
      true
    end
    
    # Track construction progress
    def track_progress(construction_job)
      return false unless construction_job.status == 'in_progress'
      
      if Manufacturing::Construction::ConstructionManager.complete?(@coverable)
        complete_construction(construction_job)
        return true
      end
      
      false
    end
    
    protected
    
    # Override in subclasses for specific defaults
    def default_panel_type
      "modular_structural_panel"
    end
    
    # Override in subclasses to find settlement
    def find_settlement
      @coverable.respond_to?(:settlement) ? @coverable.settlement : nil
    end
    
    # Override in subclasses for specialized materials
    def calculate_panel_specific_materials(panel_type)
      {}
    end
    
    # Override in subclasses for specific job types
    def job_type_name
      'skylight_cover'
    end
    
    # Override in subclasses for phase determination
    def determine_construction_phase
      case coverable_status
      when 'uncovered', 'natural'
        'primary_installation'
      when 'primary_cover'
        'secondary_installation'
      else
        'upgrade_installation'
      end
    end
    
    # Override in subclasses for status completion
    def determine_completion_status(panel_type)
      'covered'
    end
    
    # Calculate construction time
    def calculate_construction_time
      base_time = Manufacturing::Construction::CoveringCalculator.estimate_construction_time(@coverable)
      base_time * complexity_factor
    end
    
    # Override in subclasses for complexity
    def complexity_factor
      1.0
    end
    
    # Calculate equipment needs
    def calculate_equipment_requirements
      printer_requirements = Manufacturing::Construction::CoveringCalculator.calculate_printer_requirements(@coverable)
      
      [
        { equipment_type: "3d_printer", quantity: printer_requirements[:printer_count] },
        { equipment_type: "construction_drone", quantity: 4 },
        { equipment_type: "assembly_robot", quantity: 2 },
        { equipment_type: "materials_transport", quantity: 1 }
      ]
    end
    
    private
    
    def find_blueprint(panel_type)
      Blueprint.find_by(name: panel_type) ||
      Blueprint.find_by(name: "#{panel_type}_blueprint") ||
      Blueprint.find_by(name: "Generic Panel Array")
    end
    
    def update_coverable_status(status, **attributes)
      if @coverable.respond_to?(:update)
        # Determine which status column to use
        status_column = @coverable.respond_to?(:cover_status=) ? :cover_status : :status
        update_attrs = { status_column => status }
        
        new_operational_data = @coverable.operational_data.dup || {}
        
        # Only add attributes that the coverable actually supports
        attributes.each do |key, value|
          case key
          when :panel_type
            if @coverable.respond_to?(:panel_type=)
              update_attrs[key] = value
            elsif @coverable.respond_to?(:operational_data)
              new_operational_data[key.to_s] = value
              # Update shell composition
              new_operational_data['shell_composition'] ||= {}
              new_operational_data['shell_composition'][value] = {
                'count' => 1,
                'area_m2' => @coverable.area_m2
              }
            end
          when :notes
            update_attrs[key] = value if @coverable.respond_to?(:notes=)
          when :construction_date, :estimated_completion
            # Store these in operational_data for structures that don't have these columns
            if @coverable.respond_to?(:operational_data)
              new_operational_data[key.to_s] = value.to_s
            end
          else
            update_attrs[key] = value
          end
        end
        
        update_attrs[:operational_data] = new_operational_data if @coverable.respond_to?(:operational_data)
        
        @coverable.update(update_attrs)
      elsif @coverable.respond_to?(:cover_status=)
        @coverable.update(cover_status: status, **attributes)
      end
    end
    
    def coverable_status
      if @coverable.respond_to?(:status)
        @coverable.status
      elsif @coverable.respond_to?(:cover_status)
        @coverable.cover_status
      else
        'uncovered'
      end
    end
    
    def complete_construction(construction_job)
      panel_type = construction_job.target_values['panel_type']
      
      construction_job.update(
        status: 'completed',
        completion_date: Time.now
      )
      
      new_status = determine_completion_status(panel_type)
      
      update_coverable_status(
        new_status,
        panel_type: panel_type,
        construction_date: Time.now,
        notes: "#{panel_type} installation complete"
      )
      
      Manufacturing::Construction::EquipmentManager.release_equipment(construction_job)
      start_maintenance_systems(new_status)
    end
    
    def start_maintenance_systems(status)
      # Override in subclasses if needed
      MaintenanceMonitorService.start_repair_drones(@coverable, @panel_type) if defined?(MaintenanceMonitorService)
    end
end