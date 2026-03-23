# GALAXY GAME: Cycler-Adjacent Escalation (Pathfinding Stub)
**Status:** NEW **Priority:** HIGH **Agent:** GPT-4.1 **Est:** 20min

## 3 NEW TIERS (No pathfinding needed)

ROBOT_CRITICAL=['robot_repair_kit','spare_parts'] → robot_maintenance
SURVIVAL_CRITICAL+=['medicine'] → emergency_mission  
CYCLER_IMPORT → settlement.system.adjacent_systems.first.can_supply?

## EXECUTION

### Phase 1: Code Location
```bash
grep -r "determine_escalation_strategy\|can_harvest_locally" app/services/ app/models/
git checkout -b feature/galaxy-cycler-escalation
Phase 2: Add Tiers
Add ROBOT_CRITICAL/SURVIVAL_CRITICAL constants

Expand case statement with robot_maintenance_deployment

Add has_adjacent_cycler? stub method

Create handle_robot_maintenance_deployment

Phase 3: Test Updates
ruby
# robot_repair_kit test
let(:repair_order) { create(:market_order, resource: 'robot_repair_kit') }

# medicine emergency test  
let(:medicine_order) { create(:market_order, resource: 'medicine') }
Phase 4: Green + Docs
bash
rspec spec/integration/ai_manager/escalation_integration_spec.rb
Update PHYSICS_HIERARCHY.md with Galaxy Game tiers

text

## Copy To GPT-4.1:

🌌 GALAXY GAME CYCLER ESCALATION [20min] Adjacent systems only

No pathfinding needed - cyclers go adjacent_systems only

NEW TIERS:

ROBOT_CRITICAL=['robot_repair_kit','spare_parts'] → robot_maintenance ✓

medicine → emergency_mission ✓

CYCLER_IMPORT → settlement.system.adjacent_systems.first

Phase 1: grep -r "determine_escalation_strategy" app/services/

File: docs/agent/tasks/active/galaxy_cycler_escalation.md

Production-ready Galaxy Game logistics

text

## Updated Physics Hierarchy Doc

LOCAL ISRU: water, O2, regolith, iron ✓
ROBOT CRITICAL: robot_repair_kit, spare_parts → NEW
SURVIVAL: oxygen, water, food, medicine → +medicine
ADJACENT CYCLER: settlement.system.adjacent_systems
SOL FALLBACK: Earth (training)