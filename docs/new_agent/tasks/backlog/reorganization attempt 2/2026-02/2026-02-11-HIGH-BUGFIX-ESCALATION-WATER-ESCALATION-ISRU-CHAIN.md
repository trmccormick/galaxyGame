# Synthesis Report (current state analysis) → STOP

## Target File
fix_escalation_service_water_escalation_isru_chain.md

## Issue
EscalationService water escalation logic uses generic robots for ice extraction instead of correct ISRU chain (TEU + PVE). Luna water production logic is architecturally wrong.

## Diagnostic Command
N/A (service/model task)

## Tasks
- Update EscalationService to use TEU/PVE units
- Trigger precursor ISRU deployment if missing
- Update spec for correct architecture
- Remove ice_extraction robots for water escalation

## Priority
HIGH
