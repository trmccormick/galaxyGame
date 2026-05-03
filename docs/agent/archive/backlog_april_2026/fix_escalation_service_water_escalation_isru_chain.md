# Backlog Task: Fix EscalationService Water Escalation - ISRU Chain

## Problem
EscalationService water escalation logic creates generic Units::Robot with ice_extraction task, which is architecturally wrong. Luna water production comes from regolith processing via TEU (thermal_extraction_unit_mk1) + PVE (planetary_volatiles_extractor_mk1), not direct ice harvesting.

## Goals
- Correct water escalation to use actual ISRU unit architecture
- Water is byproduct of regolith processing, not primary target
- Fix foundational ISRU chain for Luna water production
- Align with precursor mission architecture

## Steps
1. Skip problematic spec: mark escalation_service_spec.rb:48 as xdescribe with comment "Pending ISRU chain redesign"
2. Update EscalationService to check for TEU/PVE deployment instead of creating robots
3. If missing: trigger precursor ISRU deployment (TEU + PVE)
4. If present but insufficient: deploy additional PVE units
5. Verify water production as regolith processing byproduct
6. Update spec once architecture is confirmed

## Acceptance Criteria
- Water escalation uses TEU + PVE units, not generic robots
- ISRU chain correctly implemented for Luna water production
- Spec updated to reflect correct architecture
- No more ice_extraction robots for water escalation

## Technical Details
**Files**:
- app/services/ai_manager/escalation_service.rb
- spec/services/ai_manager/escalation_service_spec.rb

**Current Issue**:
```ruby
# Wrong: creates generic robot for ice extraction
Units::Robot.create(task: :ice_extraction)
```

**Correct Implementation**:
```ruby
# Check for existing TEU/PVE deployment
if thermal_extraction_units.empty? || planetary_volatiles_extractors.insufficient?
  # Deploy precursor ISRU units
  deploy_thermal_extraction_unit
  deploy_planetary_volatiles_extractor
end
# Water comes as byproduct of regolith processing
```

**ISRU Chain**:
1. TEU (thermal_extraction_unit_mk1) - heats regolith to release volatiles
2. PVE (planetary_volatiles_extractor_mk1) - separates and collects water vapor
3. Water production is secondary byproduct, not primary extraction target

---

Created: 2026-03-08
Priority: HIGH (Corrects foundational ISRU logic)
Estimated Effort: 4-6 hours
Dependencies: Precursor mission architecture review
Agent Assignment: Claude Sonnet (architecture reasoning) or Gemini 2.5 Flash (implementation)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/fix_escalation_service_water_escalation_isru_chain.md