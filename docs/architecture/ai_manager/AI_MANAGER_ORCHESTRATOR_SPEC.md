# AI Manager — Orchestrator Only
**89 Files Wrong** | **Rake Tasks = Source of Truth** | **Delegate Don't Duplicate**

## WORKING RAKE TOOLS (AI Manager Calls These)
✅ gcc_bootstrap.rake → CraftFactoryService + LaunchPaymentService
✅ lunar_base:with_isru.rake → UnitLookupService + settlement.inventory
✅ ai_base_building:simulate → MissionTaskRunnerService + JSON manifests
→ AI Manager = RAKE COORDINATOR, NOT REINVENTION

## CORE ORCHESTRATION PATTERN (8 Files)
manager.rb (State Machine)
└── market_monitor.tick() # Check Market::Order queue
↓
task_execution_engine.generate_manifest(order) # JSON output
↓
cycler_optimizer.submit(order, manifest) # AstroLift routing
↓
emergency_dispatch.check_crisis(order) # Eden Snap override

## WRONG vs RIGHT (89 Files vs 8 Files)
WRONG (Delete These):
class IsruEvaluator
ISRU_UNITS = { ... } # Duplicate UnitLookupService
end

RIGHT (Keep These):
class TaskExecutionEngine
def generate_isru_manifest(order)
UnitLookupService.units_producing(order.resource_type)
end
end

## RAKE → AI MANAGER MAPPING (Exact Delegation)
rake gcc_bootstrap → LaunchPaymentService.pay_for_launch!
rake lunar_base → UnitLookupService.find_unit('PVE_MK1')
rake ai_base_building → MissionTaskRunnerService.run(manifest)
→ AI Manager reads rake patterns, delegates to same services

## SURGICAL DELETION CRITERIA
DELETE if contains:

ISRU_UNITS, GAS_COMPOSITION, resource_profile constants

Standalone simulators (not calling Rails models/services)

Hardcoded yields, costs, GCC values

KEEP if calling:

UnitLookupService, Market::Order, settlement.inventory

CraftFactoryService, LaunchPaymentService

JSON operational_data patterns
