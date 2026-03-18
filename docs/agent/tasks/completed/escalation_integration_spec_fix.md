# CRITICAL: Fix 6 Failures in escalation_integration_spec.rb
**Status:** NEW **Priority:** CRITICAL **Agent:** GPT-4.1 Copilot (Agent mode) **Est:** 20min

## Current State (Mar 18, 2026)
4016 examples, 177 failures, 20 pending
Escalation cluster: 6 failures in escalation_integration_spec.rb
Baseline stable, no dev DB corruption

text

**ALWAYS** run RSpec with: `unset DATABASE_URL && RAILS_ENV=test bundle exec rspec`

## EXACT 6 Failures + Fixes

### 1. FactoryBot `:expired` trait → KeyError
**Replace ALL** `:expired` traits with explicit timestamps:
```ruby
# ❌ BAD
create(:market_order, :expired, material_name: 'water', base_settlement: settlement)

# ✅ GOOD  
create(:market_order, material_name: 'water', base_settlement: settlement, created_at: 25.hours.ago)
2. settlement.inventory.where → NoMethodError
Inventory is NOT ActiveRecord. Use collection proxy:

ruby
# ❌ BAD
settlement.inventory.where(name: 'oxygen').destroy_all

# ✅ GOOD
settlement.inventory.items.where(name: 'oxygen').destroy_all
3. Robot count expect 3 got 0
Missing robot_repair_kit setup. Add:

ruby
let(:robot_repair_order) do
  create(:market_order, 
    material_name: 'robot_repair_kit', 
    base_settlement: settlement,
    created_at: 25.hours.ago
  )
end
4-5. Missing let(:expired_oxygen_order) scope breakage
Add these lets in relevant context blocks:

ruby
let(:expired_oxygen_order) do
  create(:market_order, material_name: 'oxygen', base_settlement: settlement, created_at: 25.hours.ago)
end

let(:expired_water_order) do
  create(:market_order, material_name: 'water', base_settlement: settlement, created_at: 25.hours.ago)
end
6. Emergency mission nil → wrong shortage material
EMERGENCY tier = medicine only (no local production):

ruby
let(:emergency_material) { Material.find_by(name: 'medicine')! }
# NOT oxygen/water/food - those are lower priority
PHYSICS HIERARCHY (NEVER VIOLATE)
Tier	Materials	Production
LOCAL	water, O2, regolith	ISRU/shell
ROBOTS	robot_repair_kit, spare_parts, food	High priority
EMERGENCY	medicine	IMPORT ONLY
SPECIAL	advanced_tech	IMPORT ONLY
EXECUTION PLAN (4 Phases)
Phase 1: Single Spec Run + Failure Capture
bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb > /home/galaxy_game/log/escalation_$(date +%s).log 2>&1'
Success: Log file created. Next: Phase 2.

Phase 2: Apply All 6 Fixes
Replace every :expired → created_at: 25.hours.ago

Fix settlement.inventory.where → settlement.inventory.items.where

Add let(:robot_repair_order) block

Add missing expired_oxygen_order/expired_water_order lets

Change emergency test to use 'medicine' material

Commit: `git commit -m "FIX: escalation_integration_spec.rb - 6 failures

Success: All fixes applied + committed. Next: Phase 3.

Phase 3: Verify Fixes
bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb'
Success: 0 failures. Next: Phase 4.
Failure: Read log, create docs/agent/tasks/active/escalation_followup.md, STOP.

Phase 4: Update Status + Handoff
Update CURRENT_STATUS.md → "escalation_integration_spec.rb: ✅ 0 failures"

Report back: "Escalation specs fixed. Total failures now: XXXX"

Mark this task ✅ COMPLETE

RSpec Command Template (Copy/Paste)
bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb'
Success Criteria
 Phase 1: Log file created in ./data/logs/

 Phase 2: Git commit with all 6 fixes

 Phase 3: rspec passes with 0 failures

 Phase 4: CURRENT_STATUS.md updated

STOP if: Dev DB corruption detected, spec failures > 10, git conflicts.

text

***

## Copy This Command to GPT-4.1 Copilot (Agent Mode Required)

🔥 CRITICAL [15min] ISSUE: 6 failures blocking escalation_integration_spec.rb

I've created docs/agent/tasks/critical/escalation_integration_spec_fix.md with EXACT fixes for all 6 failures.

CRITICAL: Enable Agent mode (Cmd+, → chat.agent.enabled → restart VS Code), then follow docs/agent/README.md + TASK_PROTOCOL.md.

The 6 failures:

FactoryBot :expired trait missing → use created_at: 25.hours.ago

settlement.inventory.where → NoMethodError (use .items)

Robot count expect 3 got 0 → missing robot_repair_kit
4-5. Missing let(:expired_oxygen_order) definitions

Emergency mission nil → wrong material (must be 'medicine')

Your 4-phase tasks:

Run single spec → capture log (Phase 1)

Apply all 6 fixes → git commit (Phase 2)

Verify 0 failures (Phase 3)

Update CURRENT_STATUS.md (Phase 4)

Start with Phase 1 - need fresh failure log.

Priority: CRITICAL - blocks AI escalation testing
Time: 15-20min
Agent: GPT-4.1 Copilot Agent Mode