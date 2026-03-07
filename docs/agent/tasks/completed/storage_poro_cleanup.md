# Task C: Remove obsolete Storage PORO classes + specs (215 → ~206 failures)

**Priority:** HIGH  
**Agent:** GPT-4.1 Copilot (Agent mode enabled)  
**Impact:** 3+ instant failures gone, zero risk to live code

## Current Status (March 7, 2026)
- 4039 examples, 215 failures, 26 pending
- Biogas JSON migration ✅ complete
- These 3 storage specs test DEAD PORO code (grep confirmed no production refs)

## The Issue
- Storage::BaseStorage, GasStorage, LiquidStorage, SolidStorage, EnergyStorage POROs
- Only referenced in their own files + specs = 100% dead code
- Live system: Inventory(AR) + SurfaceStorage + MaterialPile + StorageManager
- specs/models/storage/base_storage_spec.rb, solid_storage_spec.rb, gas_storage_spec.rb all fail

## Your Tasks (EXACTLY)
1. Delete these model files:
   - app/models/storage/base_storage.rb
   - app/models/storage/gas_storage.rb
   - app/models/storage/liquid_storage.rb
   - app/models/storage/solid_storage.rb
   - app/models/storage/energy_storage.rb

2. Delete these specs:
   - spec/models/storage/base_storage_spec.rb
   - spec/models/storage/solid_storage_spec.rb
   - spec/models/storage/gas_storage_spec.rb

3. **MANDATORY** smoke test (protects dev DB):
   docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/inventory_spec.rb --format documentation'

4. If inventory_spec ✅ GREEN:
   git add . && git commit -m "refactor: remove obsolete PORO storage classes (Inventory system only)

   - Deleted BaseStorage, GasStorage, LiquidStorage, SolidStorage, EnergyStorage models
   - Deleted their specs (previously testing dead code)
   - Verified: inventory_spec.rb passes fully
   - Keeps live AR system: Inventory, SurfaceStorage, MaterialPile, StorageManager"

5. Report back:
   - New total failure count (expect 215 → 206-209)
   - inventory_spec.rb result (paste output)
   - git log --oneline -3

## Expected Outcome
3 specs deleted = 3+ failures gone instantly

inventory_spec passes = live storage system untouched

Total failures drop 215 → ~206-209

Ready for Task A (Dome cleanup, another 3 failures)

**Time Estimate:** 20 minutes

Start Phase 1: File deletions → inventory_spec test → commit if green.

DO NOT run full RSpec suite. Just inventory_spec smoke test.