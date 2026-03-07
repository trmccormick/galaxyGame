# Settlement Model Cleanup Task

**Agent**: GPT-4.1
**Priority**: MEDIUM
**Status**: 📋 PENDING - Task created, ready for execution
**Estimated Effort**: 30 minutes
**Impact**: 215 → 212 failures (3 eliminated)

## Description
Remove obsolete settlement STI subclasses and dome model that duplicate enum values and have no table. These were superseded by the BaseSettlement + Structures::* architecture.

## Files to Delete
- app/models/settlement/dome.rb (obsolete, no table)
- app/models/settlement/colony.rb (duplicate of root Colony)
- app/models/settlement/outpost.rb (empty, outpost is enum)
- app/models/settlement/habitat.rb (empty, no enum)
- app/models/settlement/settlement.rb (empty, name collision)
- app/models/settlement/city.rb (empty, city is enum)
- app/controllers/domes_controller.rb (references dead Dome)
- spec/models/dome_spec.rb (testing dead model)

## Files to Keep
- app/models/settlement/base_settlement.rb
- app/models/settlement/space_station.rb
- app/models/settlement/orbital_depot.rb
- app/models/settlement/colony.rb (root model)

## Validation Steps
1. Run full RSpec suite to confirm baseline (215 failures)
2. Delete all listed files
3. Run RSpec again to confirm impact (212 failures expected)
4. Verify no references remain in codebase (grep search)
5. Commit with message: "Remove obsolete settlement STI subclasses and dome model"

## Architecture Context
Settlement types are now represented as enums in BaseSettlement rather than STI subclasses. The Structures::* modules provide the actual functionality.