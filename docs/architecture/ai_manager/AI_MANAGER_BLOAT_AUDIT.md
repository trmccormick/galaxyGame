AI Manager — Bloat Audit & Refactor Roadmap
DOCUMENTATION ONLY | 88 files → 8 core files target | No code deletion

Current Reality (Audit)
text
$ find app/services/ai_manager -name "*.rb" | wc -l
→ **88 files, ~2MB** duplicating working services

**Duplication Mapping**:
UnitLookupService.exists → isru_evaluator.rb (11KB hardcoded)
ConstructionJobService.exists → construction_service.rb (3KB parallel)
ResourceTrackingService.exists → resource_flow_simulator.rb (17KB reinvention)
TaskExecutionEngine.exists → mission_planner_service.rb (32KB bloat)
Proven Working Core (Reference Implementation)
text
✅ **task_execution_engine.rb** → JSON mission coordination (rake proven)
✅ **manager.rb** → State machine + thresholds  
✅ **ai_base_building.rake** → lunar_precursor → Base complete
✅ **lunar_base:with_isru.rake** → TEU→PVE→I-beams working
Refactoring Target (88 → 8 files)
text
**KEEP** (Orchestration layer):
- task_execution_engine.rb → JSON mission coordinator
- manager.rb → Monitors thresholds → Triggers missions  
- unit_deployer.rb → Robot workforce management
- construction_coordinator.rb → ConstructionJobService wrapper

**CONSOLIDATE** (Delegate to existing services):
- isru_evaluator.rb → UnitLookupService.find_unit()
- resource_flow_simulator.rb → ResourceTrackingService.track_inventory_snapshot()
- mission_scorer.rb → JSON mission_profile priorities
Agent Rules (Enforce Before Coding)
text
1. **READ THIS + AI_MANAGER_COMMAND.md FIRST** or STOP
2. **No parallel data models** → Use settlement.inventory, geosphere.crust_composition
3. **Delegate, don't duplicate** → UnitLookupService, ConstructionJobService exist
4. **TaskExecutionEngine orchestrates** → No standalone simulators
5. **Rake demos are SOURCE OF TRUTH** → Must pass post-refactor
Audit Commands (Run Before Refactoring)

# Measure bloat baseline
find app/services/ai_manager -name "*.rb" | wc -l

# Debt markers (hardcoded constants)
grep -r "PVE_DATA\|ISRU_UNITS\|resource_profile" app/services/ai_manager/

# Duplication detection
grep -r "UnitLookupService\|ConstructionJobService" app/services/ai_manager/ --include="*.rb" | grep -v "task_execution_engine.rb"
Success Metrics (Post-Refactor)
text
✅ **File count**: 88 → 8 maximum  
✅ **Zero hardcoded constants**: No PVE_DATA, ISRU_UNITS
✅ **Rake demos PASS**: lunar_base:with_isru, ai_base_building:simulate
✅ **All services delegate**: UnitLookupService + ConstructionJobService
✅ **TaskExecutionEngine orchestrates**: JSON missions only
Last Updated: 2026-04-03
Status: DOCUMENTATION → No code changes

text

