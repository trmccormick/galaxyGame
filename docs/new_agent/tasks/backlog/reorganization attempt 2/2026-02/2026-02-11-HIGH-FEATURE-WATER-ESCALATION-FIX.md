# Fix Water Escalation ISRU Chain

## Context
EscalationService water escalation logic uses generic robots for ice extraction instead of correct ISRU chain (TEU + PVE). Luna water production logic is architecturally wrong.

## Problem
- Water escalation creates generic Units::Robot with ice_extraction task
- Should use proper ISRU units: Thermal Extraction Unit (TEU) + Planetary Volatiles Extractor (PVE)
- Current implementation bypasses established ISRU architecture
- Generic robots don't have proper processing capabilities for water extraction

## Solution
Update EscalationService to deploy proper ISRU units (TEU/PVE) for water escalation instead of generic robots.

## Files to Modify
- `app/services/ai_manager/escalation_service.rb` - Update create_automated_harvester for water
- `spec/services/ai_manager/escalation_service_spec.rb` - Update tests for correct ISRU units

## Implementation Steps
1. Change water harvesting to create TEU and PVE units instead of generic robot
2. Update operational_data to match ISRU unit specifications
3. Add logic to check for precursor ISRU deployment if missing
4. Update specs to expect TEU/PVE units instead of robots
5. Remove ice_extraction robot creation for water escalation
6. Test with Luna settlement to ensure proper ISRU chain

## Acceptance Criteria
- Water escalation creates TEU and PVE units
- No more generic robots for water extraction
- ISRU chain properly implemented (TEU → PVE)
- Specs updated and passing
- Luna water production uses correct architecture

## Agent Assignment
0.33x - ISRU systems and escalation service specialist

## Priority
HIGH

## Stop Condition
Water escalation uses proper TEU/PVE ISRU chain

## Commit Message
fix: update water escalation to use TEU/PVE ISRU chain instead of generic robots</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/new_agent/tasks/backlog/2026-02/2026-02-11-HIGH-FEATURE-WATER-ESCALATION-ISRU-CHAIN.md