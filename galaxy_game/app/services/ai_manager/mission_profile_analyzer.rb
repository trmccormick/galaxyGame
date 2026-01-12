module AIManager
  class MissionProfileAnalyzer
    def self.analyze_all_mission_profiles
      missions_path = GalaxyGame::Paths::MISSIONS_PATH
      patterns = {}
      
      Dir.glob(missions_path.join('**/*_profile_v*.json')).each do |profile_path|
        pattern = analyze_profile(profile_path)
        patterns[pattern[:pattern_id]] = pattern if pattern
      end
      
      # Save extracted patterns
      save_patterns(patterns)
      patterns
    end
    
    def self.train_ai_manager_with_patterns(ai_manager = nil)
      puts "🤖 === TRAINING AI MANAGER WITH MISSION PROFILE PATTERNS ==="
      
      patterns = analyze_all_mission_profiles
      
      if patterns.empty?
        puts "❌ No patterns found to train with"
        return false
      end
      
      puts "📋 Found #{patterns.size} patterns for training:"
      patterns.each do |pattern_id, pattern|
        puts "  • #{pattern_id}: #{pattern[:phase_structure][:total_phases]} phases, #{pattern[:equipment_requirements][:total_unit_count]} units"
      end
      
      # If no AI manager provided, create a training instance
      if ai_manager.nil?
        ai_manager = create_training_ai_manager
      end
      
      trained_patterns = 0
      patterns.each do |pattern_id, pattern|
        if train_single_pattern(ai_manager, pattern)
          trained_patterns += 1
          puts "✅ Trained pattern: #{pattern_id}"
        else
          puts "❌ Failed to train pattern: #{pattern_id}"
        end
      end
      
      puts "🎓 Training complete! Successfully trained #{trained_patterns}/#{patterns.size} patterns"
      save_training_results(patterns, trained_patterns)
      
      trained_patterns > 0
    end
    
    def self.analyze_profile(profile_path)
      profile = JSON.parse(File.read(profile_path))
      
      {
        pattern_id: extract_pattern_id(profile),
        deployment_sequence: extract_sequence(profile),
        resource_dependencies: extract_dependencies(profile),
        equipment_requirements: extract_equipment(profile),
        phase_structure: extract_phases(profile),
        economic_model: extract_economics(profile),
        critical_path: extract_critical_path(profile['phases'] || [], profile),
        learned_from: "mission_json_analysis",
        learned_at: Time.current.iso8601,
        source_file: File.basename(profile_path)
      }
    end
    
    private
    
    def self.profile_has_foundry_equipment?(profile)
      inventory = profile.dig('inventory', 'units') || []
      has_atmospheric = inventory.any? { |u| u['name'].to_s.match?(/atmospheric|skimmer/i) }
      has_cnt_fabricator = inventory.any? { |u| u['name'].to_s.match?(/cnt_fabricator/i) }
      has_atmospheric && has_cnt_fabricator
    end
    
    def self.extract_pattern_id(profile)
      mission_id = profile['mission_id']
      
      # Check for interplanetary foundry pattern
      if profile_has_foundry_equipment?(profile)
        'interplanetary_foundry'
      else
        case mission_id
        when /lunar/i
          'lunar_pattern'
        when /venus/i
          'venus_pattern'
        when /mars/i
          'mars_pattern'
        when /titan/i
          'titan_pattern'
        when /belt/i
          'belt_pattern'
        else
          "#{mission_id}_pattern"
        end
      end
    end
    
    def self.extract_sequence(profile)
      phases = profile['phases'] || []
      
      phases.map do |phase|
        task_file = phase['task_list_file']
        task_data = load_task_data(task_file, profile['mission_id'])
        phase_tasks = load_phase_tasks(profile, phase)
        
        {
          phase_file: task_file,
          phase_name: phase['name'],
          phase_id: phase['phase_id'],
          estimated_duration: phase_tasks[:estimated_duration] || task_data&.dig('estimated_duration_hours') || phase['estimated_duration_hours'],
          dependencies: task_data&.dig('dependencies') || phase['dependencies'] || [],
          task_count: phase_tasks[:task_count] || task_data&.dig('tasks')&.size || 0,
          critical_path: (task_data ? identify_critical_tasks(task_data) : []) + phase_tasks[:critical_tasks]
        }
      end
    end
    
    def self.extract_dependencies(profile)
      inventory = profile.dig('inventory', 'units') || []
      
      {
        units_required: inventory.map { |u| u['name'] },
        total_unit_count: inventory.sum { |u| u['count'] },
        critical_equipment: inventory.select { |u| u['critical'] }.map { |u| u['name'] }
      }
    end
    
    def self.extract_equipment(profile)
      manifest = load_manifest_for_profile(profile)
      return {} unless manifest
      
      units = manifest.dig('inventory', 'units') || []
      craft_units = manifest.dig('inventory', 'craft') || []
      rigs = manifest.dig('inventory', 'rigs') || []
      
      {
        units: (units + craft_units).map { |u| u['name'] }.uniq,
        rigs: rigs.map { |r| r['name'] },
        total_unit_count: units.sum { |u| u['count'] || 1 } + craft_units.sum { |u| u['count'] || 1 },
        critical_equipment: identify_critical_equipment(units + craft_units),
        power_units: identify_power_units(units),
        habitat_units: identify_habitat_units(units),
        resource_units: identify_resource_units(units)
      }
    end
    
    def self.extract_phases(profile)
      phases = profile['phases'] || []
      
      total_duration = 0
      phase_types = []
      
      phases.each do |phase|
        phase_tasks = load_phase_tasks(profile, phase)
        duration = phase_tasks[:estimated_duration] || phase['estimated_duration_hours'] || 0
        total_duration += duration
        phase_types << categorize_phase(phase['task_list_file'] || phase['phase_file'] || '')
      end
      
      {
        total_phases: phases.count,
        phase_types: phase_types,
        estimated_total_duration: total_duration
      }
    end
    
    def self.extract_economics(profile)
      manifest = load_manifest_for_profile(profile)
      return {} unless manifest
      
      total_cost = calculate_manifest_cost(manifest)
      
      {
        estimated_gcc_cost: total_cost,
        import_ratio: estimate_import_ratio(manifest),
        local_production_ratio: estimate_local_ratio(manifest)
      }
    end
    
    def self.categorize_phase(phase_file)
      case phase_file
      when /landing|arrival|site/i
        'landing'
      when /habitat|tube|dome|pressurization/i
        'habitat_construction'
      when /extraction|mining|harvest/i
        'resource_extraction'
      when /processing|refining|manufacturing/i
        'processing_facility'
      when /station|depot|orbital/i
        'orbital_infrastructure'
      when /cycler|logistics|network/i
        'cycler_operations'
      when /skimmer|atmospheric/i
        'atmospheric_harvesting'
      when /cnt|foundry/i
        'foundry_production'
      when /power|energy|reactor/i
        'power_systems'
      when /deployment|setup/i
        'deployment'
      when /stabilization|satellites/i
        'wormhole_operations'
      else
        'generic'
      end
    end
    
    def self.load_manifest_for_profile(profile)
      mission_id = profile['mission_id']
      
      # Try multiple manifest naming patterns and locations
      potential_paths = [
        # Pattern 1: Manifests directory with mission_id.json
        Rails.root.join('data', 'json-data', 'manifests', 'missions', "#{mission_id}.json"),
        # Pattern 2: Manifests directory with mission_id_manifest_v1.json
        Rails.root.join('data', 'json-data', 'manifests', 'missions', "#{mission_id}_manifest_v1.json"),
        # Pattern 3: Mission directory (original location)
        GalaxyGame::Paths::MISSIONS_PATH.join(
          mission_id.gsub('_', '-'),
          "#{mission_id}_manifest_v1.json"
        ),
        # Pattern 4: Mission directory with generic manifest.json
        GalaxyGame::Paths::MISSIONS_PATH.join(
          mission_id.gsub('_', '-'),
          "manifest.json"
        ),
        # Pattern 5: Root missions directory
        GalaxyGame::Paths::MISSIONS_PATH.join("#{mission_id}_manifest.json")
      ]
      
      potential_paths.each do |path|
        if File.exist?(path)
          Rails.logger.info "[Analyzer] Found manifest: #{path}"
          return JSON.parse(File.read(path))
        end
      end
      
      Rails.logger.warn "[Analyzer] No manifest found for #{mission_id}"
      nil
    end
    
    def self.calculate_manifest_cost(manifest)
      # Simplified cost calculation
      units = manifest.dig('inventory', 'units') || []
      units.sum { |u| u['count'] * estimate_unit_cost(u['name']) }
    end
    
    def self.estimate_unit_cost(unit_name)
      # Lookup from blueprints or use defaults
      case unit_name
      when /skimmer/i then 50000
      when /cnt|foundry/i then 75000
      when /drone/i then 25000
      when /processor|fabricator/i then 100000
      else 10000
      end
    end
    
    def self.estimate_import_ratio(manifest)
      # Analyze which materials must be imported vs produced locally
      materials = manifest.dig('inventory', 'materials') || []
      
      imported = materials.count { |m| must_import?(m['name']) }
      total = materials.count
      
      total > 0 ? (imported.to_f / total).round(2) : 0.0
    end
    
    def self.estimate_local_ratio(manifest)
      1.0 - estimate_import_ratio(manifest)
    end
    
    def self.must_import?(material)
      # Materials that cannot be produced locally
      ['electronics', 'advanced_computer', 'specialized_sensor'].include?(material.downcase)
    end
    
    def self.load_task_data(task_file, mission_id)
      return nil unless task_file
      
      # Convert mission_id to directory format (lunar_precursor_1 -> lunar-precursor)
      mission_dir = mission_id.gsub('_', '-').gsub(/-\d+$/, '')
      task_path = GalaxyGame::Paths::MISSIONS_PATH.join(mission_dir, task_file)
      
      return nil unless File.exist?(task_path)
      JSON.parse(File.read(task_path))
    rescue => e
      Rails.logger.warn "[MissionProfileAnalyzer] Failed to load task data: #{e.message}"
      nil
    end
    
    def self.load_phase_tasks(profile, phase)
      phase_file = phase['task_list_file']
      mission_id = profile['mission_id']
      
      return { task_count: 0, task_types: [], estimated_duration: nil, critical_tasks: [] } unless phase_file
      
      # Try to find phase file in mission directory
      mission_dir = mission_id.gsub('_', '-').gsub(/-\d+$/, '')
      phase_path = GalaxyGame::Paths::MISSIONS_PATH.join(mission_dir, phase_file)
      
      return { task_count: 0, task_types: [], estimated_duration: nil, critical_tasks: [] } unless File.exist?(phase_path)
      
      phase_data = JSON.parse(File.read(phase_path))
      tasks = phase_data['tasks'] || []
      
      {
        task_count: tasks.count,
        task_types: tasks.map { |t| t['type'] }.uniq,
        estimated_duration: calculate_phase_duration(tasks),
        critical_tasks: tasks.select { |t| t['critical'] == true }.map { |t| t['task_id'] }
      }
    rescue => e
      Rails.logger.warn "[MissionProfileAnalyzer] Failed to load phase tasks for #{phase_file}: #{e.message}"
      { task_count: 0, task_types: [], estimated_duration: nil, critical_tasks: [] }
    end

    def self.calculate_phase_duration(tasks)
      # Estimate based on task complexity
      base_hours = {
        'deploy' => 4,
        'construct' => 24,
        'connect' => 2,
        'transfer' => 1,
        'survey' => 8,
        'harvest' => 12,
        'process' => 16,
        'manufacture' => 20,
        'stabilize' => 6,
        'test' => 4
      }
      
      tasks.sum { |task| base_hours[task['type']] || 8 }
    end
    
    def self.identify_critical_tasks(task_data)
      return [] unless task_data && task_data['tasks']
      
      task_data['tasks'].select { |t| t['critical'] == true }.map { |t| t['task_id'] }
    end
    
    def self.extract_critical_path(phases, profile)
      critical_path = []
      
      phases.each do |phase|
        phase_tasks = load_phase_tasks(profile, phase)
        
        # Identify critical tasks (those with dependencies or high duration)
        critical_tasks = phase_tasks[:critical_tasks] || []
        
        # Also check for tasks with dependencies or long duration
        if phase_tasks[:estimated_duration] && phase_tasks[:estimated_duration] > 48
          # Add all tasks from long phases as potentially critical
          critical_tasks += phase_tasks[:task_types] if phase_tasks[:task_types]
        end
        
        critical_path << {
          phase: phase['phase_id'],
          critical_tasks: critical_tasks.uniq
        } if critical_tasks.any?
      end
      
      critical_path
    end
    
    def self.identify_critical_equipment(units)
      critical_types = ['power', 'comms', 'life_support', 'rtg', 'umbilical']
      units.select { |u| critical_types.any? { |type| u['name'].downcase.include?(type) } }
           .map { |u| u['name'] }
    end
    
    def self.identify_power_units(units)
      power_keywords = ['power', 'solar', 'rtg', 'generator', 'battery']
      units.select { |u| power_keywords.any? { |kw| u['name'].downcase.include?(kw) } }
           .map { |u| u['name'] }
    end
    
    def self.identify_habitat_units(units)
      habitat_keywords = ['habitat', 'inflatable', 'pressure', 'dome', 'shell']
      units.select { |u| habitat_keywords.any? { |kw| u['name'].downcase.include?(kw) } }
           .map { |u| u['name'] }
    end
    
    def self.create_training_ai_manager
      # For now, just return nil - we'll validate patterns without a full AI manager instance
      nil
    end
    
    def self.validate_pattern_structure(pattern)
      required_keys = [:pattern_id, :deployment_sequence, :resource_dependencies, 
                      :equipment_requirements, :phase_structure, :economic_model]
      
      missing_keys = required_keys.select { |key| !pattern.key?(key) }
      
      if missing_keys.any?
        raise "Pattern missing required keys: #{missing_keys.join(', ')}"
      end
      
      # Validate phase structure
      unless pattern[:phase_structure][:total_phases].is_a?(Integer) && pattern[:phase_structure][:total_phases] > 0
        raise "Invalid phase structure: total_phases must be a positive integer"
      end
      
      # Validate equipment requirements
      unless pattern[:equipment_requirements][:total_unit_count].is_a?(Integer)
        raise "Invalid equipment requirements: total_unit_count must be an integer"
      end
    end
    
    def self.train_single_pattern(ai_manager, pattern)
      begin
        # For now, just validate the pattern structure and save it
        # The actual training will be done through rake tasks or integration tests
        validate_pattern_structure(pattern)
        
# Prioritize foundry patterns when lunar elevator project is active        priority = if pattern[:pattern_id] == 'interplanetary_foundry'                     'HIGH PRIORITY (Foundry for Lunar Elevator)'                   else                     'Standard'                   end        puts "  📋 Pattern #{pattern[:pattern_id]} validated (#{priority}):"
        puts "    • #{pattern[:phase_structure][:total_phases]} phases"
        puts "    • #{pattern[:equipment_requirements][:total_unit_count]} units"
        puts "    • #{pattern[:economic_model][:estimated_gcc_cost]} GCC cost"
        
        true
      rescue => e
        Rails.logger.error "[MissionProfileAnalyzer] Failed to validate pattern #{pattern[:pattern_id]}: #{e.message}"
        false
      end
    end
    
    def self.save_training_results(patterns, trained_count)
      results = {
        training_session: Time.current.iso8601,
        total_patterns: patterns.size,
        trained_patterns: trained_count,
        failed_patterns: patterns.size - trained_count,
        patterns_trained: patterns.keys,
        training_method: 'direct_mission_profile_analysis'
      }
      
      results_path = Rails.root.join('data', 'json-data', 'ai-manager', 'training_results.json')
      File.write(results_path, JSON.pretty_generate(results))
      
      puts "💾 Training results saved to #{results_path}"
    end
    
    def self.identify_resource_units(units)
      resource_keywords = ['extractor', 'harvester', 'processor', 'fabricator', 'printer']
      units.select { |u| resource_keywords.any? { |kw| u['name'].downcase.include?(kw) } }
           .map { |u| u['name'] }
    end
    
    def self.save_patterns(patterns)
      output_path = GalaxyGame::Paths::AI_MISSION_PATTERNS_PATH
      
      File.write(output_path, JSON.pretty_generate(patterns))
      Rails.logger.info "[MissionProfileAnalyzer] Saved #{patterns.count} patterns to #{output_path}"
    end
  end

  class PatternComparator
    def self.find_similar_patterns
      patterns = load_mission_profile_patterns
      
      similarities = {
        atmospheric_harvesting: [],
        orbital_construction: [],
        isru_focused: [],
        cycler_dependent: []
      }
      
      patterns.each do |pattern_id, pattern|
        # Check for atmospheric harvesting
        deployment_sequence = pattern[:deployment_sequence] || []
        if deployment_sequence.any? { |p| p[:phase_name].to_s.match?(/atmospheric|skimmer/i) }
          similarities[:atmospheric_harvesting] << pattern_id
        end
        
        # Check for orbital construction
        if deployment_sequence.any? { |p| p[:phase_name].to_s.match?(/orbital|station/i) }
          similarities[:orbital_construction] << pattern_id
        end
        
        # Check for ISRU focus
        economic_model = pattern[:economic_model] || {}
        if economic_model[:local_production_ratio] == 1.0
          similarities[:isru_focused] << pattern_id
        end
        
        # Check for cycler dependency
        if deployment_sequence.any? { |p| p[:phase_name].to_s.match?(/cycler/i) }
          similarities[:cycler_dependent] << pattern_id
        end
      end
      
      similarities
    end
    
    def self.load_mission_profile_patterns
      patterns_path = Rails.root.join('data', 'json-data', 'ai-manager', 'mission_profile_patterns.json')
      
      if File.exist?(patterns_path)
        JSON.parse(File.read(patterns_path)).deep_symbolize_keys
      else
        {}
      end
    end
  end
end