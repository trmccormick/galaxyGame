# Fix Missing Domes Database Table
**Task ID**: Fix_Missing_Domes_Table
**Priority**: MEDIUM
**Status**: PENDING
**Created**: March 6, 2026

## Description
After fixing dome_spec.rb namespace issues, tests now fail with PG::UndefinedTable: relation "domes" does not exist
The Settlement::Dome model exists but the database table "domes" is missing

## Root Cause
The namespace fix revealed that the domes table migration was never created or run
Settlement::Dome model exists in code but no corresponding database table

## Files Involved
- app/models/settlement/dome.rb (model exists)
- db/migrate/ (check for dome-related migrations)
- spec/models/dome_spec.rb (now properly namespaced but blocked by missing table)

## Steps
1. CHECK if dome migration exists in db/migrate/
2. IF exists: Run migration with docker exec -it web bash -c 'bundle exec rake db:migrate'
3. IF missing: Create migration for domes table
4. RUN migration in test environment: docker exec -it web bash -c 'RAILS_ENV=test bundle exec rake db:migrate'
5. TEST: docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/dome_spec.rb'
6. VERIFY: 3/3 specs green
7. COMMIT: "Add domes table migration and run in test environment"

## Dependencies
None (namespace fix completed)

## Estimated Time
15-30 minutes

## RSpec Impact
Unblocks dome_spec.rb execution (3 failures currently blocked)

## Success Criteria
rspec spec/models/dome_spec.rb → 3/3 green (table exists)

## Handoff Agent
Gemini Flash (migration work, database operations)