# 2026-03-27-HIGH-REFACTOR-ESCALATION-SERVICE-NO-MAGIC-ROBOT-DEPLOYMENT

**Agent**: 0.33x  
**Priority**: HIGH  
**Type**: refactor  
**Status**: BACKLOG  

## Context
`EscalationService#create_automated_harvester` currently calls `Units::Robot.create!` directly, bypassing the No-Magic Protocol entirely. This violates the core AI Manager principle: the AI cannot conjure units from nothing. A robot must either exist in settlement inventory (undeployed) or be built from available materials and infrastructure. GCC is only required when materials must be purchased from the market. This refactor replaces the direct `create!` call with a proper decision tree that respects the sourcing hierarchy and manufacturing constraints.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/services/ai_manager/planner.md` — No-Magic sourcing hierarchy (3 tiers)
- `docs/architecture/services/ai_manager/escalation_service.md` — Robot creation patterns and escalation rules
- `docs/architecture/services/ai_manager/priority_mapping.md` — 4-tier priority system, critical tier for life support
- `docs/architecture/services/ai_manager/governance_and_chaos.md` — Emergency requisition rules when disconnected
- `docs/architecture/services/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md` — Cost-benefit logic, GCC vs materials

## Problem
`create_automated_harvester` uses `Units::Robot.create!` to instantiate a robot directly without checking inventory, manufacturing capability, or material availability. This violates the No-Magic Protocol and bypasses `load_unit_info` which loads operational defaults from the JSON blueprint.

**Error output**:
```
#<Units::Robot> received :create! with unexpected arguments
expected: ({unit_type: "robot", operational_data: {...5 keys...}})
     got: ({unit_type: "robot", operational_data: {...6 keys including deployment_site...}})
```

**Current behavior**: Service creates a robot from nothing using hardcoded `operational_data`.

**Expected behavior**: Service follows the No-Magic decision tree:
1. Check settlement inventory for undeployed HRV-400
2. If not found — check if AI can build one (facility + materials available)
3. If can build — queue ManufacturingJob (no GCC needed if materials owned)
4. If cannot build — escalate through 3-tier sourcing hierarchy
5. If all fail — return BLOCKED status, do not create robot

## Blueprint Reference

**Robot Blueprint**: `hrv_400_resource_harvester_mk1`
**File**: `data/json-data/blueprints/units/robots/resource/hrv_400_resource_harvester_mk1_bp.json`
**Operational Data**: `data/json-data/operational_data/units/robots/resource/hrv_400_resource_harvester_mk1_data.json`

**Required facility**: `robotics_assembly_line`

**Required materials to build**:
| Material | Amount |
|---|---|
| `advanced_composites` | 120 kg |
| `hydraulic_systems` | 50 kg |
| `navigation_module` | 1 unit |
| `communication_relay` | 1 unit |
| `radiation_shielding` | 30 kg |

**Purchase cost**: 85,000 GCC (only if materials unavailable and market accessible)

## Files
- `galaxy_game/app/services/ai_manager/escalation_service.rb` — Core escalation logic, `#create_automated_harvester` line ~88
- `galaxy_game/spec/services/ai_manager/escalation_service_spec.rb` — Spec — must be rewritten to test correct pattern, line ~27

## Steps
1. **Research phase** (read only, no changes)
   - Read ALL reference files before touching any implementation file
   - Produce Synthesis Report after research, before writing any code

2. **Implement decision tree in `create_automated_harvester`**
   - Replace the direct `Units::Robot.create!` call with decision tree
   - Implement `harvester_blueprint_for`, `find_undeployed_harvester`, `deploy_harvester`, `can_build_harvester?`, and `queue_harvester_build` as private methods

3. **Implement `can_build_harvester?`**
   - Check facility and materials — GCC not required if both are present
   - Verify the correct `unit_type` string for robotics assembly line

4. **Rewrite spec to test correct pattern**
   - Test decision tree behavior, not internal `create!` calls

## Acceptance Criteria
- [ ] `create_automated_harvester` never calls `Units::Robot.create!` directly
- [ ] Decision tree checks inventory before attempting build
- [ ] Build check verifies facility AND materials (not GCC)
- [ ] GCC only checked if materials must be purchased from market
- [ ] Blocked status returned clearly when all options exhausted
- [ ] Spec tests decision tree behavior, not internal `create!` mock
- [ ] Isolation run: 0 failures
- [ ] No regressions in `spec/services/ai_manager/`

## Stop Conditions
- Inventory query pattern for undeployed units not found
- `robotics_assembly_line` unit_type string not confirmed in blueprints
- `ManufacturingJob` model does not exist or has different interface
- Decision tree requires architectural decisions beyond what docs cover
- Any other callers of `create_automated_harvester` found that would break

## Commit Message
`refactor: escalation_service — No-Magic robot deployment decision tree`