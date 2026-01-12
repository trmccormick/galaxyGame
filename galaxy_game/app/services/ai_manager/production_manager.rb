module AIManager
  class ProductionManager
    def initialize(settlement)
      @settlement = settlement
      @inventory = settlement.inventory
      @location = settlement.location
      @resource_service = Resource::Acquisition.new(settlement)
    end
    
    # Main method to handle all production/resource needs
    def manage_resources_for_construction(construction_plan)
      Rails.logger.info "[AI Production] Starting resource management for plan: #{construction_plan['plan_name']}"
      
      # 1. Gather all required materials from the plan
      required_materials = calculate_required_materials(construction_plan)
      
      # 2. Check what we already have in inventory
      missing_materials = identify_missing_materials(required_materials)
      
      # 3. Prioritize missing materials
      prioritized_materials = prioritize_materials(missing_materials)
      
      # 4. For each missing material, determine acquisition strategy
      acquisition_results = acquire_missing_materials(prioritized_materials)
      
      # 5. Ensure we have construction units
      ensure_construction_units(construction_plan)
      
      # 6. Create construction jobs for what we can build now
      create_construction_jobs(construction_plan)
      
      # Return summary of actions taken
      {
        required_materials: required_materials,
        missing_materials: missing_materials,
        acquisition_results: acquisition_results
      }
    end
    
    # Calculate all materials needed for the plan
    def calculate_required_materials(construction_plan)
      required_materials = {}
      
      construction_plan['recommended_units_to_build'].each do |item|
        # Get blueprint for this unit type
        blueprint = find_blueprint_for_unit(item['unit_type'], item['variant'])
        next unless blueprint
        
        # Calculate materials needed for this quantity
        materials = blueprint['materials'] || {}
        materials.each do |material, amount|
          # Multiply by count and add to total
          required_materials[material] = (required_materials[material] || 0) + (amount * item['count'])
        end
      end
      
      required_materials
    end
    
    # Check what materials we're missing
    def identify_missing_materials(required_materials)
      missing = {}
      
      required_materials.each do |material, amount|
        # Check inventory
        available = @inventory.available(material)
        
        # If we don't have enough, mark as missing
        if available < amount
          missing[material] = amount - available
        end
      end
      
      missing
    end
    
    # Prioritize materials based on importance and acquisition method
    def prioritize_materials(missing_materials)
      # Group by priority
      prioritized = {
        critical: {},
        high: {},
        medium: {},
        low: {}
      }
      
      missing_materials.each do |material, amount|
        priority = determine_priority(material)
        prioritized[priority][material] = amount
      end
      
      # Convert back to a flat list, but ordered by priority
      ordered_materials = {}
      
      [:critical, :high, :medium, :low].each do |priority|
        ordered_materials.merge!(prioritized[priority])
      end
      
      ordered_materials
    end
    
    # Acquire missing materials through various methods
    def acquire_missing_materials(prioritized_materials)
      results = []
      
      prioritized_materials.each do |material, amount|
        # Determine priority
        priority = determine_priority(material)
        
        # Attempt to acquire the material
        result = @resource_service.acquire_resource(material, amount, priority)
        
        results << {
          material: material,
          amount: amount,
          success: result[:success],
          method: result[:method],
          eta: result[:eta]
        }
      end
      
      results
    end
    
    # Make sure we have required construction units
    def ensure_construction_units(construction_plan)
      required_units = determine_required_construction_units(construction_plan)
      
      required_units.each do |unit_type, count|
        # Check how many we currently have
        current_count = @settlement.units.where(unit_type: unit_type).count
        
        # If we need more, build them
        if current_count < count
          units_to_build = count - current_count
          build_construction_units(unit_type, units_to_build)
        end
      end
    end
    
    # Create construction jobs for items we can build
    def create_construction_jobs(construction_plan)
      construction_plan['recommended_units_to_build'].each do |item|
        # Check if we can build this now (have the required materials)
        next unless can_build_now?(item)
        
        # Create the appropriate construction job
        case item['unit_type']
        when 'dome'
          create_dome_construction_request(item)
        when 'skylight_cover'
          create_skylight_construction_requests(item)
        when 'access_point'
          create_access_point_construction_requests(item)
        when 'habitat_module'
          create_habitat_construction_request(item)
        end
      end
    end
    
    # Check if we can build a unit now (have all materials)
    def can_build_now?(item)
      blueprint = find_blueprint_for_unit(item['unit_type'], item['variant'])
      return false unless blueprint
      
      # Check if we have all the materials
      materials = blueprint['materials'] || {}
      materials.all? do |material, amount|
        total_needed = amount * item['count']
        @inventory.available(material) >= total_needed
      end
    end
    
    private
    
    # Find the appropriate blueprint for a unit
    def find_blueprint_for_unit(unit_type, variant = nil)
      # Use BlueprintLookupService to find the blueprint
      lookup = Lookup::BlueprintLookupService.new
      lookup.find_blueprint(unit_type, variant)
    end
    
    # Determine priority based on material type
    def determine_priority(material)
      if ['Oxygen', 'Water', 'Food'].include?(material)
        :critical
      elsif ['Steel', 'Glass', 'Aluminum'].include?(material)
        :high
      elsif ['Copper', 'Silicon', 'Carbon'].include?(material)
        :medium
      else
        :low
      end
    end
    
    # Determine what construction units are needed
    def determine_required_construction_units(construction_plan)
      required_units = {}
      
      # Count buildings by type
      construction_types = construction_plan['recommended_units_to_build'].map { |item| item['unit_type'] }
      
      # Determine required construction units based on types
      if construction_types.include?('dome')
        required_units['construction_bot_heavy'] = 2
        required_units['construction_bot_standard'] = 3
      end
      
      if construction_types.include?('skylight_cover') || construction_types.include?('access_point')
        required_units['construction_bot_standard'] = 2
      end
      
      if construction_types.include?('habitat_module')
        required_units['construction_bot_standard'] = 2
        required_units['construction_bot_precision'] = 1
      end
      
      # Always need at least one standard construction bot
      required_units['construction_bot_standard'] ||= 1
      
      required_units
    end
    
    # Build construction units
    def build_construction_units(unit_type, count)
      # Find blueprint
      blueprint = find_blueprint_for_unit(unit_type)
      return unless blueprint
      
      # Create unit assembly job
      job = UnitAssemblyJob.create!(
        unit_type: unit_type,
        count: count,
        settlement: @settlement,
        status: 'scheduled',
        priority: 'high',
        blueprint_id: blueprint['id']
      )
      
      # Create material requests for the job
      materials = blueprint['materials'] || {}
      materials.each do |material, amount|
        # Multiply by count
        total_amount = amount * count
        
        job.material_requests.create!(
          material_name: material,
          quantity_requested: total_amount,
          status: 'pending',
          priority: 'high'
        )
      end
      
      # Update job status
      job.update(status: 'materials_pending')
      
      Rails.logger.info "[AI Production] Scheduled construction of #{count} #{unit_type}(s)"
    end
    
    # Create construction requests for different structures
    
    def create_dome_construction_request(item)
      # Create the dome entity if it doesn't exist
      dome = Structures::CraterDome.create!(
        name: "#{@settlement.name} Dome #{@settlement.structures.count + 1}",
        settlement: @settlement,
        location: @location,
        diameter: item['specifications']&.dig('diameter') || 100,
        depth: item['specifications']&.dig('depth') || 20,
        status: 'planned'
      )
      
      # Create the construction job
      ConstructionJobService.create_job(
        dome,
        'crater_dome_construction',
        target_values: {
          owner_id: @settlement.id,
          owner_type: @settlement.class.name,
          layer_type: 'primary',
          priority: item['priority']
        }
      )
    end
    
    def create_skylight_construction_requests(item)
      # Find uncovered skylights
      skylights = @settlement.lava_tubes.flat_map do |tube|
        tube.skylights.where(status: 'uncovered').limit(item['count'])
      end
      
      # Create jobs for each skylight
      skylights.each do |skylight|
        ConstructionJobService.create_job(
          skylight, 
          'skylight_cover',
          target_values: { 
            panel_type: 'basic_transparent_crater_tube_cover_array',
            priority: item['priority']
          }
        )
      end
    end
    
    def create_access_point_construction_requests(item)
      # Find uncovered access points
      access_points = @settlement.lava_tubes.flat_map do |tube|
        tube.access_points.where(conversion_status: 'uncovered').limit(item['count'])
      end
      
      # Create jobs for each access point
      access_points.each do |access_point|
        ConstructionJobService.create_job(
          access_point, 
          'access_point_conversion',
          target_values: { 
            conversion_type: item['variant'] || 'airlock',
            priority: item['priority']
          }
        )
      end
    end
    
    def create_habitat_construction_request(item)
      # Create a habitat module
      habitat_module = Structures::HabitatModule.create!(
        name: "Habitat Module #{@settlement.structures.count + 1}",
        settlement: @settlement,
        module_type: item['variant'] || 'standard',
        capacity: item['specifications']&.dig('capacity') || 4,
        status: 'planned'
      )
      
      # Create a construction job
      ConstructionJobService.create_job(
        habitat_module,
        'habitat_construction',
        target_values: {
          priority: item['priority']
        }
      )
    end
  end
end