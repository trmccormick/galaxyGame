# Remove Obsolete PORO Storage Classes Task

**Agent**: GPT-4.1
**Priority**: MEDIUM
**Status**: 📋 PENDING - Task created, ready for execution
**Estimated Effort**: 25 minutes
**Impact**: 215 → ~206-212 failures (~6-9 eliminated)

## Description
Delete legacy PORO storage classes superseded by Inventory + Units::BaseUnit architecture. These were early prototypes that have been replaced by the JSON-driven unit system.

## Files to Delete
- app/models/storage/base_storage.rb
- app/models/storage/gas_storage.rb
- app/models/storage/liquid_storage.rb
- app/models/storage/solid_storage.rb
- app/models/storage/energy_storage.rb
- spec/models/storage/base_storage_spec.rb
- spec/models/storage/solid_storage_spec.rb
- spec/models/storage/gas_storage_spec.rb

## Files to Keep
- Inventory (ActiveRecord model)
- SurfaceStorage (surface operations)
- MaterialPile (loose materials)
- StorageManager (coordination service)

## Validation Steps
1. Run full RSpec suite to confirm baseline (215 failures)
2. Delete all listed files
3. Run RSpec again to confirm impact (~206-212 failures expected)
4. Verify no references remain in codebase (grep search)
5. Commit with message: "Remove obsolete PORO storage classes — superseded by Inventory system"

## Architecture Context
Storage is now handled by:
- Inventory: ActiveRecord model for persistent storage
- Units::BaseUnit: JSON-driven units with storage capabilities
- SurfaceStorage: Planetary surface storage operations
- MaterialPile: Temporary loose material handling