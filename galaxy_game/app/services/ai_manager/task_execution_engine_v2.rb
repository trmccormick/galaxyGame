# Prototype: TaskExecutionEngineV2
# - Data-driven, parameterized, and generic
# - Works with tasks_v2 JSON task library
# - No hardcoded world/material logic
# - Accepts a target (e.g., "Luna") and a manifest/profile
# - Selects and executes tasks based on environment and mission goals

module AIManager
  class TaskExecutionEngineV2
    def initialize(target_body, manifest = {})
      @target_body = target_body.is_a?(String) ? target_body : target_body.identifier
      @manifest = manifest
      @environment = load_environment(@target_body)
      @task_library = load_task_library
      @task_plan = []
      @current_task_index = 0
      @required_capabilities = extract_required_capabilities_from_manifest(manifest)
    end

    attr_reader :target_body, :environment, :manifest, :task_plan

    # Main entry: plan and execute settlement
    def settle
      plan_tasks
      execute_tasks
    end

    # Step 1: Plan tasks based on environment and manifest
    def plan_tasks
      # Use extracted required_capabilities from manifest, or fallback
      capabilities = @required_capabilities
      capabilities = ["power", "habitat", "comms"] if capabilities.nil? || capabilities.empty?
      @task_plan = []
      capabilities.each do |capability|
        task = select_task_for_capability(capability)
        @task_plan << parameterize_task(task) if task
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
      # Optionally, add more extraction logic for other manifest fields
      capabilities.uniq
    end

    # Step 2: Execute planned tasks
    def execute_tasks
      @task_plan.each_with_index do |task, idx|
        puts "Executing task #{idx+1}/#{@task_plan.length}: #{task["metadata"]["name"]}"
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
        "atmosphere"      => body.atmosphere.present?,
        "has_regolith"    => capabilities[:surface].any?,
        "local_resources" => capabilities[:surface] + capabilities[:atmosphere].to_a,
        "isru_capable"    => capabilities[:isru_options].any?,
        "capabilities"    => capabilities
      }
    end

    def load_task_library
      # Loads all tasks_v2 JSON files into an array
      task_dir = File.expand_path("../../../../data/json-data/missions/tasks_v2", __dir__)
      Dir[File.join(task_dir, "task_*.json")].map { |f| JSON.parse(File.read(f)) }
    end

    def select_task_for_capability(capability)
      # If capability looks like a task_id, match by metadata.name or file name
      task = @task_library.find do |t|
        t["metadata"] && (
          t["metadata"]["name"] == capability ||
          t["metadata"]["name"] == capability.sub(/^task_/, "") ||
          t["metadata"]["name"] == capability.sub(/_v\d+$/, "")
        )
      end
      return task if task
      # Fallback: try tags
      @task_library.find { |t| t["metadata"]["tags"].include?(capability) rescue false }
    end

    def parameterize_task(task)
      # Replace $target_body in steps with actual target
      task = Marshal.load(Marshal.dump(task)) # deep copy
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
