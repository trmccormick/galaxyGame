Read docs/agent/README.md first, then create task file: docs/agent/tasks/active/ai_escalation_harvester_fix.md

[CRITICAL] ISSUE: AI Manager Escalation harvester deployment fails (5 failures)
Lines 199,210,222,233,245 in ai_manager/escalation_integration_spec.rb

The issue:
AIManager::EscalationService.deploy_harvester_to_site + schedule_harvester_completion
- Oxygen harvester wrong config  
- Water harvester wrong config
- Regolith miner wrong config
- HarvesterCompletionJob wrong timing
- Job never fulfills → no inventory update

Your tasks:
1. Read task file completely before touching code
2. Run: grep -n "deploy_harvester\|oxygen\|water\|regolith\|HarvesterCompletionJob" app/services/ai_manager/escalation_service.rb
3. Run: grep -n "deploy_harvester_to_site\|schedule_harvester_completion" spec/services/ai_manager/escalation_service_spec.rb
4. Produce Synthesis Report and STOP — wait for approval
5. Apply approved fix only
6. rspec spec/integration/ai_manager/escalation_integration_spec.rb:199:245 > log/rspec_harvester.log 2>&1
7. Confirm 0 failures in that range
8. rspec spec/integration/ > log/rspec_integration.log 2>&1 && grep "examples,.*failures" log/rspec_integration.log
9. git commit -am "Fix AI Escalation harvester deployment pipeline (5 specs)"
10. Report new baseline

Priority: CRITICAL  
Estimated time: 90 minutes  
Agent: Mid-tier — clear pattern across 5 related examples
