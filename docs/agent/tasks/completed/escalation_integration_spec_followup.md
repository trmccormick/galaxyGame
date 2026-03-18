# FOLLOWUP: Fix 2 Remaining Escalation Spec Failures
**Status:** NEW **Priority:** MEDIUM **Agent:** GPT-4.1 Copilot (Agent mode) **Est:** 10min
**Location:** docs/agent/tasks/active/
**Predecessor:** escalation_integration_spec_fix.md (4/6 fixes successful)

## Current State (Post-Atomic Patch)
✅ Fixed: :expired trait, inventory.items.where, robot_repair_order, missing lets
❌ Broken:

NoMethodError: undefined method 'material_name=' for Market::Order

Emergency mission test: expected not nil, got nil (medicine shortage)

text

## EXACT 2 FAILURES + FIXES

### 1. Market::Order Factory - `material_name=` doesn't exist
**FactoryBot uses `resource:` not `material_name:`**
```ruby
# ❌ BAD (causes NoMethodError)
create(:market_order, material_name: 'oxygen', base_settlement: settlement, created_at: 25.hours.ago)

# ✅ GOOD
create(:market_order, resource: 'oxygen', base_settlement: settlement, created_at: 25.hours.ago)
SEARCH & REPLACE ALL in spec file:

text
material_name: → resource:
2. Medicine Emergency Mission Not Triggering
Medicine shortage needs proper setup (no local production):

ruby
let(:expired_medicine_order) do
  create(:market_order, 
    resource: 'medicine',  # ← FIXED attribute name
    base_settlement: settlement,
    created_at: 25.hours.ago,
    quantity: 10,  # Ensure actual shortage amount
    fulfilled: false  # Ensure still pending
  )
end

# Verify medicine Material exists
let(:medicine_material) { Material.find_by(name: 'medicine')! }

# Test should check:
expect(ai_manager.handle_emergency_shortage(medicine_material)).not_to be_nil
EXECUTION PLAN (3 Phases)
Phase 1: Confirm Current Failures
bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb'
Expect: Exactly 2 failures matching above.

Phase 2: Apply Precise Fixes + Commit
Global replace material_name: → resource: in escalation_integration_spec.rb

Add let(:expired_medicine_order) with quantity: 10, fulfilled: false

Ensure handle_emergency_shortage receives correct Material object

Commit: git commit -m "FIX: escalation spec - Market::Order resource attr + medicine emergency"

Phase 3: Verify Green + Status
bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb'
Success: 0 failures → Update CURRENT_STATUS.md