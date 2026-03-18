# ROOT-CAUSE: Debug Escalation Service Logic (3 Failures)
**Status:** NEW **Priority:** CRITICAL **Agent:** GPT-4.1 Copilot (Agent mode) **Est:** 20min
**Predecessor:** escalation_final_2_fixes.md (test data ✅ PERFECT)

## Current State (Test Data 100% Correct)
✅ Architecture confirmed
✅ inventory.items.where(name: "medicine")
✅ Robot associations fixed
✅ NO attribute/quantity errors
✅ fulfilled: removed, quantities: 500
❌ 3 SERVICE LOGIC failures:

Robot creation not triggered (expired orders → 0 robots created)

Emergency mission nil (service not creating)

[3rd failure from log]

text

## DEBUG PLAN (4 Phases)

### Phase 1: Capture EXACT Failures + Service Code
```bash
# Get precise 3 failures
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb --format documentation > /home/galaxy_game/log/escalation_final_3.log 2>&1'

# Find escalation service code
find app -name "*escalation*" -o -name "*ai_manager*" | xargs grep -l "handle\|mission\|robot"
Phase 2: Service Logic Audit
Map the actual service methods:

text
AI::EscalationManager#handle_expired_buy_orders([expired_orders])
↓
Does it call Units::Robot.create!? [YES/NO]
AI::EscalationManager#handle_emergency_shortage(material)
↓  
Does it return Mission? [YES/NO/NIL]
Phase 3: Stub Analysis + Missing Triggers
bash
# Check for missing stubs
grep -r "stub.*escalation\|allow.*Escalation\|allow.*Mission" spec/integration/ai_manager/
Phase 4: Precise Logic Fixes
Common service bugs:

Robot trigger: Service expects order.status == 'expired' but order defaults 'pending'

Mission nil: handle_emergency_shortage missing settlement: param or wrong Material lookup

Quantity calc: Service divides by 100 somewhere (500→5→10?)

Success Criteria
 Exact service file identified

 3 failures mapped to specific service methods

 Missing stubs/parameters documented

 docs/escalation_service_debug.md with logic fixes

STOP if: Service doesn't exist → specs test wrong class

text

***

## Copy This To GPT-4.1 NOW:

🔍 SERVICE LOGIC DEBUG [20min] 3 failures = business logic bugs

Test data ✅ PERFECT. Service logic broken:

text
1. Expired orders → 0 robots created (service not calling Robot.create!)
2. handle_emergency_shortage → nil (no mission)
3. [Capture exact 3rd]
Phase 1 CRITICAL:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb --format documentation > /home/galaxy_game/log/escalation_final_3.log 2>&1'
Then find service:

bash
find app -name "*escalation*" -o -name "*ai_manager*"
NO MORE TEST DATA FIXES - debug actual service methods.

Priority: CRITICAL - service logic blocks