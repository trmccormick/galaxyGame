AI Manager — Bloat Audit & Surgical Refactor
MUST READ BEFORE DELETING CODE | 88 files → 8 core files max

Current State (Crime Scene)
text
$ find app/services/ai_manager -name "*.rb" | wc -l
→ 88 files, ~2MB bloat

**Duplicated Working Services**:
- UnitLookupService → isru_evaluator.rb (11KB), isru_optimizer.rb (15KB)
- ConstructionJobService → construction_service.rb (3KB)  
- ResourceTrackingService → resource_flow_simulator.rb (17KB)
- TaskExecutionEngine → mission_planner_service.rb (32KB)
Working Core (Keep Forever)
text
✅ task_execution_engine.rb → JSON mission coordination
✅ manager.rb → State machine + thresholds  
✅ unit_deployer.rb → Robot workforce deployment
✅ construction_coordinator.rb → ConstructionJobService wrapper
DELETE ON SIGHT (88 → 8)
text
❌ isru_evaluator.rb → Use UnitLookupService.find_unit()
❌ isru_optimizer.rb → Use operational_data JSON rates  
❌ resource_flow_simulator.rb → Use ResourceTrackingService
❌ decision_tree.rb → Use JSON mission_profiles decision logic
❌ economic_forecaster_service.rb → Use market data JSON
❌ mission_scorer.rb → Use survey_score thresholds
❌ expansion_service.rb → Use stockpile thresholds
❌ terraforming_manager.rb → Use ConstructionJobService
❌ wormhole_coordinator.rb → Use wormhole_station.json
Refactor Rules
text
1. **READ AI_MANAGER_COMMAND.md FIRST** or STOP
2. **No new data models** → settlement.inventory, geosphere.crust_composition
3. **Delete duplicated logic** → Delegate to existing services
4. **TaskExecutionEngine orchestrates** → No parallel simulators
5. **Synthesis Report format** → List deleted files + git commits
Audit Commands (Run First)
bash
# Count bloat
find app/services/ai_manager -name "*.rb" | wc -l

# Find hardcoded debt  
grep -r "PVE_DATA\|ISRU_UNITS\|resource_profile" app/services/ai_manager/

# Find duplicated services
grep -r "UnitLookupService\|ConstructionJobService" app/services/ai_manager/ --include="*.rb" | grep -v "task_execution_engine.rb"

# Generate deletion list
find app/services/ai_manager -name "*.rb" -not -name "task_execution_engine.rb" -not -name "manager.rb" | head -20
Success Criteria
text
✅ 88 files → 8 files maximum
✅ Zero "PVE_DATA" or "ISRU_UNITS" constants  
✅ All services delegate to UnitLookupService + ConstructionJobService
✅ TaskExecutionEngine orchestrates JSON missions
✅ Rake demos PASS: lunar_base:with_isru, ai_base_building:simulate
Last Updated: 2026-04-03
Target: Surgical reduction, no functionality lost

text
