# 2026-03-26-HIGH-FEATURE-MISSION-PLANNER-NO-MAGIC-SOURCING-LOGIC-ORPHANED-SYSTEM-SUPPORT

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority feature for mission planner no-magic sourcing logic and orphaned system support
**Supervision Level**: 🔴 Watched carefully

## Context
Mission Planner diagnostic tool must evaluate mission feasibility without assuming resources exist. Implements No-Magic Protocol with 3-tier sourcing hierarchy: local ISRU, intra-system trade, network import. Orphaned systems permanently lose Tier 3 access. All physics from GameConstants and operational_data JSON.

## Problem Statement
Mission Planner has no sourcing hierarchy, no orphaned system awareness, no tug dependency check, no life support runway gate. Cannot determine mission feasibility.

**Expected**: Planner runs full No-Magic sourcing check, gates on life support runway, blocks on missing tug, disables Tier 3 for orphaned systems.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/services/ai_manager/mission_planner_service.rb` | Core planning logic | Implement No-Magic sourcing hierarchy and orphaned system checks |
| `app/controllers/admin/ai_manager_controller.rb` | Planner controller action | Add connectivity detection and orphaned system awareness |
| `app/views/admin/ai_manager/planner.html.erb` | Planner UI | Add orphaned alert and import toggle |

### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/views/admin/ai_manager/_orphaned_connection_alert.html.erb` | Orphaned system warning banner | Create partial for orphaned system alerts |
| `docs/architecture/ai_manager_planner.md` | No-Magic protocol documentation | Document sourcing hierarchy and orphaned system constraints |

## Implementation Steps
1. **Research phase**: Read all reference files, run diagnostics to understand current state
2. **Controller update**: Add connectivity detection and orphaned system awareness to planner action
3. **Service implementation**: Implement 3-tier sourcing hierarchy in MissionPlannerService
4. **UI updates**: Add orphaned connection alert and import toggle to planner view
5. **Documentation**: Create ai_manager_planner.md documenting No-Magic protocol

## Acceptance Criteria
- [ ] Mission Planner checks resource availability before approving missions
- [ ] Orphaned systems lose access to Tier 3 network imports
- [ ] Tug dependency check blocks missions without available tugs
- [ ] Life support runway gate prevents missions that would deplete life support
- [ ] All physics values from GameConstants and operational_data JSON

## Stop Conditions
- Breaking existing mission planning functionality
- Changes beyond mission planner service and related components

## Commit Instructions
```bash
git add app/services/ai_manager/mission_planner_service.rb
git add app/controllers/admin/ai_manager_controller.rb
git add app/views/admin/ai_manager/planner.html.erb
git add app/views/admin/ai_manager/_orphaned_connection_alert.html.erb
git add docs/architecture/ai_manager_planner.md
git commit -m "feat: Mission planner no-magic sourcing logic and orphaned system support"
```