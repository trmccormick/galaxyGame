# Fix DatabaseCleaner Connection Error
**Task ID**: Fix_DatabaseCleaner_Connection
**Priority**: MEDIUM
**Status**: PENDING
**Created**: March 6, 2026

## Description
DatabaseCleaner connection error blocking escalation_service_spec.rb
spec/rails_helper.rb before(:suite) hook fails with PG::ConnectionBad: connection is closed
DatabaseCleaner.clean_with(:deletion) cannot establish connection at suite load time

## ⚠️ CRITICAL DATABASE SAFETY WARNING
**ALL RSpec commands must unset DATABASE_URL to prevent catastrophic development database corruption.**  
**Correct:** `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`  
**Incorrect:** `docker exec -it web rspec ...` (will wipe dev database!)  

## Files Involved
- spec/rails_helper.rb
- spec/services/ai_manager/escalation_service_spec.rb
- spec/integration/ai_manager/escalation_integration_spec.rb

## Steps
1. Run RAILS_ENV=test bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1'); puts 'DB OK'" to verify DB health
2. DIAGNOSE: docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/escalation_service_spec.rb --format documentation'
3. IDENTIFY why this spec triggers connection failure when others don't
4. FIX without breaking other specs
5. TEST: docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/escalation_service_spec.rb'
6. RUN full escalation spec suite — target green
7. COMMIT: "Fix DatabaseCleaner connection issue; green escalation specs"

## Dependencies
None

## Estimated Time
30-45 minutes

## RSpec Impact
245 → 227 failures (18 failures eliminated)

## Success Criteria
escalation_service_spec.rb loads and runs without DatabaseCleaner connection errors

## Handoff Agent
Gemini Flash (autonomous debugging capability needed for iterative diagnosis)