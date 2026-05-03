# TASK: Refactor EscalationService#create_automated_harvester — No-Magic Robot Deployment
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-03-27
**Last Updated**: 2026-03-27

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Multi-step decision tree requiring architectural reasoning across inventory, manufacturing, and sourcing systems — not a simple fix
**Supervision Level**: 🟢 Autonomous OK — must stop at Synthesis Report before applying anything

---

## Context
`EscalationService#create_automated_harvester` currently calls `Units::Robot.create!` directly, bypassing the No-Magic Protocol entirely. This violates the core AI Manager principle: the AI cannot conjure units from nothing. A robot must either exist in settlement inventory (undeployed) or be built from available materials and infrastructure. GCC is only required when materials must be purchased from the market. This refactor replaces the direct `create!` call with a proper decision tree that respects the sourcing hierarchy and manufacturing constraints.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/services/ai_manager/planner.md` — No-Magic sourcing hierarchy (3 tiers)
- `docs/architecture/services/ai_manager/escalation_service.md` — Robot creation patterns and escalation rules
- `docs/architecture/services/ai_manager/priority_mapping.md` — 4-tier priority system, critical tier for life support
- `docs/architecture/services/ai_manager/governance_and_chaos.md` — Emergency requisition rules when disconnected
- `docs/architecture/services/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md` — Cost-benefit logic, GCC vs materials

> Do not create documentation during this task.
> Flag any gaps in your completion report instead.

---

## Problem Statement
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

---

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

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `galaxy_game/app/services/ai_manager/escalation_service.rb` | Core escalation logic | `#create_automated_harvester` line ~88 |
| `galaxy_game/spec/services/ai_manager/escalation_service_spec.rb` | Spec — must be rewritten to test correct pattern | line ~27 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/models/concerns/has_units.rb` | `#add_unit` and `#install_unit` patterns |
| `galaxy_game/app/models/units/robot.rb` | Robot model — check for deploy/activate methods |
| `galaxy_game/app/models/settlement/base_settlement.rb` | Inventory query patterns |
| `galaxy_game/app/models/units/base_unit.rb` | `load_unit_info` — confirms operational_data loaded from blueprint |
| `galaxy_game/config/initializers/game_constants.rb` | `AI_PRIORITIES` — life support is critical tier |

### Migration
- [ ] No migration needed

---

## Implementation Steps

> Read ALL reference files before touching any implementation file.
> Produce Synthesis Report after research, before writing any code.

### Step 1 — Research phase (read only, no changes)
```bash
docker exec -it web bash -c 'sed -n "88,140p" galaxy_game/app/services/ai_manager/escalation_service.rb'
docker exec -it web bash -c 'sed -n "15,55p" galaxy_game/app/models/concerns/has_units.rb'
docker exec -it web bash -c 'grep -n "def inventory\|undeployed\|unit_type\|available" galaxy_game/app/models/settlement/base_settlement.rb | head -20'
docker exec -it web bash -c 'grep -n "def " galaxy_game/app/models/units/robot.rb | head -20'
docker exec -it web bash -c 'grep -n "robotics_assembly\|ManufacturingJob\|manufacturing" galaxy_game/app/services/ai_manager/escalation_service.rb | head -10'
```

### Step 2 — Produce Synthesis Report and STOP

After research, produce the report (format below) and wait for approval.

### Step 3 — Implement decision tree in `create_automated_harvester`

Replace the direct `Units::Robot.create!` call with this decision tree:
```ruby
def self.create_automated_harvester(settlement, material, quantity)
  blueprint_id = harvester_blueprint_for(material)
  return { status: :blocked, reason: 'No blueprint for material' } unless blueprint_id

  # Step 1 — Check inventory for undeployed robot
  existing = find_undeployed_harvester(settlement, blueprint_id)
  if existing
    return deploy_harvester(existing, material, quantity)
  end

  # Step 2 — Check if AI can build one
  if can_build_harvester?(settlement, blueprint_id)
    return queue_harvester_build(settlement, blueprint_id, material, quantity)
  end

  # Step 3 — Escalate through sourcing tiers
  # (defer to MissionPlannerService sourcing hierarchy)
  { status: :blocked, reason: 'Insufficient inventory and manufacturing capability' }
end
```

> Implement `harvester_blueprint_for`, `find_undeployed_harvester`, `deploy_harvester`,
> `can_build_harvester?`, and `queue_harvester_build` as private methods.
> Match existing private method patterns in the service file.

### Step 4 — Implement `can_build_harvester?`

Check facility and materials — GCC not required if both are present:
```ruby
def self.can_build_harvester?(settlement, blueprint_id)
  has_robotics_facility?(settlement) &&
    has_required_materials?(settlement, blueprint_id)
end

def self.has_robotics_facility?(settlement)
  settlement.base_units
    .any? { |u| u.unit_type == 'robotics_assembly_line' }
end
```

> Verify the correct `unit_type` string for robotics assembly line
> by checking existing unit blueprints before implementing.

### Step 5 — Rewrite spec to test correct pattern

The spec must test the decision tree, not mock `Units::Robot.create!` directly:
```ruby
describe '.create_automated_harvester' do
  context 'when undeployed harvester exists in inventory' do
    it 'deploys existing robot without creating a new one' do
      # setup existing undeployed HRV-400 in settlement
      # expect deploy called, not create!
    end
  end

  context 'when no robot in inventory but facility and materials available' do
    it 'queues a manufacturing job' do
      # setup robotics_assembly_line + materials
      # expect ManufacturingJob queued
    end
  end

  context 'when neither inventory nor build capability available' do
    it 'returns blocked status' do
      # expect { status: :blocked }
    end
  end
end
```

> Write specs that test observable behavior, not internal `create!` calls.

---

## Synthesis Report Format
```
RESEARCH FINDINGS
Inventory query pattern for undeployed units: [exact method]
HasUnits#add_unit signature: [confirmed]
Robotics assembly line unit_type string: [confirmed or not found]
ManufacturingJob exists: [yes/no]
Existing private methods in escalation_service: [list]

PROPOSED DECISION TREE
[bullet list of each private method with inputs/outputs]

RISKS
[any shared code, factory impacts, other callers of create_automated_harvester]

OPEN QUESTIONS
[anything not resolved by research]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Isolation run**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec galaxy_game/spec/services/ai_manager/escalation_service_spec.rb'
```

2. **AI manager specs**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec galaxy_game/spec/services/ai_manager/'
```

3. **Full suite**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] `create_automated_harvester` never calls `Units::Robot.create!` directly
- [ ] Decision tree checks inventory before attempting build
- [ ] Build check verifies facility AND materials (not GCC)
- [ ] GCC only checked if materials must be purchased from market
- [ ] Blocked status returned clearly when all options exhausted
- [ ] Spec tests decision tree behavior, not internal `create!` mock
- [ ] Isolation run: 0 failures
- [ ] No regressions in `spec/services/ai_manager/`

---

## Stop Conditions — escalate to user immediately if:
- Inventory query pattern for undeployed units not found
- `robotics_assembly_line` unit_type string not confirmed in blueprints
- `ManufacturingJob` model does not exist or has different interface
- Decision tree requires architectural decisions beyond what docs cover
- Any other callers of `create_automated_harvester` found that would break

---

## Commit Instructions
Use single quotes in zsh. Run git on host:
```bash
git add galaxy_game/app/services/ai_manager/escalation_service.rb
git add galaxy_game/spec/services/ai_manager/escalation_service_spec.rb
git commit -m 'refactor: escalation_service — No-Magic robot deployment decision tree'
git push
```

---

## Documentation
- [ ] No doc changes needed — `docs/architecture/services/ai_manager/escalation_service.md` already covers this pattern

---

## Dependencies
**Blocked by**: none
**Blocks**: none
**Related tasks**: `2026-03-26-HIGH-FEATURE-MISSION-PLANNER-ORPHANED-LOGIC.md` — shares No-Magic sourcing hierarchy

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned