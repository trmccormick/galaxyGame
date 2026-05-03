# 2026-04-17-ADVANCED-CLAUDE-IMPLEMENT-AI-MANAGER-OPERATIONAL-ESCALATION.md

## Task Title
Implement AI Manager Operational Escalation System (Advanced)

## Task Overview
Finalize, test, and document the AI Manager's operational escalation system for handling expired buy orders, automated harvesting, special missions, and scheduled imports. Ensure all logic is actionable, template-compliant, and fully integrated with the codebase. Assign to Claude or equivalent advanced agent.

## Background & Context
- The core escalation system is implemented: EscalationService, automated harvester deployment, special mission creation, scheduled import coordination, and integration with ResourceAcquisitionService and OperationalManager.
- EmergencyMissionService and ContractCreationService are present, with some methods as stubs or placeholders.
- Some features remain as TODOs: full resupply manifest, real consumption tracking, broadcasting, and some job logic.
- Database migration exists but may need to be run.

## Actionable Steps
1. **Finalize and Test Escalation Logic**
   - Run and verify all database migrations.
   - Complete any remaining stub/TODO logic (resupply manifest, consumption tracking, broadcasting, job scheduling).
   - Expand EmergencyMissionService for special missions as needed.
   - Implement or verify import delivery job for scheduled imports.
2. **Unit and Integration Testing**
   - Write and run unit tests for EscalationService, harvester deployment, mission creation, and import scheduling.
   - Run integration and simulation tests for end-to-end escalation flow, market order expiration, and cost optimization.
3. **Performance and Economic Validation**
   - Ensure escalation processing is performant (<100ms per order) and memory efficient.
   - Validate economic balance: AI uses players when possible, maintains market liquidity, and respects player opportunity windows.
4. **Documentation & Review**
   - Document all escalation logic, integration points, and test results in new or updated markdown files in docs/architecture/ai_manager/.
   - STOP if architectural blockers or major refactors are required; escalate to planning.
   - STOP if similar work is already complete; archive this task with reference.

## STOP/REVIEW Conditions
- STOP if architectural blockers or major refactors are required; escalate to planning.
- STOP if similar work is already complete; archive this task with reference.

## Acceptance Criteria
- [ ] All escalation logic is implemented, tested, and documented
- [ ] Database migration is run and verified
- [ ] EmergencyMissionService and ContractCreationService are fully functional
- [ ] Resupply manifest, consumption tracking, and import delivery jobs are complete
- [ ] Performance and economic balance criteria are met

## Agent Assignment
- **Agent:** Claude (or equivalent advanced AI/ML agent)

## Files to Create/Modify
- app/services/ai_manager/escalation_service.rb (finalize and test)
- app/services/ai_manager/emergency_mission_service.rb (expand as needed)
- app/services/ai_manager/contract_creation_service.rb (finalize as needed)
- app/services/ai_manager/resource_acquisition_service.rb (integration)
- app/jobs/harvester_completion_job.rb (verify job logic)
- app/models/scheduled_import.rb (verify model and migration)
- docs/architecture/ai_manager/ (add/update escalation documentation)

## Estimated Time
2-3 hours (finalization and testing)

## Priority
HIGH (Operational Reliability)