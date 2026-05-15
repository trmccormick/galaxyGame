# 2026-03-26-HIGH-FEATURE-MISSION-PLANNER-NO-MAGIC-SOURCING-LOGIC-ORPHANED-SYSTEM-SUPPORT.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: FEATURE
**Name**: Mission Planner No Magic Sourcing Logic Orphaned System Support

## Context
The Mission Planner (/admin/ai_manager/planner) evaluates whether missions are physically possible given current settlement state. It must never assume resources exist that aren't in inventory. This task implements the "No-Magic Protocol" - a 3-tier sourcing hierarchy checking local ISRU, intra-system trade, and network import in order.

## Problem
Mission Planner uses magic sourcing logic that assumes resources exist without checking inventory. Orphaned systems (no wormhole connection) need proper handling. No 3-tier sourcing hierarchy exists for realistic resource availability checking.

## Files
- Target: Mission Planner service and controller
- Related: GameConstants, operational_data JSON, wormhole connectivity logic

## Steps
1. Implement 3-tier sourcing hierarchy (local ISRU, intra-system trade, network import)
2. Add orphaned system detection and Tier 3 blocking
3. Remove all hardcoded magic numbers, use GameConstants and operational_data
4. Update mission evaluation to check actual inventory
5. Test no-magic protocol with various system connectivity scenarios

## Acceptance Criteria
- Mission Planner uses 3-tier sourcing hierarchy
- Orphaned systems lose network import access
- No hardcoded magic numbers in sourcing logic
- Missions evaluated based on actual inventory availability

## Stop Condition
- No-magic sourcing protocol implemented
- Orphaned system support working correctly
- Mission Planner accurately evaluates physical possibility

## Commit
`feat: implement no-magic sourcing logic and orphaned system support in mission planner`