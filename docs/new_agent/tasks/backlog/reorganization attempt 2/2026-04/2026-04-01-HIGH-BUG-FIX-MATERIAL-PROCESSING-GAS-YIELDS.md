---

# TASK: Fix material_processing_service_spec.rb gas yield regression
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Surgical spec fix, single service, grep-revealed root cause  
**Supervision Level**: watched carefully  

---

## Context
MaterialProcessingService handles thermal/volatiles extraction from regolith. 6 specs failed post-Claude commits - gas composition (0.06/0.995?) + inventory deltas.

---

## Problem Statement
**Error output**:
spec/services/manufacturing/material_processing_service_spec.rb:46 # thermal_extraction job
spec/services/manufacturing/material_processing_service_spec.rb:62 # inventory update
spec/services/manufacturing/material_processing_service_spec.rb:94 # volatiles_extraction job
spec/services/manufacturing/material_processing_service_spec.rb:110 # gas composition

Current behavior: Wrong gas ratios, inventory mismatch post-job  
Expected behavior: Mars baseline yields (0.06/0.995?), correct inventory delta  

---

## Files Involved
- app/services/manufacturing/material_processing_service.rb (extraction logic)
- spec/services/manufacturing/material_processing_service_spec.rb (test cases)

---

## Steps
1. Run diagnostic: grep -n "gas|0.06|0.995|thermal_extraction|volatiles_extraction" spec/services/manufacturing/material_processing_service_spec.rb app/services/manufacturing/material_processing_service.rb | head -20
2. Review and correct gas yield and inventory update logic
3. Refactor and test until all targeted specs pass

---

## Acceptance Criteria
- All targeted specs pass
- Gas yields and inventory deltas match Mars baseline

---

## Stop Conditions
- All acceptance criteria met
- No regressions in material processing logic

---

## Commit Message
fix: correct gas yield and inventory update in MaterialProcessingService
