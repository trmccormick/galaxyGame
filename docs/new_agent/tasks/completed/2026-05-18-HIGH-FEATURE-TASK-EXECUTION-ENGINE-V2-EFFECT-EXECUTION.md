---
status: completed
priority: HIGH
type: feature
system_domain: AI_MANAGER
mvp_alignment: AI_MANAGER_LUNA_SETTLEMENT
local_worker_safe: false
---

# TASK: Port Effect Execution from TaskExecutionEngine to TaskExecutionEngineV2 with Inventory Sourcing
**Status**: ✅ COMPLETED
**Priority**: HIGH
**Type**: feature
**Created**: 2026-05-17
**Last Updated**: 2026-05-18
**Completed**: 2026-05-18

---

## 🚨 MANDATORY AGENT VERIFICATION PROTOCOL
Read `docs/new_agent/rules/GUARDRAILS.md` first, then this task file completely BEFORE DOING ANYTHING ELSE — prove you read the guardrails.

Your first response must contain ONLY this confirmation block:
```text
========================================================================
🚨 GUARDRAILS READ CONFIRMATION 🚨
------------------------------------------------------------------------
• Rule 1 (Docker): All commands run inside Docker — no exceptions
• Rule 7 (RSpec Output): Never Stream Full Output
• Rule 10 (Host vs Docker Path Policy): Execute git/file operations on host;
  execute specs/tasks inside web container.
========================================================================
Do not proceed until this confirmation is approved by the human.

```

---

## Local Worker Triage Report

* **Template Conformance**: PASS
* **Docker Wrapper Check**: PASS
* **MVP Alignment**: VALID — This fixes the gap where `rake ai_manager:settle_luna` prints logs but doesn't perform active database mutations to deploy infrastructure.
* **Action Line**: READY FOR CLOUD HANDOFF

---

## Agent Assignment

**Assigned To**: Haiku 0.33x or GitHub Copilot (Diagnostic & Rules-driven)
**Why This Agent**: Porting core structural loops from V1 to V2 while enforcing precise ActiveRecord transactional mutations and local physical infrastructure constraints.
**Supervision Level**: Watched carefully — Mutates infrastructure state and inventory records.

---

## Context

`TaskExecutionEngineV2` currently loops through the Luna settlement profile and plans tasks, but it only logs action text rather than executing mutations on database entities.

The V1 engine (`TaskExecutionEngine`) contains operational effect logic. We are porting this engine behavior into the V2 system to handle the `tasks_v2` payload architecture, which maps actions into nested `effects` arrays inside a parent `tasks` wrapper.

### The Sourcing & Physical Gating Core Rules

1. **The Sourcing Rule**: Units cannot be manifested out of thin air. The engine must locate the landing Heavy Lift Transport (`Craft::BaseCraft`) tracked at the active `@settlement`. It must query the transport's `inventory.items` table using `metadata ->> 'unit_type'`, decrement or destroy the item row from the craft hold inside an atomic transaction, and only then instantiate the active surface `Units::BaseUnit` record. If materials are missing, raise an explicit `AIManager::MaterialShortageError`.
2. **Sintered Foundation Gate**: If the target unit matches an inflatable tank configuration asset (`inflatable_cryo_tank` or `inflatable_pressure_tank`), it must evaluate `settlement.operational_data['foundation_sintered'] == true`. If false, raise an explicit `AIManager::InfrastructureSequenceError` (mimicking the landing pad site-preparation loop).
3. **Central Utility Hub Hookup**: Inflatable tanks additionally require an active, physically anchored `central_utility_hub` present on the site to handle fluid anchor routing lines before inflation can engage.
4. **Linear Inflation-Before-Shell Logic**: Bladders require concurrent early extraction gas streams from active TEU/PVE cycles to reach full structural pressure stability *before* the shell printer can be triggered to wrap them in an armored `inert_regolith_waste` composite enclosure.

**Relevant files:**

* `app/services/ai_manager/task_execution_engine_v2.rb` — target engine to update
* `app/services/ai_manager/task_execution_engine.rb` — V1 reference source
* `lib/tasks/ai_manager.rake` — master Rake orchestration point

---

## Problem Statement

**Current Behavior**: Running the automated build sequence prints out `→ deploy_unit` log lines but leaves the database completely empty, preventing testing of live simulation cycles.

**Expected Behavior**: Iterating through task effects runs actual database state changes inside an explicit transaction block, strictly adhering to infrastructure sequence dependencies.

---

## Focus Areas & Implementation Steps

### Step 1 — Read and Confirm Guardrails

* Halt sequence and output the required `GUARDRAILS READ CONFIRMATION` text block. Do not write or touch any files until approved.

### Step 2 — Port and Adapt the V2 Task Iterator

Update the task loop execution method to flat-map the nested V2 array format down to individual execution effects inside `app/services/ai_manager/task_execution_engine_v2.rb`:

```ruby
def execute_task(task)
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

```

### Step 3 — Implement the Core Effect Router & Physical State Verification

Add routing blocks to catch target action tokens mapped from your configuration schemas, executing strict structural validation for inflatable infrastructure:

```ruby
def execute_effect(effect)
  case effect['action']
  when 'deploy_unit'
    deploy_unit_from_effect(effect)
  when 'connect_units'
    connect_units_from_effect(effect)
  else
    puts "  → Unknown effect action: #{effect['action']} (skipping)"
    true
  end
end

```

### Step 4 — Build deploy_unit_from_effect with Strict Inventory & Foundation Gating

Code the inventory-to-surface lifecycle. Enforce atomic transaction safety, check the sintered foundation slab flag, verify utility hub presence, and handle cargo hold subtractions:

```ruby
def deploy_unit_from_effect(effect)
  return true unless @settlement
  
  unit_name = effect['unit'] || effect['unit_type']
  count = effect['count'] || 1
  is_inflatable = ['inflatable_cryo_tank', 'inflatable_pressure_tank'].include?(unit_name.downcase.underscore)
  
  # 1. Physical Site Prep Foundation Gating
  if is_inflatable
    unless @settlement.operational_data["foundation_sintered"] == true
      raise AIManager::InfrastructureSequenceError.new("Target site requires an excavated, sintered basaltic slab foundation before anchoring inflatable tank systems.")
    end
    
    unless @settlement.units.exists?(unit_type: 'central_utility_hub')
      raise AIManager::InfrastructureSequenceError.new("Inflatable tanks must connect to an anchored central_utility_hub to begin inflation cycles.")
    end
  end

  # 2. Cargo Sourcing and Verification
  ActiveRecord::Base.transaction do
    source_item = @settlement.inventory.items.find_by("metadata ->> 'unit_type' = ?", unit_name.downcase.underscore)
    
    if source_item.nil? || source_item.amount < count
      raise AIManager::MaterialShortageError.new(unit_name, count)
    end

    blueprint_service = Lookup::BlueprintLookupService.new
    full_blueprint = blueprint_service.find_blueprint(unit_name)
    return true if full_blueprint.nil?

    # Mutate Craft Inventory Manifest
    if source_item.amount == count
      source_item.destroy!
    else
      source_item.update!(amount: source_item.amount - count)
    end

    # Instantiate Active Surface Record (Saves tracking parameters to operational_data PORO fields)
    count.times do |i|
      Units::BaseUnit.create!(
        identifier: "unit_#{SecureRandom.hex(8)}",
        name: count > 1 ? "#{unit_name} #{i+1}" : unit_name,
        unit_type: full_blueprint['id'],
        location: @settlement.location,
        owner: @settlement,
        operational_data: (full_blueprint['physical_properties'] || {}).merge({
          "inflation_state" => is_inflatable ? "inflating" : "solid",
          "shell_printed" => false
        })
      )
    end
  end
  true
end

```

### Step 5 — Produce a Synthesis Report

* STOP and paste the code layout adjustment details into the terminal/chat pane for human code review before mutating the disk layer.

---

## Verification Suite

Execute the manual Rake sequence inside the web container:

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && bundle exec rake ai_manager:settle_luna'

```

Execute the local integration suite:

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/luna_settlement_integration_spec.rb'

```

---

## Acceptance Criteria

* [x] Nested arrays inside V2 task payloads successfully flat-map to sequential effects.
* [x] Deployed hardware items are cleanly subtracted from the landing craft manifest via atomic database transactions.
* [x] Inflatable tank assets block execution and throw sequence errors if the foundation slab is not sintered or the utility hub is missing.
* [x] All code components utilize localized PORO logic structures updating existing JSONB `operational_data` fields to avoid schema bloat.
* [x] Isolation run: 0 failures, 0 regressions.

## Completion Details

**Test Results**: All 4 Luna integration tests passing
- ✅ 4 examples, 0 failures

**Implementation Files**:
- ✅ [errors.rb](app/services/ai_manager/errors.rb) — MaterialShortageError, InfrastructureSequenceError
- ✅ [task_execution_engine_v2.rb](app/services/ai_manager/task_execution_engine_v2.rb) — Full effect execution with inventory sourcing and physical gating
- ✅ [ai_manager.rb](app/services/ai_manager.rb) — Module loader with correct require order

**Git Commit**:
- Commit: 52bc22b4
- Message: feat: task_execution_engine_v2 effect execution with inventory sourcing and physical gating
- Branch: regional-view-phase2
