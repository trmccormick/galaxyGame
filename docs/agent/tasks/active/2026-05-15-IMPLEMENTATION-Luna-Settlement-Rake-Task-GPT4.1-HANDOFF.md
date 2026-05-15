# [IMPL] AI Manager: Luna Settlement Rake Task - GPT-4.1 Implementation Handoff

**Status**: READY FOR IMPLEMENTATION  
**Priority**: HIGH  
**Assigned to**: GPT-4.1 (Implementation Agent)  
**Date Created**: 2026-05-15  
**Handoff from**: Source Review Agent (Copilot)

---

## PHASE 1: IMPLEMENTATION SCOPE

### Objective
Complete the Luna settlement rake task implementation by:
1. Expanding `TaskExecutionEngineV2#plan_tasks` to parse profile JSON phases
2. Completing the `ai_manager:settle_luna` rake task with proper Luna lookup and execution loop

### Constraint
- Keep changes limited to 2 files ONLY (unless blocker found)
- Do NOT modify PrecursorCapabilityService (it's sufficient as-is)
- Do NOT modify other rake tasks or services
- Stop for approval if additional files are required

---

## PHASE 2: EXACT FILES TO EDIT

### File 1: `app/services/ai_manager/task_execution_engine_v2.rb`
**Location**: `/Users/tam0013/Documents/git/galaxyGame/app/services/ai_manager/task_execution_engine_v2.rb`

**Current State** (lines 1-33):
```ruby
# frozen_string_literal: true

module AiManager
  class TaskExecutionEngineV2
    attr_reader :identifier, :profile_path, :environment

    def initialize(identifier, profile_path)
      @identifier = identifier
      @profile_path = profile_path
      @environment = {}
      load_profile
    end

    def load_profile
      raise "Profile not found: #{@profile_path}" unless File.exist?(@profile_path)

      @profile_data = JSON.parse(File.read(@profile_path))
    end

    def plan_tasks
      # Returns a hash of task_name => task_data
      {
        setup: { description: "Setup phase" },
        execution: { description: "Execution phase" },
        completion: { description: "Completion phase" }
      }
    end

    def environment
      @environment
    end
  end
end
```

**Method to Change**: `plan_tasks` (lines 20-27)

**Required Logic**:
```
1. Read @profile_data (already parsed in load_profile)
2. Extract phases array: @profile_data["phases"]
3. Build hash where:
   - Key: phase_id (from each phase object)
   - Value: Hash with:
     - phase_name: string
     - objectives: array of objective names
     - location: string
4. Return the built hash
5. Also populate @environment with:
   - crew: @profile_data.dig("resources", "initial_crew")
   - equipment: @profile_data.dig("resources", "initial_equipment")
   - budget: @profile_data.dig("resources", "budget")
```

**Example Input** (from luna_settlement_profile_v1.json):
```json
{
  "phases": [
    {
      "phase_name": "Site Selection",
      "phase_id": "phase_1_site_selection",
      "location": "lunar_south_pole",
      "objectives": ["identify_ice_deposits", "assess_terrain", "check_sunlight"]
    },
    ...
  ],
  "resources": {
    "initial_crew": 12,
    "initial_equipment": ["hab_module", "power_system", "water_extractor", "regolith_processor"],
    "budget": 5000000
  }
}
```

**Expected Output**:
```ruby
{
  "phase_1_site_selection" => {
    phase_name: "Site Selection",
    location: "lunar_south_pole",
    objectives: ["identify_ice_deposits", "assess_terrain", "check_sunlight"]
  },
  "phase_2_infrastructure" => { ... },
  "phase_3_isru" => { ... }
}
```

---

### File 2: `lib/tasks/ai_manager.rake`
**Location**: `/Users/tam0013/Documents/git/galaxyGame/lib/tasks/ai_manager.rake`

**Current State** (lines 26-50):
```ruby
  desc "Deploy Luna base using TaskExecutionEngineV2"
  task :settle_luna => :environment do
    puts "🌙 Luna Settlement Deployment"
    puts "=" * 40

    # Load Luna settlement profile
    profile_path = "data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json"
    profile_data = JSON.parse(File.read(profile_path))

    # Initialize TaskExecutionEngineV2
    engine = AiManager::TaskExecutionEngineV2.new("luna-settlement", profile_path)

    # Plan tasks
    task_plan = engine.plan_tasks

    puts "📋 Task plan created: #{task_plan.keys.join(", ")}"

    # Execute tasks
    task_plan.each do |task_name, task_data|
      puts "🚀 Executing task: #{task_name}"
      # Task execution logic here
    end

    puts "✅ Luna settlement deployment complete"
  rescue StandardError => e
    puts "❌ Error: #{e.message}"
    puts e.backtrace
  end
```

**Required Changes**:

1. **Luna Lookup** (after line 26):
   - Add: `luna = CelestialBodies::CelestialBody.find_by(name: "Luna")`
   - Raise error if Luna not found: `raise "Luna celestial body not found in database"`
   - Output: `puts "🌍 Luna found: #{luna.name} (ID: #{luna.id})"`

2. **Profile Path Handling** (line 31):
   - Change from: `profile_path = "data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json"`
   - To: `profile_path = Rails.root.join("data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json").to_s`

3. **Task Execution Loop** (lines 44-47):
   - Replace print-only loop with actual execution logic:
   ```ruby
   task_plan.each do |phase_id, phase_data|
     puts "🚀 Executing phase: #{phase_data[:phase_name]} (#{phase_id})"
     
     # Extract objectives and process them
     objectives = phase_data[:objectives] || []
     objectives.each do |objective|
       puts "  📌 Processing objective: #{objective}"
       # Objective execution would go here
     end
     
     puts "✅ Phase #{phase_data[:phase_name]} complete"
   end
   ```

4. **Add Luna context** (before task loop):
   - After `task_plan = engine.plan_tasks`, add:
   ```ruby
   puts "🌙 Deploying to: #{luna.name}"
   puts "📊 Crew: #{engine.environment.dig(:crew)} | Budget: $#{engine.environment.dig(:budget)}"
   ```

---

## PHASE 3: EXACT METHOD SIGNATURES

### TaskExecutionEngineV2#plan_tasks
```ruby
def plan_tasks
  # Parses @profile_data.phases[] into task hash
  # Returns: Hash[String => Hash] where keys are phase_ids
  # Side effect: populates @environment with mission resources
end
```

### TaskExecutionEngineV2 Environment Building (NEW METHOD or inline)
Option A (Recommended - inline in plan_tasks):
```ruby
# In plan_tasks, after building task_plan:
@environment = {
  crew: @profile_data.dig("resources", "initial_crew"),
  equipment: @profile_data.dig("resources", "initial_equipment"),
  budget: @profile_data.dig("resources", "budget")
}
```

Option B (Separate private method):
```ruby
private

def build_environment
  @environment = {
    crew: @profile_data.dig("resources", "initial_crew"),
    equipment: @profile_data.dig("resources", "initial_equipment"),
    budget: @profile_data.dig("resources", "budget")
  }
end
```

---

## PHASE 4: EXACT COMMANDS TO RUN

### 1. Syntax Check (after editing)
```bash
cd /Users/tam0013/Documents/git/galaxyGame
ruby -c app/services/ai_manager/task_execution_engine_v2.rb
ruby -c lib/tasks/ai_manager.rake
```

### 2. Rake Task Test (in Docker container)
```bash
docker-compose -f docker-compose.dev.yml exec -T web bundle exec rake ai_manager:settle_luna
```

**Expected output** (should not error):
```
🌙 Luna Settlement Deployment
========================================
🌍 Luna found: Luna (ID: <id>)
📋 Task plan created: phase_1_site_selection, phase_2_infrastructure, phase_3_isru
🌙 Deploying to: Luna
📊 Crew: 12 | Budget: $5000000
🚀 Executing phase: Site Selection (phase_1_site_selection)
  📌 Processing objective: identify_ice_deposits
  📌 Processing objective: assess_terrain
  📌 Processing objective: check_sunlight
✅ Phase Site Selection complete
[... more phases ...]
✅ Luna settlement deployment complete
```

### 3. Integration Spec Run (in Docker)
```bash
docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec spec/integration/luna_settlement_spec.rb --format documentation
```

**Expected**: All 3 test groups should pass or be marked pending (not fail)

### 4. Full Rake Task Syntax Validation (no execution)
```bash
docker-compose -f docker-compose.dev.yml exec -T web bundle exec rake -T | grep settle_luna
```

**Expected output**:
```
rake ai_manager:settle_luna  # Deploy Luna base using TaskExecutionEngineV2
```

---

## PHASE 5: STOP CONDITIONS

### Stop and Report if Any of These Occur:

1. **Luna Not Found in Database**
   - Error message: `undefined method 'find_by' for CelestialBodies::CelestialBody:Class`
   - Action: STOP and report class name mismatch. Actual class: ?

2. **Profile File Not Found**
   - Error message: `Profile not found: /home/galaxy_game/data/...`
   - Action: STOP and verify file path in container. Mount point issue?

3. **Integration Spec Requires Additional Services**
   - Error message: `undefined method/constant XYZ`
   - Action: STOP and list missing dependencies with exact names

4. **PrecursorCapabilityService Needs Changes**
   - Error: Spec expects method that doesn't exist
   - Action: STOP. Do not modify. Report what spec expects.

5. **Additional Files Need Changes**
   - Pattern: "undefined method" or "missing association" pointing to other files
   - Action: STOP. List files and exact requirements. Do not edit.

6. **Rake Task Fails in Container**
   - Any runtime error after syntax passes
   - Action: STOP. Provide full error trace and context

---

## PHASE 6: VALIDATION CHECKLIST

### Before Committing, Verify:

- [ ] Syntax check passes for both files (ruby -c)
- [ ] Rake task runs without error in Docker
- [ ] Output shows all 3 Luna phases (site selection, infrastructure, ISRU)
- [ ] PrecursorCapabilityService tests still pass
- [ ] Integration spec runs without new failures
- [ ] No additional files were modified
- [ ] Code follows existing patterns in the codebase
- [ ] Error handling is in place for missing Luna or profile
- [ ] Environment data properly populated from profile JSON

---

## PHASE 7: HANDOFF BLOCK FOR GPT-4.1

```
==============================================================================
IMPLEMENTATION TASK HANDOFF: Luna Settlement Rake Task
==============================================================================

SOURCE REVIEW COMPLETED ✓
All class names, namespaces, and file paths verified.

EXACT SCOPE:
  File 1: app/services/ai_manager/task_execution_engine_v2.rb
    - Method: plan_tasks (lines 20-27)
    - Change: Parse @profile_data.phases[] instead of hardcoded 3-phase stub
    - Also: Populate @environment with crew/equipment/budget from profile

  File 2: lib/tasks/ai_manager.rake  
    - Task: settle_luna (lines 26-50)
    - Change 1: Add Luna lookup via CelestialBodies::CelestialBody.find_by(name: "Luna")
    - Change 2: Fix profile path to use Rails.root.join(...)
    - Change 3: Replace print-only loop with actual execution logic

VALIDATION COMMANDS (run in order):
  1. ruby -c app/services/ai_manager/task_execution_engine_v2.rb
  2. ruby -c lib/tasks/ai_manager.rake
  3. docker-compose -f docker-compose.dev.yml exec -T web bundle exec rake ai_manager:settle_luna
  4. docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec spec/integration/luna_settlement_spec.rb --format documentation

STOP CONDITIONS:
  - If Luna not found in database → report class name mismatch
  - If profile file not found → report container path issue
  - If spec requires additional services → list dependencies, don't modify
  - If additional files need changes → list them, don't edit
  - If rake task fails in container → provide full error trace

REFERENCE DATA:
  Profile location: data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json
  Profile structure: phases[] array with phase_id, phase_name, location, objectives[]
  Profile structure: resources object with initial_crew, initial_equipment, budget
  Luna factory trait: spec/factories/celestial_body_factory.rb (trait :luna)
  Luna class: CelestialBodies::CelestialBody
  Engine class: AiManager::TaskExecutionEngineV2

EXPECTED OUTCOME:
  ✓ Rake task runs without error
  ✓ Outputs all 3 Luna phases with objectives
  ✓ Environment data populated from profile
  ✓ Integration spec passes or stays pending (no new failures)
  ✓ No additional files modified

COMMIT MESSAGE:
  "feat: Implement Luna settlement rake task with full TaskExecutionEngineV2 support"

CONTEXT FOR GPT-4.1:
  - This is a Rails 7 project with Docker containerization
  - All RSpec execution happens inside Docker container
  - Use docker-compose -f docker-compose.dev.yml exec -T web for commands
  - Follow existing rake task patterns from ai_manager:deploy_npc_base
  - Keep error handling consistent with codebase style

==============================================================================
Ready to proceed. All dependencies verified. No architectural changes needed.
==============================================================================
```

---

## PHASE 8: FILES TO VERIFY AFTER IMPLEMENTATION

After making changes, verify these files are untouched:
- ✅ `app/services/ai_manager/precursor_capability_service.rb` (should NOT change)
- ✅ `spec/integration/luna_settlement_spec.rb` (should NOT change)
- ✅ `data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json` (should NOT change)
- ✅ Any other rake tasks in `lib/tasks/` (should NOT change)

---

## PHASE 9: SUMMARY FOR IMPLEMENTATION AGENT

| Aspect | Detail |
|--------|--------|
| **Files to Edit** | 2 (task_execution_engine_v2.rb, ai_manager.rake) |
| **Methods to Modify** | 1 (TaskExecutionEngineV2#plan_tasks) + rake task block |
| **New Methods** | 0 (or 1 if extract build_environment to private method) |
| **Expected Lines Changed** | ~30-40 lines total |
| **Syntax Checks** | 2 (ruby -c for each file) |
| **Docker Tests** | 3 (rake syntax, rake execution, rspec) |
| **Risk Level** | LOW (isolated changes, no new dependencies) |
| **Estimated Time** | 30-45 minutes |

---

**Status**: READY FOR IMPLEMENTATION ✅  
**Handoff Date**: 2026-05-15  
**Previous Phase**: Source Review Complete  
**Next Phase**: Docker validation + commit

All findings from source review are embedded above. No additional discovery needed.
