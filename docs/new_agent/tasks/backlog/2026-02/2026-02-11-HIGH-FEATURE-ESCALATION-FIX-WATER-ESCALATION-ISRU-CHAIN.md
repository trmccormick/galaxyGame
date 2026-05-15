# TASK: Fix Water Escalation ISRU Chain
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: feature  
**Created**: 2026-02-11

---

## Problem Statement
EscalationService water escalation logic uses generic robots for ice extraction instead of correct ISRU chain (TEU + PVE). Luna water production logic is architecturally wrong.

## Goals
- Update EscalationService to use TEU/PVE units
- Trigger precursor ISRU deployment if missing
- Update spec for correct architecture
- Remove ice_extraction robots for water escalation

## Acceptance Criteria
- [ ] EscalationService uses TEU/PVE units for water escalation
- [ ] Precursor ISRU deployment triggered if missing
- [ ] Spec updated for correct architecture
- [ ] ice_extraction robots removed for water escalation

## Implementation Notes
- Review EscalationService water escalation logic
- Update for correct ISRU chain
- Validate with tests and code review

## Diagnostic/Debugging
N/A (service/model task)

## Related Files/Paths
- app/services/escalation_service.rb
- spec/services/escalation_service_spec.rb

## References
- Synthesis Report (2026-02-11)

---

