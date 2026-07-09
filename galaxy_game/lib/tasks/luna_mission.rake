namespace :luna_mission do
  desc "Execute Luna Precursor V2 mission sequence end-to-end via TaskExecutionEngineV2"
  task execute: :environment do
    puts "\n" + "=" * 80
    puts "LUNA PRECURSOR V2 MISSION SEQUENCE - EXECUTION REPORT"
    puts "=" * 80

    target = "LUNA-01"
    legacy_profile_rel_path = "luna_base_establishment/luna_settlement_profile_v1.json"
    modern_profile_path = GalaxyGame::Paths::MISSIONS_PATH.join("profiles", "luna_base_establishment_profile_v1.json").to_s
    legacy_profile_path = GalaxyGame::Paths::MISSIONS_PATH.join(legacy_profile_rel_path).to_s
    manifest_path = GalaxyGame::Paths::MISSIONS_V2_MANIFESTS_PATH.join("lunar_precursor_manifest_v2.json").to_s

    body = CelestialBodies::CelestialBody.find_by(identifier: target)
    if body.nil?
      puts "\nFATAL: Celestial body '#{target}' not found in database."
      exit 1
    end

    v2_profile_path = GalaxyGame::Paths::MISSIONS_V2_PROFILES_PATH.join("luna_base_profile_v2.json").to_s
    profile_path = if File.exist?(v2_profile_path)
      v2_profile_path
    elsif File.exist?(legacy_profile_path)
      legacy_profile_path
    elsif File.exist?(modern_profile_path)
      modern_profile_path
    else
      nil
    end

    if profile_path.nil?
      puts "\nFATAL: Could not find profile in profiles/ or legacy path."
      exit 1
    end

    profile = JSON.parse(File.read(profile_path))
    puts "\nTarget body: #{body.name} (#{target})"
    puts "Profile: #{profile_path}"

    # Guard against unique location constraints by reusing existing body location.
    existing_location = Location::CelestialLocation.find_by(celestial_body: body)
    if existing_location && Settlement::BaseSettlement.find_by(location: existing_location).nil?
      bootstrap_settlement = Settlement::BaseSettlement.create!(
        name: "#{body.name} Base",
        settlement_type: :base,
        operational_data: {
          "foundation_sintered" => false,
          "inflation_state" => "idle"
        }
      )
      existing_location.update!(locationable: bootstrap_settlement)
    end

    # Determine manifest for engine init based on which profile was resolved.
    # The engine joins its second param with MISSIONS_PATH when it's a String,
    # or uses it directly when it's a Hash. For v2 profiles the manifest lives
    # under missions_v2/manifests/ which is NOT under MISSIONS_PATH, so we pass
    # the parsed manifest as a Hash to avoid incorrect path joining.
    engine_manifest_param = legacy_profile_rel_path
    if profile_path == v2_profile_path && File.exist?(v2_profile_path)
      v2_data = JSON.parse(File.read(v2_profile_path))
      manifest_ref = v2_data["manifest_ref"]&.to_s
      if manifest_ref
        # Read the manifest file directly and pass as Hash to avoid path joining issues
        engine_manifest_param = JSON.parse(File.read(manifest_ref))
      end
    end

    engine = AIManager::TaskExecutionEngineV2.new(target, engine_manifest_param)

    seed_inventory_from_manifest = lambda do |settlement, manifest|
      return unless settlement && manifest.is_a?(Hash)
      item_owner = settlement.owner
      if item_owner.nil?
        item_owner = Organizations::BaseOrganization.find_or_create_by!(
          identifier: "LDC-AUTOGEN",
          name: "Lunar Development Corporation",
          organization_type: :development_corporation
        )
      end

      (manifest["required_hardware"] || []).each do |hw|
        count = hw["count"].to_i
        next if count <= 0

        settlement.inventory.items.create!(
          name: hw["id"],
          amount: count,
          owner: item_owner,
          metadata: {
            "unit_type" => hw["id"],
            "role" => hw["role"],
            "task_affinity" => hw["task_affinity"]
          }
        )
      end

      (manifest["consumables"] || []).each do |cons|
        count = cons["count"].to_i
        next if count <= 0

        settlement.inventory.items.create!(
          name: cons["id"],
          amount: count,
          owner: item_owner,
          metadata: {
            "unit_type" => cons["id"],
            "purpose" => cons["purpose"]
          }
        )
      end
    end

    settlement = engine.settlement
    if settlement.nil?
      puts "\nFATAL: Could not create or find settlement for #{target}."
      exit 1
    end

    puts "Settlement: #{settlement.name} (ID: #{settlement.id})"

    # Launch origin context (seeded): Cape Canaveral Spaceport.
    earth_body = CelestialBodies::CelestialBody.find_by(identifier: 'EARTH-01')
    cape_canaveral_location = if earth_body
      Location::CelestialLocation.find_by(celestial_body: earth_body, coordinates: '28.57°N 80.65°W')
    end
    cape_canaveral = Settlement::BaseSettlement.find_by(name: 'Cape Canaveral Spaceport')
    astrolift = Organizations::BaseOrganization.find_by(identifier: 'ASTROLIFT')

    if cape_canaveral_location && cape_canaveral
      puts "Launch origin: #{cape_canaveral.name} @ #{cape_canaveral_location.coordinates}"
    else
      puts "WARNING: Cape Canaveral seed context not fully present; using direct settlement seed fallback."
    end

    if File.exist?(manifest_path)
      manifest = JSON.parse(File.read(manifest_path))
      puts "Manifest: #{manifest_path}"
      puts "Manifest ID: #{manifest["manifest_id"]}"
      puts "Required hardware entries: #{(manifest["required_hardware"] || []).count}"

      # Clear and reseed inventory to keep runs deterministic.
      settlement.inventory.items.destroy_all

      # Prefer legacy-intent staging pattern: load cargo at Cape Canaveral then transfer to Luna settlement.
      staged_via_launch = false
      if astrolift && cape_canaveral
        craft_lookup = Lookup::CraftLookupService.new
        heavy_lift_data = craft_lookup.find_craft('heavy_lift_transport')

        if heavy_lift_data
          heavy_lift = Craft::Transport::HeavyLander.create!(
            name: "LunaMission-HLT-#{SecureRandom.hex(4)}",
            craft_name: heavy_lift_data['name'],
            craft_type: heavy_lift_data['subcategory'] || heavy_lift_data['category'],
            owner: astrolift,
            deployed: false,
            operational_data: heavy_lift_data
          )
          heavy_lift.create_inventory! unless heavy_lift.inventory

          (manifest["required_hardware"] || []).each do |hw|
            count = hw["count"].to_i
            next if count <= 0
            heavy_lift.inventory.items.create!(
              name: hw["id"],
              amount: count,
              owner: astrolift,
              metadata: {
                "unit_type" => hw["id"],
                "role" => hw["role"],
                "task_affinity" => hw["task_affinity"]
              }
            )
          end

          (manifest["consumables"] || []).each do |cons|
            count = cons["count"].to_i
            next if count <= 0
            heavy_lift.inventory.items.create!(
              name: cons["id"],
              amount: count,
              owner: astrolift,
              metadata: {
                "unit_type" => cons["id"],
                "purpose" => cons["purpose"]
              }
            )
          end

          heavy_lift.inventory.items.find_each do |item|
            existing = settlement.inventory.items.find_or_initialize_by(
              name: item.name,
              owner: astrolift,
              metadata: item.metadata || {}
            )
            existing.amount = (existing.amount || 0) + item.amount
            existing.save!
          end

          staged_via_launch = true
          puts "Staged cargo via HLT launch flow from Cape Canaveral."
        end
      end

      seed_inventory_from_manifest.call(settlement, manifest) unless staged_via_launch
      puts "Seeded inventory items: #{settlement.inventory.items.count}"
    else
      puts "WARNING: V2 manifest not found at #{manifest_path}."
      puts "Deployment tasks may fail with MaterialShortageError."
    end

    phase_path_for = lambda do |phase_def|
      task_list_file = phase_def["task_list_file"].to_s

      v2_candidate = GalaxyGame::Paths::MISSIONS_V2_PHASES_PATH.join(task_list_file).to_s
      modern_candidate = GalaxyGame::Paths::MISSIONS_PATH.join(task_list_file).to_s
      legacy_candidate = GalaxyGame::Paths::MISSIONS_PATH.join("luna_base_establishment", task_list_file).to_s

      return v2_candidate if File.exist?(v2_candidate)
      return modern_candidate if File.exist?(modern_candidate)
      return legacy_candidate if File.exist?(legacy_candidate)

      nil
    end

    ensure_deploy_inventory_from_v2_tasks = lambda do |settlement_obj, profile_obj|
      item_owner = settlement_obj.owner
      if item_owner.nil?
        item_owner = Organizations::BaseOrganization.find_or_create_by!(
          identifier: "LDC-AUTOGEN",
          name: "Lunar Development Corporation",
          organization_type: :development_corporation
        )
      end

      deploy_requirements = Hash.new(0)

      (profile_obj["phases"] || []).each do |phase_def|
        phase_file_path = phase_path_for.call(phase_def)
        next if phase_file_path.nil?

        phase_data = JSON.parse(File.read(phase_file_path))
        (phase_data["tasks"] || []).each do |task_entry|
          task_ref = task_entry["task_ref"]
          next if task_ref.nil?

          task_path = GalaxyGame::Paths::MISSIONS_PATH.join(task_ref).to_s
          next unless File.exist?(task_path)

          task_data = JSON.parse(File.read(task_path))
          task_defs = task_data["tasks"].is_a?(Array) ? task_data["tasks"] : [task_data]

          task_defs.each do |task_def|
            (task_def["effects"] || []).each do |effect|
              next unless effect["action"] == "deploy_unit"

              unit_name = effect["unit"] || effect["unit_type"]
              next if unit_name.nil?

              normalized = unit_name.to_s.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_+|_+$/, "")
              deploy_requirements[normalized] += (effect["count"] || 1).to_i
            end
          end
        end
      end

      deploy_requirements.each do |normalized_unit_type, required_count|
        existing = settlement_obj.inventory.items.where("metadata ->> 'unit_type' = ?", normalized_unit_type).sum(:amount)
        missing = required_count - existing
        next if missing <= 0

        settlement_obj.inventory.items.create!(
          name: normalized_unit_type,
          amount: missing,
          owner: item_owner,
          metadata: {
            "unit_type" => normalized_unit_type,
            "seed_source" => "v2_task_effects"
          }
        )
      end
    end

    # Prefer explicit v2 execution order for this mission.
    execution_order = ["power_comms", "isru_deployment", "gas_processing", "robot_logistics"]

    # Build phase_index from profile["phases"] (v1) or from mission_plan_v2 (v2).
    phase_index = {}
    if profile["phases"].is_a?(Array) && !profile["phases"].empty?
      # v1 profile: phases array at top level
      profile["phases"].each do |phase_def|
        phase_id = phase_def["phase_id"].to_s
        phase_index[phase_id] = phase_def
      end
    elsif profile["mission_plan_ref"].to_s.present?
      # v2 profile: load mission plan to get phases
      # mission_plan_ref is relative to MISSIONS_V2_PATH (e.g. "mission_plans/luna_precursor_mission_plan_v2.json")
      # Strip the "mission_plans/" prefix since we join with MISSIONS_V2_PLANS_PATH
      plan_filename = profile["mission_plan_ref"].to_s.sub("mission_plans/", "")
      mission_plan_path = GalaxyGame::Paths::MISSIONS_V2_PLANS_PATH.join(plan_filename).to_s
      if File.exist?(mission_plan_path)
        mission_plan = JSON.parse(File.read(mission_plan_path))
        (mission_plan["phases"] || []).each do |phase_entry|
          phase_id = phase_entry["phase_id"].to_s
          # reference_file in mission plan is "phases/xxx_v2.json" — strip the "phases/" prefix
          # since phase_path_for will join with MISSIONS_V2_PHASES_PATH.
          ref_file = phase_entry["reference_file"].to_s.sub("phases/", "")
          phase_index[phase_id] = { "task_list_file" => ref_file }
        end
      else
        puts "WARNING: mission_plan_ref '#{profile['mission_plan_ref']}' not found at #{mission_plan_path}"
      end
    end

    # Fallback: if still no phases, try success_conditions.complete_phases as last resort
    if phase_index.empty? && profile["success_conditions"]["complete_phases"].is_a?(Array)
      puts "WARNING: No phases found in profile or mission plan; using success_conditions.complete_phases as fallback"
      # Map v2 phase_ids to their actual file names in missions_v2/phases/
      phase_file_map = {
        "power_comms" => "power_comms_v2.json",
        "isru_deployment" => "isru_deployment_v2.json",
        "gas_processing" => "gas_processing_v2.json",
        "robot_logistics" => "robot_logistics_v2.json"
      }
      profile["success_conditions"]["complete_phases"].each do |phase_id|
        filename = phase_file_map[phase_id] || "#{phase_id}_v2.json"
        phase_index[phase_id] = { "task_list_file" => filename }
      end
    end

    ensure_deploy_inventory_from_v2_tasks.call(settlement, profile)
    settlement.reload
    settlement.inventory.reload if settlement.inventory

    # Use a fresh settlement instance inside the engine so inventory queries are not stale.
    fresh_settlement = Settlement::BaseSettlement.find(settlement.id)
    engine.instance_variable_set(:@settlement, fresh_settlement)
    settlement = fresh_settlement

    # Preflight inventory keys used by TaskExecutionEngineV2 deploy lookup.
    puts "\nPreflight deploy inventory keys:"
    %w[
      solar_expansion_rig
      comms_equipment
      planetary_umbilical_hub
      planetary_power_management_unit
      thermal_extraction_unit
      planetary_volatiles_extractor_mk1
      gas_separator
      inflatable_pressure_tank
      inflatable_gas_storage
      inflatable_cryogenic_tank
    ].each do |unit_type_key|
      qty = settlement.inventory.items.where("metadata ->> 'unit_type' = ?", unit_type_key).sum(:amount)
      puts "  - #{unit_type_key}: #{qty}"
    end

    results = {}

    # Helper: verify task outcomes using real state checks (not just "no error")
    verify_task_outcome = lambda do |task_data, settlement_obj|
      verification_results = []
      task_defs = task_data["tasks"].is_a?(Array) ? task_data["tasks"] : [task_data]

      task_defs.each do |task_def|
        (task_def["effects"] || []).each do |effect|
          action = effect["action"]
          case action
          when "deploy_unit"
            unit_name = effect["unit"] || effect["unit_type"]
            # Handle numbered suffixes (e.g., "Inflatable Cryogenic Tank 1")
            deployed_unit = settlement_obj.units.find_by(name: unit_name) || 
                           settlement_obj.units.where("name LIKE ?", "#{unit_name}%").first
            if deployed_unit
              verification_results << "deployed #{deployed_unit.name} (id=#{deployed_unit.id})"
            else
              verification_results << "FAIL: #{unit_name} not found in settlement.units"
            end

          when "connect_units"
            unit1_name = effect["unit1"]
            unit2_name = effect["unit2"]
            unit1 = settlement_obj.units.find_by(name: unit1_name)
            if unit1
              connections = Array(unit1.operational_data&.dig("connections") || [])
              connected_to = connections.any? { |c| c.is_a?(Hash) && c["target_unit"] == unit2_name }
              if connected_to
                verification_results << "connected #{unit1_name} -> #{unit2_name}"
              else
                verification_results << "FAIL: #{unit1_name} not connected to #{unit2_name}"
              end
            else
              verification_results << "FAIL: #{unit1_name} not deployed"
            end

          when "set_unit_state"
            unit_name = effect["unit"]
            expected_state = effect["state"]
            unit = settlement_obj.units.find_by(name: unit_name)
            if unit
              actual_state = unit.operational_data&.dig("state")
              if actual_state == expected_state
                verification_results << "set #{unit_name} state to #{expected_state}"
              else
                verification_results << "FAIL: #{unit_name} state is '#{actual_state}', expected '#{expected_state}'"
              end
            else
              verification_results << "FAIL: #{unit_name} not deployed"
            end

          when "set_settlement_state"
            key = effect["key"]
            value = effect["value"]
            actual_value = settlement_obj.operational_data&.dig(key.to_s)
            if actual_value == value
              verification_results << "set settlement #{key} to #{value}"
            else
              verification_results << "FAIL: settlement #{key} is '#{actual_value}', expected '#{value}'"
            end

          when "check_unit_state"
            unit_name = effect["unit"]
            expected_state = effect["state"]
            unit = settlement_obj.units.find_by(name: unit_name)
            if unit
              actual_state = unit.operational_data&.dig("state")
              if actual_state == expected_state
                verification_results << "verified #{unit_name} is #{expected_state}"
              else
                verification_results << "FAIL: #{unit_name} state is '#{actual_state}', expected '#{expected_state}'"
              end
            else
              verification_results << "FAIL: #{unit_name} not deployed"
            end

          else
            verification_results << "#{action} (unverified)"
          end
        end
      end

      # Determine overall pass/fail from verification results
      failures = verification_results.select { |r| r.start_with?("FAIL:") }
      passed = verification_results.empty? || failures.empty?

      {
        passed: passed,
        details: verification_results,
        failure_count: failures.count
      }
    end

    execution_order.each do |phase_id|
      phase_def = phase_index[phase_id]
      if phase_def.nil?
        puts "\n------------------------------------------------------------"
        puts "PHASE: #{phase_id}"
        puts "------------------------------------------------------------"
        puts "  SKIPPED - phase not present in loaded profile"
        results[phase_id] = { tasks: [], passed: false }
        next
      end

      phase_name = phase_def["name"] || phase_id
      puts "\n------------------------------------------------------------"
      puts "PHASE: #{phase_name} (#{phase_id})"
      puts "------------------------------------------------------------"

      phase_result = { tasks: [], passed: true }
      phase_file_path = phase_path_for.call(phase_def)

      if phase_file_path.nil?
        puts "  SKIPPED - phase file missing"
        phase_result[:passed] = false
        results[phase_id] = phase_result
        next
      end

      phase_data = JSON.parse(File.read(phase_file_path))
      task_entries = phase_data["tasks"] || []

      task_entries.each do |task_entry|
        task_ref = task_entry["task_ref"]
        if task_ref.nil?
          task_id = task_entry["task_id"] || "unknown_task"
          puts "  - #{task_id}: SKIPPED (non-v2 phase task entry)"
          phase_result[:tasks] << { task_id: task_id, status: :skipped_non_v2 }
          phase_result[:passed] = false
          next
        end

        # Resolve task_ref: v2 refs start with "tasks_v2/" (relative to MISSIONS_V2_PATH),
        # v1 refs are relative to MISSIONS_PATH. Detect by prefix.
        if task_ref.start_with?("tasks_v2/")
          # Strip "tasks_v2/" prefix, append "_v2" suffix for actual filename, join with MISSIONS_V2_TASKS_PATH
          base_name = task_ref.sub("tasks_v2/", "")
          v2_filename = base_name.sub(/\.json$/, "_v2.json")
          task_path = GalaxyGame::Paths::MISSIONS_V2_TASKS_PATH.join(v2_filename).to_s
        else
          task_path = GalaxyGame::Paths::MISSIONS_PATH.join(task_ref).to_s
        end
        unless File.exist?(task_path)
          puts "  - #{task_ref}: FAIL (file not found)"
          phase_result[:tasks] << { task_id: task_ref, status: :file_missing }
          phase_result[:passed] = false
          next
        end

        task_data = JSON.parse(File.read(task_path))
        task_id = task_data["task_id"] || task_data.dig("tasks", 0, "task_id") || task_ref

        # Deploy lookup debug: show exact key TaskExecutionEngineV2 will use.
        task_defs_for_debug = task_data["tasks"].is_a?(Array) ? task_data["tasks"] : [task_data]
        task_defs_for_debug.each do |task_def|
          (task_def["effects"] || []).each do |effect|
            next unless effect["action"] == "deploy_unit"

            unit_name = effect["unit"] || effect["unit_type"]
            lookup_key = unit_name.to_s.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_+|_+$/, "")
            found = settlement.inventory.items.find_by("metadata ->> 'unit_type' = ?", lookup_key)
            puts "    deploy_lookup: unit='#{unit_name}' key='#{lookup_key}' found=#{!found.nil?} amount=#{found&.amount || 0}"
          end
        end

        begin
          success = engine.send(:execute_task, task_data)

          if success
            # Real state verification — not just "no error raised"
            verification = verify_task_outcome.call(task_data, settlement)
            if verification[:passed]
              puts "  - #{task_id}: PASS (verified: #{verification[:details].join(', ')})"
              phase_result[:tasks] << { task_id: task_id, status: :passed, verified: verification[:details] }
            else
              puts "  - #{task_id}: FAIL (verification: #{verification[:details].select { |d| d.start_with?('FAIL:') }.join(', ')})"
              phase_result[:tasks] << { task_id: task_id, status: :failed, verified: verification[:details] }
              phase_result[:passed] = false
            end
          else
            puts "  - #{task_id}: FAIL (engine returned false)"
            phase_result[:tasks] << { task_id: task_id, status: :failed }
            phase_result[:passed] = false
          end
        rescue AIManager::InfrastructureSequenceError => e
          puts "  - #{task_id}: FAIL (InfrastructureSequenceError: #{e.message})"
          phase_result[:tasks] << { task_id: task_id, status: :error, error_type: "InfrastructureSequenceError", error: e.message }
          phase_result[:passed] = false
        rescue AIManager::MaterialShortageError => e
          puts "  - #{task_id}: FAIL (MaterialShortageError: #{e.message})"
          phase_result[:tasks] << { task_id: task_id, status: :error, error_type: "MaterialShortageError", error: e.message }
          phase_result[:passed] = false
        rescue StandardError => e
          puts "  - #{task_id}: FAIL (#{e.class}: #{e.message})"
          phase_result[:tasks] << { task_id: task_id, status: :error, error_type: e.class.name, error: e.message }
          phase_result[:passed] = false
        end
      end

      phase_status = phase_result[:passed] ? "PASSED" : "PARTIAL_OR_FAILED"
      puts "\n  Phase status: #{phase_status}"
      results[phase_id] = phase_result
    end

    puts "\n" + "=" * 80
    puts "FINAL UNIT AND CONNECTION STATE"
    puts "=" * 80

    units = settlement.units.order(:created_at)
    if units.empty?
      puts "No units deployed at settlement."
    else
      puts "Deployed units: #{units.count}"
      units.each do |unit|
        op = unit.operational_data || {}
        raw_connections = op["connections"] || []
        connections = raw_connections.is_a?(Array) ? raw_connections : [raw_connections]
        puts "- #{unit.name} (type=#{unit.unit_type}, id=#{unit.id}, connections=#{connections.count})"
        connections.each do |conn|
          next unless conn.is_a?(Hash)
          target_unit = conn["target_unit"] || conn[:target_unit]
          port_label = conn["port_label"] || conn[:port_label]
          puts "    -> #{target_unit} (port_label=#{port_label})"
        end
      end
    end

    total_tasks = results.values.sum { |r| r[:tasks].count }
    passed_tasks = results.values.sum { |r| r[:tasks].count { |t| t[:status] == :passed } }
    failed_tasks = total_tasks - passed_tasks

    puts "\n" + "=" * 80
    puts "SUMMARY"
    puts "=" * 80
    puts "Phases: #{results.keys.join(', ')}"
    puts "Tasks: #{passed_tasks} passed / #{failed_tasks} not-passed (#{total_tasks} total)"

    puts "\n" + "=" * 80
    puts "KNOWN, UNRESOLVED GAPS (NOT HANDLED BY THIS RUN)"
    puts "=" * 80

    gaps_found = false

    # [3c] Stage-advancement tracking exists but no shell status/thickness field is written yet
    puts "[3c] Stage-advancement tracking exists, but no shell status/thickness field is"
    puts "      written yet — see phase6+/2026-06-27-MEDIUM-FEATURE-SHELL-STATUS-THICKNESS-FIELD.md for remaining work."
    gaps_found = true

    # [3d] Landing pad sequencing check (uses same phase_path_for lambda as rest of rake)
    phase3_def = (profile["phases"] || []).find { |p| p["phase_id"] == "gas_processing" }
    if phase3_def
      phase3_path = phase_path_for.call(phase3_def)
      if phase3_path && File.exist?(phase3_path)
        phase3 = JSON.parse(File.read(phase3_path))
        has_landing_pad = (phase3.dig("tasks") || []).any? { |t| t["task_ref"]&.include?("surface_preparation_unit_operations") }
        unless has_landing_pad
          puts "[3d] Landing pad task remains unsequenced in current v2 phase order."
          gaps_found = true
        end
      end
    end

    puts "(none)" unless gaps_found

    puts "\n" + "=" * 80
    puts "END OF REPORT"
    puts "=" * 80 + "\n"
  end
end
