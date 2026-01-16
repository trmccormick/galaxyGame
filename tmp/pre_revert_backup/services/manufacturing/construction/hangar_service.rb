class Manufacturing::Construction::HangarService
  def initialize(access_point, hangar_type = "standard_rover_hangar")
    @access_point = access_point
    @hangar_type = hangar_type
    @lava_tube = access_point.lava_tube
    @settlement = @lava_tube&.settlement
    
    # Only large access points can be converted to hangars
    unless @access_point.access_type == 'large'
      raise ArgumentError, "Only large access points can be converted to hangars"
    end
    
    # Get blueprints
    @blueprint = Lookup::BlueprintLookupService.new.find_blueprint(hangar_type)
  end
  
  def schedule_construction
      return { success: false, message: "No settlement found" } unless @settlement
      return { success: false, message: "No blueprint found for #{@hangar_type}" } unless @blueprint
      
      # 1. Calculate materials needed
      materials_needed = calculate_materials
      
      # 2. Create the hangar structure first
      hangar = create_hangar_structure
      
      # 3. Connect the access point to the hangar
      # @access_point.update(
      #   connected_structure: hangar,
      #   conversion_status: 'hangar_planned'
      # )
      # @access_point.update(conversion_status: 'hangar_planned')
      
      # 4. Create the construction job
      construction_job = ConstructionJob.create!(
        jobable: hangar,
        job_type: 'hangar_construction',
        status: 'materials_pending',
        settlement: @settlement,
        target_values: {
          hangar_type: @hangar_type,
          materials_needed: materials_needed,
          access_point_id: @access_point.id
        }
      )
      
      # 5. Create material requests
      material_requests = Manufacturing::MaterialRequest.create_material_requests_from_hash(
        construction_job,
        materials_needed
      )
      
      # 6. Create equipment requests
      equipment_requirements = calculate_equipment_requirements
      equipment_requests = Manufacturing::EquipmentRequest.create_equipment_requests(
        construction_job,
        equipment_requirements
      )
      
      {
        success: true,
        message: "Hangar construction scheduled",
        construction_job: construction_job,
        hangar: hangar,
        material_requests: material_requests,
        equipment_requests: equipment_requests
      }
    end
    
    def start_construction(construction_job)
      return false unless construction_job.materials_gathered?
      return false unless construction_job.equipment_gathered?
      
      # Update construction job status
      construction_job.update(status: 'in_progress')
      
      # Calculate estimated time
      estimated_time = calculate_construction_time
      
      # Assign builders
      Manufacturing::Construction::ConstructionManager.assign_builders(construction_job.jobable, estimated_time)
      
      # Update hangar status
      hangar = construction_job.jobable
      hangar.operational_data['status'] = 'under_construction'
      hangar.save!
      
      # Update access point
      # @access_point.update(conversion_status: 'hangar_under_construction')
      
      true
    end
    
    def track_progress(construction_job)
      return false unless construction_job.status == 'in_progress'
      
      if Manufacturing::Construction::ConstructionManager.complete?(construction_job.jobable)
        # Mark job as complete
        construction_job.update(
          status: 'completed',
          completion_date: Time.now
        )
        
        # Update hangar to operational
        hangar = construction_job.jobable
        hangar.operational_data['status'] = 'operational'
        hangar.save!
        
        # Update access point
        # @access_point.update(conversion_status: 'hangar_operational')
        
        # Release equipment
        EquipmentManager.release_equipment(construction_job)
        
        return true
      end
      
      false
    end
    
    private
    
    def create_hangar_structure
      Structures::Hangar.create!(
        name: "#{@lava_tube.name} #{@hangar_type.titleize}",
        structure_name: @hangar_type.titleize,
        settlement: @settlement,
        owner: @settlement.owner,
        location: @lava_tube,
        container_structure: nil,
        operational_data: {
          structure_type: 'hangar',
          hangar_type: @hangar_type,
          access_point_id: @access_point.id,
          status: 'planned',
          capacity: calculate_capacity
        }
      )
    end
    
    def calculate_materials
      # Base materials from blueprint
      base_materials = @blueprint&.materials || {}
      
      # Add hangar-specific materials based on type
      specific_materials = case @hangar_type
      when "standard_rover_hangar"
        {
          "reinforced_steel" => 5000,
          "structural_components" => 2000,
          "pressurized_doors" => 2,
          "environmental_systems" => 1
        }
      when "small_craft_hangar"
        {
          "reinforced_steel" => 8000,
          "structural_components" => 3500,
          "pressurized_doors" => 3,
          "environmental_systems" => 2,
          "landing_pad_materials" => 1000
        }
      when "large_craft_hangar"
        {
          "reinforced_steel" => 12000,
          "structural_components" => 5000,
          "pressurized_doors" => 4,
          "environmental_systems" => 3,
          "landing_pad_materials" => 2000,
          "advanced_airlock_systems" => 2
        }
      else
        {
          "reinforced_steel" => 3000,
          "structural_components" => 1000,
          "pressurized_doors" => 1
        }
      end
      
      # Merge materials
      base_materials.merge(specific_materials) { |key, base_val, specific_val| base_val.to_i + specific_val }
    end
    
    def calculate_equipment_requirements
      [
        { equipment_type: "3d_printer", quantity: 2 },
        { equipment_type: "construction_drone", quantity: 6 },
        { equipment_type: "assembly_robot", quantity: 3 },
        { equipment_type: "excavation_equipment", quantity: 2 },
        { equipment_type: "materials_transport", quantity: 2 }
      ]
    end
    
    def calculate_construction_time
      # Base time varies by hangar type
      base_hours = case @hangar_type
      when "standard_rover_hangar"
        240 # 10 days
      when "small_craft_hangar"
        360 # 15 days
      when "large_craft_hangar"
        480 # 20 days
      else
        240
      end
      
      base_hours
    end
    
    def calculate_capacity
      case @hangar_type
      when "standard_rover_hangar"
        { rover: 4, small_craft: 0 }
      when "small_craft_hangar"
        { rover: 2, small_craft: 2 }
      when "large_craft_hangar"
        { rover: 0, small_craft: 4 }
      else
        { rover: 2, small_craft: 0 }
      end
    end
end
