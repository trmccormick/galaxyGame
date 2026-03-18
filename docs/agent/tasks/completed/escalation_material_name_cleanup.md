# ATOMIC: Complete material_name → resource: Replacement
**Status:** NEW **Priority:** MEDIUM **Agent:** GPT-4.1 Copilot (Agent mode) **Est:** 5min
**Predecessor:** escalation_integration_spec_followup.md (partial success)

## Current State
✅ 4/6 original fixes complete
✅ let blocks corrected (oxygen/water/iron)
❌ Remaining material_name: references somewhere in file
❌ Medicine emergency still failing (likely same root cause)

text

## SINGLE ATOMIC FIX

### Global Search & Destroy `material_name:`
```bash
# In escalation_integration_spec.rb, find ALL:
grep -n "material_name:" spec/integration/ai_manager/escalation_integration_spec.rb
Replace EVERY instance:

ruby
# ❌ FIND
material_name: 'oxygen'
material_name: 'water' 
material_name: 'medicine'
material_name: 'robot_repair_kit'

# ✅ REPLACE
resource: 'oxygen'
resource: 'water'
resource: 'medicine'
resource: 'robot_repair_kit'
EXECUTION PLAN (3 Phases)
Phase 1: Find Remaining Offenders
bash
grep -n "material_name:" spec/integration/ai_manager/escalation_integration_spec.rb
Document exact line numbers and contexts found.

Phase 2: Replace + Test
Replace ALL material_name: → resource:

Commit: git commit -m "FIX: complete material_name → resource: cleanup in escalation spec"

Test: docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/ai_manager/escalation_integration_spec.rb'

Phase 3: Status Update
If ✅ 0 failures: Update CURRENT_STATUS.md

If ❌ medicine still fails: Create medicine_emergency_debug.md

Success Criteria
 grep "material_name:" returns ZERO results

 Git commit with all replacements

 RSpec failures ≤ 1 (medicine emergency only)

STOP if: resource: also rejected by factory (check factory definition).

text

***

## Copy This Command to GPT-4.1 Copilot (Agent Mode)

⚡ QUICK [5min] ATOMIC: Kill remaining material_name: references

docs/agent/tasks/active/escalation_material_name_cleanup.md created.

Issue: Lingering material_name: somewhere causing Market::Order factory fails.

SINGLE command:

bash
grep -n "material_name:" spec/integration/ai_manager/escalation_integration_spec.rb
Then replace ALL material_name: → resource:

3 phases:

grep find exact locations

Global replace + commit + test

Status update

Start with grep - show me exactly where they hide.

Priority: MEDIUM - one grep away from green
Time: 5min