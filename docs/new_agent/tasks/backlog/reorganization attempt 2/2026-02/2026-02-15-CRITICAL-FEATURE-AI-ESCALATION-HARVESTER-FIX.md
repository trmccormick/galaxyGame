# TASK: AI Escalation Harvester Fix
**Status**: BACKLOG  
**Priority**: CRITICAL  
**Type**: feature  
**Created**: 2026-02-15

---

## Problem Statement
AI Manager Escalation harvester deployment fails (5 failures):
- Oxygen harvester wrong config
- Water harvester wrong config
- Regolith miner wrong config
- HarvesterCompletionJob wrong timing
- Job never fulfills → no inventory update

## Goals
- Fix harvester deployment configs for oxygen, water, regolith
- Correct HarvesterCompletionJob timing
- Ensure job fulfillment and inventory update
- Pass all 5 related specs

## Acceptance Criteria
- [ ] All harvester deployment configs are correct
- [ ] HarvesterCompletionJob timing is fixed
- [ ] Job fulfillment and inventory update work
- [ ] All 5 escalation_integration_spec.rb failures resolved

## Implementation Notes
- Review escalation_service.rb and escalation_integration_spec.rb
- Apply fixes only after synthesis/approval
- Validate with targeted and full integration specs

## Diagnostic/Debugging
- grep -n "deploy_harvester|oxygen|water|regolith|HarvesterCompletionJob" app/services/ai_manager/escalation_service.rb
- grep -n "deploy_harvester_to_site|schedule_harvester_completion" spec/services/ai_manager/escalation_service_spec.rb
- rspec spec/integration/ai_manager/escalation_integration_spec.rb:199:245 > log/rspec_harvester.log 2>&1
- Confirm 0 failures in that range
- rspec spec/integration/ > log/rspec_integration.log 2>&1 && grep "examples,.*failures" log/rspec_integration.log

## Related Files/Paths
- app/services/ai_manager/escalation_service.rb
- spec/services/ai_manager/escalation_service_spec.rb
- spec/integration/ai_manager/escalation_integration_spec.rb

## References
- Synthesis Report (archive, 2026-02-15)

---

