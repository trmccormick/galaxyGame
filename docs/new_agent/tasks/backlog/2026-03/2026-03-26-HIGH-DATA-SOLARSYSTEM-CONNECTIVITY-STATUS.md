# 2026-03-26-HIGH-DATA-SOLARSYSTEM-CONNECTIVITY-STATUS.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: DATA
**Name**: Data Foundation SolarSystem Connectivity Status

## Context
The Mission Planner needs to know whether a solar system is connected to the wider network (Earth/Sol imports available) or orphaned (cut off from external supply). This is a system-level property - if a system is orphaned, every settlement loses access to Network Import (Tier 3 sourcing).

## Problem
No data foundation exists to track solar system connectivity status. Mission Planner cannot determine if systems are connected to Earth/Sol imports or orphaned from external supply chains.

## Files
- Target: SolarSystem model
- Related: Mission Planner service

## Steps
1. Add connectivity_status field to SolarSystem model
2. Define possible statuses (connected/orphaned)
3. Create migration to add the field
4. Update model validations and defaults
5. Test data foundation works correctly

## Acceptance Criteria
- SolarSystem model has connectivity_status field
- Systems can be marked as connected or orphaned
- Mission Planner can query connectivity status
- Data foundation supports network import logic

## Stop Condition
- SolarSystem connectivity status data foundation implemented
- Model can track connected vs orphaned systems
- Migration created and tested

## Commit
`feat: add solar system connectivity status data foundation`