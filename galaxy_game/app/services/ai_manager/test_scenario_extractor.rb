module AIManager
  class TestScenarioExtractor
    def self.extract_training_scenarios
      scenarios = []

      # Extract from OperationalManager specs
      scenarios << {
        scenario_id: 'critical_life_support_failure',
        settlement_state: {
          oxygen_level: 15, # Critical threshold
          water_level: 80,
          food_level: 75,
          debt_level: 10000,
          construction_queue: [],
          available_resources: { oxygen: 0, water: 500, food: 300 }
        },
        expected_decision: {
          action: :emergency_procurement,
          resource: :oxygen,
          priority: :critical,
          reason: 'life_support_critical'
        },
        success_criteria: 'oxygen_reserves_above_50_percent'
      }

      # Extract operational needs scenario
      scenarios << {
        scenario_id: 'resource_procurement_needed',
        settlement_state: {
          oxygen_level: 75,
          water_level: 25, # Below operational threshold
          food_level: 80,
          debt_level: 5000,
          construction_queue: ['water_reclamation_facility'],
          available_resources: { oxygen: 200, water: 50, food: 400 }
        },
        expected_decision: {
          action: :resource_procurement,
          resource: :water,
          amount: 1000,
          priority: :operational,
          reason: 'water_shortage'
        },
        success_criteria: 'water_reserves_above_75_percent'
      }

      # Extract expansion scenario
      scenarios << {
        scenario_id: 'stable_expansion_opportunity',
        settlement_state: {
          oxygen_level: 85,
          water_level: 80,
          food_level: 85,
          debt_level: 0,
          construction_queue: [],
          available_resources: { oxygen: 500, water: 800, food: 600 },
          isru_capability: 0.8, # High local production ratio
          equipment_count: 45
        },
        expected_decision: {
          action: :expansion,
          pattern: :npc_base_deploy_pattern,
          priority: :strategic,
          reason: 'high_isru_efficiency'
        },
        success_criteria: 'pattern_implemented_with_positive_roi'
      }

      scenarios
    end

    def self.extract_patterns_from_missions
      patterns = []
      manifest_parser = AIManager::ManifestParser.new

      # Find all mission folders
      mission_dirs = Dir.glob("#{GalaxyGame::Paths::MISSIONS_PATH}/*").select { |f| File.directory?(f) }

      mission_dirs.each do |mission_dir|
        pattern = extract_pattern_from_mission(mission_dir, manifest_parser)
        patterns << pattern if pattern
      end

      patterns
    end

    def self.extract_pattern_from_mission(mission_dir, manifest_parser)
      mission_name = File.basename(mission_dir)

      # Find profile and manifest files
      profile_file = Dir.glob("#{mission_dir}/*profile*.json").first
      manifest_file = Dir.glob("#{mission_dir}/*manifest*.json").first

      return nil unless profile_file && manifest_file

      # Load profile for phases and metadata
      profile = load_json(profile_file)

      # Extract equipment and economics from manifest
      manifest_data = manifest_parser.extract_equipment_from_manifest(manifest_file)

      # Load phase files for detailed tasks
      phases = extract_phases_from_profile(profile, mission_dir)

      {
        pattern_id: derive_pattern_name(profile['mission_id'] || mission_name),
        deployment_sequence: phases,
        equipment_requirements: manifest_data[:craft_fit].merge(manifest_data[:inventory]),
        resource_dependencies: {
          units_required: manifest_data[:inventory][:deployable_units] || [],
          total_unit_count: manifest_data[:inventory][:deployable_units]&.size || 0,
          critical_equipment: identify_critical_equipment(manifest_data)
        },
        economic_model: manifest_data[:economic_profile],
        phase_structure: analyze_phase_structure(phases),
        critical_path: identify_critical_path(phases),
        learned_from: "mission_json_analysis",
        learned_at: Time.current.iso8601,
        source_file: profile_file,
        manifest_file: manifest_file
      }
    end

    def self.convert_to_training_format(scenarios)
      training_data = []

      scenarios.each do |scenario|
        training_data << {
          input_state: scenario[:settlement_state],
          output_decision: scenario[:expected_decision],
          reward_function: scenario[:success_criteria],
          confidence_score: 0.9 # High confidence for test-derived scenarios
        }
      end

      training_data
    end

    private

    def self.load_json(file_path)
      JSON.parse(File.read(file_path))
    rescue JSON::ParserError, Errno::ENOENT
      {}
    end

    def self.derive_pattern_name(mission_name)
      case mission_name
      when /mars/ then 'mars_pattern'
      when /venus/ then 'venus_pattern'
      when /lunar/ then 'lunar_pattern'
      when /titan/ then 'titan_pattern'
      when /belt/ then 'belt_pattern'
      else "#{mission_name}_pattern"
      end
    end

    def self.extract_phases_from_profile(profile, mission_dir)
      return [] unless profile['phases']

      profile['phases'].map do |phase|
        phase_file_key = phase['phase_file'] || phase['task_list_file']
        next unless phase_file_key

        phase_file = "#{mission_dir}/#{phase_file_key}"
        phase_data = load_json(phase_file)

        {
          phase_file: phase_file_key,
          phase_name: phase['phase_name'] || phase['name'] || phase_data['phase_name'],
          phase_id: phase['phase_id'],
          estimated_duration: phase['estimated_duration'] || phase_data['estimated_duration'],
          dependencies: phase['dependencies'] || [],
          task_count: phase_data['tasks']&.size || 0,
          critical_path: identify_phase_critical_path(phase_data)
        }
      end.compact
    end

    def self.identify_critical_equipment(manifest_data)
      craft_fit = manifest_data[:craft_fit] || {}
      inventory = manifest_data[:inventory] || {}

      critical = []

      # Critical craft modules
      if craft_fit[:modules]
        critical += craft_fit[:modules].select do |mod|
          mod.include?('nuclear_reactor') || mod.include?('radiation_shielding')
        end
      end

      # Critical deployable units
      if inventory[:deployable_units]
        critical += inventory[:deployable_units].select do |unit|
          unit.include?('Harvesters') || unit.include?('Assembly Drones')
        end
      end

      critical
    end

    def self.analyze_phase_structure(phases)
      {
        total_phases: phases.size,
        phase_types: phases.map { |p| identify_phase_type(p) }.uniq,
        estimated_total_duration: phases.sum { |p| p[:estimated_duration].to_i },
        parallel_phases: identify_parallel_phases(phases)
      }
    end

    def self.identify_phase_type(phase)
      phase_name = phase[:phase_name].to_s.downcase

      if phase_name.include?('landing') || phase_name.include?('deployment')
        'initial_deployment'
      elsif phase_name.include?('construction') || phase_name.include?('building')
        'infrastructure_construction'
      elsif phase_name.include?('processing') || phase_name.include?('production')
        'resource_processing'
      elsif phase_name.include?('transfer') || phase_name.include?('establishment')
        'equipment_transfer'
      else
        'operational'
      end
    end

    def self.identify_parallel_phases(phases)
      # Simple heuristic: phases with no dependencies can run in parallel
      phases.select { |p| p[:dependencies].empty? }.size
    end

    def self.identify_critical_path(phases)
      # Identify the longest chain of dependent phases
      phases.select { |p| p[:critical_path] }.map { |p| p[:phase_name] }
    end

    def self.identify_phase_critical_path(phase_data)
      # Extract critical tasks from phase data
      return [] unless phase_data['tasks']

      phase_data['tasks'].select do |task|
        task['critical'] == true || task['blocking'] == true
      end.map { |t| t['task_id'] || t['name'] }
    end
  end
end