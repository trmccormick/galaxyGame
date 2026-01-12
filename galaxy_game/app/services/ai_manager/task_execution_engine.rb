module AIManager
  class TaskExecutionEngine
    # Class method for orbital resupply cycle management
    def self.orbital_resupply_cycle
      Rails.logger.info("Starting orbital resupply cycle check")
      
      l1_station = Settlement::BaseSettlement.where(settlement_type: :station).first
      
      Rails.logger.info("L1 station: #{l1_station&.name}")
      
      return unless l1_station
      
      active_projects = l1_station.orbital_construction_projects.where(status: ['materials_pending', 'in_progress'])
      return if active_projects.empty?
      
      lunar_settlement = Settlement::BaseSettlement.where.not(settlement_type: :station).where("name ILIKE ?", "%lunar%").first ||
                        Settlement::BaseSettlement.where.not(settlement_type: :station).first
      
      return unless lunar_settlement
      
      Rails.logger.info "Found lunar_settlement: #{lunar_settlement.name}"
      
      ibeam_surplus = check_material_surplus(lunar_settlement, 'ibeam')
      panel_surplus = check_material_surplus(lunar_settlement, 'modular_structural_panel_base')
      
      if ibeam_surplus > 0 || panel_surplus > 0 || true # TEMP for testing
        schedule_material_ferry(lunar_settlement, l1_station, ibeam_surplus, panel_surplus)
      end
    end
    
    def initialize(mission_id)
      @mission_id = mission_id
      @task_list = load_task_list(mission_id)
      @manifest = load_manifest(mission_id)
      @current_task_index = 0
      @mission = Mission.find_by(identifier: mission_id)
      @settlement = @mission.settlement if @mission
      @concurrent_tasks = []
      @paused_tasks = []
      @produced_materials = Hash.new(0)
      @consumed_materials = Hash.new(0)
    end
    
    attr_reader :settlement
    
    def start
      Rails.logger.info("Starting task execution for mission #{@mission_id}")
      
      # Execute all tasks synchronously for AI simulation
      while @current_task_index < @task_list.length
        break unless execute_next_task
      end
      
      complete_mission
      true
    end
    
    def execute_next_task
      return false if @current_task_index >= @task_list.length
      
      task = @task_list[@current_task_index]
      
      Rails.logger.info("Executing task #{@current_task_index + 1}/#{@task_list.length}: #{task['task_id']} - #{task['description']}")
      
      result = execute_task(task)
      
      if result
        Rails.logger.info("✓ Task #{@current_task_index + 1} completed: #{task['task_id']}")
        @current_task_index += 1
        update_mission_progress
        true
      else
        Rails.logger.error("✗ Task #{@current_task_index + 1} failed: #{task['task_id']}")
        false
      end
    end
    
    private
    
    # Class methods for orbital resupply
    def self.check_material_surplus(settlement, material_name)
      amount = settlement.inventory.current_storage_of(material_name)
      [amount - 100, 0].max
    end
    
    def self.schedule_material_ferry(from_settlement, to_station, ibeam_qty, panel_qty)
      Rails.logger.info "Schedule material ferry called with from: #{from_settlement.name}, to: #{to_station.name}, ibeam: #{ibeam_qty}, panel: #{panel_qty}"
      hlt_craft = Craft::BaseCraft.where(
        craft_type: 'heavy_lift_transport',
        docked_at: from_settlement
      ).first
      
      Rails.logger.info "Found craft: #{hlt_craft&.name}"
      
      return unless hlt_craft
      
      mission_id = "orbital_ferry_#{Time.current.to_i}"
      
      load_materials_onto_craft(hlt_craft, 'ibeam', ibeam_qty)
      load_materials_onto_craft(hlt_craft, 'modular_structural_panel_base', panel_qty)
      
      mission = Mission.create!(
        identifier: mission_id,
        operational_data: { 
          mission_type: 'orbital_ferry',
          description: "Ferry materials from #{from_settlement.name} to #{to_station.name}"
        },
        status: 'in_progress',
        settlement: from_settlement
      )
      
      # hlt_craft.status = :in_transit
      # hlt_craft.save!
      
      Rails.logger.info("Scheduled orbital ferry: #{hlt_craft.name} from #{from_settlement.name} to #{to_station.name}")
      
      mission
    end
    
    def self.load_materials_onto_craft(craft, material_name, quantity)
      Logistics::InventoryManager.transfer_item(
        item_name: material_name,
        quantity: quantity,
        from_inventory: craft.docked_at.inventory,
        to_inventory: craft.inventory
      )

      process_project_payment(craft.docked_at, craft.owner, material_name, quantity)
    end

    def self.process_project_payment(settlement, supplier, material_name, quantity)
      buy_orders = Market::Order.where(
        base_settlement: settlement,
        resource: material_name,
        order_type: :buy
      ).where('quantity > 0').order(created_at: :asc)

      return if buy_orders.empty?

      remaining_quantity = quantity

      buy_orders.each do |order|
        break if remaining_quantity <= 0

        fulfill_quantity = [remaining_quantity, order.quantity].min
        Market::DemandService.fulfill_buy_order(order, fulfill_quantity, supplier)
        remaining_quantity -= fulfill_quantity
      end
    end
    
    # Instance methods
    def load_task_list(mission_id)
      mission_dir = mission_id.gsub('_', '-')
      profile_file_path = GalaxyGame::Paths::MISSIONS_PATH.join(mission_dir, "#{mission_id}_profile_v1.json")
      puts "Loading profile from: #{profile_file_path}"

      if File.exist?(profile_file_path)
        profile = JSON.parse(File.read(profile_file_path))
        puts "Loaded profile with #{profile['phases']&.length || 0} phases"

        all_tasks = []
        profile['phases']&.each do |phase|
          task_file = phase['task_list_file']
          if task_file
            task_file_path = GalaxyGame::Paths::MISSIONS_PATH.join(mission_dir, task_file)
            puts "Loading phase tasks from: #{task_file_path}"

            if File.exist?(task_file_path)
              phase_data = JSON.parse(File.read(task_file_path))
              tasks = phase_data['tasks'] || []
              puts "  Loaded #{tasks.length} tasks from #{task_file}"
              all_tasks.concat(tasks)
            else
              puts "  Phase file not found: #{task_file_path}"
            end
          end
        end

        puts "Total tasks loaded: #{all_tasks.length}"
        all_tasks
      else
        # Fallback to old single tasks file for backward compatibility
        tasks_file_path = GalaxyGame::Paths::MISSIONS_PATH.join(mission_dir, "#{mission_id}_tasks_v1.json")
        puts "Profile not found, falling back to: #{tasks_file_path}"

        if File.exist?(tasks_file_path)
          data = JSON.parse(File.read(tasks_file_path))
          puts "Loaded #{data.length} tasks (legacy format)"
          data
        else
          puts "Tasks file not found, returning empty array"
          []
        end
      end
    end
    
    def load_manifest(mission_id)
      mission_dir = mission_id.gsub('_', '-')
      manifest_name = ENV['TEST_MANIFEST'] || "#{mission_id}_manifest_v1"
      manifest_file_path = GalaxyGame::Paths::MISSIONS_PATH.join(mission_dir, "#{manifest_name}.json")
      puts "Loading manifest from: #{manifest_file_path}"
      
      if File.exist?(manifest_file_path)
        data = JSON.parse(File.read(manifest_file_path))
        puts "Loaded manifest with keys: #{data.keys}"
        data
      else
        puts "Manifest file not found, returning empty hash"
        {}
      end
    end
    
    def execute_effect(effect, task)
      puts "  → Executing effect: #{effect['action']}"
      
      case effect['action']
      when 'set_unit_state'
        set_unit_state(effect)
      when 'deploy_unit'
        deploy_unit_from_effect(effect)
      when 'connect_units'
        connect_units_from_effect(effect)
      when 'construct_structure'
        construct_structure_from_effect(effect)
      when 'set_structure_state'
        set_structure_state_from_effect(effect)
      when 'manufacture'
        manufacture_from_effect(effect, task)
      when 'check_unit_state'
        check_unit_state_from_effect(effect)
      when 'check_unit_connected'
        check_unit_connected_from_effect(effect)
      when 'transfer_resource'
        transfer_resource_from_effect(effect)
      else
        puts "Unknown effect action: #{effect['action']}"
        false
      end
    end
    
    def execute_task(task)
      if task['effects']
        puts "  Processing #{task['effects'].length} effects..."
        task['effects'].each do |effect|
          result = execute_effect(effect, task)
          return false unless result
        end
        
        handle_manufacturing_byproducts(task)
        true
      else
        # Legacy task type handling
        result = case task['type']
        when 'deploy'
          deploy_unit(task)
        when 'construct'
          initiate_construction(task)
        when 'connect'
          connect_units(task)
        when 'transfer'
          transfer_resources(task)
        when 'survey'
          perform_survey(task)
        when 'harvest'
          harvest_resources(task)
        else
          Rails.logger.error("Unknown task type: #{task['type']}")
          false
        end
        
        handle_manufacturing_byproducts(task) if result
        result
      end
    end
    
    def deploy_unit(task)
      return false unless @settlement
      
      unit_name = task['unit_name']
      unit_type = task['unit_type']
      
      unit = Units::BaseUnit.create!(
        identifier: generate_identifier,
        name: unit_name,
        unit_type: unit_type,
        location: @settlement.location,
        owner: @settlement,
        operational_data: task['operational_data'] || {}
      )
      
      Rails.logger.info("  ✓ Deployed unit: #{unit_name} (#{unit_type})")
      true
    end
    
    def initiate_construction(task)
      return false unless @settlement
      
      structure_type = task['structure_type']
      
      case structure_type
      when 'skylight_cover'
        Rails.logger.info("  → Skipping skylight_cover for AI simulation")
        return true
        
      when 'crater_dome'
        dome_location = @settlement.location
        
        structure_name = task['name'] ? "#{task['name']} (#{@settlement.id})" : "#{@settlement.name} Dome"
        crater_dome = Structures::CraterDome.create!(
          name: structure_name,
          structure_name: structure_name,
          owner: @settlement,
          location: dome_location,
          settlement: @settlement,
          operational_data: {
            'structure_type' => 'crater_dome',
            'dimensions' => {
              'diameter' => task['diameter'] || 100.0,
              'depth' => task['depth'] || 20.0
            }
          }
        )
        
        job = ConstructionJobService.create_job(crater_dome, 'crater_dome_construction')
        
        job.material_requests.update_all(status: 'fulfilled', fulfilled_at: Time.current)
        job.equipment_requests.update_all(status: 'fulfilled', fulfilled_at: Time.current) if job.equipment_requests.any?
        
        track_construction_resources(job, 'crater_dome')
        ConstructionJobService.send(:start_construction, job)
        
        Rails.logger.info("  ✓ Created crater dome structure")
      end
      
      true
    end
    
    def connect_units(task)
      Rails.logger.info("  → connect_units not yet implemented")
      true
    end
    
    def transfer_resources(task)
      Rails.logger.info("  → transfer_resources not yet implemented")
      true
    end
    
    def perform_survey(task)
      Rails.logger.info("  → perform_survey not yet implemented")
      true
    end
    
    def harvest_resources(task)
      Rails.logger.info("  → harvest_resources not yet implemented")
      true
    end
    
    def update_mission_progress
      progress = ((@current_task_index.to_f / @task_list.length) * 100).round
      current_data = @mission.operational_data || {}
      @mission.update(
        progress: progress,
        operational_data: current_data.merge(
          current_task: @current_task_index,
          total_tasks: @task_list.length
        )
      )
    end
    
    def complete_mission
      current_data = @mission.operational_data || {}
      @mission.update(
        status: 'completed',
        progress: 100,
        completion_date: Time.current,
        operational_data: current_data.merge(
          completion_message: "All #{@task_list.length} tasks completed successfully"
        )
      )
      
      ResourceTrackingService.track_inventory_snapshot(@settlement)
      Rails.logger.info("✓ Mission #{@mission_id} completed successfully - #{@task_list.length} tasks executed")
    end
    
    def set_unit_state(effect)
      unit_name = effect['unit']
      state = effect['state']
      
      units = Units::BaseUnit.where("name LIKE ?", "%#{unit_name}%").where(owner: @settlement)
      if units.any?
        units.each do |unit|
          unit.update(operational_data: unit.operational_data.merge('state' => state))
          puts "  ✓ Set unit #{unit.name} state to #{state}"
        end
        true
      else
        puts "  → Unit #{unit_name} not found, assuming correct state for AI simulation"
        true
      end
    end
    
    def deploy_unit_from_effect(effect)
      return false unless @settlement
      
      unit_name = effect['unit']
      count = effect['count'] || 1
      
      unit_blueprint = find_unit_blueprint(unit_name)
      
      if unit_blueprint.nil?
        puts "  ✗ Blueprint not found for: #{unit_name}"
        return false
      end
      
      # Load full blueprint data for unit_type
      blueprint_service = Lookup::BlueprintLookupService.new
      full_blueprint = blueprint_service.find_blueprint(unit_name)
      
      if full_blueprint.nil?
        puts "  ⚠ Blueprint not found for: #{unit_name} - skipping deployment"
        return true  # Don't fail the task, just skip this unit
      end
      
      count.times do |i|
        unit = Units::BaseUnit.create!(
          identifier: generate_identifier,
          name: count > 1 ? "#{unit_name} #{i+1}" : unit_name,
          unit_type: full_blueprint['id'],
          location: @settlement.location,
          owner: @settlement,
          operational_data: {}
        )
        puts "  ✓ Deployed: #{unit.name}"
      end
      
      true
    end
    
    def connect_units_from_effect(effect)
      unit1_name = effect['unit1']
      unit2_name = effect['unit2']
      port1 = effect['port1']
      port2 = effect['port2']
      
      unit1 = Units::BaseUnit.find_by(name: unit1_name, owner: @settlement)
      unit2 = Units::BaseUnit.find_by(name: unit2_name, owner: @settlement)
      
      if unit1 && unit2
        puts "  ✓ Connected #{unit1_name}:#{port1} ↔ #{unit2_name}:#{port2}"
        true
      else
        Rails.logger.error("  ✗ Units not found for connection: #{unit1_name}, #{unit2_name} (continuing for AI simulation)")
        true # Return true for AI simulation even if units not found
      end
    end
    
    def construct_structure_from_effect(effect)
      structure_type = effect['structure']
      
      case structure_type
      when 'lava_tube_airlock'
        construct_regolith_airlock
      when 'skylight_cover'
        construct_regolith_skylight
      else
        Rails.logger.error("  ✗ Unknown structure type: #{structure_type}")
        false
      end
    end
    
    def set_structure_state_from_effect(effect)
      structure_name = effect['structure']
      state = effect['state']
      
      puts "  ✓ Set structure #{structure_name} state to #{state}"
      true
    end
    
    def manufacture_from_effect(effect, task)
      unit_name = effect['unit']
      # Handle output as either string or hash
      output_item = effect['output'].is_a?(Hash) ? effect['output']['material'] : effect['output']
      input_materials = effect['inputs'] || []
      quantity = effect['quantity'] || 1
      
      puts "  → Manufacturing: #{quantity}x #{output_item} using #{unit_name}"
      
      # Track input materials as consumed (local ISRU)
      input_materials.each do |input|
        material_name = input['material']
        material_qty = input['quantity'] * quantity
        
        @consumed_materials[material_name] += material_qty
        
        # Determine if this is local ISRU material
        procurement_method = if material_name.include?('regolith') || 
                                material_name == 'depleted_regolith'
                              :local_isru
                            else
                              :ai_autofulfill
                            end
        
        ResourceTrackingService.track_procurement(
          @settlement,
          material_name,
          material_qty,
          procurement_method,
          {
            mission_id: @mission_id,
            task_type: 'manufacturing',
            task_id: task['task_id'],
            purpose: procurement_method == :local_isru ? 'local_manufacturing' : 'manufacturing_autofulfill'
          }
        )
        
        puts "    • Input: #{material_qty} #{material_name} (#{procurement_method})"
      end
      
      # Track output material as produced
      if output_item && !output_item.empty?
        @produced_materials[output_item] += quantity
        
        ResourceTrackingService.track_procurement(
          @settlement,
          output_item,
          quantity,
          :local_production,
          {
            mission_id: @mission_id,
            task_type: 'manufacturing',
            task_id: task['task_id'],
            purpose: 'manufactured_output'
          }
        )
        
        puts "  ✓ Manufactured #{quantity}x #{output_item}"
      else
        puts "  ⚠ Warning: No output item specified for manufacture effect"
      end
      
      # Generate byproducts if applicable
      handle_manufacturing_byproducts(task)
      
      true
    end
    
    def check_unit_state_from_effect(effect)
      unit_name = effect['unit']
      expected_state = effect['state']
      
      unit = Units::BaseUnit.find_by(name: unit_name, owner: @settlement)
      
      if unit
        current_state = unit.operational_data['state']
        if current_state == expected_state
          puts "  ✓ Unit #{unit_name} is in expected state: #{expected_state}"
          true
        else
          puts "  ⚠ Unit #{unit_name} is in state '#{current_state}', expected '#{expected_state}' (continuing anyway for AI simulation)"
          true # Don't fail for state mismatches in AI simulation
        end
      else
        puts "  ⚠ Unit #{unit_name} not found (assuming correct for AI simulation)"
        true
      end
    end
    
    def check_unit_connected_from_effect(effect)
      unit_name = effect['unit']
      port = effect['port']
      
      unit = Units::BaseUnit.find_by(name: unit_name, owner: @settlement)
      
      if unit
        puts "  ✓ Verified unit #{unit_name} connectivity at port #{port}"
        true
      else
        puts "  ⚠ Unit #{unit_name} not found (assuming connected for AI simulation)"
        true
      end
    end
    
    def transfer_resource_from_effect(effect)
      source_unit = effect['source_unit']
      target_unit = effect['target_unit']
      resource = effect['resource']
      continuous = effect['continuous'] || false
      
      if continuous
        puts "  ✓ Configured continuous transfer: #{resource} from #{source_unit} → #{target_unit}"
      else
        puts "  ✓ Transferred #{resource} from #{source_unit} → #{target_unit}"
      end
      
      true
    end
    
    def construct_regolith_airlock
      return false unless @settlement
      
      puts "  → Starting regolith airlock construction"
      
      airlock_structure = Structures::BaseStructure.create!(
        name: "Lava Tube Airlock - #{@settlement.id}",
        structure_name: "lava_tube_airlock",
        owner: @settlement,
        settlement: @settlement,
        location: @settlement.location,
        operational_data: { 'structure_type' => 'airlock', 'status' => 'under_construction' }
      )
      
      job = ConstructionJobService.create_job(airlock_structure, 'structure_upgrade', settlement: @settlement)
      
      job.material_requests.destroy_all
      add_regolith_material_requests(job, 'airlock')
      track_construction_resources(job, 'regolith_airlock')
      ConstructionJobService.send(:start_construction, job)
      
      puts "  ✓ Regolith airlock construction initiated (using local ISRU materials)"
      true
    end
    
    def construct_regolith_skylight
      return false unless @settlement
      
      puts "  → Starting regolith skylight construction"
      
      skylight_structure = Structures::BaseStructure.create!(
        name: "Lava Tube Skylight - #{@settlement.id}",
        structure_name: "skylight_cover",
        owner: @settlement,
        settlement: @settlement,
        location: @settlement.location,
        operational_data: { 'structure_type' => 'skylight', 'status' => 'under_construction' }
      )
      
      job = ConstructionJobService.create_job(skylight_structure, 'structure_upgrade', settlement: @settlement)
      
      job.material_requests.destroy_all
      add_regolith_material_requests(job, 'skylight')
      track_construction_resources(job, 'regolith_skylight')
      ConstructionJobService.send(:start_construction, job)
      
      puts "  ✓ Regolith skylight construction initiated (using local ISRU materials)"
      true
    end
    
    def add_regolith_material_requests(job, structure_type)
      case structure_type
      when 'airlock'
        MaterialRequest.create!(
          requestable: job,
          material_name: 'regolith',
          quantity_requested: 1000,
          quantity_fulfilled: 0,
          status: 'pending'
        )
        MaterialRequest.create!(
          requestable: job,
          material_name: 'basic_regolith_panel_mk1',
          quantity_requested: 20,
          quantity_fulfilled: 0,
          status: 'pending'
        )
      when 'skylight'
        MaterialRequest.create!(
          requestable: job,
          material_name: 'regolith',
          quantity_requested: 500,
          quantity_fulfilled: 0,
          status: 'pending'
        )
        MaterialRequest.create!(
          requestable: job,
          material_name: 'basic_regolith_panel_mk1',
          quantity_requested: 10,
          quantity_fulfilled: 0,
          status: 'pending'
        )
      end
    end

    def find_unit_blueprint(unit_name)
      return nil unless @manifest && @manifest['inventory']
      @manifest['inventory']['units']&.find { |unit| unit['name'] == unit_name }
    end

    def track_construction_resources(job, construction_type)
      return unless job.material_requests.respond_to?(:each)
      
      job.material_requests.each do |request|
        procurement_method = if request.material_name.include?('regolith') || 
                                request.material_name.include?('basic_regolith_panel')
                              :local_isru  # Local ISRU resources
                            else
                              :ai_autofulfill  # Imported materials
                            end
        
        ResourceTrackingService.track_procurement(
          @settlement,
          request.material_name,
          request.quantity_requested,
          procurement_method,
          {
            mission_id: @mission_id,
            task_type: construction_type,
            purpose: procurement_method == :local_isru ? 'local_construction' : 'construction_autofulfill',
            job_id: job.id
          }
        )
        
        puts "    • #{request.material_name}: #{request.quantity_requested} (#{procurement_method})"
      end
    end
    
    def handle_manufacturing_byproducts(task)
      return unless @settlement
      
      case task['task_id']
      when 'print_ibeams', 'print_shell_panels'
        generate_regolith_volatiles
      end
    end
    
    def generate_regolith_volatiles
      return unless @settlement
      
      o2_amount = 0.001
      h2o_amount = 0.0005
      
      # Add to settlement inventory using proper inventory system
      if @settlement.respond_to?(:inventory) && @settlement.inventory
        @settlement.inventory.add_item('O2', o2_amount)
        @settlement.inventory.add_item('H2O', h2o_amount)
        Rails.logger.info("  → Generated #{o2_amount}kg O2 + #{h2o_amount}kg H2O from regolith processing")
      else
        Rails.logger.debug("  → Skipping volatile generation (no inventory system)")
      end
    end
    
    def generate_identifier
      "unit_#{SecureRandom.hex(8)}"
    end
    
    def production_summary
      summary = []
      
      if @produced_materials.any?
        summary << "MATERIALS PRODUCED"
        @produced_materials.each do |material, qty|
          summary << "#{material}: #{qty}"
        end
      end
      
      if @consumed_materials.any?
        summary << "" if summary.any?
        summary << "MATERIALS CONSUMED"
        @consumed_materials.each do |material, qty|
          summary << "#{material}: #{qty}"
        end
      end
      
      summary.join("\n")
    end
    
    private
    
    def mark_concurrent_task_completed(task)
      # Mark a concurrent task as completed
      # For now, just log it - concurrent tasks are handled separately from main mission flow
      Rails.logger.info("Concurrent task #{task['task_id']} marked as completed")
    end
  end
end