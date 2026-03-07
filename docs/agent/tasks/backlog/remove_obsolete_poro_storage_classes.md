# Task: Remove Obsolete PORO Storage Classes

**Priority:** LOW  
**Agent:** GPT-4.1  
**Impact:** ~6-9 failures eliminated (base + solid + gas specs)

## Problem
Storage::BaseStorage and subclasses are legacy PORO objects predating the Inventory + Units::BaseUnit pattern. No production code references them — only their own specs. The real storage system is Inventory (AR, polymorphic) with specialized storage routed through base_units.

## Delete these files
app/models/storage/base_storage.rb  
app/models/storage/gas_storage.rb  
app/models/storage/liquid_storage.rb  
app/models/storage/solid_storage.rb  
app/models/storage/energy_storage.rb  
spec/models/storage/base_storage_spec.rb  
spec/models/storage/solid_storage_spec.rb  
spec/models/storage/gas_storage_spec.rb

## Keep these files — active AR system
app/models/inventory.rb  
app/models/storage/surface_storage.rb  
app/models/storage/material_pile.rb  
app/models/storage/storage_manager.rb

## Verify nothing breaks
docker exec -it web bash -c 'unset DATABASE_URL && \
  RAILS_ENV=test bundle exec rspec spec/models/inventory_spec.rb \
  --format documentation 2>&1 | tail -20'

## Commit message
"Remove obsolete PORO storage classes — superseded by Inventory system"