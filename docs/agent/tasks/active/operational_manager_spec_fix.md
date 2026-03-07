# OperationalManagerSpec Fix
**Task ID**: OperationalManagerSpec_Fix
**Priority**: CRITICAL
**Status**: PENDING
**Created**: March 5, 2026

## Description
spec/services/ai_manager/operational_manager_spec.rb - 6 failures
Continue ai_manager cluster cleanup (16/16 mission_scorer → operational_manager)

## ⚠️ CRITICAL DATABASE SAFETY WARNING
**ALL RSpec commands must unset DATABASE_URL to prevent catastrophic development database corruption.**  
**Correct:** `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`  
**Incorrect:** `docker exec -it web rspec ...` (will wipe dev database!)  

## Steps
1. DIAGNOSE: docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/operational_manager_spec.rb --format documentation'
2. FIX failure patterns (method arity, factory traits, threshold logic)
3. TEST: docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/operational_manager_spec.rb'
4. COMMIT: "Fix operational_manager_spec.rb (6→0, 22/22 ai_manager GREEN)"
5. REPORT: 234 → 228 failures

## Dependencies
None (ai_manager cluster continuation)

## Estimated Time
15 minutes

## RSpec Impact
234 → 228 failures (42% → 45%)

## Handoff Agent
GPT-4.1 (diagnosis + execution)