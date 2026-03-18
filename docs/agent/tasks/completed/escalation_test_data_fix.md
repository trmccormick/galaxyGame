# TEST DATA: Fix Quantities, Robots, Emergency Mission
**Status:** NEW **Priority:** MEDIUM-HIGH **Agent:** GPT-4.1 Copilot (Agent mode) **Est:** 12min
**Predecessor:** escalation_final_fixes.md (attribute errors ✅ fixed)

## Current State (Attribute Cleanup Complete)
✅ All syntax/attribute errors fixed
❌ 5 data/setup failures:

Robot count: expected 3, got 0

Harvester quantity: expected 1000, got 10

Import quantity: expected 500, got 10 (0.1e2)
4-5. Emergency medicine mission: still nil

text

## ROOT CAUSE: Factory Defaults vs Test Expectations
Tests expect specific quantities/robots that factories don't provide.

## TARGETED FIXES

### 1. ROBOT COUNT (expected 3, got 0)
```ruby
before do
  3.times { create(:robot_unit, settlement: settlement) }  # or :robot
end
2-3. QUANTITY MISMATCHES (1000→10, 500→10)
Override factory defaults in ALL relevant lets:

ruby
let(:expired_water_order) do
  create(:market_order, 
    resource: 'water',
    base_settlement: settlement,
    created_at: 25.hours.ago,
    quantity: 1000  # Match harvester test expectation
  )
end

let(:expired_medicine_order) do
  create(:market_order, 
    resource: 'medicine',
    base_settlement: settlement,
    created_at: 25.hours.ago,
    quantity: 500   # Match import test expectation
  )
end
4-5. EMERGENCY MISSION NIL
Medicine needs inventory shortage + correct trigger:

ruby
before do
  # Clear medicine from inventory (create shortage)
  settlement.inventory.items.where(resource: 'medicine').destroy_all
  # Create expired order (pending demand)
  expired_medicine_order  # Triggers from let above
end

# Verify emergency handler receives Material object
let(:medicine_material) { Material.find_by(name: 'medicine')! }
EXECUTION PLAN (4 Phases)
Phase 1: Audit Current Test Expectations
bash
# Find ALL expect() quantity/robot numbers:
grep -n "expect.*\(3\|1000\|500\)" spec/integration/ai_manager/escalation_integration_spec.rb
Phase 2: Match Factory Quantities to Expectations
text
robot_unit: create 3x
water_order: quantity: 1000
medicine_order: quantity: 500
ALL other orders: match their expect() values
Phase 3: Fix + Test
Add before { 3.times { create(:robot_unit, settlement: settlement) } }

Set explicit quantity: matching each test expectation

Clear medicine inventory to trigger shortage

Commit: git commit -m "FIX: escalation spec test data - quantities/robots match expectations"

Test: docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb'

Phase 4: GREEN Celebration
text
✅ 0 failures → Update CURRENT_STATUS.md: "escalation_integration_spec.rb: ✅ GREEN (test data fixed)"
Report: "Escalation specs 100% green. Total failures now XXXX"
Success Criteria
 3 robots created in before block

 All quantity: values match expect() values from Phase 1 grep

 Medicine inventory cleared (shortage created)

 RSpec: 0 failures

STOP if: :robot_unit factory missing → check :robot or model name.

