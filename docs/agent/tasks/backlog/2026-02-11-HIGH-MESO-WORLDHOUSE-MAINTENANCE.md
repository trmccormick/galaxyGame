# Worldhouse Maintenance (0x Subtask)

**Parent Epic:** worldhouse_progression_system.md
**Layer:** MESO (Surface Simulation)
**Created:** 2026-02-11
**Priority:** HIGH
**Status:** TODO

## Scope
Implement worldhouse-specific maintenance challenge logic (radiation, nutrient cycling, pressure regulation).

## Target Files
- app/services/worldhouse_maintenance.rb
- app/services/maintenance_monitor_service.rb

## Acceptance Criteria
- Maintenance events simulated (radiation, nutrient, pressure)
- Repair actions available and testable
- RSpec: maintenance event simulation, repair actions

## Implementation Steps
1. Create worldhouse_maintenance.rb service
2. Integrate with maintenance_monitor_service.rb
3. Write/extend RSpec for maintenance events and repairs

---
