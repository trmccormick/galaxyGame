# Task: Settlement Model Cleanup

**Priority:** HIGH  
**Agent:** GPT-4.1  
**Impact:** ~206-209 → ~203-206 failures (dome spec)

## Problem
Several settlement models are obsolete or empty STI subclasses that duplicate enum values already on BaseSettlement. These cause test failures and architectural confusion.

## Delete these files entirely
- app/models/settlement/dome.rb (no table, obsolete)
- app/models/settlement/colony.rb (duplicate of root Colony)
- app/models/settlement/outpost.rb (empty, outpost is enum value)
- app/models/settlement/habitat.rb (empty, no enum value)
- app/models/settlement/settlement.rb (empty, name collision)
- app/models/settlement/city.rb (empty, city is enum value)
- app/controllers/domes_controller.rb (references dead Dome model)
- spec/models/dome_spec.rb (testing dead model)

## Do NOT delete
- app/models/colony.rb (root level, government layer, 6/6 green)
- app/models/settlement/base_settlement.rb
- app/models/settlement/space_station.rb
- app/models/settlement/orbital_depot.rb

## Verify after deletion
grep -r "Settlement::Dome\|Settlement::Colony\|Settlement::Outpost\|Settlement::Habitat\|Settlement::City" app/ spec/ --include="*.rb"

Remove any remaining references found.

## Command to run after changes
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ --format progress 2>&1 | tail -20'

## Commit message
"Remove obsolete settlement STI subclasses and dome model"