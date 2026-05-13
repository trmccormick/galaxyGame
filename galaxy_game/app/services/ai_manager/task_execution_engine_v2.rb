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
    end

    attr_reader :target_body, :environment, :manifest, :task_plan

    # Main entry: plan and execute settlement
    def settle
      plan_tasks
      execute_tasks
    end

    # Step 1: Plan tasks based on environment and manifest
    def plan_tasks
      @task_plan = {}
      
      # If manifest has phases, load tasks from phase files
      if @manifest["phases"].is_a?(Array)
        @manifest["phases"].each do |phase|
          phase_id = phase["phase_id"]
          task_list_file = phase["task_list_file"]
          if task_list_file
            phase_tasks = load_phase_tasks(task_list_file)
            @task_plan[phase_id] = phase_tasks if phase_tasks.any?
          end
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
      # Prototype: just print steps
      task["steps"].each do |step|
        puts "  → #{step["action"]}: #{step.reject { |k, _| k == "action" }}"
      end
      true
    end
  end
end
