# CRITICAL: Escalation Spec Architecture Review
**Status:** NEW **Priority:** CRITICAL **Agent:** GPT-4.1 Copilot **Est:** 15min
**Blocks:** escalation_column_fix.md (needs model context)

## PROBLEM
Blind patching fixed syntax but **test data expectations unknown**.

## NEED FULL MAPPING:
Settlement → Inventory → Items (name: "medicine", amount: X)
↓
Market::Order (resource: "medicine", quantity: Y, created_at: 25h.ago)
↓
AI::Escalation → Emergency Mission (medicine shortage)

text

## TASKS (3 Phases)

### Phase 1: Model Recon
```bash
# SHOW RELEVANT MODELS
grep -h -A 10 -B 5 "has_many.*inventory\|belongs_to.*inventory\|robot\|medicine" app/models/*.rb
rails runner "puts Material.find_by(name: 'medicine').inspect" -e test
Phase 2: Test Expectation Audit
bash
# EXACT numbers tests expect
grep -n "expect.*\(3\|1000\|500\|medicine\)" spec/integration/ai_manager/escalation_integration_spec.rb
Phase 3: Data Flow Diagram + Fix Template
CREATE docs/escalation_data_flow.md showing:

text
1. settlement.inventory.items.create(name: "medicine", amount: 10)
2. create(:market_order, resource: "medicine", quantity: 500, ...)
3. ai_manager.handle_emergency_shortage → Mission.new
Success Criteria
 Model associations mapped

 Test expectations documented

 Data flow diagram in docs/escalation_data_flow.md

 NO CODE CHANGES - review only

text

***

## Copy This To GPT-4.1 NOW:

🔍 CRITICAL ARCHITECTURE REVIEW: Escalation Spec Data Flow

docs/agent/tasks/active/escalation_architecture_review.md

STOP BLIND PATCHING. Item spec shows:

text
Item#name ←→ MarketOrder.resource  
Item#amount ←→ test expectations (1000/500/3 robots)
Need GPT-4.1 to:

grep ALL inventory/robot associations in models

Audit EXACT test expectations

Diagram data flow → fix template

Start Phase 1:

bash
grep -h -A 10 -B 5 "has_many.*inventory\|belongs_to.*inventory\|robot\|medicine" app/models/*.rb
NO CODE CHANGES - mapping first.

