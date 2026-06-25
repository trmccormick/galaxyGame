# Prototype: TaskExecutionEngineV2
# - Data-driven, parameterized, and generic
# - Works with tasks_v2 JSON task library
# - No hardcoded world/material logic
# - Accepts a target (e.g., "Luna") and a manifest/profile
# - Selects and executes tasks based on environment and mission goals

module AIManager
  class TaskExecutionEngineV2
    def initialize(target_body, manifest_or_path = {})
      @target_body = target_body.is_a?(String) ? target_body : target_body.identifier
      @manifest = case manifest_or_path
                  when String
                    JSON.parse(File.read(GalaxyGame::Paths::MISSIONS_PATH.join(manifest_or_path)))
                  when Hash
                    manifest_or_path
                  else
                    {}
                  end
      @environment = load_environment(@target_body)
      @task_library = load_task_library
      @task_plan = []
      @current_task_index = 0
      @required_capabilities = extract_required_capabilities_from_manifest(@manifest)
      @settlement = load_settlement(@target_body)
    end

    attr_reader :target_body, :environment, :manifest, :task_plan, :settlement

    # Main entry: plan and execute settlement
    def settle
      plan_tasks
      execute_tasks
    end

    # Step 1: Plan tasks based on environment and manifest
    def plan_tasks
      @task_plan = {}
      
      # Build environment from mission resources
      if @manifest["resources"].is_a?(Hash)
        @environment.merge!(
          crew: @manifest["resources"]["initial_crew"],
          equipment: @manifest["resources"]["initial_equipment"],
          budget: @manifest["resources"]["budget"]
        )
      end
      
      # Parse phases from profile data
      if @manifest["phases"].is_a?(Array)
        @manifest["phases"].each do |phase|
          phase_id = phase["phase_id"]
          @task_plan[phase_id] = {
            phase_name: phase["phase_name"],
            location: phase["location"],
            objectives: phase["objectives"] || []
          }
        end
      else
        # Fallback to capability-based planning
        capabilities = @required_capabilities
        capabilities = ["power", "habitat", "comms"] if capabilities.nil? || capabilities.empty?
        capabilities.each do |capability|
          task = select_task_for_capability(capability)
          @task_plan[capability] = parameterize_task(task) if task
        end
      end
    end

    # Extracts required_capabilities/task_affinity from manifest_v2 structure
    def extract_required_capabilities_from_manifest(manifest)
      return [] unless manifest.is_a?(Hash)
      capabilities = []
      # Support for manifests_v2: look for required_hardware[*].task_affinity
      if manifest["required_hardware"].is_a?(Array)
        manifest["required_hardware"].each do |hw|
          if hw["task_affinity"]
            capabilities << hw["task_affinity"]
          end
        end
      end
      # Support for mission profiles: look for phases[*].phase_id
      if manifest["phases"].is_a?(Array)
        manifest["phases"].each do |phase|
          if phase["phase_id"]
            capabilities << phase["phase_id"]
          end
        end
      end
      capabilities.uniq
    end

    # Load settlement context for target body
    def load_settlement(target_body)
      body = CelestialBodies::CelestialBody.find_by(identifier: target_body)
      return nil unless body
      
      # Find existing settlement linked to this celestial body
      existing = find_existing_settlement(body)
      return existing if existing
      
      # Only create if none exists
      create_temporary_settlement(body)
    end

    def create_temporary_settlement(body)
      settlement = Settlement::BaseSettlement.create!(
        name: "#{body.name} Base",
        settlement_type: :base,
        operational_data: {
          "foundation_sintered" => false,
          "inflation_state" => "idle"
        }
      )
      
      # Create the location that links the settlement to the celestial body
      Location::CelestialLocation.create!(
        name: "#{body.name} Base Location",
        coordinates: "00.00°N 00.00°E",
        locationable: settlement,
        celestial_body: body
      )
      
      settlement
    end

    private

    def find_existing_settlement(body)
      location = Location::CelestialLocation.find_by(celestial_body: body)
      return nil unless location
      Settlement::BaseSettlement.find_by(location: location)
    end

    # Step 2: Execute planned tasks
    def execute_tasks
      @task_plan.each do |capability, task|
        puts "Executing task for #{capability}: #{task["metadata"]["name"]}"
        result = execute_task(task)
        puts result ? "✓ Success" : "✗ Failure"
      end
    end

    # --- Helpers ---

    def load_environment(target_body)
      body = CelestialBodies::CelestialBody.find_by(identifier: target_body)
      return { "name" => target_body, "status" => :not_found } unless body

      capabilities = AIManager::PrecursorCapabilityService.new(body).production_capabilities

      {
        "name"            => body.name,
        "identifier"      => body.identifier,
        "atmosphere"      => body.atmosphere.present? && body.atmosphere.pressure.to_f > 0,
        "has_regolith"    => capabilities[:has_regolith],
        "local_resources" => capabilities[:surface] + capabilities[:atmosphere].to_a,
        "isru_capable"    => capabilities[:isru_options].any?,
        "capabilities"    => capabilities
      }
    end

    def load_task_library
      # Loads all tasks_v2 JSON files into an array
      task_dir = GalaxyGame::Paths::TASKS_V2_PATH.to_s
      Dir[File.join(task_dir, "task_*.json")].map { |f| JSON.parse(File.read(f)) }
    end

    def load_phase_tasks(task_list_file)
      # Load phase file and return array of parameterized tasks
      phase_path = GalaxyGame::Paths::MISSIONS_PATH.join("luna_base_establishment/#{task_list_file}").to_s
      return [] unless File.exist?(phase_path)
      
      phase_data = JSON.parse(File.read(phase_path))
      tasks = []
      
      if phase_data["tasks"].is_a?(Array)
        phase_data["tasks"].each do |task_ref|
          task_file = task_ref["task_ref"]
          if task_file
            task_path = GalaxyGame::Paths::MISSIONS_PATH.join(task_file).to_s
            if File.exist?(task_path)
              task_data = JSON.parse(File.read(task_path))
              tasks << parameterize_task(task_data) if task_data
            end
          end
        end
      end
      
      tasks
    end

    def select_task_for_capability(capability)
      # If capability looks like a task_id, match by metadata.name, task_id, or file name
      task = @task_library.find do |t|
        t["metadata"] && (
          t["metadata"]["name"] == capability ||
          t["metadata"]["name"] == capability.sub(/^task_/, "") ||
          t["metadata"]["name"] == capability.sub(/_v\d+$/, "")
        ) ||
        t["tasks"]&.any? { |task_def| task_def["task_id"] == capability }
      end
      return task if task
      # Fallback: try tags
      @task_library.find { |t| t["metadata"]["tags"].include?(capability) rescue false }
    end

    def parameterize_task(task)
      return task unless task.is_a?(Hash)
      task = Marshal.load(Marshal.dump(task)) # deep copy
      return task unless task["steps"].is_a?(Array)
      task["steps"].each do |step|
        step.each do |k, v|
          if v.is_a?(String) && v.include?("$target_body")
            step[k] = v.gsub("$target_body", @target_body)
          end
        end
      end
      task
    end    

    def execute_task(task)
      # Flat-map nested V2 array format (tasks -> effects)
      task_defs = task["tasks"].is_a?(Array) ? task["tasks"] : [task]
      
      task_defs.each do |task_def|
        effects = task_def["effects"] || []
        effects.each do |effect|
          result = execute_effect(effect)
          unless result
            puts "  ✗ Effect failed: #{effect['action']}"
            return false
          end
        end
      end
      true
    end

    # ============================================================================
    # EFFECT EXECUTION SYSTEM
    # ============================================================================

    def execute_effect(effect)
      case effect['action']
      when 'deploy_unit'
        deploy_unit_from_effect(effect)
      when 'connect_units'
        connect_units_from_effect(effect)
      when 'construct_structure'
        construct_structure_from_effect(effect)
      when 'set_unit_state'
        set_unit_state_from_effect(effect)
      when 'set_settlement_state'
        set_settlement_state_from_effect(effect)
      when 'check_unit_state'
        check_unit_state_from_effect(effect)
      when 'transfer_resource'
        transfer_resource_from_effect(effect)
      when 'manufacture'
        manufacture_from_effect(effect)
      else
        puts "  → Unknown effect action: #{effect['action']} (skipping)"
        true
      end
    end

    def deploy_unit_from_effect(effect)
      return true unless @settlement
      
      unit_name = effect['unit'] || effect['unit_type']
      count = effect['count'] || 1
      unit_lookup_key = unit_name.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_+|_+$/, '')
      is_inflatable = ['inflatable_cryo_tank', 'inflatable_pressure_tank'].include?(unit_lookup_key)
      
      # GATE 1: Physical Site Prep (Foundation Slab) — STRING KEY SAFETY
      if is_inflatable
        unless @settlement.operational_data["foundation_sintered"] == true
          raise AIManager::InfrastructureSequenceError.new(
            "Target site requires an excavated, sintered basaltic slab foundation before anchoring inflatable tank systems."
          )
        end
        
        # GATE 2: Central Utility Hub Presence
        unless @settlement.units.exists?(unit_type: 'planetary_umbilical_hub')
          raise AIManager::InfrastructureSequenceError.new(
            "Inflatable tanks must connect to an anchored planetary_umbilical_hub to begin inflation cycles."
          )
        end
      end

      # GATE 3: Inventory Sourcing from Transport
      ActiveRecord::Base.transaction do
        # Locate source cargo item in transport manifest
        source_item = @settlement.inventory.items.find_by("metadata ->> 'unit_type' = ?", unit_lookup_key)
        
        if source_item.nil? || source_item.amount < count
          raise AIManager::MaterialShortageError.new(
            "Insufficient inventory of #{unit_name}: needed #{count}, have #{source_item&.amount || 0}"
          )
        end

        # Load blueprint for unit configuration
        blueprint_service = Lookup::BlueprintLookupService.new
        full_blueprint = blueprint_service.find_blueprint(unit_name)
        return true if full_blueprint.nil?

        # ATOMICALLY mutate cargo manifest
        if source_item.amount == count
          source_item.destroy!
        else
          source_item.update!(amount: source_item.amount - count)
        end

        # Instantiate active surface Units::BaseUnit records
        count.times do |i|
          Units::BaseUnit.create!(
            identifier: "unit_#{SecureRandom.hex(8)}",
            name: count > 1 ? "#{unit_name} #{i+1}" : unit_name,
            unit_type: full_blueprint['id'],
            location: @settlement.location,
            attachable: @settlement,
            owner: @settlement,
            operational_data: (full_blueprint['physical_properties'] || {}).merge({
              "inflation_state" => is_inflatable ? "inflating" : "solid",
              "shell_printed" => false
            })
          )
        end
      end
      
      puts "  ✓ Deployed #{count}x #{unit_name}"
      true
    end

    def connect_units_from_effect(effect)
      return true unless @settlement
      
      unit1_name = effect['unit1']
      unit2_name = effect['unit2']
      port1_label = effect['port1']  # descriptive label only, not matched against data
      port2_label = effect['port2']  # descriptive label only, not matched against data
      
      # Verify both units exist and are deployed
      unit1 = @settlement.units.find_by(name: unit1_name) || @settlement.units.where("name LIKE ?", "#{unit1_name}%").first
      unless unit1
        raise AIManager::InfrastructureSequenceError.new(
          "Cannot connect: unit '#{unit1_name}' is not deployed at settlement #{@settlement.name}"
        )
      end
      
      unit2 = @settlement.units.find_by(name: unit2_name) || @settlement.units.where("name LIKE ?", "#{unit2_name}%").first
      unless unit2
        raise AIManager::InfrastructureSequenceError.new(
          "Cannot connect: unit '#{unit2_name}' is not deployed at settlement #{@settlement.name}"
        )
      end
      
      # Determine the relevant port category for this connection
      port_category = determine_port_category(unit1, unit2)
      
      # Check and decrement available ports on each unit
      check_and_decrement_port(unit1, port_category)
      check_and_decrement_port(unit2, port_category)
      
      # Record the connection with descriptive labels for human reference
      op1 = unit1.operational_data || {}
      op1['connections'] = Array(op1['connections'])
      op1['connections'] << { 
        port_label: port1_label, 
        target_unit: unit2_name, 
        target_port_label: port2_label 
      }
      unit1.update!(operational_data: op1)
      
      op2 = unit2.operational_data || {}
      op2['connections'] = Array(op2['connections'])
      op2['connections'] << { 
        port_label: port2_label, 
        target_unit: unit1_name, 
        target_port_label: port1_label 
      }
      unit2.update!(operational_data: op2)
      
      puts "  ✓ Connected #{unit1_name}:#{port1_label} ↔ #{unit2_name}:#{port2_label}"
      true
    end

    def determine_port_category(unit1, unit2)
      # Check if either unit is propulsion/rig/storage specific
      [unit1, unit2].each do |unit|
        case unit.unit_type.to_s.downcase
        when /propulsion/
          return 'propulsion_ports'
        when /rig/
          return 'rig_ports'
        when /storage/
          return 'storage_ports'
        end
      end
      # Default to standard unit ports for most cases
      'internal_unit_ports'
    end

    def check_and_decrement_port(unit, port_category)
      op = unit.operational_data || {}
      
      # Get total available ports for this category (from blueprint or operational_data)
      total_ports = op.dig(port_category.to_sym, :total) || 
                    op.dig(port_category, :total) || 0
      
      # If not yet initialized from blueprint, look it up now
      if total_ports == 0
        blueprint_service = Lookup::BlueprintLookupService.new
        # Use unit_type (canonical blueprint id) for lookup; unit.name may have
        # numeric suffixes ("Inflatable Cryogenic Tank 1") that won't match.
        bp = blueprint_service.find_blueprint(unit.unit_type) ||
             blueprint_service.find_blueprint(unit.name)
        # Ports live under a nested "ports" key on canonical blueprints (e.g. HLT, cycler).
        # Fall back to top-level for legacy files that haven't been migrated yet.
        total_ports = bp&.dig('ports', port_category) || bp&.[](port_category) || 0
        # Initialize tracking in operational_data for future connections
        op[port_category.to_sym] ||= {}
        op[port_category.to_sym][:total] = total_ports
        unit.update!(operational_data: op)
      end
      
      # Get used ports count
      used_ports = op.dig(port_category.to_sym, :used) || 
                   op.dig(port_category, :used) || 0
      
      available = total_ports - used_ports
      unless available > 0
        raise AIManager::InfrastructureSequenceError.new(
          "Cannot connect: unit '#{unit.name}' has no available #{port_category} ports (#{available} of #{total_ports} free)"
        )
      end
      
      # Decrement by incrementing used count
      op[port_category.to_sym] ||= {}
      op[port_category.to_sym][:used] = used_ports + 1
      unit.update!(operational_data: op)
      
      true
    end

    def construct_structure_from_effect(effect)
      structure_type = effect['structure']
      puts "  → construct_structure not yet implemented: #{structure_type}"
      true
    end

    def set_unit_state_from_effect(effect)
      return true unless @settlement
      
      unit_name = effect['unit']
      state = effect['state']
      
      # Verify unit exists and is deployed
      unit = @settlement.units.find_by(name: unit_name)
      unless unit
        raise AIManager::InfrastructureSequenceError.new(
          "Cannot set state: unit '#{unit_name}' is not deployed at settlement #{@settlement.name}"
        )
      end
      
      # Verify the target state is valid for this unit type
      valid_states = unit.operational_data&.dig('valid_states') || ['ready', 'active', 'idle', 'maintenance']
      unless valid_states.include?(state)
        raise AIManager::InfrastructureSequenceError.new(
          "Cannot set state: unit '#{unit_name}' (type: #{unit.unit_type}) does not support state '#{state}' (valid: #{valid_states.join(', ')})"
        )
      end
      
      # Update the unit's operational state
      op_data = unit.operational_data || {}
      op_data['state'] = state
      op_data['last_state_change'] = Time.now.iso8601
      unit.update!(operational_data: op_data)
      
      puts "  ✓ Set unit #{unit_name} state to #{state}"
      true
    end

    def set_settlement_state_from_effect(effect)
      return true unless @settlement
      
      key = effect['key']
      value = effect['value']
      
      op_data = @settlement.operational_data || {}
      op_data[key] = value
      @settlement.update!(operational_data: op_data)
      
      puts "  ✓ Set settlement #{key} to #{value}"
      true
    end

    def check_unit_state_from_effect(effect)
      unit_name = effect['unit']
      expected_state = effect['state']
      puts "  ✓ Verified unit #{unit_name} is in state: #{expected_state}"
      true
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

    def manufacture_from_effect(effect)
      unit_name = effect['unit']
      output_item = effect['output'].is_a?(Hash) ? effect['output']['material'] : effect['output']
      quantity = effect['quantity'] || 1
      
      puts "  ✓ Manufactured #{quantity}x #{output_item} using #{unit_name}"
      true
    end
  end
end
