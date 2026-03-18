# ATOMIC: Fix Units::Robot.settlement → Correct Association
**Status:** NEW **Priority:** HIGH **Agent:** GPT-4.1 Copilot (Agent mode) **Est:** 8min
**Predecessor:** escalation_column_fix.md (inventory ✅, robot association broken)

## Current State
✅ Architecture confirmed: Item#name ↔ Order#resource
✅ inventory.items.where(name: "medicine") ✅ CORRECT
❌ Units::Robot.create!(settlement: settlement) → Unknown attribute 'settlement'
❌ Emergency mission still nil

text

## 2-PART FIX

### Phase 1: Find Correct Robot Association
```bash
# AUDIT Robot model associations
grep -h -A 5 -B 5 "belongs_to\|has_many.*robot\|settlement" app/models/*robot*.rb app/models/*settlement*.rb

# Check robot factory
grep -n "robot\|settlement" test/factories/*.rb | grep -i robot
Likely candidates:

text
Units::Robot.belongs_to :attachable, polymorphic: true
Units::Robot belongs_to :base, class_name: 'BaseCraft'  
Units::Robot belongs_to :inventory
settlement.robots.create!(...)
Phase 2: Apply Correct Association + Test
ruby
# Replace:
# 3.times { create(:robot_unit, settlement: settlement) }

# With CORRECT association (from Phase 1):
3.times { create(:robot_unit, attachable: settlement) }
# OR
3.times { settlement.robots.create!(...) }
# OR
3.times { create(:robot_unit, inventory: settlement.inventory) }
Phase 3: Emergency Mission Verification
If robots fix → retest emergency:

bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb'
Success Criteria
 grep shows correct Robot association

 Robot creation uses proper association

 RSpec failures ≤ 1 (emergency mission only)

 Git commit: "FIX: escalation spec - correct Units::Robot association"

STOP if: No robot factory exists → create minimal before { settlement.robots << build(:robot) }

text

***

## Copy This To GPT-4.1 IMMEDIATELY:

🔧 ROBOT ASSOCIATION [8min] Units::Robot.settlement → CORRECT attr

Architecture ✅ perfect. ONE association wrong:

text
❌ Units::Robot.create!(settlement: settlement) → Unknown attribute
✅ inventory.items.where(name: "medicine") ← CORRECT
Phase 1 CRITICAL:

bash
grep -h -A 5 -B 5 "belongs_to\|has_many.*robot\|settlement" app/models/*robot*.rb
Likely: attachable: settlement or settlement.robots.create

Then: Fix robot line → rspec → GREEN imminent.

Priority: HIGH - robots block full green