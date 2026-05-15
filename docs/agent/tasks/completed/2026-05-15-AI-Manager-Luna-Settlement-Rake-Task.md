# TASK: AI Manager Luna Settlement Rake Task — V2 Engine Integration
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-05-15
**Last Updated**: 2026-05-15
**MVP Gate**: YES — this is the observable proof that the AI Manager settles Luna correctly

---

## Agent Assignment
**Assigned To**: Haiku (0.33x) for implementation — GPT-4.1 for mechanical parts
**Why This Agent**: Requires reasoning about existing patterns and integration
**Supervision Level**: 🔴 Watched carefully — touches multiple services

---

## Context

We have existing rake tasks that simulated Luna settlement using the old
`TaskExecutionEngineV1` with hardcoded world attributes and stub production
services. The new architecture uses:

- `TaskExecutionEngineV2` — loads world from DB, reads profile phases, plans tasks
- `PrecursorCapabilityService` — determines what Luna can produce from real DB data
- `GalaxyGame::Paths::MISSIONS_PATH` — correct path constants, works in Docker
- Real `MaterialProcessingService` — not stub production calculations
- `luna_settlement_profile_v1.json` — the mission profile with 3 phases

The Luna integration spec already proves these services work together:
`spec/services/ai_manager/luna_settlement_integration_spec.rb` — 4/4 passing

This task creates a rake task that runs the full settlement end-to-end
and produces observable output for human review.

**Reference rake tasks (read these first):**
- `lib/tasks/lunar_base_pipeline.rake` — original pattern, output format
- `lib/tasks/lunar_base_with_isru_pipeline.rake` — ISRU production pattern
- `lib/tasks/npc_base_deployment.rake` — clean mission execution pattern

**Reference data files:**
- `data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json`
- `data/json-data/missions/luna_base_establishment/luna_base_establishment_manifest_v2.json`
- `data/json-data/missions/luna_base_establishment/phases/phase_1_power_comms.json`
- `data/json-data/missions/luna_base_establishment/phases/phase_2_isru_deployment.json`
- `data/json-data/missions/luna_base_establishment/phases/phase_3_gas_processing.json`

---

## Problem Statement

**Current behavior**: No rake task exists that runs `TaskExecutionEngineV2`
end-to-end against a real DB and produces observable output.

**Expected behavior**: Running `rake ai_manager:settle_luna` should:
1. Find Luna in the real DB (not create it with hardcoded attributes)
2. Run `PrecursorCapabilityService` and print what Luna can produce
3. Find or create a settlement at Shackleton Crater
4. Run `TaskExecutionEngineV2` with the Luna profile
5. Print each phase executing with task names
6. Print final status — units deployed, jobs started, inventory

---

## Files to Create

### Primary
| File | Purpose |
|---|---|
| `lib/tasks/ai_manager_settle.rake` | New rake task |

### Reference Only (do not edit)
| File | Why |
|---|---|
| `app/services/ai_manager/task_execution_engine_v2.rb` | Engine to use |
| `app/services/ai_manager/precursor_capability_service.rb` | Capability check |
| `app/services/manufacturing/material_processing_service.rb` | ISRU production |
| `lib/tasks/lunar_base_with_isru_pipeline.rake` | Output format reference |

---

## Implementation Steps

### Step 1 — Read reference files before writing anything

Read these completely:
```bash
cat lib/tasks/npc_base_deployment.rake
cat lib/tasks/lunar_base_with_isru_pipeline.rake
cat app/services/ai_manager/task_execution_engine_v2.rb
cat app/services/ai_manager/precursor_capability_service.rb
cat data/json-data/missions/luna_base_establishment/luna_settlement_profile_v1.json
```

### Step 2 — Produce Synthesis Report and STOP

```
SYNTHESIS REPORT

TaskExecutionEngineV2 initialize signature:
  [show exact signature]

plan_tasks returns:
  [describe task_plan structure]

environment hash contains:
  [list keys]

PrecursorCapabilityService.production_capabilities returns:
  [list keys including has_regolith, isru_capable, isru_options]

Profile phases:
  [list phase_ids and task counts]

Proposed rake task structure:
  [outline the steps]

Questions:
  [anything unclear]
```

Wait for approval before writing any code.

### Step 3 — Implement the rake task

Follow this structure exactly:

```ruby
# lib/tasks/ai_manager_settle.rake
namespace :ai_manager do
  desc "Run AI Manager Luna settlement using TaskExecutionEngineV2"
  task settle_luna: :environment do
    puts "\n=== AI Manager: Luna Settlement ==="
    puts "Using TaskExecutionEngineV2 + PrecursorCapabilityService"
    puts "Profile: luna_settlement_profile_v1.json"
    puts ""

    # 1. Load Luna from real DB — no hardcoded attributes
    puts "1. Loading Luna from database..."
    luna = CelestialBodies::CelestialBody.find_by(identifier: 'LUNA-01')
    raise "Luna (LUNA-01) not found in database. Run db:seed first." unless luna
    puts "  ✓ Found: #{luna.name} (#{luna.type})"

    # 2. Run PrecursorCapabilityService — what can Luna produce?
    puts "\n2. Analyzing Luna capabilities..."
    capabilities = AIManager::PrecursorCapabilityService.new(luna).production_capabilities
    puts "  ✓ Has regolith: #{capabilities[:has_regolith]}"
    puts "  ✓ ISRU capable: #{capabilities[:isru_capable]}"
    puts "  ✓ ISRU options: #{capabilities[:isru_options].join(', ')}"
    puts "  ✓ Surface resources: #{capabilities[:surface].join(', ')}"

    # 3. Find or create organization and settlement
    puts "\n3. Setting up settlement..."
    org = Organizations::BaseOrganization.find_or_create_by!(
      identifier: 'LDC'
    ) do |o|
      o.name = 'Lunar Development Corporation'
      o.organization_type = :development_corporation
      o.operational_data = { 'is_npc' => true }
    end

    location = Location::CelestialLocation.find_or_create_by!(
      name: "Shackleton Crater Base",
      celestial_body: luna
    ) do |loc|
      loc.coordinates = "89.90°S 0.00°E"
    end

    settlement = Settlement::BaseSettlement.find_or_create_by!(
      name: "Luna Base Alpha",
      owner: org,
      location: location
    )
    settlement.create_inventory! unless settlement.inventory
    puts "  ✓ Settlement: #{settlement.name} (ID: #{settlement.id})"
    puts "  ✓ Location: #{location.name}"

    # 4. Initialize TaskExecutionEngineV2 with profile path
    puts "\n4. Initializing TaskExecutionEngineV2..."
    profile_path = "luna_base_establishment/luna_settlement_profile_v1.json"
    engine = AIManager::TaskExecutionEngineV2.new('LUNA-01', profile_path)
    puts "  ✓ Environment loaded"
    puts "  ✓ Identifier: #{engine.environment['identifier']}"
    puts "  ✓ Has regolith: #{engine.environment['has_regolith']}"
    puts "  ✓ Atmosphere: #{engine.environment['atmosphere']}"

    # 5. Plan tasks
    puts "\n5. Planning tasks from profile phases..."
    engine.plan_tasks
    puts "  ✓ Phases planned: #{engine.task_plan.keys.join(', ')}"
    engine.task_plan.each do |phase_id, tasks|
      task_count = tasks.is_a?(Array) ? tasks.size : 1
      puts "  ✓ Phase #{phase_id}: #{task_count} tasks"
    end

    # 6. Execute settlement
    puts "\n6. Executing settlement plan..."
    engine.task_plan.each do |phase_id, tasks|
      puts "\n  --- Phase: #{phase_id} ---"
      task_list = tasks.is_a?(Array) ? tasks : [tasks]
      task_list.each do |task|
        name = task.dig('metadata', 'name') ||
               task.dig('tasks', 0, 'task_id') ||
               'unnamed_task'
        puts "    → Executing: #{name}"
      end
      puts "    ✓ Phase #{phase_id} complete"
    end

    # 7. Start ISRU production job if capable
    if capabilities[:isru_capable]
      puts "\n7. Starting ISRU production..."
      begin
        service = Manufacturing::MaterialProcessingService.new(settlement)
        job = service.create_processing_job(
          job_type: 'thermal_extraction',
          unit_type: 'teu'
        )
        puts "  ✓ TEU job created: #{job.job_type} (status: #{job.status})"
      rescue => e
        puts "  ⚠ ISRU job creation skipped: #{e.message}"
      end
    end

    # 8. Final status
    puts "\n=== FINAL STATUS ==="
    puts "\nSettlement:"
    puts "  Name: #{settlement.name}"
    puts "  Owner: #{org.name}"
    puts "  Location: #{location.name}"

    puts "\nLuna Capabilities:"
    puts "  ISRU Mode: #{engine.manifest.dig('parameters', 'isru_mode') || 'regolith_teu_pve'}"
    puts "  Early outputs: #{engine.manifest.dig('parameters', 'early_isru_outputs')&.join(', ') || 'O2, H2, He3'}"
    puts "  Import dependencies: #{engine.manifest.dig('parameters', 'import_dependencies')&.join(', ') || 'CH4, N2'}"

    puts "\nPhases Completed:"
    engine.task_plan.keys.each { |phase| puts "  ✓ #{phase}" }

    puts "\nInventory:"
    settlement.inventory.items.order(:name).each do |item|
      puts "  - #{item.name}: #{item.amount}"
    end

    puts "\n✓ AI Manager Luna Settlement Complete!"
    puts "  TaskExecutionEngineV2 successfully settled Luna using"
    puts "  world-agnostic task library and real DB data."
  end
end
```

### Step 4 — Verify it runs

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && bundle exec rake ai_manager:settle_luna 2>&1'
```

The task should complete without errors and print the final status block.

### Step 5 — Run integration spec to confirm no regressions

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/luna_settlement_integration_spec.rb 2>&1 | tail -5'
```

Expected: 4 examples, 0 failures

### Step 6 — Commit from host

```bash
git add lib/tasks/ai_manager_settle.rake
git commit -m "feat: ai_manager:settle_luna rake task — TaskExecutionEngineV2 end-to-end settlement with observable output"
git push
```

---

## Acceptance Criteria
- [ ] `rake ai_manager:settle_luna` runs without errors
- [ ] Luna loaded from real DB — no hardcoded attributes
- [ ] `PrecursorCapabilityService` output printed
- [ ] All 3 phases shown in output
- [ ] ISRU job created if capable
- [ ] Final status block printed
- [ ] Luna integration spec still 4/4 passing
- [ ] No new test failures

---

## Stop Conditions
- Luna not found in DB — flag, do not create with hardcoded attributes
- `TaskExecutionEngineV2` raises on profile load — check path and report
- `MaterialProcessingService` missing `create_processing_job` — report, skip ISRU step gracefully
- Any currently passing spec breaks — stop and report

---

## Completion Report
**Completed by**:
**Completion date**:
**Final rake output**: [paste last 20 lines]
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed